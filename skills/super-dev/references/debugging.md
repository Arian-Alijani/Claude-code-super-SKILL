# Debugging — systematic and safe

Iron law: NO FIX WITHOUT ROOT CAUSE. Random patches waste tokens, mask bugs, create new ones. Systematic ~4x faster than guess-and-check (15-30 min vs 2-3 h thrashing).

## Phase 1 — Investigate

1. Read the error COMPLETELY: stack trace, line numbers, codes. Answer often inside.
2. Reproduce reliably. Not reproducible → gather data, don't guess.
3. Check recent changes: `git diff`, recent commits, new deps, config, environment.
4. Multi-component system (API → service → DB): instrument each boundary — log what enters/exits — run once, see WHERE it breaks, then dig there.
5. Trace bad value backward to its origin. Fix at source, not where it surfaced.

## Phase 2 — Compare

- Find similar WORKING code in the same codebase.
- List every difference vs the broken path — never assume "that can't matter".
- Implementing a known pattern? Read the reference implementation fully, not skim.

## Phase 3 — Hypothesize

- One specific hypothesis: "X causes it because Y."
- Test with SMALLEST possible change. One variable at a time.
- Failed → new hypothesis. Never stack fix on failed fix.
- Don't know → say so, research; don't pretend.

## Phase 4 — Fix

1. Failing test reproducing the bug FIRST (automated, or one-off script if no framework).
2. One fix, addressing root cause. No "while I'm here" changes.
3. Verify: repro test passes, no other test broke.
4. Fix #3 failed → STOP. Pattern of fixes each revealing new coupling = architecture problem, not bug. Discuss with user before fix #4.

## Safety (edits during debug)

- Know the rollback point before touching anything: clean commit or stash.
- Destructive/irreversible operations (migrations, deletes, force-push): plain-language warning + explicit confirmation. Never compressed.
- Debug instrumentation is temporary — remove before commit, or mark and tell user.
- Never "fix" by weakening the test or widening a catch block.

## Red flags — stop, return to Phase 1

"Quick fix for now" · "just try changing X" · multiple changes then run tests · "probably X, let me fix" · skipping repro test · proposing fixes before tracing data flow · fix attempt #3+.

## No root cause found?

95% of the time = incomplete investigation. Truly environmental/timing/external after full process: document what was ruled out, add handling (retry/timeout/clear error) + logging for next time.
