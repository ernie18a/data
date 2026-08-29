<!-- tradingview-pine-id: PUB;2ee58a0d35684c878d40a4566dd6e3c7 -->
<!-- tradingviewscripts-format: 1 -->
# Liquidity + Order Blocks [V6]

Source: https://www.tradingview.com/script/402zSixn-Liquidity-Order-Blocks/

## Description

Liquidity & Order Blocks [Pine Script 

📌 Overview

Liquidity & Order Blocks [V6] is a price-action and Smart Money Concepts (SMC) style indicator designed to help traders visually identify important liquidity areas, liquidity sweeps, and potential order-block zones directly on the chart.

The indicator is designed primarily as a market-structure and price-action analysis tool. It does not guarantee profitable trades and should not be used as a standalone trading system.

---

🔹 What Does This Indicator Show?

1. Buy-Side Liquidity (BSL)

Buy-side liquidity is generally found above previous swing highs.

The indicator identifies swing highs and projects liquidity levels from them.

When price moves above a previous swing high and then closes back below that level, the indicator can identify it as a:

BSL Sweep — Buy-Side Liquidity Sweep

This can be useful when studying potential bearish reactions after liquidity has been taken.

---

2. Sell-Side Liquidity (SSL)

Sell-side liquidity is generally found below previous swing lows.

The indicator identifies swing lows and projects liquidity levels from them.

When price moves below a previous swing low and then closes back above that level, the indicator can identify it as:

SSL Sweep — Sell-Side Liquidity Sweep

This can be useful when studying potential bullish reactions after liquidity has been taken.

---

🔹 Order Blocks

The indicator automatically searches for potential order blocks following liquidity sweeps.

🟢 Bullish Order Block

A bullish order block is identified after a sell-side liquidity sweep when bullish price action appears.

The indicator searches backward for the most recent bearish candle and uses that candle's high/low as the potential bullish order-block zone.

🔴 Bearish Order Block

A bearish order block is identified after a buy-side liquidity sweep when bearish price action appears.

The indicator searches backward for the most recent bullish candle and uses that candle's high/low as the potential bearish order-block zone.

---

📚 How To Use It

A simple workflow is:

Step 1 — Identify the Market Structure

Start by looking at the overall trend and recent swing highs/lows.

Ask yourself:

- Is price making higher highs and higher lows?
- Is price making lower highs and lower lows?
- Where are the obvious swing points?
- Where might liquidity be resting?

Do not immediately enter a trade just because an order block appears.

---

Step 2 — Find Liquidity

Look for obvious:

Buy-side liquidity

- Previous swing highs
- Equal/near-equal highs
- Areas where traders may have placed stop orders

Sell-side liquidity

- Previous swing lows
- Equal/near-equal lows
- Areas where traders may have placed stop orders

---

Step 3 — Wait for the Sweep

Instead of chasing price into liquidity, watch how price reacts when the liquidity level is taken.

For example:

Price moves below a previous low → takes sell-side liquidity → closes back above the level.

This can indicate that the liquidity below the low has been taken.

The indicator marks this as an SSL Sweep.

---

Step 4 — Look for the Order Block

After a liquidity sweep, look for the corresponding order-block zone.

For a potential bullish setup:

SSL Sweep → Bullish reaction → Bullish Order Block

For a potential bearish setup:

BSL Sweep → Bearish reaction → Bearish Order Block

The order block should be treated as an area of interest, not an automatic entry.

---

Step 5 — Wait for Confirmation

Before entering a trade, consider additional confirmation such as:

- Market Structure Shift
- Break of Structure (BOS)
- Change of Character (CHoCH)
- Strong displacement
- Fair Value Gap (FVG)
- Retest of the order block
- Higher-timeframe direction
- Risk/reward conditions

The more confluence you have, the more selective your setup can become.

---

🎯 Example Bullish Setup

A simplified bullish sequence can look like:

Sell-Side Liquidity → SSL Sweep → Bullish Displacement → Bullish Order Block → Retest → Confirmation

Instead of buying immediately after the sweep, study whether price actually produces a meaningful bullish reaction.

---

🎯 Example Bearish Setup

A simplified bearish sequence can look like:

Buy-Side Liquidity → BSL Sweep → Bearish Displacement → Bearish Order Block → Retest → Confirmation

Again, the indicator is intended to help identify the area for further analysis rather than automatically telling you to sell.

---

⚙️ Important Settings

Swing Length

Controls how sensitive swing-high and swing-low detection is.

Lower value

- More swing points
- More liquidity levels
- More signals
- More noise

Higher value

- Fewer swing points
- Larger structural levels
- Less noise
- More selective analysis

Start with a moderate value and adjust it according to the market and timeframe.

---

Order Block Search Bars

Controls how far back the indicator searches for the candle used to create the potential order block.

A larger value allows the indicator to search farther back, but may also produce zones that are less relevant to the immediate price action.

---

Order Block Extension

Controls how far the order-block zone extends into the future.

---

Maximum Order Blocks

Controls the number of historical order-block zones displayed on the chart.

---

Remove Broken Order Blocks

When enabled, an order block can be removed after price invalidates it according to the indicator's rules.

---

📖 How To Learn Liquidity & Order Blocks

If you are new to this concept, don't try to memorize dozens of SMC terms at once.

Learn in this order:

1️⃣ Market Structure

Learn:

- Swing High
- Swing Low
- Higher High (HH)
- Higher Low (HL)
- Lower High (LH)
- Lower Low (LL)

2️⃣ Liquidity

Learn why liquidity can form around:

- Previous highs
- Previous lows
- Equal highs
- Equal lows
- Obvious support/resistance

3️⃣ Liquidity Sweeps

Study what happens when price trades beyond an obvious high/low and then reverses.

4️⃣ Displacement

Learn to recognize strong directional price movement following a liquidity event.

5️⃣ Order Blocks

Study the relationship between the final opposing candle, displacement, and subsequent price reaction.

6️⃣ Confluence

Finally, combine liquidity and order blocks with market structure, FVGs, higher-timeframe bias, and risk management.

⭐ Recommended Workflow

For a simple approach:

Higher-Timeframe Bias
↓
Identify Liquidity
↓
Wait for Liquidity Sweep
↓
Look for Displacement
↓
Identify Order Block
↓
Wait for Retest
↓
Look for Confirmation
↓
Manage Risk

The goal is not to take every signal.

The goal is to use the indicator to help you understand where liquidity may be located, what price does when that liquidity is taken, and where potential order-block zones may exist.

---

🔔 Alerts

The indicator includes alert conditions for:

- Buy-Side Liquidity Sweep
- Sell-Side Liquidity Sweep
- Bullish Order Block
- Bearish Order Block

You can create TradingView alerts from these conditions and use them as notifications for further analysis.

---

Trade smart. Study the chart. Manage your risk.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ExpertTraderASK

//@version=6
indicator("Liquidity + Order Blocks [V6]", overlay=true, max_boxes_count=100, max_lines_count=100, max_labels_count=100)

//────────────────────────────────────────────────────────────
// INPUTS
//────────────────────────────────────────────────────────────
groupStructure = "Market Structure"
pivotLen       = input.int(5, "Swing Length", minval=1, group=groupStructure)
showSwings     = input.bool(true, "Show Swing High/Low", group=groupStructure)

groupLiquidity = "Liquidity"
showLiquidity  = input.bool(true, "Show Liquidity Levels", group=groupLiquidity)
showSweeps     = input.bool(true, "Show Liquidity Sweeps", group=groupLiquidity)
liqTolerance   = input.float(0.05, "Equal High/Low Tolerance %", minval=0.0, step=0.01, group=groupLiquidity)

groupOB        = "Order Blocks"
showOB         = input.bool(true, "Show Order Blocks", group=groupOB)
obLookback     = input.int(10, "Order Block Search Bars", minval=1, maxval=50, group=groupOB)
obExtend       = input.int(30, "Order Block Extension", minval=1, maxval=500, group=groupOB)
maxOBs         = input.int(10, "Maximum Order Blocks", minval=1, maxval=50, group=groupOB)
removeBroken   = input.bool(true, "Remove Broken Order Blocks", group=groupOB)

groupVisual    = "Visuals"
bullColor      = input.color(color.new(color.green, 80), "Bullish OB", group=groupVisual)
bearColor      = input.color(color.new(color.red, 80), "Bearish OB", group=groupVisual)
liqHighColor   = input.color(color.red, "Buy-Side Liquidity", group=groupVisual)
liqLowColor    = input.color(color.lime, "Sell-Side Liquidity", group=groupVisual)

//────────────────────────────────────────────────────────────
// SWING STRUCTURE
//────────────────────────────────────────────────────────────
float swingHigh = ta.pivothigh(high, pivotLen, pivotLen)
float swingLow  = ta.pivotlow(low, pivotLen, pivotLen)

bool newSwingHigh = not na(swingHigh)
bool newSwingLow  = not na(swingLow)

plotshape(
     showSwings and newSwingHigh,
     title="Swing High",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.tiny,
     offset=-pivotLen
     )

plotshape(
     showSwings and newSwingLow,
     title="Swing Low",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.lime,
     size=size.tiny,
     offset=-pivotLen
     )

//────────────────────────────────────────────────────────────
// STORE LAST SWING LEVELS
//────────────────────────────────────────────────────────────
var float lastHigh = na
var float lastLow  = na

var int lastHighBar = na
var int lastLowBar  = na

if newSwingHigh
    lastHigh := swingHigh
    lastHighBar := bar_index - pivotLen

if newSwingLow
    lastLow := swingLow
    lastLowBar := bar_index - pivotLen

//────────────────────────────────────────────────────────────
// LIQUIDITY LEVELS
//────────────────────────────────────────────────────────────
var line buySideLiquidity = na
var line sellSideLiquidity = na

if newSwingHigh and showLiquidity
    if not na(buySideLiquidity)
        line.delete(buySideLiquidity)

    buySideLiquidity := line.new(
         lastHighBar,
         swingHigh,
         bar_index + 1,
         swingHigh,
         extend=extend.right,
         color=liqHighColor,
         style=line.style_dashed,
         width=1
         )

if newSwingLow and showLiquidity
    if not na(sellSideLiquidity)
        line.delete(sellSideLiquidity)

    sellSideLiquidity := line.new(
         lastLowBar,
         swingLow,
         bar_index + 1,
         swingLow,
         extend=extend.right,
         color=liqLowColor,
         style=line.style_dashed,
         width=1
         )

//────────────────────────────────────────────────────────────
// LIQUIDITY SWEEPS
//────────────────────────────────────────────────────────────

// Buy-side liquidity sweep:
// Price trades above previous swing high but closes back below it.
bool buySideSweep =
     showSweeps and
     not na(lastHigh) and
     high > lastHigh and
     close < lastHigh

// Sell-side liquidity sweep:
// Price trades below previous swing low but closes back above it.
bool sellSideSweep =
     showSweeps and
     not na(lastLow) and
     low < lastLow and
     close > lastLow

plotshape(
     buySideSweep,
     title="Buy-Side Liquidity Sweep",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="BSL SWEEP",
     textcolor=color.white,
     size=size.tiny
     )

plotshape(
     sellSideSweep,
     title="Sell-Side Liquidity Sweep",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     text="SSL SWEEP",
     textcolor=color.white,
     size=size.tiny
     )

//────────────────────────────────────────────────────────────
// ORDER BLOCK ARRAYS
//────────────────────────────────────────────────────────────
var array<box> bullishOBs = array.new<box>()
var array<box> bearishOBs = array.new<box>()

//────────────────────────────────────────────────────────────
// FIND LAST BEARISH CANDLE
// Used for bullish order block
//────────────────────────────────────────────────────────────
findBearishCandle(int lookback) =>
    int foundBar = na

    for i = 1 to lookback
        if close[i] < open[i]
            foundBar := i
            break

    foundBar

//────────────────────────────────────────────────────────────
// FIND LAST BULLISH CANDLE
// Used for bearish order block
//────────────────────────────────────────────────────────────
findBullishCandle(int lookback) =>
    int foundBar = na

    for i = 1 to lookback
        if close[i] > open[i]
            foundBar := i
            break

    foundBar

//────────────────────────────────────────────────────────────
// CREATE BULLISH ORDER BLOCK
// Trigger: Sell-side liquidity sweep + bullish candle
//────────────────────────────────────────────────────────────
if showOB and sellSideSweep and close > open

    int obBar = findBearishCandle(obLookback)

    if not na(obBar)

        float obTop = high[obBar]
        float obBottom = low[obBar]

        box newBullOB = box.new(
             left=bar_index - obBar,
             top=obTop,
             right=bar_index + obExtend,
             bottom=obBottom,
             border_color=color.green,
             border_width=1,
             bgcolor=bullColor
             )

        array.push(bullishOBs, newBullOB)

        if array.size(bullishOBs) > maxOBs
            box oldOB = array.shift(bullishOBs)
            box.delete(oldOB)

//────────────────────────────────────────────────────────────
// CREATE BEARISH ORDER BLOCK
// Trigger: Buy-side liquidity sweep + bearish candle
//────────────────────────────────────────────────────────────
if showOB and buySideSweep and close < open

    int obBar = findBullishCandle(obLookback)

    if not na(obBar)

        float obTop = high[obBar]
        float obBottom = low[obBar]

        box newBearOB = box.new(
             left=bar_index - obBar,
             top=obTop,
             right=bar_index + obExtend,
             bottom=obBottom,
             border_color=color.red,
             border_width=1,
             bgcolor=bearColor
             )

        array.push(bearishOBs, newBearOB)

        if array.size(bearishOBs) > maxOBs
            box oldOB = array.shift(bearishOBs)
            box.delete(oldOB)

//────────────────────────────────────────────────────────────
// ORDER BLOCK MANAGEMENT
//────────────────────────────────────────────────────────────
if array.size(bullishOBs) > 0

    for i = array.size(bullishOBs) - 1 to 0

        box ob = array.get(bullishOBs, i)

        float bottom = box.get_bottom(ob)

        // Bullish OB is invalidated if price closes below it.
        if removeBroken and close < bottom
            box.delete(ob)
            array.remove(bullishOBs, i)

if array.size(bearishOBs) > 0

    for i = array.size(bearishOBs) - 1 to 0

        box ob = array.get(bearishOBs, i)

        float top = box.get_top(ob)

        // Bearish OB is invalidated if price closes above it.
        if removeBroken and close > top
            box.delete(ob)
            array.remove(bearishOBs, i)

//────────────────────────────────────────────────────────────
// ALERTS
//────────────────────────────────────────────────────────────
alertcondition(
     buySideSweep,
     title="Buy-Side Liquidity Sweep",
     message="Buy-side liquidity sweep detected."
     )

alertcondition(
     sellSideSweep,
     title="Sell-Side Liquidity Sweep",
     message="Sell-side liquidity sweep detected."
     )

alertcondition(
     sellSideSweep and close > open,
     title="Bullish Order Block",
     message="Bullish Order Block detected after sell-side liquidity sweep."
     )

alertcondition(
     buySideSweep and close < open,
     title="Bearish Order Block",
     message="Bearish Order Block detected after buy-side liquidity sweep."
     )
````
