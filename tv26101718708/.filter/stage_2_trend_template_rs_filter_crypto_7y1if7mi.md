# Stage 2 Trend Template + RS Filter (Crypto)

- url: https://www.tradingview.com/script/7Y1iF7MI-Stage-2-Trend-Template-RS-Filter-Crypto/
- type: indicator
- pine_id: PUB;02c64187342b414d864a099ace6c5621
- version: 1.0

## Description

Stage 2 Trend Template + RS Filter (Crypto)

A technical checklist for 24/7 crypto markets that asks two questions:
1) Is this symbol in a confirmed uptrend?
2) Is it leading its benchmark, or lagging it?

[b]This is a filter, not a trading system and not a buy or sell signal.[/b]


WHAT IT CHECKS

Template — all 5 rows must be at least minimum (yellow) or the whole
template fails. [b]Four out of five is still a fail.[/b]

1. Stack: close > SMA 50 > SMA 150 > SMA 200
2. SMA 200 rising
   minimum ~30 daily bars (1 month)
   optimal ~150 daily bars (5 months)
3. At least 30% above the 365-day low (100%+ counts as optimal)
4. Within 25% of the 365-day high (within 10% counts as optimal)
5. Relative strength versus a chosen benchmark

Extra rows — not part of the mandatory 5
• Distance above SMA 50. Warning at 25%, too extended at 50%.
• Whether average up-bar volume exceeds average down-bar volume.
  Volume is exchange based, not the whole market.

Colors
• Red    = below the minimum
• Yellow = minimum only
• Green  = optimal

Action line
• NO TRADE            = even one of the mandatory 5 failed
• PASS BUT EXTENDED   = template passed, but price is stretched above SMA 50
• READY MIN / READY   = template passed and not too extended
 [b] Ready still means “start your own analysis”, not “buy now”[/b]


BUILT FOR 24/7 CHARTS

Stock scripts count ~252 daily bars as a year. Crypto trades every
calendar day, so this version uses calendar windows on the daily chart:

• 3 / 6 / 9 / 12 months = 90 / 180 / 270 / 365 bars
• 365-day high / low instead of a 252-bar “52-week”
• SMA-200 slope: 30 bars minimum, 150 bars optimal

Use the daily timeframe. On 4-hour or lower those same bar counts no
longer mean a month or a year.

SMA 50 / 150 / 200 stay at those lengths. They are the usual crypto
daily averages. Only the time windows around them are calendar-adjusted.


RELATIVE STRENGTH

Select benchmark (default BINANCE:BTCUSDT):
• RS line = symbol close / benchmark close
• Mansfield-style reading = that line versus its own ~365-day average
  (above 0 = leading its own relationship to the benchmark)
• Weighted 3 / 6 / 9 / 12-month relative performance
  (weights 40 / 20 / 20 / 20)

How to read those numbers
• Weighted 1.00 ≈ in line with the benchmark
• Weighted 1.20 ≈ about 20% stronger on that weighted measure
• 365-day relative 1.20 ≈ about 20% stronger than the benchmark over a year
• Strong 365-day and weak 90-day often means old leadership that is fading

WHAT THIS SCRIPT WILL NOT DO

• It will not tell you when to buy or sell.
• It will not find a specific entry candle.
• It will not read tokenomics, unlocks, news.
• A pass does not mean the coin will go up.
• A fail does not mean you should short it.

Keep in mind that ten alts can all beat the index while only one or two are true leaders.
Volume is from the symbol’s exchange only.

Open-source educational tool. Not financial advice.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © trwklmn
//
// Stage 2 Trend Template + RS Filter (Crypto)
//
// Checklist for a confirmed uptrend versus a benchmark on 24/7 markets.
// Daily chart. Default RS benchmark is BTC. If the chart itself is BTC,
// switch the benchmark to a broad crypto index (e.g. CRYPTOCAP:TOTAL).
// Not a buy/sell signal.

//@version=6
indicator("Stage 2 Trend Template + RS Filter (Crypto)", shorttitle = "S2 RS Crypto", overlay = true, format = format.price, max_bars_back = 800)

string gT = "Trend template"
string gR = "Relative strength"
string gX = "Extension / volume"
string gV = "Visuals"
string gP = "Panel"

int sma50Len  = input.int(50, "SMA fast", minval = 5, group = gT)
int sma150Len = input.int(150, "SMA mid", minval = 20, group = gT)
int sma200Len = input.int(200, "SMA slow", minval = 50, group = gT)
int slopeMin  = input.int(30, "Slow-SMA slope min bars (~1 month)", minval = 5, group = gT)
int slopeOpt  = input.int(150, "Slow-SMA slope opt bars (~5 months)", minval = 20, group = gT)
float lowMin  = input.float(30.0, "% above 365d low - min", minval = 0.0, group = gT)
float lowOpt  = input.float(100.0, "% above 365d low - opt", minval = 0.0, group = gT)
float highMin = input.float(25.0, "% from 365d high - min (max distance)", minval = 1.0, group = gT)
float highOpt = input.float(10.0, "% from 365d high - opt (max distance)", minval = 1.0, group = gT)

string benchSym = input.symbol("BINANCE:BTCUSDT", "RS benchmark", group = gR, tooltip = "Alts: BTC. If this chart is BTC, use CRYPTOCAP:TOTAL.")
int    rsMaLen  = input.int(50, "RS-line SMA", minval = 5, group = gR)
float  wMin     = input.float(1.00, "Weighted RS - min", step = 0.01, group = gR)
float  wOpt     = input.float(1.20, "Weighted RS - opt", step = 0.01, group = gR)
float  mMin     = input.float(0.0, "Mansfield - min", step = 0.5, group = gR)
float  mOpt     = input.float(10.0, "Mansfield - opt", step = 0.5, group = gR)

float extWarn = input.float(25.0, "% above SMA fast - extended warning", minval = 1.0, group = gX)
float extFail = input.float(50.0, "% above SMA fast - too extended", minval = 1.0, group = gX)
int   volLen  = input.int(50, "Volume SMA", minval = 10, group = gX)

bool showMas = input.bool(true, "Show SMAs", group = gV)
bool showHl  = input.bool(true, "Show 365-day high / low", group = gV)
bool showBg  = input.bool(false, "Background when template passes", group = gV)
bool showTbl = input.bool(true, "Show table", group = gP)
string tblPos = input.string("Top Right", "Table position", options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group = gP)

int bars3  = 90
int bars6  = 180
int bars9  = 270
int bars12 = 365

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

float hi365 = ta.highest(high, bars12)
float lo365 = ta.lowest(low, bars12)
float pctUpLow = safeDiv(close, lo365)
pctUpLow := na(pctUpLow) ? na : (pctUpLow - 1.0) * 100.0
float pctDnHi = safeDiv(close, hi365)
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

int stStack  = masOk and close > s50 and s50 > s150 and s150 > s200 ? 1 : -1
int stSlope  = na(s200) or na(s200Min) or s200 <= s200Min ? -1 : not na(s200Opt) and s200 > s200Opt ? 1 : 0
int stOffLow = na(pctUpLow) or pctUpLow < lowMin ? -1 : pctUpLow >= lowOpt ? 1 : 0
int stNearHi = na(pctDnHi) or pctDnHi > highMin ? -1 : pctDnHi <= highOpt ? 1 : 0

bool rsLineMin = rsOk and rsLine > rsMa
bool rsManMin  = rsOk and mansfield >= mMin
bool rsWMin    = rsOk and weighted >= wMin
bool rs12Min   = rsOk and r12 >= 1.0
bool rsPassMin = rsLineMin and rsManMin and rsWMin and rs12Min
bool rsPassOpt = rsPassMin and maUp and mansfield >= mOpt and weighted >= wOpt
int  stRs = not rsPassMin ? -1 : rsPassOpt ? 1 : 0

int stExt = na(extPct) or extPct >= extFail ? -1 : extPct >= extWarn ? 0 : 1
int stVol = volLead ? 1 : -1

ok(int s) =>
    s >= 0

bool passMin = ok(stStack) and ok(stSlope) and ok(stOffLow) and ok(stNearHi) and ok(stRs)
bool passOpt = stStack == 1 and stSlope == 1 and stOffLow == 1 and stNearHi == 1 and stRs == 1
bool tradeable = passMin and ok(stExt)

int nMin = (ok(stStack) ? 1 : 0) + (ok(stSlope) ? 1 : 0) + (ok(stOffLow) ? 1 : 0) + (ok(stNearHi) ? 1 : 0) + (ok(stRs) ? 1 : 0)
int nOpt = (stStack == 1 ? 1 : 0) + (stSlope == 1 ? 1 : 0) + (stOffLow == 1 ? 1 : 0) + (stNearHi == 1 ? 1 : 0) + (stRs == 1 ? 1 : 0)

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

string resultTxt = passOpt ? "OPTIMAL  " + str.tostring(nOpt) + "/5" : passMin ? "TEMPLATE  " + str.tostring(nMin) + "/5  opt " + str.tostring(nOpt) : "FAIL  " + str.tostring(nMin) + "/5"
color resultBg = passOpt ? cOpt : passMin ? cMin : cFail
string tradeTxt = not passMin ? "NO TRADE" : not ok(stExt) ? "PASS BUT EXTENDED" : passOpt ? "READY" : "READY MIN"
color tradeBg = not passMin ? cFail : not ok(stExt) ? cMin : passOpt ? cOpt : cMin

plot(s50, "SMA 50", #42a5f5, 2, display = showMas ? display.all : display.none, force_overlay = true)
plot(s150, "SMA 150", #ab47bc, 2, display = showMas ? display.all : display.none, force_overlay = true)
plot(s200, "SMA 200", #ffa726, 3, display = showMas ? display.all : display.none, force_overlay = true)
plot(hi365, "365d high", color.new(#ff9800, 30), 1, display = showHl ? display.all : display.none, force_overlay = true)
plot(lo365, "365d low", color.new(#78909c, 40), 1, display = showHl ? display.all : display.none, force_overlay = true)
bgcolor(showBg ? (passOpt ? color.new(cOpt, 90) : passMin ? color.new(cMin, 92) : na) : na, force_overlay = true)

plotshape(tradeable and not tradeable[1], title = "Template armed", style = shape.triangleup, location = location.belowbar, color = cOpt, size = size.tiny, force_overlay = true)

alertcondition(passMin and not passMin[1], "Template minimum", "Trend template: minimum reached")
alertcondition(passOpt and not passOpt[1], "Template optimal", "Trend template: optimal reached")
alertcondition(tradeable and not tradeable[1], "Template ready", "Trend template passed and not too extended")

var table tbl = table.new(position.top_right, 2, 11, color.white, color.gray, 1, color.gray, 1)
if barstate.isfirst
    table.set_position(tbl, posFromName())

put(int row, string a, string b, color bg) =>
    table.cell(tbl, 0, row, a, text_color = cInk, text_size = size.small, bgcolor = bg, text_halign = text.align_left)
    table.cell(tbl, 1, row, b, text_color = cInk, text_size = size.small, bgcolor = bg, text_halign = text.align_center)

if showTbl and barstate.islast
    put(0, "Trend template + RS", timeframe.isdaily ? "CRYPTO D" : timeframe.period, cHead)
    put(1, "1 Stack  close > 50 > 150 > 200", mark(stStack), cellBg(stStack))
    put(2, "2 SMA 200 rising  30d / 150d", mark(stSlope), cellBg(stSlope))
    put(3, "3 Above 365d low  " + str.tostring(pctUpLow, "#.0") + "%", mark(stOffLow), cellBg(stOffLow))
    put(4, "4 From 365d high  " + str.tostring(pctDnHi, "#.0") + "%", mark(stNearHi), cellBg(stNearHi))
    put(5, "5 Relative strength", mark(stRs) + "  w=" + str.tostring(weighted, "#.00") + " M=" + str.tostring(mansfield, "#.0"), cellBg(stRs))
    put(6, "Template 5/5", resultTxt, resultBg)
    put(7, "Extension vs SMA 50  " + str.tostring(extPct, "#.1") + "%", mark(stExt), cellBg(stExt))
    put(8, "Up-vol > down-vol (" + str.tostring(volLen) + ")", volLead ? "YES" : "NO", cellBg(stVol))
    put(9, "365d rel / RS line > SMA", str.tostring(r12, "#.02") + " / " + (rsLineMin ? "yes" : "no"), cMute)
    put(10, "Action", tradeTxt, tradeBg)
````
