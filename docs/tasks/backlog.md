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

- **T-8j4m** — Add `backlog-lint.sh` and `discipline-tests.sh` — the runner that finally executes every linter's fixtures — plus fixtures for the ADR and backlog linters ([#19](https://github.com/pharzam/armature/issues/19))

## Next

<!-- Deliberately deferred tasks, same one-line shape. -->
