# DATA_MODEL.md — Firestore Schema (draft, refine with your agent in Phase 0)

Every document includes: `id`, `createdAt`, `updatedAt`, `source`
(`"manual"` | `"api"`), `createdBy`. Omitted below for brevity — assume
they're on every collection.

## `users`
| field | type | notes |
|---|---|---|
| name | string | |
| email | string | matches Firebase Auth |
| emailVerified | boolean | mirrors Firebase Auth's own verification state |
| phone | string | |
| phoneVerified | boolean | |
| mfaEnrolled | boolean | true once at least one second factor is set up |
| mfaMethods | array<string> | which second factors are enrolled, e.g. `["sms"]`, `["totp"]`, or both |
| profileImageUrl | string | Firebase Storage download URL. The file lives at `profile_images/{uid}/avatar.jpg` — a fixed name per user, so re-uploading replaces the old picture rather than orphaning files. Set by the Account Setup screen |
| dateOfBirth | timestamp | set at registration. Stored as a **date**, not an age, so it never goes stale and an 18+ check stays correct over time |
| gender | string | `"male"` \| `"female"` \| `"other"`. **Optional** — absent when the user skips it (`SECURITY.md` 9: don't collect more than needed) |
| termsAcceptedAt | timestamp | when the user accepted on the Terms of Service screen. Required evidence for App Store / Play review |
| termsVersion | number | **which version** of the terms they accepted, from `legal_documents/terms_of_service.version`. A timestamp alone can't tell you whether someone agreed to the current wording or last year's — this is what lets you re-prompt only the users who haven't seen the latest text |
| preferredLanguage | string | `en` / `ku` / `ar` |
| role | string | `"user"` \| `"admin"` |
| passwordChangedAt | timestamp | *when* the password last changed — never the password itself. Written only by Cloud Functions (`confirmPasswordResetWithCode` / `recordPasswordChange`); lets Settings show "last changed" and lets tokens issued before a reset be rejected |

Note: `emailVerified`/`phoneVerified`/MFA enrollment state ultimately
lives in Firebase Auth itself (the source of truth) — these Firestore
fields are a convenience mirror for querying/display, not a replacement
for checking the real Firebase Auth state before granting access to
anything sensitive.

**Which fields the client may write.** The Register screen creates this
document from the app, so `firestore.rules` restricts both create and update
to an explicit allow-list: `name`, `email`, `phone`, `dateOfBirth`, `gender`,
`profileImageUrl`, `preferredLanguage`, `termsAcceptedAt`, `createdAt`,
`updatedAt`, `source`. Everything else — **`role`, `emailVerified`,
`phoneVerified`, `mfaEnrolled`, `mfaMethods`, `passwordChangedAt`** — is
writable only by Cloud Functions via the Admin SDK. Without that restriction
a modified client could simply write `role: "admin"` to its own document and
grant itself the admin panel.

## `password_reset_codes` *(server-only — added for the Verification Code screen)*

Backs the **email** branch of the password-reset code flow. Firebase Auth's
built-in `sendPasswordResetEmail()` sends a *link*, not a code, so a 6-digit
email code has to be issued and checked by our own Cloud Functions.
The **phone/SMS** branch needs no collection at all — Firebase Auth generates
and verifies that code itself.

Document id = SHA-256 of the lowercased email (non-reversible, non-enumerable).
**No client access in either direction** — only the Admin SDK inside Cloud
Functions touches it (see `firestore.rules`).

| field | type | notes |
|---|---|---|
| codeHash | string | salted SHA-256 of the 6-digit code. The plaintext code is never stored |
| salt | string | random per-code salt |
| expiresAt | timestamp | 10 minutes after issue |
| attempts | number | failed verify attempts; 5 max, then locked out |
| lastSentAt | timestamp | enforces the 60s resend cooldown server-side |
| resetTokenHash | string | set only after a correct code; hash of the short-lived token the Set New Password screen will exchange |
| resetTokenExpiresAt | timestamp | 10 minutes after issue |

Note: this collection deliberately does **not** carry the standard
`id`/`createdBy`/`source` envelope — it holds no user-authored content, is
never listed or queried, and is deleted/overwritten per reset attempt.

## `mail` *(server-only — added for the Verification Code screen)*

Outbound email queue consumed by the **"Trigger Email from Firestore"**
Firebase Extension, which holds the SMTP credentials in extension config so
no secret lands in this repo (`SECURITY.md` section 4). Written only by
Cloud Functions; **no client access** — client write access would let anyone
send mail from the project's verified sender address.

| field | type | notes |
|---|---|---|
| to | array<string> | recipient address |
| message | map | `{subject, text, html}` — the extension's own schema |

## `legal_documents` *(added for the Terms of Service screen)*

Versioned legal text — currently one document, `terms_of_service`. Held in
Firestore rather than bundled in the app so the wording can be updated from
the admin panel without an App Store / Play release, which is exactly what
the Terms text itself promises ("we reserve the right… to change… at any
time"). A store release can take days; a legal correction shouldn't wait.

**Public read (including unauthenticated), admin-only write.** A user must be
able to read the terms before they have an account. If the client could write
here, it could rewrite the agreement it is about to accept.

| field | type | notes |
|---|---|---|
| version | number | bump on every wording change; consent is recorded against it in `users.termsVersion` |
| updatedAt | timestamp | shown as "Last updated" at the top — the body text refers to this date, so it has to exist |
| legalReviewed | boolean | false until a qualified translator/lawyer signs off. While false the app shows a visible warning banner |
| content | map | keyed by locale: `{ en: {sections: [...]}, ku: {...}, ar: {...} }` |
| content.{locale}.sections | array<{heading, body}> | ordered blocks, e.g. "YOUR AGREEMENT", "PRIVACY" |

One read serves all three languages. A missing locale falls back to `en` so
the legal page is never blank.

## `featured` *(added for the Home screen)*

The home screen's carousel — the four slides at the top of the dashboard.
A **curated collection** rather than a query across `nature_spots` / `cars` /
`tours` / `flights`, for three reasons: one read instead of four, the admin
panel controls exactly what appears and in what order, and a single slide can
point at any entity type without the client knowing which collections exist.

**Public read (including unauthenticated), admin-only write.** The dashboard
is fully browsable by a guest, so the carousel cannot require auth; a client
that could write here could put anything on the app's front page.

| field | type | notes |
|---|---|---|
| type | string | `"nature_spot"` \| `"hotel"` \| `"car"` \| `"tour"` \| `"flight"` — which collection `referenceId` points into |
| referenceId | string | id of the document in that collection, so Explore can open the right detail screen |
| title | map | keyed by locale: `{ en, ku, ar }`. A **map, not a string** — the app is trilingual and switching language must not cost a second read. Missing locale falls back to `en` |
| subtitle | map | same shape; the location/context line, e.g. "Erbil • Nature escape" |
| imageUrl | string | Firebase Storage download URL for the slide photo |
| rating | number | 0–5, shown as a star pill. **Optional** — absent hides the pill rather than drawing a zero, since an unrated item is not a badly rated one |
| order | number | ascending display order |
| active | boolean | false pulls a slide off the front page without deleting it |

Query: `.where('active', == true).orderBy('order').limit(8)`. That
combination needs a **composite index** — already declared in
`firestore.indexes.json`.

## `nature_spots`
| field | type | notes |
|---|---|---|
| name | string | |
| description | string | |
| imageUrls | array<string> | |
| location | geopoint | |
| distanceLabel | string | or compute client-side from geopoint |
| rating | number | 0–5. Added for the Home screen's featured card and the Phase 3 list |
| ratingCount | number | how many reviews the rating averages — a 5.0 from one review is not a 5.0 from two hundred |

> The Home screen runs a `count()` **aggregation** against this collection for
> the "N+ places" button. That needs `list` permission in the rules (granted:
> catalog data is public read), and is billed at one read per 1000 documents
> rather than one per document.

## `hotels`
| field | type | notes |
|---|---|---|
| name | string | |
| address | string | |
| city | string | |
| location | geopoint | |
| imageUrls | array<string> | |
| starRating | number | 0-5 |
| reviewScore | number | 0-10 |
| pricePerNightFrom | number | for list-card display |
| amenities | array<string> | e.g. Pool, Bar, Restaurant, Parking |

### `hotels/{hotelId}/rooms` (subcollection)
| field | type | notes |
|---|---|---|
| name | string | e.g. "Ocean View Suite" |
| bedConfiguration | array<{type, count}> | |
| sizeSqm | number | |
| facilities | array<string> | |
| pricingOptions | array<{title, infoLines, pricePerNight}> | |
| availableCount | number | |

### `hotels/{hotelId}/reviews` (subcollection)
| field | type | notes |
|---|---|---|
| userId | string | |
| name | string | |
| comment | string | |
| stars | number | |

## `cars`
| field | type | notes |
|---|---|---|
| name | string | |
| year | number | |
| rentalCompany | string | |
| companyTag | string | |
| imageUrls | array<string> | |
| capacity | number | |
| fuelType | string | |
| bags | number | |
| hasAC | boolean | |
| paymentInfo | string | |
| location | geopoint | |
| pricePerDay | number | |

## `tours`
| field | type | notes |
|---|---|---|
| name | string | |
| duration | string | e.g. "3 days travel" |
| description | string | |
| imageUrls | array<string> | |
| companyTag | string | |
| features | array<string> | e.g. Camping, Food, Transport |
| location | geopoint | |
| pricePerPerson | number | |

## `flights`
| field | type | notes |
|---|---|---|
| airline | string | |
| fromAirportCode | string | |
| toAirportCode | string | |
| departTime | timestamp | |
| arriveTime | timestamp | |
| durationMinutes | number | |
| price | number | |
| cabinClass | string | Economy / Premium Economy / Business / First |

## `bookings`
| field | type | notes |
|---|---|---|
| userId | string | |
| type | string | `"hotel"` \| `"car"` \| `"tour"` \| `"flight"` |
| referenceId | string | id of the hotel/car/tour/flight document |
| status | string | `"pending"` \| `"confirmed"` \| `"cancelled"` |
| totalPrice | number | |
| currency | string | e.g. `"USD"`, `"IQD"` — matters once local Iraqi payment providers are involved |
| paymentProvider | string | `"stripe"` \| `"fib"` \| `"nasswallet"` — see `SECURITY.md` section 5.3 |
| bookingDetails | map | flexible — dates, guest counts, add-ons, etc. |

## `favorites`

Document id is **deterministic**: `{uid}_{itemType}_{itemId}`. That makes
favoriting a plain set/delete on a known document instead of a
query-then-write, and makes a double-tap idempotent rather than creating two
rows for the same place. The id is *not* what the rules trust — they check
the `userId` field, so a forged id gains nothing.

| field | type | notes |
|---|---|---|
| userId | string | must equal `request.auth.uid`; enforced in rules |
| itemType | string | `"nature_spot"` \| `"hotel"` \| `"car"` \| `"tour"` \| `"flight"` — `flight` added for the Home screen, whose carousel can feature one |
| itemId | string | |

There is no such thing as a guest favorite: the rules require an auth uid, so
the Home screen prompts an unsigned-in user to log in rather than writing
anything locally.

---

**Notes for the agent:**
- Keep subcollections (like `hotels/{id}/rooms`) instead of separate
  top-level collections with a foreign key, when the child data is always
  fetched alongside the parent (cheaper reads, simpler security rules).
- Use top-level collections with a reference field when the child data
  needs to be queried independently of its parent (e.g. `bookings` needs
  to be queried by `userId` across all hotels/cars/tours, so it can't live
  nested under `hotels/{id}`).
- Revisit this file after Phase 0 planning — this is a starting draft, not
  final.
