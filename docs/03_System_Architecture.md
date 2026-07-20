# System Architecture

## Purpose
Describe Paysa's high-level system architecture.

## Scope
Covers app modules, boundaries, local-first data flow, cross-cutting concerns, and sync-readiness. It does not define implementation code.

## Objectives
- Keep product, domain, data, presentation, and infrastructure concerns separate.
- Support reliable offline use.
- Prepare for eventual synchronization without rewriting the domain.

## Responsibilities
- Lead Architect owns architecture decisions.
- Mobile Lead validates mobile feasibility.
- QA validates testability of architectural boundaries.

## Key Decisions
- The local app is authoritative in MVP.
- Domain logic must not depend on storage, UI, or network details.
- Sync architecture is designed as future-facing and isolated from MVP workflows.
- Security, logging, error handling, and performance are cross-cutting concerns.

## Resolved Decisions

| Question | Decision | Date |
|----------|----------|------|
| Local database | Isar 3.1.0+1 | 2026-07-18 |
| State management | Riverpod 3.x | 2026-07-18 |
| Navigation | GoRouter 17.x | 2026-07-18 |
| Architecture | Clean Architecture, feature-first | 2026-07-18 |
| Monetary amounts | `int` (minor currency units) | 2026-07-20 |
| Feature modules | Accounts, Categories, Transactions, People completed | 2026-07-20 |
| Incrementing version | `int`, optimistic concurrency | 2026-07-20 |
| Sync readiness | UUID + version + syncStatus on every entity | 2026-07-20 |

## Current Feature Inventory

| Module | Status | Domain | Data | Presentation |
|--------|--------|--------|------|-------------|
| Accounts | ✅ Complete | Entity + use cases | Isar model + repository | Pages + providers |
| Categories | ✅ Complete | Entity + use cases | Isar model + repository | Pages + providers |
| Transactions | ✅ Complete | Entity + use cases | Isar model + repository | Pages + providers |
| People (Sprint 1) | ✅ Complete | 7 types + use cases | 20-field Isar model | List, detail, form, 17 providers |
| Dashboard | ✅ Basic | — | Aggregated from services | Widget-based |
| Reports | ❌ Placeholder | — | — | Static stub |
| Budgets | ❌ Placeholder | — | — | Static stub |
| Goals | ❌ Placeholder | — | — | Static stub |

## Open Questions
- What is the minimum supported platform set for production?
- What sync provider constraints may affect identifiers and conflict resolution?

## Future Improvements
- Remote backup and sync service.
- Event-based sync queue.
- Multi-profile or household data boundaries.

## References
- `04_Clean_Architecture.md`
- `09_Database_Design.md`
- `12_Offline_First_Strategy.md`
- `13_Sync_Architecture.md`

## Changelog
- 2026-07-18: Created initial system architecture document.
## Cross References

- [Project Context](../.ai/PROJECT_CONTEXT.md)
- [AI Rules](../.ai/AI_RULES.md)
- [Documentation Guide](../docs/DOCUMENTATION_GUIDE.md)
- [Documentation Home](../docs/README.md)