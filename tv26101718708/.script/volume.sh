#!/usr/bin/env bash
# 篩出代碼區用到 volume 比較或 amount（價格×成交量）概念的 strategy，複製到 .volume/
cd "$(dirname "$0")/.." || exit 1
OUT=.volume; mkdir -p "$OUT"
code(){ awk '/^## Source/{s=1} s' "$1"; }

VP='\bvolume\b'
for f in $(grep -l -E "$VP" *.md); do
  code "$f" | grep -qE '\bvolume\b.*(>|<|crossover|crossunder)|(>|<).*\bvolume\b' && echo "$f"
done | xargs grep -l -E '^- type: strategy' | sort > "$OUT/_volume.txt"

AP='close *\* *volume|volume *\* *close|hlc3 *\* *volume|volume *\* *hlc3|src *\* *volume|volume *\* *src|dollar.?vol|成交額|成交金額'
for f in $(grep -l -iE "$AP" *.md); do
  code "$f" | grep -qiE "$AP" && echo "$f"
done | xargs grep -l -E '^- type: strategy' | sort > "$OUT/_amount.txt"

sort -u "$OUT/_volume.txt" "$OUT/_amount.txt" | xargs cp -t "$OUT/"
