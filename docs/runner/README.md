# Unattended runs

The mechanisms that let a task run without a person starting each step, and the
tests that keep them honest. This directory opens with the **pre-flight**: the
check that refuses to start a run when a precondition is missing.

| File | What it is |
| ---- | ---------- |
| [`preflight.sh`](preflight.sh) | The pre-flight. Its header carries the implementation rationale. |
| [`tests/preflight-cases.sh`](tests/preflight-cases.sh) | Its cases — one built environment per precondition class. Its own [CI job](../../.github/workflows/ci.yml), for the reason under [How the cases are wired](#how-the-cases-are-wired). |

This file holds the decisions that live nowhere else. It does **not** restate the
scripts: a claim kept in three places changes in one of them and not the others.

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
The cost was not the missing scope; it was **when it was found**. This is
[R5](../issue-workflow.md#r5--deterministic-over-llm-based): a deterministic check
in place of discovering the fault the expensive way.

## What it checks

Cheapest first, so a run whose configuration is wrong never *pays* for a network
fetch. Order is a cost argument only — the ten-second bound is held by a wall-clock
cap, not by the ordering.

1. **The hooks path** is configured, and resolves inside *this* working tree.
2. **The worktree directory** is configured, is a directory, is writable, and this
   task's subdirectory is free.
3. **The forge tool** is configured and on `PATH`.
4. **The credential** authenticates, and **one account** holds every scope the run
   needs — never the union of several.
5. **The base branch** is fetchable.

It stops at the **first** unmet precondition, and it never prints a credential
value. Both network steps run under `armature.preflightTimeout`.

## Every refusal carries a code

```
preflight: the forge credential is missing scope: repo
           code: forge-missing-scope
           fix: gh auth refresh -s repo
```

The **code is the contract** the cases assert on, and prose is not — round one found
four of ten cases asserting a substring some *other* refusal also emits. One asserted
a configured value that both base-ref refusals interpolate, which no longer substring
could have fixed. The suite fails if two classes ever share a code.

## The values you supply

Five values belong to the adopter, and the pre-flight **guesses none of them**. An
unset one *is* an unmet precondition, reported with the command that sets it:

| Key | Supplies | Default |
| --- | --- | --- |
| `armature.forgeCli` | your forge command-line tool | none — unset is an unmet precondition |
| `armature.forgeScopes` | the scopes a run needs, space-separated | none — unset is an unmet precondition |
| `armature.worktreeDir` | your `‹worktree dir›`, as in [`engineering-discipline.md`](../engineering-discipline.md) | none — unset is an unmet precondition |
| `armature.baseRef` | the branch a task branches off | `origin/main`, which the quality gate already fixes |
| `armature.preflightTimeout` | the cap on each network step, in seconds | `4` |

Configuration rather than filled-in placeholders, for three reasons: no `‹…›` marker
has to be replaced in the tree to make a check pass, the values are machine-local
rather than project-local, and a marker cannot express *unset*, so there would be
nothing to refuse on. The full selection with its rejected alternatives is on
[#126](https://github.com/pharzam/armature/issues/126#issuecomment-5540501153).

**An ADR falls due** on the first change that makes a *second* mechanism read the
`armature.*` namespace. Whichever of #124, #125 or #136 lands first carries it.

## The forge tool contract

The configured tool must answer `auth status`:

- a **non-zero exit** is treated as no usable credential — but see the measured
  limit below, because the exit code alone is not trustworthy in either direction;
- a **`Token scopes:` line** lists the scopes held;
- where more than one account is reported, the ones in play are marked
  **`Active account: true`**.

**The exit code is not trustworthy on its own, measured in both directions.**
`glab auth status` exits **1** while the host you use is fully authenticated, because
an *unrelated* second GitLab instance failed. And `gh auth status` exits **0** with an
invalid `GH_TOKEN` marked active — printing the failure as `Failed to log in to …`,
which is not the `Logged in to` shape a block starts with, and carrying no scopes
line while a working but **inactive** account below it does. Reading that inactive
account's scopes was a false *pass*: the pre-flight said `OK` over a credential that
would fail at the push, in exactly the environment it exists for, since GitHub
Actions and most agent harnesses set `GH_TOKEN`. So an account marked active that
reports no scopes is refused (`forge-active-account-broken`) rather than skipped, and
the scope check — not the exit code — is what catches it.

That refusal is **attributed to a host**, like the selection itself: only a broken
active account on the host the run targets refuses it. A first version made the check
global and so refused a perfectly good run because an unrelated host held a scopeless
bot token. A failed block carries no `Logged in to` line — `gh` writes it as *"Failed
to log in to …"* — so its host comes from the bare host-section header above it,
which is the only reason that header is parsed.

Attribution **fails closed**, because getting it wrong the other way is a false pass.
An unresolved block is closed at *every* block boundary, a section header included —
closing only at login lines let a later failure on another host inherit the target's
attribution — and a host guessed from a section header is trusted only when that host
was actually seen on a login line and is not the target. Anything else is treated as
the target's. Three false passes were measured against earlier versions of exactly
this logic; each now has a case.

### The scope model has no answer for an installation token

`gh` prints `Token scopes:` **only** for classic and OAuth tokens. An installation
token (`ghs_`) or a fine-grained PAT authenticates, exits 0, and reports **no scopes
line at all** — and `ghs_` is what `GH_TOKEN` holds inside GitHub Actions, which is
the environment this whole feature is named for.

Such a credential is refused as `forge-scopes-unverifiable`, deliberately distinct
from `forge-active-account-broken`: it is a **working** credential whose permissions
simply are not OAuth scopes, and calling it broken would be false. The pre-flight
refuses rather than passes because it cannot verify the precondition it exists to
verify, and this branch has already shipped two false passes by assuming instead.

**So the scope check does not work under a GitHub Actions token today.** Verifying an
installation token's permissions needs an API call, not a transcript, which is a
different mechanism and a different change. Two neighbouring limits no parsing can
see: a token authorized for SAML SSO enforcement shows `repo` and still fails the
push until authorized, and an SSH remote presents no OAuth token on push at all, so
the scopes checked may not be the ones used.

**The host is the selector, not activeness.** `gh` marks one account active **per
host** — *"Each host section will indicate the active account, which will be used
when targeting that host"* — so a two-host login has **two** active accounts and
neither is wrong. The pre-flight matches the account block whose host is the host of
**`origin`'s URL**, because that is where a run pushes and opens its pull request.
`armature.baseRef` may name a different remote; it answers a different question,
whether the base branch can be fetched.

Within that host: one account is used; several with one marked active uses the active
one; several with none marked active is refused (`forge-ambiguous-account`) rather
than guessed. No account for that host is `forge-no-account-for-host`. An `origin`
whose URL names no host — a local path — is `forge-host-unknown` when more than one
account is reported. **Scope sets are never merged across accounts.**

Two rules were tried and measured wrong before this one, both by keying on
activeness rather than host: *exactly one active* refused every valid two-host setup
and told the operator "marks none of them active" when both were; *every active
account holds every scope* then refused a perfectly good run against `github.com`
because an unrelated enterprise token carried fewer scopes. Enterprise tokens
routinely differ, and nothing about another host can harm this run.

**Which tools meet it, measured rather than assumed.** `gh` does. **`glab` does
not** — its binary carries neither string (`strings $(command -v glab) | grep -ci
'token scopes'` → `0`, against `2` for `gh`), and it has no `auth refresh`
subcommand either. An earlier draft of this file claimed both tools behaved this
way; that claim was false, and a `glab` adopter with a perfectly good credential
would have been refused, with a fix line naming a command that does not exist.

A tool that does not meet the contract is refused by name — `forge-no-scope-line`,
not a wrong "missing scope" — so the failure says what is actually wrong. Making one
work needs a different pre-flight, not a translation layer here: say so in an
[ADR](../adr/) rather than widening the parser until it accepts anything.

## Why `preflight.sh` is not in `AGENTS.md`'s check list

`agents-lint.sh`'s A21 requires every check shipped at `docs/*/*-lint.sh`,
`docs/*/run-*-tests.sh` or `docs/*/*-check.sh` to appear in that file's
`## Checks you can run` block. `preflight.sh` matches none of those patterns, and
this is the written record of why — A21's other two exemptions are written down in
`agents-lint.sh`'s header, and this one was not, which left the constraint resting on
a filename nobody had explained.

**The reason is the credential and the network, not the toolchain.**
`nested-checkout-check.sh` is in that block and needs a live repository, so "they read
only text, so they need no toolchain" already means no *product* toolchain. What makes
`preflight.sh` different is that it authenticates against a forge and fetches from a
remote: it cannot pass on a machine with no credential, so listing it as a check an
operator "can run" would be false.

**The constraint this imposes on the rest of this directory.** Anything added here
later and named `*-check.sh` — the runner (#125), the stop control (#136) — will be
harvested by A21 and must then be listed in `AGENTS.md`, whose word budget has single
figures of spare words. Name a mechanism that reaches a credential or a network so it
does not match, and record why here.

`tests/preflight-cases.sh` *is* listed: it needs only git and reaches no network, the
same bar `nested-checkout-check.sh` meets.

## How the cases are wired

Every other discipline suite points a linter at committed text. These preconditions
are properties of a live repository and a credential, and no committed directory can
hold them — a fixture cannot carry a nested repository directory. So each case is
**built**: one template environment, copied per case and mutated in exactly one way,
leaving every case otherwise valid so it fails for its own single reason.

That is the shape [`nested-checkout-check.sh`](../tests/nested-checkout-check.sh)
already has, and the cases follow it: **their own CI job**, in CI's restore list, and
*not* a suite inside [`run-discipline-tests.sh`](../tests/run-discipline-tests.sh).
An earlier version of this change added a third dispatch shape to that shared runner.
It was withdrawn: the runner's contract is per-case `good*`/`bad*` accounting with a
coverage floor, and a harness reporting one aggregate result sits outside both — and
it did not even work, reporting **146 on `main` and 146 on the pull request**, because
CI restores that runner from the default branch.

**Two things follow, both stated rather than implied.** The cases do not run in the
pre-commit hook: they need `git init`, real commits and about fifteen seconds. And a
change to a check is judged by the default branch's copy — the #84 control — so an
*improvement* to these cases reaches CI only from the pull request **after** the one
that makes it. That is the two-step landing [`guardrails.md`](../guardrails.md)
pre-registers, and it applies here as to every other check in the restore list.

## Running it

```
sh docs/runner/preflight.sh <task-ID> [working-tree]   # 0 met, 1 unmet, 2 bad usage
sh docs/runner/tests/preflight-cases.sh [-v]
```
