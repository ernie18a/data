<!-- tradingview-pine-id: PUB;6af3d06b08874e149c5ffe01750c7755 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Alpha MTF Trend Matrix [identityKa]

Source: https://www.tradingview.com/script/8UNfX8v0/

## Description

Alpha MTF Trend Matrix [identityKa]

Trend direction, strength and stretch across six timeframes, in one small table.

Most traders check higher timeframes by flipping charts back and forth. This tool puts them side by side and adds a single alignment reading, so you can see in a second whether the timeframes agree or fight each other.

HOW IT WORKS

Every timeframe is scored with the same three checks, each worth +1 (up), -1 (down) or 0:

1. Fast EMA versus slow EMA (default 20 and 50)
2. Close versus slow EMA
3. Slope of the slow EMA (rising or falling over the last few bars)

The sum is the timeframe's "Votes", from -3 to +3. +3 is labeled Strong Up, +1 and +2 Up, -1 and -2 Down, -3 Strong Down. A vote system was chosen over a single crossover because it separates a clean, agreed trend (all three checks agree) from a mixed or transitioning one.

Two extra columns give context for each row:
- ER: Efficiency Ratio, from 0 (choppy, going nowhere) to 1 (straight-line movement). It shows how clean the movement is, not just its direction.
- Dist (ATR): how far the close is from the slow EMA, measured in ATR. It shows how stretched the timeframe is.

ALIGNMENT

The last row combines all active timeframes into one number: the net share of timeframes pointing up minus down, from -100% to +100%. At or above the chosen threshold (default 70%) it reads Aligned Up, at or below the negative threshold it reads Aligned Down, otherwise Mixed. The counts of Up, Down and Neutral timeframes are shown next to it.

NO-REPAINT BY DEFAULT

Higher-timeframe rows use the last CLOSED bar of that timeframe, so they do not change after the fact and do not look ahead. You can switch this off to see the developing bar, but rows may then change until that bar closes. The chart's own row is always live.

WHAT YOU SEE

- A dashboard with six configurable timeframes plus your current chart timeframe
- Color-coded Trend cells, Votes, ER, and distance from the slow EMA
- One alignment row summarizing all timeframes

HOW TO USE IT

- Use it as a context filter: a setup that agrees with the higher timeframes is in a different environment from one fighting them.
- Watch the ER column. A timeframe that is Up but has a low ER is trending weakly.
- Watch Dist (ATR). A large positive or negative distance means that timeframe is already stretched from its slow average.
- Alignment is a description of agreement, not a prediction.

SETTINGS

- Calculation: fast and slow EMA length, slope lookback, ER length, confirmed-bars mode
- Timeframes: switch each of six rows on or off and pick any timeframe
- Alignment Rules: threshold for Aligned
- Display / Dashboard: colors, position, text size, footer

Timeframes lower than your chart timeframe are shown as n/a.

ALERTS

Timeframes aligned up, aligned down, alignment lost, alignment changed. For stable triggers, set the alert to Once Per Bar Close.

NOTES AND LIMITATIONS

- EMA-based trend measures lag by nature.
- In confirmed mode, higher-timeframe rows reflect the last closed bar, so they react one bar of that timeframe later. That is the price of not repainting.
- Only timeframes equal to or higher than the chart timeframe are supported.

This script is for educational and informational purposes only and is not financial advice. Past behavior does not guarantee future results.

Part of the Alpha Quant Toolkit by identityKa. See also: Alpha Regime Dashboard [identityKa], Alpha Adaptive Supertrend [identityKa].

---

## Source Code

````pine
// This Source Code Form is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © IdentityKa
//
// Alpha Quant Toolkit · #04 Multi-Timeframe Trend Matrix
// One glance at trend direction, strength and stretch across up to six timeframes,
// plus a single alignment reading. HTF data is non-repainting by default.

//@version=6
indicator("Alpha MTF Trend Matrix [identityKa]", shorttitle="AQ MTF Matrix", overlay=true)

// ═══════════════════════════════════════════════════════════════
//  CONSTANTS
// ═══════════════════════════════════════════════════════════════
const string GRP_CALC = "Calculation"
const string GRP_TFS  = "Timeframes"
const string GRP_RULE = "Alignment Rules"
const string GRP_VIS  = "Display"
const string GRP_DASH = "Dashboard"
const string BRAND    = "Alpha Quant Toolkit · identityKa"

// ═══════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════
fastLen   = input.int(20, "Fast EMA Length", minval=2, group=GRP_CALC)
slowLen   = input.int(50, "Slow EMA Length", minval=5, group=GRP_CALC)
slopeBars = input.int(3,  "Slow EMA Slope Lookback (bars)", minval=1, maxval=20, group=GRP_CALC,
     tooltip="The slow EMA counts as rising if it is above its value this many bars ago.")
erLen     = input.int(10, "Efficiency Ratio Length", minval=2, group=GRP_CALC)
useConf   = input.bool(true, "Use confirmed HTF bars only (no repaint)", group=GRP_CALC,
     tooltip="ON: higher-timeframe rows use the last CLOSED bar, so they never change after the fact. OFF: rows use the developing bar and can change until it closes.")

on1 = input.bool(true, "", inline="t1", group=GRP_TFS)
tf1 = input.timeframe("5",   "Timeframe 1", inline="t1", group=GRP_TFS)
on2 = input.bool(true, "", inline="t2", group=GRP_TFS)
tf2 = input.timeframe("15",  "Timeframe 2", inline="t2", group=GRP_TFS)
on3 = input.bool(true, "", inline="t3", group=GRP_TFS)
tf3 = input.timeframe("60",  "Timeframe 3", inline="t3", group=GRP_TFS)
on4 = input.bool(true, "", inline="t4", group=GRP_TFS)
tf4 = input.timeframe("240", "Timeframe 4", inline="t4", group=GRP_TFS)
on5 = input.bool(true, "", inline="t5", group=GRP_TFS)
tf5 = input.timeframe("D",   "Timeframe 5", inline="t5", group=GRP_TFS)
on6 = input.bool(true, "", inline="t6", group=GRP_TFS)
tf6 = input.timeframe("W",   "Timeframe 6", inline="t6", group=GRP_TFS)

alignThr = input.float(70, "Aligned at or above (% of timeframes)", minval=30, maxval=100, step=5, group=GRP_RULE,
     tooltip="Alignment = net share of timeframes pointing the same way. +100% means every active timeframe is up, -100% means every one is down.")

cUp   = input.color(#19D3A2, "Up",   group=GRP_VIS, inline="c1")
cDn   = input.color(#FF4D6A, "Down", group=GRP_VIS, inline="c1")

showTable = input.bool(true, "Show Dashboard", group=GRP_DASH)
posInput  = input.string("Top Right", "Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=GRP_DASH)
sizeInput = input.string("Normal", "Text Size", options=["Small", "Normal", "Large"], group=GRP_DASH)
showBrand = input.bool(true, "Show footer", group=GRP_DASH)

// ═══════════════════════════════════════════════════════════════
//  CORE CALCULATION (evaluated on each requested timeframe)
//  votes: +1/-1 for each of three checks, sum in [-3, +3]
//    1) fast EMA vs slow EMA   2) close vs slow EMA   3) slow EMA slope
// ═══════════════════════════════════════════════════════════════
mtfCalc(int fL, int sL, int sB, int eL, bool conf) =>
    emaF = ta.ema(close, fL)
    emaS = ta.ema(close, sL)
    atr  = ta.atr(14)
    int v = 0
    v += emaF > emaS ? 1 : emaF < emaS ? -1 : 0
    v += close > emaS ? 1 : close < emaS ? -1 : 0
    v += emaS > emaS[sB] ? 1 : emaS < emaS[sB] ? -1 : 0
    erNum = math.abs(close - close[eL])
    erDen = math.sum(math.abs(close - close[1]), eL)
    er    = erDen == 0 ? 0.0 : erNum / erDen
    dist  = (na(atr) or atr == 0) ? 0.0 : (close - emaS) / atr
    float vOut = conf ? v[1] : v
    float eOut = conf ? er[1] : er
    float dOut = conf ? dist[1] : dist
    [vOut, eOut, dOut]

lah = useConf ? barmerge.lookahead_on : barmerge.lookahead_off

[vC, eC, dC] = mtfCalc(fastLen, slowLen, slopeBars, erLen, false)
[v1, e1, d1] = request.security(syminfo.tickerid, tf1, mtfCalc(fastLen, slowLen, slopeBars, erLen, useConf), lookahead=lah)
[v2, e2, d2] = request.security(syminfo.tickerid, tf2, mtfCalc(fastLen, slowLen, slopeBars, erLen, useConf), lookahead=lah)
[v3, e3, d3] = request.security(syminfo.tickerid, tf3, mtfCalc(fastLen, slowLen, slopeBars, erLen, useConf), lookahead=lah)
[v4, e4, d4] = request.security(syminfo.tickerid, tf4, mtfCalc(fastLen, slowLen, slopeBars, erLen, useConf), lookahead=lah)
[v5, e5, d5] = request.security(syminfo.tickerid, tf5, mtfCalc(fastLen, slowLen, slopeBars, erLen, useConf), lookahead=lah)
[v6, e6, d6] = request.security(syminfo.tickerid, tf6, mtfCalc(fastLen, slowLen, slopeBars, erLen, useConf), lookahead=lah)

// A row is usable if it is switched on and its timeframe is not lower than the chart timeframe
chartSec = timeframe.in_seconds()
ok1 = on1 and timeframe.in_seconds(tf1) >= chartSec
ok2 = on2 and timeframe.in_seconds(tf2) >= chartSec
ok3 = on3 and timeframe.in_seconds(tf3) >= chartSec
ok4 = on4 and timeframe.in_seconds(tf4) >= chartSec
ok5 = on5 and timeframe.in_seconds(tf5) >= chartSec
ok6 = on6 and timeframe.in_seconds(tf6) >= chartSec

// ═══════════════════════════════════════════════════════════════
//  ALIGNMENT
// ═══════════════════════════════════════════════════════════════
f_dir(float v, bool ok) => ok and not na(v) ? (v > 0 ? 1 : v < 0 ? -1 : 0) : na
f_cnt(int x) => na(x) ? 0 : 1
f_up(int x)  => x == 1 ? 1 : 0
f_dn(int x)  => x == -1 ? 1 : 0

d0i = f_dir(vC, true)
d1i = f_dir(v1, ok1)
d2i = f_dir(v2, ok2)
d3i = f_dir(v3, ok3)
d4i = f_dir(v4, ok4)
d5i = f_dir(v5, ok5)
d6i = f_dir(v6, ok6)

validN = f_cnt(d0i) + f_cnt(d1i) + f_cnt(d2i) + f_cnt(d3i) + f_cnt(d4i) + f_cnt(d5i) + f_cnt(d6i)
upN    = f_up(d0i) + f_up(d1i) + f_up(d2i) + f_up(d3i) + f_up(d4i) + f_up(d5i) + f_up(d6i)
dnN    = f_dn(d0i) + f_dn(d1i) + f_dn(d2i) + f_dn(d3i) + f_dn(d4i) + f_dn(d5i) + f_dn(d6i)

alignPct  = validN == 0 ? na : 100.0 * (upN - dnN) / validN
alignCode = na(alignPct) ? 0 : alignPct >= alignThr ? 1 : alignPct <= -alignThr ? -1 : 0
alignText = alignCode == 1 ? "Aligned Up" : alignCode == -1 ? "Aligned Down" : "Mixed"

// ═══════════════════════════════════════════════════════════════
//  DASHBOARD
// ═══════════════════════════════════════════════════════════════
tblPos = switch posInput
    "Top Left"     => position.top_left
    "Bottom Left"  => position.bottom_left
    "Bottom Right" => position.bottom_right
    => position.top_right

txtSize = switch sizeInput
    "Small" => size.small
    "Large" => size.large
    => size.normal

fmt(float x, int d) => na(x) ? "—" : str.tostring(math.round(x, d))

f_tfLabel(string tf) =>
    int s = timeframe.in_seconds(tf)
    string r = ""
    if s >= 2592000
        r := str.tostring(math.round(s / 2592000.0)) + "M"
    else if s >= 604800
        r := str.tostring(math.round(s / 604800.0)) + "W"
    else if s >= 86400
        r := str.tostring(math.round(s / 86400.0)) + "D"
    else if s >= 3600
        r := str.tostring(math.round(s / 3600.0)) + "H"
    else if s >= 60
        r := str.tostring(math.round(s / 60.0)) + "m"
    else
        r := str.tostring(s) + "s"
    r

var table dash = table.new(tblPos, 5, 11, bgcolor=color.new(#0F1420, 8), border_width=1, border_color=color.new(#2A3350, 0), frame_width=1, frame_color=color.new(#2A3350, 0))

f_row(int r, string label, float v, float er, float d, bool ok, bool isOn) =>
    color cTxt = #E6EAF2
    color cDim = #9AA4B8
    string trendTxt = isOn ? "n/a" : "off"
    color fg = cDim
    color bg = color.new(#0F1420, 100)
    if ok and not na(v)
        if v >= 3
            trendTxt := "Strong Up"
            fg := cUp
            bg := color.new(cUp, 70)
        else if v > 0
            trendTxt := "Up"
            fg := cUp
            bg := color.new(cUp, 88)
        else if v <= -3
            trendTxt := "Strong Down"
            fg := cDn
            bg := color.new(cDn, 70)
        else if v < 0
            trendTxt := "Down"
            fg := cDn
            bg := color.new(cDn, 88)
        else
            trendTxt := "Neutral"
    string votesTxt = (ok and not na(v)) ? (v > 0 ? "+" : "") + str.tostring(math.round(v)) : "—"
    table.cell(dash, 0, r, label, text_color=cTxt, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, r, trendTxt, text_color=fg, text_size=txtSize, text_halign=text.align_center, bgcolor=bg)
    table.cell(dash, 2, r, votesTxt, text_color=fg, text_size=txtSize, text_halign=text.align_center)
    table.cell(dash, 3, r, ok ? fmt(er, 2) : "—", text_color=cTxt, text_size=txtSize, text_halign=text.align_center)
    table.cell(dash, 4, r, ok ? fmt(d, 2) : "—", text_color=cTxt, text_size=txtSize, text_halign=text.align_center)

if barstate.islast and showTable
    cTxt = #E6EAF2
    cDim = #9AA4B8
    hdrBg = color.new(#1B2440, 0)

    table.cell(dash, 0, 0, "MTF TREND MATRIX", text_color=cTxt, text_size=txtSize, text_halign=text.align_center, bgcolor=hdrBg)
    table.merge_cells(dash, 0, 0, 4, 0)

    table.cell(dash, 0, 1, "TF",         text_color=cDim, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 1, "Trend",      text_color=cDim, text_size=txtSize, text_halign=text.align_center)
    table.cell(dash, 2, 1, "Votes",      text_color=cDim, text_size=txtSize, text_halign=text.align_center)
    table.cell(dash, 3, 1, "ER",         text_color=cDim, text_size=txtSize, text_halign=text.align_center)
    table.cell(dash, 4, 1, "Dist (ATR)", text_color=cDim, text_size=txtSize, text_halign=text.align_center)

    f_row(2, timeframe.period + " (chart)", vC, eC, dC, true, true)
    f_row(3, f_tfLabel(tf1), v1, e1, d1, ok1, on1)
    f_row(4, f_tfLabel(tf2), v2, e2, d2, ok2, on2)
    f_row(5, f_tfLabel(tf3), v3, e3, d3, ok3, on3)
    f_row(6, f_tfLabel(tf4), v4, e4, d4, ok4, on4)
    f_row(7, f_tfLabel(tf5), v5, e5, d5, ok5, on5)
    f_row(8, f_tfLabel(tf6), v6, e6, d6, ok6, on6)

    alignCol = alignCode == 1 ? cUp : alignCode == -1 ? cDn : cTxt
    alignBg  = alignCode == 1 ? color.new(cUp, 70) : alignCode == -1 ? color.new(cDn, 70) : color.new(#0F1420, 100)
    table.cell(dash, 0, 9, "Alignment", text_color=cDim, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 9, alignText, text_color=alignCol, text_size=txtSize, text_halign=text.align_center, bgcolor=alignBg)
    table.cell(dash, 2, 9, str.tostring(upN) + " up · " + str.tostring(dnN) + " down · " + str.tostring(validN - upN - dnN) + " neutral  (" + fmt(alignPct, 0) + "%)", text_color=cTxt, text_size=txtSize, text_halign=text.align_center)
    table.merge_cells(dash, 2, 9, 4, 9)

    table.cell(dash, 0, 10, showBrand ? BRAND : "", text_color=cDim, text_size=size.tiny, text_halign=text.align_center)
    table.merge_cells(dash, 0, 10, 4, 10)

// ═══════════════════════════════════════════════════════════════
//  ALERTS  (set to "Once Per Bar Close" for stable, non-repainting triggers)
// ═══════════════════════════════════════════════════════════════
alignChanged = ta.change(alignCode) != 0

alertcondition(alignChanged and alignCode == 1,  "Timeframes Aligned Up",   "{{ticker}} ({{interval}}): timeframes are aligned Up")
alertcondition(alignChanged and alignCode == -1, "Timeframes Aligned Down", "{{ticker}} ({{interval}}): timeframes are aligned Down")
alertcondition(alignChanged and alignCode == 0,  "Timeframe alignment lost", "{{ticker}} ({{interval}}): timeframe alignment is now Mixed")
alertcondition(alignChanged,                     "Alignment changed (any)",  "{{ticker}} ({{interval}}): multi-timeframe alignment changed")
````
