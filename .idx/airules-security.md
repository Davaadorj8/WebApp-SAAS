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
