# Git Workflow

## Purpose
Define version control and review workflow for Paysa.

## Scope
Covers branches, commits, pull requests, review gates, documentation updates, release tags, and change traceability.

## Objectives
- Keep changes reviewable.
- Tie implementation to approved documentation.
- Maintain clean release history.

## Responsibilities
- Engineering Lead owns workflow.
- Reviewers enforce documentation and test gates.
- Release Manager owns release branch and tag process.

## Key Decisions
- Feature work should reference approved requirements or backlog items.
- PRs that change behavior must update relevant docs.
- Release branches require QA and documentation approval.
- Commit messages should describe intent and scope.

## Open Questions
- What branch naming convention will be used?
- Will conventional commits be required?
- What approvals are required for merge?

## Future Improvements
- PR template.
- Release branch policy.
- Automated checks.

## References
- `18_Testing_Strategy.md`
- `19_AI_Development_Rules.md`
- `24_Release_Process.md`

## Changelog
- 2026-07-18: Created Git workflow.
## Cross References

- [Project Context](../.ai/PROJECT_CONTEXT.md)
- [AI Rules](../.ai/AI_RULES.md)
- [Documentation Guide](../docs/DOCUMENTATION_GUIDE.md)
- [Documentation Home](../docs/README.md)