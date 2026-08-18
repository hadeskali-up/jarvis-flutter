# Jarvis Flutter

Jarvis Flutter app rebuilt with neobrutalist pet-care inspired design from [needMCP pet-care-dashboard](https://needmcp.com/wireframes/pet-care-dashboard).

## Features

- **Neobrutalist Design System**
  - Cream background (#F6F3E6)
  - Yellow/Teal/Orange accent colors
  - Heavy black borders (3-4px)
  - Hard shadows (no blur)
  - Bold typography

- **Screens**
  - Animated splash screen
  - Home dashboard with AI Router credit display
  - Crypto positions viewer
  - MT5 Forex positions viewer

- **Functionality**
  - Real-time data from bridge.alisuhari.top API
  - Pull-to-refresh
  - Working navigation
  - All buttons functional
  - Error handling with retry

## Tech Stack

- Flutter 3.24.0
- Dart 3.0+
- Dependencies:
  - `http` - API calls
  - `provider` - State management
  - `intl` - Date/number formatting

## Build

CI/CD via GitHub Actions builds APK on every push to main.

```bash
flutter pub get
flutter build apk --release
```

APK artifact available in GitHub Actions runs and Releases.

## API Endpoints

- `/ai/usage` - AI Router credit balance
- `/crypto/positions` - Crypto positions
- `/mt5/positions` - MT5 Forex positions

Base URL: `https://bridge.alisuhari.top`

## Design Reference

Original KMP Jarvis: [hadeskali-up/kmp-jarvis](https://github.com/hadeskali-up/kmp-jarvis)

Pet-care dashboard wireframe: [needMCP](https://needmcp.com/wireframes/pet-care-dashboard)
