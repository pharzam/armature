# Continuous integration (optional)

CI runs the [quality gate](../engineering-discipline.md) automatically on every
change, so the gate is enforced by the forge rather than by memory. It is the
**authority** — its checks are the ones you make required before a merge. The
[`.githooks/`](../../.githooks/) run the same rules locally for fast feedback.

**This is optional.** Armature is domain- and forge-free, so nothing here runs
until you opt in. The templates in this directory are **inert** — they will not
run while they sit here (that is deliberate: a half-filled workflow must never go
red on the kit itself). You activate CI by copying the template your forge uses
into the place it expects.

## Activate

**GitHub Actions:**

```bash
mkdir -p .github/workflows
cp docs/ci/github-actions-ci.yml       .github/workflows/ci.yml
cp docs/ci/github-actions-pr-title.yml .github/workflows/pr-title.yml   # optional
```

**GitLab CI:**

```bash
cp docs/ci/gitlab-ci.yml .gitlab-ci.yml
```

Then replace every `‹…›` marker with your stack's command, and make the checks
**required** on your default branch (GitHub: branch protection; GitLab: protected
branch + "pipelines must succeed").

## What the templates run

| Job | What it checks | Ready or adapt? |
|-----|----------------|-----------------|
| `adr-lint` | `docs/adr/` discipline, via [`adr-lint.sh`](../adr/adr-lint.sh). | Ready as-is. |
| `lint` | Your formatter/linter. | Fill `‹…›`. |
| `tests` | Your `‹test runner›`. | Fill `‹…›`. |
| `secrets` | Secret scan over full history. | Fill `‹…›`. |
| PR title | Conventional Commits on the PR title (GitHub only). | Ready as-is. |

Delete any job your project does not need. If you add a discipline test beyond
the ADR linter, wire it into both a CI job and the
[`pre-commit`](../../.githooks/pre-commit) hook.
