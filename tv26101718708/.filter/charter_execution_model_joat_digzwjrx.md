# Charter Execution Model [JOAT]

- url: https://www.tradingview.com/script/diGzWjrX-Charter-Execution-Model-JOAT/
- type: strategy
- pine_id: PUB;d155438224ee4da3bd2c6ce443ba1586
- version: 1.0

## Description

[b]Charter Execution Model [JOAT][/b]

[b]Introduction[/b]

Charter Execution Model is an open-source Pine Script v6 strategy that integrates the broader JOAT framework into a single non-repainting execution model. It does not rely on one trigger alone. Instead, it uses a hierarchy of filters: regime eligibility first, liquidity bias second, structure confirmation third, and imbalance or displacement triggers fourth. Only when those layers align does the strategy consider taking a trade.

The goal of this strategy is not to present a magical black box. It is to model a disciplined decision stack. Many strategies fail because they treat every trigger the same way regardless of context. Charter Execution Model is built around the idea that context should do most of the work. If the market is not in a mature directional regime, if the liquidity ledger is not skewed appropriately, or if local structure does not agree, then a trigger by itself is not enough.

The script uses realistic execution controls directly in the declaration: fixed initial capital, percent-of-equity sizing, non-zero commission, non-zero slippage, no pyramiding, confirmed-bar evaluation, and orders processed on close. Those defaults are intended to make the backtest more responsible and easier to interpret than an overly aggressive model with idealized execution assumptions.

This strategy is best understood as a research framework. It can help traders study how context filters, imbalance triggers, continuation pressure, and ATR-based exits behave when combined inside one model. It is not a guarantee of future profitability, and it should be evaluated thoughtfully across symbols, regimes, and timeframes.

[image]https://www.tradingview.com/x/5D3swPh8/[/image]

[b]Core Concepts[/b]

[b]1. Regime Eligibility Layer[/b]

The first gate determines whether the market is mature enough to even consider longs or shorts. It uses a directional midpoint and structural midpoint built from EMA and HMA references, then normalizes their spread by ATR and combines that with heat positioning inside the recent price range.

[pine]
bool bullRegime = directionalMid > structuralMid
float regimeStrength = clamp(spreadNorm * 0.60 + math.abs(heatNorm - 50.0) * 0.80, 0, 100)
bool matureBullRegime = bullRegime and regimeStrength >= regimeFloor and regimePersistence >= 12
[/pine]

That means the strategy does not allow triggers to fire in weak or undeveloped directional states. Context comes first.

[b]2. Liquidity Bias Layer[/b]

Next, the strategy builds a rolling bin-based liquidity distribution and compares buy-side volume versus sell-side volume. A long context requires positive liquidity bias and price above the reference EMA. A short context requires negative liquidity bias and price below the reference EMA.

This adds an inventory-style filter so the strategy is not trading purely off price shape.

[b]3. Structure Filter[/b]

Local structure is confirmed using pivot-derived reference points and a rolling swing lookback. Longs require price to hold above recent swing support and above the slow EMA. Shorts require the inverse.

This helps reduce cases where a regime and liquidity reading are still positive or negative, but local price structure has already started to degrade.

[b]4. Trigger Stack[/b]

Once context aligns, the strategy allows three possible triggers: a confirmed imbalance gap, a displacement shift, or an optional continuation retest into the directional midpoint. This means the model can participate through both fresh displacement and controlled continuation.

Importantly, the trigger layer does not override the context layer. It only becomes active when the earlier filters already agree.

[b]5. ATR-Based Exit Framework[/b]

Risk management is handled through ATR-sensitive invalidation and two fixed-R profit targets. When the regime is especially strong, an optional trailing rule tightens the stop using recent local price action.

This creates a trade structure with a defined stop, two staged exits, and optional adaptation in stronger conditions without relying on unrealistic all-in-all-out assumptions.


[b]Features[/b]

[list]
[*][b]Four-layer decision hierarchy:[/b] Regime, liquidity, structure, and trigger conditions must align before entry
[*][b]Confirmed-bar logic:[/b] Entries are evaluated only on confirmed bars to avoid repaint-style execution logic
[*][b]Non-zero execution costs:[/b] Includes realistic commission and slippage in the strategy declaration
[*][b]No pyramiding:[/b] Prevents stacking multiple positions in the same direction
[*][b]Partial profit framework:[/b] Uses two independent `strategy.exit()` orders to scale out at separate R multiples
[*][b]Optional continuation triggers:[/b] Allows pullback-style participation inside already qualified context
[*][b]Optional strong-regime trailing stop:[/b] Tightens exits when regime strength is elevated
[*][b]Dashboard summary:[/b] Displays regime, liquidity bias, pressure, trigger state, position state, stop settings, and current risk fields
[*][b]Clean visual overlay:[/b] Shows directional and structural mids with contextual fill directly on the chart
[*][b]Open-source research design:[/b] Lets users inspect and adapt the full context-to-execution hierarchy
[/list]

[b]Default Strategy Properties[/b]

[list]
[*]Initial capital: `100000` is used as the default starting capital in the script declaration
[*]Position sizing: Orders use `strategy.percent_of_equity` with a default quantity of `10`, meaning the strategy allocates 10% of equity per position by default
[*]Commission: Commission is modeled as `0.02%` per trade
[*]Slippage: Slippage is modeled as `2` ticks
[*]Pyramiding: Pyramiding is set to `0`, so the model does not stack entries in the same direction
[*]Order timing: `process_orders_on_close = true` and `calc_on_every_tick = false`, so the model evaluates and processes with confirmed-bar logic
[/list]

[b]Input Parameters[/b]

[b]Regime:[/b]
[list]
[*]Fast Length: Controls the fast directional reference
[*]Slow Length: Controls the slow structural reference
[*]ATR Length: Sets the ATR normalization length
[*]Heat Window: Defines the range window for heat normalization
[*]Regime Strength Floor: Sets the minimum maturity threshold for context eligibility
[/list]

[b]Liquidity Filter:[/b]
[list]
[*]Liquidity Lookback: Sets the rolling history used for the liquidity model
[*]Liquidity Bins: Controls the liquidity distribution granularity
[*]Liquidity Bias Floor: Sets the minimum skew required before liquidity counts as directional
[/list]

[b]Structure Filter:[/b]
[list]
[*]Pivot Length: Sets pivot confirmation sensitivity
[*]Swing Lookback: Defines the rolling structural context window
[/list]

[b]Trigger Stack:[/b]
[list]
[*]Gap Sigma Filter: Sets the minimum imbalance displacement required for gap-style triggers
[*]Shift Momentum Length: Controls the raw momentum lookback
[*]Shift RSI Length: Controls the pressure RSI smoothing
[*]Displacement Floor: Sets the threshold for shift-style triggers
[*]Allow Continuation Triggers: Enables or disables pullback continuation entries
[*]Continuation Pressure Floor: Sets the minimum pressure level for continuation logic
[/list]

[b]Risk Management:[/b]
[list]
[*]Stop ATR Multiplier: Scales the ATR contribution to stop placement
[*]Target 1 R: Sets the first partial profit target
[*]Target 2 R: Sets the second partial profit target
[*]Trail In Strong Regime: Enables optional trailing behavior when regime strength is elevated
[/list]

[b]How to Use This Strategy[/b]

[b]Step 1: Evaluate Context Before Results[/b]
Begin by understanding what the strategy is trying to do rather than focusing immediately on performance output. It only wants to trade when a mature regime, directional liquidity bias, and confirming structure are all aligned. If that idea does not match your own process, the results will be hard to interpret.

[b]Step 2: Study Trigger Type Distribution[/b]
Not all entries come from the same source. Some come from imbalance gaps, some from displacement shifts, and some from continuation pressure. Understanding which trigger type dominates on a given market can be more useful than simply checking net profit.

[b]Step 3: Understand The Exit Framework[/b]
The model uses a staged exit approach. Half the position is managed toward the first target and half toward the second. A stop is always active, and strong-regime trailing can tighten the exit path further. Review this logic carefully before drawing conclusions from the backtest.

[b]Step 4: Keep Expectations Realistic[/b]
The strategy includes commission, slippage, confirmed-bar logic, and no pyramiding, but that still does not make the backtest “real.” Results depend on the instrument, the timeframe, the data sample, and how well the context assumptions fit the market studied.

[b]Step 5: Use It As A Research Framework[/b]
Charter Execution Model is best used as a framework for studying context-first execution logic. Adapt the filters, test the thresholds, and evaluate how the hierarchy behaves across different environments rather than assuming the defaults are universally optimal.

[b]Strategy Limitations[/b]

[list]
[*]The strategy relies on historical context filters that may adapt poorly to sudden regime shifts or atypical event-driven conditions
[*]Liquidity bias is based on bar-level directional volume attribution rather than true exchange order-flow data
[*]Processing orders on close simplifies execution and can differ materially from real fills on fast markets
[*]Backtest results are sensitive to parameter choices, timeframe selection, instrument behavior, and dataset length
[/list]

[b]Originality Statement[/b]

Charter Execution Model is original in the way it organizes multiple analytical layers into a disciplined execution hierarchy. It is not published as a simple indicator mashup strategy:

[list]
[*]It requires mature regime, directional liquidity bias, and local structure to align before any trigger is allowed to matter
[*]It supports multiple trigger archetypes inside the same context framework rather than treating one trigger as universally sufficient
[*]It combines staged exits, ATR-sensitive invalidation, and optional strong-regime trailing inside a consistent risk model
[*]It exposes its internal context state on-chart so users can study why the strategy is active or inactive at any point
[/list]

[b]Disclaimer[/b]

This strategy is provided for educational and informational purposes only. It is not financial advice or a recommendation to buy or sell any financial instrument. Backtest results depend on assumptions, data quality, slippage, commission, bar resolution, and market conditions. Past performance does not guarantee future results. Always use independent judgment and proper risk management before using any strategy logic in live markets.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
strategy("Charter Execution Model [JOAT]", shorttitle = "NAV [JOAT]", overlay = true, max_labels_count = 200, max_lines_count = 200, max_boxes_count = 100, initial_capital = 100000, pyramiding = 0, commission_type = strategy.commission.percent, commission_value = 0.02, slippage = 2, calc_on_every_tick = false, process_orders_on_close = true, default_qty_type = strategy.percent_of_equity, default_qty_value = 10)
//--------------------------------------------------------------------------------------------------
// Inputs
//--------------------------------------------------------------------------------------------------
string groupRegime = "Regime"
int fastLength = input.int(34, "Fast Length", minval = 10, maxval = 120, group = groupRegime)
int slowLength = input.int(89, "Slow Length", minval = 20, maxval = 250, group = groupRegime)
int atrLength = input.int(100, "ATR Length", minval = 20, maxval = 250, group = groupRegime)
int heatLength = input.int(70, "Heat Window", minval = 20, maxval = 200, group = groupRegime)
float regimeFloor = input.float(34.0, "Regime Strength Floor", minval = 10.0, maxval = 100.0, step = 0.5, group = groupRegime)
int regimePersistenceFloor = input.int(8, "Regime Persistence Floor", minval = 3, maxval = 30, group = groupRegime)

string groupLiquidity = "Liquidity Filter"
int liquidityLookback = input.int(180, "Liquidity Lookback", minval = 80, maxval = 400, group = groupLiquidity)
int liquidityBins = input.int(24, "Liquidity Bins", minval = 10, maxval = 50, group = groupLiquidity)
float liquidityBiasFloor = input.float(0.04, "Liquidity Bias Floor", minval = 0.01, maxval = 0.40, step = 0.01, group = groupLiquidity)

string groupStructure = "Structure Filter"
int pivotLength = input.int(4, "Pivot Length", minval = 2, maxval = 20, group = groupStructure)
int swingLookback = input.int(24, "Swing Lookback", minval = 10, maxval = 100, group = groupStructure)

string groupTrigger = "Trigger Stack"
float gapSigma = input.float(0.25, "Gap Sigma Filter", minval = 0.10, maxval = 2.00, step = 0.05, group = groupTrigger)
int shiftMomentum = input.int(9, "Shift Momentum Length", minval = 3, maxval = 30, group = groupTrigger)
int shiftRsi = input.int(14, "Shift RSI Length", minval = 5, maxval = 50, group = groupTrigger)
float displacementFloor = input.float(46.0, "Displacement Floor", minval = 20.0, maxval = 100.0, step = 0.5, group = groupTrigger)
bool allowContinuationTriggers = input.bool(true, "Allow Continuation Triggers", group = groupTrigger)
float continuationFloor = input.float(50.0, "Continuation Pressure Floor", minval = 20.0, maxval = 100.0, step = 0.5, group = groupTrigger)

string groupRisk = "Risk Management"
float stopAtr = input.float(1.2, "Stop ATR Multiplier", minval = 0.5, maxval = 5.0, step = 0.1, group = groupRisk)
float targetOneR = input.float(1.5, "Target 1 R", minval = 0.5, maxval = 5.0, step = 0.1, group = groupRisk)
float targetTwoR = input.float(2.5, "Target 2 R", minval = 1.0, maxval = 8.0, step = 0.1, group = groupRisk)
bool useTrailingInStrongRegime = input.bool(true, "Trail In Strong Regime", group = groupRisk)

string groupStyle = "Style"
color bullCore = input.color(color.rgb(24, 202, 154), "Bull Core", group = groupStyle, inline = "a")
color bearCore = input.color(color.rgb(200, 66, 185), "Bear Core", group = groupStyle, inline = "a")
color neutralCore = input.color(color.rgb(137, 146, 160), "Neutral", group = groupStyle)
color panelBg = input.color(color.rgb(14, 20, 30), "Panel Background", group = groupStyle)
bool showDashboard = input.bool(true, "Show Dashboard", group = groupStyle)

//--------------------------------------------------------------------------------------------------
// Persistent risk state
//--------------------------------------------------------------------------------------------------
var float storedLongStop = na
var float storedShortStop = na
var float storedLongTargetOne = na
var float storedLongTargetTwo = na
var float storedShortTargetOne = na
var float storedShortTargetTwo = na

//--------------------------------------------------------------------------------------------------
// Helpers
//--------------------------------------------------------------------------------------------------
safeDiv(float numerator, float denominator) =>
    denominator == 0.0 ? 0.0 : numerator / denominator

clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

dashboardCell(table tbl, int column, int row, string cellText, color bg, color fg) =>
    table.cell(tbl, column, row, cellText, bgcolor = bg, text_color = fg, text_size = size.small)

//--------------------------------------------------------------------------------------------------
// Regime model
//--------------------------------------------------------------------------------------------------
float atrValue = ta.atr(atrLength)
float emaFast = ta.ema(close, fastLength)
float emaSlow = ta.ema(close, slowLength)
float hmaFast = ta.hma(close, math.max(10, fastLength - 8))
float hmaSlow = ta.hma(close, math.max(20, slowLength - 13))

float directionalMid = math.avg(emaFast, hmaFast)
float structuralMid = math.avg(emaSlow, hmaSlow)
float spread = directionalMid - structuralMid
float spreadNorm = safeDiv(math.abs(spread), atrValue) * 100.0

float rangeHigh = ta.highest(high, heatLength)
float rangeLow = ta.lowest(low, heatLength)
float heatNorm = safeDiv(close - rangeLow, math.max(rangeHigh - rangeLow, syminfo.mintick)) * 100.0

bool bullRegime = directionalMid > structuralMid
var int regimePersistence = 0
regimePersistence := bullRegime == bullRegime[1] ? nz(regimePersistence[1]) + 1 : 0
float regimeStrength = clamp(spreadNorm * 0.60 + math.abs(heatNorm - 50.0) * 0.80, 0, 100)
bool matureBullRegime = bullRegime and regimeStrength >= regimeFloor and regimePersistence >= regimePersistenceFloor
bool matureBearRegime = not bullRegime and regimeStrength >= regimeFloor and regimePersistence >= regimePersistenceFloor

//--------------------------------------------------------------------------------------------------
// Liquidity bias model
//--------------------------------------------------------------------------------------------------
float referencePrice = ta.ema(close, 55)
float liqHigh = ta.highest(high, liquidityLookback)
float liqLow = ta.lowest(low, liquidityLookback)
float liqRange = liqHigh - liqLow
float liqBinSize = liqRange / liquidityBins
int effectiveLiquidityLookback = math.min(liquidityLookback, bar_index + 1)

array<float> buyBins = array.new_float(liquidityBins, 0.0)
array<float> sellBins = array.new_float(liquidityBins, 0.0)

for i = 0 to liquidityBins - 1
    buyBins.set(i, 0.0)
    sellBins.set(i, 0.0)

if liqRange > 0 and effectiveLiquidityLookback > 0
    for offset = 0 to effectiveLiquidityLookback - 1
        int rawIndex = int(math.floor((hlc3[offset] - liqLow) / liqBinSize))
        int binIndex = math.max(0, math.min(liquidityBins - 1, rawIndex))
        if close[offset] >= open[offset]
            buyBins.set(binIndex, buyBins.get(binIndex) + volume[offset])
        else
            sellBins.set(binIndex, sellBins.get(binIndex) + volume[offset])

float totalBuyLiquidity = buyBins.sum()
float totalSellLiquidity = sellBins.sum()
float liquidityBias = safeDiv(totalBuyLiquidity - totalSellLiquidity, math.max(totalBuyLiquidity + totalSellLiquidity, 1.0))
bool bullishLiquidity = liquidityBias > liquidityBiasFloor and close >= referencePrice
bool bearishLiquidity = liquidityBias < -liquidityBiasFloor and close <= referencePrice

//--------------------------------------------------------------------------------------------------
// Structure model
//--------------------------------------------------------------------------------------------------
float pivotHigh = ta.pivothigh(high, pivotLength, pivotLength)
float pivotLow = ta.pivotlow(low, pivotLength, pivotLength)

float recentPivotHigh = ta.valuewhen(not na(pivotHigh), high[pivotLength], 0)
float recentPivotLow = ta.valuewhen(not na(pivotLow), low[pivotLength], 0)
float swingLow = ta.lowest(low, swingLookback)
float swingHigh = ta.highest(high, swingLookback)

bool bullishStructure = close > nz(recentPivotLow, swingLow) and close > emaSlow
bool bearishStructure = close < nz(recentPivotHigh, swingHigh) and close < emaSlow

//--------------------------------------------------------------------------------------------------
// Imbalance + shift trigger model
//--------------------------------------------------------------------------------------------------
bool enoughGapHistory = bar_index >= 2
float bullGapSigma = (low - high[2]) / math.max(ta.stdev(low - high[2], 200), syminfo.mintick)
float bearGapSigma = (low[2] - high) / math.max(ta.stdev(low[2] - high, 200), syminfo.mintick)
bool bullGap = enoughGapHistory and barstate.isconfirmed and low > high[2] and high[1] > high[2] and bullGapSigma > gapSigma
bool bearGap = enoughGapHistory and barstate.isconfirmed and high < low[2] and low[1] < low[2] and bearGapSigma > gapSigma

float momentum = ta.mom(close, shiftMomentum)
float pressureRsi = ta.rsi(momentum, shiftRsi)
float displacement = clamp(safeDiv(math.abs(emaFast - emaSlow), atrValue) * 40.0 + math.abs(pressureRsi - 50.0) * 1.0, 0, 100)
bool bullShift = barstate.isconfirmed and displacement >= displacementFloor and pressureRsi > 54 and close > emaFast and spread > 0
bool bearShift = barstate.isconfirmed and displacement >= displacementFloor and pressureRsi < 46 and close < emaFast and spread < 0

//--------------------------------------------------------------------------------------------------
// Entry conditions
//--------------------------------------------------------------------------------------------------
bool longContext = matureBullRegime and bullishLiquidity and bullishStructure
bool shortContext = matureBearRegime and bearishLiquidity and bearishStructure

bool bullContinuation = barstate.isconfirmed and allowContinuationTriggers and pressureRsi >= continuationFloor and close > directionalMid and low <= emaFast
bool bearContinuation = barstate.isconfirmed and allowContinuationTriggers and pressureRsi <= 100.0 - continuationFloor and close < directionalMid and high >= emaFast

bool longTrigger = bullGap or bullShift or bullContinuation
bool shortTrigger = bearGap or bearShift or bearContinuation

bool longSignal = barstate.isconfirmed and longContext and longTrigger and strategy.position_size <= 0
bool shortSignal = barstate.isconfirmed and shortContext and shortTrigger and strategy.position_size >= 0

//--------------------------------------------------------------------------------------------------
// Risk model
//--------------------------------------------------------------------------------------------------
float longInvalidation = math.min(nz(recentPivotLow, swingLow), low)
float shortInvalidation = math.max(nz(recentPivotHigh, swingHigh), high)

float longStop = math.min(close - atrValue * stopAtr, longInvalidation - atrValue * 0.15)
float shortStop = math.max(close + atrValue * stopAtr, shortInvalidation + atrValue * 0.15)

float longRisk = math.max(close - longStop, syminfo.mintick * 10)
float shortRisk = math.max(shortStop - close, syminfo.mintick * 10)

float candidateLongTargetOne = close + longRisk * targetOneR
float candidateLongTargetTwo = close + longRisk * targetTwoR
float candidateShortTargetOne = close - shortRisk * targetOneR
float candidateShortTargetTwo = close - shortRisk * targetTwoR

//--------------------------------------------------------------------------------------------------
// Orders
//--------------------------------------------------------------------------------------------------
if longSignal
    storedLongStop := longStop
    storedLongTargetOne := candidateLongTargetOne
    storedLongTargetTwo := candidateLongTargetTwo
    storedShortStop := na
    storedShortTargetOne := na
    storedShortTargetTwo := na
    strategy.entry("Long", strategy.long, comment = "Long", alert_message = "NAV [JOAT] long entry confirmed")

if shortSignal
    storedShortStop := shortStop
    storedShortTargetOne := candidateShortTargetOne
    storedShortTargetTwo := candidateShortTargetTwo
    storedLongStop := na
    storedLongTargetOne := na
    storedLongTargetTwo := na
    strategy.entry("Short", strategy.short, comment = "Short", alert_message = "NAV [JOAT] short entry confirmed")

if strategy.position_size > 0
    float activeLongStop = nz(storedLongStop, longStop)
    if useTrailingInStrongRegime and regimeStrength >= 60
        activeLongStop := math.max(activeLongStop, ta.lowest(low, 5) - atrValue * 0.20)
    storedLongStop := activeLongStop
    strategy.exit("Long Exit 1", from_entry = "Long", stop = activeLongStop, limit = storedLongTargetOne, qty_percent = 50, alert_message = "NAV [JOAT] long target one or stop")
    strategy.exit("Long Exit 2", from_entry = "Long", stop = activeLongStop, limit = storedLongTargetTwo, qty_percent = 50, alert_message = "NAV [JOAT] long target two or stop")

if strategy.position_size < 0
    float activeShortStop = nz(storedShortStop, shortStop)
    if useTrailingInStrongRegime and regimeStrength >= 60
        activeShortStop := math.min(activeShortStop, ta.highest(high, 5) + atrValue * 0.20)
    storedShortStop := activeShortStop
    strategy.exit("Short Exit 1", from_entry = "Short", stop = activeShortStop, limit = storedShortTargetOne, qty_percent = 50, alert_message = "NAV [JOAT] short target one or stop")
    strategy.exit("Short Exit 2", from_entry = "Short", stop = activeShortStop, limit = storedShortTargetTwo, qty_percent = 50, alert_message = "NAV [JOAT] short target two or stop")

if strategy.position_size == 0
    storedLongStop := na
    storedShortStop := na
    storedLongTargetOne := na
    storedLongTargetTwo := na
    storedShortTargetOne := na
    storedShortTargetTwo := na

//--------------------------------------------------------------------------------------------------
// Strategy visuals
//--------------------------------------------------------------------------------------------------
color stateColor =
     longContext
     ? color.from_gradient(regimeStrength, regimeFloor, 100, color.new(bullCore, 70), color.new(bullCore, 0))
     : shortContext
       ? color.from_gradient(regimeStrength, regimeFloor, 100, color.new(bearCore, 70), color.new(bearCore, 0))
       : color.new(neutralCore, 70)

midFastPlot = plot(directionalMid, "Directional Mid", color = stateColor, linewidth = 2)
midSlowPlot = plot(structuralMid, "Structural Mid", color = color.new(neutralCore, 25), linewidth = 1)
fill(midFastPlot, midSlowPlot, color = color.new(stateColor, 88))

barcolor(stateColor)
plotcandle(open, high, low, close, color = stateColor, wickcolor = stateColor, bordercolor = stateColor, force_overlay = true, title = "Strategy Candles")

//--------------------------------------------------------------------------------------------------
// Dashboard
//--------------------------------------------------------------------------------------------------
var table dashboard = table.new(position.top_right, 2, 12, frame_color = color.new(color.white, 85), frame_width = 1)

if showDashboard and barstate.islast
    color topBg = color.new(longContext ? bullCore : shortContext ? bearCore : neutralCore, 84)
    string status = longContext ? "Long Eligible" : shortContext ? "Short Eligible" : "Flat Context"

    dashboardCell(dashboard, 0, 0, "Charter Model", topBg, color.white)
    dashboardCell(dashboard, 1, 0, status, topBg, color.white)

    dashboardCell(dashboard, 0, 1, "Regime", panelBg, color.new(color.white, 10))
    dashboardCell(dashboard, 1, 1, str.tostring(regimeStrength, "#.0") + "%", panelBg, longContext ? bullCore : shortContext ? bearCore : color.white)

    dashboardCell(dashboard, 0, 2, "Liquidity", panelBg, color.new(color.white, 10))
    dashboardCell(dashboard, 1, 2, str.tostring(liquidityBias * 100, "#.0") + "%", panelBg, liquidityBias >= 0 ? bullCore : bearCore)

    dashboardCell(dashboard, 0, 3, "Pressure RSI", panelBg, color.new(color.white, 10))
    dashboardCell(dashboard, 1, 3, str.tostring(pressureRsi, "#.0"), panelBg, bullShift ? bullCore : bearShift ? bearCore : color.white)

    dashboardCell(dashboard, 0, 4, "Trigger", panelBg, color.new(color.white, 10))
    dashboardCell(dashboard, 1, 4, longTrigger ? "Bull" : shortTrigger ? "Bear" : "Idle", panelBg, longTrigger ? bullCore : shortTrigger ? bearCore : color.white)

    dashboardCell(dashboard, 0, 5, "Position", panelBg, color.new(color.white, 10))
    dashboardCell(dashboard, 1, 5, strategy.position_size > 0 ? "Long" : strategy.position_size < 0 ? "Short" : "Flat", panelBg, strategy.position_size > 0 ? bullCore : strategy.position_size < 0 ? bearCore : color.white)

    dashboardCell(dashboard, 0, 6, "Stop ATR", panelBg, color.new(color.white, 10))
    dashboardCell(dashboard, 1, 6, str.tostring(stopAtr, "#.0"), panelBg, color.white)

    dashboardCell(dashboard, 0, 7, "Target 1", panelBg, color.new(color.white, 10))
    dashboardCell(dashboard, 1, 7, str.tostring(targetOneR, "#.0") + "R", panelBg, color.white)

    dashboardCell(dashboard, 0, 8, "Target 2", panelBg, color.new(color.white, 10))
    dashboardCell(dashboard, 1, 8, str.tostring(targetTwoR, "#.0") + "R", panelBg, color.white)

    dashboardCell(dashboard, 0, 9, "Cont Trig", panelBg, color.new(color.white, 10))
    dashboardCell(dashboard, 1, 9, bullContinuation ? "Bull" : bearContinuation ? "Bear" : "Idle", panelBg, bullContinuation ? bullCore : bearContinuation ? bearCore : color.white)

    dashboardCell(dashboard, 0, 10, "Stop Px", panelBg, color.new(color.white, 10))
    dashboardCell(dashboard, 1, 10, strategy.position_size > 0 ? str.tostring(storedLongStop, format.mintick) : strategy.position_size < 0 ? str.tostring(storedShortStop, format.mintick) : "na", panelBg, strategy.position_size > 0 ? bullCore : strategy.position_size < 0 ? bearCore : color.white)

    dashboardCell(dashboard, 0, 11, "Risk Px", panelBg, color.new(color.white, 10))
    dashboardCell(dashboard, 1, 11, longSignal ? str.tostring(longRisk, format.mintick) : shortSignal ? str.tostring(shortRisk, format.mintick) : "na", panelBg, color.white)

plot(regimeStrength, "Regime Strength (Data Window)", color = stateColor, display = display.data_window)
plot(liquidityBias * 100.0, "Liquidity Bias % (Data Window)", color = liquidityBias >= 0 ? bullCore : bearCore, display = display.data_window)
plot(displacement, "Displacement (Data Window)", color = displacement >= displacementFloor ? stateColor : neutralCore, display = display.data_window)
plot(pressureRsi, "Pressure RSI (Data Window)", color = pressureRsi >= 50 ? bullCore : bearCore, display = display.data_window)
plot(strategy.position_size, "Position Size (Data Window)", color = strategy.position_size >= 0 ? bullCore : bearCore, display = display.data_window)
````
