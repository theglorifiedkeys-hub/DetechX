# Demo and Firebase handoff

The Flutter project includes a Dar map (`/#/map`) and a responsive staff workspace. From the app, open Wasifu → Ingia, then select Fundi or Msimamizi. This is a local role preview with seeded, in-memory rows, not authentication or live customer data.

## Map decision

- The Esri topographic basemap replaces the illustrated and OpenStreetMap tile views. `flutter_map` renders tiles; Geolocator provides optional GPS. The route is a simulation. Select a properly licensed tile service and production routing/ETA provider before a real pilot.
- GPS is requested only after a tap. The app saves the confirmed service neighborhood, not latitude and longitude. Moving the map to the device location may request tiles near that location from Esri. Web hosting requires HTTPS (or localhost for development).

## Backend plan

1. Start a staging Firebase project and configure Flutter with FlutterFire CLI. Add customer and staff authentication. Server-issued custom claims and Firestore rules must protect real dispatch information; replace or disable the public demo route before connecting real records.
2. Store jobs, state transitions, technician assignments and invoices in Firestore. Replace the in-memory dispatch store through a repository, and enforce transition rules server-side. Customer users only read their own jobs; technicians only see assigned ones.
3. Collect technician location only during a consented active trip, limit update frequency and retention, and avoid storing precise customer coordinates unless required. The demo does not stream locations.
4. Keep payment secrets in Cloud Functions secret storage. A verified provider event or validated server-side lookup settles payment; the client cannot mark a real invoice paid.
5. Run `flutter build web`, select the staging project explicitly, and deploy with `firebase deploy --only hosting --project <project-id>`. This repo only configures static hosting; it does not provision Firebase, configure authentication, or deploy a live website.

For locally generated Android runners, add `INTERNET`, `ACCESS_COARSE_LOCATION` and `ACCESS_FINE_LOCATION` to the main manifest (CI does this automatically). For iOS, configure `NSLocationWhenInUseUsageDescription`. Background location is not needed for this demo.
