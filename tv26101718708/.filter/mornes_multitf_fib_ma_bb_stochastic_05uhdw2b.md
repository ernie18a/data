# Morne's Multi-TF Fib + MA + BB + Stochastic

- url: https://www.tradingview.com/script/05uhdW2B-Morne-s-Multi-TF-Fib-MA-BB-Stochastic/
- type: indicator
- pine_id: PUB;83bce0ad479f4c9caed1f79dcc4c200a
- version: 2.0

## Description

Multi-Timeframe Fibonacci + MA + Bollinger Bands + Stochastic

OVERVIEW
An all-in-one overlay that combines two independent, timeframe-locked Fibonacci
grids with a standard trend and momentum toolkit, so you can read higher-timeframe
structure without leaving your working chart.

WHAT IT PLOTS
- Annual Fibonacci (yellow) — anchored to the PREVIOUS full calendar year's high
  and low, sourced from a configurable timeframe (Weekly by default). Recalculates
  once a year and then stays fixed, giving you the macro yearly range.
- Weekly Fibonacci (red, or a per-level palette) — anchored to the CURRENT rolling
  week's high and low, sourced from H4 by default. Updates live through the week.
- Both grids auto-detect direction (whether the high or the low formed first) and
  plot the full set: 0, 23.6, 50, 61.8, 78.6, 88.6, 100, plus 127 / 161.8 and
  -127 / -161.8 extensions.
- Two moving averages (21 & 100 by default; SMA / EMA / SMMA / LWMA selectable).
- Bollinger Bands (20, 2 deviations).
- Stochastic oscillator (50, 24, 1) in a separate lower pane.

Because the two Fib layers are locked to their source timeframes, they render
correctly on ANY chart timeframe — view an H1 chart and still see the weekly- and
H4-derived grids, correctly scaled.

HOW TO USE IT
Treat the yearly grid as macro structure and the weekly grid as intraweek structure.
Confluence — where a yearly level, a weekly level, a moving average, or a band edge
line up — is where these levels are most worth watching. The MAs and Stochastic add
trend and momentum context around them.

SETTINGS 
Every layer has independent on/off toggles, colour, line width, line style, label
size, and left/right bar extension. The Weekly grid can be a single colour or a
per-level palette. All periods and methods are editable via inputs.

NOTES
The weekly reset uses a Monday 00:00 UTC boundary; adjust the source timeframes to
suit your instrument. This script is an analysis tool, not financial advice.

## Source Code

````pine
//@version=6
// =============================================================================
// Multi-Timeframe Fibonacci + MA + Bollinger Bands + Stochastic + Signals
// Pine v6  |  rev 5
//  - Weekly Fib now anchored to the PREVIOUS week (levels per spec)
//  - 8 EMA / 21 EMA defaults
//  - Entry logic: 8 EMA crosses BB mid + 21 EMA, candle close beyond BB mid
//  - ATR filter on the break candle, SL at BB band (trailing), TP at opposite band
//  - Optional early exit when 21 EMA crosses back through BB mid
//  - Heads-up / setup / entry / exit alerts for manual trading
// Separate pane hosts the Stochastic; price elements use force_overlay=true.
// =============================================================================

indicator("Multi-TF Fib + MA + BB + Stochastic + Signals", shorttitle="MTF Fib+MA+BB+Sig", overlay=false, max_lines_count=100, max_labels_count=100)

// -------- TOGGLES --------
grpTgl  = "Toggles"
showAnnual = input.bool(true,  "Annual Fib (Yellow)", group=grpTgl)
showWeekly = input.bool(true,  "Previous-week Fib",   group=grpTgl)
showMA1    = input.bool(true,  "EMA fast (8)",        group=grpTgl)
showMA2    = input.bool(true,  "EMA slow (21)",       group=grpTgl)
showBB     = input.bool(true,  "Bollinger Bands",     group=grpTgl)
showStoch  = input.bool(true,  "Stochastic",          group=grpTgl)
showLegend = input.bool(true,  "Legend / trade status", group=grpTgl)
showAnchors= input.bool(false, "Fib anchor markers",  group=grpTgl, tooltip="Tags the exact High/Low bar each Fib layer is anchored to.")
showPW     = input.bool(true,  "Previous-week High/Low trend lines", group=grpTgl)

// -------- FIB SOURCE + SHARED LAYOUT --------
grpFib  = "Fibonacci - source & layout"
annTF     = input.timeframe("W",   "Annual Fib source TF", group=grpFib, tooltip="Layer 1 derived from this TF over the PREVIOUS calendar year.")
wkTF      = input.timeframe("240", "Weekly Fib source TF", group=grpFib, tooltip="Layer 2 derived from this TF over the PREVIOUS week (Fib on last week's price action).")
lvl7      = input.float(78.6, "7th Fib level", step=0.1, group=grpFib, tooltip="Email lists 76.8 - standard level is 78.6. Change here if 76.8 is intended.")
labelGap  = input.int(3, "Label gap past right end (bars)", minval=0, maxval=50, group=grpFib)
labelBg   = input.bool(false, "Label background", group=grpFib)

grpAnn  = "Fibonacci - Annual"
colAnn     = input.color(#FFC000, "Colour",     group=grpAnn, inline="a")
annWidth   = input.int(1, "Width", minval=1, maxval=6, group=grpAnn, inline="a")
annStyle   = input.string("Solid", "Line",  options=["Solid","Dashed","Dotted"], group=grpAnn)
annLblSize = input.string("Small", "Labels", options=["Tiny","Small","Normal","Large"], group=grpAnn)
annBack    = input.int(80, "Bars back",    minval=0, maxval=5000, group=grpAnn, inline="ab")
annFwd     = input.int(10, "Bars forward", minval=0, maxval=500,  group=grpAnn, inline="ab")

grpWk   = "Fibonacci - Previous week"
wkColMode  = input.string("Single", "Colour mode", options=["Single","Multi-colour"], group=grpWk, tooltip="Single = one colour (below). Multi-colour = per-level palette.")
colWk      = input.color(#C00000, "Single colour", group=grpWk, inline="w")
wkWidth    = input.int(1, "Width", minval=1, maxval=6, group=grpWk, inline="w")
wkStyle    = input.string("Solid", "Line",  options=["Solid","Dashed","Dotted"], group=grpWk)
wkLblSize  = input.string("Tiny",  "Labels", options=["Tiny","Small","Normal","Large"], group=grpWk)
wkAutoDash = input.bool(false, "Dash where it overlaps an Annual level", group=grpWk)
wkBack     = input.int(30, "Bars back",    minval=0, maxval=5000, group=grpWk, inline="wb")
wkFwd      = input.int(10, "Bars forward", minval=0, maxval=500,  group=grpWk, inline="wb")
colPWH     = input.color(#9C27B0, "Prev-week High line", group=grpWk, inline="pw")
colPWL     = input.color(#00BCD4, "Low line",            group=grpWk, inline="pw")

grpWkC  = "Fibonacci - Weekly level colours (Multi mode)"
cWn127 = input.color(#E91E63, "-127%",  group=grpWkC, inline="c1")
cW0    = input.color(#787B86, "0%",     group=grpWkC, inline="c1")
cW236  = input.color(#F23645, "23.6%",  group=grpWkC, inline="c2")
cW382  = input.color(#FF5252, "38.2%",  group=grpWkC, inline="c2")
cW50   = input.color(#FF9800, "50%",    group=grpWkC, inline="c3")
cW618  = input.color(#4CAF50, "61.8%",  group=grpWkC, inline="c3")
cW786  = input.color(#089981, "7th lvl",group=grpWkC, inline="c4")
cW886  = input.color(#00BCD4, "88.6%",  group=grpWkC, inline="c4")
cW100  = input.color(#787B86, "100%",   group=grpWkC, inline="c5")
cW127  = input.color(#2962FF, "127%",   group=grpWkC, inline="c5")

// -------- MOVING AVERAGES --------
grpMA   = "Moving Averages"
ma1Len  = input.int(8,  "Fast MA length", minval=1, group=grpMA, inline="m1")
ma1Meth = input.string("EMA", "", options=["SMA","EMA","SMMA (RMA)","LWMA (WMA)"], group=grpMA, inline="m1")
colMA1  = input.color(#C00000, "", group=grpMA, inline="m1")
ma1W    = input.int(1, "W", minval=1, maxval=6, group=grpMA, inline="m1")
ma2Len  = input.int(21, "Slow MA length", minval=1, group=grpMA, inline="m2")
ma2Meth = input.string("EMA", "", options=["SMA","EMA","SMMA (RMA)","LWMA (WMA)"], group=grpMA, inline="m2")
colMA2  = input.color(#1F4E79, "", group=grpMA, inline="m2")
ma2W    = input.int(2, "W", minval=1, maxval=6, group=grpMA, inline="m2")

// -------- BOLLINGER BANDS --------
grpBB   = "Bollinger Bands"
bbLen   = input.int(20, "Period",  minval=1, group=grpBB)
bbShift = input.int(0,  "Shift (visual only)", group=grpBB)
bbDev   = input.float(2.0, "Deviations", step=0.1, group=grpBB)
colBB   = input.color(#2E7D32, "Band",  group=grpBB, inline="bb")
bbW     = input.int(1, "W", minval=1, maxval=6, group=grpBB, inline="bb")
colBBm  = input.color(#66BB6A, "Basis", group=grpBB, inline="bb2")
bbmW    = input.int(1, "W", minval=1, maxval=6, group=grpBB, inline="bb2")

// -------- STOCHASTIC --------
grpSt   = "Stochastic"
kLen    = input.int(50, "%K period", minval=1, group=grpSt)
dLen    = input.int(24, "%D period", minval=1, group=grpSt)
slowing = input.int(1,  "Slowing",   minval=1, group=grpSt)
obLvl   = input.int(80, "Overbought", group=grpSt)
osLvl   = input.int(20, "Oversold",   group=grpSt)
colK    = input.color(#2962FF, "%K", group=grpSt, inline="s")
colD    = input.color(#FF6D00, "%D", group=grpSt, inline="s")

// -------- SIGNALS --------
grpSig       = "Signals (8/21 EMA + BB mid)"
useSignals   = input.bool(true,  "Enable signals", group=grpSig)
setupBars    = input.int(5, "Setup valid for (bars)", minval=1, group=grpSig, tooltip="After the 8 EMA is above/below both the BB mid and 21 EMA, how many bars to wait for a qualifying close.")
useAtrFilter = input.bool(true,  "ATR filter on break candle", group=grpSig, tooltip="Skips entries when the candle breaking the BB mid is over-extended.")
atrLen       = input.int(14, "ATR length", minval=1, group=grpSig)
maxBreakAtr  = input.float(1.0, "Max close distance beyond BB mid (x ATR)", minval=0.1, step=0.1, group=grpSig)
maxCandleAtr = input.float(2.0, "Max candle range (x ATR)", minval=0.1, step=0.1, group=grpSig)
trailSL      = input.bool(true,  "Trail SL with BB band", group=grpSig)
useEarlyExit = input.bool(true,  "Early exit: 21 EMA crosses back through BB mid", group=grpSig)
showTradeLns = input.bool(true,  "Show entry / SL / TP lines", group=grpSig)
showHeadsUp  = input.bool(true,  "Show heads-up markers", group=grpSig)
useAlerts    = input.bool(true,  "Send alert() messages with prices", group=grpSig, tooltip="Create an alert with condition: this indicator -> 'Any alert() function call'.")

// -------- LEGEND --------
grpLg   = "Legend"
legendPos  = input.string("Top Left", "Position", options=["Top Left","Top Right","Bottom Left","Bottom Right"], group=grpLg)
legendSize = input.string("Normal", "Text size", options=["Tiny","Small","Normal","Large"], group=grpLg)

// -------- MAPPERS --------
f_lstyle(string s) => s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid
f_size(string s)   => s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : s == "Large" ? size.large : size.small
f_pos(string p)    => p == "Top Right" ? position.top_right : p == "Bottom Left" ? position.bottom_left : p == "Bottom Right" ? position.bottom_right : position.top_left
f_px(float p)      => str.tostring(p, format.mintick)

// -------- FIB LEVELS + weekly palette --------
var array<float> levels = array.from(-127.0, 0.0, 23.6, 38.2, 50.0, 61.8, lvl7, 88.6, 100.0, 127.0)
var array<color> wkPal  = array.from(cWn127, cW0, cW236, cW382, cW50, cW618, cW786, cW886, cW100, cW127)
nL = array.size(levels)
f_price(float H, float L, int Ht, int Lt, float lv) =>
    rng = H - L
    (Ht >= Lt) ? L + (lv / 100.0) * rng : H - (lv / 100.0) * rng

// -------- LAYER 1 : Annual (previous calendar year) --------
f_annual() =>
    int y = year(time)
    var float ch = na, var float cl = na, var int cht = na, var int clt = na
    var float ph = na, var float pl = na, var int pht = na, var int plt = na
    bool newYear = y != y[1]
    if newYear
        ph := ch, pl := cl, pht := cht, plt := clt
        ch := high, cl := low, cht := time, clt := time
    else
        if na(ch) or high > ch
            ch := high, cht := time
        if na(cl) or low < cl
            cl := low, clt := time
    [ph, pl, pht, plt]
[aH, aL, aHt, aLt] = request.security(syminfo.tickerid, annTF, f_annual())

// -------- LAYER 2 : Previous week --------
// Uses the exchange's weekly session (time("W")) so forex Sunday opens roll correctly.
f_prevWeek() =>
    int wk = time("W")
    var float h  = na, var float l  = na, var int ht  = na, var int lt  = na
    var float ph = na, var float pl = na, var int pht = na, var int plt = na
    if wk != wk[1]
        ph := h, pl := l, pht := ht, plt := lt
        h := high, l := low, ht := time, lt := time
    else
        if na(h) or high > h
            h := high, ht := time
        if na(l) or low < l
            l := low, lt := time
    [ph, pl, pht, plt]
[wH, wL, wHt, wLt] = request.security(syminfo.tickerid, wkTF, f_prevWeek())

int cy = year(time)
int wkOpen = time("W")
var int curWkStart  = na
var int prevWkStart = na
if wkOpen != wkOpen[1]
    prevWkStart := curWkStart
    curWkStart  := wkOpen

// -------- MA / BB / ATR calculations --------
f_ma(float src, int len, string m) =>
    switch m
        "EMA"        => ta.ema(src, len)
        "SMMA (RMA)" => ta.rma(src, len)
        "LWMA (WMA)" => ta.wma(src, len)
        => ta.sma(src, len)

emaF    = f_ma(close, ma1Len, ma1Meth)
emaS    = f_ma(close, ma2Len, ma2Meth)
bbBasis = ta.sma(close, bbLen)
bbD     = bbDev * ta.stdev(close, bbLen)
bbUpper = bbBasis + bbD
bbLower = bbBasis - bbD
atrV    = ta.atr(atrLen)

// =============================================================================
// SIGNAL ENGINE
// =============================================================================
// Bias: 8 EMA on the correct side of BOTH the BB mid and the 21 EMA
longBias   = emaF > bbBasis and emaF > emaS
shortBias  = emaF < bbBasis and emaF < emaS
longSetup  = longBias  and not longBias[1]
shortSetup = shortBias and not shortBias[1]

// Heads-up: 8 EMA has crossed ONE of the two (BB mid or 21 EMA) but not both yet
fXupMid = ta.crossover(emaF, bbBasis)
fXupS   = ta.crossover(emaF, emaS)
fXdnMid = ta.crossunder(emaF, bbBasis)
fXdnS   = ta.crossunder(emaF, emaS)
longHeadsUp  = (fXupMid or fXupS) and not longBias
shortHeadsUp = (fXdnMid or fXdnS) and not shortBias

// ATR "in range" filter for the break candle
longRangeOK  = not useAtrFilter or ((close - bbBasis) <= maxBreakAtr * atrV and (high - low) <= maxCandleAtr * atrV)
shortRangeOK = not useAtrFilter or ((bbBasis - close) <= maxBreakAtr * atrV and (high - low) <= maxCandleAtr * atrV)

// Early-exit triggers
slowXdnMid = ta.crossunder(emaS, bbBasis)
slowXupMid = ta.crossover(emaS, bbBasis)

var int   pos     = 0      // 1 = long, -1 = short, 0 = flat
var int   armDir  = 0      // pending setup direction
var int   armBar  = na
var float entryPx = na
var float slPx    = na
var float tpPx    = na

bool enterLong  = false
bool enterShort = false
bool exitTP     = false
bool exitSL     = false
bool exitEarly  = false
bool blockedL   = false
bool blockedS   = false
int  exitDir    = 0
bool wasFlat    = pos == 0

if useSignals
    // 1) Manage open trade (SL checked first = conservative if both touched)
    if pos == 1
        tpPx := bbUpper
        if low <= slPx
            exitSL := true
        else if high >= tpPx
            exitTP := true
        else if useEarlyExit and slowXdnMid
            exitEarly := true
        else if trailSL
            slPx := math.max(slPx, bbLower)
    else if pos == -1
        tpPx := bbLower
        if high >= slPx
            exitSL := true
        else if low <= tpPx
            exitTP := true
        else if useEarlyExit and slowXupMid
            exitEarly := true
        else if trailSL
            slPx := math.min(slPx, bbUpper)

    if exitSL or exitTP or exitEarly
        exitDir := pos
        pos     := 0
    // 2) Look for new entries (only when flat, never on an exit bar)
    else if pos == 0
        if longSetup
            armDir := 1
            armBar := bar_index
        else if shortSetup
            armDir := -1
            armBar := bar_index

        if armDir == 1 and (not longBias or bar_index - armBar >= setupBars)
            armDir := 0
        if armDir == -1 and (not shortBias or bar_index - armBar >= setupBars)
            armDir := 0

        if armDir == 1 and close > bbBasis
            if longRangeOK
                enterLong := true
            else
                blockedL := true
        if armDir == -1 and close < bbBasis
            if shortRangeOK
                enterShort := true
            else
                blockedS := true

        if enterLong
            pos := 1, entryPx := close, slPx := bbLower, tpPx := bbUpper, armDir := 0
        if enterShort
            pos := -1, entryPx := close, slPx := bbUpper, tpPx := bbLower, armDir := 0

// Events for alerts / markers
headsUpL = useSignals and wasFlat and longHeadsUp
headsUpS = useSignals and wasFlat and shortHeadsUp
setupL   = useSignals and longSetup  and armDir == 1 and not enterLong
setupS   = useSignals and shortSetup and armDir == -1 and not enterShort

// =============================================================================
// DRAWING : Fib layers
// =============================================================================
var array<line>  annLines  = array.new<line>()
var array<label> annLabels = array.new<label>()
var array<line>  wkLines   = array.new<line>()
var array<label> wkLabels  = array.new<label>()
var label mkAH = na, var label mkAL = na, var label mkWH = na, var label mkWL = na

if barstate.isfirst
    for i = 0 to nL - 1
        array.push(annLines,  line.new(bar_index, close, bar_index, close, xloc=xloc.bar_index, force_overlay=true))
        array.push(annLabels, label.new(bar_index, close, "", xloc=xloc.bar_index, style=label.style_none, force_overlay=true))
        array.push(wkLines,   line.new(bar_index, close, bar_index, close, xloc=xloc.bar_index, force_overlay=true))
        array.push(wkLabels,  label.new(bar_index, close, "", xloc=xloc.bar_index, style=label.style_none, force_overlay=true))
    mkAH := label.new(na, na, "", xloc=xloc.bar_time, style=label.style_label_down, force_overlay=true)
    mkAL := label.new(na, na, "", xloc=xloc.bar_time, style=label.style_label_up,   force_overlay=true)
    mkWH := label.new(na, na, "", xloc=xloc.bar_time, style=label.style_label_down, force_overlay=true)
    mkWL := label.new(na, na, "", xloc=xloc.bar_time, style=label.style_label_up,   force_overlay=true)

f_hide(line ln, label lb) =>
    line.set_xy1(ln, na, na), line.set_xy2(ln, na, na)
    label.set_xy(lb, na, na)

f_style_label(label lb, int x, float p, float lv, color c, string szKey) =>
    label.set_xy(lb, x, p)
    label.set_style(lb, labelBg ? label.style_label_left : label.style_none)
    label.set_color(lb, labelBg ? color.new(color.black, 15) : color.new(color.black, 100))
    label.set_textcolor(lb, c)
    label.set_size(lb, f_size(szKey))
    label.set_text(lb, str.format("{0,number,#.#}%  {1}", lv, str.tostring(p, format.mintick)))

f_mk(label lb, bool on, int t, float p, string txt, color c) =>
    if on and not na(t) and not na(p)
        label.set_xy(lb, t, p)
        label.set_text(lb, txt)
        label.set_textcolor(lb, c)
        label.set_color(lb, color.new(color.black, 20))
        label.set_size(lb, size.small)
    else
        label.set_xy(lb, na, na)

if barstate.islast
    int aX1 = math.max(0, bar_index - annBack)
    int aX2 = math.min(bar_index + 500, bar_index + annFwd)
    int aLX = math.min(bar_index + 500, aX2 + labelGap)
    int wX1 = math.max(0, bar_index - wkBack)
    int wX2 = math.min(bar_index + 500, bar_index + wkFwd)
    int wLX = math.min(bar_index + 500, wX2 + labelGap)

    // ---- Layer 1 : annual ----
    for i = 0 to nL - 1
        ln = array.get(annLines, i)
        lb = array.get(annLabels, i)
        if showAnnual and not na(aH) and not na(aL)
            lv = array.get(levels, i)
            p  = f_price(aH, aL, aHt, aLt, lv)
            line.set_xy1(ln, aX1, p)
            line.set_xy2(ln, aX2, p)
            line.set_color(ln, colAnn)
            line.set_width(ln, annWidth)
            line.set_style(ln, f_lstyle(annStyle))
            f_style_label(lb, aLX, p, lv, colAnn, annLblSize)
        else
            f_hide(ln, lb)

    // ---- Layer 2 : previous week ----
    for i = 0 to nL - 1
        ln = array.get(wkLines, i)
        lb = array.get(wkLabels, i)
        if showWeekly and not na(wH) and not na(wL)
            lv = array.get(levels, i)
            p  = f_price(wH, wL, wHt, wLt, lv)
            col = wkColMode == "Multi-colour" ? array.get(wkPal, i) : colWk
            bool overlap = false
            if wkAutoDash and showAnnual and not na(aH) and not na(aL)
                eps = math.max(syminfo.mintick, math.abs(p) * 0.0002)
                for j = 0 to nL - 1
                    ap = f_price(aH, aL, aHt, aLt, array.get(levels, j))
                    if math.abs(p - ap) <= eps
                        overlap := true
                        break
            line.set_xy1(ln, wX1, p)
            line.set_xy2(ln, wX2, p)
            line.set_color(ln, col)
            line.set_width(ln, wkWidth)
            line.set_style(ln, overlap ? line.style_dashed : f_lstyle(wkStyle))
            f_style_label(lb, wLX, p, lv, col, wkLblSize)
        else
            f_hide(ln, lb)

    // ---- anchor markers ----
    f_mk(mkAH, showAnchors and showAnnual, aHt, aH, "Annual High " + f_px(aH), colAnn)
    f_mk(mkAL, showAnchors and showAnnual, aLt, aL, "Annual Low "  + f_px(aL), colAnn)
    f_mk(mkWH, showAnchors and showWeekly, wHt, wH, "Prev Wk High " + f_px(wH), colWk)
    f_mk(mkWL, showAnchors and showWeekly, wLt, wL, "Prev Wk Low "  + f_px(wL), colWk)

// =============================================================================
// PLOTS (price pane)
// =============================================================================
plot(showMA1 ? emaF : na, "EMA fast", color=colMA1, linewidth=ma1W, force_overlay=true)
plot(showMA2 ? emaS : na, "EMA slow", color=colMA2, linewidth=ma2W, force_overlay=true)

plot(showBB ? bbUpper : na, "BB Upper", color=colBB,  linewidth=bbW,  offset=bbShift, force_overlay=true)
plot(showBB ? bbLower : na, "BB Lower", color=colBB,  linewidth=bbW,  offset=bbShift, force_overlay=true)
plot(showBB ? bbBasis : na, "BB Basis", color=colBBm, linewidth=bbmW, offset=bbShift, force_overlay=true)

// Previous-week High / Low trend lines
plot(showPW ? wH : na, "Prev Week High", color=colPWH, linewidth=2, style=plot.style_stepline, force_overlay=true)
plot(showPW ? wL : na, "Prev Week Low",  color=colPWL, linewidth=2, style=plot.style_stepline, force_overlay=true)

// Trade lines
inTrade = useSignals and pos != 0
plot(showTradeLns and inTrade ? entryPx : na, "Entry", color=color.new(color.gray, 0),  linewidth=1, style=plot.style_linebr, force_overlay=true)
plot(showTradeLns and inTrade ? slPx    : na, "SL",    color=color.new(#F23645, 0),     linewidth=2, style=plot.style_linebr, force_overlay=true)
plot(showTradeLns and inTrade ? tpPx    : na, "TP",    color=color.new(#089981, 0),     linewidth=2, style=plot.style_linebr, force_overlay=true)

// Markers
plotshape(showHeadsUp and headsUpL, "Heads-up Long",  shape.circle, location.belowbar, color.new(#089981, 40), size=size.tiny, force_overlay=true)
plotshape(showHeadsUp and headsUpS, "Heads-up Short", shape.circle, location.abovebar, color.new(#F23645, 40), size=size.tiny, force_overlay=true)
plotshape(enterLong,  "Long entry",  shape.triangleup,   location.belowbar, #089981, text="LONG",  textcolor=#089981, size=size.small, force_overlay=true)
plotshape(enterShort, "Short entry", shape.triangledown, location.abovebar, #F23645, text="SHORT", textcolor=#F23645, size=size.small, force_overlay=true)
plotshape(blockedL, "Long blocked (ATR)",  shape.xcross, location.belowbar, color.new(color.gray, 30), size=size.tiny, force_overlay=true)
plotshape(blockedS, "Short blocked (ATR)", shape.xcross, location.abovebar, color.new(color.gray, 30), size=size.tiny, force_overlay=true)
plotshape(exitTP    and exitDir == 1,  "Long TP",     shape.labeldown, location.abovebar, #089981, text="TP", textcolor=color.white, size=size.tiny, force_overlay=true)
plotshape(exitSL    and exitDir == 1,  "Long SL",     shape.labeldown, location.abovebar, #F23645, text="SL", textcolor=color.white, size=size.tiny, force_overlay=true)
plotshape(exitEarly and exitDir == 1,  "Long early",  shape.labeldown, location.abovebar, #FF9800, text="EX", textcolor=color.white, size=size.tiny, force_overlay=true)
plotshape(exitTP    and exitDir == -1, "Short TP",    shape.labelup,   location.belowbar, #089981, text="TP", textcolor=color.white, size=size.tiny, force_overlay=true)
plotshape(exitSL    and exitDir == -1, "Short SL",    shape.labelup,   location.belowbar, #F23645, text="SL", textcolor=color.white, size=size.tiny, force_overlay=true)
plotshape(exitEarly and exitDir == -1, "Short early", shape.labelup,   location.belowbar, #FF9800, text="EX", textcolor=color.white, size=size.tiny, force_overlay=true)

// =============================================================================
// STOCHASTIC (this pane)
// =============================================================================
kSlow = ta.sma(ta.stoch(close, high, low, kLen), slowing)
dLine = ta.sma(kSlow, dLen)
plot(showStoch ? kSlow : na, "%K", color=colK, linewidth=1)
plot(showStoch ? dLine : na, "%D", color=colD, linewidth=1)
hline(obLvl, "Overbought", color=color.new(color.gray, 40), linestyle=hline.style_dashed)
hline(osLvl, "Oversold",   color=color.new(color.gray, 40), linestyle=hline.style_dashed)
hline(50,    "Mid",        color=color.new(color.gray, 70), linestyle=hline.style_dotted)

// =============================================================================
// ALERTS
// =============================================================================
// Simple conditions (pick individually in the Alerts dialog)
alertcondition(headsUpL,   "1. Heads-up LONG",   "Heads-up LONG: 8 EMA crossing BB mid / 21 EMA")
alertcondition(headsUpS,   "1. Heads-up SHORT",  "Heads-up SHORT: 8 EMA crossing BB mid / 21 EMA")
alertcondition(setupL,     "2. Setup LONG",      "Setup LONG: 8 EMA above BB mid and 21 EMA - waiting for qualifying close")
alertcondition(setupS,     "2. Setup SHORT",     "Setup SHORT: 8 EMA below BB mid and 21 EMA - waiting for qualifying close")
alertcondition(enterLong,  "3. Entry LONG",      "LONG entry signal")
alertcondition(enterShort, "3. Entry SHORT",     "SHORT entry signal")
alertcondition(exitTP or exitSL or exitEarly, "4. Exit (TP / SL / early)", "Trade exit signal")

// Detailed messages with prices (use "Any alert() function call")
if useSignals and useAlerts
    string tk = syminfo.ticker + " " + timeframe.period + ": "
    if headsUpL
        alert(tk + "HEADS-UP LONG - 8 EMA crossing BB mid / 21 EMA. BB mid " + f_px(bbBasis), alert.freq_once_per_bar_close)
    if headsUpS
        alert(tk + "HEADS-UP SHORT - 8 EMA crossing BB mid / 21 EMA. BB mid " + f_px(bbBasis), alert.freq_once_per_bar_close)
    if setupL
        alert(tk + "SETUP LONG - waiting for close above BB mid " + f_px(bbBasis), alert.freq_once_per_bar_close)
    if setupS
        alert(tk + "SETUP SHORT - waiting for close below BB mid " + f_px(bbBasis), alert.freq_once_per_bar_close)
    if enterLong
        alert(tk + "LONG @ " + f_px(entryPx) + " | SL " + f_px(slPx) + " | TP " + f_px(tpPx) + " | PW High " + f_px(wH), alert.freq_once_per_bar_close)
    if enterShort
        alert(tk + "SHORT @ " + f_px(entryPx) + " | SL " + f_px(slPx) + " | TP " + f_px(tpPx) + " | PW Low " + f_px(wL), alert.freq_once_per_bar_close)
    if exitTP
        alert(tk + (exitDir == 1 ? "LONG" : "SHORT") + " TP hit at BB band", alert.freq_once_per_bar_close)
    if exitSL
        alert(tk + (exitDir == 1 ? "LONG" : "SHORT") + " SL hit @ " + f_px(slPx), alert.freq_once_per_bar_close)
    if exitEarly
        alert(tk + (exitDir == 1 ? "LONG" : "SHORT") + " EARLY EXIT - 21 EMA crossed back through BB mid", alert.freq_once_per_bar_close)

// =============================================================================
// LEGEND / STATUS
// =============================================================================
var table lg = table.new(f_pos(legendPos), 1, 3, force_overlay=true, frame_color=color.new(color.gray, 50), frame_width=1)
if showLegend and barstate.islast
    table.cell(lg, 0, 0, "Annual Fib -> " + str.tostring(cy - 1), text_color=colAnn, text_size=f_size(legendSize), bgcolor=color.new(color.black, 80))
    wkStr = na(prevWkStart) ? "n/a" : str.format_time(prevWkStart, "yyyy-MM-dd", syminfo.timezone)
    table.cell(lg, 0, 1, "Prev-week Fib -> wk of " + wkStr, text_color=colWk, text_size=f_size(legendSize), bgcolor=color.new(color.black, 80))
    string st = "Flat"
    color  sc = color.gray
    if pos == 1
        st := "LONG @ " + f_px(entryPx) + "  SL " + f_px(slPx) + "  TP " + f_px(tpPx)
        sc := #089981
    else if pos == -1
        st := "SHORT @ " + f_px(entryPx) + "  SL " + f_px(slPx) + "  TP " + f_px(tpPx)
        sc := #F23645
    else if armDir == 1
        st := "Setup LONG - waiting for close"
        sc := #089981
    else if armDir == -1
        st := "Setup SHORT - waiting for close"
        sc := #F23645
    table.cell(lg, 0, 2, useSignals ? st : "Signals off", text_color=sc, text_size=f_size(legendSize), bgcolor=color.new(color.black, 80))
````
