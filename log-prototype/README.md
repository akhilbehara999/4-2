# LOG (We Listen · Organise · Grow)
### Offline, Voice-First Kirana Shop Manager Prototype (Telugu / English)

LOG is an Android-style mobile web application prototype designed for a Telugu neighborhood kirana (grocery) shop owner. It allows shopkeepers to track credit (*Udhar* · ఉధార్), inventory (*Stock* · స్టాక్), daily finances (*Dashboard* · డాష్‌బోర్డ్), and spoken queries (*Ask* · అడగండి) in Telugu and Romanized Telugu without requiring an internet connection.

---

## How to Run

1. **Zero build step, zero dependencies**: No Node.js, npm, or bundlers required.
2. **Double-click `index.html`** in the `log-prototype/` folder or open it in Google Chrome, Microsoft Edge, Mozilla Firefox, or Safari:
   ```
   file:///path/to/log-prototype/index.html
   ```
   *(Or serve via any static HTTP server if preferred, e.g. `npx serve log-prototype` or Python `python -m http.server`).*
3. Designed with Android (Material 3) styling. On desktop displays wider than 440px, the application renders inside a 392×820px rounded Android phone frame. On mobile screens, it stretches full-bleed.

---

## Directory Structure

```
log-prototype/
├── index.html            # Main Android app shell, system status bar, bottom nav, overlays
├── css/
│   └── app.css           # Extracted design tokens (light/dark/system), Android components
├── js/
│   ├── store.js          # Centralized reactive state store & localStorage persistence
│   ├── engine.js         # Kirana arithmetic, weighted 14-day stock forecasting, Ask queries
│   ├── parser.js         # Voice & typed rule-based Telugu/English intent & entity parser
│   ├── router.js         # Screen router, 16-screen registry, bottom sheets & toasts manager
│   └── screens/
│       ├── setup.js          # 1. First-time setup (4 steps) [Hidden]
│       ├── home.js           # 2. Home dashboard & recent activity [Main]
│       ├── more.js           # 3. More feature hub [Main]
│       ├── udhar.js          # 4. Udhar customer balances [Main]
│       ├── stock.js          # 5. Inventory item status list [Main]
│       ├── dashboard.js      # 6. Today/Week/Month financial charts [Main]
│       ├── ask.js            # 7. Kirana voice assistant chat [Main]
│       ├── transactions.js   # 8. All transactions ledger [Supporting]
│       ├── udhar-detail.js   # 9. Customer ledger & payment sheet [Supporting]
│       ├── stock-detail.js   # 10. Item usage chart & recount sheet [Supporting]
│       ├── customers.js      # 11. Customer directory management [Supporting]
│       ├── items.js          # 12. Inventory catalog management [Supporting]
│       ├── settings.js       # 13. Settings, backups, CSV export, themes [Supporting]
│       ├── listen.js         # 14. Full-screen white voice capture [Hidden]
│       ├── confirm.js        # 15. Confirm spoken/typed entry [Hidden]
│       └── recount.js        # 16. Weekly recount step-by-step audit [Hidden]
└── README.md             # Documentation, screen map, and acceptance checklist
```

---

## Screen Registry & Navigation Map (16 Screens)

The router strictly enforces a closed screen registry. Bottom navigation is visible on Main and Supporting screens, and hidden on Hidden flow screens.

| # | Route | Screen Name | Type | Nav Item | Parent | Links In | Links Out |
|---|---|---|---|---|---|---|---|
| 1 | `#/setup` | First-time Setup | Hidden | *None* | *None* | `settings` (reset) | `home` |
| 2 | `#/home` | Home | Main | Home | *None* | `setup`, `confirm`, `transactions`, `settings`, `more` | `settings`, `transactions`, `dashboard`, `confirm`, `listen`, `recount` |
| 3 | `#/more` | More Hub | Main | More | `home` | `home`, `bottom-nav` | `udhar`, `stock`, `dashboard`, `ask` |
| 4 | `#/udhar` | Udhar List | Main | More | `more` | `more` | `udhar-detail` |
| 5 | `#/stock` | Stock List | Main | More | `more` | `more`, `ask`, `recount` | `stock-detail`, `recount` |
| 6 | `#/dashboard` | Dashboard | Main | More | `more` | `more`, `home` | *(back only)* |
| 7 | `#/ask` | Ask Assistant | Main | More | `more` | `more` | `udhar-detail`, `stock` |
| 8 | `#/transactions` | All Transactions | Supporting | Home | `home` | `home` | `confirm` |
| 9 | `#/udhar/:customerId` | Customer Detail | Supporting | More | `udhar` | `udhar`, `customers`, `ask` | `confirm` |
| 10 | `#/stock/:itemId` | Stock Item Detail | Supporting | More | `stock` | `stock`, `items` | `confirm` |
| 11 | `#/customers` | Manage Customers | Supporting | More | `settings` | `settings` | `udhar-detail` |
| 12 | `#/items` | Manage Items | Supporting | More | `settings` | `settings` | `stock-detail` |
| 13 | `#/settings` | Settings | Supporting | Home | `home` | `home` | `customers`, `items`, `setup` |
| 14 | `#/listen` | Listening Screen | Hidden | *None* | `home` | `home`, `bottom-nav`, `confirm`, `ask` | `confirm` |
| 15 | `#/confirm` | Confirm Entry | Hidden | *None* | `home` | `listen`, `home`, `transactions`, `udhar-detail`, `stock-detail` | `home` |
| 16 | `#/recount` | Weekly Recount | Hidden | *None* | `stock` | `stock`, `home` | `stock` |

*To inspect the registry live, open DevTools console; `window.LOG.router.printScreenMap()` prints the formatted registry table.*

---

## Click-Path Reachability from Home

Starting from `#/home`, all 16 screens are reachable without typing URLs:
1. **Home**: Starting point (`#/home`)
2. **Setup**: Home → gear icon (`Settings`) → scroll to bottom → "Reset prototype" → Confirm → `#/setup`
3. **More**: Home → Bottom Nav "More" → `#/more`
4. **Udhar**: Home → Bottom Nav "More" → "Udhar" card → `#/udhar`
5. **Stock**: Home → Bottom Nav "More" → "Stock" card → `#/stock`
6. **Dashboard**: Home → Tap "Weekly revenue" tile or "Today's split" tile → `#/dashboard` *(or More → Dashboard)*
7. **Ask**: Home → Bottom Nav "More" → "Ask" card → `#/ask`
8. **All transactions**: Home → Recent activity "View all · అన్నీ చూడండి" button → `#/transactions`
9. **Udhar detail**: Home → More → Udhar → Tap "Ramesh" row → `#/udhar/c1`
10. **Stock detail**: Home → More → Stock → Tap "Rice" row → `#/stock/i1`
11. **Customers**: Home → gear icon (`Settings`) → "Customers · కస్టమర్లు" row → `#/customers`
12. **Items**: Home → gear icon (`Settings`) → "Items · వస్తువులు" row → `#/items`
13. **Settings**: Home → gear icon in top bar → `#/settings`
14. **Listening**: Home → Bottom Nav center "Speak" button (or mic button in header) → `#/listen`
15. **Confirm entry**: Home → Tap any entry row in Recent activity (opens in edit mode) → `#/confirm`
16. **Weekly recount**: Home → Weekly check banner "Edit · మార్చు" → `#/recount` *(or Stock → banner "Edit")*

---

## Data Reconciliation Summary

The initial dataset in `js/store.js` guarantees all prompt constraints strictly hold:
- **Ramesh**: Owes **₹4,200**. Last entry was **21 days ago**, so he is marked with the orange **Overdue** tag (threshold: 15 days).
- **Today's Kirana Business**:
  - Total Sales = **₹4,820**
  - Credit Given = **₹1,200** (Padma ₹1,200 credit sale today)
  - Cash Sales = **₹3,620** (Sales − Credit: 4,820 − 1,200 = 3,620)
  - Expenditures = **₹680** (Electricity ₹80, Transport ₹120, Restock ₹400, Misc ₹80)
  - Cash Profit = **₹2,940** (Cash sales − Expenses: 3,620 − 680 = 2,940)
  - Split Donut = Credit (₹1,200) + Expenses (₹680) + Profit (₹2,940) = ₹4,820
- **Rice Stock**: Initial quantity is **3 kg** with high daily usage, correctly classified as **Low** (red badge, ≤ 2 days left).
- **Udhar Total**: Exactly **₹12,450** across 8 customers (Ramesh ₹4,200, Venkat Rao ₹2,300, Lakshmi ₹1,850, Padma ₹1,400, Suresh ₹950, Naresh ₹800, Anitha ₹550, Kiran ₹400).
- **Usage Forecast Engine**: Weighted 14-day average where newest days carry weights $14, 13, \dots, 1$ (sum of weights = 105). Red $\le 2$ days, amber $\le 6$ days, green $> 6$ days, grey when no usage data.

---

## Acceptance Checklist Results

| # | Test Requirement | Result | Notes |
|---|---|---|---|
| 1 | **Clear localStorage → Setup** | **PASS** | On first load (or reset), opens `#/setup`. Completing 4 steps lands on `#/home` with "Sri Lakshmi Kirana" in the header. |
| 2 | **Speak button → Listening screen** | **PASS** | Tapping Speak opens full-white `#/listen`. Starts Web Speech API (`te-IN`/`en-IN`), shows interim words in grey and final words in dark text. "Check entry" navigates to `#/confirm`. Close returns to previous screen and halts microphone. |
| 3 | **Microphone permission denied** | **PASS** | Handles blocked permissions and browsers without SpeechRecognition gracefully with the "Microphone is off" state. "Type instead" allows full keyboard entry. |
| 4 | **Type "Ramesh ki 5 kg biyyam udhar 300 rs"** | **PASS** | Parser extracts Type: Credit, Customer: Ramesh, Item: Rice, Qty: 5 kg, Amount: ₹300. Shows balance hint "₹4,200 now, ₹4,500 after". Saving updates Home recent ledger, Udhar total (+₹300 to ₹12,750), Ramesh balance (₹4,500), Rice stock (−5 kg to −2 kg), and Dashboard. |
| 5 | **Ramesh detail → Payment received ₹1,000** | **PASS** | In `#/udhar/c1`, opening payment sheet with ₹1,000 reduces Ramesh balance to ₹3,500. Ledger adds payment row. Because payment occurred today, the 15-day overdue badge disappears immediately. |
| 6 | **Stock detail & Weekly recount** | **PASS** | "Correct count" on item detail updates inventory quantity, days left, and logs a count check entry. Missing screen `#/recount` reviews items one by one ("3 of 9") with Telugu prompts ("బియ్యం 12 కిలోలు ఉన్నాయా?"), Yes/Edit actions, and summary. Marking Done clears banner on Home and Stock. |
| 7 | **Add new customer & new item** | **PASS** | Adding a customer in `#/customers` and item in `#/items` checks for duplicates. They immediately appear in dropdowns, chip selectors, and the rule-based parser. |
| 8 | **Delete entry with Undo** | **PASS** | In `#/transactions`, clicking delete removes entry and displays a bottom snackbar with "Undo". Tapping Undo restores entry and item quantities. Allowing snackbar to expire commits deletion and updates balances. |
| 9 | **Ask voice queries** | **PASS** | Queries like "రామేష్ కి ఎంత ఉధార్ ఉంది?" (Ramesh balance), "ఈ రోజు ఎంత సేల్స్?" (Today sales), "items running low", and "profit this week" return dynamic data answers with actionable shortcut cards. |
| 10 | **Theme switch & Persistence** | **PASS** | Theme switcher in `#/settings` (System, Light, Dark) instantly sets `data-theme` on document root and persists across reloads via localStorage. |
| 11 | **No dead buttons** | **PASS** | Every button, link, switch, search filter, period chip, sheet scrim, and modal is hooked to working JavaScript handlers. |
| 12 | **Back button & Browser history** | **PASS** | Hardware/browser back button (`hashchange`) and top-bar back arrow return to previous screen in history, or to the designated parent screen if opened directly. |
| 13 | **Reachability of all 16 screens** | **PASS** | Starting from `#/home`, every screen can be reached strictly through in-app links and buttons. |
| 14 | **Bottom navigation visibility** | **PASS** | Visible on all 12 Main and Supporting screens, hidden on the 4 Hidden screens (`#/setup`, `#/listen`, `#/confirm`, `#/recount`), with proper highlight styling (`aria-current="page"`). |
| 15 | **Screen map printer** | **PASS** | `LOG.router.printScreenMap()` outputs the complete 16-screen registry matching the connection specification. |

---

## Technical Assumptions & Design Notes

1. **Client-side storage**: `localStorage` stores shop profile, customers, items, and entries under the key `log_app_data_v1`. If localStorage is blocked or throws, an in-memory fallback preserves data during the active session.
2. **Audio / Speech Recognition**: Uses the standard `window.SpeechRecognition || window.webkitSpeechRecognition` Web Speech API. If speech recognition is unavailable or blocked, simulated microphone tests and "Type instead" fallbacks are provided without error.
3. **Data Export & Backup**: "Back up now" saves a JSON snapshot to localStorage. "Export data" generates a real RFC-4180 CSV file (`log_transactions.csv`) and triggers a direct browser download. "Restore from backup" accepts valid JSON files via file picker.
4. **Offline Copy Remind**: Tapping "Remind · గుర్తు చేయి" copies a localized Telugu reminder message to the system clipboard (e.g. `రామేష్, మీ బాకీ ₹4,200. దయచేసి చెల్లించండి. – శ్రీ లక్ష్మి కిరాణా`). If `navigator.clipboard` access is denied by browser permissions, an in-page bottom sheet fallback displays the text for manual copying.
