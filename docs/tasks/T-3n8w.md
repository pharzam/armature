# T-3n8w — The objective-scientist conduct standard

Tracks [issue #173](https://github.com/pharzam/armature/issues/173), child of
[#170](https://github.com/pharzam/armature/issues/170). Completed line:
[completed.md](completed.md).

## Why

The review sections reach for a conduct standard but never state it: `Who may review`
already polices its own overstatement, and `When reviewers disagree` needs a
vocabulary for a finding that survives on force rather than basis. A conduct adjective
is unfalsifiable; the fix is to make it checkable at the grain the record already
exposes — a finding's *basis*.

## Plan (R12 — ordered, test-first where a test applies)

1. Task card: this file and the [`backlog.md`](backlog.md) line.
2. State the standard in [`Reviewing until findings decay`](../engineering-discipline.md#reviewing-until-findings-decay)
   (a rule next to its use — not a new `## Reviewer conduct` section), naming the
   preacher and the inquisitor; sharpen the `Material has a test` bullet's *basis*
   clause; add a one-line pointer from `Reviewing for semantic agreement`.
3. Add an `Objective-scientist standard` entry to [`glossary.md`](../glossary.md).
4. Run the discipline checks; run independent decay review rounds on a frozen head.
5. Close out: move this task's line to [`completed.md`](completed.md), tick the DoD,
   write the verdict.

## Definition of Done

- The conduct standard is stated inside the review sections, naming both
  anti-patterns — the preacher and the inquisitor.
- The text says what a finding's *basis* must be: an observation, a test, or a cited
  clause that could have come out the other way — never a bare preference. Citing a
  written rule is a basis; an appeal to unwritten convention is not.
- The text states plainly that `nothing material in scope` is a valid round outcome.
- The text says what the standard does **not** buy — no mechanism reads it — in the
  honest register `Who may review` uses.
- No new field is added to the ten-field review record.
- The `Objective-scientist standard` term is in `glossary.md`.
- `link-lint`, `run-discipline-tests` and `git diff --check` pass.
- `engineering-discipline.md`, `glossary.md` and `AGENTS.md` agree (R10); AGENTS.md is
  touched only if a rule's wording changed — it did not.

## Verdict

_(Filled at close-out, after the decay rounds settle.)_
