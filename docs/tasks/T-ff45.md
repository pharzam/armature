# T-ff45 — Correct the stale required-context count in docs/ci/README.md

Tracks [issue #184](https://github.com/pharzam/armature/issues/184). Completed line:
[completed.md](completed.md). Plan and its independent review are on the issue (R12).

## Why

`docs/ci/README.md:94` says "the `checks` below are the **eight** the kit's own
repository requires", but the array below lists **six** contexts and the file itself
says "The six contexts above are the ones this repository requires". A false count in a
kept, adopter-facing doc — a leftover from before two checks (`agents-lint`,
`audit-record`) were cut.

## What

Change `:94` **eight → six**. Leave the other counts, which are correct and about
*different* things: `:165` "**seven** of the **eight** jobs check out the PR's own head"
(the eight check *jobs* — five in `ci.yml` plus `pr-link`, `conventional-title`,
`review-record` — seven of which run an in-tree script); `:172` "**Two** … you may leave
out" (`pr-link`, `conventional-title`). A blind `eight → six` would corrupt the job
count — the classify-each-count discipline
[`guardrails.md`](../guardrails.md#2-known-pitfalls--the-traps-specific-to-this-domain)
§2 records.

This task is the **first started after [ADR-0007](../adr/0007-record-task-resource-use.md)
landed**, so it carries the first **resource record** (below `## Verdict`).

## Plan (R12 — ordered, test-first where a test applies)

Task card → confirm the count is inconsistent now → correct `:94` and re-verify `:165`
and `:172` are unchanged and true → run every check + a consistency grep → one
independent decay round → close out with the resource record, the completed line, and
the verdict.

## Definition of Done

See the acceptance criteria on [issue #184](https://github.com/pharzam/armature/issues/184):
`:94` reads six; the job-count and optional-count are untouched and true; every count in
the file is internally consistent; all lints and `git diff --check` pass; the task
carries a resource record (ADR-0007).

## Verdict

Corrected `docs/ci/README.md:94` (`eight` → `six`), leaving the distinct job-count
(`:165`) and optional-count (`:172`) untouched and verified true. One independent decay
round returned `nothing material in scope`; all lints pass; 42 changed lines / 2 files,
within budget.

## Resource record

Per [ADR-0007](../adr/0007-record-task-resource-use.md) — the first task recorded under
it. This harness reports tokens and elapsed time for the independent **agent** sessions
(the reviews) but not per part for the main loop, so those cells read `not reported` (the
degradation ADR-0007 anticipates, never a guess); no execution part was routed to a
lighter tier, so the whole task ran on the reasoning-tier model — the single-tier limit
[ADR-0005](../adr/0005-route-work-by-model-tier.md) says to record.

| Part | Expected tier | Model | Effort | Tokens | Elapsed |
| ---- | ------------- | ----- | ------ | ------ | ------- |
| the plan | reasoning | Opus 4.8 | not reported | not reported | not reported |
| the plan review | reasoning | an independent agent session | not reported | 63,342 | ~3 min |
| the fix | execution | Opus 4.8 | not reported | not reported | not reported |
| the decay review round | reasoning | an independent agent session | not reported | 49,514 | ~2 min |
| isolate + close-out | `—` | Opus 4.8 | not reported | not reported | not reported |
| **Total** | | | | not reported (main-loop parts unmeasured) | not reported |

