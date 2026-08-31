# Guardrails — the known pitfalls, and the numbers you must not move

This document is the target of gate step 2, "Honor the guardrails", in
[`engineering-discipline.md`](engineering-discipline.md). It holds the pitfalls a
task author must take into account **before** writing code, so the team does not
re-derive a known trap every time.

It is a generic template. It merges two kinds of guardrail that many projects keep
in separate files — **decision gates** (pre-registered pass/fail rules) and
**validation** (how you check you are not fooling yourself). Keep them together or
split them; the rule is that both exist and both are read before work starts.

> **How to adapt this file.** Replace every `‹…›` marker with your project's own
> rule. Delete the sections you do not need. Keep the ones you keep short — a
> guardrail nobody reads is not a guardrail.

## In plain terms

`‹State, in one plain sentence, the single worst mistake this project can make and
what stops it — for example: "It is easy to build a result that looks great and is
wrong; the defense is to write the pass/fail numbers down before the experiment
runs."›`

## 1. Pre-registered decisions — or the goalposts move

A decision rule chosen **after** seeing the result is a fitted parameter, not a
rule. Write the pass/fail numbers first, somewhere they cannot be quietly edited.

- **What must be pre-registered:** `‹list the decisions that need a frozen rule —
  thresholds, acceptance bars, go / no-go criteria›`.
- **Where the numbers freeze:** `‹where a frozen rule is recorded so it provably
  predates the result — for example a ticket, an intent record, a committed
  config›`.
- **The bands, not a single line:** prefer **Pass / Investigate / Fail** to a
  single pass line on a noisy measure. Define "Investigate" with a rule written
  before you look — for example, one re-examination whose scope is fixed in
  advance; landing there twice counts as Fail.

## 2. Known pitfalls — the traps specific to this domain

`‹List the failure modes that have actually hurt this project or its field. For
each: the trap, why it is silent, and the check that catches it. Examples of the
kind of thing that goes here:›`

- ❌ `‹pitfall 1 — e.g. a data / input leak: future or out-of-scope information
  reaching the code that must not see it›`
- ❌ `‹pitfall 2 — e.g. a measurement that looks strong for the wrong reason›`
- ❌ `‹pitfall 3 — e.g. an environment or scale difference between test and
  production›`

### Gate pitfalls (kit-wide — keep these)

The gate is only as real as the thing that runs it. These traps let it report
success without having done its job.

- ❌ **An absolute `core.hooksPath`.** Worktrees **share** `.git/config`, so an
  absolute path binds every worktree to one checkout's hooks. A check added on a
  branch then does not run on that branch's own commits: the hook reports success
  having run something other than what the branch says it runs. It is silent
  because the hook still runs, still passes, and still uses the *right* files —
  only the *set of checks* comes from elsewhere. **The check:** install with a
  **relative** path, `git config core.hooksPath .githooks`, which git resolves per
  working tree; the `pre-commit` hook's own block 0 refuses to run when the path
  resolves outside the tree being committed to, and
  [`.githooks/tests/provenance-check.sh`](../.githooks/tests/provenance-check.sh)
  proves it. **Bound on the damage:** CI invokes each check script directly and
  never through `core.hooksPath`, so this costs a local round trip, not a landed
  bug — it is a developer-experience gap, not an open gate.
- ❌ **A check that cannot fail.** A grep whose pattern also matches its own error
  message, a fixture harness that compares only exit codes, a coverage floor that
  counts zero as success. The check: for every assertion, make it fail on purpose
  once and read the reason — a green nobody attacked is not evidence.

### Testing pitfalls (kit-wide — keep these)

These traps are not domain-specific: they hurt every project's test suite, so the
kit ships them filled. Keep them, and add your own above.

- ❌ **Testing after the code.** A test written to fit code that already "works"
  tends to encode the code's bugs as expected behaviour. The check: write the test
  first and watch it fail for the right reason
  ([strict TDD](engineering-discipline.md#requirements-traceability)).
- ❌ **Tests that depend on external state.** A test that reads a shared database, a
  live network, the wall clock, or another test's leftovers passes or fails for
  reasons unrelated to the code. The check: isolate and control every dependency,
  with a fresh fixture per run — see
  [`tests/scaling-checklist.md`](tests/scaling-checklist.md).
- ❌ **Tests that pass for the wrong reason.** A test that asserts nothing, asserts
  the wrong thing, or never actually exercises the path reports a safety that is not
  there — worse than no test. The check: confirm the test fails when the behaviour
  is broken; the red step is the proof.
- ❌ **Stale tests after a requirement changes.** When a requirement changes but its
  test does not, the suite now guards the old behaviour and blocks the new. The
  check: the [old-tests conflict rule](engineering-discipline.md#testing) — fix the
  code, update the requirement with a written reason, or retire the test; never
  weaken a passing old test.
- ❌ **Tests that slow down as the project grows.** A suite that creeps past the
  hook's patience gets skipped, and a skipped gate is no gate. The check: keep the
  cheap levels fast and cheap-first, push slow ones to CI, and bound each with
  `‹test timeout›` — see [`tests/scaling-checklist.md`](tests/scaling-checklist.md).

## 3. Validation — how you check you are not fooling yourself

A result is **untrusted** until it passes the checks below, and the pass is a
recorded event, not a memory. Order the checks cheap-first, so a failure stops the
expensive ones.

| # | Check | Pass condition | Cost |
|---|-------|----------------|------|
| 1 | `‹cheap smoke check›` | `‹what "clean" looks like›` | minutes |
| 2 | `‹stronger check›` | `‹pass condition›` | `‹cost›` |
| 3 | `‹end-of-work check›` | `‹pass condition›` | `‹cost›` |

Notes on how to read a failure: `‹which checks catch which class of bug; which are
cheap enough to wire into CI; which run once per change of a given kind›`.

**The automated gate is this validation layer, mechanized.** The cheap, always-on
checks — the [discipline linters](engineering-discipline.md#testing) the kit
ships (ADR, PRD and agent-entry) and their
[fixture self-tests](engineering-discipline.md#testing), the
[test levels](engineering-discipline.md#testing), lint, a security
scan, and the [commit-format](engineering-discipline.md#commit-messages)
check — run in the [`pre-commit` hook](engineering-discipline.md#git-hooks) for
fast local feedback and in [CI](engineering-discipline.md#continuous-integration-optional)
as the authority. Treat those checks as pre-registered pass/fail rules under
section 1: they predate any single result and are not edited to make a change
pass. Wire the "cheap enough to wire into CI" checks from the table above into
both layers.

## 4. Mechanics

- **Frozen rules do not get edited.** Changing a guardrail after it is set means a
  new version with a written reason, the old one preserved. Legitimate reasons
  exist (a bug in the measure); silent edits do not.
- **This document holds the structure; `‹your record of record›` holds the frozen
  values.** When real values exist, mirror them here as history, after the fact,
  never as the primary copy.

## Sources

`‹Link the references that justify your thresholds and checks, so a later reader
can see they are not arbitrary.›`
