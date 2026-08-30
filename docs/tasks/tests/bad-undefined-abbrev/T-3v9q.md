# T-3v9q — Record two external audits of the kit

A minimal, valid record. Every other case in this directory is this file with one
thing broken, so a failure names the thing that broke.

## In plain terms

> Two audits were run against this kit. Two of their three claims are true. One is
> refuted.

## Why

**Verification result.** 2 of 3 claims stand — 1 as written, 1 with a correction.
One is refuted.

## Definition of Done

This task has **seven** Definition of Done items.

| # | Item | Covered by |
| - | ---- | ---------- |
| 1 | All 3 claims recorded with a verdict | `audit-record-lint.sh` block 1 |
| 2 | Every standing claim cites a file and a line | `audit-record-lint.sh` block 2 |
| 3 | The prose arithmetic matches the tables | `audit-record-lint.sh` block 3 |
| 4 | Every finding an already-closed issue covers names that issue | `audit-record-lint.sh` block 4 |
| 5 | Each follow-up is one line under **Next** with a stable ID | `audit-record-lint.sh` block 5 |
| 6 | Every abbreviation used has a glossary row | `audit-record-lint.sh` block 6 |
| 7 | Docs updated and the task line moved to `completed.md` | `audit-record-lint.sh` block 9 |

## Test traceability

| Test ID | Level | Covers | Guardrail | Task | Status |
| ------- | ----- | ------ | --------- | ---- | ------ |
| `audit-record-lint.sh` block 1 | discipline | DoD 1 | — | `T-3v9q` | green |
| `audit-record-lint.sh` block 2 | discipline | DoD 2 | — | `T-3v9q` | green |
| `audit-record-lint.sh` block 3 | discipline | DoD 3 | — | `T-3v9q` | green |
| `audit-record-lint.sh` block 4 | discipline | DoD 4 | — | `T-3v9q` | green |
| `audit-record-lint.sh` block 5 | discipline | DoD 5 | — | `T-3v9q` | green |
| `audit-record-lint.sh` block 6 | discipline | DoD 6 | — | `T-3v9q` | green |
| `audit-record-lint.sh` block 9 | discipline | DoD 7 | — | `T-3v9q` | green |

## Findings

| ID | Finding | Verdict | Severity |
| -- | ------- | ------- | -------- |
| M1 | The duplicate-number check is `adr-lint.sh:75` and has no fixture. | Stands | medium |
| M2 | The title-line check is `adr-lint.sh:93-95`, not one line. | Corrected | low |
| M3 | The two paths do not diverge. | Refuted | none |

## What neither report found

**X1 — the template difference is not a defect.** It is the rule's two halves.

## Already recorded — finding to abandoned issue

| Findings here | Already written up in |
| ------------- | --------------------- |
| M1, M2 | [#45](https://github.com/pharzam/armature/issues/45) — record shapes the linter approves |
| X1 | [#16](https://github.com/pharzam/armature/issues/16) — the earlier audit |

## Corrections to the reports

- The two-hooks sentence is at `engineering-discipline.md:454`.

## Out of scope (follow-ups)

Scheduled under **Next** in [backlog.md](backlog.md): `T-8b4r`, `T-4x2k`.

## Verdict

The record is complete and the gate is green. The SLA for it is one day.
