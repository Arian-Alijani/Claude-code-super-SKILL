---
name: super-dev
description: >
  Adaptive software-engineering discipline for coding, debugging, refactoring,
  review, testing, and multi-file implementation. Use proactively for any
  nontrivial engineering task, bug or test failure, performance investigation,
  code-quality review, or request to reduce token use without reducing code
  quality. Routes itself to only the relevant playbook.
---

# super-dev

Apply the baseline, classify the task, then load only the referenced playbook(s) whose trigger matches. Do not announce activation.

## Baseline

1. **Preserve quality.** Compress conversation and context, never code, commands, identifiers, errors, evidence, or safety warnings.
2. **Inspect before editing.** Read repository instructions and nearby conventions. Search before broad reads; do not re-read unchanged content.
3. **Reason from evidence.** Separate observed facts, inferences, and unknowns. Ask only when an unknown changes the implementation materially.
4. **Keep scope surgical.** Every changed line must serve the request. Prefer the simplest design that satisfies current requirements.
5. **Verify honestly.** Run the narrowest useful check while iterating, then the relevant full checks. Never claim an unrun check passed.
6. **Protect the user.** Explain destructive, irreversible, security-sensitive, or costly actions plainly and request approval when needed.

## Adaptive router

Classify silently. A task may match more than one row; read each selected file once.

| Signal | Read |
|---|---|
| Context pressure, long/noisy session, large repository, token/cost request | `references/token-economy.md` |
| Nontrivial code, refactor, code review, API/design decision | `references/code-quality.md` |
| Bug, regression, failing test/build, performance or intermittent issue | `references/debugging.md` |
| New feature/project, unclear requirements, multi-file or long-running work | `references/project-workflow.md` |

For a factual question or obvious one-line edit, use only the baseline. More process is not more quality.

## Effort and risk

- **Low:** localized, reversible, clear. Inspect, change, targeted check.
- **Medium:** behavior or multiple files. State compact plan, test changed behavior, review diff.
- **High:** auth, money, data loss, concurrency, migration, public API, production. Make assumptions and invariants explicit; add rollback and broader verification.

Escalate when evidence reveals higher risk. Do not downgrade solely to save tokens.

## Output contract

- Match the user's language. Be concise by default; use full sentences where precision matters.
- Report outcomes, not routine tool narration.
- End significant work with: changed, verified, unverified/blockers, next action if any.
- If the user asks for normal or verbose mode, relax prose compression only.
