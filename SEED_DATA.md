# SEED_DATA.md — One Example Per Collection

Tracks the one real example document seeded into each Firestore collection,
so it's always clear what "real" data currently exists to test screens
against (per the "One example, seeded to Firestore, per page" rule in
`CLAUDE.md`).

Update the **Status** column as each one actually gets added to Firestore —
don't mark it seeded until it's really there and confirmed rendering.

| Collection | Example | Status |
|---|---|---|
| legal_documents | `terms_of_service` v1 (en/ku/ar) — seed with `node tool/seed_legal_documents.js` | NOT SEEDED (needs a Firebase project) |
| featured | 4 carousel slides (nature spot, car, flight, tour) — seed with `node tool/seed_home_screen.js` | NOT SEEDED (needs a Firebase project) |
| nature_spots | Rawanduz Canyon — seeded by the same script | NOT SEEDED (needs a Firebase project) |
| hotels | Divan Hotel (Iraq, Erbil, 40m Street) | NOT SEEDED |
| hotels/{id}/rooms | Ocean View Suite | NOT SEEDED |
| hotels/{id}/reviews | Sarah — "The views are incredible! Highly recommend." | NOT SEEDED |
| cars | Tesla Model 3 (GreenWheels Rentals) | NOT SEEDED |
| tours | Moraine Lake (Alberta, Canada, 3 days travel) | NOT SEEDED |
| flights | Astra Airlines, Erbil (EBL) → Istanbul | NOT SEEDED |
| users | (your own test account, created via the Auth screen) | NOT SEEDED |
| bookings | (one test booking once a booking flow exists) | NOT SEEDED |
| favorites | (one test favorite once favoriting is wired up) | NOT SEEDED |
| password_reset_codes | n/a — written only by Cloud Functions | N/A (not seeded by hand) |
| mail | n/a — written only by Cloud Functions | N/A (not seeded by hand) |

> The Verification Code screen reads no catalog data, so the "one seeded
> example document" rule doesn't apply to it in the usual way. Its equivalent
> proof is an **end-to-end run**: request a code, receive the real SMS/email,
> and verify it against the deployed Cloud Function. That can't happen until
> `FIREBASE_SETUP.md` is finished.

### featured + nature_spots (Home screen)

Seeded together by one script, because the carousel is meaningless without at
least one catalog document behind it:

```
GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json \
  node tool/seed_home_screen.js
```

The same four slides are duplicated as `bundledFeatured()` in
`lib/services/featured_service.dart`, which is what preview mode serves before
Firebase exists — **keep the two in sync**, the same rule as the bundled
Terms text.

> ⚠️ Every seeded slide has an **empty `imageUrl`**. Upload the four photos to
> Firebase Storage and paste the download URLs in (or set them from the admin
> panel) — with no URL the card falls back to a flat brand colour instead of
> a photo. The page is not "done" until at least one slide renders with its
> real image on a running device.

### legal_documents/terms_of_service

Seeded by script rather than by hand — the document holds three languages of
legal prose, which is impractical to retype in the console:

```
GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json \
  node tool/seed_legal_documents.js
```

The same wording is duplicated as `bundledTerms()` in
`lib/services/legal_document_service.dart`, which is what preview mode serves
before Firebase exists. **Keep the two in sync** — if you edit one, edit the
other, or bump `version` in both.

> `legalReviewed` is seeded as **false**, and the app shows a visible warning
> banner while it is. Flip it to true only once the wording — especially the
> Kurdish and Arabic renderings — has been signed off by someone qualified.

## Suggested field values, ready to paste into the admin manual-entry
## forms (or Firestore console) once each collection exists

### hotels
```
name: Divan Hotel
address: Iraq, Erbil, 40m Street
city: Erbil
starRating: 5
reviewScore: 8.9
pricePerNightFrom: 200
amenities: [Pool, Bar, Restaurant, Parking]
```

### hotels/{id}/rooms
```
name: Ocean View Suite
bedConfiguration: [{type: Queen, count: 1}, {type: Sofa Bed, count: 1}]
sizeSqm: 90
facilities: [Beach Access, Balcony, Free Wi-Fi, Minibar, Room Service]
pricingOptions: [
  {title: "Property + Breakfast", infoLines: ["Non-refundable","Prepay online","Check-in: 3:00 PM"], pricePerNight: 260},
  {title: "Properties Only", infoLines: ["Free cancellation","Prepay online","Check-in: 2:00 PM"], pricePerNight: 240}
]
availableCount: 4
```

### cars
```
name: Tesla Model 3
year: 2026
rentalCompany: GreenWheels Rentals
companyTag: DriveXpress
capacity: 4
fuelType: Electric
bags: 2
hasAC: true
paymentInfo: Pay at the pick-up
pricePerDay: 58
```

### tours
```
name: Moraine Lake
duration: 3 days travel
description: A glacier-fed alpine lake surrounded by towering peaks, with
  guided hikes along the shoreline and prime photography stops.
companyTag: AB Travels
features: [Camping, Transport, Hiking, Guide]
pricePerPerson: 50
```

### flights
```
airline: Astra Airlines
fromAirportCode: EBL
toAirportCode: IST
durationMinutes: 165
price: 400
cabinClass: Economy
```
