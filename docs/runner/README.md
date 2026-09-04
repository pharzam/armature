# Unattended runs

The mechanisms that let a task run without a person starting each step, and the
tests that keep them honest. This directory opens with the **pre-flight**: the
check that refuses to start a run when a precondition is missing.

| File | What it is |
| ---- | ---------- |
| [`preflight.sh`](preflight.sh) | The pre-flight. Reads the preconditions a run needs and exits naming the first unmet one, with a stable code for its class and the command that fixes it. |
| [`tests/preflight-cases.sh`](tests/preflight-cases.sh) | Its cases — one built environment per precondition class. Its own [CI job](../../.github/workflows/ci.yml), for the reason under [How the cases are wired](#how-the-cases-are-wired). |

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

In this order, cheapest first, so a run whose configuration is wrong never *pays*
for a network fetch. Order is a cost argument only; the ten-second bound is held by
the cap below, not by the ordering:

1. **The hooks path** is configured, and resolves inside *this* working tree.
   Configured, not merely resolvable: with `core.hooksPath` unset git falls back to
   `.git/hooks`, which every linked worktree reaches through the shared common git
   directory — so a check added on a branch would not run on that branch.
2. **The worktree directory** is configured, is a directory, is writable, and this
   task's subdirectory is free. Two runs of one task would otherwise land in the
   same tree and overwrite each other.
3. **The forge tool** is configured and on `PATH`.
4. **The credential** authenticates, and **every scope** the run needs is held by
   **one account** — see below.
5. **The base branch** is fetchable.

It stops at the **first** unmet precondition. Reporting all of them at once reads as
more helpful and is not: a later check often fails only *because* an earlier one
did, so a list invites the operator to fix four things when one was wrong.

## One account's scopes, never the union

`gh` prints one block per host, and since 2.40 one block per account per host. An
earlier version of this script read *every* `Token scopes:` line and treated the
result as one set, so a work account holding `repo` and a personal account holding
`workflow` passed a check that required both — the exact shape of #80, waved through
by the check written to catch it.

The scopes are now read from the block marked the active account. With one block the
question does not arise. With several and **none** marked active the pre-flight
refuses rather than guess, because guessing here is what #80 cost.

## The ten-second bound is enforced, not hoped for

Two steps can reach the network — `auth status` and the base-ref fetch — and neither
git nor the forge tools take a timeout argument. Measured on this branch: against a
remote that never answers, the first version ran **44 seconds and printed nothing**,
against an acceptance criterion of ten.

Both steps now run under a wall-clock cap. POSIX has no `timeout`, so `run_bounded`
is a watchdog: the command runs in the background and a second background shell kills
it once the cap fires, with a flag file recording which of the two won — a killed
command and a command that failed on its own both come back non-zero, and without the
flag the refusal would name the wrong cause.

The cap is `armature.preflightTimeout`, four seconds by default. Two capped steps at
four keep the worst case inside ten. `GIT_TERMINAL_PROMPT=0` closes the credential
prompt; the cap closes the rest.

## It never prints a credential value

The forge tool's output is read and never echoed; only scope names, which are not
secret, reach a message. Every case in
[`tests/preflight-cases.sh`](tests/preflight-cases.sh) asserts that a secret-shaped
token printed by its stub tool is absent from the output — one assertion applied
everywhere, so the promise is a property of the script rather than of the one case
someone thought to write.

## Every refusal carries a code

`refuse` prints three lines — what is wrong, a `code:` naming the precondition class,
and a `fix:` giving one command:

```
preflight: the forge credential is missing scope: repo
           code: forge-missing-scope
           fix: gh auth refresh -s repo
```

The **code is the contract** the cases assert on, and prose is not. Round one
measured `bad-forge-cli-unset` passing with the very check it existed for deleted,
because the substring it asserted — `armature.forgeCli` — also appears in a
*different* refusal's fix line. A case matching loose prose cannot tell one
precondition class from another, which is the one thing it exists to do. The suite
also fails if two classes ever share a code.

## The values you supply

Five values belong to the adopter, and the pre-flight **guesses none of them**. It
reads them from repository-local configuration, and an unset one *is* an unmet
precondition, reported with the command that sets it:

| Key | Supplies | Default |
| --- | --- | --- |
| `armature.forgeCli` | your forge command-line tool | none — unset is an unmet precondition |
| `armature.forgeScopes` | the scopes a run needs, space-separated | none — unset is an unmet precondition |
| `armature.worktreeDir` | your `‹worktree dir›`, as in [`engineering-discipline.md`](../engineering-discipline.md) | none — unset is an unmet precondition |
| `armature.baseRef` | the branch a task branches off | `origin/main`, which the quality gate already fixes |
| `armature.preflightTimeout` | the cap on each network step, in seconds | `4` |

Configuration rather than a file of filled-in placeholders, for three reasons: no
`‹…›` marker has to be replaced in the tree to make the check pass, the values are
machine-local rather than project-local, and a marker cannot express *unset*, so
there would be nothing to refuse on. The full selection with its rejected
alternatives is recorded on
[#126](https://github.com/pharzam/armature/issues/126#issuecomment-5540501153).

**An ADR falls due** on the first change that makes a *second* mechanism read the
`armature.*` namespace. Whichever of #124, #125 or #136 lands first carries it, so
none of them inherits the decision undecided.

## The forge tool contract

The configured tool must answer `auth status`:

- a **non-zero exit** means no authenticated account;
- a **`Token scopes:` line** lists the scopes held;
- where more than one account is reported, the one to use is marked
  **`Active account: true`**.

Both `gh` and `glab` behave this way. The output is read from standard output and
standard error together, because the tools disagree about which one it goes to and
have changed their minds between versions.

A tool that answers `auth status` differently needs a different pre-flight, not a
translation layer here — say so in an [ADR](../adr/) rather than widening the parser
until it accepts anything.

## Why `preflight.sh` is not in `AGENTS.md`'s check list

`agents-lint.sh`'s A21 requires every check the tree ships at
`docs/*/*-lint.sh`, `docs/*/run-*-tests.sh` or `docs/*/*-check.sh` to appear in that
file's `## Checks you can run` block. `preflight.sh` matches none of those patterns,
and this is the written record of why — A21's other two exemptions are written down
in `agents-lint.sh`'s own header, and this one was not, which left the constraint
resting on a filename nobody had explained.

**The reason is the credential and the network, not the toolchain.**
`nested-checkout-check.sh` is in that block and needs a live repository, so "they
read only text, so they need no toolchain" already means no *product* toolchain. What
makes `preflight.sh` different is that it authenticates against a forge and fetches
from a remote: it cannot pass on a machine with no credential, so listing it as a
check an operator "can run" would be false.

**The constraint this imposes on the rest of this directory.** Anything added here
later and named `*-check.sh` — the runner (#125), the stop control (#136) — will be
harvested by A21 and must then be listed in `AGENTS.md`, whose word budget is
measured in single figures of spare words. Name a mechanism that reaches a credential
or a network so that it does not match, and record why here.

`tests/preflight-cases.sh` *is* listed, because it needs only git and reaches no
network — the same bar `nested-checkout-check.sh` meets.

## How the cases are wired

Every other discipline suite points a linter at a directory of committed text. The
preconditions here are properties of a live repository and a credential, and no
committed directory can hold them — a fixture cannot carry a nested repository
directory. So each case is **built**: one template environment is made once, then
copied per case and mutated in exactly one way, leaving every case otherwise valid so
it fails for its own single reason.

That is the shape [`nested-checkout-check.sh`](../tests/nested-checkout-check.sh)
already has, and the cases follow it: **their own CI job**, in CI's restore list, and
*not* a suite inside [`run-discipline-tests.sh`](../tests/run-discipline-tests.sh).
An earlier version of this change added a third dispatch shape to that shared runner
instead. It was withdrawn, because the runner's contract is per-case `good*`/`bad*`
accounting with a coverage floor, and a harness reporting one aggregate result sits
outside both.

**Two things follow, and both are stated rather than implied.** The cases do not run
in the pre-commit hook: they need `git init`, real commits and about fifteen seconds.
And a change to a check is judged by the default branch's copy — the #84 control — so
an *improvement* to these cases reaches CI only from the pull request **after** the
one that makes it. That is the two-step landing
[`guardrails.md`](../guardrails.md) pre-registers, and it applies here as it does to
every other check in the restore list.

## Running it

```
sh docs/runner/preflight.sh <task-ID> [working-tree]
sh docs/runner/tests/preflight-cases.sh [-v]
```

The pre-flight exits `0` when every precondition is met, `1` when one is unmet and
named, `2` on bad usage.
