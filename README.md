# SkillSwap Hackathon Project

A full-stack skill-exchange platform built for a hackathon, with:
- A Node.js backend API (`backend/`)
- A Flutter mobile app (`hackathon_app/`)

## Project Structure

- `backend/` - Express API, routes, and server-side logic
- `hackathon_app/` - Flutter client application

## Prerequisites

- Node.js and npm
- Flutter SDK
- Android SDK (for APK builds)

## Backend Setup

```bash
cd backend
npm install
npm run dev
```

If `npm run dev` is not available, use:

```bash
npm start
```

## Flutter App Setup

```bash
cd hackathon_app
flutter pub get
flutter run
```

## Build APK (Debug)

```bash
cd hackathon_app
flutter build apk --debug
```

Output APK:

`hackathon_app/build/app/outputs/flutter-apk/app-debug.apk`

## Useful Checks

```bash
cd hackathon_app
flutter analyze
```

## Notes

- Update API base URLs in the Flutter app for your local network/device as needed.
- Ensure backend is running before testing chat, matches, and analytics flows.
