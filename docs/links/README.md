# Link discipline

The check that keeps the documents' own navigation honest.

| File | What it is |
| ---- | ---------- |
| [`link-lint.sh`](link-lint.sh) | Resolves every in-tree Markdown link and heading anchor. Runs in the [`pre-commit` hook](../../.githooks/pre-commit) and in [CI](../ci/). |
| [`tests/`](tests/) | Its fixtures — one `good` case and a `bad-*` case per assertion, plus one per false-green hole a review found. Run by [`run-discipline-tests.sh`](../tests/run-discipline-tests.sh). |
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
| `L6` | Every reference use `[text][label]` has a matching `[label]: target` definition. |
| `L7` | No in-tree target is an absolute path. |

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
- **Fenced code blocks, HTML comments, and inline code spans**, whose links are
  examples, not navigation. A link-shaped example in backticks is not resolved.
- **Fixture case directories** — any path with a `good`, `good-*` or `bad-*` component.
  Their links are deliberately broken: `docs/agents/tests/bad-dead-link/` exists
  to make `agents-lint` reject a dead link, and linting it would report that
  suite's success as failure. **The limit is real and named: a genuinely broken
  link in a fixture's own prose goes unseen.** Fixture *suite* READMEs are not
  skipped — they are prose a reader follows, and that is exactly where the one
  real defect was found.
- **A nested checkout under the root** — a linked worktree, a clone, a submodule.
  The file list is what git lists for this repository, so a copy of the tree
  inside one is never read. Limit 9 below carries the detail.
- **Most links into a path containing a space** — worth knowing before you write
  such a path, not after. Three of the four destination forms cut at the first
  space: `[a](Design Notes/target.md)` is read as a link to `Design` and fails
  `L1`; a `%20` is never decoded and fails too; and the CommonMark angle form
  `[a](<Design Notes/target.md>)` is **skipped in silence**, because what
  survives the cut is `<Design`, which reads as a `‹…›` adopter placeholder.
  Measured: a *correct* spaced link and a *dead* one produce byte-identical
  output, so the check cannot tell those two apart. **The raw HTML form is the
  exception and the one that works** — `<a href="Design Notes/target.md">` is
  captured between its quotes, spaces and all, and resolves. So if your
  repository has a `docs/Design Notes/` or an `RFC 001/`, links into it are
  checked only when written that way. Limits 7 and 8 below carry the detail.

## The forms it reads

A checker blind to a link form is worse than no checker, because the reader
trusts it. Four forms are read:

| Form | Example |
|------|---------|
| Inline | `[x](target.md)` |
| **Nested** | `[![alt](inner.png)](outer.md)` — both destinations |
| Reference | `[x][label]`, and the **collapsed** `[x][]` whose label is its own text |
| Raw HTML | `<a href="target.md">` |

Nested links are found by scanning for **each `](` opener** rather than matching a
whole `[…](…)`: a whole-link match consumes the inner link and advances past the
outer destination, which is a silent false green on the badge idiom.

A CommonMark angle destination `[x](<a path.md>)` is a real link and is resolved.
An adopter marker only *opens* with `<`, as in `<id>.md`; they are told apart on
the closing `>`, so a real link is never skipped as a placeholder.

## Why A19 was removed, and what replaced it

`agents-lint` once carried its own assertion **A19**, resolving the root
`AGENTS.md`'s links. It was removed ([#67](https://github.com/pharzam/armature/issues/67))
because this check walks every Markdown file in the tree and `AGENTS.md` is one of
them ([ADR-0007](../adr/0007-link-coverage-belongs-to-link-lint.md)) — the same work, done once instead of twice, across four link forms instead
of one.

One branch of A19 was **not** redundant: it rejected an **absolute** target, and
this check accepted one. That gap is now `L7`, and closing it here covers every
file in the tree rather than the single file A19 watched.

`bad-entry-point-dead-link` is the fixture that keeps the replacement honest. Note
what it does *not* prove: this check is **filename-agnostic**, so it does not know
`AGENTS.md` is special. The case locks the intent, and would go red if a future
change excluded the repository root from the walk.

## Nine limits, recorded rather than hidden

1. **The slug rule exists in two places and nothing keeps them in step.** It began
   as a copy of `agents-lint.sh`'s A19; that assertion was removed
   ([#67](https://github.com/pharzam/armature/issues/67)) and the named function went
   with it. What survives there is the same rule written inline in the rule-anchor
   derivation (`agents-lint.sh:540`). If one changes and the other does not, one
   check resolves anchors the other rejects — **by hand, with no mechanism**. It also
   drops underscores, which GitHub keeps in an anchor: harmless while no heading in
   the tree uses one, and a defect the day one does.
2. **Duplicate headings are not disambiguated.** GitHub appends `-1` to the second
   occurrence's slug; `anchors_of()` does not, so a legitimate `#foo-1` link would
   be wrongly rejected. No duplicate heading exists in the tree today. This is a
   false *red* — it fails loudly rather than passing silently, which is the right
   direction for a bug to point.
3. **A case-mismatched target passes on a case-insensitive filesystem.** `[ -e ]`
   on macOS accepts `Target.md` for `target.md`, where Linux CI rejects it, so the
   local hook is more lenient than the authority. CI is the authority precisely
   for this class of difference.
4. **A protocol-relative target `//host/path` is reported as an absolute path.**
   It is really an external link, and `L7`'s message misnames it. Inherited
   unchanged from `agents-lint`'s A19, which matched `/*` the same way, so this is
   a limit carried over rather than introduced — recorded here because it was
   never written down there.
5. **A line beginning `[word]: text` is read as a reference definition**, and its
   first word is resolved as a target. So a description-list line such as
   `[TODO]: revisit this later` reports a broken link to `revisit`. That is what
   CommonMark does with the same line, so the linter is not wrong — but it is
   surprising, and the direction is safe: it fails loudly rather than passing
   silently.
6. **The link extractor now exists in two places and nothing keeps them in step.**
   `adr-lint.sh`'s `links_to_record()` reads the same three destination forms this
   file does, the same way, to decide whether a record has an inbound link
   ([#73](https://github.com/pharzam/armature/issues/73)). It resolves nothing —
   that stays this linter's job — but the two must agree about what a link *is*.
   They have disagreed **twice**, and both were found by reading one against the
   other rather than by any mechanism. This one strips a CommonMark angle
   destination and that one did not, so `[a](<x.md>)` resolved here and read as no
   link there. Then the reverse: that one stripped a trailing carriage return and
   this one did not, so every reference definition in a CRLF file reported as
   broken here and resolved there
   ([#76](https://github.com/pharzam/armature/issues/76)). Both are fixed, both
   **by hand, with no mechanism** — the same shape as limit 1, and the reason
   ADR-0007 recorded that one rather than leaving it to be found.
7. **Three of the four destination forms drop a link to a path containing a
   space, and the CommonMark angle form does it *silently*.** The `](…)`,
   reference-definition and angle branches cut a destination at the first space
   or tab, so `[a](<dir with space/target.md>)` — a legal link — is cut to
   `<dir`, which `is_placeholder()` then reads as an adopter `<…>` marker and
   skips. The **raw HTML** branch is the exception: `href="[^"]*"` captures the
   whole quoted value, so `<a href="dir with space/target.md">` resolves
   correctly. Measured, not assumed. No error, nothing resolved, and the reader is not told — the direction a
   bug should never point. Limit 3 is the only other silent one, and it is silent
   *locally*: CI is a case-sensitive filesystem and rejects there. This one is
   silent everywhere.
   An unbracketed `[c](dir with space/target.md)` fails `L1` on `dir`, which is
   *correct* — CommonMark stops at the space too. Reachable since
   [#76](https://github.com/pharzam/armature/issues/76) put two spaced fixture
   directories in the tree; no document links into one today, so nothing is
   currently missed. Recorded rather than fixed, by decision on that issue.
8. **A percent-encoded space is not decoded, so a correct link reports as broken.**
   `[b](dir%20with%20space/target.md)` is what a forge writes and what GitHub
   resolves; this linter looks for a file literally named `dir%20with%20space`,
   does not find one, and fails `L1`. Loud rather than silent, and the mirror of
   limit 7. Between them, exactly **one** spelling of a spaced path both resolves
   here and works on the forge: the raw HTML anchor. An earlier draft of this
   entry said none did, which was wrong — it reasoned from the three Markdown
   branches and never measured the fourth.
9. **The file list is the third thing written in two places and kept in step by
   hand.** This linter and `audit-record-lint.sh` (block 2b) list the repository's
   files the same way — what git tracks plus what it does not ignore, read
   NUL-delimited so no name is quoted and with symlinks refused, so a nested
   checkout is one entry and never read, with a `find` walk that prunes any
   directory holding a `.git` entry whenever this directory is not itself the
   repository root, or git lists nothing
   ([#80](https://github.com/pharzam/armature/issues/80)). The same shape as limits
   1 and 6, **by hand, with no mechanism**:
   [`nested-checkout-check.sh`](../tests/nested-checkout-check.sh) drives both
   copies but does not compare them. The shape's own limit: `--exclude-standard`
   reads `.git/info/exclude` and the global ignore file, neither versioned, so two
   operators on one commit can get different lists.

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
| `good` | `link-lint: OK`, exit 0 | every rule and every form in its passing shape — inline, nested, reference, HTML, angle destination, a fragment, a same-file fragment, a directory, the double-hyphen slug, an external link, both placeholder shapes, and a link-shaped example in a code span |
| `good-crlf` | `link-lint: OK`, exit 0 | the same file with **Windows line endings**. Its three reference definitions — a path, a path with a fragment, and a same-file fragment — each failed `L1`, `L2` and `L3` before the carriage return was stripped; the inline, angle and raw-HTML forms beside them never did, and are there to show where the boundary was. Its endings are pinned by [`.gitattributes`](../../.gitattributes); without that pin, anyone whose git is set to `core.autocrlf=input` or `true` strips the returns the next time they stage it — the conversion happens on the way *into* the blob, not on checkout — and the case then passes while testing nothing. Git normally skips that conversion for a file whose blob already holds returns, but `eol=crlf` keeps these blobs as line feeds on purpose, so that guard does not cover them |
| `bad-dead-path` | FAIL `L1`, exit 1 | a link to a file that does not exist |
| `bad-crlf-expect` | FAIL `L1`, exit 1 | the same, on a case that is **CRLF throughout — its `EXPECT` file included**. That is what gives [`expect-check.sh`](tests/expect-check.sh)'s own carriage-return strip a case: it reads `EXPECT` and demands that id in the linter's output, and before the strip the id was `L1` plus a return, which matches no line — so every case in this suite failed there while the linter beside it was right. The case is *named* `crlf` on purpose, which is what puts it inside the runner's case-name check |
| `bad-dead-fragment` | FAIL `L2`, exit 1 | a real file, an anchor it does not have |
| `bad-same-file-fragment` | FAIL `L3`, exit 1 | a bare `#anchor` this file does not have |
| `bad-escapes-root` | FAIL `L4`, exit 1 | a target that climbs out of the tree |
| `bad-no-links` | FAIL `L5`, exit 1 | a file with nothing left to resolve — the fail-open |
| `bad-reference-target` | FAIL `L1`, exit 1 | a broken destination reached only through a `[label]:` definition |
| `bad-nested-link` | FAIL `L1`, exit 1 | a badge-shaped link whose **outer** target is broken and inner one is not |
| `bad-undefined-label` | FAIL `L6`, exit 1 | a reference label nothing defines |
| `bad-absolute-target` | FAIL `L7`, exit 1 | an absolute target, which resolves for any file at the repository root and so passes silently |
| `bad-entry-point-dead-link` | FAIL `L1`, exit 1 | the **redundancy test** — a dead link in a root `AGENTS.md`, locking the coverage that `agents-lint`'s A19 used to provide |
| `bad-collapsed-reference` | FAIL `L6`, exit 1 | the collapsed `[x][]` form, whose empty second bracket makes a naive reader drop it |
| `bad-definition-trailing-link` | FAIL `L1`, exit 1 | a broken link *after* a reference definition on the same line |

Each `bad-*` case is otherwise valid, so it fails for its own single reason.

Run one: `sh docs/links/link-lint.sh docs/links/tests/good`
Run the reasons: `sh docs/links/tests/expect-check.sh`
