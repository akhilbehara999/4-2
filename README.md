# LOG (We Listen · Organise · Grow)

> **We Listen · Organise · Grow**

An offline-first, voice-first Android app for Telugu kirana shopkeepers to record sales, udhar (credit), and stock.

## Features & Architecture (Starter Skeleton)
- **Voice-first Kirana Interface**: Material 3 UI tailored for shopkeepers with high contrast and large touch targets.
- **5 Core Navigation Tabs**:
  - **Home**: Quick voice recording with prominent mic button.
  - **Udhar**: Customer ledger and credit management.
  - **Stock**: Inventory counts and restock tracking.
  - **Dashboard**: Kirana sales and performance overview.
  - **Ask**: Voice/text query assistant.
- **Settings**: Accessible via top AppBar icon.
- **Local SQLite Database (`sqflite`)**:
  - Tables: `item`, `customer`, `txn`, `stock_log`, `alert`.
- **Cloud Backup Ready (`supabase_flutter`)**: Safe initialization supporting offline/no-keys launch.

## Getting Started

1. Copy environment template:
   ```bash
   cp lib/core/env.dart.example lib/core/env.dart
   ```
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run tests:
   ```bash
   flutter test
   ```
4. Run the app:
   ```bash
   flutter run
   ```
