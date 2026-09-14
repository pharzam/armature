# 0008. Require decision-driving text to admit one reading

Date: 2026-09-10

## Status

Accepted

## Context

A check proves what it measures, not what the author meant, and the kit already
enforces clarity in three narrow places only: a
[plain-language summary](../engineering-discipline.md#plain-language-summaries)
states a finding jargon-free for a non-expert; the
[semantic-agreement](../engineering-discipline.md#reviewing-for-semantic-agreement)
round checks that a *summary* still means its *source*; and
[R11](../issue-workflow.md#r11--single-goal-issues)'s tripwire holds a demo to one
sentence. None of the three governs the **primary** text an operator acts on — the
issue statement, the acceptance criteria and the Definition of Done, a directive to
another operator, a plan step, and a review finding.

A statement that admits two honest readings is acted on two ways. The failure is
silent: each reader believes the text was clear, the work diverges, and the
divergence surfaces far from its cause — late, in a review or a merge, as a dispute
over what the task ever asked. "Be clear" is itself too vague to enforce, so the
gap is not closed by exhortation but by a standard a reviewer can apply and cite.

## Decision

We will require decision-driving text to admit **one honest reading, not two**, and
to be falsifiable — you can name the observation that would show it unmet — with no
unquantified vague word ("fast", "robust", "soon") left carrying a decision. The
operative standard, its three parts and its tripwire are stated once in
[One reading, not two](../engineering-discipline.md#one-reading-not-two), and the
rule is bound as the citable [R13](../issue-workflow.md#r13--one-reading-not-two) so
a review or a commit names it by number. It rides the review mechanisms that
already exist — the plan review and each decay round — and adds no new gate step.

We reject three alternatives, recorded so none is reopened:

- **A deterministic "vague-word" linter.** Ambiguity is a semantic judgement, like
  reviewer [independence](../engineering-discipline.md#who-may-review) and a
  finding's materiality, for which the kit already declines to claim a mechanism. A
  grep over a banned word list is a
  [check that cannot fail](../guardrails.md#2-known-pitfalls--the-traps-specific-to-this-domain)
  to any purpose: it flags a word, never a *reading*, and would be answered by
  avoiding the word, not by writing an unambiguous sentence.
  [R5](../issue-workflow.md#r5--deterministic-over-llm-based)'s preference for a
  deterministic check applies where a rule *can* be checked by a machine; this one
  cannot, and saying so is the honest position, not a gap.
- **A guardrail pitfall only.** A `❌` entry frames a trap to avoid; it is not a
  rule an operator is bound by and a reviewer cites by number.
- **An engineering principle only.** Without a citable R-number the rule has no
  hook in a review; the principle and the rule are both needed, not one of them.

## Consequences

- A reviewer gains a basis to reject an ambiguous statement — the tripwire turns
  "is this clear?" into a recorded check on the plan review and every decay round —
  and a citable number for the finding.
- **Nothing verifies it.** No check reads a statement and judges whether it reads
  one way; the rule buys a claim precise enough to be *wrong*, not a control. The
  [enforced-where table](../issue-workflow.md#what-is-enforced-where) records R13 as
  reviewer judgement, the same honesty the independence levels and
  [ADR-0007](0007-record-task-resource-use.md) state of themselves; overstating it
  would be the defect the review sections exist to catch.
- It adds a reviewer step and a small authoring cost: the "no unquantified vague
  word" clause makes the author supply a number or a glossary term up front, which
  is where the ambiguity was going to be paid for anyway, moved earlier and made
  cheap.
- The three existing clarity rules are unchanged; this sits beside them and names
  the grain each does not cover, so no reader has to infer which rule owns which
  text.
