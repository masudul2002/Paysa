# Logging

## Purpose
Define privacy-safe diagnostic logging principles.

## Scope
Covers log levels, sensitive data rules, crash context, future observability, and release diagnostics.

## Objectives
- Support debugging without exposing financial data.
- Make production issues diagnosable.
- Prepare for future crash and analytics tooling.

## Responsibilities
- Engineering Lead owns logging standards.
- Security Lead reviews sensitive data risks.
- QA validates diagnostic coverage.

## Key Decisions
- Logs must not contain transaction names, amounts, notes, account names, or personal identifiers.
- Logs should capture event type, feature area, error category, and non-sensitive state.
- Debug logging must be reduced or gated for production.
- Future remote logging requires privacy review.

## Open Questions
- Which crash reporting service, if any, will be approved?
- What diagnostic data can be collected with consent?
- How long should local logs be retained?

## Future Improvements
- Logging field schema.
- Crash report triage workflow.
- Observability dashboard plan.

## References
- `14_Security.md`
- `15_Error_Handling.md`
- `24_Release_Process.md`

## Changelog
- 2026-07-18: Created logging guide.
## Cross References

- [Project Context](../.ai/PROJECT_CONTEXT.md)
- [AI Rules](../.ai/AI_RULES.md)
- [Documentation Guide](../docs/DOCUMENTATION_GUIDE.md)
- [Documentation Home](../docs/README.md)