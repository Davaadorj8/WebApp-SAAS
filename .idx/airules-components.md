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
