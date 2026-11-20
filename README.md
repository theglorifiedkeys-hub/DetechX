# DetechX

A Flutter prototype for home-service intake, guided diagnostics, and technician dispatch. The three screens share a warm glass visual system, bundled Inter and Lucide fonts, and locally bundled demo imagery.

## Run

Use Flutter 3.29.3 or a compatible newer stable SDK:

```sh
flutter pub get
flutter run -d chrome
```

To generate mobile platform runners locally, run `flutter create --platforms=android,ios .`, then `flutter run -d <device-id>`. For iOS gallery selection, also configure `NSPhotoLibraryUsageDescription` in `ios/Runner/Info.plist`.

## Try the flow

1. Choose a Dar es Salaam neighborhood and describe an issue on Home. An empty submission opens a fresh conversation.
2. Pick **Normal**, **Weak**, or **Not sure** to see a diagnosis and estimate. The assistant also handles category-specific intake from **Quick Services**.
3. Tap **Find a Technician** to see the animated route and estimated arrival. Drag the technician sheet handle or tap the chevrons for vehicle and certification details.
4. Edit your name and Tanzanian contact number under **Profile**, or turn on **Reduce motion** in **Settings**. **Call** and **Message** are explicitly simulated.

Diagnostics are rule-based and dispatch is simulated. There is no AI backend, GPS feed, real booking, or outbound communication. Photos and videos can be selected locally; the chat displays their filenames and does not upload or analyze them. Profile, service neighborhood, and motion preferences are saved on the device. Chat history is session-only. Home uses East Africa Time and estimates are shown in Tanzanian shillings (TZS).

## Verify

```sh
flutter analyze
flutter test
flutter build web
```

The widget tests cover issue handoff, keyboard insets, estimate propagation, and the simulated call sheet at 360px and 430px widths. CI runs analysis, tests, and a web build.

### Test a service through payment

On tracking, confirm the fundi has arrived, start work, confirm completion, review the TZS test invoice, and confirm a test payment. A local receipt appears; no mobile-money prompt or charge is sent. The visit and receipt are session-only. See [the Snippe integration plan](docs/snippe-payments.md) for merchant onboarding and the backend steps needed to enable real payments.

### Map lab and operations website

Open **Wasifu → Ramani ya Dar es Salaam** for the street map, or **Wasifu → Ingia** for the local staff role demo. See the [Firebase handoff](docs/firebase-roadmap.md) for permissions, hosting and the backend plan.

### Premium marketing website (React / Vite)

The standalone website lives in [`website/`](website/README.md). It has its own Vercel config and does not replace the Flutter app. See the [web motion reference shortlist](docs/web-motion-references.md) for WebGL, GLSL, Barba, Anime.js, tween.js and GSAP examples.

### Android 1.0.1: Dar service pilot

Home no longer exposes staff tools. Open **Wasifu → Ingia** and choose **Mteja**, **Fundi**, or **Msimamizi**. These are local preview roles, not authentication. Demo staff share an in-memory job queue; the selected fundi only sees their sample jobs and cannot record payments. Android Back returns from staff and tracking screens normally, and returns a secondary Home tab to **Mwanzo** before leaving the app.

The Android launcher uses the ice-blue artwork in `assets/launcher.png`; CI installs the legacy and adaptive icons using `scripts/android_launcher.py` after generating the runner. The service-area picker requests GPS only on **Tambua eneo langu**, suggests a supported Dar neighborhood, and saves only the area the user confirms. Manual selection remains available. Both map screens now use Esri topographic tiles, with attribution and an internet retry; no illustrated map or OpenStreetMap tile endpoint remains. Tracking still uses a sample path, not live navigation. Confirm the map provider’s licensing, attribution and coverage before any commercial rollout.
