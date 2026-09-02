# T-2p6k — Portable paths and line endings in the linters

Tracks [issue #76](https://github.com/pharzam/armature/issues/76), landed by
[PR #77](https://github.com/pharzam/armature/pull/77) at `6c3f5d0` on
2026-09-01. This file was written on 2026-09-02 under
[#83](https://github.com/pharzam/armature/issues/83) (`T-xj92`), from the landed
record: the #76 thread, the PR #77 body and the commit history, plus, for the
follow-ups only, the titles of issues #78 to #83 and the #79 thread, which
names #81 and #82 as its children. Every number below is copied from one of
those and its source is named beside it; nothing was re-measured for this
file. Times are UTC on 2026-09-01 unless dated. The task had no backlog line:
it was born from #76 and went straight to the completed log
([completed.md](completed.md)).

## Why

Two defects of one class were live in the tree and nothing owned them (#76
body). `link-lint` did not strip a trailing carriage return, so a reference
definition in a CRLF file resolved to `target.md\r` and `L1` failed on a good
link. `adr-lint` and `prd-lint` accumulated their file lists into a
space-joined string and looped over it unquoted, so a checkout whose path
contains a space split the list and the run failed on a repository that
violated nothing. Both fail an adopter who has done nothing wrong; in the
issue's words, an adopter on Windows with git's default `core.autocrlf=true`
"meets it on day one".

The issue's premise about testing was wrong and was corrected on the record
(#76, 19:27Z). It held that no fixture could reach the spaced-path defect,
because the runner passes relative paths. The space can come from the fixture
directory's own name, which `run_dir_suite` passes quoted, so an ordinary
`good-*` case reaches the defect with no change to the harness (#76, 13:29Z,
finding A).

## Design

Recorded before the first commit (#76, 13:29Z) and selected under R3.

- **Spaced paths: positional parameters.** `adr-lint` and `prd-lint` build
  their list with `set --` and `set -- "$@" "$path"` and walk it with
  `for path do`, in place of a space-joined string. POSIX, quote-safe, and it
  removes the class rather than the symptom: a space, a tab, a newline or a
  glob character in a path is safe. Rejected: a newline-joined list under
  `IFS`, which fixes spaces and leaves pathname expansion, the state
  `link-lint` was already in; and quoting the loop variable, because the split
  has already happened by the time there is a variable to quote.
- **Carriage returns: one strip at the reader.** `link-lint` strips the
  carriage return as its first awk rule, so every later rule reads a clean
  line. `agents-lint` and `audit-record-lint` route every file read through
  one `text()` helper rather than a strip per site, so the next site added
  does not find the defect again (#76, 14:38Z; PR #77 lines 22-24). One stated
  exception: `audit-record-lint`'s block 1-4 reads its record twice in one awk
  run, and a pipe can be read once, so that block keeps two file arguments and
  strips inside awk, marked where it happens. `expect-check` strips the
  carriage return from its own `EXPECT` file.
- **The `.gitattributes` pin.** `eol=crlf` on the CRLF fixtures, because a
  CRLF fixture is a test only while it stays CRLF: under `core.autocrlf=input`
  with no pin, the fixture arrives as LF and "the test silently stops testing"
  (#76, 13:29Z, section 7, measured on three throwaway repositories). `eol=lf`
  on every shipped executable, so the scripts and hooks run on a Windows
  checkout (decision C1, below). Rejected: a repository-wide
  `* text=auto eol=lf`, which would hide the defect rather than fix it, a
  workaround under R4, and would constrain every adopter's own files (#76,
  13:29Z; PR #77 lines 26-28).
- **Not an ADR.** Two scripts change how they hold a list and two change where
  they cut a line; nothing here decides structure or ownership (#76, 13:29Z).

## The three widenings, and the two decisions not to widen

The issue opened naming two defects in three scripts and landed touching five
scripts and a new `.gitattributes` (#76, 20:44Z). Four of the five steps below
are operator decisions recorded on the thread in the comment at the time
given. The E2 row records what the thread holds for it, which is the outcome
and not the choice.

| comment at | step | effect |
| --- | --- | --- |
| 13:37Z | **A** over B and C | fix the two named defects and the two more instances the fixtures exposed: `adr-lint`'s `Date:` and `Status` reads, and `audit-record-lint`'s candidate loop |
| 14:13Z | **C1** | pin the executables to LF: on a `core.autocrlf=true` clone the scripts and hooks did not run at all, `main` included (finding C, 14:00Z) |
| 14:38Z | **E2** | fix the residue C1 exposed in `agents-lint`, `audit-record-lint` and `expect-check`, rather than open a new issue for the three. The 14:19Z comment offered E1 (recommended) and E2 and asked for a decision; the next comment, at 14:38Z, reports "E2 done". No comment on the thread records the operator's choice between them |
| 14:13Z | **D1** | record the two spaced-link limits in `docs/links/README.md` as limits 7 and 8; fix neither |
| 20:36Z | **D1a** | after round 2 reopened D1 (17:42Z), leave both limits recorded; the code fix D1b goes to a new issue |

The close-out (#76, 20:44Z) counts "five operator decisions widening scope".
That phrase counts decisions, not widenings: of the five steps in the table,
three (A, C1, E2) widened the change and two (D1, D1a) declined to, and for E2
the thread records the outcome rather than the choice.

## Verification

| measure | before | after | source |
| --- | --- | --- | --- |
| `adr-lint` at a checkout path containing a space | 90 `FAIL` lines | `OK` | #76, 20:36Z, which corrected the scoping comment's 138 to 90, measured on `main` at `52629b6`; PR #77 line 15 |
| checks that run on a `core.autocrlf=true` clone | `0 of 7` | `7 of 7` | PR #77 line 41 |
| discipline suite | `97` cases | `104` cases | PR #77 line 42 |

The confirming pass at the frozen head `a90d41e` ran in four environments, the
worktree and clones at a spaced path, with `core.autocrlf=true` and with
`core.autocrlf=input`: five linters `OK`, `104 passed, 0 failed` and
`git diff --check` clean in each (PR #77 lines 34-39; #76, 20:36Z). The runner
compares exit codes only, so the claim those 104 support is that 104 exit codes
matched, not that each case passed or failed for its own reason; the owner of
that stronger assertion is `T-9c5t` ([backlog.md](backlog.md)).

Two sources disagree on how many executables the CRLF checkout stopped: #76
(14:00Z) says "eleven of eleven" and PR #77 (line 16) says "all twelve". This
file asserts no count. The recovered round-1 record on #76 (line-endings lens,
posted 2026-09-02) holds the reviewer's finding that the twelfth was
`.githooks/tests/provenance-check.sh`.

The 138 in the scoping comment (#76, 13:04Z) is stale: 20:36Z measured 90 on
`main`. The recovered round-2 records on #76 hold two reviewers' finding that
138 belongs to a path with two spaces and 90 to a path with one.

## Corrections on the record

Each correction is a new comment or a new commit, never a rewrite of a landed
one.

1. **Two false claims in commit messages** (#76, 19:52Z; PR #77 lines 70-82).
   `b8d7643`'s five-loss table, row 1, claimed `104 passed, 1 failed` for a
   dropped `EXPECT` pin; measured at that commit it was `104 passed, 0 failed`,
   and `011aa1c` and `a73ba05` later made it true. `f36ccaa` said `sect()`
   alone covers seven of `agents-lint`'s fifteen read sites; there are eight
   `sect "` call sites, and the fifteen is exact. Neither commit was amended,
   because the thread cites those SHAs about a dozen times.
2. **Definition-of-Done item 4 removed with a reason** (#76, 19:22Z). A comment
   on #39 was put out of scope by decision, so the item was deleted from the
   issue body rather than left unticked or ticked falsely. The tradeoff is
   stated there: #39 gets no forward pointer to the fix.
3. **Definition-of-Done item 2 rewritten** (#76, 19:27Z) to say the opposite of
   its first premise: no absolute-path invocation was needed to reach the
   spaced-path defect.
4. **PR #77's third acceptance box corrected** under #83. The box "Independent
   review ran until findings decayed; evidence committed" is not met: no round
   found nothing material, and no round record existed. Recorded on #76 on
   2026-09-02 ([comment](https://github.com/pharzam/armature/issues/76#issuecomment-5507016514)).
   The reviewers' raw findings for both rounds were then recovered from the
   transcripts and posted on #76 as six comments, dated as recovered, starting
   [here](https://github.com/pharzam/armature/issues/76#issuecomment-5507054627).

## Out of scope (follow-ups)

Opened from this work. None of them is worked under #83.

- [#78](https://github.com/pharzam/armature/issues/78) — `link-lint` is silent
  on a link whose destination contains a space, and cannot tell a good spaced
  link from a dead one; the D1b/D1c fix that D1a deferred.
- [#79](https://github.com/pharzam/armature/issues/79) — the gate's decay rule
  cannot terminate on a growing branch, and R11 has no tripwire; its children
  are [#81](https://github.com/pharzam/armature/issues/81), the stopping
  protocol as an ADR, and [#82](https://github.com/pharzam/armature/issues/82),
  the mechanisms behind the written rules.
- [#80](https://github.com/pharzam/armature/issues/80) — `audit-record-lint`
  walks nested checkouts and ranks a stale copy over the real file, found after
  the merge in a checkout that holds worktrees inside the repository.
- [#83](https://github.com/pharzam/armature/issues/83) — this record.
- No issue: `.gitattributes` is 186 lines for 10 rules, and a further trim was
  left undone because the branch was frozen (PR #77 lines 84-89).

## Verdict

The two defects #76 named are fixed, and so are the two more instances the
fixtures exposed: the kit runs on a checkout whose path contains a space and
on a `core.autocrlf=true` checkout (#76, 20:44Z; PR #77 lines 41-44). The
review record behind that verdict was not honest until #83. PR #77's third
acceptance box is not met, and the two rounds have a record only as recovered
on 2026-09-02, which shows that no lens reviewed a frozen commit and that the
reviewers ran the same model as the author (the recovered records on #76).
