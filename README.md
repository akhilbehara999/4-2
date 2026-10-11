# LOG — We Listen · Organise · Grow
> **An offline, voice-first Telugu notebook for Kirana shopkeepers**  
> *Final Year B.Tech Project*

---

## 🏬 Project Overview

**LOG** is an offline-first digital assistant and ledger engineered specifically for Indian kirana (grocery) shopkeepers. Operating in colloquial Telugu and English, it eliminates manual paper bookkeeping through intuitive speech recognition, offline SQLite data storage, and automated stock & credit tracking.

- **Listen (వినండి)**: Fast Telugu voice logging of sales, expenses, and Udhar credit.
- **Organise (సరిదిద్దండి)**: Automated double-entry customer ledger and item catalog.
- **Grow (ఎదగండి)**: Daily profit metrics, weekly revenue curves, and low-stock alerts.

---

## 📁 Repository Structure

```
.
├── log_app/                  # Full Flutter Android & Web Application
│   ├── lib/                  # Application source code
│   │   ├── core/             # Design tokens, theme, bilingual constants
│   │   ├── data/             # SQLite database service, PRD models, repositories
│   │   ├── features/         # Features (home, setup, more, udhar, stock, speak)
│   │   └── services/         # Speech-to-text, permissions, notifications
│   ├── test/                 # Full unit and widget test suite
│   ├── android/              # Native Android project configuration
│   ├── web/                  # Web runner with WASM SQLite support
│   └── pubspec.yaml          # Project dependencies & assets
│
├── html all/                 # High-fidelity Material 3 HTML design mockups
│   ├── LOG Home Screen.html
│   ├── LOG More Screen.html
│   ├── LOG First-time Setup.html
│   ├── LOG Listening Screen.html
│   ├── LOG Confirm Entry.html
│   ├── LOG Weekly Recount.html
│   └── ...
│
├── log-prototype/            # Interactive browser HTML/JS prototype
└── log-prd (1).html          # Complete Product Requirements Document (PRD)
```

---

## 🚀 Running the Flutter App

```bash
# 1. Navigate to the Flutter project folder
cd log_app

# 2. Install dependencies
flutter pub get

# 3. Run in Chrome (Browser evaluation)
flutter run -d chrome

# 4. Run on Android device or emulator
flutter run -d android
```

---

## 🧪 Testing & Verification

```bash
cd log_app

# Run all unit and widget tests
flutter test

# Run Dart code analysis
flutter analyze
```

---

## 🎨 Design System
- **Primary Color**: Material 3 Teal `#0B6E5F` (Light) / `#4FD1B8` (Dark)
- **Typography**: Roboto + Noto Sans Telugu bilingual pairing
- **Architecture**: Clean, modular, explainable viva architecture with offline-first SQLite.
