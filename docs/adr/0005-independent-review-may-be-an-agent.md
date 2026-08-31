# 0005. Independent review may be an agent

Date: 2026-08-31

## Status

Accepted

## Context

The [quality gate](../engineering-discipline.md#working-a-task-under-the-quality-gate)
rests on review twice: once on the plan under
[R12](../issue-workflow.md#r12--slice-and-prioritize), and then in the uncapped
[rounds that run until findings decay](../engineering-discipline.md#reviewing-until-findings-decay).
Neither said what a reviewer must *be*.

That silence stopped being free when the kit started shipping deterministic
checks that are honest about their own limits.
[`agents/agents-lint.sh`](../agents/agents-lint.sh) proves presence, structure and
coverage over the agent entry points, and its
[README](../agents/README.md) says in as many words that it does **not** prove
semantic agreement — that a compressed sentence means what its source paragraph
means. It hands that residual to the R12 plan review, the blind rounds, and the
[R9](../issue-workflow.md#r9--test-freeze-after-confirmation) fresh-context
confirmation. A machine check that names its own gap is only as good as the
reviewer that catches what it drops.

The review of the change that shipped those entry points
([#58](https://github.com/pharzam/armature/issues/58), landed by
[#60](https://github.com/pharzam/armature/pull/60)) proposed closing the gap with
a **human maintainer** for semantic agreement, on the reasoning that a fresh model
context is not the same as independent ownership.

The reasoning identifies something real and then names the wrong remedy. What
makes a review worth anything is that the reviewer cannot see what the author
saw. Ownership is one way to buy that distance; it is not the only one, and this
kit binds two operator classes — the human and the
[LLM](../glossary.md) — as equals everywhere else. A rule that admits only one of
them for the review that matters most would make the kit unusable by the agent
teams it is written for, and would put a species test where an evidence test
belongs.

The opposite error is as easy. Two agents given the same prompt, the same
context and the same model are not two reviewers. They are one reviewer run
twice, and they share every blind spot. "A fresh context reviewed it" is only
evidence if what was fresh about it is written down.

## Decision

We will require **independence**, not a reviewer species. A reviewer may be a
human or a fresh agent session. Human review is an **escalation**, not a
universal requirement.

An independent review has four levels. Each level is a distance from the author,
and a review claims only the levels it actually had:

1. **Context independence** — the reviewer starts a fresh session and sees the
   issue, the acceptance criteria, the source documents and the diff. It does
   **not** see the author's reasoning or any earlier round's verdict. Required of
   every review.
2. **Method independence** — a different lens and a different prompt from the
   round before it. Required of every round after the first, and already the rule
   for the [decay rounds](../engineering-discipline.md#reviewing-until-findings-decay).
3. **Execution independence** — a separate run, recorded separately. The review
   names the commit it read, the reviewer's identity — the model, or the person —
   its input, its raw findings, the fixes, and its verdict. Required of every
   review.
4. **Model independence** — a different model, or a different provider. Required
   for high-risk work: a governance change, a change to the checks themselves, or
   anything feeding a costly or irreversible action.

Two further rules bound it:

- **Deterministic checks stay preferred over any reviewer** — human or agent
  ([R5](../issue-workflow.md#r5--deterministic-over-llm-based)). Every claim a
  script can settle is settled by a script, and review is what is left over.
  Independence is how the residual is judged, never a reason to leave a
  mechanizable claim to judgement.
- **A review reads a fixed commit.** A moving target cannot be reviewed, and a
  verdict that does not name what it read is not evidence.

Unresolved disagreement escalates by the task's risk: a second reviewer at a
higher independence level, and a human operator at the top. Two reviewers who
disagree do not average their verdicts, and the author does not break the tie.

We reject three alternatives:

- **Require a human maintainer for semantic agreement.** It buys real
  independence with a bottleneck the kit's own operator model forbids, and it
  measures the reviewer instead of the review.
- **Accept "a fresh context reviewed it" as sufficient.** Unrecorded freshness is
  unfalsifiable, and identical prompts on identical models share blind spots.
- **Replace the shell linters with a real Markdown parser or structured
  metadata**, proposed in the same review to shrink the check's review surface.
  The zero-toolchain POSIX `sh` property is load-bearing: it is what lets the
  [discipline tests](../tests/test-levels.md#discipline-tests) be an adopter's
  *first* test, before any product code or toolchain exists. Trading it for
  reviewability spends a property the kit is built on. The structured-metadata
  half is compatible with that property and stays open as its own task; the
  parser half is closed here.

## Consequences

Semantic agreement now has somewhere to land. It becomes a
[DoD](../tests/dod-checklist.md) item reviewed clause by clause, rather than an
obligation named in a linter's README and collected by nothing.

The R12 plan review gains a stated scope — architecture and scope, not
implementation approval — so a reviewer who approved a plan's shape has not
thereby approved whatever size arrives under it. That is the failure this ADR
comes from: a reviewed plan produced a 1051-line linter and 41 fixture trees, and
no one had agreed to that.

Review gets more expensive to record and cheaper to trust. A round now names its
commit, its reviewer, its lens and its verdict, which is more writing than "LGTM"
and is the only form a later reader can check. High-risk work costs a second
model.

This stays a **written rule**. No mechanism reads a review record today, and the
[enforcement table](../issue-workflow.md#what-is-enforced-where) says so rather
than implying a gate that does not exist. Wiring one — a check that a PR's issue
carries a review record naming a commit and a reviewer — is left open.

Independence levels are a floor, not a ceiling, and the kit sets no numeric bar:
it does not say how many rounds, or how many reviewers, because that number
depends on a risk the adopter knows and the kit does not.
