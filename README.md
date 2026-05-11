---
title: ChefInPocket
emoji: 🍳
colorFrom: yellow
colorTo: red
sdk: docker
app_port: 7860
pinned: false
---

# ChefInPocket

ChefInPocket is a CS310 Step 4 Flutter + Firebase project that includes:

- Firebase Authentication for email/password sign-up, login, and logout.
- Cloud Firestore storage for recipes, saved recipes, grocery items, and user profiles.
- Provider-based state management for auth, recipes, and persisted preferences.
- Firestore security rules that restrict private data to the signed-in owner.
- A Flutter UI implementation based on the team wireframes.

## Project Structure

```text
chef_in_pocket/
├── frontend/
│   ├── lib/                   # Flutter source code
│   ├── ios/Runner/            # iOS Firebase config
│   ├── assets/                # Images and fonts
│   └── pubspec.yaml
├── firestore.rules            # Firestore access control
└── reports/                   # Previous step reports and screenshots
```

## Frontend Highlights

- 16 named-route screens that follow the wireframe flow
- Shared utility files for colors, spacing, and text styles
- Custom fonts: Inter and Syne
- Asset images and network images
- Form validation with inline errors and success `AlertDialog`
- Protected navigation for logged-out and logged-in users
- Responsive layouts for narrow and wide screens

## Firebase Backend Highlights

- Auth state is managed through `AuthProvider`.
- Firestore CRUD lives in `FirestoreService`.
- Recipes, saved recipes, and grocery items use Firestore streams for real-time updates.
- Theme mode is saved and restored with `SharedPreferences`.
- Security rules are defined in `firestore.rules`.

## Local Run

### Flutter

```bash
cd frontend
flutter pub get
flutter run
```

### Firestore Rules

```bash
firebase deploy --only firestore:rules
```

Requires Firebase CLI access to the `chefinpocket` Firebase project.

## Frontend Docker

The frontend has its own Dockerfile for a Flutter web build:

```bash
cd frontend
docker build -t chefinpocket-frontend .
docker run -p 3000:80 chefinpocket-frontend
```
