# ChefInPocket

ChefInPocket is a mobile recipe assistant built for **CS310 - Mobile Application Development**. The application helps users discover recipes from available ingredients, save favorites, manage a grocery list, and access a context-aware cooking assistant from inside the recipe flow.

## Motivation

Many recipe applications assume that users already know what they want to cook. ChefInPocket was designed to solve the opposite problem: users often start with the ingredients they already have at home. Our goal was to build a Flutter application that shortens the path from pantry items to a realistic meal plan while keeping the experience simple, responsive, and beginner-friendly.

## Main Features

- Firebase Authentication with sign up, login, logout, and route protection
- Firestore-backed recipe, profile, saved recipe, community, grocery list, and chat data
- Ingredient-based recipe filtering
- Named-route navigation across the full cooking flow
- Community recipe sharing and profile browsing
- Real-time saved recipes and grocery list updates using Firestore streams
- Provider-based state management for authentication, shared app data, and preferences
- SharedPreferences-based theme preference persistence
- Context-aware Chef AI screen for recipe-related guidance
- Responsive layouts for phones and larger device widths

## Tech Stack

### Frontend

- Flutter `3.41.6`
- Dart `3.11.4`
- Material 3
- Provider
- SharedPreferences

### Firebase Packages

- `firebase_core`
- `firebase_auth`
- `cloud_firestore`

### Additional Packages

- `http`
- `cupertino_icons`

## Project Structure

```text
chef_in_pocket/
├── frontend/
│   ├── assets/
│   ├── lib/
│   │   ├── bootstrap/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── routes/
│   │   ├── screens/
│   │   ├── services/
│   │   ├── theme/
│   │   ├── utils/
│   │   └── widgets/
│   └── test/
├── backend/
├── docs/
├── firebase.json
└── firestore.rules
```

## Firebase Setup

The current Flutter code expects Firebase Authentication and Firestore to be configured before the app runs on a real device.

### Required Files

Add these Firebase platform files to the Flutter project:

- `frontend/ios/Runner/GoogleService-Info.plist`
- `frontend/android/app/google-services.json`

### Optional FlutterFire CLI Setup

If you prefer the FlutterFire CLI workflow:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

### Firestore Rules

The repository includes:

- `firestore.rules`
- `firebase.json`

Deploy them with:

```bash
firebase deploy --only firestore:rules
```

## Installation

### 1. Clone the project

```bash
git clone <your-repository-url>
cd chef_in_pocket
```

### 2. Install Flutter dependencies

```bash
cd frontend
flutter pub get
```

### 3. Add Firebase configuration

Copy the Firebase platform files listed above into the correct directories.

### 4. Run the application

```bash
flutter run
```

For Chrome:

```bash
flutter run -d chrome
```

For a connected iPhone:

```bash
flutter devices
flutter run -d <device-id>
```

## Testing

ChefInPocket includes both a unit test and a widget test.

### Run all tests

```bash
cd frontend
flutter test
```

### Included tests

- `frontend/test/logic/recipe_logic_test.dart`
  Verifies the core business rule for ingredient-based recipe filtering.

- `frontend/test/screens/login_screen_test.dart`
  Verifies login screen rendering, inline validation, and successful submit behavior through the authentication provider.

## Notes on Images and AI

- The current demo uses a combination of local asset images and seeded network image URLs.
- The Firebase architecture is ready for Authentication and Firestore in the current repository.
- Firebase Storage is part of the intended deployment architecture for recipe media, but the demo content currently relies on seeded URLs and bundled assets.
- The Chef AI flow now performs lightweight retrieval over the recipe corpus before generating a response, so answers are grounded in the app's own recipe data.

## Known Limitations

- Firebase platform files are not committed to the repository and must be added locally.
- The current AI assistant uses a lightweight in-app retrieval layer rather than an external production LLM stack.
- Recipe media upload is not yet migrated to Firebase Storage.
- The repository still contains an older Dockerized backend from previous milestones, while the latest Flutter flow is centered on Firebase.

## Future Improvements

- Add Firebase Storage upload support for user-submitted recipe images
- Connect the assistant layer to a full external LLM + retrieval pipeline
- Add richer community interactions such as comments and likes
- Expand automated test coverage for providers, route guards, and Firestore repositories

## Team

- Mehmet Selman Yılmaz
- Cem Ozkul
- Emir Keskin
- Semse Doga Atilgan
- Nilsu Saraclar
- Bora Demirkol
