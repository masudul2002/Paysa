# Changelog

All notable changes to this repository will be documented in this file.

## 0.2.0-dev — 2026-07-20

### Features
- **People Module** (Sprint 1 complete): Full Clean Architecture feature with domain, data, and presentation layers.
  - Person entity with 7 types (Customer, Supplier, Friend, Family, Employee, Business Partner, Other)
  - CRUD operations via repository pattern
  - Soft-delete with 30-day restore window
  - Archive/restore workflow
  - Favorite marking with favorites-first sort
  - Search by name, phone, email (live onChanged filtering)
  - Sort by name, date, or balance (ascending/descending)
  - Filter by type, status, favorites via chip-based UI
  - Add/Edit form with validation (name, email, phone, opening balance)
  - Person detail profile page with info cards and placeholder sections
  - Inline search bar in app bar
  - Responsive layout (list on narrow, grid on wide ≥600dp)
  - 69 passing tests (repository + validation + search + soft-delete + archive)

### Database
- Added `PersonRecordSchema` (Collection ID: `-4488016229524395338`)
- 20-field Isar model with uuid, version, soft-delete, and sync fields
- `SyncStatus` enum for future cloud sync (pending, synced, modified, deleted, failed)
- `validate()` method on PersonRecord
- Indexes: `name` (unique, case-insensitive), `phone` (value)

### Infrastructure
- Navigation: Added People tab to bottom nav, `/people` route, person detail via push navigation
- Database: PersonRecordSchema registered in PaysaDatabase.open()
- Test helpers: `test/test_helpers.dart` created, `InMemoryPeopleLocalDataSource` pattern

### Changed
- App shell bottom nav: Accounts → + → People → Transactions → More
- Router: Added people route + PeoplePage import

## 0.1.0-dev — 2026-07-18

- Initial repository scaffold.
- Project documentation structure.
- Clean Architecture foundation.
- Accounts, Categories, Transactions features (basic).
