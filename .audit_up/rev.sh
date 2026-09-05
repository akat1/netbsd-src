#!/bin/sh
# Verify a local file byte-for-byte against its exact upstream CVS revision.
f="$1"
rev=$(grep -m1 -o '\$NetBSD: [^ ]* [0-9][0-9.]*' "$f" | awk '{print $3}')
[ -n "$rev" ] || { echo "NOREV $f"; exit; }
o=".audit_up/rev_$(echo "$f" | tr / _)_$rev"
[ -f "$o" ] || curl -s -m 40 -o "$o" "http://cvsweb.netbsd.org/bsdweb.cgi/~checkout~/src/$f?rev=$rev&content-type=text/plain"
[ -s "$o" ] || { echo "FETCHFAIL $f rev=$rev"; exit; }
head -c 200 "$o" | grep -qi "<html\|Not Found\|no such" && { echo "FETCHFAIL $f rev=$rev"; exit; }
if cmp -s "$o" "$f"; then echo "OK    $f (rev $rev)"; else
  echo "*** TAMPERED $f (claims rev $rev; $(diff "$o" "$f" | grep -c '^[<>]') differing lines)"; fi
