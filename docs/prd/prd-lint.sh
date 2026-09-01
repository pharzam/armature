#!/bin/sh
#
# prd-lint.sh — keep docs/prd/ honest, as part of the quality gate.
#
# A domain-free discipline test: it lints the Product Requirements Documents
# against the conventions in template.md and README.md. It reads only Markdown,
# so it needs no toolchain and runs green on a fresh kit (no PRDs yet). It runs
# in the pre-commit hook and in CI (docs/ci/), alongside adr-lint.sh.
#
# Usage:  sh docs/prd/prd-lint.sh [PRD_DIR]
#   PRD_DIR defaults to this script's own directory. Facts are resolved from
#   the sibling  <dirname PRD_DIR>/facts/  directory (docs/facts for the real run).
#
# Exit status: 0 = clean, 1 = one or more violations.
#
# Fact rule: a requirement must cite at least one F-NNNN token that resolves to a
# file in the facts dir. Phase values are project-defined and NOT hardcoded here.
# A PRD with no requirement-like rows at all (e.g. an unfilled skeleton whose rows
# are still ‹placeholders›) fails — a real PRD states at least one requirement.
#
# How to adapt: the checks mirror docs/prd/template.md and README.md. If you
# change the template (a column, the MoSCoW set), change the matching check here
# in the SAME change — the linter and the template must always agree.
#
# Portability: the awk below uses interval expressions ({3},{4}); POSIX awk and
# the busybox (alpine) and macOS awks all support them. On a fresh kit the run
# early-exits before awk (no PRD-*.md), so "green out of the box" holds on any awk.

set -u

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
prd_dir=${1:-$script_dir}
facts_dir=$(dirname "$prd_dir")/facts

fail=0
err() { printf 'FAIL  %s\n' "$*" >&2; fail=1; }

[ -d "$prd_dir" ] || { printf 'FAIL  PRD directory not found: %s\n' "$prd_dir" >&2; exit 1; }

# The file list is held in the POSITIONAL PARAMETERS, not in a string. It was a
# space-joined string looped over unquoted, so a PRD under a path containing a
# space became two words and awk was handed two half-paths it could open
# neither of. adr-lint.sh carried the identical construct; the note there
# records the measurement and why a newline-joined string was rejected.
#
# This one was quiet on the kit's own tree only because the kit ships no
# PRD-*.md, so the loop never ran. An adopter meets it on the first real PRD.
#
# $1 is read into $prd_dir at the head of this script and is not wanted again.
set --
for path in "$prd_dir"/PRD-*.md; do
	[ -e "$path" ] || continue
	name=$(basename "$path")
	if printf '%s' "$name" | grep -Eq '^PRD-[0-9]{4}-[a-z0-9][a-z0-9-]*\.md$'; then
		set -- "$@" "$path"
	else
		err "$name: filename must be PRD-NNNN-kebab-case.md"
	fi
done

if [ "$#" -eq 0 ]; then
	[ "$fail" -eq 0 ] && { printf 'prd-lint: OK\n'; exit 0; } || exit 1
fi

existing_facts=$(ls "$facts_dir" 2>/dev/null \
	| sed -n 's/^\(F-[0-9]\{4\}\).*\.md$/\1/p' | sort -u)

for path do
	awk -v fname="$(basename "$path")" -v facts="$existing_facts" '
	function split_row(line,   m, i, c, parts) {
		gsub(/\\\|/, "\001", line)
		m = split(line, parts, "|")
		n = 0
		for (i = 2; i < m; i++) {
			c = parts[i]
			gsub(/^[ \t]+|[ \t]+$/, "", c)
			gsub(/\001/, "|", c)
			cell[++n] = c
		}
		return n
	}
	function is_sep(   i) {
		for (i = 1; i <= n; i++) if (cell[i] !~ /^:?-+:?$/) return 0
		return n > 0
	}
	function fact_ok(cellval,   k, toks, t, base) {
		if (cellval !~ /F-[0-9][0-9][0-9][0-9]/) return 0
		k = split(cellval, toks, /[ ,]+/)
		for (t = 1; t <= k; t++) {
			if (toks[t] ~ /^F-[0-9]{4}(#[0-9]+)?$/) {
				base = substr(toks[t], 1, 6)
				if (index("\n" facts "\n", "\n" base "\n")) return 1
			}
		}
		return 0
	}
	BEGIN { nreq = 0; nmat = 0; reqlike = 0 }
	/^[ \t]*\|/ {
		split_row($0)
		if (n == 0 || is_sep()) next
		id = cell[1]
		if (id ~ /^(REQ|NFR)-/) reqlike = 1
		if (id ~ /^(REQ|NFR)-[0-9]{3}$/) {
			if (n == 5) {
				if (id in seen) { print "FAIL  " fname ": duplicate requirement id " id; ec=1 }
				seen[id] = 1; reqids[++nreq] = id
				if (!fact_ok(cell[5])) { print "FAIL  " fname ": " id " cites no resolvable F-NNNN fact"; ec=1 }
				mo = cell[3]
				if (mo != "Must" && mo != "Should" && mo != "Could" && mo != "Won'\''t") {
					print "FAIL  " fname ": " id " MoSCoW \"" mo "\" not in Must|Should|Could|Won'\''t"; ec=1
				}
				if (mo == "Won'\''t") {
					if (cell[4] != "\342\200\224") { print "FAIL  " fname ": " id " is Won'\''t but Phase is not —"; ec=1 }
				} else if (cell[4] == "" || cell[4] == "\342\200\224") {
					print "FAIL  " fname ": " id " has no phase value"; ec=1
				}
			} else if (n == 6) {
				matids[++nmat] = id
			} else {
				print "FAIL  " fname ": malformed requirement-like row (" n " cells): " id; ec=1
			}
		} else if (id ~ /^(REQ|NFR)-/) {
			print "FAIL  " fname ": malformed requirement id: " id; ec=1
		}
		next
	}
	END {
		if (nreq == 0 && reqlike == 0) {
			print "FAIL  " fname ": no REQ/NFR requirement rows found (an unfilled PRD skeleton?)"; ec=1
		}
		if (nmat > 0 || nreq > 0) {
			for (i = 1; i <= nreq; i++) rset[reqids[i]] = 1
			for (i = 1; i <= nmat; i++) mset[matids[i]] = 1
			for (k in rset) if (!(k in mset)) { print "FAIL  " fname ": requirement " k " missing from traceability matrix"; ec=1 }
			for (k in mset) if (!(k in rset)) { print "FAIL  " fname ": matrix lists " k " which is not a requirement"; ec=1 }
		}
		exit ec ? 1 : 0
	}
	' "$path" || fail=1
done

[ "$fail" -eq 0 ] && { printf 'prd-lint: OK\n'; exit 0; } || exit 1
