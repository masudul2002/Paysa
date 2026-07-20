# Product Requirements Document

**Product:** Paysa — Offline-first Finance & Ledger Platform  
**Version:** 3.0  
**Status:** Draft  
**Owner:** Product Management  
**Last Updated:** 2026-07-20  
**Classification:** Internal — Single Source of Truth

---

## TABLE OF CONTENTS

1. [Executive Summary](#1-executive-summary)
2. [Product Overview](#2-product-overview)
3. [Target Users & Personas](#3-target-users--personas)
4. [Product Philosophy](#4-product-philosophy)
5. [App Modes](#5-app-modes)
6. [Module Specifications](#6-module-specifications)
   - 6.1 [Dashboard](#61-dashboard)
   - 6.2 [Accounts](#62-accounts)
   - 6.3 [Categories](#63-categories)
   - 6.4 [Transactions](#64-transactions)
   - 6.5 [People](#65-people)
   - 6.6 [Ledger](#66-ledger)
   - 6.7 [Payment Methods](#67-payment-methods)
   - 6.8 [Budgets](#68-budgets)
   - 6.9 [Savings Goals](#69-savings-goals)
   - 6.10 [Reports](#610-reports)
   - 6.11 [Search](#611-search)
   - 6.12 [Backup & Restore](#612-backup--restore)
   - 6.13 [Settings](#613-settings)
   - 6.14 [Notifications](#614-notifications)
   - 6.15 [Share & Export](#615-share--export)
7. [Database Design](#7-database-design)
8. [UX & Navigation](#8-ux--navigation)
9. [Design System](#9-design-system)
10. [Security & Privacy](#10-security--privacy)
11. [Future Sync Architecture](#11-future-sync-architecture)
12. [Roadmap & Phases](#12-roadmap--phases)
13. [Decision Log](#13-decision-log)
14. [Open Questions](#14-open-questions)
15. [Architecture Notes](#15-architecture-notes)
16. [Appendices](#16-appendices)

---

## 1. Executive Summary

Paysa is an offline-first Finance & Ledger Platform that combines personal finance management with digital ledger workflows in a single, original product. It enables individuals, families, freelancers, shop owners, and small businesses to track money across two complementary domains: their own personal finances and their interpersonal financial transactions (lending, borrowing, customer/supplier balances, and settlements).

The product prioritizes privacy, offline reliability, speed, simplicity, and professional design. No existing application is copied — Paysa creates an original experience while supporting proven finance workflows.

---

## 2. Product Overview

### 2.1 Product Vision

Create a trusted finance platform that helps users understand, organize, and control their money — both personal and interpersonal — with confidence, on their own terms, entirely offline.

### 2.2 Product Mission

Deliver a disciplined, documentation-driven product that supports stable, scalable growth from foundation to release, combining personal finance tracking and digital ledger workflows in a single original product without copying existing applications.

### 2.3 Problem Statement

Individuals, families, freelancers, and small operators lack a unified, offline-capable tool to manage both personal finances and interpersonal money transactions. Current solutions fragment into:
- Personal finance apps (track spending, budgets, goals)
- Ledger/IOU apps (track who owes whom)
- Business cashbook apps (track customer/supplier balances)
- Paper records or mental notes

Users are forced to maintain multiple systems, leading to inconsistency, lost data, and cognitive overhead. Paysa solves this by providing one app that does all of the above, offline-first.

### 2.4 Business Goals

BG-1: Help users manage personal and interpersonal finances with confidence and consistency.  
BG-2: Establish a stable product foundation for long-term growth across both domains.  
BG-3: Support future expansion without forcing repeated redesigns.  
BG-4: Maintain strong trust through clarity, reliability, and privacy-minded decisions.  
BG-5: Create an original product that differentiates through the finance + ledger combination.  
BG-6: Enable a migration path from paper-ledger users to digital without friction.

### 2.5 Success Metrics

SM-1: Users can complete core workflows in under 30 seconds.  
SM-2: Core finance and ledger activities remain available in offline scenarios (100% of MVP features).  
SM-3: Product and documentation stay aligned across releases (documentation review gates).  
SM-4: The roadmap can expand without destabilizing the foundation.  
SM-5: Zero data loss in backup/restore scenarios.

### 2.6 Product Scope — In Scope

**Personal Finance Domain:**
- Account management (Cash, Bank, Mobile Banking, Credit Card, Savings, Investment, Other)
- Income tracking with categorization
- Expense tracking with categorization
- Transfers between accounts
- Recurring transactions
- Budgets with period tracking
- Savings goals with allocation tracking
- Spending, income, net worth, and cash flow reports

**Ledger Domain:**
- People management (Customer, Supplier, Friend, Family, Employee, Other)
- Give Money (lend, gift, pay out)
- Receive Money (repayment, collection, gift in)
- Opening Balance
- Adjustment entries
- Discount entries
- Sale/Purchase tracking
- Ledger History with running balance
- Outstanding Balance per person and net
- Payment Reminders
- Notes on entries and people
- Attachments (images, PDFs)
- Share Statement

**Cross-cutting:**
- Payment Methods (Cash, Bank, Card, Bkash, Nagad, Rocket, Upay, Cheque, Mobile Banking, Custom)
- Unified Search across both domains
- Local Notifications (reminders, alerts, achievements)
- Backup & Restore
- Settings (theme, currency, defaults, preferences)
- Dashboard (aggregated overview of both domains)

### 2.7 Product Scope — Out of Scope

- Complex enterprise accounting (GAAP, double-entry beyond ledger scope)
- Investment portfolio tracking, stock market integration
- Tax preparation, filing, or calculation
- Bank feed aggregation or automatic bank import (MVP)
- Real-time cloud sync (future phase)
- Multi-user or household sharing (future phase)
- OCR receipt scanning (future phase)
- AI-powered insights (future phase)

---

## 3. Target Users & Personas

### 3.1 Target User Groups

| Group | Needs | Primary Domain |
|-------|-------|----------------|
| Students | Track expenses, manage limited budgets, track friend loans | Finance + Ledger |
| Families | Household budget, shared expenses, track family lending | Finance + Ledger |
| Freelancers | Track income from clients, expenses, client payment status | Finance + Ledger |
| Shop Owners | Daily sales, supplier payments, customer credit tracking | Ledger-heavy |
| Small Businesses | Cashbook, customer/supplier ledger, P&L view | Ledger + Finance |
| Personal Users | Daily expense tracking, savings goals, lend/borrow tracking | Finance + Ledger |

### 3.2 Personas

**Persona 1: Rafiq — The Shop Owner**
- Age: 45
- Occupation: Small grocery shop owner
- Pain points: Uses a physical notebook for customer credit, forgets who paid what, loses paper records
- Needs: Record daily sales, track customer outstanding balances, get reminders for pending payments
- Domains: Ledger (primary), Finance (secondary)
- Technical level: Low — needs simple, icon-driven UI with minimal text entry

**Persona 2: Nusrat — The Freelancer**
- Age: 28
- Occupation: Graphic designer
- Pain points: Mixes personal and business money, forgets to invoice clients, doesn't track expenses
- Needs: Separate client invoicing, expense tracking for tax, savings goals for equipment purchases
- Domains: Finance + Ledger (equal)
- Technical level: High — comfortable with digital tools

**Persona 3: Hasan — The Student**
- Age: 21
- Occupation: University student
- Pain points: Runs out of money mid-month, lends small amounts to friends and forgets
- Needs: Monthly budget tracking, quick expense entry, friend loan tracking
- Domains: Finance (primary), Ledger (secondary)
- Technical level: Medium — app-native user

**Persona 4: Fatima — The Homemaker**
- Age: 38
- Occupation: Household manager
- Pain points: Manages household expenses across multiple categories, tracks family member loans
- Needs: Category-based expense tracking, family ledger, monthly summaries
- Domains: Finance + Ledger
- Technical level: Medium

**Persona 5: Karim — The Small Business Owner**
- Age: 52
- Occupation: Runs a small construction materials supply business
- Pain points: Multiple suppliers with complex payment terms, customer credit management, needs to share statements
- Needs: Supplier ledger with purchase tracking, customer ledger with sale tracking, statement sharing via WhatsApp
- Domains: Ledger (primary)
- Technical level: Low — needs minimal taps

---

## 4. Product Philosophy

### 4.1 Core Principles

| Principle | Description |
|-----------|-------------|
| **Privacy First** | All data stays on-device. No telemetry, no analytics, no cloud without explicit user consent. |
| **Offline-Native** | Every feature works without internet. Offline is not a degraded mode; it is the primary mode. |
| **Fast by Default** | UI responds in under 100ms for interactions. Lists render instantly. Search completes in under 500ms. |
| **Simple & Clear** | One tap to record a transaction. No confusing finance jargon. Clear visual hierarchy. |
| **Reliable & Correct** | Balances always reconcile. Data is never silently lost. Validation catches errors before they happen. |
| **Beautiful & Professional** | Material 3 design system. Attention to typography, spacing, color, and motion. Professional-grade output (statements, reports). |
| **Original Experience** | Never copy another app's design. Solve problems in a way that feels natural to the target users. |

### 4.2 Design Tenets

1. **One-handed operation** — Primary actions within thumb reach on a 6.5" screen.
2. **Data integrity over convenience** — If we cannot guarantee correctness, we do not allow the operation.
3. **Progressive disclosure** — Show essentials first, advanced options on demand.
4. **Credit-culture aware** — Support lending, borrowing, and credit workflows common in South Asian and Middle Eastern contexts (where the product is initially targeted).
5. **Low-literacy friendly** — Icon-driven navigation, minimal text requirements, numeric keypad by default for money entry.

---

## 5. App Modes

Paysa operates in two modes. Users may use one or both. The app does not force a mode choice at setup — all features are available.

### 5.1 Mode 1: Personal Finance

Focuses on the user's own money:
- Accounts and balances
- Income/Expense/Transfer tracking
- Categories
- Budgets
- Savings Goals
- Personal Finance Reports

### 5.2 Mode 2: Ledger

Focuses on interpersonal financial relationships:
- People directory
- Give/Receive Money
- Opening Balance
- Sale/Purchase
- Adjustment/Discount
- Ledger History
- Outstanding Balance
- Payment Reminders
- Notes & Attachments
- Statement Sharing

### 5.3 Dual-Mode Integration

The two modes share:
- **Accounts** — A Ledger Give entry debits from an account; a Ledger Receive entry credits to an account
- **Payment Methods** — Shared across both modes
- **Search** — Unified across both domains
- **Dashboard** — Shows summary from both domains
- **Reports** — Can include or exclude ledger activity
- **Settings** — Shared preferences
- **Backup** — Single backup includes both domains

---

## 6. Module Specifications

---

### 6.1 Dashboard

#### 6.1.1 Purpose
Provide a centralized, at-a-glance overview of the user's complete financial picture — both personal and ledger — with quick access to common actions.

#### 6.1.2 Primary Users
All users

#### 6.1.3 User Stories
- As a user, I want to see my total balance across all accounts so I know my net position.
- As a user, I want to see recent transactions from both domains so I stay informed.
- As a user, I want to see total outstanding balance (who owes me / who I owe) so I know my ledger position.
- As a user, I want to quickly add any type of transaction from one screen.
- As a user, I want to see budget progress (if budgets exist).

#### 6.1.4 Business Rules
- Dashboard shows total balance across all active accounts.
- Dashboard shows net outstanding: total owed to user minus total user owes.
- Dashboard shows 5 most recent entries from both Finance and Ledger, interleaved by date.
- Budget progress cards appear if budgets exist (show up to 3).
- Savings goal progress cards appear if goals exist (show up to 3).
- Quick action bar: Add Income, Add Expense, Add Transfer, Give Money, Receive Money.

#### 6.1.5 Validation Rules
- Dashboard must render even if some data sources are unavailable (graceful degradation).
- Zero balances show "0.00" — not an error.
- Empty states show onboarding prompts, not blank screens.

#### 6.1.6 Permissions
- No special permissions required for dashboard display.

#### 6.1.7 Offline Behaviour
- Dashboard loads from local database. Works fully offline.

#### 6.1.8 Future Sync Behaviour
- Dashboard remains locally computed. Sync does not change dashboard logic.

#### 6.1.9 Acceptance Criteria
- AC-DASH-01: Total balance is displayed prominently at the top.
- AC-DASH-02: Net outstanding (Ledger) is displayed in a separate card.
- AC-DASH-03: Recent transactions list shows last 5 entries with icon, description, amount, and domain badge.
- AC-DASH-04: Quick action buttons open the respective entry forms.
- AC-DASH-05: Empty states guide the user to create their first account or add their first transaction.
- AC-DASH-06: Budget and goal progress cards are shown if data exists.

#### 6.1.10 Edge Cases
- User has accounts but no transactions — show balance card + "No recent activity" state.
- User has ledger people but no finance accounts — show ledger summary prominently.
- Total balance crosses zero — show in red with sign.
- User has accounts in multiple currencies — show base currency with note.

#### 6.1.11 Dependencies
- Accounts module (for balance calculation)
- Transactions module (for recent transactions)
- Ledger module (for outstanding balance)
- Budgets module (if budgets exist)
- Savings Goals module (if goals exist)

#### 6.1.12 Future Enhancements
- Customizable dashboard layout (drag-and-drop cards)
- Multi-currency total with live rates
- Spending forecast chart
- Personalized insights ("You spent 20% more on food this month")

---

### 6.2 Accounts

#### 6.2.1 Purpose
Allow users to create and manage multiple financial accounts that represent where their money is held.

#### 6.2.2 Primary Users
All users (Finance mode primary, Ledger mode secondary)

#### 6.2.3 User Stories
- As a user, I want to create an account (Cash, Bank, Mobile Banking, Credit Card, Savings, Investment, Other) so I can track money in different places.
- As a user, I want to see all my accounts with current balances.
- As a user, I want to edit, archive, or delete accounts.
- As a user, I want to search and filter accounts by type or status.

#### 6.2.4 Business Rules
- Account types: Cash, Bank, Mobile Banking, Credit Card, Savings, Investment, Other.
- "Other" type allows a custom label.
- Each account has a unique name (case-insensitive enforcement).
- Balance is set at creation and updated via transactions.
- Deleting an account requires confirmation and warns about linked transactions and ledger entries.
- Archived accounts are excluded from default views but data is preserved.
- Account can have a description, color, and icon for visual identification.

#### 6.2.5 Validation Rules
- Account name is required, max 100 chars.
- Account name must be unique (case-insensitive).
- Balance must be a valid number (decimal, up to 2 decimal places).
- Negative balance allowed (credit card or overdraft).
- Currency must be a valid 3-letter ISO 4217 code.
- Color must be a valid ARGB hex value.

#### 6.2.6 Permissions
- No special permissions required.

#### 6.2.7 Offline Behaviour
- Full CRUD available offline. All account data is stored locally.

#### 6.2.8 Future Sync Behaviour
- Accounts sync with conflict resolution (last-write-wins).
- Archived status syncs.
- Deleted accounts sync as tombstone records.

#### 6.2.9 Acceptance Criteria
- AC-ACC-01: User can create an account with name, type, balance, currency, and optional color/icon.
- AC-ACC-02: Account list shows all non-archived accounts with name, type icon, and balance.
- AC-ACC-03: User can edit all account fields except auto-increment ID.
- AC-ACC-04: User can archive and unarchive accounts.
- AC-ACC-05: User can delete accounts with confirmation.
- AC-ACC-06: Archived accounts are hidden by default, visible via filter.
- AC-ACC-07: Name uniqueness is enforced case-insensitively.

#### 6.2.10 Edge Cases
- User creates "Bank" and "bank" — second creation rejected.
- User deletes an account with transactions — warn: "X transactions and Y ledger entries will become unlinked."
- Account balance is zero or negative at creation — allowed.
- User creates 50+ accounts — list should scroll with search.
- Account in a currency different from base currency — displayed in its own currency.

#### 6.2.11 Dependencies
- None (foundational module)

#### 6.2.12 Future Enhancements
- Account grouping (folders like "My Banks", "My Wallets")
- Net worth calculation
- Credit card-specific fields (statement date, due date, credit limit, APR)
- Account closure date tracking
- Account balance history chart

---

### 6.3 Categories

#### 6.3.1 Purpose
Provide a structured system for classifying income and expenses, enabling meaningful reporting and analysis.

#### 6.3.2 Primary Users
Finance mode users

#### 6.3.3 User Stories
- As a user, I want predefined categories so I can start tracking immediately.
- As a user, I want to create custom categories for my unique needs.
- As a user, I want to categorize transactions so I can understand my spending patterns.

#### 6.3.4 Business Rules
- Categories are typed: Income or Expense.
- Each category belongs to a group (e.g., Food & Dining, Transportation, Housing, Utilities, Entertainment, Shopping, Health, Education, Salary, Freelance, Investment, Business, Other).
- System presets are provided and cannot be deleted (can be disabled/hidden).
- Users can create, edit, and delete custom categories.
- Deleting a category does not delete associated transactions (category reference becomes null).
- Each category has a color and icon for visual identification.

#### 6.3.5 System Presets

**Income Presets:**
Salary, Freelance, Business Income, Investment Income, Gift Received, Rental Income, Refund, Interest, Dividend, Other Income

**Expense Presets:**
Food & Dining, Groceries, Transportation, Fuel, Rent/Mortgage, Utilities (Electricity, Water, Gas, Internet), Mobile/Phone, Entertainment, Shopping, Clothing, Health/Medical, Education, Insurance, Subscription, Household Supplies, Personal Care, Travel, Gifts & Donations, Eating Out, Snacks & Beverages, Other Expense

#### 6.3.6 Validation Rules
- Category name is required, max 50 chars.
- Category name must be unique within its type (case-insensitive).
- Category type (Income/Expense) is immutable after creation.

#### 6.3.7 Permissions
- No special permissions required.

#### 6.3.8 Offline Behaviour
- Full CRUD available offline.

#### 6.3.9 Future Sync Behaviour
- Category list syncs. Custom categories sync as user-created records.

#### 6.3.10 Acceptance Criteria
- AC-CAT-01: System presets are available on first launch.
- AC-CAT-02: User can create custom categories with name, type, group, color, and icon.
- AC-CAT-03: Category selector shows type-appropriate categories (Income categories for income transactions).
- AC-CAT-04: User can edit and delete custom categories.
- AC-CAT-05: User can filter categories by type.

#### 6.3.11 Edge Cases
- User deletes a category used by 100+ transactions — fast deletion without iteration.
- User creates category with same name as a system preset — allowed (custom takes priority in UI).
- User has 200+ categories — search and scroll required.

#### 6.3.12 Dependencies
- None

#### 6.3.13 Future Enhancements
- Category hierarchy (sub-categories with parent)
- Bulk category management (import, export, reorder)
- Category monthly spending limit (integrated with Budgets)
- Category merge (combine two categories, reassign transactions)

---

### 6.4 Transactions

#### 6.4.1 Purpose
Enable users to record all money movements in Personal Finance mode — income received, expenses paid, and transfers between accounts.

#### 6.4.2 Primary Users
Finance mode users

#### 6.4.3 User Stories
- As a user, I want to record income so I know how much I earned.
- As a user, I want to record expenses so I know where my money went.
- As a user, I want to transfer money between accounts so my balances stay correct.
- As a user, I want to view my transaction history with search and filters.
- As a user, I want to create recurring transactions so I don't forget regular bills.

#### 6.4.4 Transaction Types

**Income:**
- Amount (positive)
- Account (credited)
- Category (Income type)
- Date & Time
- Description (optional)
- Payment Method (optional)
- Tags (optional)
- Note (optional)
- Attachment (optional)

**Expense:**
- Amount (positive)
- Account (debited)
- Category (Expense type)
- Date & Time
- Description (optional)
- Payment Method (optional)
- Tags (optional)
- Note (optional)
- Attachment (optional)
- IsPending (boolean — for unsettled transactions)

**Transfer:**
- Amount (positive)
- Source Account (debited)
- Destination Account (credited)
- Date & Time
- Description (optional)
- Exchange Rate (if currencies differ)
- Fee (optional, recorded as expense)
- Note (optional)

#### 6.4.5 Business Rules
- Every transaction is immutable after creation (soft-delete + create approach for edits).
- Income increases account balance; Expense decreases account balance.
- Transfers debit source, credit destination in a single atomic operation.
- Transfer fee is recorded as a separate expense transaction if applicable.
- Recurring transactions generate instances on their schedule until cancelled.
- Transactions can be pending (entered but not yet fully settled).
- Date can be past or present. Future dates require explicit confirmation.
- Tags are free-form text labels, max 10 per transaction.

#### 6.4.6 Validation Rules
- Amount must be > 0.
- Account must exist and not be archived.
- Category must exist and match transaction type (Income category for income).
- Source and destination must differ for transfers.
- For transfers with different currencies, exchange rate > 0 is required.
- Date cannot be in the future without explicit toggle.
- Description max 500 chars.
- Tags max 30 chars each, max 10 tags.

#### 6.4.7 Permissions
- No special permissions.

#### 6.4.8 Offline Behaviour
- Full CRUD available offline.
- Recurring transactions generate locally on schedule (app must be opened).

#### 6.4.9 Future Sync Behaviour
- Transactions sync as atomic units.
- Edits sync as new versions (immutable history).
- Recurring transactions generate independently per device — potential duplicates, requires reconciliation.

#### 6.4.10 Acceptance Criteria
- AC-TXN-01: User can record income with amount, account, category, date, and optional fields.
- AC-TXN-02: User can record expense with same fields plus pending status.
- AC-TXN-03: User can transfer between accounts with optional exchange rate and fee.
- AC-TXN-04: Transaction list shows all transactions with date, description, category, and amount.
- AC-TXN-05: User can filter by date range, account, category, type, and search text.
- AC-TXN-06: Recurring transactions can be created with frequency (daily/weekly/monthly/yearly).
- AC-TXN-07: Editing a transaction preserves an audit trail.

#### 6.4.11 Edge Cases
- User records expense larger than account balance — configurable: warn or block.
- User records income in a different currency than the account — conversion required.
- User edits a transaction — original is preserved as history, new version takes effect.
- User deletes a recurring transaction — future instances are cancelled, past instances remain.
- Recurring transaction generates on a date when the account is archived — generate but flag.
- Transfer fee exceeds transfer amount — warn.

#### 6.4.12 Dependencies
- Accounts module
- Categories module
- Payment Methods module (optional)

#### 6.4.13 Future Enhancements
- Split transaction (one expense split across multiple categories)
- Multi-account split (expense paid from multiple accounts)
- Merchant/store tracking
- Receipt attachment with OCR scanning
- Auto-categorization based on merchant or description history
- Bulk transaction import (CSV, bank export)
- Duplicate transaction detection

#### 6.4.14 Recurring Transactions Specification

**Frequency Options:**
- Daily — every N days
- Weekly — every N weeks on selected days
- Monthly — every N months on selected date
- Yearly — every N years on selected date
- Custom — cron-like expression

**Recurring Transaction Fields:**
- Template (all fields same as Income/Expense, stored as template)
- Frequency
- Interval (every N)
- End condition: Never, After N occurrences, On specific date
- Next generation date
- Auto-generate toggle (if off, user must manually trigger)

**Business Rules:**
- Recurring transactions that miss their generation date (app not opened) generate on next app open.
- Up to 30 days of missed generations are created on next open.
- Users can edit or delete future instances without affecting the template.
- Editing the template asks: "Apply to all future instances?" or "Apply to this instance only."

---

### 6.5 People

#### 6.5.1 Purpose
Maintain a contact directory of individuals and organizations with whom the user has financial relationships.

#### 6.5.2 Primary Users
Ledger mode users

#### 6.5.3 User Stories
- As a user, I want to add people (Customer, Supplier, Friend, Family, Employee, Other) so I can track financial interactions with them.
- As a user, I want to see each person's outstanding balance at a glance.
- As a user, I want to search and filter my people list.
- As a user, I want to view a person's full ledger history.

#### 6.5.4 Person Fields

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| Name | String | Yes | Max 100 chars |
| Type | Enum | Yes | Customer, Supplier, Friend, Family, Employee, Other |
| Phone | String | No | Validated format |
| Email | String | No | Validated format |
| Address | String | No | Max 500 chars |
| Photo | File (image) | No | Stored locally, max 5MB |
| Notes | Text | No | Max 1000 chars |
| Tags | List<String> | No | Max 10 tags, 30 chars each |
| Opening Balance | Decimal | No | Set at creation, editable within grace period |
| Opening Balance Type | Enum | If opening balance set | Give (person owes) or Receive (user owes) |
| Current Balance | Decimal | Computed | Auto-calculated from ledger entries |
| Status | Enum | Yes | Active, Archived |
| Created Date | DateTime | Auto | |
| Updated Date | DateTime | Auto | |

#### 6.5.5 Business Rules
- Person type determines default behavior: Customer (business), Supplier (business), Friend (casual), Family (casual), Employee (salary/advance), Other.
- Current balance is always computed from ledger entries — never manually set (opening balance is the only exception).
- Positive balance = person owes user (user has given more than received by net).
- Negative balance = user owes person (user has received more than given by net).
- Zero balance = settled.
- Deleting a person with outstanding balance greater than zero is BLOCKED — must archive instead.
- Deleting a person with zero balance and no ledger entries is allowed immediately.
- Duplicate names are allowed (e.g., two customers named "Md. Karim") but trigger a confirmation.

#### 6.5.6 Validation Rules
- Name is required.
- Phone, if provided, must match E.164 format or local format with validation per region.
- Email, if provided, must match standard email regex.
- Opening balance cannot be zero if set.
- Opening balance cannot be changed after 24 hours from creation (grace period).

#### 6.5.7 Permissions
- No special permissions.
- Photo access requires device storage/gallery permission (prompted on first attachment).

#### 6.5.8 Offline Behaviour
- Full CRUD available offline.
- Photos stored locally.

#### 6.5.9 Future Sync Behaviour
- People sync as records. Photos sync as attachments.
- Duplicate detection across devices requires server-side matching.

#### 6.5.10 Acceptance Criteria
- AC-PPL-01: User can create a person with name, type, phone, email, address, photo, opening balance.
- AC-PPL-02: Person list shows name, type badge, and outstanding balance.
- AC-PPL-03: User can filter people by type.
- AC-PPL-04: User can search by name, phone, or email.
- AC-PPL-05: User can view a person's detail showing all fields + current balance.
- AC-PPL-06: User can archive and unarchive a person.
- AC-PPL-07: User cannot delete a person with non-zero outstanding balance.

#### 6.5.11 Edge Cases
- User has 500+ people — paginated list with search.
- User adds a person with the same name as an existing person — confirmation dialog: "Add anyway?".
- User deletes a person with opening balance — opening balance entry is also deleted.
- User changes a person's type from Customer to Friend — no data impact, display only.
- Person photo fails to load — show initials avatar as fallback.

#### 6.5.12 Dependencies
- None

#### 6.5.13 Future Enhancements
- Contact import from device address book
- Bulk person management (import from CSV)
- Person groups and labels
- Credit limit per person with alert
- Person activity log (when they were last active)
- GST/TIN/VAT number fields for business persons

---

### 6.6 Ledger

#### 6.6.1 Purpose
Track all financial transactions between the user and another person — giving, receiving, sales, purchases, adjustments, and discounts — maintaining a complete, auditable history.

#### 6.6.2 Primary Users
Ledger mode users

#### 6.6.3 User Stories
- As a user, I want to record money I give to someone (lend, gift, pay) so the ledger is accurate.
- As a user, I want to record money I receive from someone (repayment, collection, gift) so their balance updates.
- As a user, I want to record a sale to a customer or purchase from a supplier.
- As a user, I want to adjust a person's balance (discount, correction, write-off).
- As a user, I want to see the full ledger history with running balance.
- As a user, I want to see who owes me money and who I owe money to.

#### 6.6.4 Ledger Entry Types

**Give Money:**
- Amount (positive)
- Source Account (debited)
- Person (balance increases by amount)
- Type: Loan (expects repayment) or Gift (no repayment expected)
- Due Date (if loan)
- Date & Time
- Description (optional)
- Payment Method (optional)
- Tags (optional)
- Note (optional)
- Attachment (optional)

**Receive Money:**
- Amount (positive)
- Destination Account (credited)
- Person (balance decreases by amount)
- Date & Time
- Description (optional)
- Payment Method (optional)
- Tags (optional)
- Note (optional)
- Attachment (optional)
- Linked Give Entry (optional — for partial/full settlement)

**Sale (to Customer):**
- Amount (positive)
- Person (Customer type, balance increases — they owe the user)
- Items/Services (optional description)
- Date & Time
- Payment Method (optional)
- Note (optional)
- Attachment (optional)

**Purchase (from Supplier):**
- Amount (positive)
- Person (Supplier type, balance increases — user owes them)
- Items/Services (optional description)
- Date & Time
- Payment Method (optional)
- Note (optional)
- Attachment (optional)

**Adjustment:**
- Amount (positive or negative)
- Person (balance adjusted)
- Reason (required — max 200 chars)
- Date & Time
- Note (optional)

**Discount:**
- Amount (positive)
- Person (balance decreases — user writing off part of what they're owed)
- Reason (required)
- Date & Time
- Note (optional)

**Opening Balance:**
- Amount (positive)
- Direction: Give (person owes user) or Receive (user owes person)
- Person
- Date (on or before person creation)
- Note (optional)
- Only settable within 24 hours of person creation (grace period)

**Manual Entry:**
- Any combination of the above fields
- Used when the entry type doesn't fit predefined categories

#### 6.6.5 Business Rules

**Balance Calculation:**
- Outstanding Balance = Sum(Give Amounts) + Sum(Sale Amounts) - Sum(Receive Amounts) - Sum(Purchase Amounts) - Sum(Discount Amounts) +/- Adjustment Amounts + Opening Balance
- Positive = person owes user
- Negative = user owes person

**Core Rules:**
- Every ledger entry affects both the person's outstanding balance AND a user account balance.
- Give Money debits the user's source account and increases the person's outstanding balance.
- Receive Money credits the user's destination account and decreases the person's outstanding balance.
- Sale increases the person's outstanding balance (they owe for goods/services).
- Purchase increases the person's outstanding balance (user owes them for goods/services).
- Discount decreases the person's outstanding balance (write-off).
- Each entry is immutable after creation. Edits create a new entry with an adjustment to correct.
- Linked Receive entries show remaining balance on the original Give entry.

#### 6.6.6 Validation Rules
- Amount must be > 0 (except Adjustment which can be negative).
- Person must exist and not be archived.
- Account must exist and not be archived.
- For Give: source account balance must be >= amount (configurable — warn or block).
- For Receive linked to Give: received amount must not exceed Give's remaining outstanding.
- Due date, if set, must be in the future for reminder activation.
- Reason field is required for Adjustment and Discount entries.

#### 6.6.7 Permissions
- No special permissions.

#### 6.6.8 Offline Behaviour
- Full CRUD available offline.

#### 6.6.9 Future Sync Behaviour
- Ledger entries sync as immutable records with version history.
- Balance computation remains local (always computed, never stored as a synced field).

#### 6.6.10 Acceptance Criteria
- AC-LDG-01: User can Give Money with account, person, amount, type (loan/gift), due date, and note.
- AC-LDG-02: User can Receive Money with account, person, amount, and optional link to Give entry.
- AC-LDG-03: User can record Sale to a customer and Purchase from a supplier.
- AC-LDG-04: User can record Adjustment and Discount entries with reason.
- AC-LDG-05: Person's outstanding balance updates correctly after every entry.
- AC-LDG-06: Ledger history shows all entries with date, type, amount, and running balance.
- AC-LDG-07: User can filter ledger history by entry type.
- AC-LDG-08: Give entries with Loan type show due date and reminder status.

#### 6.6.11 Edge Cases
- User gives money in currency X, receives repayment in currency Y — exchange rate conversion needed.
- User records a Receive that exceeds the person's outstanding balance — excess becomes negative (user now owes the person).
- User records a Give to a person who already has a negative balance (user owed them) — balances net correctly.
- User attempts to delete a Give entry after a partial Receive against it — BLOCKED.
- User records a Sale but later the customer returns goods — record as Receive or Adjustment.
- User wants to write off a bad debt — use Discount entry type.

#### 6.6.12 Dependencies
- People module (required)
- Accounts module (required — for money movement)
- Payment Methods module (optional)

#### 6.6.13 Future Enhancements
- Interest accrual on overdue loans
- Partial settlement with auto-settlement suggestion
- Sale with invoice number tracking
- Purchase order tracking
- Batch ledger entries (create multiple entries at once)
- Ledger entry templates
- Recurring Give (monthly allowance)

---

### 6.7 Payment Methods

#### 6.7.1 Purpose
Manage the mechanisms users employ to transact — applicable to both Personal Finance and Ledger domains.

#### 6.7.2 Primary Users
All users

#### 6.7.3 User Stories
- As a user, I want to select a payment method when recording a transaction so I remember how I paid.
- As a user, I want to add custom payment methods specific to my region.
- As a user, I want to see which payment method I used for past transactions.

#### 6.7.4 System Presets

| Method | Type | Icon | Editable? |
|--------|------|------|-----------|
| Cash | Physical | cash | No |
| Bank Transfer | Electronic | bank | No |
| Credit Card | Card | credit_card | No |
| Debit Card | Card | debit_card | No |
| bKash | Mobile Wallet | bKash-branded | No |
| Nagad | Mobile Wallet | Nagad-branded | No |
| Rocket | Mobile Wallet | Rocket-branded | No |
| Upay | Mobile Wallet | Upay-branded | No |
| Cheque | Instrument | cheque | No |
| Mobile Banking | Electronic | mobile_banking | No |
| Online Transfer | Electronic | online | No |
| Other (custom) | — | other | Yes |

#### 6.7.5 Business Rules
- Payment methods are informational — they have no financial logic.
- System presets cannot be deleted or edited (can be disabled/hidden).
- Users can create, edit, and delete custom payment methods.
- Deleting a payment method nulls the reference on existing transactions (data preserved).
- Payment methods available in both Finance and Ledger entry forms.

#### 6.7.6 Validation Rules
- Custom payment method name is required, max 50 chars.
- Custom payment method names must be unique.

#### 6.7.7 Permissions
- No special permissions.

#### 6.7.8 Offline Behaviour
- Full CRUD available offline.

#### 6.7.9 Future Sync Behaviour
- Custom payment methods sync. System presets are universal.

#### 6.7.10 Acceptance Criteria
- AC-PMT-01: System presets are available on first launch.
- AC-PMT-02: User can add custom payment methods.
- AC-PMT-03: User can edit and delete custom payment methods.
- AC-PMT-04: System presets are not editable or deletable.
- AC-PMT-05: Payment method selector is available in all transaction forms.
- AC-PMT-06: Selected payment method is displayed in transaction detail.

#### 6.7.11 Edge Cases
- User adds "bKash" as a custom method while it's already a preset — show warning.
- User deletes a custom method that is used in 50+ transactions — allowed, reference nulled.
- User wants to reorder payment methods for convenience — future enhancement.

#### 6.7.12 Dependencies
- None

#### 6.7.13 Future Enhancements
- Payment method with account linking (e.g., "bKash" → linked to a specific account)
- Per-method spending reports
- Payment method icons and branding colors
- Payment method popularity sorting

---

### 6.8 Budgets

#### 6.8.1 Purpose
Allow users to set spending limits per category or category group for a defined period and track progress.

#### 6.8.2 Primary Users
Finance mode users

#### 6.8.3 User Stories
- As a user, I want to set a monthly budget for Food so I control dining expenses.
- As a user, I want to see my budget progress visually.
- As a user, I want to get a warning when I'm near my limit.

#### 6.8.4 Business Rules
- Budgets are defined per category or per category group.
- Budget period: Weekly, Monthly, Yearly, or Custom date range.
- Budget progress = sum of expenses in the matching categories within the period.
- Budget can be a spending limit (cap) or a savings target (floor).
- Multiple budgets can overlap (e.g., monthly Food budget + quarterly Dining Out budget).
- Overlapping budgets calculate independently.
- Budget resets at period boundary automatically.
- Budget does NOT block transactions — it tracks and warns.

#### 6.8.5 Validation Rules
- Budget amount must be > 0.
- Period end must be after period start.
- At least one category or category group must be selected.
- Budget name is required (auto-generated if not provided: "Food — Monthly").

#### 6.8.6 Permissions
- No special permissions.

#### 6.8.7 Offline Behaviour
- Full CRUD available offline.
- Budget progress calculated from local data.

#### 6.8.8 Future Sync Behaviour
- Budgets sync. Budget progress is computed locally.

#### 6.8.9 Acceptance Criteria
- AC-BGT-01: User can create a budget with amount, period, categories, and name.
- AC-BGT-02: Budget progress is shown with a progress bar and percentage.
- AC-BGT-03: Budget shows remaining (or overspent) amount.
- AC-BGT-04: Budget resets at period end.
- AC-BGT-05: User receives notification at 80%, 90%, 100% of budget.

#### 6.8.10 Edge Cases
- User exceeds budget — budget shows overspent in red, transactions continue.
- User changes a category mid-period — budget recalculates from the beginning of the period.
- User deletes a category that has a budget — budget is orphaned, flagged in budget list.
- Budget period is in the past — warn when creating.
- User has 20+ budgets — list view with summary cards, expand to detail.

#### 6.8.11 Dependencies
- Categories module
- Transactions module (for progress calculation)

#### 6.8.12 Future Enhancements
- Rollover budget (unused amount carries to next period)
- Annual budget with monthly breakdown
- Budget templates (predefined sets)
- Budget vs. actual report
- AI-powered budget suggestions based on spending history

---

### 6.9 Savings Goals

#### 6.9.1 Purpose
Enable users to define financial targets, allocate funds, and track progress toward specific goals.

#### 6.9.2 Primary Users
Finance mode users

#### 6.9.3 User Stories
- As a user, I want to create a savings goal so I can save for something specific.
- As a user, I want to allocate money from my accounts to a goal.
- As a user, I want to see my progress visually.

#### 6.9.4 Business Rules
- Each goal has: name, target amount, current amount, optional deadline, source account, and status.
- Goal progress updates when user allocates funds (manual one-time or recurring).
- Allocating funds to a goal deducts from the source account balance.
- Goals have status: Active, Completed, Cancelled.
- Completed goals are moved to archive.
- Cancelled goals refund allocated amounts to source accounts.

#### 6.9.5 Validation Rules
- Goal name is required.
- Target amount must be > 0.
- Allocation amount must be > 0 and <= source account balance.
- Deadline, if set, must be in the future.
- Source account must exist and not be archived.

#### 6.9.6 Permissions
- No special permissions.

#### 6.9.7 Offline Behaviour
- Full CRUD available offline.

#### 6.9.8 Future Sync Behaviour
- Goals sync as records. Progress is computed locally.

#### 6.9.9 Acceptance Criteria
- AC-GOA-01: User can create a goal with name, target, deadline (optional), and source account.
- AC-GOA-02: User can allocate funds to a goal.
- AC-GOA-03: Goal progress shows as percentage and amount.
- AC-GOA-04: Allocating funds deducts from account balance.
- AC-GOA-05: User can complete, reopen, or cancel a goal.
- AC-GOA-06: Completed goals appear in archive view.

#### 6.9.10 Edge Cases
- User reaches goal early — marked complete, user can set new target.
- User needs to withdraw from a goal (emergency) — allowed, logged as "withdrawal".
- Goal with no deadline — open-ended, no time pressure.
- User changes target after allocations — progress recalculates.
- User cancels a goal — all allocated amounts are refunded to source account.

#### 6.9.11 Dependencies
- Accounts module (for allocation deduction)

#### 6.9.12 Future Enhancements
- Recurring automatic allocations (daily/weekly/monthly)
- Goal progress notifications
- Goal-linked sub-accounts (envelope style)
- Multiple source accounts per goal
- Goal sharing (couples saving together)

---

### 6.10 Reports

#### 6.10.1 Purpose
Provide users with visual and tabular summaries of their financial data for understanding, planning, and decision-making.

#### 6.10.2 Primary Users
All users

#### 6.10.3 User Stories
- As a user, I want to see my spending by category so I know where my money goes.
- As a user, I want to see income vs. expenses over time so I understand my cash flow.
- As a user, I want to see my net worth trend.
- As a user, I want to see a person's complete statement.
- As a user, I want to share reports with others.

#### 6.10.4 Report Types

**Personal Finance Reports:**

| Report | Type | Description |
|--------|------|-------------|
| Spending by Category | Chart (pie/bar) | Expense breakdown by category for selected period |
| Income vs. Expense | Chart (bar) | Monthly comparison of total income and expenses |
| Net Worth | Chart (line) | Total assets minus total liabilities over time |
| Cash Flow | Table | Itemized inflows and outflows in selected period |
| Budget vs. Actual | Chart (bar) | Budgeted amount vs. actual spending per category |
| Monthly Summary | Card | Income total, expense total, net, top categories |
| Category Summary | Table | Per-category totals in selected period |
| Account Summary | Table | Per-account balances and activity |

**Ledger Reports:**

| Report | Type | Description |
|--------|------|-------------|
| Outstanding Summary | Table | All people with outstanding balance, sorted |
| Person Statement | Document | Full ledger history for one person |
| Monthly Ledger Summary | Table | Give/Receive totals by month |
| Net Position | Card | Total owed to user vs. total user owes |
| Person Activity | Table | Most active people by transaction count |

#### 6.10.5 Business Rules
- Reports are read-only views computed from transaction and ledger data.
- All reports support a configurable date range.
- Reports are generated locally — no data leaves the device.
- Reports can be filtered by account, category, person, or domain.
- Reports with zero data show empty state, not errors.

#### 6.10.6 Validation Rules
- Date range end must be >= start.
- Cannot generate reports for periods before the first data entry.
- Reports with filters that return no results show empty state.

#### 6.10.7 Permissions
- No special permissions.

#### 6.10.8 Offline Behaviour
- All reports generated from local data. Fully offline.

#### 6.10.9 Future Sync Behaviour
- Reports remain locally computed. Sync does not change report logic.

#### 6.10.10 Acceptance Criteria
- AC-RPT-01: User can view Spending by Category report with date range selector.
- AC-RPT-02: User can view Income vs. Expense report.
- AC-RPT-03: User can view Net Worth trend.
- AC-RPT-04: User can view Outstanding Summary (all people with balances).
- AC-RPT-05: User can generate a Person Statement with full history.
- AC-RPT-06: Reports show appropriate empty states when no data.
- AC-RPT-07: Reports can be shared (exported as image or PDF).

#### 6.10.11 Edge Cases
- User has accounts in multiple currencies — each account's data shown in its own currency; totals require base currency selection.
- Report period spans 10 years — optimize for performance with aggregation.
- User has 200+ categories — show top 10 with "Other" grouping.
- User archives all accounts — report shows no data with guidance to unarchive.
- User has 500+ people in Outstanding Summary — show top 20 with "View All".

#### 6.10.12 Dependencies
- Transactions module (for finance reports)
- Ledger module (for ledger reports)
- Accounts module (for account data)
- Categories module (for category grouping)

#### 6.10.13 Future Enhancements
- PDF export with professional formatting
- CSV export for Excel/Google Sheets
- Scheduled report generation (email or notification)
- Comparative periods (this month vs. last month)
- Spending insights and anomaly detection
- Custom report builder (select metrics, dimensions, filters)

---

### 6.11 Search

#### 6.11.1 Purpose
Provide a unified search experience across both Personal Finance and Ledger domains.

#### 6.11.2 Primary Users
All users

#### 6.11.3 User Stories
- As a user, I want to search across all my data by keyword.
- As a user, I want to filter results by domain (Finance vs. Ledger).
- As a user, I want to search by amount, date, person name, or category.

#### 6.11.4 Business Rules
- Search indexes: transaction descriptions, amounts, dates, category names, account names, person names, notes, tags, payment methods.
- Results are grouped by domain and type.
- Search is case-insensitive and locale-aware.
- Search is performed locally (no network required).
- Recent searches are saved (max 10, persisted locally).
- Search query must be at least 2 characters.

#### 6.11.5 Validation Rules
- Query < 2 characters returns no results (no search performed).
- Empty or whitespace-only queries return no results.

#### 6.11.6 Permissions
- No special permissions.

#### 6.11.7 Offline Behaviour
- Full search available offline.

#### 6.11.8 Future Sync Behaviour
- Search remains local. No change.

#### 6.11.9 Acceptance Criteria
- AC-SRC-01: Search returns matching results from both Finance and Ledger.
- AC-SRC-02: Results are grouped (Transactions, People, Ledger Entries).
- AC-SRC-03: User can filter by domain.
- AC-SRC-04: Tapping a result navigates to detail view.
- AC-SRC-05: Search completes within 500ms for 10K entries.
- AC-SRC-06: Recent searches are shown when search bar is focused.

#### 6.11.10 Edge Cases
- User searches in Bengali script — Unicode-aware matching required.
- User searches "500" — matches transactions with amount 500, descriptions containing "500", etc.
- User has 50K entries — search must use indexed query, not full scan.
- User searches while a transaction is being added (form open) — search continues to work.

#### 6.11.11 Dependencies
- Transactions module
- Ledger module
- People module

#### 6.11.12 Future Enhancements
- Full-text search with fuzzy matching
- Search by tag, custom label, payment method
- Voice search
- Saved searches and search history management
- Search within a specific person's ledger

---

### 6.12 Backup & Restore

#### 6.12.1 Purpose
Protect user data through local backups and enable restoration when needed.

#### 6.12.2 Primary Users
All users

#### 6.12.3 User Stories
- As a user, I want to create a backup so I don't lose my data.
- As a user, I want to restore from a backup after switching devices or data loss.

#### 6.12.4 Business Rules
- Backup file is created on device storage at user-selected location.
- Backup includes all data: accounts, transactions, categories, budgets, goals, people, ledger entries, payment methods, settings.
- Backup does NOT include: theme preferences, notification preferences, session data.
- Backup file is encrypted with AES-256 using a device-derived key.
- Restore replaces ALL current data (destructive operation).
- Restore requires: explicit user confirmation, warning about data loss, and integrity verification.
- Backup is manual-only in MVP. Auto-backup is a future enhancement.

#### 6.12.5 Validation Rules
- Backup file must be from a compatible schema version (major.minor match).
- Backup file integrity is verified via checksum before restore.
- Restore is blocked if backup file is corrupted.
- Restore rolls back to previous state if it fails midway.

#### 6.12.6 Permissions
- Storage write permission required for backup.
- Storage read permission required for restore.

#### 6.12.7 Offline Behaviour
- Backup and restore work fully offline.

#### 6.12.8 Future Sync Behaviour
- Backup can be stored in cloud-synced folder (Drive, iCloud) for cross-device restore.
- Cloud backup is a future enhancement.

#### 6.12.9 Acceptance Criteria
- AC-BAK-01: User can create a backup with one tap.
- AC-BAK-02: Backup file is saved at user's chosen location.
- AC-BAK-03: User can restore from a valid backup file.
- AC-BAK-04: Restore shows progress with status updates.
- AC-BAK-05: Backup file integrity is verified before restore.
- AC-BAK-06: Data integrity is verified after restore.

#### 6.12.10 Edge Cases
- User restores from a newer version backup — show incompatibility warning.
- Backup file is corrupted — error message with suggestion to use an older backup.
- User has 100K+ entries — backup may take 30+ seconds; progress indicator required.
- User stores backup in cloud-synced folder — works but may have sync latency.
- Restore fails at 80% — database rolls back to previous state automatically.
- User creates backup, then restores it on the same device (duplicate data) — allowed.

#### 6.12.11 Dependencies
- All data modules (backup scope)

#### 6.12.12 Future Enhancements
- Automatic scheduled backups (daily/weekly)
- Cloud backup to user's Drive/iCloud
- Incremental backups (only changed data since last full backup)
- Selective restore (restore only accounts, only transactions, etc.)
- Encrypted backup with user-provided password
- Export as CSV/PDF alongside backup

---

### 6.13 Settings

#### 6.13.1 Purpose
Allow users to configure application behavior, preferences, and view app information.

#### 6.13.2 Primary Users
All users

#### 6.13.3 User Stories
- As a user, I want to set my base currency.
- As a user, I want to configure the app theme.
- As a user, I want to manage notification preferences.
- As a user, I want to view app version and licenses.

#### 6.13.4 Settings Categories

**1. General**
- Base Currency (default: USD, select from ISO 4217 list)
- Default Account for new transactions
- Number Format (locale-specific: 1,234.56 vs 1.234,56)
- First Day of Week (Sunday, Monday, Saturday)

**2. Appearance**
- Theme: System, Light, Dark
- Color Scheme (seed color picker from Material 3 palette)
- Font Size: Small, Medium, Large
- Currency Symbol Position: Before Amount ($10) or After Amount (10$)

**3. Transactions**
- Allow Negative Balances: Warn or Block
- Default Transaction Type: Income or Expense
- Default Payment Method
- Enable Pending Transactions

**4. Ledger**
- Default Ledger Entry Type: Loan or Gift
- Reminder Default Time (for due dates, default: 9:00 AM)
- Enable Opening Balance Grace Period (24h default)
- Block Delete with Outstanding Balance (on/off)

**5. Notifications**
- Per-type toggle (see Notifications module)

**6. Backup & Data**
- Create Backup
- Restore from Backup
- Export All Data (future)
- Clear All Data (with confirmation)

**7. About**
- App Version and Build Number
- Open Source Licenses
- Privacy Policy (static page)
- Terms of Service (static page)
- Rate the App

#### 6.13.5 Validation Rules
- Base currency must be valid ISO 4217.
- Default account must exist (null if no accounts).
- Settings changes take effect immediately (no restart).

#### 6.13.6 Permissions
- No special permissions required.

#### 6.13.7 Offline Behaviour
- All settings work offline.

#### 6.13.8 Future Sync Behaviour
- Settings sync across devices (theme, currency, preferences).
- Backup/restore settings do not sync.

#### 6.13.9 Acceptance Criteria
- AC-SET-01: All settings categories are accessible from a single Settings screen.
- AC-SET-02: Changes persist across app restarts.
- AC-SET-03: Theme changes take effect immediately.
- AC-SET-04: Currency changes affect new transactions (existing data unchanged).
- AC-SET-05: App version and build number display correctly.
- AC-SET-06: "Clear All Data" shows double confirmation.

#### 6.13.10 Edge Cases
- User changes base currency — existing transactions retain original currency.
- User deletes the default account — default resets to null (user must set new).
- User resets settings to defaults — confirmation required before reset.
- User clears app data from device settings — all data and settings lost irrecoverably.

#### 6.13.11 Dependencies
- Accounts module (default account)
- Notifications module (preferences)

#### 6.13.12 Future Enhancements
- Import/export settings
- User profile (name, photo)
- App lock with PIN/biometric
- Advanced settings (developer options, debug mode)

---

### 6.14 Notifications

#### 6.14.1 Purpose
Keep users informed of important events — payment reminders, budget alerts, goal achievements, and backup prompts.

#### 6.14.2 Primary Users
All users

#### 6.14.3 User Stories
- As a user, I want to receive a notification when a loan repayment is due.
- As a user, I want to be warned when I'm approaching my budget limit.
- As a user, I want to know when I achieve a savings goal.

#### 6.14.4 Notification Types

| Type | Trigger | Content | Frequency |
|------|---------|---------|-----------|
| Payment Reminder | Due date of a Loan Give entry | "Reminder: Tk 5,000 due to you from Rafiq by July 25" | At due date, repeat every N days if unsettled |
| Budget Alert | Spending reaches 80%, 90%, 100% of budget | "You've used 80% of your Food budget (Tk 8,000 of Tk 10,000)" | Once per threshold per period |
| Goal Achievement | Goal.current >= Goal.target | "Congratulations! You saved Tk 50,000 for Emergency Fund!" | Once |
| Backup Reminder | 7 days since last backup | "It's been 7 days since your last backup" | Every 7 days until backup created |
| Settlement Alert | Person balance reaches zero | "Settled up! Rafiq's balance is now zero" | Once |
| Overspend Alert | Transaction exceeds account balance (if set to warn) | "This expense exceeds your Bank Account balance by Tk 2,000" | Per transaction |

#### 6.14.5 Business Rules
- Notifications are local-only (no push server).
- Each notification type can be independently enabled/disabled in Settings.
- Notifications respect device-level notification settings (DND, etc.).
- Tapping a notification navigates to the relevant screen.
- Multiple notifications of the same type are grouped.

#### 6.14.6 Validation Rules
- Notification preferences are persisted locally.
- Disabled notification types do not fire.

#### 6.14.7 Permissions
- Local notification permission required (requested on first relevant action).

#### 6.14.8 Offline Behaviour
- Notifications are local-only; fully offline.

#### 6.14.9 Future Sync Behaviour
- Notification preferences sync, but notifications themselves remain local.

#### 6.14.10 Acceptance Criteria
- AC-NOT-01: Payment reminders fire at the scheduled date and time.
- AC-NOT-02: Budget alerts fire at 80%, 90%, and 100%.
- AC-NOT-03: Goal achievement notification fires once when target is reached.
- AC-NOT-04: Tapping a notification navigates to the correct screen.
- AC-NOT-05: Notification preferences are respected.

#### 6.14.11 Edge Cases
- User has 10+ reminders due on the same day — group into one summary notification.
- User clears a reminder but hasn't been repaid — reminder can be re-enabled.
- Reminder fires when app is closed — stored as local notification, shown on next open.
- User disables all notifications — no alerts, no badge.
- Recurring reminder for a loan that is fully repaid — auto-cancels.

#### 6.14.12 Dependencies
- Ledger module (for payment reminders)
- Budgets module (for budget alerts)
- Savings Goals module (for goal achievements)

#### 6.14.13 Future Enhancements
- Rich notifications with action buttons ("Mark as Paid", "Snooze")
- Weekly summary notification
- Notification history view
- Quiet hours configuration

---

### 6.15 Share & Export

#### 6.15.1 Purpose
Allow users to share financial information — ledger statements, reports, summaries — with others via messaging apps, email, or print.

#### 6.15.2 Primary Users
Ledger users (primary), Finance users (secondary)

#### 6.15.3 User Stories
- As a user, I want to share a person's outstanding balance via WhatsApp so they know what they owe.
- As a user, I want to generate a PDF statement for a customer.
- As a user, I want to export my monthly report for record-keeping.

#### 6.15.4 Share Formats

| Format | Use Case | Platforms |
|--------|----------|-----------|
| Text Summary | Quick balance share | WhatsApp, Messenger, Telegram, SMS |
| Image (PNG) | Visual report share | All platforms |
| PDF Statement | Formal statement | Email, Print, Save to Files |
| CSV Export | Data portability | Email, Save to Files |

#### 6.15.5 Share Channels (via native share sheet)

- WhatsApp
- WhatsApp Business
- Messenger
- Telegram
- Email
- SMS/MMS
- Print (AirPrint/HP Print)
- Save to Files
- Copy to Clipboard
- Any installed app that accepts text/images/PDFs

#### 6.15.6 Business Rules
- Statement content: person name, outstanding balance, entry list (date, type, amount, running balance).
- Statements do NOT include the user's account balances or other people's data.
- Reports include only the data visible in the report (no private data leaked).
- Generated files are temporary and stored in app cache (not persisted).
- CSV export includes all transaction/ledger data in flat table format.

#### 6.15.7 Validation Rules
- Empty statements (no entries) are not shareable.
- Person must not be archived for statement generation.

#### 6.15.8 Permissions
- No special permissions (uses native share sheet).

#### 6.15.9 Offline Behaviour
- Share sheet works offline. Content generation is local.
- Messaging apps may require internet to send.

#### 6.15.10 Future Sync Behaviour
- No change.

#### 6.15.11 Acceptance Criteria
- AC-SHR-01: User can share a person's outstanding balance as text via any messaging app.
- AC-SHR-02: User can generate and share a PDF statement.
- AC-SHR-03: User can export a report as image.
- AC-SHR-04: User can export data as CSV.
- AC-SHR-05: Shared content is formatted cleanly and professionally.

#### 6.15.12 Edge Cases
- User has no sharing apps installed — show "Save to Files" only.
- Statement has 500+ entries — PDF automatically paginates.
- User shares to WhatsApp but message fails — fallback to "Save to Files".
- Statement contains emoji or non-Latin text — renders correctly in PDF.

#### 6.15.13 Dependencies
- Ledger module (for statements)
- Reports module (for report export)

#### 6.15.14 Future Enhancements
- Direct WhatsApp API integration (skip share sheet)
- Branded statements with logo and colors
- Digital signature on statements
- Auto-share on settlement (trigger: send statement when balance reaches zero)
- Scheduled statement delivery

---

## 7. Database Design

### 7.1 Entity-Relationship Diagram (Textual)

```
┌──────────────────┐       ┌──────────────────────┐
│    Account       │       │     Category          │
├──────────────────┤       ├──────────────────────┤
│ id (PK)          │       │ id (PK)               │
│ name (UQ, IX)    │       │ name (UQ, IX)         │
│ type (enum)      │       │ type (income/expense) │
│ currency         │       │ group (enum)          │
│ balance          │       │ icon                  │
│ icon             │       │ color                 │
│ color            │       │ isPreset              │
│ description      │       │ isArchived            │
│ isArchived       │       │ createdAt             │
│ createdAt (IX)   │       │ updatedAt             │
│ updatedAt        │       └──────────────────────┘
└───────┬──────────┘
        │ 1
        │
        │ *
┌───────┴──────────────────────────────────────┐
│           Transaction                         │
├──────────────────────────────────────────────┤
│ id (PK)                                       │
│ accountId (FK → Account.id) (IX)              │
│ categoryId (FK → Category.id, nullable) (IX)  │
│ type (income/expense/transfer)                │
│ amount                                        │
│ currency                                      │
│ description                                   │
│ date                                          │
│ isPending                                     │
│ tags                                          │
│ paymentMethodId (FK → PaymentMethod.id)       │
│ transferToAccountId (nullable)                │
│ exchangeRate (nullable)                       │
│ fee (nullable)                                │
│ isRecurring                                   │
│ recurringTemplateId (nullable)                │
│ note                                          │
│ createdAt (IX)                                │
│ updatedAt                                     │
└──────────────────────────────────────────────┘

┌──────────────────┐       ┌──────────────────────┐
│     Person       │       │   LedgerEntry         │
├──────────────────┤       ├──────────────────────┤
│ id (PK)          │──1   *│ id (PK)               │
│ name (IX)        │       │ personId (FK → Person.id) (IX) │
│ type (enum)      │       │ accountId (FK → Account.id)     │
│ phone            │       │ type (give/receive/sale/       │
│ email            │       │       purchase/adjustment/     │
│ address          │       │       discount/opening)        │
│ photoPath        │       │ amount                          │
│ notes            │       │ direction (in/out)              │
│ tags             │       │ date                           │
│ openingBalance   │       │ description                    │
│ openingType      │       │ paymentMethodId (FK, nullable) │
│ status (enum)    │       │ linkedEntryId (self-ref, null) │
│ createdAt (IX)   │       │ dueDate (nullable)             │
│ updatedAt        │       │ note                           │
└──────────────────┘       │ tags                           │
                            │ attachmentPaths                │
                            │ runningBalance (computed)      │
                            │ createdAt (IX)                 │
                            │ updatedAt                      │
                            └──────────────────────────────┘

┌──────────────────────┐    ┌──────────────────────┐
│   Budget              │    │   SavingsGoal         │
├──────────────────────┤    ├──────────────────────┤
│ id (PK)               │    │ id (PK)               │
│ name                  │    │ name                  │
│ amount                │    │ targetAmount          │
│ period (weekly/       │    │ currentAmount         │
│   monthly/yearly)     │    │ deadline (nullable)   │
│ startDate             │    │ accountId (FK)        │
│ endDate               │    │ status (active/       │
│ categoryIds (JSON)    │    │   completed/cancelled)│
│ type (cap/target)     │    │ icon                  │
│ createdAt             │    │ color                 │
│ updatedAt             │    │ createdAt (IX)        │
└──────────────────────┘    │ updatedAt             │
                            └──────────────────────┘

┌──────────────────────┐    ┌──────────────────────┐
│  PaymentMethod        │    │  RecurringTemplate    │
├──────────────────────┤    ├──────────────────────┤
│ id (PK)               │    │ id (PK)               │
│ name                  │    │ type (income/expense) │
│ type (preset/custom)  │    │ accountId (FK)        │
│ icon                  │    │ categoryId (FK)       │
│ isEnabled             │    │ amount                │
└──────────────────────┘    │ frequency             │
                            │ interval              │
                            │ endCondition          │
                            │ endValue              │
                            │ nextDate              │
                            │ isActive              │
                            │ createdAt             │
                            │ updatedAt             │
                            └──────────────────────┘

┌──────────────────────┐    ┌──────────────────────┐
│  NotificationPref     │    │  AppSettings          │
├──────────────────────┤    ├──────────────────────┤
│ type (enum)           │    │ key (PK)              │
│ isEnabled             │    │ value                 │
│ updatedAt             │    │ updatedAt             │
└──────────────────────┘    └──────────────────────┘
```

### 7.2 Indexes

| Table | Index | Type | Fields |
|-------|-------|------|--------|
| Account | idx_account_name | Unique | name (case-insensitive) |
| Account | idx_account_createdAt | Standard | createdAt |
| Category | idx_category_name | Unique | name (case-insensitive) |
| Transaction | idx_txn_accountId | Standard | accountId |
| Transaction | idx_txn_categoryId | Standard | categoryId |
| Transaction | idx_txn_date | Standard | date |
| Transaction | idx_txn_createdAt | Standard | createdAt |
| Transaction | idx_txn_type | Standard | type |
| Person | idx_person_name | Standard | name |
| Person | idx_person_type | Standard | type |
| Person | idx_person_createdAt | Standard | createdAt |
| LedgerEntry | idx_ledger_personId | Standard | personId |
| LedgerEntry | idx_ledger_accountId | Standard | accountId |
| LedgerEntry | idx_ledger_date | Standard | date |
| LedgerEntry | idx_ledger_type | Standard | type |
| LedgerEntry | idx_ledger_createdAt | Standard | createdAt |
| Budget | idx_budget_period | Standard | startDate, endDate |
| SavingsGoal | idx_goal_createdAt | Standard | createdAt |
| SavingsGoal | idx_goal_status | Standard | status |

### 7.3 Constraints

**Referential Integrity:**
- Transaction.accountId → Account.id (CASCADE on delete — account deletion deletes transactions)
- Transaction.categoryId → Category.id (SET NULL on delete)
- LedgerEntry.personId → Person.id (RESTRICT on delete if non-zero balance)
- LedgerEntry.accountId → Account.id (CASCADE on delete)
- SavingsGoal.accountId → Account.id (CASCADE on delete)
- LedgerEntry.linkedEntryId → LedgerEntry.id (SET NULL on delete)

**Business Constraints:**
- Account.name UNIQUE (case-insensitive)
- Category.name + Category.type UNIQUE (case-insensitive within type)
- LedgerEntry.amount > 0
- Budget.amount > 0
- SavingsGoal.targetAmount > 0
- Person.openingBalance != 0 (if set)

### 7.4 Migration Strategy

**Version 1 (MVP):**
- Initial schema as defined above.
- Schema version: 1.
- Migration: None (fresh install).

**Version 2+ Future:**
- Migration file: `migrations/v1_to_v2.dart`
- Each migration is a class with `up()` and `down()` methods.
- Migration is applied at database open time.
- Migration failure rolls back and shows error (do not open with partial migration).
- Schema version is stored in a dedicated `_schema_version` key in settings.

**Rules:**
- NEVER delete a column that might have user data.
- Adding nullable columns is safe and non-breaking.
- Adding non-nullable columns requires a default value or migration.
- Renaming columns requires a migration with data copy.
- Index changes are applied in migration without data loss.

### 7.5 Financial Amount Handling

- Amounts are stored as integers representing the smallest currency unit (e.g., cents, paisa).
- Display values are computed by dividing by 100 (for 2-decimal currencies) or appropriate divisor.
- This avoids floating-point precision issues.
- The database stores `amount` as an integer (signed 64-bit).
- Max representable value: ~9.2 × 10¹⁸ smallest units ≈ ~9.2 × 10¹⁶ USD — sufficient for any personal/ledger use.

---

## 8. UX & Navigation

### 8.1 Navigation Structure

```
App Launch
  │
  ▼
[Splash Screen] ──(500ms, animated)──► [Dashboard]
                                          │
                          ┌───────────────┼───────────────────┐
                          │               │                   │
                          ▼               ▼                   ▼
                    [Accounts]      [Transactions]       [People]
                          │               │                   │
                          ▼               ▼                   ▼
                    Account List    Transaction List      People List
                          │               │                   │
                          ▼               ▼                   ▼
                    Account Detail  Transaction Detail   Person Detail
                                                               │
                                                               ▼
                                                         Ledger History
                                                               │
                                                    ┌──────────┼──────────┐
                                                    ▼          ▼          ▼
                                                Give Money  Receive    Statement
                                                            Money      Share
```

### 8.2 Screen Hierarchy

**Level 1 — Shell (Bottom Navigation):**
1. Dashboard (Home)
2. Accounts
3. Transactions
4. People (Ledger)
5. More (Reports, Budgets, Goals, Settings, etc.)

**Level 2 — Detail Screens:**
- Account Detail (transaction list filtered by account)
- Transaction Detail (full transaction view)
- Person Detail (person info + ledger history)
- Category List
- Budget List
- Goals List

**Level 3 — Form Screens (Bottom Sheets):**
- Create/Edit Account
- Add Income
- Add Expense
- Add Transfer
- Add Person
- Give Money
- Receive Money
- Sale/Purchase
- Adjustment/Discount
- Create/Edit Budget
- Create/Edit Goal

**Level 4 — Read-only Screens:**
- Reports
- Person Statement
- Search Results
- Settings
- About

### 8.3 User Journey — New User Onboarding

1. User opens app → Splash screen (brand animation, 500ms)
2. → Dashboard (empty state)
3. Dashboard shows "Create your first account to get started" + CTA button
4. User taps "Create Account" → Account form (bottom sheet)
5. User fills name, type, balance, currency → saves
6. → Dashboard now shows balance card + "Add your first transaction" prompt
7. User taps "Add Income" → Income form
8. → Dashboard shows balance + recent transaction
9. User explores other tabs naturally

### 8.4 User Journey — Ledger User

1. User opens app → Dashboard
2. Taps "People" tab → Empty state
3. "Add your first person" → Person form
4. Fill name, type (Customer), optional phone
5. Optionally set opening balance → saves
6. → People list shows person with balance
7. Tap person → Person Detail → Ledger History (empty)
8. "Give Money" → Give form → person, account, amount, note → save
9. → Ledger history shows entry with running balance
10. → Dashboard ledger card updates

### 8.5 Information Architecture

```
/paysa
├── /accounts
│   ├── /list
│   ├── /{id}
│   └── /new
├── /transactions
│   ├── /list
│   ├── /{id}
│   ├── /income/new
│   ├── /expense/new
│   └── /transfer/new
├── /people
│   ├── /list
│   ├── /{id}
│   │   ├── /ledger
│   │   │   ├── /give/new
│   │   │   └── /receive/new
│   │   └── /statement
│   └── /new
├── /categories
├── /budgets
├── /goals
├── /reports
│   ├── /spending-by-category
│   ├── /income-vs-expense
│   ├── /net-worth
│   ├── /cash-flow
│   └── /budget-vs-actual
├── /search
└── /settings
```

### 8.6 Key UX Principles

- **Bottom sheet forms** — All creation/editing happens in modal bottom sheets, never full-screen navigation. This keeps context, enables quick entry, and supports one-handed use.
- **Floating action button** — Each list screen has a FAB for the primary creation action.
- **Swipe actions** — Swipe left on list items for quick actions (delete, archive, mark paid).
- **Pull to refresh** — All list screens support pull-to-refresh.
- **Empty states** — Every list screen has a thoughtful empty state with icon, message, and action.
- **Snackbar feedback** — All mutations show brief snackbar confirmation.
- **Numeric keypad** — Amount fields default to numeric keypad with decimal support.
- **Date presets** — Date fields offer presets: Today, Yesterday, This Week, This Month, Custom.

---

## 9. Design System

### 9.1 Design Philosophy

Material 3 with customization for a professional, trustworthy finance app. The design communicates reliability, clarity, and calm — not excitement or urgency.

### 9.2 Brand

- **Name:** Paysa
- **Seed color:** #0F766E (Teal) — conveys trust, stability, growth
- **Typography:** System default (Roboto on Android, SF Pro on iOS) — no custom fonts for performance
- **Icon style:** Material Symbols (outlined variant for navigation, filled for active state)

### 9.3 Color System

**Seed color:** #0F766E

**Generated Material 3 palettes:**
- Primary: Teal (from seed)
- Secondary: Complementary (auto-generated from seed)
- Tertiary: Contrast (auto-generated from seed)
- Error: Red
- Neutral: Surface tones

**Functional colors:**
- Income/Positive: Green (#16A34A)
- Expense/Negative: Red (#DC2626)
- Pending: Amber (#D97706)
- Loan due warning: Orange (#EA580C)
- User gives money: Red (outgoing)
- User receives money: Green (incoming)

### 9.4 Typography

- Headlines: `titleLarge` for screen titles, `headlineMedium` for balance displays
- Body: `bodyLarge` for list items, `bodyMedium` for descriptions, `bodySmall` for metadata
- Monetary amounts: `headlineMedium` for large balance, `titleMedium` for transaction amounts
- Tab labels: `labelMedium` all caps
- Button labels: `labelLarge`

### 9.5 Spacing Scale

```
4px  → XS
8px  → Sm
12px → Md
16px → Lg
24px → XL
32px → XXL
```

### 9.6 Component Library

| Component | Description |
|-----------|-------------|
| AppBar | Material 3, elevated for scroll, transparent for dashboard |
| Bottom Nav | 5 items, fixed, with badge support |
| FAB | Standard, small variant for secondary actions |
| Card | Elevated for balance cards, filled for list items |
| List Tile | Standard with leading icon, title, trailing amount |
| Bottom Sheet | Modal, scrollable, drag handle, for all forms |
| Dialog | Alert for confirmations, simple for selection |
| Snackbar | For mutation feedback, 4-second duration |
| Chip | Filter chips for lists, choice chips for form selection |
| Segmented Button | For transaction type (Income/Expense) |
| Progress Bar | Linear for budget and goal progress |
| Empty State | Centered illustration + message + action |
| Loading | Shimmer placeholder for initial loads |
| Amount Text | Special formatting with currency, color, sign |

### 9.7 Responsive Behavior

- **Phone (<600dp):** Single column, bottom sheets, full-width lists.
- **Tablet (600-840dp):** Two-column master-detail on applicable screens (accounts, people, transactions).
- **Large Tablet (>840dp):** Multi-column layouts, side panel navigation option.
- **Landscape:** Optimized layout, wider forms, side-by-side reports.

### 9.8 Dark Mode

- Full Material 3 dark mode support.
- Dark mode uses the same seed color but adjusts surface tones.
- Balance colors (green/red) maintain contrast ratio in dark mode.
- Charts use darker backgrounds with brighter data colors.
- No custom dark mode configuration required from user (follows system).

### 9.9 Accessibility

- Minimum touch target: 48dp (Material 3 default).
- All icons accompanied by text labels.
- Sufficient color contrast (WCAG AA minimum).
- Screen reader support for all data displays (content descriptions).
- Font scaling support (system font size settings respected).
- Reduced motion option respected for animations.

---

## 10. Security & Privacy

### 10.1 Data Storage

- All data stored locally on-device using Isar database (encrypted at rest via platform-level encryption).
- No data is sent to any server.
- No analytics, no telemetry, no crash reporting without user consent.
- Backup files are encrypted with AES-256-GCM.

### 10.2 App Lock (Future)

- Optional PIN or biometric (fingerprint/face) lock on app launch.
- Configurable lock timeout (immediate, 1 minute, 5 minutes, 15 minutes).
- App content hidden in app switcher when lock is enabled.

### 10.3 Backup Security

- Backup files encrypted with device-derived key.
- User can optionally set a custom password for backup encryption.
- Restore requires decryption with the same key/password.

### 10.4 Sharing Security

- Statement sharing sends only the intended data.
- No account balances are included in person statements.
- User is warned before sharing sensitive financial data.

### 10.5 Future Sync Security

- End-to-end encryption for all synced data.
- User-controlled encryption key (device-derived or user-provided).
- Server never has access to unencrypted financial data.
- Zero-knowledge architecture for any future cloud service.

### 10.6 Permissions

| Permission | When Requested | Why |
|------------|----------------|-----|
| Storage (backup) | First backup creation | To write backup file |
| Storage (restore) | First restore | To read backup file |
| Camera (future) | First attachment | To take receipt photo |
| Biometric (future) | First app lock enable | To unlock app |
| Notifications | First reminder set | To show notifications |

---

## 11. Future Sync Architecture

### 11.1 Principles

- Local data remains primary source of truth.
- Sync is user-initiated or scheduled, never real-time by default.
- Data is end-to-end encrypted.
- Sync supports both Finance and Ledger domains.
- Conflicts resolved via last-write-wins initially, manual resolution later.

### 11.2 Data Flow

```
Device A ──► Local DB
                │
        [encrypt + serialize]
                │
                ▼
        Sync File/Stream
                │
        [decrypt + validate]
                │
                ▼
Device B ──► Local DB
```

### 11.3 Conflict Resolution

- Default: Last-write-wins based on `updatedAt` timestamp.
- If timestamps are equal (within tolerance): device ID tiebreaker.
- Future: Manual conflict resolution UI showing both versions.
- Sync log records all conflicts and resolutions.

### 11.4 Sync Triggers

- Manual: User taps "Sync Now" in Settings.
- Scheduled: Optional daily sync at configured time.
- Event-based: App launch, app background (future).

---

## 12. Roadmap & Phases

### 12.1 Version Scheme

```
Major.Minor.Patch
  │       │       └── Bug fixes, small improvements
  │       └────────── Features, non-breaking additions
  └─────────────── Major releases, breaking changes
```

### 12.2 Phase 1 — MVP (v1.0.0)

**Focus:** Core Personal Finance + Basic Ledger

**Modules:**
- Dashboard (basic)
- Accounts (full CRUD)
- Categories (system presets + custom)
- Transactions (Income, Expense, Transfer)
- People (basic CRUD)
- Ledger (Give, Receive, Opening Balance, Ledger History, Outstanding Balance)
- Payment Methods (system presets)
- Search (basic)
- Settings (theme, currency, defaults)

**Database schema version: 1**

**Target:** Personal users, students, casual lender/borrowers

### 12.3 Phase 2 — Ledger Expansion (v1.1.0)

**Focus:** Complete Ledger for business users

**Modules:**
- Sale/Purchase entries
- Adjustment/Discount entries
- Payment Reminders (local notifications)
- Notes (on entries and people)
- Attachments (images)
- Share Statement (image + text)
- Reports (Outstanding Summary, Person Statement)

**Target:** Shop owners, small businesses, freelancers

### 12.4 Phase 3 — Planning & Enhancement (v1.2.0)

**Focus:** Budgets, Goals, Enhanced Reports

**Modules:**
- Budgets (category-based, period tracking, alerts)
- Savings Goals (allocation, progress, completion)
- Reports expansion (Spending by Category, Income vs Expense, Net Worth, Monthly Summary)
- Recurring Transactions (templates, auto-generation)
- Backup & Restore (manual)

**Target:** All users

### 12.5 Phase 4 — Professional Features (v2.0.0)

**Focus:** Export, PDF, Business workflows

**Modules:**
- PDF Statement generation
- CSV Export
- Share & Export (all channels)
- Enhanced Reports (Budget vs Actual, Cash Flow)
- App Lock (PIN/biometric)

**Target:** Professional users, business owners

### 12.6 Phase 5 — Future (v2.x — v3.0)

**Focus:** Advanced features, sync

**Modules:**
- Cloud Sync (encrypted, user-initiated)
- Multi-device Sync
- OCR Receipt Scanner
- AI Insights (spending patterns, suggestions)
- Bank statement import
- Shared budgets/goals (household)
- Biometric authentication

---

## 13. Decision Log

| ID | Date | Decision | Rationale | Alternatives Considered |
|----|------|----------|-----------|------------------------|
| D-001 | 2026-07-18 | Offline-first architecture | Target users have unreliable internet; finance data must always be accessible | Online-first with offline cache (rejected — offline is primary mode) |
| D-002 | 2026-07-18 | Isar as local database | Fast, cross-platform, supports complex queries, embedded, no native setup | SQLite (more complex schema mgmt), Hive (limited queries) |
| D-003 | 2026-07-18 | Riverpod for state management | Compile-safe, testable, no BuildContext dependency, supports streaming | Provider (deprecated), BLoC (more boilerplate) |
| D-004 | 2026-07-18 | GoRouter for navigation | Declarative, supports deep linking, ShellRoute for bottom nav | Navigator 2.0 (more complex), auto_route (codegen dependency) |
| D-005 | 2026-07-18 | Material 3 design | Modern, responsive, accessibility built-in, theming via seed color | Material 2 (dated), custom design system (higher effort) |
| D-006 | 2026-07-18 | Amount stored as integer (smallest unit) | Avoids floating-point precision errors | Double (precision issues), custom Decimal type (no Dart stdlib support) |
| D-007 | 2026-07-18 | No code generation (freezed, build_runner) | Simpler build process, no codegen complexity, faster iteration | Freezed (reduces boilerplate but adds build_runner dependency) |
| D-008 | 2026-07-18 | Bottom sheets for all forms | Preserves context, enables quick entry, supports one-handed use | Full-screen forms (context switching overhead) |
| D-009 | 2026-07-20 | Dual-domain: Finance + Ledger | Solves fragmentation problem, creates original product, serves wider audience | Finance-only (too narrow), Ledger-only (misses personal market) |
| D-010 | 2026-07-20 | Shared accounts between domains | Simplifies architecture, user sees unified money picture | Separate account pools (confusing, redundant data entry) |
| D-011 | 2026-07-20 | Ledger balance always computed, never stored | Single source of truth, no sync inconsistencies | Stored balance (risk of drift from actual calculations) |
| D-012 | 2026-07-20 | Give/Receive affect both person balance AND account balance | Money movement is real — both the person and the account are affected | Person-only tracking (incomplete picture) |
| D-013 | 2026-07-20 | Notifications are local-only in MVP | No server infrastructure needed, privacy-preserving | Push notifications (requires cloud setup, privacy concerns) |

---

## 14. Open Questions

| ID | Question | Domain | Decision Needed By |
|----|----------|--------|-------------------|
| Q-001 | Should transactions support multi-currency natively or convert to base currency at entry time? | Finance | Phase 2 |
| Q-002 | How should recurring transactions that overlap with date changes (e.g., monthly on 31st) be handled? | Finance | Phase 3 |
| Q-003 | Should opening balance changes after grace period be allowed with an audit trail? | Ledger | Phase 1 |
| Q-004 | Should discount entries be treated as a separate ledger type or as a sub-type of Adjustment? | Ledger | Phase 2 |
| Q-005 | How should attachment storage be managed on low-storage devices? | Ledger | Phase 2 |
| Q-006 | Should shared statements include a verification code/hash for authenticity? | Ledger | Phase 2 |
| Q-007 | What is the maximum practical number of categories/budgets/goals before performance degrades? | Finance | Phase 1 |
| Q-008 | Should the app support multiple base currencies (one per account) or one global base currency? | Settings | Phase 1 |
| Q-009 | How should transfer fees be recorded — as part of the transfer transaction or as a separate expense? | Finance | Phase 1 |
| Q-010 | Should backup include media files (photos) or only database data? | Backup | Phase 3 |
| Q-011 | What is the first localization target after English? Bengali? Arabic? Hindi? | Product | Phase 2 |
| Q-012 | Should the app support multiple users on the same device (family mode)? | Product | Future |

---

## 15. Architecture Notes

### 15.1 Technology Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| UI Framework | Flutter 3.44+ | Cross-platform, single codebase, Material 3 |
| State Management | Riverpod 3.x | Compile-safe, testable, provider-based |
| Navigation | GoRouter 17.x | Declarative routing, ShellRoute, deep links |
| Database | Isar 3.1.x | Embedded, fast, cross-platform, no native deps |
| Localization | Flutter i18n + ARB | Standard Flutter approach |
| Charts | fl_chart | Lightweight, customizable, supports all needed chart types |
| PDF Generation | pdf package | Pure Dart, no native dependencies |
| Notifications | flutter_local_notifications | Cross-platform local notifications |
| File Handling | path_provider + file_picker | Standard file access |
| CSV Export | csv package | Lightweight CSV generation |

### 15.2 Clean Architecture Layers

```
┌─────────────────────────────────────────────────┐
│  Presentation Layer (UI)                        │
│  - Pages, Widgets, Providers                    │
│  - Riverpod state + GoRouter navigation         │
├─────────────────────────────────────────────────┤
│  Domain Layer (Business Logic)                  │
│  - Entities, Use Cases, Repository Interfaces   │
│  - Pure Dart, no framework dependencies         │
├─────────────────────────────────────────────────┤
│  Data Layer (Implementation)                    │
│  - Repository implementations, DataSources       │
│  - Isar models, mappers, local storage          │
├─────────────────────────────────────────────────┤
│  Core Layer (Cross-cutting)                     │
│  - AppException, Failure, Result                │
│  - Logger interface, Responsive utilities       │
└─────────────────────────────────────────────────┘
```

### 15.3 Feature Module Structure

```
lib/features/{feature}/
├── domain/
│   ├── entities/         # Business objects
│   ├── repositories/     # Abstract repository interfaces
│   └── usecases/         # Business logic use cases
├── data/
│   ├── models/           # Isar models + mappers
│   ├── datasources/      # Local data sources
│   └── repositories/     # Repository implementations
└── presentation/
    ├── pages/            # Full-page widgets
    ├── providers/        # Riverpod providers
    └── widgets/          # Reusable UI components
```

### 15.4 Offline Architecture

```
User Action → Provider → Use Case → Repository → DataSource → Isar DB
                                                              │
                                                    ┌─────────┴─────────┐
                                                    │  Watch stream     │
                                                    │  (reactive)       │
                                                    └───────────────────┘
                                                              │
                                                    ┌─────────▼─────────┐
                                                    │  UI rebuilds       │
                                                    │  (Riverpod)        │
                                                    └───────────────────┘
```

- All mutations write directly to Isar.
- Isar streams (`watchLazy`) propagate changes to Riverpod providers.
- UI automatically rebuilds on data changes.
- No network layer, no loading states for data reads (always local).
- Optimistic updates are inherent (local write is the source of truth).

### 15.5 Future Sync Data Flow (Conceptual)

```
Local Write → Change Log → [Encrypt] → Sync Queue
                                              │
                                    [When sync triggered]
                                              │
                                              ▼
                                     Cloud Storage
                                              │
                                    [Other device pulls]
                                              │
                                              ▼
                                     [Decrypt + Validate]
                                              │
                                              ▼
                                     Apply to Local DB
                                              │
                                     [Conflict? → Resolve]
```

---

## 16. Appendices

### 16.1 Appendix A: System Presets — Categories

**Income Categories (17):**
Salary, Wages, Freelance Income, Business Income, Investment Income, Rental Income, Dividend, Interest, Gift Received, Refund, Cashback, Bonus, Commission, Pension, Social Benefit, Scholarship, Other Income

**Expense Categories (30+):**
Food & Dining, Groceries, Fruits & Vegetables, Meat & Fish, Dairy & Eggs, Snacks & Beverages, Eating Out, Transportation, Fuel, Public Transport, Ride Sharing, Vehicle Maintenance, Rent/Mortgage, Electricity, Water, Gas, Internet, Mobile/Phone, Cable TV, Entertainment, Movies, Sports, Hobbies, Shopping, Clothing, Electronics, Home Supplies, Health/Medical, Doctor Visit, Medicine, Hospital, Insurance, Education, Tuition, Books & Stationery, Course/Training, Personal Care, Salon, Cosmetics, Travel, Hotel, Flight, Holiday, Gifts & Donations, Charity, Subscription, Software, Streaming, Gym/Fitness, Sports Equipment, Pet Care, Pet Food, Veterinary, Baby/Children, Baby Food, Diapers, Toys, Other Expense

### 16.2 Appendix B: System Presets — Payment Methods

Cash, Bank Transfer, Credit Card, Debit Card, bKash, Nagad, Rocket, Upay, Cheque, Mobile Banking, Online Transfer, Other

### 16.3 Appendix C: Currency Support (Phase 1)

USD ($), EUR (€), GBP (£), JPY (¥), CNY (¥), INR (₹), BDT (৳), PKR (₨), LKR (₨), NPR (₨), MYR (RM), SGD (S$), AUD (A$), CAD (C$), AED (د.إ), SAR (﷼), QAR (﷼), OMR (﷼), KWD (د.ك), THB (฿), VND (₫), PHP (₱), IDR (Rp), KRW (₩)

Full ISO 4217 support planned for Phase 2.

### 16.4 Appendix D: Glossary

| Term | Definition |
|------|------------|
| Account | A container for tracking money in a specific place (bank account, cash wallet, mobile wallet) |
| Adjustment | A ledger entry that corrects a person's balance without a corresponding money movement |
| Allocation | Transferring money from an account to a savings goal |
| Balance | The current amount of money in an account |
| Budget | A spending limit for one or more categories over a defined period |
| Category | A classification label for income or expense transactions |
| Discount | A ledger entry that reduces what a person owes (write-off) |
| Domain | Personal Finance or Ledger — the two major product areas |
| Entry | A single record in a person's ledger history |
| Give Money | Recording money given to another person (loan or gift) |
| Income | Money received into a user's account (earnings, gifts, refunds) |
| Expense | Money spent from a user's account (purchases, bills, payments) |
| Ledger | Interpersonal financial transaction tracking |
| Outstanding Balance | The net amount a person owes the user (or vice versa) |
| Payment Method | The mechanism used to transact (cash, bank transfer, mobile wallet) |
| Pending | A transaction recorded but not yet fully settled |
| Person | A contact in the ledger (customer, supplier, friend, family, etc.) |
| Receive Money | Recording money received from another person |
| Reminder | A scheduled notification about an expected repayment |
| Sale | A ledger entry recording a sale of goods/services to a customer |
| Purchase | A ledger entry recording a purchase of goods/services from a supplier |
| Statement | A shareable summary of a person's ledger |
| Tags | Free-form text labels attached to transactions or people |
| Transfer | Moving money between the user's own accounts |

---

## Change History

| Date | Version | Author | Changes |
|------|---------|--------|---------|
| 2026-07-18 | 1.0 | Product | Initial draft (Personal Finance only) |
| 2026-07-20 | 2.0 | Product | Expanded to Finance & Ledger Platform with module specs |
| 2026-07-20 | 3.0 | Product | Complete rewrite — full PRD with all modules, ERD, UX, design system, security, roadmap, decision log, open questions |

---

## References

- [Project Overview](01_Project_Overview.md)
- [System Architecture](03_System_Architecture.md)
- [Clean Architecture](04_Clean_Architecture.md)
- [Feature Roadmap](05_Feature_Roadmap.md)
- [Database Design](09_Database_Design.md)
- [UI/UX Guidelines](06_UI_UX_Guidelines.md)
- [Design System](06_Design_System.md)
- [Testing Strategy](09_Testing_Strategy.md)
- [Offline-First Strategy](12_Offline_First_Strategy.md)
- [Documentation Home](README.md)
- [Project Context](../.ai/PROJECT_CONTEXT.md)
- [AI Rules](../.ai/AI_RULES.md)
