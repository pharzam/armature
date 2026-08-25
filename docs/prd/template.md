# PRD-NNNN. ‹short noun phrase naming the product or feature›

Date: YYYY-MM-DD

## 1. Header & "In plain terms"

| Field        | Value                                                             |
| ------------ | ---------------------------------------------------------------- |
| PRD ID       | `PRD-NNNN`                                                       |
| Title        | ‹the product or feature this document specifies›                 |
| Status       | `Draft / Accepted / Superseded by PRD-NNNN`                     |
| Date         | YYYY-MM-DD                                                        |
| Author       | ‹the engineer or agent who wrote this record›                   |
| Derives from | ‹F-NNNN, … — the [facts](../facts/) this PRD is built on›        |

### In plain terms

> ‹State, in one or two jargon-free sentences, what this product or feature is
> and why it exists — the [plain-language](../engineering-discipline.md#plain-language-summaries)
> rule. Someone who does not know the domain should understand the point from
> this block alone.›

## 2. Problem & evidence

‹The problem this PRD answers, evidenced by cited facts — not opinion. Every
claim about what the customer needs points to a fact ID (`F-NNNN` or `F-NNNN#n`)
from [`../facts/`](../facts/). If a claim has no fact behind it, it is an
assumption or a known trap and belongs in [`../guardrails.md`](../guardrails.md),
not here.›

## 3. Goals & non-goals

**Goals.** ‹What this product or feature must achieve, in a short list.›

**Non-goals.** ‹What it deliberately does not do. Each non-goal also appears as a
`Won't` row in §6 / §7, so the boundary is machine-checkable, not just prose.›

## 4. Personas & jobs-to-be-done

‹Who uses this, and the job each of them hires it to do. One short entry per
persona; name the persona so §5 user stories can refer back to it.›

## 5. User stories

‹One story per line, each traceable to a persona (§4) and a cited fact (§2). For
example: "As ‹persona›, I ‹do a job› so that ‹outcome› (`F-NNNN#n`)."›

## 6. Functional requirements

| REQ       | Statement                              | MoSCoW                        | Phase            | Facts             |
| --------- | -------------------------------------- | ----------------------------- | ---------------- | ----------------- |
| ‹REQ-001› | ‹short, active capability statement›   | ‹Must / Should / Could / Won't› | ‹1 / 2 / 3 / 4 / —› | ‹F-0001#6, F-0002#7› |

## 7. Non-functional requirements

| REQ       | Statement                              | MoSCoW                        | Phase            | Facts        |
| --------- | -------------------------------------- | ----------------------------- | ---------------- | ------------ |
| ‹NFR-001› | ‹short, active quality-attribute statement› | ‹Must / Should / Could / Won't› | ‹1 / 2 / 3 / 4 / —› | ‹F-0003#2› |

## 8. Success metrics

‹How you will know each goal is met, in units the reader already knows. State the
target and how it is measured, not a vague direction.›

## 9. Rollout & phases

‹How this reaches users, mapped to the phase tags used in §6 / §7. Name each
phase and say what ships in it.›

## 10. Risks

‹The risks to this product or feature. Cross-reference [`../guardrails.md`](../guardrails.md)
for the pre-registered pass/fail rules rather than duplicating them here; this
section names the risk and links the guardrail that holds the line.›

## 11. Open questions & assumptions

‹What is still undecided, and every assumption this PRD rests on. An assumption
that later proves load-bearing should become a fact (with a new `F-NNNN` record)
or a guardrail.›

## 12. Requirements traceability matrix

One row per requirement in §6 / §7. This is the line a reader follows from the
customer's words to the test that proves them.

| REQ       | Facts       | Guardrail                 | ADR         | Task        | Test              |
| --------- | ----------- | ------------------------- | ----------- | ----------- | ----------------- |
| ‹REQ-001› | ‹F-0001#6›  | ‹guardrails pitfall or —› | ‹ADR or —›  | ‹task-ID›   | ‹REQ-001 or —›    |

## 13. Change log

| Date       | Change                     | Requirement(s) affected |
| ---------- | -------------------------- | ----------------------- |
| YYYY-MM-DD | ‹what changed, and why›    | ‹REQ-001, NFR-001 or —› |
