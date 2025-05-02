# AI Rules: Architecture & Structure

These rules govern the overall structure, modularity, and architectural patterns of the SaaS Enterprise Dashboard.

## 1. Directory Structure (Module-First)

*   **Adherence:** Strictly follow the documented directory structure outlined in the main documentation (`architectureAndImplementation.directoryStructure`).
*   **`src/modules/*`:** Primary location for business domain features (e.g., `crm`, `billing`). Each module MUST be self-contained, including its own `components`, `services`, `hooks`, `types`, `store` (slice), etc.
*   **`src/plugins/*`:** Location for cross-cutting features that interact with multiple modules (e.g., `notifications`, `integrations`).
*   **`src/components/ui/*`:** Location for shared, domain-agnostic, primitive UI components (Button, Card, Input).
*   **`src/components/{forms,layout,data}`:** Location for other shared, non-primitive UI components.
*   **`src/lib/*`:** Location for shared, domain-agnostic utilities, constants, validation functions.
*   **`src/core/*`:** Location for essential, application-wide services and configurations (Auth, Firebase setup, gRPC setup, i18n).
*   **`src/hooks/*`:** Location ONLY for shared, domain-agnostic custom hooks. Module-specific hooks belong inside `src/modules/*/hooks/`.
*   **`src/store/*`:** Location for core Redux setup (store config, root reducer, typed hooks). Slices typically belong in their respective modules.
*   **`src/types/*`:** Location ONLY for truly global types. Prefer defining types within the module/feature where they are primarily used.
*   **`app/*`:** Governed by Next.js App Router conventions. API routes in `app/api/...`. UI routes organized logically, potentially using route groups `(group)`.

## 2. Modularity & Encapsulation

*   **High Cohesion:** Keep related code together within its module/plugin directory.
*   **Low Coupling:** Modules MUST NOT have direct dependencies on other modules' internal implementation details. Interaction MUST occur via:
    *   Shared services/hooks from `src/core` or `src/lib`.
    *   Shared state managed via Redux (accessed via selectors).
    *   Well-defined extension points (React Context, explicit interfaces, potentially event bus if implemented).
*   **Clear Boundaries:** Maintain strict separation between core logic/styling and module/plugin business logic.
*   **Self-Containment:** A module should ideally be removable without breaking core application functionality (though dependent features might be lost).

## 3. Separation of Concerns

*   **UI vs. Logic:** React components should primarily focus on presentation. Business logic, data fetching, and state manipulation MUST reside in hooks, services, or Redux thunks/slices.
*   **Services:** Encapsulate external interactions (API calls, database operations) within dedicated service files (e.g., `src/modules/crm/services/contactService.ts`).
*   **Hooks:** Use custom hooks to encapsulate reusable stateful logic, especially logic interacting with services or context.
*   **State:** Differentiate between local UI state (`useState`), shared UI state (Context), and global application state (Redux).

## 4. Next.js App Router Usage

*   **Server Components:** Use by default for data fetching, accessing backend resources directly, and non-interactive UI.
*   **Client Components (`"use client"`):** Use ONLY when necessary for interactivity (event handlers, `useState`, `useEffect`, browser APIs, Context consumers).
*   **Route Handlers (`route.ts`):** Implement server-side API endpoints within the `app/api/` directory.
*   **Layouts (`layout.tsx`):** Define shared UI structure for route segments.
*   **Loading/Error UI:** Implement `loading.tsx` and `error.tsx` for better UX during navigation and error states.
*   **Route Groups (`(group)`):** Use to organize routes without affecting the URL path (e.g., `(auth)`, `(dashboard)`).

## 5. Multi-Tenancy

*   **Isolation:** All data access, configuration, and features MUST respect tenant boundaries. This is primarily enforced via Firestore security rules and backend logic, but frontend code MUST pass tenant context where required.
*   **Configuration:** Tenant-specific settings or module enablement should be managed via a central configuration mechanism (potentially fetched based on tenant context).

## 6. Technology Stack Summary

*   **Framework:** Next.js 15+ (App Router)
*   **Language:** TypeScript (Strict)
*   **UI:** React, Radix UI, Tailwind CSS v4, CVA
*   **State:** Redux Toolkit
*   **Data:** Firebase Firestore
*   **API:** gRPC-Web
*   **Testing:** Jest, RTL, Playwright
*   **Tooling:** ESLint, Prettier, Storybook, T3 Env

*AI assistants MUST adhere to the established patterns and libraries for each domain.* 

## 7. Technology Stack & Configuration Details

*   **Primary Source for Dependencies:** For the **complete list of installed packages and their exact versions**, AI assistants **MUST** consult the `package.json` file in the project root.
*   **Key Configuration Files:** Understand that project configuration is managed through standard files. Refer to these for specific settings:
    *   `package.json`: Dependencies, scripts.
    *   `tsconfig.json`: TypeScript compiler options (note strict mode enforcement).
    *   `next.config.js`: Next.js specific configurations (if any).
    *   `tailwind.config.js`: Tailwind CSS theme, plugins, content paths.
    *   `.eslintrc.json` (or similar): ESLint rules and configuration.
    *   `.prettierrc.json` (or similar): Prettier formatting rules.
    *   T3 Env setup file (e.g., `src/env.mjs` or `src/env.js`): Environment variable schema and validation.
    *   Firebase configuration files (typically in `src/core/firebase/`): Initialization settings.
    *   `firestore.rules` / `storage.rules`: Firebase security rules.
*   **Version Alignment:** When suggesting code or installing dependencies, ensure compatibility with the major versions specified in the tech stack summary (Section 6) and verified against `package.json`.
*   **Configuration Consistency:** Generated code or configuration suggestions MUST align with the settings found in these key configuration files (e.g., use defined Tailwind theme colors, adhere to ESLint rules).
