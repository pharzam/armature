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
The round-one record on
[#126](https://github.com/pharzam/armature/issues/126) holds each with its evidence;
three belong here because they were defects in the *check itself*, of the very class
it exists to prevent:

- **The ten-second bound was not real** — against a remote that never answers the
  pre-flight ran 44 seconds and printed nothing.
- **Scopes were unioned across accounts**, so a work account holding `repo` and a
  personal one holding `workflow` satisfied a requirement for both — #80's own shape,
  waved through by the check written to catch it.
- **The forge contract named a tool that does not meet it.** `glab` emits no
  `Token scopes:` line, so a valid credential was refused, with a fix line naming a
  command `glab` does not have. The claim was written without being measured.

Three more were defects in the *suite*, all of one kind: it reported green over a
check that had been deleted. Refusals now carry a stable `code:` and the cases assert
on that rather than on prose.

## What round two changed

The second frozen head, `d8caa2b`, was read against one question: does every claim
this branch makes about itself survive measurement? One did not, and it was round
one's last finding in a new costume — a contract measured on one shape, and false on
another the tool actually produces:

- **`gh` marks one account active per host, not one overall.** An operator logged in
  to `github.com` and to an enterprise host presents two active accounts. The parser
  matched neither "exactly one account" nor "exactly one active", so it refused a
  credential that held every scope the run needed, printed "marks none of them
  active" where both were marked, and named `gh auth switch` — which cannot make a
  two-host setup have fewer than two active accounts.

The fix selects the account by **host**, the host of `origin`'s URL, because that is
where a run pushes and opens its pull request. Activeness is the wrong axis: within
the target host an inactive block is not used, and an active block on another host is
not used either. `armature.baseRef` keeps answering the separate question of
fetchability. The suite grew to 22 cases, `good-enterprise-other-host-short` among
them — that record's own enterprise shape, which now passes.

Round two also recorded a limit this branch does **not** fix. An SSH remote presents
no OAuth token on push, so the scopes the pre-flight reads may not be the scopes the
push presents. That is [#140](https://github.com/pharzam/armature/issues/140), opened
rather than absorbed.

## What landed after the last record

Five commits landed after `8ee0a59`, ending at `91851aa`:

| Commit | Subject |
|---|---|
| `37d2b29` | refuse a broken active credential instead of reading an unused account |
| `665e74d` | attribute a broken active account to its host, not to the whole run |
| `2e5305c` | close every block boundary and fail closed on a guessed host |
| `23be470` | pin the four attribution false passes, and a valid IP-addressed forge |
| `91851aa` | treat a failed login as a block, and the exit code as a signal |

No review record on [#126](https://github.com/pharzam/armature/issues/126) covers any
of them, and no commit message cites a round. Whether they answer a round that ran
and was never posted, or work the author did unprompted, cannot be decided from the
artifacts this repository keeps — so this record says that, rather than naming a
round three that may not exist. The commit carrying this record makes one more head,
and the next round reads it.

## The two bounds this branch stands outside

A successor session reads this file first, so both are here and not only on the
issue.

- **The cycle cap.** The plan review set it at `2`. `d8caa2b` was cycle 1, `cbd8d53`
  cycle 2, and `8ee0a59` cycle 3 — declared on the issue as an overrun the operator
  directed. [ADR-0008 §2](../adr/0008-stop-the-gate-on-a-frozen-head.md#2-the-cycle-cap-and-the-non-merge-verdict)
  provides no approval that raises a cap: "Nothing raises it." The five commits above
  stand outside it as well.
- **The size budget.** The maximum is **1,000 changed lines over 10 files**, measured
  against base `19cf8d2`. The last figure recorded on the issue was **1,106** at
  `d8caa2b`; the branch measured **1,499 over 9 files** at `91851aa`, before this
  record. [#139](https://github.com/pharzam/armature/issues/139) carries the growth,
  and [ADR-0008 §5](../adr/0008-stop-the-gate-on-a-frozen-head.md#5-the-budget-record)
  says an overrun the operator has not approved blocks the merge.

## Two things that were tried and withdrawn

A third dispatch shape in
[`run-discipline-tests.sh`](../tests/run-discipline-tests.sh); that file is now
byte-identical to `main`, and [`docs/runner/README.md`](../runner/README.md) carries
the reasoning. The deciding fact was that it did not work — `run-discipline-tests`
reported **146 on `main` and 146 on the pull request**, because CI restores that
runner from the default branch (#84).

A `docs/runner/` row in `AGENTS.md`'s **Sources of truth**, refused by `agents-lint`
A7 at 1506 words against a budget of under 1500. It is the wrong table anyway: that
column names the document authoritative for a *class of rule*, and gate step 1
belongs to [`engineering-discipline.md`](../engineering-discipline.md), which now
names the pre-flight in **Starting a task**.

## Deliberately out of scope

The runner calling this pre-flight before its first step was acceptance criterion 5,
**moved to [#125](https://github.com/pharzam/armature/issues/125)** where the runner
is built: a criterion this task cannot satisfy is neither ticked nor left open.

## Verdict

Recorded at close-out, in the pull request that lands the work.
