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
| Massachusetts Institute of Technology License | `MIT` | A permissive open-source software license with short notice and warranty-disclaimer requirements. Collision to watch for: MIT also names the institute that created the license. | A project can reuse an MIT-licensed library when it preserves the required copyright and license notice. |
| Berkeley Software Distribution licenses | `BSD` | A family of permissive open-source software licenses with variants that differ in their notice clauses. Collision to watch for: BSD can also name the related Unix operating-system family. | Before adoption, the team checks which BSD variant applies and preserves its notices. |
| GNU's Not Unix | `GNU` | The recursive name of the free-software project whose licenses include GPL and AGPL. | A dependency can state that it uses a GNU license. |
| GNU General Public License | `GPL` | A copyleft open-source software license that can require distributed derivative work to use the same license. | The team accepts GPL obligations before it distributes a product that includes GPL-covered code. |
| GNU Affero General Public License | `AGPL` | A copyleft open-source software license that extends source-sharing obligations to modified software used over a network. | The team reviews AGPL obligations before it operates a modified AGPL service for users. |
| Application Programming Interface | `API` | A defined interface through which software components or services exchange requests, data, or operations. Collision to watch for: an API can be local code, not only a network service. | A stable API lets a client update without depending on a component's internal code. |
| Facts Document | `—` | A record under [`facts/`](facts/) that stores one customer's requirements or statements as-is, word for word, as immutable evidence. Carries a stable `F-NNNN` ID that derived requirements cite. Collision to watch for: not a data-warehouse "fact table" — this is a source document, not a database row. | `F-0007#3` cites the third fact in facts document `F-0007`; a requirement written from it names that ID. |
| Simplified Technical English | `STE` | A controlled subset of English — the ASD-STE100 standard — with a limited vocabulary and short, active sentences, used for unambiguous technical writing. In this kit it is the language of the derived requirements written from [facts documents](facts/). Collision to watch for: not the same as a [plain-language summary](engineering-discipline.md#plain-language-summaries) — STE is a formal standard, a plain-language summary is just jargon-free prose. | The requirements derived from `F-0007` are written in STE: short, active sentences drawn from the approved word list. |
| Product Requirements Document | `PRD` | Layer 2 of the two-layer facts rule: a versioned document under [`prd/`](prd/) whose every requirement cites the `F-NNNN` fact it derives from. Collision to watch for: not a `PR` (pull request) — a PRD is a requirements document, a PR is a code change. | A `PRD-NNNN` collects a product's requirements; each `REQ`/`NFR` in it names the fact it came from. |
| Requirement ID | `REQ` / `NFR` | The stable ID of one functional (`REQ-NNN`) or non-functional (`NFR-NNN`) requirement in a [PRD](prd/); assigned once, never reused or renumbered. | `REQ-001` states one capability; `NFR-001` states one quality attribute such as a latency bound. |
| MoSCoW | `—` | A prioritisation scheme — Must, Should, Could, Won't — carried in a PRD requirement's priority column, so the statement need not repeat "shall". | A Must requirement ships in the first phase; a Won't is explicitly out of scope, with an em-dash phase. |
| Test-Driven Development | `TDD` | Write the failing test first, watch it fail for the right reason, then write the code that makes it pass. The kit's default order for a feature or a fix. | R8 of the [issue workflow](issue-workflow.md) states TDD in strict mode: red, then green. |
| Pull Request | `PR` | The unit of change review and merge: a branch proposed for landing on the default branch. The kit lands every change via a PR, never a direct push. Collision to watch for: not a `PRD` — see above. | The [`pre-push` hook](../.githooks/pre-push) refuses a direct push to `main`; a PR is how the change lands. |
| Issue-first workflow | `—` | The rule that an open issue precedes any change, and a PR links back to it — defined in [`issue-workflow.md`](issue-workflow.md) as R1–R12. | No commit starts without an open issue; the PR body says `Closes #N`. |
| Solution selection | `—` | The reusable comparison standard for every technical selection, including problem resolution, planning, testing, and choices of software or services. The canonical criteria are in [`engineering-discipline.md`](engineering-discipline.md#solution-selection). | Before a team builds a custom test tool, it searches for public tools and compares suitable candidates with the same standard used to select its work plan. |
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
| Portable Operating System Interface | `POSIX` | A standard for a portable Unix-like system; here it names the shell-and-utilities subset the kit's scripts target. The [discipline tests](tests/test-levels.md#discipline-tests) are written to POSIX `sh` (plus `grep`/`awk`/`sed`), so they run with no extra toolchain on any such system — Linux, macOS, or the Alpine image in the [CI templates](ci/). Collision to watch for: here it means that shell-and-utilities standard, not the wider operating-system interfaces the full standard also covers (threads, signals). | [`run-discipline-tests.sh`](tests/run-discipline-tests.sh) and the linters use only POSIX `sh`, so `/bin/sh` runs them with no interpreter to install. |
| Work slice | `—` | One step of an issue's plan under [R12](issue-workflow.md#r12--slice-and-prioritize): a unit of work scoped to a single domain — a test slice, a datastore slice, a docs slice — that passes the [quality gate](engineering-discipline.md#working-a-task-under-the-quality-gate) on its own. Slices are ordered by dependency and TDD, the test slice first. Collision to watch for: the "domain" a slice is scoped to is an area of the *work*; it is not the kit's "domain-free", which means the kit names no *product* domain. | A change to product code has a test slice (done first) and an implementation slice, each its own gate-passing step. |
| Command-line interface | `CLI` | A program a person drives by typing a command and reading its text output. One of the three interface kinds named by the rule that a long operation must show progress ([engineering-discipline.md](engineering-discipline.md#progress-indicators-for-long-running-operations)). | A linter that prints `adr-lint: OK` and exits is a CLI program. |
| Text user interface | `TUI` | A full-screen interface drawn with text characters in a terminal, with its own layout and keyboard control. Named beside the CLI and the GUI in the same progress rule. Collision to watch for: not a CLI — a TUI paints and repaints a screen, a CLI prints a stream of lines. | A terminal dashboard that redraws a progress bar in place is a TUI. |
| Graphical user interface | `GUI` | An interface built from windows, pointers, and drawn controls rather than text. The third interface kind the same progress rule names. | A desktop application that shows a progress bar in a window has a GUI. |
| Artificial intelligence | `AI` | The field of software that makes a machine do work which usually needs human judgement. In this kit it names the class of tool an LLM belongs to. Collision to watch for: not a synonym for LLM — an LLM is one kind of AI system. | An audit measured against a book about AI is still verified against the tree. |
| Identifier | `ID` | The short, stable handle that names one record, so a later reader can find it again. The kit gives one to every task, requirement, fact, and finding. | The task ID `T-3v9q` stays the same after the card moves to `completed.md`. |
| Secure Hash Algorithm | `SHA` | The fixed-length digest that names one exact commit or one exact file version. Pinning a dependency to a SHA makes the reference immutable, where a tag can move. | An action pinned to a tag can change under you; the same action pinned to a SHA cannot. |
| Change Risk Anti-Patterns | `CRAP` | A code-quality metric that combines cyclomatic complexity with test coverage, so complex and untested code scores worst. Named here as one of the numeric quality bars the kit does not set. | A search for a CRAP threshold in this kit returns nothing, because no numeric quality bar is written down. |
| HyperText Markup Language | `HTML` | The markup language of web pages. It reaches this kit only as the comment form Markdown borrows, which hides a template line from the rendered page. | The example line in `backlog.md` sits inside an HTML comment, so a reader does not see it. |
| Agent entry point | `—` | A file at the repository root that a coding agent loads when it starts work, so the rules are found rather than looked for. This kit ships two, `AGENTS.md` and a one-line `CLAUDE.md` import of it, described in [`agents/README.md`](agents/README.md) and decided by [ADR-0004](adr/0004-ship-agent-entry-points.md). Collision to watch for: not one of the inert forge files under [`templates/`](templates/) — those are copied into place to change a forge's behaviour, while an entry point is live at the root and only tells a reader where the rules are. | An agent that opens `AGENTS.md` first finds the eight gate steps, the twelve rules, and the document that is authoritative for each. |
| Instruction precedence | `—` | The order in which instructions win when two apply: a higher-priority platform or operator instruction outranks the repository's own agent entry point, which in turn defers to the governance documents it summarises. A nested instruction file may add a local constraint and may never weaken the [quality gate](engineering-discipline.md#working-a-task-under-the-quality-gate). | Where `AGENTS.md` and `issue-workflow.md` disagree about a rule, the rule document wins and the summary is corrected in the same change. |

## 1. `‹Domain area one›`

| Term | Abbr. | Description | Example |
|------|-------|-------------|---------|
| `‹term›` | `‹—›` | `‹definition›` | `‹example›` |

## 2. `‹Domain area two›`

| Term | Abbr. | Description | Example |
|------|-------|-------------|---------|
| `‹term›` | `‹—›` | `‹definition›` | `‹example›` |
