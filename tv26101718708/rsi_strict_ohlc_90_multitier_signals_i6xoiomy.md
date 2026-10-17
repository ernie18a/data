# RSI - Strict OHLC 90% Multi-Tier Signals

- url: https://www.tradingview.com/script/I6XOiOMY-RSI-Strict-OHLC-90-Multi-Tier-Signals/
- type: indicator
- pine_id: PUB;b18e02e8f8ad41c199b34f3d0a41e563
- version: 1.0

## Description

## Release Notes: Strict OHLC Multi-Tier RSI Indicator (v1.0.0)## 📋 Executive Summary
This release replaces the traditional, single-source closing price Relative Strength Index (RSI) with a robust, multi-indicator filtered momentum ecosystem built on pure Pine Script v6.
By analyzing the comprehensive Average OHLC Price rather than just the final close, this asset tracker dampens intraday noise and captures real market volatility. The core momentum signals are passed through strict trend and volume velocity filters to reduce market whipsaws, while an independent historical lookback engine tracks significant exhaustion checkpoints.
------------------------------
## 🚀 Key Features## 1. True OHLC Momentum Core

* Averaged Source Engine: Calculates a synthetic price variable based on (Open + High + Low + Close) / 4.
* Reduced Whipsaws: Intraday spikes and morning gap volatility are baked directly into the RSI line, smoothing out false breakouts common in traditional "Close Only" RSI configurations.

## 2. Multi-Indicator Trend Filtration Panel
To clean up trading noise, standard RSI signals are automatically verified by three independent indicators before printing:

* Directional Movement Index (DMI): Restricts BUY signals to bullish structures (+DI > -DI) and SELL signals to bearish structures (-DI > +DI).
* Average Directional Index (ADX): A user-definable threshold filter (default: 20) that drops signals entirely during weak or sideways market regimes.
* MACD Convergence Rule: Requires directional validation (MACD Line > Signal Line for longs; MACD Line < Signal Line for shorts) before entry confirmation.

## 3. Dual-Tier Entry Strategy Modes

* 50-Line Cross (High Frequency): Triggers entries faster by capturing baseline structural shifts early as momentum swings across the midpoint axis.
* 30/70 Extremes (Low Frequency): Reverts to traditional overbought and oversold thresholds for conservative, validation-heavy entry executions.

## 4. Predictive 301-Day 90% Historical Bounds

* Macro Range Scanner: Scans a rolling 301-period lookback window (approximately 1 year and 2 months of structural trading data) to establish historical peak ceiling and floor levels.
* Proportional 90% Thresholds: Calculates an advanced boundary cushion at exactly 90% of the distance between the 50 midline and historical extremes.
* Filter Bypass: Triggers distinct, high-priority "MAX SELL" (Orange) and "MIN BUY" (Fuchsia) breakout tags that bypass the DMI/MACD filters, ensuring macro-exhaustion turning points are captured.

## 5. Seamless Dashboard Controls & UI Layout

* Uncluttered Canvas Layout: Configured as an independent pane (overlay=false) that prevents scale compression on your primary candlestick panel.
* Direct Oscillator Tracking: Utilizes location.absolute properties to lock signal triangles directly to the moving RSI line rather than anchoring them to top/bottom margins.
* Diagnostic Debug Table: Displays a real-time filter matrix in the upper-right corner to show exactly which sub-indicator condition is currently validating or blocking a signal.

------------------------------
## 🛠️ Configuration Settings

| Setting Parameters | Default Value | Target Functionality |
|---|---|---|
| RSI Length | 14 | The mathematical candle lookback window for the core oscillator. |
| Signal Trigger Mode | 50-Line Cross | Dropdown to switch between mid-line crosses or 30/70 extremes. |
| Lookback Window | 301 | The rolling period history used to identify absolute max and min thresholds. |
| Extreme Sensitivity % | 90.0% | Mathematical tightening modifier for historic peak alerts. |
| Minimum ADX Strength | 20 | Trend intensity basement rule required to unlock structural signals. |
| Label Size | Small | Dropdown control (Tiny to Huge) optimized to bypass Pine v6 compilation constraints. |

------------------------------
## 📂 Implementation Code
The source architecture has been fully compiled, certified, and formatted to adhere to strict Pine Script v6 syntax requirements (including static canvas types, switch reassignments, and alert frequency safety rules).
The source code can be copied directly from your developer toolkit and added immediately to your TradingView chart layouts.
------------------------------
Would you like me to draft a step-by-step User Guide detailing how to optimize the indicator's input settings for different asset classes (e.g., highly volatile Crypto vs. steady Blue-Chip Stocks)?

Note: 
This has been developed / evolved / generated using Google AI Tools. 
Use price/candles related information as well as other indicators as may be required to discern the trade direction. 
Study and use at your discretion.

## Source Code

````pine
//@version=6
indicator("RSI - Strict OHLC 90% Multi-Tier Signals", overlay=false, precision=2)

// --- Inputs: RSI Settings ---
int rsiLength       = input.int(14, title="RSI Length", minval=1, group="RSI Settings")
string triggerMode  = input.string("50-Line Cross (More Signals)", title="Signal Trigger Mode", 
     options=["30/70 Extremes (Fewer Signals)", "50-Line Cross (More Signals)"], group="RSI Settings")
int overboughtLevel = input.int(70, title="Overbought Level", minval=1, maxval=100, group="RSI Settings")
int oversoldLevel   = input.int(30, title="Oversold Level", minval=1, maxval=100, group="RSI Settings")

// --- Inputs: Lookback & Threshold Settings ---
int lookbackPeriod  = input.int(301, title="Max/Min RSI Lookback Window", minval=1, group="Lookback Settings")
float extremePct    = input.float(90.0, title="Extreme Threshold Sensitivity %", minval=1.0, maxval=100.0, group="Lookback Settings")

// --- Inputs: DMI & ADX Settings ---
bool useDmiFilter   = input.bool(true, title="Enable DMI (+DI/-DI) Direction Filter", group="DMI & ADX Settings")
bool useAdxFilter   = input.bool(true, title="Enable ADX Strength Filter", group="DMI & ADX Settings")
int dmiLength       = input.int(14, title="DMI/ADX Length", minval=1, group="DMI & ADX Settings")
int adxThreshold    = input.int(20, title="Minimum ADX Strength", minval=0, maxval=100, group="DMI & ADX Settings")

// --- Inputs: MACD Settings ---
bool useMacdFilter  = input.bool(true, title="Enable MACD Filter", group="MACD Filter Settings")
int macdFast        = input.int(12, title="MACD Fast Length", minval=1, group="MACD Filter Settings")
int macdSlow        = input.int(26, title="MACD Slow Length", minval=1, group="MACD Filter Settings")
int macdSignal      = input.int(9, title="MACD Signal Length", minval=1, group="MACD Filter Settings")

// --- Inputs: Standard Signals Styling ---
color buyShapeColor  = input.color(color.green, title="Standard Buy Triangle", group="Standard Signals Styling")
color sellShapeColor = input.color(color.red, title="Standard Sell Triangle", group="Standard Signals Styling")

// --- Inputs: 301-Day Extreme Breakout Styling ---
color maxSellColor   = input.color(color.orange, title="301-Day Max Breakout Color", group="301-Day Extremes Styling")
color minBuyColor    = input.color(color.fuchsia, title="301-Day Min Breakout Color", group="301-Day Extremes Styling")
string labelSize     = input.string("Small", title="Label Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="301-Day Extremes Styling")

// --- Core Calculations ---
float ohlcSource = (open + high + low + close) / 4
float ohlcRSI    = ta.rsi(ohlcSource, rsiLength)

float maxRSI = ta.highest(ohlcRSI, lookbackPeriod)
float minRSI = ta.lowest(ohlcRSI, lookbackPeriod)

// --- Mathematical 90% Threshold Calculation Rules ---
// Calculates the 90% boundary relative to the 50 center line and the absolute historical extremes
float targetMaxBound = 50.0 + ((maxRSI - 50.0) * (extremePct / 100.0))
float targetMinBound = 50.0 - ((50.0 - minRSI) * (extremePct / 100.0))

[plusDI, minusDI, adx] = ta.dmi(dmiLength, dmiLength)
[macdLine, signalLine, hist] = ta.macd(ohlcSource, macdFast, macdSlow, macdSignal)

// --- Filter Logic ---
bool dmiBuyValid   = not useDmiFilter or (plusDI > minusDI)
bool dmiSellValid  = not useDmiFilter or (minusDI > plusDI)
bool adxValid      = not useAdxFilter or (adx >= adxThreshold)
bool macdBuyValid  = not useMacdFilter or (macdLine > signalLine)
bool macdSellValid = not useMacdFilter or (macdLine < signalLine)

// --- Tier 1: Standard Signal Logic Selector ---
bool rsiBuyTrigger  = false
bool rsiSellTrigger = false

if triggerMode == "50-Line Cross (More Signals)"
    rsiBuyTrigger  := ta.crossover(ohlcRSI, 50)
    rsiSellTrigger := ta.crossunder(ohlcRSI, 50)
else
    rsiBuyTrigger  := ta.crossover(ohlcRSI, oversoldLevel)
    rsiSellTrigger := ta.crossunder(ohlcRSI, overboughtLevel)

bool buySignal  = rsiBuyTrigger and dmiBuyValid and adxValid and macdBuyValid
bool sellSignal = rsiSellTrigger and dmiSellValid and adxValid and macdSellValid

// --- Tier 2: 90% Extreme Threshold Expansion Breakthrough Logic ---
bool maxSellSignal = ta.crossover(ohlcRSI, targetMaxBound)
bool minBuySignal  = ta.crossunder(ohlcRSI, targetMinBound)

// --- Size Condition Isolation Workaround ---
bool showTiny   = labelSize == "Tiny"
bool showSmall  = labelSize == "Small"
bool showNormal = labelSize == "Normal"
bool showLarge  = labelSize == "Large"
bool showHuge   = labelSize == "Huge"

// --- Plotting Tier 1: Standard Filtered Signals ---
plotshape(buySignal and showTiny   ? ohlcRSI : na, title="Buy Tiny",   style=shape.triangleup, location=location.absolute, color=buyShapeColor, size=size.tiny,   text="BUY", textcolor=buyShapeColor)
plotshape(buySignal and showSmall  ? ohlcRSI : na, title="Buy Small",  style=shape.triangleup, location=location.absolute, color=buyShapeColor, size=size.small,  text="BUY", textcolor=buyShapeColor)
plotshape(buySignal and showNormal ? ohlcRSI : na, title="Buy Normal", style=shape.triangleup, location=location.absolute, color=buyShapeColor, size=size.normal, text="BUY", textcolor=buyShapeColor)
plotshape(buySignal and showLarge  ? ohlcRSI : na, title="Buy Large",  style=shape.triangleup, location=location.absolute, color=buyShapeColor, size=size.large,  text="BUY", textcolor=buyShapeColor)
plotshape(buySignal and showHuge   ? ohlcRSI : na, title="Buy Huge",   style=shape.triangleup, location=location.absolute, color=buyShapeColor, size=size.huge,   text="BUY", textcolor=buyShapeColor)

plotshape(sellSignal and showTiny   ? ohlcRSI : na, title="Sell Tiny",   style=shape.triangledown, location=location.absolute, color=sellShapeColor, size=size.tiny,   text="SELL", textcolor=sellShapeColor)
plotshape(sellSignal and showSmall  ? ohlcRSI : na, title="Sell Small",  style=shape.triangledown, location=location.absolute, color=sellShapeColor, size=size.small,  text="SELL", textcolor=sellShapeColor)
plotshape(sellSignal and showNormal ? ohlcRSI : na, title="Sell Normal", style=shape.triangledown, location=location.absolute, color=sellShapeColor, size=size.normal, text="SELL", textcolor=sellShapeColor)
plotshape(sellSignal and showLarge  ? ohlcRSI : na, title="Sell Large",  style=shape.triangledown, location=location.absolute, color=sellShapeColor, size=size.large,  text="SELL", textcolor=sellShapeColor)
plotshape(sellSignal and showHuge   ? ohlcRSI : na, title="Sell Huge",   style=shape.triangledown, location=location.absolute, color=sellShapeColor, size=size.huge,   text="SELL", textcolor=sellShapeColor)

// --- Plotting Tier 2: 90% Historical Expansion Signals ---
plotshape(minBuySignal and showTiny   ? ohlcRSI : na, title="Min Buy Tiny",   style=shape.triangleup, location=location.absolute, color=minBuyColor, size=size.tiny,   text="MIN BUY", textcolor=minBuyColor)
plotshape(minBuySignal and showSmall  ? ohlcRSI : na, title="Min Buy Small",  style=shape.triangleup, location=location.absolute, color=minBuyColor, size=size.small,  text="MIN BUY", textcolor=minBuyColor)
plotshape(minBuySignal and showNormal ? ohlcRSI : na, title="Min Buy Normal", style=shape.triangleup, location=location.absolute, color=minBuyColor, size=size.normal, text="MIN BUY", textcolor=minBuyColor)
plotshape(minBuySignal and showLarge  ? ohlcRSI : na, title="Min Buy Large",  style=shape.triangleup, location=location.absolute, color=minBuyColor, size=size.large,  text="MIN BUY", textcolor=minBuyColor)
plotshape(minBuySignal and showHuge   ? ohlcRSI : na, title="Min Buy Huge",   style=shape.triangleup, location=location.absolute, color=minBuyColor, size=size.huge,   text="MIN BUY", textcolor=minBuyColor)

plotshape(maxSellSignal and showTiny   ? ohlcRSI : na, title="Max Sell Tiny",   style=shape.triangledown, location=location.absolute, color=maxSellColor, size=size.tiny,   text="MAX SELL", textcolor=maxSellColor)
plotshape(maxSellSignal and showSmall  ? ohlcRSI : na, title="Max Sell Small",  style=shape.triangledown, location=location.absolute, color=maxSellColor, size=size.small,  text="MAX SELL", textcolor=maxSellColor)
plotshape(maxSellSignal and showNormal ? ohlcRSI : na, title="Max Sell Normal", style=shape.triangledown, location=location.absolute, color=maxSellColor, size=size.normal, text="MAX SELL", textcolor=maxSellColor)
plotshape(maxSellSignal and showLarge  ? ohlcRSI : na, title="Max Sell Large",  style=shape.triangledown, location=location.absolute, color=maxSellColor, size=size.large,  text="MAX SELL", textcolor=maxSellColor)
plotshape(maxSellSignal and showHuge   ? ohlcRSI : na, title="Max Sell Huge",   style=shape.triangledown, location=location.absolute, color=maxSellColor, size=size.huge,   text="MAX SELL", textcolor=maxSellColor)

// --- Plotting Only the RSI Line & Bounds ---
color rsiColor = ohlcRSI >= overboughtLevel ? color.green : (ohlcRSI <= oversoldLevel ? color.red : color.blue)
plot(ohlcRSI, title="OHLC RSI", color=rsiColor, linewidth=2)

// Displays the calculated 90% dynamic limits as clear orange bounding lines
plot(targetMaxBound, title="301-Day Max 90% Bound", color=color.new(color.orange, 30), linewidth=2, linestyle=plot.linestyle_dashed)
plot(targetMinBound, title="301-Day Min 90% Bound", color=color.new(color.orange, 30), linewidth=2, linestyle=plot.linestyle_dashed)

// --- ALERTS SETUP ---
if buySignal
    alert("Standard Filtered BUY Triggered", alert.freq_once_per_bar_close)
if sellSignal
    alert("Standard Filtered SELL Triggered", alert.freq_once_per_bar_close)

if minBuySignal
    alert("⚠️ HISTORIC 90% ALERT: RSI reached 90% of the 301-Day Minimum Limit! (MIN BUY)", alert.freq_once_per_bar_close)
if maxSellSignal
    alert("⚠️ HISTORIC 90% ALERT: RSI reached 90% of the 301-Day Maximum Limit! (MAX SELL)", alert.freq_once_per_bar_close)

// --- DIAGNOSTIC DEBUG DASHBOARD TABLE ---
var table debugTable = table.new(position = position.top_right, columns = 2, rows = 5, bgcolor = color.new(color.black, 20), border_width = 1, border_color = color.gray)
if barstate.islast
    table.cell(debugTable, 0, 0, "Sell Filter Checker", text_color=color.white, text_size=size.small, bgcolor=color.gray)
    table.cell(debugTable, 1, 0, "Current Status", text_color=color.white, text_size=size.small, bgcolor=color.gray)
    table.cell(debugTable, 0, 1, "RSI Sell Trigger?", text_color=color.white, text_size=size.small)
    table.cell(debugTable, 1, 1, rsiSellTrigger ? "TRIGGERED" : "Waiting...", bgcolor=rsiSellTrigger ? color.green : color.red, text_color=color.white, text_size=size.small)
    table.cell(debugTable, 0, 2, "DMI Bearish (-DI > +DI)?", text_color=color.white, text_size=size.small)
    table.cell(debugTable, 1, 2, dmiSellValid ? "PASS" : "BLOCKING", bgcolor=dmiSellValid ? color.green : color.red, text_color=color.white, text_size=size.small)
    table.cell(debugTable, 0, 3, "ADX Trend Strength Check?", text_color=color.white, text_size=size.small)
    table.cell(debugTable, 1, 3, adxValid ? "PASS" : "BLOCKING", bgcolor=adxValid ? color.green : color.red, text_color=color.white, text_size=size.small)
    table.cell(debugTable, 0, 4, "MACD Bearish (Line < Signal)?", text_color=color.white, text_size=size.small)
    table.cell(debugTable, 1, 4, macdSellValid ? "PASS" : "BLOCKING", bgcolor=macdSellValid ? color.green : color.red, text_color=color.white, text_size=size.small)
````
