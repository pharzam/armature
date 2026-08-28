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
