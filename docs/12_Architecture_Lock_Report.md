# Architecture Lock Report — Sprint 0 Foundation Lock

**Product:** Paysa — Offline-first Finance & Ledger Platform  
**Report:** ALR v1.0  
**Date:** 2026-07-20  
**Status:** NOT READY for Sprint 1  

---

## TABLE OF CONTENTS

1. [Architecture Lock Status](#1-architecture-lock-status)
2. [Technical Debt Inventory](#2-technical-debt-inventory)
3. [Critical Bugs](#3-critical-bugs)
4. [Future Risks](#4-future-risks)
5. [Definition of Done](#5-definition-of-done)
6. [Coding & Architecture Rules](#6-coding--architecture-rules)
7. [Checklists](#7-checklists)
8. [Final Verdict](#8-final-verdict)

---

## 1. Architecture Lock Status

| # | Area | Status | Verdict |
|---|------|--------|---------|
| 1 | Folder Structure vs Documentation | ⚠️ **NOT READY** | Docs are aspirational, not descriptive. 6 stub pages in `lib/app/` duplicate feature layer. |
| 2 | Material 3 / Theme | ⚠️ **NOT READY** | DesignTokens defined but ignored in feature widgets (~50+ hardcoded values). |
| 3 | Riverpod | ⚠️ **NOT READY** | Legacy import used. Usecase providers are proxy wrappers. Repository providers in presentation layer. |
| 4 | GoRouter | ✅ **READY** | ShellRoute with 5 tabs + splash. No 404 route (acceptable for MVP). |
| 5 | Isar / Database | ⚠️ **NOT READY** | Missing indexes on accountId, categoryId, date. No migration config. No tuning. |
| 6 | Repository Pattern | ✅ **READY** | Correct. Every interface has impl. All classes const. |
| 7 | Dependency Injection | ⚠️ **NOT READY** | CrashReporter always Noop. ErrorHandler not injected. Isar eagerly opened. |
| 8 | Feature Architecture | ✅ **READY** | All 3 features have complete domain/data/presentation layers. |
| 9 | Error Handling | ⚠️ **NOT READY** | `Result<T>` and `Failure` are dead code (defined, exported, never used). |
| 10 | Logging | ⚠️ **NOT READY** | `CoreLogger` (interface) and `AppLogger` (impl) are parallel abstractions with no shared contract. |
| 11 | Testing | ⚠️ **NOT READY** | Only 1 test. `isarProvider` not overridden — test will crash at runtime. Zero unit tests. |
| 12 | Generated Files | ✅ **READY** | All g.dart correct. Version matches Isar. Part directives correct. |
| 13 | Public API Surface (Barrels) | ✅ **READY** | Only domain types exported. No data/presentation leaks. |
| 14 | pubspec.yaml | ⚠️ **NOT READY** | `xxh3` unused. Missing `build_runner`, `isar_generator`, `mocktail` in dev_deps. |

**6 of 14 areas READY.**  
**8 of 14 areas NOT READY.**

---

## 2. Technical Debt Inventory

### Priority: High

| ID | Item | Files Affected | Impact |
|----|------|----------------|--------|
| TD-01 | `Result<T>`, `Failure`, `CoreLogger` are dead code | `lib/core/result.dart`, `lib/core/failure.dart`, `lib/core/logger/app_logger_interface.dart` | 3 files, ~80 lines of unused abstractions. Documented architecture does not match code. |
| TD-02 | `xxh3` dependency unused | `pubspec.yaml` | Unnecessary transitive dependency. Remove or document. |
| TD-03 | Missing `isarProvider` override in test | `test/app_foundation_test.dart` | Test will crash at runtime. Blocks CI. |
| TD-04 | Missing indexes on `TransactionRecord` | `lib/features/transactions/data/models/transaction_record.dart` | O(n) scans for account/category/date queries at scale. |
| TD-05 | No migration architecture | `lib/app/database/paysa_database.dart` | Schema changes will break existing user databases. |

### Priority: Medium

| ID | Item | Files Affected | Impact |
|----|------|----------------|--------|
| TD-06 | DesignTokens not used in feature widgets | 10+ feature widget files | ~50+ hardcoded spacing/radius values. Theming inconsistency. |
| TD-07 | `riverpod/legacy.dart` imported unnecessarily | `accounts_providers.dart`, `transactions_providers.dart` | Legacy API usage. autoDispose is default in 3.x. |
| TD-08 | Stub pages in `lib/app/` | 6 files (accounts_page, dashboard_page, transactions_page, etc.) | One-line re-exports. Add noise to the directory tree. |
| TD-09 | Cross-feature imports bypass barrels | `dashboard_page.dart` | Direct import of feature providers instead of barrel. |
| TD-10 | No `build_runner` in dev_dependencies | `pubspec.yaml` | Cannot regenerate g.dart files without installing it first. |

### Priority: Low

| ID | Item | Files Affected | Impact |
|----|------|----------------|--------|
| TD-11 | `SecondaryButton` uses `OutlinedButton` vs `FilledButton.tonal` | `secondary_button.dart` | Visual inconsistency with M3 naming conventions. |
| TD-12 | AnimatedSwitcher missing ValueKey | 3 page files | Potential incorrect transition animation. |
| TD-13 | No custom lint rules | `analysis_options.yaml` | Only default flutter_lints. No project-specific rules. |
| TD-14 | Usecase providers are proxy wrappers | All provider files | 17 usecase providers doing minimal validation then delegating. Adds boilerplate with little value. |

---

## 3. Critical Bugs

| ID | Bug | Severity | Impact | Fix |
|----|-----|----------|--------|-----|
| B-01 | Test crashes on navigation to Dashboard | **HIGH** | CI will always fail. No automated testing possible. | Override `isarProvider` in `ProviderScope` in test. |
| B-02 | Multi-currency dashboard displays wrong total | **HIGH** | Dashboard shows sum of different currencies under one label. Financial misrepresentation. | Group by currency or convert to single display currency. |
| B-03 | Orphaned transactions on account/category deletion | **HIGH** | Deleting an account leaves transactions pointing to deleted entity. Balance calculations include orphaned data. | Add FK validation or null-out references on delete. |
| B-04 | Balance stored as `double` | **MEDIUM** | Floating-point precision errors will accumulate over thousands of transactions. | Migrate to `int` (minor units). See DB architecture doc. |
| B-05 | Currency validated only as non-empty string | **MEDIUM** | Users can enter "dollar", "USD", "$" — all saved as different values. Aggregation queries produce incorrect totals. | Validate against ISO 4217 list. |

---

## 4. Future Risks

| ID | Risk | Timeline | Impact if Realized |
|----|------|----------|-------------------|
| R-01 | No indexes on foreign keys | When transactions exceed 10,000 records | Dashboard and report loading times degrade to seconds/minutes |
| R-02 | No migration configuration | Next schema change | Existing user databases will crash or lose data on update |
| R-03 | No sync-ready UUIDs in entities | Sync sprint (Phase 6) | Full migration required to add UUID fields to every entity |
| R-04 | No Cascade/Referential Integrity | Any delete operation | Orphaned records accumulate; sync multiplies the problem |
| R-05 | CrashReporter always Noop | Production launch | All production crashes are invisible to developers |
| R-06 | double for financial amounts | 10,000+ transactions | Floating-point drift becomes measurable (>$0.01 cumulative error) |

---

## 5. Definition of Done

### 5.1 Feature DoD

```
[ ] Feature has complete Clean Architecture layers (domain, data, presentation)
[ ] Feature builds with zero errors
[ ] Feature passes `flutter analyze` with zero errors
[ ] Feature has unit tests for all use cases
[ ] Feature has widget tests for all pages
[ ] Feature uses DesignTokens for all spacing, radius, and elevation values
[ ] Feature has empty state, loading state, and error state for every async view
[ ] Feature handles all edge cases documented in the Finance Engine specification
[ ] Feature barrel file exports only domain types
[ ] Feature provider files do not import `riverpod/legacy.dart`
[ ] Feature uses `int` for monetary amounts, not `double`
[ ] Feature has no hardcoded strings (use constants or localization)
```

### 5.2 Bug Fix DoD

```
[ ] Root cause identified and documented
[ ] Fix applied with minimal change surface
[ ] Test added that reproduces the bug
[ ] Test passes after fix
[ ] No regression in existing tests
[ ] `flutter analyze` passes with zero errors
[ ] `flutter build apk --debug` succeeds
[ ] Fix documented in changelog
```

### 5.3 Sprint DoD

```
[ ] All committed features pass Feature DoD
[ ] All committed bug fixes pass Bug Fix DoD
[ ] `flutter analyze` — zero errors, zero warnings
[ ] `flutter test` — all tests pass
[ ] `flutter build apk --debug` — builds successfully
[ ] `flutter run` on emulator — launches without crash
[ ] No dead code introduced
[ ] No unused dependencies added
[ ] Generated files regenerated if schema changed
[ ] Documentation updated for any behavior/schema changes
[ ] Audit log created for any financial logic changes
```

---

## 6. Coding & Architecture Rules

### 6.1 Architecture Rules

| Rule | Description |
|------|-------------|
| AR-01 | Domain layer is pure Dart. Zero Flutter, zero framework imports. |
| AR-02 | Domain entities are immutable (`final class` with `copyWith`). |
| AR-03 | Domain repositories are abstract interfaces. Never concrete classes. |
| AR-04 | Data layer depends on domain layer. Not vice versa. |
| AR-05 | Presentation layer depends on domain layer via providers. |
| AR-06 | Every feature has a barrel file. Cross-feature imports go through barrels. |
| AR-07 | Repository implementations are `const`-constructible. |
| AR-08 | All provider classes are `final`. |
| AR-09 | Riverpod providers follow naming: `{entity}{Action}Provider`. |
| AR-10 | Amounts are stored as `int` (minor currency units). Never `double`. Never `String`. |

### 6.2 Coding Rules

| Rule | Description |
|------|-------------|
| CR-01 | No hardcoded spacing/radius/elevation values. Use `DesignTokens.*`. |
| CR-02 | No `import 'package:riverpod/legacy.dart'`. Use Riverpod 3.x API. |
| CR-03 | All monetary comparisons use integer arithmetic. |
| CR-04 | Every async view handles loading, error, and empty states. |
| CR-05 | Every form validates all fields before submission. |
| CR-06 | Every mutation shows a snackbar on success. |
| CR-07 | Every mutation creates an audit log entry. |
| CR-08 | Soft-delete is the default. Hard-delete requires explicit approval. |
| CR-09 | Financial records are immutable. Corrections use reversals. |
| CR-10 | Dart 3 `final class` is the default class modifier. |

### 6.3 Naming Conventions

| Convention | Example |
|------------|---------|
| Files: `snake_case` | `account_record.dart` |
| Classes: `PascalCase` | `AccountRecord` |
| Variables: `camelCase` | `accountBalance` |
| Constants: `camelCase` | `defaultCurrency` |
| Providers: `camelCase + Provider` | `accountListProvider` |
| Use cases: `PascalCase` verb | `CreateAccount` |
| Repositories: `PascalCase + Impl` | `AccountRepositoryImpl` |
| Datasources: `PascalCase + ({Type})` | `IsarAccountsLocalDataSource` |
| Barrel files: feature name | `accounts.dart` |
| Generated files: `_feature.g.dart` | `account_record.g.dart` |
| Test files: `_test.dart` | `account_repository_test.dart` |

### 6.4 Git Commit Convention

```
<type>(<scope>): <description>

Types:
  feat    — New feature
  fix     — Bug fix
  docs    — Documentation
  style   — Formatting, lint fixes
  refactor— Code change that fixes neither bug nor adds feature
  perf    — Performance improvement
  test    — Adding or fixing tests
  chore   — Build process, CI, dependency changes

Scope:
  accounts, categories, transactions, ledger, people, budgets,
  goals, reports, dashboard, settings, search, backup, sync,
  core, shared, app, database, router, theme, docs, ci

Examples:
  feat(accounts): add create account form with validation
  fix(transactions): correct balance calculation for multi-currency
  docs(database): add migration strategy to DB design
  test(ledger): add outstanding balance calculation tests
```

### 6.5 Branch Naming Convention

```
<type>/<scope>-<description>

Types:
  feature/    — New features
  fix/        — Bug fixes
  docs/       — Documentation
  refactor/   — Code refactoring
  test/       — Testing
  chore/      — Maintenance

Examples:
  feature/accounts-crud
  fix/transfer-currency-conversion
  docs/database-migration-strategy
  refactor/design-tokens-migration
  test/ledger-balance-calculation
```

---

## 7. Checklists

### 7.1 Feature Checklist

```
[ ] PRD reference: Section/module documented
[ ] IA reference: Screen IDs assigned
[ ] DB reference: Entities and fields match data model
[ ] FE reference: Business rules match Finance Engine spec
[ ] Architecture: All 3 layers present
[ ] Design: Uses DesignTokens, M3 components
[ ] States: Loading, empty, error, data
[ ] Validation: All input fields validated
[ ] Error handling: User errors caught and displayed
[ ] Accessible: 48dp touch targets, color-independent indicators
[ ] Tested: Unit + widget tests written
[ ] Analyzed: flutter analyze passes
[ ] Built: flutter build apk succeeds
```

### 7.2 PR Checklist

```
[ ] Code builds without errors
[ ] flutter analyze passes with zero errors
[ ] All existing tests pass
[ ] New tests cover the change
[ ] No dead code added
[ ] No unused imports added
[ ] DesignTokens used instead of hardcoded values
[ ] Amounts use int (minor units), not double
[ ] Riverpod legacy API not imported
[ ] Feature barrel exports only domain types
[ ] Cross-feature imports use barrel files
[ ] Security reviewed (no sensitive data exposure)
[ ] Edge cases handled per Finance Engine spec
[ ] Audit trail created for financial mutations
[ ] Changelog updated
```

### 7.3 Review Checklist

```
[ ] Architecture follows Clean Architecture layers
[ ] Domain layer has no framework dependencies
[ ] Use cases have single responsibility
[ ] Repositories abstract data sources correctly
[ ] Providers use correct Riverpod patterns
[ ] Widgets handle loading/error/empty states
[ ] Forms validate all inputs
[ ] Hardcoded spacing/radius/elevation flagged
[ ] double used for amounts? → BLOCK
[ ] riverpod/legacy imported? → FLAG
[ ] Barrel file leaks data layer? → BLOCK
[ ] Test coverage adequate for the change
```

### 7.4 Testing Checklist

```
[ ] All use cases tested (positive + negative + edge)
[ ] Repository tests mock datasource
[ ] Widget tests for every page (loading/error/empty/data)
[ ] Form tests for validation rules
[ ] No flaky tests (deterministic assertions)
[ ] isarProvider overridden in all ProviderScope tests
[ ] Tests run in under 30 seconds
[ ] flutter test passes consistently
```

---

## 8. Final Verdict

### ❌ NOT READY for Sprint 1

**6 blocking issues must be resolved before Sprint 1 can begin:**

| Priority | Issue | Repo Impact |
|----------|-------|-------------|
| **BLOCKER** | Test crashes — `isarProvider` not overridden | All CI pipelines invalid |
| **BLOCKER** | Missing indexes on TransactionRecord (accountId, categoryId, date) | Performance failure at scale |
| **BLOCKER** | Multi-currency dashboard displays wrong total | Financial misrepresentation |
| **BLOCKER** | Orphaned transactions on account/category deletion | Data integrity failure |
| **HIGH** | `Result<T>`, `Failure`, `CoreLogger` dead code — architecture mismatch | Documented architecture does not match code |
| **HIGH** | No migration architecture | Schema changes break existing databases |

### Recommended Sprint 0.5: Foundation Hardening

Run a one-week hardening sprint to resolve all 6 blocking issues before starting feature work:

1. **Fix test infrastructure** — Override `isarProvider`, add base test utilities
2. **Add missing indexes** — Add `accountId`, `categoryId`, `date` indexes to `TransactionRecord`
3. **Fix multi-currency dashboard** — Group by currency or convert to base currency
4. **Add delete validation** — Block deletion if transactions reference account/category
5. **Remove dead code OR adopt it** — Either use `Result<T>` in repository returns or delete `Result<T>`, `Failure`, `CoreLogger`
6. **Add migration architecture** — Register migration callbacks in `PaysaDatabase.open()`

### Approved for Sprint 0.5

✅ Architecture patterns (Clean Architecture, Repository, DI)  
✅ Feature-first structure  
✅ Isar schema and generated files  
✅ GoRouter navigation  
✅ Material 3 theme foundation  
✅ DesignTokens pattern (needs broader adoption)  
✅ Error boundary and crash reporter interfaces  
✅ Logger setup  
✅ Shared widget library  
✅ Barrel file conventions  

The foundation is structurally sound but needs hardening before it can support production feature development safely.
