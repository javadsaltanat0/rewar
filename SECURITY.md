# SECURITY.md — Security Requirements

*Last verified against current standards: July 2026 (PCI DSS v4.0.1, the
version in effect now — all of its previously "future-dated" requirements
became mandatory as of March 2025). Security standards change; if this
file hasn't been reviewed in 6-12 months, that's a signal to re-check it,
not to assume it's still fully current.*

This is not optional polish — treat every rule here as part of "definition
of done" alongside `CLAUDE.md`. A screen that works but skips the matching
security rule is not finished. **Payment-related screens are held to the
highest bar in this file — see section 5 specifically.**

## 1. Firestore Security Rules — core principles

- **Deny by default.** Every collection starts with no access; each rule
  explicitly grants the minimum access it needs. Never leave a collection
  in Firebase's default test mode (`allow read, write: if true;`) past the
  screen that introduces it.
- **Validate shape, not just auth.** Rules should check that incoming data
  has the right fields/types (e.g. `pricePerNight` is a number, not just
  "any authenticated user can write anything"). Client-side validation is
  for UX; rules are the actual security boundary — assume the client can
  be bypassed entirely.
- **Users can only read/write their own data** for anything user-specific
  (`bookings`, `favorites`, their own `users/{uid}` document). Check
  `request.auth.uid == resource.data.userId` (or the relevant field) on
  every rule that touches personal data.
- **Public read, admin-only write** for catalog data (`hotels`, `cars`,
  `tours`, `flights`, `nature_spots`) — any user can read these to browse
  the app, but only admins can create/update/delete them.
- Write rules for a collection **at the same time** you build the screen
  that uses it — not as cleanup at the end. Add them to version control
  and treat changes to them with the same scrutiny as schema changes.

## 2. Firebase Storage Security Rules

Same principles as Firestore, applied to file uploads:
- Users can only upload to their own path (e.g. `profile_images/{uid}/`).
- Admin-only write for catalog images (`hotel_images/`, `car_images/`,
  `tour_images/`), public read.
- Enforce file size limits and content-type checks (images only) in the
  rules themselves, not just client-side — a malicious client could
  otherwise upload arbitrary files.

## 3. Admin access control

The admin panel must never rely on hiding UI elements as its only
protection — that only stops accidental access, not a deliberate one.

- Grant admin status via a **Firebase custom claim** on the user's Auth
  token, set through a Cloud Function (never set directly from a client,
  and never store "isAdmin" as a plain editable Firestore field a user
  could write to themselves).
- Every Firestore/Storage rule that gates admin-only writes checks
  `request.auth.token.admin == true`, not a client-supplied value.
- The admin panel's own login is a normal Firebase Auth login — the
  custom claim is what elevates that specific account, not a separate
  password system.
- Log admin actions (who changed what, when) — at minimum a
  `createdBy`/`updatedBy` field per document (already required by
  `DATA_MODEL.md`), ideally an `admin_activity_log` collection for
  higher-risk actions like deletes.

## 4. Secrets & API keys

- Third-party API keys (for the admin panel's API-import feature, or any
  future payment/maps/weather integration) live in **Cloud Functions
  environment config**, never in the Flutter client code — anything
  shipped in the app bundle can be extracted by a determined user.
- Firebase's own client config (`google-services.json` /
  `GoogleService-Info.plist`) is safe to ship in the app — it's not a
  secret, it's a public project identifier. Security comes from the rules
  above, not from hiding this file. Don't confuse the two.
- `.gitignore` any local `.env` files used for Cloud Functions development
  secrets; never commit real API keys to the repo, including in commit
  history.

## 5. Payment security (online payments — highest priority section)

Payments change your risk profile significantly — a breach here means
real financial and legal exposure, not just an inconvenience. Follow
every rule below; none of these are optional.

### 5.1 The single most important rule: keep card data out of your app entirely
The safest card data is the data your app never touches. Use:
- **Tokenization / hosted payment fields** — card numbers go straight
  from the user's device to the payment processor (Stripe, etc.), never
  through your own servers or Firestore, via the processor's official
  SDK (e.g. `flutter_stripe`'s prebuilt Payment Sheet, or web Stripe
  Elements for the admin panel if it ever needs payment UI).
- **Apple Pay / Google Pay** where possible — these are effectively
  out of PCI scope entirely since your app never sees card details at
  all.
- Never write code that reads, logs, stores, or caches a raw card
  number, CVV, or expiry date, anywhere — not in Firestore, not in
  Cloud Function logs, not in Crashlytics, not "temporarily for
  debugging." There is no safe way to do this even briefly.

Following this one rule correctly is what keeps your PCI DSS compliance
burden small (tokenized/hosted-field integrations can qualify for a
much simpler self-assessment than an app that handles raw card data
directly) — it's the highest-leverage security decision in the whole
payment flow.

### 5.2 Recommended Firebase integration pattern
Use the **"Run Payments with Stripe" Firebase Extension** (Firestore +
Cloud Functions + webhooks, maintained by Invertase) rather than
building a custom Stripe integration from scratch:
- Card entry happens through Stripe's own SDK/Payment Sheet — never
  through custom-built input fields.
- The extension manages Stripe customers, checkout sessions, and
  subscription/payment status sync into Firestore automatically.
- Firestore rules for the extension's collections should follow the
  same "users can only read their own" pattern as the rest of this
  file — e.g. a user can read their own `stripe-customers/{uid}`
  document and its subcollections, never anyone else's.

### 5.3 Local Iraqi payment providers, alongside Stripe (not instead of it)
Confirmed as real, regulated options, added per request — Stripe/Apple
Pay/Google Pay is not exclusive; these are additional methods offered at
checkout, not a restriction on which cards are accepted (see 5.1 — Stripe
already accepts Visa/Mastercard/etc., these are separate local rails
some users will prefer):

- **FIB (First Iraqi Bank)** — has public, documented SDKs (Node.js,
  Python, PHP/Laravel, Android, WordPress) and a REST API using OAuth2
  client-credentials authentication, a sandbox environment for testing,
  and webhook/callback support for payment status. Default currency is
  IQD. Same architecture rule applies as with Stripe: the integration
  runs through a **Cloud Function** holding the `client_id`/
  `client_secret` (via `integration@fib.iq` for production credentials)
  — never in the Flutter client. Verify webhook payloads the same way
  as Stripe's.
- **NassWallet** — a Central Bank of Iraq-licensed digital wallet
  (PCI DSS compliant), supporting QR-code payments and a Visa-branded
  prepaid card (NassPay). Public self-serve API documentation wasn't
  found alongside FIB's — contact NASS directly (nass.iq) for merchant/
  developer integration docs and credentials before building against
  it, and re-verify the exact auth/webhook pattern they provide rather
  than assuming it matches FIB's or Stripe's shape.
- Whichever of these gets built, the same core rules from 5.1 and 5.4-5.7
  apply without exception — provider name changes, the security
  requirements don't.
- Add a `paymentProvider` field to the `bookings` schema in
  `DATA_MODEL.md` (`"stripe"` | `"fib"` | `"nasswallet"`) so bookings
  paid through different rails are still queryable/reportable together.

### 5.4 Critical: real-world bookings vs. digital content are treated differently by Apple/Google
This distinction can get your app **rejected from app store review** if
missed, so it's worth being explicit:
- **Real-world services** — hotel stays, car rentals, tour bookings,
  flight tickets (everything this app currently sells) — are generally
  **allowed to use Stripe/PayPal/other processors directly**. This is
  the "physical goods and services" exception to Apple's and Google's
  in-app purchase requirements.
- **Digital-only content** — subscriptions to app features, virtual
  currency, unlockable premium content, anything consumed *within* the
  app rather than in the real world — **must** use Apple's In-App
  Purchase system and Google Play Billing instead of Stripe/PayPal, per
  both platforms' store policies. Using a third-party processor for
  this category of purchase is a common and serious app-rejection
  reason.
- If a future feature blurs this line (e.g. a "premium membership" tier
  with in-app perks), flag it and ask before building the payment flow
  — don't assume which payment path applies.

### 5.5 Webhook security
- Every Stripe (or other processor) webhook handler must **verify the
  webhook signature** using the processor's secret before trusting the
  payload — an unverified webhook endpoint lets anyone fake a "payment
  succeeded" event.
- Webhook handlers run as Cloud Functions, never as client-side code.

### 5.6 Idempotency
- Payment-creating operations (charging a card, creating a booking with
  a charge attached) must use idempotency keys so a network retry or a
  double-tap doesn't create two charges for one booking.

### 5.7 Encryption and transport
- Enforce TLS 1.2 minimum, TLS 1.3 preferred, for anything payment-
  related — Firebase's own services enforce this by default; if any
  custom Cloud Function calls an external payment API directly, confirm
  it's also using TLS 1.3 where the provider supports it.
- Any payment-adjacent data actually stored (e.g. last 4 digits of a
  card for display purposes, subscription status) should be the
  minimum needed for the feature — never full card numbers, ever.

### 5.8 Access control and monitoring specific to payments
- MFA (multi-factor authentication) should be required for **your own**
  admin/owner access to the Stripe dashboard and any Firebase Console
  access with billing/payments visibility — this is standard practice
  under PCI DSS v4.0.1's "MFA everywhere" requirement for anyone who can
  reach cardholder-adjacent systems, not just for end users.
- Monitor for anomalous transaction patterns (unusual volume, repeated
  failed charges, mismatched geography) — Stripe's own Radar fraud
  tooling covers a lot of this out of the box; don't disable or ignore
  it.
- Data minimization applies to your own team too: support staff,
  developers, and analytics tools should never have access to full
  card data — there should be no path in the app or admin panel that
  displays it, because there should be no path where your systems ever
  receive it in the first place (see 5.1).

## 6. Authentication hardening — registration, login, and verification

### 6.1 What the registration/login screens must capture and verify
Per the confirmed requirement: registration collects full account info and
offers **three verification factors** — email, mobile number (SMS), and
an authenticator app (TOTP). Specifics:

- **Email verification** — required for every account, via Firebase
  Auth's built-in `sendEmailVerification()`. This is also a hard
  prerequisite for enabling any further MFA factor (Firebase requires a
  verified email before a second factor can be added — this prevents an
  attacker registering with someone else's email and then locking the
  real owner out by adding their own second factor).
- **Phone/SMS verification** — via Firebase Authentication's phone-based
  MFA. **Important nuance, not just a checkbox**: Firebase's own
  documentation explicitly cautions against relying on SMS alone,
  since SMS can be intercepted or spoofed. Support it (it's what most
  users expect and is a real requirement here), but the UI should
  encourage the authenticator app as the stronger option rather than
  treating both as equally secure.
- **Authenticator app (TOTP)** — Google Authenticator/Authy/Microsoft
  Authenticator compatible, via Firebase Auth's TOTP MFA support. This
  is real and documented, but is a newer, still-actively-updated part
  of the Firebase/FlutterFire SDK compared to SMS MFA — **re-verify its
  current maturity/support status on both Android and iOS specifically
  at the time this is actually implemented**, rather than assuming
  today's exact API surface. Enrollment flow: generate a TOTP secret,
  show it as a QR code, user scans it with their authenticator app,
  user enters the generated code once to confirm enrollment.
- Both SMS and TOTP MFA require **Firebase Authentication with Identity
  Platform** (an upgrade from base Firebase Auth) — confirm this is
  enabled in Phase 0, and note it may have billing implications beyond
  the free tier; flag the cost impact before enabling it.

### 6.1a Password reset by 6-digit code — the two branches are not alike
Added when the Verification Code screen was built. Worth stating explicitly
because the asymmetry is easy to get wrong:

- **Phone/SMS branch** — Firebase Auth generates, sends and verifies the code
  itself. We never see it, never store it, and there is no collection
  involved. Use `verifyPhoneNumber` → `PhoneAuthProvider.credential`.
- **Email branch** — Firebase Auth has **no** built-in code-based reset;
  `sendPasswordResetEmail()` sends a *link*. A 6-digit email code therefore
  has to be implemented in Cloud Functions. Non-negotiable properties:
  - Store only a **salted hash** of the code, never the plaintext, and never
    return the code to the client.
  - The client gets **no read or write access** to `password_reset_codes`
    (see `firestore.rules`) — the Admin SDK bypasses rules, so the functions
    still work.
  - Compare codes in **constant time** (`crypto.timingSafeEqual`) so a timing
    side channel can't leak them.
  - **Never reveal whether an email is registered.** Return the same success
    response either way, or the endpoint becomes an account-enumeration
    oracle.
  - Rate-limit **both** directions: a cooldown between sends, and a hard cap
    on failed verify attempts. Enforce this on the server — a client-side
    countdown is UX, not security.
  - Expire codes (10 minutes) and burn them on first successful use so they
    can't be replayed.
  - SMTP credentials belong to the "Trigger Email from Firestore" extension's
    config, never to this repo (section 4).
- **App Check matters more here than almost anywhere else**: an unprotected
  send endpoint lets anyone burn your SMS and email quota, which is a direct
  billing attack. Both functions ship with `enforceAppCheck: false` and must
  be flipped to `true` once App Check is live — tracked in
  `FIREBASE_SETUP.md`.

### 6.1b Actually changing the password — what must and must not happen
Added when the Reset Password screen was built.

- **The password never touches Firestore.** It goes to Firebase Auth
  directly (phone flow, via the signed-in credential) or to the Admin SDK
  inside a Cloud Function (email flow). Never log it, never cache it, never
  put it in a document — the same absolute rule as card data in section 5.1.
  Firestore records only *when* it changed (`users.passwordChangedAt`).
- **Revoke refresh tokens on every password change.** This is the step most
  often missed: without `revokeRefreshTokens(uid)`, a session an attacker
  already holds keeps working after the real owner "recovers" the account,
  which defeats the point of the reset. Both
  `confirmPasswordResetWithCode` and `recordPasswordChange` do this.
- **The reset token is single-use and short-lived.** It is stored hashed,
  compared in constant time, and its document is deleted the moment the
  password changes, so a replayed token cannot set the password twice.
- **Validate the password policy on the server as well as the client.**
  `isStrongEnough()` in `functions/index.js` mirrors the rule shown on
  screen. Client validation is UX; this is the boundary (section 7). Also
  configure the same policy in Firebase Auth's own password-policy settings
  so it applies to registration too, not just reset.
- **The client needs no write access to `users`.** Both stamping functions
  run under the Admin SDK, so `users` stays fully closed in
  `firestore.rules` rather than being opened up for one field.

### 6.1c Registration — the field allow-list is the whole point
Added when the Register screen was built. The client now creates its own
`users/{uid}` document, which is the first time app code writes to Firestore
at all. The risk is not *whether* it can write, but *which fields*:

- `firestore.rules` restricts create and update to an explicit **allow-list**
  (`name`, `email`, `phone`, `dateOfBirth`, `gender`, `profileImageUrl`,
  `preferredLanguage`, `termsAcceptedAt`, `createdAt`, `updatedAt`,
  `source`). Anything outside it is rejected whatever its value.
- **`role` is not on that list.** Without this, a modified client could write
  `role: "admin"` to its own document and grant itself the admin panel. Same
  reasoning for `emailVerified` / `phoneVerified` — a client that can set
  those can claim a verification it never passed.
- Rules validate **shape as well as ownership**: name length, field types,
  and `gender` restricted to the three permitted values.
- `list` is not granted on `users` — nobody may enumerate the user base.
- `delete` is denied outright; account deletion must go through a Cloud
  Function so Auth, Firestore and Storage are cleaned up together
  (section 9).
- The registration password goes straight to
  `createUserWithEmailAndPassword` and is never placed on a model object,
  logged, or written to Firestore.
- **Terms/Privacy consent is captured at registration** (`termsAcceptedAt`).
  Both app stores require explicit consent at account creation; without it,
  review can reject the app.

### 6.1d Consent — record the version, not just the moment
Added when the Terms of Service screen was built.

- Consent is captured on its own screen, as a **required gate** between
  account creation and phone verification. Continue stays disabled until the
  checkbox is ticked, and the checkbox sits at the end of the scrollable
  document so it cannot be reached without scrolling past the text.
- Store **`termsVersion` as well as `termsAcceptedAt`**. A timestamp alone
  cannot answer "did this user agree to the current wording?", which is the
  only question that matters when the terms change. With the version stored,
  you can re-prompt exactly the users who haven't seen the latest text.
- `legal_documents` is **public read, admin-only write**. Public because a
  user must be able to read the terms before they have an account;
  admin-only write because a client that could edit this collection could
  rewrite the agreement it is about to accept.
- **Translated legal text is a legal risk, not a UI task.** The Kurdish and
  Arabic renderings currently in the repo were produced by translation, not
  by a qualified legal translator. The document carries a `legalReviewed`
  flag and the app shows a visible warning while it is false. Do not ship
  with it false — the language a user reads is the one they are agreeing to.

### 6.1e Profile pictures and OS permissions
Added when the Account Setup screen was built.

- **Storage rules enforce the limits, not the client.** `storage.rules`
  restricts writes to `profile_images/{uid}/` for that uid only, requires
  `contentType` to match `image/.*`, and caps size at 5 MB. Client-side
  checks are UX; a modified client could otherwise upload any file type at
  any size and serve it from your domain — and run up the bill.
- Avatars use a **fixed filename per user** (`avatar.jpg`), so re-uploading
  replaces the old picture instead of leaving orphaned files in Storage.
- Images are **downscaled on device** (1024px, quality 85) before upload. A
  modern phone photo is 4–12 MB; an avatar needs a fraction of that.
- Profile pictures are **public read** — they appear beside reviews and
  bookings, so they must be readable without knowing who is asking.

> ⚠️ **Permission timing — a known review risk, accepted deliberately.**
> Camera, photos, location and notifications are all requested **up front**
> when Account Setup opens. Apple and Google both recommend requesting a
> permission at the point of use with visible context; asking for location
> and notifications on a screen that uses neither is a common App Store
> rejection reason and lowers grant rates for later prompts. This trade-off
> was raised and the up-front approach chosen anyway.
>
> If review pushes back, the change is small: stop calling
> `AppPermissions.requestAll()` in `AccountSetupScreen.initState`, and rely
> on `AppPermissions.requestForImageSource()`, which the screen already
> calls at the moment the user picks a source. The iOS
> `NSLocationWhenInUseUsageDescription` string also currently describes a
> feature that does not exist yet — it must describe a real feature before
> submission.

### 6.1f Guests — the dashboard is public, the user's own data is not
Added when the Home screen was built. This is the first screen a
**not-signed-in** user can reach, which changes what the rules have to allow.

- `featured` and `nature_spots` are **public read, including unauthenticated**
  — a guest browses the whole dashboard. Both grant `list` (unlike
  `legal_documents`, which is fetched by known id) because the screen queries
  them. Both stay **admin-only write**: a client that could write `featured`
  could put arbitrary content on the app's front page.
- `favorites` is the opposite — **owner-only in both directions**. `list` is
  granted only because the rule pins `resource.data.userId` to the caller, so
  Firestore rejects any query not provably limited to that user's own rows.
  Nobody can enumerate someone else's saved places.
- `update` on `favorites` is **denied outright**. A favourite is added or
  removed; allowing update would only add a way to repoint an existing row at
  another user.
- **There is no anonymous favorite.** Rather than storing guest favorites
  locally and merging them later, the screen prompts the guest to sign in.
  One source of truth, and no second store to keep in sync or leak.
- Guest mode is **not** Firebase anonymous auth — it is simply "no user". If
  anonymous auth is introduced later, revisit this: an anonymous uid *would*
  satisfy the favorites rules, which may or may not be intended.

> ⚠️ **The count() aggregation is a read the client controls.** `count()` on
> `nature_spots` requires `list`, which means a client can also run
> unconstrained queries against that collection. That is acceptable for
> catalog data that is public anyway, but it is a real cost surface — add
> App Check (6.3) before launch, and watch the usage dashboard (section 10).

### 6.2 Platform-specific setup — both Android and iOS need explicit configuration
This isn't automatic just because Flutter is cross-platform — each OS
needs its own setup for phone/SMS verification to work correctly:
- **Android**: the app's SHA-256 signing certificate hash must be added
  in the Firebase console (Project Settings → your Android app) —
  phone auth verification will fail silently without this.
- **iOS**: in Xcode, Push Notifications capability must be enabled, an
  APNs authentication key must be configured and linked to Firebase
  Cloud Messaging, and Background Modes → Remote Notifications must be
  enabled. iOS phone verification relies on a silent push to confirm
  the request came from a real device instead of always falling back to
  a visible SMS challenge.
- Test both platforms' verification flows independently — a
  configuration that works on Android does not guarantee it works on
  iOS, and vice versa, given how differently each platform implements
  the underlying device-attestation step.

### 6.3 App/device integrity — both platforms, via one Firebase feature
- Enable **Firebase App Check** once real user data is involved. Under
  the hood, App Check uses **Play Integrity API on Android** and
  **Apple's App Attest on iOS** — one Firebase integration covers the
  hardware-backed integrity check on both platforms, rather than
  needing separate native code per OS.
- (Historical note, not an action needed: Android's older SafetyNet API
  is deprecated; Play Integrity API is its replacement and is what App
  Check already uses — nothing to migrate here as long as App Check is
  used rather than a hand-rolled SafetyNet integration.)

### 6.4 General hardening
- Store any locally-cached auth tokens using `flutter_secure_storage`
  (backed by Keychain on iOS / Keystore on Android), never
  `shared_preferences` — plain shared preferences are not encrypted at
  rest.
- Rate-limit sensitive actions (login attempts, password resets) —
  Firebase Auth has some of this built in; don't disable or work around
  it.
- Enforce a real password policy (minimum length, mix of character
  types) using Firebase Auth's password policy configuration rather
  than only client-side validation.

## 7. Input validation — both ends

- Validate on the client for good UX (instant feedback, no round trip).
- **Re-validate the same rules in Firestore Security Rules or a Cloud
  Function.** Client validation is convenience, not security — treat every
  client request as potentially hostile when writing rules/functions.

## 8. Dependency hygiene

- Keep Flutter, Dart, and all packages (especially `firebase_*` packages)
  on recent stable versions — security patches land in updates.
- Avoid adding packages with low maintenance activity for anything
  touching auth, storage, or payments.
- Run `flutter pub outdated` periodically and flag anything with a known
  CVE for priority updating.

## 9. Privacy & compliance

- Since the app collects email, phone, profile photos, and location data,
  a **privacy policy page is required** for both app store submissions —
  build this before submitting to App Store / Play Store, not after.
- Support account/data deletion (a user can request their `users/{uid}`
  document, bookings, and storage files be deleted) — required by both
  Apple and Google's app review guidelines if accounts can be created in
  the app.
- Don't collect more data than a screen actually needs — if a field isn't
  in `DATA_MODEL.md` and isn't being used by an approved screen, don't
  add it "just in case."

## 10. Monitoring

- Enable **Firebase Crashlytics** early — catching real crashes in
  production is part of security, not just stability (a crash can be a
  symptom of someone probing for weaknesses).
- Watch Firebase Console's usage/billing dashboards after launch —
  unexpected spikes in reads/writes can indicate a security rule gap
  being exploited (or just a bug), and Firestore's pay-per-read model
  means this is also a cost issue.

## 11. Pre-launch security checklist (before App Store/Play Store submission)

- [ ] Every Firestore collection has explicit rules — no collection is
      left in test/open mode
- [ ] Every Storage bucket path has explicit rules
- [ ] Admin custom claim implemented via Cloud Function, verified in rules
- [ ] App Check enabled
- [ ] No API keys or secrets anywhere in the Flutter client codebase
- [ ] Auth tokens stored via `flutter_secure_storage`, not
      `shared_preferences`
- [ ] Privacy policy page live and linked from both the app and store
      listings
- [ ] `legal_documents/terms_of_service` seeded, and **`legalReviewed` set
      to true** only after a qualified translator/lawyer has signed off all
      three languages (see 6.1d)
- [ ] Account/data deletion flow implemented and tested
- [ ] Crashlytics enabled
- [ ] `flutter pub outdated` run, no known-vulnerable packages in use
- [ ] **Auth/verification-specific:**
  - [ ] Email verification required and tested
  - [ ] SMS/phone MFA tested on a real Android device
  - [ ] SMS/phone MFA tested on a real iOS device (do not assume Android
        testing covers iOS — platform setup differs)
  - [ ] Authenticator app (TOTP) enrollment and verification tested on
        both platforms; current SDK support status re-confirmed since
        this is a newer/actively-changing feature
  - [ ] Android SHA-256 certificate hash registered in Firebase console
  - [ ] iOS Push Notifications + APNs key + Background Modes configured
        in Xcode
  - [ ] Firebase App Check enabled and confirmed working on both
        platforms (Play Integrity on Android, App Attest on iOS)
- [ ] **Payment-specific:**
  - [ ] Confirmed no raw card data ever touches the app, Firestore, or
        Cloud Function logs — card entry goes through Stripe's own SDK/
        Payment Sheet or Apple Pay/Google Pay only
  - [ ] Webhook signature verification implemented and tested on every
        payment webhook handler
  - [ ] Idempotency keys used on all charge-creating operations
  - [ ] Confirmed real-world bookings use Stripe/PayPal directly, and
        any digital-only content (if added later) uses Apple/Google's
        in-app purchase systems instead — not mixed up
  - [ ] MFA enabled on the Stripe dashboard account and any Firebase
        Console access with billing visibility
  - [ ] Re-check this section's guidance against current PCI DSS
        requirements if more than 6-12 months have passed since the
        "last verified" date at the top of this file — standards do
        get updated
