# #45 — adr-lint reports OK on ten record shapes that violate the ADR conventions

*Archived from GitHub. State at archive time: OPEN. Opened 2026-08-27T12:14:50Z.*

---

Part of #16.

## Goal

Close the holes in `docs/adr/adr-lint.sh`, which reports `adr-lint: OK` on records that violate `docs/adr/README.md` and `docs/adr/template.md`.

## In plain terms

> The one automated check this project runs on its decision records approves a record with three empty sections in the wrong order, a made-up date, and no real index entry. It has said OK to every such file since it was written.

## Why now

Found by the independent review round on #43, then reproduced. `adr-lint` is one of only two linters `main` carries, and the [audit in #16](https://github.com/pharzam/armature/issues/16) leans on it as the project's first discipline test. It is the same defect class the whole round is about — **a check that reports OK having checked less than it claims** — in the linter that gates the records that document the rules.

## Duplicate check (R2)

- [x] Searched the open **and** closed issues. [#29](https://github.com/pharzam/armature/issues/29) names the identical *root cause* (a code fence hiding the rest of a file) but only in `backlog-lint` and `glossary-lint` — **neither of which exists on `main`**. `adr-lint` does, and #29 does not name it. Related: [#37](https://github.com/pharzam/armature/issues/37) (assert the reason, not the outcome), [#38](https://github.com/pharzam/armature/issues/38), [#39](https://github.com/pharzam/armature/issues/39). Parent: #16.

## The holes

All reproduced against `main` at `2cd70ee` with `sh docs/adr/adr-lint.sh <dir>`. Each prints `adr-lint: OK`, exit 0.

| # | Hole | Mechanism |
| --- | --- | --- |
| 1 | Required sections satisfied by headings **inside a fenced code block** — no real Context, Decision or Consequences | `grep -Eq '^## Context'` with no fence awareness |
| 2 | A decoy `## Status` masks an invalid one — first says `Accepted`, second says `Abandoned, do not follow` | `awk` stops at the first match |
| 3 | Empty title — `# 0002. ` with nothing after the period | the regex requires the separator, never content |
| 4 | Dangling supersession — `Superseded by ` with nothing after, or `Superseded by ADR-9999` which does not exist | the case arm `"Superseded by "*` matches the empty string; the target is never resolved |
| 5 | No index **row** — the filename appearing anywhere, including inside an HTML comment | check 3e is `grep -Fq "$name" "$readme"`, a substring, not a table row |
| 6 | Index/file drift — file says `Deprecated`, the row says `Accepted`, title unrelated | nothing compares the row's columns to the record |
| 7 | Stale row for a deleted ADR | the check runs files→README only, never README→files |
| 8 | Impossible date — `Date: 2026-13-45` | shape is validated, the calendar is not |
| 9 | `Date:` only inside a code fence | `grep -E '^Date:' \| head -n1` reads anywhere in the file |

Two lower-value cases of the same shape: `0002-a--b--------c-.md` passes the kebab-case check, and the four sections in reverse order pass although `template.md` fixes the Nygard order. Subdirectories are never scanned (`docs/adr/archive/0009-garbage.md` → `OK`), which is the shape an operator reaches for when parking a superseded record.

**Worked example — all three sections empty, reversed, placeholder date, prose "index row":**

```
$ cat 0001-empty.md
# 0001. Empty

Date: YYYY-MM-DD

## Status

Proposed

## Consequences

## Decision

## Context

$ cat README.md   # no table row; just prose naming the file
random prose mentioning 0001-empty.md not in any table

$ sh adr-lint.sh .
adr-lint: OK
EXIT=0
```

**One more, and it is the nastiest.** The no-orphan cross-link check greps for the literal string `ADR-NNNN`, so a **dead link to a different record that happens to share the number** silences the warning for the new one. This goes live the moment [#17](https://github.com/pharzam/armature/issues/17) re-lands, because the discarded `0004-ship-a-root-agents-file.md` is referenced as `ADR-0004` in two append-only `completed.md` lines.

## Solution note (R3)

- **Chosen:** fixtures first, one per hole, each asserting **why** the linter failed and not merely that it exited non-zero — [#37](https://github.com/pharzam/armature/issues/37)'s rule, which must apply to the fixtures for this fix or they repeat the defect they test. Then strip fenced blocks before scanning (shared with #29's fix), parse the index as a table, resolve supersession targets, and validate the date as a calendar date.
- **Rejected:** *a Markdown parser* — needs a toolchain the kit refuses to assume. *Fixing only the fence bug* — it is one of ten, and the substring index check (#5) is the one that lets a record ship unlisted.
- **Decision record:** this issue.

## Acceptance criteria

- [ ] A red fixture exists for each hole above, and each asserts the **reason** for the failure.
- [ ] All ten pass; the control cases still fail correctly (a genuinely missing `## Context`, a duplicate number, a numbering gap, a missing `README.md`).
- [ ] The fence fix is shared with #29's, or the two are explicitly kept separate with a stated reason.
- [ ] `docs/adr/README.md` stops claiming the linter checks "a row in the index table" unless it does.
- [ ] The task line moves from `docs/tasks/backlog.md` to `docs/tasks/completed.md` in the same pull request.

## Notes

Sequencing: this depends on [#37](https://github.com/pharzam/armature/issues/37) landing first — without a runner that asserts the reason, these fixtures would report OK against a linter that still has the holes.

