# Project workflow

Use proportional structure: enough to prevent rework, not enough to become the work.

## 1. Frame the outcome

Extract from the request and repository before asking questions:

- user-visible outcome and acceptance criteria;
- constraints, existing architecture, and compatibility requirements;
- risk areas and irreversible decisions;
- explicit non-goals.

Ask one batched set of questions only when answers materially change the design. Otherwise state reasonable, reversible assumptions and proceed.

For ambiguous or expensive work, compare at most three viable approaches. Recommend one using evidence from the codebase; avoid architecture theater.

## 2. Plan in verifiable slices

Each step should produce an observable increment:

```text
Goal: <one sentence>
1. <small end-to-end change> — verify: <command or observation>
2. <next change> — verify: <command or observation>
Risks/rollback: <only material items>
Out of scope: <boundaries>
```

Track three or more steps with the available task system. Keep exactly one implementation task in progress unless truly independent work is delegated.

Prefer vertical slices over layer-by-layer scaffolding. A slice should connect the smallest necessary path from input to observable result and include its test.

## 3. Execute from repository evidence

- Read project instructions, build metadata, and nearby examples before creating new structure.
- Establish the baseline: relevant tests/build state and clean working-tree expectations.
- Implement the smallest slice; verify before extending it.
- Update the plan when evidence changes scope or design. Do not silently drift.
- Keep refactors separate from behavior changes when practical; do not block a necessary local refactor that makes the requested change safe.
- Use parallel agents only for independent research or isolated work with clear ownership and merge criteria.

## 4. Review gates

Before calling a slice complete:

1. **Specification:** Does it meet the stated outcome and non-goals?
2. **Behavior:** Is new behavior covered by a meaningful test or direct runtime verification?
3. **Quality:** Does the diff follow local conventions and avoid unnecessary complexity?
4. **Safety:** Are security, data, concurrency, compatibility, and rollback concerns handled in proportion to risk?
5. **Integration:** Do relevant full tests, lint, type checks, build, and generated-file checks pass?

Do not hide pre-existing failures. Re-run or isolate them and report evidence that distinguishes them from regressions.

## 5. Completion

Inspect `git diff` and status. Remove temporary diagnostics and accidental artifacts. Ensure documentation changes only when behavior, setup, or public contracts require them.

Handoff:

```text
Changed: <behavior and key files>
Verified: <exact checks and results>
Unverified: <honest gaps or none>
Rollback: <safe reversal point when relevant>
Next: <only if action remains>
```

## Scale

- **Trivial/local:** inspect, edit, targeted check. No formal plan.
- **Feature/multi-file:** compact plan, vertical slices, regression tests, diff review.
- **Large/high-risk:** explicit acceptance criteria, milestones, rollback, compatibility strategy, independent review where available.

Stop when acceptance criteria are met. Additional features, abstractions, and cleanup require separate justification.
