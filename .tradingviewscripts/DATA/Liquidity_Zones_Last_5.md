<!-- tradingview-pine-id: PUB;a8365c46cf854c588166a7c741ef83ad -->
<!-- tradingviewscripts-format: 1 -->
# Liquidity Zones - Last 5

Source: https://www.tradingview.com/script/XQeTY3uf-Liquidity-Zones-Last-5/

## Description

Liquidity Zones — Last 5

A simple and clean Liquidity Zones indicator designed to help traders identify potential Buy-Side Liquidity (BSL) and Sell-Side Liquidity (SSL) using equal highs and equal lows.

🔴 Buy-Side Liquidity

The indicator identifies nearby/equal swing highs and marks the area as a potential Buy-Side Liquidity zone.

🟢 Sell-Side Liquidity

The indicator identifies nearby/equal swing lows and marks the area as a potential Sell-Side Liquidity zone.

📦 Last 5 Liquidity Areas

To keep the chart clean and focused, the indicator displays only the 5 most recent liquidity zones. When a new zone is created, the oldest zone is automatically removed.

⚙️ Customizable Settings

You can adjust:

- Pivot Length
- Equal High/Low Tolerance
- Liquidity Zone Size
- Box Extension
- Buy-Side Liquidity visibility
- Sell-Side Liquidity visibility
- Zone colors

🎯 Purpose

This indicator is designed to help traders visually identify areas where liquidity may be resting around previous equal highs and lows.

Use these zones together with your own market structure, price action, BOS/CHOCH, FVG, and risk-management rules.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ExpertTraderASK

//@version=6
indicator("Liquidity Zones - Last 5", overlay=true, max_boxes_count=50, max_lines_count=50)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
pivotLength = input.int(3, "Pivot Length", minval=1)
tolerance   = input.float(0.10, "Equal High/Low Tolerance %", minval=0.01, step=0.01)
zoneSize    = input.float(0.10, "Liquidity Zone Size %", minval=0.01, step=0.01)
extendBars  = input.int(100, "Box Extension Bars", minval=10)

showBuySide  = input.bool(true, "Show Buy-Side Liquidity")
showSellSide = input.bool(true, "Show Sell-Side Liquidity")

buyColor  = input.color(color.red, "Buy-Side Liquidity")
sellColor = input.color(color.green, "Sell-Side Liquidity")

// ─────────────────────────────────────────────
// ARRAYS FOR LAST 5 LIQUIDITY BOXES
// ─────────────────────────────────────────────
var box[] liquidityBoxes = array.new_box()

// Store recent pivot prices
var float lastHigh = na
var int   lastHighBar = na

var float lastLow = na
var int   lastLowBar = na

// ─────────────────────────────────────────────
// PIVOTS
// ─────────────────────────────────────────────
pivotHigh = ta.pivothigh(high, pivotLength, pivotLength)
pivotLow  = ta.pivotlow(low, pivotLength, pivotLength)

// ─────────────────────────────────────────────
// FUNCTION: ADD LIQUIDITY BOX
// ─────────────────────────────────────────────
addLiquidityBox(_left, _top, _bottom, _color) =>
    newBox = box.new(
         left = _left,
         top = _top,
         right = bar_index + extendBars,
         bottom = _bottom,
         border_color = _color,
         bgcolor = color.new(_color, 85)
     )

    array.push(liquidityBoxes, newBox)

    // Keep only the latest 5 zones
    if array.size(liquidityBoxes) > 5
        oldBox = array.shift(liquidityBoxes)
        box.delete(oldBox)

// ─────────────────────────────────────────────
// BUY-SIDE LIQUIDITY
// Equal Highs
// ─────────────────────────────────────────────
if not na(pivotHigh)
    currentHigh = pivotHigh
    currentHighBar = bar_index - pivotLength

    if not na(lastHigh)
        difference = math.abs(currentHigh - lastHigh) / lastHigh * 100

        if difference <= tolerance and showBuySide
            zoneTop = math.max(currentHigh, lastHigh)
            zoneBottom = zoneTop * (1 - zoneSize / 100)

            addLiquidityBox(
                 math.min(currentHighBar, lastHighBar),
                 zoneTop,
                 zoneBottom,
                 buyColor
             )

    lastHigh := currentHigh
    lastHighBar := currentHighBar

// ─────────────────────────────────────────────
// SELL-SIDE LIQUIDITY
// Equal Lows
// ─────────────────────────────────────────────
if not na(pivotLow)
    currentLow = pivotLow
    currentLowBar = bar_index - pivotLength

    if not na(lastLow)
        difference = math.abs(currentLow - lastLow) / lastLow * 100

        if difference <= tolerance and showSellSide
            zoneBottom = math.min(currentLow, lastLow)
            zoneTop = zoneBottom * (1 + zoneSize / 100)

            addLiquidityBox(
                 math.min(currentLowBar, lastLowBar),
                 zoneTop,
                 zoneBottom,
                 sellColor
             )

    lastLow := currentLow
    lastLowBar := currentLowBar

// ─────────────────────────────────────────────
// EXTEND ACTIVE BOXES
// ─────────────────────────────────────────────
if array.size(liquidityBoxes) > 0
    for i = 0 to array.size(liquidityBoxes) - 1
        b = array.get(liquidityBoxes, i)
        box.set_right(b, bar_index + extendBars)
````
