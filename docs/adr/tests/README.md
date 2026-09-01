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
| `good-mention-not-link` | `adr-lint: OK`, exit 0 | a record this file names but never links: the no-orphan `WARN` must still fire |
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
for an inbound link, so the case cannot carry its own counter-example. This README
is it. The three lines below name that case's record the three ways a document
names one, and **link it nowhere**:

- by shorthand, the way a review note does: ADR-0001 of that case is the record.
- by stem in a code span, the way a citation does: `0001-mentioned-only.md`.
- link-*shaped*, inside a fence, the way a document that explains link syntax does:

```markdown
[ADR-0001](0001-mentioned-only.md)
```

None of the three is a link, so the `WARN` must fire. Before
[#73](https://github.com/pharzam/armature/issues/73) the first two silenced it: the
check matched the record's stem or its `ADR-NNNN` shorthand as a plain string
anywhere under `docs/`, and a document that merely discusses a record was read as
one that links it. **Do not link that record from this file** — a link here ends
the case's whole purpose, and nothing mechanical would tell you.

## What this suite does not prove

**The runner asserts exit codes, not output.** A missing inbound link is a
non-fatal `WARN`, so `good-mention-not-link` pins the exit code at 0 and no more;
the warning text itself is checked by hand, by the run below. A `bad-*` case
cannot do the job — the runner requires exit 1 of one, and a warning does not
produce it. `T-9c5t` in the [backlog](../../tasks/backlog.md#next) — assert *why* a
linter failed, not only that it did — is the task that would make this machine-checkable.

**Run it without the trailing slash.** The check filters on `^$adr_dir/`, so a
directory argument that already ends in `/` builds a double slash that matches no
path, the case's own index README stops being excluded, and its link to the record
counts as the inbound one. The `WARN` is then silenced by the argument's shape
rather than by the record's state. `T-6f3w` in the backlog carries the fix
(finding A1 of [T-3v9q](../../tasks/T-3v9q.md)); the runner passes the slash, which
is why the by-hand run is the one that shows the warning:

```
sh docs/adr/adr-lint.sh docs/adr/tests/good-mention-not-link
```
