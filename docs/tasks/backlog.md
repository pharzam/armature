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

> **Re-sliced toward the adopter (2026-09-07)** — see the archived pivot decision
> ADR-0009 (now under `docs/decisions/`). Now is adopter-facing and Next
> starts with the adopter-proving work. The self-facing tasks the pivot retired are
> recorded on [#156](https://github.com/pharzam/armature/issues/156).

## Now

<!-- One line per task. Example shape:
- **‹ID›** — ‹one-sentence summary› ([‹ADR or doc link›](...); [detail](‹id›.md))
-->

- **T-7m6s** — Adopter day one: ignore the worktree directory, mark `LICENSE`, pin every floating action reference ([#23](https://github.com/pharzam/armature/issues/23))
- **T-3n8w** — Write the objective-scientist conduct standard into the review sections, with a checkable finding basis ([#173](https://github.com/pharzam/armature/issues/173); [detail](T-3n8w.md))

## Next

<!-- Deliberately deferred tasks, same one-line shape. -->

- **#22** — Dogfood the kit on one real product repository — the audit's most important finding, the one slice that cannot land inside this repo ([#22](https://github.com/pharzam/armature/issues/22))
- **#20** — Define core / standard / full adoption profiles ([#20](https://github.com/pharzam/armature/issues/20))
- **T-6f3w** — Fix `adr-lint`: check an index row's status against the record it names ([#45](https://github.com/pharzam/armature/issues/45))
- **T-4x2k** — Self-violation sweep, trimmed: the enforcement table and overlong `completed.md` entries ([#40](https://github.com/pharzam/armature/issues/40))
- **T-5h8n** — Triage the `NOT_PLANNED` issues the Phase 0 closures did not settle ([#16](https://github.com/pharzam/armature/issues/16))
