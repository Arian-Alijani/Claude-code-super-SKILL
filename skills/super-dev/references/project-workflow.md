# Project workflow — feature and project delivery

For any multi-file task, new feature, or project build. Path: grill → plan → execute → verify → hand off.

## Step 0 — Grill the plan (before building the wrong thing)

Cheapest bug is the one never written. Before coding, challenge the request:
- What is the actual goal behind the ask? (User asks for X, needs Y — surface it.)
- Ambiguity with materially different implementations → list interpretations, ask once, batch all questions together.
- Existing code that already does this or constrains the approach? Grep first.
- Smallest version that delivers the value? Propose it; scope creep is opt-in.

Skip grilling only when the request is fully specified and small.

## Step 1 — Plan (compact, verifiable)

```
Goal: [one line]
1. [step] → verify: [concrete check]
2. [step] → verify: [concrete check]
Out of scope: [explicit non-goals]
```

- Every step needs a verify. "Make it work" is not a criterion; "test X passes" is.
- 3+ steps → track with todo list, one in-progress at a time.
- Transform vague asks: "add validation" → "write tests for invalid inputs, make them pass".

## Step 2 — Execute

- Explore before create: read existing conventions (naming, structure, error style, test layout) and match them.
- Vertical slices: smallest end-to-end working increment, then extend. Not all-scaffolding-first.
- Apply code-quality playbook for every nontrivial file.
- Commit after each coherent unit — atomic, conventional format (`feat:`, `fix:`, `refactor:`), message says why.
- Stuck or discovering the plan was wrong → update plan visibly, don't silently drift.

## Step 3 — Verify

- Run each step's check as completed, full test suite + lint/build before declaring done.
- New behavior needs a test that fails without the change.
- Manual-only verification → say exactly what was and wasn't checked. Never imply tested when not.

## Step 4 — Hand off

End of significant work, 5 lines max:
```
Changed: [files]
Verified: [what ran green]
Unverified: [honest gaps]
Rollback: [commit/point]
Next: [safe next action]
```

## Scale guide

| Task size | Process |
|---|---|
| One-liner / trivial | Just do it. Verify. No ceremony. |
| Single feature | Grill briefly, inline plan, execute, verify. |
| Multi-feature / project | Full path + todo tracking + handoff per milestone. |

Ceremony proportional to risk. Process serves the code, not itself.
