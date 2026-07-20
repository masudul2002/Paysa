# Information Architecture & UX Flow

**Product:** Paysa — Offline-first Finance & Ledger Platform  
**Document:** IA-UX v1.0  
**Status:** Draft  
**Owner:** Product Design  
**Last Updated:** 2026-07-20  

---

## TABLE OF CONTENTS

1. [Screen Tree](#1-screen-tree)
2. [Navigation Tree](#2-navigation-tree)
3. [User Flow Diagrams](#3-user-flow-diagrams)
4. [Information Architecture](#4-information-architecture)
5. [UX Decisions](#5-ux-decisions)
6. [Navigation Rules](#6-navigation-rules)
7. [Design Notes](#7-design-notes)
8. [Future Expansion Strategy](#8-future-expansion-strategy)
9. [Appendix: Screen Specifications](#9-appendix-screen-specifications)

---

## 1. Screen Tree

### 1.1 Complete Screen Inventory

Every screen in the application is listed below, organized by module. Each screen has a unique ID for cross-referencing.

#### 1.1.1 System Screens

| ID | Screen | Type | Purpose |
|----|--------|------|---------|
| S-01 | Splash | Splash | Brand animation, initialization |
| S-02 | Onboarding | Full | First-launch introduction (3 steps) |
| S-03 | App Lock | Full | PIN/Biometric unlock (future) |

#### 1.1.2 Shell (Persistent Container)

| ID | Screen | Type | Purpose |
|----|--------|------|---------|
| S-10 | App Shell | Shell | Bottom nav, persistent scaffold |

#### 1.1.3 Dashboard

| ID | Screen | Type | Purpose |
|----|--------|------|---------|
| S-20 | Dashboard | Full | Home screen, aggregated overview |
| S-21 | Quick Action Sheet | Bottom Sheet | Action selector overlay |

#### 1.1.4 Accounts

| ID | Screen | Type | Purpose |
|----|--------|------|---------|
| S-30 | Account List | Full | All accounts with balances |
| S-31 | Account Detail | Full | Single account with transactions |
| S-32 | Account Form | Bottom Sheet | Create/edit account |

#### 1.1.5 Transactions

| ID | Screen | Type | Purpose |
|----|--------|------|---------|
| S-40 | Transaction List | Full | All transactions, filterable |
| S-41 | Transaction Detail | Full | Single transaction view |
| S-42 | Income Form | Bottom Sheet | Record income |
| S-43 | Expense Form | Bottom Sheet | Record expense |
| S-44 | Transfer Form | Bottom Sheet | Transfer between accounts |
| S-45 | Recurring Template List | Full | Manage recurring templates |
| S-46 | Recurring Template Form | Bottom Sheet | Create/edit recurring template |

#### 1.1.6 Categories

| ID | Screen | Type | Purpose |
|----|--------|------|---------|
| S-50 | Category List | Full | All categories grouped by type |
| S-51 | Category Form | Bottom Sheet | Create/edit category |

#### 1.1.7 People (Ledger)

| ID | Screen | Type | Purpose |
|----|--------|------|---------|
| S-60 | People List | Full | All people with balances |
| S-61 | Person Detail | Full | Person info + ledger history |
| S-62 | Person Form | Bottom Sheet | Create/edit person |
| S-63 | Opening Balance Dialog | Dialog | Set opening balance on create |

#### 1.1.8 Ledger Entries

| ID | Screen | Type | Purpose |
|----|--------|------|---------|
| S-70 | Ledger History | Full | Full transaction timeline for a person |
| S-71 | Give Money Form | Bottom Sheet | Record lending/payment |
| S-72 | Receive Money Form | Bottom Sheet | Record repayment/collection |
| S-73 | Sale Form | Bottom Sheet | Record sale to customer |
| S-74 | Purchase Form | Bottom Sheet | Record purchase from supplier |
| S-75 | Adjustment Form | Bottom Sheet | Record balance adjustment |
| S-76 | Discount Form | Bottom Sheet | Record write-off/discount |
| S-77 | Ledger Entry Detail | Bottom Sheet | View/edit single entry |
| S-78 | Link Receive to Give | Dialog | Select which Give entry to settle |

#### 1.1.9 Payment Methods

| ID | Screen | Type | Purpose |
|----|--------|------|---------|
| S-80 | Payment Method List | Full | Manage payment methods |
| S-81 | Payment Method Form | Bottom Sheet | Add custom payment method |

#### 1.1.10 Budgets

| ID | Screen | Type | Purpose |
|----|--------|------|---------|
| S-90 | Budget List | Full | All budgets with progress |
| S-91 | Budget Detail | Full | Single budget with breakdown |
| S-92 | Budget Form | Bottom Sheet | Create/edit budget |

#### 1.1.11 Savings Goals

| ID | Screen | Type | Purpose |
|----|--------|------|---------|
| S-100 | Goal List | Full | All goals with progress |
| S-101 | Goal Detail | Full | Single goal with allocation history |
| S-102 | Goal Form | Bottom Sheet | Create/edit goal |
| S-103 | Allocate to Goal | Bottom Sheet | Add funds to goal |

#### 1.1.12 Reports

| ID | Screen | Type | Purpose |
|----|--------|------|---------|
| S-110 | Report Hub | Full | Report type selector |
| S-111 | Spending by Category | Full | Chart + breakdown |
| S-112 | Income vs Expense | Full | Bar chart + totals |
| S-113 | Net Worth | Full | Line chart + history |
| S-114 | Cash Flow | Full | Table + totals |
| S-115 | Budget vs Actual | Full | Comparison chart |
| S-116 | Monthly Summary | Full | Month overview card |
| S-117 | Category Summary | Full | Per-category table |
| S-118 | Account Summary | Full | Per-account table |
| S-119 | Outstanding Summary | Full | All people with balances |
| S-120 | Person Statement | Full | Full person history |
| S-121 | Report Date Range Picker | Bottom Sheet | Select period |

#### 1.1.13 Search

| ID | Screen | Type | Purpose |
|----|--------|------|---------|
| S-130 | Search | Full | Full-screen search with results |
| S-131 | Search Results | Inline | Results list within search |

#### 1.1.14 Notifications

| ID | Screen | Type | Purpose |
|----|--------|------|---------|
| S-140 | Notification List | Full | All notification history |
| S-141 | Notification Settings | Full | Per-type toggle configuration |

#### 1.1.15 Backup & Restore

| ID | Screen | Type | Purpose |
|----|--------|------|---------|
| S-150 | Backup Center | Full | Backup/restore actions |
| S-151 | Backup Progress | Dialog | Progress indicator |
| S-152 | Restore Confirm | Dialog | Warning + confirmation |

#### 1.1.16 Settings

| ID | Screen | Type | Purpose |
|----|--------|------|---------|
| S-160 | Settings Hub | Full | Settings category list |
| S-161 | General Settings | Full | Currency, defaults, format |
| S-162 | Appearance Settings | Full | Theme, font, color |
| S-163 | Transaction Settings | Full | Negative balance, defaults |
| S-164 | Ledger Settings | Full | Entry defaults, reminder time |
| S-165 | Notification Settings | Full | Per-type toggles |
| S-166 | Backup Settings | Full | Backup/restore actions |
| S-167 | About / Licenses | Full | Version info, legal |

#### 1.1.17 Share & Export

| ID | Screen | Type | Purpose |
|----|--------|------|---------|
| S-170 | Share Sheet | System | OS share sheet |
| S-171 | Statement Preview | Full | Preview before sharing |
| S-172 | Export Format Picker | Bottom Sheet | PDF, CSV, Image |

---

### 1.2 Screen Hierarchy Diagram

```
S-01 Splash
  │
  ├──► [First launch] ──► S-02 Onboarding (3 steps)
  │                            │
  │                            └──► S-10 App Shell
  │
  └──► [Returning user] ──► S-03 App Lock (if enabled)
                                │
                                └──► S-10 App Shell
                                      │
                          ┌───────────┼──────────────┬────────────────┬──────────────┐
                          │           │              │                │              │
                     S-20        S-30 / S-31    S-40 / S-41     S-60 / S-61      More
                   Dashboard     Accounts       Transactions      People         ┌─────┴─────┐
                      │              │               │               │          S-90   S-130
                      │              │               │               │        Budgets  Search
                      │              │               │               │           │
                      │              │               │               ├── S-62 Person   │
                      │              │               │               ├── S-63 Open Bal │
                      │              │               │               │                 │
                      │              │               │               └── S-70 Ledger   │
                      │              │               │                     │           │
                      │              │               │              S-71 Give Money    │
                      │              │               │              S-72 Receive Money │
                      │              │               │              S-73 Sale          │
                      │              │               │              S-74 Purchase      │
                      │              │               │              S-75 Adjustment    │
                      │              │               │              S-76 Discount      │
                      │              │               │              S-77 Entry Detail  │
                      │              │               │              S-78 Link Settle   │
                      │              │               │                                 │
                      │              │               ├── S-42 Income                  │
                      │              │               ├── S-43 Expense                 │
                      │              │               ├── S-44 Transfer                │
                      │              │               ├── S-45 Recurring List          │
                      │              │               └── S-46 Recurring Form          │
                      │              │
                      │         S-32 Account Form    S-50 Category List  S-80 Pay Methods
                      │                              └── S-51 Category   └── S-81 Pay Form
                      │
                      ├── S-21 Quick Action Sheet
                      │
                      ├── S-110 Report Hub ──► S-111 through S-121
                      │
                      ├── S-100 Goal List ──► S-101 Detail
                      │                          └── S-102 Form / S-103 Allocate
                      │
                      ├── S-140 Notification List
                      │
                      ├── S-150 Backup Center
                      │
                      └── S-160 Settings Hub ──► S-161 through S-167
```

---

## 2. Navigation Tree

### 2.1 Bottom Navigation (Shell Level)

The bottom navigation bar contains 5 items. The center item is the FAB trigger for quick actions.

```
┌──────────┬──────────┬──────────┬──────────┬──────────┐
│ Dashboard │ Accounts │    +     │  People  │  More    │
│  (Home)   │          │  (FAB)   │ (Ledger) │          │
├──────────┼──────────┼──────────┼──────────┼──────────┤
│   Icon:  │  Icon:   │  Icon:   │  Icon:   │  Icon:   │
│  dashboard│  wallet  │   add    │  people  │  more_horiz│
└──────────┴──────────┴──────────┴──────────┴──────────┘
```

- **Tab 1 — Dashboard** (S-20): Default landing after splash.
- **Tab 2 — Accounts** (S-30 / S-31): Account list by default, detail when an account is selected.
- **Tab 3 — Quick Action** (Center FAB): Opens S-21 Quick Action Sheet. Not a navigation destination.
- **Tab 4 — People** (S-60 / S-61): People list by default, person detail when selected.
- **Tab 5 — More**: Opens a grid or list menu containing:
  - Reports (S-110), Budgets (S-90), Goals (S-100), Categories (S-50), Payment Methods (S-80), Search (S-130), Notifications (S-140), Backup (S-150), Settings (S-160)

### 2.2 Quick Action Sheet (S-21)

Triggered by the center FAB. Appears as a bottom sheet grid with 6 action buttons:

```
┌────────────────────────────────────┐
│  Quick Actions                     │
│                                    │
│  ┌──────┐ ┌──────┐ ┌──────┐        │
│  │Income │ │Expense│ │Transfer│     │
│  │  ▲    │ │  ▼   │ │  ⇄   │       │
│  └──────┘ └──────┘ └──────┘        │
│  ┌──────┐ ┌──────┐ ┌──────┐        │
│  │ Give  │ │Receive│ │  Person│    │
│  │  →   │ │  ←   │ │  👤   │      │
│  └──────┘ └──────┘ └──────┘        │
└────────────────────────────────────┘
```

### 2.3 Navigation Rules

| Rule | Description |
|------|-------------|
| NR-01 | Bottom navigation preserves the selected tab's stack when switching tabs |
| NR-02 | The center FAB is not a navigation destination — it opens an overlay |
| NR-03 | Back navigation from a detail screen returns to the list screen within the same tab |
| NR-04 | Back navigation from a form (bottom sheet) dismisses the sheet without saving |
| NR-05 | All forms use bottom sheets, never full-screen navigation |
| NR-06 | Dialogs are used only for confirmations, never for data entry |
| NR-07 | Deep linking: `/accounts/{id}`, `/people/{id}`, `/transactions/{id}`, `/reports/{type}` |
| NR-08 | Search is accessible from any screen via a search icon in the app bar |
| NR-09 | The "More" tab is always the last (5th) item — it never reorders |
| NR-10 | Person Detail and Ledger History are on the same screen |
| NR-11 | Report screens are read-only — back always returns to Report Hub |
| NR-12 | Settings sub-screens push onto the stack and return to Settings Hub |

### 2.4 App Bar Behavior by Screen Type

| Screen Type | App Bar Content |
|-------------|-----------------|
| Dashboard | Title: "Paysa", Search icon, Notification bell |
| List screens | Title, Search icon (if applicable), Sort/Filter icon |
| Detail screens | Back arrow, Title: entity name, Edit icon |
| Form sheets | No app bar — drag handle for dismissal |

### 2.5 FAB Behavior by Screen

| Screen | FAB Action |
|--------|-----------|
| Dashboard | None (center nav FAB) |
| Account List | New Account |
| Transaction List | New Transaction (opens Quick Action Sheet) |
| People List | New Person |
| Budget List | New Budget |
| Goal List | New Goal |
| Category List | New Category |
| Notifications | Mark All Read |

---

## 3. User Flow Diagrams

### 3.1 New User Onboarding

```
[App Install]
     │
     ▼
[S-01 Splash — 500ms brand animation]
     │
     ▼
[S-02 Onboarding Step 1]
  "Welcome to Paysa"
  "Your all-in-one finance & ledger platform"
  [Next]
     │
     ▼
[S-02 Onboarding Step 2]
  "Track Personal Finances"
  "Income, expenses, budgets, and savings goals"
  [Skip]  [Next]
     │
     ▼
[S-02 Onboarding Step 3]
  "Manage Ledgers"
  "Track customer, supplier, and personal lending"
  [Skip]  [Get Started]
     │
     ▼
[S-10 App Shell → S-20 Dashboard — Empty State]
  ┌─────────────────────────────────┐
  │  Welcome to Paysa!              │
  │  Create your first account      │
  │  to start tracking your money.  │
  │                                 │
  │  [Create First Account]         │
  │  [Add a Person]                 │
  └─────────────────────────────────┘
```

### 3.2 Create First Account

```
[Dashboard CTA or Accounts tab → + FAB]
     │
     ▼
[S-32 Account Form — Bottom Sheet]
  Name: [__________] | Type: [▼] | Balance: [___] | Currency: [▼]
  [Cancel]  [Save Account]
     │
     ├── Success → Dashboard updates balance, Snackbar: "Account created"
     └── Error → Inline validation: "Name is required", "Name must be unique"
```

### 3.3 Record Income

```
[FAB] → [Income]
     │
     ▼
[S-42 Income Form — Bottom Sheet]
  Amount: [___] | Account: [▼] | Category: [▼] | Date: [▼]
  Payment: [▼] | Description: [___] | Tags: [...]
  [Cancel]  [Save Income]
     │
     └── Success → Balance increases, Snackbar: "Income recorded"
```

### 3.4 Record Expense

```
[FAB] → [Expense]
     │
     ▼
[S-43 Expense Form — Bottom Sheet]
  Amount: [___] | Account: [▼] | Category: [▼] | Date: [▼]
  Payment: [▼] | Pending: [ ] | Description: [___]
  Tags: [...] | Note: [___]
  [Cancel]  [Save Expense]
     │
     └── Success → Balance decreases, Snackbar: "Expense recorded"
```

### 3.5 Transfer Between Accounts

```
[FAB] → [Transfer]
     │
     ▼
[S-44 Transfer Form — Bottom Sheet]
  From: [▼] | To: [▼] | Amount: [___] | Exchange Rate: [___]
  [Cancel]  [Transfer]
     │
     ├── Same currency → Source debited, destination credited
     └── Different currency → Rate required, fee recorded as expense
```

### 3.6 Create Person

```
[People Tab → + FAB]
     │
     ▼
[S-62 Person Form — Bottom Sheet]
  Name: [___] | Type: [▼] | Phone: [___] | Email: [___]
  Opening Balance: [Yes/No] → Amount: [___] Direction: [Give/Receive]
  [Cancel]  [Save Person]
     │
     ├── Success → Person listed with balance, Snackbar
     └── Duplicate → Warning: "Already exists. Add anyway?"
```

### 3.7 Lend Money (Give Money)

```
[Person Detail → FAB → Give] or [FAB → Give → Select Person]
     │
     ▼
[S-71 Give Money Form — Bottom Sheet]
  Person: [Rafiq] | Balance: +Tk 0 | Amount: [15000]
  From: [Cash] | Type: [Loan/Gift] | Due: [2026-08-20]
  Reminder: [✔] | Note: [___]
  [Cancel]  [Give Money]
     │
     ├── Loan → Balance +15,000, Account -15,000, Reminder set
     └── Gift → Balance +15,000, Account -15,000, No reminder
```

### 3.8 Receive Payment (Receive Money)

```
[Person Detail → Receive] or [FAB → Receive → Select Person]
     │
     ▼
[S-72 Receive Money Form — Bottom Sheet]
  Person: [Rafiq] | Balance: +Tk 15,000
  Amount: [5000] | To: [Cash] | Settle Against: [Specific/Any]
  [Cancel]  [Receive]
     │
     └── Success → Balance +15,000 → +10,000, Account +5,000
```

### 3.9 View Statement

```
[Person Detail → Menu → Share Statement]
     │
     ▼
[S-171 Statement Preview]
  Statement for Rafiq Ahmed
  Outstanding: Tk 10,000
  [Entry list with running balance]
  [Share] [Export PDF] [Save Image]
```

### 3.10 Backup & Restore

```
[More → Settings → Backup]
     │
     ▼
[S-150 Backup Center]
  [Create Backup] → Progress → File picker → Snackbar
  [Restore] → Confirm dialog → File picker → Progress → Snackbar
  [Clear All Data] → Double confirm → Wipe
```

### 3.11 Generate Reports

```
[More → Reports]
     │
     ▼
[S-110 Report Hub]
  Select report type → Select date range → View report
  [Share] → [Export Format Picker] → [PDF/CSV/Image]
```

### 3.12 Search

```
[Search icon — any screen]
     │
     ▼
[S-130 Search]
  Type > 2 chars → Results grouped by:
  [Transactions] [People] [Ledger Entries]
  Tap → Navigate to detail
```

### 3.13 Budget Creation

```
[More → Budgets → + FAB]
     │
     ▼
[S-92 Budget Form — Bottom Sheet]
  Name | Amount | Period | Categories | Type | Alert %
  [Save] → List, Dashboard, Snackbar
```

### 3.14 Savings Goal Flow

```
[More → Goals → + FAB]
     │
     ▼
[S-102 Goal Form — Bottom Sheet]
  Name | Target | Deadline | Source | Initial Allocation
  [Save] → Goal created, allocation deducted
```

---

## 4. Information Architecture

### 4.1 Content Grouping

```
[HOME]
├── Dashboard (S-20)
│   ├── Balance Summary Card
│   ├── Outstanding Summary Card (Ledger)
│   ├── Recent Activity Feed
│   ├── Budget Progress Cards
│   ├── Goal Progress Cards
│   └── Quick Action Bar

[FINANCE DOMAIN]
├── Accounts
│   ├── Account List (S-30)
│   ├── Account Detail + Transactions (S-31)
│   └── Account Form (S-32)
├── Transactions
│   ├── Transaction List (S-40)
│   ├── Transaction Detail (S-41)
│   ├── Income Form (S-42)
│   ├── Expense Form (S-43)
│   ├── Transfer Form (S-44)
│   ├── Recurring Templates (S-45)
│   └── Recurring Form (S-46)
├── Categories
│   ├── Category List (S-50)
│   └── Category Form (S-51)
├── Budgets
│   ├── Budget List (S-90)
│   ├── Budget Detail (S-91)
│   └── Budget Form (S-92)
├── Savings Goals
│   ├── Goal List (S-100)
│   ├── Goal Detail (S-101)
│   ├── Goal Form (S-102)
│   └── Allocate Form (S-103)
└── Reports (Finance)
    ├── Report Hub (S-110)
    ├── Spending by Category (S-111)
    ├── Income vs Expense (S-112)
    ├── Net Worth (S-113)
    ├── Cash Flow (S-114)
    ├── Budget vs Actual (S-115)
    ├── Monthly Summary (S-116)
    ├── Category Summary (S-117)
    ├── Account Summary (S-118)
    └── Date Range Picker (S-121)

[LEDGER DOMAIN]
├── People
│   ├── People List (S-60)
│   ├── Person Detail + Ledger History (S-61/S-70)
│   ├── Person Form (S-62)
│   ├── Opening Balance Dialog (S-63)
│   ├── Give Money Form (S-71)
│   ├── Receive Money Form (S-72)
│   ├── Sale Form (S-73)
│   ├── Purchase Form (S-74)
│   ├── Adjustment Form (S-75)
│   ├── Discount Form (S-76)
│   ├── Entry Detail (S-77)
│   ├── Link Settlement (S-78)
│   └── Share Statement (S-171)
└── Reports (Ledger)
    ├── Outstanding Summary (S-119)
    └── Person Statement (S-120)

[CROSS-CUTTING]
├── Payment Methods (S-80, S-81)
├── Search (S-130)
├── Notifications (S-140, S-141)
├── Backup & Restore (S-150, S-151, S-152)
├── Settings (S-160 through S-167)
└── Share & Export (S-170, S-171, S-172)
```

### 4.2 Feature Access by Screen

| Feature | Path | Taps |
|---------|------|------|
| View Balance | Dashboard | 1 |
| Add Income | FAB → Income | 2 |
| Add Expense | FAB → Expense | 2 |
| Transfer | FAB → Transfer | 2 |
| View Transactions | Transactions tab | 1 |
| View by Account | Accounts → Tap account | 2 |
| Add Person | People tab → FAB | 2 |
| Give Money | People → Person → Give | 3 |
| Receive Money | People → Person → Receive | 3 |
| View Ledger | People → Person | 2 |
| Share Statement | People → Person → Menu → Share | 3 |
| View Reports | More → Reports | 2 |
| View Budget | More → Budgets | 2 |
| View Goals | More → Goals | 2 |
| Search | Any screen → Search icon | 1 |
| Backup | More → Settings → Backup | 3 |
| Settings | More → Settings | 2 |

### 4.3 Navigation Depth Analysis

| Depth | % Actions | Examples |
|-------|-----------|---------|
| 1 tap | ~30% | View balance, recent activity |
| 2 taps | ~50% | Add transaction, view person |
| 3 taps | ~15% | Give money, share statement |
| 4+ taps | ~5% | Settings, backup |

**Target:** 80% of common actions within 2 taps.

---

## 5. UX Decisions

### 5.1 Form Pattern — Bottom Sheets Only

All data entry uses modal bottom sheets. Rationale: preserves navigation context, enables one-handed use, faster dismissal, supports quick consecutive entries.

### 5.2 List Pattern — Grouped ListTile

All lists use grouped `ListTile` with leading icon and trailing amount/value. Rationale: consistent visual scanning, immediate type identification, right-aligned amount is the most important data point.

### 5.3 Balance Display — Color-Coded + Signed

Balances show currency code, color (green positive, red negative), and sign indicator (+/-). Rationale: immediate emotional signal, accessibility for color-blind users.

### 5.4 Quick Action FAB — Center Nav

The center bottom nav item is a FAB, not a navigation destination. Rationale: recording transactions is the most frequent action, FAB is visually distinct, sheet-based selection allows choosing type without navigating away.

### 5.5 Person + Ledger — Same Screen

Person Detail and Ledger History are the same screen. Rationale: when viewing a person, the ledger is the primary content. Separate screens add unnecessary depth.

### 5.6 No Action Landing Page — Sheet In Place

Quick Action Sheet opens and closes in place, no navigation history created. Rationale: faster multiple actions, unambiguous back behavior.

### 5.7 Separate Transaction Forms

Income, Expense, Transfer have separate forms, not a unified "Add Transaction" form. Rationale: different required fields per type, conditional fields in a unified form are confusing.

### 5.8 Separate Ledger Entry Forms

Give, Receive, Sale, Purchase, Adjustment, Discount each have distinct forms. Rationale: distinct business rules per type, explicit naming reduces errors.

### 5.9 Report Hub Pattern

Reports hub lists all report types. Each opens into its own read-only view. Rationale: reports are read-only, back always returns to hub, consistent with Settings.

### 5.10 Settings Organization

Settings Hub lists categories, each opens to a sub-screen. Rationale: settings aren't frequently changed, depth is acceptable, categories prevent endless scroll.

### 5.11 Empty States — Onboarding Opportunities

Every list has a purposeful empty state with illustration, message, and action button. Rationale: first-time users need guidance, reducing friction to first data entry.

### 5.12 Error Handling — Layered

Inline form errors for validation, snackbar for mutations, full-page for loading failures. Rationale: errors shown at the right level of context and urgency.

---

## 6. Navigation Rules

### 6.1 Tab Navigation Rules

- TNR-01: Tabs preserve their navigation stack when switching
- TNR-02: Active tab uses the filled icon variant
- TNR-03: Tabs are always visible except when full-screen modal (search, reports) is open
- TNR-04: Center FAB is not a tab — tapping opens Quick Action Sheet
- TNR-05: Badge counts on People tab (overdue reminders) and Notifications (unread)

### 6.2 Bottom Sheet Rules

- BSR-01: All forms use modal bottom sheets with drag handle
- BSR-02: Swipe down dismisses without saving
- BSR-03: Back button dismisses without saving
- BSR-04: Sheets max height 90% of screen
- BSR-05: Long forms scroll within sheet
- BSR-06: Keyboard does not obscure primary action button

### 6.3 Back Navigation Rules

- BNR-01: Back from detail → list in same tab
- BNR-02: Back from form sheet → sheet dismissed (no save)
- BNR-03: Back from report → Report Hub
- BNR-04: Back from Settings sub-screen → Settings Hub
- BNR-05: Back from Search → previous screen (not home)
- BNR-06: Back from any screen with unsaved data → confirm discard dialog

### 6.4 Deep Linking Rules

- DLR-01: Route pattern: `/accounts/:id`, `/people/:id`, `/transactions/:id`, `/reports/:type`
- DLR-02: Unknown routes redirect to Dashboard
- DLR-03: Notification taps use deep links to navigate to relevant screen
- DLR-04: Deep links work whether app is foreground, background, or cold-started

---

## 7. Design Notes

### 7.1 Touch Targets

| Element | Min Size | Notes |
|---------|----------|-------|
| Touch target | 48×48 dp | Material 3 standard |
| List item height | 72 dp | Comfortable reading |
| Amount font size | 24-32 sp | Prominent scanning |
| Category label | 12-14 sp | Secondary info |
| Bottom sheet drag handle | 32×4 dp | Always visible |

### 7.2 Functional Colors

| Context | Hex |
|---------|-----|
| Income / Positive | #16A34A |
| Expense / Negative | #DC2626 |
| Pending | #D97706 |
| Loan due / Warning | #EA580C |
| Give Money (outgoing) | Red tint |
| Receive Money (incoming) | Green tint |
| Settled | #6B7280 |
| Overdue badge | #DC2626 |

### 7.3 Animation Durations

| Transition | Duration | Easing |
|------------|----------|--------|
| Screen transition | 300ms | EaseInOut |
| Bottom sheet appear | 250ms | EaseOut |
| Bottom sheet dismiss | 200ms | EaseIn |
| Snackbar auto-dismiss | 4s delay | — |
| Chart animation | 800ms | EaseOut |

### 7.4 Empty State Messages

| Screen | Title | Action |
|--------|-------|--------|
| Dashboard | Welcome to Paysa! | Create Account |
| Accounts | No accounts yet | Add Account |
| Transactions | No transactions yet | Add Transaction |
| People | No people yet | Add Person |
| Ledger | No entries yet | Give Money |
| Budgets | No budgets yet | Create Budget |
| Goals | No goals yet | Create Goal |
| Reports | No data for this period | Go to Transactions |
| Backup | No backup yet | Create Backup |

---

## 8. Future Expansion Strategy

### 8.1 Cloud Sync Impact

- Navigation: No change — sync is background
- Dashboard: No change — still local computation
- Settings: Add "Cloud Sync" section
- Backup: Add "Cloud Backup" option
- Conflicts: Add "Sync Conflicts" screen

### 8.2 Future Feature Integration

| Feature | Integration Point |
|---------|------------------|
| OCR Scanner | Expense Form — Camera icon |
| Bank Import | Settings → Data → Import |
| PDF Export | Every Report — Export button |
| Multi-Device Sync | Settings → Cloud Sync |
| Household Sharing | People → "Household" type |
| AI Insights | Dashboard bottom card |
| Budget Templates | Budget Form → "Load Template" |
| Goal Sharing | Goal Detail → Share |

### 8.3 Scaling Limits

| Entity | Limit | Strategy |
|--------|-------|----------|
| Accounts | Unlimited | Search + filter |
| Transactions | Unlimited | Virtual scrolling, date-indexed |
| People | Unlimited | Search + type filter |
| Ledger entries | Unlimited per person | Virtual scrolling |
| Categories | Unlimited | Type-grouped + search |
| Active budgets | 50 | Archive old ones |
| Active goals | 50 | Archive completed |
| Attachments per entry | 5 | Compression, storage alert |

---

## 9. Appendix: Screen Specifications

### 9.1 Dashboard (S-20)

| Element | Value |
|---------|-------|
| Purpose | Aggregated financial overview at a glance |
| Entry Points | App launch → Splash → Dashboard |
| Exit Points | Card tap → detail; Action → form; Tab navigation |
| Primary Actions | View balance, recent activity, quick action FAB |
| Required Data | Account balances, last 5 entries, budget/goal progress |
| Empty State | Welcome card with Create Account + Add Person buttons |
| Loading State | Shimmer placeholders |
| Error State | "Could not load data" with retry (rare — local data) |
| Permissions | None |

### 9.2 People List (S-60)

| Element | Value |
|---------|-------|
| Purpose | Browse and search all people with outstanding balances |
| Entry Points | Tab 4: People; Search result tap |
| Exit Points | Person tap → detail; Tab nav; Back |
| Primary Actions | Person tap, Search, Add Person (FAB) |
| Required Data | All people: name, type, balance, status |
| Empty State | "No people yet" with Add Person button |
| Permissions | None |

### 9.3 Person Detail + Ledger (S-61/S-70)

| Element | Value |
|---------|-------|
| Purpose | View person info and full ledger history in one screen |
| Entry Points | Person list tap |
| Exit Points | Back → People list |
| Primary Actions | Give Money (FAB), Receive Money (FAB) |
| Required Data | Person fields, all ledger entries with running balance |
| Empty State | "No entries yet" with Give/Receive buttons |
| Permissions | Storage (attachments) |

### 9.4 Give Money Form (S-71)

| Element | Value |
|---------|-------|
| Purpose | Record money given to a person (loan or gift) |
| Entry Points | Person Detail → FAB → Give; FAB → Give → Select person |
| Exit Points | Save → dismiss; Swipe → discard; Back → discard |
| Primary Actions | Amount, account, type (loan/gift), due date, save |
| Default Values | Type: Loan; Date: Today; Reminder: true if loan |
| Permissions | Storage (attachments) |

### 9.5 Receive Money Form (S-72)

| Element | Value |
|---------|-------|
| Purpose | Record money received from a person |
| Entry Points | Person Detail → Receive; FAB → Receive → Select person |
| Key UX | Show outstanding balance prominently; suggest settlement against oldest Give |
| Edge UX | If person has negative balance (user owes), warn before receiving |

### 9.6 Sale Form (S-73)

| Element | Value |
|---------|-------|
| Purpose | Record a sale to a customer (increases their balance) |
| Validation | Person must be type Customer (with confirmation override) |

### 9.7 Purchase Form (S-74)

| Element | Value |
|---------|-------|
| Purpose | Record purchase from a supplier (increases their balance) |
| Validation | Person must be type Supplier |

### 9.8 Budget List (S-90)

| Element | Value |
|---------|-------|
| Display | Progress bar per budget (green < 80%, amber 80-99%, red ≥ 100%) |
| Empty | "No budgets yet" with Create Budget button |

### 9.9 Goals List (S-100)

| Element | Value |
|---------|-------|
| Display | Progress bar per goal, completed dimmed in separate section |
| Empty | "No goals yet" with Create Goal button |

### 9.10 Settings Hub (S-160)

| Element | Value |
|---------|-------|
| Sections | General, Appearance, Transactions, Ledger, Notifications, Backup & Data, About |
| Pattern | Hub → Category sub-screen → Back to hub |

### 9.11 Quick Action Sheet (S-21)

| Element | Value |
|---------|-------|
| Design | 2-row × 3-column icon+text grid |
| Actions | Income, Expense, Transfer, Give, Receive, Add Person |
| Dismiss | Tap action (opens form), swipe down, back, tap outside |

### 9.12 Search Screen (S-130)

| Element | Value |
|---------|-------|
| Trigger | Search icon on any screen; More tab |
| Threshold | Minimum 2 characters |
| Debounce | 300ms |
| Results Group | Transactions, People, Ledger Entries |
| Recent | Last 10 searches persisted locally |

---

## Change History

| Date | Version | Author | Changes |
|------|---------|--------|---------|
| 2026-07-20 | 1.0 | Product Design | Initial IA & UX Flow document |

---

## References

- [Product Requirements Document](02_Product_Requirements_Document.md)
- [System Architecture](03_System_Architecture.md)
- [UI/UX Guidelines](06_UI_UX_Guidelines.md)
- [Design System](06_Design_System.md)
- [Documentation Home](README.md)
