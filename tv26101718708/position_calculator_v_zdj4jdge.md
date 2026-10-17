# Position Calculator - V

- url: https://www.tradingview.com/script/Zdj4JDGe/
- type: indicator
- pine_id: PUB;d822d0a8017d41cb899ad3d80ae2b121
- version: 1.0

## Description

Position Calculator — Dynamic Stop Loss & Targets
A simple, chart-synced position calculator that automatically adjusts to your current timeframe. Enter your entry price, select direction (Long/Short), and instantly get a logical stop loss based on ATR, plus two take-profit targets based on customizable risk/reward ratios.
Features:

ATR-based stop loss that adapts to the current timeframe's volatility
Customizable ATR length and multiplier
Two take-profit levels with adjustable R:R ratios (default 1:1 and 1:2)
Visual lines on chart for Entry, Stop, TP1, and TP2
Clean info table showing prices, percentages, ATR value, and stop distance
Configurable table position

How to use:

Add the indicator to your chart
Open settings and enter your entry price
Select Long or Short
The stop and targets calculate automatically based on the timeframe you're viewing

Switching timeframes updates the stop dynamically — perfect for traders who want a logical, volatility-adjusted stop without manual recalculation.

## Source Code

````pine
//@version=5
indicator("Position Calculator - Vitali", overlay=true)

// === Inputs ===
entryPrice  = input.float(0.0, "מחיר כניסה", step=0.01, tooltip="הזן את מחיר הכניסה שלך")
direction   = input.string("Long", "כיוון", options=["Long", "Short"])
atrLength   = input.int(14, "ATR Length", minval=1)
atrMult     = input.float(1.5, "מכפיל ATR לסטופ", step=0.1, minval=0.1)
rrTarget1   = input.float(1.0, "יחס סיכון/סיכוי TP1", step=0.1, minval=0.1)
rrTarget2   = input.float(2.0, "יחס סיכון/סיכוי TP2", step=0.1, minval=0.1)
showLines   = input.bool(true, "הצג קווים על הגרף")
tablePos    = input.string("top_right", "מיקום טבלה", options=["top_right","top_left","bottom_right","bottom_left","middle_right","middle_left"])

// === Calculations ===
atrVal = ta.atr(atrLength)
stopDistance = atrVal * atrMult

isLong = direction == "Long"

stopPrice = isLong ? entryPrice - stopDistance : entryPrice + stopDistance
tp1Price  = isLong ? entryPrice + stopDistance * rrTarget1 : entryPrice - stopDistance * rrTarget1
tp2Price  = isLong ? entryPrice + stopDistance * rrTarget2 : entryPrice - stopDistance * rrTarget2

riskPct = entryPrice > 0 ? (stopDistance / entryPrice) * 100 : 0
tp1Pct  = entryPrice > 0 ? (math.abs(tp1Price - entryPrice) / entryPrice) * 100 : 0
tp2Pct  = entryPrice > 0 ? (math.abs(tp2Price - entryPrice) / entryPrice) * 100 : 0

// === Lines on Chart ===
var line entryLine = na
var line stopLine  = na
var line tp1Line   = na
var line tp2Line   = na

if showLines and entryPrice > 0
    line.delete(entryLine)
    line.delete(stopLine)
    line.delete(tp1Line)
    line.delete(tp2Line)
    entryLine := line.new(bar_index - 50, entryPrice, bar_index + 10, entryPrice, color=color.blue, width=2, style=line.style_solid, extend=extend.right)
    stopLine  := line.new(bar_index - 50, stopPrice,  bar_index + 10, stopPrice,  color=color.red,  width=2, style=line.style_dashed, extend=extend.right)
    tp1Line   := line.new(bar_index - 50, tp1Price,   bar_index + 10, tp1Price,   color=color.green, width=1, style=line.style_dashed, extend=extend.right)
    tp2Line   := line.new(bar_index - 50, tp2Price,   bar_index + 10, tp2Price,   color=color.new(color.green, 0), width=2, style=line.style_dashed, extend=extend.right)

// === Table ===
tablePosition = tablePos == "top_right" ? position.top_right : tablePos == "top_left" ? position.top_left : tablePos == "bottom_right" ? position.bottom_right : tablePos == "bottom_left" ? position.bottom_left : tablePos == "middle_right" ? position.middle_right : position.middle_left

var table calcTable = table.new(tablePosition, 2, 7, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.gray)

if barstate.islast and entryPrice > 0
    table.cell(calcTable, 0, 0, "Position Calc", text_color=color.white, bgcolor=color.new(color.blue, 30), text_size=size.normal)
    table.cell(calcTable, 1, 0, direction, text_color=color.white, bgcolor=isLong ? color.new(color.green, 30) : color.new(color.red, 30), text_size=size.normal)

    table.cell(calcTable, 0, 1, "Entry", text_color=color.white)
    table.cell(calcTable, 1, 1, str.tostring(entryPrice, "#.##"), text_color=color.aqua)

    table.cell(calcTable, 0, 2, "Stop Loss", text_color=color.white)
    table.cell(calcTable, 1, 2, str.tostring(stopPrice, "#.##") + "  (-" + str.tostring(riskPct, "#.##") + "%)", text_color=color.red)

    table.cell(calcTable, 0, 3, "TP1 (1:" + str.tostring(rrTarget1, "#.#") + ")", text_color=color.white)
    table.cell(calcTable, 1, 3, str.tostring(tp1Price, "#.##") + "  (+" + str.tostring(tp1Pct, "#.##") + "%)", text_color=color.lime)

    table.cell(calcTable, 0, 4, "TP2 (1:" + str.tostring(rrTarget2, "#.#") + ")", text_color=color.white)
    table.cell(calcTable, 1, 4, str.tostring(tp2Price, "#.##") + "  (+" + str.tostring(tp2Pct, "#.##") + "%)", text_color=color.green)

    table.cell(calcTable, 0, 5, "ATR(" + str.tostring(atrLength) + ")", text_color=color.white)
    table.cell(calcTable, 1, 5, str.tostring(atrVal, "#.##"), text_color=color.yellow)

    table.cell(calcTable, 0, 6, "Stop Distance", text_color=color.white)
    table.cell(calcTable, 1, 6, str.tostring(stopDistance, "#.##"), text_color=color.orange)
````
