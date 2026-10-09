# LOG — We Listen · Organise · Grow

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/SQLite-07405E?style=for-the-badge&logo=sqlite&logoColor=white" alt="SQLite" />
  <img src="https://img.shields.io/badge/Platforms-Android%20%7C%20Web-blue?style=for-the-badge" alt="Platforms" />
  <img src="https://img.shields.io/badge/Tests-19%20Passing-brightgreen?style=for-the-badge" alt="Tests" />
  <img src="https://img.shields.io/badge/Architecture-Offline--First-orange?style=for-the-badge" alt="Offline-First" />
</p>

> **"We Listen, Organise, Grow"** — An offline-first, voice-first kirana store management application crafted specifically for Telugu-speaking shopkeepers to manage daily sales, customer credit (*Udhar*), and intelligent stock replenishment without requiring cloud connectivity.

---

## 🌟 Overview & Key Highlights

Kirana shopkeepers operate in high-velocity, hands-busy retail environments. Traditional accounting apps require tedious multi-step manual tapping, complex bookkeeping concepts, or continuous internet access.

**LOG** solves this through a voice-first, bilingual interface tailored to local Telugu kirana workflows:
- **🗣️ Voice & Text Kirana Parser**: Speaks natural Telugu or Romanized colloquial phrases (*e.g., "రమేష్ కి 5 కేజీల బియ్యం ఉధార్ 300 రూపాయలు"* or *"Ramesh ki 5 kg biyyam udhar 300 rs"*). A fast, on-device rule-based NLP engine extracts the customer, item, quantity, unit, price, and transaction type instantaneously without cloud latency or costly LLM tokens.
- **⚡ 100% On-Device & Offline-First**: Built on SQLite (`sqflite` on Android and WASM SQLite on Web). Runs entirely without internet connectivity.
- **📊 Predictive Stock Engine**: Pure Dart depletion forecasting algorithm based on a 14-day weighted moving average with double weighting on recent sales. Predicts runaway stock-outs before they occur.
- **🔔 Proactive Stock Alerts**: Triggers bilingual notifications (*"బియ్యం ఇంకా 2 రోజులకే సరిపోతుంది"*) and prominent in-app alert banners when inventory drops below safety thresholds.
- **📋 Smart Weekly Recount Audits**: Automatically flags top-selling items unverified in over 7 days for quick 1-tap confirmation or adjustment.
- **📈 Real-Time Business Dashboard**: Dynamic period toggle (*Today / 7 Days / 30 Days*), gross profit estimation, credit exposure tracking, and `fl_chart` visual bar graphs.
- **🎲 Integrated Demo Data Suite**: 30-day realistic transaction generator with weekend volume spikes, restocks, credit settlements, and store expenses for immediate evaluation.

---

## 🏗️ Architecture & What Has Been Built

### 1. Pure Dart Stock Prediction Engine (`lib/data/stock_engine.dart`)
- **Zero Framework Coupling**: Pure Dart logic, fully decoupled from Flutter widgets.
- **Adaptive Window**: $\min(14, \text{days since first sale})$. Requires $\ge 3$ days before predicting (returns `"not enough data"` otherwise).
- **Double-Weighted Recent Consumption**:
  $$\text{avg daily sales} = \frac{2 \times \sum \text{sales}_{\text{last 7 days}} + \sum \text{sales}_{\text{older days}}}{2 \times \text{days}_{\text{last 7 days}} + \text{days}_{\text{older days}}}$$
- **Color Status Heuristic**:
  - 🔴 **Red**: $\text{days\_left} \le \text{alert\_days}$ (default 2 days) or $\text{current\_stock} \le 0$
  - 🟡 **Amber**: $\text{days\_left} \le \text{alert\_days} + 2$
  - 🟢 **Green**: Adequate stock level
  - ⚪ **Grey**: Insufficient data or no recent sales

### 2. Bilingual Kirana NLP Parser (`lib/data/parser.dart`)
- **Multi-Script & Romanized Support**: Accurately parses Telugu script (*బియ్యం, కందిపప్పు, ఉధార్, రమేష్*) as well as Romanized phonetics (*biyyam, pappu, udhar, kandulu*).
- **Automatic Entity Extraction**:
  - Customer Identification (`Ramesh ki`, `Suresh gariki`, `లక్ష్మి గారికి`)
  - Quantity & Unit Extraction (`5 kg`, `2 litrelu`, `1 packet`)
  - Financial Classification (`udhar`, `credit_sale`, `cash_sale`, `payment`, `restock`, `expense`)
  - Synonym normalization against SQLite commodity registry with automatic fallback.

### 3. Proactive Stock Alerts & Local Notifications (`lib/core/notifications.dart`)
- Evaluates inventory after every saved transaction and at app launch.
- Automatically creates alerts with a 24-hour debounce per commodity.
- Fires localized notifications on Android with Telugu title and English summary:
  - *Title:* `బియ్యం ఇంకా 2.0 రోజులకే సరిపోతుంది`
  - *Body:* `Rice has only 2.0 days of stock left`
- Shows an interactive in-app `"Running low · అయిపోతోంది"` banner on the Home screen that marks alerts as seen and navigates straight to the Stock tab.

### 4. Weekly Physical Stock Recount Flow
- Detects fastest-moving items whose last physical audit (`recount` / `recount_ok`) is older than 7 days.
- Displays non-intrusive cards on the Home screen:
  - *"[బియ్యం 12 కిలోలు ఉన్నాయా? · Biyyam 12 kilo undha?]"*
  - **"అవును · Yes"**: 1-tap confirmation logging zero difference with reason `recount_ok`.
  - **"మార్చు · Edit"**: Interactive numerical dialog updating stock and recording audited variance with reason `recount`.

### 5. Upgraded Inventory Management Tab (`lib/features/stock/stock_screen.dart`)
- Displays bilingual commodity titles, stock counts, and dynamic days-left metrics.
- Proportional color-coded status bar (Red / Amber / Green / Grey).
- Urgent/depleted items automatically sorted to the top.
- 1-tap edit sheet to customize `alert_days`, `cost_price`, `sell_price`, and `current_stock`.

### 6. Interactive Analytics & Profit Dashboard (`lib/features/dashboard/dashboard_screen.dart`)
- **Period Filter**: `SegmentedButton` toggle for **Today**, **7 Days**, and **30 Days**.
- **Financial Metrics**:
  - Total Sales (Cash + Credit sales)
  - Operating Expenses
  - Estimated Gross Profit: $\text{Sales} - (\text{Sold Qty} \times \text{Cost Price}) - \text{Expenses}$
  - Credit Extended in Period vs. All-Time Customer Credit Due
- **Interactive Visualizations (`fl_chart`)**:
  - Daily sales timeline bar chart.
  - Top 5 revenue-generating items bar chart.
- **Operational Breakdowns**: Slow-moving products, top debtor customers, and critically low inventory ($\le 3$ days).
- Clean bilingual empty state (*"ఇంకా డేటా లేదు · No data yet"*).

### 7. Synthetic Kirana Demo Generator (`lib/features/settings/settings_screen.dart`)
- Built for quick testing and demonstrations in debug builds (`kDebugMode`).
- **Generate 30 Days Demo Data**: Synthesizes 30 days of realistic Kirana commerce with higher weekend customer volumes, recurring restocks, debt payments, and store utilities.
- **Reset All Data**: One-tap clean wipe of all tables (`txn`, `stock_log`, `customer`, `alert`, `item`) and reseeding of the 8 default staples.

---

## 📁 Project Structure

```
lib/
├── app.dart                   # MaterialApp shell, navigation tabs & theme
├── main.dart                  # App bootstrap, web/mobile SQLite & notification init
├── core/
│   ├── env.dart.example       # Supabase credential template (optional backup)
│   ├── notifications.dart     # FlutterLocalNotifications wrapper with kIsWeb guard
│   ├── strings.dart           # Centralized bilingual Telugu · English labels
│   └── theme.dart             # High-contrast Material 3 Kirana theme
├── data/
│   ├── analytics.dart         # Dashboard models and query definitions
│   ├── item_model.dart        # Item, Customer, Txn, StockLog, Alert models
│   ├── kirana_provider.dart   # ChangeNotifier state coordinator
│   ├── local_db.dart          # SQLite tables, triggers, queries & demo data generator
│   ├── parser.dart            # Rule-based NLP entity extractor (Telugu & Romanized)
│   └── stock_engine.dart      # Pure Dart 14-day weighted depletion engine
└── features/
    ├── assistant/             # Assistant tab screen
    ├── dashboard/             # Executive analytics & fl_chart bar graphs
    ├── home/                  # Quick voice entry, low stock banner, weekly audits
    ├── ledger/                # Udhar credit balances & customer account detail
    ├── settings/              # App info, demo data generator & factory reset
    └── stock/                 # Inventory list, stock progress indicators & editor
test/
├── database_smoke_test.dart   # SQLite schema and serialization tests
├── parser_test.dart           # 10 bilingual NLP extraction unit tests
├── stock_engine_test.dart     # 5 stock depletion & window boundary tests
└── widget_test.dart           # Full 5-tab UI smoke & transaction save test
```

---

## 🧪 Testing & Verification

All tests run locally on device/desktop without an active internet connection.

```bash
# Run all unit and widget tests
flutter test

# Run code analysis
flutter analyze
```

### Test Suite Summary:
- ✅ **`stock_engine_test.dart` (5 tests)**: Steady sales, recent spike weighting, new items with $<3$ days history, zero sales edge cases, zero stock behavior.
- ✅ **`parser_test.dart` (10 tests)**: Telugu script credit/cash sales, Romanized credit/cash sales, repayments, supplier restocks, and shop expenses.
- ✅ **`database_smoke_test.dart` (2 tests)**: In-memory table creation, CRUD operations, model serialization.
- ✅ **`widget_test.dart` (2 tests)**: Full 5-tab shell navigation, UI text rendering, and voice/type entry $\to$ confirm sheet $\to$ save transaction flow.
- ✅ **`flutter analyze`**: **0 issues found**.

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK**: `^3.7.0` or higher
- **Android SDK**: `minSdkVersion 26` (Android 8.0+)
- **Google Chrome**: For browser-based evaluation

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/akhilbehara999/4-2.git
   cd 4-2
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run on Chrome (Web):**
   ```bash
   flutter run -d chrome
   ```

4. **Run on Android Emulator or Physical Device:**
   ```bash
   flutter run -d android
   ```

---

## 🛠️ Technology Stack

| Technology | Purpose |
|---|---|
| **Flutter & Dart** | Cross-platform frontend application |
| **sqflite** | On-device persistent SQLite storage for Android |
| **sqflite_common_ffi_web** | WASM-based SQLite driver for in-browser evaluation |
| **provider** | Lightweight, reactive app state management |
| **fl_chart** | Fluid, responsive bar charts for business analytics |
| **speech_to_text** | On-device speech recognition integration |
| **flutter_local_notifications**| Native Android background alerts and status updates |
| **permission_handler** | Android runtime microphone & notification permissions |

---

## 📝 License
Built with ❤️ for Indian kirana store owners. Distributed under the MIT License.
