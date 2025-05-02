# AI Rules: Documentation Standards & Methods

These rules define the standards and methods for documenting the SaaS Enterprise Dashboard codebase, ensuring clarity, maintainability, and effective knowledge sharing for both humans and AI assistants.

## 1. JSDoc Comments (`/** ... */`)

*   **Requirement:** MUST be used for all exported:
    *   Functions
    *   React Components (including props interfaces)
    *   Custom Hooks
    *   Classes (if any)
    *   Type Aliases and Interfaces (especially complex ones)
    *   Constants with non-obvious purpose
*   **Content:**
    *   **Purpose:** Clear, concise description of what the element does.
    *   **Parameters (`@param`):** Document each parameter, its type (`{type}`), and description.
    *   **Return Value (`@returns`):** Document the return value, its type (`{type}`), and description.
    *   **Props (for Components):** Describe the purpose of each prop within the interface definition or using `@param` on the component function.
    *   **Hooks:** Describe the state returned and any functions exposed.
    *   **Side Effects (`@effects` or description):** Document any significant side effects.
    *   **Usage Example (`@example`):** Provide brief usage examples where helpful.
*   **Consistency:** Use consistent formatting and terminology.

## 2. README Files (`README.md`)

*   **Root README (`./README.md`):**
    *   **Requirement:** MUST be comprehensive and up-to-date.
    *   **Sections:** MUST include:
        *   Project Title & Brief Description
        *   Badges (CI Status, Coverage, License, etc.)
        *   Table of Contents (if long)
        *   Project Overview & Goal
        *   Key Features
        *   Getting Started (Prerequisites, Installation, Running Locally - Dev, Test, Build)
        *   Architecture Overview (Link to detailed docs, mention modularity, key tech)
        *   Tech Stack Summary
        *   Directory Structure Overview
        *   Contributing Guidelines (Branching strategy, PR process, Code style)
        *   Running Tests
        *   Deployment Information
        *   License Information
        *   Links to Storybook, other relevant documentation.
*   **Directory-Level READMEs:**
    *   **Requirement:** SHOULD exist for major directories (`src/modules`, `src/core`, `src/components`, etc.) and individual modules (`src/modules/crm`).
    *   **Content:** Explain the purpose of the directory/module, its internal structure, key components/services, and any specific patterns or conventions used within it.

## 3. Storybook Documentation

*   **Scope:** All reusable UI components (`src/components/*`) MUST have stories.
*   **Stories (`*.stories.tsx`):**
    *   Demonstrate all variants and states.
    *   Use Controls addon for interactive props.
    *   Include basic usage examples in the story code.
*   **MDX Documentation (`*.mdx` or within stories):**
    *   Use MDX for richer documentation alongside stories.
    *   Provide detailed usage guidelines, best practices, "do's and don'ts".
    *   Explain the purpose and context of the component.
    *   Use Storybook `ArgsTable`, `Description`, `Source` blocks effectively.
    *   Link to related components or design principles.
*   **Autodocs:** Leverage Storybook's Autodocs feature by ensuring JSDoc comments on components and props are well-written.

## 4. Architecture Decision Records (ADRs)

*   **Requirement:** MUST be used to document significant architectural decisions, technology choices, or pattern adoptions.
*   **Location:** Store ADRs in `docs/adr/` using a sequential numbering format (e.g., `001-use-grpc-web.md`).
*   **Format:** Use a standard ADR template (e.g., Markdown Architectural Decision Records) including sections for Status, Context, Decision, Consequences.

## 5. Code Comments (Inline `//`)

*   **Usage:** Use sparingly.
*   **Purpose:** Explain *why* something is done, not *what* it does (code should be self-explanatory).
*   **Focus:** Clarify complex algorithms, non-obvious logic, workarounds, or important assumptions.
*   **Avoid:** Do not comment obvious code or use comments to disable code (use version control).

## 6. Diagrams

*   **Usage:** Use diagrams (Sequence, Component, C4 Model, Flowcharts) to illustrate complex architectures, data flows, or processes.
*   **Location:** Store diagrams in `docs/architecture/` or relevant subdirectories.
*   **Format:** Use maintainable formats like PlantUML, Mermaid (can be embedded in Markdown), or exportable formats from tools like Draw.io/Excalidraw.
*   **Consistency:** Keep diagrams up-to-date with code changes.

## 7. General Documentation Principles

*   **Clarity & Conciseness:** Write clearly and avoid jargon where possible.
*   **Accuracy:** Ensure documentation accurately reflects the current state of the code.
*   **Up-to-Date:** Documentation MUST be updated as part of the development process when code changes affect it.
*   **Discoverability:** Use clear naming, linking (e.g., from READMEs), and organization to make documentation easy to find.
*   **Audience:** Consider the audience (developers, potentially AI assistants) when writing documentation.
