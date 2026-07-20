# Database Design — Reference Summary

**Product:** Paysa — Offline-first Finance & Ledger Platform  
**Last Updated:** 2026-07-20  

---

## Purpose

This document provides a high-level reference to Paysa's database architecture. The complete detailed specification is maintained in [10_Data_Modeling.md](10_Data_Modeling.md).

---

## Database Engine

**Isar 3.1.0+1** — confirmed and integrated.

Isar is an embedded, cross-platform, NoSQL document database with:
- Native Dart API
- Full ACID transactions
- Composite indexes
- Reactive streams (watchLazy)
- No native dependencies (pure Dart FFI)
- Support for offline-first architecture

---

## Schema Inventory

| # | Entity | Collection ID (xxh3 hash) | Domain |
|---|--------|--------------------------|--------|
| 1 | AccountRecord | `6248368834734623252` | Finance |
| 2 | CategoryRecord | `-7531377010659943767` | Finance |
| 3 | TransactionRecord | `5251947889243599499` | Finance |
| 4 | PersonRecord | `-4488016229524395338` | Ledger |
| 5+ | Future entities | Sequential (computed by codegen) | Both |

**IMPORTANT:** Collection IDs are xxh3 hashes of the collection name. They must NEVER be changed after the first release with production data. Changing a collection ID creates a new empty collection and orphaned existing data.

---

## Key Decisions

| Decision | Detail |
|----------|--------|
| Amount storage | `int` (minor currency units). No `double`. No floating point. |
| Balance computation | Always derived from entry sums. Never stored as a mutable field. |
| Entity identity | Dual: auto-increment `id` for local joins + `uuid` for future sync. |
| Soft deletes | Every mutable entity has `deletedAt`. Data is never permanently deleted. |
| Versioning | Every mutable entity has `version` integer for optimistic concurrency. |
| Immutable history | Transactions and ledger entries are never mutated. Corrections use reversals. |

---

## Entity Count

**23 entities** across 5 domains:

| Domain | Entities |
|--------|----------|
| Finance | Account, Category, Transaction, RecurringTemplate, Budget, BudgetCategory, SavingsGoal, GoalAllocation |
| Ledger | Person, LedgerEntry, OpeningBalance |
| Cross-cutting | PaymentMethod, Reminder, Attachment, Tag, EntityTag, AppSetting, Notification, NotificationPreference |
| Sync | SyncQueue, SyncConflict |
| System | AuditLog, SchemaVersion |

See [10_Data_Modeling.md#5-detailed-entity-specifications](10_Data_Modeling.md#5-detailed-entity-specifications) for complete specifications.

---

## Migration Strategy

- Schema version tracked in `SchemaVersion` table.
- Migrations stored in `lib/app/database/migrations/`.
- Applied sequentially on database open.
- Rollback on failure.
- See [10_Data_Modeling.md#13-migration-strategy](10_Data_Modeling.md#13-migration-strategy) for details.

---

## References

- [Complete Data Model](10_Data_Modeling.md)
- [Product Requirements](02_Product_Requirements_Document.md)
- [System Architecture](03_System_Architecture.md)
- [Offline-First Strategy](12_Offline_First_Strategy.md)
- [Sync Architecture](13_Sync_Architecture.md)

---

## Change History

| Date | Version | Author | Changes |
|------|---------|--------|---------|
| 2026-07-18 | 1.0 | DB Architecture | Initial placeholder |
| 2026-07-20 | 2.0 | DB Architecture | Updated schema inventory, collection IDs |
| 2026-07-20 | 3.0 | DB Architecture | Complete rewrite — full production database architecture in `10_Data_Modeling.md` |
| 2026-07-20 | 3.1 | DB Architecture | Added PersonRecord schema (Collection ID `-4488016229524395338`). 20 fields including uuid, syncStatus, version, soft-delete. |
| 2026-07-20 | 3.2 | DB Architecture | Completed Sprint 1 — PersonRecord verified. Indexes on `name` (unique) and `phone`. validate() method. SyncStatus enum. |
| 2026-07-20 | 4.0 | DB Architecture | Added LedgerRecordSchema (ID `7969488079492419995`) and LedgerEntryRecordSchema (ID `-737622932812665416`). 10 entry types, proper indexes, validate() on both entities. |
