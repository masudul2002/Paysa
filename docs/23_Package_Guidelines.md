# Package Guidelines

## Purpose
Define dependency selection, approval, and maintenance rules.

## Scope
Covers package evaluation, licensing, maintenance health, security risk, architecture fit, replacement policy, and documentation requirements.

## Objectives
- Avoid unnecessary dependency risk.
- Choose packages that support offline-first quality.
- Keep future maintenance predictable.

## Responsibilities
- Engineering Lead owns package selection process.
- Security Lead reviews risk-sensitive packages.
- Lead Architect validates architectural fit.

## Key Decisions
- Packages must solve a real project need.
- Storage, crypto, networking, analytics, and sync packages require extra review.
- Package decisions must include alternatives considered.
- Unmaintained packages require an exit plan.

## Open Questions
- Which package license types are prohibited?
- What maintenance signals are mandatory?
- Who approves transitive risk exceptions?

## Future Improvements
- Package evaluation template.
- Approved dependency register.
- Periodic dependency audit process.

## References
- `14_Security.md`
- `20_Coding_Standards.md`
- `24_Release_Process.md`

## Changelog
- 2026-07-18: Created package guidelines.
## Cross References

- [Project Context](../.ai/PROJECT_CONTEXT.md)
- [AI Rules](../.ai/AI_RULES.md)
- [Documentation Guide](../docs/DOCUMENTATION_GUIDE.md)
- [Documentation Home](../docs/README.md)