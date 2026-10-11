# LOG (వింటాము · సర్దుతాము · ఎదుగుతాము)
> **Voice-first Telugu notebook for kirana shopkeepers**  
> Final-Year B.Tech Project (4-2)

LOG (**L**isten · **O**rganise · **G**row) turns spoken Telugu shop transactions into instant digital records, credit (udhar) management, low-stock alerts, and daily profit analytics. All processing runs entirely on the smartphone offline.

---

## Important Build Rule
> ⚠️ **CRITICAL:** Do **NOT** build an APK or app bundle (`flutter build apk`, `flutter build appbundle`) during daily development.  
> **The release APK will only be built at the very end when all features and evaluations are complete.**

---

## How to Run During Development

### 1. Run in Browser (Web - Daily Testing)
```bash
flutter run -d chrome
```
*Note: SQLite is powered by `sqflite_common_ffi_web` with WebAssembly (`sqlite3.wasm`). Platform-specific services (notifications, background tasks) are guarded with web-safe fallbacks.*

### 2. Run on Android Emulator / Physical Device
```bash
# List available Android devices & emulators
flutter devices

# Run on connected Android device/emulator
flutter run -d android
```

---

## Project Structure
```
lib/
  main.dart               # App entrypoint and DB initialization
  app.dart                # MaterialApp, themes, route table
  core/
    constants/            # Shop constants, teal seed colors, business thresholds
    theme/                # Material 3 light/dark themes with Roboto & Noto Sans Telugu
    platform/             # Platform detection and web-safe guards
    utils/                # Bilingual text helpers (Telugu · English)
  data/
    database/             # SQLite database service, cross-platform factories, schema
    models/               # Item, Customer, Txn, StockLog, Alert, CorrectionLog models
    repositories/         # Repositories for data access
  features/
    home/                 # Home screen
    more/                 # More screen hub (8 feature tiles)
    speak/                # Voice listening screen & confirm entry screen
    udhar/                # Udhar ledger & customer detail screens
    stock/                # Stock items & stock item detail screens
    dashboard/            # Financial & sales charts dashboard
    ask/                  # Telugu query assistant screen
    transactions/         # All transactions ledger
    customers/            # Customer directory
    items/                # Items catalog
    settings/             # Settings & backup configuration
    setup/                # First-time onboarding screen
    recount/              # Weekly stock recount screen
    navigation/           # 3-section bottom bar with raised centre Speak button
  services/               # Speech-to-text, TTS, and Android-only notification wrappers
test/                     # Unit and widget tests
```

---

## Database Tables (SQLite)
- `item`: id, name_te, name_en, unit, current_stock, alert_days, cost_price, sell_price
- `customer`: id, name, phone, balance_due
- `txn`: id, type, item_id, customer_id, qty, amount, raw_text, audio_path, created_at, synced
- `stock_log`: id, item_id, change, reason, created_at
- `alert`: id, item_id, predicted_days_left, sent_at, seen
- `correction_log`: id, txn_id, raw_text, parsed_fields, final_fields, was_edited, created_at
