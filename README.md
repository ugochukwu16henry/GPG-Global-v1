# GPG Gathering Place Global

A high-trust, faith-centered digital ecosystem for the YSA and BYU-Pathway community. Built with Flutter.

## Run the app

1. Install [Flutter](https://flutter.dev/docs/get-started/install).
2. From the project root:

```bash
flutter pub get
flutter run
```

- **Chrome (web):** `flutter run -d chrome`
- **Mobile:** connect a device or start an emulator, then `flutter run`

## Home Dashboard (this implementation)

- **Bento grid:** Profile card (top-left), Pathway progress (top-right), scrollable Gathering Feed (center).
- **Corporate identity:** Primary Navy `#002E5D`, Pathway Amber `#E9B14C`, Surface White `#F9F9F9`.
- **Glassmorphism** on cards; **Inter** as primary font.
- **Custom nav bar:** Home, Mission (Peer Search), Marketplace, Study Groups, Profile.
- **G-Nexus logo** with pulse animation; **Success confetti** when toggling status Connect → Degree.
- **Video cards** with 12px rounded corners and overlay **Hire Talent** button.
- **Riverpod** used for mock profile, pathway progress, and feed state.

## Project layout

- `lib/core/theme/` – colors and app theme
- `lib/features/home/` – dashboard screen, widgets, Riverpod providers

## Deep Linking (Talent + Mission Group)

Implemented app routes:

- `https://links.gpgglobal.app/talent/<id>` → in-app `/talent/:id`
- `https://links.gpgglobal.app/mission-group/<id>` → in-app `/mission-group/:id`

### Android App Links

- Intent filters are configured in `android/app/src/main/AndroidManifest.xml`.
- Host this file at `https://links.gpgglobal.app/.well-known/assetlinks.json`:

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.gpg.global.gpgGlobal",
      "sha256_cert_fingerprints": ["<YOUR_RELEASE_SHA256_CERT_FINGERPRINT>"]
    }
  }
]
```

### iOS Universal Links

- Associated Domains entitlement stub is set in:
  - `ios/Runner/Runner.entitlements`
  - `ios/Runner.xcodeproj/project.pbxproj` (`CODE_SIGN_ENTITLEMENTS`)
- Host this file at `https://links.gpgglobal.app/.well-known/apple-app-site-association` (no extension):

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "<APPLE_TEAM_ID>.com.gpg.global.gpgGlobal",
        "paths": ["/talent/*", "/mission-group/*"]
      }
    ]
  }
}
```

### Fallback custom scheme

- iOS URL scheme fallback: `gpgglobal://` (configured in `ios/Runner/Info.plist`).
