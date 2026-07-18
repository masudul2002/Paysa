# Documentation Guide

## Documentation Philosophy

Documentation MUST be clear, current, and directly useful for engineers, reviewers, and AI assistants.
It SHOULD explain decisions instead of repeating implementation details.

## Folder Organization

Documentation SHOULD be grouped by purpose, with each file owning one topic and one responsibility.
The repository MUST keep homepage, index, status, planning, and policy documents easy to find.

## Naming Convention

Document names MUST be descriptive, stable, and easy to sort.
Numbered prefixes MAY be used for ordered reading paths, but names MUST still describe the topic.

## Versioning

Every maintained document SHOULD include a version or revision marker when stability matters.
Major changes MUST be reflected in the document history or change log where applicable.

## Update Policy

Documentation MUST be updated whenever architecture, workflow, scope, or repository rules change.
Updates SHOULD happen in the same change set as the related technical change.

## Review Policy

Documentation changes MUST be reviewed for accuracy, consistency, and scope alignment.
Reviewers SHOULD reject wording that is vague, contradictory, or outdated.

## Ownership

Each document SHOULD have a clear owner or maintainer role.
Ownership MUST be obvious enough that questions and changes can be routed without confusion.

## Cross References

Every documentation file SHOULD link to [Project Context](../.ai/PROJECT_CONTEXT.md), [AI Rules](../.ai/AI_RULES.md), and this guide.
Cross references MUST be kept current when files move or are renamed.

## Change Log Policy

Substantial documentation updates SHOULD record what changed, why it changed, and when it changed.
Change logs MUST remain concise and should not duplicate the full document content.
