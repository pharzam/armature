# Integration test template

An integration test proves that **two or more components work together across
a real seam**, per the
[integration level](test-levels.md#2-integration-tests). This is the pattern to
copy for each new one.

> **How to adapt this file.** Copy [the skeleton](#fill-in-skeleton) below for
> every new integration test, replacing each `‹…›` with the real names, setup,
> and command. Keep the pattern's rules; delete this note once your first real
> test is written from it.

## In plain terms

> Test that two real parts of the system actually work together — using the
> real thing on at least one side, not a stand-in — and clean up after
> yourself so the next run starts fresh.

## The pattern

An integration test proves a **real seam**: two or more components working
together across a genuine interface — a real datastore, a real adapter, a real
message queue — rather than a stubbed one. The shape:

1. **Arrange** — stand up or connect to the real collaborator, then build the
   components under test against it.
2. **Act** — drive the workflow across the seam, the way the components would
   use it for real.
3. **Assert** — check the outcome on both sides of the seam where relevant
   (for example, the call succeeded *and* the record now exists in the real
   store).
4. **Teardown** — tear the real collaborator back down, or reset it, so the
   next run starts from the same state this one did.

Because it exercises a real collaborator, an integration test is slower and
more fragile than a unit test, and runs after the unit level. It isolates its
own external state — a fresh fixture per run — so runs do not interfere with
each other or leave residue behind.

## Fill-in skeleton

```text
test ‹name: the workflow, in plain words, e.g. "saves a record and reads it back"›:
    arrange:
        ‹stand up or connect to the real collaborator: ...›
        ‹build the components under test against it›
    act:
        ‹drive the real workflow across the seam›
    assert:
        ‹expected outcome, checked on both sides of the seam›
    teardown:
        ‹tear down or reset the real collaborator: ...›
```

- **Run with:** `‹integration test command›`
- **Timeout:** `‹test timeout›` — a real collaborator that hangs must fail the
  test, not stall the pipeline.
- **Lives in:** `‹test directory›`

## Checklist

- [ ] Exercises a real collaborator, not a stand-in, across at least one seam.
- [ ] Isolates its external state — a fresh fixture per run — and cleans up
  after itself.
- [ ] Does not depend on another test's state or order.
- [ ] Tagged `integration`, so the level can run on its own.
- [ ] Names the requirement or workflow it covers, via a
  [traceability](traceability-template.md) row.
- [ ] Slower than a unit test is expected; a fast subset runs in the commit
  hook, and the full set runs in CI.

The [test levels](test-levels.md) document defines what "integration" means
against the other levels; the [traceability template](traceability-template.md)
is where you record what this test proves.
