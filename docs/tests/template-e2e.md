# End-to-end (E2E) test template

A generic pattern for writing an end-to-end test — the level defined in
[`test-levels.md`](test-levels.md#3-end-to-end-e2e-tests). Copy the skeleton
below for each new user-facing scenario.

> **How to adapt this file.** Replace every `‹…›` placeholder with your stack's
> real command once, in [`test-levels.md`](test-levels.md); this file inherits
> them. Copy the [skeleton](#fill-in-skeleton) for each new scenario and delete
> this note from your own copy once the first real test is in.

## In plain terms

> An end-to-end test opens the whole system the way a real user would, does one
> thing a user cares about, and checks that the result looks right at the end. If
> it needs to peek inside the system to pass, it is not really end-to-end.

## The pattern

- **Drive the real entry point.** Start the whole running system and go in the
  way an actual user or caller would — not a shortcut that skips a layer the
  user would have gone through.
- **One scenario per test.** Each test covers a single user-facing path. A test
  that checks several unrelated things fails for an ambiguous reason.
- **Assert the final, visible result.** Check what the user or caller would see
  at the end, not an internal detail only the system's own code cares about.
- **Use a stable interface.** Find things the way a user would — by a stable,
  documented handle — not by a brittle detail (an incidental layout position, a
  fragile lookup) that breaks on unrelated changes. Wait for a real, observable
  condition to be true, never for a fixed amount of time.
- **Bound it with a timeout.** Set `‹test timeout›` so a hang fails the test
  instead of stalling the pipeline behind it.
- **Mind where it runs.** The full set runs in CI, where the expense is
  affordable; a tiny smoke subset may run in the local hook to prove the wiring
  still works, per [`test-levels.md`](test-levels.md#3-end-to-end-e2e-tests).

## Fill-in skeleton

```text
Scenario: ‹the one user-facing path this test proves›

1. Start the system: ‹how the running system comes up for this test›
2. Drive the path: ‹the steps a real user or caller takes, in order›
3. Assert the result: ‹the final, visible outcome that proves the scenario
   worked›

Run: ‹end-to-end test command›
Timeout: ‹test timeout›
Lives under: ‹test directory›
```

## Checklist

- [ ] Covers exactly one user-facing scenario.
- [ ] Goes through the system's real entry point, not a shortcut around it.
- [ ] Finds things by a stable interface — no brittle selectors, no
      fixed-time waits.
- [ ] Bounded by `‹test timeout›`, so a hang fails rather than stalls.
- [ ] Names the requirement it covers via a
      [traceability](traceability-template.md) row.
- [ ] Runs in CI (and, if it is a smoke test, in the local hook too).

## See also

- [`test-levels.md`](test-levels.md) — where E2E sits in the ladder, and the
  command placeholders this file uses.
- [`template-uat.md`](template-uat.md) — the human sign-off that rides on this
  same path.
