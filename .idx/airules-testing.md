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
