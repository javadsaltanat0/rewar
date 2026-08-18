# PROGRESS.md — Build Log

Append a new entry every time a page/task is approved. Never delete old
entries — this is the project's memory across sessions.

Template for each entry:

```
## [Date] — [Page/Task name]
Status: APPROVED
What was built: [1-3 sentences]
Known placeholders/limitations: [anything not fully wired up]
Firestore collections touched: [list]
Example data seeded: [what, and whether via admin panel or manually]
```

---

> **Note on this log's history.** Entries below start at the Home screen.
> The screens built before it (Splash, Language, Onboarding, Login, Register,
> Terms, Account Setup, Register Complete, and the three password-reset
> screens) were never recorded here — their decisions live in the notes
> section of `DESIGN_SYSTEM.md` instead. Worth backfilling.

## 2026-08-05 — Phase 2: Main dashboard (Home screen)
Status: **AWAITING APPROVAL** — not yet approved.

What was built: The post-login / post-guest dashboard from the `main screen`
reference. Top bar (hamburger · bare logo · language globe), a time-of-day
greeting with the user's name, a swipeable featured carousel reading the new
`featured` collection, a "Plan your journey" grid of five cards (Explore
Nature, Where to Stay, Car Rental, Flight Ticketing, Explore Tours), and a
floating liquid-glass bottom nav. Light **and** dark, in English, Kurdish and
Arabic with full RTL. 26 new widget tests; 125 pass, analyzer clean.

Decisions taken (all four confirmed by the user before building):
- Featured slides come from a **curated `featured` collection**, not a
  fan-out across four catalog collections — one read, admin-ordered, and a
  slide can point at any entity type.
- Guests get a **sign-in prompt** on the heart; there is no anonymous
  favorite, so `favorites` keeps a single owner-only source of truth.
- The "N+ places" number is a **live `count()` aggregation**, and falls back
  to a plain "Explore" label rather than an invented number.
- The Map tab opens the **platform maps app** at Erbil via `url_launcher`
  (new dependency, approved).

Known placeholders / not wired up:
- **The five per-card photographs are missing.** Only the page background was
  supplied, so every journey card renders the design system's glass fill
  instead of its photo. The card already accepts an `imageAsset`; dropping
  the files in and setting five paths is the whole change.
- **Nothing is seeded, because there is still no Firebase project.** The
  screen runs in preview mode behind the yellow banner: bundled slides, a
  bundled count of 120, favorites not persisted.
- **Not yet run on a device or emulator.** `flutter run` fails on this
  machine with "Building with plugins requires symlink support" until
  Developer Mode is enabled in Windows settings. Verification so far is the
  test suite only.
- Hamburger menu, Explore/detail navigation, Trips and Saved are all
  deliberately inert ("coming soon") — those screens are later phases.
- Login **success** still doesn't reach this screen; only "Continue as Guest"
  does. Real auth is still unwired, as it was before.
- The Welcome/tagline transition screen (Phase 1, item 5) was skipped — the
  guest path goes straight from Login to here.

Firestore collections touched: `featured` (read), `nature_spots`
(count), `favorites` (read/write). Rules for all three added to
`firestore.rules`; composite index for the carousel query added to
`firestore.indexes.json`. **Rules are written but not yet deployed or
emulator-tested** — that needs the Firebase project.

Example data seeded: none yet. `tool/seed_home_screen.js` is ready and seeds
four `featured` slides plus one `nature_spots` document.
