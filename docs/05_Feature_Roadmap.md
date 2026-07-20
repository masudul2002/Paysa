# Feature Roadmap

## Purpose
Prioritize features across MVP, post-MVP, beta, production, and future sync phases across both Finance and Ledger domains.

## Scope
Covers feature sequencing and rationale for both Personal Finance and Ledger modules, not implementation tasks.

## Objectives
- Keep product scope deliberate.
- Separate essential workflows from later enhancements.
- Track sync-readiness without overcommitting to cloud behavior.
- Balance Finance and Ledger domain priorities.

## Responsibilities
- Product Manager owns roadmap priority.
- Architecture reviews dependencies.
- QA reviews release readiness for each phase.

## Key Decisions
- MVP focuses on manual offline tracking for both Finance and Ledger domains.
- Dashboard, Reports, and Search are built after core transaction workflows.
- Budgets, Savings Goals, and Payment Reminders are post-MVP enhancements.
- Cloud sync remains future scope until security and identity decisions are approved.
- Ledger Notes and Attachments are post-MVP.

## Phases

### Phase 1: Foundation (Current)
- App shell, navigation, theming, DI, error handling, database
- **Accounts** (Finance) — complete
- **Categories** (Finance) — complete
- **Transactions** (Finance) — complete (Income, Expense, Transfer)
- Dashboard (Finance) — basic implementation

### Phase 2: Ledger MVP
- People (Customer / Supplier / Friend / Family)
- Give Money
- Receive Money
- Opening Balance
- Ledger History
- Outstanding Balance

### Phase 3: Finance Enhancement
- Budgets
- Savings Goals
- Reports v1 (Spending by Category, Income vs Expense, Net Worth)
- Payment Methods

### Phase 4: Ledger Enhancement
- Payment Reminders
- Notes (Ledger)
- Attachments
- Share Statement

### Phase 5: Cross-cutting
- Search (unified across both domains)
- Notifications (reminders, budget alerts, goal achievements)
- Backup & Restore
- Settings (full implementation)

### Phase 6: Future
- Cloud Sync (encrypted, user-initiated)
- Statement sharing via messaging apps
- Advanced reports and insights
- Import/export (CSV, bank statements)

## References
- `02_Product_Requirements_Document.md`
- `13_Sync_Architecture.md`
- `25_Backlog.md`

## Changelog
- 2026-07-18: Created initial roadmap.
## Cross References

- [Project Context](../.ai/PROJECT_CONTEXT.md)
- [AI Rules](../.ai/AI_RULES.md)
- [Documentation Guide](../docs/DOCUMENTATION_GUIDE.md)
- [Documentation Home](../docs/README.md)