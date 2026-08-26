# Review prompts

The prompts for **gate step 5** — [Reviewing until findings
decay](../engineering-discipline.md#reviewing-until-findings-decay) — and for the
single plan review that [R12](../issue-workflow.md#r12--slice-and-prioritize)
requires before building starts.

The discipline documents say a review round happens and what each lens looks for.
These files are that instruction written as a prompt an operator can hand
straight to a reviewer, human or agent, without rebuilding it from prose each
time. This is [R5](../issue-workflow.md#r5--deterministic-over-llm-based) applied
to the kit itself: where a procedure can be an artifact rather than a memory, make
it an artifact.

## In plain terms

> These are the review checklists, written so you can hand one to a reviewer
> as-is. Use one per round, in order, until a round finds nothing worth fixing.

## The files

| File | Lens | When |
| ---- | ---- | ---- |
| [`plan.md`](plan.md) | The R12 plan review | **Before** the first test, once |
| [`correctness.md`](correctness.md) | Correctness and failure modes | Gate step 5, round 1 |
| [`guardrails.md`](guardrails.md) | Guardrails and acceptance criteria | Gate step 5, round 2 |
| [`simple.md`](simple.md) | Clean and simple | Gate step 5, round 3 |
| [`adversarial.md`](adversarial.md) | Adversarial bug-hunt | Gate step 5, last round |

## How to use them

1. **One lens per round.** The order above is deliberate: correctness before
   cleanliness, and the bug-hunt last, when the obvious defects are already gone.
2. **A fresh context every round.** A reviewer that has seen the author's
   reasoning inherits the author's blind spot. If you wrote the code, you cannot
   review it.
3. **Fix every real finding, then run another round.** Keep going until one round
   finds nothing material. One pass is never enough — each lens catches a
   different class of error.
4. **Record the rounds.** The plan review's verdict goes on the issue, next to the
   plan. The code rounds and their findings belong with the task's evidence under
   `‹evidence store›`.

## They are inert

Nothing here runs on its own, exactly like [`../ci/`](../ci/) and
[`../templates/`](../templates/). Copy a file into wherever your agent runner
reads prompts from — a commands directory, a rules file, a saved prompt — or paste
it into a fresh session by hand.

> **How to adapt these files.** Replace the `‹…›` marker in
> [`correctness.md`](correctness.md) with the failure modes that have actually hurt
> this project; that one list is what turns a generic review into yours. Add a lens
> when a class of defect keeps escaping — one file per lens, added to the table
> above and to the discipline document in the same change (R10). Delete this note
> once your failure modes are in.
