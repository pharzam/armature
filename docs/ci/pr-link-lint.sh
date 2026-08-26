#!/bin/sh
#
# pr-link-lint.sh — enforce R1: a pull request must link its issue.
#
# A domain-free discipline test, the CI twin of docs/issue-workflow.md (R1) and
# docs/templates/*/PULL_REQUEST_TEMPLATE.md. It reads a PR/MR body and passes
# only when the body links an issue with a forge keyword and a concrete numeric
# reference. It reads only text, so it needs no toolchain.
#
# Unlike adr-lint.sh / prd-lint.sh, this check has no repo files to lint: the PR
# body is a forge artifact that exists only on a pull-request / merge-request
# event, so this runs in CI (docs/ci/) and NOT in the pre-commit hook.
#
# Usage:
#   sh docs/ci/pr-link-lint.sh [BODY_FILE]
#     BODY_FILE  a file holding the PR body (used by the self-tests). With no
#                argument the body is read from stdin, e.g. in CI:
#                  printf '%s' "$PR_BODY" | sh docs/ci/pr-link-lint.sh
#
# Exit status: 0 = a linked issue was found, 1 = none (or a bad argument).
#
# What counts as a link:
#   keyword : Close(s|d) | Fix(es|ed) | Resolve(s|d) | Ref(s) | Part of
#   ref     : #123  ·  owner/repo#123  ·  a full issue/MR URL ending in /123
# A concrete numeric id is required, so the template's `#N` placeholder and an
# example inside an <!-- HTML comment --> are both rejected. Closing vs. linking
# (Closes vs. Refs/Part of) is the author's call per R1 — both satisfy the gate.
#
# How to adapt: the keywords mirror the table in docs/issue-workflow.md (R1). If
# you change that table, change this pattern in the SAME change — the linter and
# the workflow doc must always agree.

set -u

src=${1:-}
if [ -n "$src" ]; then
	[ -f "$src" ] || { printf 'FAIL  pr-link-lint: body file not found: %s\n' "$src" >&2; exit 1; }
	body=$(cat -- "$src")
else
	body=$(cat)
fi

# Strip HTML comments (they may span lines) so a `#123` shown as guidance inside
# `<!-- ... -->` never counts as a real link.
stripped=$(printf '%s' "$body" | awk '
	{ buf = buf $0 "\n" }
	END {
		while ((s = index(buf, "<!--")) > 0) {
			rest = substr(buf, s + 4)
			e = index(rest, "-->")
			if (e == 0) { buf = substr(buf, 1, s - 1); break }
			buf = substr(buf, 1, s - 1) substr(rest, e + 3)
		}
		printf "%s", buf
	}')

kw='(clos(e|es|ed)|fix(es|ed)?|resolv(e|es|ed)|refs?|part of)'
ref='(#[0-9]+|[A-Za-z0-9][A-Za-z0-9._-]*/[A-Za-z0-9._-]+#[0-9]+|https?://[^ ]+/[0-9]+)'

if printf '%s' "$stripped" | grep -Eiq "(^|[^A-Za-z])${kw}[[:space:]]+${ref}"; then
	printf 'pr-link-lint: OK\n'
	exit 0
fi

cat >&2 <<'EOF'
FAIL  pr-link-lint: the PR body links no issue (R1).
  Add a linking line to the PR body, for example:
    Closes #123     # closes the issue when this PR merges (fully satisfies it)
    Refs #123       # links a parent/multi-part issue without closing it
  See docs/issue-workflow.md (R1) and docs/templates/*/PULL_REQUEST_TEMPLATE.md.
EOF
exit 1
