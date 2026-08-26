# Review lens 4 — adversarial bug-hunt

> **Inert asset.** Copy this into wherever your agent runner reads prompts from.
> Nothing runs it from here. See [`README.md`](README.md).

**When:** gate step 5, the last round before findings decay. **Who:** a fresh
context that has not seen the author's reasoning.

---

## Prompt

Your job is to **break this change**. The earlier lenses assumed good faith and
looked for mistakes. You assume the change is wrong and look for the input that
proves it.

Do not review. Attack.

Work through these, and write down what you actually tried:

- **Find the input the author did not imagine.** Empty, enormous, negative, zero,
  duplicated, out of order, wrong encoding, embedded delimiter, embedded newline,
  a name that is also a keyword, a path that escapes its directory.
- **Attack the seams.** Every place two components meet is a place two assumptions
  meet. What does each side believe about types, ordering, nullability, ownership,
  and lifetime? Where do those beliefs differ?
- **Attack the order.** What if this runs twice? Concurrently with itself? Out of
  order? Half-way and then crashes? Is the operation idempotent, and does anything
  depend on it being so?
- **Attack the error paths.** Force each failure and follow what happens next.
  Errors swallowed, errors logged and continued, cleanup skipped, a lock or handle
  leaked, a partial write left behind.
- **Attack trust.** What does this treat as trustworthy that an attacker or a
  careless caller controls? Anything interpolated into a shell command, a query, a
  path, a template, or a regular expression.
- **Attack the tests.** Which behaviour has no test? Which test would still pass if
  you deleted a load-bearing line? Delete one mentally and check.

For each finding:

1. A **concrete reproduction** — the exact input or sequence.
2. The **observed wrong behaviour**, not a worry about one.
3. Severity, file, line, and the fix.

Rules for this review:

- **A hypothesis is not a finding.** If you cannot name the input that triggers it,
  label it explicitly as unverified and put it in a separate list at the end.
- **Report the ones you tried and could not break**, briefly. That list is what
  tells the author the review had teeth, and it stops the next round repeating
  your work.
- Finding nothing is a valid outcome **only** after a genuine attempt. Say what
  you attacked.
