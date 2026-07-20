# Paysa

> Offline-first Finance & Ledger Platform built with Flutter.

## Quick Start

```bash
flutter pub get
flutter build apk --debug
flutter run
```

## Verification

```bash
flutter analyze            # 0 errors, 0 warnings expected
flutter test               # 69+ tests, all passing
flutter build apk --debug  # APK builds successfully
```

## Key Features (Implemented)

- **Accounts** — Full CRUD for Cash, Bank, Mobile Banking, Credit Card, Savings, Investment accounts
- **Categories** — System presets + custom categories for Income and Expense
- **Transactions** — Income, Expense, and Transfer recording with categories and tags
- **People** — 7 person types (Customer, Supplier, Friend, Family, Employee, Business Partner, Other) with search, sort, filter, favorites, soft-delete, archive/restore
- **Dashboard** — Balance summary, recent activity, quick actions, account overview
- **Ledger-ready** — Person detail with placeholder sections for Give/Receive, reminders, sharing

## Technology Stack

| Layer | Technology |
|-------|-----------|
| UI Framework | Flutter 3.44+, Material 3 |
| State Management | Riverpod 3.x |
| Navigation | GoRouter 17.x |
| Database | Isar 3.1.x (embedded, no native deps) |
| Diagrams/Audit | No external services (offline-first) |

## Architecture

Paysa follows **Clean Architecture** with a feature-first structure:

```
lib/
├── app/           # Bootstrap, DI, router, theme, database, error handling
├── core/          # Exceptions, failures, utilities, responsive helpers
├── features/      # Vertical feature modules (accounts, categories, transactions, people)
│   ├── domain/    # Entities, repository interfaces, use cases (pure Dart)
│   ├── data/      # Isar models, datasources, repository implementations
│   └── presentation/  # Pages, Riverpod providers, widgets
└── shared/        # Reusable UI components
```

## Feature Modules

| Module | Status | Domain | Data Layer | Presentation |
|--------|--------|--------|------------|--------------|
| Accounts | ✅ Complete | Entity, repos, use cases | Isar model, datasource, repository | Pages, providers, widgets |
| Categories | ✅ Complete | Entity, repos, use cases | Isar model, datasource, repository | Pages, providers, widgets |
| Transactions | ✅ Complete | Entity, repos, use cases | Isar model, datasource, repository | Pages, providers, widgets |
| People | ✅ Complete | Entity (7 types), repos, 7 use cases | Isar model (20 fields), datasource, repository | List, detail, add/edit form, 17 providers |
| Dashboard | ✅ Basic | — | — | Aggregated view with balance, activity |

## People Module (Sprint 1)

- **7 Person Types**: Customer, Supplier, Friend, Family, Employee, Business Partner, Other
- **20-field Isar model**: uuid, name, phone, email, address, photoPath, personType, openingBalance, currentBalance, currencyCode, notes, favorite, active, timestamps, soft-delete, syncStatus, version
- **Search**: Live onChanged filtering by name, phone, email
- **Sort**: By name (A-Z, Z-A), created date (newest/oldest), balance (low-high, high-low)
- **Filter**: By type (each of 7 types), status (active/archived), favorites only
- **Soft-delete**: deletedAt timestamp, restorable within 30 days
- **Sync-ready**: UUID, version, syncStatus fields on every record

## Testing

```bash
flutter test

# 69 tests covering:
#   createPerson:    18  (validation, duplicates, edge cases)
#   updatePerson:    7   (name, phone, uuid preservation)
#   getPeople:       24  (filters, search, sort, by-id, by-phone)
#   deletePerson:    5   (soft-delete, balance guard)
#   archivePerson:   6   (archive/restore round-trip)
#   watchPeople:     3   (stream emissions)
#   validation:      6   (trimming, currency, null handling)
```

## Documentation

Key references in `docs/`:

- [Product Requirements](docs/02_Product_Requirements_Document.md)
- [System Architecture](docs/03_System_Architecture.md)
- [Information Architecture](docs/08_Navigation_Architecture.md)
- [Database Architecture](docs/10_Data_Modeling.md)
- [Finance Engine](docs/11_Finance_Engine_Specification.md)
- [Architecture Lock Report](docs/12_Architecture_Lock_Report.md)
