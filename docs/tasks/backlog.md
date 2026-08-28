# Backlog

Lean task list for this project. Two sections: **Now** (the current version) and
**Next** (deliberately deferred).

## How to keep this file readable

**One line per task — keep it that way.** Each entry is exactly an ID, a
one-sentence summary, and the link(s) that motivate or scope it. Nothing more. If
a task needs more than that — design notes, rejected alternatives, open questions,
reproduction detail — it goes in `tasks/<id>.md` and the entry links to it as
`[detail](<id>.md)`. Do **not** grow the entry itself; this file is an index, not
a design doc. (Multi-paragraph entries are prohibited.)

Each task has a stable ID assigned once and never reused or renumbered — an ID
stays with its task when promoted from Next to Now. Use a `‹task-ID scheme›`: a
short, stable token per task. Prefer **random** IDs over a sequential counter — a
counter forces every session to agree on "the next number", so two people (or
agents) working in parallel both pick the same one and collide in filenames,
branches, and PRs. A random suffix needs no coordination. `‹State your exact scheme
here — for example: "T-" plus four characters drawn from 0-9 a-z minus the
ambiguous i l o u; before using an ID, confirm tasks/<id>.md does not already
exist."›`

When a Now item is done, move its line to [completed.md](completed.md) — same ID,
same summary, dated — rather than deleting it or checking it off.

## Now

<!-- One line per task. Example shape:
- **‹ID›** — ‹one-sentence summary› ([‹ADR or doc link›](...); [detail](‹id›.md))
-->

- **T-3v9q** — Record the verified result of two external audits of the kit: 43 of 44 claims stand, almost none is new, and 23 issues closed `NOT_PLANNED` already hold most of them ([#55](https://github.com/pharzam/armature/issues/55); [detail](T-3v9q.md))

## Next

<!-- Deliberately deferred tasks, same one-line shape. -->

- **T-5h8n** — Triage the 23 issues closed `NOT_PLANNED`: reopen, supersede, or record a decision for each ([#16](https://github.com/pharzam/armature/issues/16); [detail](T-3v9q.md))
- **T-2q7d** — Restore or re-decide ADR-0004: an `Accepted` record left `main` with no supersession, and the number now holds two decisions on two branches ([#17](https://github.com/pharzam/armature/issues/17); [detail](T-3v9q.md))
- **T-8b4r** — Add fixtures that kill the six surviving linter mutants, including a piped standard-input case for `pr-link-lint` ([#45](https://github.com/pharzam/armature/issues/45); [detail](T-3v9q.md))
- **T-6f3w** — Fix `adr-lint`: strip the trailing slash, and check the index row's status against the record it names ([#45](https://github.com/pharzam/armature/issues/45); [detail](T-3v9q.md))
- **T-9c5t** — Make a skipped suite fail the gate, and assert why a linter failed rather than only that it did ([#37](https://github.com/pharzam/armature/issues/37); [detail](T-3v9q.md))
- **T-4x2k** — The self-violation sweep: the hook count, the broken link, the enforcement table, the overlong `completed.md` entries ([#40](https://github.com/pharzam/armature/issues/40); [detail](T-3v9q.md))
- **T-7m6s** — Adopter day one: ignore the worktree directory, mark `LICENSE`, pin the 13 floating action references ([#23](https://github.com/pharzam/armature/issues/23); [detail](T-3v9q.md))
- **T-3d9v** — Define "fresh context" and "substantive task", and decide the scope of the abbreviation rule ([#21](https://github.com/pharzam/armature/issues/21); [detail](T-3v9q.md))
