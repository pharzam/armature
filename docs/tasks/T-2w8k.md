# T-2w8k — Activate live CI for the Armature repo

Tracks [issue #51](https://github.com/pharzam/armature/issues/51). Backlog line:
[backlog.md](backlog.md).

## Why

`docs/ci/` ships **inert** GitHub Actions templates; nothing runs on the forge.
This activates them for the Armature repo itself, so every PR and push to `main`
runs the gate on GitHub — CI is the authority the local `.githooks/` give fast
feedback against. It also makes the kit dogfood its own CI advice.

## Plan (R12 — ordered, test-first where a test applies)

1. **Copy the ready-as-is checks** into `.github/workflows/`, filling the one
   `‹default branch›` placeholder with `main`:
   - `ci.yml` — `adr-lint`, `prd-lint`, `discipline-tests` (no toolchain).
   - `pr-title.yml` — Conventional Commits on the PR title.
   - `pr-link.yml` — R1: the PR body links an issue.
2. **Omit** the template's `lint` / `tests` / `security` jobs — Armature ships no
   product code, so there is nothing for them to run; the kit's own "tests" are the
   discipline checks. Record why in the `ci.yml` header.
3. **Validate before the forge sees it** — `actionlint` clean, and each job's
   command green locally (`adr-lint`, `prd-lint`, the fixture runner).
4. **Docs, same PR** — a "live example" note in [`ci/README.md`](../ci/README.md)
   pointing at the activated workflows.
5. **Prove it live** — open the PR and confirm every check runs green on the forge
   (the real verification for a workflow file).
6. **Backlog bookkeeping** — this card moves backlog → completed in the landing PR.

## Definition of Done

- `.github/workflows/{ci.yml,pr-title.yml,pr-link.yml}` present; `ci.yml` runs the
  three ready jobs against `main`, product jobs omitted with the reason recorded.
- `actionlint` passes; each CI job command is green locally.
- Every check runs **green on the actual PR** on GitHub.
- `ci/README.md` points at the live workflows; no undefined abbreviation.

## Out of scope (follow-ups)

- A `shellcheck` job over the kit's shell scripts (needs a small pass for SC1007 on
  the idiomatic `CDPATH= cd`, SC2034 in `pre-push`, SC2012 in `prd-lint`).
- Making the checks **required** via branch protection — a maintainer repo-setting.

## Verdict

<!-- Filled at close: the workflows activated, actionlint result, and the live
green check run on the PR. -->
