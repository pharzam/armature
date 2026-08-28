# commit-msg self-tests

These are fixtures for the [`../../commit-msg`](../../commit-msg) hook, **not**
example commits. Each `*.txt` file holds a candidate commit message; the hook is
run as `sh .githooks/commit-msg <file>` (the same way git invokes it) and its exit
code is asserted. The [discipline-test runner](../../../docs/tests/run-discipline-tests.sh)
drives every case and asserts the outcome.

| Case | Expected | Exercises |
| ---- | -------- | --------- |
| `good-simple` | exit 0 | `type: description` |
| `good-scope` | exit 0 | `type(scope): description` |
| `good-task-id` | exit 0 | a task ID after the colon (`feat(store): T-1a2b …`) |
| `good-breaking` | exit 0 | the breaking-change `!` marker (`refactor!: …`) |
| `good-merge` | exit 0 | a git-generated `Merge …` subject (short-circuited) |
| `bad-no-type` | exit 1 | no `type:` prefix at all |
| `bad-unknown-type` | exit 1 | a type outside the allowed set |
| `bad-capital-type` | exit 1 | a capitalised type (`Docs:`) |
| `bad-no-description` | exit 1 | a `type:` with no description |

The `good*` / `bad*` filename prefix is the runner's contract: `good*` must exit 0,
`bad*` must exit 1. A `bad-*` subject must not begin with `Merge `, `Revert `,
`fixup!`, `squash!`, or `amend!` — the hook lets those through by design, so such a
subject would wrongly pass.
