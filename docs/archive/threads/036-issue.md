# #36 — The quality gate lints the working tree, not what is being committed

*Archived from GitHub. State at archive time: OPEN. Opened 2026-08-27T08:13:18Z.*

---

Found by the gate-step-5 rounds on #33 (round 1, correctness, finding M4). Part of #16.

## The defect

**The pre-commit hook lints the working tree, not the index.** The gate therefore
checks content that is not what the commit contains. A violation staged and then
tidied in the working copy lands with five green checks.

Reproduced against a clean `git archive` of `999765f` with
`core.hooksPath=.githooks` enabled:

```
$ printf 'This doc uses ZQXSTAGED which is undefined.\n' > docs/staged-demo.md
$ git add docs/staged-demo.md
$ sh docs/glossary-lint.sh
FAIL  abbreviation "ZQXSTAGED" is used but has no glossary row (in: docs/staged-demo.md )

$ printf 'This doc is clean prose now.\n' > docs/staged-demo.md   # index untouched
$ git commit -m "docs: demo staged bad content"
adr-lint: OK
prd-lint: OK
glossary-lint: OK
backlog-lint: OK
discipline-tests: OK (37 cases)

$ git show HEAD:docs/staged-demo.md
This doc uses ZQXSTAGED which is undefined.      <- what landed
```

The reverse is equally wrong and equally reachable: stage the fix, leave the
working copy broken, and the hook blocks a commit whose staged content is clean.

## Why it matters more than the other findings

1. **It is the gate itself.** Every other check in this repository is trusted
   because the hook runs it. If the hook reads the wrong bytes, no linter's verdict
   means what the kit says it means.
2. **`git add -p`, or editing between `git add` and `git commit`, is the ordinary
   workflow** — and the default workflow for an agent.
3. **A comment asserts the opposite.** `docs/glossary-lint.sh:53-55` says:
   *"The staged index is still what git reads, so a pre-commit run still sees what
   is about to land."* Only the **file list** comes from the index
   (`git ls-files`); every byte of **content** comes from disk (`awk … "$scan_root/$f"`).
   That comment was added by #30 — the pull request written to close this exact
   class of defect. A false claim in a comment is the one thing the correctness
   lens says never to trust, and here the kit wrote one about itself.

## Duplicate check (R2)

- [x] Searched open **and** closed issues. #29 and #31 fixed neighbouring defects
      of the same class; neither touches worktree-versus-index. Not a duplicate.

## Solution note (R3) — decided when the work starts

Three candidates, to be settled with a decision note on this issue before the
first test:

- **Lint a temporary checkout of the index.** `git checkout-index --all --prefix=`
  into a temp tree and run the linters there. Checks exactly what lands. Cost:
  `glossary-lint` needs `git ls-files`, which will not work inside a tree with no
  `.git` — so the linter needs a way to be told its file list.
- **Read staged content per file.** `git show ":$f"` instead of reading from disk,
  behind a `--staged` flag the hook passes. Smaller change, touches every linter
  that reads file content.
- **Document the limitation and stop claiming otherwise.** Cheapest, and honest,
  but it leaves the gate checking something other than what lands — which the kit's
  own "a skipped gate is no gate" reasoning rejects.

The third is the fallback, not the goal. Whichever is chosen, the false comment at
`glossary-lint.sh:53-55` goes in the same change.

## Acceptance criteria

- [ ] A fixture proves the defect: content staged, working copy differing, and the
      check verdicts follow the **staged** content.
- [ ] The hook's verdict is decided by what the commit will contain.
- [ ] The claim at `docs/glossary-lint.sh:53-55` is true, or gone.
- [ ] The chosen option and the rejected ones are recorded here (R3).
- [ ] `docs/issue-workflow.md` "What is enforced where" says honestly what the hook
      reads.
- [ ] The task line moves from `docs/tasks/backlog.md` to
      `docs/tasks/completed.md` in the same pull request.




---

### Comment — pharzam — 2026-08-27T10:46:37Z

**Status: main was reset.** `main` is back at `2cd70ee` — the revision before any change made under #16.

All work done under this issue is safe. It lives in the branch [`backup/pre-r12-reset-999765f`](https://github.com/pharzam/armature/tree/backup/pre-r12-reset-999765f) (head `999765f`).

**This issue is closed so it can be learned and done again** from a clean main, together with the other child issues, under parent #16 — see https://github.com/pharzam/armature/issues/16#issuecomment-5437842022


---

### Comment — pharzam — 2026-08-27T11:47:24Z

## Reopened — `main` does not hold this deliverable

This issue was closed as **completed**. On 2026-08-27 `main` was reset to [`2cd70ee`](https://github.com/pharzam/armature/commit/2cd70ee), which removed every tranche-1 commit. The deliverable this issue claims is therefore not on `main` today.

Leaving it closed repeats the one defect this whole round found at every layer — *a check that reports OK having checked less than it claims* ([finding R-3 in the review](https://github.com/pharzam/armature/issues/16#issuecomment-5438020512)) — this time in the issue tracker. Phase 0 of that plan states the rule plainly: **the tracker must never claim more than `main` holds.**

### Evidence, checked at `2cd70ee`

`2cd70ee:.githooks/pre-commit` runs `sh docs/adr/adr-lint.sh` and `sh docs/prd/prd-lint.sh` directly. It never reads the index and never stashes the unstaged remainder, so the gate still lints **what is on disk**, not **what is being committed**. A clean staged change can fail on unrelated working-tree edits, and a broken staged change can pass on a clean working tree.

The defect is exactly as reported, on the same two linters, unmodified.

### Where the work went

Nothing is lost. The tranche-1 history is preserved on [`backup/pre-r12-reset-999765f`](https://github.com/pharzam/armature/tree/backup/pre-r12-reset-999765f), which is **reference only, never a merge source**: each slice re-lands as a fresh pull request from clean `main`, with the review record on this thread as its test list.

### Returns in

**Phase 2** — redo tranche 1, with the linter slices whose results the hook decides.


---

### Comment — pharzam — 2026-08-27T11:55:50Z

## Fresh reproduction against the reset base

Reproduced today on `main` at `2cd70ee` while building #43, without trying to. Recording it here so Phase 2 re-lands this fix against a defect that has been re-verified, not one remembered from a tree that no longer exists.

The commit staged **one** file, `docs/tasks/backlog.md`, and that staged change was valid. The hook failed it on a different file that was not in the commit:

```
$ git diff --cached --name-only
docs/tasks/backlog.md

$ git status --porcelain
M  docs/tasks/backlog.md
?? docs/adr/0004-reset-the-default-branch.md      # untracked, not staged, not in the commit

$ sh .githooks/pre-commit
FAIL  0004-reset-the-default-branch.md: no row for it in README.md's index table
EXIT=1
```

`2cd70ee:.githooks/pre-commit` calls `sh docs/adr/adr-lint.sh` and `sh docs/prd/prd-lint.sh` directly. It never reads the index and never stashes the unstaged remainder, so it decides a commit on evidence the commit does not contain.

### A second consequence, not in the original report

Because the hook lints the working tree, **a failing tree cannot be committed at all** — and `adr-lint` is the only test this repository has for a documentation change. So the red half of red-green can never be *committed* here: R8's "watch it fail" can be observed and quoted, never recorded as a commit.

The pre-reset history worked around this without naming it. #43 states it instead ([the plan](https://github.com/pharzam/armature/issues/43#issuecomment-5438576883), [the pull request](https://github.com/pharzam/armature/pull/44)) and quotes the red output as evidence rather than committing it.

That makes this issue worth more than its original scope. It is not only "the gate checks the wrong thing" — it is also **the reason this repository cannot practise its own R8 literally**. Both belong in the fix, and both belong in the acceptance criteria when it re-lands.

### For the re-land

Fixture first, and make the fixture assert the *reason*: a staged change that is clean, plus an unstaged or untracked file that is dirty, must **pass**. A fixture that only checks "the hook exited non-zero" would pass against the broken hook too — the [#37](https://github.com/pharzam/armature/issues/37) class, in the test for this very fix.


---

### Comment — pharzam — 2026-08-27T12:07:49Z

## Correction, and the defect is worse than I reported

My [previous comment](https://github.com/pharzam/armature/issues/36#issuecomment-5438656027) said the hook makes it so *"a failing tree cannot be committed at all."* **That is false**, and an independent reviewer disproved it during the round on #43. I re-ran the experiment myself rather than take the correction on trust. It holds.

What is true is narrower: a failing **working tree** blocks a commit. That is the direction I hit, and it is only half the defect.

### The other half: the hook lets through a commit that fails the linter

Because `adr-lint.sh` globs `"$adr_dir"/*.md` off **disk** and greps `README.md` off **disk**, the hook judges the working tree while `git commit` records the **index**. Make the working tree green and stage a subset that is not, and the gate waves it through:

```
$ sh docs/adr/adr-lint.sh >/dev/null 2>&1 ; echo $?     # working tree
0

$ git diff --cached --name-only                          # what is being committed
docs/adr/0004-test-adr.md
$ git diff --name-only                                   # deliberately NOT staged
docs/adr/README.md

$ git commit -m "docs: add an ADR without its index row" # hook live, NO --no-verify
adr-lint: OK
prd-lint: OK
exit 0                                                    # <-- commit ACCEPTED

$ git archive HEAD | tar -x -C co && sh co/docs/adr/adr-lint.sh co/docs/adr
FAIL  0004-test-adr.md: no row for it in README.md's index table
exit 1                                                    # <-- committed tree is BROKEN
```

Reproduced in a throwaway clone of `docs/` and `.githooks/` outside the repository, `core.hooksPath=.githooks`, on `main` at `2cd70ee`.

### Why this reframes the issue

I reported #36 as "the gate refuses a valid commit" — annoying, loud, self-announcing. The reverse is the real defect:

| Direction | Effect | Noticed? |
| --- | --- | --- |
| Working tree dirty, staged change clean | A **valid** commit is refused | Immediately — it blocks you |
| Working tree clean, staged change broken | A **broken** commit is accepted, printing `adr-lint: OK` | **Never** — it prints OK |

The second is the one that reaches `main`. It is silent, and it is the project's own defect class stated exactly: *a check that reports OK having checked less than it claims* — here, having checked a **different tree** than the one it is approving. The false rejection is a nuisance. The false acceptance is the bug.

### For the re-land

The fixture must assert **both** directions, and assert the reason rather than the exit code:

1. Working tree dirty + staged change clean → the hook must **pass**.
2. Working tree clean + staged change broken → the hook must **fail**, and the fixture must check that it failed *for the index's defect*, not merely that it exited non-zero.

Case 2 is the one that would have caught this. A fixture that only tested case 1 would report OK against a hook that still accepts broken commits — the [#37](https://github.com/pharzam/armature/issues/37) class reappearing inside the test for this very fix.

### Consequence for the R8 claim

My earlier note said this repository "cannot practise its own R8 literally" because a red state cannot be committed. **Withdrawn** — the red state *can* be committed, by the same index/worktree split shown above, and `git commit --no-verify` was always available besides. R8 asks the operator to *run the tests and watch them fail*; it never asks for the red state to be committed. There was no limit on R8 here, and I should not have claimed one.
