# T-m2n5 — Ship a hooks-install script to pin `core.hooksPath` per clone

Tracks [issue #191](https://github.com/pharzam/armature/issues/191). Completed
line: [completed.md](completed.md). Plan and its independent review are on the
issue (R12).

## Why

The quality-gate hooks in [`.githooks/`](../../.githooks/) run only when a clone
points git at them with `core.hooksPath`. Today that is a hand-run step documented
in AGENTS.md's "Checks you can run" section. Manual, it is forgotten on a fresh
clone (so the local hooks never run), and in a multi-worktree setup the shared
`.git/config` value drifts to an **absolute** path, which the `#84` provenance
`pre-commit` hook rejects (it requires the value to resolve inside the current tree
so a branch tests its own hooks) — blocking commits from every other worktree. Both
were hit while landing [#185](https://github.com/pharzam/armature/issues/185) and
[#188](https://github.com/pharzam/armature/issues/188). `.git/config` cannot ship in
the repo (git never versions `.git/`, and will not auto-apply a committed
`core.hooksPath`), so only a **script that applies the setting** can be committed.

## What

Add a small POSIX `sh` script that pins `core.hooksPath` to the **relative**
`.githooks` for the clone, and reference it from the AGENTS.md install sentence.

- **Location: `.githooks/install.sh`** (picked on #191) — beside the hooks it
  enables, and the repo root stays minimal; git never runs a file named `install.sh`
  as a hook.
- Behaviour: verify it runs inside a git work tree; `cd` to the repo top; verify
  `.githooks/` exists; `git config core.hooksPath .githooks` (relative, never
  absolute); print a one-line confirmation. Idempotent; no destructive or networked
  operation.
- AGENTS.md "Checks you can run": replace the raw `git config …` install sentence
  with a reference to `sh .githooks/install.sh`, stating it pins `core.hooksPath` to
  the relative `.githooks`.

Rejected alternative: commit `.git/config` or a committed `core.hooksPath` — git
does not version `.git/`, and auto-applying a committed hooksPath is a security
footgun git forbids. A script the operator runs once is the only committable form.

**Decisions (picked by the plan review on #191):** (a) location
`.githooks/install.sh`; (b) the behaviour test is **committed** as
`.githooks/tests/install-check.sh`, run by hand and **not** wired into
`run-discipline-tests.sh` — mirroring the sibling `.githooks/tests/provenance-check.sh`,
which tests `core.hooksPath` the same way and is deliberately hand-run (it exceeds the
"reads only text, no toolchain" bar the auto-dispatched checks meet).

**Doc sweep (plan-review Condition 1, classified per [guardrails §2](../guardrails.md)):**
the raw `git config core.hooksPath .githooks` install step appears in several
human-facing docs. Update the **install-instruction** sites to run the script —
`README.md` (the `.githooks/` row and the adopt-the-template walkthrough step),
`AGENTS.md` ("Checks you can run"), `.githooks/README.md` ("Install (one command)"),
`docs/engineering-discipline.md` (the "Install the git hooks" bullet and the
"Git hooks" reference block), and — caught by decay round 1 — the three hook scripts'
"inert until you run …" header comments (`.githooks/pre-commit`, `commit-msg`,
`pre-push`) plus `pre-commit`'s runtime provenance-fix message, which now point at the
script (the inventory grep first missed these because git hook files carry no `.sh`
extension). **Keep** the mechanism / internal / historical mentions
(`docs/guardrails.md`'s absolute-vs-relative pitfall, `.githooks/README.md`'s uninstall
and fallback notes, `engineering-discipline.md`'s `core.hooksPath` fallback text, the
`provenance-check.sh` internals, and the dated `completed.md` / audit entries).

## Plan (R12 — ordered, test-first where a test applies)

1. Task card (`docs/tasks/T-m2n5.md`) and this plan.
2. **Test (red):** a pre-registered check that runs the script in a throwaway git
   repo and asserts `core.hooksPath` becomes `.githooks`, that it is idempotent
   (re-run is a no-op with the same result), and that it refuses outside a git tree.
   Confirm it fails now (the script does not exist).
3. Write `.githooks/install.sh`; make it executable; commit the behaviour test as
   `.githooks/tests/install-check.sh` (hand-run, not auto-wired); re-run the test
   (green).
4. Doc sweep (Condition 1): update the install-instruction sites — `README.md`,
   `AGENTS.md`, `.githooks/README.md`, and `docs/engineering-discipline.md` — to run
   `sh .githooks/install.sh`, keeping the `core.hooksPath` mechanism explained where a
   site also teaches it; leave the classified mechanism/history mentions untouched.
5. Run `adr-lint`, `prd-lint`, `link-lint` (the new in-tree links must resolve),
   `run-discipline-tests`, and `git diff --check`; confirm a tree-wide grep leaves only
   the classified, kept mentions of the raw command.
6. One independent decay review on a frozen head, on a second model (a governance
   document and a new executable script — Model independence applies): a
   clause-by-clause semantic-agreement pass on the AGENTS.md edit, plus a
   correctness/safety pass on the script (idempotent, non-destructive, relative path,
   guards).
7. Close out: the `completed.md` line, the verdict, and the ADR-0007 resource record,
   in the landing PR (`Closes #191`).

## Definition of Done

- A tracked POSIX `sh` script pins `core.hooksPath` to the relative `.githooks`,
  runs only inside a git work tree, is idempotent, and runs nothing destructive or
  networked.
- Every human-facing install-instruction site references `sh .githooks/install.sh`
  (`README.md`, `AGENTS.md`, `.githooks/README.md`, `docs/engineering-discipline.md`);
  the classified mechanism/history mentions are left as-is; the new in-tree links
  resolve (`link-lint`).
- A committed behaviour test `.githooks/tests/install-check.sh` passes (sets the
  value, idempotent, refuses outside a git tree); it failed before the script existed.
  It is hand-run and not wired into `run-discipline-tests.sh`, mirroring
  `provenance-check.sh`.
- `adr-lint`, `prd-lint`, `link-lint`, `run-discipline-tests` and `git diff --check`
  pass.
- A clause-by-clause semantic-agreement review of the AGENTS.md edit, and a
  correctness/safety review of the script, are recorded on
  [#191](https://github.com/pharzam/armature/issues/191).

## Verdict

_Filled at close-out._

## Resource record

_Filled at close-out._
