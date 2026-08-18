/**
 * Cloud Functions for the password-reset-by-code flow.
 *
 * Why these exist at all: Firebase Auth has no built-in *code*-based password
 * reset for email — `sendPasswordResetEmail()` sends a clickable link. The
 * Verification Code screen's design requires a 6-digit code, so the email
 * branch is implemented here. (The phone/SMS branch needs none of this —
 * Firebase Auth's own phone verification generates and sends that code.)
 *
 * Security properties, per SECURITY.md:
 *  - The plaintext code is NEVER stored and NEVER returned to the client.
 *    Firestore holds only a salted SHA-256 hash of it.
 *  - The client has zero access to `password_reset_codes` (see
 *    firestore.rules); only the Admin SDK, which bypasses rules, touches it.
 *  - Account enumeration is prevented: sending always reports success,
 *    whether or not the email belongs to a real account.
 *  - Rate limited on send (60s between sends) and on verify (5 attempts),
 *    satisfying SECURITY.md 6.4.
 *  - Codes expire after 10 minutes.
 *  - No secrets live in this file. Email delivery goes through the "Trigger
 *    Email from Firestore" extension, which holds the SMTP credentials in
 *    extension config (SECURITY.md section 4).
 */

const crypto = require("crypto");
const { initializeApp } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");
const { getFirestore, FieldValue, Timestamp } =
  require("firebase-admin/firestore");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

initializeApp();
const db = getFirestore();

const CODE_LENGTH = 6;
const CODE_TTL_MS = 10 * 60 * 1000; // 10 minutes
const RESEND_COOLDOWN_MS = 60 * 1000; // must match _resendCooldown in Dart
const MAX_ATTEMPTS = 5;
const RESET_TOKEN_TTL_MS = 10 * 60 * 1000;

const COLLECTION = "password_reset_codes";

/** Stable, non-reversible document id for an email address. */
function docIdFor(email) {
  return crypto
    .createHash("sha256")
    .update(email.trim().toLowerCase())
    .digest("hex");
}

/** Salted hash of a code — what we actually persist. */
function hashCode(code, salt) {
  return crypto
    .createHash("sha256")
    .update(`${salt}:${code}`)
    .digest("hex");
}

/**
 * A cryptographically random 6-digit code.
 *
 * `randomInt` is used rather than `Math.random()` so the code is not
 * predictable from previously issued ones.
 */
function generateCode() {
  const max = 10 ** CODE_LENGTH;
  return String(crypto.randomInt(0, max)).padStart(CODE_LENGTH, "0");
}

/** Constant-time comparison, so a timing side channel can't leak the code. */
function safeEqual(a, b) {
  const bufA = Buffer.from(String(a));
  const bufB = Buffer.from(String(b));
  if (bufA.length !== bufB.length) return false;
  return crypto.timingSafeEqual(bufA, bufB);
}

function normalizeEmail(raw) {
  if (typeof raw !== "string") return null;
  const email = raw.trim().toLowerCase();
  // Deliberately permissive — real validation is "does an account exist".
  if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) return null;
  return email;
}

/**
 * Step 1 — generate a code, store its hash, and queue the email.
 *
 * Always resolves with `{ ok: true }`, even for an unknown address, so an
 * attacker can't use this endpoint to discover which emails are registered.
 */
exports.sendPasswordResetCode = onCall(
  { region: "us-central1", enforceAppCheck: false },
  async (request) => {
    const email = normalizeEmail(request.data && request.data.email);
    if (!email) {
      throw new HttpsError("invalid-argument", "A valid email is required.");
    }

    const ref = db.collection(COLLECTION).doc(docIdFor(email));
    const now = Date.now();

    // Rate limit before doing any work, and before revealing any latency
    // difference between known and unknown addresses.
    const existing = await ref.get();
    if (existing.exists) {
      const lastSentAt = existing.get("lastSentAt");
      const lastSentMs = lastSentAt ? lastSentAt.toMillis() : 0;
      if (now - lastSentMs < RESEND_COOLDOWN_MS) {
        throw new HttpsError(
          "resource-exhausted",
          "Please wait before requesting another code.",
          "too-many-attempts"
        );
      }
    }

    // Does this address actually have an account? We branch only on whether
    // we queue an email — the response is identical either way.
    let userExists = true;
    try {
      await getAuth().getUserByEmail(email);
    } catch (e) {
      if (e.code === "auth/user-not-found") {
        userExists = false;
      } else {
        logger.error("Auth lookup failed", e);
        throw new HttpsError("internal", "Could not send the code.");
      }
    }

    const code = generateCode();
    const salt = crypto.randomBytes(16).toString("hex");

    await ref.set(
      {
        codeHash: hashCode(code, salt),
        salt,
        expiresAt: Timestamp.fromMillis(now + CODE_TTL_MS),
        attempts: 0,
        lastSentAt: FieldValue.serverTimestamp(),
        createdAt: FieldValue.serverTimestamp(),
        // Cleared on a fresh send so an old token can't be reused.
        resetTokenHash: FieldValue.delete(),
        resetTokenExpiresAt: FieldValue.delete(),
      },
      { merge: true }
    );

    if (userExists) {
      // Consumed by the "Trigger Email from Firestore" extension, which owns
      // the SMTP credentials — no keys in this codebase.
      await db.collection("mail").add({
        to: [email],
        message: {
          subject: "Your Kurdistan Paradise verification code",
          text:
            `Your password reset code is ${code}.\n\n` +
            "It expires in 10 minutes. If you didn't request this, you can " +
            "safely ignore this email.",
          html:
            `<p>Your password reset code is <strong>${code}</strong>.</p>` +
            "<p>It expires in 10 minutes. If you didn't request this, you " +
            "can safely ignore this email.</p>",
        },
      });
    } else {
      logger.info("Reset requested for an address with no account.");
    }

    return { ok: true };
  }
);

/**
 * Step 2 — check a submitted code.
 *
 * On success returns a short-lived `resetToken`. That token proves the user
 * controls the mailbox; the Set New Password screen will exchange it (plus
 * the new password) via a separate function. Holding the token grants no
 * other privilege.
 */
exports.verifyPasswordResetCode = onCall(
  { region: "us-central1", enforceAppCheck: false },
  async (request) => {
    const email = normalizeEmail(request.data && request.data.email);
    const code = request.data && request.data.code;

    if (!email || typeof code !== "string" ||
        !new RegExp(`^\\d{${CODE_LENGTH}}$`).test(code)) {
      throw new HttpsError("invalid-argument", "Email and code are required.");
    }

    const ref = db.collection(COLLECTION).doc(docIdFor(email));

    // A transaction so concurrent guesses can't race past the attempt limit.
    const resetToken = await db.runTransaction(async (tx) => {
      const snap = await tx.get(ref);
      if (!snap.exists) {
        throw new HttpsError(
          "not-found", "No code was requested.", "expired-code"
        );
      }

      const attempts = snap.get("attempts") || 0;
      if (attempts >= MAX_ATTEMPTS) {
        throw new HttpsError(
          "resource-exhausted",
          "Too many attempts.",
          "too-many-attempts"
        );
      }

      const expiresAt = snap.get("expiresAt");
      if (!expiresAt || expiresAt.toMillis() < Date.now()) {
        throw new HttpsError(
          "deadline-exceeded", "The code expired.", "expired-code"
        );
      }

      const expectedHash = snap.get("codeHash");
      const salt = snap.get("salt");
      if (!expectedHash || !salt ||
          !safeEqual(hashCode(code, salt), expectedHash)) {
        tx.update(ref, { attempts: FieldValue.increment(1) });
        throw new HttpsError(
          "permission-denied", "Incorrect code.", "incorrect-code"
        );
      }

      // Correct. Burn the code immediately so it can't be replayed, and
      // issue the token the next screen will need.
      const token = crypto.randomBytes(32).toString("hex");
      tx.update(ref, {
        codeHash: FieldValue.delete(),
        salt: FieldValue.delete(),
        attempts: 0,
        resetTokenHash: crypto
          .createHash("sha256").update(token).digest("hex"),
        resetTokenExpiresAt:
          Timestamp.fromMillis(Date.now() + RESET_TOKEN_TTL_MS),
      });
      return token;
    });

    return { resetToken };
  }
);

/**
 * Step 3 (email branch) — set the new password.
 *
 * Called by the Reset Password screen with the `resetToken` issued by
 * `verifyPasswordResetCode`. The password is applied through the Admin SDK
 * and is never written to Firestore or logged.
 *
 * Revoking refresh tokens is the point of a password reset that people often
 * miss: without it, a session an attacker already holds keeps working after
 * the legitimate owner "recovers" the account.
 */
exports.confirmPasswordResetWithCode = onCall(
  { region: "us-central1", enforceAppCheck: false },
  async (request) => {
    const email = normalizeEmail(request.data && request.data.email);
    const resetToken = request.data && request.data.resetToken;
    const newPassword = request.data && request.data.newPassword;

    if (!email || typeof resetToken !== "string" || !resetToken) {
      throw new HttpsError("invalid-argument", "Email and token are required.");
    }
    if (typeof newPassword !== "string" || !isStrongEnough(newPassword)) {
      throw new HttpsError(
        "invalid-argument",
        "Password does not meet the policy.",
        "weak-password"
      );
    }

    const ref = db.collection(COLLECTION).doc(docIdFor(email));
    const snap = await ref.get();
    if (!snap.exists) {
      throw new HttpsError(
        "not-found", "No reset in progress.", "invalid-reset-token"
      );
    }

    const expectedHash = snap.get("resetTokenHash");
    const expiresAt = snap.get("resetTokenExpiresAt");
    const submittedHash = crypto
      .createHash("sha256").update(resetToken).digest("hex");

    if (!expectedHash || !safeEqual(submittedHash, expectedHash)) {
      throw new HttpsError(
        "permission-denied", "Invalid token.", "invalid-reset-token"
      );
    }
    if (!expiresAt || expiresAt.toMillis() < Date.now()) {
      throw new HttpsError(
        "deadline-exceeded", "Token expired.", "invalid-reset-token"
      );
    }

    let user;
    try {
      user = await getAuth().getUserByEmail(email);
    } catch (e) {
      logger.error("Auth lookup failed during reset confirm", e);
      throw new HttpsError("internal", "Could not update the password.");
    }

    await getAuth().updateUser(user.uid, { password: newPassword });
    // Kill every existing session for this account.
    await getAuth().revokeRefreshTokens(user.uid);

    // The token is single-use — delete the whole document.
    await ref.delete();

    await stampPasswordChange(user.uid);

    return { ok: true };
  }
);

/**
 * Bookkeeping for the phone branch, where the client already changed the
 * password itself using its signed-in credential.
 *
 * Exists so the app needs **no** client write access to `users` — the
 * collection stays fully closed in `firestore.rules`.
 */
exports.recordPasswordChange = onCall(
  { region: "us-central1", enforceAppCheck: false },
  async (request) => {
    if (!request.auth || !request.auth.uid) {
      throw new HttpsError("unauthenticated", "Sign-in required.");
    }
    const uid = request.auth.uid;
    await getAuth().revokeRefreshTokens(uid);
    await stampPasswordChange(uid);
    return { ok: true };
  }
);

/**
 * Records *when* the password changed — never the password itself.
 *
 * Useful for showing "last changed" in settings and for rejecting tokens
 * issued before the reset.
 */
async function stampPasswordChange(uid) {
  try {
    await db.collection("users").doc(uid).set(
      {
        passwordChangedAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
  } catch (e) {
    // Non-fatal: the password change itself already succeeded.
    logger.error("Could not stamp passwordChangedAt", e);
  }
}

/**
 * Server-side copy of the policy shown on the Reset Password screen:
 * 8+ characters, an uppercase letter, a lowercase letter, a special
 * character. The client validates the same rules for fast feedback, but this
 * is the one that actually counts (SECURITY.md section 7).
 */
function isStrongEnough(password) {
  return (
    password.length >= 8 &&
    /[A-Z]/.test(password) &&
    /[a-z]/.test(password) &&
    /[^A-Za-z0-9]/.test(password)
  );
}
