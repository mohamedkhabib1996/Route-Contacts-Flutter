# Contact App

Flutter assignment source for Mohamed Khaled.

## Run

Flutter 3.50.0 / Dart 3.14.0.

```bash
flutter pub get
flutter run
```

Android, iOS, and web project files are included. Android builds need an Android SDK; iOS builds need macOS and Xcode.

## Included

- Contact cards with name, email, phone, and an optional gallery photo.
- A contact form with live preview and field validation.
- Add, delete, and undo deletion.
- Contacts and photos saved locally between launches.
- Original supplied Lottie animations, bundled for offline use.
- Scrollable forms and an adaptive card grid.

Images are resized during selection and limited to 2 MB. Data stays in this app's local storage; it is not synchronized with the phone's system contacts. Clearing application data or browser storage removes the saved list.

## Demo recording

`demo.mp4` is a 34.8-second **automated Flutter test session**, encoded as H.264 at 720 × 1480 and 10 fps. It shows the empty state, live entry of valid contact data, saving, deletion, and Undo.

All 348 frames come from the running application's Flutter widget tree during real `WidgetTester` interactions. They were captured at 100 ms intervals of the test clock. This is **not a device or emulator screen capture**. The session uses synthetic contact data and the production storage adapter with the SharedPreferences test backend. It does not demonstrate native gallery selection.

The recording test is `test/manual/record_demo.dart`; it runs only when selected explicitly. It loads the SDK's original Roboto and Material Icons fonts and asserts the saved, deleted, and restored states. To reproduce it with an empty frame-output directory:

```bash
BOT=true FLUTTER_SUPPRESS_ANALYTICS=true flutter test --no-pub \
  test/manual/record_demo.dart \
  --dart-define=FLUTTER_SDK=/path/to/flutter
ffmpeg -y -framerate 10 -i build/demo_frames/frame_%05d.png \
  -c:v libx264 -crf 22 -pix_fmt yuv420p -an -movflags +faststart demo.mp4
```

## Assignment references

- Design: https://www.figma.com/design/75BNa0JF2kPRjZVlhx1BHK/Contact-App?node-id=0-1
- Animations: https://drive.google.com/drive/folders/1wLbNedeZZjrdlwJZqk7aKZRuV48g9gJb
- Supplied alternate empty animation: https://drive.google.com/file/d/1umP01NElGV_4UNGquN126fPV9aoCXkFy/view

The supplied DOCX contains links only and does not identify an assignment number. The original animation files were retrieved successfully. Exact visual matching to Figma is **not verified**: the Figma connector requires editor access, and the browser could not render the file because WebGL was unavailable. The working interface is an independent implementation using the supplied cream animation palette and a navy background.

## Verification

```bash
flutter analyze
flutter test
flutter build web
```

Verified on 14 November 2026 with Flutter 3.50.0 and Dart 3.14.0:

- `flutter analyze`: no issues found.
- `flutter test`: all 7 tests passed.
- `flutter build web`: successful release build; WebAssembly compatibility dry run also succeeded.
- Flutter-rendered visual checks at 360 px: empty state, populated cards, contact form, and the form with a simulated 280 px keyboard inset. No layout overflow was observed, and the save button remained reachable.

Tests cover contact validation, storage round trips, malformed saved data, add/delete/undo, form validation, failed save recovery, and failed load recovery. Reduced-motion mode displays a static animation frame.

Android and iOS binaries were not built in the Linux verification environment; Android SDK and Xcode were unavailable. Platform photo selection still needs a device check.
