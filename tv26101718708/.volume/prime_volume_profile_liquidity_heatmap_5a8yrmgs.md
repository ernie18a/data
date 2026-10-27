# Prime Volume Profile + Liquidity Heatmap

- url: https://www.tradingview.com/script/5a8YRMgs/
- type: indicator
- pine_id: PUB;3ef14e6837e548b8a42aeddb00c285d7
- version: 1.0

## Description

This indicator is designed to provide a clear, institutional-style view of market structure and liquidity distribution, combining a fully customizable Volume Profile with a dynamic Liquidity Heatmap.

It operates on a daily basis, automatically resetting at the start of each new trading day to ensure that all calculations reflect fresh, relevant market data.

🔍 Core Features
• Customizable Volume Profile (Daily)

The indicator builds a high-resolution Volume Profile for the current trading day, allowing traders to visualize where trading activity has been most concentrated.

It highlights three key levels:

POC (Point of Control) – the price level with the highest traded volume during the day. This represents the area where the market has found the strongest agreement between buyers and sellers.
VAH (Value Area High) – the upper boundary of the value area, where approximately 70% of the day’s total volume has been traded.
VAL (Value Area Low) – the lower boundary of the value area, completing the range in which most trading activity has occurred.

These levels are recalculated in real time and reset daily, making them highly relevant for intraday and scalping strategies.

• Liquidity Heatmap

In addition to the volume profile, the indicator provides a visual heatmap of recent liquidity.

Areas with higher intensity represent zones where a significant amount of volume has been transacted.
More transparent zones indicate low participation or “empty” areas in the market.

This allows traders to quickly identify:

Where liquidity is concentrated
Where price is more likely to react
Where inefficiencies or low-interest zones exist

🧠 Understanding Liquidity

In trading, liquidity refers to the amount of buy and sell orders available at specific price levels.

High liquidity zones:

Attract price like a magnet
Often act as support/resistance
Are commonly revisited by the market

Low liquidity zones:

Allow price to move quickly
Often result in sharp, impulsive moves

Understanding liquidity helps traders interpret why price moves, not just where it moves.

⚙️ How to Use This Indicator

This tool is best used as a confirmation layer within a broader trading strategy.

Common use cases:
POC as a magnet
Price often gravitates toward the Point of Control. Traders monitor reactions around this level for mean reversion or continuation setups.
VAH / VAL as reaction zones
These levels can act as dynamic support and resistance.
Breakouts or rejections around these zones can signal potential trade opportunities.
Heatmap for execution timing
Use the liquidity heatmap to identify:
High-interest zones for entries or exits
Low-liquidity areas where price may move quickly

⚠️ Important Disclaimer

This indicator is not financial advice and does not provide direct buy or sell signals.

It is intended to be used as a decision-support tool, ideally in combination with:

Price action analysis
Market structure
Other indicators or trading strategies

🎯 Summary

This indicator gives you a real-time map of market participation, helping you understand:

Where volume is concentrated
Where liquidity is sitting
Where price is likely to react

Used correctly, it provides a significant informational edge, especially for intraday and short-term traders.

## Source Code

````pine
//@version=6
indicator("Daily Volume Profile + Liquidity Heatmap", overlay=true, max_lines_count=500, max_boxes_count=500)

// ==========================
// INPUTS
// ==========================
vp_bins      = input.int(40, "VP Bins", minval=10, maxval=100)
vp_valueArea = input.int(70, "Value Area %", minval=50, maxval=95)
vp_offset    = input.int(30, "VP Right Offset")

col_poc = input.color(color.red, "POC Color")
col_vah = input.color(color.blue, "VAH Color")
col_val = input.color(color.blue, "VAL Color")
col_vp  = input.color(color.new(color.gray, 70), "VP Bars")

heat_bins = input.int(30, "Heatmap Resolution", minval=10, maxval=50)
col_bull  = input.color(color.rgb(0,255,255), "Bullish (Neon Azure)")
col_bear  = input.color(color.rgb(180,0,255), "Bearish (Neon Violet)")

// ==========================
// DAY DETECTION
// ==========================
newDay = ta.change(time("D")) != 0

// ==========================
// VARIABLES
// ==========================
var float dayHigh = na
var float dayLow  = na

var float[] vpVol   = array.new_float()
var float[] heatVol = array.new_float()

var bool initialized = false

// ==========================
// INIT / RESET
// ==========================
if not initialized or newDay
    dayHigh := high
    dayLow  := low

    array.clear(vpVol)
    array.clear(heatVol)

    for i = 0 to vp_bins - 1
        array.push(vpVol, 0.0)

    for i = 0 to heat_bins - 1
        array.push(heatVol, 0.0)

    initialized := true

// ==========================
// UPDATE RANGE
// ==========================
dayHigh := math.max(dayHigh, high)
dayLow  := math.min(dayLow, low)

rangeVP = dayHigh - dayLow
stepVP  = rangeVP / vp_bins

// ==========================
// BUILD VP (LIGHTWEIGHT)
// ==========================
if stepVP > 0 and array.size(vpVol) == vp_bins
    for i = 0 to vp_bins - 1
        lvlLow  = dayLow + stepVP * i
        lvlHigh = lvlLow + stepVP

        if close >= lvlLow and close < lvlHigh
            array.set(vpVol, i, array.get(vpVol, i) + volume)

// ==========================
// POC + VA CALCULATION
// ==========================
float pocPrice = na
float vahPrice = na
float valPrice = na
float maxVol   = na

if array.size(vpVol) == vp_bins and stepVP > 0

    maxVol := 0.0
    int pocIdx = 0

    // POC
    for i = 0 to vp_bins - 1
        v = array.get(vpVol, i)
        if v > maxVol
            maxVol := v
            pocIdx := i

    // TOTAL
    float totalVol = 0.0
    for i = 0 to vp_bins - 1
        totalVol += array.get(vpVol, i)

    target = totalVol * vp_valueArea / 100.0

    int up = pocIdx
    int dn = pocIdx
    float accVol = maxVol

    // VA EXPANSION (SAFE)
    for i = 0 to vp_bins - 1
        if accVol >= target
            break

        upVol = up < vp_bins - 1 ? array.get(vpVol, up + 1) : 0
        dnVol = dn > 0 ? array.get(vpVol, dn - 1) : 0

        if upVol > dnVol
            accVol += upVol
            up += 1
        else
            accVol += dnVol
            dn -= 1

    pocPrice := dayLow + stepVP * pocIdx
    vahPrice := dayLow + stepVP * up
    valPrice := dayLow + stepVP * dn

// ==========================
// DRAW VP
// ==========================
var line[] vpLines = array.new_line()

if barstate.isfirst
    for i = 0 to vp_bins - 1
        array.push(vpLines, line.new(bar_index, close, bar_index, close))

if barstate.islast and array.size(vpVol) == vp_bins
    maxWidth = 20

    for i = 0 to vp_bins - 1
        vol = array.get(vpVol, i)

        width = (not na(maxVol) and maxVol > 0) ? math.round(vol / maxVol * maxWidth) : 0

        y = dayLow + stepVP * i

        x1 = bar_index + vp_offset - width
        x2 = bar_index + vp_offset

        l = array.get(vpLines, i)
        line.set_xy1(l, x1, y)
        line.set_xy2(l, x2, y)
        line.set_color(l, col_vp)

// ==========================
// DRAW POC / VA
// ==========================
var line pocLine = na
var line vahLine = na
var line valLine = na

if barstate.isfirst
    pocLine := line.new(bar_index, close, bar_index, close, color=col_poc, width=2)
    vahLine := line.new(bar_index, close, bar_index, close, color=col_vah, width=1)
    valLine := line.new(bar_index, close, bar_index, close, color=col_val, width=1)

if barstate.islast
    if not na(pocPrice)
        line.set_xy1(pocLine, bar_index - 100, pocPrice)
        line.set_xy2(pocLine, bar_index + vp_offset, pocPrice)

    if not na(vahPrice)
        line.set_xy1(vahLine, bar_index - 100, vahPrice)
        line.set_xy2(vahLine, bar_index + vp_offset, vahPrice)

    if not na(valPrice)
        line.set_xy1(valLine, bar_index - 100, valPrice)
        line.set_xy2(valLine, bar_index + vp_offset, valPrice)

// ==========================
// HEATMAP BUILD
// ==========================
rangeH = dayHigh - dayLow
stepH  = rangeH / heat_bins

if stepH > 0 and array.size(heatVol) == heat_bins
    for i = 0 to heat_bins - 1
        lvlLow  = dayLow + stepH * i
        lvlHigh = lvlLow + stepH

        if close >= lvlLow and close < lvlHigh
            array.set(heatVol, i, array.get(heatVol, i) + volume)

// ==========================
// DRAW HEATMAP
// ==========================
var box[] heatBoxes = array.new_box()

if barstate.islast and array.size(heatVol) == heat_bins

    for b in heatBoxes
        box.delete(b)
    array.clear(heatBoxes)

    maxHeat = 0.0
    for i = 0 to heat_bins - 1
        maxHeat := math.max(maxHeat, array.get(heatVol, i))

    for i = 0 to heat_bins - 1
        vol = array.get(heatVol, i)

        strength = maxHeat > 0 ? vol / maxHeat : 0
        alpha = 90 - int(strength * 80)

        y1 = dayLow + stepH * i
        y2 = y1 + stepH

        mid = (y1 + y2) / 2
        col = close > mid ? col_bull : col_bear
        col := color.new(col, alpha)

        b = box.new(
            bar_index - 20,
            y2,
            bar_index,
            y1,
            bgcolor = col,
            border_color = na
        )

        array.push(heatBoxes, b)
````
