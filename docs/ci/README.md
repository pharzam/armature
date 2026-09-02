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
| `agents-lint` | The root `AGENTS.md` and `CLAUDE.md` against the documents they summarise, via [`agents-lint.sh`](../agents/agents-lint.sh). | Ready as-is — but it **needs a root `AGENTS.md`**. It is the one job here that hard-fails on a slimmed kit; delete it if you drop the [agent entry points](../agents/README.md), and [drop its required check with it](#drop-what-you-did-not-install). |
| `link-lint` | Every in-tree Markdown link and heading anchor, via [`link-lint.sh`](../links/link-lint.sh). | Ready as-is. |
| `lint` | Your formatter/linter. | Fill `‹…›`. |
| `tests` | The test ladder, cheap → expensive — unit → integration → end-to-end (see [`test-levels.md`](../tests/test-levels.md)). | Fill each `‹…›`. |
| `security` | Secret, dependency, and static-analysis scans over full history, behind `‹security scanner›` (see [`security-checklist.md`](../tests/security-checklist.md)). | Fill `‹…›`. |
| PR title | Conventional Commits on the PR title (GitHub only). | Ready as-is — but its workflow copy is optional; skip the copy and [drop `conventional-title` with it](#drop-what-you-did-not-install). |
| PR link | The PR body links an issue (R1), via [`pr-link-lint.sh`](pr-link-lint.sh). Its own PR-event workflow (GitHub); an `mr-link` job (GitLab). | Ready as-is — but its workflow copy is optional; skip the copy and [drop `pr-link` with it](#drop-what-you-did-not-install). |

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
any app or token satisfy a name by posting a status under it. The array is this
repository's set, not yours: before you paste it, check every context against
[Drop what you did not install](#drop-what-you-did-not-install) and delete the line
for each job you did not install — and add your own jobs as you fill them.

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
      {"context": "pr-link (PR body links an issue)",           "app_id": 15368},
      {"context": "conventional-title",                         "app_id": 15368},
      {"context": "link-lint (in-tree links and anchors)",      "app_id": 15368}
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

### Drop what you did not install

The eight contexts above are the ones **this** repository requires. Four of them are
jobs the kit itself tells you elsewhere that you may leave out, and the array names
them anyway. Delete the line for each one you did not install:

| Context | Delete it when |
|---------|----------------|
| `audit-record-lint (T-3v9q record)` | Always, unless you install a job like it. No template here ships this one: it is the kit's own job, checking the kit's own record, and it goes with that record. |
| `agents-lint (root AGENTS.md and CLAUDE.md)` | You drop the [agent entry points](../agents/README.md), which the table above says you may. |
| `pr-link (PR body links an issue)` | You do not copy [`github-actions-pr-link.yml`](github-actions-pr-link.yml), which the Activate block marks optional. |
| `conventional-title` | You do not copy [`github-actions-pr-title.yml`](github-actions-pr-title.yml), which the Activate block marks optional. |
| Any other context | You deleted its job under "Delete any job your project does not need". |

`link-lint` is last in the array on purpose, and it is the one line here that names
no droppable job: deleting any line above it leaves the JSON valid, while deleting a
*last* line leaves the comma before it and the body no longer parses. The template
says to keep that job whatever else you drop, so it is the safe anchor. If you do drop
it too, delete the trailing comma on the line above.

**What one wrong line costs.** A required context that no workflow reports never
arrives, so the check stays pending and no pull request merges — the mechanism
**Limits** above states for a renamed or removed job, met from the other end. The body
sets `"enforce_admins": true`, so no pull request merges its way out. Recovery is not
expensive, and it is worth knowing which route costs what: an administrator edits the
protection in the repository's own settings, under Branches, at no token cost —
`enforce_admins` binds merges, not the setting itself. The scripted route is a second
`PUT` of the whole corrected body, and that one needs the administration-scoped token
**Limits** names, which `secrets.GITHUB_TOKEN` does not carry. So an adopter who set
this from CI can undo it by hand but not from CI.

**On another forge.** This subsection is GitHub-shaped, because the array it prunes is
GitHub's. [`gitlab-ci.yml`](gitlab-ci.yml) ships `‹…›` jobs of its own, and its gate —
"Pipelines must succeed" on a protected branch — is pipeline-wide: there is no list of
contexts to prune, so nothing here has to be deleted, and a job you leave unfilled
fails the whole pipeline rather than leaving one check pending. That is the same trap
with a louder failure and no edit to get wrong. `‹the setting under which a failing
pipeline blocks the merge›` is where an adopter on a third forge records what their
own gate does.

**The same instruction, read the other way.**
[`github-actions-ci.yml`](github-actions-ci.yml) ships three jobs the array names none
of, and they run green while blocking nothing until you add them — the trap this
section exists to close, met from the third side. Add each one **as you fill it**, and
add its *context*, which is the job's `name:` and not its id:
`lint (‹your linter/formatter›)`, `tests (unit → integration → e2e)` and
`security (‹security scanner›)`. Two of those names still hold a `‹…›` marker, so
replace the marker in the workflow first and copy the resulting name: a context that
names a marker is a context nothing will ever report, which is this section's own
failure by another route. Add none of them before the job has reported once.
