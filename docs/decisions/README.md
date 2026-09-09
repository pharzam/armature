# Decision records — this repository's own governance history

This directory holds the Architecture Decision Records that shaped **the kit
itself** rather than a project built with it. They were moved out of the
constitution ([`docs/adr/`](../adr/README.md)) by
[D-0007](D-0007-split-adr-archive-kit-decisions.md), so that `docs/adr/` ships only
records an adopter would adopt.

**An adopter deletes this whole directory** — it is step 4 of [*How to adapt this kit*](../engineering-discipline.md#how-to-adapt-this-kit). No constitutional or core-convention
document links into it — that is a
[rule of the constitution](../adr/README.md#what-belongs-in-this-directory) — so an
adopter's *live rules* stay green when it is removed. It leaves together with the
rest of this repository's own history: [`docs/audit/`](../audit/README.md) and the
historical entries in the [completed-task log](../tasks/completed.md) and
[`T-k4vm.md`](../tasks/T-k4vm.md), which link in here and which an adopter clears on
adoption. These records may link *up* to a
constitutional record in [`docs/adr/`](../adr/README.md); that direction survives
the deletion.

The records carry a **prefixed, zero-based identifier** — `D-0000`–`D-0007` — a
namespace that shares **no number** with the living [`docs/adr/`](../adr/README.md)
sequence, now or as either grows, and they are cited **by that identifier**. A bare
`ADR-NNNN` means the living sequence; a `D-NNNN` means this archive. The former scheme
kept each record's original `docs/adr/` filename (`0005`–`0012`) and leaned on an
unenforced "cite the archive by path" rule to tell the two apart; that rule broke once
the living sequence reached `0005`, so
[D-0008](D-0008-namespace-the-decision-archive.md) renumbered the archive into this
namespace and **amends** [D-0007](D-0007-split-adr-archive-kit-decisions.md)'s
numbering clause. The mapping from each former filename is below, so a citation
written before the renumbering — including one in external history that cannot be
rewritten — still resolves.

| Former `docs/adr/` filename | Archive identifier | Title |
| --- | --- | --- |
| `0005` | `D-0000` | Independent review may be an agent |
| `0006` | `D-0001` | Keep deriving expectations from the prose |
| `0007` | `D-0002` | Link coverage belongs to link-lint |
| `0008` | `D-0003` | Stop the gate on a frozen head |
| `0009` | `D-0004` | Refocus on the adopter |
| `0010` | `D-0005` | Cut the self-facing checks |
| `0011` | `D-0006` | Fail on a missing named suite |
| `0012` | `D-0007` | Split docs/adr/: archive the kit's own governance decisions |

**Not linted.** [`adr-lint.sh`](../adr/adr-lint.sh) reads only `docs/adr/`, so the
records here are not checked for template shape, numbering or cross-links. That is
deliberate: they are closed history, two of them already superseded, and a checker
whose only subject is this repository's own past is the kind of self-facing
mechanism the [pivot](D-0004-refocus-on-the-adopter.md) removed.

## Index

| Record | Title | Status |
| ------ | ----- | ------ |
| [D-0000](D-0000-independent-review-may-be-an-agent.md) | Independent review may be an agent | Accepted |
| [D-0001](D-0001-derive-expectations-from-prose.md) | Keep deriving expectations from the prose | Superseded by D-0005 |
| [D-0002](D-0002-link-coverage-belongs-to-link-lint.md) | Link coverage belongs to link-lint | Superseded by D-0005 |
| [D-0003](D-0003-stop-the-gate-on-a-frozen-head.md) | Stop the gate on a frozen head | Accepted |
| [D-0004](D-0004-refocus-on-the-adopter.md) | Refocus on the adopter; stop the unattended-run milestone | Accepted |
| [D-0005](D-0005-cut-the-self-facing-checks.md) | Cut the self-facing checks; de-link immutable references | Accepted |
| [D-0006](D-0006-fail-on-a-missing-named-suite.md) | Fail on a missing named suite | Accepted |
| [D-0007](D-0007-split-adr-archive-kit-decisions.md) | Split docs/adr/: archive the kit's own governance decisions | Accepted. Amended by D-0008 |
| [D-0008](D-0008-namespace-the-decision-archive.md) | Give the decision archive its own prefixed identifier sequence | Accepted |
