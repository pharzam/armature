# audit-record-lint self-tests

These are fixtures for [`../audit-record-lint.sh`](../audit-record-lint.sh),
**not** example task records to fill in. Each case is a directory holding a
`T-3v9q.md`, a `backlog.md`, a `glossary.md` and a `completed.md`; the linter is
pointed at the case directory and reads all four from inside it.

The real run (`sh docs/tasks/audit-record-lint.sh`, no argument) reads
`docs/tasks/` and `docs/glossary.md` only — it never descends into this
directory — so these fixtures never affect the kit's own green state. The
[discipline-test runner](../../tests/run-discipline-tests.sh) drives every case
below and asserts the exit code.

| Case | Expected | Exercises |
| ---- | -------- | --------- |
| `good` | `audit-record-lint: OK`, exit 0 | a small, valid record: 3 claims, matching arithmetic, every item covered |
| `bad-uncited-claim` | FAIL, exit 1 | a standing claim with no `file:line` (block 2 — issue #55 criterion 1) |
| `bad-arithmetic` | FAIL, exit 1 | prose that says 3 of 3 stand over a table holding 1 Stands (block 3) |
| `bad-dod-uncovered` | FAIL, exit 1 | a Definition of Done row whose `Covered by` cell names a document, not a test (block 7) |
| `bad-unscheduled-followup` | FAIL, exit 1 | a follow-up named in the record with no line under **Next** (block 5) |
| `bad-undefined-abbrev` | FAIL, exit 1 | an abbreviation used in prose with no glossary row (block 6) |
| `bad-empty-corrections` | FAIL, exit 1 | a `Corrected` verdict with an empty Corrections section (block 8) |

Each `bad-*` case is otherwise valid, so it fails for its own single reason.

`bad-dod-uncovered` is the case that matters most. It is the literal defect the
review of [#56](https://github.com/pharzam/armature/pull/56) blocked on — a
Definition of Done item mapped to "this file" rather than to a test — and the
first version of this linter passed it.

Two assertions of the real run are **not** exercised here, because a fixture
directory has no repository to resolve against: block 2b, which resolves every
cited path and line against the tree, and the parts of block 9 that read the real
`completed.md`. They are covered by the real run in the pre-commit hook and in CI.

Run one: `sh docs/tasks/audit-record-lint.sh docs/tasks/tests/good`
