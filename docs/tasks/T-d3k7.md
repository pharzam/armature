# T-d3k7 — Correct the discipline-linter count and drop the phantom agent-entry linter

Tracks [issue #196](https://github.com/pharzam/armature/issues/196). Plan, decision
record and the independent review are on the issue (R12). Completed line:
[completed.md](completed.md).

## Why

A citation audit across the docs found the discipline-linter count stated
inconsistently, and a phantom `agent-entry` linter cited as if it ships.
`engineering-discipline.md` contradicted itself (`five` at :83 vs `four` at :836);
`test-levels.md` did too (`three` at :93 vs "the five above" at :102); five
living-doc sites named an `agent-entry` linter that was cut with `agents-lint`
([D-0005](../decisions/D-0005-cut-the-self-facing-checks.md)); and the enumerations
omitted `link-lint` and `review-record-lint`. No linter guards these hand-mirrored
counts — the same class as the R-rule count.

## What

State the ground truth everywhere it appears: the kit ships **five** discipline
linters — `adr-lint`, `prd-lint`, `link-lint` (hook + CI) and `pr-link-lint`,
`review-record-lint` (CI only); `run-discipline-tests.sh` is the harness (six
suites), not a linter; the `pre-commit` runs three linters directly (ADR, PRD,
link) plus the harness. Remove every phantom `agent-entry` linter, and write the
lesson back to [`guardrails.md`](../guardrails.md#2-known-pitfalls--the-traps-specific-to-this-domain) §2.

Left untouched **by design** (frozen history — the R10 / immutable-ADR precedent):
`adr/0003:22` ("R1–R11"), `adr/0004:13` ("twelve rules"), and the `agents-lint`
history in `docs/decisions`, `docs/audit`, `docs/tasks` and `docs/links/README.md`.

## Definition of Done

Every living-doc count/set is true and internally consistent; the pre-registered
phantom-linter grep (`git grep -nE "agent-entry([^-.]|$)"`) is zero bar deliberate
history; `adr-lint`, `prd-lint`, `run-discipline-tests`, `link-lint` and
`git diff --check` all pass; a §2 pitfall records the lesson; one independent decay
round on the frozen head; close-out with the completed line and the ADR-0007
resource record.

## Verdict

Delivered. Every living-doc statement of the discipline-linter set and count now
matches the tree: five linters ship — `adr-lint`, `prd-lint`, `link-lint` (hook +
CI) and `pr-link-lint`, `review-record-lint` (CI only); `run-discipline-tests.sh`
is the harness, not a linter; the `pre-commit` runs three linters directly plus the
harness. The phantom `agent-entry` linter is gone from all five living-doc sites,
the two self-contradictions (`engineering-discipline.md` five-vs-four;
`test-levels.md` three-vs-"five above") are reconciled, and the lesson is in
`guardrails.md` §2.

One independent decay round (context- and execution-independent fresh session, on
frozen head `c818f64`) raised one material finding — the new §2 pitfall asserted
"at least seven" living mirrors but listed six and omitted `docs/ci/README.md`,
itself the hand-mirrored-count footgun. The round-1 fix (`d07442f`) dropped the
fragile exact count for "across many living docs, among them …" and named
`ci/README.md`; the same reviewer confirmed **nothing material in scope**.

Evidence: `adr-lint` OK, `prd-lint` OK, `run-discipline-tests` 81/0, `link-lint` OK
(990 links), `git diff --check` clean. Pre-registered phantom-linter grep: zero bar
the one deliberate historical mention in the new pitfall. Reviewed head `d07442f`,
cycle 1.

## Resource record

Per [ADR-0007](../adr/0007-record-task-resource-use.md); recorded, not budgeted.
Author-side work (the plan, the edits, the close-out) ran on the reasoning-tier
model; there is no execution-tier model, so the edits ran on the reasoning tier —
that limit is recorded, not implied ([ADR-0005](../adr/0005-route-work-by-model-tier.md)).
The decay review ran in a **context- and execution-independent** fresh agent
session across two turns (the round and the round-1 fix re-check). Per-part tokens
and wall-clock for the main loop are **not reported**: this harness exposes no
per-part meter to the agent, and a guess is not evidence (the degradation ADR-0007
anticipates). The independent agent session reports its own cumulative totals,
recorded below.

| Part | Expected tier | Model | Effort | Tokens | Elapsed |
| ---- | ------------- | ----- | ------ | ------ | ------- |
| The plan and the decision record | reasoning | Opus 4.8 | not reported | not reported | not reported |
| The fix (the edits) | execution | Opus 4.8 (no execution-tier model — limit recorded) | not reported | not reported | not reported |
| The decay review round (+ round-1 fix re-check) | reasoning | independent fresh agent session | not reported | ≈79,400 (cumulative) | ≈5 min (two turns) |
| Isolate, guardrails, docs sync, close-out | — | Opus 4.8 | not reported | not reported | not reported |
| **Total** | | | | not reported (main-loop parts unmeasured) | not reported |
