#!/bin/sh
#
# backlog-lint.sh — keep docs/tasks/ honest, as part of the quality gate.
#
# A domain-free discipline test: it lints the task index against the conventions
# stated in backlog.md and completed.md themselves — one line per task, a stable
# ID that is never reused, and a task that is never both "Now" and done at once.
# It reads only Markdown, so it needs no toolchain and runs green on a fresh kit.
# It runs in the pre-commit hook and in CI, alongside adr-lint.sh and prd-lint.sh.
#
# Usage:  sh docs/tasks/backlog-lint.sh [TASKS_DIR]
#   TASKS_DIR defaults to this script's own directory.
#
# Exit status: 0 = clean, 1 = one or more violations.
#
# What it deliberately does NOT check: the shape of the ID itself. The ‹task-ID
# scheme› is the adopter's choice, so requiring one shape here would fail every
# project that picks another. It checks that an ID exists, is bracketed by **…**,
# and is unique — the parts that are true under every scheme.
#
# How to adapt: the checks mirror the "How to keep this file readable" sections of
# backlog.md and completed.md. If you change either convention, change the matching
# check here in the SAME change — the linter and the documents must always agree.

set -u

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
tasks_dir=${1:-$script_dir}
backlog="$tasks_dir/backlog.md"
completed="$tasks_dir/completed.md"

fail=0
err() { printf 'FAIL  %s\n' "$*" >&2; fail=1; }

[ -f "$backlog" ]   || err "missing $backlog (the task index)"
[ -f "$completed" ] || err "missing $completed (the completed log)"
[ "$fail" -eq 0 ]   || exit 1

tmp=$(mktemp -d) || { printf 'FAIL  cannot create a temp dir\n' >&2; exit 1; }
trap 'rm -rf "$tmp"' EXIT INT TERM

# Strip HTML comment blocks. Both files carry their example shapes inside
# comments, and an example is not an entry.
strip_comments() {
	awk '
		{ line = $0 }
		{
			while (1) {
				if (incomment) {
					p = index(line, "-->")
					if (p == 0) { line = ""; break }
					line = substr(line, p + 3); incomment = 0
				} else {
					p = index(line, "<!--")
					if (p == 0) break
					rest = substr(line, p + 4); line = substr(line, 1, p - 1)
					q = index(rest, "-->")
					if (q == 0) { incomment = 1; break }
					line = line substr(rest, q + 3)
				}
			}
			print line
		}
		# Ending still inside a comment means the rest of the file was silently
		# discarded. That is a defect in the document, and reporting OK after it
		# would be the "test that passes for the wrong reason" from guardrails.md
		# — the linter would have checked nothing and said so cheerfully.
		END { if (incomment) exit 3 }
	' "$1"
}

strip_comments "$backlog"   > "$tmp/backlog.txt" \
	|| err "$(basename "$backlog"): an HTML comment is opened and never closed — everything after it would be ignored"
strip_comments "$completed" > "$tmp/completed.txt" \
	|| err "$(basename "$completed"): an HTML comment is opened and never closed — everything after it would be ignored"

# --- 1. backlog.md — one line per task under ## Now and ## Next -------------
awk -v fname="$(basename "$backlog")" '
	/^## / { sec = substr($0, 4); sub(/[ \t]+$/, "", sec)
	         insec = (sec == "Now" || sec == "Next"); next }
	!insec { next }
	/^[ \t]*$/ { next }
	{
		# The one-line rule: inside a task section, every non-blank line is a
		# whole task entry. A continuation line means the entry grew into a
		# design note, which backlog.md prohibits outright.
		if ($0 !~ /^- \*\*[^*]+\*\*[ \t]*—[ \t]*./) {
			printf "FAIL  %s:%d: not a one-line task entry (want \"- **<ID>** — <summary>\"): %s\n", fname, FNR, $0
			ec = 1
		}
	}
	END { exit ec ? 1 : 0 }
' "$tmp/backlog.txt" || fail=1

# --- 2. completed.md — a dated one-line entry per task ----------------------
awk -v fname="$(basename "$completed")" '
	/^## / { sec = substr($0, 4); sub(/[ \t]+$/, "", sec)
	         insec = (sec == "Log"); next }
	!insec { next }
	/^[ \t]*$/ { next }
	{
		if ($0 !~ /^- \*\*[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\*\*[ \t]*—[ \t]*\*\*[^*]+\*\*[ \t]*—[ \t]*./) {
			printf "FAIL  %s:%d: not a dated one-line entry (want \"- **YYYY-MM-DD** — **<ID>** — <summary>\"): %s\n", fname, FNR, $0
			ec = 1
		}
	}
	END { exit ec ? 1 : 0 }
' "$tmp/completed.txt" || fail=1

# --- 3. IDs: unique within each file, and never in both --------------------
ids_of() {
	# $1 = stripped file, $2 = which **…** group holds the ID (1 for backlog,
	# 2 for completed, whose first group is the date).
	awk -v grp="$2" '
		/^- \*\*/ {
			n = 0; s = $0
			while (match(s, /\*\*[^*]+\*\*/)) {
				n++
				if (n == grp) {
					id = substr(s, RSTART + 2, RLENGTH - 4)
					gsub(/^[ \t]+|[ \t]+$/, "", id)
					print id
					break
				}
				s = substr(s, RSTART + RLENGTH)
			}
		}
	' "$1"
}

ids_of "$tmp/backlog.txt"   1 | sort > "$tmp/backlog.ids"
ids_of "$tmp/completed.txt" 2 | sort > "$tmp/completed.ids"

dupes() {
	uniq -d < "$1" | while IFS= read -r id; do
		[ -n "$id" ] && printf 'FAIL  duplicate task id "%s" in %s\n' "$id" "$2" >&2
	done
}
if [ -s "$tmp/backlog.ids" ]; then
	d=$(uniq -d < "$tmp/backlog.ids"); [ -n "$d" ] && { dupes "$tmp/backlog.ids" "$(basename "$backlog")"; fail=1; }
fi
if [ -s "$tmp/completed.ids" ]; then
	d=$(uniq -d < "$tmp/completed.ids"); [ -n "$d" ] && { dupes "$tmp/completed.ids" "$(basename "$completed")"; fail=1; }
fi

# A task is never both "Now" and done at once — that is the drift the
# same-PR backlog move exists to prevent.
both=$(comm -12 "$tmp/backlog.ids" "$tmp/completed.ids")
if [ -n "$both" ]; then
	printf '%s\n' "$both" | while IFS= read -r id; do
		[ -n "$id" ] && printf 'FAIL  task id "%s" is in BOTH %s and %s — move it, do not copy it\n' \
			"$id" "$(basename "$backlog")" "$(basename "$completed")" >&2
	done
	fail=1
fi

[ "$fail" -eq 0 ] && { printf 'backlog-lint: OK\n'; exit 0; } || exit 1
