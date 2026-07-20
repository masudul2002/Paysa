# Database Architecture & Data Modeling

**Product:** Paysa — Offline-first Finance & Ledger Platform  
**Document:** DB v1.0  
**Status:** Draft  
**Owner:** Database Architecture  
**Last Updated:** 2026-07-20  

---

## TABLE OF CONTENTS

1. [Principles & Decisions](#1-principles--decisions)
2. [Money Design](#2-money-design)
3. [Complete Entity Catalog](#3-complete-entity-catalog)
4. [Entity Relationship Diagram](#4-entity-relationship-diagram)
5. [Detailed Entity Specifications](#5-detailed-entity-specifications)
6. [Index Strategy](#6-index-strategy)
7. [Validation & Business Rules](#7-validation--business-rules)
8. [Ledger System Design](#8-ledger-system-design)
9. [Sync Architecture](#9-sync-architecture)
10. [Backup & Restore](#10-backup--restore)
11. [Search Architecture](#11-search-architecture)
12. [Reporting Architecture](#12-reporting-architecture)
13. [Migration Strategy](#13-migration-strategy)
14. [Future Expansion](#14-future-expansion)

---

## 1. Principles & Decisions

### 1.1 Core Principles

| Principle | Description |
|-----------|-------------|
| **Offline-first** | Every operation works without network. Local database is the source of truth. |
| **Amount safety** | Financial amounts are stored as integers in the smallest currency unit. No floating point. |
| **Immutable history** | Transactions and ledger entries are never mutated after creation. Corrections create reversal entries. |
| **Balance is derived** | Account and person balances are NEVER stored as a single mutable field. They are computed from the sum of entries. |
| **Sync-ready from day one** | Every entity includes UUID, version, timestamps, and soft-delete support — even before sync is built. |
| **Normalized where it counts** | Normalize to avoid duplication. Denormalize only for performance and only with a documented sync strategy. |

### 1.2 Key Architecture Decisions

| ID | Decision | Rationale |
|----|----------|-----------|
| D-DB-01 | Amounts stored as `int` (minor units) | Eliminates floating-point precision errors. Safe for all currencies (fiat max 3 decimal places: Kuwaiti Dinar, Omani Rial). Max value ~9.2 × 10¹⁸ minor units = ~9.2 × 10¹⁶ USD (at 2 decimals) — sufficient for any personal/ledger use. |
| D-DB-02 | Every entity gets a UUID + auto-increment local ID | UUID enables future sync without collision. Auto-increment enables fast local joins and ordered display. |
| D-DB-03 | Every entity has `createdAt`, `updatedAt`, `deletedAt` | `deletedAt` enables soft-delete and sync-aware deletion. Timestamps enable conflict resolution via last-write-wins. |
| D-DB-04 | Every mutable entity has a `version` integer | Optimistic concurrency control for future sync conflict resolution. |
| D-DB-05 | Balance is never stored — always computed | Stored balance would drift from actual transactions over time. Computing from entries guarantees accuracy. Optimize with summary tables for reports. |
| D-DB-06 | Transactions use soft-delete (isDeleted flag) | Hard-deleting a transaction would change historical balance computations. Soft-delete preserves history. |
| D-DB-07 | Foreign keys use local auto-increment IDs | Local FK joins are fast (int → int). UUIDs are stored alongside but not used for joins. |
| D-DB-08 | Enum values stored as `int` (index), not name | Smaller storage, faster comparison. Names displayed via UI mapping. |

---

## 2. Money Design

### 2.1 Amount Storage

**Decision: Amounts stored as `int` (signed 64-bit integer) in the smallest currency unit.**

```dart
// Examples
USD 10.00        → amount = 1000 (cents)
BDT 500.00       → amount = 50000 (paisa)
KWD 10.000       → amount = 10000 (fils — 3 decimal places)
JPY 1000         → amount = 1000 (no decimals)
BTC 0.001        → amount = 100000 (satoshi — 8 decimal places)
```

**Why not `double`?**
- 0.1 + 0.2 = 0.30000000000000004 in IEEE 754
- Financial auditing requires exact arithmetic
- Rounding errors compound over thousands of transactions
- Regulatory compliance (GAAP, IFRS) requires exact amounts

**Why not a custom Decimal type?**
- Dart has no native decimal type
- Custom Decimal type adds complexity for serialization, Isar storage, and arithmetic
- `int` with minor units is the industry standard (Stripe, Square, all major FinTech)

**Currency precision map:**
- 0 decimal places: JPY, KRW, VND, CLP, ISK
- 2 decimal places: USD, EUR, GBP, BDT, INR, most fiat currencies
- 3 decimal places: KWD, OMR, BHD, TND
- 8 decimal places: BTC, ETH (cryptocurrency support — future)

### 2.2 Currency Storage

```dart
// Currency stored as ISO 4217 3-letter code
currencyCode: String  // "USD", "BDT", "EUR", etc.
```

Currency metadata (name, symbol, decimal places, isCrypto) stored in a system reference table or hardcoded map. Not user-editable.

### 2.3 Multi-Currency Design

Each transaction stores its own `currencyCode` AND the account's `currencyCode`. If they differ, `exchangeRate` captures the conversion rate at the time of the transaction.

```
Transaction:
  amount: 100000         // 1,000.00 USD
  currencyCode: "USD"
  accountCurrencyCode: "BDT"
  exchangeRate: 109.50    // 1 USD = 109.50 BDT
  convertedAmount: 10950000  // 109,500.00 BDT (computed, stored for reporting)
```

---

## 3. Complete Entity Catalog

### 3.1 Entity List

| # | Entity | Domain | Purpose |
|---|--------|--------|---------|
| 01 | Account | Finance | Container for tracking money |
| 02 | Category | Finance | Classification for income/expense |
| 03 | Transaction | Finance | Income, expense, or transfer record |
| 04 | RecurringTemplate | Finance | Template for recurring transactions |
| 05 | Budget | Finance | Spending limit or savings target |
| 06 | BudgetCategory | Finance | Many-to-many budget-category link |
| 07 | SavingsGoal | Finance | Financial target with allocation |
| 08 | GoalAllocation | Finance | Individual allocation to a goal |
| 09 | Person | Ledger | Contact with financial relationship |
| 10 | LedgerEntry | Ledger | Give, receive, sale, purchase, etc. |
| 11 | OpeningBalance | Ledger | Initial balance for a person |
| 12 | PaymentMethod | Cross | Transaction mechanism |
| 13 | Reminder | Cross | Scheduled notification |
| 14 | Attachment | Cross | File attached to any entity |
| 15 | Tag | Cross | Free-form label |
| 16 | EntityTag | Cross | Many-to-many tag link |
| 17 | AppSetting | Cross | Key-value settings store |
| 18 | Notification | Cross | Local notification record |
| 19 | NotificationPreference | Cross | Per-type notification toggle |
| 20 | SyncQueue | Cross | Future sync outbox |
| 21 | SyncConflict | Cross | Future sync conflict records |
| 22 | AuditLog | Cross | Immutable audit trail |
| 23 | SchemaVersion | System | Migration tracking |

---

## 4. Entity Relationship Diagram

### 4.1 Textual ERD

```
┌──────────────────────┐         ┌──────────────────────┐
│       Account        │         │      Category        │
├──────────────────────┤         ├──────────────────────┤
│ id (PK, auto)        │         │ id (PK, auto)        │
│ uuid (UQ, IX)        │         │ uuid (UQ, IX)        │
│ name (UQ, IX)        │         │ name (UQ, IX)        │
│ type (enum)          │         │ type (income/expense) │
│ currencyCode         │         │ group (enum)         │
│ icon                 │         │ icon                 │
│ color                │         │ color                │
│ description          │         │ isSystem             │
│ isArchived           │         │ isArchived           │
│ sortOrder            │         │ sortOrder            │
│ version              │         │ version              │
│ createdAt            │         │ createdAt            │
│ updatedAt            │         │ updatedAt            │
│ deletedAt            │         │ deletedAt            │
└───────┬──────────────┘         └───────┬──────────────┘
        │ 1                              │ 1
        │                                │
        │ *                              │ *
┌───────┴────────────────────────────────┴──────────────┐
│                     Transaction                        │
├───────────────────────────────────────────────────────┤
│ id (PK, auto)                                          │
│ uuid (UQ, IX)                                          │
│ type (income/expense/transfer)                         │
│ amount (int — minor units)                             │
│ currencyCode                                           │
│ accountId (FK → Account.id)                            │
│ categoryId (FK → Category.id, nullable)                │
│ destinationAccountId (FK → Account.id, nullable)       │
│ exchangeRate (nullable)                                │
│ fee (int, nullable)                                    │
│ feeCurrencyCode (nullable)                             │
│ description                                            │
│ note                                                   │
│ tags (List<String>)                                    │
│ paymentMethodId (FK → PaymentMethod.id, nullable)      │
│ isPending                                              │
│ date                                                   │
│ recurringTemplateId (FK → RecurringTemplate.id, null)  │
│ parentTransactionId (FK → Transaction.id, null)        │
│ isReversal                                             │
│ version                                                │
│ createdAt                                              │
│ updatedAt                                              │
│ deletedAt                                              │
└───────────────────────────────────────────────────────┘
        │
        │ *
┌───────┴──────────────────────────┐
│      RecurringTemplate           │
├─────────────────────────────────┤
│ id (PK, auto)                    │
│ uuid (UQ, IX)                    │
│ type (income/expense)            │
│ amount (int — minor units)       │
│ currencyCode                     │
│ accountId (FK → Account.id)      │
│ categoryId (FK → Category.id)    │
│ frequency (daily/weekly/etc)     │
│ interval (int)                   │
│ endType (never/count/date)       │
│ endValue (int/DateTime/null)     │
│ nextDate                         │
│ isActive                         │
│ version                          │
│ createdAt                        │
│ updatedAt                        │
│ deletedAt                        │
└─────────────────────────────────┘

┌──────────────────────┐    ┌──────────────────────────┐
│       Budget         │    │    BudgetCategory        │
├──────────────────────┤    ├──────────────────────────┤
│ id (PK, auto)        │──1→│ id (PK, auto)            │
│ uuid (UQ, IX)        │ *  │ budgetId (FK → Budget)  │──*→1 Category
│ name                 │    │ categoryId (FK → Cat)    │
│ amount (int)         │    └──────────────────────────┘
│ period (enum)        │
│ startDate            │
│ endDate              │
│ type (cap/target)    │
│ alertPercent (80)    │
│ version              │
│ createdAt            │
│ updatedAt            │
│ deletedAt            │
└──────────────────────┘

┌──────────────────────┐    ┌──────────────────────────┐
│     SavingsGoal      │    │    GoalAllocation         │
├──────────────────────┤    ├──────────────────────────┤
│ id (PK, auto)        │──1→│ id (PK, auto)            │
│ uuid (UQ, IX)        │ *  │ goalId (FK → Goal)      │
│ name                 │    │ accountId (FK → Account) │
│ targetAmount (int)   │    │ amount (int)             │
│ currentAmount (int)  │    │ date                     │
│ accountId (FK → Acct)│    │ note (optional)          │
│ deadline (nullable)  │    │ version                  │
│ status (active/compl)│    │ createdAt                │
│ icon                 │    │ updatedAt                │
│ color                │    │ deletedAt                │
│ version              │    └──────────────────────────┘
│ createdAt            │
│ updatedAt            │
│ deletedAt            │
└──────────────────────┘

┌──────────────────────┐         ┌──────────────────────┐
│       Person         │         │    LedgerEntry        │
├──────────────────────┤         ├──────────────────────┤
│ id (PK, auto)        │──1    *│ id (PK, auto)          │
│ uuid (UQ, IX)        │────────│ uuid (UQ, IX)          │
│ name (IX)            │         │ personId (FK → Person) │
│ type (cust/supp/fr)  │         │ accountId (FK → Acct)  │
│ phone                │         │ type (enum)            │
│ email                │         │ direction (in/out)     │
│ address              │         │ amount (int)           │
│ photoPath            │         │ currencyCode           │
│ notes                │         │ description            │
│ status (active/arch) │         │ date                   │
│ creditLimit (int)    │         │ paymentMethodId (FK)   │
│ version              │         │ parentEntryId (FK, nu) │
│ createdAt            │         │ linkedTransactionId(FK)│
│ updatedAt            │         │ dueDate (nullable)     │
│ deletedAt            │         │ isSettled              │
└──────────────────────┘         │ note                   │
                                 │ tags (List<String>)    │
                                 │ version                │
                                 │ createdAt              │
                                 │ updatedAt              │
                                 │ deletedAt              │
                                 └────────────────────────┘
                                        │ 1
                                        │
                                        │ *
                                 ┌──────┴─────────┐
                                 │  OpeningBalance  │
                                 ├─────────────────┤
                                 │ id (PK, auto)   │
                                 │ personId(FK, UQ)│
                                 │ amount (int)    │
                                 │ direction (in)  │
                                 │ note            │
                                 │ date            │
                                 │ version         │
                                 │ updatedAt       │
                                 └─────────────────┘

┌──────────────────────┐    ┌──────────────────────────┐
│    PaymentMethod     │    │    Attachment             │
├──────────────────────┤    ├──────────────────────────┤
│ id (PK, auto)        │    │ id (PK, auto)             │
│ uuid (UQ, IX)        │    │ uuid (UQ, IX)             │
│ name                 │    │ entityType (polymorphic)  │
│ type (preset/custom) │    │ entityId (int)            │
│ icon                 │    │ filePath                  │
│ isEnabled            │    │ fileName                  │
│ sortOrder            │    │ mimeType                  │
│ version              │    │ fileSize (int)            │
│ createdAt            │    │ isSynced                  │
│ updatedAt            │    │ createdAt                 │
│ deletedAt            │    │ deletedAt                 │
└──────────────────────┘    └──────────────────────────┘

┌──────────────────────┐    ┌──────────────────────────┐
│      Reminder        │    │      Tag                 │
├──────────────────────┤    ├──────────────────────────┤
│ id (PK, auto)        │    │ id (PK, auto)             │
│ uuid (UQ, IX)        │    │ name (UQ)                 │
│ entityType           │    │ color (optional)          │
│ entityId (int)       │    │ createdAt                 │
│ dueDate              │    └──────────────────────────┘
│ dueTime (nullable)   │             │ 1
│ repeatInterval (enum)│             │
│ repeatCount (int)    │    ┌────────┴──────────┐
│ isCompleted          │    │   EntityTag        │
│ completedAt          │    ├──────────────────┤
│ note                 │    │ entityType        │
│ version              │    │ entityId (int)    │
│ createdAt            │    │ tagId (FK → Tag)  │
│ updatedAt            │    └──────────────────┘
│ deletedAt            │
└──────────────────────┘

┌──────────────────────┐    ┌──────────────────────────┐
│    AppSetting        │    │    Notification           │
├──────────────────────┤    ├──────────────────────────┤
│ key (PK)             │    │ id (PK, auto)             │
│ value (String)       │    │ type (enum)               │
│ updatedAt            │    │ title                     │
└──────────────────────┘    │ body                      │
                            │ entityType (nullable)     │
┌──────────────────────┐    │ entityId (nullable)       │
│ NotificationPref     │    │ isRead                    │
├──────────────────────┤    │ isDismissed               │
│ type (PK, enum)      │    │ createdAt                 │
│ isEnabled            │    └──────────────────────────┘
│ updatedAt            │
└──────────────────────┘

┌──────────────────────┐    ┌──────────────────────────┐
│     SyncQueue        │    │    AuditLog              │
├──────────────────────┤    ├──────────────────────────┤
│ id (PK, auto)        │    │ id (PK, auto)             │
│ entityType           │    │ entityType                │
│ entityId (int)       │    │ entityId (int)            │
│ action (create/upd/d)│    │ action (create/update/    │
│ payload (JSON)       │    │         delete/reverse)   │
│ status (pending/     │    │ previousValues (JSON)     │
│        syncing/done) │    │ newValues (JSON)          │
│ retryCount (int)     │    │ timestamp                 │
│ createdAt            │    │ version (int)             │
│ syncedAt (nullable)  │    │ description               │
└──────────────────────┘    └──────────────────────────┘

┌──────────────────────┐
│   SchemaVersion      │
├──────────────────────┤
│ version (PK, int)    │
│ appliedAt            │
│ checksum             │
│ description          │
└──────────────────────┘
```

### 4.2 Relationship Summary

| From | To | Type | Via | Cascade |
|------|----|------|-----|---------|
| Transaction | Account | M:1 | accountId | RESTRICT |
| Transaction | Category | M:1 | categoryId | SET NULL |
| Transaction | Account (dest) | M:1 | destinationAccountId | RESTRICT |
| Transaction | RecurringTemplate | M:1 | recurringTemplateId | SET NULL |
| Transaction | Transaction (parent) | M:1 | parentTransactionId | SET NULL |
| Transaction | PaymentMethod | M:1 | paymentMethodId | SET NULL |
| RecurringTemplate | Account | M:1 | accountId | CASCADE |
| RecurringTemplate | Category | M:1 | categoryId | SET NULL |
| Budget | Category | M:N | BudgetCategory | CASCADE |
| BudgetCategory | Budget | M:1 | budgetId | CASCADE |
| BudgetCategory | Category | M:1 | categoryId | CASCADE |
| SavingsGoal | Account | M:1 | accountId | RESTRICT |
| GoalAllocation | SavingsGoal | M:1 | goalId | CASCADE |
| GoalAllocation | Account | M:1 | accountId | RESTRICT |
| LedgerEntry | Person | M:1 | personId | RESTRICT (if non-zero balance) |
| LedgerEntry | Account | M:1 | accountId | RESTRICT |
| LedgerEntry | LedgerEntry | M:1 | parentEntryId | SET NULL |
| LedgerEntry | Transaction | 1:1 | linkedTransactionId | SET NULL |
| LedgerEntry | PaymentMethod | M:1 | paymentMethodId | SET NULL |
| OpeningBalance | Person | 1:1 | personId | CASCADE |
| Attachment | (polymorphic) | M:1 | entityType + entityId | CASCADE |
| Reminder | (polymorphic) | M:1 | entityType + entityId | CASCADE |
| EntityTag | (polymorphic) | M:1 | entityType + entityId | CASCADE |
| EntityTag | Tag | M:1 | tagId | RESTRICT |

---

## 5. Detailed Entity Specifications

### 5.1 Account

**Purpose:** Container for tracking money in a specific place.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| id | int (auto) | Yes | — | Local primary key |
| uuid | String | Yes | UUID v4 | Universal identifier for sync |
| name | String | Yes | — | Display name (unique, case-insensitive) |
| type | int (enum) | Yes | — | 0=Cash, 1=Bank, 2=MobileBanking, 3=CreditCard, 4=Savings, 5=Investment, 6=Other |
| currencyCode | String | Yes | "USD" | ISO 4217 code |
| icon | String | Yes | "wallet" | Icon key from design system |
| color | int | Yes | 0xFF0F766E | ARGB color value |
| description | String? | No | null | Optional description |
| isArchived | bool | Yes | false | Soft visibility toggle |
| sortOrder | int | Yes | 0 | User-defined ordering |
| version | int | Yes | 1 | Optimistic concurrency |
| createdAt | DateTime | Yes | now() | |
| updatedAt | DateTime | Yes | now() | |
| deletedAt | DateTime? | No | null | Soft delete |

**Indexes:** `id` (PK), `uuid` (unique), `name` (unique, case-insensitive), `type`, `isArchived`, `deletedAt`

**Relationships:**
- Has many `Transaction` (via accountId or destinationAccountId)
- Has many `LedgerEntry` (via accountId)
- Has many `GoalAllocation` (via accountId)
- Has many `RecurringTemplate` (via accountId)
- Has many `SavingsGoal` (via accountId)

**Validation Rules:**
- Name: required, 1-100 chars, unique (case-insensitive)
- Type: must be a valid AccountType enum value
- CurrencyCode: must be valid ISO 4217
- Color: must be valid ARGB
- Cannot delete if non-zero sum of transactions (soft-delete instead)

---

### 5.2 Category

**Purpose:** Classification label for income and expense transactions.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| id | int (auto) | Yes | — | Local primary key |
| uuid | String | Yes | UUID v4 | Universal identifier |
| name | String | Yes | — | Display name |
| type | int (enum) | Yes | — | 0=Income, 1=Expense |
| group | int (enum) | Yes | — | Category group (Food, Transport, etc.) |
| icon | String | Yes | "category" | Icon key |
| color | int | Yes | 0xFF6B7280 | ARGB color |
| isSystem | bool | Yes | false | System preset (not deletable) |
| isArchived | bool | Yes | false | Visibility toggle |
| sortOrder | int | Yes | 0 | User ordering |
| version | int | Yes | 1 | |
| createdAt | DateTime | Yes | now() | |
| updatedAt | DateTime | Yes | now() | |
| deletedAt | DateTime? | No | null | |

**Indexes:** `id` (PK), `uuid` (unique), `name + type` (unique, case-insensitive), `type`, `isSystem`, `deletedAt`

**Validation Rules:**
- Name + Type must be unique (case-insensitive within same type)
- isSystem categories cannot be deleted (can be disabled)
- Type cannot be changed after creation

---

### 5.3 Transaction

**Purpose:** Record of income, expense, or transfer affecting an account.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| id | int (auto) | Yes | — | Local primary key |
| uuid | String | Yes | UUID v4 | Universal identifier |
| type | int (enum) | Yes | — | 0=Income, 1=Expense, 2=Transfer |
| amount | int | Yes | — | Amount in minor currency units |
| currencyCode | String | Yes | — | ISO 4217 code |
| accountId | int | Yes | — | FK → Account.id |
| categoryId | int? | No | null | FK → Category.id |
| destinationAccountId | int? | No | null | FK → Account.id (for transfers) |
| exchangeRate | double? | No | null | Rate if currencies differ |
| fee | int? | No | null | Transfer fee in minor units |
| feeCurrencyCode | String? | No | null | Currency of the fee |
| description | String? | No | null | User description (max 500 chars) |
| note | String? | No | null | Internal note |
| tags | List<String>? | No | null | Max 10 tags, 30 chars each |
| paymentMethodId | int? | No | null | FK → PaymentMethod.id |
| isPending | bool | Yes | false | Not yet fully settled |
| date | DateTime | Yes | today | Transaction date |
| recurringTemplateId | int? | No | null | FK → RecurringTemplate.id |
| parentTransactionId | int? | No | null | FK → Transaction.id (reversal) |
| isReversal | bool | Yes | false | Is this a reversal of another? |
| version | int | Yes | 1 | |
| createdAt | DateTime | Yes | now() | |
| updatedAt | DateTime | Yes | now() | |
| deletedAt | DateTime? | No | null | |

**Indexes:** `id` (PK), `uuid` (unique), `accountId`, `categoryId`, `destinationAccountId`, `date`, `type`, `isPending`, `createdAt`, `deletedAt`

**Relationships:**
- Belongs to `Account` (via accountId)
- Belongs to `Category` (via categoryId, nullable)
- Belongs to `Account` as destination (via destinationAccountId, nullable)
- Belongs to `RecurringTemplate` (via recurringTemplateId, nullable)
- Belongs to `Transaction` as parent (via parentTransactionId, nullable)
- Belongs to `PaymentMethod` (via paymentMethodId, nullable)
- Has one `LedgerEntry` (via linkedTransactionId on LedgerEntry)

**Validation Rules:**
- Amount > 0 (always positive in storage)
- For income/expense: accountId required, destinationAccountId null
- For transfer: accountId (source) required, destinationAccountId required, must differ
- categoryId required for income/expense, null for transfers
- If exchangeRate set, must be > 0
- fee only applicable with exchangeRate (different currencies)
- parentTransactionId must reference a different transaction (no self-reference)

---

### 5.4 RecurringTemplate

**Purpose:** Template for auto-generating recurring transactions.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| id | int (auto) | Yes | — | |
| uuid | String | Yes | UUID v4 | |
| type | int (enum) | Yes | — | 0=Income, 1=Expense |
| amount | int | Yes | — | In minor units |
| currencyCode | String | Yes | — | |
| accountId | int | Yes | — | FK → Account |
| categoryId | int? | No | null | FK → Category |
| description | String? | No | null | |
| paymentMethodId | int? | No | null | FK → PaymentMethod |
| tags | List<String>? | No | null | |
| frequency | int (enum) | Yes | — | 0=Daily, 1=Weekly, 2=Monthly, 3=Yearly |
| interval | int | Yes | 1 | Every N periods |
| endType | int (enum) | Yes | 0 | 0=Never, 1=After count, 2=On date |
| endValue | int? | No | null | Count if endType=1 |
| endDate | DateTime? | No | null | Date if endType=2 |
| nextDate | DateTime | Yes | — | Next generation date |
| isActive | bool | Yes | true | |
| version | int | Yes | 1 | |
| createdAt | DateTime | Yes | now() | |
| updatedAt | DateTime | Yes | now() | |
| deletedAt | DateTime? | No | null | |

**Indexes:** `id` (PK), `uuid` (unique), `accountId`, `nextDate`, `isActive`, `deletedAt`

---

### 5.5 Budget

**Purpose:** Spending limit or savings target for categories over a period.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| id | int (auto) | Yes | — | |
| uuid | String | Yes | UUID v4 | |
| name | String | Yes | — | Auto-generated if empty |
| amount | int | Yes | — | Budget amount in minor units |
| period | int (enum) | Yes | — | 0=Weekly, 1=Monthly, 2=Yearly, 3=Custom |
| startDate | DateTime | Yes | — | Period start |
| endDate | DateTime | Yes | — | Period end (computed if not custom) |
| type | int (enum) | Yes | 0 | 0=Spending cap, 1=Savings target |
| alertPercent | int | Yes | 80 | Alert at this percentage |
| version | int | Yes | 1 | |
| createdAt | DateTime | Yes | now() | |
| updatedAt | DateTime | Yes | now() | |
| deletedAt | DateTime? | No | null | |

**Indexes:** `id` (PK), `uuid` (unique), `startDate`, `endDate`, `deletedAt`

---

### 5.6 BudgetCategory (Join Table)

**Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | int (auto) | Yes | |
| budgetId | int | Yes | FK → Budget.id (CASCADE) |
| categoryId | int | Yes | FK → Category.id (CASCADE) |

**Indexes:** `budgetId + categoryId` (unique)

---

### 5.7 SavingsGoal

**Purpose:** Financial target with progress tracking.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| id | int (auto) | Yes | — | |
| uuid | String | Yes | UUID v4 | |
| name | String | Yes | — | |
| targetAmount | int | Yes | — | In minor units |
| currentAmount | int | Yes | 0 | Computed, stored for display |
| accountId | int | Yes | — | Default source account |
| deadline | DateTime? | No | null | Optional target date |
| status | int (enum) | Yes | 0 | 0=Active, 1=Completed, 2=Cancelled |
| icon | String | Yes | "savings" | |
| color | int | Yes | 0xFF0F766E | |
| version | int | Yes | 1 | |
| createdAt | DateTime | Yes | now() | |
| updatedAt | DateTime | Yes | now() | |
| deletedAt | DateTime? | No | null | |

**Indexes:** `id` (PK), `uuid` (unique), `status`, `accountId`, `deletedAt`

---

### 5.8 GoalAllocation

**Purpose:** Individual allocation of funds to a goal.

**Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | int (auto) | Yes | |
| uuid | String | Yes | UUID v4 |
| goalId | int | Yes | FK → SavingsGoal.id (CASCADE) |
| accountId | int | Yes | FK → Account.id |
| amount | int | Yes | In minor units |
| date | DateTime | Yes | Allocation date |
| note | String? | No | Optional note |
| version | int | Yes | |
| createdAt | DateTime | Yes | |
| updatedAt | DateTime | Yes | |
| deletedAt | DateTime? | No | |

**Indexes:** `id` (PK), `uuid` (unique), `goalId`, `accountId`

---

### 5.9 Person

**Purpose:** Contact with whom the user has financial relationships.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| id | int (auto) | Yes | — | |
| uuid | String | Yes | UUID v4 | |
| name | String | Yes | — | Max 100 chars |
| type | int (enum) | Yes | — | 0=Customer, 1=Supplier, 2=Friend, 3=Family, 4=Employee, 5=Other |
| phone | String? | No | null | E.164 or local format |
| email | String? | No | null | Standard email |
| address | String? | No | null | Max 500 chars |
| photoPath | String? | No | null | Local file path |
| notes | String? | No | null | Max 1000 chars |
| status | int (enum) | Yes | 0 | 0=Active, 1=Archived |
| creditLimit | int? | No | null | In minor units |
| version | int | Yes | 1 | |
| createdAt | DateTime | Yes | now() | |
| updatedAt | DateTime | Yes | now() | |
| deletedAt | DateTime? | No | null | |

**Indexes:** `id` (PK), `uuid` (unique), `name` (case-insensitive), `type`, `status`, `deletedAt`

**Validation Rules:**
- Name required
- Person with non-zero outstanding balance CANNOT be hard-deleted (must archive)
- Person with zero balance and no entries can be hard-deleted

---

### 5.10 LedgerEntry

**Purpose:** Record of any financial interaction with a person.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| id | int (auto) | Yes | — | |
| uuid | String | Yes | UUID v4 | |
| personId | int | Yes | — | FK → Person.id (RESTRICT if non-zero) |
| accountId | int | Yes | — | FK → Account.id |
| type | int (enum) | Yes | — | 0=Give, 1=Receive, 2=Sale, 3=Purchase, 4=Adjustment, 5=Discount, 6=Refund, 7=Reversal, 8=Opening |
| direction | int (enum) | Yes | — | 0=Incoming (to user), 1=Outgoing (from user) |
| amount | int | Yes | — | In minor units, always positive |
| currencyCode | String | Yes | — | ISO 4217 |
| description | String? | No | null | |
| date | DateTime | Yes | today | |
| paymentMethodId | int? | No | null | FK → PaymentMethod.id |
| parentEntryId | int? | No | null | FK → LedgerEntry.id (reversal/partial) |
| linkedTransactionId | int? | No | null | FK → Transaction.id (dual-entry) |
| dueDate | DateTime? | No | null | For loan-type Give |
| isSettled | bool | Yes | true | False for unsettled loans |
| note | String? | No | null | |
| tags | List<String>? | No | null | |
| version | int | Yes | 1 | |
| createdAt | DateTime | Yes | now() | |
| updatedAt | DateTime | Yes | now() | |
| deletedAt | DateTime? | No | null | |

**Indexes:** `id` (PK), `uuid` (unique), `personId`, `accountId`, `date`, `type`, `direction`, `isSettled`, `dueDate`, `parentEntryId`, `deletedAt`

**Balance Calculation (derived, not stored):**
```
person.balance = sum(incoming amounts) - sum(outgoing amounts) + openingBalance
```

Where:
- Give = outgoing (person owes user more)
- Receive = incoming (person owes user less)
- Sale = outgoing (customer owes user)
- Purchase = outgoing (user owes supplier — but direction is outgoing from user)

**Validation Rules:**
- Amount always > 0
- Person with non-zero balance cannot be deleted
- parentEntryId cannot self-reference
- linkedTransactionId must reference an existing Transaction
- If type=Reversal, parentEntryId is required

---

### 5.11 OpeningBalance

**Purpose:** Initial balance for a person, set at creation.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| id | int (auto) | Yes | — | |
| personId | int | Yes (UQ) | — | FK → Person.id (CASCADE) |
| amount | int | Yes | — | In minor units |
| direction | int (enum) | Yes | — | 0=Give (person owes user), 1=Receive (user owes person) |
| note | String? | No | null | |
| date | DateTime | Yes | creation date | |
| version | int | Yes | 1 | |
| updatedAt | DateTime | Yes | now() | |

**Indexes:** `personId` (unique)

---

### 5.12 PaymentMethod

**Purpose:** Mechanism used to transact.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| id | int (auto) | Yes | — | |
| uuid | String | Yes | UUID v4 | |
| name | String | Yes | — | Display name |
| type | int (enum) | Yes | 0=System, 1=Custom |
| icon | String | Yes | "payment" | |
| isEnabled | bool | Yes | true | |
| sortOrder | int | Yes | 0 | |
| version | int | Yes | 1 | |
| createdAt | DateTime | Yes | now() | |
| updatedAt | DateTime | Yes | now() | |
| deletedAt | DateTime? | No | null | |

**Indexes:** `id` (PK), `uuid` (unique), `name` (unique)

**System Presets (type=0):**
Cash, Bank Transfer, Credit Card, Debit Card, bKash, Nagad, Rocket, Upay, Cheque, Mobile Banking, Online Transfer

---

### 5.13 Reminder

**Purpose:** Scheduled notification for a due event.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| id | int (auto) | Yes | — | |
| uuid | String | Yes | UUID v4 | |
| entityType | String | Yes | — | Polymorphic: "ledger_entry", "transaction" |
| entityId | int | Yes | — | FK to entity |
| dueDate | DateTime | Yes | — | |
| dueTime | String? | No | "09:00" | HH:MM format |
| repeatInterval | int? (enum) | No | null | 0=Daily, 1=Weekly, 2=Monthly |
| repeatCount | int? | No | null | Max repeats |
| isCompleted | bool | Yes | false | |
| completedAt | DateTime? | No | null | |
| note | String? | No | null | |
| version | int | Yes | 1 | |
| createdAt | DateTime | Yes | now() | |
| updatedAt | DateTime | Yes | now() | |
| deletedAt | DateTime? | No | null | |

---

### 5.14 Attachment

**Purpose:** File attached to any entity.

**Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | int (auto) | Yes | |
| uuid | String | Yes | UUID v4 |
| entityType | String | Yes | Polymorphic type |
| entityId | int | Yes | FK to entity |
| filePath | String | Yes | Local file path |
| fileName | String | Yes | Original filename |
| mimeType | String | Yes | image/jpeg, application/pdf, etc. |
| fileSize | int | Yes | Bytes |
| isSynced | bool | No | false | For future cloud sync |
| createdAt | DateTime | Yes | now() | |
| deletedAt | DateTime? | No | null | |

**Indexes:** `entityType + entityId`

---

### 5.15 Tag

**Purpose:** Free-form label for categorization.

**Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | int (auto) | Yes | |
| name | String | Yes (UQ) | Case-insensitive unique |
| color | int? | No | Optional display color |
| createdAt | DateTime | Yes | now() |

---

### 5.16 EntityTag (Join)

**Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | int (auto) | Yes | |
| entityType | String | Yes | Polymorphic |
| entityId | int | Yes | |
| tagId | int | Yes | FK → Tag.id (RESTRICT) |

**Indexes:** `entityType + entityId + tagId` (unique)

---

### 5.17 AppSetting

**Purpose:** Key-value settings store.

**Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| key | String | Yes (PK) | Setting key |
| value | String | Yes | JSON-encoded value |
| updatedAt | DateTime | Yes | now() |

---

### 5.18 Notification

**Purpose:** Record of a notification shown to the user.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| id | int (auto) | Yes | — | |
| type | int (enum) | Yes | — | 0=Reminder, 1=BudgetAlert, 2=GoalAchievement, 3=Backup, 4=Settlement |
| title | String | Yes | — | |
| body | String | Yes | — | |
| entityType | String? | No | null | For deep link |
| entityId | int? | No | null | For deep link |
| isRead | bool | Yes | false | |
| isDismissed | bool | Yes | false | |
| createdAt | DateTime | Yes | now() | |

**Indexes:** `type`, `isRead`, `createdAt`

---

### 5.19 NotificationPreference

**Fields:**

| Field | Type | Required | Default |
|-------|------|----------|---------|
| type | int (enum) | Yes (PK) | — |
| isEnabled | bool | Yes | true |
| updatedAt | DateTime | Yes | now() |

---

### 5.20 SyncQueue

**Purpose:** Outbox for future cloud sync.

**Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | int (auto) | Yes | |
| entityType | String | Yes | |
| entityId | int | Yes | Local ID |
| action | int (enum) | Yes | 0=Create, 1=Update, 2=Delete |
| payload | String | Yes | JSON snapshot |
| status | int (enum) | Yes | 0=Pending, 1=Syncing, 2=Done, 3=Failed |
| retryCount | int | Yes | 0 |
| lastError | String? | No | null |
| createdAt | DateTime | Yes | now() |
| syncedAt | DateTime? | No | null |

---

### 5.21 SyncConflict

**Purpose:** Record of sync conflicts for resolution.

**Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | int (auto) | Yes | |
| entityType | String | Yes | |
| localEntityId | int | Yes | |
| remoteEntityId | String | Yes | Remote UUID |
| localVersion | int | Yes | |
| remoteVersion | int | Yes | |
| localPayload | String | Yes | JSON |
| remotePayload | String | Yes | JSON |
| resolution | int? (enum) | No | 0=KeepLocal, 1=KeepRemote, 2=Merge |
| resolvedAt | DateTime? | No | |
| createdAt | DateTime | Yes | now() |

---

### 5.22 AuditLog

**Purpose:** Immutable audit trail for financial operations.

**Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | int (auto) | Yes | |
| entityType | String | Yes | |
| entityId | int | Yes | |
| action | int (enum) | Yes | 0=Create, 1=Update, 2=Delete, 3=Reverse |
| previousValues | String? | No | JSON of changed fields |
| newValues | String? | No | JSON of new values |
| timestamp | DateTime | Yes | now() |
| version | int | Yes | Entity version after change |
| description | String? | No | Human-readable description |

**Indexes:** `entityType + entityId`, `timestamp`

---

### 5.23 SchemaVersion

**Purpose:** Track database schema migrations.

**Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| version | int | Yes (PK) | Schema version number |
| appliedAt | DateTime | Yes | now() |
| checksum | String | Yes | Hash of migration content |
| description | String | Yes | Human-readable summary |

---

## 6. Index Strategy

### 6.1 Core Indexes

| Table | Index Name | Type | Columns | Purpose |
|-------|------------|------|---------|---------|
| Account | idx_account_id | PK | id | Primary lookup |
| Account | idx_account_uuid | UQ | uuid | Sync lookup |
| Account | idx_account_name | UQ | name | Case-insensitive unique name |
| Account | idx_account_type | ST | type | Filter by type |
| Account | idx_account_archived | ST | isArchived | Active accounts query |
| Account | idx_account_active | ST | isArchived, deletedAt | Active non-deleted query |
| Transaction | idx_txn_id | PK | id | |
| Transaction | idx_txn_uuid | UQ | uuid | |
| Transaction | idx_txn_account | ST | accountId, date | Account transaction list |
| Transaction | idx_txn_category | ST | categoryId | Category aggregation |
| Transaction | idx_txn_date | ST | date, type | Date-range reports |
| Transaction | idx_txn_pending | ST | isPending | Pending transactions |
| Transaction | idx_txn_created | ST | createdAt | Recent activity |
| Transaction | idx_txn_active | ST | deletedAt | Active transactions |
| Person | idx_person_id | PK | id | |
| Person | idx_person_uuid | UQ | uuid | |
| Person | idx_person_name | ST | name | Search by name |
| Person | idx_person_type | ST | type | Filter by type |
| Person | idx_person_status | ST | status | Active people |
| LedgerEntry | idx_ledger_id | PK | id | |
| LedgerEntry | idx_ledger_uuid | UQ | uuid | |
| LedgerEntry | idx_ledger_person | ST | personId, date | Person history |
| LedgerEntry | idx_ledger_account | ST | accountId | Account impact |
| LedgerEntry | idx_ledger_type | ST | type | Filter by type |
| LedgerEntry | idx_ledger_due | ST | dueDate | Overdue reminders |
| LedgerEntry | idx_ledger_settled | ST | isSettled | Unsettled loans |
| LedgerEntry | idx_ledger_active | ST | deletedAt | Active entries |
| Budget | idx_budget_period | ST | startDate, endDate | Active budgets |
| Attachment | idx_attach_entity | ST | entityType, entityId | Entity attachments |
| EntityTag | idx_tag_entity | UQ | entityType, entityId, tagId | Unique tagging |
| SyncQueue | idx_sync_status | ST | status, createdAt | Pending sync items |
| AuditLog | idx_audit_entity | ST | entityType, entityId | Entity history |
| AuditLog | idx_audit_time | ST | timestamp | Time-based audit |

### 6.2 Composite Index Design Notes

- **Transaction (accountId, date)**: Enables efficient "view transactions for Account X" sorted by date without a separate sort.
- **Transaction (date, type)**: Enables "all expenses in March" without scanning income.
- **LedgerEntry (personId, date)**: Enables "history for Person X" sorted by date.
- **LedgerEntry (dueDate)**: Enables "find all overdue reminders" in one index scan (filter: dueDate < today AND isSettled = false AND type = Give).

### 6.3 Soft-Delete Index Strategy

Every table with `deletedAt` has a partial-style index that filters out soft-deleted records:

```
idx_txn_active: deletedAt IS NULL
```

This ensures that the vast majority of queries (which only show active records) never scan deleted data.

---

## 7. Validation & Business Rules

### 7.1 Cross-Entity Validation Rules

| Rule ID | Rule | Scope |
|---------|------|-------|
| VR-01 | Amount must always be > 0. Negative amounts are illegal. Direction fields handle sign. | All financial entities |
| VR-02 | A deleted entity cannot be referenced by new entries. | All FKs |
| VR-03 | Cascade delete is never used for financial entities (would lose history). Use RESTRICT or SET NULL. | All FKs |
| VR-04 | UUID is immutable after creation. | All entities with UUID |
| VR-05 | version increments on every mutation. | All mutable entities |
| VR-06 | Soft-delete preserves the record but excludes from all default queries. | All entities with deletedAt |

### 7.2 Financial Integrity Rules

| Rule ID | Rule |
|---------|------|
| FIR-01 | Balance is NEVER stored. Always computed from event-sourced entry sums. |
| FIR-02 | A reversal entry must reference the original entry via parentEntryId. |
| FIR-03 | A reversal entry must have the opposite direction of the original. |
| FIR-04 | Partial settlements calculate remaining balance as original amount - sum of all linked child entries. |
| FIR-05 | A Transaction with a linked LedgerEntry updates both balances atomically. |
| FIR-06 | A Budget's spending is calculated as sum of expenses in the budget's categories within the period. |
| FIR-07 | A SavingsGoal's progress = sum of all GoalAllocation amounts for that goal. |

### 7.3 Deletion Rules

| Rule ID | Entity | Rule |
|---------|--------|------|
| DR-01 | Account | Cannot delete if has transactions. Must archive. |
| DR-02 | Category | Can delete at any time. Referencing transactions get null category. |
| DR-03 | Person | Cannot delete if outstanding balance != 0. Must archive. |
| DR-04 | Person | Cannot delete if has ledger entries. Must archive. |
| DR-05 | Transaction | Cannot hard-delete if it would change historical balance. Soft-delete only. |
| DR-06 | LedgerEntry | Cannot delete if it has child entries (reversals, partials). |

---

## 8. Ledger System Design

### 8.1 Balance Computation

Person balance is computed using an event-sourced approach:

```
openingBalance = OpeningBalance.amount (with direction)
runningBalance = openingBalance

For each LedgerEntry (sorted by date ASC):
  if entry.direction == incoming:
    runningBalance -= entry.amount  // person owes less
  else:
    runningBalance += entry.amount  // person owes more

outstandingBalance = runningBalance  // final value
```

**Positive outstanding** = person owes the user (net Give > net Receive).  
**Negative outstanding** = user owes the person (net Receive > net Give).  
**Zero** = settled.

### 8.2 Ledger Entry Effects

| Entry Type | Direction | Person Balance Effect | Account Balance Effect |
|-----------|-----------|----------------------|----------------------|
| Give (Loan) | Outgoing | +amount | -amount |
| Give (Gift) | Outgoing | +amount | -amount |
| Receive | Incoming | -amount | +amount |
| Sale | Outgoing | +amount | +amount (user received) |
| Purchase | Outgoing | +amount (user owes) | -amount |
| Adjustment (+) | Incoming or Outgoing | +amount or -amount | No change |
| Discount | Incoming | -amount (write-off) | No change |
| Reversal | Opposite of original | Opposite of original | Opposite of original |
| Opening | As configured | +amount or -amount | No change |

### 8.3 Statement Generation

Statement = all entries for a person within a date range, sorted by date ascending, with running balance computed per entry.

```
Statement:
  personName: "Rafiq Ahmed"
  personType: "Customer"
  dateRange: "July 2026"
  openingBalance: Tk 5,000 (from prior period or opening entry)
  
  Entries:
  Jul 01  Give        Tk 15,000    Bal: Tk 20,000
  Jul 15  Receive     Tk  5,000    Bal: Tk 15,000
  Jul 20  Receive     Tk  2,000    Bal: Tk 13,000
  
  Closing Balance: Tk 13,000
```

---

## 9. Sync Architecture

### 9.1 Sync-Ready Fields

Every entity includes these fields for future sync:

| Field | Purpose |
|-------|---------|
| `uuid` (String, unique) | Stable identifier across devices. Generated once at creation. Never changes. |
| `version` (int) | Monotonically increasing. Incremented on every mutation. Enables optimistic concurrency. |
| `createdAt` (DateTime) | Server timestamp is authoritative. Local timestamp used as fallback. |
| `updatedAt` (DateTime) | Last modification timestamp. Used for last-write-wins conflict resolution. |
| `deletedAt` (DateTime?) | Soft delete. Sync propagates deletions as tombstones. |

### 9.2 Sync Flow (Future)

```
1. Local mutation → Write to local DB + SyncQueue entry
2. Sync trigger (manual/scheduled/background) → Read pending SyncQueue
3. For each pending entry: encrypted payload → server
4. Server acknowledges → mark SyncQueue as synced
5. Server fan-out to other devices → other devices receive encrypted payload
6. Apply to local DB with conflict check → if version matches, apply. If not, log SyncConflict.
```

### 9.3 Conflict Resolution Strategy

| Scenario | Strategy |
|----------|----------|
| Same entity edited on two devices | Last-write-wins (highest updatedAt + version) |
| Entity deleted on one device, edited on another | Deletion wins (tombstone overrides edit) |
| Same entity created on two devices (different UUIDs) | Both kept (different UUIDs = different records) |
| Same UUID created on two devices | Last-write-wins (impossible if UUID generation is correct) |

---

## 10. Backup & Restore

### 10.1 Backup Format

Backup file structure (encrypted JSON):

```
backup.paysa
│
├── header (unencrypted):
│   ├── version: 1
│   ├── schemaVersion: 1
│   ├── createdAt: ISO 8601
│   ├── checksum: SHA-256
│   └── encryptionAlgorithm: AES-256-GCM
│
├── data (encrypted):
│   ├── accounts: [...]
│   ├── categories: [...]
│   ├── transactions: [...]
│   ├── people: [...]
│   ├── ledgerEntries: [...]
│   ├── budgets: [...]
│   ├── goals: [...]
│   ├── paymentMethods: [...]
│   ├── settings: [...]
│   └── tags: [...]
│
└── footer:
    └── checksum: SHA-256 (signed)
```

### 10.2 Backup Rules

- Backup includes ALL data except: device-specific config, notification preferences, session state, attachment files.
- Attachments are backed up separately (optional: include or skip).
- Backup file must not exceed device storage limit.
- Backup is encrypted with AES-256-GCM using device-derived key.
- User may optionally set a custom encryption password.

### 10.3 Restore Validation

| Check | Action |
|-------|--------|
| File signature valid | Continue |
| Decryption successful | Continue |
| Schema version compatible | Continue |
| Schema version incompatible | Show error: "Backup from newer app version" |
| Checksum valid | Continue |
| Checksum invalid | Show error: "Backup file corrupted" |
| Data integrity check | Verify all FK references are resolvable |

### 10.4 Restore Rollback

If restore fails at any point:
1. Keep old data intact until new data is fully written
2. If failure occurs mid-write, roll back to previous state
3. Atomic restore using a temporary database + swap on success

---

## 11. Search Architecture

### 11.1 Searchable Fields

| Entity | Searchable Fields |
|--------|------------------|
| Transaction | description, note, amount (formatted), date, category name, account name, tags, payment method name |
| Person | name, phone, email, address, notes, tags |
| LedgerEntry | description, note, amount (formatted), date, person name, account name, tags |
| Account | name, description |
| Category | name |
| Budget | name |
| Goal | name |

### 11.2 Search Index Strategy

- Full-text search implemented via Isar's `where().filter()` with case-insensitive string matching.
- Search queries are truncated to 2-200 characters.
- Results are capped at 50 per entity type.
- Index strategy relies on the existing column indexes (search filters on indexed columns where possible).
- For future: consider dedicated FTS (Full-Text Search) extension or external search index.

---

## 12. Reporting Architecture

### 12.1 Report Computation

Reports are computed on-demand from the event-sourced data. No pre-aggregated tables in MVP.

| Report | Data Source | Query Pattern |
|--------|-------------|---------------|
| Spending by Category | Transaction | SUM(amount) WHERE type=Expense AND date in range, GROUP BY categoryId |
| Income vs. Expense | Transaction | SUM(amount) WHERE date in range, GROUP BY type, GROUP BY month |
| Net Worth | Account | SUM(balance) — computed from all transactions per account |
| Cash Flow | Transaction | All transactions in date range, ordered by date |
| Budget vs. Actual | Budget + Transaction | Budget.amount vs SUM(expense) WHERE category in budget's categories |
| Monthly Summary | Transaction | SUM grouped by type for the month |
| Category Summary | Transaction | SUM grouped by category for the period |
| Account Summary | Transaction | SUM per account for the period |
| Outstanding Summary | Person | Computed balance per person, filtered by non-zero |
| Person Statement | LedgerEntry | All entries for person, sorted by date |

### 12.2 Performance Optimization

For MVP, reports compute on-the-fly. Expected performance:
- Monthly data (< 2000 entries): < 500ms
- Yearly data (< 24000 entries): < 3s
- All-time data (< 100000 entries): < 10s

If performance degrades in production, add pre-aggregated summary tables:
- `DailySummary`: accountId, date, totalIncome, totalExpense, netChange
- `MonthlyCategorySummary`: accountId, year, month, categoryId, totalAmount
- `PersonMonthlySummary`: personId, year, month, totalGiven, totalReceived, netChange

---

## 13. Migration Strategy

### 13.1 Versioning

- Database schema version is stored in the `SchemaVersion` table.
- Version numbers are sequential integers starting at 1.
- Each migration is a Dart class that implements `up()` and `down()`.
- Migration files are stored in `lib/app/database/migrations/`.

### 13.2 Migration File Structure

```
migrations/
├── migration_001_initial.dart    // v0 → v1: Initial schema
├── migration_002_tags.dart       // v1 → v2: Add tags to Transaction
└── migration_003_attachments.dart // v2 → v3: Add Attachment table
```

### 13.3 Migration Execution

```
1. Read current schema version from SchemaVersion table (or 0 if absent)
2. If currentVersion < latestVersion:
   a. Apply migrations sequentially (currentVersion + 1 ... latestVersion)
   b. For each migration:
      - Run up()
      - Insert SchemaVersion record with checksum
      - If failure: roll back entire migration batch
3. If currentVersion == latestVersion: proceed normally
4. If currentVersion > latestVersion: warn — database from future version
```

### 13.4 Migration Rules

| Rule | Description |
|------|-------------|
| MR-01 | Never delete a column that might contain user data. Add nullable columns instead. |
| MR-02 | Every migration must have a corresponding rollback (`down()`). |
| MR-03 | Migration checksums prevent re-running the same migration. |
| MR-04 | Columns can be added as nullable without a migration (Isar supports this). |
| MR-05 | Adding non-nullable columns with defaults requires a migration. |
| MR-06 | Renaming a column = create new column + data copy + drop old column (3-step migration). |
| MR-07 | All migrations run inside a single transaction. Failure rolls back everything. |

---

## 14. Future Expansion

### 14.1 Multi-User Architecture

When multi-user support is added:

```
User (new entity)
├── id (UUID)
├── name
├── preferredCurrency
├── locale
└── isPrimary (bool)

All existing entities get a userId FK (for multi-user on same device)
```

### 14.2 Cloud Sync Additions

```
SyncQueue → active (not empty in MVP)
SyncConflict → new table
All entities → use uuid for server-side joins

Server-side tables (new):
- ServerAccount (mirrors Account)
- ServerTransaction (mirrors Transaction)
- etc.
```

### 14.3 AI Insights Data

For future AI/ML features, consider adding:

```
SpendingPattern
├── period
├── categoryId
├── averageAmount
├── frequency
├── trend (up/down/flat)
└── confidence (0.0 - 1.0)

Insight
├── type (anomaly, trend, suggestion)
├── title
├── description
├── severity (info/warning/alert)
├── relatedEntityType
├── relatedEntityId
├── isDismissed
└── createdAt
```

### 14.4 OCR Data

```
ScannedDocument
├── id
├── filePath
├── rawText (OCR output)
├── confidence
├── suggestedAmount
├── suggestedDate
├── suggestedCategory
├── suggestedAccount
├── isProcessed
└── linkedTransactionId (nullable)
```

### 14.5 Entity Scaling Limits

| Entity | Practical Limit | Mitigation |
|--------|----------------|------------|
| Account | 100 | Sortable, scrollable list |
| Category | 200 | Type-grouped, searchable |
| Transaction | 1,000,000 | Date-indexed, virtual scrolling, monthly archiving |
| Person | 10,000 | Search, type filter, alphabetical grouping |
| LedgerEntry | 1,000,000 per person (unlikely) | Date-indexed, paginated |
| Budget | 100 active | Archive old periods |
| Goal | 100 active | Archive completed |
| Attachment | 50 MB total device storage | Compression, storage usage indicator |
| Tag | 500 | Autocomplete, dedup on creation |

---

## Change History

| Date | Version | Author | Changes |
|------|---------|--------|---------|
| 2026-07-20 | 1.0 | Database Architecture | Initial production database architecture document |

---

## References

- [Product Requirements Document](02_Product_Requirements_Document.md)
- [Information Architecture](08_Navigation_Architecture.md)
- [System Architecture](03_System_Architecture.md)
- [Clean Architecture](04_Clean_Architecture.md)
- [Offline-First Strategy](12_Offline_First_Strategy.md)
- [Sync Architecture](13_Sync_Architecture.md)
- [Documentation Home](README.md)
