# MTF Order Block Confluence [EmpArchitect]

- url: https://www.tradingview.com/script/OMUfYbWg-MTF-Order-Block-Confluence-EmpArchitect/
- type: indicator
- pine_id: PUB;ff3f228aa02d4436a5896d28309439b9
- version: 1.0

## Description

█ OVERVIEW

MTF Order Block Confluence [EmpArchitect] maps active bullish and bearish Order Block zones across multiple timeframes and shows when same-direction zones overlap.

The script tracks the most recently formed active bullish and bearish OB on the chart timeframe, then checks whether higher-timeframe OB zones overlap that chart-timeframe zone within a configurable ATR tolerance.

“N TF” means N same-direction active OB zones overlap.

It maps multi-timeframe OB context. It does not provide entries, exits, targets, stop losses, probability scores, or trade signals.

█ WHAT IT MAPS

Order Block zones:

A bullish OB is the last down candle before a bullish structure break.

A bearish OB is the last up candle before a bearish structure break.

The OB zone is drawn from the origin candle’s high to low.

The script tracks one active bullish OB and one active bearish OB per supported timeframe.

Active means the zone has not been invalidated by a close through its far boundary.

This script does not use touch-based mitigation. A zone touch does not remove the OB. Only a close-through invalidates it.

█ MULTI-TIMEFRAME OVERLAP

The script anchors on the chart-timeframe OB and checks whether higher-timeframe OB zones overlap it.

Same-direction overlap only:

• Bull OB overlaps Bull OB
• Bear OB overlaps Bear OB

Opposite-direction overlap is not counted as confluence.

The overlap count is shown as:

• 1 TF = chart-timeframe OB only
• 2 TF = chart-timeframe OB overlaps one higher-timeframe OB
• 3 TF = chart-timeframe OB overlaps two higher-timeframe OBs
• 4 TF = chart-timeframe OB overlaps three higher-timeframe OBs

This is a structure-context read only. It does not mean price should react from the zone.

█ SUPPORTED TIMEFRAMES

The ladder is:

• 15m
• 1H
• 4H
• 1D

Run the script on 15m for the full ladder.

The script uses chart timeframe + higher timeframes only. It does not fake lower-timeframe OBs from a higher chart.

If a ladder timeframe is below the current chart timeframe, the dashboard marks it as below chart TF.

█ CONFIRMATION MODEL

The script uses confirmed candles only.

A new OB forms only after:

• a confirmed structure break
• a first close-cross of the relevant swing level
• a directional break candle
• a valid opposing origin candle
• minimum displacement strength

Weak displacement can consume the structure level without creating an OB.

Higher-timeframe values use confirmed snapshots from completed higher-timeframe candles. This is designed to avoid intrabar higher-timeframe flicker.

█ OB VALIDITY

Bullish OB:

A bullish OB remains active until price closes below the bottom of the zone.

Bearish OB:

A bearish OB remains active until price closes above the top of the zone.

Once invalidated, the OB stays inactive until a new OB forms.

Only the current active chart-timeframe OB zones are drawn. Historical OB zones are not retained on the chart.

█ OVERLAP TOLERANCE

OB zones rarely align perfectly by exact tick.

The script includes an ATR-based overlap tolerance so nearby zones can still count as overlapping when they are structurally close.

The default tolerance is 0.25 × ATR.

This is adjustable.

Lower values require stricter overlap.

Higher values allow wider buffered overlap.

The tolerance should be reviewed manually. It is a visual structure tool, not an automatic validation of zone strength.

█ DASHBOARD

The dashboard shows:

• Bull OB Stack
• Bear OB Stack
• Timeframes included in the stack
• Bull/Bear OB grade per timeframe
• Below-chart timeframe status
• Current supported ladder context

The dashboard grade is based only on the displacement strength of the candle that formed the OB.

Grade does not measure future performance.

█ ALERTS

Included context alerts:

• Bull OB 2+ TF overlap
• Bear OB 2+ TF overlap

Alerts fire when a same-direction OB overlap reaches 2 or more timeframes.

Alerts describe structure context only. They are not trade signals.

█ IMPORTANT LIMITATIONS

• Tracks only the most recently formed active OB per direction per timeframe
• Does not retain multiple historical OBs
• Does not select the nearest OB to current price
• Does not use touch-based mitigation
• Does not predict whether price will react from a zone
• Does not provide entries, stops, targets, or trade instructions
• Overlap depends on the selected ATR tolerance
• Best reviewed manually with the relevant higher timeframes

█ NOTES

• Pine Script v6
• Open-source
• Designed for 15m / 1H / 4H / 1D structure review
• Same-direction OB overlap only
• Built by EmpArchitect
• Educational structure-context tool only
• Not financial advice
• Not a signal service

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
// © EmpArchitect
// MTF Order Block Confluence [EmpArchitect] — v0.1 (free, open-source)
// Tracks the latest active bullish & bearish order block on each supported
// timeframe and shows where same-direction zones OVERLAP across timeframes.
// Structure context only. No signals, entries, targets, SL or TP.
// "3 TF" = three same-direction OB zones overlap under the tolerance buffer.
// It does not imply probability or entry quality.

//@version=6
indicator("MTF Order Block Confluence [EmpArchitect]", shorttitle="OB Confluence [EA]", overlay=true,
     max_lines_count=100, max_labels_count=100, max_boxes_count=50)

// ═══════════════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════════════

grpEng = "═══ Detection ═══"
swingLen    = input.int(5, "Swing Length", minval=2, maxval=50, group=grpEng,
     tooltip="Pivot lookback for structure breaks.")
atrPeriod   = input.int(14, "ATR Period", minval=1, maxval=50, group=grpEng)
obSearchBars = input.int(20, "OB Search Window", minval=1, maxval=100, group=grpEng,
     tooltip="Max bars between the OB origin candle and the break that creates it.")
minGrade    = input.int(1, "Minimum OB Grade", minval=1, maxval=3, group=grpEng,
     tooltip="1=C, 2=B, 3=A. Weak displacement consumes the level but creates no OB.")
obTolAtr    = input.float(0.25, "Overlap Tolerance (×ATR)", minval=0.0, maxval=2.0, step=0.05, group=grpEng,
     tooltip="Padding on the overlap test so zones that are close but not touching still count. Tune manually; do not assume 0.25 is correct.")

grpDisp = "═══ Display ═══"
showBoxes = input.bool(true, "Draw Chart-TF OB Zones", group=grpDisp)
showDash  = input.bool(true, "Show Dashboard", group=grpDisp)

grpCol = "═══ Colors ═══"
bullColor = input.color(#14B8A6, "Bullish (Teal)", group=grpCol)
bearColor = input.color(#F59E0B, "Bearish (Amber)", group=grpCol)
strongCol = input.color(#22C55E, "3+ TF Overlap", group=grpCol)
midCol    = input.color(#EAB308, "2 TF Overlap", group=grpCol)
textCol   = input.color(#F8FAFC, "Text", group=grpCol)
dimCol    = input.color(#6B7280, "Dim / Neutral", group=grpCol)

// ═══════════════════════════════════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════════════════════════════════

f_tfShort(string tf) =>
    s = timeframe.in_seconds(tf)
    s <= 900 ? "15m" : s <= 3600 ? "1H" : s <= 14400 ? "4H" : s <= 86400 ? "1D" : "1W"

f_gradeTxt(int g) => g == 3 ? "A" : g == 2 ? "B" : g == 1 ? "C" : "—"
f_overlapCol(int n) => n >= 3 ? strongCol : n == 2 ? midCol : dimCol

// overlap of [aBot,aTop] and [bBot,bTop] with ATR tolerance padding
f_overlap(float aTop, float aBot, float bTop, float bBot, float tol) =>
    not na(aTop) and not na(aBot) and not na(bTop) and not na(bBot) and (aTop + tol >= bBot) and (bTop + tol >= aBot)

// ═══════════════════════════════════════════════════════════════════════
//  THE ENGINE — latest active OB per direction, numeric only
//  gate = commit live-data state only when true (barstate.isconfirmed inline).
//  Returns:
//   [ bullTop, bullBot, bullValid, bullGrade,
//     bearTop, bearBot, bearValid, bearGrade,
//     bullOriginBar, bullFormBar, bearOriginBar, bearFormBar ]
// ═══════════════════════════════════════════════════════════════════════

f_obSnapshot(bool gate) =>
    _atr = ta.atr(atrPeriod)
    _ph  = ta.pivothigh(high, swingLen, swingLen)
    _pl  = ta.pivotlow(low, swingLen, swingLen)

    // swing levels + pivot bars; mark already-broken if price was past on confirm
    var float topLevel = na
    var float btmLevel = na
    var int   topPivotBar = na
    var int   btmPivotBar = na
    var bool  topBroken = false
    var bool  btmBroken = false
    if gate and not na(_ph)
        topLevel := _ph
        topPivotBar := bar_index - swingLen
        topBroken := close[1] > _ph
    if gate and not na(_pl)
        btmLevel := _pl
        btmPivotBar := bar_index - swingLen
        btmBroken := close[1] < _pl

    // track most recent up / down candle (OB origin)
    var float lastDownHigh = na
    var float lastDownLow  = na
    var int   lastDownBar  = na
    var float lastUpHigh   = na
    var float lastUpLow    = na
    var int   lastUpBar    = na
    bool isDown = close < open
    bool isUp   = close > open
    if gate and isDown
        lastDownHigh := high
        lastDownLow  := low
        lastDownBar  := bar_index
    if gate and isUp
        lastUpHigh := high
        lastUpLow  := low
        lastUpBar  := bar_index

    // first close-cross breaks with directional displacement candle
    bool bullBreak = gate and not na(topLevel) and not topBroken and close > topLevel and close[1] <= topLevel and close > open
    bool bearBreak = gate and not na(btmLevel) and not btmBroken and close < btmLevel and close[1] >= btmLevel and close < open

    // displacement grade of the break candle
    float dispNorm = (na(_atr) or _atr == 0) ? 0.0 : math.abs(close - open) / _atr
    int dispG = dispNorm >= 1.2 ? 3 : dispNorm >= 0.7 ? 2 : dispNorm >= 0.35 ? 1 : 0

    // origin candle must exist, sit after the pivot, and be within the search window
    bool validBullOrigin = not na(lastDownBar) and lastDownBar < bar_index and not na(topPivotBar) and lastDownBar >= topPivotBar and (bar_index - lastDownBar <= obSearchBars)
    bool validBearOrigin = not na(lastUpBar) and lastUpBar < bar_index and not na(btmPivotBar) and lastUpBar >= btmPivotBar and (bar_index - lastUpBar <= obSearchBars)

    var float bullTop = na
    var float bullBot = na
    var int   bullOriginBar = na
    var int   bullFormBar = na
    var int   bullGrade = 0
    var bool  bullValid = false
    var float bearTop = na
    var float bearBot = na
    var int   bearOriginBar = na
    var int   bearFormBar = na
    var int   bearGrade = 0
    var bool  bearValid = false

    if bullBreak
        topBroken := true
        if validBullOrigin and dispG >= minGrade
            bullTop       := lastDownHigh
            bullBot       := lastDownLow
            bullOriginBar := lastDownBar
            bullFormBar   := bar_index
            bullGrade     := dispG
            bullValid     := true

    if bearBreak
        btmBroken := true
        if validBearOrigin and dispG >= minGrade
            bearTop       := lastUpHigh
            bearBot       := lastUpLow
            bearOriginBar := lastUpBar
            bearFormBar   := bar_index
            bearGrade     := dispG
            bearValid     := true

    // sticky invalidation (close-through far boundary)
    if bullValid and gate and not na(bullBot) and close < bullBot
        bullValid := false
    if bearValid and gate and not na(bearTop) and close > bearTop
        bearValid := false

    [bullTop, bullBot, bullValid ? 1 : 0, bullGrade,
     bearTop, bearBot, bearValid ? 1 : 0, bearGrade,
     bullOriginBar, bullFormBar, bearOriginBar, bearFormBar]

// Confirmed wrapper for HTF reads — destructure, offset each series [1].
// (Pine forbids tuple[1]; offsetting individual series inside a wrapper is legal.)
f_obConfirmed() =>
    [a, b, c, d, e, f, g, h, i, j, k, l] = f_obSnapshot(true)
    [a[1], b[1], c[1], d[1], e[1], f[1], g[1], h[1], i[1], j[1], k[1], l[1]]

// ═══════════════════════════════════════════════════════════════════════
//  CHART TF (inline, gated) — the overlap ANCHOR
// ═══════════════════════════════════════════════════════════════════════

[cBullTop, cBullBot, cBullValid, cBullGrade, cBearTop, cBearBot, cBearValid, cBearGrade, cBullOrigin, cBullForm, cBearOrigin, cBearForm] = f_obSnapshot(barstate.isconfirmed)

float chartAtr = ta.atr(atrPeriod)
int   chartSec = timeframe.in_seconds(timeframe.period)
float tol      = obTolAtr * (na(chartAtr) ? 0.0 : chartAtr)

int sec15 = timeframe.in_seconds("15")
int sec60 = timeframe.in_seconds("60")
int sec24 = timeframe.in_seconds("240")
int secD  = timeframe.in_seconds("1D")

// supported chart timeframes only (matches the documented ladder)
bool supportedChart = chartSec == sec15 or chartSec == sec60 or chartSec == sec24 or chartSec == secD

// ═══════════════════════════════════════════════════════════════════════
//  HIGHER-TF READS — confirmed, chart TF + higher only
// ═══════════════════════════════════════════════════════════════════════

[t15B, b15B, v15B, g15B, t15S, b15S, v15S, g15S, o15B, f15B, o15S, f15S] = request.security(syminfo.tickerid, "15",  f_obConfirmed(), lookahead=barmerge.lookahead_on)
[t60B, b60B, v60B, g60B, t60S, b60S, v60S, g60S, o60B, f60B, o60S, f60S] = request.security(syminfo.tickerid, "60",  f_obConfirmed(), lookahead=barmerge.lookahead_on)
[t24B, b24B, v24B, g24B, t24S, b24S, v24S, g24S, o24B, f24B, o24S, f24S] = request.security(syminfo.tickerid, "240", f_obConfirmed(), lookahead=barmerge.lookahead_on)
[tDB,  bDB,  vDB,  gDB,  tDS,  bDS,  vDS,  gDS,  oDB,  fDB,  oDS,  fDS ] = request.security(syminfo.tickerid, "1D",  f_obConfirmed(), lookahead=barmerge.lookahead_on)

// ═══════════════════════════════════════════════════════════════════════
//  MULTI-TF OVERLAP — anchored on chart TF, count overlapping HIGHER TFs
// ═══════════════════════════════════════════════════════════════════════

int bullStack = 0
string bullTFs = ""
int bearStack = 0
string bearTFs = ""

if supportedChart
    if cBullValid == 1
        bullStack := 1
        bullTFs := f_tfShort(timeframe.period)
        if sec60 > chartSec and v60B == 1 and f_overlap(cBullTop, cBullBot, t60B, b60B, tol)
            bullStack += 1
            bullTFs += "·1H"
        if sec24 > chartSec and v24B == 1 and f_overlap(cBullTop, cBullBot, t24B, b24B, tol)
            bullStack += 1
            bullTFs += "·4H"
        if secD > chartSec and vDB == 1 and f_overlap(cBullTop, cBullBot, tDB, bDB, tol)
            bullStack += 1
            bullTFs += "·1D"
    if cBearValid == 1
        bearStack := 1
        bearTFs := f_tfShort(timeframe.period)
        if sec60 > chartSec and v60S == 1 and f_overlap(cBearTop, cBearBot, t60S, b60S, tol)
            bearStack += 1
            bearTFs += "·1H"
        if sec24 > chartSec and v24S == 1 and f_overlap(cBearTop, cBearBot, t24S, b24S, tol)
            bearStack += 1
            bearTFs += "·4H"
        if secD > chartSec and vDS == 1 and f_overlap(cBearTop, cBearBot, tDS, bDS, tol)
            bearStack += 1
            bearTFs += "·1D"

// ═══════════════════════════════════════════════════════════════════════
//  DRAW CHART-TF OB ZONES (one persistent box + label per direction)
// ═══════════════════════════════════════════════════════════════════════

var box   bullBox = na
var label bullLbl = na
var box   bearBox = na
var label bearLbl = na

if showBoxes and supportedChart and cBullValid == 1 and not na(cBullOrigin)
    color bc = f_overlapCol(bullStack)
    string txt = "Bull OB · " + str.tostring(bullStack) + "TF stack"
    if na(bullBox)
        bullBox := box.new(cBullOrigin, cBullTop, bar_index, cBullBot, border_color=bullColor, bgcolor=color.new(bc, 80))
        bullLbl := label.new(bar_index, cBullTop, txt, style=label.style_label_left, color=color.new(bc, 20), textcolor=textCol, size=size.small)
    else
        box.set_lefttop(bullBox, cBullOrigin, cBullTop)
        box.set_rightbottom(bullBox, bar_index, cBullBot)
        box.set_bgcolor(bullBox, color.new(bc, 80))
        box.set_border_color(bullBox, bullColor)
        label.set_xy(bullLbl, bar_index, cBullTop)
        label.set_text(bullLbl, txt)
        label.set_color(bullLbl, color.new(bc, 20))
else
    if not na(bullBox)
        box.delete(bullBox)
        label.delete(bullLbl)
        bullBox := na
        bullLbl := na

if showBoxes and supportedChart and cBearValid == 1 and not na(cBearOrigin)
    color sc = f_overlapCol(bearStack)
    string txt = "Bear OB · " + str.tostring(bearStack) + "TF stack"
    if na(bearBox)
        bearBox := box.new(cBearOrigin, cBearTop, bar_index, cBearBot, border_color=bearColor, bgcolor=color.new(sc, 80))
        bearLbl := label.new(bar_index, cBearBot, txt, style=label.style_label_left, color=color.new(sc, 20), textcolor=textCol, size=size.small)
    else
        box.set_lefttop(bearBox, cBearOrigin, cBearTop)
        box.set_rightbottom(bearBox, bar_index, cBearBot)
        box.set_bgcolor(bearBox, color.new(sc, 80))
        box.set_border_color(bearBox, bearColor)
        label.set_xy(bearLbl, bar_index, cBearBot)
        label.set_text(bearLbl, txt)
        label.set_color(bearLbl, color.new(sc, 20))
else
    if not na(bearBox)
        box.delete(bearBox)
        label.delete(bearLbl)
        bearBox := na
        bearLbl := na

// ═══════════════════════════════════════════════════════════════════════
//  DASHBOARD
// ═══════════════════════════════════════════════════════════════════════

var string[] tfStr = array.from("15", "60", "240", "1D")
var string[] tfLbl = array.from("15m", "1H", "4H", "1D")

bullValArr = array.from(sec15 == chartSec ? cBullValid : v15B, sec60 == chartSec ? cBullValid : v60B, sec24 == chartSec ? cBullValid : v24B, secD == chartSec ? cBullValid : vDB)
bullGrArr  = array.from(sec15 == chartSec ? cBullGrade : g15B, sec60 == chartSec ? cBullGrade : g60B, sec24 == chartSec ? cBullGrade : g24B, secD == chartSec ? cBullGrade : gDB)
bearValArr = array.from(sec15 == chartSec ? cBearValid : v15S, sec60 == chartSec ? cBearValid : v60S, sec24 == chartSec ? cBearValid : v24S, secD == chartSec ? cBearValid : vDS)
bearGrArr  = array.from(sec15 == chartSec ? cBearGrade : g15S, sec60 == chartSec ? cBearGrade : g60S, sec24 == chartSec ? cBearGrade : g24S, secD == chartSec ? cBearGrade : gDS)

var table dash = table.new(position.top_right, 3, 12, bgcolor=color.new(color.black, 82), border_width=0)

if barstate.islast and showDash
    table.clear(dash, 0, 0, 2, 11)
    table.cell(dash, 0, 0, "MTF OB Confluence", text_color=textCol, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 2, 0, "v0.1", text_color=dimCol, text_size=size.tiny, text_halign=text.align_right)

    if not supportedChart
        table.cell(dash, 0, 1, "Use 15m / 1H / 4H / 1D", text_color=dimCol, text_size=size.small, text_halign=text.align_left)
    else
        table.cell(dash, 0, 1, "Bull OB Stack", text_color=dimCol, text_size=size.small, text_halign=text.align_left)
        table.cell(dash, 1, 1, bullStack > 0 ? str.tostring(bullStack) + " TF" : "—", text_color=bullStack >= 2 ? strongCol : textCol, text_size=size.small, text_halign=text.align_left)
        table.cell(dash, 2, 1, bullStack > 0 ? bullTFs : "", text_color=dimCol, text_size=size.tiny, text_halign=text.align_right)

        table.cell(dash, 0, 2, "Bear OB Stack", text_color=dimCol, text_size=size.small, text_halign=text.align_left)
        table.cell(dash, 1, 2, bearStack > 0 ? str.tostring(bearStack) + " TF" : "—", text_color=bearStack >= 2 ? strongCol : textCol, text_size=size.small, text_halign=text.align_left)
        table.cell(dash, 2, 2, bearStack > 0 ? bearTFs : "", text_color=dimCol, text_size=size.tiny, text_halign=text.align_right)

        table.cell(dash, 0, 4, "TF",      text_color=dimCol, text_size=size.small, text_halign=text.align_left)
        table.cell(dash, 1, 4, "Bull OB", text_color=dimCol, text_size=size.small, text_halign=text.align_left)
        table.cell(dash, 2, 4, "Bear OB", text_color=dimCol, text_size=size.small, text_halign=text.align_right)

        for i = 0 to 3
            int row = 5 + i
            int rowSec = timeframe.in_seconds(array.get(tfStr, i))
            table.cell(dash, 0, row, array.get(tfLbl, i), text_color=textCol, text_size=size.small, text_halign=text.align_left)
            if rowSec < chartSec
                table.cell(dash, 1, row, "below chart TF", text_color=dimCol, text_size=size.tiny, text_halign=text.align_left)
                table.cell(dash, 2, row, "", text_size=size.tiny)
            else
                int bv = array.get(bullValArr, i)
                int bg = array.get(bullGrArr, i)
                int sv = array.get(bearValArr, i)
                int sg = array.get(bearGrArr, i)
                table.cell(dash, 1, row, bv == 1 ? f_gradeTxt(bg) : "—", text_color=bv == 1 ? bullColor : dimCol, text_size=size.small, text_halign=text.align_left)
                table.cell(dash, 2, row, sv == 1 ? f_gradeTxt(sg) : "—", text_color=sv == 1 ? bearColor : dimCol, text_size=size.small, text_halign=text.align_right)

    table.cell(dash, 0, 10, "OB displacement grade only. Not a trade signal.", text_color=dimCol, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 0, 11, "'N TF' = N same-direction OB zones overlap.", text_color=dimCol, text_size=size.tiny, text_halign=text.align_left)

// ═══════════════════════════════════════════════════════════════════════
//  ALERTS (context only) — fire on overlap transition, not every bar
// ═══════════════════════════════════════════════════════════════════════

bool bullAnchorChanged = not na(cBullForm) and cBullForm != cBullForm[1]
bool bearAnchorChanged = not na(cBearForm) and cBearForm != cBearForm[1]

bool bullNew2 = supportedChart and cBullValid == 1 and bullStack >= 2 and (bullStack[1] < 2 or bullAnchorChanged)
bool bearNew2 = supportedChart and cBearValid == 1 and bearStack >= 2 and (bearStack[1] < 2 or bearAnchorChanged)

alertcondition(bullNew2, "Bull OB 2+ TF overlap", "Bullish OB overlap across 2+ timeframes. Structure context only. Not a trade signal.")
alertcondition(bearNew2, "Bear OB 2+ TF overlap", "Bearish OB overlap across 2+ timeframes. Structure context only. Not a trade signal.")
````
