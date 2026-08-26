# glossary-lint self-tests

Fixtures for [`../../glossary-lint.sh`](../../glossary-lint.sh), **not** example
glossaries to copy. Each `<case>/` directory holds a small `glossary.md` and a
`doc.md`, and the linter is pointed at the case directory.

**Why these live here and not beside the linter.** Every other linter keeps its
fixtures in a `tests/` directory next to itself. `glossary-lint.sh` sits at the
`docs/` root, where `docs/tests/` is already the test-conventions section — so its
fixtures live under that section instead, named for the linter.

The real run (`sh docs/glossary-lint.sh`, no argument) skips every path under a
`tests/` directory, so these fixtures never affect the kit's own green state. The
one exception is this README: a README is prose, so it **is** scanned, and every
abbreviation in it needs a glossary row like anywhere else.

| Case | Expected | Exercises |
| ---- | -------- | --------- |
| `good` | `glossary-lint: OK`, exit 0 | a defined abbreviation used in prose |
| `bad-undefined` | FAIL, exit 1 | an abbreviation used with no glossary row |
| `bad-unclosed-fence` | FAIL, exit 1 | a code fence opened and never closed, which would otherwise hide the rest of the file |
| `bad-dup-term` | FAIL, exit 1 | the same term defined twice |
| `bad-malformed-row` | FAIL, exit 1 | a table row without four cells |

Run one: `sh docs/glossary-lint.sh docs/tests/glossary-lint/good`

Run them all, with every other linter's fixtures:
`sh docs/tests/discipline-tests.sh`
