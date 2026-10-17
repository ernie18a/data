# Liquidity Rails @darshakssc

- url: https://www.tradingview.com/script/6VaV7QYM-Liquidity-Rails-darshakssc/
- type: indicator
- pine_id: PUB;2dd7c43c4d56433fabd32145125507b3
- version: 1.0

## Description

Liquidity Rails projects dotted liquidity lines from every confirmed swing pivot — sellside 
liquidity above prior highs, buyside liquidity below prior lows — and automatically removes 
each line the moment price sweeps through it, giving an always-current liquidity map instead 
of a cluttered chart full of old, already-swept levels.

🔶 HOW IT WORKS
Every confirmed pivot high spawns a dotted line projecting forward, labeled "Sellside 
liquidity." Every confirmed pivot low spawns a dotted line labeled "Buyside liquidity." Nearby 
levels of the same type (within an ATR-based tolerance) automatically merge into a single 
line with a touch count, instead of stacking overlapping duplicate labels. The moment price 
closes through a level, that line is deleted — swept liquidity doesn't linger on the chart.

🔶 HOW TO USE
- Red dotted line above price = resting sellside liquidity (prior high).
- Green dotted line below price = resting buyside liquidity (prior low).
- A line disappearing = that level was just swept by price.
- "×2 / ×3" on a label = multiple nearby swing points clustered into one liquidity zone.

🔶 SETTINGS
Swing Lookback (pivot sensitivity), Max Tracked Lines, ATR-based label offset, Merge Nearby 
Levels tolerance, custom colors.

🔶 LIMITATIONS
Pivot confirmation requires right-side bars, so lines appear with an inherent lag — standard 
for any non-repainting pivot-based tool. In fast trending markets many lines can appear and 
sweep in quick succession; increase Max Tracked Lines or Swing Lookback for a calmer view.

This script is 100% original, open-source (MPL 2.0), and does not repaint.

For educational/informational purposes only. Not financial advice. Past performance does 
not guarantee future results. Always use proper risk management.

## Source Code

````pine
// @darshakssc — Radhe Radhe 🙏
//@version=6
indicator("Liquidity Rails [Original]", shorttitle="LiqRails", overlay=true, max_lines_count=150, max_labels_count=150)

// ───────────────────────── INPUTS ─────────────────────────
grpCore = "Core Settings"
swingLen = input.int(10, "Swing Lookback (Left/Right Bars)", minval=2, group=grpCore)
maxLines = input.int(15, "Max Tracked Lines", minval=3, maxval=40, group=grpCore)
atrLen   = input.int(14, "ATR Length (label offset)", minval=1, group=grpCore)
clusterTolerance = input.float(1.0, "Merge Nearby Levels (x ATR)", minval=0.0, step=0.1, group=grpCore)

grpDisplay = "Display"
showLabels = input.bool(true, "Show Labels", group=grpDisplay)
sellColor  = input.color(#ff4d6d, "Sellside (Above) Color", group=grpDisplay)
buyColor   = input.color(#00c896, "Buyside (Below) Color", group=grpDisplay)

// ───────────────────────── SWING TRACKING (global scope) ─────────────────────────
atrVal = ta.atr(atrLen)
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)
pivotBarIdx = bar_index - swingLen

// ───────────────────────── RAIL STATE ARRAYS ─────────────────────────
var array<float> railPrice  = array.new<float>(0)
var array<bool>  railIsHigh = array.new<bool>(0)
var array<line>  railLine   = array.new<line>(0)
var array<label> railLabel  = array.new<label>(0)
var array<int>   railCount  = array.new<int>(0)

addRail(price, isHigh, leftBar) =>
    col = isHigh ? sellColor : buyColor
    tol = atrVal * clusterTolerance
    found = false
    if array.size(railPrice) > 0
        for i = 0 to array.size(railPrice) - 1
            if array.get(railIsHigh, i) == isHigh and math.abs(array.get(railPrice, i) - price) <= tol
                newCount = array.get(railCount, i) + 1
                array.set(railCount, i, newCount)
                existingLb = array.get(railLabel, i)
                if not na(existingLb)
                    baseText = isHigh ? "Sellside liquidity" : "Buyside liquidity"
                    label.set_text(existingLb, baseText + " ×" + str.tostring(newCount))
                found := true
                break
    if not found
        newLn = line.new(leftBar, price, bar_index, price, color=color.new(col, 5), width=2, style=line.style_dotted)
        label newLb = na
        if showLabels
            offset = atrVal * 0.4
            labelPrice = isHigh ? price + offset : price - offset
            newLb := label.new(leftBar, labelPrice, isHigh ? "Sellside liquidity" : "Buyside liquidity", style=label.style_none, color=color.new(col, 100), textcolor=col, size=size.small)
        array.push(railPrice, price)
        array.push(railIsHigh, isHigh)
        array.push(railLine, newLn)
        array.push(railLabel, newLb)
        array.push(railCount, 1)
        if array.size(railPrice) > maxLines
            line.delete(array.shift(railLine))
            oldLb = array.shift(railLabel)
            if not na(oldLb)
                label.delete(oldLb)
            array.shift(railPrice)
            array.shift(railIsHigh)
            array.shift(railCount)

if not na(ph)
    addRail(ph, true, pivotBarIdx)
if not na(pl)
    addRail(pl, false, pivotBarIdx)

// ───────────────────────── SWEEP DETECTION + LINE EXTENSION ─────────────────────────
var bool sweepSellEvent = false
var bool sweepBuyEvent  = false
sweepSellEvent := false
sweepBuyEvent  := false

if barstate.isconfirmed and array.size(railPrice) > 0
    for i = array.size(railPrice) - 1 to 0
        price  = array.get(railPrice, i)
        isHigh = array.get(railIsHigh, i)
        swept = isHigh ? (close > price and close[1] <= price) : (close < price and close[1] >= price)
        if swept
            line.delete(array.get(railLine, i))
            lb = array.get(railLabel, i)
            if not na(lb)
                label.delete(lb)
            array.remove(railPrice, i)
            array.remove(railIsHigh, i)
            array.remove(railLine, i)
            array.remove(railLabel, i)
            array.remove(railCount, i)
            if isHigh
                sweepSellEvent := true
            else
                sweepBuyEvent := true
        else
            line.set_x2(array.get(railLine, i), bar_index)

// ───────────────────────── ALERTS ─────────────────────────
alertcondition(sweepSellEvent, "Sellside Liquidity Swept", "Liquidity Rails — price swept a sellside liquidity level.")
alertcondition(sweepBuyEvent, "Buyside Liquidity Swept", "Liquidity Rails — price swept a buyside liquidity level.")
````
