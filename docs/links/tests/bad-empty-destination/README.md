# Bad — L10, a link with an empty destination

`[a]()` and `[a](   )` are links. `pandoc --from commonmark` renders both as
`<a href="">`, and a reader clicking one goes nowhere.

Before issue #111 the extractor
dropped them: `if (t != "")` skipped the empty target and nothing was reported.
That is the silence the trimming two lines above it exists to prevent —
`link-lint.sh` says the trimming is there so a destination is not *"cut to nothing
and dropped in silence"*, and then the empty one was dropped in silence.

A control link resolves here on purpose. Without it, removing the `L10` assertion
makes this case fail `L5` — *no in-tree link was resolved* — which is still exit 1,
so a harness comparing exit codes alone would pass the case with the assertion it
names deleted. That is the *fixture harness that compares only exit codes* pitfall
in docs/guardrails.md, and it was found by mutating this very case.
