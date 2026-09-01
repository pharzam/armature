# adr-lint self-tests

These are fixtures for [`../adr-lint.sh`](../adr-lint.sh), **not** example ADRs to
fill in. Each case is a directory holding one or more `NNNN-*.md` records and its
own `README.md` index; the linter is pointed at the case directory.

The real run (`sh docs/adr/adr-lint.sh`, no argument) globs `docs/adr/*.md` only —
it never descends into this directory — so these fixtures never affect the kit's
own green state. The [discipline-test runner](../../tests/run-discipline-tests.sh)
drives every case below and asserts the exit code.

| Case | Expected | Exercises |
| ---- | -------- | --------- |
| `good` | `adr-lint: OK`, exit 0 | two contiguous, well-formed ADRs with an index |
| `good-mention-not-link` | exit 0 — all the runner checks | a record this file names three ways and links nowhere. By eye it draws the no-orphan `WARN`; the runner cannot see that, so the case pins the exit code and no more |
| `bad-filename` | FAIL, exit 1 | a filename that is not `NNNN-kebab-case.md` |
| `bad-numbering` | FAIL, exit 1 | a gap in the sequence (0001 then 0003) |
| `bad-status` | FAIL, exit 1 | a `## Status` value outside the allowed set |
| `bad-missing-section` | FAIL, exit 1 | an ADR missing a required `## Decision` section |
| `bad-no-index` | FAIL, exit 1 | a valid ADR the case `README.md` does not list |

Each `bad-*` case is otherwise valid, so it fails for its own single reason.

Every case whose records reach the per-record checks draws the non-fatal
no-orphan `WARN`, one per record — a fixture record is not linked from a real
plan, and since the check began skipping fixture directories it cannot be linked
from a neighbouring case either. `bad-filename` is the exception, and shows where
the boundary is: its record is rejected by the filename rule before the per-record
checks run, so it draws none. Exit codes are unaffected, which is all the runner
asserts, so a `bad-*` case still fails for its own single reason and a `good*`
case still passes.

Run one: `sh docs/adr/adr-lint.sh docs/adr/tests/good`

## This file is half of `good-mention-not-link`

The no-orphan check searches the case directory's **parent** — this directory —
and skips fixture case directories, so nothing inside a case can supply its own
inbound link. Not even its index `README.md`, whose row links the record: that
file sits in a `good-*` directory, which the check treats as test data rather
than as navigation. So the counter-example has to live here, and it does. The
three lines below name that case's record the three ways a document names one,
and **link it nowhere**:

- by shorthand, the way a review note does: ADR-0001 of that case is the record.
  The check can no longer match this form at all — it compares filenames — and
  that is the point: this is the shape that used to silence it.
- by filename in a code span, the way a citation does: `0001-mentioned-only.md`.
- link-*shaped*, inside a fence, the way a document that explains link syntax does:

```markdown
[ADR-0001](0001-mentioned-only.md)
```

This case exists because the shape it holds is not hypothetical. ADR-0007 read as
cross-linked on the day it was written, before anything linked it: `T-3v9q.md`
had used `ADR-0007` as a hypothetical counter-example back when no such record
existed, and the token match counted that sentence as an inbound link
([#73](https://github.com/pharzam/armature/issues/73)). An audit record about this
linter's loose matching was the thing that defeated this linter's loose matching.

None of the three is a link, so the `WARN` fires — with or without a trailing
slash on the argument, since the case directory is excluded by its `good-*` name
as well as by the self-exclusion, which `T-8q3f` made independent of how the
directory argument is spelled. Before
[#73](https://github.com/pharzam/armature/issues/73) **any one of the three**
silenced it: the check matched the record's stem or its `ADR-NNNN` shorthand as a
plain string anywhere in a file, so the fenced example counted as much as the
sentence, and a document that merely discusses a record was read as one that
links it. **Do not link that record from this file** — a link here ends
the case's whole purpose, and nothing mechanical would tell you. Two files can end it,
and this is one of them. The other is the ADR index two levels up, the real
[`../README.md`](../README.md), which the check appends to its search space
whatever directory it is pointed at. Neither should ever link a fixture record,
and neither is stopped from doing so.

## What this suite does not prove

**No assertion here fails if the cross-link check is deleted.** Replace
`is_cross_linked()` with `return 0` and the suite still reports `97 passed, 0
failed`. The runner compares exit codes, the missing-link report is a non-fatal
`WARN`, and no arrangement of fixtures can change that — a `bad-*` case would have
to exit 1, which a warning never does. `good-mention-not-link` is therefore a
**demonstration a reader runs**, not a test the gate runs: it pins the exit code
at 0, and the warning beside it is checked by eye.

```
sh docs/adr/adr-lint.sh docs/adr/tests/good-mention-not-link
```

`T-9c5t` in the [backlog](../../tasks/backlog.md#next) — assert *why* a linter
failed, not only that it did — is the one thing that would close this gap, for
this suite and for every other. Until it lands, treat the row above as a claim
this file makes, not one the runner proves.
