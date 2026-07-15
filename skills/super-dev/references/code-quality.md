# Code quality

Produce the smallest maintainable change that preserves contracts and makes failure visible.

## Understand the contract

Before typing code, identify:

- required behavior and explicit non-goals;
- callers, public interfaces, data shape, and compatibility constraints;
- invariants that must remain true;
- realistic edge and failure cases;
- repository conventions and the nearest working analogue.

If multiple designs satisfy the request, prefer the one with fewer concepts, states, dependencies, and irreversible choices. Explain only the tradeoff that affects the user.

## Implementation

- Keep responsibilities cohesive; use guard clauses when they clarify control flow.
- Prefer explicit, unsurprising code over clever compression.
- Name from the caller's perspective; names must remain truthful after the change.
- Validate untrusted input at boundaries. Maintain internal invariants rather than repeatedly revalidating trusted state.
- Handle an error where useful recovery, translation, or context can be added. Never swallow it or catch more broadly than needed.
- Preserve useful causal information when wrapping errors.
- Prefer standard-library and existing-project capabilities. Add a dependency only when its maintenance and security cost is justified.
- Avoid speculative abstractions and configuration. Extract repeated behavior when a real second use proves the shared concept.
- Keep mutable state local. Make ownership, concurrency, retries, idempotency, and cancellation explicit when relevant.

## Security and reliability pass

For affected boundaries, check:

- authorization is enforced server-side and distinct from authentication;
- queries and commands do not concatenate untrusted input;
- secrets, tokens, and personal data are neither hardcoded nor logged;
- paths, URLs, uploads, deserialization, and redirects are constrained;
- timeouts, resource bounds, and cleanup exist where external work can stall or leak;
- partial failure cannot silently corrupt state;
- migrations and destructive changes have compatibility and rollback plans.

Apply this proportionally. Do not add irrelevant defenses to pure internal code.

## Comments and documentation

- Follow repository language rules; otherwise use English.
- Explain why a non-obvious constraint, workaround, or tradeoff exists. Do not narrate syntax.
- Document public contracts and surprising side effects; avoid restating signatures.
- Remove commented-out code, decorative banners, changelog comments, and stale TODOs introduced by the change.

## Tests

Test behavior, not implementation trivia.

- New behavior: include success, meaningful boundary, and failure cases proportional to risk.
- Bug fix: first add the smallest regression test that fails for the observed reason.
- Refactor: establish green tests before and after; do not alter behavior accidentally.
- Avoid mocks that merely reproduce the implementation. Fake only boundaries needed for determinism, speed, or failure injection.
- A test must be capable of failing. When practical, observe it fail before the fix.

## Adversarial diff review

Before completion, inspect the diff rather than relying on memory:

1. Does every changed line serve the request?
2. Did any public behavior, schema, error, or dependency change unintentionally?
3. Is there a simpler design with fewer moving parts?
4. Can empty, malformed, concurrent, slow, or partial inputs reach this code?
5. Do tests prove the requested behavior and fail for the right reason?
6. Are diagnostics actionable without exposing secrets?
7. Did the change leave dead imports, parameters, comments, fixtures, or generated artifacts?

Fix material findings; do not broaden scope into unrelated cleanup.
