# Project Overview

Paysa is a production-grade, offline-first personal finance manager designed for long-term maintainability, strong documentation discipline, and future cloud synchronization readiness.
This document is the single source of truth for AI assistants working in this repository.

## Cross References

- [Project Context](PROJECT_CONTEXT.md)
- [AI Rules](AI_RULES.md)
- [Documentation Home](../docs/README.md)
- [Documentation Guide](../docs/DOCUMENTATION_GUIDE.md)

# Vision

Build a trustworthy personal finance platform that remains fast, private, and dependable when offline, while creating a foundation that can evolve into a secure multi-device product over time.

# Mission

Deliver a maintainable Flutter codebase and repository workflow that supports sustainable product growth, clear architecture, and documentation-driven development from the first commit onward.

# Goals

The project aims to keep financial workflows simple, the architecture understandable, the codebase modular, and the documentation synchronized with the implementation.

# Non Goals

This repository does not prioritize rapid prototype shortcuts, ad hoc architecture changes, or feature work that bypasses documentation and review discipline.
It also does not pursue implementation details that are not aligned with the approved product direction.

# Target Users

The primary users are individuals managing personal finances, and the secondary users are maintainers, reviewers, and future contributors who need a clear and stable repository structure.

# Project Scope

Paysa currently focuses on repository foundation, documentation, architecture planning, and long-term maintainability.
Product implementation should always remain within the documented scope and approved roadmap.

# Technology Stack

The approved stack includes Flutter, Material 3, Riverpod, GoRouter, Isar, Freezed, Build Runner, Responsive Framework, and fl_chart.
The repository should remain aligned with these choices unless an explicit architecture change is approved.

# Development Philosophy

Development should favor clarity, modularity, small safe changes, and documentation-first decisions over speed or convenience.
Every change should be easy to review, easy to reason about, and easy to evolve.

# Architecture Principles

Use Clean Architecture, SOLID principles, feature-first organization, dependency inversion, and clear separation between presentation, domain, and data responsibilities.
Prefer abstractions that protect the core domain from infrastructure churn.

# Project Structure

The repository should remain organized around dedicated areas for documentation, prompts, templates, checklists, scripts, assets, tooling, and application code.
Each folder should have a narrow purpose so ownership and maintenance remain obvious.

# Design Philosophy

The product should feel calm, readable, and intentional, with reusable design patterns and a consistent visual language.
Design decisions should support clarity, accessibility, and long-term maintainability.

# Offline First Strategy

Offline capability is a first-class product requirement, so core finance workflows must remain dependable without network access.
Any future synchronization work must respect local-first behavior and avoid compromising data integrity.

# Future Cloud Sync Vision

Cloud synchronization is a planned future capability, not an assumption that should distort the current local-first architecture.
The repository should be structured so sync can be introduced through clear boundaries rather than invasive rewrites.

# Coding Philosophy

Write production-ready, reusable, and reviewable code with minimal duplication and explicit intent.
Prefer constants, small units of behavior, and names that clearly describe purpose.

# Git Workflow

Use Conventional Commits, keep commits small, keep branches focused, and avoid unrelated changes in the same change set.
Repository history should remain easy to inspect, audit, and release from.

# Branch Strategy

Use a protected `main` branch for the stable line of development and short-lived branches for focused work.
Avoid branch sprawl and do not introduce long-lived divergence without a clear reason.

# Documentation Rules

Documentation must be updated whenever architecture, workflow, or repository conventions change.
Keep docs concise, current, and directly connected to the codebase rather than aspirational or redundant.

# AI Development Workflow

AI assistants must think before coding, explain architectural decisions before implementation, avoid unnecessary code generation, and ask before changing core architecture.
Repository guidance in this document should always be treated as higher priority than ad hoc assumptions.

# Code Quality Standards

Favor clean, reviewed, and testable changes that are easy to maintain over time.
Do not accept quick fixes that create hidden debt, ambiguous boundaries, or undocumented behavior.

# Security Principles

Protect user financial data, minimize exposure, and avoid design choices that weaken confidentiality or integrity.
Security-sensitive decisions should be explicit, documented, and reviewed.

# Performance Principles

Prefer responsive user experiences, efficient data access, and predictable behavior under constrained conditions.
Performance work should support real usage, especially on lower-end devices and offline scenarios.

# Accessibility Principles

Accessibility is a required quality attribute, not an optional enhancement.
Interfaces should remain readable, navigable, and usable with assistive technologies and diverse user needs.

# Testing Philosophy

Every meaningful change should be backed by the appropriate test level, with tests treated as part of the implementation rather than an afterthought.
Prefer fast feedback, clear coverage, and tests that protect important behavior.

# Release Strategy

Release work should remain deliberate, documented, and versioned with semantic versioning discipline.
Each release should be traceable to reviewed changes and stable documentation.

# Long Term Roadmap

The long-term roadmap should evolve from repository foundation to core offline finance workflows, then to reporting, sync readiness, and secure cloud-enabled capabilities.
Future work must preserve maintainability and avoid forcing architectural rewrites.

# Document Version

1.0

# Last Updated

2026-07-18

# Owner

Paysa Lead Software Architect and Repository Maintainer

# Next Documents to Create

- Architecture decision records
- Repository workflow guidelines
- Testing strategy details
- Release process guide
