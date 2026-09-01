# prd-lint self-tests

These are fixtures for [`../prd-lint.sh`](../prd-lint.sh), **not** example PRDs to
fill in. Each `<case>/` directory holds one `PRD-*.md`; the linter is pointed at
the case directory and resolves facts from the shared sibling [`facts/`](facts/).

The real run (`sh docs/prd/prd-lint.sh`, no argument) globs `docs/prd/PRD-*.md`
only — it never descends into this directory — so these fixtures never affect the
kit's own green state.

| Case | Expected | Exercises |
| ---- | -------- | --------- |
| `good` | `prd-lint: OK`, exit 0 | a well-formed PRD |
| `good-path with space` | `prd-lint: OK`, exit 0 | a **space in the case directory's own name**. The file list was a space-joined string looped over unquoted, so the one path split on **both** its spaces into three fragments — `docs/prd/tests/good-path`, `with`, and `space/PRD-0001-spaced-case-directory.md` — each handed to awk as a separate file, and none of them openable ([#76](https://github.com/pharzam/armature/issues/76)). The kit ships no `PRD-*.md`, so this linter was green on its own tree and red for an adopter on the first real PRD — this case is what makes it visible here |
| `bad-missing-fact` | FAIL, exit 1 | a requirement citing no fact |
| `bad-unknown-fact` | FAIL, exit 1 | a requirement citing a non-existent fact |
| `bad-dup-id` | FAIL, exit 1 | a duplicated requirement ID |
| `bad-moscow` | FAIL, exit 1 | a MoSCoW value outside the allowed set |
| `bad-wont-phase` | FAIL, exit 1 | a `Won't` requirement whose phase is not `—` |
| `bad-malformed-id` | FAIL, exit 1 | a requirement-like row with a malformed ID |
| `bad-matrix-mismatch` | FAIL, exit 1 | a matrix listing an ID that is not a requirement |
| `bad-empty` | FAIL, exit 1 | an unfilled skeleton with no real requirement rows |

Run one: `sh docs/prd/prd-lint.sh docs/prd/tests/good`
