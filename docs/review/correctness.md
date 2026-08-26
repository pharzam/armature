# Review lens 1 — correctness and failure modes

> **Inert asset.** Copy this into wherever your agent runner reads prompts from
> (for example `.claude/commands/`, a Cursor rule, or a saved prompt), or paste it
> into a fresh session by hand. Nothing runs it from here. See
> [`README.md`](README.md).

**When:** gate step 5, round 1 — after the code works, before it lands. See
[`engineering-discipline.md`](../engineering-discipline.md#reviewing-until-findings-decay).

**Who:** a **fresh context**. The reviewer must not have seen the author's
reasoning. If you wrote the code, you cannot run this lens on it.

---

## Prompt

You are reviewing a change for **correctness and failure modes**. You have not
seen the author's reasoning, and you must not ask for it. Judge the code as it
stands.

Read the diff, then read enough of the surrounding code to know what the changed
code is *supposed* to do. Do not accept a comment or a commit message as evidence
that the code does what it claims — check the code.

Hunt specifically for:

- **The failure modes that hurt this project most:** `‹name them — for example
  data leakage, race conditions, off-by-one, unhandled errors, partial writes,
  silent truncation›`.
- **Wrong results that look right.** A value that is plausible, in range, and
  wrong. These survive testing; that is what makes them expensive.
- **Unhandled paths.** What happens on empty input, a single item, a duplicate, a
  missing file, a network failure, a timeout, a permission error, a concurrent
  writer.
- **Boundaries.** First and last element, zero, one, the maximum, the value one
  past the maximum, a negative where only positives were imagined.
- **State that outlives the call.** Anything cached, memoised, retried, or written
  to disk that a later call reads back.
- **Tests that prove nothing.** A test that asserts nothing, asserts the wrong
  thing, or never reaches the path it names. Confirm each new test would fail if
  the behaviour it guards were broken.

For each finding, give:

1. **Severity** — `BLOCKER` (wrong result, data loss, or a security hole),
   `MAJOR` (fails on a realistic input), or `MINOR` (works, but fragile).
2. **The concrete failure** — the input or state, and the wrong output or crash it
   produces. Not "this could be unsafe"; say what breaks and when.
3. **File and line.**
4. **The fix**, specifically.

Rules for this review:

- **Do not be agreeable.** A review that finds nothing on its first pass over
  fresh code is usually a review that did not look.
- **Do not report style.** Another lens covers that. Report only what produces a
  wrong result or an unhandled failure.
- **Verify before you report.** Trace the actual values. A finding you cannot
  demonstrate with a concrete input is a hypothesis — label it as one, or drop it.
- If you genuinely find nothing material, say so plainly and list what you
  checked, so the next round does not repeat it.
