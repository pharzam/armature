# #37 — discipline-tests asserts that a linter exited 1, never why — fixtures can vanish and the gate stays green

*Archived from GitHub. State at archive time: OPEN. Opened 2026-08-27T08:13:20Z.*

---

Found by the gate-step-5 rounds on #33 — round 1 (M1, m3), round 2 (F1), round 4 (F7). Part of #16.

## The defect

`docs/tests/discipline-tests.sh` is "the gate for the gate" — its own words. It
asserts only that a `bad-*` fixture made the linter **exit 1**, never **why**. Exit
1 is the only rejection code every linter has, so the runner cannot tell "the
linter caught the defect" from "the linter could not find the file".

Four reproduced consequences, all ending in `discipline-tests: OK` and exit 0:

**1. Delete three fixtures' contents — still `OK (37 cases)`.**

```
$ rm -f docs/tests/glossary-lint/bad-undefined/*.md \
        docs/tasks/tests/bad-dup-id/*.md \
        docs/adr/tests/bad-status/*.md
$ sh docs/tests/discipline-tests.sh
discipline-tests: OK (37 cases)
```
The three "passing" cases now pass on `FAIL glossary not found`,
`FAIL missing … (the task index)` and `FAIL missing … (the ADR index)` — none of
which is the rule the fixture is named for.

**2. Delete a whole linter — the runner and the hook both stay green.**

```
$ mv docs/glossary-lint.sh away
NOTE  docs/glossary-lint.sh not present — skipped
discipline-tests: OK (32 cases, 1 set(s) skipped)
```
`.githooks/pre-commit` wraps every check in `if [ -f … ]`, so a renamed linter
leaves the hook **and** the runner green. Deleting a linter is the largest possible
linter regression, and it is reported as a pass.

**3. Rename a fixture and it vanishes without a word.** `run_case`'s `*) return 0`
arm drops anything matching neither `good*` nor `bad-*`: the count drops from 37 to
35 and nothing says so.

**4. An empty `bad-*` directory counts as a passing test.**

```
$ mkdir -p docs/adr/tests/bad-empty-dir
$ sh docs/tests/discipline-tests.sh
discipline-tests: OK (38 cases)
```

The runner's own floor (`pass + fail == 0`) only catches **every** set vanishing.
The realistic failure is one set vanishing, and that is exactly what it misses.

## The dishonest table row

`docs/issue-workflow.md:185` tells an adopter:

> `| Every discipline linter still catches what it claims to | … | Enforced |`

The shipped code checks a weaker property — that some non-zero exit occurred. In a
table whose own preamble promises to be honest about what is enforced, that row
overstates. It is the same overstatement pattern #19 already corrected once for
`backlog-lint`'s ID-shape box.

## Duplicate check (R2)

- [x] Searched open **and** closed issues. #29 hardened two linters against
      unterminated markup; #31 fixed `AGENTS.md` agreement. Neither touches the
      runner's pass criterion. Not a duplicate.

## Solution note (R3)

- **Chosen:** assert the reason. Each `bad-*` fixture gains a sibling `expect` file
  holding a fixed substring of the message it must provoke; `run_case` captures
  stderr and requires `grep -qF -f expect`. Plus a **per-set floor** — a manifest
  row whose linter or fixture root is missing, or which yields zero cases, is a
  `FAIL`, not a `NOTE` — and a loud `NOTE` for any entry inside a fixture root that
  matches neither naming convention.
- **Rejected:** *pin the total case count only* — it catches deletion but not a
  fixture passing for the wrong reason, which is the deeper half. *Give each linter
  distinct exit codes* — it changes five scripts' contracts to avoid changing one
  runner, and the kit's linters deliberately use the POSIX 0/1 convention.
- **Note on the opt-out:** an adopter who deletes a whole section must still pass.
  That becomes an explicit `SKIP_SETS=` opt-out rather than the silent default, so
  skipping is a decision someone wrote down.

## Acceptance criteria

- [ ] Every `bad-*` fixture asserts a substring of the message it must produce.
- [ ] Deleting a fixture's contents makes the run FAIL.
- [ ] Deleting or renaming a linter makes the run FAIL, unless explicitly opted out.
- [ ] A fixture root that yields zero cases makes the run FAIL.
- [ ] An entry inside a fixture root matching neither convention prints a NOTE.
- [ ] The `.githooks/pre-commit` `if [ -f … ]` guards no longer let a missing
      linter pass silently.
- [ ] The "What is enforced where" row states what is actually enforced.
- [ ] The task line moves from backlog to completed in the same pull request.




---

### Comment — pharzam — 2026-08-27T10:46:40Z

**Status: main was reset.** `main` is back at `2cd70ee` — the revision before any change made under #16.

All work done under this issue is safe. It lives in the branch [`backup/pre-r12-reset-999765f`](https://github.com/pharzam/armature/tree/backup/pre-r12-reset-999765f) (head `999765f`).

**This issue is closed so it can be learned and done again** from a clean main, together with the other child issues, under parent #16 — see https://github.com/pharzam/armature/issues/16#issuecomment-5437842022


---

### Comment — pharzam — 2026-08-27T11:47:27Z

## Reopened — `main` does not hold this deliverable

This issue was closed as **completed**. On 2026-08-27 `main` was reset to [`2cd70ee`](https://github.com/pharzam/armature/commit/2cd70ee), which removed every tranche-1 commit. The deliverable this issue claims is therefore not on `main` today.

Leaving it closed repeats the one defect this whole round found at every layer — *a check that reports OK having checked less than it claims* ([finding R-3 in the review](https://github.com/pharzam/armature/issues/16#issuecomment-5438020512)) — this time in the issue tracker. Phase 0 of that plan states the rule plainly: **the tracker must never claim more than `main` holds.**

### Evidence, checked at `2cd70ee`

`docs/tests/discipline-tests.sh` is absent at `2cd70ee`. The runner and its exit-1-only assertion are both gone, and with them every fixture the runner drove.

The fix lived on PR #42, whose branch carries the whole pre-reset history and can no longer merge against the reset base. That pull request is now closed with a pointer; its content returns here, re-landed from clean `main`.

This is the root of the defect class the review named: **assert the reason, not the outcome.** Until the runner asserts *why* a fixture failed, every later fixture is a check that reports OK having checked less than it claims.

### Where the work went

Nothing is lost. The tranche-1 history is preserved on [`backup/pre-r12-reset-999765f`](https://github.com/pharzam/armature/tree/backup/pre-r12-reset-999765f), which is **reference only, never a merge source**: each slice re-lands as a fresh pull request from clean `main`, with the review record on this thread as its test list.

### Returns in

**Phase 2 — first.** Triage already ruled this slice goes first, so every fixture landed after it proves something.
