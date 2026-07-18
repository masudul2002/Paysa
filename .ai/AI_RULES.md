# Purpose

This document defines mandatory rules that every AI assistant working in the Paysa repository MUST follow.

## Cross References

- [Project Context](PROJECT_CONTEXT.md)
- [AI Rules](AI_RULES.md)
- [Documentation Home](../docs/README.md)
- [Documentation Guide](../docs/DOCUMENTATION_GUIDE.md)

# AI Responsibilities

AI assistants MUST protect repository quality, preserve architectural consistency, and keep documentation synchronized with changes.
AI assistants SHOULD optimize for clarity, maintainability, and reviewability.

# AI Limitations

AI assistants MUST NOT invent requirements, infer unsupported product decisions, or introduce undocumented scope.
AI assistants MUST NOT generate Flutter implementation code unless explicitly requested for an approved task.

# Development Workflow

AI assistants MUST think before coding, explain the approach before implementation, and wait for approval when required.
AI assistants SHOULD make the smallest correct change and verify it before expanding scope.

# Repository Rules

AI assistants MUST treat the repository as documentation-driven and MUST keep changes aligned with approved project scope.
AI assistants MUST NOT modify unrelated files or introduce unapproved folder changes.

# Architecture Rules

AI assistants MUST respect approved architectural decisions and MUST raise conflicts before making changes.
AI assistants SHOULD prefer explicit boundaries, modularity, and long-term maintainability.

# Clean Architecture Rules

AI assistants MUST preserve separation between presentation, domain, and data concerns.
AI assistants MUST NOT couple UI logic directly to infrastructure or persistence details.

# SOLID Rules

AI assistants MUST design changes so responsibilities remain focused and dependencies remain easy to replace.
AI assistants SHOULD prefer small, composable units over large multipurpose constructs.

# Feature-first Rules

AI assistants MUST organize work by feature before implementation details.
AI assistants MUST keep shared abstractions intentional and limited.

# Naming Conventions

AI assistants MUST use clear, descriptive names that reveal intent.
AI assistants MUST NOT use vague, abbreviated, or misleading names when a precise name is available.

# Folder Rules

AI assistants MUST place artifacts in the correct repository folder and MUST preserve folder ownership boundaries.
AI assistants MUST NOT move or rename folders without explicit approval.

# State Management Rules

AI assistants MUST keep state management predictable, scoped, and testable.
AI assistants MUST NOT mix transient UI state with domain or persistence state.

# Riverpod Rules

AI assistants MUST use Riverpod in a way that keeps dependencies explicit and state easy to reason about.
AI assistants MUST NOT create hidden coupling through global mutable state.

# Routing Rules

AI assistants MUST keep navigation rules centralized and predictable.
AI assistants MUST NOT scatter route decisions across unrelated UI components.

# Database Rules

AI assistants MUST keep database access behind repository boundaries.
AI assistants MUST NOT allow UI code to read or write the database directly.

# Isar Rules

AI assistants MUST treat Isar as an implementation detail of the data layer.
AI assistants MUST preserve data access patterns that support future migration and sync.

# Freezed Rules

AI assistants SHOULD use immutable data models for state and domain boundaries where appropriate.
AI assistants MUST keep generated model concerns isolated from business rules.

# Theme Rules

AI assistants MUST use centralized theme decisions and MUST prefer tokens over ad hoc styling.
AI assistants MUST NOT hardcode visual values that should be design-system driven.

# UI Rules

AI assistants MUST keep widgets small, reusable, and focused on presentation.
AI assistants MUST NOT build oversized widgets that combine layout, state, and business logic.

# Material 3 Rules

AI assistants MUST align UI work with Material 3 guidance.
AI assistants MUST NOT mix incompatible design patterns without a documented reason.

# Responsive Design Rules

AI assistants MUST design for different screen sizes and form factors.
AI assistants SHOULD ensure layouts degrade gracefully instead of breaking on narrower or wider screens.

# Accessibility Rules

AI assistants MUST preserve accessibility as a required quality attribute.
AI assistants MUST NOT add visuals or interactions that reduce readability, contrast, keyboard support, or screen reader usability.

# Performance Rules

AI assistants MUST avoid unnecessary rebuilds, redundant work, and expensive operations in critical paths.
AI assistants SHOULD prefer efficient data access and lightweight UI composition.

# Security Rules

AI assistants MUST protect sensitive financial data and MUST avoid exposing secrets, tokens, or unsafe logging.
AI assistants MUST treat security changes as deliberate and reviewable.

# Offline-first Rules

AI assistants MUST preserve offline-first behavior as a core product constraint.
AI assistants MUST NOT make network availability a dependency for core finance workflows.

# Future Sync Rules

AI assistants SHOULD keep sync readiness in mind while protecting the local-first architecture.
AI assistants MUST NOT couple current local behavior to unfinished cloud assumptions.

# Error Handling Rules

AI assistants MUST handle failures explicitly and SHOULD surface recoverable states clearly.
AI assistants MUST NOT swallow errors silently or mask important failures.

# Logging Rules

AI assistants MUST keep logs useful, minimal, and free of sensitive data.
AI assistants MUST NOT log secrets, personal financial data, or noisy debug output in production paths.

# Testing Rules

AI assistants MUST generate or update the appropriate tests after implementation.
AI assistants MUST cover meaningful behavior with unit, widget, or integration tests as appropriate.

# Documentation Rules

AI assistants MUST update documentation whenever architecture, workflow, or repository guidance changes.
AI assistants SHOULD keep documentation concise, accurate, and aligned with the current repository state.

# Git Rules

AI assistants MUST use Conventional Commits and MUST keep changes focused.
AI assistants MUST NOT stage or commit unrelated work.

# Conventional Commit Rules

AI assistants MUST choose a commit type that matches the actual change and MUST keep the message concise.
AI assistants SHOULD prefer stable, descriptive commit subjects over generic wording.

# Pull Request Rules

AI assistants MUST keep pull requests small and reviewable.
AI assistants MUST include documentation and tests when the change affects behavior or contracts.

# Code Review Rules

AI assistants MUST review changes for architectural fit, safety, and maintainability.
AI assistants SHOULD flag ambiguity, hidden coupling, or incomplete testing before merge.

# Dependency Rules

AI assistants MUST justify new dependencies and MUST avoid adding packages without clear benefit.
AI assistants MUST prefer existing approved tools whenever they satisfy the requirement.

# Refactoring Rules

AI assistants SHOULD refactor only when the change improves clarity, maintainability, or correctness.
AI assistants MUST NOT mix broad refactors with unrelated feature work unless explicitly approved.

# Breaking Change Rules

AI assistants MUST NOT introduce breaking changes without explicit approval.
AI assistants MUST call out compatibility impact before proceeding with any breaking change.

# Release Rules

AI assistants MUST treat releases as documented, versioned, and traceable events.
AI assistants SHOULD ensure release notes, changelog entries, and verification steps are aligned.

# Things AI Must Never Do

AI assistants MUST NEVER generate unapproved Flutter feature code.
AI assistants MUST NEVER create business logic without a clear task.
AI assistants MUST NEVER hardcode values that belong in constants or design tokens.
AI assistants MUST NEVER bypass architecture rules, documentation rules, or approval requirements.

# Definition of Done

A task is done only when the requested change is implemented, validated, documented where needed, and ready for review or release.
AI assistants MUST confirm that the change satisfies scope, quality, and repository rules before marking work complete.
