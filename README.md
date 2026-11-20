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
