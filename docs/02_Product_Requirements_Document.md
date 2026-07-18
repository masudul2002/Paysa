# Product Requirements Document

## Purpose
Define testable product requirements for Paysa.

## Scope
This document covers MVP and near-term personal finance capabilities, excluding implementation details and excluding production cloud sync delivery.

## Objectives
- Capture core user workflows.
- Define functional and non-functional requirements.
- Provide acceptance criteria for QA and future development.

## Responsibilities
- Product owns requirement priority and acceptance criteria.
- QA owns testability review.
- Architecture reviews feasibility and constraints.

## Key Decisions
- MVP includes manual transaction tracking, categories, accounts, budgets, summaries, and local persistence.
- Requirements must distinguish MVP, post-MVP, and future sync.
- Every feature must have an offline behavior.

## Open Questions
- Should recurring transactions be MVP or post-MVP?
- Should budgets be monthly only at first?
- Should reports support custom date ranges in MVP?

## Future Improvements
- Receipt attachments.
- Account reconciliation.
- Import/export workflows.
- Automated insights.

## References
- `01_Project_Overview.md`
- `05_Feature_Roadmap.md`
- `18_Testing_Strategy.md`

## Changelog
- 2026-07-18: Created initial PRD structure.

