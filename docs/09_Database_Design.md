# Database Design

## Purpose
Define local persistence responsibilities and database design principles.

## Scope
Covers conceptual local storage, schema ownership, migration strategy, indexing principles, backup considerations, and sync-readiness. It does not include database implementation.

## Objectives
- Persist financial data reliably offline.
- Support efficient reads for lists, summaries, and reports.
- Preserve future sync compatibility.

## Responsibilities
- Data Architect owns persistence design.
- Security Lead reviews sensitive data handling.
- QA validates migration and durability scenarios.

## Key Decisions
- Local database is the MVP source of truth.
- Records should include stable local identifiers and future-ready remote identity fields when approved.
- Migrations must be explicit, reversible where possible, and tested.
- Financial amounts must avoid floating-point ambiguity.

## Open Questions
- Which database engine will be selected?
- What backup/export format is required?
- How should deleted records be represented for future sync?

## Future Improvements
- Migration playbook.
- Database diagram.
- Backup and restore testing.

## References
- `10_Data_Modeling.md`
- `12_Offline_First_Strategy.md`
- `13_Sync_Architecture.md`
- `17_Performance.md`

## Changelog
- 2026-07-18: Created database design guide.
## Cross References

- [Project Context](../.ai/PROJECT_CONTEXT.md)
- [AI Rules](../.ai/AI_RULES.md)
- [Documentation Guide](../docs/DOCUMENTATION_GUIDE.md)
- [Documentation Home](../docs/README.md)