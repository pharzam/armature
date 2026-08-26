#!/bin/sh
#
# glossary-lint.sh — keep docs/glossary.md honest, as part of the quality gate.
#
# A domain-free discipline test with two jobs:
#
#   1. The table is well formed — four cells per row, no duplicate term, no empty
#      cell.
#   2. "No undefined abbreviation" is actually true, for the scope a machine can
#      read: every abbreviation used in committed Markdown has a glossary row.
#
# It reads only Markdown, so it needs no toolchain. It runs in the pre-commit hook
# and in CI, alongside adr-lint.sh, prd-lint.sh, and backlog-lint.sh.
#
# Usage:  sh docs/glossary-lint.sh [GLOSSARY] [SCAN_ROOT]
#   GLOSSARY  defaults to <script dir>/glossary.md
#   SCAN_ROOT defaults to the repository root (the parent of the glossary's dir).
#
# Exit status: 0 = clean, 1 = one or more violations.
#
# SCOPE, stated honestly. The written rule asks for every abbreviation in "any
# conversation, context, prompt, reply, or response". No program can read a
# conversation, so this linter enforces the part that is checkable — committed
# Markdown — and the discipline document labels the conversational half as an
# aspiration rather than a gate. A rule with no machine behind it drifts, and this
# one had: CLI, TUI, and GUI sat undefined inside the very file that states it.
#
# KNOWN LIMIT. The scan matches all-caps runs (ADR, CI, E2E). It does not match
# mixed-case abbreviations such as DoD or MoSCoW, so those are found by review,
# not by this check. False negatives are the safe direction; a linter that cried
# wolf would be switched off, which guardrails.md already warns about.
#
# How to adapt: extend STOPLIST below with the abbreviations your project treats
# as shared vocabulary. Keep it short — every entry is a term a reader might not
# know. If you change the glossary's column shape, change this linter in the SAME
# change; the two must always agree.

set -u

# Byte semantics, deliberately. These documents carry ‹…›, em dashes, and IPA, and
# several awks abort with "multibyte conversion failure" on them in a UTF-8 locale.
# That abort is silent in a pipeline: the scan yields nothing and the linter
# reports OK — a check that passes for the wrong reason, which is worse than no
# check. Under LC_ALL=C every byte is a byte, [A-Z] stays ASCII, and the scan
# cannot die on a character it was never meant to inspect.
LC_ALL=C
export LC_ALL

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
glossary=${1:-$script_dir/glossary.md}
scan_root=${2:-$(dirname "$script_dir")}

fail=0
err() { printf 'FAIL  %s\n' "$*" >&2; fail=1; }

[ -f "$glossary" ] || { printf 'FAIL  glossary not found: %s\n' "$glossary" >&2; exit 1; }

# Shared vocabulary that needs no row. Two kinds only: general English, and
# formats/protocols a reader of any software project already knows. A term that
# carries project-specific meaning does NOT belong here — it needs a row.
STOPLIST="OK FAIL WARN PASS SKIP TODO NOTE END
HTML URL URI URLS PDF ASCII UTF JSON YAML YML CSV TSV XML SQL HTTP HTTPS SSH GIT
OS IO CPU RAM API CD ID IDS AI
README LICENSE MIT BSD GPL EOF
NNNN NNN NN YYYY YY MM DD HH SS
ASD STE100"

tmp=$(mktemp -d) || { printf 'FAIL  cannot create a temp dir\n' >&2; exit 1; }
trap 'rm -rf "$tmp"' EXIT INT TERM

# --- 1. table shape, duplicate terms, empty cells ---------------------------
awk -v fname="$(basename "$glossary")" '
	function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
	function bare(s) { gsub(/`/, "", s); return trim(s) }
	# A placeholder row is the documented skeleton (‹term›), not a real entry.
	function is_placeholder(s) { return s ~ /‹/ }
	/^[ \t]*\|/ {
		line = $0
		n = split(line, part, "|")
		ncell = 0
		for (i = 2; i < n; i++) cell[++ncell] = trim(part[i])
		if (ncell == 0) next
		sep = 1
		for (i = 1; i <= ncell; i++) if (cell[i] !~ /^:?-+:?$/) sep = 0
		if (sep) next
		if (bare(cell[1]) == "Term") next            # header row
		if (ncell != 4) {
			printf "FAIL  %s:%d: table row has %d cells, want 4 (Term | Abbr. | Description | Example)\n", fname, FNR, ncell
			ec = 1; next
		}
		term = bare(cell[1])
		if (is_placeholder(term)) next               # skeleton row, not an entry
		if (term == "") { printf "FAIL  %s:%d: empty Term cell\n", fname, FNR; ec = 1; next }
		if (term in seen) {
			printf "FAIL  %s:%d: duplicate glossary term \"%s\" (first at line %d)\n", fname, FNR, term, seen[term]
			ec = 1
		} else seen[term] = FNR
		for (i = 3; i <= 4; i++) {
			if (bare(cell[i]) == "") {
				printf "FAIL  %s:%d: term \"%s\" has an empty %s cell\n", fname, FNR, term, (i == 3 ? "Description" : "Example")
				ec = 1
			}
		}
	}
	END { exit ec ? 1 : 0 }
' "$glossary" || fail=1

# --- 2. collect the abbreviations the glossary defines ----------------------
# The Abbr. column may hold one token, several ("REQ / NFR"), or an em dash.
awk '
	function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
	/^[ \t]*\|/ {
		n = split($0, part, "|")
		if (n < 4) next
		a = part[3]; gsub(/`/, "", a)
		t = part[2]; gsub(/`/, "", t); t = trim(t)
		if (t == "Term" || t ~ /‹/) next
		gsub(/[^A-Za-z0-9]+/, " ", a)
		k = split(a, toks, " ")
		for (i = 1; i <= k; i++) if (toks[i] != "") print toupper(toks[i])
		# A term that is itself written as an abbreviation counts as defined.
		if (t ~ /^[A-Z][A-Z0-9]+$/) print toupper(t)
	}
' "$glossary" | sort -u > "$tmp/defined"

printf '%s\n' "$STOPLIST" | tr ' ' '\n' | sed '/^$/d' | tr 'a-z' 'A-Z' | sort -u > "$tmp/stop"

# --- 3. collect the abbreviations committed Markdown actually uses ----------
# Skip fenced code blocks and inline URLs: a YAML key or a path is not prose.
( cd "$scan_root" 2>/dev/null && git ls-files '*.md' 2>/dev/null ) > "$tmp/files" || :
if [ ! -s "$tmp/files" ]; then
	# Not a git checkout (or no Markdown): nothing to scan, table checks stand.
	[ "$fail" -eq 0 ] && { printf 'glossary-lint: OK\n'; exit 0; } || exit 1
fi

while IFS= read -r f; do
	[ -f "$scan_root/$f" ] || continue
	# A test fixture is an input to a linter, not documentation: its contents are
	# deliberately malformed, so scanning it for vocabulary is meaningless. The
	# README that describes a fixture set is prose, and stays in scope.
	case "$f" in
		*/tests/*README.md) : ;;
		*/tests/*)           continue ;;
	esac
	awk -v fname="$f" '
		/^[ \t]*```/ { infence = !infence; next }
		infence { next }
		{
			line = $0
			gsub(/https?:\/\/[^ )>]*/, " ", line)   # URLs are not prose
			gsub(/`[^`]*`/, " ", line)              # inline code is not prose
			while (match(line, /[A-Z][A-Z0-9]+/)) {
				tok   = substr(line, RSTART, RLENGTH)
				before = (RSTART > 1) ? substr(line, RSTART - 1, 1) : " "
				after  = substr(line, RSTART + RLENGTH, 1)
				next2  = substr(line, RSTART + RLENGTH + 1, 1)
				line   = substr(line, RSTART + RLENGTH)
				# Joined to a longer word, or hyphenated into a slug or a
				# pronunciation guide ("AR-mə-chər"): not an abbreviation in prose.
				if (before ~ /[A-Za-z0-9_-]/) continue
				if (after == "-" || after == "_") continue
				# A plural ("PRDs") still names the abbreviation; any other
				# lower-case tail means it was part of a longer word.
				if (after ~ /[a-z]/ && !(after == "s" && next2 !~ /[A-Za-z0-9]/)) continue
				printf "%s\t%s\n", tok, fname
			}
		}
	' "$scan_root/$f"
done < "$tmp/files" | sort -u > "$tmp/used"

# Rule references (R1 … R12) are pointers, not abbreviations.
cut -f1 "$tmp/used" | sort -u | grep -Ev '^R[0-9]+$' > "$tmp/used.tokens"

# Self-check: a repository of Markdown always contains some abbreviation. Zero
# means the scan broke, not that the documents are clean — fail loudly rather
# than report a green that was never earned.
if [ ! -s "$tmp/used.tokens" ]; then
	err "the abbreviation scan found no tokens at all in $(wc -l < "$tmp/files" | tr -d ' ') Markdown files — the scan is broken, not the documents"
fi

missing=$(comm -23 "$tmp/used.tokens" "$tmp/defined" | comm -23 - "$tmp/stop")
if [ -n "$missing" ]; then
	printf '%s\n' "$missing" | while IFS= read -r tok; do
		[ -z "$tok" ] && continue
		where=$(awk -F'\t' -v t="$tok" '$1 == t { print $2 }' "$tmp/used" | sort -u | head -3 | tr '\n' ' ')
		printf 'FAIL  abbreviation "%s" is used but has no glossary row (in: %s)\n' "$tok" "$where" >&2
	done
	fail=1
fi

[ "$fail" -eq 0 ] && { printf 'glossary-lint: OK\n'; exit 0; } || exit 1
