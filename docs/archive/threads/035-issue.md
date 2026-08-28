# #35 — R6 must bind the agent-to-human channel too, not only agent-to-agent

*Archived from GitHub. State at archive time: OPEN. Opened 2026-08-27T07:30:33Z.*

---

Part of #16.

## Goal

Widen R6 to the channel it always meant to cover. The rule in full: **an agent
never communicates with the human operator, or with another agent, except through
comments on issues or pull requests.** No direct channel, in either direction.

## Why

R6 today binds agent-to-agent talk only (`docs/issue-workflow.md:84`). The human
half is missing from every document that states it. That leaves the most common
channel in the kit's own audience — one person plus agents — unwritten, and it is
the channel where the reasoning gets lost: a decision taken in a chat session
leaves no trace an auditor, a fresh context, or the next operator can read.

The kit already justifies the rule for agents: it *"keeps the coordination
auditable and lets a fresh context pick up where another left off"*. Nothing in
that reason is specific to agents.

## Duplicate check (R2)

- [x] Searched the open **and** closed issues. No issue covers the human half of
      R6. Parent: #16. Related: #17 (closed) shipped the `AGENTS.md` summary of R6
      that this change edits.

## Solution note (R3)

- **Chosen:** restate R6 to cover both channels, keep the existing severity and
  response-time convention for the agent-to-agent case, and add what the human
  half needs — the substantive answer lands on the issue thread, not only in the
  session. R10 sync across `docs/issue-workflow.md`,
  `docs/engineering-discipline.md`, and `AGENTS.md`.
- **Rejected:** *a new rule R13 for the human channel* — R6 is one rule about one
  thing (coordination is auditable); splitting it by counterpart would leave two
  rules to drift apart. *Leave it as convention* — an unwritten rule is exactly
  the finding #16 raised against this kit.
- **Decision record:** this issue. Not architecturally significant: it widens the
  scope of an existing rule.

## Acceptance criteria

- [ ] R6 in `docs/issue-workflow.md` binds the agent-to-human and human-to-agent
      channel as well as agent-to-agent.
- [ ] R6 states what still may happen in a session, and what has to reach the
      issue.
- [ ] `AGENTS.md` carries the widened R6 line (R10).
- [ ] `docs/engineering-discipline.md` agrees wherever it names the channel.
- [ ] The "What is enforced where" table stays honest about the row.
- [ ] The task line moves from `docs/tasks/backlog.md` to
      `docs/tasks/completed.md` in the same pull request.




---

### Comment — pharzam — 2026-08-27T10:46:35Z

**Status: main was reset.** `main` is back at `2cd70ee` — the revision before any change made under #16.

All work done under this issue is safe. It lives in the branch [`backup/pre-r12-reset-999765f`](https://github.com/pharzam/armature/tree/backup/pre-r12-reset-999765f) (head `999765f`).

**This issue is closed so it can be learned and done again** from a clean main, together with the other child issues, under parent #16 — see https://github.com/pharzam/armature/issues/16#issuecomment-5437842022


---

### Comment — pharzam — 2026-08-27T11:47:22Z

## Reopened — `main` does not hold this deliverable

This issue was closed as **completed**. On 2026-08-27 `main` was reset to [`2cd70ee`](https://github.com/pharzam/armature/commit/2cd70ee), which removed every tranche-1 commit. The deliverable this issue claims is therefore not on `main` today.

Leaving it closed repeats the one defect this whole round found at every layer — *a check that reports OK having checked less than it claims* ([finding R-3 in the review](https://github.com/pharzam/armature/issues/16#issuecomment-5438020512)) — this time in the issue tracker. Phase 0 of that plan states the rule plainly: **the tracker must never claim more than `main` holds.**

### Evidence, checked at `2cd70ee`

R6 at `2cd70ee` binds agent-to-agent talk only: *"An LLM agent never asks another agent directly."* The human half of the channel is absent from every document that states the rule:

- `docs/issue-workflow.md` — agent-to-agent only.
- `docs/engineering-discipline.md` — no statement of the human half.
- `AGENTS.md` — the file does not exist.

The most common channel in the kit's own audience, one person plus agents, is still unwritten.

### Where the work went

Nothing is lost. The tranche-1 history is preserved on [`backup/pre-r12-reset-999765f`](https://github.com/pharzam/armature/tree/backup/pre-r12-reset-999765f), which is **reference only, never a merge source**: each slice re-lands as a fresh pull request from clean `main`, with the review record on this thread as its test list.

### Returns in

**Phase 1** — patch the rules before any code.
