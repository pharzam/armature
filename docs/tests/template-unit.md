# Unit test template

A unit test proves that **one component behaves correctly in isolation**, per
the [unit level](test-levels.md#1-unit-tests). This is the pattern to copy for
each new one.

> **How to adapt this file.** Copy [the skeleton](#fill-in-skeleton) below for
> every new unit test, replacing each `‹…›` with the real name, code, and
> command. Keep the pattern's rules; delete this note once your first real test
> is written from it.

## In plain terms

> Test one small piece of the system on its own, with everything around it
> replaced by a simple stand-in, and check one thing about how it behaves.

## The pattern

Every unit test has the same three-part shape, in this order:

1. **Arrange** — build the one component under test and its stand-in
   dependencies. A stand-in replaces a real collaborator (a database, a network
   call, the clock) with something predictable and local, so the test touches
   no real file, network, or clock.
2. **Act** — call the one behaviour under test.
3. **Assert** — check one outcome. A unit test proves one behaviour; if a test
   needs several unrelated assertions to make its point, it is usually testing
   more than one behaviour and should split.

A unit test does not depend on another test's state or order. Where a real
collaborator is genuinely needed, that is an
[integration test](template-integration.md), not a unit test.

## Fill-in skeleton

```text
test ‹name: the behaviour, in plain words, e.g. "rejects a negative amount"›:
    arrange:
        ‹build the component under test›
        ‹build the stand-in(s) that replace its dependencies›
    act:
        ‹call the one behaviour being tested›
    assert:
        ‹expected outcome, and nothing else›
```

- **Run with:** `‹unit test command›`
- **Timeout:** `‹test timeout›` — a unit test that hangs must fail, not stall
  the commit hook.
- **Lives in:** `‹test directory›`

## Checklist

- [ ] Tests exactly one behaviour.
- [ ] Does not depend on another test's state or order.
- [ ] Deterministic — touches no real file, network, or clock; every
  dependency is a stand-in.
- [ ] Tagged `unit`, so the level can run on its own.
- [ ] Names the requirement it covers, via a
  [traceability](traceability-template.md) row.
- [ ] Fast enough to run in the commit hook, alongside every other unit test.

## See also

- [`test-levels.md`](test-levels.md) — where the unit level sits in the ladder, and
  the command placeholders this file uses.
- [`traceability-template.md`](traceability-template.md) — where you record what
  this test proves.
