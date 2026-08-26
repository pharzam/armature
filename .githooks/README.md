# Git hooks

Local enforcement of the [quality gate](../docs/engineering-discipline.md). These
hooks catch a violation **before** it is committed, so it never reaches CI or a
reviewer. They are the fast-feedback twin of [`docs/ci/`](../docs/ci/), which is
the authority — both run the same rules.

Hooks live here (version-controlled), not in `.git/hooks` (local, untracked), so
the whole team shares one set.

## Install (one command)

```bash
git config core.hooksPath .githooks
```

Until you run this, the hooks are inert. Run it once per clone. To stop using
them, `git config --unset core.hooksPath`.

## What each hook does

| Hook | Runs | Adapt? |
|------|------|--------|
| [`pre-commit`](pre-commit) | The ADR, PRD, and glossary linters, then your `‹lint›` / test levels (fast subset) / security checks (fast subset). | Fill the `‹…›` steps for your stack. |
| [`commit-msg`](commit-msg) | Conventional-Commits check on the subject line. | Ready as-is. |
| [`pre-push`](pre-push) | Refuses a direct push to `main` — use a branch and a PR instead. | Change the branch name if your default is not `main`. |

## Protecting `main`

[`pre-push`](pre-push) blocks a direct push to `main` so changes go through a
branch and a pull request. It is a **local, fast-feedback guardrail only** —
advisory, bypassable with `git push --no-verify`, and absent on a fresh clone
until `core.hooksPath` is set. The real, unbypassable lock is your host's
**branch-protection rule** (require a pull request before merging), enforced
server-side. Turn that on for every repo; this hook is its local twin, not a
substitute.

## How to adapt

1. Open [`pre-commit`](pre-commit) and replace each `‹…›` with your project's
   command, then uncomment that line. Delete any step you do not use. Keep the
   steps cheap-first and fast — the full test suite belongs in CI.
2. [`commit-msg`](commit-msg) is ready to use; widen its type list only if you
   first agree the new type in
   [§"Commit messages"](../docs/engineering-discipline.md#commit-messages).

## Optional: the `pre-commit` framework

For a richer setup — pinned, shared, auto-updating hooks across languages — adopt
the [`pre-commit`](https://pre-commit.com) framework and drive it from a
`.pre-commit-config.yaml`. It replaces these shell hooks; keep one approach, not
both. The plain hooks here are the dependency-free default.
