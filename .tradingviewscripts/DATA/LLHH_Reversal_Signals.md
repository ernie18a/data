<!-- tradingview-pine-id: PUB;89ff3a9ac1fa4ccea8de1614e24a9487 -->
<!-- tradingviewscripts-format: 1 -->
# LL-HH Reversal Signals

Source: https://www.tradingview.com/script/63GCf825-LL-HH-Reversal-Signals/

## Description

# LL-HH Reversal Signals

LL-HH Reversal Signals is a market structure indicator designed to identify high-probability reversal opportunities using confirmed swing structure instead of repainting signals.

The script detects Lower Lows (LL) and Higher Highs (HH) to identify potential bullish and bearish reversals while automatically calculating Fibonacci retracement targets, invalidation levels, and trade statistics.

## Features

* Automatic detection of Higher Highs (HH) and Lower Lows (LL)
* Bullish and bearish reversal signals based on confirmed market structure
* Oscillator divergence pre-signals (RSI, MACD, and Stochastic)
* Early structure pre-signals before pivot confirmation
* Fibonacci 0.50 and 0.618 profit targets
* Automatic invalidation levels
* Win/loss statistics table
* Fully customizable alerts
* Non-repainting confirmed pivot logic

## How It Works

The indicator continuously tracks confirmed swing highs and swing lows.

A bullish signal is generated after:

* A confirmed Higher High exists.
* Price forms a confirmed Lower Low.
* The market structure indicates a potential bullish reversal.

A bearish signal is generated after:

* A confirmed Lower Low exists.
* Price forms a confirmed Higher High.
* The market structure indicates a potential bearish reversal.

Before confirmation, the indicator can generate early pre-signals based on oscillator divergence or market structure breaks, allowing traders to prepare before the final confirmation occurs.

## Divergence Pre-Signals

The indicator monitors RSI, MACD, and Stochastic for bullish and bearish divergences.

These divergence signals are used as early warnings and do not replace the confirmed HH/LL reversal logic.

## Trade Management

Each confirmed signal automatically displays:

* Suggested Fibonacci take-profit levels (0.50 or 0.618)
* Invalidation level
* Historical win/loss statistics based on completed trades

This allows traders to evaluate the performance of the strategy directly on the chart.

## Alerts

The script includes alerts for:

* Bullish divergence pre-signal
* Bearish divergence pre-signal
* Bullish structure pre-signal
* Bearish structure pre-signal
* Bullish confirmed reversal
* Bearish confirmed reversal
* Combined "Any Signal" alerts

## Notes

This indicator is designed as a decision-support tool and should be used alongside sound risk management and additional market analysis.

Like any trading methodology, no signal is guaranteed. Users should always validate the strategy on their preferred market and timeframe before using it in live trading.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/ MPL-2.0
//@version=6
indicator("LL-HH Reversal Signals", overlay = true, max_labels_count = 500, max_lines_count = 500)

// --- Constants ---
string FIB_050 = "0.50"
string FIB_0618 = "0.618"
string MODE_CONFIRMED = "Confirmed pivots"
string BREAK_WICK = "Wick"
string BREAK_CLOSE = "Close"

// --- Inputs ---
int leftBars = input.int(5, "Pivot Left Bars", minval = 1, tooltip = "Number of bars to the left of a price pivot")
int rightBars = input.int(5, "Pivot Right Bars", minval = 1, tooltip = "Number of bars to the right of a price pivot")
int rsiLength = input.int(14, "RSI Length", minval = 2, group = "Divergence", tooltip = "RSI period used to detect divergence")
int macdFastLength = input.int(12, "MACD Fast Length", minval = 1, group = "Divergence", tooltip = "Fast EMA length used to calculate MACD")
int macdSlowLength = input.int(26, "MACD Slow Length", minval = 2, group = "Divergence", tooltip = "Slow EMA length used to calculate MACD")
int macdSignalLength = input.int(9, "MACD Signal Length", minval = 1, group = "Divergence", tooltip = "Signal EMA length used to calculate MACD")
int stochasticLength = input.int(14, "Stochastic Length", minval = 1, group = "Divergence", tooltip = "Lookback length used to calculate Stochastic")
int stochasticSmooth = input.int(3, "Stochastic Smoothing", minval = 1, group = "Divergence", tooltip = "SMA smoothing applied before Stochastic pivot detection")
int divergencePivotLeft = input.int(2, "Divergence Left Bars", minval = 1, group = "Divergence", tooltip = "Bars to the left used to confirm oscillator pivots")
int divergencePivotRight = input.int(2, "Divergence Right Bars", minval = 1, group = "Divergence", tooltip = "Bars to the right used to confirm oscillator pivots")
bool enableSignalAlerts = input.bool(true, "Enable Signal Alerts", group = "Alerts", tooltip = "Enable bullish and bearish signal alerts")
bool enablePreSignalAlerts = input.bool(true, "Enable Divergence Pre-Signal Alerts", group = "Alerts", tooltip = "Enable oscillator divergence pre-signal alerts")
bool enableStructurePreSignalAlerts = input.bool(true, "Enable Structure Pre-Signal Alerts", group = "Alerts", tooltip = "Enable early alerts when price breaks the prior pivot and a confirmed signal is developing")
string signalMode = MODE_CONFIRMED
string structurePreSignalSource = input.string(BREAK_CLOSE, "Structure Pre-Signal Confirmation", options = [BREAK_CLOSE, BREAK_WICK], group = "Alerts", tooltip = "Break source for the confirmed-mode pre-signal. It triggers before the new LL or HH pivot is fully confirmed.")
int lookbackTrades = input.int(20, "Trades To Look Back", minval = 1, maxval = 500, tooltip = "Number of most recently completed trades included in the table")
string winFibInput = input.string(FIB_050, "Winning TP Level", options = [FIB_050, FIB_0618], tooltip = "Fib level that confirms a winning trade")
bool showInvalidation = input.bool(true, "Show Invalidation Levels", group = "Style", tooltip = "Show each trade's invalidation level")
bool showDivergenceLines = input.bool(true, "Show Oscillator Divergence Lines", group = "Style", tooltip = "Draw the divergence line used by each pre-signal")
bool showStructurePreSignals = input.bool(true, "Show Structure Pre-Signals", group = "Style", tooltip = "Show the early structure-break label that appears before a confirmed LL or HH signal")
color bullColor = input.color(#089981, "Bullish Color", group = "Style", tooltip = "Color for bullish signals")
color bearColor = input.color(#f23645, "Bearish Color", group = "Style", tooltip = "Color for bearish signals")
color tpColor = input.color(#5b9cf6, "TP (0.50 / 0.618) Color", group = "Style", tooltip = "Color for Fibonacci target levels")

// --- Structure Variables ---
var float lastPH = na
var float prevPH = na
var float lastPL = na
var float prevPL = na
var float llValue = na
var int llIndex = na
var bool lastLowWasLL = false
var float hhValue = na
var int hhIndex = na
var bool lastHighWasHH = false

// --- RSI Divergence Memory ---
var float previousRsiPivotLow = na
var float previousPriceAtRsiLow = na
var int previousBarAtRsiLow = na
var float previousRsiPivotHigh = na
var float previousPriceAtRsiHigh = na
var int previousBarAtRsiHigh = na

// --- MACD Divergence Memory ---
var float previousMacdPivotLow = na
var float previousPriceAtMacdLow = na
var int previousBarAtMacdLow = na
var float previousMacdPivotHigh = na
var float previousPriceAtMacdHigh = na
var int previousBarAtMacdHigh = na

// --- Stochastic Divergence Memory ---
var float previousStochPivotLow = na
var float previousPriceAtStochLow = na
var int previousBarAtStochLow = na
var float previousStochPivotHigh = na
var float previousPriceAtStochHigh = na
var int previousBarAtStochHigh = na

// --- Divergence Pre-Signal Objects ---
var label bullishPendingLabel = na
var line bullishPendingLine = na
var int bullishPendingBar = na
var float bullishPendingPrice = na
var label bearishPendingLabel = na
var line bearishPendingLine = na
var int bearishPendingBar = na
var float bearishPendingPrice = na

// --- Structure Pre-Signal Objects ---
var label bullishStructurePendingLabel = na
var label bearishStructurePendingLabel = na
var bool bullishStructurePending = false
var bool bearishStructurePending = false

// --- Active Trade Variables ---
var array<int> activeDirections = array.new_int()
var array<float> activeTargets = array.new_float()
var array<float> activeStops = array.new_float()
var array<int> activeStartBars = array.new_int()
var array<line> activeInvalidationLines = array.new_line()
var array<bool> tradeResults = array.new_bool()

// --- Indicator Calculations ---
float ph = ta.pivothigh(leftBars, rightBars)
float pl = ta.pivotlow(leftBars, rightBars)
float rsi = ta.rsi(close, rsiLength)
[macdLine, macdSignal, macdHistogram] = ta.macd(close, macdFastLength, macdSlowLength, macdSignalLength)
float stochasticRaw = ta.stoch(close, high, low, stochasticLength)
float stochastic = ta.sma(stochasticRaw, stochasticSmooth)
float rsiPH = ta.pivothigh(rsi, divergencePivotLeft, divergencePivotRight)
float rsiPL = ta.pivotlow(rsi, divergencePivotLeft, divergencePivotRight)
float macdPH = ta.pivothigh(macdLine, divergencePivotLeft, divergencePivotRight)
float macdPL = ta.pivotlow(macdLine, divergencePivotLeft, divergencePivotRight)
float stochasticPH = ta.pivothigh(stochastic, divergencePivotLeft, divergencePivotRight)
float stochasticPL = ta.pivotlow(stochastic, divergencePivotLeft, divergencePivotRight)
float labelSpacing = math.max(nz(ta.atr(14), high - low), syminfo.mintick * 10) * 0.75

// --- Signal State ---
bool bullishSignal = false
bool bearishSignal = false
bool bullishPreSignal = false
bool bearishPreSignal = false
bool bullishStructurePreSignal = false
bool bearishStructurePreSignal = false

// --- Divergence State For This Bar ---
bool bullishRsiDivergence = false
bool bearishRsiDivergence = false
bool bullishMacdDivergence = false
bool bearishMacdDivergence = false
bool bullishStochasticDivergence = false
bool bearishStochasticDivergence = false
float bullishRsiPrice = na
float bullishRsiPreviousPrice = na
int bullishRsiBar = na
int bullishRsiPreviousBar = na
float bearishRsiPrice = na
float bearishRsiPreviousPrice = na
int bearishRsiBar = na
int bearishRsiPreviousBar = na
float bullishMacdPrice = na
float bullishMacdPreviousPrice = na
int bullishMacdBar = na
int bullishMacdPreviousBar = na
float bearishMacdPrice = na
float bearishMacdPreviousPrice = na
int bearishMacdBar = na
int bearishMacdPreviousBar = na
float bullishStochasticPrice = na
float bullishStochasticPreviousPrice = na
int bullishStochasticBar = na
int bullishStochasticPreviousBar = na
float bearishStochasticPrice = na
float bearishStochasticPreviousPrice = na
int bearishStochasticBar = na
int bearishStochasticPreviousBar = na

if not na(rsiPL)
    bullishRsiPrice := low[divergencePivotRight]
    bullishRsiPreviousPrice := previousPriceAtRsiLow
    bullishRsiPreviousBar := previousBarAtRsiLow
    bullishRsiBar := bar_index[divergencePivotRight]
    bullishRsiDivergence := not na(previousRsiPivotLow) and bullishRsiPrice < previousPriceAtRsiLow and rsiPL > previousRsiPivotLow
    previousRsiPivotLow := rsiPL
    previousPriceAtRsiLow := bullishRsiPrice
    previousBarAtRsiLow := bullishRsiBar

if not na(rsiPH)
    bearishRsiPrice := high[divergencePivotRight]
    bearishRsiPreviousPrice := previousPriceAtRsiHigh
    bearishRsiPreviousBar := previousBarAtRsiHigh
    bearishRsiBar := bar_index[divergencePivotRight]
    bearishRsiDivergence := not na(previousRsiPivotHigh) and bearishRsiPrice > previousPriceAtRsiHigh and rsiPH < previousRsiPivotHigh
    previousRsiPivotHigh := rsiPH
    previousPriceAtRsiHigh := bearishRsiPrice
    previousBarAtRsiHigh := bearishRsiBar

if not na(macdPL)
    bullishMacdPrice := low[divergencePivotRight]
    bullishMacdPreviousPrice := previousPriceAtMacdLow
    bullishMacdPreviousBar := previousBarAtMacdLow
    bullishMacdBar := bar_index[divergencePivotRight]
    bullishMacdDivergence := not na(previousMacdPivotLow) and bullishMacdPrice < previousPriceAtMacdLow and macdPL > previousMacdPivotLow
    previousMacdPivotLow := macdPL
    previousPriceAtMacdLow := bullishMacdPrice
    previousBarAtMacdLow := bullishMacdBar

if not na(macdPH)
    bearishMacdPrice := high[divergencePivotRight]
    bearishMacdPreviousPrice := previousPriceAtMacdHigh
    bearishMacdPreviousPrice := previousPriceAtMacdHigh
    bearishMacdPreviousBar := previousBarAtMacdHigh
    bearishMacdBar := bar_index[divergencePivotRight]
    bearishMacdDivergence := not na(previousMacdPivotHigh) and bearishMacdPrice > previousPriceAtMacdHigh and macdPH < previousMacdPivotHigh
    previousMacdPivotHigh := macdPH
    previousPriceAtMacdHigh := bearishMacdPrice
    previousBarAtMacdHigh := bearishMacdBar

if not na(stochasticPL)
    bullishStochasticPrice := low[divergencePivotRight]
    bullishStochasticPreviousPrice := previousPriceAtStochLow
    bullishStochasticPreviousBar := previousBarAtStochLow
    bullishStochasticBar := bar_index[divergencePivotRight]
    bullishStochasticDivergence := not na(previousStochPivotLow) and bullishStochasticPrice < previousPriceAtStochLow and stochasticPL > previousStochPivotLow
    previousStochPivotLow := stochasticPL
    previousPriceAtStochLow := bullishStochasticPrice
    previousBarAtStochLow := bullishStochasticBar

if not na(stochasticPH)
    bearishStochasticPrice := high[divergencePivotRight]
    bearishStochasticPreviousPrice := previousPriceAtStochHigh
    bearishStochasticPreviousBar := previousBarAtStochHigh
    bearishStochasticBar := bar_index[divergencePivotRight]
    bearishStochasticDivergence := not na(previousStochPivotHigh) and bearishStochasticPrice > previousPriceAtStochHigh and stochasticPH < previousStochPivotHigh
    previousStochPivotHigh := stochasticPH
    previousPriceAtStochHigh := bearishStochasticPrice
    previousBarAtStochHigh := bearishStochasticBar

bool bullishDivergence = bullishRsiDivergence or bullishMacdDivergence or bullishStochasticDivergence
bool bearishDivergence = bearishRsiDivergence or bearishMacdDivergence or bearishStochasticDivergence
float bullishDivergencePrice = bullishRsiDivergence ? bullishRsiPrice : bullishMacdDivergence ? bullishMacdPrice : bullishStochasticPrice
float bullishDivergencePreviousPrice = bullishRsiDivergence ? bullishRsiPreviousPrice : bullishMacdDivergence ? bullishMacdPreviousPrice : bullishStochasticPreviousPrice
int bullishDivergenceBar = bullishRsiDivergence ? bullishRsiBar : bullishMacdDivergence ? bullishMacdBar : bullishStochasticBar
int bullishDivergencePreviousBar = bullishRsiDivergence ? bullishRsiPreviousBar : bullishMacdDivergence ? bullishMacdPreviousBar : bullishStochasticPreviousBar
string bullishDivergenceSource = bullishRsiDivergence ? "RSI" : bullishMacdDivergence ? "MACD" : "Stochastic"
float bearishDivergencePrice = bearishRsiDivergence ? bearishRsiPrice : bearishMacdDivergence ? bearishMacdPrice : bearishStochasticPrice
float bearishDivergencePreviousPrice = bearishRsiDivergence ? bearishRsiPreviousPrice : bearishMacdDivergence ? bearishMacdPreviousPrice : bearishStochasticPreviousPrice
int bearishDivergenceBar = bearishRsiDivergence ? bearishRsiBar : bearishMacdDivergence ? bearishMacdBar : bearishStochasticBar
int bearishDivergencePreviousBar = bearishRsiDivergence ? bearishRsiPreviousBar : bearishMacdDivergence ? bearishMacdPreviousBar : bearishStochasticPreviousBar
string bearishDivergenceSource = bearishRsiDivergence ? "RSI" : bearishMacdDivergence ? "MACD" : "Stochastic"

// --- Evaluate Active Trades ---
int activeCount = array.size(activeDirections)
if activeCount > 0
    for j = 0 to activeCount - 1
        int tradeIndex = activeCount - 1 - j
        int startBar = array.get(activeStartBars, tradeIndex)
        line invalidationLine = array.get(activeInvalidationLines, tradeIndex)
        if not na(invalidationLine)
            line.set_x2(invalidationLine, bar_index)
        if bar_index > startBar
            int direction = array.get(activeDirections, tradeIndex)
            float target = array.get(activeTargets, tradeIndex)
            float stop = array.get(activeStops, tradeIndex)
            bool stopHit = direction == 1 ? low <= stop : high >= stop
            bool targetHit = direction == 1 ? high >= target : low <= target
            if stopHit or targetHit
                bool isWin = targetHit and not stopHit
                array.push(tradeResults, isWin)
                if array.size(tradeResults) > lookbackTrades
                    array.shift(tradeResults)
                if not na(invalidationLine)
                    line.delete(invalidationLine)
                array.remove(activeDirections, tradeIndex)
                array.remove(activeTargets, tradeIndex)
                array.remove(activeStops, tradeIndex)
                array.remove(activeStartBars, tradeIndex)
                array.remove(activeInvalidationLines, tradeIndex)

// --- Confirmed-Mode Structure Pre-Signals ---
// A structure pre-signal fires when price breaks the latest confirmed pivot that
// should become the next LL or HH. The confirmed signal still waits for the
// new pivot's rightBars confirmation, so this removes most of that delay.
if signalMode == MODE_CONFIRMED
    bool breaksPreviousHighForPreSignal = not na(lastPH) and (structurePreSignalSource == BREAK_CLOSE ? close > lastPH : high > lastPH)
    bool breaksPreviousLowForPreSignal = not na(lastPL) and (structurePreSignalSource == BREAK_CLOSE ? close < lastPL : low < lastPL)
    bool bullishStructureWaiting = lastHighWasHH and breaksPreviousLowForPreSignal and not breaksPreviousHighForPreSignal and not bullishStructurePending
    bool bearishStructureWaiting = lastLowWasLL and breaksPreviousHighForPreSignal and not breaksPreviousLowForPreSignal and not bearishStructurePending

    if bullishStructureWaiting
        bullishStructurePending := true
        bullishStructurePreSignal := true
        if showStructurePreSignals
            bullishStructurePendingLabel := label.new(bar_index, low - labelSpacing, "Bullish Structure Pre-Signal\nPrice broke prior LL\nWaiting for LL confirmation", color = color.new(bullColor, 15), textcolor = chart.fg_color, style = label.style_label_up, size = size.tiny)

    if bearishStructureWaiting
        bearishStructurePending := true
        bearishStructurePreSignal := true
        if showStructurePreSignals
            bearishStructurePendingLabel := label.new(bar_index, high + labelSpacing, "Bearish Structure Pre-Signal\nPrice broke prior HH\nWaiting for HH confirmation", color = color.new(bearColor, 15), textcolor = chart.fg_color, style = label.style_label_down, size = size.tiny)

// --- Confirmed Pivot Structure Updates ---
if not na(ph)
    prevPH := lastPH
    lastPH := ph
    if not na(prevPH)
        if lastPH > prevPH
            hhValue := lastPH
            hhIndex := bar_index[rightBars]
            lastHighWasHH := true
            if signalMode == MODE_CONFIRMED and lastLowWasLL
                bearishSignal := true
                float fibRange = hhValue - llValue
                float fib050 = hhValue - fibRange * 0.50
                float fib0618 = hhValue - fibRange * 0.618
                float winTarget = winFibInput == FIB_0618 ? fib0618 : fib050
                label.new(hhIndex, high[rightBars], "Bearish Signal\nTP 0.50-0.618\nWin: " + str.tostring(winTarget, format.mintick) + "\nInvalidation: " + str.tostring(hhValue, format.mintick), color = bearColor, textcolor = chart.fg_color, style = label.style_label_down, size = size.small)
                line.new(llIndex, fib050, hhIndex, fib050, color = tpColor, width = 2, style = line.style_dashed)
                line.new(llIndex, fib0618, hhIndex, fib0618, color = tpColor, width = 2, style = line.style_dotted)
                line invalidationLine = showInvalidation ? line.new(hhIndex, hhValue, bar_index, hhValue, color = bearColor, width = 2) : na
                array.push(activeDirections, -1)
                array.push(activeTargets, winTarget)
                array.push(activeStops, hhValue)
                array.push(activeStartBars, bar_index)
                array.push(activeInvalidationLines, invalidationLine)
                if bearishStructurePending
                    if not na(bearishStructurePendingLabel)
                        label.set_text(bearishStructurePendingLabel, "Bearish Structure Pre-Signal\nHH confirmation received")
                    bearishStructurePendingLabel := na
                    bearishStructurePending := false
                lastLowWasLL := false

if not na(pl)
    prevPL := lastPL
    lastPL := pl
    if not na(prevPL)
        if lastPL < prevPL
            llValue := lastPL
            llIndex := bar_index[rightBars]
            lastLowWasLL := true
            if signalMode == MODE_CONFIRMED and lastHighWasHH
                bullishSignal := true
                float fibRange = hhValue - llValue
                float fib050 = llValue + fibRange * 0.50
                float fib0618 = llValue + fibRange * 0.618
                float winTarget = winFibInput == FIB_0618 ? fib0618 : fib050
                label.new(llIndex, low[rightBars], "Bullish Signal\nTP 0.50-0.618\nWin: " + str.tostring(winTarget, format.mintick) + "\nInvalidation: " + str.tostring(llValue, format.mintick), color = bullColor, textcolor = chart.fg_color, style = label.style_label_up, size = size.small)
                line.new(hhIndex, fib050, llIndex, fib050, color = tpColor, width = 2, style = line.style_dashed)
                line.new(hhIndex, fib0618, llIndex, fib0618, color = tpColor, width = 2, style = line.style_dotted)
                line invalidationLine = showInvalidation ? line.new(llIndex, llValue, bar_index, llValue, color = bullColor, width = 2) : na
                array.push(activeDirections, 1)
                array.push(activeTargets, winTarget)
                array.push(activeStops, llValue)
                array.push(activeStartBars, bar_index)
                array.push(activeInvalidationLines, invalidationLine)
                if bullishStructurePending
                    if not na(bullishStructurePendingLabel)
                        label.set_text(bullishStructurePendingLabel, "Bullish Structure Pre-Signal\nLL confirmation received")
                    bullishStructurePendingLabel := na
                    bullishStructurePending := false
                lastHighWasHH := false

// --- Divergence Pre-Signal Management ---
// Divergence pre-signals are provisional and remain visible after confirmation
// so both the original divergence and the confirmed signal can be reviewed.
if signalMode == MODE_CONFIRMED
    bool bullishWaiting = bullishDivergence and not bullishSignal and lastHighWasHH and not na(lastPL) and bullishDivergencePrice < lastPL and bar_index <= bullishDivergenceBar + rightBars
    bool bearishWaiting = bearishDivergence and not bearishSignal and lastLowWasLL and not na(lastPH) and bearishDivergencePrice > lastPH and bar_index <= bearishDivergenceBar + rightBars

    if bullishWaiting
        if not na(bullishPendingLabel)
            label.delete(bullishPendingLabel)
        if not na(bullishPendingLine)
            line.delete(bullishPendingLine)
        bullishPendingLabel := label.new(bullishDivergenceBar, bullishDivergencePrice - labelSpacing * 2.0, "Bullish Pre-Signal\n" + bullishDivergenceSource + " Divergence\nWaiting for LL confirmation", color = color.new(bullColor, 15), textcolor = chart.fg_color, style = label.style_label_up, size = size.tiny)
        bullishPendingLine := showDivergenceLines ? line.new(bullishDivergencePreviousBar, bullishDivergencePreviousPrice, bullishDivergenceBar, bullishDivergencePrice, color = bullColor, width = 2) : na
        bullishPendingBar := bullishDivergenceBar
        bullishPendingPrice := bullishDivergencePrice
        bullishPreSignal := true

    if bearishWaiting
        if not na(bearishPendingLabel)
            label.delete(bearishPendingLabel)
        if not na(bearishPendingLine)
            line.delete(bearishPendingLine)
        bearishPendingLabel := label.new(bearishDivergenceBar, bearishDivergencePrice + labelSpacing * 2.0, "Bearish Pre-Signal\n" + bearishDivergenceSource + " Divergence\nWaiting for HH confirmation", color = color.new(bearColor, 15), textcolor = chart.fg_color, style = label.style_label_down, size = size.tiny)
        bearishPendingLine := showDivergenceLines ? line.new(bearishDivergencePreviousBar, bearishDivergencePreviousPrice, bearishDivergenceBar, bearishDivergencePrice, color = bearColor, width = 2) : na
        bearishPendingBar := bearishDivergenceBar
        bearishPendingPrice := bearishDivergencePrice
        bearishPreSignal := true

    if not na(bullishPendingLabel)
        bool bullishConfirmed = bullishSignal and not na(pl) and bar_index[rightBars] == bullishPendingBar
        bool bullishInvalidated = low < bullishPendingPrice or not lastHighWasHH
        bool bullishExpired = bar_index > bullishPendingBar + rightBars
        if bullishConfirmed
            label.set_text(bullishPendingLabel, "Bullish Pre-Signal\nDivergence Confirmed\nLL confirmation received")
            bullishPendingLabel := na
            bullishPendingLine := na
            bullishPendingBar := na
            bullishPendingPrice := na
        else if bullishInvalidated or bullishExpired
            label.delete(bullishPendingLabel)
            if not na(bullishPendingLine)
                line.delete(bullishPendingLine)
            bullishPendingLabel := na
            bullishPendingLine := na
            bullishPendingBar := na
            bullishPendingPrice := na

    if not na(bearishPendingLabel)
        bool bearishConfirmed = bearishSignal and not na(ph) and bar_index[rightBars] == bearishPendingBar
        bool bearishInvalidated = high > bearishPendingPrice or not lastLowWasLL
        bool bearishExpired = bar_index > bearishPendingBar + rightBars
        if bearishConfirmed
            label.set_text(bearishPendingLabel, "Bearish Pre-Signal\nDivergence Confirmed\nHH confirmation received")
            bearishPendingLabel := na
            bearishPendingLine := na
            bearishPendingBar := na
            bearishPendingPrice := na
        else if bearishInvalidated or bearishExpired
            label.delete(bearishPendingLabel)
            if not na(bearishPendingLine)
                line.delete(bearishPendingLine)
            bearishPendingLabel := na
            bearishPendingLine := na
            bearishPendingBar := na
            bearishPendingPrice := na
else
    if not na(bullishPendingLabel)
        label.delete(bullishPendingLabel)
    if not na(bullishPendingLine)
        line.delete(bullishPendingLine)
    if not na(bearishPendingLabel)
        label.delete(bearishPendingLabel)
    if not na(bearishPendingLine)
        line.delete(bearishPendingLine)
    bullishPendingLabel := na
    bullishPendingLine := na
    bullishPendingBar := na
    bullishPendingPrice := na
    bearishPendingLabel := na
    bearishPendingLine := na
    bearishPendingBar := na
    bearishPendingPrice := na


// --- Alerts ---
alertcondition(enablePreSignalAlerts and bullishPreSignal, "Bullish Oscillator Divergence Pre-Signal", "Bullish RSI, MACD, or Stochastic divergence pre-signal on {{ticker}} {{interval}}. Structure is waiting for LL confirmation. Close: {{close}}")
alertcondition(enablePreSignalAlerts and bearishPreSignal, "Bearish Oscillator Divergence Pre-Signal", "Bearish RSI, MACD, or Stochastic divergence pre-signal on {{ticker}} {{interval}}. Structure is waiting for HH confirmation. Close: {{close}}")
alertcondition(enableStructurePreSignalAlerts and bullishStructurePreSignal, "Bullish Structure Pre-Signal", "Bullish structure pre-signal on {{ticker}} {{interval}}. Price broke the prior LL and an LL confirmation is developing. Close: {{close}}")
alertcondition(enableStructurePreSignalAlerts and bearishStructurePreSignal, "Bearish Structure Pre-Signal", "Bearish structure pre-signal on {{ticker}} {{interval}}. Price broke the prior HH and an HH confirmation is developing. Close: {{close}}")
alertcondition(enableSignalAlerts and bullishSignal, "Bullish Reversal Signal", "Bullish reversal signal on {{ticker}} {{interval}}. Close: {{close}}")
alertcondition(enableSignalAlerts and bearishSignal, "Bearish Reversal Signal", "Bearish reversal signal on {{ticker}} {{interval}}. Close: {{close}}")
alertcondition(signalMode == MODE_CONFIRMED and enablePreSignalAlerts and bullishPreSignal, "Confirmed Pivot Bullish Divergence Pre-Signal", "Confirmed-pivot bullish divergence pre-signal from RSI, MACD, or Stochastic on {{ticker}} {{interval}}. Waiting for LL confirmation. Close: {{close}}")
alertcondition(signalMode == MODE_CONFIRMED and enablePreSignalAlerts and bearishPreSignal, "Confirmed Pivot Bearish Divergence Pre-Signal", "Confirmed-pivot bearish divergence pre-signal from RSI, MACD, or Stochastic on {{ticker}} {{interval}}. Waiting for HH confirmation. Close: {{close}}")
alertcondition(signalMode == MODE_CONFIRMED and enableSignalAlerts and bullishSignal, "Confirmed Pivot Bullish Signal", "Confirmed-pivot bullish reversal signal on {{ticker}} {{interval}}. Close: {{close}}")
alertcondition(signalMode == MODE_CONFIRMED and enableSignalAlerts and bearishSignal, "Confirmed Pivot Bearish Signal", "Confirmed-pivot bearish reversal signal on {{ticker}} {{interval}}. Close: {{close}}")
alertcondition(signalMode == MODE_CONFIRMED and enablePreSignalAlerts and (bullishPreSignal or bearishPreSignal), "Confirmed Pivot Any Divergence Pre-Signal", "Confirmed-pivot oscillator divergence pre-signal on {{ticker}} {{interval}}. Close: {{close}}")
alertcondition(signalMode == MODE_CONFIRMED and enableStructurePreSignalAlerts and (bullishStructurePreSignal or bearishStructurePreSignal), "Confirmed Pivot Any Structure Pre-Signal", "Confirmed-pivot structure pre-signal on {{ticker}} {{interval}}. Close: {{close}}")
alertcondition(signalMode == MODE_CONFIRMED and enableSignalAlerts and (bullishSignal or bearishSignal), "Confirmed Pivot Any Signal", "Confirmed-pivot reversal signal on {{ticker}} {{interval}}. Close: {{close}}")
alertcondition((enableSignalAlerts and (bullishSignal or bearishSignal)) or (enablePreSignalAlerts and (bullishPreSignal or bearishPreSignal)) or (enableStructurePreSignalAlerts and (bullishStructurePreSignal or bearishStructurePreSignal)), "Any Reversal Signal", "Reversal signal or pre-signal on {{ticker}} {{interval}}. Close: {{close}}")

// Direct alert() calls support the "Any alert() function call" alert option.
if enablePreSignalAlerts and bullishPreSignal
    alert("Bullish oscillator divergence pre-signal on " + syminfo.ticker + " " + timeframe.period + ". Structure is waiting for LL confirmation. Close: " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
if enablePreSignalAlerts and bearishPreSignal
    alert("Bearish oscillator divergence pre-signal on " + syminfo.ticker + " " + timeframe.period + ". Structure is waiting for HH confirmation. Close: " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
if enableStructurePreSignalAlerts and bullishStructurePreSignal
    alert("Bullish structure pre-signal on " + syminfo.ticker + " " + timeframe.period + ". Price broke the prior LL and an LL confirmation is developing. Close: " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
if enableStructurePreSignalAlerts and bearishStructurePreSignal
    alert("Bearish structure pre-signal on " + syminfo.ticker + " " + timeframe.period + ". Price broke the prior HH and an HH confirmation is developing. Close: " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
if enableSignalAlerts and bullishSignal
    alert("Bullish confirmed reversal signal on " + syminfo.ticker + " " + timeframe.period + ". Close: " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
if enableSignalAlerts and bearishSignal
    alert("Bearish confirmed reversal signal on " + syminfo.ticker + " " + timeframe.period + ". Close: " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)

// --- Pivot Markers ---
plotshape(ph, "Pivot High", shape.triangledown, location.abovebar, color.new(bearColor, 80), offset = -rightBars, size = size.tiny)
plotshape(pl, "Pivot Low", shape.triangleup, location.belowbar, color.new(bullColor, 80), offset = -rightBars, size = size.tiny)

// --- Results Table ---
var table resultsTable = table.new(position.top_right, 2, 7, border_width = 1)
int resultCount = array.size(tradeResults)
int wins = 0
int losses = 0
if resultCount > 0
    for i = 0 to resultCount - 1
        if array.get(tradeResults, i)
            wins += 1
        else
            losses += 1
int completedTrades = wins + losses
float winRate = completedTrades > 0 ? wins * 100.0 / completedTrades : na
if barstate.islast
    color headerBg = color.new(tpColor, 70)
    table.cell(resultsTable, 0, 0, "TRADE RESULTS", bgcolor = headerBg, text_color = chart.fg_color)
    table.cell(resultsTable, 1, 0, "LAST " + str.tostring(lookbackTrades), bgcolor = headerBg, text_color = chart.fg_color)
    table.cell(resultsTable, 0, 1, "Signal Mode", text_color = chart.fg_color)
    table.cell(resultsTable, 1, 1, "Confirmed pivots", text_color = tpColor)
    table.cell(resultsTable, 0, 2, "Win TP", text_color = chart.fg_color)
    table.cell(resultsTable, 1, 2, winFibInput, text_color = tpColor)
    table.cell(resultsTable, 0, 3, "Wins", text_color = chart.fg_color)
    table.cell(resultsTable, 1, 3, str.tostring(wins), text_color = bullColor)
    table.cell(resultsTable, 0, 4, "Losses", text_color = chart.fg_color)
    table.cell(resultsTable, 1, 4, str.tostring(losses), text_color = bearColor)
    table.cell(resultsTable, 0, 5, "Completed", text_color = chart.fg_color)
    table.cell(resultsTable, 1, 5, str.tostring(completedTrades), text_color = chart.fg_color)
    table.cell(resultsTable, 0, 6, "Win Rate", text_color = chart.fg_color)
    table.cell(resultsTable, 1, 6, na(winRate) ? "N/A" : str.tostring(winRate, "#.##") + "%", text_color = chart.fg_color)
````
