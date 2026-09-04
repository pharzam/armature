# Unattended runs

The mechanisms that let a task run without a person starting each step, and the
tests that keep them honest. This directory opens with the **pre-flight**: the
check that refuses to start a run when a precondition is missing.

| File | What it is |
| ---- | ---------- |
| [`preflight.sh`](preflight.sh) | The pre-flight. Reads the preconditions a run needs and exits naming the first unmet one, with the command that fixes it. |
| [`tests/preflight-cases.sh`](tests/preflight-cases.sh) | Its cases — one built environment per precondition class. Run by [`run-discipline-tests.sh`](../tests/run-discipline-tests.sh) in the [`pre-commit` hook](../../.githooks/pre-commit) and in [CI](../ci/). |

## In plain terms

> A run needs a few things before it can do any work: a credential with the right
> scopes, somewhere to put its worktree, a base branch it can reach, and the
> project's hooks switched on. Any of those can be missing. Checking each one where
> it is *used* means the missing scope is discovered at the push — after the whole
> build is already paid for. The pre-flight asks all of them first, in seconds, and
> stops with the name of the one that is missing.

## Why it runs first

Issue [#80](https://github.com/pharzam/armature/issues/80) lost 1 h 40 m to a push
rejected for a missing token scope, discovered only when the build was already done.
Its thread records the fix as one interactive command by the operator.

The cost was not the missing scope. It was **when it was found**. A pre-flight
converts that stall into an immediate, named failure that a successor session can
act on with no human message — which is
[R5](../issue-workflow.md#r5--deterministic-over-llm-based): a deterministic check
in place of discovering the fault the expensive way.

## What it checks

In this order, cheapest first, so a run whose configuration is wrong never pays for
a network fetch:

1. **The hooks path** is configured, and resolves inside *this* working tree.
   Configured, not merely resolvable: with `core.hooksPath` unset git falls back to
   `.git/hooks`, which every linked worktree reaches through the shared common git
   directory — so a check added on a branch would not run on that branch. The
   `pre-commit` hook refuses the same fault at commit time; this refuses it before
   the work starts.
2. **The worktree directory** is configured, writable, and this task's
   subdirectory is free. Two runs of one task would otherwise land in the same tree
   and overwrite each other.
3. **The forge tool** is configured and on `PATH`.
4. **The credential** authenticates, and **every scope** the run needs is held.
5. **The base branch** is fetchable. This is the only check that reaches the
   network, so it is last.

It stops at the **first** unmet precondition. Reporting all of them at once reads as
more helpful and is not: a later check often fails only *because* an earlier one
did, so a list invites the operator to fix four things when one was wrong.

It **never prints a credential value.** The forge tool's output is read and never
echoed; only scope names, which are not secret, reach a message. Every case in
[`tests/preflight-cases.sh`](tests/preflight-cases.sh) asserts that a secret-shaped
token printed by its stub tool is absent from the output — one assertion applied
everywhere, so the promise is a property of the script rather than of the one case
someone thought to write.

## The values you supply

Four values belong to the adopter, and the pre-flight **guesses none of them**. It
reads them from repository-local configuration, and an unset one *is* an unmet
precondition, reported with the command that sets it:

| Key | Supplies | Default |
| --- | --- | --- |
| `armature.forgeCli` | your forge command-line tool | none — unset is an unmet precondition |
| `armature.forgeScopes` | the scopes a run needs, space-separated | none — unset is an unmet precondition |
| `armature.worktreeDir` | your `‹worktree dir›`, as in [`engineering-discipline.md`](../engineering-discipline.md) | none — unset is an unmet precondition |
| `armature.baseRef` | the branch a task branches off | `origin/main`, which the quality gate already fixes |

Configuration rather than a file of filled-in placeholders, for two reasons: no
`‹…›` marker has to be replaced in the tree to make the check pass, and the values
differ per clone, which a committed file cannot express.

## The forge tool contract

The configured tool must answer `auth status`:

- a **non-zero exit** means no authenticated account;
- a **`Token scopes:` line** lists the scopes held.

Both `gh` and `glab` behave this way. The output is read from standard output and
standard error together, because the tools disagree about which one it goes to and
have changed their minds between versions.

A tool that answers `auth status` differently needs a different pre-flight, not a
translation layer here — say so in an [ADR](../adr/) rather than widening the
parser until it accepts anything.

## Why it is not in `AGENTS.md`'s check list

The `## Checks you can run` block promises checks that "read only text, so they need
no toolchain". The pre-flight reads an environment and needs a forge command-line
tool and a credential, so listing it there would make that sentence false. It is
also not in the `pre-commit` hook, which is the fast, offline gate; its **cases**
run there instead, and they reach no network — the "remote" they fetch from is a
bare repository in the same temporary directory.

## Running it

```
sh docs/runner/preflight.sh <task-ID> [working-tree]
```

Exit status: `0` every precondition met, `1` one is unmet and named, `2` bad usage.

## How the cases work

Every other discipline suite points a linter at a directory of committed text. Four
of these five preconditions are properties of a live repository and a credential, and
no committed directory can hold them — a fixture cannot carry a nested repository
directory. So each case is **built**: one template environment is made once, then
copied per case and mutated in exactly one way, leaving every case otherwise valid
so it fails for its own single reason.

That is the third fixture shape
[`run-discipline-tests.sh`](../tests/run-discipline-tests.sh) dispatches, and the
one it cannot count into its own good/bad coverage floor — so the harness carries a
floor of its own.
