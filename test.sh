#!/usr/bin/env bash
# Quick regression suite. Runs every test/*.sh script.
set -u

cd "$(dirname "$0")"

fail=0
for t in test/*.sh; do
	[[ -e "$t" ]] || continue
	echo "=== $t ==="
	if bash "$t"; then
		echo
	else
		echo "!!! $t FAILED"
		echo
		fail=1
	fi
done

exit $fail
