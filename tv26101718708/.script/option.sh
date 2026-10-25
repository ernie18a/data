#!/usr/bin/env bash
# 篩出代碼區用到 taifex.option 對應概念（OI、P/C、COT、VIX、SKEW、GEX、OPEX、Black-Scholes）且接到訊號的腳本，及 OI 四象限，複製到 .option/
cd "$(dirname "$0")/.." || exit 1
OUT=.option; mkdir -p "$OUT"
code(){ awk '/^## Source/{s=1} s' "$1"; }
declare -A P=(
[oi]='_OI\b|open_?interest|openInterest'
[pcr]='PCCE|USI:PCC|\bPCC\b|PCSPX|PCSP|put_?call|putCall'
[cot]='LibraryCOT|COT[0-9]?:|CFTC|request\.cot|\bcot_'
[vix]='VIX9D|VIX3M|VVIX|CBOE:VIX|TVC:VIX|"VIX"'
[skew]='CBOE:SKEW|"SKEW"'
[gex]='\bgex\b|gamma_?exp|callWall|putWall|call_wall|put_wall|max_?pain|maxPain'
[opex]='opex|OPEX|thirdFriday|third_friday|expiry_?day|expirationDay'
[bs]='black_?scholes|blackScholes|impliedVol|implied_vol|\bnormCdf|\bcdf\('
)
SIG='strategy\.entry|plotshape|alertcondition|bgcolor|barcolor'
for k in "${!P[@]}"; do
  for f in $(grep -l -E "${P[$k]}" *.md); do
    code "$f" | grep -qE "${P[$k]}" && code "$f" | grep -qE "$SIG" && echo "$f"
  done | sort > "$OUT/_$k.txt"
done
grep -l -iE 'long ?build-?up|short ?covering|long ?unwinding|short ?build-?up' *.md | sort > "$OUT/_buildup.txt"
sort -u "$OUT"/_*.txt | xargs cp -t "$OUT/"
