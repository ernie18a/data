<!-- tradingview-pine-id: PUB;83bce0ad479f4c9caed1f79dcc4c200a -->
<!-- tradingviewscripts-format: 1 -->
# Multi-TF Fib + MA + BB + Stochastic

Source: https://www.tradingview.com/script/05uhdW2B-Morne-s-Multi-TF-Fib-MA-BB-Stochastic/

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

---

## Source Code

````pine
//@version=6
// =============================================================================
// Multi-Timeframe Fibonacci + MA + Bollinger Bands + Stochastic
// Pine v6  |  rev 4 (per-layer bars back/fwd + weekly single/multi colour)
// Separate pane hosts the Stochastic; price elements use force_overlay=true.
// =============================================================================

indicator("Multi-TF Fib + MA + BB + Stochastic", shorttitle="MTF Fib+MA+BB+Stoch", overlay=false, max_lines_count=100, max_labels_count=100)

// -------- TOGGLES --------
grpTgl  = "Toggles"
showAnnual = input.bool(true,  "Annual Fib (Yellow)", group=grpTgl)
showWeekly = input.bool(true,  "Weekly Fib",          group=grpTgl)
showMA1    = input.bool(true,  "MA #1",               group=grpTgl)
showMA2    = input.bool(true,  "MA #2",               group=grpTgl)
showBB     = input.bool(true,  "Bollinger Bands",     group=grpTgl)
showStoch  = input.bool(true,  "Stochastic",          group=grpTgl)
showLegend = input.bool(true,  "Anchor legend",       group=grpTgl)
showAnchors= input.bool(false, "Fib anchor markers",  group=grpTgl, tooltip="Tags the exact High/Low bar each Fib layer is anchored to.")

// -------- FIB SOURCE + SHARED LAYOUT --------
grpFib  = "Fibonacci - source & layout"
annTF     = input.timeframe("W",   "Annual Fib source TF", group=grpFib, tooltip="Layer 1 derived from this TF over the PREVIOUS calendar year.")
wkTF      = input.timeframe("240", "Weekly Fib source TF", group=grpFib, tooltip="Layer 2 derived from this TF over the CURRENT (rolling) week.")
labelGap  = input.int(3, "Label gap past right end (bars)", minval=0, maxval=50, group=grpFib)
labelBg   = input.bool(false, "Label background", group=grpFib)

grpAnn  = "Fibonacci - Annual"
colAnn     = input.color(#FFC000, "Colour",     group=grpAnn, inline="a")
annWidth   = input.int(1, "Width", minval=1, maxval=6, group=grpAnn, inline="a")
annStyle   = input.string("Solid", "Line",  options=["Solid","Dashed","Dotted"], group=grpAnn)
annLblSize = input.string("Small", "Labels", options=["Tiny","Small","Normal","Large"], group=grpAnn)
annBack    = input.int(80, "Bars back",    minval=0, maxval=5000, group=grpAnn, inline="ab")
annFwd     = input.int(10, "Bars forward", minval=0, maxval=500,  group=grpAnn, inline="ab")

grpWk   = "Fibonacci - Weekly"
wkColMode  = input.string("Single", "Colour mode", options=["Single","Multi-colour"], group=grpWk, tooltip="Single = one colour (below). Multi-colour = per-level palette.")
colWk      = input.color(#C00000, "Single colour", group=grpWk, inline="w")
wkWidth    = input.int(1, "Width", minval=1, maxval=6, group=grpWk, inline="w")
wkStyle    = input.string("Solid", "Line",  options=["Solid","Dashed","Dotted"], group=grpWk)
wkLblSize  = input.string("Tiny",  "Labels", options=["Tiny","Small","Normal","Large"], group=grpWk)
wkAutoDash = input.bool(false, "Dash where it overlaps an Annual level", group=grpWk)
wkBack     = input.int(30, "Bars back",    minval=0, maxval=5000, group=grpWk, inline="wb")
wkFwd      = input.int(10, "Bars forward", minval=0, maxval=500,  group=grpWk, inline="wb")

grpWkC  = "Fibonacci - Weekly level colours (Multi mode)"
cW0    = input.color(#787B86, "0%",     group=grpWkC, inline="c1")
cW236  = input.color(#F23645, "23.6%",  group=grpWkC, inline="c1")
cW50   = input.color(#FF9800, "50%",    group=grpWkC, inline="c2")
cW618  = input.color(#4CAF50, "61.8%",  group=grpWkC, inline="c2")
cW786  = input.color(#089981, "78.6%",  group=grpWkC, inline="c3")
cW886  = input.color(#00BCD4, "88.6%",  group=grpWkC, inline="c3")
cW100  = input.color(#787B86, "100%",   group=grpWkC, inline="c4")
cW127  = input.color(#2962FF, "127%",   group=grpWkC, inline="c4")
cW1618 = input.color(#9C27B0, "161.8%", group=grpWkC, inline="c5")
cWn127 = input.color(#E91E63, "-127%",  group=grpWkC, inline="c5")
cWn162 = input.color(#F23645, "-161.8%",group=grpWkC, inline="c6")

// -------- MOVING AVERAGES --------
grpMA   = "Moving Averages"
ma1Len  = input.int(21,  "MA #1 length", minval=1, group=grpMA, inline="m1")
ma1Meth = input.string("SMA", "", options=["SMA","EMA","SMMA (RMA)","LWMA (WMA)"], group=grpMA, inline="m1")
colMA1  = input.color(#C00000, "", group=grpMA, inline="m1")
ma1W    = input.int(1, "W", minval=1, maxval=6, group=grpMA, inline="m1")
ma2Len  = input.int(100, "MA #2 length", minval=1, group=grpMA, inline="m2")
ma2Meth = input.string("SMA", "", options=["SMA","EMA","SMMA (RMA)","LWMA (WMA)"], group=grpMA, inline="m2")
colMA2  = input.color(#1F4E79, "", group=grpMA, inline="m2")
ma2W    = input.int(2, "W", minval=1, maxval=6, group=grpMA, inline="m2")

// -------- BOLLINGER BANDS --------
grpBB   = "Bollinger Bands"
bbLen   = input.int(20, "Period",  minval=1, group=grpBB)
bbShift = input.int(0,  "Shift",             group=grpBB)
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

// -------- LEGEND --------
grpLg   = "Legend"
legendPos  = input.string("Top Left", "Position", options=["Top Left","Top Right","Bottom Left","Bottom Right"], group=grpLg)
legendSize = input.string("Normal", "Text size", options=["Tiny","Small","Normal","Large"], group=grpLg)

// -------- MAPPERS --------
f_lstyle(string s) => s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid
f_size(string s)   => s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : s == "Large" ? size.large : size.small
f_pos(string p)    => p == "Top Right" ? position.top_right : p == "Bottom Left" ? position.bottom_left : p == "Bottom Right" ? position.bottom_right : position.top_left

// -------- FIB LEVELS + weekly palette --------
var array<float> levels = array.from(0.0, 23.6, 50.0, 61.8, 78.6, 88.6, 100.0, 127.0, 161.8, -127.0, -161.8)
var array<color> wkPal  = array.from(cW0, cW236, cW50, cW618, cW786, cW886, cW100, cW127, cW1618, cWn127, cWn162)
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

// -------- LAYER 2 : Weekly (current rolling week) --------
f_weekly() =>
    int wid = math.floor((time - 345600000) / 604800000)
    var float h = na, var float l = na, var int ht = na, var int lt = na
    bool newWeek = wid != wid[1]
    if newWeek
        h := high, l := low, ht := time, lt := time
    else
        if na(h) or high > h
            h := high, ht := time
        if na(l) or low < l
            l := low, lt := time
    [h, l, ht, lt]
[wH, wL, wHt, wLt] = request.security(syminfo.tickerid, wkTF, f_weekly())

int cy = year(time)
int cwid = math.floor((time - 345600000) / 604800000)
var int wWeekStartTime = na
if barstate.isfirst
    wWeekStartTime := time
else if cwid != cwid[1]
    wWeekStartTime := time

// -------- Drawing objects --------
var array<line>  annLines  = array.new<line>()
var array<label> annLabels = array.new<label>()
var array<line>  wkLines    = array.new<line>()
var array<label> wkLabels   = array.new<label>()
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
    // per-layer bar windows (clamped to valid range)
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

    // ---- Layer 2 : weekly ----
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
    f_mk(mkAH, showAnchors and showAnnual, aHt, aH, "Annual High " + str.tostring(aH, format.mintick), colAnn)
    f_mk(mkAL, showAnchors and showAnnual, aLt, aL, "Annual Low "  + str.tostring(aL, format.mintick), colAnn)
    f_mk(mkWH, showAnchors and showWeekly, wHt, wH, "Wk High " + str.tostring(wH, format.mintick), colWk)
    f_mk(mkWL, showAnchors and showWeekly, wLt, wL, "Wk Low "  + str.tostring(wL, format.mintick), colWk)

// -------- MOVING AVERAGES --------
f_ma(float src, int len, string m) =>
    switch m
        "EMA"        => ta.ema(src, len)
        "SMMA (RMA)" => ta.rma(src, len)
        "LWMA (WMA)" => ta.wma(src, len)
        => ta.sma(src, len)
plot(showMA1 ? f_ma(close, ma1Len, ma1Meth) : na, "MA #1", color=colMA1, linewidth=ma1W, force_overlay=true)
plot(showMA2 ? f_ma(close, ma2Len, ma2Meth) : na, "MA #2", color=colMA2, linewidth=ma2W, force_overlay=true)

// -------- BOLLINGER BANDS --------
bbBasis = ta.sma(close, bbLen)
bbD     = bbDev * ta.stdev(close, bbLen)
plot(showBB ? bbBasis + bbD : na, "BB Upper", color=colBB,  linewidth=bbW,  offset=bbShift, force_overlay=true)
plot(showBB ? bbBasis - bbD : na, "BB Lower", color=colBB,  linewidth=bbW,  offset=bbShift, force_overlay=true)
plot(showBB ? bbBasis       : na, "BB Basis", color=colBBm, linewidth=bbmW, offset=bbShift, force_overlay=true)

// -------- STOCHASTIC (this pane) --------
kSlow = ta.sma(ta.stoch(close, high, low, kLen), slowing)
dLine = ta.sma(kSlow, dLen)
plot(showStoch ? kSlow : na, "%K", color=colK, linewidth=1)
plot(showStoch ? dLine : na, "%D", color=colD, linewidth=1)
hline(obLvl, "Overbought", color=color.new(color.gray, 40), linestyle=hline.style_dashed)
hline(osLvl, "Oversold",   color=color.new(color.gray, 40), linestyle=hline.style_dashed)
hline(50,    "Mid",        color=color.new(color.gray, 70), linestyle=hline.style_dotted)

// -------- LEGEND --------
var table lg = table.new(f_pos(legendPos), 1, 2, force_overlay=true, frame_color=color.new(color.gray, 50), frame_width=1)
if showLegend and barstate.islast
    table.cell(lg, 0, 0, "Annual Fib -> " + str.tostring(cy - 1), text_color=colAnn, text_size=f_size(legendSize), bgcolor=color.new(color.black, 80))
    wkStr = na(wWeekStartTime) ? "n/a" : str.format_time(wWeekStartTime, "yyyy-MM-dd", syminfo.timezone)
    table.cell(lg, 0, 1, "Weekly Fib -> wk of " + wkStr, text_color=colWk, text_size=f_size(legendSize), bgcolor=color.new(color.black, 80))
````
