# Archive — issue #16 and its tree

This directory holds the complete GitHub record of the **#16 audit** and every
issue and pull request under it, captured as files so the work survives
independently of the forge.

**The work was settled, not completed.** See the decision recorded on
[#16](threads/016-issue.md).

## What is here

`threads/` holds one file per issue or pull request: the body as it stood at
archive time, then every comment in order, with author and timestamp.
**24 threads, 94 comments, 512,588 bytes.**

| Thread | Kind | Title | Comments | Bytes |
| ------ | ---- | ----- | -------: | ----: |
| [#16](threads/016-issue.md) | issue | Audit: is Armature state-of-the-art, over-engineered, or over-fitted? — findings and the | 16 | 102,709 |
| [#17](threads/017-issue.md) | issue | Ship a root AGENTS.md template (and a CLAUDE.md pointer) | 2 | 6,116 |
| [#18](threads/018-issue.md) | issue | Package the mandated review procedures as runnable, inert assets | 1 | 3,273 |
| [#19](threads/019-issue.md) | issue | Add the AGENTS.md drift check | 9 | 19,437 |
| [#20](threads/020-issue.md) | issue | Define core / standard / full adoption profiles | 2 | 3,568 |
| [#21](threads/021-issue.md) | issue | Rescope the two rules the kit cannot enforce (abbreviation rule, R4) | 3 | 7,031 |
| [#22](threads/022-issue.md) | issue | Dogfood the kit on one real product repository | 2 | 3,594 |
| [#23](threads/023-issue.md) | issue | Housekeeping: remove the stale worktree, prune merged branches, ignore the worktree dir | 2 | 4,345 |
| [#29](threads/029-issue.md) | issue | backlog-lint and glossary-lint report OK after an unclosed comment or code fence hides t | 1 | 4,767 |
| [#31](threads/031-issue.md) | issue | AGENTS.md contradicts the rules it summarises — R10 omits itself, R4 omits the agent loo | 1 | 5,218 |
| [#33](threads/033-issue.md) | issue | Clear the review debt: run the missing independent review rounds over the seven merged P | 10 | 100,704 |
| [#34](threads/034-issue.md) | issue | Remove the solo form of R4 — a workaround needs two operators, always | 2 | 5,846 |
| [#35](threads/035-issue.md) | issue | R6 must bind the agent-to-human channel too, not only agent-to-agent | 2 | 4,790 |
| [#36](threads/036-issue.md) | issue | The quality gate lints the working tree, not what is being committed | 4 | 12,264 |
| [#37](threads/037-issue.md) | issue | discipline-tests asserts that a linter exited 1, never why — fixtures can vanish and the | 2 | 6,933 |
| [#38](threads/038-issue.md) | issue | glossary-lint scans less than it claims: five silent holes and one false rejection | 3 | 11,467 |
| [#39](threads/039-issue.md) | issue | CRLF and spaced paths: backlog-lint checks nothing and says OK; adr-lint and prd-lint fa | 3 | 10,777 |
| [#40](threads/040-issue.md) | issue | Six shipped statements are not true of main | 2 | 6,134 |
| [#41](threads/041-issue.md) | issue | One decision, sixteen places: delete the nine prose copies of the linter roster | 2 | 7,530 |
| [#43](threads/043-issue.md) | issue | Record when history on the default branch may be destroyed — the rule the 2026-08-27 res | 25 | 156,084 |
| [#45](threads/045-issue.md) | issue | adr-lint reports OK on ten record shapes that violate the ADR conventions | 0 | 5,699 |
| [#46](threads/046-issue.md) | issue | Two shipped statements still say R1–R11, and one is inside an immutable ADR the kit cann | 0 | 4,996 |
| [#48](threads/048-issue.md) | issue | Decide how a destruction of history may be undone — ADR-0004 leaves it open | 0 | 5,699 |
| [#47](threads/047-pull-request.md) | pull request | docs: T-7d2x record when history on the default branch may be destroyed (ADR-0004) | 0 | 13,607 |

## Why it was archived rather than finished

The audit asked whether Armature is state-of-the-art, over-engineered, or
over-fitted. Answering it meant applying the kit's own quality gate to the kit
itself. The gate's step 5 requires independent review rounds until findings
decay, and over two days that produced **twelve rounds** on a single record —
`ADR-0004`, which is roughly six kilobytes.

The rounds did not converge. Each one found real defects, and rounds 10, 11 and
12 each found a defect *introduced by the repair before it*. The record improved
throughout — round 12's fix was the first that made it smaller — but the process
showed no sign of terminating.

The finding underneath that is the one worth keeping: **a kit that encodes
engineering discipline should probably not be the thing that governs its own
development.** The gate has no stopping rule other than decay, and a
self-referential subject supplies an unlimited quantity of things to find.

This is evidence about the kit, not a failure of the review. It is preserved
here so that a later reader can weigh it rather than rediscover it.

## Where the code is

The branch this archive sits on carries the full working state, including
`docs/adr/0004-destroying-history-on-the-default-branch.md` and its task file
`docs/tasks/t-7d2x.md`. Neither was merged to the default branch.
