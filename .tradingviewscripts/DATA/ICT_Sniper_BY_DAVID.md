<!-- tradingview-pine-id: PUB;a121b9e1a05d49df915b9ac749fd9b80 -->
<!-- tradingviewscripts-format: 1 -->
# ICT Sniper BY DAVID

Source: https://www.tradingview.com/script/oAmR5VYx-ICT-Sniper-BY-DAVID/

## Description

The ICT Sniper (Clean Version) is a systematic Pine Script v6 indicator designed for traders using Smart Money Concepts (SMC) and Price Action models. Based on mechanical entry models, this tool identifies institutional market manipulations and precise entry zones by combining Liquidity Sweeps with Fair Value Gaps (FVG).

Instead of cluttering the chart with endless technical indicators, this script operates on market structure and liquidity dynamics. It isolates low-risk, high-probability execution points by waiting for institutional smart money to sweep liquidity before confirming an entry via market imbalance.

Core Strategy and Logical Framework
The indicator executes a mechanical three-phase validation sequence:

1. Liquidity Sweep Detection
Market makers frequently run price beyond key swing points to activate retail stop-loss orders and breakout entries. This script continuously monitors market structure using pivot points:

Bullish Sweep: Price breaks below a recent Pivot Low to grab sell-side liquidity, but the bar closes back above that low, confirming a stop run rather than a legitimate breakout.

Bearish Sweep: Price breaks above a recent Pivot High to grab buy-side liquidity, but the bar closes back below that high, confirming a false breakout.

2. Order Block Marking
When a sweep occurs, the script flags the specific candle or range where the liquidity sweep originated as an active Order Block zone, anticipating that institutional orders remain resting within this area.

3. Fair Value Gap (FVG) Refinement and Signal Trigger
A liquidity sweep alone is insufficient for an entry. The strategy requires displacement—rapid price movement leaving behind an imbalance (FVG).

The indicator tracks the bars following a sweep up to a user-defined lookback window (default: 10 bars).

If a three-candle imbalance forms within this lookback window:

Bullish FVG (Low of candle 1 > High of candle 3): Triggers a BUY Entry signal.

Bearish FVG (High of candle 1 < Low of candle 3): Triggers a SELL Entry signal.

Detailed Input Parameters
Market Structure
Pivot Lookback Length (Default: 5): Determines the sensitivity of swing highs and lows. A smaller number identifies short-term internal liquidity, while a larger number focuses on major swing points.

Strategy Rules
Max Bars After Sweep to Find FVG (Default: 10): Specifies the maximum duration allowed between the liquidity sweep and the displacement/FVG formation. If an FVG forms after this limit, the signal is discarded to ensure only fresh displacement is traded.

Clean Visuals
Show Minor Sweep Shapes (Default: Off): Displays minor directional indicators on every sweep candle. Kept disabled by default to maintain chart clarity.

Show Active Order Blocks (Default: On): Draws shaded boxes around active Order Blocks resulting from liquidity sweeps.

Show FVG Highlights (Default: On): Plots distinct colored boxes directly over the Fair Value Gaps that triggered entry signals.

Max Boxes to Keep on Chart (Default: 2): Automatically deletes older historical boxes to prevent memory lag and visual clutter.

Execution and Risk Management Guidelines
1. Signal Confirmation
Wait for the current bar to close when a BUY or SELL signal appears. Do not execute mid-bar, as FVGs require candle completion to be valid.

2. Stop-Loss Placement
BUY Setup: Position the Stop-Loss a few ticks below the Liquidity Sweep Low or beneath the bottom boundary of the FVG box.

SELL Setup: Position the Stop-Loss a few ticks above the Liquidity Sweep High or above the top boundary of the FVG box.

3. Take-Profit Targets
Fixed Risk-to-Reward: Maintain a standard 1:2 Risk-to-Reward ratio (2R) for consistent expectancy.

Structural Targets: Target the opposing Swing High for long positions or Swing Low for short positions.

Best Practices and Context
While this indicator automates pattern recognition, trade performance improves significantly when aligning signals with higher-timeframe context:

Trade in the direction of the higher-timeframe trend.

Focus executions during major market sessions (London and New York sessions).

Recommended Timeframes: 1-minute to 15-minute charts for intraday execution; 1-hour to 4-hour charts for swing trading.

Recommended Assets: Forex major pairs, equity indices (NAS100, US30), commodities (Gold), and major cryptocurrencies.

---

## Source Code

````pine
//@version=6
indicator("ICT Sniper BY DAVID", overlay = true, max_labels_count = 50, max_boxes_count = 50)

// ==========================================
// INPUTS
// ==========================================
swingLength = input.int(5, "Pivot Lookback Length", minval = 1, group = "Market Structure")
fvgLookback = input.int(10, "Max Bars After Sweep to Find FVG", minval = 1, group = "Strategy Rules")

// Visual Controls (Off/On karke dekhein!)
showSweeps  = input.bool(false, "Show Minor Sweep Shapes", group = "Clean Visuals")
showOB      = input.bool(true, "Show Active Order Blocks", group = "Clean Visuals")
showFVG     = input.bool(true, "Show FVG Highlights", group = "Clean Visuals")
maxHistory  = input.int(2, "Max Boxes to Keep on Chart", minval = 1, maxval = 5, group = "Clean Visuals")

// ==========================================
// PIVOTS & LIQUIDITY SWEEPS
// ==========================================
ph = ta.pivothigh(high, swingLength, swingLength)
pl = ta.pivotlow(low, swingLength, swingLength)

var float lastHigh = na
var float lastLow  = na

if not na(ph)
    lastHigh := ph

if not na(pl)
    lastLow := pl

bullishSweep = not na(lastLow) and low < lastLow and close > lastLow
bearishSweep = not na(lastHigh) and high > lastHigh and close < lastHigh

var int lastBullSweepBar = na
var int lastBearSweepBar = na

if bullishSweep
    lastBullSweepBar := bar_index

if bearishSweep
    lastBearSweepBar := bar_index

// ==========================================
// FAIR VALUE GAPS (FVG)
// ==========================================
bullishFVG = low > high[2]
bearishFVG = high < low[2]

// Combined Entry Logic
bool bullSignal = bullishFVG and not na(lastBullSweepBar) and (bar_index - lastBullSweepBar <= fvgLookback)
bool bearSignal = bearishFVG and not na(lastBearSweepBar) and (bar_index - lastBearSweepBar <= fvgLookback)

var int lastBullSignalBar = na
var int lastBearSignalBar = na

if bullSignal and (na(lastBullSignalBar) or lastBullSignalBar != lastBullSweepBar)
    lastBullSignalBar := lastBullSweepBar
else
    bullSignal := false

if bearSignal and (na(lastBearSignalBar) or lastBearSignalBar != lastBearSweepBar)
    lastBearSignalBar := lastBearSweepBar
else
    bearSignal := false

// ==========================================
// CLEAN PLOTTING LOGIC
// ==========================================
// 1. Minor Sweep Shapes (Disabled by default for clean chart)
plotshape(showSweeps and bullishSweep, title="Bull Sweep", style=shape.triangleup, location=location.belowbar, color=color.new(color.green, 40), size=size.tiny)
plotshape(showSweeps and bearishSweep, title="Bear Sweep", style=shape.triangledown, location=location.abovebar, color=color.new(color.red, 40), size=size.tiny)

// 2. Neat BUY / SELL Signals (Small Arrows instead of Big Labels)
plotshape(bullSignal, title="BUY Entry", style=shape.arrowup, location=location.belowbar, color=color.green, size=size.normal, text="BUY", textcolor=color.green)
plotshape(bearSignal, title="SELL Entry", style=shape.arrowdown, location=location.abovebar, color=color.red, size=size.normal, text="SELL", textcolor=color.red)

// 3. Auto-Deleting Box Management (Limits historical boxes)
var box[] obBoxes = array.new_box()

// Manage OB Boxes
if showOB
    if bullishSweep
        b = box.new(left=bar_index, top=high, right=bar_index+8, bottom=low, bgcolor=color.new(color.green, 92), border_color=color.new(color.green, 70))
        array.push(obBoxes, b)

    if bearishSweep
        b = box.new(left=bar_index, top=high, right=bar_index+8, bottom=low, bgcolor=color.new(color.red, 92), border_color=color.new(color.red, 70))
        array.push(obBoxes, b)

    // Remove old boxes when exceeding limit
    if array.size(obBoxes) > maxHistory * 2
        box.delete(array.shift(obBoxes))

// Manage FVG Boxes
if showFVG
    if bullSignal
        b = box.new(left=bar_index-2, top=low, right=bar_index+4, bottom=high[2], bgcolor=color.new(color.teal, 88), border_color=color.teal)
        array.push(obBoxes, b)
    if bearSignal
        b = box.new(left=bar_index-2, top=low[2], right=bar_index+4, bottom=high, bgcolor=color.new(color.maroon, 88), border_color=color.maroon)
        array.push(obBoxes, b)
````
