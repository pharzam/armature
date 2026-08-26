# pr-link-lint self-tests

These are fixtures for [`../pr-link-lint.sh`](../pr-link-lint.sh), **not** example
PR bodies to fill in. Each file is a whole PR/MR body; the linter is pointed at
one and asked whether it links an issue (R1).

The real run reads the body from the forge — `${{ github.event.pull_request.body }}`
on GitHub, `$CI_MERGE_REQUEST_DESCRIPTION` on GitLab — piped in on stdin. It never
reads these files, so the fixtures never affect a real check.

| Case | Expected | Exercises |
| ---- | -------- | --------- |
| `good-closes` | `pr-link-lint: OK`, exit 0 | a `Closes #NNN` link |
| `good-refs` | `pr-link-lint: OK`, exit 0 | a non-closing `Refs`/`Part of #NNN` link |
| `good-url` | `pr-link-lint: OK`, exit 0 | a full issue-URL link |
| `bad-none` | FAIL, exit 1 | a body with no linked issue |
| `bad-comment-only` | FAIL, exit 1 | an issue reference only inside an HTML comment |
| `bad-placeholder` | FAIL, exit 1 | the unfilled template's `#N` placeholder |
| `bad-id-suffix-letters` | FAIL, exit 1 | `Closes #123abc` — the id does not end at a delimiter |
| `bad-id-suffix-hyphen` | FAIL, exit 1 | `Refs #123-placeholder` — `-` continues into a slug |
| `bad-id-suffix-crossrepo` | FAIL, exit 1 | `Closes owner/repo#123abc` — same rule, cross-repo form |
| `bad-id-suffix-url` | FAIL, exit 1 | a URL ending in `/123abc`, not `/123` |

Run one:

```bash
sh docs/ci/pr-link-lint.sh docs/ci/tests/pr-link/good-closes.md   # -> OK, exit 0
sh docs/ci/pr-link-lint.sh docs/ci/tests/pr-link/bad-none.md      # -> FAIL, exit 1
```
