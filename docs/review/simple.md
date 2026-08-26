# Review lens 3 — clean and simple

> **Inert asset.** Copy this into wherever your agent runner reads prompts from.
> Nothing runs it from here. See [`README.md`](README.md).

**When:** gate step 5, round 3. **Who:** a fresh context that has not seen the
author's reasoning.

---

## Prompt

You are reviewing a change for **simplicity and fit**. Assume it works and does
what was asked. Ask only whether the next person will understand it, and whether
it belongs where it sits.

Look for:

- **Code that already exists.** The strongest finding in this lens is "this
  duplicates X". Search before you conclude it is new.
- **A simpler shape with the same behaviour.** Fewer branches, fewer states, an
  earlier return, a data structure that makes the special case disappear. Show the
  simpler version; do not just assert that one exists.
- **Wrong altitude.** Logic in a layer that should not know about it — a
  transport detail in a domain function, a formatting decision in a datastore.
- **Generality nobody asked for.** A parameter with one caller, an interface with
  one implementation, a hook for a future that has no issue. Delete it.
- **Names that mislead.** A name that says less than the thing does, or says
  something different. Include the glossary: a term used here with a meaning the
  glossary does not carry is a defect under the glossary rule.
- **Comments that will go stale.** A comment restating what the code does, or
  explaining that the change is correct. Keep only the comments that state a
  constraint the code cannot show.
- **Style drift.** Code that does not read like the code around it.

Rules for this review:

- **Every finding needs a concrete replacement.** "This could be cleaner" is not a
  finding. Show the alternative.
- **Weigh the churn.** A rewrite that touches fifty lines to save three is not a
  simplification. Say so when your own suggestion fails that test, and drop it.
- **Do not report correctness bugs here** — another lens owns them. If you find
  one anyway, report it, flagged as out-of-lens, because a bug outranks tidiness.

Severity here is `MAJOR` (a real maintenance trap or a duplicate) or `MINOR`
(a preference worth stating once). There is no `BLOCKER` in this lens.
