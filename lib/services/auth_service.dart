import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/registration.dart';
import 'firebase_bootstrap.dart';

/// Why a registration attempt failed. Screens map these to localized
/// strings — a raw Firebase message is never shown to the user.
enum AuthErrorKind {
  backendUnavailable,
  emailAlreadyInUse,
  invalidEmail,
  weakPassword,
  network,
  tooManyRequests,
  unknown,
}

class AuthException implements Exception {
  AuthException(this.kind, [this.debugMessage]);

  final AuthErrorKind kind;
  final String? debugMessage;

  @override
  String toString() => 'AuthException($kind): $debugMessage';
}

/// Account creation for the Register screen.
///
/// The password goes straight to Firebase Auth and is never written to
/// Firestore, logged, or held on a model object (`SECURITY.md` 6.1b).
/// The `users/{uid}` document holds only profile data.
class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _authOverride = auth,
      _firestoreOverride = firestore;

  final FirebaseAuth? _authOverride;
  final FirebaseFirestore? _firestoreOverride;

  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;
  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  /// Debug-only stand-in so the Register flow can be walked before Firebase
  /// exists. Same guard as [PasswordResetService.isPreviewMode]: gated on
  /// [kDebugMode], so a release build can never create a fake account.
  static bool get isPreviewMode => kDebugMode && !FirebaseBootstrap.isReady;

  /// Creates the account and its profile document.
  ///
  /// Does **not** verify the phone number — the Register screen sends the
  /// user on to the Verification Code screen for that.
  Future<void> register({
    required RegistrationDetails details,
    required String password,
  }) async {
    if (isPreviewMode) {
      debugPrint(
        'PREVIEW MODE: pretending to register '
        '${details.email}. No account was created.',
      );
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return;
    }
    if (!FirebaseBootstrap.isReady) {
      throw AuthException(AuthErrorKind.backendUnavailable);
    }

    final UserCredential credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: details.email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    } catch (e) {
      throw AuthException(AuthErrorKind.unknown, '$e');
    }

    final user = credential.user;
    if (user == null) {
      throw AuthException(AuthErrorKind.unknown, 'No user after signup.');
    }

    try {
      await user.updateDisplayName(details.fullName);
      // Required before any second factor can be enrolled — SECURITY.md 6.1.
      await user.sendEmailVerification();
    } catch (e) {
      // Non-fatal: the account exists. Surface in logs, not to the user.
      debugPrint('Post-signup profile step failed: $e');
    }

    await _writeProfile(uid: user.uid, details: details);
  }

  /// Writes `users/{uid}`. Only the fields the client is allowed to set —
  /// `role`, `emailVerified`, `phoneVerified` and the MFA flags are
  /// deliberately absent and are rejected by `firestore.rules` if a modified
  /// client tries to send them.
  Future<void> _writeProfile({
    required String uid,
    required RegistrationDetails details,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'name': details.fullName,
        'email': details.email,
        'phone': details.phoneE164,
        'dateOfBirth': Timestamp.fromDate(details.dateOfBirth),
        if (details.gender != null) 'gender': details.gender!.value,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'source': 'manual',
      });
    } on FirebaseException catch (e) {
      throw AuthException(AuthErrorKind.unknown, '${e.code}: ${e.message}');
    }
  }

  /// Records consent once the user accepts on the Terms of Service screen.
  ///
  /// [version] is stored alongside the timestamp so that when the wording
  /// changes you can tell who agreed to which text and re-prompt only those
  /// who haven't seen the current version. A timestamp alone can't answer
  /// that question.
  Future<void> recordTermsAcceptance(int version) async {
    if (isPreviewMode) {
      debugPrint(
        'PREVIEW MODE: pretending to record acceptance of terms '
        'version $version.',
      );
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return;
    }
    if (!FirebaseBootstrap.isReady) {
      throw AuthException(AuthErrorKind.backendUnavailable);
    }
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw AuthException(AuthErrorKind.unknown, 'No signed-in user.');
    }
    try {
      await _firestore.collection('users').doc(uid).set({
        'termsAcceptedAt': FieldValue.serverTimestamp(),
        'termsVersion': version,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw AuthException(AuthErrorKind.unknown, '${e.code}: ${e.message}');
    }
  }

  AuthException _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return AuthException(AuthErrorKind.emailAlreadyInUse, e.message);
      case 'invalid-email':
        return AuthException(AuthErrorKind.invalidEmail, e.message);
      case 'weak-password':
      case 'password-does-not-meet-requirements':
        return AuthException(AuthErrorKind.weakPassword, e.message);
      case 'network-request-failed':
        return AuthException(AuthErrorKind.network, e.message);
      case 'too-many-requests':
        return AuthException(AuthErrorKind.tooManyRequests, e.message);
      default:
        return AuthException(AuthErrorKind.unknown, '${e.code}: ${e.message}');
    }
  }
}
