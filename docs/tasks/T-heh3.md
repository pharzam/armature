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
   — one built environment per precondition class — and watch every case fail for
   want of the script.
3. Write [`docs/runner/preflight.sh`](../runner/preflight.sh) until the cases pass.
4. Give the cases their **own CI job**, in CI's restore list, following
   [`nested-checkout-check.sh`](../tests/nested-checkout-check.sh) — the shape this
   repository already has for a check that needs a live repository.
5. Update the documentation the change leaves stale (R10): this record, the
   `docs/runner/` README, the glossary, `AGENTS.md`'s check list, and
   `engineering-discipline.md`'s **Starting a task**.
6. Close out in the same pull request.

## Definition of Done

- The pre-flight checks, at minimum: the forge credential and the scopes the run
  needs, that the worktree directory is usable and not already in use, that the base
  branch is fetchable, and that the hooks path is configured.
- It exits non-zero **within ten seconds** naming the **first** unmet precondition
  and the command that fixes it — and the bound is *enforced*, not left to the order
  of the checks.
- It never prints a credential value.
- The scopes it accepts are **one account's**, never the union of several.
- A test asserts each precondition class fails the pre-flight when that class is
  removed, and asserts *which* precondition was named rather than only that the
  check failed.
- Every adopter value it needs is read from configuration; none is guessed, and no
  `‹…›` marker is filled in to make a check pass.
- The discipline checks pass.

## What round one changed

The first frozen head, `0d8d743`, passed its own suite and was wrong in seven ways.
Two are worth recording here because they were defects in the *check itself*, of the
class it exists to prevent:

- **The ten-second bound was not real.** Ordering the cheap checks first bounds a
  cheap failure and says nothing about the last one. Measured against a remote that
  never answers, the pre-flight ran 44 seconds and printed nothing. Both steps that
  can reach the network now run under a wall-clock cap.
- **Scopes were unioned across accounts.** `gh` prints one block per account, and
  every `Token scopes:` line was read into one set — so a work account holding
  `repo` and a personal one holding `workflow` satisfied a requirement for both.
  That is #80's own shape, waved through by the check written to catch it.

Three more were defects in the *suite*: nothing asserted the `fix:` line, so deleting
it left every case green; `bad-forge-cli-unset` passed with its check deleted,
because the loose substring it asserted also appears in another refusal's fix line;
and the harness was not isolated from `$XDG_CONFIG_HOME`, so the operator's own
global configuration could decide whether it passed. Refusals now carry a stable
`code:` and the cases assert on that.

## Why the wiring changed

The first version added a third dispatch shape to
[`run-discipline-tests.sh`](../tests/run-discipline-tests.sh). It was withdrawn on
the plan review's second condition, and that shared file is now byte-identical to
`main`. Three reasons, in order of weight:

1. **It did not work.** `run-discipline-tests` reported **146 on `main` and 146 on
   the pull request** — the same number — because CI restores that runner from the
   default branch (#84). The delegated suite ran in the commit hook and nowhere else.
2. **It broke the runner's contract**, which is per-case `good*`/`bad*` accounting
   with a coverage floor. A harness reporting one aggregate result sits outside both.
3. **The repository already had the shape.** `nested-checkout-check.sh` builds real
   repositories, has its own CI job, is in the restore list, and is named in
   `AGENTS.md`. Following it also means the cases get *real* CI coverage on this pull
   request, because the restore step keeps a file that is not yet on the default
   branch.

## The `AGENTS.md` question, decided twice

A `docs/runner/` row in **Sources of truth** was written, refused by `agents-lint`
A7 at 1506 words against a budget of under 1500, and reverted rather than paid for by
trimming unrelated prose. It is also the wrong table: that column names the document
authoritative for a *class of rule*, and gate step 1 belongs to
[`engineering-discipline.md`](../engineering-discipline.md), which now names the
pre-flight in **Starting a task**.

What `AGENTS.md` *does* gain is one line in `## Checks you can run` for
`tests/preflight-cases.sh`, which needs only git and reaches no network — the same
bar `nested-checkout-check.sh` meets. `preflight.sh` itself stays out, because it
authenticates against a forge; that exemption is now written down in
[`docs/runner/README.md`](../runner/README.md), together with the constraint it puts
on everything added to that directory later.

## Deliberately out of scope

The runner calling this pre-flight before its first step was acceptance criterion 5.
It is **moved to [#125](https://github.com/pharzam/armature/issues/125)**, which is
where the runner is built; there is nothing here to wire, and a criterion this task
cannot satisfy is neither ticked nor left silently open.

## Verdict

Recorded at close-out, in the pull request that lands the work.
