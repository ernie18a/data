# STA FVG Locator

- url: https://www.tradingview.com/script/CbqpJ3MW-STA-FVG-Locator/
- type: indicator
- pine_id: PUB;f48f2431b81a4612b15a20e3cb663134
- version: 2.0

## Description

Marks the current unfilled fair value gap and the structural levels around it, so the zone you would work and the level price is drawing toward are both on screen at once.

This is a locator, not a signal tool. It reports measurements. It does not grade setups, score quality, or tell you when to trade.

What it draws

Three things, all belonging to one gap:

[list]
[*]The nearest unfilled gap, as a shaded box with a midline. When more than one gap is on screen, the one the panel describes keeps a solid, full strength midline and the others are faded, so there is never doubt which gap the numbers refer to.
[*]Gap Swing, the swing that preceded the displacement which created the gap. A bullish gap takes the swing low before the move up, a bearish gap the swing high before the move down. Captured when the gap forms and fixed from then on.
[*]Next Liquidity, the nearest swing level price has not yet traded through, on the side the gap's own type implies. Below for a bearish gap, above for a bullish one. The gap chooses the side, not a directional filter.
[/list]

The panel

Gap, Size, Mid, Distance, Swing, Next Liq, and Swing : Liq. Hover any row for its definition.

Mid is snapped to the instrument's tick grid so it is a price an order can actually rest at, and Distance and the ratio are computed from that same snapped value.

Swing : Liq is the ratio of two measured distances from the midline: midline to Gap Swing against midline to Next Liquidity. It is arithmetic on two landmarks. It is deliberately not labeled risk to reward, because what counts as risk is the trader's decision and not the indicator's.

Unfilled and untested

A gap stays on the board until price trades through its far edge. A wick into the gap is a partial fill and leaves it live, which matters because that wick is often where you would be working from.

Swing levels are tracked until price trades through them, then dropped. Next Liquidity therefore only ever points at a level that has not been taken.

Settings

Gaps shown per side, unfilled only or all recent, the full color palette, label sizes, label lane spacing, gap box extension, and dashboard position, size and visibility.

Used by members of the Sisterhood Trading Academy

## Source Code

````pine
//@version=6
// Indicator: STA FVG Locator
// VERSION 1.0 (2026-10-04)
// Derived from "TR FVG & Swing High Low Finder" by traderriazofficial (original copyright (c)).
//
// FIXES vs original (see review notes):
//   1. Untested-swing arrays are now PRUNED (tested swings are removed, not flagged)
//      + hard-capped  -> kills the O(n^2) per-bar scan that caused the timeout on 1m/3m.
//   2. All drawing/deleting now happens ONLY on the last bar (barstate.islast).
//   3. FVG box top/bottom were swapped (top held the LOWER price). Now correct.
//   4. Loop guards moved OUTSIDE the loops (for i = 0 to size-1 counts DOWN when size = 0).
//   5. Dead comparison to "Next Liquidity Target" removed.
//   6. Stale `var` nearest-swing state removed.
//   7. max_boxes/lines/labels raised so higher input limits don't silently drop drawings.
//   8. 5-SMA direction filter DROPPED - both liquidity sides are reported instead.
//   9. Gap fill tracking added; panel reports landmarks only (see DEFINITION KEY).
//  10. Swing High / Swing Low RESTORED as optional structure (Oct 4). They sit in
//      the near label lane; Gap Swing and Next Liquidity sit further out.

// ============================ DEFINITION KEY =================================
// This indicator REPORTS structural landmarks. It does not name trades, place
// stops, or grade setups. Every term below is an observation about price.
//
//   FVG (fair value gap)  Three-bar imbalance. Bullish: high[2] < low.
//                         Bearish: low[2] > high.
//   UNFILLED              Price has not traded through the gap's far edge.
//                         A wick INTO the gap is a partial fill; still unfilled.
//   MIDLINE               The middle of the gap, snapped to the instrument's tick
//                         grid. A gap's true centre can fall on a half tick; the
//                         snapped value is what the panel shows, what the line is
//                         drawn at, and what DISTANCE and SWING : LIQUIDITY are
//                         computed from. A reference level, not an entry instruction.
//   DISTANCE              Current price minus the midline. Signed: positive means
//                         price is above the midline, negative means below.
//   SWING / ORIGIN SWING  The swing that preceded the displacement which created
//                         the gap. Bullish gap -> the swing LOW before the move up.
//                         Bearish gap -> the swing HIGH before the move down.
//                         Captured when the gap forms; it never moves afterward.
//                         Panel row: "Swing". Chart label: "Gap Swing".
//   UNTESTED (swing)      Price has not yet traded through that swing level. Tracked
//                         internally; only the nearest one is drawn (Next Liquidity).
//   NEXT LIQUIDITY        Nearest untested swing level price has not yet reached, on
//                         the side this gap's own type implies - below for a bearish
//                         gap, above for a bullish one. The gap chooses, not a
//                         directional call. Same level in the panel and on the chart.
//                         The opposite side is tracked internally but NOT drawn.
//   SWING : LIQUIDITY     Ratio of two measured distances, both from the midline:
//                         midline-to-origin-swing vs midline-to-liquidity on the
//                         side the gap's own type implies. It is arithmetic on two
//                         landmarks - NOT a risk:reward claim. What counts as risk
//                         is the trader's decision, not the indicator's.
//
// Developed and designed for members of the Sisterhood Trading Academy.
//
// For education and study. This script reports levels on a chart. It does not
// place orders, it is not financial advice, and nothing here is a claim about
// future results. Futures trading carries risk of loss.
// =============================================================================

indicator("STA FVG Locator", shorttitle="STA FVG Locator", overlay=true,
     max_boxes_count=500, max_lines_count=500, max_labels_count=500,
     max_bars_back=5000)

// --- Inputs ---
bullishFvgLimit = input.int(1, "Number of Bullish FVGs to Show", minval=1, maxval=20)
bearishFvgLimit = input.int(1, "Number of Bearish FVGs to Show", minval=1, maxval=20)
gapMode         = input.string("Unfilled only", "Gaps shown",
     options=["Unfilled only", "All recent"],
     tooltip="Unfilled = price has not traded through the far edge. Wicks into the gap do NOT fill it, so the gap stays on the board while price works into it.")
showUnfilledOnly = gapMode == "Unfilled only"

swingGroup      = "Swing Levels"
showSwings      = input.bool(true, "Show Swing High / Low labels", group=swingGroup)
swingHighLimit  = input.int(1, "Number of Swing Highs to Show", minval=1, maxval=20, group=swingGroup)
swingLowLimit   = input.int(1, "Number of Swing Lows to Show", minval=1, maxval=20, group=swingGroup)
swingMode       = input.string("Untested only", "Swing labels show", group=swingGroup,
     options=["Untested only", "All recent"],
     tooltip="Untested only = just the swings price has NOT yet traded through. All recent = the last N swings whether or not they have been swept.")
showUntestedOnly = swingMode == "Untested only"

// --- FVG box colors ---
// Border and fill are separate per side, so a long gap and a short gap can be
// styled independently without touching anything else on the chart.
fvgGroup = "FVG Colors"
bullBorder = input.color(#18454E, "Bullish (long) gap - border", group=fvgGroup)
bullFill   = input.color(#18454E, "Bullish (long) gap - fill",   group=fvgGroup)
bearBorder = input.color(#F3492B, "Bearish (short) gap - border", group=fvgGroup)
bearFill   = input.color(#F1A3A4, "Bearish (short) gap - fill",   group=fvgGroup)

// --- Visuals (everything else) ---
// Nothing is hard-coded - swap any swatch here without touching the code below.
visGroup = "Visuals"
deepOcean    = input.color(#18454E, "Deep Ocean - Next Liquidity and panel", group=visGroup)
morningHaze  = input.color(#E08D2D, "Morning Haze - FVG midline", group=visGroup)
eveningLight = input.color(#E56F33, "Evening Light - Gap Swing line", group=visGroup)
hemp         = input.color(#766E35, "Hemp - Swing High / Low structure", group=visGroup)
paper        = input.color(#F6EDE7, "Paper - label text and light label fills", group=visGroup)

fvgFillTransp   = input.int(88, "FVG fill transparency",   minval=0, maxval=100, group=visGroup)
fvgBorderTransp = input.int(35, "FVG border transparency", minval=0, maxval=100, group=visGroup)
inactiveFade    = input.int(30, "Inactive gap fade (added transparency)", minval=0, maxval=90, group=visGroup,
     tooltip="Gaps other than the one the dashboard describes are drawn this much fainter.")
laneGap         = input.int(10, "Label lane spacing (bars)", minval=0, maxval=60, group=visGroup,
     tooltip="How far right of the last bar the Gap Swing and Next Liquidity labels sit.")

sizeOf(opt) =>
    switch opt
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        =>          size.huge

fvgLabelSizeOpt   = input.string("Large", "FVG label text size", group=visGroup,
     options=["Tiny", "Small", "Normal", "Large", "Huge"])
swingLabelSizeOpt = input.string("Small", "Level label text size", group=visGroup,
     options=["Tiny", "Small", "Normal", "Large", "Huge"],
     tooltip="Controls the Swing High / Low, Gap Swing and Next Liquidity labels.")

fvgLabelSize   = sizeOf(fvgLabelSizeOpt)
swingLabelSize = sizeOf(swingLabelSizeOpt)

extendGroup   = "FVG Box Extend Options"
extendOption  = input.string("Default", "Extend Option", options=["None", "Limited", "Default"], group=extendGroup)
extendCandles = input.int(8, "Extend Candles (Only Applies if Limited Selected)", minval=1, maxval=100, step=1, group=extendGroup)

dashGroup   = "Dashboard"
showDash    = input.bool(true, "Show dashboard", group=dashGroup)
dashPosOpt  = input.string("Top right", "Position", group=dashGroup,
     options=["Top right", "Top left", "Bottom right", "Bottom left", "Middle right"])
dashSizeOpt = input.string("Normal", "Dashboard text size", group=dashGroup,
     options=["Tiny", "Small", "Normal", "Large", "Huge"])

perfGroup    = "Performance"
untestedCap  = input.int(300, "Max untested swings tracked per side", minval=20, maxval=2000, group=perfGroup,
     tooltip="Hard cap so the nearest-liquidity scan can never grow unbounded on low timeframes.")

// --- Data arrays ---
var array<float>  bullishFvgTop      = array.new_float(0)
var array<float>  bullishFvgBottom   = array.new_float(0)
var array<int>    bullishFvgStartBar = array.new_int(0)
var array<float>  bullishFvgOrigin   = array.new_float(0)
var array<int>    bullishFvgOriginBar = array.new_int(0)

var array<float>  bearishFvgTop      = array.new_float(0)
var array<float>  bearishFvgBottom   = array.new_float(0)
var array<int>    bearishFvgStartBar = array.new_int(0)
var array<float>  bearishFvgOrigin   = array.new_float(0)
var array<int>    bearishFvgOriginBar = array.new_int(0)

var array<float>  swingHighs    = array.new_float(0)
var array<float>  swingLows     = array.new_float(0)
var array<int>    swingHighBars = array.new_int(0)
var array<int>    swingLowBars  = array.new_int(0)

// UNTESTED swings only - tested ones are removed outright, so these stay small.
var array<float>  openSwingHighs    = array.new_float(0)
var array<int>    openSwingHighBars = array.new_int(0)
var array<float>  openSwingLows     = array.new_float(0)
var array<int>    openSwingLowBars  = array.new_int(0)

// --- Drawing-object handles ---
var array<box>   bullishFvgBoxes  = array.new_box(0)
var array<label> bullishFvgLabels = array.new_label(0)
var array<line>  bullishFvgLines  = array.new_line(0)

var array<box>   bearishFvgBoxes  = array.new_box(0)
var array<label> bearishFvgLabels = array.new_label(0)
var array<line>  bearishFvgLines  = array.new_line(0)

var array<line>  swingHighLines  = array.new_line(0)
var array<label> swingHighLabels = array.new_label(0)
var array<line>  swingLowLines   = array.new_line(0)
var array<label> swingLowLabels  = array.new_label(0)

var array<line>  originLines  = array.new_line(0)
var array<label> originLabels = array.new_label(0)

var array<line>  nearestSwingLines  = array.new_line(0)
var array<label> nearestSwingLabels = array.new_label(0)

// --- Most recent swing, kept so a new gap can capture its origin ---
var float lastSwingHigh    = na
var int   lastSwingHighBar = na
var float lastSwingLow     = na
var int   lastSwingLowBar  = na

// --- Detection ---
bullishFVG = high[2] < low
bearishFVG = low[2] > high

swingHigh = high[1] > high[2] and high[1] > high
swingLow  = low[1]  < low[2]  and low[1]  < low

// --- Store FVGs (top = higher price, bottom = lower price) ---
if bullishFVG
    array.push(bullishFvgTop,      low)
    array.push(bullishFvgBottom,   high[2])
    array.push(bullishFvgStartBar, bar_index[2])
    array.push(bullishFvgOrigin,    lastSwingLow)     // swing low before the move up
    array.push(bullishFvgOriginBar, lastSwingLowBar)

if bearishFVG
    array.push(bearishFvgTop,      low[2])
    array.push(bearishFvgBottom,   high)
    array.push(bearishFvgStartBar, bar_index[2])
    array.push(bearishFvgOrigin,    lastSwingHigh)    // swing high before the move down
    array.push(bearishFvgOriginBar, lastSwingHighBar)

// --- Store swings ---
if swingHigh
    array.push(swingHighs,        high[1])
    array.push(swingHighBars,     bar_index[1])
    array.push(openSwingHighs,    high[1])
    array.push(openSwingHighBars, bar_index[1])
    lastSwingHigh    := high[1]
    lastSwingHighBar := bar_index[1]

if swingLow
    array.push(swingLows,        low[1])
    array.push(swingLowBars,     bar_index[1])
    array.push(openSwingLows,    low[1])
    array.push(openSwingLowBars, bar_index[1])
    lastSwingLow    := low[1]
    lastSwingLowBar := bar_index[1]

// --- Retire swings that price has now traded through ---
if array.size(openSwingHighs) > 0
    for i = array.size(openSwingHighs) - 1 to 0
        if high >= array.get(openSwingHighs, i)
            array.remove(openSwingHighs, i)
            array.remove(openSwingHighBars, i)

if array.size(openSwingLows) > 0
    for i = array.size(openSwingLows) - 1 to 0
        if low <= array.get(openSwingLows, i)
            array.remove(openSwingLows, i)
            array.remove(openSwingLowBars, i)

while array.size(openSwingHighs) > untestedCap
    array.shift(openSwingHighs)
    array.shift(openSwingHighBars)

while array.size(openSwingLows) > untestedCap
    array.shift(openSwingLows)
    array.shift(openSwingLowBars)

// --- Retire gaps price has now filled ---
// Bullish gap fills when price trades below its bottom; bearish when price trades
// above its top. A wick INTO the gap is a partial fill and leaves it live.
if showUnfilledOnly
    if array.size(bullishFvgBottom) > 0
        for i = array.size(bullishFvgBottom) - 1 to 0
            if low < array.get(bullishFvgBottom, i)
                array.remove(bullishFvgTop, i)
                array.remove(bullishFvgBottom, i)
                array.remove(bullishFvgStartBar, i)
                array.remove(bullishFvgOrigin, i)
                array.remove(bullishFvgOriginBar, i)

    if array.size(bearishFvgTop) > 0
        for i = array.size(bearishFvgTop) - 1 to 0
            if high > array.get(bearishFvgTop, i)
                array.remove(bearishFvgTop, i)
                array.remove(bearishFvgBottom, i)
                array.remove(bearishFvgStartBar, i)
                array.remove(bearishFvgOrigin, i)
                array.remove(bearishFvgOriginBar, i)

// --- Enforce display limits ---
while array.size(bullishFvgTop) > bullishFvgLimit
    array.shift(bullishFvgTop)
    array.shift(bullishFvgBottom)
    array.shift(bullishFvgStartBar)
    array.shift(bullishFvgOrigin)
    array.shift(bullishFvgOriginBar)

while array.size(bearishFvgTop) > bearishFvgLimit
    array.shift(bearishFvgTop)
    array.shift(bearishFvgBottom)
    array.shift(bearishFvgStartBar)
    array.shift(bearishFvgOrigin)
    array.shift(bearishFvgOriginBar)

// --- Helpers ---
// A drawing anchored with xloc.bar_index cannot reach further back than the
// historical buffer. Untested swings and unfilled gaps can be very old, so clamp
// the left edge. The price level stays exact; only the line's start is pulled in.
while array.size(swingHighs) > swingHighLimit
    array.shift(swingHighs)
    array.shift(swingHighBars)

while array.size(swingLows) > swingLowLimit
    array.shift(swingLows)
    array.shift(swingLowBars)

BAR_FLOOR = 4500
safeBar(b) => math.max(b, bar_index - BAR_FLOOR)

formatTimeframe(tf, isBullish) =>
    suffix = isBullish ? "Bullish FVG" : "Bearish FVG"
    switch tf
        "1"   => "1m "      + suffix
        "3"   => "3m "      + suffix
        "5"   => "5m "      + suffix
        "15"  => "15m "     + suffix
        "30"  => "30m "     + suffix
        "60"  => "1h "      + suffix
        "240" => "4h "      + suffix
        "1D"  => "Daily "   + suffix
        "1W"  => "Weekly "  + suffix
        "1M"  => "Monthly " + suffix
        =>       tf + " "   + suffix

drawBox(startBar, endBar, topPrice, bottomPrice, fillColor, borderColor, textColor, isBullish,
     isActive, boxArray, labelArray, lineArray) =>
    // Snapped to the tick grid so the line, the panel and the arithmetic all agree,
    // and so Mid is a price an order can actually rest at.
    mid = math.round_to_mintick((topPrice + bottomPrice) / 2)
    array.push(boxArray, box.new(left=safeBar(startBar), top=topPrice, right=endBar, bottom=bottomPrice,
         bgcolor=fillColor, border_color=borderColor, border_width=isActive ? 2 : 1))
    array.push(labelArray, label.new(x=endBar, y=mid,
         text=formatTimeframe(timeframe.period, isBullish), color=color.new(color.gray, 100),
         textcolor=textColor, style=label.style_label_right,
         size=fvgLabelSize, textalign=text.align_right))
    // The midline IS the dashboard's Entry price - make the active one unmistakable.
    array.push(lineArray, line.new(x1=safeBar(startBar), y1=mid, x2=endBar, y2=mid,
         color=color.new(morningHaze, isActive ? 0 : math.min(100, 15 + inactiveFade)),
         width=isActive ? 2 : 1,
         style=isActive ? line.style_solid : line.style_dashed))

// --- Next Liquidity badge + dashboard plumbing ---
// Swing structure: one color for both line and text, so it reads as background
// structure and cannot be confused with Gap Swing or Next Liquidity.
drawSwing(price, startBar, endBar, txt, isHigh, lineArray, labelArray) =>
    array.push(lineArray, line.new(x1=safeBar(startBar), y1=price, x2=endBar, y2=price,
         color=color.new(hemp, 35), width=1, style=line.style_solid))
    array.push(labelArray, label.new(x=endBar, y=price, text=txt,
         color=color.new(paper, 15), textcolor=hemp,
         style=isHigh ? label.style_label_down : label.style_label_up, size=swingLabelSize))

drawLiq(price, startBar, endBar, txt, isAbove, lineArray, labelArray) =>
    array.push(lineArray, line.new(x1=safeBar(startBar), y1=price, x2=endBar, y2=price,
         color=color.new(deepOcean, 20), width=1, style=line.style_solid))
    array.push(labelArray, label.new(x=endBar, y=price, text=txt,
         color=color.new(deepOcean, 5), textcolor=paper,
         style=isAbove ? label.style_label_down : label.style_label_up,
         size=swingLabelSize))

var table dash = table.new(position.top_right, 2, 10, border_width=1)

dashPosition = switch dashPosOpt
    "Top right"    => position.top_right
    "Top left"     => position.top_left
    "Bottom right" => position.bottom_right
    "Bottom left"  => position.bottom_left
    =>                position.middle_right

fmtPrice(x) => na(x) ? "--" : str.tostring(x, format.mintick)
fmtPts(x)   => na(x) ? "--" : str.tostring(x, "#.##")
fmtSigned(x) => na(x) ? "--" : (x >= 0 ? "+" : "") + str.tostring(x, "#.##")

// --- Draw once, on the last bar only ---
if barstate.islast

    if array.size(bullishFvgBoxes) > 0
        for i = 0 to array.size(bullishFvgBoxes) - 1
            box.delete(array.get(bullishFvgBoxes, i))
            label.delete(array.get(bullishFvgLabels, i))
            line.delete(array.get(bullishFvgLines, i))
        array.clear(bullishFvgBoxes)
        array.clear(bullishFvgLabels)
        array.clear(bullishFvgLines)

    if array.size(bearishFvgBoxes) > 0
        for i = 0 to array.size(bearishFvgBoxes) - 1
            box.delete(array.get(bearishFvgBoxes, i))
            label.delete(array.get(bearishFvgLabels, i))
            line.delete(array.get(bearishFvgLines, i))
        array.clear(bearishFvgBoxes)
        array.clear(bearishFvgLabels)
        array.clear(bearishFvgLines)

    if array.size(swingHighLines) > 0
        for i = 0 to array.size(swingHighLines) - 1
            line.delete(array.get(swingHighLines, i))
            label.delete(array.get(swingHighLabels, i))
        array.clear(swingHighLines)
        array.clear(swingHighLabels)

    if array.size(swingLowLines) > 0
        for i = 0 to array.size(swingLowLines) - 1
            line.delete(array.get(swingLowLines, i))
            label.delete(array.get(swingLowLabels, i))
        array.clear(swingLowLines)
        array.clear(swingLowLabels)

    if array.size(originLines) > 0
        for i = 0 to array.size(originLines) - 1
            line.delete(array.get(originLines, i))
            label.delete(array.get(originLabels, i))
        array.clear(originLines)
        array.clear(originLabels)

    if array.size(nearestSwingLines) > 0
        for i = 0 to array.size(nearestSwingLines) - 1
            line.delete(array.get(nearestSwingLines, i))
            label.delete(array.get(nearestSwingLabels, i))
        array.clear(nearestSwingLines)
        array.clear(nearestSwingLabels)

    // ---- Which gap is the dashboard describing? Nearest midline to price. ----
    activeLane = bar_index + 5 + laneGap

    float actBullMid = na
    int   actBullIdx = na
    if array.size(bullishFvgTop) > 0
        for i = 0 to array.size(bullishFvgTop) - 1
            m = (array.get(bullishFvgTop, i) + array.get(bullishFvgBottom, i)) / 2
            if na(actBullMid) or math.abs(close - m) < math.abs(close - actBullMid)
                actBullMid := m
                actBullIdx := i

    float actBearMid = na
    int   actBearIdx = na
    if array.size(bearishFvgTop) > 0
        for i = 0 to array.size(bearishFvgTop) - 1
            m = (array.get(bearishFvgTop, i) + array.get(bearishFvgBottom, i)) / 2
            if na(actBearMid) or math.abs(close - m) < math.abs(close - actBearMid)
                actBearMid := m
                actBearIdx := i

    bool useBull      = na(actBearMid) or (not na(actBullMid) and math.abs(close - actBullMid) <= math.abs(close - actBearMid))
    bool activeIsBull = useBull and not na(actBullMid)
    bool activeIsBear = not useBull and not na(actBearMid)

    if array.size(bullishFvgTop) > 0
        for i = 0 to array.size(bullishFvgTop) - 1
            bTop   = array.get(bullishFvgTop, i)
            bBot   = array.get(bullishFvgBottom, i)
            bStart = array.get(bullishFvgStartBar, i)
            bEnd   = extendOption == "Default" ? bar_index + 3 : extendOption == "Limited" ? bStart + extendCandles : bStart + 2
            act    = activeIsBull and i == actBullIdx
            fade   = act ? 0 : inactiveFade
            drawBox(bStart, bEnd, bTop, bBot, color.new(bullFill, math.min(100, fvgFillTransp + fade)),
                 color.new(bullBorder, math.min(100, fvgBorderTransp + fade)), bullBorder, true, act,
                 bullishFvgBoxes, bullishFvgLabels, bullishFvgLines)

    if array.size(bearishFvgTop) > 0
        for i = 0 to array.size(bearishFvgTop) - 1
            bTop   = array.get(bearishFvgTop, i)
            bBot   = array.get(bearishFvgBottom, i)
            bStart = array.get(bearishFvgStartBar, i)
            bEnd   = extendOption == "Default" ? bar_index + 3 : extendOption == "Limited" ? bStart + extendCandles : bStart + 2
            act    = activeIsBear and i == actBearIdx
            fade   = act ? 0 : inactiveFade
            drawBox(bStart, bEnd, bTop, bBot, color.new(bearFill, math.min(100, fvgFillTransp + fade)),
                 color.new(bearBorder, math.min(100, fvgBorderTransp + fade)), bearBorder, false, act,
                 bearishFvgBoxes, bearishFvgLabels, bearishFvgLines)

    // Nearest untested liquidity on BOTH sides. The indicator does not pick a
    // direction - it reports what is above and what is below.
    float liqUp    = na
    int   liqUpBar = na
    if array.size(openSwingHighs) > 0
        for i = 0 to array.size(openSwingHighs) - 1
            p = array.get(openSwingHighs, i)
            if p > close and (na(liqUp) or p < liqUp)
                liqUp    := p
                liqUpBar := array.get(openSwingHighBars, i)

    float liqDn    = na
    int   liqDnBar = na
    if array.size(openSwingLows) > 0
        for i = 0 to array.size(openSwingLows) - 1
            p = array.get(openSwingLows, i)
            if p < close and (na(liqDn) or p > liqDn)
                liqDn    := p
                liqDnBar := array.get(openSwingLowBars, i)

    // Swing structure in the near lane; Gap Swing and Next Liquidity sit further
    // out in activeLane, so the two families cannot overlap.
    // The active gap's origin, resolved early so the swing labels can dedupe
    // against it as well as against Next Liquidity.
    float oPrice = na
    int   oBar   = na
    if activeIsBull
        oPrice := array.get(bullishFvgOrigin, actBullIdx)
        oBar   := array.get(bullishFvgOriginBar, actBullIdx)
    else if activeIsBear
        oPrice := array.get(bearishFvgOrigin, actBearIdx)
        oBar   := array.get(bearishFvgOriginBar, actBearIdx)

    if showSwings
        swingLane   = bar_index + 5
        // One label per PRICE. Two swings can share a level (a double bottom is
        // two bars at one price) and would otherwise stack two identical labels.
        drawnPrices = array.new_float(0)
        srcHighs    = showUntestedOnly ? openSwingHighs    : swingHighs
        srcHighBars = showUntestedOnly ? openSwingHighBars : swingHighBars
        srcLows     = showUntestedOnly ? openSwingLows     : swingLows
        srcLowBars  = showUntestedOnly ? openSwingLowBars  : swingLowBars

        nHighs = array.size(srcHighs)
        if nHighs > 0
            for i = math.max(0, nHighs - swingHighLimit) to nHighs - 1
                hp = array.get(srcHighs, i)
                hb = array.get(srcHighBars, i)
                // Already badged as Next Liquidity, or as this gap's Gap Swing?
                isLiq = not na(liqUp) and hp == liqUp
                isOrg = not na(oPrice) and hp == oPrice
                isDup = array.includes(drawnPrices, hp)
                if not isLiq and not isOrg and not isDup
                    array.push(drawnPrices, hp)
                    drawSwing(hp, hb, swingLane, "Swing High", true, swingHighLines, swingHighLabels)

        nLows = array.size(srcLows)
        if nLows > 0
            for i = math.max(0, nLows - swingLowLimit) to nLows - 1
                lp = array.get(srcLows, i)
                lb = array.get(srcLowBars, i)
                isLiq = not na(liqDn) and lp == liqDn
                isOrg = not na(oPrice) and lp == oPrice
                isDup = array.includes(drawnPrices, lp)
                if not isLiq and not isOrg and not isDup
                    array.push(drawnPrices, lp)
                    drawSwing(lp, lb, swingLane, "Swing Low", false, swingLowLines, swingLowLabels)

    if showDash
        table.set_position(dash, dashPosition)
        dSize = sizeOf(dashSizeOpt)

        float gTop = na
        float gBot = na
        if activeIsBull
            gTop := array.get(bullishFvgTop, actBullIdx)
            gBot := array.get(bullishFvgBottom, actBullIdx)
        else if activeIsBear
            gTop := array.get(bearishFvgTop, actBearIdx)
            gBot := array.get(bearishFvgBottom, actBearIdx)

        float midline = na(gTop) ? na : math.round_to_mintick((gTop + gBot) / 2)
        // Target side follows the gap's own type - structural, not a bias call.
        float liqSide = activeIsBull ? liqUp : activeIsBear ? liqDn : na

        // Two measured distances from the midline. Naming them is the trader's job.
        float dSwing = na(midline) or na(oPrice) ? na : math.abs(midline - oPrice)
        float dLiq   = na(midline) or na(liqSide) ? na : math.abs(liqSide - midline)
        bool  liqAhead = na(liqSide) or na(midline) ? false : (activeIsBull ? liqSide > midline : liqSide < midline)
        string ratioTxt = na(dSwing) or na(dLiq) or dSwing <= 0 or not liqAhead ? "--" : "1 : " + str.tostring(dLiq / dSwing, "#.##")

        table.cell(dash, 0, 0, "STA FVG LOCATOR", text_color=morningHaze, bgcolor=deepOcean, text_size=dSize)
        table.cell(dash, 1, 0, "",                text_color=morningHaze, bgcolor=deepOcean, text_size=dSize)

        // label, value, tooltip
        rows = array.from(
             "Gap", na(gTop) ? "--" : (activeIsBull ? "Bullish" : "Bearish"),
             "The nearest unfilled gap to price, by midline distance. This is the gap the rest of the panel describes, and the one drawn with a solid midline on the chart.",

             "Size", na(gTop) ? "--" : fmtPts(gTop - gBot) + " pt",
             "Height of the gap, top edge to bottom edge. In ticks: " + (na(gTop) ? "--" : str.tostring(math.round((gTop - gBot) / syminfo.mintick))),

             "Mid", fmtPrice(midline),
             "MIDLINE - the middle of the gap, snapped to the tick grid so it is a price an order can rest at. Distance and the ratio are computed from this same snapped value. A reference level; the indicator is not calling it an entry.",

             "Distance", na(midline) ? "--" : fmtSigned(close - midline) + " pt",
             "DISTANCE - how far current price sits from the midline, and on which side. Positive = price is ABOVE the midline; negative = price is BELOW it. The only row that moves tick to tick; everything else is a fixed level.",

             "Swing", fmtPrice(oPrice),
             "ORIGIN SWING, drawn on the chart as Gap Swing. The swing that preceded the displacement which created this gap. Bullish gap = the swing low before the move up; bearish gap = the swing high before the move down. Captured when the gap formed and fixed since. Distance from the midline: " + (na(dSwing) ? "--" : fmtPts(dSwing) + " pt"),

             "Next Liq", fmtPrice(liqSide),
             "NEXT LIQUIDITY - the nearest untested liquidity on the side this gap's own type implies - below for a bearish gap, above for a bullish one. Structural, not a directional call. Distance from price: " + (na(liqSide) ? "--" : fmtPts(math.abs(liqSide - close)) + " pt") + ".  Drawn on the chart as Next Liquidity. Note the OPPOSITE side is not shown - that is the level a sweep can run, so check it yourself when placing a stop.",

             "Swing : Liq", ratioTxt,
             "Ratio of two measured distances, both from the midline: midline-to-origin-swing against midline-to-liquidity on the side this gap's type implies. Arithmetic on two landmarks, NOT a risk:reward claim - what counts as risk is your decision. Shows -- when the liquidity on that side sits behind the midline.")

        for r = 0 to 6
            table.cell(dash, 0, r + 1, array.get(rows, r * 3),
                 text_color=paper, bgcolor=deepOcean, text_size=dSize,
                 text_halign=text.align_left, tooltip=array.get(rows, r * 3 + 2))
            table.cell(dash, 1, r + 1, array.get(rows, r * 3 + 1),
                 text_color=r == 6 ? morningHaze : paper, bgcolor=deepOcean, text_size=dSize,
                 text_halign=text.align_right, tooltip=array.get(rows, r * 3 + 2))
    else
        table.clear(dash, 0, 0, 1, 9)

    // ---- Gap Swing: the active gap's origin, drawn from where it happened ----
    if not na(oPrice) and not na(oBar)
        array.push(originLines, line.new(x1=safeBar(oBar), y1=oPrice, x2=activeLane, y2=oPrice,
             color=color.new(eveningLight, 15), width=1, style=line.style_dashed))
        array.push(originLabels, label.new(x=activeLane, y=oPrice, text="Gap Swing",
             color=color.new(paper, 15), textcolor=eveningLight,
             style=activeIsBull ? label.style_label_up : label.style_label_down,
             size=swingLabelSize))

    // ---- Next Liquidity: one line, on the side this gap's own type implies ----
    float nlPrice = activeIsBull ? liqUp    : activeIsBear ? liqDn    : na
    int   nlBar   = activeIsBull ? liqUpBar : activeIsBear ? liqDnBar : na

    if not na(nlPrice) and not na(nlBar)
        drawLiq(nlPrice, nlBar, activeLane, "Next Liquidity", activeIsBull, nearestSwingLines, nearestSwingLabels)
````
