#!/bin/bash
# Safe text fetch: https only, 5MB cap, html/pdf/text only, never executed.
url="$1"; out="$2"
case "$url" in https://*) ;; *) echo "REFUSED non-https: $url"; exit 1;; esac
ct=$(curl -sSL --proto '=https' --max-time 25 --max-filesize 5000000 -A "Mozilla/5.0" -o "$out.raw" -w "%{content_type}" "$url") || { echo "FAIL $url"; rm -f "$out.raw"; exit 1; }
case "$ct" in
  text/html*|text/plain*) python3 -c "
import sys,html,re
s=open(sys.argv[1],encoding='utf-8',errors='replace').read()
s=re.sub(r'(?is)<(script|style|noscript|svg).*?</\1>',' ',s)
s=re.sub(r'(?s)<[^>]+>',' ',s); s=html.unescape(s); s=re.sub(r'[ \t\r]+',' ',s); s=re.sub(r'\n\s*\n+','\n',s)
open(sys.argv[2],'w').write(s)" "$out.raw" "$out.txt";;
  application/pdf*) python3 -c "
import sys,pypdf
r=pypdf.PdfReader(sys.argv[1]); open(sys.argv[2],'w').write('\n'.join((pg.extract_text() or '') for pg in r.pages))" "$out.raw" "$out.txt";;
  *) echo "REFUSED content-type $ct for $url"; rm -f "$out.raw"; exit 1;;
esac
[ -s "$out.txt" ] || { echo "EMPTY $url"; rm -f "$out.raw"; exit 1; }
rm -f "$out.raw"; echo "OK $ct $(wc -c <"$out.txt") bytes -> $out.txt"
