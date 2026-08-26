# backlog-lint self-tests

Fixtures for [`../backlog-lint.sh`](../backlog-lint.sh), **not** example task
indexes to copy. Each `<case>/` directory holds a `backlog.md` and a
`completed.md`, and the linter is pointed at the case directory.

The real run (`sh docs/tasks/backlog-lint.sh`, no argument) reads
`docs/tasks/backlog.md` and `docs/tasks/completed.md` only — it never descends
here — so these fixtures never affect the kit's own green state.

| Case | Expected | Exercises |
| ---- | -------- | --------- |
| `good` | `backlog-lint: OK`, exit 0 | a well-formed backlog and completed log |
| `bad-multiline` | FAIL, exit 1 | a task entry that spills onto a second line |
| `bad-dup-id` | FAIL, exit 1 | the same task id used twice in the backlog |
| `bad-in-both` | FAIL, exit 1 | a task listed as "Now" that is also in the completed log |
| `bad-no-date` | FAIL, exit 1 | a completed entry with no completion date |
| `bad-malformed` | FAIL, exit 1 | an entry that is not `- **<ID>** — <summary>` |

Run one: `sh docs/tasks/backlog-lint.sh docs/tasks/tests/good`

Run them all, with every other linter's fixtures:
`sh docs/tests/discipline-tests.sh`
