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
| `good-mention-not-link` | `adr-lint: OK`, exit 0, one `WARN` | a record this file names but never links — the no-orphan `WARN` fires, and the exit code stays 0 |
| `bad-filename` | FAIL, exit 1 | a filename that is not `NNNN-kebab-case.md` |
| `bad-numbering` | FAIL, exit 1 | a gap in the sequence (0001 then 0003) |
| `bad-status` | FAIL, exit 1 | a `## Status` value outside the allowed set |
| `bad-missing-section` | FAIL, exit 1 | an ADR missing a required `## Decision` section |
| `bad-no-index` | FAIL, exit 1 | a valid ADR the case `README.md` does not list |

Each `bad-*` case is otherwise valid, so it fails for its own single reason. A
`good`-case ADR draws a non-fatal `WARN` about a missing inbound cross-link (a
fixture is not linked from a real plan); the run still exits 0, as the runner
asserts.

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
- by stem in a code span, the way a citation does: `0001-mentioned-only.md`.
- link-*shaped*, inside a fence, the way a document that explains link syntax does:

```markdown
[ADR-0001](0001-mentioned-only.md)
```

None of the three is a link, so the `WARN` fires — with or without a trailing
slash on the argument, since the case directory is excluded by its `good-*` name
rather than by the `^$adr_dir/` filter that finding A1 defeats. Before
[#73](https://github.com/pharzam/armature/issues/73) the first two silenced it:
the check matched the record's stem or its `ADR-NNNN` shorthand as a plain string
anywhere under `docs/`, and a document that merely discusses a record was read as
one that links it. **Do not link that record from this file** — a link here ends
the case's whole purpose, and nothing mechanical would tell you.

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
