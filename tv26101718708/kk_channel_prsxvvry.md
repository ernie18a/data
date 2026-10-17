# KK Channel

- url: https://www.tradingview.com/script/PRSXVvrY-KK-Channel/
- type: indicator
- pine_id: PUB;da94c890a0934aa3ad34108d60b994b8
- version: 1.0

## Description

KK Channel is a precision-based trading indicator designed to simplify market structure, identify high-probability zones, and visually map out institutional price behavior.

Built for traders who focus on price action, structure, and liquidity, this tool combines trend analysis, consolidation detection, and higher-timeframe context into one clean system.

## Source Code

````pine
//@version=6
indicator("KK Channel", overlay=true, max_boxes_count=100)

// === Inputs ===
emaLength      = input.int(21, "EMA Length", minval=1)
rangeLength    = input.int(10, "Consolidation Lookback", minval=2)
rangePercent   = input.float(1.0, "Max Range % for Consolidation", minval=0.1, step=0.1)
insideBarsNeed = input.int(7, "Bars Inside EMA Channel Needed", minval=1)

// === EMA Channel ===
emaHigh = ta.ema(high, emaLength)
emaLow  = ta.ema(low, emaLength)

// === Trend Logic ===
trendBull = close > emaHigh
trendBear = close < emaLow

// === Consolidation Range ===
hh = ta.highest(high, rangeLength)
ll = ta.lowest(low, rangeLength)
rangeWidthPct = ll != 0 ? ((hh - ll) / ll) * 100 : 0.0
tightRange = rangeWidthPct <= rangePercent

// Count how many recent bars closed inside EMA channel
insideCount = 0
for i = 0 to rangeLength - 1
    insideCount += (close[i] <= emaHigh[i] and close[i] >= emaLow[i]) ? 1 : 0

isConsolidating = tightRange and insideCount >= insideBarsNeed

// === Plots ===
p1 = plot(emaHigh, "EMA High (21)", color=color.red, linewidth=2)
p2 = plot(emaLow, "EMA Low (21)", color=color.green, linewidth=2)

fillColor = trendBull ? color.new(color.green, 85) :
     trendBear ? color.new(color.red, 85) :
     color.new(color.gray, 88)

fill(p1, p2, color=fillColor, title="KK Channel Fill")

barcolor(
     trendBull ? color.lime :
     trendBear ? color.red :
     color.gray
)

// === Consolidation Box ===
var box consolidBox = na
var int boxLeft = na
var float boxTop = na
var float boxBottom = na

startNewBox = isConsolidating and not isConsolidating[1]
extendBox   = isConsolidating and not startNewBox
endBox      = not isConsolidating and isConsolidating[1]

if startNewBox
    boxLeft := bar_index - rangeLength + 1
    boxTop := hh
    boxBottom := ll
    consolidBox := box.new(
         left = boxLeft,
         top = boxTop,
         right = bar_index,
         bottom = boxBottom,
         border_color = color.yellow,
         bgcolor = color.new(color.yellow, 85)
     )

if extendBox and not na(consolidBox)
    boxTop := math.max(boxTop, hh)
    boxBottom := math.min(boxBottom, ll)
    box.set_right(consolidBox, bar_index)
    box.set_top(consolidBox, boxTop)
    box.set_bottom(consolidBox, boxBottom)

if endBox and not na(consolidBox)
    box.set_right(consolidBox, bar_index - 1)

// === Alerts ===
alertcondition(isConsolidating, title="KK Consolidation", message="Market is consolidating inside KK Channel")
````
