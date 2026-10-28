# Stage 2 Trend Template + RS Filter

- url: https://www.tradingview.com/script/pvbrC3gx-Stage-2-Trend-Template-RS-Filter/
- type: indicator
- pine_id: PUB;0cf162af54e549af895f0f8c248b77fd
- version: 1.0

## Description

Stage 2 Trend Template + Relative Strength Filter

A technical checklist that asks two questions:
1) Is this symbol in a confirmed uptrend?
2) Is it leading its benchmark, or lagging it?

[b]This is a filter, not a trading system and not a buy or sell signal.[/b]


WHAT IT CHECKS

Template — all 8 rows must be at least minimum (yellow) or the whole
template fails. [b]Seven out of eight is still a fail.[/b]

1. Price above SMA 150 and SMA 200
2. SMA 150 above SMA 200
3. SMA 200 rising (minimum ~1 month, optimal ~5 months)
4. SMA 50 above SMA 150 and SMA 200
5. Price above SMA 50
6. At least 30% above the 52-week low (100%+ counts as optimal)
7. Within 25% of the 52-week high (within 10% counts as optimal)
8. Relative strength versus a chosen benchmark

Extra rows — not part of the mandatory 8
• Distance above SMA 50. Names that already ran far above the 50-day
  are considered riskier new entries even when the template passes.
• Whether average up-bar volume exceeds average down-bar volume.
  A coarse accumulation hint, not proof of institutional buying.

Colors
• Red    = below the minimum
• Yellow = minimum only
• Green  = optimal

Action line
• NO TRADE            = even one of the mandatory 8 failed
• PASS BUT EXTENDED   = template with mandatory 8 passed, but price is stretched above SMA 50
• READY MIN / READY   = template passed and not too extended
  [b]Ready still means “start your own analysis”, not “buy now”.[/b]


RELATIVE STRENGTH — WHAT THIS SCRIPT DOES AND DOES NOT DO

[b]It does NOT calculate a 1–99 percentile RS rating.[/b]

A 1–99 rating is a rank against a full stock universe on that day.
Example: 90 means the name beat 90% of the stocks in that universe.
A Pine script on a single chart cannot see thousands of other tickers,
so it cannot produce that rank.

What you get instead, all versus the selected benchmark (default SPY):
• RS line = symbol close / benchmark close
• Mansfield-style reading = that line versus its own ~12-month average
  (above 0 = leading its own relationship to the index)
• Weighted 3 / 6 / 9 / 12-month relative performance
  (weights 40 / 20 / 20 / 20)

How to read those numbers
• Weighted 1.00 ≈ in line with the benchmark
• Weighted 1.20 ≈ about 20% stronger on that weighted measure
• 12-month relative 1.20 ≈ about 20% stronger than the benchmark over a year
• Strong 12-month and weak 3-month often means old leadership that is fading

Optional 1–99 field
Settings → Relative strength → “Use published 1-99 RS rating”.

[b]Leave this OFF unless you already have a real 1–99 number from somewhere
else [/b] (for example a universe ranking list or a dedicated RS-rating script
that maps against a stock universe). Type that number into
“Published RS rating”. This script does not invent it.

If the option is off, row 8 uses only the benchmark-relative measures
above. That is the default and the intended daily use.

Change the benchmark for a different market (for crypto, use BTC or a broad crypto index, not SPY). This script’s 3/6/9/12-month and 52-week windows are fixed at 63/126/189/252 daily bars, which matches a stock trading year. On 24/7 markets those same bar counts cover less calendar time.


LIMITATIONS

Relative strength here is versus one benchmark, not versus every stock.
Ten names can all beat SPY while only one or two of them are true market leaders.

52-week high/low use 252 bars. That is close to a trading year on a
daily chart but it is not calendar-perfect around holidays.

Volume comparison is a coarse hint.

Open-source educational tool. Not financial advice.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// ©trwklmn
//
// Stage 2 Trend Template + Relative Strength Filter
//
// Technical checklist for a confirmed uptrend versus a benchmark.
// Does not score fundamentals, news catalysts, or a specific entry pattern.
// Does not compute a 1-99 percentile rating against a stock universe.
// RED = below minimum | YELLOW = minimum | GREEN = optimal
// Use on the daily chart. Change the benchmark for non-US symbols.

//@version=6
indicator("Stage 2 Trend Template + RS Filter", shorttitle = "S2 RS Filter", overlay = true, max_bars_back = 500)

string gT = "Trend template"
string gR = "Relative strength"
string gX = "Extension / volume"
string gV = "Visuals"
string gP = "Panel"

int sma50Len  = input.int(50, "SMA 50", minval = 5, group = gT)
int sma150Len = input.int(150, "SMA 150", minval = 20, group = gT)
int sma200Len = input.int(200, "SMA 200", minval = 50, group = gT)
int slopeMin  = input.int(22, "200-SMA slope min bars (~1 month)", minval = 5, group = gT)
int slopeOpt  = input.int(105, "200-SMA slope opt bars (~5 months)", minval = 20, group = gT)
float lowMin  = input.float(30.0, "% above 52w low - min", minval = 0.0, group = gT)
float lowOpt  = input.float(100.0, "% above 52w low - opt", minval = 0.0, group = gT)
float highMin = input.float(25.0, "% from 52w high - min (max distance)", minval = 1.0, group = gT)
float highOpt = input.float(10.0, "% from 52w high - opt (max distance)", minval = 1.0, group = gT)

string benchSym = input.symbol("SPY", "RS benchmark", group = gR)
int    rsMaLen  = input.int(50, "RS-line SMA", minval = 5, group = gR)
float  wMin     = input.float(1.00, "Weighted RS - min", step = 0.01, group = gR)
float  wOpt     = input.float(1.20, "Weighted RS - opt", step = 0.01, group = gR)
float  mMin     = input.float(0.0, "Mansfield - min", step = 0.5, group = gR)
float  mOpt     = input.float(10.0, "Mansfield - opt", step = 0.5, group = gR)
bool   usePubRs = input.bool(false, "Use published 1-99 RS rating", group = gR)
int    pubRs    = input.int(70, "Published RS rating", minval = 1, maxval = 99, group = gR)
int    pubMin   = input.int(70, "Published RS min", minval = 1, maxval = 99, group = gR)
int    pubOpt   = input.int(80, "Published RS opt", minval = 1, maxval = 99, group = gR)

float extWarn = input.float(15.0, "% above SMA 50 - extended warning", minval = 1.0, group = gX)
float extFail = input.float(25.0, "% above SMA 50 - too extended", minval = 1.0, group = gX)
int   volLen  = input.int(50, "Volume SMA", minval = 10, group = gX)

bool showMas = input.bool(true, "Show SMAs", group = gV)
bool showHl  = input.bool(true, "Show 52-week high / low", group = gV)
bool showBg  = input.bool(false, "Background when template passes", group = gV)
bool showTbl = input.bool(true, "Show table", group = gP)
string tblPos = input.string("Top Right", "Table position", options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group = gP)

int bars3  = 63
int bars6  = 126
int bars9  = 189
int bars12 = 252

safeDiv(float num, float den) =>
    float out = na
    if not na(num) and not na(den) and den != 0.0
        out := num / den
    out

posFromName() =>
    switch tblPos
        "Top Left" => position.top_left
        "Bottom Left" => position.bottom_left
        "Bottom Right" => position.bottom_right
        => position.top_right

float s50  = ta.sma(close, sma50Len)
float s150 = ta.sma(close, sma150Len)
float s200 = ta.sma(close, sma200Len)
float s200Min = s200[slopeMin]
float s200Opt = s200[slopeOpt]

float hi52 = ta.highest(high, bars12)
float lo52 = ta.lowest(low, bars12)
float pctUpLow = safeDiv(close, lo52)
pctUpLow := na(pctUpLow) ? na : (pctUpLow - 1.0) * 100.0
float pctDnHi = safeDiv(close, hi52)
pctDnHi := na(pctDnHi) ? na : (1.0 - pctDnHi) * 100.0

float bench = request.security(benchSym, timeframe.period, close, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
float rsLine = safeDiv(close, bench)
float rsMa = ta.sma(rsLine, rsMaLen)
float st3 = safeDiv(close, close[bars3])
float st6 = safeDiv(close, close[bars6])
float st9 = safeDiv(close, close[bars9])
float st12 = safeDiv(close, close[bars12])
float bn3 = safeDiv(bench, bench[bars3])
float bn6 = safeDiv(bench, bench[bars6])
float bn9 = safeDiv(bench, bench[bars9])
float bn12 = safeDiv(bench, bench[bars12])
float r3 = safeDiv(st3, bn3)
float r6 = safeDiv(st6, bn6)
float r9 = safeDiv(st9, bn9)
float r12 = safeDiv(st12, bn12)
float weighted = 0.4 * nz(r3, 0.0) + 0.2 * nz(r6, 0.0) + 0.2 * nz(r9, 0.0) + 0.2 * nz(r12, 0.0)
float rsYearMa = ta.sma(rsLine, bars12)
float mansRaw = safeDiv(rsLine, rsYearMa)
float mansfield = na(mansRaw) ? na : (mansRaw - 1.0) * 100.0

float extPct = safeDiv(close, s50)
extPct := na(extPct) ? na : (extPct - 1.0) * 100.0
float upVol = close >= open ? volume : 0.0
float dnVol = close < open ? volume : 0.0
float upVolAvg = ta.sma(upVol, volLen)
float dnVolAvg = ta.sma(dnVol, volLen)
bool volLead = not na(upVolAvg) and not na(dnVolAvg) and upVolAvg > dnVolAvg

bool masOk = not na(s50) and not na(s150) and not na(s200)
bool rsOk = not na(rsLine) and not na(rsMa) and not na(weighted) and not na(mansfield) and not na(r12)
bool maUp = rsOk and not na(rsMa[1]) and rsMa > rsMa[1]

int stPxSlow = masOk and close > s150 and close > s200 ? 1 : -1
int st150200 = masOk and s150 > s200 ? 1 : -1
int stSlope  = na(s200) or na(s200Min) or s200 <= s200Min ? -1 : not na(s200Opt) and s200 > s200Opt ? 1 : 0
int stStack  = masOk and s50 > s150 and s50 > s200 ? 1 : -1
int stPx50   = masOk and close > s50 ? 1 : -1
int stOffLow = na(pctUpLow) or pctUpLow < lowMin ? -1 : pctUpLow >= lowOpt ? 1 : 0
int stNearHi = na(pctDnHi) or pctDnHi > highMin ? -1 : pctDnHi <= highOpt ? 1 : 0

bool rsLineMin = rsOk and rsLine > rsMa
bool rsManMin  = rsOk and mansfield >= mMin
bool rsWMin    = rsOk and weighted >= wMin
bool rs12Min   = rsOk and r12 >= 1.0
bool rsPubMin  = not usePubRs or pubRs >= pubMin
bool rsPassMin = rsLineMin and rsManMin and rsWMin and rs12Min and rsPubMin
bool rsPassOpt = rsPassMin and maUp and mansfield >= mOpt and weighted >= wOpt and (not usePubRs or pubRs >= pubOpt)
int  stRs = not rsPassMin ? -1 : rsPassOpt ? 1 : 0

int stExt = na(extPct) or extPct >= extFail ? -1 : extPct >= extWarn ? 0 : 1
int stVol = volLead ? 1 : -1

ok(int s) =>
    s >= 0

bool passMin = ok(stPxSlow) and ok(st150200) and ok(stSlope) and ok(stStack) and ok(stPx50) and ok(stOffLow) and ok(stNearHi) and ok(stRs)
bool passOpt = stPxSlow == 1 and st150200 == 1 and stSlope == 1 and stStack == 1 and stPx50 == 1 and stOffLow == 1 and stNearHi == 1 and stRs == 1
bool tradeable = passMin and ok(stExt)

int nMin = (ok(stPxSlow) ? 1 : 0) + (ok(st150200) ? 1 : 0) + (ok(stSlope) ? 1 : 0) + (ok(stStack) ? 1 : 0) + (ok(stPx50) ? 1 : 0) + (ok(stOffLow) ? 1 : 0) + (ok(stNearHi) ? 1 : 0) + (ok(stRs) ? 1 : 0)
int nOpt = (stPxSlow == 1 ? 1 : 0) + (st150200 == 1 ? 1 : 0) + (stSlope == 1 ? 1 : 0) + (stStack == 1 ? 1 : 0) + (stPx50 == 1 ? 1 : 0) + (stOffLow == 1 ? 1 : 0) + (stNearHi == 1 ? 1 : 0) + (stRs == 1 ? 1 : 0)

color cFail = #ef5350
color cMin  = #ffee58
color cOpt  = #66bb6a
color cHead = #26c6da
color cInk  = #000000
color cMute = #eceff1
cellBg(int s) =>
    s == 1 ? cOpt : s == 0 ? cMin : cFail
mark(int s) =>
    s == 1 ? "OPT" : s == 0 ? "MIN" : "NO"

string resultTxt = passOpt ? "OPTIMAL  " + str.tostring(nOpt) + "/8" : passMin ? "TEMPLATE  " + str.tostring(nMin) + "/8  opt " + str.tostring(nOpt) : "FAIL  " + str.tostring(nMin) + "/8"
color resultBg = passOpt ? cOpt : passMin ? cMin : cFail
string tradeTxt = not passMin ? "NO TRADE" : not ok(stExt) ? "PASS BUT EXTENDED" : passOpt ? "READY" : "READY MIN"
color tradeBg = not passMin ? cFail : not ok(stExt) ? cMin : passOpt ? cOpt : cMin

plot(showMas ? s50 : na, "SMA 50", #42a5f5, 1)
plot(showMas ? s150 : na, "SMA 150", #ab47bc, 1)
plot(showMas ? s200 : na, "SMA 200", #ffa726, 2)
plot(showHl ? hi52 : na, "52w high", color.new(#ff9800, 30), 1)
plot(showHl ? lo52 : na, "52w low", color.new(#78909c, 40), 1)
bgcolor(showBg ? (passOpt ? color.new(cOpt, 90) : passMin ? color.new(cMin, 92) : na) : na)

plotshape(tradeable and not tradeable[1], "Template armed", shape.triangleup, location.belowbar, cOpt, size = size.tiny)

alertcondition(passMin and not passMin[1], "Template minimum", "Trend template: minimum reached")
alertcondition(passOpt and not passOpt[1], "Template optimal", "Trend template: optimal reached")
alertcondition(tradeable and not tradeable[1], "Template ready", "Trend template passed and not too extended")

var table tbl = table.new(position.top_right, 2, 14, color.white, color.gray, 1, color.gray, 1)
if barstate.isfirst
    table.set_position(tbl, posFromName())

put(int row, string a, string b, color bg) =>
    table.cell(tbl, 0, row, a, text_color = cInk, text_size = size.small, bgcolor = bg, text_halign = text.align_left)
    table.cell(tbl, 1, row, b, text_color = cInk, text_size = size.small, bgcolor = bg, text_halign = text.align_center)

if showTbl and barstate.islast
    put(0, "Trend template + RS", timeframe.isdaily ? "DAILY" : timeframe.period, cHead)
    put(1, "1 Price > SMA 150 & 200", mark(stPxSlow), cellBg(stPxSlow))
    put(2, "2 SMA 150 > SMA 200", mark(st150200), cellBg(st150200))
    put(3, "3 SMA 200 rising  1m / 5m", mark(stSlope), cellBg(stSlope))
    put(4, "4 SMA 50 > 150 & 200", mark(stStack), cellBg(stStack))
    put(5, "5 Price > SMA 50", mark(stPx50), cellBg(stPx50))
    put(6, "6 Above 52w low  " + str.tostring(pctUpLow, "#.0") + "%", mark(stOffLow), cellBg(stOffLow))
    put(7, "7 From 52w high  " + str.tostring(pctDnHi, "#.0") + "%", mark(stNearHi), cellBg(stNearHi))
    put(8, "8 Relative strength", mark(stRs) + "  w=" + str.tostring(weighted, "#.00") + " M=" + str.tostring(mansfield, "#.0"), cellBg(stRs))
    put(9, "Template 8/8", resultTxt, resultBg)
    put(10, "Extension vs SMA 50  " + str.tostring(extPct, "#.1") + "%", mark(stExt), cellBg(stExt))
    put(11, "Up-vol > down-vol (" + str.tostring(volLen) + ")", volLead ? "YES" : "NO", cellBg(stVol))
    put(12, "12m rel / RS line > SMA", str.tostring(r12, "#.02") + " / " + (rsLineMin ? "yes" : "no"), cMute)
    put(13, "Action", tradeTxt, tradeBg)
````
