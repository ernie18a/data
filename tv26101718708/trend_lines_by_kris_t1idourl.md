# Trend Lines by Kris

- url: https://www.tradingview.com/script/t1IDOuRL-trend-lines-by-kris/
- type: indicator
- pine_id: PUB;c894299903b44e0da5bfc9161242dfc1
- version: 1.0

## Description

This indicator is an automated tool designed to identify and draw valid trend lines directly on your chart, based on significant price swing points (pivots). It helps traders visualize the current trend structure without manually drawing lines.

[b]How it works[/b]

The script detects pivot highs and pivot lows using a configurable sensitivity period. A pivot high is confirmed when its price is the highest point within the surrounding bars on both sides. A pivot low is confirmed symmetrically. Once two consecutive pivot highs form a descending sequence, the script attempts to draw a Supply (downtrend) line. Once two consecutive pivot lows form an ascending sequence, it attempts to draw a Demand (uptrend) line.
Before drawing, each candidate line goes through a strict validation process:

No candle body (open or close) may cross the line between the two pivot points
No candle body may cross the projected line from the second pivot up to the current bar
The line angle must fall within a realistic range to filter out near-vertical lines

This ensures that only clean, unbroken trend lines are displayed.

[b]Unique Feature: Auto-Break Detection[/b]

The indicator continuously monitors price action against each active trend line. If a candle body closes beyond the line, the trend line is automatically fixed at the point of the break and stops extending. A new trend line will be drawn as soon as the next valid pivot structure forms. Up to 3 historical trend lines per side are kept on the chart so you can see recent structure at a glance.

Angle labels
Each trend line displays its angle in degrees at the starting point, normalized to the visible price range. This gives you a quick read on trend momentum — steeper angles indicate stronger, faster-moving trends.
Alerts
Two alert conditions are available:

Supply Line Break — fires when price closes above an active downtrend line
Demand Line Break — fires when price closes below an active uptrend line

[b]Settings[/b]

Sensitivity: controls how significant a price swing must be to qualify as a pivot. Higher values produce fewer but more meaningful trend lines
Supply Lines / Demand Lines: toggle each direction independently
Line width: visual preference
Supply color / Demand color: customize to match your chart style

[b]Usage[/b]

Use Supply lines as dynamic resistance and Demand lines as dynamic support. A confirmed body close beyond the line signals a potential trend change. Combine with your existing levels or imbalance zones for higher-confidence entries.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © KRISTRADER1

//@version=6
indicator("Trend Lines by Kris", overlay=true, max_lines_count=500, max_labels_count=500, max_bars_back=5000)

// ===== SETTINGS =====
prd         = input.int(20,            "Sensitivity",  minval=5, maxval=50, tooltip="Controls how significant a price swing must be to form a trend line. Higher = fewer but more significant lines")
showSupply  = input.bool(true,         "Supply Lines")
showDemand  = input.bool(true,         "Demand Lines")
lineWidth   = input.int(1,             "Line width",   minval=1, maxval=4)
supplyColor = input.color(color.red,   "Supply color")
demandColor = input.color(color.green, "Demand color")

// ===== PIVOTS =====
float ph = ta.pivothigh(prd, prd)
float pl = ta.pivotlow(prd, prd)

// ===== TYPES =====
type pivotPoint
    float price
    int   barIdx

// ===== ANGLE NORMALIZATION =====
bars   = 500
ratio  = 3.0
height = bars / ratio
Xaxis  = math.min(math.max(1, bar_index), bars)
Yaxis  = ta.highest(Xaxis) - ta.lowest(Xaxis)

calcAngle(int x1, float y1, int x2, float y2) =>
    diffX = x2 - x1
    diffY = y2 - y1
    angleResult = 0.0
    if diffX != 0 and diffY != 0 and Yaxis != 0
        diffYToYaxis    = Yaxis / diffY
        normalisedSlope = (height / diffYToYaxis) / diffX
        angleResult    := math.abs(math.round(math.atan(normalisedSlope) * 180 / math.pi, 2))
    angleResult

// ===== PIVOT BINS =====
var pivotPoint[] supplyBin = array.new<pivotPoint>()
var pivotPoint[] demandBin = array.new<pivotPoint>()

// ===== ACTIVE LINE TRACKING =====
var line  supplyLine   = na
var int   supplyLX1    = na
var float supplyLY1    = na
var int   supplyLX2    = na
var float supplyLY2    = na
var bool  supplyBroken = true

var line  demandLine   = na
var int   demandLX1    = na
var float demandLY1    = na
var int   demandLX2    = na
var float demandLY2    = na
var bool  demandBroken = true

// ===== LINE + LABEL HISTORY =====
var line[]  supplyLineHist  = array.new_line()
var label[] supplyLabelHist = array.new_label()
var line[]  demandLineHist  = array.new_line()
var label[] demandLabelHist = array.new_label()

// ===== HELPERS =====
calcLineY(int x1, float y1, int x2, float y2, int x) =>
    y1 + (y2 - y1) * (x - x1) / (x2 - x1)

trimHistory(line[] lns, label[] lbls, int maxCount) =>
    while array.size(lns) > maxCount
        line.delete(array.shift(lns))
        label.delete(array.shift(lbls))

maxDist = int(prd * 7)

// ===== SUPPLY LOGIC =====
if showSupply and not na(ph)
    array.unshift(supplyBin, pivotPoint.new(ph, bar_index - prd))
    if array.size(supplyBin) > 10
        array.pop(supplyBin)

    if array.size(supplyBin) > 1
        current = array.get(supplyBin, 0)
        before  = array.get(supplyBin, 1)

        if current.price < before.price and (current.barIdx - before.barIdx) <= maxDist
            valid = supplyBroken

            if not valid and array.size(supplyBin) > 2
                prev2 = array.get(supplyBin, 2)
                valid := before.price < prev2.price

            if valid
                ok = true
                for b = before.barIdx + 1 to current.barIdx - 1
                    if close[bar_index - b] > calcLineY(before.barIdx, before.price, current.barIdx, current.price, b)
                        ok := false
                        break
                if ok
                    for b = current.barIdx to bar_index
                        if close[bar_index - b] > calcLineY(before.barIdx, before.price, current.barIdx, current.price, b)
                            ok := false
                            break

                if ok
                    angle = calcAngle(before.barIdx, before.price, current.barIdx, current.price)
                    if angle <= 30.0
                        supplyLX1    := before.barIdx
                        supplyLY1    := before.price
                        supplyLX2    := current.barIdx
                        supplyLY2    := current.price
                        supplyBroken := false
                        supplyLine   := line.new(before.barIdx, before.price, current.barIdx, current.price,
                         extend = extend.none,
                         color  = supplyColor,
                         width  = lineWidth,
                         style  = line.style_solid)
                        lbl = label.new(before.barIdx, before.price, str.tostring(angle) + "°",
                         style     = label.style_label_down,
                         color     = color.new(chart.bg_color, 100),
                         textcolor = supplyColor,
                         size      = size.small)
                        array.push(supplyLineHist,  supplyLine)
                        array.push(supplyLabelHist, lbl)
                        trimHistory(supplyLineHist, supplyLabelHist, 3)

bool supplyBreakNow = false
if not na(supplyLine) and not supplyBroken
    lineNow  = calcLineY(supplyLX1, supplyLY1, supplyLX2, supplyLY2, bar_index)
    bodyHigh = math.max(open, close)
    if bodyHigh > lineNow
        supplyBroken   := true
        supplyBreakNow := true
        line.set_x2(supplyLine, bar_index)
        line.set_y2(supplyLine, lineNow)
    else
        line.set_x2(supplyLine, bar_index)
        line.set_y2(supplyLine, lineNow)

// ===== DEMAND LOGIC =====
if showDemand and not na(pl)
    array.unshift(demandBin, pivotPoint.new(pl, bar_index - prd))
    if array.size(demandBin) > 10
        array.pop(demandBin)

    if array.size(demandBin) > 1
        current = array.get(demandBin, 0)
        before  = array.get(demandBin, 1)

        if current.price > before.price and (current.barIdx - before.barIdx) <= maxDist
            valid = demandBroken

            if not valid and array.size(demandBin) > 2
                prev2 = array.get(demandBin, 2)
                valid := before.price > prev2.price

            if valid
                ok = true
                for b = before.barIdx + 1 to current.barIdx - 1
                    if close[bar_index - b] < calcLineY(before.barIdx, before.price, current.barIdx, current.price, b)
                        ok := false
                        break
                if ok
                    for b = current.barIdx to bar_index
                        if close[bar_index - b] < calcLineY(before.barIdx, before.price, current.barIdx, current.price, b)
                            ok := false
                            break

                if ok
                    angle = calcAngle(before.barIdx, before.price, current.barIdx, current.price)
                    if angle <= 30.0
                        demandLX1    := before.barIdx
                        demandLY1    := before.price
                        demandLX2    := current.barIdx
                        demandLY2    := current.price
                        demandBroken := false
                        demandLine   := line.new(before.barIdx, before.price, current.barIdx, current.price,
                         extend = extend.none,
                         color  = demandColor,
                         width  = lineWidth,
                         style  = line.style_solid)
                        lbl = label.new(before.barIdx, before.price, str.tostring(angle) + "°",
                         style     = label.style_label_up,
                         color     = color.new(chart.bg_color, 100),
                         textcolor = demandColor,
                         size      = size.small)
                        array.push(demandLineHist,  demandLine)
                        array.push(demandLabelHist, lbl)
                        trimHistory(demandLineHist, demandLabelHist, 3)

bool demandBreakNow = false
if not na(demandLine) and not demandBroken
    lineNow = calcLineY(demandLX1, demandLY1, demandLX2, demandLY2, bar_index)
    bodyLow = math.min(open, close)
    if bodyLow < lineNow
        demandBroken   := true
        demandBreakNow := true
        line.set_x2(demandLine, bar_index)
        line.set_y2(demandLine, lineNow)
    else
        line.set_x2(demandLine, bar_index)
        line.set_y2(demandLine, lineNow)

// ===== ALERTS =====
alertcondition(supplyBreakNow, "Supply Line Break", "Price closed above the Supply Trend Line")
alertcondition(demandBreakNow, "Demand Line Break", "Price closed below the Demand Trend Line")
````
