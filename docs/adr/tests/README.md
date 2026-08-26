# adr-lint self-tests

Fixtures for [`../adr-lint.sh`](../adr-lint.sh), **not** example ADRs to copy —
copy [`../template.md`](../template.md) for that. Each `<case>/` directory holds a
small ADR set plus its own `README.md` index, and the linter is pointed at the
case directory.

The real run (`sh docs/adr/adr-lint.sh`, no argument) globs `docs/adr/*.md` only —
it never descends here — so these fixtures never affect the kit's own green state.

| Case | Expected | Exercises |
| ---- | -------- | --------- |
| `good` | `adr-lint: OK`, exit 0 | a well-formed ADR with an index row |
| `bad-numbering` | FAIL, exit 1 | numbering that does not start at `0001` |
| `bad-missing-section` | FAIL, exit 1 | a missing `## Decision` section |
| `bad-status` | FAIL, exit 1 | a `Status` outside the allowed set |
| `bad-filename` | FAIL, exit 1 | a filename that is not `NNNN-kebab-case.md` |
| `bad-no-index` | FAIL, exit 1 | a valid ADR absent from the index table |

Run one: `sh docs/adr/adr-lint.sh docs/adr/tests/good`

Run them all, with every other linter's fixtures:
`sh docs/tests/discipline-tests.sh`
