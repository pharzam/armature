# Decision records — this repository's own governance history

This directory holds the Architecture Decision Records that shaped **the kit
itself** rather than a project built with it. They were moved out of the
constitution ([`docs/adr/`](../adr/README.md)) by
[ADR-0012](0012-split-adr-archive-kit-decisions.md), so that `docs/adr/` ships only
records an adopter would adopt.

**An adopter deletes this whole directory.** No constitutional or core-convention
document links into it — that is a
[rule of the constitution](../adr/README.md#what-belongs-in-this-directory) — so an
adopter's *live rules* stay green when it is removed. It leaves together with the
rest of this repository's own history: [`docs/audit/`](../audit/README.md) and the
historical entries in the [completed-task log](../tasks/completed.md), which link
in here and which an adopter clears on adoption. These records may link *up* to a
constitutional record in [`docs/adr/`](../adr/README.md); that direction survives
the deletion.

The records keep the numeric filenames they had when they lived in `docs/adr/`
(`0005`–`0011`), plus `0012`, the record of the move — so existing history stays
legible. They are cited **by path**, not as a bare "ADR-NNNN", which now means the
living [`docs/adr/`](../adr/README.md) sequence.

**Not linted.** [`adr-lint.sh`](../adr/adr-lint.sh) reads only `docs/adr/`, so the
records here are not checked for template shape, numbering or cross-links. That is
deliberate: they are closed history, two of them already superseded, and a checker
whose only subject is this repository's own past is the kind of self-facing
mechanism the [pivot](0009-refocus-on-the-adopter.md) removed.

## Index

| Record | Title | Status |
| ------ | ----- | ------ |
| [0005](0005-independent-review-may-be-an-agent.md) | Independent review may be an agent | Accepted |
| [0006](0006-derive-expectations-from-prose.md) | Keep deriving expectations from the prose | Superseded by 0010 |
| [0007](0007-link-coverage-belongs-to-link-lint.md) | Link coverage belongs to link-lint | Superseded by 0010 |
| [0008](0008-stop-the-gate-on-a-frozen-head.md) | Stop the gate on a frozen head | Accepted |
| [0009](0009-refocus-on-the-adopter.md) | Refocus on the adopter; stop the unattended-run milestone | Accepted |
| [0010](0010-cut-the-self-facing-checks.md) | Cut the self-facing checks; de-link immutable references | Accepted |
| [0011](0011-fail-on-a-missing-named-suite.md) | Fail on a missing named suite | Accepted |
| [0012](0012-split-adr-archive-kit-decisions.md) | Split docs/adr/: archive the kit's own governance decisions | Accepted |
