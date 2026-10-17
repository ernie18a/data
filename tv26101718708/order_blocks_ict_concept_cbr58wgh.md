# Order Blocks (ICT Concept)

- url: https://www.tradingview.com/script/cbR58WGh-Order-Blocks-ICT-Concept/
- type: indicator
- pine_id: PUB;2cd97290a531416eb1cfc6bd8c4c9232
- version: 3.0

## Description

[b]Order Blocks (ICT Concept)[/b]

This indicator identifies potential Order Blocks based on the ICT (Inner Circle Trader) methodology. An Order Block represents a price zone where institutional orders were likely placed, causing a significant directional move.

[b]How it works:[/b]

[list]
[*][b]Bullish Order Block [/b]— Identified when price makes a higher high (break of prior swing high), signalling a structural shift to the upside. The OB zone is the last bearish (down-close) candle before the swing low that preceded the breakout — the area where buying pressure originated.
[*][b]Bearish Order Block[/b] — Identified when price makes a lower low (break of prior swing low), signalling a structural shift to the downside. The OB zone is the last bullish (up-close) candle before the swing high that preceded the breakdown.
[/list]
Each OB box extends from the OB candle's relevant edge to the swing extreme, covering the full zone where orders were concentrated. OBs are automatically removed when price closes through them (mitigation).

[b]Settings:[/b]

[list]
[*]Swing Pivot Bars — Controls how significant a swing must be to qualify
[*]Max OB Age — Removes OBs older than a set number of bars
[*]Max OBs Shown — Show only the most recent N OBs per direction
[*]Swing Dots — Optional overlay of swing highs and lows
[/list]
[b]Disclaimer[/b]: This indicator is [i]built based on my personal understanding of the ICT Order Block concept[/i]. The interpretation and implementation may not be perfectly aligned with the original ICT teachings. I could be wrong — always do your own research

## Source Code

````pine
//@version=6
indicator("Order Blocks (ICT Concept)", overlay=true, max_boxes_count=200, max_lines_count=500)

// ── Visuals ───────────────────────────────────────────────────────────────────
showBullOBs  = input.bool(true,  "Show Bullish OBs")
bullObColor  = input.color(color.new(color.green, 80), "Bullish OB Color")
showBearOBs  = input.bool(true,  "Show Bearish OBs")
bearObColor  = input.color(color.new(color.red,   80), "Bearish OB Color")
showMidline  = input.bool(true, "Show 50% Midline")

// ── Structure ─────────────────────────────────────────────────────────────────
swingLen     = input.int(3,   "Swing Pivot Bars (each side)", minval=1, maxval=10, group="Structure",
               tooltip="Bars required on each side of a pivot to confirm a swing high/low.")
maxBars      = input.int(100, "Max OB Age (bars)",            minval=10, maxval=500, group="Structure",
               tooltip="OB candles older than this many bars are ignored.")
maxBullOBs   = input.int(1,   "Max Bullish OBs Shown", minval=1, maxval=10, group="Structure",
               tooltip="Max bullish OBs shown at once. Set to 1 to see only the most recent bullish OB.")
maxBearOBs   = input.int(1,   "Max Bearish OBs Shown", minval=1, maxval=10, group="Structure",
               tooltip="Max bearish OBs shown at once. Set to 1 to see only the most recent bearish OB.")

// ── Swing Dots ────────────────────────────────────────────────────────────────
showSwingDots  = input.bool(false,        "Show Swing Dots",      group="Swing Dots")
swingHighColor = input.color(color.red,   "Swing High Dot Color", group="Swing Dots")
swingLowColor  = input.color(color.green, "Swing Low Dot Color",  group="Swing Dots")
dotSizeInput   = input.string("small",    "Dot Size",             group="Swing Dots",
               options=["tiny", "small", "normal", "large", "huge"])

// ── Swing Pivot Detection ─────────────────────────────────────────────────────
pivHigh = ta.pivothigh(high, swingLen, swingLen)
pivLow  = ta.pivotlow (low,  swingLen, swingLen)

// Track last two swing highs/lows (price + bar index of actual pivot)
var float lastSwingHigh    = na
var float lastSwingLow     = na
var float prevSwingHigh    = na
var float prevSwingLow     = na
var int   lastSwingHighBar = na  // actual bar index of the pivot candle
var int   lastSwingLowBar  = na

if not na(pivHigh)
    prevSwingHigh    := lastSwingHigh
    lastSwingHigh    := pivHigh
    lastSwingHighBar := bar_index - swingLen

if not na(pivLow)
    prevSwingLow    := lastSwingLow
    lastSwingLow    := pivLow
    lastSwingLowBar := bar_index - swingLen

// ── OB State Arrays ───────────────────────────────────────────────────────────
var box[]   obBoxes    = array.new<box>()
var line[]  obMidLines = array.new<line>()
var line[]  obTopLines = array.new<line>()
var line[]  obBotLines = array.new<line>()
var float[] obTop      = array.new<float>()
var float[] obBot      = array.new<float>()
var bool[]  obIsBull   = array.new<bool>()
var int[]   obLeft     = array.new<int>()

// ── Alert Flags ───────────────────────────────────────────────────────────────
var bool newBullOB = false
var bool newBearOB = false
newBullOB := false
newBearOB := false

// ── Derived Colors ────────────────────────────────────────────────────────────
bullMidColor = showMidline ? color.new(color.green, 40) : color(na)
bearMidColor = showMidline ? color.new(color.red,   40) : color(na)

// ── Sync Colors + Extend All Active OBs Right ────────────────────────────────
// Visibility: only show the N most recent OBs per direction (by obLeft bar index)
if array.size(obBoxes) > 0
    for i = 0 to array.size(obBoxes) - 1
        isBull   = array.get(obIsBull, i)
        thisLeft = array.get(obLeft,   i)
        maxCount = isBull ? maxBullOBs : maxBearOBs
        // Count how many OBs of the same direction are newer than this one
        newerCount = 0
        for j = 0 to array.size(obBoxes) - 1
            if array.get(obIsBull, j) == isBull and array.get(obLeft, j) > thisLeft
                newerCount += 1
        showDir = isBull ? showBullOBs : showBearOBs
        visible = showDir and newerCount < maxCount
        b  = array.get(obBoxes,    i)
        ml = array.get(obMidLines, i)
        edgeColor = visible ? (isBull ? color.new(bullObColor, 40) : color.new(bearObColor, 40)) : color(na)
        tl = array.get(obTopLines, i)
        bl = array.get(obBotLines, i)
        box.set_right(b, bar_index)
        box.set_bgcolor(b,      visible ? (isBull ? bullObColor : bearObColor) : color(na))
        box.set_border_color(b, color(na))
        line.set_x2(tl, bar_index)
        line.set_color(tl, edgeColor)
        line.set_x2(bl, bar_index)
        line.set_color(bl, edgeColor)
        line.set_x2(ml, bar_index)
        line.set_color(ml, visible ? (isBull ? bullMidColor : bearMidColor) : color(na))

// ── Mitigation + Expiry: remove OB when price closes beyond zone or age exceeded ──
if array.size(obBoxes) > 0
    for i = array.size(obBoxes) - 1 to 0
        isBull  = array.get(obIsBull, i)
        tooOld  = (bar_index - array.get(obLeft, i)) > maxBars
        hit     = isBull ? close < array.get(obBot, i) : close > array.get(obTop, i)
        if hit or tooOld
            box.delete(array.get(obBoxes,    i))
            line.delete(array.get(obMidLines, i))
            line.delete(array.get(obTopLines, i))
            line.delete(array.get(obBotLines, i))
            array.remove(obBoxes,    i)
            array.remove(obMidLines, i)
            array.remove(obTopLines, i)
            array.remove(obBotLines, i)
            array.remove(obTop,      i)
            array.remove(obBot,      i)
            array.remove(obIsBull,   i)
            array.remove(obLeft,     i)

// ── Helper: draw one OB ───────────────────────────────────────────────────────
drawOB(leftBar, obH, obL, isBull) =>
    obColor  = isBull ? bullObColor : bearObColor
    midColor = isBull ? bullMidColor : bearMidColor
    lbl      = isBull ? "OB+" : "OB-"
    txtColor = isBull ? color.new(color.green, 20) : color.new(color.red, 20)
    obM      = (obH + obL) / 2
    edgeColor = color.new(obColor, 40)
    b  = box.new(leftBar, obH, bar_index, obL,
         border_color=color(na), bgcolor=obColor, border_width=0,
         text=lbl, text_color=txtColor, text_size=size.small,
         text_halign=text.align_right, text_valign=text.align_center)
    tl = line.new(leftBar, obH, bar_index, obH, color=edgeColor, style=line.style_solid)
    bl = line.new(leftBar, obL, bar_index, obL, color=edgeColor, style=line.style_solid)
    ml = line.new(leftBar, obM, bar_index, obM, color=midColor,  style=line.style_dashed)
    array.push(obBoxes,    b)
    array.push(obMidLines, ml)
    array.push(obTopLines, tl)
    array.push(obBotLines, bl)
    array.push(obTop,      obH)
    array.push(obBot,      obL)
    array.push(obIsBull,   isBull)
    array.push(obLeft,     leftBar)

// ── Helper: check if zone already violated between now and a past bar ─────────
alreadyMitigated(obH, obL, isBull, window) =>
    hit = false
    for j = 0 to window
        if isBull ? close[j] < obL : close[j] > obH
            hit := true
            break
    hit

// ── Helper: duplicate check ───────────────────────────────────────────────────
isDuplicate(leftBar, isBull) =>
    dup = false
    if array.size(obLeft) > 0
        for k = 0 to array.size(obLeft) - 1
            if array.get(obLeft, k) == leftBar and array.get(obIsBull, k) == isBull
                dup := true
                break
    dup

// ═══════════════════════════════════════════════════════════════════════════════
// BULLISH OB — confirmed when a HIGHER HIGH is made
// Logic: swing low occurred → price then breaks above previous swing high
// OB candle = last down-close candle at or before that swing low
// ═══════════════════════════════════════════════════════════════════════════════
if not na(pivHigh) and not na(prevSwingHigh) and pivHigh > prevSwingHigh and not na(lastSwingLowBar)
    startJ = bar_index - lastSwingLowBar  // offset to the swing low candle
    if startJ >= 0 and startJ <= maxBars
        obIdx = -1
        for j = startJ to startJ + maxBars
            if open[j] > close[j]
                obIdx := j
                break

        if obIdx >= 0
            leftBar = bar_index - obIdx
            if (bar_index - leftBar) <= maxBars and not isDuplicate(leftBar, true)
                obH = high[obIdx]
                obL = math.min(low[obIdx], low[bar_index - lastSwingLowBar])
                if not alreadyMitigated(obH, obL, true, bar_index - lastSwingLowBar)
                    drawOB(leftBar, obH, obL, true)
                    newBullOB := true

// ═══════════════════════════════════════════════════════════════════════════════
// BEARISH OB — confirmed when a LOWER LOW is made
// Logic: swing high occurred → price then breaks below previous swing low
// OB candle = last up-close candle at or before that swing high
// ═══════════════════════════════════════════════════════════════════════════════
if not na(pivLow) and not na(prevSwingLow) and pivLow < prevSwingLow and not na(lastSwingHighBar)
    startJ = bar_index - lastSwingHighBar  // offset to the swing high candle
    if startJ >= 0 and startJ <= maxBars
        obIdx = -1
        for j = startJ to startJ + maxBars
            if close[j] > open[j]
                obIdx := j
                break

        if obIdx >= 0
            leftBar = bar_index - obIdx
            if (bar_index - leftBar) <= maxBars and not isDuplicate(leftBar, false)
                obH = math.max(high[obIdx], high[bar_index - lastSwingHighBar])
                obL = low[obIdx]
                if not alreadyMitigated(obH, obL, false, bar_index - lastSwingHighBar)
                    drawOB(leftBar, obH, obL, false)
                    newBearOB := true

// ── Swing Dots ────────────────────────────────────────────────────────────────
plotshape(showSwingDots and not na(pivHigh) and dotSizeInput == "tiny",   style=shape.circle, location=location.abovebar, color=swingHighColor, size=size.tiny,   offset=-swingLen, editable=false, display=display.pane)
plotshape(showSwingDots and not na(pivHigh) and dotSizeInput == "small",  style=shape.circle, location=location.abovebar, color=swingHighColor, size=size.small,  offset=-swingLen, editable=false, display=display.pane)
plotshape(showSwingDots and not na(pivHigh) and dotSizeInput == "normal", style=shape.circle, location=location.abovebar, color=swingHighColor, size=size.normal, offset=-swingLen, editable=false, display=display.pane)
plotshape(showSwingDots and not na(pivHigh) and dotSizeInput == "large",  style=shape.circle, location=location.abovebar, color=swingHighColor, size=size.large,  offset=-swingLen, editable=false, display=display.pane)
plotshape(showSwingDots and not na(pivHigh) and dotSizeInput == "huge",   style=shape.circle, location=location.abovebar, color=swingHighColor, size=size.huge,   offset=-swingLen, editable=false, display=display.pane)

plotshape(showSwingDots and not na(pivLow)  and dotSizeInput == "tiny",   style=shape.circle, location=location.belowbar, color=swingLowColor,  size=size.tiny,   offset=-swingLen, editable=false, display=display.pane)
plotshape(showSwingDots and not na(pivLow)  and dotSizeInput == "small",  style=shape.circle, location=location.belowbar, color=swingLowColor,  size=size.small,  offset=-swingLen, editable=false, display=display.pane)
plotshape(showSwingDots and not na(pivLow)  and dotSizeInput == "normal", style=shape.circle, location=location.belowbar, color=swingLowColor,  size=size.normal, offset=-swingLen, editable=false, display=display.pane)
plotshape(showSwingDots and not na(pivLow)  and dotSizeInput == "large",  style=shape.circle, location=location.belowbar, color=swingLowColor,  size=size.large,  offset=-swingLen, editable=false, display=display.pane)
plotshape(showSwingDots and not na(pivLow)  and dotSizeInput == "huge",   style=shape.circle, location=location.belowbar, color=swingLowColor,  size=size.huge,   offset=-swingLen, editable=false, display=display.pane)

// ── Alerts ────────────────────────────────────────────────────────────────────
alertcondition(newBullOB, "Bullish OB Formed", "New Bullish Order Block identified")
alertcondition(newBearOB, "Bearish OB Formed", "New Bearish Order Block identified")
````
