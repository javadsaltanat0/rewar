import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/legal_document.dart';
import 'firebase_bootstrap.dart';

/// Loads versioned legal text from `legal_documents`.
///
/// Public read, admin-only write (see `firestore.rules`) — a user has to be
/// able to read the Terms before they have an account.
class LegalDocumentService {
  LegalDocumentService({FirebaseFirestore? firestore})
    : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  static const String collection = 'legal_documents';
  static const String termsDocId = 'terms_of_service';

  static bool get isPreviewMode => kDebugMode && !FirebaseBootstrap.isReady;

  /// Fetches the Terms of Service for [languageCode].
  ///
  /// Throws on failure rather than silently returning stale bundled text:
  /// consent must be recorded against the *current* wording, so the screen
  /// shows an error with a retry instead of quietly showing something else.
  /// The one exception is preview mode, where Firebase doesn't exist yet.
  Future<LegalDocument> fetchTerms(String languageCode) async {
    if (isPreviewMode) {
      debugPrint(
        'PREVIEW MODE: serving the bundled Terms of Service. '
        'Seed $collection/$termsDocId in Firestore for the real one.',
      );
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return bundledTerms(languageCode);
    }
    if (!FirebaseBootstrap.isReady) {
      throw StateError('Firebase is not configured — see FIREBASE_SETUP.md');
    }

    final snapshot = await _firestore
        .collection(collection)
        .doc(termsDocId)
        .get();
    if (!snapshot.exists) {
      throw StateError('$collection/$termsDocId has not been seeded');
    }
    final document = LegalDocument.fromMap(snapshot.data(), languageCode);
    if (document == null) {
      throw StateError('$collection/$termsDocId is malformed');
    }
    return document;
  }

  /// The same wording that gets seeded into Firestore, kept in the app so the
  /// screen is usable in preview mode before the backend exists.
  ///
  /// ⚠️ NOT LEGALLY REVIEWED. The Kurdish and Arabic renderings in particular
  /// were produced by translation, not by a qualified legal translator, and
  /// must be signed off before release — the language a user actually reads
  /// is the one they are agreeing to. Tracked in `PROGRESS.md`.
  static LegalDocument bundledTerms(String languageCode) => LegalDocument(
    version: bundledVersion,
    updatedAt: DateTime(2026, 7, 29),
    legalReviewed: false,
    sections: _sections[languageCode] ?? _sections['en']!,
  );

  /// Bump whenever the wording changes, so consent can be re-collected.
  static const int bundledVersion = 1;

  static final Map<String, List<LegalSection>> _sections = {
    'en': const [
      LegalSection(
        heading: 'YOUR AGREEMENT',
        body:
            'By using this App, you agree to be bound by, and to comply '
            'with, these Terms and Conditions. If you do not agree to these '
            'Terms and Conditions, please do not use this app.\n\n'
            'PLEASE NOTE: We reserve the right, at our sole discretion, to '
            'change, modify or otherwise alter these Terms and Conditions at '
            'any time. Unless otherwise indicated, amendments will become '
            'effective immediately. Please review these Terms and Conditions '
            'periodically. Your continued use of the App following the '
            'posting of changes and/or modifications will constitute your '
            'acceptance of the revised Terms and Conditions and the '
            'reasonableness of these standards for notice of changes. For '
            'your information, this page was last updated as of the date at '
            'the top of these terms and conditions.',
      ),
      LegalSection(
        heading: 'PRIVACY',
        body:
            'Please review our Privacy Policy, which also governs your use '
            'of this App, to understand our data practices regarding your '
            'personal information, travel bookings, and reservations.',
      ),
    ],
    'ku': const [
      LegalSection(
        heading: 'ڕێککەوتننامەکەت',
        body:
            'بە بەکارهێنانی ئەم ئەپە، ڕازی دەبیت بە پابەندبوون بەم مەرج و '
            'ڕێساییانە و جێبەجێکردنیان. ئەگەر ڕازی نیت بەم مەرج و ڕێساییانە، '
            'تکایە ئەم ئەپە بەکارمەهێنە.\n\n'
            'تێبینی: ئێمە مافی ئەوەمان هەیە، بە بڕیاری تەواوی خۆمان، کە لە '
            'هەر کاتێکدا ئەم مەرج و ڕێساییانە بگۆڕین یان دەستکارییان بکەین. '
            'مەگەر بە شێوەیەکی تر ئاماژەی پێ کرابێت، گۆڕانکارییەکان دەستبەجێ '
            'جێبەجێ دەبن. تکایە کات بە کات ئەم مەرج و ڕێساییانە بخوێنەوە. '
            'بەردەوامبوونت لە بەکارهێنانی ئەپەکە دوای بڵاوکردنەوەی '
            'گۆڕانکارییەکان، بە پەسەندکردنی مەرج و ڕێسا نوێکراوەکان و بە '
            'گونجاوی ئەم شێوازەی ئاگادارکردنەوە دادەنرێت. بۆ زانیاریت، ئەم '
            'پەڕەیە لە بەرواری سەرەوەی ئەم مەرج و ڕێساییانەدا نوێکراوەتەوە.',
      ),
      LegalSection(
        heading: 'تایبەتمەندی',
        body:
            'تکایە سیاسەتی تایبەتمەندیمان بخوێنەوە، کە هەروەها بەکارهێنانی '
            'ئەم ئەپە ڕێکدەخات، بۆ تێگەیشتن لە چۆنیەتی مامەڵەکردنمان لەگەڵ '
            'زانیارییە کەسییەکانت و حجز و گەشتەکانت.',
      ),
    ],
    'ar': const [
      LegalSection(
        heading: 'اتفاقيتك',
        body:
            'باستخدامك هذا التطبيق، فإنك توافق على الالتزام بهذه الشروط '
            'والأحكام والامتثال لها. إذا كنت لا توافق على هذه الشروط '
            'والأحكام، فيرجى عدم استخدام هذا التطبيق.\n\n'
            'يرجى الملاحظة: نحتفظ بالحق، وفقًا لتقديرنا المطلق، في تغيير هذه '
            'الشروط والأحكام أو تعديلها أو تبديلها في أي وقت. ما لم يُذكر '
            'خلاف ذلك، تصبح التعديلات سارية فور نشرها. يرجى مراجعة هذه '
            'الشروط والأحكام بشكل دوري. إن استمرارك في استخدام التطبيق بعد '
            'نشر التغييرات و/أو التعديلات يشكّل قبولًا منك للشروط والأحكام '
            'المعدّلة ولمعقولية هذه المعايير الخاصة بالإشعار بالتغييرات. '
            'للعلم، جرى آخر تحديث لهذه الصفحة بالتاريخ المذكور في أعلى هذه '
            'الشروط والأحكام.',
      ),
      LegalSection(
        heading: 'الخصوصية',
        body:
            'يرجى مراجعة سياسة الخصوصية الخاصة بنا، والتي تحكم أيضًا '
            'استخدامك لهذا التطبيق، لفهم ممارساتنا المتعلقة ببياناتك '
            'الشخصية وحجوزات السفر والحجوزات الخاصة بك.',
      ),
    ],
  };
}
