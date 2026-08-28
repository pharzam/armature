# #38 — glossary-lint scans less than it claims: five silent holes and one false rejection

*Archived from GitHub. State at archive time: OPEN. Opened 2026-08-27T08:13:21Z.*

---

Found by the gate-step-5 rounds on #33 — round 1 (M2, M3, M5, m2), round 2 (F2, F6), round 3 (M2), round 4 (F1, F2, F3, F8). Part of #16.

## The defect

`docs/glossary-lint.sh` enforces the rule `AGENTS.md:104` and
`docs/engineering-discipline.md:303` both state as *"every abbreviation that
appears in committed Markdown has a glossary row"*. **Five reproduced ways it scans
less than that, and one way it rejects a file that breaks no rule.** All five
silent ones end in `glossary-lint: OK`, exit 0.

### 1. Ten committed prose documents are excluded by a glob meant for fixtures

`:168-171` skips anything under any path segment named `tests`. `docs/tests/` is
the kit's **test-conventions documentation**, not a fixture directory:

```
docs/tests/dod-checklist.md          docs/tests/template-e2e.md
docs/tests/example-fact-to-test.md   docs/tests/template-integration.md
docs/tests/scaling-checklist.md      docs/tests/template-uat.md
docs/tests/security-checklist.md     docs/tests/template-unit.md
docs/tests/test-levels.md            docs/tests/traceability-template.md
```

Reproduced — the same undefined token in two files, one reported:

```
$ printf '\nZQXW is a token that has no glossary row.\n' >> docs/tests/test-levels.md
$ printf '\nZQXW is a token that has no glossary row.\n' >> docs/guardrails.md
$ sh docs/glossary-lint.sh
FAIL  abbreviation "ZQXW" is used but has no glossary row (in: docs/guardrails.md )
```

Second-order trap: `docs/tests/README.md` **is** scanned, so anyone probing the
exclusion by editing that file concludes the directory is in scope.

### 2. Any path git C-quotes is dropped without a word

With git's default `core.quotePath=true`, a non-ASCII path is listed as a quoted,
escaped string. `[ -f "$scan_root/$f" ] || continue` at `:164` then drops it
silently:

```
$ git ls-files 'docs/caf*'
"docs/caf\303\251.md"
$ sh docs/glossary-lint.sh
glossary-lint: OK
```

Two opposite answers on the same tree, decided by a git setting the linter never
mentions — the same shape as the `GIT_DIR` defect #29 fixed. A path containing a
newline hits the same silent `continue`.

### 3. The code-fence tracker desyncs, and skips real prose

`:173-174` blindly toggles on ` ``` `. It does not know `~~~` fences or longer
fences, both valid CommonMark — and the only way to *show* a backtick fence, which
a documentation kit does. A desynced region ends with `infence == 0`, so the
unterminated-fence guard added by #29 never fires. Round 4 built a valid CommonMark
file where an undefined token sits in plain prose on line 9 and is invisible, while
a second token appended later in the *same file* is caught.

### 4. The same tracker rejects files that break no rule

`~~~`-fenced code, four-space-indented code, and a four-backtick fence wrapping a
three-backtick fence all produce `FAIL` on correct documents. A linter that cries
wolf gets switched off — `guardrails.md` says so.

### 5. A scan root that does not exist reports OK

```
$ sh docs/glossary-lint.sh docs/glossary.md /no/such/dir
glossary-lint: OK
```
The `cd` fails, the file list is empty, and #29's "untracked Markdown" guard finds
nothing to complain about because the directory is absent. Reachable through the
two-argument form the script's own usage documents.

### 6. A valid escaped pipe in a table row is rejected

`:98` splits on `|` with no escape handling, so `\|` inside a cell — the standard
GitHub-flavoured Markdown escape — inflates the cell count and produces
`table row has 5 cells, want 4`. **`prd-lint.sh` in the same pull-request set gets
this right** (`split_row`, line 61). Two linters that shipped together disagree
about the same Markdown.

### 7. A claim in the header the code does not keep

`:9-11` promises "no empty cell"; the loop at `:117-122` checks columns 3 and 4
only. Column 2 (`Abbr.`) is never checked. An em dash there is legitimate, so the
fix may be to the comment rather than the code — but the two disagree today.

## Duplicate check (R2)

- [x] Searched open **and** closed issues. #29 fixed the unterminated-fence and
      `GIT_DIR` defects in this same file; these are different doors into the same
      failure, found by the rounds #29 never got. Not a duplicate.

## Solution note (R3)

- **Chosen:** (1) exclude fixture **roots**, derived from the manifest in
  `docs/tests/discipline-tests.sh:90-94`, so the two cannot drift; (2)
  `git -c core.quotePath=false ls-files`, and make the `continue` at `:164`
  **loud** — a path the scan cannot open is the exact "scanned nothing, said OK"
  failure this script exists to prevent; (3) track the opening fence's character
  and run length, per CommonMark, and handle indented code; (4) fail when the scan
  root does not exist, in the same shape as the existing glossary-not-found check;
  (5) port `prd-lint`'s `split_row` escape handling; (6) settle the `Abbr.` claim
  in code or in the comment.
- **Rejected:** *scan untracked files too* — #29 rejected that correctly; the
  rule's scope is what is committed. *Drop the fixture exclusion and let fixtures
  be scanned* — deliberately malformed input is not prose, and the noise would get
  the linter switched off.

## Acceptance criteria

- [ ] A fixture for each of items 1–6 above, each failing before its fix.
- [ ] `docs/tests/*.md` prose is scanned; fixture inputs are not.
- [ ] A committed path with a non-ASCII byte is scanned, and a path that cannot be
      read is reported, never dropped.
- [ ] `~~~` fences, longer fences, and indented code are handled per CommonMark, in
      both directions.
- [ ] A missing scan root fails.
- [ ] `\|` in a table cell is accepted, matching `prd-lint`.
- [ ] The header's claims match the code.
- [ ] The task line moves from backlog to completed in the same pull request.




---

### Comment — pharzam — 2026-08-27T08:48:44Z

## R12 plan for this issue, and its confirmation

**Task ID:** `T-9v2d` · **Branch:** `fix/t-9v2d-glossary-scope` · slice 3 of the
[tranche-2 repair order](https://github.com/pharzam/armature/issues/33) —
`#37 → #38 → #39 → #36 → #40`.

**It waits for #37 to merge.** Not for the reason that usually blocks a slice:
#37 pins each fixture set's case count in the runner manifest, and this issue adds
`glossary-lint` fixtures, so the two change the same line. In series there is no
conflict to resolve — the same reasoning that put #34 before #35 in the parent
plan.

### Ordered steps — strict TDD

0. Open the backlog line for `T-9v2d`; confirm `docs/tasks/t-9v2d.md` is free.
1. **Red.** One fixture per defect, wired into the runner with its `.expect`, and
   the manifest count raised to match:
   - prose under a directory named `tests/` that is documentation, not fixtures
   - a committed path git C-quotes (a non-ASCII byte in the filename)
   - a `~~~` fence, a fence longer than three backticks, and four-space-indented
     code — in **both** directions: prose after them must be scanned, and code
     inside them must not be flagged
   - a scan root that does not exist
   - a table row with an escaped `\|` in a cell
   Run the runner: every new case fails, because none of the fixes exists.
2. **Green.** Six changes to `docs/glossary-lint.sh`:
   - exclude fixture **roots**, derived from the runner's manifest, not any
     directory named `tests`
   - `git -c core.quotePath=false ls-files`, and make the silent `continue` at
     `:164` **loud** — a path the scan cannot open is the exact failure this
     script exists to prevent
   - track the opening fence's character and run length per CommonMark, and skip
     indented code
   - fail when the scan root does not exist, in the shape of the existing
     glossary-not-found check
   - port `prd-lint`'s `split_row` escaped-pipe handling
   - settle the "no empty cell" claim in the header — the `Abbr.` column is not
     checked, and an em dash there is legitimate, so the honest fix is probably
     the comment
3. Whatever the scan now covers that it did not before, **the glossary must
   satisfy** — expect this step to surface undefined abbreviations in the ten
   `docs/tests/*.md` documents that have never been scanned. Those rows are part
   of this change.
4. R10 sync: `AGENTS.md` and `engineering-discipline.md` both state the rule this
   linter enforces; if the enforced scope changes, they change in the same pull
   request. "What is enforced where" likewise.
5. Backlog line → completed, same pull request.

### The risk worth naming

Step 3 is unbounded from here: nobody knows what ten unscanned documents contain
until the scan reaches them. If it turns up many abbreviations, the honest choices
are to define them or to widen the exempt list — **not** to narrow the scan again
to keep the diff small. Narrowing the scan to avoid work is how the ten documents
came to be excluded in the first place.

### Confirmation

The slice ordering and its dependency were reviewed three times on #16 (two
REJECTED, one APPROVED WITH CHANGES; 29 findings, all accepted). The design
choices above are new to this issue-level plan and carry no separate verdict; they
are recorded here under R3 and R7, and the pull request gets its own independent
rounds under gate step 5 before it lands.



---

### Comment — pharzam — 2026-08-27T10:46:42Z

**Status: main was reset.** `main` is back at `2cd70ee` — the revision before any change made under #16.

All work done under this issue is safe. It lives in the branch [`backup/pre-r12-reset-999765f`](https://github.com/pharzam/armature/tree/backup/pre-r12-reset-999765f) (head `999765f`).

**This issue is closed so it can be learned and done again** from a clean main, together with the other child issues, under parent #16 — see https://github.com/pharzam/armature/issues/16#issuecomment-5437842022


---

### Comment — pharzam — 2026-08-27T11:47:29Z

## Reopened — `main` does not hold this deliverable

This issue was closed as **completed**. On 2026-08-27 `main` was reset to [`2cd70ee`](https://github.com/pharzam/armature/commit/2cd70ee), which removed every tranche-1 commit. The deliverable this issue claims is therefore not on `main` today.

Leaving it closed repeats the one defect this whole round found at every layer — *a check that reports OK having checked less than it claims* ([finding R-3 in the review](https://github.com/pharzam/armature/issues/16#issuecomment-5438020512)) — this time in the issue tracker. Phase 0 of that plan states the rule plainly: **the tracker must never claim more than `main` holds.**

### Evidence, checked at `2cd70ee`

`docs/glossary-lint.sh` is absent at `2cd70ee`. The five silent holes and the one false rejection went with the script.

Re-land each of the six as a **red fixture first** — the reproductions on this thread are the test list — then port or rewrite the code.

### Where the work went

Nothing is lost. The tranche-1 history is preserved on [`backup/pre-r12-reset-999765f`](https://github.com/pharzam/armature/tree/backup/pre-r12-reset-999765f), which is **reference only, never a merge source**: each slice re-lands as a fresh pull request from clean `main`, with the review record on this thread as its test list.

### Returns in

**Phase 2** — redo tranche 1, after #37.
