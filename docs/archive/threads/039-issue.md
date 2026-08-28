# #39 — CRLF and spaced paths: backlog-lint checks nothing and says OK; adr-lint and prd-lint fail a clean repository

*Archived from GitHub. State at archive time: OPEN. Opened 2026-08-27T08:13:22Z.*

---

Found by the gate-step-5 rounds on #33 — round 4 (F4, F5, F6) and round 1 (m1, m5). Part of #16.

## The defect

The linters assume a Unix checkout at a path with no spaces. Neither assumption is
written down, and both fail loudly or — worse — silently.

### 1. CRLF makes `backlog-lint` check nothing, and say OK

`docs/tasks/backlog-lint.sh:79` strips trailing spaces and tabs from a heading, not
`\r`. On a CRLF file the section name is `"Now\r"`, `insec` is never true, and
**both structural checks become no-ops**. Reproduced — identical content, only the
line endings differ:

```
# LF, with a deliberate violation appended:
FAIL  backlog.md:10: not a one-line task entry (want "- **<ID>** — <summary>"): * T-zzzz - ...
exit=1

# byte-identical content, converted to CRLF:
backlog-lint: OK
exit=0
```

Convert the whole fixture set and three `bad-*` fixtures flip green:
`bad-malformed`, `bad-multiline`, `bad-no-date`.

The repository ships **no `.gitattributes`**, so any adopter on Windows with the
default `core.autocrlf=true` gets a backlog linter that reports OK having checked
nothing.

### 2. CRLF makes `adr-lint` fail a repository that violates nothing — with self-contradicting messages

```
FAIL  0001-record-architecture-decisions.md: Date must be YYYY-MM-DD (a real date or
      the placeholder); got 'YYYY-MM-DD'
FAIL  0001-record-architecture-decisions.md: Status '' is not one of: Proposed | Accepted | …
```

The first message rejects the placeholder for not being the placeholder. The second
reports an empty Status for a file whose Status line reads `Accepted`. A Windows
checkout cannot pass the gate, and the diagnostics point nowhere.

### 3. A repository path containing a space breaks `adr-lint` and `prd-lint`

`adr-lint.sh:59,71,87` and `prd-lint.sh:45,58` accumulate paths into a
space-joined string and then loop over it **unquoted**. Reproduced on a clean
`git archive` of `999765f` unpacked into a directory whose name has a space:

```
$ sh "…/atk space dir/docs/adr/adr-lint.sh"
adr-lint.sh: line 78: [: atk: integer expression expected
FAIL  duplicate ADR number: atk
FAIL  duplicate ADR number: spac
```

Nonsense on a repository that violates nothing. `prd-lint.sh` carries the identical
bug and only looks clean because the kit ships no `PRD-*.md` to reach it; add one
and it fires. `backlog-lint`, `glossary-lint` and `discipline-tests` quote
throughout and survive.

**No fixture can catch this** — `discipline-tests` hands the linters *relative*
paths, which never carry the spaced prefix. It needs a case that invokes a linter
by absolute path.

### 4. `backlog-lint` lacks the `LC_ALL=C` guard its sibling documents at length

`glossary-lint.sh:40-47` explains that several `awk` implementations abort on this
repository's `‹…›` and em dashes, and that the abort is silent in a pipeline.
`backlog-lint.sh` has no such guard, and its `awk` programs match a literal em
dash. Its `sort` / `uniq -d` / `comm -12` chain is likewise locale-dependent, and
`comm`'s exit status is unchecked. Round 1 could not make it fail on macOS; round 4
expects it to fire under glibc collation, which is what CI runs. One line, and the
identical concern is already documented as load-bearing next door.

### 5. The GitLab template runs git-dependent jobs on an image with no git

`docs/ci/gitlab-ci.yml` adds three jobs on `image: alpine:3`; two of them call
`git ls-files` through `glossary-lint`. The image comment — "any image with POSIX
sh + grep/awk/sed" — was true before this change and is not true now.

## Duplicate check (R2)

- [x] Searched open **and** closed issues. Nothing covers line endings, path
      quoting, or the CI image. Not a duplicate.

## Solution note (R3)

- **Chosen:** strip `\r` at the top of every awk program in all five linters; ship
  `.gitattributes` with `*.md text eol=lf`; stop accumulating paths in a string
  (process each file in the first loop, or use `set --` / `"$@"`); add
  `LC_ALL=C; export LC_ALL` to `backlog-lint.sh` and check `comm`'s exit status;
  give the git-dependent GitLab jobs an image that has git.
- **Rejected:** *`.gitattributes` alone* — it fixes this repository and not an
  adopter who does not copy it, and the linter would still lie when handed a CRLF
  file. *Reject CRLF files outright* — the kit is domain-free and must not dictate
  an adopter's line endings; it must read them correctly.
- **Also:** `backlog-lint` never checks that the sections it lints **exist**. An
  empty `backlog.md` reports OK. That is what makes item 1 silent rather than loud,
  so it is fixed here too.

## Acceptance criteria

- [ ] A CRLF fixture for `backlog-lint` and one for `adr-lint`; both fail before
      the fix. No current fixture touches line endings at all.
- [ ] A case that invokes a linter by an absolute path containing a space.
- [ ] `backlog-lint` fails when `backlog.md` has no `## Now`/`## Next`, or
      `completed.md` has no `## Log`.
- [ ] `backlog-lint` sets `LC_ALL=C` and checks `comm`'s exit status.
- [ ] `.gitattributes` ships with `*.md text eol=lf`.
- [ ] The GitLab jobs that need git run on an image that has it, and the comment
      says so.
- [ ] The task line moves from backlog to completed in the same pull request.




---

### Comment — pharzam — 2026-08-27T09:16:38Z

## R12 plan for this issue, and its confirmation

**Task ID:** `T-6r4p` · **Branch:** `fix/t-6r4p-crlf-and-paths` · slice 4 of the
repair order on #33 (`#37 → #38 → #39 → #36 → #40`). It follows #38 because both
add fixtures, and #37 pins each set's `good*` and `bad-*` counts in the manifest —
so two slices adding fixtures in parallel collide on one line.

### Ordered steps — strict TDD

0. Open the backlog line for `T-6r4p`.
1. **Red.** Fixtures first, each with its `.expect`, counts raised in the manifest:
   - a CRLF `backlog.md` + `completed.md` carrying a violation that the LF version
     catches — today the linter reports OK
   - a CRLF ADR fixture — today `adr-lint` fails a file that violates nothing, and
     says `Date must be YYYY-MM-DD …; got 'YYYY-MM-DD'`
   - a `backlog.md` with **no** `## Now` / `## Next` heading, and a
     `completed.md` with no `## Log` — today both report OK, and that missing
     assertion is what makes the CRLF defect silent rather than loud
   - a case that invokes a linter by an **absolute path containing a space**.
     No existing fixture can catch this: the runner hands linters *relative*
     paths, so the spaced prefix never reaches them. This one needs its own
     shape, most likely in `runner-selftest.sh` rather than the fixture set.
   Run the runner: every new case fails.
2. **Green.**
   - strip `\r` at the top of every awk program in all five linters
   - stop accumulating paths in a space-joined string in `adr-lint.sh` and
     `prd-lint.sh` — process each file inside the first loop, or use `set --`
   - `backlog-lint` fails when the sections it lints do not exist
   - `backlog-lint` sets `LC_ALL=C` and checks `comm`'s exit status
3. `docs/ci/gitlab-ci.yml`: the jobs that need git get an image that has it, and
   the comment stops claiming "any image with POSIX sh + grep/awk/sed".
4. R10 sync and the enforced-where table. Backlog line → completed.

### What is already done, and why it is not enough

`.gitattributes` landed with #37, because a CRLF `.expect` file could never match
the message it named. It protects **this** repository. It does not protect an
adopter who does not copy it, and it does not make a linter handed a CRLF file
behave correctly. The linters must tolerate `CR` themselves; that is this issue.

### The risk worth naming

Item 2's second bullet rewrites the file-collection loop in two linters that
currently pass every fixture. That is the kind of change that fixes a defect
nobody hits and breaks a path everybody hits. The mitigation is order: the
fixtures come first and must stay green through the rewrite, and `adr-lint` and
`prd-lint` are the two linters with the most fixtures (6 and 9).

### Confirmation

Slice ordering reviewed three times on #16 (29 findings, all accepted). The design
choices here are new to this issue-level plan and carry no separate verdict — they
are recorded under R3 and R7, and the pull request gets its own independent rounds
under gate step 5 before it lands.



---

### Comment — pharzam — 2026-08-27T10:46:45Z

**Status: main was reset.** `main` is back at `2cd70ee` — the revision before any change made under #16.

All work done under this issue is safe. It lives in the branch [`backup/pre-r12-reset-999765f`](https://github.com/pharzam/armature/tree/backup/pre-r12-reset-999765f) (head `999765f`).

**This issue is closed so it can be learned and done again** from a clean main, together with the other child issues, under parent #16 — see https://github.com/pharzam/armature/issues/16#issuecomment-5437842022


---

### Comment — pharzam — 2026-08-27T11:47:32Z

## Reopened — `main` does not hold this deliverable

This issue was closed as **completed**. On 2026-08-27 `main` was reset to [`2cd70ee`](https://github.com/pharzam/armature/commit/2cd70ee), which removed every tranche-1 commit. The deliverable this issue claims is therefore not on `main` today.

Leaving it closed repeats the one defect this whole round found at every layer — *a check that reports OK having checked less than it claims* ([finding R-3 in the review](https://github.com/pharzam/armature/issues/16#issuecomment-5438020512)) — this time in the issue tracker. Phase 0 of that plan states the rule plainly: **the tracker must never claim more than `main` holds.**

### Evidence, checked at `2cd70ee`

- `docs/tasks/backlog-lint.sh` — absent, so the CRLF finding has no script to fail on.
- `docs/adr/adr-lint.sh` and `docs/prd/prd-lint.sh` at `2cd70ee` are the **pre-fix** versions: the CRLF and spaced-path corrections were tranche-1 commits and went with the reset.

Both halves of this issue are open again. The spaced-path half is the more urgent: it fails a clean repository, so it is a false rejection an adopter meets on day one.

### Where the work went

Nothing is lost. The tranche-1 history is preserved on [`backup/pre-r12-reset-999765f`](https://github.com/pharzam/armature/tree/backup/pre-r12-reset-999765f), which is **reference only, never a merge source**: each slice re-lands as a fresh pull request from clean `main`, with the review record on this thread as its test list.

### Returns in

**Phase 2** — redo tranche 1, after #37.
