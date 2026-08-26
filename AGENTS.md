# AGENTS.md

Agent context for **Armature**, the engineering-discipline kit. Read this before
any other file in the repository.

This is the compressed form of the full rules. Where it disagrees with the
document it summarises, the document wins — and the disagreement is a defect to
fix in the same change, under [R10](#the-issue-rules-r1r12).

## What this repository is

A domain-free **template**, not a product. It ships the "how we work" — a quality
gate, guardrails, Architecture Decision Records (ADRs), a glossary, a
facts-and-requirements convention, a test section, and a task backlog — for an
adopter to copy onto their own domain.

Three things catch agents out here:

- **`‹…›` markers are deliberate.** They mark a value only the adopter can supply.
  Do not "fix" one by inventing content.
- **The root `tests/` directory is empty on purpose.** It is the adopter's
  drop-in. The kit has no product, so it has no product tests. Its own tests are
  the discipline linters.
- **The kit stays domain-free.** Never name a language, framework, or test runner
  outside a `‹…›` placeholder.

## Non-negotiables

1. Never work in the operator's main worktree. Never commit to `main`. Never push
   to `main`.
2. Never weaken, skip, or delete a passing test to make new code pass.
3. Never land a change that leaves a document stale. Same pull request, or not at
   all.
4. State outcomes plainly. A failing test is reported as failing, with its output.

## The quality gate

Every substantive task passes these steps, in this order. Before step 1 there is
an open issue ([R1](#the-issue-rules-r1r12)) with a reviewed, ordered plan
([R12](#the-issue-rules-r1r12)).

1. **Isolate.** Own branch, own git worktree under `‹worktree dir›/<task>`,
   branched off `origin/main`.
2. **Honor the guardrails.** Before writing code, read the ticket's acceptance
   criteria, [`docs/guardrails.md`](docs/guardrails.md), and the ADRs it
   references. They hold lessons already paid for.
3. **Test first.** The failing test comes first, and must fail for the *right*
   reason. A change with no test that covers it is not done.
4. **Make long tasks visible.** Anything that can run over 10 seconds shows
   progress: which step runs, how much remains, and that it is still alive.
5. **Review until findings decay.** Rounds of independent blind review, a
   different lens each round, until one round finds nothing material. One pass is
   never enough. Prompts: [`docs/review/`](docs/review/).
6. **Be honest, keep evidence.** Commit run evidence under `‹evidence store›`.
   When the evidence comes from a costly or irreversible action, review the
   producing code **before** the action, never after.
7. **Keep documentation current.** Every document and comment the change touches
   or leaves stale, in the same pull request.
8. **Close out in the same pull request.** Tick the acceptance boxes, write the
   verdict, and move the task line from
   [`docs/tasks/backlog.md`](docs/tasks/backlog.md) to
   [`docs/tasks/completed.md`](docs/tasks/completed.md).

## The issue rules (R1–R12)

The full text is [`docs/issue-workflow.md`](docs/issue-workflow.md). Cite a rule
by number in a review or a commit.

| Rule | In one line |
| ---- | ----------- |
| **R1** Issue first | No commit without an open issue. The pull-request body links it: `Closes #N` closes it, `Refs #N` does not. |
| **R2** Duplicate check | Search open **and** closed issues first. Related work becomes a child issue, not a duplicate. |
| **R3** Best practice only | Take the proven standard over a custom build. Record the chosen option **and the rejected ones** — an ADR if architecturally significant, else an issue comment. |
| **R4** No workarounds | A workaround needs two operators' written approval, or — on a solo project — one dated self-review comment that states why it is unavoidable. Either way it gets its own removal issue. |
| **R5** Deterministic over LLM | Prefer a script, linter, type check, or CI gate to a model's judgement. Choosing the model anyway is recorded on the issue with its reason. |
| **R6** Agents talk through the issue | Never ask another agent directly. Comment on the in-progress issue, with a severity and an expected response time. |
| **R7** Decision transparency | Before the commit that carries it out, comment the action chosen, why, and the tradeoffs. |
| **R8** Red, then green | Plan on the issue. Write the tests. Watch them fail for the right reason. Then write code until they pass. |
| **R9** Test freeze | Once a fresh context confirms the tests, they are frozen. A frozen test that later fails opens a **bug sub-issue** — it is not edited. |
| **R10** Sync with governance | Keep discipline, ADRs, guardrails, glossary, and the requirements convention in step. A conflict between them **stops work**. |
| **R11** Single-goal issues | One issue is one actionable, demoable goal. Larger work is a parent issue with child issues. |
| **R12** Slice and prioritize | Before the first test, write an ordered, Definition-of-Done-covering plan — one domain per slice, the **test slice first**, each slice passing this gate alone. Review it once, record it on the issue. |

## Commits, branches, and landing

- **Commit subject:** `<type>: <description>`, or `<type>: <ID> <description>` when
  it carries a backlog task. Types: `feat fix docs refactor perf test build ci
  chore revert`. Enforced by [`.githooks/commit-msg`](.githooks/commit-msg).
- **Task IDs:** `‹task-ID scheme›` — in this repository, `T-` plus four characters
  from `0-9 a-z` minus the ambiguous `i l o u`. Pick them **at random**, never
  sequentially: a counter makes two parallel agents choose the same number and
  collide. Confirm `docs/tasks/<id>.md` is free before using one.
- **Granularity:** commit at each logical step, not one batch at the end. Each
  commit is independently buildable and testable.
- **Landing:** rebase onto the latest `origin/main`, then a **plain merge**.
  **Never squash** — the per-commit granularity is deliberate, and a squash
  destroys it.

## The glossary rule

Any change that adds a term, renames one, or changes what one means updates
[`docs/glossary.md`](docs/glossary.md) in the same change.

**Enforced:** every abbreviation that appears in committed Markdown has a glossary
row — Term, Abbr., Description, Example. General-English forms (`e.g.`, `i.e.`,
`etc.`, `vs.`) are exempt until they carry a project-specific meaning.

**Aspiration, not enforced:** the same courtesy in conversation. No machine reads
a conversation, so this one rests on the operator rather than a gate.

## Run the checks

```bash
git config core.hooksPath .githooks   # once per clone — turns the hooks on
sh docs/adr/adr-lint.sh               # -> adr-lint: OK
sh docs/prd/prd-lint.sh               # -> prd-lint: OK
sh docs/glossary-lint.sh              # -> glossary-lint: OK
```

The hooks then run the linters before each commit, refuse a non-conforming commit
subject, and refuse a direct push to `main`.

## The values an adopter fills

Search for `‹` to find every one. None has a default; each is a decision.

| Marker | What it names |
| ------ | ------------- |
| `‹test runner›` | How tests run in the adopter's stack. |
| `‹unit test command›`, `‹integration test command›`, `‹end-to-end test command›` | One command per level, defined once in [`docs/tests/test-levels.md`](docs/tests/test-levels.md). |
| `‹security test command›`, `‹security scanner›` | The parallel security track and the tool behind it. |
| `‹test timeout›`, `‹test directory›` | The bound on a hanging test, and where product tests live. |
| `‹lint›` | The formatter and linter step in the hook and CI. |
| `‹evidence store›` | Where run outputs and logs are committed. |
| `‹task-ID scheme›` | How a task is tagged. |
| `‹worktree dir›` | The gitignored per-task isolation directory. |

## Where the full rules live

| Document | Holds |
| -------- | ----- |
| [`docs/engineering-discipline.md`](docs/engineering-discipline.md) | The gate and every working practice. The authority. |
| [`docs/issue-workflow.md`](docs/issue-workflow.md) | R1–R12, and an honest table of what is enforced where. |
| [`docs/guardrails.md`](docs/guardrails.md) | Known pitfalls, pre-registered pass/fail rules, validation. |
| [`docs/glossary.md`](docs/glossary.md) | The shared vocabulary. |
| [`docs/adr/`](docs/adr/) | Architecture Decision Records, plus `adr-lint.sh`. |
| [`docs/facts/`](docs/facts/), [`docs/prd/`](docs/prd/) | Customer facts as immutable evidence, and the requirements derived from them, plus `prd-lint.sh`. |
| [`docs/tests/`](docs/tests/) | Test levels, per-level patterns, and the checklists. |
| [`docs/review/`](docs/review/) | The review-lens prompts for gate step 5. |
| [`docs/ci/`](docs/ci/), [`.githooks/`](.githooks/) | Enforcement: CI templates (inert) and the local hooks. |
