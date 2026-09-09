# T-5t2q — Write a post-mortem lesson back into guardrails.md §2

Tracks [issue #174](https://github.com/pharzam/armature/issues/174), child of
[#170](https://github.com/pharzam/armature/issues/170). Completed line:
[completed.md](completed.md).

## Why

Most of "collaborative culture and shared knowledge" already ships: R6, R7 and
`Honesty and evidence` keep reasoning, coordination and failures on the issue. The one
gap is **cross-task reach** — a lesson learned on issue #N is discoverable only by
someone who reads #N. `guardrails.md` §2 already holds "known pitfalls", but no rule
says how a trap gets into it.

## Plan (R12 — ordered, test-first where a test applies)

1. Task card: this file and the [`backlog.md`](backlog.md) line.
2. Add a **write-back rule** to [`guardrails.md`](../guardrails.md) §2: how a pitfall
   gets there and by whom, and the **filter** that keeps §2 readable. Links R6, R7 and
   `Honesty and evidence` — does not restate them.
3. Hook it from **gate step 7** ("Keep the documentation current") in
   [`engineering-discipline.md`](../engineering-discipline.md) — the quality-gate list
   item and the `Keeping documentation current` section — mirrored in
   [`AGENTS.md`](../../AGENTS.md) step 7. No ninth step; the eight-step count is
   unchanged.
4. Run the discipline checks; run independent decay review rounds on a frozen head.
5. Close out: move this task's line to [`completed.md`](completed.md), tick the DoD,
   write the verdict.

## Definition of Done

- `guardrails.md` §2 states how a pitfall gets added, and by whom.
- The rule names the **filter** — what is worth writing back and what is not — so §2
  does not grow without bound.
- A named gate step (step 7) asks the question, so the rule is applied, not merely
  written.
- The change adds no new document type and no new infrastructure.
- R6, R7 and `Honesty and evidence` are **not** restated — the change links them.
- Any adopter-specific value stays a `‹…›` marker.
- `link-lint`, `run-discipline-tests` and `git diff --check` pass.
- Docs updated in the same PR (R10), including `AGENTS.md` step 7; the eight-step gate
  count is unchanged (onboarding states no count, so it is not touched).

## Verdict

_(Filled at close-out, after the decay rounds settle.)_
