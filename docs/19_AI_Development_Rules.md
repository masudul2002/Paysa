# AI Development Rules

## Purpose
Define how AI assistants may contribute to Paysa.

## Scope
Covers documentation-first workflows, approval boundaries, code generation restrictions, review requirements, and implementation guardrails.

## Objectives
- Prevent undocumented implementation drift.
- Keep architecture decisions human-reviewable.
- Ensure AI work follows product and QA standards.

## Responsibilities
- Lead Architect owns AI rules.
- Engineering Lead reviews AI-generated changes.
- QA validates resulting behavior against documentation.

## Key Decisions
- AI must not generate Flutter or Dart implementation unless explicitly approved in a later implementation prompt.
- AI must update or reference documentation before proposing architecture changes.
- AI must distinguish facts, assumptions, and open questions.
- AI must not introduce packages without following package guidelines.

## Open Questions
- What approval level is required for AI-generated implementation?
- Should AI be allowed to draft test plans without implementation approval?
- How will AI-generated decisions be audited?

## Future Improvements
- AI contribution checklist.
- Prompt library.
- Architecture decision review template.

## References
- `00_Documentation_Approval_Checklist.md`
- `20_Coding_Standards.md`
- `21_Git_Workflow.md`
- `23_Package_Guidelines.md`

## Changelog
- 2026-07-18: Created AI development rules.
## Cross References

- [Project Context](../.ai/PROJECT_CONTEXT.md)
- [AI Rules](../.ai/AI_RULES.md)
- [Documentation Guide](../docs/DOCUMENTATION_GUIDE.md)
- [Documentation Home](../docs/README.md)