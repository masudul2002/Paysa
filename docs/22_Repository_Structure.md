# Repository Structure

## Purpose
Define intended repository organization for Paysa.

## Scope
Covers documentation placement, future source boundaries, test organization, assets, tooling, generated files, and naming rules. It does not create implementation structure.

## Objectives
- Make the repo easy to navigate.
- Align folders with architecture.
- Separate source, tests, documentation, assets, and generated output.

## Responsibilities
- Lead Architect owns structure.
- Engineering Lead owns enforcement.
- QA Lead owns test organization review.

## Key Decisions
- `docs/` is the documentation source of truth.
- Future source structure must reflect product features and clean architecture boundaries.
- Generated build outputs should not be treated as source documentation.
- Tests should mirror feature and layer ownership.

## Open Questions
- Should features be organized by vertical modules from MVP?
- What generated files should be committed?
- Where should design assets live?

## Future Improvements
- Repository tree proposal.
- Asset naming guide.
- Tooling directory policy.

## References
- `03_System_Architecture.md`
- `04_Clean_Architecture.md`
- `20_Coding_Standards.md`

## Changelog
- 2026-07-18: Created repository structure guide.
## Cross References

- [Project Context](../.ai/PROJECT_CONTEXT.md)
- [AI Rules](../.ai/AI_RULES.md)
- [Documentation Guide](../docs/DOCUMENTATION_GUIDE.md)
- [Documentation Home](../docs/README.md)