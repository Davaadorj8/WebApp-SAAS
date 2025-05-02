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
