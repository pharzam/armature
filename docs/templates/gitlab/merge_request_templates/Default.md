<!-- See docs/issue-workflow.md. A merge request with no linked issue does not merge (R1). -->

## Linked issue (R1)

‹`Closes #N`› <!-- or `Refs #N` / `Part of #N` for a parent/multi-part issue -->

## What & why (R7)

- **Action:** ‹what this change does›
- **Why:** ‹the reason, and the fact/requirement it serves›
- **Tradeoffs:** ‹what was weighed, what was rejected›

## Acceptance criteria

- [ ] Every acceptance box on the linked issue is ticked.
- [ ] Tests cover the change and fail against the old code (R8).
- [ ] Independent review ran until findings decayed; evidence committed.
- [ ] Docs and comments updated in this same merge request.
- [ ] The task line is recorded in `tasks/completed.md`, moved from `tasks/backlog.md` where the task had a line there.
