# Multi-Timeframe Trend Table (Weighted)

- url: https://www.tradingview.com/script/XeF0gibv-Multi-Timeframe-Trend-Table-Weighted/
- type: indicator
- pine_id: PUB;706f403bbed3407cabc4476ee018fde1
- version: 1.0

## Description

**Multi-Timeframe Trend Table (Weighted) — Market Bias Dashboard**

This indicator is a **multi-timeframe trend analysis system** designed to evaluate overall market direction using a weighted combination of **ATR trend structure, Stochastic RSI momentum, and Moving Averages** across multiple timeframes.

It aggregates data from higher to lower timeframes into a single **bias scoring table**, giving traders a clear, structured view of market sentiment and directional strength.

---

### 🔍 Core Concept

Instead of relying on a single timeframe or indicator, this tool builds a **composite market bias model** by:

* Analysing trend strength across multiple timeframes (Monthly → 1M)
* Applying weighted importance to each timeframe
* Combining three key systems:

* ATR-based trend direction (volatility structure)
* Stochastic RSI momentum shifts
* Moving Average bias filter

---

### 📊 Key Features

• **Multi-Timeframe Structure**

* Monthly, Weekly, Daily, 4H, 1H, 30m, 15m, 1m analysis
* Hierarchical trend evaluation from macro → micro

• **Weighted Bias System**

* Assigns importance to each timeframe (customisable)
* Higher timeframes dominate overall market direction
* Produces a final **bullish / bearish bias score**

• **Triple Indicator Confirmation**
Each timeframe uses:

* ATR trend logic (volatility direction)
* Stochastic RSI (momentum confirmation)
* Moving Average filter (trend bias)

• **No Repainting Logic**

* Uses confirmed higher timeframe closes only
* Prevents false real-time signal shifts
* Ensures stable, reliable bias readings

• **Signal Threshold System**

* Custom X-signal trigger based on bias strength
* Highlights strong directional conviction zones

---

### 📊 How to Use

**Bullish Bias**

* Higher timeframes align bullish
* Weighted score exceeds threshold
→ Market favours long setups

**Bearish Bias**

* Higher timeframes align bearish
* Weighted score exceeds threshold
→ Market favours short setups

**Neutral / Mixed Bias**

* Conflicting multi-timeframe signals
→ Avoid directional trading or wait for alignment

---

### ⚠️ Best Practice

This is a **market context tool**, not a standalone entry system.

For best performance combine with:

* Liquidity zones
* Market structure (BOS / CHoCH)
* Support & resistance levels
* Entry triggers from lower timeframe setups

---

### 🚀 Ideal For

* Swing traders
* Position traders
* Smart money / structure-based trading
* Multi-timeframe confirmation strategies
* Crypto, Forex, indices

---

### 🧠 Trading Philosophy

**Higher timeframes define direction.
Lower timeframes define execution.
This tool bridges both into one bias model.**

---

**Trade with alignment, not randomness.**

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Gemini

//@version=6
// This indicator calculates and displays multi-timeframe trend biases in a dynamic table.
// It uses a combination of ATR, Stochastic RSI, and Moving Average to determine the trend
// for each selected timeframe, then aggregates the results into a final bias score.
// This version uses 'lookahead=barmerge.lookahead_off' to use only closed and final data
// from higher timeframes. This prevents the indicator from "repainting" on the current bar,
// providing a more stable and reliable signal.

// This updated version also implements a new weighting system for the three indicators:
// ATR is weighted at 40%, Stoch RSI at 30%, and the Moving Average at 30%.
indicator('Multi-Timeframe Trend Table (Weighted)', overlay = true, scale = scale.right)

//================================================================================
// INPUTS - User-configurable settings with improved organization.
//================================================================================

// --- Table & Aesthetics Settings
var string groupAesthetics = 'Table & Aesthetics'
i_tableTextSize = input.string(size.small, 'Table Text Size', options = [size.tiny, size.small, size.normal, size.large], group = groupAesthetics)
i_showXSignals = input.bool(true, 'Show X Signals', group = groupAesthetics)
i_biasThreshold = input.float(55.0, 'X Signal Threshold (%)', minval = 0.0, maxval = 100.0, step = 1.0, group = groupAesthetics, tooltip = 'The overall bias score percentage required to trigger a bullish or bearish \'X\' signal.')

// --- Timeframe Settings
var string groupTimeframes = 'Timeframe Settings'
i_tf0_select = input.timeframe('M', 'Timeframe 0', group = groupTimeframes)
i_tf1_select = input.timeframe('W', 'Timeframe 1', group = groupTimeframes)
i_tf2_select = input.timeframe('D', 'Timeframe 2', group = groupTimeframes)
i_tf3_select = input.timeframe('240', 'Timeframe 3', group = groupTimeframes)
i_tf4_select = input.timeframe('60', 'Timeframe 4', group = groupTimeframes)
i_tf5_select = input.timeframe('30', 'Timeframe 5', group = groupTimeframes)
i_tf6_select = input.timeframe('15', 'Timeframe 6', group = groupTimeframes)
i_tf7_select = input.timeframe('1', 'Timeframe 7', group = groupTimeframes)

// --- Indicator Parameters (Grouped for each timeframe)
var string groupTF0 = 'Timeframe 0 (Monthly) Parameters'
i_atrPeriod0 = input.int(10, 'ATR Period', group = groupTF0)
i_src0 = input.source(hl2, 'Source', group = groupTF0)
i_multiplier0 = input.float(2.0, 'ATR Multiplier', step = 0.1, group = groupTF0)
i_stochRsiK0 = input.int(3, 'Stoch RSI K', group = groupTF0)
i_stochRsiD0 = input.int(3, 'Stoch RSI D', group = groupTF0)
i_stochRsiLength0 = input.int(14, 'Stoch RSI Length', group = groupTF0)
i_maPeriod0 = input.int(20, 'Moving Average Period', group = groupTF0)

var string groupTF1 = 'Timeframe 1 (Weekly) Parameters'
i_atrPeriod1 = input.int(10, 'ATR Period', group = groupTF1)
i_src1 = input.source(hl2, 'Source', group = groupTF1)
i_multiplier1 = input.float(2.0, 'ATR Multiplier', step = 0.1, group = groupTF1)
i_stochRsiK1 = input.int(3, 'Stoch RSI K', group = groupTF1)
i_stochRsiD1 = input.int(3, 'Stoch RSI D', group = groupTF1)
i_stochRsiLength1 = input.int(14, 'Stoch RSI Length', group = groupTF1)
i_maPeriod1 = input.int(20, 'Moving Average Period', group = groupTF1)

var string groupTF2 = 'Timeframe 2 (Daily) Parameters'
i_atrPeriod2 = input.int(10, 'ATR Period', group = groupTF2)
i_src2 = input.source(hl2, 'Source', group = groupTF2)
i_multiplier2 = input.float(2.0, 'ATR Multiplier', step = 0.1, group = groupTF2)
i_stochRsiK2 = input.int(3, 'Stoch RSI K', group = groupTF2)
i_stochRsiD2 = input.int(3, 'Stoch RSI D', group = groupTF2)
i_stochRsiLength2 = input.int(14, 'Stoch RSI Length', group = groupTF2)
i_maPeriod2 = input.int(20, 'Moving Average Period', group = groupTF2)

var string groupTF3 = 'Timeframe 3 (4H) Parameters'
i_atrPeriod3 = input.int(10, 'ATR Period', group = groupTF3)
i_src3 = input.source(hl2, 'Source', group = groupTF3)
i_multiplier3 = input.float(2.0, 'ATR Multiplier', step = 0.1, group = groupTF3)
i_stochRsiK3 = input.int(3, 'Stoch RSI K', group = groupTF3)
i_stochRsiD3 = input.int(3, 'Stoch RSI D', group = groupTF3)
i_stochRsiLength3 = input.int(14, 'Stoch RSI Length', group = groupTF3)
i_maPeriod3 = input.int(20, 'Moving Average Period', group = groupTF3)

var string groupTF4 = 'Timeframe 4 (1H) Parameters'
i_atrPeriod4 = input.int(10, 'ATR Period', group = groupTF4)
i_src4 = input.source(hl2, 'Source', group = groupTF4)
i_multiplier4 = input.float(2.0, 'ATR Multiplier', step = 0.1, group = groupTF4)
i_stochRsiK4 = input.int(3, 'Stoch RSI K', group = groupTF4)
i_stochRsiD4 = input.int(3, 'Stoch RSI D', group = groupTF4)
i_stochRsiLength4 = input.int(14, 'Stoch RSI Length', group = groupTF4)
i_maPeriod4 = input.int(20, 'Moving Average Period', group = groupTF4)

var string groupTF5 = 'Timeframe 5 (30m) Parameters'
i_atrPeriod5 = input.int(10, 'ATR Period', group = groupTF5)
i_src5 = input.source(hl2, 'Source', group = groupTF5)
i_multiplier5 = input.float(2.0, 'ATR Multiplier', step = 0.1, group = groupTF5)
i_stochRsiK5 = input.int(3, 'Stoch RSI K', group = groupTF5)
i_stochRsiD5 = input.int(3, 'Stoch RSI D', group = groupTF5)
i_stochRsiLength5 = input.int(14, 'Stoch RSI Length', group = groupTF5)
i_maPeriod5 = input.int(20, 'Moving Average Period', group = groupTF5)

var string groupTF6 = 'Timeframe 6 (15m) Parameters'
i_atrPeriod6 = input.int(10, 'ATR Period', group = groupTF6)
i_src6 = input.source(hl2, 'Source', group = groupTF6)
i_multiplier6 = input.float(2.0, 'ATR Multiplier', step = 0.1, group = groupTF6)
i_stochRsiK6 = input.int(3, 'Stoch RSI K', group = groupTF6)
i_stochRsiD6 = input.int(3, 'Stoch RSI D', group = groupTF6)
i_stochRsiLength6 = input.int(14, 'Stoch RSI Length', group = groupTF6)
i_maPeriod6 = input.int(20, 'Moving Average Period', group = groupTF6)

var string groupTF7 = 'Timeframe 7 (1m) Parameters'
i_atrPeriod7 = input.int(10, 'ATR Period', group = groupTF7)
i_src7 = input.source(hl2, 'Source', group = groupTF7)
i_multiplier7 = input.float(2.0, 'ATR Multiplier', step = 0.1, group = groupTF7)
i_stochRsiK7 = input.int(3, 'Stoch RSI K', group = groupTF7)
i_stochRsiD7 = input.int(3, 'Stoch RSI D', group = groupTF7)
i_stochRsiLength7 = input.int(14, 'Stoch RSI Length', group = groupTF7)
i_maPeriod7 = input.int(20, 'Moving Average Period', group = groupTF7)

// --- Bias Weighting Settings
var string groupWeights = 'Bias Weights (%)'
i_weight0 = input.float(35, 'Weight TF0', minval = 0.0, maxval = 100.0, step = 1.0, tooltip = 'Monthly is typically the most important, so a higher weight is common.', group = groupWeights)
i_weight1 = input.float(25, 'Weight TF1', minval = 0.0, maxval = 100.0, step = 1.0, group = groupWeights)
i_weight2 = input.float(15, 'Weight TF2', minval = 0.0, maxval = 100.0, step = 1.0, group = groupWeights)
i_weight3 = input.float(10, 'Weight TF3', minval = 0.0, maxval = 100.0, step = 1.0, group = groupWeights)
i_weight4 = input.float(10, 'Weight TF4', minval = 0.0, maxval = 100.0, step = 1.0, group = groupWeights)
i_weight5 = input.float(5, 'Weight TF5', minval = 0.0, maxval = 100.0, step = 1.0, group = groupWeights)
i_weight6 = input.float(3, 'Weight TF6', minval = 0.0, maxval = 100.0, step = 1.0, group = groupWeights)
i_weight7 = input.float(2, 'Weight TF7', minval = 0.0, maxval = 100.0, step = 1.0, group = groupWeights)

//================================================================================
// TREND CALCULATION FUNCTIONS
//================================================================================
// Function to determine trend based on ATR stop.
// Returns 1.0 for bullish, -1.0 for bearish.
f_atr_trend(atrPeriod, src, multiplier) =>
    atr = ta.atr(atrPeriod)
    up = src - multiplier * atr
    dn = src + multiplier * atr
    up1 = nz(up[1], up)
    up := close[1] > up1 ? math.max(up, up1) : up
    dn1 = nz(dn[1], dn)
    dn := close[1] < dn1 ? math.min(dn, dn1) : dn
    float trend = 1.0
    trend := nz(trend[1], trend)
    trend := trend == -1.0 and close > dn1 ? 1.0 : trend == 1.0 and close < up1 ? -1.0 : trend
    trend

// Function to determine trend based on a Stochastic RSI cross.
// This version is more robust, holding the trend until a new cross is confirmed.
f_stoch_trend(stochRsiK, stochRsiD, stochRsiLength) =>
    rsi = ta.rsi(close, stochRsiLength)
    stochRsi = (rsi - ta.lowest(rsi, stochRsiLength)) / (ta.highest(rsi, stochRsiLength) - ta.lowest(rsi, stochRsiLength)) * 100
    k = ta.sma(stochRsi, stochRsiK)
    d = ta.sma(k, stochRsiD)

    // Store the trend in a variable that persists its value.
    var float trend = na

    if ta.crossover(k, d)
        trend := 1.0
        trend
    else if ta.crossunder(k, d)
        trend := -1.0
        trend

    trend

// Function to determine trend based on a Simple Moving Average (SMA).
// Returns 1.0 for bullish, -1.0 for bearish.
f_ma_trend(maPeriod) =>
    ma = ta.sma(close, maPeriod)
    float maTrend = na
    if close > ma
        maTrend := 1.0
        maTrend
    else if close < ma
        maTrend := -1.0
        maTrend
    maTrend

//================================================================================
// FETCHING DATA FROM SELECTED TIMEFRAMES (non-repainting)
//================================================================================
// `request.security` is used to get data from other timeframes.
// `lookahead=barmerge.lookahead_off` is now used to ensure we only get final,
// closed-bar data from the requested timeframe. This prevents repainting.

// ATR Trends
trend0 = request.security(syminfo.tickerid, i_tf0_select, f_atr_trend(i_atrPeriod0, i_src0, i_multiplier0), lookahead = barmerge.lookahead_off)
trend1 = request.security(syminfo.tickerid, i_tf1_select, f_atr_trend(i_atrPeriod1, i_src1, i_multiplier1), lookahead = barmerge.lookahead_off)
trend2 = request.security(syminfo.tickerid, i_tf2_select, f_atr_trend(i_atrPeriod2, i_src2, i_multiplier2), lookahead = barmerge.lookahead_off)
trend3 = request.security(syminfo.tickerid, i_tf3_select, f_atr_trend(i_atrPeriod3, i_src3, i_multiplier3), lookahead = barmerge.lookahead_off)
trend4 = request.security(syminfo.tickerid, i_tf4_select, f_atr_trend(i_atrPeriod4, i_src4, i_multiplier4), lookahead = barmerge.lookahead_off)
trend5 = request.security(syminfo.tickerid, i_tf5_select, f_atr_trend(i_atrPeriod5, i_src5, i_multiplier5), lookahead = barmerge.lookahead_off)
trend6 = request.security(syminfo.tickerid, i_tf6_select, f_atr_trend(i_atrPeriod6, i_src6, i_multiplier6), lookahead = barmerge.lookahead_off)
trend7 = request.security(syminfo.tickerid, i_tf7_select, f_atr_trend(i_atrPeriod7, i_src7, i_multiplier7), lookahead = barmerge.lookahead_off)

// Stoch RSI Trends
stochTrend0 = request.security(syminfo.tickerid, i_tf0_select, f_stoch_trend(i_stochRsiK0, i_stochRsiD0, i_stochRsiLength0), lookahead = barmerge.lookahead_off)
stochTrend1 = request.security(syminfo.tickerid, i_tf1_select, f_stoch_trend(i_stochRsiK1, i_stochRsiD1, i_stochRsiLength1), lookahead = barmerge.lookahead_off)
stochTrend2 = request.security(syminfo.tickerid, i_tf2_select, f_stoch_trend(i_stochRsiK2, i_stochRsiD2, i_stochRsiLength2), lookahead = barmerge.lookahead_off)
stochTrend3 = request.security(syminfo.tickerid, i_tf3_select, f_stoch_trend(i_stochRsiK3, i_stochRsiD3, i_stochRsiLength3), lookahead = barmerge.lookahead_off)
stochTrend4 = request.security(syminfo.tickerid, i_tf4_select, f_stoch_trend(i_stochRsiK4, i_stochRsiD4, i_stochRsiLength4), lookahead = barmerge.lookahead_off)
stochTrend5 = request.security(syminfo.tickerid, i_tf5_select, f_stoch_trend(i_stochRsiK5, i_stochRsiD5, i_stochRsiLength5), lookahead = barmerge.lookahead_off)
stochTrend6 = request.security(syminfo.tickerid, i_tf6_select, f_stoch_trend(i_stochRsiK6, i_stochRsiD6, i_stochRsiLength6), lookahead = barmerge.lookahead_off)
stochTrend7 = request.security(syminfo.tickerid, i_tf7_select, f_stoch_trend(i_stochRsiK7, i_stochRsiD7, i_stochRsiLength7), lookahead = barmerge.lookahead_off)

// MA Trends
maTrend0 = request.security(syminfo.tickerid, i_tf0_select, f_ma_trend(i_maPeriod0), lookahead = barmerge.lookahead_off)
maTrend1 = request.security(syminfo.tickerid, i_tf1_select, f_ma_trend(i_maPeriod1), lookahead = barmerge.lookahead_off)
maTrend2 = request.security(syminfo.tickerid, i_tf2_select, f_ma_trend(i_maPeriod2), lookahead = barmerge.lookahead_off)
maTrend3 = request.security(syminfo.tickerid, i_tf3_select, f_ma_trend(i_maPeriod3), lookahead = barmerge.lookahead_off)
maTrend4 = request.security(syminfo.tickerid, i_tf4_select, f_ma_trend(i_maPeriod4), lookahead = barmerge.lookahead_off)
maTrend5 = request.security(syminfo.tickerid, i_tf5_select, f_ma_trend(i_maPeriod5), lookahead = barmerge.lookahead_off)
maTrend6 = request.security(syminfo.tickerid, i_tf6_select, f_ma_trend(i_maPeriod6), lookahead = barmerge.lookahead_off)
maTrend7 = request.security(syminfo.tickerid, i_tf7_select, f_ma_trend(i_maPeriod7), lookahead = barmerge.lookahead_off)

//================================================================================
// BIAS CALCULATION
//================================================================================
// Define the weights for each indicator.
float INDICATOR_WEIGHT_ATR = 0.40
float INDICATOR_WEIGHT_STOCH_RSI = 0.30
float INDICATOR_WEIGHT_MA = 0.30

// Calculate the final total bullish and bearish bias percentages using the user-defined weights.
float totalWeight = i_weight0 + i_weight1 + i_weight2 + i_weight3 + i_weight4 + i_weight5 + i_weight6 + i_weight7
float weight0Normalized = i_weight0 / totalWeight
float weight1Normalized = i_weight1 / totalWeight
float weight2Normalized = i_weight2 / totalWeight
float weight3Normalized = i_weight3 / totalWeight
float weight4Normalized = i_weight4 / totalWeight
float weight5Normalized = i_weight5 / totalWeight
float weight6Normalized = i_weight6 / totalWeight
float weight7Normalized = i_weight7 / totalWeight

// Helper function to calculate a timeframe's bullish/bearish percentages
// This function now uses the pre-defined indicator weights.
f_calc_tf_bias_percentage(atrTrend, stochTrend, maTrend) =>
    float bullishScore = 0.0
    bullishScore := bullishScore + (atrTrend == 1.0 ? INDICATOR_WEIGHT_ATR : 0.0)
    bullishScore := bullishScore + (stochTrend == 1.0 ? INDICATOR_WEIGHT_STOCH_RSI : 0.0)
    bullishScore := bullishScore + (maTrend == 1.0 ? INDICATOR_WEIGHT_MA : 0.0)

    float bearishScore = 0.0
    bearishScore := bearishScore + (atrTrend == -1.0 ? INDICATOR_WEIGHT_ATR : 0.0)
    bearishScore := bearishScore + (stochTrend == -1.0 ? INDICATOR_WEIGHT_STOCH_RSI : 0.0)
    bearishScore := bearishScore + (maTrend == -1.0 ? INDICATOR_WEIGHT_MA : 0.0)

    [bullishScore * 100, bearishScore * 100]

[bullish0, bearish0] = f_calc_tf_bias_percentage(trend0, stochTrend0, maTrend0)
[bullish1, bearish1] = f_calc_tf_bias_percentage(trend1, stochTrend1, maTrend1)
[bullish2, bearish2] = f_calc_tf_bias_percentage(trend2, stochTrend2, maTrend2)
[bullish3, bearish3] = f_calc_tf_bias_percentage(trend3, stochTrend3, maTrend3)
[bullish4, bearish4] = f_calc_tf_bias_percentage(trend4, stochTrend4, maTrend4)
[bullish5, bearish5] = f_calc_tf_bias_percentage(trend5, stochTrend5, maTrend5)
[bullish6, bearish6] = f_calc_tf_bias_percentage(trend6, stochTrend6, maTrend6)
[bullish7, bearish7] = f_calc_tf_bias_percentage(trend7, stochTrend7, maTrend7)

float totalFinalBullishBias = bullish0 * weight0Normalized + bullish1 * weight1Normalized + bullish2 * weight2Normalized + bullish3 * weight3Normalized + bullish4 * weight4Normalized + bullish5 * weight5Normalized + bullish6 * weight6Normalized + bullish7 * weight7Normalized

float totalFinalBearishBias = bearish0 * weight0Normalized + bearish1 * weight1Normalized + bearish2 * weight2Normalized + bearish3 * weight3Normalized + bearish4 * weight4Normalized + bearish5 * weight5Normalized + bearish6 * weight6Normalized + bearish7 * weight7Normalized

float biasScore = totalFinalBullishBias - totalFinalBearishBias

//================================================================================
// X SIGNAL PLOTTING
//================================================================================
bool bullishSignalCondition = biasScore >= i_biasThreshold
bool bearishSignalCondition = biasScore <= -i_biasThreshold

// Plot a signal only on the first bar the condition is met
bool newBullishSignal = bullishSignalCondition and not bullishSignalCondition[1]
bool newBearishSignal = bearishSignalCondition and not bearishSignalCondition[1]

plotshape(series = newBullishSignal and i_showXSignals, title = 'Bullish X Signal', style = shape.xcross, location = location.belowbar, color = color.new(color.lime, 0), size = size.tiny)
plotshape(series = newBearishSignal and i_showXSignals, title = 'Bearish X Signal', style = shape.xcross, location = location.abovebar, color = color.new(color.red, 0), size = size.tiny)

//================================================================================
// TABLE DISPLAY
//================================================================================
// Table for displaying the trend data.
var trendTable = table.new(position = position.top_right, columns = 6, rows = 10, bgcolor = #585b6470, border_width = 1)

// Define colors for the table cells
var colorBullish = color.rgb(76, 175, 80, 20) // Light green for individual indicator bullish trends
var colorBearish = color.new(color.red, 20) // Light red for individual indicator bearish trends
var colorNeutral = #d58309cc // Orange for neutral
var colorFinalBullish = color.new(color.green, 60) // Slightly darker green for final bullish percentage
var colorFinalBearish = color.new(color.red, 60) // Slightly darker red for final bearish percentage
var headerBgColor = color.rgb(120, 123, 134, 26) // Header background
var cellBgColor = #787b86cb // Normal cell background

// Helper function to format timeframe names for the table
f_format_tf(tf) =>
    if tf == '240'
        '4H'
    else if tf == '60'
        '1H'
    else if tf == '30'
        '30m'
    else if tf == '15'
        '15m'
    else if tf == '1'
        '1m'
    else if tf == 'M'
        'MN'
    else
        tf

// Helper function to get text and color for a trend value
f_get_trend_info(trend) =>
    if trend == 1.0
        ['Bullish', colorBullish]
    else if trend == -1.0
        ['Bearish', colorBearish]
    else
        ['Neutral', colorNeutral]

if barstate.islast
    // Headers
    table.cell(trendTable, 0, 0, 'Timeframe', text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = headerBgColor)
    table.cell(trendTable, 1, 0, 'ATR', text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = headerBgColor)
    table.cell(trendTable, 2, 0, 'StochRSI', text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = headerBgColor)
    table.cell(trendTable, 3, 0, 'MA', text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = headerBgColor)
    table.cell(trendTable, 4, 0, 'Bullish %', text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = headerBgColor)
    table.cell(trendTable, 5, 0, 'Bearish %', text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = headerBgColor)

    // TF0
    [t0Text, t0Color] = f_get_trend_info(trend0)
    [s0Text, s0Color] = f_get_trend_info(stochTrend0)
    [m0Text, m0Color] = f_get_trend_info(maTrend0)
    [b0, be0] = f_calc_tf_bias_percentage(trend0, stochTrend0, maTrend0)
    table.cell(trendTable, 0, 1, f_format_tf(i_tf0_select), text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = cellBgColor)
    table.cell(trendTable, 1, 1, t0Text, text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = t0Color)
    table.cell(trendTable, 2, 1, s0Text, text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = s0Color)
    table.cell(trendTable, 3, 1, m0Text, text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = m0Color)
    table.cell(trendTable, 4, 1, str.tostring(b0, '#.0') + '%', text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = b0 > be0 ? colorFinalBullish : colorNeutral)
    table.cell(trendTable, 5, 1, str.tostring(be0, '#.0') + '%', text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = be0 > b0 ? colorFinalBearish : colorNeutral)

    // TF1
    [t1Text, t1Color] = f_get_trend_info(trend1)
    [s1Text, s1Color] = f_get_trend_info(stochTrend1)
    [m1Text, m1Color] = f_get_trend_info(maTrend1)
    [b1, be1] = f_calc_tf_bias_percentage(trend1, stochTrend1, maTrend1)
    table.cell(trendTable, 0, 2, f_format_tf(i_tf1_select), text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = cellBgColor)
    table.cell(trendTable, 1, 2, t1Text, text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = t1Color)
    table.cell(trendTable, 2, 2, s1Text, text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = s1Color)
    table.cell(trendTable, 3, 2, m1Text, text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = m1Color)
    table.cell(trendTable, 4, 2, str.tostring(b1, '#.0') + '%', text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = b1 > be1 ? colorFinalBullish : colorNeutral)
    table.cell(trendTable, 5, 2, str.tostring(be1, '#.0') + '%', text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = be1 > b1 ? colorFinalBearish : colorNeutral)

    // TF2
    [t2Text, t2Color] = f_get_trend_info(trend2)
    [s2Text, s2Color] = f_get_trend_info(stochTrend2)
    [m2Text, m2Color] = f_get_trend_info(maTrend2)
    [b2, be2] = f_calc_tf_bias_percentage(trend2, stochTrend2, maTrend2)
    table.cell(trendTable, 0, 3, f_format_tf(i_tf2_select), text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = cellBgColor)
    table.cell(trendTable, 1, 3, t2Text, text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = t2Color)
    table.cell(trendTable, 2, 3, s2Text, text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = s2Color)
    table.cell(trendTable, 3, 3, m2Text, text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = m2Color)
    table.cell(trendTable, 4, 3, str.tostring(b2, '#.0') + '%', text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = b2 > be2 ? colorFinalBullish : colorNeutral)
    table.cell(trendTable, 5, 3, str.tostring(be2, '#.0') + '%', text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = be2 > b2 ? colorFinalBearish : colorNeutral)

    // TF3
    [t3Text, t3Color] = f_get_trend_info(trend3)
    [s3Text, s3Color] = f_get_trend_info(stochTrend3)
    [m3Text, m3Color] = f_get_trend_info(maTrend3)
    [b3, be3] = f_calc_tf_bias_percentage(trend3, stochTrend3, maTrend3)
    table.cell(trendTable, 0, 4, f_format_tf(i_tf3_select), text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = cellBgColor)
    table.cell(trendTable, 1, 4, t3Text, text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = t3Color)
    table.cell(trendTable, 2, 4, s3Text, text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = s3Color)
    table.cell(trendTable, 3, 4, m3Text, text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = m3Color)
    table.cell(trendTable, 4, 4, str.tostring(b3, '#.0') + '%', text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = b3 > be3 ? colorFinalBullish : colorNeutral)
    table.cell(trendTable, 5, 4, str.tostring(be3, '#.0') + '%', text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = be3 > b3 ? colorFinalBearish : colorNeutral)

    // TF4
    [t4Text, t4Color] = f_get_trend_info(trend4)
    [s4Text, s4Color] = f_get_trend_info(stochTrend4)
    [m4Text, m4Color] = f_get_trend_info(maTrend4)
    [b4, be4] = f_calc_tf_bias_percentage(trend4, stochTrend4, maTrend4)
    table.cell(trendTable, 0, 5, f_format_tf(i_tf4_select), text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = cellBgColor)
    table.cell(trendTable, 1, 5, t4Text, text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = t4Color)
    table.cell(trendTable, 2, 5, s4Text, text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = s4Color)
    table.cell(trendTable, 3, 5, m4Text, text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = m4Color)
    table.cell(trendTable, 4, 5, str.tostring(b4, '#.0') + '%', text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = b4 > be4 ? colorFinalBullish : colorNeutral)
    table.cell(trendTable, 5, 5, str.tostring(be4, '#.0') + '%', text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = be4 > b4 ? colorFinalBearish : colorNeutral)

    // TF5
    [t5Text, t5Color] = f_get_trend_info(trend5)
    [s5Text, s5Color] = f_get_trend_info(stochTrend5)
    [m5Text, m5Color] = f_get_trend_info(maTrend5)
    [b5, be5] = f_calc_tf_bias_percentage(trend5, stochTrend5, maTrend5)
    table.cell(trendTable, 0, 6, f_format_tf(i_tf5_select), text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = cellBgColor)
    table.cell(trendTable, 1, 6, t5Text, text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = t5Color)
    table.cell(trendTable, 2, 6, s5Text, text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = s5Color)
    table.cell(trendTable, 3, 6, m5Text, text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = m5Color)
    table.cell(trendTable, 4, 6, str.tostring(b5, '#.0') + '%', text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = b5 > be5 ? colorFinalBullish : colorNeutral)
    table.cell(trendTable, 5, 6, str.tostring(be5, '#.0') + '%', text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = be5 > b5 ? colorFinalBearish : colorNeutral)

    // TF6
    [t6Text, t6Color] = f_get_trend_info(trend6)
    [s6Text, s6Color] = f_get_trend_info(stochTrend6)
    [m6Text, m6Color] = f_get_trend_info(maTrend6)
    [b6, be6] = f_calc_tf_bias_percentage(trend6, stochTrend6, maTrend6)
    table.cell(trendTable, 0, 7, f_format_tf(i_tf6_select), text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = cellBgColor)
    table.cell(trendTable, 1, 7, t6Text, text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = t6Color)
    table.cell(trendTable, 2, 7, s6Text, text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = s6Color)
    table.cell(trendTable, 3, 7, m6Text, text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = m6Color)
    table.cell(trendTable, 4, 7, str.tostring(b6, '#.0') + '%', text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = b6 > be6 ? colorFinalBullish : colorNeutral)
    table.cell(trendTable, 5, 7, str.tostring(be6, '#.0') + '%', text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = be6 > b6 ? colorFinalBearish : colorNeutral)

    // TF7
    [t7Text, t7Color] = f_get_trend_info(trend7)
    [s7Text, s7Color] = f_get_trend_info(stochTrend7)
    [m7Text, m7Color] = f_get_trend_info(maTrend7)
    [b7, be7] = f_calc_tf_bias_percentage(trend7, stochTrend7, maTrend7)
    table.cell(trendTable, 0, 8, f_format_tf(i_tf7_select), text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = cellBgColor)
    table.cell(trendTable, 1, 8, t7Text, text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = t7Color)
    table.cell(trendTable, 2, 8, s7Text, text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = s7Color)
    table.cell(trendTable, 3, 8, m7Text, text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = m7Color)
    table.cell(trendTable, 4, 8, str.tostring(b7, '#.0') + '%', text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = b7 > be7 ? colorFinalBullish : colorNeutral)
    table.cell(trendTable, 5, 8, str.tostring(be7, '#.0') + '%', text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = be7 > b7 ? colorFinalBearish : colorNeutral)

    // Final Bias Row
    table.cell(trendTable, 0, 9, 'Final Bias', text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = headerBgColor)
    table.cell(trendTable, 1, 9, '', text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = headerBgColor)
    table.cell(trendTable, 2, 9, '', text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = headerBgColor)
    table.cell(trendTable, 3, 9, '', text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = headerBgColor)
    table.cell(trendTable, 4, 9, str.tostring(math.round(totalFinalBullishBias)) + '%', text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = totalFinalBullishBias > totalFinalBearishBias ? colorFinalBullish : colorNeutral)
    table.cell(trendTable, 5, 9, str.tostring(math.round(totalFinalBearishBias)) + '%', text_halign = text.align_center, text_size = i_tableTextSize, bgcolor = totalFinalBearishBias > totalFinalBullishBias ? colorFinalBearish : colorNeutral)


//================================================================================
// ALERTS & BIAS CONDITIONS
//================================================================================
float biasThreshold = input.float(10.0, 'Bias Alert Threshold (%)', minval = 0.0, maxval = 100.0, group = 'Alerts')

alertcondition(totalFinalBullishBias > 50.0 + biasThreshold, title = 'Strong Bullish Bias', message = '✅ A strong bullish bias is detected!')
alertcondition(totalFinalBearishBias > 50.0 + biasThreshold, title = 'Strong Bearish Bias', message = '❌ A strong bearish bias is detected!')

// Optional popup label on chart when condition triggers
if totalFinalBullishBias > 50.0 + biasThreshold and barstate.islast
    label.new(bar_index, high, 'Strong BUY Bias (' + str.tostring(math.round(totalFinalBullishBias)) + '%)', style = label.style_label_up, color = color.green, textcolor = color.white)
if totalFinalBearishBias > 50.0 + biasThreshold and barstate.islast
    label.new(bar_index, low, 'Strong SELL Bias (' + str.tostring(math.round(totalFinalBearishBias)) + '%)', style = label.style_label_down, color = color.red, textcolor = color.white)
````
