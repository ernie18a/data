<!-- tradingview-pine-id: PUB;a66a11ac8dce4951bae444cc320b8316 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# The Trap Indicator

Source: https://www.tradingview.com/script/Iso1a4wS/

## Description

The Trap Indicator

WHAT IT IS
The Trap Indicator is a structure-based tool that automatically detects and marks a specific market sequence known as "the trap": a Change of Character (CHoCH) that catches one side of the market off guard, followed by a Break of Structure (BOS) that catches the opposite side, before price turns to sweep the liquidity left behind by both groups. Instead of drawing every structure break on the chart, it isolates this particular chained sequence and highlights only the CHoCH, the BOS, and the liquidity pool that sits between them.

WHAT IT IS BASED ON
The indicator is built on core Smart Money Concepts (SMC) / ICT-style ideas: market structure shifts (CHoCH and BOS), and liquidity resting above and below swing points as pools of stop orders that price tends to gravitate toward. The specific sequence it looks for is a practical extension of those building blocks: a structure break in one direction traps traders who enter on it, the market then reverses and breaks structure in the other direction, trapping a second, opposite group, and only after that combined liquidity has been swept does the underlying move tend to unfold with less resistance. The individual concepts (CHoCH, BOS, liquidity) are standard SMC/ICT vocabulary; the way they are chained together here into one tracked pattern is this indicator's own interpretation of that idea.

WHAT IT IS MADE OF
The indicator works from three consecutive swing points, labeled A, B and C:
- Swing A: a confirmed pivot (high or low) taken as the starting reference.
- Swing B: the swing right after A, in the opposite direction.
- Swing C: the swing right after B, in the same direction as A, but going further than A (a lower low for a bullish resolution, a higher high for a bearish resolution). This is what confirms the CHoCH — structure breaking against the initial A-to-B move, trapping whoever entered on it.
From there:
- BOS line: plotted when price closes back beyond swing B, confirming a Break of Structure in the opposite direction and trapping a second group of traders who act on that break.
- Rebound Zone: a box drawn across the price range between swings A and C — the pool of liquidity left behind by both trapped groups. The box grows bar by bar for a set number of bars after the BOS confirms, then disappears automatically, leaving only the CHoCH and BOS marks on the chart.
Swing detection uses standard pivot highs/lows, with an optional ATR-based minimum-amplitude filter to ignore minor, noise-level swings.

HOW TO USE IT
Add the indicator to any symbol and timeframe. When a valid CHoCH forms, an orange line appears at the level that was broken, labeled "CHoCH." If price then breaks structure the other way, a second line (green for a bullish resolution, red for a bearish one) appears at that level, labeled "BOS," together with the Rebound Zone box marking the liquidity range between swings A and C. That box is the area to watch: it represents the combined liquidity from both trapped groups, which price often revisits before the larger move plays out. Once the configured number of bars has passed, the box disappears on its own, while the CHoCH and BOS lines remain as a permanent record of the structure shift.

Settings worth adjusting:
- Pivot lookback/lookahead and the amplitude filter control how sensitive swing detection is — lower values catch more (and smaller) swings, higher values focus on more significant structure.
- Rebound zone duration (bars) sets how long the liquidity box stays visible before it is removed.
- Bullish/bearish resolutions can be toggled independently, and all colors, line width and label size are configurable.

This indicator only marks structure — it does not plot entries, targets, or stop levels, and it does not predict that price will necessarily reverse inside the Rebound Zone. It is meant to help visualize where this specific liquidity-trap sequence is forming, so it can be combined with the trader's own confirmation (price action, volume, or other tools) before making any decision. It is provided for educational and analytical purposes only and does not constitute financial advice.

---

## Source Code

````pine
//@version=6
indicator("The Trap Indicator", overlay = true, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500)

// =========================================================================
// "La Trampa"
//
// For each direction, the logic follows three consecutive alternating
// swings (A, B, C):
//   A = a confirmed swing.
//   B = the swing right after A (opposite type).
//   C = the swing right after B (same type as A), going FURTHER than A
//       (a lower low for the bullish-resolution case, a higher high for
//       the bearish-resolution case). This is what marks the CHoCH: the
//       structure breaks against the A->B leg, trapping the side that
//       had just entered on that leg.
//   BOS = the first close, after C confirms, that breaks back past B --
//       this traps the opposite side, who enter expecting continuation.
//   REBOUND ZONE = the range between A and C: the pool of liquidity left
//       by both trapped groups. Drawn as a box that grows for `zoneBars`
//       bars after the BOS confirms, then disappears automatically --
//       only the CHoCH and BOS marks stay on the chart afterwards.
//
// Pivots use ta.pivothigh/ta.pivotlow (confirm `pivotLen` bars after they
// form), so nothing here is plotted before it is actually known.
// =========================================================================

// ---------------------------- Inputs ------------------------------------
grpSwing = "Swing / structure"
pivotLen      = input.int(8, "Pivot lookback / lookahead (bars)", minval = 2, group = grpSwing)
useAmpFilter  = input.bool(false, "Filter swings by minimum amplitude", group = grpSwing)
atrLen        = input.int(14, "ATR length", minval = 1, group = grpSwing)
minAmpATR     = input.float(1.5, "Minimum swing amplitude (x ATR)", minval = 0.1, step = 0.1, group = grpSwing)

grpLogic = "Pattern"
maxWaitBars   = input.int(500, "Max bars to wait for the BOS before invalidating", minval = 10, group = grpLogic)
zoneBars      = input.int(100, "Rebound zone duration (bars)", minval = 1, group = grpLogic)
showBull      = input.bool(true, "Show bullish-resolution setups", group = grpLogic)
showBear      = input.bool(true, "Show bearish-resolution setups", group = grpLogic)

grpStyle = "Style"
chochColorBull = input.color(color.new(color.orange, 0), "CHoCH line (bullish resolution)", group = grpStyle)
chochColorBear = input.color(color.new(color.orange, 0), "CHoCH line (bearish resolution)", group = grpStyle)
bosColorBull   = input.color(color.new(color.lime, 0), "BOS line (bullish resolution)", group = grpStyle)
bosColorBear   = input.color(color.new(color.red, 0), "BOS line (bearish resolution)", group = grpStyle)
zoneColorBull  = input.color(color.new(color.teal, 80), "Rebound zone (bullish resolution)", group = grpStyle)
zoneColorBear  = input.color(color.new(color.maroon, 80), "Rebound zone (bearish resolution)", group = grpStyle)
lineWidth      = input.int(1, "Line width", minval = 1, maxval = 4, group = grpStyle)
markExtendBars = input.int(20, "Extend CHoCH / BOS lines forward (bars)", minval = 0, group = grpStyle)
showLabels     = input.bool(true, "Show text labels", group = grpStyle)
labelSizeInput = input.string("Large", "Label size", options = ["Small", "Normal", "Large", "Huge"], group = grpStyle)

labelSize = labelSizeInput == "Small" ? size.small : labelSizeInput == "Normal" ? size.normal : labelSizeInput == "Large" ? size.large : size.huge

atrVal = ta.atr(atrLen)

// ---------------------------- Pivot tracking ------------------------------
ph = ta.pivothigh(pivotLen, pivotLen)
pl = ta.pivotlow(pivotLen, pivotLen)

var float lastOppPivotHigh = na  // used only for the amplitude filter
var float lastOppPivotLow  = na

// rolling window of the last 3 CONFIRMED pivots, oldest (p1) to newest (p3)
var string p1Type = na
var float  p1Price = na
var int    p1Bar = na
var string p2Type = na
var float  p2Price = na
var int    p2Bar = na
var string p3Type = na
var float  p3Price = na
var int    p3Bar = na

// ============================== BULLISH-RESOLUTION SIDE ===================
// A = low, B = high, C = low with C < A  ->  CHoCH.  BOS = close > B.
var int   bullState  = 0   // 0 = idle, 1 = armed (waiting for BOS), 2 = zone active
var float bullAPrice = na
var int   bullABar   = na
var float bullBPrice = na
var int   bullBBar   = na
var float bullCPrice = na
var int   bullCBar   = na
var int   bullZoneStartBar = na
var box   bullZoneBox   = na
var label bullZoneLabel = na

// ============================== BEARISH-RESOLUTION SIDE ====================
// A = high, B = low, C = high with C > A  ->  CHoCH.  BOS = close < B.
var int   bearState  = 0
var float bearAPrice = na
var int   bearABar   = na
var float bearBPrice = na
var int   bearBBar   = na
var float bearCPrice = na
var int   bearCBar   = na
var int   bearZoneStartBar = na
var box   bearZoneBox   = na
var label bearZoneLabel = na

// ---------------------------- Handle a newly confirmed pivot ---------------
// (inlined rather than a shared function: Pine does not allow a
// user-defined function to modify global variables)
//
// Raw ta.pivothigh/pivotlow do NOT alternate high/low/high/low -- two or
// more highs (or lows) in a row are common. Consecutive same-type pivots
// are merged here, keeping only the more extreme one, before the 3-slot
// alternating window (p1/p2/p3) is updated -- otherwise the window almost
// never lines up as low/high/low or high/low/high and the pattern never
// triggers.
if not na(ph)
    pivotBar = bar_index - pivotLen
    ampOK = not useAmpFilter or na(lastOppPivotLow) or math.abs(ph - lastOppPivotLow) >= minAmpATR * atrVal
    if ampOK
        lastOppPivotHigh := ph
        if p3Type == "high"
            // merge with the previous high: keep whichever is more extreme
            if ph > p3Price
                p3Price := ph
                p3Bar := pivotBar
        else
            p1Type := p2Type
            p1Price := p2Price
            p1Bar := p2Bar
            p2Type := p3Type
            p2Price := p3Price
            p2Bar := p3Bar
            p3Type := "high"
            p3Price := ph
            p3Bar := pivotBar

if not na(pl)
    pivotBar2 = bar_index - pivotLen
    ampOK2 = not useAmpFilter or na(lastOppPivotHigh) or math.abs(pl - lastOppPivotHigh) >= minAmpATR * atrVal
    if ampOK2
        lastOppPivotLow := pl
        if p3Type == "low"
            if pl < p3Price
                p3Price := pl
                p3Bar := pivotBar2
        else
            p1Type := p2Type
            p1Price := p2Price
            p1Bar := p2Bar
            p2Type := p3Type
            p2Price := p3Price
            p2Bar := p3Bar
            p3Type := "low"
            p3Price := pl
            p3Bar := pivotBar2

// bullish-resolution match: low, high, low with p3 < p1
if showBull and bullState == 0 and p1Type == "low" and p2Type == "high" and p3Type == "low" and p3Price < p1Price and (na(bullCBar) or p3Bar != bullCBar)
    bullAPrice := p1Price
    bullABar := p1Bar
    bullBPrice := p2Price
    bullBBar := p2Bar
    bullCPrice := p3Price
    bullCBar := p3Bar
    bullState := 1
    line.new(bullABar, bullAPrice, bullCBar + markExtendBars, bullAPrice, xloc = xloc.bar_index, color = chochColorBull, width = lineWidth)
    if showLabels
        label.new(bullCBar, bullAPrice, "CHoCH", xloc = xloc.bar_index, style = label.style_label_up, color = color.new(chochColorBull, 80), textcolor = chochColorBull, size = labelSize)

// bearish-resolution match: high, low, high with p3 > p1
if showBear and bearState == 0 and p1Type == "high" and p2Type == "low" and p3Type == "high" and p3Price > p1Price and (na(bearCBar) or p3Bar != bearCBar)
    bearAPrice := p1Price
    bearABar := p1Bar
    bearBPrice := p2Price
    bearBBar := p2Bar
    bearCPrice := p3Price
    bearCBar := p3Bar
    bearState := 1
    line.new(bearABar, bearAPrice, bearCBar + markExtendBars, bearAPrice, xloc = xloc.bar_index, color = chochColorBear, width = lineWidth)
    if showLabels
        label.new(bearCBar, bearAPrice, "CHoCH", xloc = xloc.bar_index, style = label.style_label_down, color = color.new(chochColorBear, 80), textcolor = chochColorBear, size = labelSize)

// ---------------------------- Bullish-resolution: wait for BOS / run zone --
if showBull
    if bullState == 1
        if close > bullBPrice
            bullState := 2
            zoneTop = math.max(bullAPrice, bullCPrice)
            zoneBot = math.min(bullAPrice, bullCPrice)
            line.new(bullBBar, bullBPrice, bar_index + markExtendBars, bullBPrice, xloc = xloc.bar_index, color = bosColorBull, width = lineWidth)
            if showLabels
                label.new(bar_index, bullBPrice, "BOS", xloc = xloc.bar_index, style = label.style_label_down, color = color.new(bosColorBull, 80), textcolor = bosColorBull, size = labelSize)
            bullZoneStartBar := bar_index
            bullZoneBox := box.new(bar_index, zoneTop, bar_index, zoneBot, border_color = color.new(zoneColorBull, 40), bgcolor = zoneColorBull)
            if showLabels
                bullZoneLabel := label.new(bar_index, zoneBot, "Rebound Zone", xloc = xloc.bar_index, style = label.style_label_up, color = color.new(zoneColorBull, 40), textcolor = color.teal, size = labelSize)
        else if bar_index - bullCBar > maxWaitBars
            bullState := 0
    else if bullState == 2
        age = bar_index - bullZoneStartBar
        if age >= zoneBars
            box.delete(bullZoneBox)
            if not na(bullZoneLabel)
                label.delete(bullZoneLabel)
            bullZoneBox := na
            bullZoneLabel := na
            bullState := 0
        else
            box.set_right(bullZoneBox, bar_index)
            if not na(bullZoneLabel)
                label.set_x(bullZoneLabel, bar_index)

// ---------------------------- Bearish-resolution: wait for BOS / run zone --
if showBear
    if bearState == 1
        if close < bearBPrice
            bearState := 2
            zoneTop = math.max(bearAPrice, bearCPrice)
            zoneBot = math.min(bearAPrice, bearCPrice)
            line.new(bearBBar, bearBPrice, bar_index + markExtendBars, bearBPrice, xloc = xloc.bar_index, color = bosColorBear, width = lineWidth)
            if showLabels
                label.new(bar_index, bearBPrice, "BOS", xloc = xloc.bar_index, style = label.style_label_up, color = color.new(bosColorBear, 80), textcolor = bosColorBear, size = labelSize)
            bearZoneStartBar := bar_index
            bearZoneBox := box.new(bar_index, zoneTop, bar_index, zoneBot, border_color = color.new(zoneColorBear, 40), bgcolor = zoneColorBear)
            if showLabels
                bearZoneLabel := label.new(bar_index, zoneTop, "Rebound Zone", xloc = xloc.bar_index, style = label.style_label_down, color = color.new(zoneColorBear, 40), textcolor = color.maroon, size = labelSize)
        else if bar_index - bearCBar > maxWaitBars
            bearState := 0
    else if bearState == 2
        age = bar_index - bearZoneStartBar
        if age >= zoneBars
            box.delete(bearZoneBox)
            if not na(bearZoneLabel)
                label.delete(bearZoneLabel)
            bearZoneBox := na
            bearZoneLabel := na
            bearState := 0
        else
            box.set_right(bearZoneBox, bar_index)
            if not na(bearZoneLabel)
                label.set_x(bearZoneLabel, bar_index)
````
