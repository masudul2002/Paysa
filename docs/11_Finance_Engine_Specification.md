# Finance Engine & Business Rules Specification

**Product:** Paysa — Offline-first Finance & Ledger Platform  
**Document:** FE v1.0  
**Status:** Draft  
**Owner:** FinTech Architecture  
**Last Updated:** 2026-07-20  

---

## TABLE OF CONTENTS

1. [General Principles](#1-general-principles)
2. [Account Engine](#2-account-engine)
3. [Category Engine](#3-category-engine)
4. [Transaction Engine](#4-transaction-engine)
5. [Transfer Engine](#5-transfer-engine)
6. [Ledger Engine](#6-ledger-engine)
7. [Lending Engine](#7-lending-engine)
8. [Balance Engine](#8-balance-engine)
9. [Payment Method Engine](#9-payment-method-engine)
10. [Report Engine](#10-report-engine)
11. [Search Engine](#11-search-engine)
12. [Delete Engine](#12-delete-engine)
13. [Edit Engine](#13-edit-engine)
14. [Audit Engine](#14-audit-engine)
15. [Share Engine](#15-share-engine)
16. [Reminder Engine](#16-reminder-engine)
17. [Backup Engine](#17-backup-engine)
18. [Sync Engine](#18-sync-engine)
19. [Security Engine](#19-security-engine)
20. [Edge Case Catalog](#20-edge-case-catalog)
21. [Error Handling](#21-error-handling)

---

## 1. General Principles

### 1.1 Core Principles

| # | Principle | Description | Enforced By |
|---|-----------|-------------|-------------|
| GP-01 | **Offline-first** | Every operation works without network. Local DB is the source of truth. | Architecture |
| GP-02 | **Immutable financial records** | Once committed, a financial record is NEVER mutated. Corrections create reversal entries. | Application logic |
| GP-03 | **Balance is derived, not stored** | Account and person balances are ALWAYS computed from entry sums. Never stored as a mutable field. | Application logic |
| GP-04 | **No silent data loss** | Every user action that affects financial data produces a visible, undoable, or logged outcome. | Application logic |
| GP-05 | **No hidden calculations** | Every computed value (balance, outstanding, budget progress) can be explained by enumerating the source entries. | Application logic |
| GP-06 | **Predictable behavior** | Given the same inputs, the system produces the same outputs. No randomness, no unspecified behavior. | Application logic |
| GP-07 | **Deterministic balance** | A balance at any point in time is the deterministic sum of all entries before that time. | Application logic |
| GP-08 | **Audit-friendly** | Every financial mutation creates an audit log entry. Audit logs are immutable and readable. | Application logic |
| GP-09 | **Soft-delete default** | Financial data is never permanently deleted. Data is hidden via soft-delete and can be restored. | Application logic |
| GP-10 | **Reversals over edits** | To correct a financial error, create a reversal entry. Do NOT mutate the original entry. | Application logic |

### 1.2 Amount Handling

| Rule | Value |
|------|-------|
| Storage type | `int` (signed 64-bit) |
| Unit | Smallest currency unit (cents, paisa, fils) |
| Precision | Depends on currency (2 for USD, 3 for KWD, 0 for JPY) |
| Display | Divide by 10^precision on output |
| Max value (2-decimal) | ~92.2 quadrillion USD — exceeds any personal/business need |
| Min value (2-decimal) | -92.2 quadrillion USD |
| Rounding | Banker's rounding (round half to even) for currency conversion |
| Negative | Never. Direction field handles positive/negative semantics |

### 1.3 Operation Types

Every financial operation is classified as one of:

| Operation | Domain | Mutates Balance | Requires Account | Requires Person |
|-----------|--------|-----------------|-----------------|-----------------|
| Income | Finance | Yes (credit) | Yes | No |
| Expense | Finance | Yes (debit) | Yes | No |
| Transfer | Finance | Yes (both) | Yes (2) | No |
| Give Money | Ledger | Yes (debit) | Yes | Yes |
| Receive Money | Ledger | Yes (credit) | Yes | Yes |
| Sale | Ledger | Yes (credit) | Yes | Yes |
| Purchase | Ledger | Yes (debit) | Yes | Yes |
| Opening Balance | Both | Yes | Yes* | Yes* |
| Adjustment | Both | Yes | Optional | Optional |
| Discount | Ledger | No | No | Yes |
| Reversal | Both | Opposite | Yes | Yes* |

---

## 2. Account Engine

### 2.1 Account Types

| Code | Name | Allows Negative Balance | Icon | Category Context |
|------|------|------------------------|------|------------------|
| 0 | Cash | Yes | `cash` | Physical cash on hand |
| 1 | Bank | No (unless overdraft enabled) | `bank` | Bank checking/savings |
| 2 | Mobile Banking | No | `mobile_banking` | bKash, Nagad, Rocket, etc. |
| 3 | Credit Card | Yes (by nature) | `credit_card` | Liability account |
| 4 | Savings | No | `savings` | Savings account |
| 5 | Investment | Yes | `investment` | Stock, mutual fund, etc. |
| 6 | Other | Configurable | `other` | Any custom type |

### 2.2 Account Creation Rules

| Rule ID | Rule | Error if violated |
|---------|------|-------------------|
| ACC-01 | Account name must be 1-100 characters | "Account name is required" |
| ACC-02 | Account name must be unique (case-insensitive) | "An account named '{name}' already exists" |
| ACC-03 | Account type must be a valid AccountType value (0-6) | "Invalid account type" |
| ACC-04 | Currency must be a valid ISO 4217 3-letter code | "Invalid currency code" |
| ACC-05 | Initial balance can be any integer (including negative) | None |
| ACC-06 | Color must be a valid ARGB hex value | "Invalid color value" |
| ACC-07 | Icon must be a valid icon key from the design system | "Invalid icon" |
| ACC-08 | uuid is auto-generated as UUID v4 on creation | None (internal) |
| ACC-09 | version starts at 1 | None (internal) |
| ACC-10 | Bank account with negative balance creates a warning (not error) | Warning: "Bank accounts typically have positive balances" |

### 2.3 Account Edit Rules

| Rule ID | Rule | Error if violated |
|---------|------|-------------------|
| ACC-20 | Name change triggers name uniqueness revalidation | "An account named '{name}' already exists" |
| ACC-21 | Currency change is allowed. Existing transactions retain original currency. New transactions use new currency. | Warning: "Existing transactions will keep their original currency" |
| ACC-22 | Type change is allowed. No balance impact. | Warning: "Changing type does not affect balance" |
| ACC-23 | Balance cannot be directly edited after creation. Must use transactions. | Error: "Use income, expense, or transfer to change balance" |
| ACC-24 | Archived accounts cannot be used as the account for new transactions. | Error: "Cannot add transactions to an archived account" |

### 2.4 Account Archive Rules

| Rule ID | Rule |
|---------|------|
| ACC-30 | Archiving hides the account from all default views |
| ACC-31 | Archived accounts continue to appear in historical reports (unless filtered out) |
| ACC-32 | Transactions can still be viewed for archived accounts (via explicit filter) |
| ACC-33 | Archiving does NOT affect account balance |
| ACC-34 | An archived account can be unarchived at any time |

### 2.5 Account Soft-Delete Rules

| Rule ID | Rule | Block if |
|---------|------|----------|
| ACC-40 | Accounts are soft-deleted (deletedAt set, record preserved) | Account has any transactions |
| ACC-41 | If account has transactions → BLOCK delete, suggest archive | "Cannot delete. Archive this account instead. It has X transactions." |
| ACC-42 | If account has zero transactions → allow hard delete | None |
| ACC-43 | Soft-deleted accounts can be restored (deletedAt set to null) | None |
| ACC-44 | Restoring a soft-deleted account restores it to active state | None |
| ACC-45 | If account is used in a RecurringTemplate, warn before archive/delete | "This account is used in X recurring templates" |

### 2.6 Account Merge Rules (Future)

| Rule ID | Rule |
|---------|------|
| ACC-50 | Merging Account A into Account B: All transactions with accountId=A → accountId=B |
| ACC-51 | Merging Account A into Account B: Account A is soft-deleted after merge |
| ACC-52 | Merge is irreversible (short of restoring from backup) |
| ACC-53 | Merge creates an audit log entry |

### 2.7 Account Balance Calculation

```
balance(account, asOf) = sum(income amounts) - sum(expense amounts) + sum(transfer in amounts) - sum(transfer out amounts) + openingBalance
```

Where:
- **Income**: transactions WHERE type=income AND accountId=account
- **Expense**: transactions WHERE type=expense AND accountId=account
- **Transfer in**: transactions WHERE type=transfer AND destinationAccountId=account
- **Transfer out**: transactions WHERE type=transfer AND accountId=account (source)
- **Opening balance**: the initial balance set at account creation

**Current balance** = balance(account, DateTime.now()) — filtered to non-deleted entries.

### 2.8 Account — Balance Change Causes

| Action | Effect | Timing |
|--------|--------|--------|
| Income recorded | +amount | Immediately on save |
| Expense recorded | -amount | Immediately on save |
| Transfer as source | -amount | Immediately on save |
| Transfer as destination | +amount | Immediately on save |
| Give Money (from this account) | -amount | Immediately on save |
| Receive Money (to this account) | +amount | Immediately on save |
| Sale (to this account) | +amount | Immediately on save |
| Purchase (from this account) | -amount | Immediately on save |
| Goal allocation (from this account) | -amount | Immediately on save |
| Goal withdrawal (to this account) | +amount | Immediately on save |
| Account archived | No change | — |
| Account soft-deleted | No change | — |
| Opening balance (at creation) | +amount | At creation |

---

## 3. Category Engine

### 3.1 Category Types

| Code | Name | Used In |
|------|------|---------|
| 0 | Income | Income transactions |
| 1 | Expense | Expense transactions |

### 3.2 Category — System Presets

Income (17 presets):
Salary, Wages, Freelance Income, Business Income, Investment Income, Rental Income, Dividend, Interest, Gift Received, Refund, Cashback, Bonus, Commission, Pension, Social Benefit, Scholarship, Other Income

Expense (32 presets):
Food & Dining, Groceries, Fruits & Vegetables, Meat & Fish, Snacks & Beverages, Eating Out, Transportation, Fuel, Public Transport, Ride Sharing, Vehicle Maintenance, Rent/Mortgage, Electricity, Water, Gas, Internet, Mobile/Phone, Entertainment, Shopping, Clothing, Health/Medical, Education, Personal Care, Travel, Gifts & Donations, Subscription, Gym/Fitness, Pet Care, Baby/Children, Home Supplies, Insurance, Other Expense

### 3.3 Category Rules

| Rule ID | Rule | Error if violated |
|---------|------|-------------------|
| CAT-01 | Category name is required, 1-100 chars | "Category name is required" |
| CAT-02 | Category name + type must be unique (case-insensitive) | "A {type} category named '{name}' already exists" |
| CAT-03 | Category type (income/expense) is immutable after creation | "Category type cannot be changed" |
| CAT-04 | System presets (isSystem=true) cannot be deleted | "System categories cannot be deleted. You can disable them." |
| CAT-05 | System presets cannot be renamed | "System categories cannot be renamed" |
| CAT-06 | Custom categories can be created, edited, and deleted | None |
| CAT-07 | Deleting a category does NOT delete associated transactions. Category reference becomes null. | Warning: "X transactions using this category will become uncategorized" |
| CAT-08 | A category can be archived (hidden from default picker but data preserved) | None |
| CAT-09 | Category type determines which transaction form it appears in (income categories → income form) | None |
| CAT-10 | Predefined category icons and colors can be overridden for custom categories | None |

### 3.4 Category Merge Rules (Future)

| Rule ID | Rule |
|---------|------|
| CAT-20 | Merging Category A into Category B: All transactions with categoryId=A → categoryId=B |
| CAT-21 | Category A is soft-deleted after merge |
| CAT-22 | Merge is irreversible |

---

## 4. Transaction Engine

### 4.1 Transaction Types

| Code | Name | Description |
|------|------|-------------|
| 0 | Income | Money received into an account |
| 1 | Expense | Money spent from an account |
| 2 | Transfer | Money moved between user's own accounts |

### 4.2 Transaction Creation Rules

| Rule ID | Rule | Applicable Types | Error if violated |
|---------|------|-------------------|-------------------|
| TXN-01 | Amount must be > 0 (stored as positive int) | All | "Amount must be greater than zero" |
| TXN-02 | Account must exist and not be archived | All | "Account not found or is archived" |
| TXN-03 | Account must not be soft-deleted | All | "Account not found" |
| TXN-04 | Category is required for income and expense | Income, Expense | "Category is required" |
| TXN-05 | Category type must match transaction type (income→Income, expense→Expense) | Income, Expense | "Category type must match transaction type" |
| TXN-06 | Category must not be archived (warning, not error) | Income, Expense | Warning: "Category is archived" |
| TXN-07 | Date can be past, present, or future (future requires explicit flag) | All | Warning: "Transaction date is in the future. Continue?" |
| TXN-08 | Currency defaults to account's currency. Can differ (multi-currency). | All | None |
| TXN-09 | Description max 500 characters | All | "Description must be under 500 characters" |
| TXN-10 | Tags max 10 per transaction, 30 characters each | All | "Maximum 10 tags per transaction" |
| TXN-11 | uuid auto-generated | All | None (internal) |
| TXN-12 | version starts at 1 | All | None (internal) |
| TXN-13 | Transfer requires destinationAccountId | Transfer | "Destination account is required for transfers" |
| TXN-14 | Transfer source and destination must differ | Transfer | "Source and destination accounts must be different" |
| TXN-15 | Transfer destination must not be archived or soft-deleted | Transfer | "Destination account not found or is archived" |
| TXN-16 | Exchange rate must be > 0 if currencies differ | Transfer | "Exchange rate must be greater than zero" |
| TXN-17 | Transfer fee recorded as separate expense transaction | Transfer (optional) | None |
| TXN-18 | Expense can be marked as pending (isPending=true) | Expense | None |
| TXN-19 | Parent transaction can be set for reversals | All | "Parent transaction not found" |
| TXN-20 | Reversal flag requires parentTransactionId | All | "Reversal must reference an original transaction" |

### 4.3 Transaction State Machine

```
[Draft] ──save──► [Completed]
                    │
                    ├── soft-delete ──► [Deleted]
                    │
                    └── reversal ──► [Completed (original)]
                                     [Completed (reversal)]
```

### 4.4 Recurring Transaction Rules

| Rule ID | Rule |
|---------|------|
| RTX-01 | A recurring transaction is a template. It does NOT represent individual transactions. |
| RTX-02 | On the scheduled nextDate, the system generates a new transaction from the template. |
| RTX-03 | Generated transactions are independent of the template. Editing the template does NOT modify generated transactions. |
| RTX-04 | If nextDate is in the past when the app opens, generate missed transactions (up to 30 days back). |
| RTX-05 | If the source account was archived on the generation date, skip generation and flag the template. |
| RTX-06 | Editing the template asks: "Apply to future instances only?" or "Apply to this instance only?" |
| RTX-07 | Deleting a template does NOT delete previously generated transactions. |
| RTX-08 | Templates with isActive=false do not generate new transactions. |

### 4.5 Transaction — Immutability Rule

**Once a transaction is committed (status = completed), it is IMMUTABLE.**

| Action | Allowed? | How to correct |
|--------|----------|----------------|
| Edit amount | ❌ No | Create reversal + new transaction |
| Edit account | ❌ No | Create reversal in old account + new in correct account |
| Edit category | ❌ No | Create reversal + new with correct category |
| Edit date | ❌ No | Create reversal + new with correct date |
| Edit description | ✅ Yes | No financial impact — mutable |
| Edit note | ✅ Yes | No financial impact — mutable |
| Edit tags | ✅ Yes | No financial impact — mutable |
| Edit isPending | ✅ Yes | No financial impact — mutable |
| Soft-delete | ✅ Yes | Reverses balance effect |
| Hard-delete | ❌ No | Use soft-delete |

### 4.6 Refund Rules

| Rule ID | Rule |
|---------|------|
| RFD-01 | A refund is recorded as a new transaction of the OPPOSITE type from the original. |
| RFD-02 | If original was an Expense (debit), refund is an Income (credit) to the same account. |
| RFD-03 | If original was Income (credit), refund is an Expense (debit) to the same account. |
| RFD-04 | The refund transaction links to the original via parentTransactionId. |
| RFD-05 | Refund amount can be up to the original amount (partial refund allowed). |
| RFD-06 | If partial refund, the remaining original amount is the effective expense/income. |

---

## 5. Transfer Engine

### 5.1 Transfer Model

**Decision: ONE record, not two.**

A transfer creates exactly one Transaction record with:
- `type` = Transfer
- `accountId` = source account (debited)
- `destinationAccountId` = destination account (credited)
- `amount` = transfer amount in source currency
- `exchangeRate` = rate if currencies differ
- `fee` = optional fee

### 5.2 Why One Record?

| Aspect | One Record | Two Linked Records |
|--------|------------|-------------------|
| Atomicity | Single write, single rollback | Must coordinate two writes |
| Balance tracking | Single source of truth | Must reconcile pair |
| Reporting | Single filter for transfers | Must JOIN across two records |
| Reversal | Reverse one record | Must reverse both |
| Error state | One failure = no partial state | One could succeed, other fail |
| Audit | Single audit entry | Two entries must be correlated |

**Decision: One record.** Unanimous advantage for an offline-first app.

### 5.3 Transfer Execution

```
1. Validate source and destination accounts
2. Validate source account balance ≥ amount (configurable: warn or block)
3. Calculate:
   a. If same currency: source debited by amount, destination credited by amount
   b. If different currencies: source debited by amount, destination credited by (amount × exchangeRate)
   c. If fee: source debited by (amount + fee), fee recorded as separate expense transaction
4. Create single Transaction record
5. Update both account balances (via query, not stored field)
6. Return the Transaction
```

### 5.4 Transfer Failure & Rollback

| Failure Point | Action |
|---------------|--------|
| Validation failure | Transaction NOT created. No balance impact. |
| Write failure (DB error) | Not written. No balance impact. Automatic retry. |
| Partial write (power loss) | Isar atomic write prevents partial state. |
| Fee creation fails | Transfer is NOT created. Rollback entire operation. |

---

## 6. Ledger Engine

### 6.1 Person Types

| Code | Type | Balance Direction (Typical) | Business Context |
|------|------|----------------------------|------------------|
| 0 | Customer | Positive (customer owes user) | Sale-oriented |
| 1 | Supplier | Negative (user owes supplier) | Purchase-oriented |
| 2 | Friend | Either | Personal lending |
| 3 | Family | Either | Personal lending |
| 4 | Employee | Either | Salary, advances |
| 5 | Other | Either | Uncategorized |

### 6.2 Ledger Entry Types

| Code | Name | Direction | Person Balance Effect | Account Balance Effect |
|------|------|-----------|----------------------|----------------------|
| 0 | Give (Loan) | Outgoing | +amount (they owe more) | -amount |
| 1 | Give (Gift) | Outgoing | +amount (they owe more) | -amount |
| 2 | Receive | Incoming | -amount (they owe less) | +amount |
| 3 | Sale | Outgoing | +amount (they owe more) | +amount |
| 4 | Purchase | Outgoing | +amount (you owe them more) | -amount |
| 5 | Adjustment + | Incoming | -amount (reduce what they owe) | None |
| 6 | Adjustment - | Outgoing | +amount (increase what they owe) | None |
| 7 | Discount | Incoming | -amount (write off what they owe) | None |
| 8 | Refund (give) | Outgoing | +amount | -amount |
| 9 | Refund (receive) | Incoming | -amount | +amount |
| 10 | Reversal | Varies | Opposite of original | Opposite of original |
| 11 | Opening | Varies | +amount or -amount | None |

### 6.3 Person Outstanding Balance Calculation

```
outstanding(person) = openingBalance + sum(type=Give, Sale) - sum(type=Receive, Discount) ± sum(type=Adjustment)
```

**Decision table:**

| Entry Type | Direction | Outstanding Effect |
|-----------|-----------|-------------------|
| Give (Loan) | Outgoing | +amount (person owes user more) |
| Give (Gift) | Outgoing | +amount (person owes user more) |
| Receive | Incoming | -amount (person owes user less) |
| Sale | Outgoing | +amount (customer owes user) |
| Purchase | Outgoing | +amount (user owes supplier) |
| Adjustment (+) | Incoming | -amount (reduce balance) |
| Adjustment (-) | Outgoing | +amount (increase balance) |
| Discount | Incoming | -amount (write-off) |
| Reversal | Varies | Opposite of original |
| Opening (give) | Outgoing | +amount |
| Opening (receive) | Incoming | -amount |

### 6.4 Person Lifecycle

```
[Active] ──archive──► [Archived]
   │                      │
   ├── soft-delete ──► [Deleted (no entries)]
   │                      │
   └── soft-delete ──► [BLOCKED (has entries)]
                              │
                         [Suggestion: archive instead]
```

### 6.5 Person Deletion Rules

| Rule ID | Rule |
|---------|------|
| PPL-01 | Person with non-zero outstanding balance CANNOT be deleted (hard or soft). Must archive. |
| PPL-02 | Person with zero outstanding balance and NO ledger entries → can be hard-deleted. |
| PPL-03 | Person with zero outstanding balance but HAS ledger entries → can be soft-deleted (archived). |
| PPL-04 | Archiving a person hides them from default views but preserves all data. |
| PPL-05 | An archived person can be unarchived at any time. |
| PPL-06 | Deleting a person deletes all associated ledger entries ONLY if balance is zero. |

### 6.6 Statement Generation Rules

| Rule ID | Rule |
|---------|------|
| STM-01 | Statement = all non-deleted ledger entries for a person within a date range |
| STM-02 | Entries sorted by date ascending |
| STM-03 | Running balance computed after each entry |
| STM-04 | Opening balance shows balance from before the date range (calculated from earlier entries) |
| STM-05 | Closing balance = opening + sum of all entries in range |
| STM-06 | Statement includes: person name, type, date range, opening balance, entries, closing balance |
| STM-07 | Statement does NOT include the user's account balances |
| STM-08 | Statement can be filtered by entry type |

---

## 7. Lending Engine

### 7.1 Core Lending Rules

| Rule ID | Rule |
|---------|------|
| LND-01 | Giving money to a person (Give, type=Loan) creates a receivable for the user |
| LND-02 | A loan Give entry can have a dueDate and optional reminder |
| LND-03 | A loan without a dueDate is open-ended (no reminder) |
| LND-04 | A gift Give entry (type=Gift) has no dueDate and no reminder |
| LND-05 | The person's outstanding balance increases by the Give amount |
| LND-06 | The user's account balance decreases by the Give amount |
| LND-07 | Receiving money from a person (Receive) decreases their outstanding balance |
| LND-08 | The user's account balance increases by the Receive amount |
| LND-09 | A Receive can be linked to a specific Give entry (settlement) or unlinked (general reduction) |

### 7.2 Partial Payment Rules

| Rule ID | Rule |
|---------|------|
| LND-10 | A partial payment is a Receive entry linked to a Give entry |
| LND-11 | After a partial payment, the Give entry's remaining balance = original amount - sum of all linked Receive amounts |
| LND-12 | A Give entry can have unlimited partial payments against it |
| LND-13 | Each partial payment creates a separate LedgerEntry with parentEntryId pointing to the original Give |

### 7.3 Full Payment Rules

| Rule ID | Rule |
|---------|------|
| LND-20 | A full payment is a Receive entry where amount = remaining balance of the Give entry |
| LND-21 | After full payment, the Give entry's remaining balance = 0 |
| LND-22 | The linked Give entry's isSettled flag becomes true |
| LND-23 | Any associated reminder is auto-cancelled |

### 7.4 Overpayment Rules

| Rule ID | Rule |
|---------|------|
| LND-30 | If Receive amount > remaining balance of the linked Give → the excess creates a credit balance (user now owes the person) |
| LND-31 | Example: Give Tk 10,000. Receive Tk 12,000. Person balance: -Tk 2,000 (user owes person Tk 2,000). |
| LND-32 | User is warned before overpayment: "Receiving Tk 12,000 exceeds the outstanding Tk 10,000. Excess Tk 2,000 will be recorded as a credit (you will owe the person)." |

### 7.5 Negative Balance Rules

| Rule ID | Rule |
|---------|------|
| LND-40 | A negative person balance means the user owes the person |
| LND-41 | If user gives money to a person with negative balance: the negative balance decreases toward zero, then becomes positive |
| LND-42 | Example: Balance = -Tk 5,000 (user owes). Give Tk 8,000. New balance: +Tk 3,000 (person owes user). |
| LND-43 | Negative balances are displayed in red with a "You owe" label |

### 7.6 Lending Adjustment Rules

| Rule ID | Rule |
|---------|------|
| LND-50 | An Adjustment entry changes a person's balance without a corresponding money movement |
| LND-51 | Adjustment requires a reason (required field, max 200 chars) |
| LND-52 | A Discount entry reduces what a person owes (write-off) |
| LND-53 | Discount requires a reason (required field) |
| LND-54 | Discounts are tracked separately from Adjustments in reports |

---

## 8. Balance Engine

### 8.1 When Balance Is Calculated

| Trigger | Scope | Performance |
|---------|-------|-------------|
| Dashboard load | All accounts, all people | Full scan on first load, cached for session |
| Account list view | All non-deleted accounts | Full scan |
| Account detail view | Single account | Single account scan |
| Person list view | All non-archived people | Full scan |
| Person detail view | Single person | Single person scan |
| Transaction list | Per-account (implicit) | Via date-indexed query |
| After any mutation | Affected account(s) + person (if ledger) | Single entity |
| After backup restore | All | Full scan |

### 8.2 Balance Calculation Performance

**Strategy:** Compute on demand using indexed queries.

| Scenario | Entities | Query Pattern | Expected Time |
|----------|----------|---------------|---------------|
| Account balance | 1 account | SUM where accountId = X | < 10ms |
| All account balances | 10 accounts | SUM GROUP BY accountId | < 50ms |
| Person outstanding | 1 person | SUM where personId = X | < 10ms |
| All person balances | 100 people | SUM GROUP BY personId | < 200ms |
| All person balances | 1000 people | SUM GROUP BY personId | < 2s |

**Optimization path (Phase 2):** Add a `BalanceSnapshot` table that stores computed balances nightly or on mutation. Snapshot invalidated on next mutation.

### 8.3 Balance Cache Invalidation

| Mutation | Invalidates |
|----------|-------------|
| New transaction | Account balance (source, destination if transfer) |
| Transaction soft-deleted | Account balance (source) |
| New ledger entry | Person balance + Account balance |
| Ledger entry soft-deleted | Person balance + Account balance |
| Goal allocation | Account balance |
| Goal withdrawal | Account balance |
| Backup restore | All balances |

### 8.4 Opening Balance Handling

| Rule | Detail |
|------|--------|
| Account opening balance | Set at creation via initial balance field. Becomes the first entry in balance computation. |
| Person opening balance | Set at creation or within 24-hour grace period. Becomes the first entry in person balance computation. |
| Opening balance in reports | Included in all historical calculations. Reports show it as a distinct line item. |
| Opening balance changes | After grace period, cannot be changed. Use Adjustment entries to correct. |

---

## 9. Payment Method Engine

### 9.1 Payment Method Types

| Code | Name | Preset? | Deletable? |
|------|------|---------|------------|
| 0 | Cash | Yes | No |
| 1 | Bank Transfer | Yes | No |
| 2 | Credit Card | Yes | No |
| 3 | Debit Card | Yes | No |
| 4 | bKash | Yes | No |
| 5 | Nagad | Yes | No |
| 6 | Rocket | Yes | No |
| 7 | Upay | Yes | No |
| 8 | Cheque | Yes | No |
| 9 | Mobile Banking | Yes | No |
| 10 | Online Transfer | Yes | No |
| 100+ | Custom | No | Yes |

### 9.2 Payment Method Rules

| Rule ID | Rule |
|---------|------|
| PMT-01 | System presets (isPreset=true) cannot be deleted or renamed |
| PMT-02 | System presets can be disabled/hidden (isEnabled=false) |
| PMT-03 | Custom payment methods can be created, edited, and deleted |
| PMT-04 | Custom payment method name must be unique (case-insensitive) |
| PMT-05 | Deleting a custom payment method: existing references are preserved (FK set to null on read) |
| PMT-06 | Payment methods have NO financial logic — informational only |
| PMT-07 | Payment methods available in: Income, Expense, Transfer, Give, Receive, Sale, Purchase |
| PMT-08 | Default sort order: system presets first (by popularity), custom methods below |

---

## 10. Report Engine

### 10.1 Report Calculation Rules

| Report | Data Source | Computation | Aggregation |
|--------|-------------|-------------|-------------|
| Spending by Category | Transaction | SUM(amount) WHERE type=expense AND date in range | GROUP BY categoryId |
| Income vs Expense | Transaction | SUM(amount) WHERE date in range | GROUP BY type, GROUP BY month |
| Net Worth | Transaction per Account | SUM(income) - SUM(expense) per account | GROUP BY accountId |
| Cash Flow | Transaction | All non-deleted transactions in date range | ORDER BY date |
| Budget vs Actual | Budget + Transaction | Budget.amount vs SUM(expense) matching categories | GROUP BY budgetId |
| Monthly Summary | Transaction | SUM by type for single month | GROUP BY type |
| Category Summary (person) | LedgerEntry | SUM by entry type | GROUP BY category/person |
| Outstanding Summary | LedgerEntry per Person | Computed balance per person | FILTER non-zero |

### 10.2 Report Rules

| Rule ID | Rule |
|---------|------|
| RPT-01 | Reports are read-only. They never modify data. |
| RPT-02 | Reports always filter by date range. Default range: current month. |
| RPT-03 | Reports exclude soft-deleted entries by default. |
| RPT-04 | Reports include archived accounts unless user filters them out. |
| RPT-05 | Reports with zero results show empty state ("No data for this period"). |
| RPT-06 | Multi-currency reports show each entry in its own currency. A total requires base currency selection. |
| RPT-07 | Report data is computed on load. No caching in MVP. |
| RPT-08 | Large date ranges (>1 year with >10K entries) show a progress indicator. |

### 10.3 Date Range Rules

| Preset | Definition |
|--------|------------|
| Today | Start = today 00:00, End = today 23:59 |
| This Week | Start = Monday 00:00 of current week, End = today 23:59 |
| This Month | Start = 1st of month 00:00, End = today 23:59 |
| Last Month | Start = 1st of last month 00:00, End = last day of last month 23:59 |
| This Year | Start = Jan 1 00:00 of current year, End = today 23:59 |
| Last Year | Start = Jan 1 00:00 of last year, End = Dec 31 23:59 of last year |
| Custom | User-selected start and end dates |

---

## 11. Search Engine

### 11.1 Searchable Fields by Entity

| Entity | Searchable Fields | Match Type |
|--------|-------------------|------------|
| Transaction | description, note, amount (as string), date, category name, account name, tags, payment method | Case-insensitive substring |
| Person | name, phone, email, address, notes, tags | Case-insensitive substring |
| LedgerEntry | description, note, amount (as string), date, person name, account name, tags | Case-insensitive substring |
| Account | name, description | Case-insensitive substring |
| Category | name | Case-insensitive substring |
| Budget | name | Case-insensitive substring |
| Goal | name | Case-insensitive substring |

### 11.2 Search Rules

| Rule ID | Rule |
|---------|------|
| SRC-01 | Minimum query length: 2 characters |
| SRC-02 | Maximum query length: 200 characters |
| SRC-03 | Maximum results per entity type: 50 |
| SRC-04 | Search is case-insensitive |
| SRC-05 | Search is accent-sensitive (future: accent-insensitive) |
| SRC-06 | Search is performed locally on all data |
| SRC-07 | Results are grouped by domain (Finance, Ledger) then by entity type |
| SRC-08 | Tapping a result navigates to the entity detail screen |
| SRC-09 | Recent searches are saved (max 10, persisted in AppSetting) |
| SRC-10 | Search debounce: 300ms after user stops typing |

---

## 12. Delete Engine

### 12.1 Delete Methods

| Method | Data Preserved? | UI Visibility | Reversible? | Use Case |
|--------|----------------|---------------|-------------|----------|
| Archive | ✅ Full | Hidden from default views | ✅ Unarchive | Person, Account, Category |
| Soft-delete | ✅ Full | Hidden from all views | ✅ Restore | Transaction, LedgerEntry |
| Hard-delete | ❌ Removed | Gone | ❌ Not reversible | Account (if no transactions), Person (if no entries) |
| Cascade | ❌ Removed with parent | Gone | ❌ Not reversible | GoalAllocation (when Goal deleted) |

### 12.2 Delete Decision Table

| Entity Type | Archive? | Soft-delete? | Hard-delete? | Default Action |
|-------------|----------|-------------|--------------|----------------|
| Account | ✅ | ❌ | ✅ (if no transactions) | Archive |
| Transaction | ❌ | ✅ | ❌ | Soft-delete |
| Category | ✅ | ❌ | ✅ (warn if in use) | Archive |
| Person | ✅ | ✅ (if zero balance) | ✅ (if no entries) | Archive |
| LedgerEntry | ❌ | ✅ | ❌ | Soft-delete |
| Budget | ❌ | ✅ | ❌ | Soft-delete |
| Goal | ❌ | ✅ | ❌ | Soft-delete |
| PaymentMethod (custom) | ❌ | ❌ | ✅ | Hard-delete |
| Tag | ❌ | ❌ | ✅ | Hard-delete |

### 12.3 Delete Cascade Rules

| Parent Deleted | Child Entities Affected | Action |
|----------------|------------------------|--------|
| Account | Transaction | RESTRICT — block deletion |
| Account | LedgerEntry | RESTRICT — block deletion |
| Account | RecurringTemplate | CASCADE — delete templates |
| Account | GoalAllocation | RESTRICT — block deletion |
| Category | Transaction | SET NULL — category ref nulled |
| Person | LedgerEntry | RESTRICT — block if non-zero balance |
| Person | OpeningBalance | CASCADE — delete opening balance |
| Person | Reminder | CASCADE — delete reminders |
| Person | Attachment | CASCADE — delete attachments |
| Budget | BudgetCategory | CASCADE — delete join records |
| Goal | GoalAllocation | CASCADE — delete allocations |

---

## 13. Edit Engine

### 13.1 Edit Permissions by Entity

| Entity | Editable Fields | Non-editable Fields | Rationale |
|--------|----------------|---------------------|-----------|
| Transaction | description, note, tags, isPending | amount, account, category, date, type | Financial fields affect balance |
| LedgerEntry | description, note, tags, dueDate | amount, person, account, type, direction | Financial fields affect balance |
| Account | name, type, icon, color, description, isArchived | balance, currency (warn) | Balance computed from transactions |
| Category | name (if custom), icon, color, group | type | Type determines transaction allocation |
| Person | name, type, phone, email, address, notes, photo, status | openingBalance (after grace period) | Opening balance is historical |
| Budget | name, amount, period, categories, alertPercent | — | All fields editable |
| Goal | name, targetAmount, deadline, icon, color, accountId | currentAmount | Current computed from allocations |

### 13.2 Edit Audit Rules

| Rule ID | Rule |
|---------|------|
| EDT-01 | Editing a non-financial field (description, note, tag) does NOT create a new version. |
| EDT-02 | Editing a financial field is ILLEGAL. Use reversal instead. |
| EDT-03 | Every edit creates an audit log entry with before/after values. |
| EDT-04 | Edited fields are shown with a small "edited" indicator in the UI (for future). |

---

## 14. Audit Engine

### 14.1 Audit Events

| Event Code | Event Name | Trigger | Severity |
|------------|------------|---------|----------|
| A-001 | Transaction Created | New transaction saved | Info |
| A-002 | Transaction Soft-Deleted | Transaction deleted | Warning |
| A-003 | Transaction Restored | Transaction undeleted | Info |
| A-004 | Transaction Reversed | Reversal transaction created | Warning |
| A-005 | Account Created | New account saved | Info |
| A-006 | Account Archived | Account archived | Info |
| A-007 | Account Restored | Account unarchived | Info |
| A-008 | Account Merged | Two accounts merged | Warning |
| A-009 | Person Created | New person saved | Info |
| A-010 | Person Archived | Person archived | Info |
| A-011 | Ledger Entry Created | Give/Receive/etc saved | Info |
| A-012 | Ledger Entry Soft-Deleted | Entry deleted | Warning |
| A-013 | Out-of-Balance Warning | Balance check fails | Error |
| A-014 | Backup Created | Backup completed | Info |
| A-015 | Backup Restored | Restore completed | Warning |
| A-016 | Data Cleared | All data deleted | Error |
| A-017 | Settings Changed | Any setting modified | Info |
| A-018 | Category Merged | Categories merged | Warning |
| A-019 | Person Merged | Persons merged | Warning |
| A-020 | Currency Converted | Transaction with exchange | Info |

### 14.2 Audit Log Storage

| Field | Type | Description |
|-------|------|-------------|
| id | int (auto) | Auto-increment |
| eventCode | String | A-001 through A-020 |
| entityType | String | Entity name |
| entityId | int | PK of affected entity |
| previousValues | String (JSON) | Null for creates |
| newValues | String (JSON) | Snapshot after change |
| timestamp | DateTime | When it happened |
| description | String | Human-readable summary |

### 14.3 Audit Rules

| Rule ID | Rule |
|---------|------|
| AUD-01 | Every financial mutation creates an audit log entry. |
| AUD-02 | Audit log entries are immutable (no edit, no delete). |
| AUD-03 | Audit log is stored locally. Included in backup. |
| AUD-04 | Audit log is exportable as CSV or JSON for external review. |
| AUD-05 | Audit log entries older than the retention period (configurable, default: never deleted) can be archived. |
| AUD-06 | Audit log viewer is accessible from Settings → About → Audit Log (future). |

---

## 15. Share Engine

### 15.1 Shareable Content

| Content Type | Available Formats | Target Platforms |
|-------------|-------------------|-----------------|
| Person Statement | Text summary, PDF | All share apps |
| Outstanding Balance | Text, Image | WhatsApp, Messenger |
| Monthly Report | Image, PDF | All share apps |
| Yearly Report | PDF | Email |
| Spending by Category | Image | All share apps |
| Cash Flow | CSV | Email |
| Budget Progress | Image | All share apps |

### 15.2 Share Rules

| Rule ID | Rule |
|---------|------|
| SHR-01 | Statement content: person name, outstanding balance, entry list with running balance |
| SHR-02 | Statements do NOT include the user's account balances |
| SHR-03 | Statements do NOT include data about other people |
| SHR-04 | Reports include only the data visible in the report |
| SHR-05 | User sees a preview before sharing |
| SHR-06 | All sharing uses the device's native share sheet |
| SHR-07 | Shared text includes a "Generated by Paysa" footer |
| SHR-08 | PDF generation includes page numbers, date, and "Paysa" branding |

---

## 16. Reminder Engine

### 16.1 Reminder Rules

| Rule ID | Rule |
|---------|------|
| REM-01 | Reminder can be set on any LedgerEntry with type=Give and a dueDate |
| REM-02 | Reminder cannot be set on Gift-type Give entries |
| REM-03 | A Give entry can have at most one active (non-completed) reminder |
| REM-04 | Reminder fires at the scheduled time via local notification |
| REM-05 | If the app is closed, the reminder fires on next app open |
| REM-06 | Reminders can be one-time or recurring (daily, weekly, monthly) |
| REM-07 | A recurring reminder continues until the linked entry's remaining balance = 0 |
| REM-08 | When a linked entry is fully settled, its reminder auto-cancels |

### 16.2 Reminder Timing

| Due Date Status | Classification | Visual Indicator |
|----------------|----------------|------------------|
| dueDate > today + 7 days | Upcoming | None |
| dueDate ≤ today + 7 days AND dueDate > today | Soon | Amber badge |
| dueDate = today | Due today | Orange badge |
| dueDate < today AND isSettled = false | Overdue | Red badge |

### 16.3 Overdue Reminder Rules

| Rule ID | Rule |
|---------|------|
| REM-20 | An overdue reminder fires daily at 9:00 AM until dismissed or settled |
| REM-21 | Overdue entries are shown at the top of the person's ledger list |
| REM-22 | The People tab shows a badge count equal to the number of overdue reminders |

---

## 17. Backup Engine

### 17.1 Backup Rules

| Rule ID | Rule |
|---------|------|
| BAK-01 | Backup is manual (user-initiated). No auto-backup in MVP. |
| BAK-02 | Backup includes ALL data: accounts, categories, transactions, people, ledger entries, budgets, goals, payment methods, settings, tags, notification preferences |
| BAK-03 | Backup does NOT include: device-specific config, session data, attachment files |
| BAK-04 | Backup file is encrypted with AES-256-GCM |
| BAK-05 | Encryption key is device-derived (future: user-provided password) |
| BAK-06 | User selects backup file location via OS file picker |
| BAK-07 | Backup file extension: `.paysa` |

### 17.2 Restore Rules

| Rule ID | Rule |
|---------|------|
| BAK-20 | Restore is destructive. ALL current data is replaced. |
| BAK-21 | User must confirm twice before restore begins. |
| BAK-22 | Backup file integrity is verified before restore starts. |
| BAK-23 | Schema version must match (major.minor). Backup from newer version is rejected. |
| BAK-24 | If restore fails midway, database rolls back to previous state. |
| BAK-25 | After successful restore, all cached balances are invalidated. |

### 17.3 Duplicate Detection on Restore

| Rule ID | Rule |
|---------|------|
| BAK-30 | On restore, UUIDs are compared. If a record with the same UUID exists, it is overwritten. |
| BAK-31 | If a record with the same UUID does NOT exist, it is inserted. |
| BAK-32 | Records in the database that have no corresponding record in the backup are preserved (they were created after the backup). |

---

## 18. Sync Engine (Future)

### 18.1 Sync Queue Rules

| Rule ID | Rule |
|---------|------|
| SYNC-01 | Every mutation creates a SyncQueue entry |
| SYNC-02 | SyncQueue entries are processed in creation order |
| SYNC-03 | Failed sync entries are retried up to 3 times, then flagged for manual review |
| SYNC-04 | Sync is user-initiated or scheduled (not real-time) |

### 18.2 Conflict Resolution Rules

| Rule ID | Rule |
|---------|------|
| SYNC-10 | Last-write-wins based on updatedAt timestamp |
| SYNC-11 | If updatedAt timestamps are within 1 second of each other: higher version wins |
| SYNC-12 | If version is also equal: device ID with higher UUID wins (deterministic tiebreaker) |
| SYNC-13 | Deletions always win over edits (tombstone overrides update) |

### 18.3 Deleted Record Sync

| Rule ID | Rule |
|---------|------|
| SYNC-20 | Soft-deleted records sync as tombstones (deletedAt timestamp + version) |
| SYNC-21 | The receiving device marks the equivalent local record as soft-deleted |
| SYNC-22 | A deleted-then-recreated record gets a new UUID (no conflict) |

---

## 19. Security Engine

### 19.1 Security Rules

| Rule ID | Rule | Implementation |
|---------|------|----------------|
| SEC-01 | App can be locked with a 4-6 digit PIN | Local storage (encrypted) |
| SEC-02 | App can be locked with biometric (fingerprint/face) | Platform biometric API |
| SEC-03 | When locked, app content is hidden in the app switcher | Flutter platform channel |
| SEC-04 | Lock activates after configurable timeout (immediate/1m/5m/15m) | Timer on app background |
| SEC-05 | Sensitive data (balances, amounts) can be hidden in lists | Toggle in Settings → Privacy |
| SEC-06 | When privacy mode is on, all amounts show as "***" | UI toggle |
| SEC-07 | No data is ever transmitted unless user explicitly shares or backs up | Architecture |
| SEC-08 | Backup files are encrypted | AES-256-GCM |

### 19.2 Privacy Mode Rules

| Rule ID | Rule |
|---------|------|
| PRV-01 | Privacy mode toggle in Settings |
| PRV-02 | When enabled: all balance cards, transaction amounts, and list amounts show "***" |
| PRV-03 | When enabled: notification content does not include amounts |
| PRV-04 | Privacy mode affects display ONLY. Data is always fully stored. |

---

## 20. Edge Case Catalog

### 20.1 Duplicate Transactions (Accidental Double-Entry)

| Rule ID | Resolution |
|---------|------------|
| EC-01 | The system cannot automatically detect duplicates. |
| EC-02 | Prevention: if the user creates two transactions within 60 seconds with the same amount, same account, same category, and same date → show a warning: "A similar transaction was just created. Duplicate?" |
| EC-03 | If user confirms "Not a duplicate" → save. |
| EC-04 | If duplicate was created, user must soft-delete one. |

### 20.2 Zero Amount

| Rule ID | Rule |
|---------|------|
| EC-10 | Zero-amount transactions are REJECTED at the application level |
| EC-11 | Zero-amount ledger entries are REJECTED at the application level |

### 20.3 Negative Amount

| Rule ID | Rule |
|---------|------|
| EC-20 | Amounts are ALWAYS stored as positive integers. Direction/type determines whether it's a credit or debit. |
| EC-21 | If a user enters a negative amount in the UI, it is normalized: -5000 → 5000 + flip direction |

### 20.4 Future Date

| Rule ID | Rule |
|---------|------|
| EC-30 | Transactions can be dated in the future, but require explicit user confirmation |
| EC-31 | Future-dated transactions are included in balance calculations immediately (the user is committing that the transaction will happen) |
| EC-32 | A future-dated transaction can be soft-deleted before its date without affecting historical reports (it was never "in the past") |

### 20.5 Past Date

| Rule ID | Rule |
|---------|------|
| EC-40 | Past-dated transactions are always allowed |
| EC-41 | A past-dated transaction affects the account balance as if it occurred on that date |
| EC-42 | Users can create a transaction dated before the account was created (warn: "This transaction date is before the account was created") |

### 20.6 Deleted Account Reference

| Rule ID | Rule |
|---------|------|
| EC-50 | If a transaction references an account that was later soft-deleted: the transaction is still visible in historical views, but the account is marked as "(Deleted)" |
| EC-51 | Transactions referencing soft-deleted accounts continue to appear in reports unless filtered |

### 20.7 Deleted Category Reference

| Rule ID | Rule |
|---------|------|
| EC-60 | If a transaction's category is deleted: categoryId becomes null. The transaction shows as "Uncategorized" |
| EC-61 | The original category name is preserved in a denormalized text field for historical accuracy (future) |

### 20.8 Deleted Person Reference

| Rule ID | Rule |
|---------|------|
| EC-70 | If a ledger entry references a person who is archived: the entry is still visible in the ledger history |
| EC-71 | The person's name is displayed with an "(Archived)" badge |

### 20.9 Currency Change

| Rule ID | Rule |
|---------|------|
| EC-80 | If a user changes an account's currency: existing transactions retain their original currency |
| EC-81 | New transactions use the new currency |
| EC-82 | Reports show multi-currency accounts in their respective currencies. Totals require a base currency to be selected. |

### 20.10 Account Merge

| Rule ID | Rule |
|---------|------|
| EC-90 | All transactions from the source account are reassigned to the target account |
| EC-91 | The source account is soft-deleted |
| EC-92 | An audit log entry is created describing the merge |
| EC-93 | Merge cannot be undone (restore from backup is the only option) |

### 20.11 Category Merge

| Rule ID | Rule |
|---------|------|
| EC-100 | All transactions from the source category are reassigned to the target category |
| EC-101 | The source category is soft-deleted |
| EC-102 | If target category has a different type than source → BLOCK merge |

### 20.12 Undo Delete

| Rule ID | Rule |
|---------|------|
| EC-110 | Soft-deleted items can be restored within 30 days |
| EC-111 | Restoring a soft-deleted transaction reverses its balance effect |
| EC-112 | Restoring a soft-deleted ledger entry reverses its balance effect |
| EC-113 | After 30 days, soft-deleted items are auto-purgable (future) |

### 20.13 Backup Restore Duplicate

| Rule ID | Rule |
|---------|------|
| EC-120 | If a backup is restored onto the same device without wiping first: records with matching UUIDs are overwritten. Records without matching UUIDs are duplicated. |
| EC-121 | Prevention: before restore, show a warning: "This backup may contain duplicate records if data was added after the backup was created." |

---

## 21. Error Handling

### 21.1 Error Severity Levels

| Level | Description | User Impact | Recovery |
|-------|-------------|-------------|----------|
| Info | Expected non-error event | None | N/A |
| Warning | User action may have unintended effect | No data loss | User can proceed or cancel |
| User Error | Validation failure | Action rejected | User must correct input |
| System Error | Unexpected failure | Operation failed | Automatic retry or user retry |
| Fatal | Unrecoverable state | App may crash | Restart or reinstall |

### 21.2 Error Code Ranges

| Range | Module | Example |
|-------|--------|---------|
| 1000-1999 | Account | 1001: "Account name already exists" |
| 2000-2999 | Category | 2001: "Category type cannot be changed" |
| 3000-3999 | Transaction | 3001: "Amount must be greater than zero" |
| 4000-4999 | Transfer | 4001: "Source and destination must differ" |
| 5000-5999 | Ledger | 5001: "Person has non-zero outstanding balance" |
| 6000-6999 | Database | 6001: "Database write failed" |
| 7000-7999 | Backup | 7001: "Backup file is corrupted" |
| 8000-8999 | Sync (future) | 8001: "Sync conflict unresolved" |
| 9000-9999 | General | 9001: "Operation not permitted" |

### 21.3 System Error Handling

| Error Type | Detection | User Message | Recovery |
|------------|-----------|--------------|----------|
| DB write failure | Isar throws exception | "Could not save. Please try again." | Auto-retry once |
| DB read failure | Isar throws exception | "Could not load data." | Pull-to-refresh retry |
| File write failure (backup) | OS file API error | "Could not write backup to this location." | Choose different location |
| File read failure (restore) | OS file API error | "Could not read backup file." | Choose different file |
| Encryption failure | Crypto library error | "Could not encrypt backup." | Retry or contact support |
| Decryption failure | Crypto library error | "Backup file could not be decrypted. It may be corrupted or from another device." | Use different backup |

### 21.4 User Error Messages

| Scenario | Error Message | Error Code |
|----------|---------------|------------|
| Empty account name | "Account name is required." | 1001 |
| Duplicate account name | "An account named '{name}' already exists." | 1002 |
| Transaction to archived account | "Cannot add transactions to an archived account." | 3002 |
| Zero amount | "Amount must be greater than zero." | 3003 |
| Same source/destination transfer | "Source and destination accounts must be different." | 4001 |
| Delete person with balance | "Cannot delete. This person has an outstanding balance of {amount}." | 5001 |
| Delete account with transactions | "Cannot delete. This account has {count} transactions. Archive instead." | 1004 |
| Category type mismatch | "Category type must match transaction type." | 2002 |
| Backup version incompatible | "This backup was created by a newer version of Paysa. Please update the app to restore." | 7002 |
| Restore corruption | "Backup file is corrupted. Try a different backup." | 7003 |

---

## Change History

| Date | Version | Author | Changes |
|------|---------|--------|---------|
| 2026-07-20 | 1.0 | FinTech Architecture | Initial Finance Engine Specification |

---

## References

- [Product Requirements Document](02_Product_Requirements_Document.md)
- [Database Architecture](10_Data_Modeling.md)
- [Information Architecture](08_Navigation_Architecture.md)
- [System Architecture](03_System_Architecture.md)
- [Documentation Home](README.md)
