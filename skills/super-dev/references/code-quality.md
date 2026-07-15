# Code quality — full playbook

Terse prose, never terse code. Code gets full engineering effort.

## Design before typing

1. Restate the problem in one line. Wrong problem = wasted tokens and time.
2. Choose the simplest design that works. Note the tradeoff you rejected in one line if nontrivial.
3. Identify invariants and edge cases that MATTER (real inputs, not imaginary ones).
4. For public interfaces: name things as the caller would guess them.

## Writing rules

- Small functions, single responsibility, guard clauses over nesting.
- Explicit over clever. Cleverness needs a WHY comment or gets rewritten.
- Handle errors at the boundary where you can act on them; don't swallow, don't blanket try/catch.
- Types/type-hints on public signatures. Internal locals: infer.
- No dead parameters, no TODO without owner context, no copy-paste blocks — extract on the SECOND duplication, not preemptively.
- Dependencies: prefer stdlib; add a package only when it clearly pays for itself.
- Security defaults: parameterize queries, validate external input at entry, never log secrets, never hardcode credentials.

## Comments standard

- English only.
- WHY, not WHAT: `# Retry: upstream flaky during deploys` good; `# increment counter` forbidden.
- Density target: most functions need zero comments. Comment appears where code cannot speak: workarounds, protocol quirks, non-obvious constraints, links to specs/issues.
- Docstrings: public API only — one line for purpose, args/returns only when non-obvious.
- Forbidden: banner blocks, changelog-in-comments, commented-out code, "end of X" markers, restating the signature.

## Self-review pass (junior-to-senior)

Before declaring done, adversarial pass over own diff:
- Would a senior reviewer flag anything as overcomplicated? Simplify.
- Any changed line NOT traceable to the request? Revert it.
- Naming: does each name still tell the truth after the change?
- Failure paths: what happens on empty input, timeout, partial failure — for cases that can actually occur?
- Concurrency/state: shared mutable state introduced? Justify or remove.

## Refactoring discipline

- Refactor only with green tests before AND after.
- One refactoring kind per commit (rename, extract, move — not all mixed).
- Behavior change and refactor never in the same commit.
