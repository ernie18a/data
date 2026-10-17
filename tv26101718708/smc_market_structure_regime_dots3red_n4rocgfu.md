# SMC Market Structure Regime [Dots3Red]

- url: https://www.tradingview.com/script/n4ROcGfU-SMC-Market-Structure-Regime-Dots3Red/
- type: indicator
- pine_id: PUB;b01ae9dabc0d45d2b9341abb45f3df3e
- version: 1.0

## Description

Most traders can spot [b]BOS [/b]and [b]CHoCH[/b].
Reading the CURRENT market regime in real time is much harder.

[b]SMC Market Structure Regime[/b] transforms raw price structure into a dynamic visual system — highlighting bullish, bearish, and weakening phases using adaptive boundaries and [b]smart-money[/b] logic.

Built for traders who want cleaner SMC visualization without cluttered charts.

[b]─────────────────────────────────[/b]
[b]FEATURES[/b]
[b]─────────────────────────────────[/b]

[b]◆ Smart Money Structure Detection[/b]
[list]
[*]Automatic BOS (Break of Structure) detection
[*]CHoCH (Change of Character) transitions
[*]Bullish / Bearish / Neutral regime tracking
[/list]
[b]◆ Adaptive Structure Boundaries[/b]
[list]
[*]Smoothed curved regime envelopes
[*]Dynamic offset zones that breathe with price
[*]Visual market phase mapping
[/list]
[b]◆ Real-Time Regime Projection[/b]
[list]
[*]Live regime state on the last bar
[*]Detects weakening structure conditions
[*]Highlights possible transition phases before they confirm
[/list]
[b]◆ Clean Visual Design[/b]
[list]
[*]Minimal chart clutter
[*]Cyberpunk-inspired color system — fast visual reads
[*]Designed for speed, not noise
[/list]
[b]─────────────────────────────────[/b]
[b]HOW TO READ[/b]
[b]─────────────────────────────────[/b]

[b]▲ Green Zone — Bullish Regime[/b]
HH + HL structure confirmed. Market is in bullish continuation.

[b]▼ Red Zone — Bearish Regime[/b]
LH + LL structure confirmed. Market is in bearish continuation.

[b]◆ Teal Zone — Neutral / Transition[/b]
Structure is resetting. Wait for BOS confirmation before committing.

[b]⚠ Orange Warning — Weakening Structure[/b]
Current regime is showing signs of exhaustion. Possible CHoCH incoming.

[b]BOS Label[/b]
Structure continuation confirmed in the direction of the regime.

[b]»CHoCH« Label[/b]
Character of the market is changing. Possible reversal forming.

[b]─────────────────────────────────[/b]
[b]SETTINGS[/b]
[b]─────────────────────────────────[/b]

[b]Pivot Length[/b]
Controls sensitivity of swing detection.
Lower = more sensitive, higher = smoother structure.

[b]Boundary Offset %[/b]
Controls how wide the envelope sits around price.
Increase for volatile assets, decrease for tight structure.

[b]Boundary Smoothing[/b]
EMA period for boundary curves.
Lower = reactive, higher = smooth channel look.

[b]─────────────────────────────────[/b]
[b]BEST USED WITH[/b]
[b]─────────────────────────────────[/b]
[list]
[*]Higher timeframe bias confirmation
[*]Liquidity zone mapping
[*]Volume analysis
[*]Order block confirmation
[*]Intraday and swing trading setups
[/list]
[b]─────────────────────────────────[/b]
[b]NOTES[/b]
[b]─────────────────────────────────[/b]

This indicator is a [b]visualization and context tool[/b].
It works best as part of a broader SMC framework — not as a standalone signal.

[i]No indicator constitutes financial advice. Trade responsibly.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Dots3Red

//@version=6
indicator("SMC Market Structure Regime [Dots3Red]", 
     max_lines_count     = 500, 
     max_labels_count    = 500, 
     max_boxes_count     = 500, 
     max_polylines_count = 100,
     overlay             = true)

var color colorBar  = #b2b5be
var color C_BULL    = #39FF14
var color C_BEAR    = #FF0055
var color C_NEUTRAL = #5F9EA0
var color C_CHOCH   = #b2b5be

var int   pivotLength = input.int(3,   "Pivot Length",       options=[2,3,4,5,6,7,8,9,10])
var float offsetPct   = input.float(7,"Boundary Offset %",  step=0.5, minval=0.0) / 100
var int   smoothLen   = input.int(3,   "Boundary Smoothing", minval=1, maxval=10)

pH = ta.pivothigh(high, pivotLength, pivotLength)
pL = ta.pivotlow(low,  pivotLength, pivotLength)

var int marketRegime = 0

var arrPvH = array.new<int>()
var arrPvL = array.new<int>()

var arrUpperPoints = array.new<chart.point>()
var arrLowerPoints = array.new<chart.point>()

smoothH = ta.ema(high, smoothLen) * (1 + offsetPct)
smoothL = ta.ema(low,  smoothLen) * (1 - offsetPct)

arrUpperPoints.push(chart.point.from_index(bar_index, smoothH))
arrLowerPoints.push(chart.point.from_index(bar_index, smoothL))

f_drawStructure(regime) =>
    col     = regime ==  1 ? color.new(C_BULL,    75) : 
              regime == -1 ? color.new(C_BEAR,    75) : 
                             color.new(C_NEUTRAL, 35)
    fillCol = regime ==  1 ? color.new(C_BULL,    95) : 
              regime == -1 ? color.new(C_BEAR,    95) : 
                             color.new(C_NEUTRAL, 80)

    if arrUpperPoints.size() > 1 and arrLowerPoints.size() > 1
        closedPoints = array.new<chart.point>()
        for i = 0 to arrUpperPoints.size() - 1
            closedPoints.push(arrUpperPoints.get(i))
        for i = arrLowerPoints.size() - 1 to 0
            closedPoints.push(arrLowerPoints.get(i))
        polyline.new(closedPoints,
             curved        = true,
             closed        = true,
             line_color    = col,
             fill_color    = fillCol,
             line_width    = 2,
             force_overlay = true)

f_drawLabel(pvIDX, txt, isHigh, col) =>
    y     = isHigh ? smoothH * (1+offsetPct/1.5) : smoothL * (1-offsetPct/1.5)
    style = isHigh ? label.style_triangledown : label.style_triangleup
    lblPoint = chart.point.from_index(bar_index,y)
    label.new(lblPoint, 
         color        = color.new(col,50),
         textcolor    = color.white,         
         style        = style,
         size         = 3,
         force_overlay= true)


f_drawCurrentPhase() =>
    if arrUpperPoints.size() > 1 and arrLowerPoints.size() > 1
        recentHigh = ta.highest(high, pivotLength * 2)
        recentLow  = ta.lowest(low,  pivotLength * 2)
        lastPvH = arrPvH.size() > 0 ? arrPvH.get(arrPvH.size() - 1) : na
        lastPvL = arrPvL.size() > 0 ? arrPvL.get(arrPvL.size() - 1) : na

        hintBull = not na(lastPvL) and recentLow  > low[bar_index - lastPvL]
        hintBear = not na(lastPvH) and recentHigh < high[bar_index - lastPvH]

        projCol = switch marketRegime
            1  => hintBull ? C_BULL  : C_CHOCH
            -1 => hintBear ? C_BEAR  : C_CHOCH
            => C_NEUTRAL

        fillCol = color.new(projCol, 90)
        lineCol = color.new(projCol, 30)

        closedPoints = array.new<chart.point>()
        for i = 0 to arrUpperPoints.size() - 1
            closedPoints.push(arrUpperPoints.get(i))
        for i = arrLowerPoints.size() - 1 to 0
            closedPoints.push(arrLowerPoints.get(i))

        polyline.new(closedPoints,
             curved        = true,
             closed        = true,
             line_color    = color.new(projCol, 100), 
             fill_color    = fillCol,
             force_overlay = true)


        for i = 0 to arrUpperPoints.size() - 2
            p1 = arrUpperPoints.get(i), p2 = arrUpperPoints.get(i + 1)
            line.new(p1.index, p1.price, p2.index, p2.price, color=lineCol, style=line.style_dashed, width=1, force_overlay=true)

        for i = 0 to arrLowerPoints.size() - 2
            p1 = arrLowerPoints.get(i), p2 = arrLowerPoints.get(i + 1)
            line.new(p1.index, p1.price, p2.index, p2.price, color=lineCol, style=line.style_dashed, width=1, force_overlay=true)

        lastUpper = arrUpperPoints.get(arrUpperPoints.size() - 1)
        statusTxt = (marketRegime == 1 ? (hintBull ? "SYSTEM: BULLISH" : "WARN: WEAKENING") : 
                     marketRegime == -1 ? (hintBear ? "SYSTEM: BEARISH" : "WARN: WEAKENING") : "SYSTEM: NEUTRAL")

        label.new(lastUpper.index, lastUpper.price, "» " + statusTxt,
             color     = color.new(color.black, 100), 
             textcolor = projCol,
             style     = label.style_label_left,
             size      = size.small,
             force_overlay = true)


// ─── SEED HELPERS ────────────────────────────────────────────────────
f_clearAndSeedH(pvIDX) =>
    arrPvH.push(pvIDX)
    f_drawStructure(marketRegime)
    array.clear(arrPvH)
    array.clear(arrPvL)
    array.clear(arrUpperPoints)
    array.clear(arrLowerPoints)
    arrPvH.push(pvIDX)

f_clearAndSeedL(pvIDX) =>
    arrPvL.push(pvIDX)
    f_drawStructure(marketRegime)
    array.clear(arrPvH)
    array.clear(arrPvL)
    array.clear(arrUpperPoints)
    array.clear(arrLowerPoints)
    arrPvL.push(pvIDX)

// ─── PIVOT HIGH LOGIC ────────────────────────────────────────────────
if not na(pH)
    pvIDX   = bar_index - pivotLength
    lastPvH = arrPvH.size() > 0 ? arrPvH.get(arrPvH.size() - 1) : na

    if na(lastPvH)
        arrPvH.push(pvIDX)
    else
        prevHPrice = high[bar_index - lastPvH]

        if pH > prevHPrice
            // HH
            if marketRegime == 1
                arrPvH.push(pvIDX)
            else if marketRegime == -1
                // HH breaks bear → CHoCH
                f_drawLabel(pvIDX, "»CHoCH«", true, C_CHOCH)
                f_clearAndSeedH(pvIDX)
                marketRegime := 0
            else
                // HH in neutral → BOS, confirms BULL
                f_clearAndSeedH(pvIDX)
                f_drawLabel(pvIDX, "BOS", true, C_BULL)
                marketRegime := 1
        else
            // LH
            if marketRegime == 1
                // LH breaks bull → CHoCH
                f_drawLabel(pvIDX, "»CHoCH«", false, C_CHOCH)
                f_clearAndSeedH(pvIDX)
                marketRegime := 0
            else if marketRegime == -1
                arrPvH.push(pvIDX)
            else
                // LH in neutral → confirms BEAR
                f_clearAndSeedH(pvIDX)
                f_drawLabel(pvIDX, "BOS", true, C_BEAR)
                marketRegime := -1

// ─── PIVOT LOW LOGIC ─────────────────────────────────────────────────
if not na(pL)
    pvIDX   = bar_index - pivotLength
    lastPvL = arrPvL.size() > 0 ? arrPvL.get(arrPvL.size() - 1) : na

    if na(lastPvL)
        arrPvL.push(pvIDX)
    else
        prevLPrice = low[bar_index - lastPvL]

        if pL < prevLPrice
            // LL
            if marketRegime == -1
                arrPvL.push(pvIDX)
            else if marketRegime == 1
                // LL breaks bull → CHoCH
                f_drawLabel(pvIDX, "»CHoCH«", false, C_CHOCH)
                f_clearAndSeedL(pvIDX)
                marketRegime := 0
            else
                // LL in neutral → BOS, confirms BEAR
                f_clearAndSeedL(pvIDX)
                f_drawLabel(pvIDX, "BOS", false, C_BEAR)
                marketRegime := -1
        else
            // HL
            if marketRegime == 1
                arrPvL.push(pvIDX)
            else if marketRegime == -1
                // HL breaks bear → CHoCH
                f_drawLabel(pvIDX, "»CHoCH«", true, C_CHOCH)
                f_clearAndSeedL(pvIDX)
                marketRegime := 0
            else
                // HL in neutral → confirms BULL
                f_clearAndSeedL(pvIDX)
                f_drawLabel(pvIDX, "BOS", true, C_BULL)  
                marketRegime := 1

if barstate.islast
    f_drawCurrentPhase()


barcolor(colorBar)
````
