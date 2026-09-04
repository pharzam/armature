# T-heh3 — Refuse to start a run when a precondition is missing

Tracks [issue #126](https://github.com/pharzam/armature/issues/126). Completed line:
[completed.md](completed.md).

## Why

A precondition that fails where it is *used* is discovered after the work that
needed it is already spent. Issue [#80](https://github.com/pharzam/armature/issues/80)
lost 1 h 40 m to a push rejected for a missing token scope, found only once the
build was done, and its thread records the fix as one interactive command by the
operator.

Checking the same precondition **first** costs seconds and converts that stall into
an immediate, named failure that a successor session can act on with no human
message. This is [R5](../issue-workflow.md#r5--deterministic-over-llm-based): a
deterministic check in place of discovering the fault the expensive way.

## Plan (R12 — ordered, test-first)

1. Open `docs/runner/` with this task's record and its one-line backlog entry.
2. Write [`docs/runner/tests/preflight-cases.sh`](../runner/tests/preflight-cases.sh)
   — one `good` case and one `bad-*` case per precondition class — and watch every
   case fail for want of the script.
3. Write [`docs/runner/preflight.sh`](../runner/preflight.sh) until the cases pass.
4. Wire the cases into
   [`run-discipline-tests.sh`](../tests/run-discipline-tests.sh), so they run in the
   `pre-commit` hook and in CI with no new CI step.
5. Update the documentation the change leaves stale (R10).
6. Close out in the same pull request.

## Definition of Done

- The pre-flight checks, at minimum: the forge credential and the scopes the run
  needs, that the worktree directory is writable and not already in use, that the
  base branch is fetchable, and that the hooks path is configured.
- It exits non-zero within ten seconds naming the **first** unmet precondition and
  the command that fixes it.
- It never prints a credential value.
- A test asserts each precondition class fails the pre-flight when that class is
  removed, and asserts *which* precondition was named rather than only that the
  check failed.
- Every adopter value it needs is read from configuration; none is guessed, and no
  `‹…›` marker is filled in to make a check pass.
- The discipline checks pass.

## Why the root `AGENTS.md` is unchanged

Considered and rejected, not overlooked. A `docs/runner/` row in its **Sources of
truth** table costs 10 words against a pre-registered budget of under 1500 that the
file already sits 4 words below, so the row would have to be paid for by cutting
unrelated prose — a change no reviewer asked for, in the file whose whole point is
that it stays an index.

It is also the wrong table. That column names the document authoritative for a
**class of rule**, and `docs/runner/` is authoritative for no rule: gate step 1 is
[`engineering-discipline.md`](../engineering-discipline.md)'s, and that document now
names the pre-flight in **Starting a task**. The chain a reader follows —
`AGENTS.md` → `engineering-discipline.md` → [`docs/runner/README.md`](../runner/README.md)
— is unbroken, so nothing in `AGENTS.md` is left stale by this change (R10).

`agents-lint.sh` agrees: its A21 requires a listing only for a shipped
`docs/*/*-lint.sh`, `docs/*/run-*-tests.sh` or `docs/*/*-check.sh`, and the
pre-flight is deliberately none of those — see the README section on why it is not
in the `## Checks you can run` block.

## Deliberately out of scope

The runner calling this pre-flight before its first step is
[#125](https://github.com/pharzam/armature/issues/125), which this task unblocks and
does not pre-empt. No runner exists yet to call it.

## Verdict

Recorded at close-out, in the pull request that lands the work.
