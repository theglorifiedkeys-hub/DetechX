# Demo and Firebase handoff

The same Flutter project has a customer website, a map lab (`/#/map`) and a responsive operations preview (`/#/admin`). From Home, choose either demo card. The admin workspace is deliberately public **only for seeded, in-memory demo rows**. It is not connected to customer bookings or payments.

## Map decision

- **Illustrated:** included and usable without network or location permission. Good for presentation or when tiles are unavailable; cannot show real streets or your GPS position.
- **Street map:** `flutter_map` renders OpenStreetMap tiles, pan/zoom, sample markers and a moving van. The demo polyline is pre-drawn, not a calculated driving route. Geolocator adds a separate device pin only when you tap **My location** and grant permission. The point is not persisted or uploaded. Web hosting needs HTTPS (or localhost for development).
- Use the street map for a real pilot and keep the illustrated view for previews. Before production select a tile service with suitable terms and capacity, respect attribution, and integrate a routing/ETA service if needed. Rendering, GPS and directions are separate responsibilities.

## Backend plan

1. Start a staging Firebase project and configure Flutter with FlutterFire CLI. Add customer and staff authentication. Server-issued custom claims and Firestore rules must protect real dispatch information; replace or disable the public demo route before connecting real records.
2. Store jobs, state transitions, technician assignments and invoices in Firestore. Replace the in-memory dispatch store through a repository, and enforce transition rules server-side. Customer users only read their own jobs; technicians only see assigned ones.
3. Collect technician location only during a consented active trip, limit update frequency and retention, and avoid storing precise customer coordinates unless required. The demo does not stream locations.
4. Keep payment secrets in Cloud Functions secret storage. A verified provider event or validated server-side lookup settles payment; the client cannot mark a real invoice paid.
5. Run `flutter build web`, select the staging project explicitly, and deploy with `firebase deploy --only hosting --project <project-id>`. This repo only configures static hosting; it does not provision Firebase, configure authentication, or deploy a live website.

For locally generated Android runners, add `INTERNET`, `ACCESS_COARSE_LOCATION` and `ACCESS_FINE_LOCATION` to the main manifest (CI does this automatically). For iOS, configure `NSLocationWhenInUseUsageDescription`. Background location is not needed for this demo.
