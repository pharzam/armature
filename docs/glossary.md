# Glossary

Terms, abbreviations, and short definitions for this project. This is the shared
vocabulary the rest of the docs assume. It is the target of the
[Glossary](engineering-discipline.md#glossary) rule, which has two parts. First: any
change that adds a term, renames one, or changes a meaning updates this file in the
same change. Second — **No undefined abbreviation**: every abbreviation used in any
conversation, context, prompt, reply, or response must have an entry here, and any
LLM or operator who uses one that is missing adds it in the same turn. General-English
abbreviations (`e.g.`, `i.e.`, `etc.`) are exempt unless they carry a
project-specific meaning.

> **How to adapt this file.** The **Kit vocabulary** section below is real content —
> it defines the abbreviations these discipline docs themselves use, so keep it.
> Everything after it is skeleton: keep the format, then fill the domain sections with
> your own terms and rename the sections to match your domain. Delete this note once
> your own terms are in.

## The format — three columns, plus two rules

Each entry is a row in a table:

| Term | Abbr. | Description | Example |
|------|-------|-------------|---------|
| `‹term›` | `‹abbr or —›` | `‹one or two sentences. State what it is and why it matters here.›` | `‹a concrete instance that makes it real›` |

Two rules keep the glossary earning its place:

1. **Collision to watch for.** When a term means something different outside this
   project — in a common library, a neighbouring team, or the wider field — say so
   in the Description, in the form "Collision to watch for: …". A word that quietly
   means two things is worse than an unknown word.
2. **Quick-reference table.** Keep the whole glossary skimmable. If it grows past
   what a reader can scan, add a short quick-reference table at the top with just
   Term and one-line meaning, and keep the full entries below.

## Kit vocabulary — the abbreviations these discipline docs use

These are defined here because the kit's own documents use them. Keep this
section as-is; add your domain terms in the sections below.

| Term | Abbr. | Description | Example |
|------|-------|-------------|---------|
| Large Language Model | `LLM` | A machine-learning model that generates and transforms natural-language text. In this kit it is one of the two operator classes the rules bind, alongside the human operator. | An AI assistant that edits these docs must add any abbreviation it uses to this glossary in the same turn. |
| Architecture Decision Record | `ADR` | A short, numbered document that records one architecturally significant decision and its context. Stored under [`adr/`](adr/). | [`adr/0001-record-architecture-decisions.md`](adr/0001-record-architecture-decisions.md) records the decision to use ADRs. |
| Continuous Integration | `CI` | The automated pipeline that builds the project and runs its checks on each change. Collision to watch for: in statistics and machine-learning writing, "CI" usually means *Confidence Interval* — state which you mean. | The cheap validation checks in [`guardrails.md`](guardrails.md) are the ones worth wiring into CI so they run on every change. |
| Facts Document | `—` | A record under [`facts/`](facts/) that stores one customer's requirements or statements as-is, word for word, as immutable evidence. Carries a stable `F-NNNN` ID that derived requirements cite. Collision to watch for: not a data-warehouse "fact table" — this is a source document, not a database row. | `F-0007#3` cites the third fact in facts document `F-0007`; a requirement written from it names that ID. |
| Simplified Technical English | `STE` | A controlled subset of English — the ASD-STE100 standard — with a limited vocabulary and short, active sentences, used for unambiguous technical writing. In this kit it is the language of the derived requirements written from [facts documents](facts/). Collision to watch for: not the same as a [plain-language summary](engineering-discipline.md#plain-language-summaries) — STE is a formal standard, a plain-language summary is just jargon-free prose. | The requirements derived from `F-0007` are written in STE: short, active sentences drawn from the approved word list. |
| Product Requirements Document | `PRD` | Layer 2 of the two-layer facts rule: a versioned document under [`prd/`](prd/) whose every requirement cites the `F-NNNN` fact it derives from. Collision to watch for: not a `PR` (pull request) — a PRD is a requirements document, a PR is a code change. | A `PRD-NNNN` collects a product's requirements; each `REQ`/`NFR` in it names the fact it came from. |
| Requirement ID | `REQ` / `NFR` | The stable ID of one functional (`REQ-NNN`) or non-functional (`NFR-NNN`) requirement in a [PRD](prd/); assigned once, never reused or renumbered. | `REQ-001` states one capability; `NFR-001` states one quality attribute such as a latency bound. |
| MoSCoW | `—` | A prioritisation scheme — Must, Should, Could, Won't — carried in a PRD requirement's priority column, so the statement need not repeat "shall". | A Must requirement ships in the first phase; a Won't is explicitly out of scope, with an em-dash phase. |
| Test-Driven Development | `TDD` | Write the failing test first, watch it fail for the right reason, then write the code that makes it pass. The kit's default order for a feature or a fix. | R8 of the [issue workflow](issue-workflow.md) states TDD in strict mode: red, then green. |
| Pull Request | `PR` | The unit of change review and merge: a branch proposed for landing on the default branch. The kit lands every change via a PR, never a direct push — except destroying history on the default branch, and any repair no PR can express ([ADR-0004](adr/0004-destroying-history-on-the-default-branch.md)). Collision to watch for: not a `PRD` — see above. | The [`pre-push` hook](../.githooks/pre-push) refuses a direct push to `main`; a PR is how the change lands. |
| Issue-first workflow | `—` | The rule that an open issue precedes any change, and a PR links back to it — defined in [`issue-workflow.md`](issue-workflow.md) as R1–R12. Destroying history has the issue but no PR (ADR-0004). | No commit starts without an open issue; the PR body says `Closes #N`. |
| Single-goal issue | `—` | One issue scoped to one actionable, demoable goal (R11); larger work becomes a parent issue with child issues. | A task you cannot demo in one step is really several single-goal issues. |
| Test freeze | `—` | The state a test reaches once a fresh context confirms it: it is not weakened or deleted to make new code pass (R9). | A frozen test that later fails opens a bug sub-issue, not a test edit. |
| Requirements traceability matrix | `—` | The table at the end of each [PRD](prd/) that links a requirement across fact, guardrail, ADR, task, and test — the line from the customer's words to the test. | The `§12` matrix's ID set must equal the PRD's requirement set; `prd-lint.sh` checks it. |
| Test level | `—` | One rung of the fixed ladder — unit, integration, end-to-end — ordered cheap-first, so a change runs the cheap levels in the commit hook and the expensive ones in CI. Each level is tagged so it can run on its own. Defined in [`tests/test-levels.md`](tests/test-levels.md). | Tagging tests by level lets the hook run only the unit level while CI runs all three. |
| Unit test | `—` | A test of one component in isolation, with its dependencies replaced by stand-ins, so a failure points at that one component. The cheapest [test level](tests/test-levels.md) and the first to run in the hook. | A pure function's unit test names an input and asserts the exact output, with no file, network, or clock involved. |
| Integration test | `—` | A test that two or more components work together across a real interface or workflow — the seams a unit test stubs out. Slower than a unit test, so it runs after the unit level in the cheap-first order. | An integration test drives a handler through a real datastore and asserts the stored row, not a mocked one. |
| End-to-end test | `E2E` | A test of a whole user-facing path through the running system, front to back, as a real user or caller would exercise it. The most expensive automated level, usually run in CI rather than the commit hook. Collision to watch for: not the same as a `UAT` — an E2E test is automated, a UAT is a human sign-off. | An E2E test starts the app and walks one scenario from first input to final visible result. |
| User Acceptance Test | `UAT` | A scenario a human runs, or signs off, to confirm the delivered behaviour is what was asked — written in plain Given/When/Then steps, not code. It layers on the E2E path but is judged by a person. Collision to watch for: not an automated [test level](tests/test-levels.md) — a UAT is the human acceptance step. | A UAT scenario reads "Given a new account, when the user runs setup, then the welcome screen appears," checked by a person. |
| Definition of Done | `DoD` | The fixed checklist a change satisfies before it counts as finished — tests, docs, review, evidence. In the test section each DoD item maps to a test that proves it, tracked by [`tests/dod-checklist.md`](tests/dod-checklist.md). Collision to watch for: broader than "acceptance criteria" — the DoD applies to every task, the criteria are one issue's. | The DoD item "every requirement has a test" is met by finding a traceability row for each `REQ`/`NFR`. |
| Discipline test | `—` | A test of the *process* rather than the product: it lints the repo's own conventions and needs no product toolchain, so a project has tests before any product code exists. | [`adr/adr-lint.sh`](adr/adr-lint.sh) is a discipline test — it fails a commit whose ADRs break the numbering rule. |
| Work slice | `—` | One step of an issue's plan under [R12](issue-workflow.md#r12--slice-and-prioritize): a unit of work scoped to a single domain — a test slice, a datastore slice, a docs slice — that passes the [quality gate](engineering-discipline.md#working-a-task-under-the-quality-gate) on its own. Slices are ordered by dependency and TDD, the test slice first. Collision to watch for: the "domain" a slice is scoped to is an area of the *work*; it is not the kit's "domain-free", which means the kit names no *product* domain. | A change to product code has a test slice (done first) and an implementation slice, each its own gate-passing step. |
| Forge | `—` | The hosted service holding the repository, its issues, and its pull requests. The kit is forge-free: it names no specific one, and forge-specific templates ship inert under [`templates/`](templates/). Collision to watch for: a forge keeps references the operator cannot delete, so deleting a commit from a branch does not always remove it from the forge. | Whether a discarded commit stays fetchable after a history rewrite depends on what your forge retains. |
| Backup branch | `—` | A reference holding a tip that a [destruction of history](adr/0004-destroying-history-on-the-default-branch.md) is about to make unreachable — a branch named `backup/pre-<reason>-<short-sha>`, or a tag under `backup/pre-<reason>/<tag>-<short-sha>`, one per discarded tip. It goes to the remote unless the content is itself the reason for the destruction, in which case it is kept off the remote. Collision to watch for: not a backup *copy* of the repository — it preserves one commit inside the same repository. | Before a reset, the default branch's tip and every unmerged branch tip that is not an ancestor of it each get one. |
| Operator | `—` | Anyone the kit's rules bind: each human and each LLM coding agent alike, as [`issue-workflow.md`](issue-workflow.md) states. Collision to watch for: one rule narrows it — [ADR-0004](adr/0004-destroying-history-on-the-default-branch.md) requires the second operator approving a destruction of history to be a person, because an agent instantiated by the acting operator is not an independent party. | R4 needs two different operators to approve a workaround; either may be an agent. |
| Coordinated Universal Time | `UTC` | The time standard records are stamped in, so a sequence of events reads the same to every reader regardless of where they are. | A timeline of an incident gives every entry in UTC, not in the operator's local zone. |
| Application Programming Interface | `API` | The programmatic interface a service exposes, as distinct from its web pages. It matters here because a change made through a forge's API bypasses every local git hook: the hook runs on the operator's machine, and an API write never touches it. | A commit written through the forge's contents API never runs `pre-commit` or `pre-push`. |
| Destruction of history | `—` | Making commits that are — or once were — reachable from the **published** default branch unreachable from it: a reset, a force-pushed rewrite, or deleting the branch. Deleting or moving a tag that points into commits already discarded from the branch counts too, as the act that removes the last handle on history already gone. Permitted only under the conditions in [ADR-0004](adr/0004-destroying-history-on-the-default-branch.md). Collision to watch for: rewriting local history you have never pushed is not this, and neither is deleting any other branch, merged or not. | A reset of the published default branch to an earlier commit destroys history; rebasing an unpushed local branch does not. |
| Repair | `—` | Undoing a prior destruction of history on the default branch by restoring the tip the branch held immediately before that act, while that destruction is still the branch's current state. It waives the second-operator requirement, and adds one: its issue must name the act being undone from a source the actor cannot rewrite. Undoing a repair is not itself a repair. Collision to watch for: a repair is normally a destruction too — a fast-forward repair is the exception, since it makes nothing unreachable. | Restoring the default branch after an accidental force-push is a repair; rewinding it again once other work has landed is a destruction. |
| Secure Hash Algorithm | `SHA` | The hash that names a git object; a short SHA is its abbreviated form, used here to make one backup reference per preserved tip. Collision to watch for: `SHA-1` and `SHA-256` are the algorithms; a "sha" in prose is almost always the object name they produce. | `backup/pre-rewind-a1b2c3d` ends in the short SHA of the tip it preserves. |

## 1. `‹Domain area one›`

| Term | Abbr. | Description | Example |
|------|-------|-------------|---------|
| `‹term›` | `‹—›` | `‹definition›` | `‹example›` |

## 2. `‹Domain area two›`

| Term | Abbr. | Description | Example |
|------|-------|-------------|---------|
| `‹term›` | `‹—›` | `‹definition›` | `‹example›` |
