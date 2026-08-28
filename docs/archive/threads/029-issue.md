# #29 — backlog-lint and glossary-lint report OK after an unclosed comment or code fence hides the rest of a file

*Archived from GitHub. State at archive time: OPEN. Opened 2026-08-26T16:21:15Z.*

---

## Goal

Fix a defect present in both new linters: a text-scanning state machine that ends **inside** a comment or a code fence silently discards everything after the opener, and the linter then reports success.

Found by an adversarial pass over the merged work from #16.

## Duplicate check (R2)

- [x] Searched open and closed issues. Not a duplicate. Related: #19, #21, #16.

## The two failures, reproduced

**`backlog-lint.sh` — an unclosed `<!--` hides a real violation:**

```
# Backlog
## Now

<!-- oops, never closed
- **T-zzzz** — one
- **T-zzzz** — duplicate id, should FAIL

## Next
```
```
$ sh docs/tasks/backlog-lint.sh <case>
backlog-lint: OK          <- exit 0; the duplicate id was never seen
```

**`glossary-lint.sh` — an unclosed code fence hides a real violation:**

```
# Doc
```
some code

The ZQX subsystem is undefined and should be flagged.
```
```
$ sh docs/glossary-lint.sh <glossary> <root>
glossary-lint: OK         <- exit 0; ZQX was never seen
```

## Why this matters more than the inputs suggest

Both are unlikely inputs. The **class** is not unlikely, and it is the one the kit already names: `guardrails.md` lists "Tests that pass for the wrong reason — a test that … never actually exercises the path reports a safety that is not there — worse than no test."

This is that pitfall, twice, inside the tools written to enforce the pitfall list. The same defect already appeared once in #25, where `glossary-lint` reported `OK` while scanning nothing because `awk` had aborted on a multibyte character. A guard was added there for **that** cause. The guard was too specific: it caught "zero tokens overall" but not "this one file contributed nothing".

## Solution note (R3)

- **Chosen:** make an unterminated state an explicit failure. After scanning a file, if the stripper is still inside a comment (`backlog-lint`) or the scanner is still inside a fence (`glossary-lint`), fail with a message naming the file. An unclosed marker is a real document defect in its own right, so failing is correct behaviour, not merely defensive.
- **Rejected:** *treat an unclosed opener as though it closed at end-of-file* — that silently changes what the document means and keeps the linter quiet about a broken file. *Widen the existing zero-token guard* — it is a whole-run check and cannot see a single file contributing nothing when other files contribute plenty.
- **Decision record:** this issue. A bug fix within an established design; not architecturally significant.

## Acceptance criteria

- [ ] `backlog-lint` fails, naming the file, when a comment is opened and never closed.
- [ ] `glossary-lint` fails, naming the file, when a code fence is opened and never closed.
- [ ] A fixture for each, under the existing `tests/` convention, so `discipline-tests.sh` runs them.
- [ ] Both fixtures fail against the current code and pass against the fix (R8).
- [ ] The full gate stays green: five checks plus the runner.
- [ ] The task line moves from `tasks/backlog.md` to `tasks/completed.md` in the same PR.



---

### Comment — pharzam — 2026-08-27T11:47:12Z

## Reopened — `main` does not hold this deliverable

This issue was closed as **completed**. On 2026-08-27 `main` was reset to [`2cd70ee`](https://github.com/pharzam/armature/commit/2cd70ee), which removed every tranche-1 commit. The deliverable this issue claims is therefore not on `main` today.

Leaving it closed repeats the one defect this whole round found at every layer — *a check that reports OK having checked less than it claims* ([finding R-3 in the review](https://github.com/pharzam/armature/issues/16#issuecomment-5438020512)) — this time in the issue tracker. Phase 0 of that plan states the rule plainly: **the tracker must never claim more than `main` holds.**

### Evidence, checked at `2cd70ee`

- `docs/tasks/backlog-lint.sh` — absent.
- `docs/glossary-lint.sh` — absent.

Both fixes and both fixtures went with the scripts they patched. Re-land each defect as a **red fixture first**, then the code — the reproduction on this thread is the test list.

### Where the work went

Nothing is lost. The tranche-1 history is preserved on [`backup/pre-r12-reset-999765f`](https://github.com/pharzam/armature/tree/backup/pre-r12-reset-999765f), which is **reference only, never a merge source**: each slice re-lands as a fresh pull request from clean `main`, with the review record on this thread as its test list.

### Returns in

**Phase 2** — redo tranche 1, after #37 and alongside the linter slices it patches.
