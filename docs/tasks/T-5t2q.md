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

The cross-task-reach gap is closed. A write-back rule in
[`guardrails.md`](../guardrails.md) §2 states how a pitfall gets there and by whom —
when a task ends, its author writes back any trap the task taught that the next reader
could hit, as a new `❌` pitfall (the trap, why it is silent, the check), in the same
PR — and names the **filter** (silent failures and footguns are worth it; one-offs,
restatements and the blow-by-blow are not) so §2 does not grow without bound. R6, R7
and `Honesty and evidence` are linked, not restated, and the rule draws the boundary
between per-issue transparency and cross-task write-back.

The rule is hooked from **gate step 7** ("Keep the documentation current") in the
quality-gate list and the [`Keeping documentation current`](../engineering-discipline.md#keeping-documentation-current)
section, mirrored in [`AGENTS.md`](../../AGENTS.md) step 7, so it is applied rather than
merely written. **No ninth step** — the eight-step gate count is unchanged (the literal
"eight" lives only in `AGENTS.md` and is untouched; onboarding states no count, so it is
not edited). No new document type and no infrastructure.

Reviewed under a frozen head: round 1 (three lenses on `c1d717c` — guardrails, semantic
agreement, adversarial) returned `nothing material in scope`; no fix was needed (cycle
cap 2, used 0). Evidence: `link-lint` (841 links), `run-discipline-tests` (81 passed),
`adr-lint`, `prd-lint` and `git diff --check` all pass. Budget: 85 changed lines across
5 files, against base `bf566d2` (max 150 / ≤8).
