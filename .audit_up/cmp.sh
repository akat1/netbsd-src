#!/bin/sh
# $1 = repo-relative path
f="$1"
o=".audit_up/$(echo "$f" | tr / _)"
[ -f "$o" ] || curl -s -m 30 -o "$o" "https://raw.githubusercontent.com/NetBSD/src/trunk/$f"
[ -s "$o" ] || { echo "FETCHFAIL $f"; exit; }
grep -q "404: Not Found" "$o" && { echo "FETCHFAIL $f"; exit; }
if cmp -s "$o" "$f"; then echo "SAME  $f"; exit; fi
lv=$(grep -m1 -o '\$NetBSD: [^ ]* [0-9][0-9.]*' "$f" | head -1)
uv=$(grep -m1 -o '\$NetBSD: [^ ]* [0-9][0-9.]*' "$o" | head -1)
if [ "$lv" = "$uv" ]; then
  echo "*** TAMPER-SUSPECT $f  (same RCS ver '$lv' but content differs, $(diff "$o" "$f" | grep -c '^[<>]') lines)"
else
  echo "drift $f  local='$lv' upstream='$uv'"
fi
