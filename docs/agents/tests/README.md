# agents-lint self-tests

These are fixtures for [`../agents-lint.sh`](../agents-lint.sh), **not** example
entry points to fill in. Each case directory is a **miniature repository root**
holding the seven files the linter reads:

```
AGENTS.md  CLAUDE.md  README.md
docs/engineering-discipline.md  docs/issue-workflow.md
docs/onboarding-for-engineers.md  docs/stub/demo-lint.sh
```

The linter is pointed at the case directory and resolves every input inside it.
There is no shared-fixture fallback and no "check it only if the file exists"
branch anywhere in the script, so every assertion runs identically for a fixture
and for the real repository.

The real run (`sh docs/agents/agents-lint.sh`, no argument) reads the repository
root and never descends into this directory, so these fixtures never affect the
kit's own green state. The
[discipline-test runner](../../tests/run-discipline-tests.sh) drives every case
below and asserts the exit code.

**The stub sources declare three gate steps and three rules, and none of the
kit's real names.** That is what makes the `good` case positive proof that
nothing is hardcoded: a linter expecting eight steps and R1–R12 would fail it.
In the stubs, R1 is the mechanized rule and R2 and R3 are written-rule-only, and
R3's title is deliberately long — long enough that a rule line could otherwise
pass the prose floor on its mandated title alone.

## The cases

| Case | Expected | Exercises |
| ---- | -------- | --------- |
| `good` | `agents-lint: OK`, exit 0 | a valid mini-root: thirteen headings in order, one H1 and no other heading-shaped line, three numbered gate steps under `**three** ordered steps`, three rule lines with derived anchors and source titles under `**three** numbered rules`, resolving links, a sources table, and every required literal |
| `bad-no-agents` | FAIL, exit 1 | `AGENTS.md` deleted — the deliverable-absent case, and the same failure the real tree produced before this work landed (A1) |
| `bad-no-claude` | FAIL, exit 1 | `CLAUDE.md` deleted; the Claude entry point is a deliverable, not an option (A2) |
| `bad-no-gate-source` | FAIL, exit 1 | `docs/engineering-discipline.md` deleted, so the gate steps cannot be derived (A3) |
| `bad-agent-singular` | FAIL, exit 1 | a root `AGENT.md` (singular) beside the plural one — two competing sources of instruction (A4) |
| `bad-claude-extra-line` | FAIL, exit 1 | `CLAUDE.md` carrying the import **and** a policy sentence — the duplicated-policy drift the one-line rule exists to stop (A5) |
| `bad-claude-wrong-import` | FAIL, exit 1 | `CLAUDE.md` holding exactly one line, `@AGENT.md`: right count, right shape, wrong target (A6) |
| `bad-over-budget` | FAIL, exit 1 | the guide padded past the pre-registered 1,500-word budget, inside an existing section and adding no heading (A7) |
| `bad-heading-renamed` | FAIL, exit 1 | one required heading renamed, everything else intact (A8) |
| `bad-hidden-tail` | FAIL, exit 1 | a single `# note` line inside `## Checks you can run`, followed by an invented command. Without A9 this line would truncate the section and hide everything after it (A9) |
| `bad-html-comment` | FAIL, exit 1 | an HTML comment in `AGENTS.md`. Comment text is invisible to a reader but still counts as section body, so a required section could be emptied with the gate green (A26) |
| `bad-empty-section` | FAIL, exit 1 | a required heading kept with its body cut to four words (A10) |
| `bad-gate-step-missing` | FAIL, exit 1 | the guide lists two of the source's three steps, renumbered so they look complete (A11) |
| `bad-gate-step-bare` | FAIL, exit 1 | a gate step reduced to a bare title with no prose (A12) |
| `bad-gate-count-word` | FAIL, exit 1 | all three steps listed, but the prose says `**two** ordered steps` — the anti-truncation anchor (A13) |
| `bad-rule-missing` | FAIL, exit 1 | the line for R2 omitted (A14) |
| `bad-rule-wrong-title` | FAIL, exit 1 | R2's link text reads `Gamma rule…` while its anchor is still R2's. An anchor alone would let a line describe the wrong rule (A14) |
| `bad-rule-anchor-suffix` | FAIL, exit 1 | a rule anchor with extra characters after the derived one. They sit **outside** `[-a-z0-9]` on purpose, so A16's harvest stops at the valid prefix and finds it known — only A14's exact-ending test can catch this (A14) |
| `bad-rule-listing-only` | FAIL, exit 1 | a rule line reduced to its number, title and link, with no summary — listing the identifier is not covering the rule (A15) |
| `bad-rule-title-as-prose` | FAIL, exit 1 | R3 carrying its deliberately long source title and a link, and nothing else. A14 already mandates that title, so counting it as prose would let the line say nothing at all (A15) |
| `bad-rule-invented` | FAIL, exit 1 | an `R4` line whose anchor the source never defines (A16) |
| `bad-rule-count-word` | FAIL, exit 1 | all three rules listed, but the prose says `**four** numbered rules` (A17) |
| `bad-false-enforcement` | FAIL, exit 1 | the trailing ` (written rule)` dropped from a rule the enforcement table backs with nothing — the false enforcement claim (A18) |
| `bad-enforcement-hedged` | FAIL, exit 1 | the same rule rewritten to "more than a written rule; the continuous integration job enforces it". It *contains* the phrase while making the false claim, which is why the marker is pinned line-final (A18) |
| `bad-enforcement-table-contradiction` | FAIL, exit 1 | an enforcement-table row naming a hook **and** a CI job while its Status still reads `Written rule until wired`. Deriving from the Status prose would skip the row and silently accept a now-false marking (A18) |
| `bad-dead-link` | FAIL, exit 1 | one link repointed at a document the root does not hold — the rot a rename leaves behind (A19) |
| `bad-source-row-blank` | FAIL, exit 1 | a sources-of-truth row naming a real document with an empty `Authoritative for` cell (A20) |
| `bad-source-row-unresolved` | FAIL, exit 1 | a sources-of-truth row whose first column is a bare path — not a Markdown link, so A19 never harvests it — that resolves to nothing (A20) |
| `bad-source-row-empty-target` | FAIL, exit 1 | a sources-of-truth row whose link target is empty, so the existence test would become `[ -e "$root/" ]` and always pass (A20) |
| `bad-unnamed-check` | FAIL, exit 1 | a second shipped `*-lint.sh` in the tree that `## Checks you can run` does not name (A21) |
| `bad-invented-command` | FAIL, exit 1 | a plausible product command in **inline backticks**, in a section that is not the checks section (A22) |
| `bad-missing-literal` | FAIL, exit 1 | `git diff --check` removed from the checks section (A23) |
| `bad-readme-no-pointer` | FAIL, exit 1 | the mini-root `README.md` keeps its `## Start here` prose but drops the link to `AGENTS.md` (A24) |
| `bad-readme-decoy-pointer` | FAIL, exit 1 | `README.md` links `sub/AGENTS.md` — a real file with the right name that is **not** the root deliverable. A suffix test accepted it; the target is now resolved against the linking file's directory (A24) |
| `bad-rule-decoy-link` | FAIL, exit 1 | a rule line linking `sub/docs/issue-workflow.md#r1--alpha-rule` — a real document, with the right anchor, that is not the one the expectations derive from. The same decoy shape as above, in the rules section (A14) |
| `bad-enforcement-cell-unrecognised` | FAIL, exit 1 | a mechanism cell reading `none`. Honest English, but neither a named mechanism nor a recognised empty cell — so the check reports it instead of guessing which it means (A18) |
| `bad-invented-command-root` | FAIL, exit 1 | an invented `sh setup.sh` — a repository-root script with no directory part. The first narrowing of the harvest required a slash, so this slipped through (A22) |
| `bad-link-escapes-root` | FAIL, exit 1 | a link whose target is exactly `..`. The escape guard required a slash after the dots, so this fell through to an existence test that always succeeds (A19) |

Each `bad-*` case is otherwise valid, so it fails for its own single reason.

Two cases print more than one line, and in both every line names the **same**
assertion. `bad-rule-invented` prints two `A16` lines — the invented anchor and
the invented rule number are the two halves of one equality, and each names what
it found. `bad-enforcement-table-contradiction` prints three `A18` lines — the
self-contradicting row, plus the two rule lines whose marking it falsifies.

## The `EXPECT` convention

Each `bad-*` directory carries an `EXPECT` file holding only its assertion id. It
is not one of the seven files the linter reads, so it changes no assertion. It
exists because the harness compares **only exit codes** — a bad case that started
failing for a different reason would still look green. Check the reasons with:

```
for d in docs/agents/tests/bad-*/; do
	id=$(cat "$d/EXPECT")
	sh docs/agents/agents-lint.sh "$d" 2>&1 | grep -q "FAIL  $id:" || echo "MISMATCH $d"
done
```

**Say plainly: this loop is not itself a gate.** It is run and its output recorded
when the suite changes. Backlog tasks `T-9c5t` ("assert why a linter failed rather
than only that it did") and `T-8b4r` ("make the harness prove each mutant
applied") own that residual.

## Two rules when you add or edit a fixture

1. **Keep each stub short.** The [audit-record linter](../../tasks/audit-record-lint.sh)
   resolves a citation by bare filename against any tree path ending in it, so a
   long fixture file can silently satisfy a citation meant for the real document.
   Measured limits: `README.md` under 32 lines, `engineering-discipline.md` under
   7, `issue-workflow.md` under 22. `onboarding-for-engineers.md` is never cited.
   The stub linter is named `demo-lint.sh`, a basename no record cites.
2. **Name no real ADR.** [`adr-lint.sh`](../../adr/adr-lint.sh) greps every
   Markdown file under `docs/` for an ADR filename stem or an `ADR-NNNN` token to
   decide whether a record is cross-linked. A fixture that named one could
   satisfy a genuine orphan's inbound link by accident.

## What these fixtures do NOT exercise

A fixture cannot reach everything, and a suite that implies otherwise is worse
than one that says so. This list names the **classes** of unfixtured branch, not
every line of the script:

- **A25 cannot be fixtured.** It reads the running script's own leading comment
  block, and a fixture case cannot vary the running script. It *can* now fail —
  it is checked by deleting the sentence from a scratch copy of the script — but
  nothing recurring proves that.
- **A21's empty-set floor is unreachable in the real tree**, because
  `agents-lint.sh` is itself one of the files the glob finds.
- **The "checked nothing" floors** have no cases: A19's "no links at all", A22's
  "no commands at all", A20's "no data rows", A14's "no rule derived", A11's "no
  gate step derived", A18's "empty mechanized set" and its "table holds no rows",
  and the malformed-row branches of A18 and A20.
- **The "section is empty" branches** of A10, A23 and A24, and A24's whole-file
  fallback when a heading is absent.
- **The `beyond_vocabulary` branch** of A13 and A17, which needs a source
  declaring more than twenty steps or rules.
- **Green properties are verified by hand, not by a `bad-*` case**, because a
  fixture can only assert a failure. Those are: A22 no longer failing on ordinary
  prose containing the word "sh" or on a sentence-final period; A18 staying green
  when only the Status *prose* changes with no mechanism wired; and A24 accepting
  an adopter README that carries the link outside the kit's own headings.
- **Three of A24's four inbound-pointer triples**, and the individual pairs of
  A23's literal table. One fixture proves the **mechanism**; the pairs and triples
  are data, exactly as the thirteen required headings are.

Run one case: `sh docs/agents/agents-lint.sh docs/agents/tests/good`
