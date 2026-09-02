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

- **T-q22n** — Mechanise the review record: a CI-only record check with chronology, a budget line in the DoD checklist, and required checks on `main` ([#82](https://github.com/pharzam/armature/issues/82))
- **T-5k3q** — Ship the branch-protection command in `docs/ci/README.md` with removal guidance that names every droppable job ([#86](https://github.com/pharzam/armature/issues/86))

## Next

<!-- Deliberately deferred tasks, same one-line shape. -->

- **T-5h8n** — Triage the 23 issues closed `NOT_PLANNED`: reopen, supersede, or record a decision for each ([#16](https://github.com/pharzam/armature/issues/16); [detail](T-3v9q.md))
- **T-2q7d** — Decide what to do with the two branch-only ADR-0004 records: an `Accepted` record left `main` with no supersession, and the number now holds a different decision on each of two branches and a third on `main` ([#17](https://github.com/pharzam/armature/issues/17); [detail](T-3v9q.md))
- **T-8b4r** — Add fixtures that kill all eleven surviving linter mutants, including a piped standard-input case for `pr-link-lint`, and make the harness prove each mutant applied ([#45](https://github.com/pharzam/armature/issues/45); [detail](T-3v9q.md))
- **T-6f3w** — Fix `adr-lint`: check the index row's status against the record it names (the directory-argument half was closed by `T-8q3f`, which canonicalised the argument rather than stripping a slash — the slash was one of five spellings of one defect) ([#45](https://github.com/pharzam/armature/issues/45); [detail](T-3v9q.md))
- **T-9c5t** — Make a skipped suite fail the gate, and assert why a linter failed rather than only that it did ([#37](https://github.com/pharzam/armature/issues/37); [detail](T-3v9q.md))
- **T-4x2k** — The self-violation sweep: the hook count, the broken link, the enforcement table, the overlong `completed.md` entries ([#40](https://github.com/pharzam/armature/issues/40); [detail](T-3v9q.md))
- **T-7m6s** — Adopter day one: ignore the worktree directory, mark `LICENSE`, pin every floating action reference ([#23](https://github.com/pharzam/armature/issues/23); [detail](T-3v9q.md))
- **T-3d9v** — Define "fresh context" and "substantive task", and decide the scope of the abbreviation rule ([#21](https://github.com/pharzam/armature/issues/21); [detail](T-3v9q.md))
