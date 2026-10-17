# MACD + 200 EMA + Support/Resistance Strategy 

- url: https://www.tradingview.com/script/FzfWWd0i-MACD-200-EMA-Support-Resistance-Strategy/
- type: strategy
- pine_id: PUB;eaeb3dc44d04457bac655aded7f9d5c2
- version: 1.0

## Description

This open-source strategy is an educational Pine Script implementation of a MACD + 200 EMA + support/resistance trading concept.

It was created to convert a visually explained strategy idea into clear, testable rules, so traders can study how the logic behaves under backtesting conditions.

The strategy combines three main components:

1. MACD momentum logic
2. A 200 EMA trend filter
3. A pivot-based support and resistance filter

For long setups, the strategy looks for a bullish MACD crossover below the zero line, while price is above the 200 EMA.

For short setups, the strategy looks for a bearish MACD crossover above the zero line, while price is below the 200 EMA.

A support and resistance filter can also be enabled. This filter uses confirmed pivot levels, wick-based touches, ATR-based tolerance, and a maximum level age to create a more objective interpretation of support and resistance behavior.

Main features:

- MACD default settings
- 200 EMA trend filter
- Optional pivot-based support and resistance filter
- Confirmed pivots only
- Wick-based touch detection
- ATR-based tolerance
- Long and short logic
- Multiple stop-loss modes
- Risk/reward based take-profit logic
- Optional pyramiding controls
- Strategy backtesting support

Stop-loss logic:

The script includes more than one stop-loss interpretation because the original concept does not define the stop placement with full precision.

Stop option 1:
A stop placed above or below the 200 EMA by a user-defined number of ticks.

Stop option 2:
A stop placed at the nearest valid swing within a user-defined lookback window. If no valid swing is found, the script falls back to the EMA-based stop.

Take-profit logic:

The take-profit target is calculated using a fixed risk/reward multiple based on the distance between entry and stop-loss.

Default risk/reward:
1.5R

Execution assumptions:

- Entries are placed on the next candle open after the signal bar.
- Exits are handled through stop-loss and take-profit only.
- MACD is calculated on close.
- EMA is calculated on close.
- Support and resistance levels are based on confirmed pivots only.
- The strategy is designed for educational backtesting and research, not for automatic live trading.

Important backtesting notes:

Backtest results can vary significantly depending on the symbol, timeframe, commission, slippage, spread, data provider, and strategy settings.

Users should always adjust commission and slippage settings to match the market being tested. A zero-cost setup may produce unrealistic results.

This script does not guarantee profitability, future performance, or a specific win rate.

This is not the original creator’s code. It is a testable logical interpretation of the strategy idea, built by converting unclear visual rules into explicit Pine Script conditions.

If you believe a different interpretation of the unclear parts would be more accurate, you can modify the open-source code and test your own version.

Disclaimer:

This script is provided for educational and research purposes only. It is not financial advice, investment advice, or a recommendation to buy, sell, short, or trade any asset.

Trading involves risk. Past performance and backtested results do not guarantee future results. Always do your own research and test thoroughly before using any strategy in live market conditions.

No strategy, indicator, or backtest can guarantee profits or eliminate trading risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Phantom_Trader_Global

//@version=5
strategy(
     "Phantom MACD + EMA + Pivot S/R Backtest",
     overlay = true,
     max_bars_back = 5000,
     pyramiding = 50,
     process_orders_on_close = false,
     commission_type = strategy.commission.percent,
     commission_value = 0.06,
     slippage = 2)

// =========================
// Inputs
// =========================
groupCore   = "1) Core Logic"
groupRisk   = "2) Risk / Trade Management"
groupSR     = "3) Support / Resistance Filter"
groupExec   = "4) Position / Execution"
groupDebug  = "5) Visuals / Debug"

emaLength      = input.int(200, "EMA Length", minval = 1, group = groupCore)
macdFast       = input.int(12, "MACD Fast Length", minval = 1, group = groupCore)
macdSlow       = input.int(26, "MACD Slow Length", minval = 1, group = groupCore)
macdSignalLen  = input.int(9, "MACD Signal Length", minval = 1, group = groupCore)

rrTarget       = input.float(1.5, "Risk/Reward Target", minval = 0.1, step = 0.1, group = groupRisk)
stopMode       = input.string("Nearest Swing", "Stop Mode", options = ["EMA Buffer", "Nearest Swing"], group = groupRisk)
emaBufferTicks = input.int(5, "EMA Stop Buffer (Ticks)", minval = 1, group = groupRisk)
swingLookback  = input.int(10, "Swing Stop Lookback (Bars)", minval = 1, group = groupRisk)
swingBufTicks  = input.int(1, "Swing Stop Buffer (Ticks)", minval = 0, group = groupRisk)

useSRFilter       = input.bool(true, "Enable Pivot S/R Filter", group = groupSR)
pivotLeft         = input.int(3, "Pivot Left Bars", minval = 1, group = groupSR)
pivotRight        = input.int(3, "Pivot Right Bars", minval = 1, group = groupSR)
minTouches        = input.int(2, "Minimum Distinct Touches", minval = 1, group = groupSR)
maxLevelAge       = input.int(100, "Max Bars Since Level Creation", minval = 1, group = groupSR)
maxBreakCloses    = input.int(2, "Max Closes Beyond Level", minval = 0, group = groupSR)
atrLength         = input.int(14, "ATR Length", minval = 1, group = groupSR)
atrFraction       = input.float(0.25, "ATR Fraction Tolerance", minval = 0.0, step = 0.01, group = groupSR)

positionMode      = input.string("Single Position", "Position Mode", options = ["Single Position", "Pyramiding"], group = groupExec)
maxOpenTrades     = input.int(3, "Max Open Trades (Used In Pyramiding Mode)", minval = 1, group = groupExec)

showSignals       = input.bool(true, "Show Entry Signals", group = groupDebug)
showLevels        = input.bool(true, "Show Latest Valid Levels", group = groupDebug)
showDebugStops    = input.bool(false, "Show Planned Stop Markers", group = groupDebug)

// =========================
// Core Calculations
// =========================
ema200 = ta.ema(close, emaLength)
[macdLine, macdSignal, macdHist] = ta.macd(close, macdFast, macdSlow, macdSignalLen)
atr = ta.atr(atrLength)
tick = syminfo.mintick

coreLong  = ta.crossover(macdLine, macdSignal) and macdLine < 0 and close > ema200
coreShort = ta.crossunder(macdLine, macdSignal) and macdLine > 0 and close < ema200

// =========================
// Pivot Storage
// =========================
var pivotLowBars    = array.new_int()
var pivotLowPrices  = array.new_float()
var pivotHighBars   = array.new_int()
var pivotHighPrices = array.new_float()

pl = ta.pivotlow(low, pivotLeft, pivotRight)
ph = ta.pivothigh(high, pivotLeft, pivotRight)

if not na(pl)
    array.push(pivotLowBars, bar_index - pivotRight)
    array.push(pivotLowPrices, pl)

if not na(ph)
    array.push(pivotHighBars, bar_index - pivotRight)
    array.push(pivotHighPrices, ph)


pruneHorizon = math.max(maxLevelAge * 3, swingLookback * 3)

while array.size(pivotLowBars) > 0
    if bar_index - array.get(pivotLowBars, 0) > pruneHorizon
        array.shift(pivotLowBars)
        array.shift(pivotLowPrices)
    else
        break

while array.size(pivotHighBars) > 0
    if bar_index - array.get(pivotHighBars, 0) > pruneHorizon
        array.shift(pivotHighBars)
        array.shift(pivotHighPrices)
    else
        break


if not na(ph)
    array.push(pivotHighBars, bar_index - pivotRight)
    array.push(pivotHighPrices, ph)
    
// =========================
// Helper Functions
// =========================
f_count_touches(_level, _barsSince, _isSupport, _atrFrac) =>
    int touches = 0
    bool prevTouch = false
    if _barsSince >= 0
        for i = _barsSince to 0
            float tol = atr[i] * _atrFrac
            bool touch = _isSupport ? (low[i] <= _level + tol and high[i] >= _level - tol) : (high[i] >= _level - tol and low[i] <= _level + tol)
            if touch and not prevTouch
                touches += 1
            prevTouch := touch
    touches

f_reclaim_long(_level, _barsSince, _atrFrac, _maxCloseBars) =>
    bool breakActive = false
    float breakMaxOpen = na
    int closeBelowCount = 0
    bool reclaimNow = false

    if _barsSince >= 1
        for i = _barsSince - 1 to 0
            float tol = atr[i] * _atrFrac
            bool wickBreak = low[i] < _level - tol
            bool closeBelow = close[i] < _level - tol

            if not breakActive
                if wickBreak
                    breakActive := true
                    breakMaxOpen := open[i]
                    closeBelowCount := closeBelow ? 1 : 0
            else
                breakMaxOpen := math.max(breakMaxOpen, open[i])
                if closeBelow
                    closeBelowCount += 1

                if closeBelowCount > _maxCloseBars
                    breakActive := false
                    breakMaxOpen := na
                    closeBelowCount := 0
                    if wickBreak
                        breakActive := true
                        breakMaxOpen := open[i]
                        closeBelowCount := closeBelow ? 1 : 0
                else if close[i] > breakMaxOpen and close[i] > _level
                    reclaimNow := i == 0
                    breakActive := false
                    breakMaxOpen := na
                    closeBelowCount := 0
    reclaimNow

f_reclaim_short(_level, _barsSince, _atrFrac, _maxCloseBars) =>
    bool breakActive = false
    float breakMinOpen = na
    int closeAboveCount = 0
    bool reclaimNow = false

    if _barsSince >= 1
        for i = _barsSince - 1 to 0
            float tol = atr[i] * _atrFrac
            bool wickBreak = high[i] > _level + tol
            bool closeAbove = close[i] > _level + tol

            if not breakActive
                if wickBreak
                    breakActive := true
                    breakMinOpen := open[i]
                    closeAboveCount := closeAbove ? 1 : 0
            else
                breakMinOpen := math.min(breakMinOpen, open[i])
                if closeAbove
                    closeAboveCount += 1

                if closeAboveCount > _maxCloseBars
                    breakActive := false
                    breakMinOpen := na
                    closeAboveCount := 0
                    if wickBreak
                        breakActive := true
                        breakMinOpen := open[i]
                        closeAboveCount := closeAbove ? 1 : 0
                else if close[i] < breakMinOpen and close[i] < _level
                    reclaimNow := i == 0
                    breakActive := false
                    breakMinOpen := na
                    closeAboveCount := 0
    reclaimNow

f_find_open_trade_index(_entryId) =>
    int found = -1
    if strategy.opentrades > 0
        for t = 0 to strategy.opentrades - 1
            if strategy.opentrades.entry_id(t) == _entryId
                found := t
                break
    found

// =========================
// Latest Valid Support / Resistance
// =========================
float latestSupport = na
int latestSupportBar = na

if useSRFilter and array.size(pivotLowBars) > 0
    for idx = array.size(pivotLowBars) - 1 to 0
        int pb = array.get(pivotLowBars, idx)
        int barsSince = bar_index - pb
        if barsSince <= maxLevelAge
            float lvl = array.get(pivotLowPrices, idx)
            int tCount = f_count_touches(lvl, barsSince, true, atrFraction)
            if tCount >= minTouches
                latestSupport := lvl
                latestSupportBar := pb
                break

float latestResistance = na
int latestResistanceBar = na

if useSRFilter and array.size(pivotHighBars) > 0
    for idx = array.size(pivotHighBars) - 1 to 0
        int pb = array.get(pivotHighBars, idx)
        int barsSince = bar_index - pb
        if barsSince <= maxLevelAge
            float lvl = array.get(pivotHighPrices, idx)
            int tCount = f_count_touches(lvl, barsSince, false, atrFraction)
            if tCount >= minTouches
                latestResistance := lvl
                latestResistanceBar := pb
                break

longSRReady  = not useSRFilter or (not na(latestSupport) and f_reclaim_long(latestSupport, bar_index - latestSupportBar, atrFraction, maxBreakCloses))
shortSRReady = not useSRFilter or (not na(latestResistance) and f_reclaim_short(latestResistance, bar_index - latestResistanceBar, atrFraction, maxBreakCloses))

longSignal  = coreLong and longSRReady
shortSignal = coreShort and shortSRReady

// =========================
// Stop Calculations
// =========================
emaStopLong  = ema200 - (emaBufferTicks * tick)
emaStopShort = ema200 + (emaBufferTicks * tick)

float swingStopLong = na
if array.size(pivotLowBars) > 0
    for idx = array.size(pivotLowBars) - 1 to 0
        int pb = array.get(pivotLowBars, idx)
        int barsSince = bar_index - pb
        if barsSince <= swingLookback
            float lvl = array.get(pivotLowPrices, idx)
            if lvl < ema200
                swingStopLong := lvl - (swingBufTicks * tick)
                break
        else
            break

float swingStopShort = na
if array.size(pivotHighBars) > 0
    for idx = array.size(pivotHighBars) - 1 to 0
        int pb = array.get(pivotHighBars, idx)
        int barsSince = bar_index - pb
        if barsSince <= swingLookback
            float lvl = array.get(pivotHighPrices, idx)
            if lvl > ema200
                swingStopShort := lvl + (swingBufTicks * tick)
                break
        else
            break

plannedLongStop  = stopMode == "EMA Buffer" ? emaStopLong  : nz(swingStopLong, emaStopLong)
plannedShortStop = stopMode == "EMA Buffer" ? emaStopShort : nz(swingStopShort, emaStopShort)

// Guard against obviously invalid signal-bar stops
validLongStopNow  = plannedLongStop < close
validShortStopNow = plannedShortStop > close

// =========================
// Position Filters
// =========================
allowLong =
     positionMode == "Single Position" ?
         strategy.opentrades == 0 and strategy.position_size == 0 :
         strategy.position_size >= 0 and strategy.opentrades < maxOpenTrades

allowShort =
     positionMode == "Single Position" ?
         strategy.opentrades == 0 and strategy.position_size == 0 :
         strategy.position_size <= 0 and strategy.opentrades < maxOpenTrades

// =========================
// Order Storage
// =========================
var entryIds       = array.new_string()
var entryDirs      = array.new_int()
var entryStops     = array.new_float()
var entrySeenOpen  = array.new_bool()
var int tradeCounter = 0

if longSignal and allowLong and validLongStopNow
    tradeCounter += 1
    string entryId = "L_" + str.tostring(tradeCounter)
    strategy.entry(entryId, strategy.long)
    array.push(entryIds, entryId)
    array.push(entryDirs, 1)
    array.push(entryStops, plannedLongStop)
    array.push(entrySeenOpen, false)

if shortSignal and allowShort and validShortStopNow
    tradeCounter += 1
    string entryId = "S_" + str.tostring(tradeCounter)
    strategy.entry(entryId, strategy.short)
    array.push(entryIds, entryId)
    array.push(entryDirs, -1)
    array.push(entryStops, plannedShortStop)
    array.push(entrySeenOpen, false)

// =========================
// Attach / Maintain Exits Per Entry
// =========================
if array.size(entryIds) > 0
    for i = array.size(entryIds) - 1 to 0
        string curId = array.get(entryIds, i)
        int curDir = array.get(entryDirs, i)
        float curStop = array.get(entryStops, i)
        bool seenOpen = array.get(entrySeenOpen, i)

        int openIdx = f_find_open_trade_index(curId)

        if openIdx != -1
            array.set(entrySeenOpen, i, true)

            float entryPrice = strategy.opentrades.entry_price(openIdx)
            float effStop = curDir == 1 ? math.min(curStop, entryPrice - tick) : math.max(curStop, entryPrice + tick)
            float riskPerUnit = curDir == 1 ? (entryPrice - effStop) : (effStop - entryPrice)
            float limitPrice = curDir == 1 ? (entryPrice + rrTarget * riskPerUnit) : (entryPrice - rrTarget * riskPerUnit)

            strategy.exit("X_" + curId, from_entry = curId, stop = effStop, limit = limitPrice)
        else
            if seenOpen
                array.remove(entryIds, i)
                array.remove(entryDirs, i)
                array.remove(entryStops, i)
                array.remove(entrySeenOpen, i)

// =========================
// Visuals
// =========================
plot(ema200, "EMA 200", color = color.orange, linewidth = 2)
plot(showLevels and useSRFilter ? latestSupport : na, "Latest Valid Support", color = color.new(color.lime, 0), linewidth = 2, style = plot.style_linebr)
plot(showLevels and useSRFilter ? latestResistance : na, "Latest Valid Resistance", color = color.new(color.red, 0), linewidth = 2, style = plot.style_linebr)

plotshape(showSignals and longSignal, title = "Long Signal", style = shape.triangleup, location = location.belowbar, color = color.lime, size = size.tiny, text = "L")
plotshape(showSignals and shortSignal, title = "Short Signal", style = shape.triangledown, location = location.abovebar, color = color.red, size = size.tiny, text = "S")

debugLongStopPlot  = showDebugStops and longSignal  ? plannedLongStop  : na
debugShortStopPlot = showDebugStops and shortSignal ? plannedShortStop : na

plot(debugLongStopPlot,  "Planned Long Stop",  color = color.new(color.lime, 0), style = plot.style_circles, linewidth = 2)
plot(debugShortStopPlot, "Planned Short Stop", color = color.new(color.red, 0),  style = plot.style_circles, linewidth = 2)

// =========================
// Alerts
// =========================
alertcondition(longSignal, "Long Setup", "Phantom MACD setup: Long signal detected.")
alertcondition(shortSignal, "Short Setup", "Phantom MACD setup: Short signal detected.")

// ==============================
// Phantom Signature (Brand Mark)
// ==============================
var table phantomSig = table.new(position.top_center, 1, 1, border_width=0,bgcolor = #363a4500)
showsign = input.bool(true,"Show Signature")

if barstate.isfirst and showsign
    table.cell(phantomSig,0, 0,"💎👻💎",text_color=color.white,text_size=size.large,bgcolor=color.new(color.black, 85))
````
