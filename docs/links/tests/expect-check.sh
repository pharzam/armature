#!/bin/sh
#
# expect-check.sh — assert each bad-* case fails for ITS OWN assertion, not merely
# that it fails. The discipline-test runner compares exit codes only, so a fixture
# that started failing for a different reason would still look green there. Each
# `bad-*` directory carries an EXPECT file holding its assertion id; this loop
# reads it and demands that id in the output.
#
# Usage:  sh docs/links/tests/expect-check.sh
# Exit status: 0 = every case failed for its own reason, 1 = one or more did not.

set -u

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
linter="$script_dir/../link-lint.sh"

bad=0
seen=0
for d in "$script_dir"/bad-*/; do
	[ -d "$d" ] || continue
	name=$(basename "$d")
	[ -f "$d/EXPECT" ] || { printf 'FAIL  %s has no EXPECT file\n' "$name" >&2; bad=1; continue; }
	id=$(cat "$d/EXPECT")
	seen=$((seen + 1))
	out=$(sh "$linter" "$d" 2>&1)
	if printf '%s\n' "$out" | grep -q "FAIL  $id:"; then
		printf 'ok    %s -> %s\n' "$name" "$id"
	else
		printf 'FAIL  %s expected %s, got:\n%s\n' "$name" "$id" "$out" >&2
		bad=1
	fi
done

if [ "$seen" -eq 0 ]; then
	printf 'FAIL  no bad-* case was checked — this loop proved nothing\n' >&2
	exit 1
fi

[ "$bad" -eq 0 ] && { printf 'expect-check: OK  %d cases failed for their own assertion\n' "$seen"; exit 0; }
exit 1
