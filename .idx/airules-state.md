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
