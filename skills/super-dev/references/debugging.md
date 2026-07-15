# Systematic debugging

Rule: investigate before changing behavior. The goal is the earliest causal fault, not the latest visible symptom.

## 1. Establish facts

- Read the complete primary error, stack, timestamps, exit status, and relevant surrounding logs.
- Reproduce with the smallest reliable command and record expected versus actual behavior.
- If intermittent, record frequency and correlated input, timing, load, environment, and state. Do not call non-reproduction a fix.
- Check recent code, dependency, configuration, data, and environment changes.
- Separate facts from hypotheses. Preserve exact errors and commands.

For production incidents, stabilize user impact first with a safe, reversible mitigation when necessary. Label mitigation as such; continue root-cause work.

## 2. Localize the fault

Trace the failing value or state backward:

1. Where is it first observed wrong?
2. Which caller or boundary supplied it?
3. Where was that value created or transformed?
4. What invariant should have rejected or prevented it?

For multi-component paths, inspect one request or correlation ID across each boundary. Capture sanitized inputs, outputs, state, configuration presence, and timing. Never log secrets merely to debug faster.

Use narrowing techniques appropriate to the issue:

- compare with the nearest working path;
- binary-search commits, inputs, or pipeline stages;
- inspect ownership and happens-before relationships for concurrency;
- profile before optimizing performance;
- replace fixed sleeps with observable conditions when testing timing behavior;
- verify environment parity for "works locally" failures.

## 3. Form and test one hypothesis

Write: **X causes the failure because evidence Y; observation Z would disprove it.**

Test the smallest discriminating change or experiment. Change one variable. A failed hypothesis must be removed or reverted before the next test; do not stack speculative patches.

If evidence is insufficient, gather better evidence or research the unknown. Confidence is not evidence.

## 4. Fix at the source

1. Add the smallest regression test or deterministic reproducer and observe the expected failure.
2. Implement one root-cause fix.
3. Observe the reproducer pass for the intended reason.
4. Run adjacent and broader checks based on blast radius.
5. Remove temporary instrumentation, or explicitly retain sanitized diagnostics that have operational value.

Do not "fix" by weakening assertions, hiding errors, adding an unbounded retry, widening a catch, disabling a check, or increasing a timeout without proving timing is the cause.

## Failed-fix circuit breaker

After each failed fix, return to evidence and update the hypothesis. After three failed implementation attempts, stop patching and review assumptions and architecture with the user. Repeated failures across coupled areas often indicate a flawed model, hidden shared state, or an invalid contract.

## Intermittent, external, or environmental causes

When a fully investigated cause is outside the codebase:

- document evidence and ruled-out causes;
- add bounded timeout/retry/circuit-breaker behavior only where the operation is safe and idempotent;
- produce a specific actionable error;
- add sanitized telemetry that will distinguish the next occurrence;
- test failure handling, not only the happy path.

## Debugging receipt

Report compactly:

- **Reproduction:** command/input and observed failure.
- **Root cause:** earliest faulty assumption or transition, with evidence.
- **Fix:** why the change addresses that cause.
- **Verification:** regression and broader checks run.
- **Remaining risk:** intermittent behavior, missing environment, or unverified production condition.
