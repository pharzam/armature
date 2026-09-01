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
| `good` | `audit-record-lint: OK`, exit 0 | a small, valid record: 3 claims, matching arithmetic, every item covered, and two follow-ups in different lifecycle states — `T-8b4r` scheduled under **Next**, `T-4x2k` done and logged |
| `good-crlf` | `audit-record-lint: OK`, exit 0 | the same case with **Windows line endings**. This linter compares whole strings everywhere — a verdict word, a claim ID, a task line — so before the carriage return was stripped it reported 37 failures on a record that violates nothing. It exists because a mutation survived without it: replace `text()` with `cat`, or delete the strip inside the two-pass block, and every other case still passed. Endings pinned by [`.gitattributes`](../../../.gitattributes) and asserted by the runner |
| `bad-uncited-claim` | FAIL, exit 1 | a standing claim with no `file:line` (block 2 — issue #55 criterion 1) |
| `bad-arithmetic` | FAIL, exit 1 | prose that says 3 of 3 stand over a table holding 1 Stands (block 3) |
| `bad-dod-uncovered` | FAIL, exit 1 | a Definition of Done row whose `Covered by` cell names a document, not a test (block 7) |
| `bad-followup-nowhere` | FAIL, exit 1 | a follow-up in **no** lifecycle state: absent from `## Now`, `## Next` and `## Log` (block 5). This is the case that proves an open follow-up still needs a line somewhere. |
| `bad-followup-in-both` | FAIL, exit 1 | a follow-up under **Next** *and* logged as done at the same time (block 5) |
| `bad-followup-twice-in-completed` | FAIL, exit 1 | a follow-up with two `## Log` entries (block 5) |
| `bad-followup-bare-completed` | FAIL, exit 1 | a `## Log` line that names the ID but carries no completion date and no issue link, so it does not show the work was done (block 5) |
| `bad-undefined-abbrev` | FAIL, exit 1 | an abbreviation used in prose with no glossary row (block 6) |
| `bad-empty-corrections` | FAIL, exit 1 | a `Corrected` verdict with an empty Corrections section (block 8) |
| `bad-item-count` | FAIL, exit 1 | a DoD item dropped from **both** tables, so the two agree with each other and disagree with the declared count (block 7) |

Each `bad-*` case is otherwise valid, so it fails for its own single reason.

The four `bad-followup-*` cases together define the follow-up lifecycle that block
5 enforces: `backlog.md` `## Now` or `## Next` while the work is open, a dated
`## Log` entry in `completed.md` once it is done, and **exactly one** of those at a
time. An earlier version of block 5 knew only `## Next`, so it failed the gate on
the promotion `backlog.md:25` documents and on completion itself.

`bad-dod-uncovered` is the case that matters most. It is the literal defect the
review of [#56](https://github.com/pharzam/armature/pull/56) blocked on — a
Definition of Done item mapped to "this file" rather than to a test — and the
first version of this linter passed it.

Two assertions of the real run are **not** exercised here, because a fixture
directory has no repository to resolve against: block 2b, which resolves every
cited path and line against the tree, and the parts of block 9 that read the real
`completed.md`. They are covered by the real run in the pre-commit hook and in CI.

Run one: `sh docs/tasks/audit-record-lint.sh docs/tasks/tests/good`
