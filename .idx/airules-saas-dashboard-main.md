# SaaS Enterprise Dashboard - Main AI Rules (v1.1.0)

## 1. Purpose & Overview

This file provides the **core context, principles, and detailed rule navigation** specifically for the **SaaS Enterprise Dashboard** project. It builds upon the general guidelines defined in the top-level `airules.md`. **AI assistants MUST consult this file after the general guidelines and follow the links herein for specific implementation details.**

## 2. AI Persona (Project Specific Reinforcement)

While adhering to the general expert persona (defined in `airules.md`), for *this project*, your expertise specifically involves:

*   **TypeScript** (Strict, No `any`)
*   **Next.js 15+** (App Router)
*   **React** (Hooks, Context)
*   **UI:** Radix UI Primitives + Tailwind CSS v4 + CVA (shadcn/ui conventions)
*   **State:** Redux Toolkit (Typed Hooks, Slices, Async Thunks/RTK Query)
*   **Data:** Firebase Firestore SDK v9+
*   **API:** gRPC-Web
*   **Testing:** Jest + RTL + Playwright
*   **Tooling:** T3 Env, Storybook

## 3. Core Project Context (SaaS Dashboard)

*   **Type:** Multi-tenant SaaS application.
*   **Goal:** Unified business operations platform with a modular, customizable card-based dashboard.
*   **Architecture:** Modular (feature-based directories in `src/modules/`), Next.js App Router.
*   **Key Features:** Modular Card system, Real-time updates (Firestore), Role-based access control, Multi-tenancy support, Dynamic Modules/Plugins, AI Layout Suggestions.
*   **Tech Stack:** As listed in the Persona section above.

## 4. Overarching Principles (SaaS Dashboard Specific)

*   **TypeScript First:** Strict mode mandatory. No `any` types.
*   **Modularity:** Strictly respect module boundaries (`src/modules`, `src/plugins`). Shared code in `src/lib`, `src/components/ui`.
*   **Separation of Concerns:** UI (React Components) separated from Logic (Hooks, Services, Redux).
*   **Testing:** Mandatory automated tests (Unit, Integration, E2E) required for all features.
*   **Documentation:** Mandatory documentation (JSDoc, Storybook, READMEs, ADRs) following project standards.
*   **Security:** Prioritize tenant isolation (Firestore rules, backend checks) and input validation.
*   **Accessibility:** Mandatory WCAG 2.1 AA adherence for all UI.
*   **Performance:** Optimize bundle size, rendering, and data fetching.

## 5. Sub-Rules Files (SaaS Dashboard Specifics)

Consult these files for detailed rules governing specific implementation areas for *this project*:

*   **Architecture & Structure:** [`./airules-architecture.md`](./airules-architecture.md)
    *   *Covers: Directory organization, module/plugin design, separation of concerns, Next.js structure, Tech Stack details.*
*   **Components & UI:** [`./airules-components.md`](./airules-components.md)
    *   *Covers: React patterns, Radix UI usage, Tailwind CSS & CVA styling, accessibility, Storybook.*
*   **State Management:** [`./airules-state.md`](./airules-state.md)
    *   *Covers: Redux Toolkit usage (slices, thunks, selectors), typed hooks, persistence, RTK Query considerations.*
*   **API & Data Communication:** [`./airules-api.md`](./airules-api.md)
    *   *Covers: gRPC-Web client implementation, Firestore SDK usage, error handling, real-time patterns.*
*   **Documentation Standards:** [`./airules-documentation-method.md`](./airules-documentation-method.md)
    *   *Covers: JSDoc format, README structure, Storybook content, ADRs, commenting.*
*   **Testing Strategy:** [`./airules-testing.md`](./airules-testing.md)
    *   *Covers: Types of tests required, tools, coverage expectations, CI integration.*
*   **Security Guidelines:** [`./airules-security.md`](./airules-security.md)
    *   *Covers: Authentication, authorization, tenant isolation, input validation, common vulnerabilities.*\

## 6. How to Use These Project-Specific Rules

1.  **Start with General Rules:** Always begin by understanding the guidelines in the root `airules.md`.
2.  **Understand Project Context:** Use Section 3 of *this* file to grasp the specifics of the SaaS Dashboard.
3.  **Identify Task Domain:** Determine the area your task relates to (e.g., UI component, state logic).
4.  **Consult Specific Sub-Rule File:** Follow the relevant link in Section 5 above.
5.  **Apply Detailed Rules:** Implement code according to the specific patterns and constraints in the sub-rule file.
6.  **Adhere to Project Principles:** Ensure alignment with the Overarching Principles in Section 4 of *this* file.

## 7. Codebase Indexing & Chunking Reference

Refer to the main project documentation section `aiSmartInstructionImplementation` for details on how the SaaS Dashboard codebase is indexed and chunked. Use this understanding for precise navigation and modification requests.
