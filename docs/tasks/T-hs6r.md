# T-hs6r — Neutralise the kept-surface citations of the deletable decision archive

Tracks [issue #182](https://github.com/pharzam/armature/issues/182), the kept-surface
follow-up from [#180](https://github.com/pharzam/armature/issues/180). Completed line:
[completed.md](completed.md). Plan and its independent review are recorded on the
issue thread (R12).

## Why

[#180](https://github.com/pharzam/armature/issues/180) renamed this repository's
decision archive to the `D-NNNN` namespace and updated the *token* on the surfaces an
adopter keeps, so their citations keep resolving. It deliberately did **not** remove
the *dependency*: four functional kept surfaces — the ones an adopter keeps verbatim
and **executes** — still name archived records (`D-0003`, `D-0006`) that leave with
`docs/decisions/` on adoption. After the adopter deletes the archive, those citations
name nothing. This is the fourth residual class after
[#164](https://github.com/pharzam/armature/issues/164) →
[#166](https://github.com/pharzam/armature/issues/166) →
[#167](https://github.com/pharzam/armature/issues/167).

## What

Make each functional kept surface **self-contained** by citing the contract's *living*
home instead of the deletable record. The review-record contract already lives in
[`engineering-discipline.md`](../engineering-discipline.md#what-a-round-records) ("What
a round records") and [Reviewing until findings decay](../engineering-discipline.md#reviewing-until-findings-decay),
and in [`issue-workflow.md`](../issue-workflow.md#r12--slice-and-prioritize) (R12);
the enforcement table already maps `review-record-lint` there. The archived `D-0003`
is only the decision that *created* the contract.

- **`review-record-lint.sh`** — repoint the `D-0003 §6` contract citations to the
  living "What a round records" / R12. The `D-0003 §5` "a later change is a new
  comment, not an edit" rule has **no living home**, so it is stated **inline**.
- **Both review-record workflows** (`docs/ci/github-actions-review-record.yml` and the
  live `.github/workflows/review-record.yml`) — the title / `name:` / header / path
  reference the living section, not the archived record.
- **`run-discipline-tests.sh`** — drop the two `(D-0006)` provenance pointers; the
  missing-suite rule is stated in full right beside them.

Comment/doc changes only — **no behaviour changes**. No ADR, no decision record.

## Out of scope (boundary)

- **`docs/adr/0004`'s Status** naming `D-0005`/`D-0006` — a *deliberate* bare-mention
  amendment trace ([D-0007](../decisions/D-0007-split-adr-archive-kit-decisions.md))
  kept legible **while the archive exists in this repo**; for an adopter it is an
  adoption-time reset of a constitutional record, not a this-repo edit.
- **`backlog.md:29`** (the re-slice note) and the kept **documentation** mentions
  (`glossary.md`'s `D-NNNN` entry, the ADR-convention bare mentions, the "delete the
  archive" adoption steps) — kit prose cleared/refilled on adoption, or definitional/
  illustrative bare text that is not a resolvable link, so `link-lint` stays green
  after deletion.

## Plan (R12 — ordered, test-first where a test applies)

1. Task card (this file) + a pre-registered grep of the four functional surfaces that
   must end returning no `D-000N` / `docs/decisions/` reference.
2. Repoint `review-record-lint.sh`; inline the `§5` rule.
3. Repoint both review-record workflows.
4. Drop the `(D-0006)` provenance in `run-discipline-tests.sh`.
5. Verify: every discipline check, the grep, the `review-record` parse of this issue's
   own record chain, and a semantic read that each repointed citation names a section
   that carries the fact.
6. Close out: move this line to [`completed.md`](completed.md), write back any lesson
   to [`guardrails.md`](../guardrails.md) §2, tick the DoD, write the verdict.

## Definition of Done

See the acceptance criteria on [issue #182](https://github.com/pharzam/armature/issues/182):
every functional kept surface reads correctly after the archive is deleted; each cites
the living home, not the deletable record; the one rule with no living home is inlined;
behaviour is unchanged (the discipline self-tests and the `review-record` parse still
pass); a grep of the four surfaces returns no archive reference.
