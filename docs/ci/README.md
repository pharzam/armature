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

**Live example — the kit runs its own.** Armature's repo activates the *ready-as-is*
subset for itself, under [`.github/workflows/`](../../.github/workflows/):
[`ci.yml`](../../.github/workflows/ci.yml) (`adr-lint`, `prd-lint`,
`discipline-tests`, `audit-record-lint`, `agents-lint`, `link-lint`),
[`pr-title.yml`](../../.github/workflows/pr-title.yml), and
[`pr-link.yml`](../../.github/workflows/pr-link.yml). It omits the `lint`, `tests`,
and `security` jobs because the kit ships no product code to run them against — a
worked instance of "delete any job your project does not need." Use those files as a
filled-in reference alongside the templates here.

## Activate

**GitHub Actions:**

```bash
mkdir -p .github/workflows
cp docs/ci/github-actions-ci.yml       .github/workflows/ci.yml
cp docs/ci/github-actions-pr-title.yml .github/workflows/pr-title.yml   # optional
cp docs/ci/github-actions-pr-link.yml  .github/workflows/pr-link.yml    # optional
```

**GitLab CI:**

```bash
cp docs/ci/gitlab-ci.yml .gitlab-ci.yml
```

Then replace every `‹…›` marker with your stack's command, and
[make the checks required](#make-the-checks-required) on your default branch.

## What the templates run

| Job | What it checks | Ready or adapt? |
|-----|----------------|-----------------|
| `adr-lint` | `docs/adr/` discipline, via [`adr-lint.sh`](../adr/adr-lint.sh). | Ready as-is. |
| `prd-lint` | `docs/prd/` discipline, via [`prd-lint.sh`](../prd/prd-lint.sh). | Ready as-is. |
| `discipline-tests` | Runs each discipline linter against its good/bad fixtures, via [`run-discipline-tests.sh`](../tests/run-discipline-tests.sh). | Ready as-is. |
| `agents-lint` | The root `AGENTS.md` and `CLAUDE.md` against the documents they summarise, via [`agents-lint.sh`](../agents/agents-lint.sh). | Ready as-is — but it **needs a root `AGENTS.md`**. It is the one job here that hard-fails on a slimmed kit; delete it if you drop the [agent entry points](../agents/README.md). |
| `link-lint` | Every in-tree Markdown link and heading anchor, via [`link-lint.sh`](../links/link-lint.sh). | Ready as-is. |
| `lint` | Your formatter/linter. | Fill `‹…›`. |
| `tests` | The test ladder, cheap → expensive — unit → integration → end-to-end (see [`test-levels.md`](../tests/test-levels.md)). | Fill each `‹…›`. |
| `security` | Secret, dependency, and static-analysis scans over full history, behind `‹security scanner›` (see [`security-checklist.md`](../tests/security-checklist.md)). | Fill `‹…›`. |
| PR title | Conventional Commits on the PR title (GitHub only). | Ready as-is. |
| PR link | The PR body links an issue (R1), via [`pr-link-lint.sh`](pr-link-lint.sh). Its own PR-event workflow (GitHub); an `mr-link` job (GitLab). | Ready as-is. |

Delete any job your project does not need. If you add a discipline test that lints
files in the repo — as the [PRD linter](../prd/prd-lint.sh) does — wire it into
both a CI job and the [`pre-commit`](../../.githooks/pre-commit) hook, the way
`adr-lint` and `prd-lint` are. A check whose input is a forge artifact, not a repo
file — like [`pr-link-lint.sh`](pr-link-lint.sh), which reads the PR body — has no
local hook to run in and lives in CI only.

## Make the checks required

A check that runs but does not block is a run result, not a merge control. Until a
check is required on the default branch, a red run and a green one merge alike, and
the kit's own [`ci.yml`](../../.github/workflows/ci.yml) says at its head that
making them block is a repository setting, not a file in the tree. This is the step
the two `‹…›` rows of the
[enforcement table](../issue-workflow.md#what-is-enforced-where) leave to you.

**GitHub.** One `PUT` to the branch-protection endpoint sets the whole protection
object. The body goes on standard input with `--input -`, because `gh api` flag
syntax cannot express an array of objects. The `checks` below are the eight the
kit's own repository requires — a context is the check's displayed name, the job's
`name:` or its id when it has none, which is why the last is `conventional-title` —
each pinned to `"app_id": 15368`, GitHub Actions; a bare `contexts` list would let
any app or token satisfy a name by posting a status under it. Drop
`audit-record-lint` with the record it checks, and add your own jobs as you fill them.

```bash
gh api -X PUT repos/‹owner›/‹repo›/branches/‹default branch›/protection --input - <<'EOF'
{
  "required_status_checks": {
    "strict": true,
    "checks": [
      {"context": "adr-lint (docs/adr discipline)",             "app_id": 15368},
      {"context": "prd-lint (docs/prd discipline)",             "app_id": 15368},
      {"context": "discipline-tests (linter fixtures)",         "app_id": 15368},
      {"context": "audit-record-lint (T-3v9q record)",          "app_id": 15368},
      {"context": "agents-lint (root AGENTS.md and CLAUDE.md)", "app_id": 15368},
      {"context": "link-lint (in-tree links and anchors)",      "app_id": 15368},
      {"context": "pr-link (PR body links an issue)",           "app_id": 15368},
      {"context": "conventional-title",                         "app_id": 15368}
    ]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": false,
    "require_code_owner_reviews": false,
    "require_last_push_approval": false,
    "required_approving_review_count": 0
  },
  "restrictions": null,
  "required_linear_history": false,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "block_creations": false,
  "required_conversation_resolution": true,
  "lock_branch": false,
  "allow_fork_syncing": false
}
EOF
```

**The body is the whole setting, so a partial body is destructive.** The `PUT`
replaces the entire protection object, and `required_status_checks`,
`enforce_admins`, `required_pull_request_reviews` and `restrictions` are required
parameters: a body that omits `required_conversation_resolution` turns it off, and
one that sends `required_pull_request_reviews` as `null` removes the pull-request
requirement while adding the check requirement. `"restrictions": null` is required,
and must be null on a user-owned repository, because push restrictions exist for
organizations only. `required_signatures` is a separate endpoint the `PUT` does not
touch. Read the setting back with
`gh api repos/‹owner›/‹repo›/branches/‹default branch›/protection`; that output, not
the green run, is the evidence a close-out records.

**Another forge.** GitLab: protect the default branch and turn on "Pipelines must
succeed". Elsewhere: `‹the setting under which a failing pipeline blocks the merge,
and the command that sets it›`.

**Limits.** Writing or reading the setting needs an administration-scoped token,
which `secrets.GITHUB_TOKEN` does not carry, so no text-only check in this kit
proves it: the verification is the command above, run by an operator, and each
close-out records its output. A renamed or removed **job** blocks every merge until
the setting follows it — the check name is the job's `name:` or its id, never the
workflow's name — which is the right direction of failure, loud and where the gate
lives.
`enforce_admins: true` binds the operator too. `strict: true` mechanises the house
rule to rebase onto the latest `origin/main` before a merge, at a price: with a
plain merge, every merge to the default branch invalidates the up-to-date status of
every other open pull request, so a queue of pull requests serialises into rebase,
re-run, merge. And a required check is only as trustworthy as the script it runs:
seven of the eight jobs check out the pull request's own head and run a linter from
it, so a pull request that edits a check to `exit 0` passes its own required check;
only the PR-title check runs no in-tree script. That is pre-existing, it needs write
access to the repository, and it is tracked in
[#84](https://github.com/pharzam/armature/issues/84).
