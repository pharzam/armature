# D-0006. Fail on a missing named suite

Date: 2026-09-07

## Status

Accepted

## Context

[`run-discipline-tests.sh`](../tests/run-discipline-tests.sh) dispatches a fixed list
of named suites, and **skipped** any whose linter file or fixture directory was absent,
so a slimmed adopter kit — one that dropped `prd/` or ships no ADRs — still ran green
without editing the runner. [ADR-0004](../adr/0004-ship-agent-entry-points.md) describes that
choice ("the fixture runner skips an absent suite").

The skip made the dispatch list non-binding. A suite could vanish — its fixtures
emptied, its linter deleted — and the gate stayed green, because the runner skipped what
it could not find rather than failing. Issue [#37](https://github.com/pharzam/armature/issues/37)
recorded exactly this: *"fixtures can vanish and the gate stays green."*

## Decision

We will make the dispatch list the contract. A suite named by a `run_dir_suite` or
`run_file_suite` call **must** have its linter file and its fixture directory; if either
is absent, the runner **fails**. An adopter who drops a suite removes its one dispatch
line, rather than relying on a silent skip.

We reject keeping the skip — it is the `#37` defect, a named suite disappearing under a
green gate. We reject a committed meta-test of the runner: a fixture that deletes a suite
to prove the runner fails would reintroduce the self-facing meta-recursion
[D-0005](D-0005-cut-the-self-facing-checks.md) removed. The behaviour is demonstrated
red→green on `#149` instead.

## Consequences

- A silently disabled suite now turns the gate red, which is the point.
- Slimming the kit becomes a **one-line dispatch edit** rather than a bare file deletion —
  a small added step for the adopter, and the only adopter-visible change. This amends
  ADR-0004's description of the skip; ADR-0004's Status now points here.
- The runner's `skipped` counter, which only ever counted an absent suite, is removed.
- **Transparency.** `T-9c5t` is a self-facing task by the independent assessment's reading
  (finding F7), and the pivot's default ([D-0004](D-0004-refocus-on-the-adopter.md)) is to
  record such a task rather than work it. It is implemented here by the repository owner's
  explicit decision over that default, with the disagreement reported on `#149`.
