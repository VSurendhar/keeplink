# How to Set Up the Project

Follow these steps the first time you set up Keep Links on a new machine.

## 1. Install the tools

- [FVM](https://fvm.app/) (Flutter Version Management). The project pins Flutter `3.35.4` in `.fvm/fvm_config.json`, and every `flutter`/`dart` command is prefixed with `fvm`.
- Android Studio (Android SDK and an emulator) and, on macOS, Xcode for iOS.

Install Flutter `3.35.4` through FVM, then the project's packages:

```bash
fvm install 3.35.4
fvm flutter pub get
```

Run these from the project root. `fvm flutter` uses the version pinned in `.fvm/fvm_config.json`, so check that it reports Flutter `3.35.4`:

```bash
fvm flutter --version
```

## 2. Get the Mixpanel project token

1. Open the Keep Links project in [Mixpanel](https://mixpanel.com/).
2. Go to **Project Settings → Overview → Access Keys**.
3. Copy the **Project Token**.

## 3. Create `secrets.json`

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

## 4. Run the app with the token

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

## 5. Check that analytics works

1. Open the **Developer Options** tab (shown in debug builds).
2. Tap **Trigger a Test Analytics**.
3. In Mixpanel, open **Data → Events**. A `clicked_test_analytics` event should appear within a few seconds.

## Troubleshooting

- **"MIXPANEL_TOKEN is not set" toast at launch**: the app was started without `--dart-define-from-file=secrets.json`, or `secrets.json` has no `MIXPANEL_TOKEN`. Analytics stays off, and every analytics call logs "Mixpanel is null".
- **No events in Mixpanel, and no error in the app**: the token is probably wrong. Mixpanel doesn't check the token on the device, so a wrong token fails silently when the events are uploaded. Copy the Project Token again from step 2.
- **Changed `secrets.json` but nothing changed**: the values are compiled into the app, so hot reload doesn't pick them up. Stop the app and run it again.
