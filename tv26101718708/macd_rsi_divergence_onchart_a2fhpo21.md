# MACD & RSI Divergence (ON-CHART)

- url: https://www.tradingview.com/script/A2fHPO21-MACD-RSI-Divergence-ON-CHART/
- type: indicator
- pine_id: PUB;0bc405b9be214512920cbe5a2c1c51d9
- version: 1.0

## Description

*MACD & RSI Divergence (On-Chart Overlay) — Pro Signal Visualization Layer**

This is a companion overlay designed for the **MACD & RSI Divergence Pro system**, built to project divergence signals directly onto the price chart for cleaner execution and faster decision-making.

It does not calculate indicators independently—instead, it acts as a **visual mapping layer**, synchronising with the main divergence engine.

---

### 🔍 Core Purpose

This script enhances trade clarity by displaying:

* MACD divergence signals on price action
* RSI divergence signals on price action
* Swing structure counts for momentum tracking
* Visual divergence confirmation lines

It transforms oscillator-based signals into **actionable chart-level events**.

---

### 📊 Key Features

• **On-Chart Divergence Mapping**

* MACD bullish & bearish divergences
* RSI bullish & bearish divergences
* Regular and hidden structure signals

• **Multi-Signal Integration**

* Combines MACD + RSI logic into one visual layer
* Separates momentum vs structure divergence
* Highlights high-confidence confluence zones

• **Swing Count Tracking**

* MACD swing progression counter
* StochRSI momentum swing tracking
* Helps identify trend exhaustion phases

• **Divergence Line Visualization**

* Connects pivot highs and lows
* Shows structural divergence clearly on price
* Enhances pattern recognition and confirmation

• **Execution-Focused Design**

* No oscillator clutter
* Clean price-based signal presentation
* Built for fast decision-making environments

---

### 📊 How to Use

**Bullish Divergence**

* Price forms lower low
* RSI / MACD forms higher low
→ Potential reversal or continuation upward

**Bearish Divergence**

* Price forms higher high
* RSI / MACD forms lower high
→ Potential reversal or continuation downward

**Confluence Zones**

* When MACD + RSI divergences align
→ Higher probability setup

---

### ⚠️ Important Notes

* This is a **companion overlay**, not a standalone system
* Best used alongside the main “MACD & RSI Divergence Pro” indicator
* Signals gain strength when multiple divergences align

---

### 🚀 Ideal For

* Advanced divergence traders
* Smart money / structure-based trading
* Scalpers and intraday traders
* Traders who need visual confirmation on price

---

### 🧠 Trading Philosophy

**Oscillators generate signals.
Price confirms intent.
This tool bridges the two.**

---

**See divergence where it actually matters — on price.**

## Source Code

````pine
//@version=6
// This is an overlay companion script for the "MACD & RSI Divergence Indicator (Pro)".
// It is designed to be used in tandem with the main indicator to display divergence signals and swing counts directly on the price chart.
// It will not plot any MACD or RSI lines itself, only the visual signals.
indicator(title = 'MACD & RSI Divergence (onchart)', overlay = true)

// ------------------------------------------------------------------------------
// General & Global Settings (Must match the main indicator's settings)
// ------------------------------------------------------------------------------
groupGeneral = 'General Settings'
lbL = input.int(title = 'Pivot Lookback Left', defval = 5, group = groupGeneral, tooltip = 'Number of bars to the left of a potential pivot to confirm it.')
lbR = input.int(title = 'Pivot Lookback Right', defval = 5, group = groupGeneral, tooltip = 'Number of bars to the right of a potential pivot to confirm it.')
rangeUpper = input.int(title = 'Max Lookback Range', defval = 60, group = groupGeneral, tooltip = 'The maximum number of bars a valid divergence can span.')
rangeLower = input.int(title = 'Min Lookback Range', defval = 5, group = groupGeneral, tooltip = 'The minimum number of bars a valid divergence can span.')

// ------------------------------------------------------------------------------
// MACD Settings (Must match the main indicator's settings)
// ------------------------------------------------------------------------------
groupMacd = 'MACD Settings'
plotMacdSwings = input.bool(title = 'Plot MACD Swing Counts', defval = true, group = groupMacd, tooltip = 'Enable or disable the visual plotting of MACD swing numbers on the chart.')
fast_length = input.int(title = 'Fast MA Length', defval = 12, group = groupMacd, tooltip = 'The period for the faster moving average in the MACD calculation.')
slow_length = input.int(title = 'Slow MA Length', defval = 26, group = groupMacd, tooltip = 'The period for the slower moving average in the MACD calculation.')
signal_length = input.int(title = 'Signal Line Smoothing', minval = 1, maxval = 50, defval = 9, group = groupMacd, tooltip = 'The period used to smooth the MACD line to create the signal line.')
srcMacd = input(title = 'MACD Source', defval = close, group = groupMacd, tooltip = 'The source series (e.g., \'close\') for the MACD calculation.')
sma_source = input.string(title = 'Oscillator MA Type', defval = 'EMA', options = ['SMA', 'EMA'], group = groupMacd, tooltip = 'Choose between Simple Moving Average (SMA) or Exponential Moving Average (EMA) for the MACD oscillator.')
sma_signal = input.string(title = 'Signal Line MA Type', defval = 'EMA', options = ['SMA', 'EMA'], group = groupMacd, tooltip = 'Choose between Simple Moving Average (SMA) or Exponential Moving Average (EMA) for the signal line.')
tfMacd = input.timeframe(title = 'MACD Timeframe', defval = '', group = groupMacd, tooltip = 'Leave blank for the current chart\'s timeframe. Enter a specific timeframe like \'1D\' or \'4H\'.')

// ------------------------------------------------------------------------------
// MACD Divergence Settings (Must match the main indicator's settings)
// ------------------------------------------------------------------------------
groupMacdDiv = 'MACD Divergence Settings'
plotMacdDivergence = input.bool(title = 'Plot MACD Divergence', defval = true, group = groupMacdDiv, tooltip = 'Enable or disable all MACD divergence signals.')
divergenceSource = input.string(title = 'Divergence Source', defval = 'Both', options = ['MACD Line', 'Histogram', 'Both'], group = groupMacdDiv, tooltip = 'Detect divergence on the MACD line, histogram, or both.')
plotRegularBullMacd = input.bool(title = 'Plot Regular Bullish', defval = true, group = groupMacdDiv, tooltip = 'Enable/disable plotting for regular bullish MACD divergence.')
plotHiddenBullMacd = input.bool(title = 'Plot Hidden Bullish', defval = true, group = groupMacdDiv, tooltip = 'Enable/disable plotting for hidden bullish MACD divergence.')
plotRegularBearMacd = input.bool(title = 'Plot Regular Bearish', defval = true, group = groupMacdDiv, tooltip = 'Enable/disable plotting for regular bearish MACD divergence.')
plotHiddenBearMacd = input.bool(title = 'Plot Hidden Bearish', defval = true, group = groupMacdDiv, tooltip = 'Enable/disable plotting for hidden bearish MACD divergence.')
filterDivergenceAtZero = input.bool(title = 'Filter Divergence at Zero', defval = true, group = groupMacdDiv, tooltip = 'Bullish signals only below zero, bearish above zero. Applies to MACD histogram only.')
plotMacdLines = input.bool(title = 'Plot Divergence Lines', defval = true, group = groupMacdDiv, tooltip = 'Draws lines connecting the pivots on both price and MACD for visual confirmation.')

// ------------------------------------------------------------------------------
// StochRSI Swing Count Settings (Must match the main indicator's settings)
// ------------------------------------------------------------------------------
groupStoch = 'StochRSI Swing Count'
plotStochSwings = input.bool(title = 'Plot StochRSI Swing Counts', defval = true, group = groupStoch, tooltip = 'Enable or disable the visual plotting of StochRSI swing numbers on the chart.')
lenStoch = input.int(title = 'StochRSI Period', defval = 14, group = groupStoch, tooltip = 'The period used for the StochRSI calculation.')
k = input.int(title = '%K Smoothing', defval = 3, group = groupStoch, tooltip = 'The smoothing period for the StochRSI %K line.')
d = input.int(title = '%D Smoothing', defval = 3, group = groupStoch, tooltip = 'The smoothing period for the StochRSI %D line.')
stochSwingSpacingFactor = input.float(title = 'StochRSI Swing Count Spacing Factor', defval = 4.0, group = groupStoch, tooltip = 'Adjusts the vertical distance of the StochRSI swing numbers from the high/low of the bar. A higher number increases the distance.')
tfStoch = input.timeframe(title = 'StochRSI Timeframe', defval = '', group = groupStoch, tooltip = 'Leave blank for the current chart\'s timeframe.')

// ------------------------------------------------------------------------------
// RSI Divergence Settings (Must match the main indicator's settings)
// ------------------------------------------------------------------------------
groupRsi = 'RSI Divergence Settings'
lenRsi = input.int(title = 'RSI Period', minval = 1, defval = 14, group = groupRsi, tooltip = 'The period for the RSI calculation.')
srcRsi = input(title = 'RSI Source', defval = close, group = groupRsi, tooltip = 'The source series for the RSI calculation.')
plotRsiDivergence = input.bool(title = 'Plot RSI Divergence', defval = true, group = groupRsi, tooltip = 'Enable or disable all RSI divergence signals.')
plotRegularBullRsi = input.bool(title = 'Plot Regular Bullish', defval = true, group = groupRsi, tooltip = 'Enable/disable plotting for regular bullish RSI divergence.')
plotHiddenBullRsi = input.bool(title = 'Plot Hidden Bullish', defval = true, group = groupRsi, tooltip = 'Enable/disable plotting for hidden bullish RSI divergence.')
plotRegularBearRsi = input.bool(title = 'Plot Regular Bearish', defval = true, group = groupRsi, tooltip = 'Enable/disable plotting for regular bearish RSI divergence.')
plotHiddenBearRsi = input.bool(title = 'Plot Hidden Bearish', defval = true, group = groupRsi, tooltip = 'Enable/disable plotting for hidden bearish RSI divergence.')
plotRsiLines = input.bool(title = 'Plot Divergence Lines', defval = true, group = groupRsi, tooltip = 'Draws lines connecting the pivots on both price and RSI for visual confirmation.')
tfRsi = input.timeframe(title = 'RSI Divergence Timeframe', defval = '', group = groupRsi, tooltip = 'Leave blank for the current chart\'s timeframe.')


// ------------------------------------------------------------------------------
// Appearance & Colors (Must match the main indicator's settings)
// ------------------------------------------------------------------------------
groupColors = 'Appearance'
plotSignalAs = input.string(title = 'Signal Plot Style', defval = 'Labels', options = ['Arrows', 'Labels', 'None'], group = groupColors, tooltip = 'Choose how divergence signals are displayed on the chart.')
macdLineBullishColor = input.color(color.new(color.green, 0), 'MACD Line Bullish Color', group = groupColors)
macdLineBearishColor = input.color(color.new(color.red, 0), 'MACD Line Bearish Color', group = groupColors)
macdHistBullishColor = input.color(color.new(color.green, 20), 'MACD Hist Bullish Color', group = groupColors)
macdHistBearishColor = input.color(color.new(color.red, 20), 'MACD Hist Bearish Color', group = groupColors)
macdBullSwingColor = input.color(color.new(color.lime, 0), 'MACD Bullish Swing Color', group = groupColors)
macdBearSwingColor = input.color(color.new(color.red, 0), 'MACD Bearish Swing Color', group = groupColors)
stochBullSwingColor = input.color(color.new(color.blue, 0), 'StochRSI Bullish Swing Color', group = groupStoch)
stochBearSwingColor = input.color(color.new(color.orange, 0), 'StochRSI Bearish Swing Color', group = groupStoch)
rsiBullColor = input.color(color.new(color.green, 0), 'RSI Regular Bullish Color', group = groupRsi)
rsiBearColor = input.color(color.new(color.red, 0), 'RSI Regular Bearish Color', group = groupRsi)
rsiHiddenBullColor = input.color(color.new(color.green, 80), 'RSI Hidden Bullish Color', group = groupRsi)
rsiHiddenBearColor = input.color(color.new(color.red, 80), 'RSI Hidden Bearish Color', group = groupRsi)
textColor = input.color(color.white, 'Label Text Color', group = groupColors)


// ------------------------------------------------------------------------------
// MACD & RSI Calculation Functions
// ------------------------------------------------------------------------------
// Function to calculate MACD on a specified timeframe
calcMacd() =>
    fast_ma = sma_source == 'SMA' ? ta.sma(srcMacd, fast_length) : ta.ema(srcMacd, fast_length)
    slow_ma = sma_source == 'SMA' ? ta.sma(srcMacd, slow_length) : ta.ema(srcMacd, slow_length)
    macd_val = fast_ma - slow_ma
    signal_val = sma_signal == 'SMA' ? ta.sma(macd_val, signal_length) : ta.ema(macd_val, signal_length)
    hist_val = macd_val - signal_val
    [macd_val, signal_val, hist_val]

// Function to calculate StochRsi on a specified timeframe
calcStochRsi() =>
    rsi_val = ta.rsi(srcMacd, lenStoch)
    stochK_val = ta.sma(ta.stoch(rsi_val, rsi_val, rsi_val, lenStoch), k)
    stochD_val = ta.sma(stochK_val, d)
    [stochK_val, stochD_val]

// Function to calculate RSI on a specified timeframe
calcRsi() =>
    ta.rsi(srcRsi, lenRsi)


// ------------------------------------------------------------------------------
// Main Indicator Body
// ------------------------------------------------------------------------------
// Retrieve indicator values from the specified timeframes
[macd, signal, hist] = request.security(syminfo.tickerid, tfMacd, calcMacd(), lookahead = barmerge.lookahead_on)
[stochK, stochD] = request.security(syminfo.tickerid, tfStoch, calcStochRsi(), lookahead = barmerge.lookahead_on)
oscRsi = request.security(syminfo.tickerid, tfRsi, calcRsi(), lookahead = barmerge.lookahead_on)
low_mtf = request.security(syminfo.tickerid, tfMacd, low, lookahead = barmerge.lookahead_on)
high_mtf = request.security(syminfo.tickerid, tfMacd, high, lookahead = barmerge.lookahead_on)


// ------------------------------------------------------------------------------
// Divergence Detection & Plotting
// ------------------------------------------------------------------------------
// Helper function to check if a pivot is within the specified lookback range
_inRange(cond) =>
    bars = ta.barssince(cond == true)
    rangeLower <= bars and bars <= rangeUpper

// --- MACD Divergence Detection
macdPlFound = na(ta.pivotlow(macd, lbL, lbR)) ? false : true
macdPhFound = na(ta.pivothigh(macd, lbL, lbR)) ? false : true
histPlFound = na(ta.pivotlow(hist, lbL, lbR)) ? false : true
histPhFound = na(ta.pivothigh(hist, lbL, lbR)) ? false : true

// Regular Bullish Divergence on MACD Line
line_bull_cond = plotRegularBullMacd and (divergenceSource == 'MACD Line' or divergenceSource == 'Both') and low_mtf[lbR] < ta.valuewhen(macdPlFound, low_mtf[lbR], 1) and macd[lbR] > ta.valuewhen(macdPlFound, macd[lbR], 1) and _inRange(macdPlFound[1]) and macdPlFound
// Hidden Bullish Divergence on MACD Line
line_hidden_bull_cond = plotHiddenBullMacd and (divergenceSource == 'MACD Line' or divergenceSource == 'Both') and low_mtf[lbR] > ta.valuewhen(macdPlFound, low_mtf[lbR], 1) and macd[lbR] < ta.valuewhen(macdPlFound, macd[lbR], 1) and _inRange(macdPlFound[1]) and macdPlFound
// Regular Bearish Divergence on MACD Line
line_bear_cond = plotRegularBearMacd and (divergenceSource == 'MACD Line' or divergenceSource == 'Both') and high_mtf[lbR] > ta.valuewhen(macdPhFound, high_mtf[lbR], 1) and macd[lbR] < ta.valuewhen(macdPhFound, macd[lbR], 1) and _inRange(macdPhFound[1]) and macdPhFound
// Hidden Bearish Divergence on MACD Line
line_hidden_bear_cond = plotHiddenBearMacd and (divergenceSource == 'MACD Line' or divergenceSource == 'Both') and high_mtf[lbR] < ta.valuewhen(macdPhFound, high_mtf[lbR], 1) and macd[lbR] > ta.valuewhen(macdPhFound, macd[lbR], 1) and _inRange(macdPhFound[1]) and macdPhFound

// Regular Bullish Divergence on MACD Histogram
hist_bull_cond = plotRegularBullMacd and (divergenceSource == 'Histogram' or divergenceSource == 'Both') and low_mtf[lbR] < ta.valuewhen(histPlFound, low_mtf[lbR], 1) and hist[lbR] > ta.valuewhen(histPlFound, hist[lbR], 1) and _inRange(histPlFound[1]) and histPlFound and (not filterDivergenceAtZero or hist[lbR] < 0)
// Regular Bearish Divergence on MACD Histogram
hist_bear_cond = plotRegularBearMacd and (divergenceSource == 'Histogram' or divergenceSource == 'Both') and high_mtf[lbR] > ta.valuewhen(histPhFound, high_mtf[lbR], 1) and hist[lbR] < ta.valuewhen(histPhFound, hist[lbR], 1) and _inRange(histPhFound[1]) and histPhFound and (not filterDivergenceAtZero or hist[lbR] > 0)

// --- RSI Divergence Detection
plFoundRsi = na(ta.pivotlow(oscRsi, lbL, lbR)) ? false : true
phFoundRsi = na(ta.pivothigh(oscRsi, lbL, lbR)) ? false : true

// Regular Bullish RSI Divergence
rsi_bull_cond = plotRegularBullRsi and low[lbR] < ta.valuewhen(plFoundRsi, low[lbR], 1) and oscRsi[lbR] > ta.valuewhen(plFoundRsi, oscRsi[lbR], 1) and _inRange(plFoundRsi[1]) and plFoundRsi
// Hidden Bullish RSI Divergence
rsi_hidden_bull_cond = plotHiddenBullRsi and low[lbR] > ta.valuewhen(plFoundRsi, low[lbR], 1) and oscRsi[lbR] < ta.valuewhen(plFoundRsi, oscRsi[lbR], 1) and _inRange(plFoundRsi[1]) and plFoundRsi
// Regular Bearish RSI Divergence
rsi_bear_cond = plotRegularBearRsi and high[lbR] > ta.valuewhen(phFoundRsi, high[lbR], 1) and oscRsi[lbR] < ta.valuewhen(phFoundRsi, oscRsi[lbR], 1) and _inRange(phFoundRsi[1]) and phFoundRsi
// Hidden Bearish RSI Divergence
rsi_hidden_bear_cond = plotHiddenBearRsi and high[lbR] < ta.valuewhen(phFoundRsi, high[lbR], 1) and oscRsi[lbR] > ta.valuewhen(phFoundRsi, oscRsi[lbR], 1) and _inRange(phFoundRsi[1]) and phFoundRsi


// --- Plotting Logic
// MACD Divergence Plotting (Arrows or Labels)
plotshape(plotMacdDivergence and plotSignalAs == 'Arrows' and (line_bull_cond or hist_bull_cond) ? low : na, offset = -lbR, title = 'MACD Bullish', style = shape.triangleup, location = location.belowbar, color = macdLineBullishColor, size = size.small)
plotshape(plotMacdDivergence and plotSignalAs == 'Arrows' and line_hidden_bull_cond ? low : na, offset = -lbR, title = 'MACD Hidden Bullish', style = shape.triangleup, location = location.belowbar, color = macdHistBullishColor, size = size.small)
plotshape(plotMacdDivergence and plotSignalAs == 'Arrows' and (line_bear_cond or hist_bear_cond) ? high : na, offset = -lbR, title = 'MACD Bearish', style = shape.triangledown, location = location.abovebar, color = macdLineBearishColor, size = size.small)
plotshape(plotMacdDivergence and plotSignalAs == 'Arrows' and line_hidden_bear_cond ? high : na, offset = -lbR, title = 'MACD Hidden Bearish', style = shape.triangledown, location = location.abovebar, color = macdHistBearishColor, size = size.small)

plotshape(plotMacdDivergence and plotSignalAs == 'Labels' and (line_bull_cond or hist_bull_cond) ? low : na, offset = -lbR, title = 'MACD Bullish', text = 'MACD Bull', style = shape.labelup, location = location.belowbar, color = macdLineBullishColor, textcolor = textColor, size = size.small)
plotshape(plotMacdDivergence and plotSignalAs == 'Labels' and line_hidden_bull_cond ? low : na, offset = -lbR, title = 'MACD Hidden Bullish', text = 'MACD H.Bull', style = shape.labelup, location = location.belowbar, color = macdHistBullishColor, textcolor = textColor, size = size.small)
plotshape(plotMacdDivergence and plotSignalAs == 'Labels' and (line_bear_cond or hist_bear_cond) ? high : na, offset = -lbR, title = 'MACD Bearish', text = 'MACD Bear', style = shape.labeldown, location = location.abovebar, color = macdLineBearishColor, textcolor = textColor, size = size.small)
plotshape(plotMacdDivergence and plotSignalAs == 'Labels' and line_hidden_bear_cond ? high : na, offset = -lbR, title = 'MACD Hidden Bearish', text = 'MACD H.Bear', style = shape.labeldown, location = location.abovebar, color = macdHistBearishColor, textcolor = textColor, size = size.small)

// RSI Divergence Plotting (Arrows or Labels)
plotshape(plotRsiDivergence and plotSignalAs == 'Arrows' and rsi_bull_cond ? low : na, offset = -lbR, title = 'RSI Regular Bullish', style = shape.triangleup, location = location.belowbar, color = rsiBullColor, size = size.small)
plotshape(plotRsiDivergence and plotSignalAs == 'Arrows' and rsi_hidden_bull_cond ? low : na, offset = -lbR, title = 'RSI Hidden Bullish', style = shape.triangleup, location = location.belowbar, color = rsiHiddenBullColor, size = size.small)
plotshape(plotRsiDivergence and plotSignalAs == 'Arrows' and rsi_bear_cond ? high : na, offset = -lbR, title = 'RSI Regular Bearish', style = shape.triangledown, location = location.abovebar, color = rsiBearColor, size = size.small)
plotshape(plotRsiDivergence and plotSignalAs == 'Arrows' and rsi_hidden_bear_cond ? high : na, offset = -lbR, title = 'RSI Hidden Bearish', style = shape.triangledown, location = location.abovebar, color = rsiHiddenBearColor, size = size.small)

plotshape(plotRsiDivergence and plotSignalAs == 'Labels' and rsi_bull_cond ? low : na, offset = -lbR, title = 'RSI Regular Bullish', text = 'RSI Bull', style = shape.labelup, location = location.belowbar, color = rsiBullColor, textcolor = textColor, size = size.small)
plotshape(plotRsiDivergence and plotSignalAs == 'Labels' and rsi_hidden_bull_cond ? low : na, offset = -lbR, title = 'RSI Hidden Bullish', text = 'RSI H.Bull', style = shape.labelup, location = location.belowbar, color = rsiHiddenBullColor, textcolor = textColor, size = size.small)
plotshape(plotRsiDivergence and plotSignalAs == 'Labels' and rsi_hidden_bull_cond ? low : na, offset = -lbR, title = 'RSI Hidden Bullish', text = 'RSI H.Bull', style = shape.labelup, location = location.belowbar, color = rsiHiddenBullColor, textcolor = textColor, size = size.small)
plotshape(plotRsiDivergence and plotSignalAs == 'Labels' and rsi_bear_cond ? high : na, offset = -lbR, title = 'RSI Regular Bearish', text = 'RSI Bear', style = shape.labeldown, location = location.abovebar, color = rsiBearColor, textcolor = textColor, size = size.small)
plotshape(plotRsiDivergence and plotSignalAs == 'Labels' and rsi_hidden_bear_cond ? high : na, offset = -lbR, title = 'RSI Hidden Bearish', text = 'RSI H.Bear', style = shape.labeldown, location = location.abovebar, color = rsiHiddenBearColor, textcolor = textColor, size = size.small)

// ------------------------------------------------------------------------------
// MACD Swing Count Logic
// ------------------------------------------------------------------------------
var int bullish_swing_count = 0
var int bearish_swing_count = 0
bool new_bullish_swing_event = ta.crossover(macd, signal) and macd > 0
bool new_bearish_swing_event = ta.crossunder(macd, signal) and macd < 0
if new_bullish_swing_event
    bullish_swing_count := bullish_swing_count + 1
    bearish_swing_count := 0
    bearish_swing_count
else if new_bearish_swing_event
    bearish_swing_count := bearish_swing_count + 1
    bullish_swing_count := 0
    bullish_swing_count
atr = ta.atr(14)
plot_pos_bull = low - atr * 2.0
plot_pos_bear = high + atr * 2.0
bullish_text = bullish_swing_count > 5 ? '+5' : str.tostring(bullish_swing_count)
if plotMacdSwings and new_bullish_swing_event
    label.new(x = bar_index, y = plot_pos_bull, text = bullish_text, color = color.new(macdBullSwingColor, 75), style = label.style_label_up, textcolor = textColor, size = size.small, xloc = xloc.bar_index)
bearish_text = bearish_swing_count > 5 ? '+5' : str.tostring(bearish_swing_count)
if plotMacdSwings and new_bearish_swing_event
    label.new(x = bar_index, y = plot_pos_bear, text = bearish_text, color = color.new(macdBearSwingColor, 75), style = label.style_label_down, textcolor = textColor, size = size.small, xloc = xloc.bar_index)


// ------------------------------------------------------------------------------
// StochRSI Swing Count Logic
// ------------------------------------------------------------------------------
var int stoch_bullish_swing_count = 0
var int stoch_bearish_swing_count = 0
bool new_stoch_bullish_swing_event = ta.crossover(stochK, stochD) and macd > signal
bool new_stoch_bearish_swing_event = ta.crossunder(stochK, stochD) and macd < signal
if new_stoch_bullish_swing_event
    stoch_bullish_swing_count := stoch_bullish_swing_count + 1
    stoch_bearish_swing_count := 0
    stoch_bearish_swing_count
else if new_stoch_bearish_swing_event
    stoch_bearish_swing_count := stoch_bearish_swing_count + 1
    stoch_bullish_swing_count := 0
    stoch_bullish_swing_count
plot_pos_stoch_bull = low - atr * stochSwingSpacingFactor
plot_pos_stoch_bear = high + atr * stochSwingSpacingFactor
stoch_bullish_text = stoch_bullish_swing_count > 5 ? '+5' : str.tostring(stoch_bullish_swing_count)
if plotStochSwings and new_stoch_bullish_swing_event
    label.new(x = bar_index, y = plot_pos_stoch_bull, text = stoch_bullish_text, color = color.new(stochBullSwingColor, 75), style = label.style_label_up, textcolor = textColor, size = size.small, xloc = xloc.bar_index)
stoch_bearish_text = stoch_bearish_swing_count > 5 ? '+5' : str.tostring(stoch_bearish_swing_count)
if plotStochSwings and new_stoch_bearish_swing_event
    label.new(x = bar_index, y = plot_pos_stoch_bear, text = stoch_bearish_text, color = color.new(stochBearSwingColor, 75), style = label.style_label_down, textcolor = textColor, size = size.small, xloc = xloc.bar_index)


// ------------------------------------------------------------------------------
// Divergence Line Drawing Logic
// ------------------------------------------------------------------------------
// MACD Divergence Lines
line.new(x1 = plotMacdLines and (line_bull_cond or hist_bull_cond) ? int(ta.valuewhen(line_bull_cond or hist_bull_cond, bar_index[lbR], 1)) : na, y1 = plotMacdLines and (line_bull_cond or hist_bull_cond) ? ta.valuewhen(line_bull_cond or hist_bull_cond, low[lbR], 1) : na, x2 = plotMacdLines and (line_bull_cond or hist_bull_cond) ? bar_index[lbR] : na, y2 = plotMacdLines and (line_bull_cond or hist_bull_cond) ? low[lbR] : na, color = color.new(macdLineBullishColor, 20), style = line.style_dotted, width = 2)
line.new(x1 = plotMacdLines and (line_bear_cond or hist_bear_cond) ? int(ta.valuewhen(line_bear_cond or hist_bear_cond, bar_index[lbR], 1)) : na, y1 = plotMacdLines and (line_bear_cond or hist_bear_cond) ? ta.valuewhen(line_bear_cond or hist_bear_cond, high[lbR], 1) : na, x2 = plotMacdLines and (line_bear_cond or hist_bear_cond) ? bar_index[lbR] : na, y2 = plotMacdLines and (line_bear_cond or hist_bear_cond) ? high[lbR] : na, color = color.new(macdLineBearishColor, 20), style = line.style_dotted, width = 2)

// RSI Divergence Lines
line.new(x1 = plotRsiLines and (rsi_bull_cond or rsi_hidden_bull_cond) ? int(ta.valuewhen(rsi_bull_cond or rsi_hidden_bull_cond, bar_index[lbR], 1)) : na, y1 = plotRsiLines and (rsi_bull_cond or rsi_hidden_bull_cond) ? ta.valuewhen(rsi_bull_cond or rsi_hidden_bull_cond, low[lbR], 1) : na, x2 = plotRsiLines and (rsi_bull_cond or rsi_hidden_bull_cond) ? bar_index[lbR] : na, y2 = plotRsiLines and (rsi_bull_cond or rsi_hidden_bull_cond) ? low[lbR] : na, color = color.new(rsiBullColor, 20), style = line.style_dotted, width = 2)
line.new(x1 = plotRsiLines and (rsi_bear_cond or rsi_hidden_bear_cond) ? int(ta.valuewhen(rsi_bear_cond or rsi_hidden_bear_cond, bar_index[lbR], 1)) : na, y1 = plotRsiLines and (rsi_bear_cond or rsi_hidden_bear_cond) ? ta.valuewhen(rsi_bear_cond or rsi_hidden_bear_cond, high[lbR], 1) : na, x2 = plotRsiLines and (rsi_bear_cond or rsi_hidden_bear_cond) ? bar_index[lbR] : na, y2 = plotRsiLines and (rsi_bear_cond or rsi_hidden_bear_cond) ? high[lbR] : na, color = color.new(rsiBearColor, 20), style = line.style_dotted, width = 2)
````
