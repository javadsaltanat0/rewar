# ROADMAP.md — Page-by-Page Build Order (Mobile App)

Rule: build only the page marked "IN PROGRESS." Do not start the next page
until the current one is marked "APPROVED" in `PROGRESS.md`.

Every page below that reads from Firestore also requires one seeded
example document, confirmed rendering live, and matching security rules
tested — see `CLAUDE.md`, `SECURITY.md`, and `SEED_DATA.md`.

Status legend: `NOT STARTED` / `IN PROGRESS` / `APPROVED`

## Phase 0 — Foundation (do this before any real page)
- [ ] Firebase project created (dev + prod environments)
- [ ] Firestore, Auth, Storage, Functions enabled
- [ ] Firestore/Storage set to deny-by-default (not left in test mode)
- [ ] Design finalized externally, handed over as `DESIGN_SYSTEM.md`
      (both light and dark values)
- [ ] `DATA_MODEL.md` first draft written and approved (copy to admin
      panel repo too)
- [ ] `SECURITY.md` reviewed — confirm the admin custom-claim setup will
      exist before the admin panel needs it (built in the other project)
- [ ] Base Flutter project scaffolded (folder structure, theming
      boilerplate supporting light+dark via ColorScheme, Firebase config
      wired up, no real screens yet)

## Phase 1 — Onboarding & Auth flow

Order matters here — build and approve in this exact sequence:
1. **Splash screen** (logo) — same as the earlier prototype version
2. **Language selection screen** — same as the earlier prototype version
3. **Onboarding screen** — one screen containing an internal 3-slide
   swiper (confirmed: not 3 separate pages)
4. **Login/Auth screen** — a new design, different from the earlier
   prototype's version. Do not reuse that layout; wait for the uploaded
   reference screenshot + info for this screen specifically. Must
   include: full registration info capture, email verification, phone/
   SMS verification, and authenticator app (TOTP) enrollment — see
   `SECURITY.md` section 6 for the full spec, and build/test both
   Android and iOS platform-specific setup (they are not automatically
   equivalent).
5. **Welcome/tagline transition screen** — shown after login, before the
   dashboard (as in the earlier prototype)

- [ ] Splash screen
- [ ] Language selection screen
- [ ] Onboarding screen (3-slide swiper) — IN PROGRESS. All three slides
      have localized copy, entry/exit motion, the shared panning panorama,
      and scroll-linked aircraft motion. Awaiting final review/approval.
- [ ] Auth screen (Firebase Auth: sign up / log in, new design, full
      registration info + email + SMS + TOTP verification, tested on
      both Android and iOS)
- [ ] Welcome/tagline transition screen

## Phase 2 — Core navigation shell
- [ ] Main dashboard (home tab) — IN PROGRESS. Built from the `main screen`
      reference: top bar, time-based greeting, featured carousel reading
      `featured`, five "plan your journey" cards, floating glass bottom nav.
      Light + dark, all three languages. Awaiting review/approval; still
      needs the five per-card photos and a live Firebase project.
- [ ] Side drawer (profile header, services menu, settings, logout) — the
      hamburger is in place and inert; menu options not yet specified
- [x] Bottom navigation (Home / Trips / Map / Saved) — built as part of the
      dashboard. Home is the only destination with a screen; Map opens the
      platform maps app; Trips and Saved say "coming soon" until Phase 8

## Phase 3 — Explore Nature
- [ ] Explore Nature list screen (reads from Firestore `nature_spots`)
- [ ] Spot detail screen

## Phase 4 — Where to Stay
- [ ] Where to Stay search/filter screen (reads from Firestore `hotels`)
- [ ] Hotel detail screen
- [ ] Room selection screen

## Phase 5 — Car Rental
- [ ] Car Rental search/filter screen (reads from Firestore `cars`)
- [ ] Car search results screen
- [ ] Car booking/options screen

## Phase 6 — Explore Tours
- [ ] Explore Tours screen (reads from Firestore `tours`)
- [ ] Tour detail/booking screen

## Phase 7 — Flight Ticketing
- [ ] Flight Ticketing search screen
- [ ] Flight results screen

## Phase 8 — Account features
- [ ] My Bookings (real data — bookings made across hotels/cars/tours/flights)
- [ ] Favorites
- [ ] Settings (Billing/Payment, Policy, Help/Support, About Us,
      Contact Way — build out one at a time)
- [ ] Profile picture upload (Firebase Storage)

## Phase 9 — Polish & hardening
- [ ] Work through the full pre-launch checklist in `SECURITY.md` section 10
- [ ] Firestore security rules review, end to end
- [ ] Loading/error/empty states audit across all screens
- [ ] Performance pass (pagination on long lists, image caching)
- [ ] Verify both light and dark mode across every screen, not just the
      first few built
- [ ] App icon, splash branding, store listing assets
- [ ] Privacy policy page live (required for both app stores)

---

Note: the admin/data-entry web panel has its own project, its own
`CLAUDE.md`, and its own roadmap — see the companion `admin-panel/` doc
set, not this file.
