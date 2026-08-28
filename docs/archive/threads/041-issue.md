# #41 — One decision, sixteen places: delete the nine prose copies of the linter roster

*Archived from GitHub. State at archive time: OPEN. Opened 2026-08-27T08:13:25Z.*

---

Found by the gate-step-5 rounds on #33 — round 3 (M3, M4, m2, m3, m4, m5, m6), round 4 (F9), round 1 (m3, m4). Part of #16.

## The finding

**One decision — which discipline linters the kit ships, and where each runs — is
written out in sixteen places.** Three of them were wrong on `main` when the round
ran (those three are #E). This is the audit's own "over-engineered in breadth"
finding (#16 §2), measured.

Round 3 enumerated all sixteen. Seven are genuinely different machines' inputs and
must each carry the list: the hook, the two CI templates, the runner manifest, and
three README/table indexes. **Nine are prose restating them.**

Alongside it, six small pieces of dead or duplicated machinery:

| # | Where | What |
| - | ----- | ---- |
| 1 | `docs/engineering-discipline.md:416-431` | One sentence, fifteen lines, four `and`s, describing five linters. Round 3 supplies the table that replaces it: 15 lines → 8. |
| 2 | `docs/engineering-discipline.md:416`, `docs/tests/test-levels.md:93` | "the kit ships **five**" — a count, above a list that already says it. It said "three" before this tranche. |
| 3 | `docs/review/correctness.md:3-6` | The odd one of five sibling prompts: a four-line variant where the others carry two — and **the only place in the kit that names a specific agent vendor** (`.claude/commands/`, Cursor). `AGENTS.md:24-25` forbids naming a vendor outside a `‹…›`; ADR-0004 rejected a `CLAUDE.md`-only entry point on exactly that principle. |
| 4 | `docs/tasks/backlog-lint.sh:134-144` | `uniq -d` runs twice per file — once into a variable that is discarded — and the `[ -s ]` guard is dead. The block four lines below does the same job in the clean shape. |
| 5 | `docs/glossary-lint.sh:15-17, 64-70` | A documented two-argument call shape that **nothing in the repository uses**: an untested code path inside a linter whose whole job is to be trustworthy. (Its *directory* form is load-bearing — the runner drives every linter uniformly with it — and stays.) |
| 6 | `docs/tests/discipline-tests.sh:12-13, 35` | A `[REPO_ROOT]` parameter with zero callers. A second, untested way to invoke the one script the whole gate rests on. |
| 7 | `docs/glossary-lint.sh:21-26` | The third copy of the `CLI`/`TUI`/`GUI` anecdote, after `engineering-discipline.md:312-314` and `AGENTS.md:104-112`. Six lines for a story that reads as stale the moment those three rows change. |
| 8 | `docs/adr/adr-lint.sh:39-49` | The cross-link check can never fire inside a fixture — every fixture directory holds a `0001-sample.md`, so the recursive grep always matches a sibling. **No fixture exercises it in either direction:** delete lines 133-136 and all 37 cases still pass. |

## What the round said to leave alone

Recorded so a later sweep does not "simplify" them: the per-case fixture READMEs
(`adr-lint` requires an index in each); the `err()` / `mktemp` / `trap` idiom
repeated across four linters (a shared `lib.sh` adds a sourcing path that must
resolve from the hook, from CI, from the runner, and from a bare command line — a
real portability surface to save six lines); `backlog-lint`'s comment stripping
versus `glossary-lint`'s fence tracking (different grammars, not two copies of
one thing); `glossary-lint`'s `LC_ALL=C` and `unset GIT_DIR` blocks and their long
comments (they state constraints the code cannot show); the `__UNCLOSED_FENCE__`
sentinel; and `AGENTS.md` restating the gate and R1–R12, which ADR-0004 already
decided, costed, and mitigated.

## Why this is filed as its own issue, not fixed inside another slice

It is **not material** in the sense #33's acceptance criteria use: none of it makes
a check lie. It is the over-engineering finding, and it belongs next to #20
(adoption profiles), which is the slice that addresses the same audit finding from
the other direction. Item 3 is the exception worth pulling forward — a vendor name
in a shipped file breaks a stated rule of the kit — and it is one line.

## Duplicate check (R2)

- [x] Searched open **and** closed issues. #20 defines adoption profiles and does
      not touch duplication; nothing else covers it. Not a duplicate. Related: #20.

## Solution note (R3)

- **Chosen:** delete, do not restate. Take sixteen sites to nine by removing the
  nine prose copies and pointing at the seven that machines read. `AGENTS.md:53` is
  the pattern — it points at `docs/review/` instead of restating four lenses.
- **Rejected:** *generate the prose from the manifest* — new machinery to keep a
  sentence in step with a list, when deleting the sentence costs nothing.

## Acceptance criteria

- [ ] The roster is stated in the seven places a machine reads it, and pointed at
      elsewhere.
- [ ] Items 1–8 above are closed, or each has a written reason here for staying.
- [ ] `docs/review/correctness.md` matches its four siblings and names no vendor.
- [ ] `adr-lint`'s cross-link check gains a fixture, or is removed with its reason.
- [ ] Five checks green, and the case count does not fall.
- [ ] The task line moves from backlog to completed in the same pull request.




---

### Comment — pharzam — 2026-08-27T10:46:50Z

**Status: main was reset.** `main` is back at `2cd70ee` — the revision before any change made under #16.

All work done under this issue is safe. It lives in the branch [`backup/pre-r12-reset-999765f`](https://github.com/pharzam/armature/tree/backup/pre-r12-reset-999765f) (head `999765f`).

**This issue is closed so it can be learned and done again** from a clean main, together with the other child issues, under parent #16 — see https://github.com/pharzam/armature/issues/16#issuecomment-5437842022


---

### Comment — pharzam — 2026-08-27T11:47:37Z

## Reopened — `main` does not hold this deliverable

This issue was closed as **completed**. On 2026-08-27 `main` was reset to [`2cd70ee`](https://github.com/pharzam/armature/commit/2cd70ee), which removed every tranche-1 commit. The deliverable this issue claims is therefore not on `main` today.

Leaving it closed repeats the one defect this whole round found at every layer — *a check that reports OK having checked less than it claims* ([finding R-3 in the review](https://github.com/pharzam/armature/issues/16#issuecomment-5438020512)) — this time in the issue tracker. Phase 0 of that plan states the rule plainly: **the tracker must never claim more than `main` holds.**

### Evidence, checked at `2cd70ee`

The nine prose copies of the linter roster are absent at `2cd70ee`, because the linters they listed are absent.

This issue is the cheapest to close correctly and the easiest to get wrong: it closes by **never creating the nine copies in the first place**. Each Phase 2 slice that adds a linter names it in one place only. If the redo re-creates the copies and then deletes them, this issue has taught nothing.

### Where the work went

Nothing is lost. The tranche-1 history is preserved on [`backup/pre-r12-reset-999765f`](https://github.com/pharzam/armature/tree/backup/pre-r12-reset-999765f), which is **reference only, never a merge source**: each slice re-lands as a fresh pull request from clean `main`, with the review record on this thread as its test list.

### Returns in

**Phase 2** — folded into the slices that create each roster mention, not landed on its own.
