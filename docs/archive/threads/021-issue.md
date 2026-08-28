# #21 — Rescope the two rules the kit cannot enforce (abbreviation rule, R4)

*Archived from GitHub. State at archive time: OPEN. Opened 2026-08-26T14:57:40Z.*

---

Part of #16.

## Goal

Rescope the two rules the kit cannot enforce, so that each becomes checkable or honestly labelled.

1. **The abbreviation rule** (`engineering-discipline.md` §Glossary) binds "any conversation, context, prompt, reply, or response". No test can read a conversation. By the kit's own words, an unenforced gate is no gate.
2. **R4** needs two operators to approve a workaround. The kit's primary audience — one person plus agents — has one operator.

## Duplicate check (R2)

- [x] Searched open and closed issues. Not a duplicate. Parent: #16.

## Solution note (R3)

- **Chosen:** limit the abbreviation rule's **enforced** scope to committed Markdown, where a linter reaches, and keep the conversational form as a stated aspiration that is explicitly labelled unenforced. Give R4 a solo-operator form: a written, dated self-review on the issue plus the mandatory removal issue.
- **Rejected:** *delete the rules* — both encode a real lesson. *Leave them as they are* — they will drift, and a drifting rule teaches a reader to ignore the rest.
- **Decision record:** this issue. It narrows two rules; it does not change the structure.

## Acceptance criteria

- [ ] The abbreviation rule states its enforced scope and its unenforced aspiration, separately.
- [ ] R4 has a solo-operator form that keeps the removal issue mandatory.
- [ ] The "What is enforced where" table reflects both.
- [ ] R10 sync holds; the glossary is unchanged unless a term moves.
- [ ] The task line moves from backlog to completed in the same PR.




---

### Comment — pharzam — 2026-08-26T15:05:05Z

**Evidence: the rule is already broken, in this repository, today.**

While planning I ran the check that `glossary-lint` would run. The abbreviation rule in `engineering-discipline.md` §Glossary says *every* abbreviation must have a glossary row, that it "binds **all LLMs and all human operators**", and that it "is not optional". The only exemption is general-English forms such as `e.g.` and `i.e.`

Every abbreviation the kit's own documents use, against the glossary:

| Abbreviation | Used in | Glossary row |
| ------------ | ------- | ------------ |
| `ADR` `CI` `PRD` `PR` `REQ` `NFR` `TDD` `UAT` `DoD` `E2E` `LLM` `STE` | many | ✅ |
| **`CLI`** | `engineering-discipline.md` §"Progress indicators" | ❌ |
| **`TUI`** | `engineering-discipline.md` §"Progress indicators" | ❌ |
| **`GUI`** | `engineering-discipline.md` §"Progress indicators" | ❌ |
| **`MR`** | `docs/templates/gitlab/` (merge request) | ❌ |
| `HTML` `URL` `PDF` | scattered | ❌ |

`CLI`, `TUI`, and `GUI` are not general English. They are exactly the kind of term the rule exists to catch, and they sit in the same document that states the rule.

**Why this matters for this slice.** It is the clearest possible proof of the audit's over-engineering finding (#16): a rule with no machine behind it drifts, and it drifted inside the very file that declares it. It also tells us the rescoped rule needs three things, not one:

1. **A bounded scope** — committed Markdown, which a linter can actually read.
2. **A stoplist** — general English *and* the widely-shared technical vocabulary (`HTML`, `URL`, `PDF`, `ASCII`, `JSON`, `YAML`) that would otherwise bury the signal in noise. The stoplist lives next to the linter and is itself reviewable.
3. **A decision on the real gaps** — `CLI`, `TUI`, `GUI`, and `MR` get glossary rows in this slice. They are genuine project vocabulary.

Without the stoplist a strict linter fails on `YYYY`, `NNNN`, `OK`, and `FAIL`, and would be turned off within a week — which is the failure mode `guardrails.md` already names ("a skipped gate is no gate").


---

### Comment — pharzam — 2026-08-26T16:02:11Z

**Plan change: this slice absorbs `glossary-lint.sh` from #19.**

Executing the plan surfaced a circular dependency that the slicing had hidden.

- This issue rescopes the abbreviation rule so that one half is **enforced**. That word is only true once a linter exists.
- #19 was to build `glossary-lint.sh`. But that linter fails on the current repository until `CLI`, `TUI`, `GUI`, and `MR` have glossary rows — and those rows are this issue.

So #21-then-#19 would ship a document claiming "enforced" with nothing enforcing it, and #19-then-#21 would ship a linter that fails the moment it lands. Neither order works, because the two are one change wearing two issue numbers.

**Resolution.** This slice now delivers the whole unit:

1. The four missing glossary rows (`CLI`, `TUI`, `GUI`, `MR`).
2. `glossary-lint.sh` itself.
3. The rescoped rule, worded to match exactly what the linter checks.
4. The hook and CI wiring.
5. The honest row in "What is enforced where".
6. R4's solo-operator form (a small rule edit in the same file, same theme: rules that say what is really true).

#19 keeps the rest: `backlog-lint.sh`, the `AGENTS.md` drift check, and the fixture runner that self-tests every discipline linter.

This is R12 working as intended — "a step with no DoD item is scope creep; a DoD item with no step is a gap." The gap here was that "enforced" had no step behind it.


---

### Comment — pharzam — 2026-08-27T11:47:05Z

## Reopened — `main` does not hold this deliverable

This issue was closed as **completed**. On 2026-08-27 `main` was reset to [`2cd70ee`](https://github.com/pharzam/armature/commit/2cd70ee), which removed every tranche-1 commit. The deliverable this issue claims is therefore not on `main` today.

Leaving it closed repeats the one defect this whole round found at every layer — *a check that reports OK having checked less than it claims* ([finding R-3 in the review](https://github.com/pharzam/armature/issues/16#issuecomment-5438020512)) — this time in the issue tracker. Phase 0 of that plan states the rule plainly: **the tracker must never claim more than `main` holds.**

### Evidence, checked at `2cd70ee`

- `docs/glossary-lint.sh` — absent.
- The abbreviation rule in `docs/engineering-discipline.md` at `2cd70ee` still binds "any conversation, context, prompt, reply, or response", with no split between its enforced scope and its unenforced aspiration.

**One correction for the re-land.** R4's solo form must **not** come back. #34 reversed it, and the reset removed it by deleting the commit that added it. Re-land the abbreviation half of this issue and drop the R4 half — #34 now owns that rule.

### Where the work went

Nothing is lost. The tranche-1 history is preserved on [`backup/pre-r12-reset-999765f`](https://github.com/pharzam/armature/tree/backup/pre-r12-reset-999765f), which is **reference only, never a merge source**: each slice re-lands as a fresh pull request from clean `main`, with the review record on this thread as its test list.

### Returns in

**Phase 2** — redo tranche 1, **abbreviation half only**.
