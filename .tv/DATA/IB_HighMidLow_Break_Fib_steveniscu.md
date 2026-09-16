<!-- tradingview-pine-id: PUB;be4ee572ce4547bb86be86ced914d43b -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# IB High/Mid/Low + Break Fib (steveniscu)

Source: https://www.tradingview.com/script/T1AadQ7m-IB-FIB-CUCAP/

## Description

Here's a plain-English description of what IB High/Mid/Low + Break Fib (steveniscu) does — useful either as your own reference or as copy for the TradingView "Description" box if you publish it:

What it does

Marks out the Initial Balance (IB) — the high and low of the first 30 minutes of the session (9:30–10:00 AM ET / 8:30–9:00 AM CT by default) — and plots three static levels once that window closes: IB High, IB Low, and IB Mid (the 50% midpoint).

From there, it watches for the first time price closes outside that range in either direction. Whichever side breaks first becomes the "dominant" direction for the day — only that side's fib gets drawn, even if price later reverses and tags the opposite extreme too. This keeps the chart clean and reflects the idea that the first break sets the day's character (initiative/trend vs. failed break back to balance).

Once a dominant break happens, it draws a live fib retracement anchored between the IB extreme on the origin side and the developing swing extreme on the breakout side — so as a downside break keeps making lower lows, the retracement recalculates and slides down with it. It shows 0.786, 0.618, 0.5, and 0.382, plus optional "1"/"0" anchor labels and a dashed connector line showing the leg being measured.

The 0.618–0.65 zone (the "golden pocket") gets a translucent yellow box overlay that resizes along with the rest of the fib, so the highest-probability pullback re-entry zone is visually obvious at a glance.

Inputs

IB session window and timezone
Toggle for IB Mid
Toggle for the break-fib, anchor labels, and connector line
Golden zone toggle plus adjustable low/high ratio bounds (default 0.618/0.65)
Line width, label size, extend-right styling

Trading logic it encodes: the IB is the first "honest" value area of the day. A hold outside it signals a trend day and gives you a real, high-volume leg to measure a fib retracement from for pullback entries — rather than drawing fibs on arbitrary swings.

---

## Source Code

````pine
//@version=6
indicator("IB High/Mid/Low + Break Fib (steveniscu)", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=100)

// ============================================================
// INPUTS
// ============================================================
grpIB = "Initial Balance"
ibSession  = input.session("0930-1000", "IB Session (Opening Range)", group=grpIB)
ibTimezone = input.string("America/New_York", "Session Timezone", group=grpIB)
showIBMid  = input.bool(true, "Show IB Mid", group=grpIB)

grpFib = "Fib on IB Break (dominant direction only)"
showBreakFib  = input.bool(true, "Show Fib Retracement on Break", group=grpFib)
showAnchors   = input.bool(true, "Show 0 / 1 Anchor Lines", group=grpFib)
showConnector = input.bool(true, "Show Diagonal Connector Line", group=grpFib)

grpGolden = "Golden Zone"
showGoldenZone = input.bool(true, "Highlight 0.618 Golden Zone", group=grpGolden)
goldenZoneLow  = input.float(0.618, "Golden Zone Low Ratio", minval=0.0, maxval=1.0, step=0.001, group=grpGolden)
goldenZoneHigh = input.float(0.65,  "Golden Zone High Ratio", minval=0.0, maxval=1.0, step=0.001, group=grpGolden)

grpStyle = "Style"
extendRight = input.bool(true, "Extend Lines Right", group=grpStyle)
lineWidth   = input.int(1, "Line Width", minval=1, maxval=4, group=grpStyle)
labelSize   = input.string(size.small, "Label Size", options=[size.tiny, size.small, size.normal], group=grpStyle)

extendStyle = extendRight ? extend.right : extend.none

colIB        = color.new(color.yellow, 0)
colIBMid     = color.new(color.yellow, 55)
col786       = color.new(color.aqua, 0)
col618       = color.new(color.aqua, 0)
col50        = color.new(color.white, 0)
col382       = color.new(color.aqua, 0)
colAnchor    = color.new(color.gray, 30)
colConnector = color.new(color.white, 40)
colGolden    = color.new(color.yellow, 75)
colGoldenBorder = color.new(color.yellow, 20)

// ============================================================
// HELPERS
// ============================================================
clearArr(line[] lineArr, label[] labelArr) =>
    while array.size(lineArr) > 0
        line.delete(array.pop(lineArr))
    while array.size(labelArr) > 0
        label.delete(array.pop(labelArr))

clearBoxArr(box[] boxArr) =>
    while array.size(boxArr) > 0
        box.delete(array.pop(boxArr))

drawLevel(line[] lineArr, label[] labelArr, float price, color col, string txt, int fromBar, bool dashed) =>
    lstyle = dashed ? line.style_dashed : line.style_solid
    l  = line.new(x1=fromBar, y1=price, x2=bar_index, y2=price, xloc=xloc.bar_index, extend=extendStyle, color=col, width=lineWidth, style=lstyle)
    lb = label.new(x=bar_index, y=price, text=txt + "  " + str.tostring(price, format.mintick), style=label.style_label_left, textcolor=col, color=color.new(color.black, 100), size=labelSize)
    array.push(lineArr, l)
    array.push(labelArr, lb)

// ============================================================
// IB TRACKING (High / Low, and which bar each occurred on)
// ============================================================
inIB     = not na(time(timeframe.period, ibSession, ibTimezone))
newIBBar = inIB and not inIB[1]
ibEnded  = inIB[1] and not inIB

var float ibHigh     = na
var float ibLow      = na
var int   ibHighBar  = na
var int   ibLowBar   = na
var int   ibStartBar = na

if newIBBar
    ibHigh     := high
    ibLow      := low
    ibHighBar  := bar_index
    ibLowBar   := bar_index
    ibStartBar := bar_index

if inIB
    if high > ibHigh
        ibHigh    := high
        ibHighBar := bar_index
    if low < ibLow
        ibLow    := low
        ibLowBar := bar_index

ibDone = not inIB and not na(ibHigh)

// ============================================================
// STATIC IB LEVEL DRAWINGS
// ============================================================
var line[]  ibLines  = array.new_line()
var label[] ibLabels = array.new_label()

if newIBBar
    clearArr(ibLines, ibLabels)

if ibEnded
    drawLevel(ibLines, ibLabels, ibHigh, colIB, "IB High", ibStartBar, false)
    drawLevel(ibLines, ibLabels, ibLow,  colIB, "IB Low",  ibStartBar, false)
    if showIBMid
        drawLevel(ibLines, ibLabels, (ibHigh + ibLow) / 2, colIBMid, "IB Mid", ibStartBar, false)

// ============================================================
// BREAKOUT STATE — resets each new IB session
// dominantDir locks in whichever side breaks first; the other
// side is never drawn for the rest of that IB session.
// ============================================================
var string dominantDir    = "none"
var float  runningLow     = na
var float  runningHigh    = na
var int    runningLowBar  = na
var int    runningHighBar = na

var line[]  breakLines  = array.new_line()
var label[] breakLabels = array.new_label()
var box[]   goldenBoxes = array.new_box()

if newIBBar
    dominantDir    := "none"
    runningLow     := na
    runningHigh    := na
    runningLowBar  := na
    runningHighBar := na
    clearArr(breakLines, breakLabels)
    clearBoxArr(goldenBoxes)

// ============================================================
// DRAW / REFRESH THE ACTIVE (DOMINANT) BREAK-FIB
// anchor "1" = high side price, "0" = low side price
// ============================================================
drawBreakFib(float anchor1Price, int anchor1Bar, float anchor0Price, int anchor0Bar) =>
    clearArr(breakLines, breakLabels)
    clearBoxArr(goldenBoxes)
    rangeAmt = anchor1Price - anchor0Price
    fromBar  = math.min(anchor1Bar, anchor0Bar)
    if showAnchors
        drawLevel(breakLines, breakLabels, anchor1Price, colAnchor, "1", fromBar, true)
        drawLevel(breakLines, breakLabels, anchor0Price, colAnchor, "0", fromBar, true)
    if showConnector
        cl = line.new(x1=anchor1Bar, y1=anchor1Price, x2=anchor0Bar, y2=anchor0Price, xloc=xloc.bar_index, color=colConnector, width=1, style=line.style_dashed)
        array.push(breakLines, cl)
    if rangeAmt != 0
        drawLevel(breakLines, breakLabels, anchor0Price + rangeAmt * 0.786, col786, "0.786", fromBar, false)
        drawLevel(breakLines, breakLabels, anchor0Price + rangeAmt * 0.618, col618, "0.618", fromBar, false)
        drawLevel(breakLines, breakLabels, anchor0Price + rangeAmt * 0.5,   col50,  "0.5",   fromBar, false)
        drawLevel(breakLines, breakLabels, anchor0Price + rangeAmt * 0.382, col382, "0.382", fromBar, false)

        if showGoldenZone
            gzLow  = anchor0Price + rangeAmt * math.min(goldenZoneLow, goldenZoneHigh)
            gzHigh = anchor0Price + rangeAmt * math.max(goldenZoneLow, goldenZoneHigh)
            gb = box.new(left=fromBar, top=gzHigh, right=bar_index, bottom=gzLow, xloc=xloc.bar_index, extend=extendStyle, bgcolor=colGolden, border_color=colGoldenBorder, border_width=1)
            array.push(goldenBoxes, gb)

// ============================================================
// BREAKOUT DETECTION — only the dominant (first) direction draws
// ============================================================
if showBreakFib and ibDone
    if dominantDir == "none"
        if low < ibLow
            dominantDir := "down"
        else if high > ibHigh
            dominantDir := "up"

    if dominantDir == "down"
        if na(runningLow)
            runningLow    := low
            runningLowBar := bar_index
            drawBreakFib(ibHigh, ibHighBar, runningLow, runningLowBar)
        else if low < runningLow
            runningLow    := low
            runningLowBar := bar_index
            drawBreakFib(ibHigh, ibHighBar, runningLow, runningLowBar)

    if dominantDir == "up"
        if na(runningHigh)
            runningHigh    := high
            runningHighBar := bar_index
            drawBreakFib(runningHigh, runningHighBar, ibLow, ibLowBar)
        else if high > runningHigh
            runningHigh    := high
            runningHighBar := bar_index
            drawBreakFib(runningHigh, runningHighBar, ibLow, ibLowBar)
````
