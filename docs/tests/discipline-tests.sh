#!/bin/sh
#
# discipline-tests.sh — run every discipline linter against its own fixtures.
#
# THE GAP THIS CLOSES. The kit's linters shipped with fixtures and no runner. A
# per-directory README listed the cases and told a human to run them one at a
# time, so nothing failed when a linter regressed. Fixtures nobody runs are
# documentation, not tests — and an untested linter is exactly the "test that
# passes for the wrong reason" that guardrails.md warns about, sitting inside the
# gate itself. This script is the gate for the gate.
#
# WHAT TWO REVIEW ROUNDS THEN FOUND (issue #37). The first runner asserted only
# that a bad-* fixture made the linter exit 1 — never WHY. Exit 1 is the only
# rejection code every linter has, so it could not tell "the linter caught the
# defect" from "the linter could not open the file". A second round, after the
# reason-assertion was added, found that a fixture could still DISAPPEAR without
# a word: `for entry in "$root"/*` never matches a dotfile, drops a broken
# symlink, and cannot see a deletion at all, and nothing pinned how many cases a
# set should yield. `rm -rf docs/adr/tests/good` still gave a green.
#
# So this script now holds three independent guarantees, and it needs all three —
# each one covers a class the others cannot see:
#
#   1. WHY, not just THAT. Every bad-* fixture names the message it must provoke,
#      in a sibling <name>.expect file.
#   2. HOW MANY. Every manifest row pins its case count exactly. A case that
#      disappears by any mechanism — deletion, a dotfile rename, a broken
#      symlink, one nobody has thought of — is a failure.
#   3. NOTHING SKIPPED BY ACCIDENT. A missing linter, a missing fixture root, an
#      entry matching neither naming convention, and an orphaned .expect are all
#      failures. Deliberate skipping goes through SKIP_SETS, which is validated
#      against the manifest so a typo is an error rather than a silent hole.
#
# docs/tests/runner-selftest.sh is the test for this file.
#
# Usage:  sh docs/tests/discipline-tests.sh [REPO_ROOT]
#   REPO_ROOT defaults to two directories above this script.
#   SKIP_SETS  space-separated linter paths to skip on purpose:
#                SKIP_SETS='docs/prd/prd-lint.sh' sh docs/tests/discipline-tests.sh
#
# Exit status: 0 = every case behaved, 1 = one or more did not.
#
# THE CONVENTION. A fixture's name states what it must do:
#   good*  -> the linter must accept it   (exit 0)
#   bad-*  -> the linter must reject it   (exit 1) AND say why
# For every bad-* fixture there is a sibling <name>.expect holding EXACTLY ONE
# non-blank line: a fixed substring of the message that fixture must provoke.
# Several fixtures may name the same message when they test one rule with several
# inputs — what is forbidden is a fixture that would accept any message at all.
#
# A fixture may be a directory (the linter is pointed at the directory) or a
# single file (the linter is pointed at the file). Both shapes already exist.
#
# How to adapt: add a row to the manifest below when you add a linter, and update
# a row's count when you add a fixture. A row is
#   run_set <linter> <fixture root> <entries to ignore> <expected case count>

set -u
LC_ALL=C
export LC_ALL

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=${1:-$(dirname "$(dirname "$script_dir")")}
SKIP_SETS=${SKIP_SETS:-}

cd "$repo_root" || { printf 'FAIL  cannot enter repo root: %s\n' "$repo_root" >&2; exit 1; }

pass=0
fail=0
skipped=0
known_linters=

# Is this linter named in SKIP_SETS?
#
# `set -f` matters: without it the unquoted expansion below is pathname-expanded,
# so SKIP_SETS='docs/*/*-lint.sh' silently skipped four of the five sets. A skip
# is meant to be a decision someone wrote down, and a glob is a decision that
# depends on what happens to be on disk.
is_skipped() {
	set -f
	for _s in $SKIP_SETS; do
		if [ "$_s" = "$1" ]; then set +f; return 0; fi
	done
	set +f
	return 1
}

# Read the single pattern a bad-* fixture must provoke.
#
# NOT `grep -f <file>`: that reads one pattern per line, and an empty line is the
# empty pattern, which matches EVERY input. One stray blank line in any .expect
# file silently turned that fixture back into an exit-status-only check — so a
# gutted fixture passed again, invisibly, in a file no diff would draw attention
# to. Reading one line and passing it as -e removes the whole hazard.
# Echoes the pattern, or nothing if the file is unusable.
expect_pattern() {
	# Strip CR so a CRLF checkout does not produce a pattern that can never match.
	_lines=$(tr -d '\r' < "$1" | grep -c '' 2>/dev/null || printf '0')
	_nonblank=$(tr -d '\r' < "$1" | grep -c '[^[:space:]]' 2>/dev/null || printf '0')
	[ "$_nonblank" -eq 1 ] || return 1
	[ "$_lines" -le 1 ] || return 1
	tr -d '\r' < "$1" | grep '[^[:space:]]'
}

# Run one fixture and check both halves of what its name promises.
run_case() {
	_linter=$1
	_target=$2
	_name=$(basename "$_target")
	_name=${_name%.md}
	_expect=${_target%.md}.expect

	case "$_name" in
		good*) _want=0 ;;
		bad-*) _want=1 ;;
		*)     return 0 ;;   # the caller has already vetted the name
	esac

	# A bad-* fixture directory with no input files is not a test: the linter
	# rejects it for having nothing to read, which proves nothing about the rule.
	if [ "$_want" -eq 1 ] && [ -d "$_target" ]; then
		if [ -z "$(find "$_target" -type f -print 2>/dev/null | head -n1)" ]; then
			fail=$((fail + 1))
			printf 'FAIL  %s is an empty bad-* directory — it tests nothing\n' "$_target" >&2
			return 0
		fi
	fi

	_out=$(sh "$_linter" "$_target" 2>&1)
	_got=$?

	if [ "$_got" -ne "$_want" ]; then
		fail=$((fail + 1))
		printf 'FAIL  %s on %s: exit %d, expected %d\n' \
			"$(basename "$_linter")" "$_target" "$_got" "$_want" >&2
		return 0
	fi

	# A good* fixture is finished: it was accepted, which is the whole claim.
	if [ "$_want" -eq 0 ]; then
		pass=$((pass + 1))
		return 0
	fi

	# A bad-* fixture must be rejected for the rule it is named for. Without this,
	# deleting the fixture's input files leaves a case that still "passes" — on
	# "file not found" rather than on the rule.
	if [ ! -f "$_expect" ]; then
		fail=$((fail + 1))
		printf 'FAIL  %s: no %s — a bad-* fixture must state the message it expects\n' \
			"$_target" "$(basename "$_expect")" >&2
		return 0
	fi

	_pat=$(expect_pattern "$_expect")
	if [ -z "$_pat" ]; then
		fail=$((fail + 1))
		printf 'FAIL  %s must hold exactly one non-blank line and nothing else\n' "$_expect" >&2
		printf '      An empty or blank pattern would match every message, including "file not found".\n' >&2
		return 0
	fi

	if printf '%s\n' "$_out" | grep -qF -e "$_pat"; then
		pass=$((pass + 1))
	else
		fail=$((fail + 1))
		printf 'FAIL  %s was rejected, but not for its own reason\n' "$_target" >&2
		printf '      wanted a message containing: %s\n' "$_pat" >&2
		printf '      got: %s\n' "$(printf '%s\n' "$_out" | head -n1)" >&2
	fi
}

# Walk one fixture root. Directories that hold a case are cases; so are files.
run_set() {
	_linter=$1
	_root=$2
	_ignore=${3:-}
	_expected=${4:-0}

	known_linters="$known_linters $_linter"

	if is_skipped "$_linter"; then
		printf 'NOTE  %s skipped on purpose (SKIP_SETS)\n' "$_linter" >&2
		skipped=$((skipped + 1)); return 0
	fi

	# A missing linter is the largest possible linter regression. It was a NOTE
	# once; that let a renamed script pass the hook and this runner at the same
	# time.
	if [ ! -f "$_linter" ]; then
		fail=$((fail + 1))
		printf 'FAIL  %s is not present — name it in SKIP_SETS if that is deliberate\n' "$_linter" >&2
		return 0
	fi
	if [ ! -d "$_root" ]; then
		fail=$((fail + 1))
		printf 'FAIL  %s has no fixtures at %s — name it in SKIP_SETS if that is deliberate\n' \
			"$(basename "$_linter")" "$_root" >&2
		return 0
	fi

	_before=$((pass + fail))
	_good=0
	_bad=0

	# Dotfiles are globbed deliberately: a fixture renamed to `.bad-status`
	# vanished from `"$_root"/*` in silence. `[ -e ] || [ -L ]` keeps a broken
	# symlink in scope for the same reason — it used to be dropped before the
	# naming check could complain about it.
	for _entry in "$_root"/* "$_root"/.[!.]* "$_root"/..?*; do
		[ -e "$_entry" ] || [ -L "$_entry" ] || continue
		_base=$(basename "$_entry")

		# Not cases, and never were: the index README, the expectation files, and
		# whatever this row declares as shared input.
		case "$_base" in
			README.md|*.expect) continue ;;
		esac
		_is_ignored=0
		for _i in $_ignore; do
			[ "$_i" = "$_base" ] && _is_ignored=1
		done
		[ "$_is_ignored" -eq 1 ] && continue

		# Anything else must be a case. An entry that matches neither convention
		# used to be dropped in silence, so a renamed fixture stopped testing
		# anything and the count quietly fell.
		case "${_base%.md}" in
			good*) _good=$((_good + 1)); run_case "$_linter" "$_entry" ;;
			bad-*) _bad=$((_bad + 1));   run_case "$_linter" "$_entry" ;;
			*)
				fail=$((fail + 1))
				printf 'FAIL  %s matches neither good* nor bad-* — it would never run\n' "$_entry" >&2
				;;
		esac
	done

	# An .expect with no fixture beside it is the signpost a deleted fixture
	# leaves behind. Nothing else in the walk can see a deletion.
	for _e in "$_root"/*.expect; do
		[ -e "$_e" ] || continue
		_stem=${_e%.expect}
		if [ ! -d "$_stem" ] && [ ! -f "$_stem.md" ]; then
			fail=$((fail + 1))
			printf 'FAIL  %s has no fixture beside it — the fixture was deleted\n' "$_e" >&2
		fi
	done

	_ran=$((pass + fail - _before))

	# The count is the guarantee that covers the mechanisms nobody thought of.
	if [ "$_expected" -gt 0 ] && [ "$_ran" -ne "$_expected" ]; then
		fail=$((fail + 1))
		printf 'FAIL  %s yielded %d cases, expected %d — a case appeared or disappeared\n' \
			"$_root" "$_ran" "$_expected" >&2
	fi

	# A linter is two claims: it rejects what is wrong AND accepts what is right.
	# Deleting every good* fixture left the accept half untested, with a green.
	if [ "$_good" -eq 0 ]; then
		fail=$((fail + 1))
		printf 'FAIL  %s has no good* fixture — nothing checks that the linter accepts valid input\n' "$_root" >&2
	fi
	if [ "$_bad" -eq 0 ]; then
		fail=$((fail + 1))
		printf 'FAIL  %s has no bad-* fixture — nothing checks that the linter rejects anything\n' "$_root" >&2
	fi
}

# --- the manifest ----------------------------------------------------------
# linter | fixture root | entries that are shared input, not cases | case count
run_set docs/adr/adr-lint.sh       docs/adr/tests           ''      6
run_set docs/prd/prd-lint.sh       docs/prd/tests           facts   9
run_set docs/tasks/backlog-lint.sh docs/tasks/tests         ''      7
run_set docs/ci/pr-link-lint.sh    docs/ci/tests/pr-link    ''     10
run_set docs/glossary-lint.sh      docs/tests/glossary-lint ''      5

# --- SKIP_SETS must name something real -------------------------------------
# A typo used to be accepted in silence, which is the same hole as a silent skip
# wearing a different hat.
set -f
for _s in $SKIP_SETS; do
	_found=0
	for _k in $known_linters; do
		[ "$_k" = "$_s" ] && _found=1
	done
	if [ "$_found" -eq 0 ]; then
		set +f
		printf 'FAIL  SKIP_SETS names %s, which is not in the manifest\n' "$_s" >&2
		fail=$((fail + 1))
		set -f
	fi
done
set +f

# --- the runner's own sanity check -----------------------------------------
# Zero cases means the walk broke, not that everything passed. A green with no
# work done is the failure this whole script exists to prevent.
if [ "$((pass + fail))" -eq 0 ]; then
	printf 'FAIL  no fixture cases ran at all — the runner is broken, not the linters\n' >&2
	exit 1
fi

if [ "$fail" -eq 0 ]; then
	printf 'discipline-tests: OK (%d cases' "$pass"
	[ "$skipped" -gt 0 ] && printf ', %d set(s) skipped on purpose' "$skipped"
	printf ')\n'
	exit 0
fi

printf 'discipline-tests: %d of %d cases failed\n' "$fail" "$((pass + fail))" >&2
exit 1
