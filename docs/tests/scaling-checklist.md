# Scaling checklist

A test suite that passes today can still rot as the project grows: tests slow
down, start depending on one another, or flake until nobody trusts a red result
to mean a real bug. This file is the set of rules that keep a suite fast and
stable as it grows, sitting alongside the [test levels](test-levels.md) — every
rule below applies within a level and across all of them.

> **How to adapt this file.** The rules are the reusable content — keep them.
> Fill in `‹test timeout›` with your project's real number, and use the
> checklist as a gate whenever you review or extend the suite. Delete this note
> once you have done that.

## In plain terms

> A slow, flaky suite gets skipped, and a skipped suite catches nothing. These
> five rules keep every test fast, predictable, and safe to run alone or
> together, so the suite stays worth trusting as the project grows.

## The rules

### Independent

**Rule:** no test depends on another test's state or on the order tests run in.
Each test sets up what it needs and cleans up after itself.

**Why it matters:** a suite where test order matters cannot be run in parallel,
cannot have a single test re-run in isolation to debug it, and turns one
unrelated change into a wave of failures across tests that happen to run after
it.

**The smell:** a test fails only when the full suite runs, never alone; renaming
or reordering tests changes which ones pass.

### Deterministic

**Rule:** no uncontrolled clock, network, randomness, or ordering — the same
input produces the same result on every run.

**Why it matters:** a test that sometimes fails for no code reason teaches the
team to re-run first and read the failure second. Once that habit sets in, a
real regression looks exactly like noise.

**The smell:** a test that is re-run to make it pass, or one whose result
depends on what time it runs, what order it runs in, or what real network
endpoint answered that day.

### Fast enough for hook and CI

**Rule:** keep the cheap [test levels](test-levels.md) in the
[commit hook](../../.githooks/pre-commit) and push the slow ones to
[CI](../ci/); every test — and the hook's whole run — stays within
`‹test timeout›`.

**Why it matters:** a hook that takes minutes gets skipped or disabled, which
throws away the fast local feedback the ladder exists to give. A CI run with no
timeout can hang forever on one bad test and block everyone behind it.

**The smell:** engineers start passing `--no-verify`, or a CI run that used to
take minutes now takes an hour and nobody remembers why.

### Tagged by level

**Rule:** every test is tagged by the [level](test-levels.md) it belongs to —
unit, integration, or end-to-end (E2E) — so any one level can be run alone.

**Why it matters:** without a tag, "run just the fast tests" is not possible,
and the hook is forced to choose between running everything (slow) or guessing
(unsafe).

**The smell:** a test that is unit in name but opens a real network connection,
or a suite where nobody can say how many tests belong to which level.

### Stable interfaces

**Rule:** assert against a stable, documented contract — a return value, a
status, a state — not a brittle selector, an internal implementation detail, or
a fixed sleep waiting for something to become ready.

**Why it matters:** a test tied to incidental detail breaks on every harmless
refactor, and a test that waits on a fixed delay is both slow (padded for the
worst case) and still flaky (the one time the delay is not enough).

**The smell:** a test that fails when unrelated code is refactored, or one that
contains a fixed wait/sleep instead of waiting on the actual condition it needs.

## Checklist

- [ ] Every test runs independent of the others — shuffle the run order and it
  still passes.
- [ ] Every test is deterministic — no unmocked clock, network, or randomness
  reaches it.
- [ ] Every test, and the hook's whole run, fits within `‹test timeout›`; cheap
  levels run in the hook, slow ones in CI.
- [ ] Every test is tagged by [level](test-levels.md) (unit/integration/E2E) so
  one level can run on its own.
- [ ] Every assertion targets a stable interface, not a brittle selector or a
  fixed wait.
