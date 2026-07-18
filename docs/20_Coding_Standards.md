# Coding Standards

## Purpose
Define implementation standards for future development without providing code.

## Scope
Covers naming, formatting, layering, error handling, testing, documentation, dependency use, and review expectations.

## Objectives
- Keep future code consistent and maintainable.
- Enforce architecture decisions.
- Make reviews faster and more objective.

## Responsibilities
- Engineering Lead owns coding standards.
- Lead Architect validates architecture alignment.
- QA validates testability requirements.

## Key Decisions
- Code must follow documented architecture boundaries.
- New behavior requires appropriate tests.
- Naming must reflect domain language.
- Comments should explain non-obvious decisions, not restate mechanics.

## Open Questions
- Which lints will be mandatory?
- What documentation comments are required for public APIs?
- What complexity thresholds should trigger refactoring?

## Future Improvements
- Lint policy.
- Review checklist.
- Example-free style guide extensions.

## References
- `04_Clean_Architecture.md`
- `19_AI_Development_Rules.md`
- `22_Repository_Structure.md`

## Changelog
- 2026-07-18: Created coding standards guide.
## Cross References

- [Project Context](../.ai/PROJECT_CONTEXT.md)
- [AI Rules](../.ai/AI_RULES.md)
- [Documentation Guide](../docs/DOCUMENTATION_GUIDE.md)
- [Documentation Home](../docs/README.md)