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
