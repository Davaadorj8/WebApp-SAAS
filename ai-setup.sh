#!/bin/bash

# Script to set up AI rule files for the SaaS Enterprise Dashboard project.
# This script creates the .idx directory and populates it with the necessary
# AI rule markdown files, defining guidelines for AI-assisted development.

# Create .idx directory if it doesn't exist
mkdir -p .idx
echo "Created/Ensured .idx directory exists."

# Create .idx/airules.md (New Parent AI Rule File)
cat << 'EOF' > .idx/airules.md
# AI Assistant General Guidelines & Entry Point

## 1. Purpose

This file provides the **initial entry point and general operational guidelines** for AI assistants interacting with projects in this repository. It defines the expected base persona and universal coding/interaction principles. **For project-specific context, principles, and detailed rules, you MUST follow the link provided in Section 5.**

## 2. Persona

You are an **expert developer** proficient in both front- and back-end development with a deep understanding of modern web technologies, including:

*   **Core Languages:** TypeScript, Node.js
*   **Frontend:** React, Next.js, Tailwind CSS (and related UI libraries like Radix UI, CVA)
*   **Backend/Cloud:** Firebase services (Firestore, Auth, etc.), Google Cloud Platform (GCP)

You create **clear, concise, documented, and readable TypeScript code.** You are an excellent troubleshooter.

## 3. Coding-specific Guidelines (Universal)

*   **Prefer TypeScript:** Always use TypeScript and adhere to its conventions (strict mode, explicit types, no `any` unless absolutely unavoidable and justified).
*   **Accessibility:** Ensure generated code is accessible (e.g., semantic HTML, ARIA attributes where needed, alt tags for images).
*   **Troubleshooting:** When analyzing errors, consider them thoroughly and in the context of the code they affect. Provide step-by-step reasoning.
*   **No Boilerplate:** Do not add placeholder code. If more information is needed to generate valid code, ask the user.
*   **Dependencies:** After suggesting adding dependencies, remind the user to install them (e.g., `npm install` or `yarn install`).
*   **Browser Compatibility:** Ensure generated frontend code is compatible with modern versions of Chrome, Safari, and Firefox.
*   **Documentation Style:** When creating user documentation (READMEs, guides), aim for clarity and adhere to common best practices (similar to the Google developer documentation style guide: <https://developers.google.com/style>).

## 4. Overall Guidelines (Interaction Style)

*   **Assume Junior Developer User:** Explain concepts clearly and provide context, assuming the user may not have expert-level knowledge of all areas.
*   **Step-by-Step Thinking:** Break down complex tasks or explanations into logical steps.
*   **Clarity and Conciseness:** Be clear and to the point in your responses.

## 5. Project-Specific Rules & Context

**This project is the SaaS Enterprise Dashboard.**

For the **detailed context, specific architectural principles, technology stack details, coding patterns, and links to specialized rules** (Components, State, API, etc.) pertaining *specifically* to the **SaaS Enterprise Dashboard**, you **MUST** consult the following file:

*   **SaaS Dashboard Main Rules:** [`./airules-saas-dashboard-main.md`](./airules-saas-dashboard-main.md)

*Follow the instructions and links within that file for project-specific guidance.*
EOF
echo "Created .idx/airules.md"

# Create .idx/airules-saas-dashboard-main.md (Old Parent AI Rule File, now 2nd Parent)
cat << 'EOF' > .idx/airules-saas-dashboard-main.md
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
EOF
echo "Created .idx/airules-saas-dashboard-main.md"

# Create .idx/airules-architecture.md
cat << 'EOF' > .idx/airules-architecture.md
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
EOF
echo "Created .idx/airules-architecture.md"

# Create .idx/airules-components.md
cat << 'EOF' > .idx/airules-components.md
# AI Rules: Components & UI Implementation

These rules govern the creation, styling, and behavior of React components within the SaaS Enterprise Dashboard.

## 1. Component Foundation & Structure

*   **Primitives:** All interactive UI elements MUST be built upon **Radix UI** primitives to ensure accessibility and headless behavior.
*   **Functional Components:** Use functional components with React Hooks exclusively. Avoid class components.
*   **TypeScript:** Components MUST be written in TypeScript (`.tsx`) with strict typing for props and internal state. Use interfaces for prop definitions.
*   **`shadcn/ui` Convention:** Follow the architectural patterns inspired by `shadcn/ui`:
    *   Use `forwardRef` for components that might need refs.
    *   Utilize a `cn` utility (from `clsx` + `tailwind-merge`) for merging Tailwind classes.
    *   Employ `Slot` from `@radix-ui/react-slot` for `asChild` prop functionality where appropriate.
*   **Naming:** Use PascalCase for component filenames and function names (e.g., `UserProfileCard.tsx`, `function UserProfileCard(...)`).
*   **File Location:** Place shared, reusable UI components in `src/components/ui` (primitives) or `src/components/{forms,layout,data}`. Module-specific components belong inside `src/modules/*/components/`.

## 2. Styling

*   **Tailwind CSS:** Use Tailwind CSS v4 utility classes for all styling. Avoid custom CSS files unless absolutely necessary for complex global styles or third-party overrides.
*   **CVA (Class Variance Authority):** MUST use CVA to define component variants (e.g., button `variant`, `size`; card `state`). Define CVA configurations alongside the component or in a dedicated `variants.ts` file.
*   **Configuration:** Adhere to the project's `tailwind.config.js` for theme values (colors, spacing, fonts).
*   **Consistency:** Maintain consistent spacing using the defined scale (multiples of 4px). Use theme colors (`primary`, `secondary`, `destructive`, etc.) defined in the config.
*   **Responsiveness:** Implement responsive designs using Tailwind's breakpoint modifiers (`sm:`, `md:`, `lg:`).

## 3. State Management within Components

*   **Local State (`useState`):** Use only for simple, non-shared UI state (e.g., input values, toggle states).
*   **Complex State:** For complex state, state shared across components, or state derived from server data, use:
    *   Custom Hooks (for reusable stateful logic).
    *   React Context (for simple, low-frequency update shared state like theme or auth).
    *   Redux Toolkit (for global application state). See [`./airules-state.md`](./airules-state.md).
*   **Avoid Prop Drilling:** Use Context or state management solutions instead of passing props down multiple levels.

## 4. Accessibility (WCAG 2.1 AA)

*   **Mandatory:** All components MUST meet WCAG 2.1 Level AA standards.
*   **Semantic HTML:** Use appropriate HTML elements (`button`, `nav`, `main`, etc.).
*   **Keyboard Navigation:** Ensure all interactive elements are focusable and operable via keyboard in a logical order.
*   **Focus Indicators:** Provide clear, visible focus states (Tailwind's `focus-visible` utilities).
*   **ARIA Attributes:** Use ARIA roles, states, and properties correctly, especially for custom components built on Radix primitives, to convey semantics to assistive technologies.
*   **Labels & Alt Text:** Provide meaningful labels for form controls (`<label htmlFor>`) and alt text for informative images.
*   **Color Contrast:** Ensure text and significant UI elements meet the 4.5:1 contrast ratio requirement (use contrast checking tools).
*   **Testing:** Test components with `axe-core` during development/testing.

## 5. Storybook

*   **Requirement:** All reusable components in `src/components/*` MUST have corresponding Storybook stories (`*.stories.tsx`).
*   **Content:** Stories should demonstrate all component variants (via CVA) and states (e.g., loading, error, disabled).
*   **Controls:** Configure Storybook Controls (`args`, `argTypes`) to allow interactive manipulation of props, especially CVA variants.
*   **Documentation:** Use MDX or JSDoc comments within stories to provide usage examples, explain props (via Autodocs/ArgTables), and link to design guidelines.
*   **Organization:** Organize stories logically within the Storybook UI.

## 6. Performance

*   **Memoization:** Use `React.memo` for components that receive complex props or render frequently without changes.
*   **Avoid Unnecessary Renders:** Optimize hook dependencies (`useEffect`, `useMemo`, `useCallback`).
*   **Dynamic Imports:** For heavy, non-critical components, consider using `next/dynamic` (see [`./airules-architecture.md`](./airules-architecture.md)).
*   **List Virtualization:** Implement virtualization for long lists or tables using libraries like `@tanstack/react-virtual`.
EOF
echo "Created .idx/airules-components.md"

# Create .idx/airules-state.md
cat << 'EOF' > .idx/airules-state.md
# AI Rules: State Management

These rules govern the implementation and usage of state management patterns, primarily using Redux Toolkit (RTK), within the SaaS Enterprise Dashboard.

## 1. Primary State Management Library

*   **Redux Toolkit (RTK):** MUST be used for managing global application state, complex shared state, and caching server state (unless RTK Query is used for the latter).
*   **React Context:** MAY be used for simple, low-frequency update shared state like theme preferences or authentication status.
*   **Local State (`useState`, `useReducer`):** Use ONLY for component-local UI state.

## 2. Redux Toolkit Implementation

*   **Store Configuration (`src/store/index.ts`):**
    *   Configure the store using `configureStore` from RTK.
    *   Combine reducers from different slices in the `reducer` option.
    *   Include default middleware (`redux-thunk`, Immer). Add custom middleware as needed (logging, analytics, persistence).
    *   Infer `RootState` and `AppDispatch` types from the store itself.
*   **Typed Hooks (`src/store/hooks.ts`):**
    *   MUST create and export typed `useAppDispatch` and `useAppSelector` hooks using the inferred `RootState` and `AppDispatch` types.
    *   Components MUST use these typed hooks instead of the plain `useDispatch` and `useSelector` from `react-redux`.
*   **Slices (`createSlice`):**
    *   Organize state logically into domain-specific slices.
    *   Place slice files within the relevant module directory (e.g., `src/modules/crm/store/contactsSlice.ts`) or in `src/store/slices/` for truly shared state.
    *   Define slices using `createSlice`, including `name`, `initialState`, and `reducers`.
    *   Use the Immer integration within reducers for immutable updates (write 'mutating' logic).
    *   Export generated action creators and the reducer.
*   **Async Logic (`createAsyncThunk` / RTK Query):**
    *   Use `createAsyncThunk` for handling asynchronous operations (API calls, database interactions) that need to interact with the Redux store.
    *   Handle pending, fulfilled, and rejected states within the slice using `extraReducers`.
    *   **Alternative:** Consider using **RTK Query** for managing server cache state. If adopted, define API endpoints using `createApi` and use generated hooks (`useGetUserQuery`, `useUpdateUserMutation`) in components. This simplifies data fetching, caching, invalidation, and loading/error state management.
*   **Selectors:**
    *   Define selectors within slice files or dedicated selector files for accessing specific parts of the state.
    *   Use `createSelector` from `reselect` to create memoized selectors for derived or computed state to optimize performance.
    *   Components SHOULD use selectors via `useAppSelector` rather than accessing nested state directly.
*   **Middleware:**
    *   Use middleware for cross-cutting concerns like logging, analytics event tracking, or handling specific side effects (e.g., offline queue synchronization).
    *   Place custom middleware in `src/store/middleware/`.
*   **Persistence (`redux-persist`):**
    *   Use `redux-persist` integrated with `localStorage` (or another storage engine) to persist critical parts of the state (e.g., user preferences, UI settings).
    *   Configure persistence carefully, potentially using `whitelist` or `blacklist` options to avoid storing sensitive or unnecessary data.

## 3. State Management Principles

*   **Single Source of Truth:** Global application state should reside within the Redux store.
*   **Immutability:** State updates MUST be immutable (RTK's Immer handles this in reducers).
*   **Predictability:** State changes should be predictable and traceable through actions.
*   **Separation:** Keep state logic separate from UI components. Components should dispatch actions and select data.
*   **Normalization:** Consider normalizing nested server data within the Redux store, especially if using `createAsyncThunk` manually, to avoid duplication and simplify updates. RTK Query often handles caching more effectively.

## 4. Context API Usage

*   Use Context API sparingly for state that:
    *   Is relatively simple.
    *   Does not change frequently.
    *   Is needed by many components at different nesting levels (e.g., theme, user auth status).
*   Avoid using Context for high-frequency updates or complex application state, as it can lead to performance issues.
*   Ensure Context providers are placed appropriately in the component tree to limit unnecessary re-renders.
EOF
echo "Created .idx/airules-state.md"

# Create .idx/airules-api.md
cat << 'EOF' > .idx/airules-api.md
# AI Rules: API & Data Communication

These rules govern communication with backend services (primarily via gRPC-Web) and interaction with the database (Firebase Firestore).

## 1. API Communication (gRPC-Web)

*   **Primary Method:** gRPC-Web is the standard for client-server API communication.
*   **Protocol Buffers (`.proto`):**
    *   Define service contracts and message structures using Protocol Buffers v3 syntax.
    *   Store `.proto` files in `src/core/proto/` organized by service/domain.
    *   Generate TypeScript client code and message types from `.proto` files during the build process (using tools like `protobuf-ts` or `protoc` with plugins).
*   **Client Implementation:**
    *   Use the generated TypeScript client code.
    *   Instantiate clients with a gRPC-Web transport (e.g., `GrpcWebFetchTransport` from `@protobuf-ts/grpcweb-transport` or the standard `grpc-web` library).
    *   Configure the correct base URL for the gRPC-Web backend endpoint.
    *   Place client instantiation and API call logic within dedicated **service files** (e.g., `src/modules/billing/services/invoiceService.ts`) or custom hooks, NOT directly in UI components.
*   **Authentication:**
    *   Handle authentication tokens (e.g., JWT from Firebase Auth) via **gRPC interceptors** (client-side middleware) to automatically attach credentials to outgoing requests.
    *   Implement token refresh logic within interceptors or auth services.
*   **Error Handling:**
    *   Wrap gRPC calls in `try...catch` blocks within service layers/hooks.
    *   Handle specific gRPC errors (`RpcError`) and map them to application-specific errors or user-friendly messages where appropriate.
    *   Log gRPC errors with relevant context.
*   **Resilience:**
    *   Implement retry mechanisms (with exponential backoff) for transient network errors, potentially using interceptors or wrapper functions.
    *   Consider implementing circuit breaker patterns for services prone to failure.
*   **Typed Communication:** Leverage the strong typing provided by generated Protobuf types for all requests and responses.

## 2. Database Operations (Firebase Firestore)

*   **SDK Usage:** Use the Firebase Client SDK (v9+ modular API) for all Firestore interactions.
*   **Initialization:** Configure and initialize the Firebase app and Firestore instance in `src/core/firebase/`.
*   **Typed Collections:** Define and use typed helper functions or constants to interact with Firestore collections, ensuring type safety for document data (e.g., using `withConverter`).
*   **Data Fetching:**
    *   Perform reads (`getDoc`, `getDocs`) within service layers or custom hooks (often triggered by Redux thunks or component effects).
    *   Use appropriate queries (`query`, `where`, `orderBy`, `limit`, `startAfter`) to fetch only necessary data.
*   **Real-time Updates (`onSnapshot`):**
    *   Set up real-time listeners using `onSnapshot` within `useEffect` hooks in components or custom hooks.
    *   Apply necessary queries to the listener.
    *   **Crucially:** Always return the `unsubscribe` function returned by `onSnapshot` from the `useEffect` cleanup function to prevent memory leaks.
    *   Handle listener errors gracefully.
*   **Data Modification (`setDoc`, `updateDoc`, `deleteDoc`):**
    *   Perform writes within service layers or hooks.
    *   Use `updateDoc` for partial updates, `setDoc` (with `merge: true` if needed) for overwriting or creating documents.
*   **Transactions & Batched Writes:**
    *   Use `runTransaction` for atomic read-modify-write operations.
    *   Use `writeBatch` for performing multiple writes atomically.
*   **Security Rules:** Rely on Firestore Security Rules for primary data validation and authorization. Frontend code should assume rules are enforced but perform basic input validation for UX.
*   **Tenant Isolation:** All Firestore queries and operations MUST include filters or conditions based on the current tenant ID, enforced by security rules.
*   **Optimistic UI:** Implement optimistic UI updates where appropriate (e.g., updating Redux state immediately after a write request is initiated), ensuring rollback mechanisms are in place if the write fails.
*   **Performance:** Adhere to Firestore best practices: use specific queries, limit data fetched, index fields, use pagination.

## 3. API Route Handlers (Next.js)

*   **Usage:** May be used for specific server-side tasks not suitable for gRPC (e.g., simple webhooks, specific integrations, server-side rendering helpers).
*   **Location:** Implement within `app/api/.../route.ts`.
*   **Implementation:** Use standard Next.js `NextRequest` and `NextResponse` objects. Ensure proper error handling, request validation, and response formatting.
*   **Security:** Apply authentication checks and rate limiting as needed.
EOF
echo "Created .idx/airules-api.md"

# Create .idx/airules-documentation-method.md
cat << 'EOF' > .idx/airules-documentation-method.md
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
EOF
echo "Created .idx/airules-documentation-method.md"

# Create .idx/airules-testing.md
cat << 'EOF' > .idx/airules-testing.md
# AI Rules: Testing Strategy & Implementation

These rules define the testing requirements and practices for the SaaS Enterprise Dashboard, ensuring code quality, reliability, and maintainability.

## 1. Testing Philosophy

*   **Mandatory:** Automated testing is a non-negotiable part of the development process.
*   **Pyramid:** Follow the testing pyramid principle: prioritize unit tests, have a good number of integration tests, and focus E2E tests on critical user flows.
*   **Confidence:** Tests should provide high confidence that the code works as expected and that refactoring does not introduce regressions.
*   **CI Integration:** All tests MUST run and pass in the CI pipeline before code can be merged.

## 2. Types of Tests & Tools

*   **Unit Tests:**
    *   **Tool:** Jest + React Testing Library (RTL).
    *   **Scope:** Test individual units in isolation (React components, hooks, utility functions, Redux reducers/selectors).
    *   **Focus:** Verify component rendering based on props/state, basic interactions (simulating user events), hook return values, utility function outputs, reducer state transitions.
    *   **Mocking:** Mock dependencies (functions, modules, API calls) using Jest's mocking capabilities (`jest.fn`, `jest.mock`).
*   **Integration Tests:**
    *   **Tool:** Jest + RTL + Mock Service Worker (MSW) or similar API mocking library.
    *   **Scope:** Test the interaction between multiple units (e.g., a component interacting with a hook that calls a service, components using shared Context, form submission logic).
    *   **Focus:** Verify that components work together correctly, data flows as expected through connected parts, interactions with mocked APIs yield correct UI updates.
    *   **API Mocking:** Use MSW to intercept and mock API requests (gRPC, REST) at the network level for realistic integration testing without needing a live backend.
*   **End-to-End (E2E) Tests:**
    *   **Tool:** Playwright.
    *   **Scope:** Test critical user flows from start to finish in a browser environment, interacting with the application as a user would.
    *   **Focus:** Verify core functionality like login/logout, creating/editing key data entities (e.g., contacts, invoices), navigating through main sections, dashboard interactions.
    *   **Environment:** Run against a deployed environment (staging) or a locally running instance with necessary backend services (potentially emulated).
*   **Visual Regression Tests:**
    *   **Tool:** Percy or Chromatic (integrated with Storybook or E2E tests).
    *   **Scope:** Detect unintended visual changes in UI components.
    *   **Focus:** Capture and compare component snapshots across code changes.
*   **Accessibility Tests:**
    *   **Tool:** `axe-core` integrated with Jest/RTL (`jest-axe`).
    *   **Scope:** Automatically check rendered component output for WCAG violations during unit/integration tests.

## 3. Implementation Guidelines

*   **Test Location:** Place test files (`*.test.tsx`, `*.spec.ts`) alongside the code they test, either in a `__tests__` subdirectory or colocated.
*   **Naming:** Use descriptive names for test suites (`describe`) and test cases (`it` or `test`) that clearly state what is being tested.
*   **Arrange-Act-Assert (AAA):** Structure tests following the AAA pattern.
*   **RTL Queries:** Prefer user-facing queries (`getByRole`, `getByLabelText`, `getByText`) over implementation details (`getByTestId` should be a last resort).
*   **User Events:** Use `@testing-library/user-event` for simulating realistic user interactions.
*   **`waitFor` / `findBy`:** Use asynchronous utilities (`waitFor`, `findBy*`) when testing asynchronous behavior (e.g., waiting for state updates after API calls).
*   **Mocking Strategy:** Be consistent with mocking. Mock at the boundary of your unit/integration scope.
*   **Test Coverage:**
    *   **Target:** Aim for 80%+ code coverage, but focus on testing critical logic and functionality rather than just hitting a number.
    *   **Measurement:** Use Jest's built-in coverage reporting.
    *   **CI Check:** Optionally enforce coverage thresholds in CI.

## 4. AI Assistant Role in Testing

*   **Test Generation:** AI SHOULD assist in generating boilerplate test files (unit, integration) based on component/hook structure and project patterns.
*   **Test Case Suggestion:** AI CAN suggest relevant test cases based on component props, states, and logic complexity.
*   **Mocking Assistance:** AI CAN help generate mock implementations for dependencies.
*   **Refactoring Tests:** When refactoring code, AI SHOULD also update corresponding tests.
*   **Verification:** AI-generated tests MUST be reviewed by developers for correctness and completeness.
EOF
echo "Created .idx/airules-testing.md"

# Create .idx/airules-security.md
cat << 'EOF' > .idx/airules-security.md
# AI Rules: Security Guidelines

These rules outline critical security considerations and practices that MUST be followed during the development of the SaaS Enterprise Dashboard.

## 1. Authentication & Authorization

*   **Authentication Provider:** Use Firebase Authentication as the primary identity provider.
*   **Session Management:** Implement secure session management. If using JWTs, ensure proper handling (secure storage, e.g., HttpOnly cookies if applicable, short expiry, refresh token strategy).
*   **Role-Based Access Control (RBAC):**
    *   Use Firebase Custom Claims to store user roles.
    *   Backend APIs (gRPC services, Route Handlers) MUST verify user authentication and authorization (based on roles/claims) before performing actions or returning data.
    *   Firestore Security Rules MUST enforce RBAC for direct database access.
    *   Frontend UI should conditionally render elements/routes based on user roles, but this is for UX only – **authorization MUST be enforced on the backend.**
*   **Password Security:** Rely on Firebase Auth for password handling (hashing, resets).
*   **Session Timeout:** Implement configurable session timeouts.

## 2. Tenant Isolation

*   **Critical Requirement:** Preventing data leakage between tenants is paramount.
*   **Database Level:**
    *   All Firestore documents MUST contain a `tenantId` field (or equivalent).
    *   Firestore Security Rules MUST enforce that users can only read/write documents matching their own `tenantId` (obtained securely from custom claims: `request.auth.token.tenant_id`).
    *   Example Rule Snippet: `allow read, write: if request.auth != null && request.auth.token.tenant_id == resource.data.tenantId;`
*   **API Level:** Backend API endpoints (gRPC, Route Handlers) MUST validate that requested resources belong to the authenticated user's tenant before returning data or performing actions.
*   **Configuration:** Ensure tenant-specific configurations are loaded securely based on the authenticated user's context.

## 3. Input Validation & Sanitization

*   **Server-Side Validation:** All data received from the client (API requests, form submissions via Server Actions) MUST be rigorously validated on the server-side before processing or storing.
    *   Validate data types, formats, lengths, ranges.
    *   Use libraries like Zod for schema validation.
*   **Sanitization:** Sanitize inputs to prevent injection attacks (XSS, NoSQL Injection, etc.). Use appropriate libraries or techniques based on the context (e.g., escaping output for HTML, using parameterized queries/SDK methods for database interaction).
*   **Client-Side Validation:** Use for UX improvement only, not as a security measure.

## 4. Preventing Common Vulnerabilities

*   **Cross-Site Scripting (XSS):**
    *   Use frameworks/libraries that automatically encode output (React does this).
    *   Be cautious when using `dangerouslySetInnerHTML`.
    *   Implement strict Content Security Policy (CSP) headers.
    *   Sanitize user-generated content stored in the database before rendering.
*   **Cross-Site Request Forgery (CSRF):**
    *   Use CSRF protection mechanisms for state-changing requests, especially if using traditional forms or session cookies (e.g., synchronizer token pattern, double submit cookie). Next.js Server Actions have built-in protection.
    *   Use `SameSite` attribute on cookies.
*   **Insecure Direct Object References (IDOR):** Prevented by proper authorization checks on the backend (verifying user/tenant ownership of requested resources).
*   **Dependency Vulnerabilities:** Regularly update dependencies using tools like Dependabot. Audit dependencies for known vulnerabilities.

## 5. API Security

*   **Rate Limiting:** Implement rate limiting on API endpoints (Route Handlers, potentially gRPC services via gateway) to prevent abuse.
*   **Authorization:** Re-emphasize: All API endpoints MUST enforce authorization.
*   **Sensitive Data:** Avoid exposing unnecessary sensitive data in API responses.
*   **Logging:** Implement detailed audit logging for security-relevant events (logins, failures, permission changes, critical data access/modification).

## 6. Secure Configuration

*   **Secrets Management:** Store secrets (API keys, database credentials) securely (e.g., environment variables managed by hosting provider secrets manager, T3 Env for type safety). DO NOT commit secrets to version control.
*   **Environment Separation:** Ensure strict separation of configuration between development, staging, and production environments.
*   **Firebase Security Rules:** Deploy and manage Firestore/Storage security rules securely.

## 7. AI Assistant Security Role

*   **Awareness:** AI MUST consider these security principles when generating code.
*   **Validation Logic:** AI SHOULD assist in generating input validation logic (e.g., Zod schemas).
*   **Secure Patterns:** AI SHOULD default to secure patterns (e.g., parameterized queries via SDK, proper authorization checks in templates).
*   **Caution:** AI suggestions involving security-critical areas (auth logic, security rules) MUST be carefully reviewed by developers.
EOF
echo "Created .idx/airules-security.md"

echo ""
echo "AI rule files setup complete in .idx/ directory."
echo "You can make this script executable by running: chmod +x ai-setup.sh"
echo "Then run it with: ./ai-setup.sh"