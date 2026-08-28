# T-6r2d — Discipline-test runner

Tracks [issue #49](https://github.com/pharzam/armature/issues/49). Backlog line:
[backlog.md](backlog.md).

## Why

The kit governs itself only in the cheap layers: `commit-msg`, `adr-lint`, and
`prd-lint` pass, and the kit stays domain-free. But the *expensive* layer of its
own gate — **running its own tests** — is not applied to the kit. The discipline
linters self-lint the **real** repo green, yet **nothing runs their fixtures**, so
there is no automated proof that a linter correctly *rejects* bad input; and two of
them (`adr-lint`, `commit-msg`) ship no fixtures at all.

The reframe that makes the expensive layer apply: **the kit's product is its
documents and its linters.** With that view, "run your own tests" has a domain-free
form — run the discipline linters against their fixtures and assert the outcome.

## Plan (R12 — ordered, DoD-covering, test-first)

The fixtures (the tests) come before the runner (the code under them), and the
runner before its wiring, so each step is independently buildable and testable.

1. **`adr-lint` fixtures** — `docs/adr/tests/` with a `README.md`, a `good/` case
   (exit 0), and `bad-*` cases isolating one violation each (bad filename,
   numbering gap, bad Status value, missing section, no index row). Prove each by
   hand against `adr-lint.sh` — watch every `bad-*` fail for its *own* reason.
2. **`commit-msg` fixtures** — `.githooks/tests/commit-msg/` with a `README.md` and
   `good-*.txt` / `bad-*.txt` message files. Prove each by hand against the hook.
3. **The runner** — `docs/tests/run-discipline-tests.sh` (POSIX shell, no
   toolchain). It is **data-driven over a per-suite descriptor** — each row names
   the linter, its fixture root, and whether a fixture is a **directory**
   (`adr-lint`, `prd-lint`) or a **file** (`pr-link-lint`, `commit-msg`), because
   the two invocation modes differ. It asserts the exit code by the
   `good*`→pass / `bad*`→fail naming convention, and **skips any entry that is
   neither** — the shared `docs/prd/tests/facts/` dir and every suite `README.md`.
   It also **skips an absent suite** (guard each with
   `[ -f <linter> ] && [ -d <fixtures> ]`) so a slimmed adopter kit — one that
   deleted `prd/` or ships no ADRs — still runs green. Print a summary; exit
   non-zero on any mismatch. Prove it green on all real fixtures; prove it goes
   **red** via a temporary mislabeled fixture (a valid message named `bad-*`), then
   remove it.
4. **Wire into `pre-commit` and CI** — add the runner behind an `if [ -f ]` guard
   after the existing `adr-lint` / `prd-lint` steps in
   [`pre-commit`](../../.githooks/pre-commit), **and** as a job in both CI templates
   ([`github-actions-ci.yml`](../ci/github-actions-ci.yml),
   [`gitlab-ci.yml`](../ci/gitlab-ci.yml)) plus a mention in
   [`ci/README.md`](../ci/README.md). Discipline tests run **hook + CI** by
   definition ([`test-levels.md`](../tests/test-levels.md)); CI is the authority, and
   hook-only enforcement is bypassable with `--no-verify`.
5. **Docs, same PR** — `docs/tests/README.md` (new row **and** the "does not run any
   tests itself / ships no product tests" framing reworded, since the folder now
   holds an executable self-test), `test-levels.md` (name the runner under
   Discipline without miscounting it as a fourth linter; note `commit-msg` is now
   fixture-tested), the "what is enforced where" table in `issue-workflow.md` (a row
   for the discipline self-tests, hook + CI), the main `README.md` "What's inside"
   (and fix the stale `R1–R11` → `R1–R12` on line 45 in passing), and a **`POSIX`
   glossary row** (the term is used by the runner and already appears uncovered in
   `prd-lint.sh` and `gitlab-ci.yml`).
6. **Backlog bookkeeping** — this card moves from `backlog.md` to `completed.md` in
   the same PR that lands the work.

## Definition of Done

- Every discipline linter has both a `good` fixture (proves it passes clean input)
  and at least one `bad-*` fixture (proves it rejects a violation).
- The runner runs all four suites and exits 0; a mislabeled fixture makes it exit 1
  (the negative test, captured below once run).
- The runner dispatches dir-mode vs file-mode per suite, skips non-fixture entries
  (`facts/`, READMEs), and skips an absent suite (adopter-slimmed kit stays green).
- The runner is wired into **both** `pre-commit` and the two CI templates; the real
  linters stay green.
- Docs updated in the same PR (tests/README reframe, test-levels, enforced-where
  table, main README R1–R12 fix); a `POSIX` glossary row added — no undefined
  abbreviation.

## Verdict

<!-- Filled at close: what the task delivered, with the runner's green output and
the negative-test evidence. -->
