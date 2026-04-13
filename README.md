# ChefInPocket

ChefInPocket is a CS310 Mobile Application Development project — a smart recipe and meal planning assistant built with Flutter.

---

## Group Members

| Name | ID | Role |
|---|---|---|
| Mehmet Selman Yılmaz | 31158 | RAG Architect & Data Scientist · Learning & Research Lead |
| Cem Özkul | 34183 | Backend Developer & Data Engineer · Testing & Quality Assurance Lead |
| Emir Keskin | 31020 | Backend Lead · Integration & Repository Lead |
| Şemse Doğa Atılğan | 34450 | Frontend Developer & Data Analyst · Presentation & Communication Lead |
| Nilsu Saraçlar | 34210 | Frontend Lead (UI/UX) · Documentation & Submission Lead |
| Bora Demirkol | 32361 | Full Stack Developer · Project Coordinator |

---

## Project Structure

```
chef_in_pocket/
├── frontend/               # Flutter mobile/web UI
│   ├── lib/                # Dart source code
│   │   ├── screens/        # All app screens
│   │   ├── widgets/        # Reusable widgets
│   │   ├── models/         # Data models
│   │   ├── routes/         # Named route definitions
│   │   ├── theme/          # Colors, text styles, spacing
│   │   └── utils/          # Utility classes
│   ├── assets/             # Local images and fonts
│   ├── pubspec.yaml
│   └── ...
└── reports/                # Submission reports (Step 1, 2, 3)
```

---

## Frontend Highlights (Step 3 — UI Implementation)

- **16 named-route screens** following the wireframe flow
- **Shared utility files** for colors, spacing, and text styles
- **Custom fonts**: Inter and Syne
- **Asset images** (local) and **network images**
- **Form validation** with inline errors and success `AlertDialog`
- **Card-based list** (e.g. pantry/grocery) with dynamic remove buttons
- **Responsive layouts** adapting to narrow and wide screens

---

## Running the Flutter App

```bash
cd frontend
flutter pub get
flutter run
```

Requires Flutter SDK installed. Tested on Flutter 3.x.

---

## CS310 — Spring 2025–2026

Sabancı University · CS310 Mobile Application Development  
Group 03
