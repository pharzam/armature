# Link discipline

The check that keeps the documents' own navigation honest.

| File | What it is |
| ---- | ---------- |
| [`link-lint.sh`](link-lint.sh) | Resolves every in-tree Markdown link and heading anchor. Runs in the [`pre-commit` hook](../../.githooks/pre-commit) and in [CI](../ci/). |
| [`tests/`](tests/) | Its fixtures — one `good` case and a `bad-*` case per assertion. Run by [`run-discipline-tests.sh`](../tests/run-discipline-tests.sh). |
| [`tests/expect-check.sh`](tests/expect-check.sh) | Asserts each `bad-*` case fails for **its own** assertion, not merely that it fails. |

## Why it exists

Armature's product **is** its documents, and they are a web of relative links and
heading anchors. Rename a heading and every anchor pointing at it dies silently:
the page still renders, the link still looks like a link, and a reader following
it lands nowhere. Nothing in the kit caught that until this check.

The gap was found the honest way. A review of [#61](https://github.com/pharzam/armature/issues/61)
noticed that a "311 links resolve" claim had been cited beside the committed
linters as if it were one of them, when it came from a throwaway script. It was
not repeatable, so it was not evidence —
[R5](../issue-workflow.md#r5--deterministic-over-llm-based) says a mechanizable
claim belongs in a mechanism. This is that mechanism.

On its first run over the tree it found a real dead link in
`docs/ci/tests/pr-link/README.md`, which had pointed one directory too shallow
since the file was written.

## What it asserts

| ID | Assertion |
|----|-----------|
| `L1` | Every relative link target resolves to a path that exists. |
| `L2` | Every `#fragment` on an in-tree `.md` target names a heading in that file. |
| `L3` | Every same-file `#fragment` names a heading in the linking file. |
| `L4` | No link target escapes the repository root. |
| `L5` | Coverage floor — a run that resolved **zero** links fails. |

## What it proves, and what it does not

It proves a link's target **exists**. It does **not** prove the link is the
**right** one: a link to the wrong existing file, or to a real heading that does
not say what the sentence claims, passes every assertion here. That is the
[semantic-agreement review](../engineering-discipline.md#reviewing-for-semantic-agreement),
not this script.

## What it skips, and the limits that leaves

- **External `http(s)` links.** Checking them needs the network, which would cost
  the offline property every [discipline test](../tests/test-levels.md#discipline-tests)
  depends on. A rotted external link is not caught here.
- **Placeholders** — `‹…›` adopter markers, `<…>` shapes, and the ADR template's
  `NNNN-…` form. Flagging one would push an author to "fix" a template by
  inventing a filename, which is the placeholder-integrity failure
  [`AGENTS.md`](../../AGENTS.md) warns about.
- **Fenced code blocks and HTML comments**, whose links are examples, not
  navigation.
- **Fixture case directories** — any path with a `good*` or `bad-*` component.
  Their links are deliberately broken: `docs/agents/tests/bad-dead-link/` exists
  to make `agents-lint` reject a dead link, and linting it would report that
  suite's success as failure. **The limit is real and named: a genuinely broken
  link in a fixture's own prose goes unseen.** Fixture *suite* READMEs are not
  skipped — they are prose a reader follows, and that is exactly where the one
  real defect was found.

One more, recorded rather than hidden: the slug function is copied from
`agents-lint.sh`'s A19 so the two can never disagree. It drops underscores, which
GitHub keeps in an anchor. Harmless while no heading in the tree uses one, and a
defect the day one does.

## The `EXPECT` convention

Each `bad-*` directory carries an `EXPECT` file holding only its assertion id.
The [discipline-test runner](../tests/run-discipline-tests.sh) compares **exit
codes only**, so a bad case that started failing for a different reason would
still look green there. [`tests/expect-check.sh`](tests/expect-check.sh) closes
that for this suite, and fails if it finds no case to check.

It is a script rather than a copy-paste loop, but it is **not yet a gate** — it is
not wired into the runner. Backlog task `T-9c5t` ([#37](https://github.com/pharzam/armature/issues/37))
owns generalizing `EXPECT` across every suite; this suite is ready for it.

## The cases

| Case | Expected | Exercises |
| ---- | -------- | --------- |
| `good` | `link-lint: OK`, exit 0 | every rule in its passing form — a file link, a fragment, a same-file fragment, a directory, the double-hyphen slug, an external link, and both placeholder shapes |
| `bad-dead-path` | FAIL `L1`, exit 1 | a link to a file that does not exist |
| `bad-dead-fragment` | FAIL `L2`, exit 1 | a real file, an anchor it does not have |
| `bad-same-file-fragment` | FAIL `L3`, exit 1 | a bare `#anchor` this file does not have |
| `bad-escapes-root` | FAIL `L4`, exit 1 | a target that climbs out of the tree |
| `bad-no-links` | FAIL `L5`, exit 1 | a file with nothing left to resolve — the fail-open |

Each `bad-*` case is otherwise valid, so it fails for its own single reason.

Run one: `sh docs/links/link-lint.sh docs/links/tests/good`
Run the reasons: `sh docs/links/tests/expect-check.sh`
