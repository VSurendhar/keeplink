# How to Set Up the Project

Follow these steps the first time you set up Keep Links on a new machine.

## 1. Install the tools

1. Install [FVM](https://fvm.app/docs/getting_started/installation/).
2. Install Android Studio (Android SDK and an emulator) and, on macOS, Xcode for iOS.

## 2. Set up Flutter

From the project root:

1. `fvm install 3.35.4` (downloads the SDK)
2. `fvm use 3.35.4` (links it into `.fvm/flutter_sdk`)
3. `fvm flutter pub get`
4. `fvm flutter --version` (should report 3.35.4)
5. `fvm flutter doctor` (fix anything it reports)

## 3. IDE setup (Android Studio)

1. Install the Flutter plugin.
2. Open **Settings** (**Preferences** on macOS) > Languages & Frameworks > Flutter.
3. Set **Flutter SDK path** to `<project>/.fvm/flutter_sdk`.

## 4. Get the Mixpanel project token

1. Open the Keep Links project in [Mixpanel](https://mixpanel.com/).
2. Go to **Project Settings → Overview → Access Keys**.
3. Copy the **Project Token**.

## 5. Create `secrets.json`

Build-time secrets live in `secrets.json` at the project root. The file is gitignored, so it is never committed: create it from the example file.

```bash
cp secrets.example.json secrets.json
```

Open `secrets.json` and replace the placeholder with your token:

```json
{
  "MIXPANEL_TOKEN": "your-mixpanel-project-token"
}
```

| Key              | Description                                |
|------------------|--------------------------------------------|
| `MIXPANEL_TOKEN` | Mixpanel project token used for analytics. |

Never commit `secrets.json` or paste the token into source code. In code, read it through `BuildConfig.mixpanelToken` (`lib/core/utils/build_config.dart`).

## 6. Run the app with the token

Pass the secrets file with `--dart-define-from-file` so the token is injected at build time:

```bash
fvm flutter run lib/main.dart --dart-define-from-file=secrets.json
```

Release builds need the same flag:

```bash
fvm flutter build apk --dart-define-from-file=secrets.json
fvm flutter build ipa --dart-define-from-file=secrets.json
```

If you run from the IDE, add `--dart-define-from-file=secrets.json` to the run configuration's additional arguments.

## 7. Check that analytics works

1. Open the **Developer Options** tab (shown in debug builds).
2. Tap **Trigger a Test Analytics**.
3. In Mixpanel, open **Data → Events**. A `clicked_test_analytics` event should appear within a few seconds.

## Troubleshooting

- **"MIXPANEL_TOKEN is not set" toast at launch**: the app was started without `--dart-define-from-file=secrets.json`, or `secrets.json` has no `MIXPANEL_TOKEN`. Analytics stays off, and every analytics call logs "Mixpanel is null".
- **No events in Mixpanel, and no error in the app**: the token is probably wrong. Mixpanel doesn't check the token on the device, so a wrong token fails silently when the events are uploaded. Copy the Project Token again from step 4.
- **Changed `secrets.json` but nothing changed**: the values are compiled into the app, so hot reload doesn't pick them up. Stop the app and run it again.
