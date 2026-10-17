# Self Strength Oscillator

- url: https://www.tradingview.com/script/QAxVIn6I-Self-Strength-Oscillator/
- type: indicator
- pine_id: PUB;69b9be0dbd4346d5b23f5d1b61bb7673
- version: 1.0

## Description

1. Overview

Self Strength Oscillator is an internal strength indicator that measures how strong price is compared with its own long-term trend baseline.

The indicator is designed to help traders evaluate whether price is showing internal strength or internal weakness relative to a selected moving-average baseline.

This is an indicator, not a strategy. It does not place trades, does not execute orders, and does not produce TradingView Strategy Tester results.

2. Core Idea

The indicator is built around a zero line.

When the oscillator is above zero, price is trading above its own trend baseline.

When the oscillator is below zero, price is trading below its own trend baseline.

This makes the tool useful for identifying whether the symbol is showing internal strength or weakness.

3. Trend Baseline

The trend baseline is the reference line used to measure internal strength.

Users can choose the baseline type:

* EMA
* SMA
* WMA

The default baseline length is 50.

A longer baseline gives a slower and broader strength reading.

A shorter baseline gives a faster and more reactive reading.

4. Normalization Modes

The indicator includes two normalization modes:

Percent

This mode measures the percentage distance between price and its trend baseline.

Volatility (ATR)

This mode normalizes the distance using ATR percentage.

ATR normalization can help adjust readings for volatility differences across symbols and timeframes.

5. Oscillator Reading

The oscillator line represents the distance between price and the selected trend baseline.

Above zero

Price is above its own baseline. This can suggest internal strength.

Below zero

Price is below its own baseline. This can suggest internal weakness.

The oscillator should be interpreted as a strength filter, not as a direct trade signal.

6. Signal Line

The indicator includes an optional signal line.

The signal line is a moving average of the oscillator.

It helps users observe whether internal strength momentum is improving or weakening.

When the oscillator is above the signal line, internal strength may be improving.

When the oscillator is below the signal line, internal strength may be fading.

This should be used as context only, not as a standalone entry or exit signal.

7. Histogram

The histogram shows the difference between the oscillator and the signal line.

The histogram is ON by default.

A rising histogram can indicate improving internal strength momentum.

A falling histogram can indicate fading internal strength momentum.

The histogram can help users observe changes in strength momentum before or during price movement.

8. New Strength Highs

The indicator can flag new strength highs.

This feature is ON by default.

A New Strength High appears when the oscillator prints a new high over the selected lookback window while still above zero.

This can help highlight moments where internal strength is improving.

A New Strength High is not a guaranteed breakout signal. It is only a visual alert that the oscillator has reached a new strength high.

9. Zero-Line Crosses

The indicator can flag zero-line crosses.

This feature is ON by default.

A cross above zero means price moved from below its baseline to above its baseline.

A cross below zero means price moved from above its baseline to below its baseline.

Zero-line crosses can help identify changes in internal strength state.

They are not automatic buy or sell signals.

10. Background Regime

The indicator includes an optional background regime color.

The background is OFF by default to keep the pane clean.

When enabled, it can tint the pane based on whether the oscillator is above or below zero.

Users can enable this feature if they prefer a stronger visual regime view.

11. How to Use

A practical workflow:

1. Add the indicator to the chart.

2. Watch the oscillator relative to the zero line.

3. Above zero suggests internal strength.

4. Below zero suggests internal weakness.

5. Use the signal line to observe strength momentum.

6. Use the histogram to track acceleration or fading of internal strength.

7. Use New Strength High markers as alerts that internal strength is improving.

8. Use Zero-Line Cross markers as alerts that price has changed its internal strength state.

9. Combine the indicator with trend, support/resistance, market structure, volume, and risk management.

10. Do not use any single marker as a complete trading decision.

11. Suggested Use Cases

Self Strength Oscillator can be useful for:

* Internal strength analysis
* Trend confirmation
* Momentum confirmation
* Pullback review
* Breakout preparation
* Watchlist review
* Comparing price against its own baseline
* Filtering weak setups
* Identifying improving internal strength
* Monitoring fading strength

13. Important Usage Note

This indicator does not tell users when to buy or sell.

It does not predict future price movement.

It does not guarantee a breakout.

It does not guarantee continuation.

It does not guarantee reversal.

It only helps users observe whether price is strong or weak relative to its own trend baseline.

The best use is as a confirmation and filtering tool, not as a standalone trading system.

14. Limitations

The oscillator can remain above zero for a long time during strong trends.

The oscillator can remain below zero for a long time during weak trends.

Zero-line crosses can happen frequently during sideways markets.

New Strength High markers can appear after price has already moved.

A positive oscillator does not guarantee that price will continue higher.

A negative oscillator does not guarantee that price will continue lower.

Users should always analyze the broader chart context before making any trading decision.

15. Alerts

The script includes alert conditions for:

* SSO crossing above zero
* SSO crossing below zero
* SSO printing a new strength high

Alerts are notifications only. They do not place orders and do not confirm broker execution.

16. Originality and Purpose

Self Strength Oscillator combines internal strength calculation with a signal line, histogram, zero-line state, and new strength high alerts.

The purpose is to provide a clean internal strength oscillator that helps traders evaluate whether price is showing strength or weakness compared with its own trend baseline.

17. Educational Disclaimer

This script is for educational and chart-analysis purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any financial instrument. Users are responsible for their own analysis, risk management, and trading decisions.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (c) ADXAE

//@version=6
// ============================================================================
// Self Strength Oscillator
// ============================================================================
// Self Strength Oscillator measures how strong price is compared with its OWN
// long-term trend baseline.
//
// Classic relative strength compares an asset against an external benchmark
// such as SPY, QQQ, BTC, or another index.
//
// This version uses NO external benchmark.
// It is benchmark-free.
//
// The oscillator is built around a zero line:
// - Above 0 = price is above its own trend baseline.
// - Below 0 = price is below its own trend baseline.
//
// Use it as a self-strength filter and confirmation tool.
// It is not a standalone entry or exit signal.
// ============================================================================

indicator("Self Strength Oscillator", "SSO", overlay = false)

// ============================================================================
// Core Settings
// ============================================================================

grpCore = "1) Core Settings"

src = input.source(
     close,
     "Source",
     group = grpCore,
     tooltip = "Price series used to measure strength. Default = close.")

maType = input.string(
     "EMA",
     "Trend Baseline Type",
     options = ["EMA", "SMA", "WMA"],
     group = grpCore,
     tooltip = "Moving-average type used as the asset's own trend baseline. EMA reacts faster, SMA is steadier, and WMA is more responsive to recent price.")

maLen = input.int(
     50,
     "Trend Baseline Length",
     minval = 2,
     group = grpCore,
     tooltip = "Lookback for the trend baseline. Longer values are slower and more strategic. Shorter values are more reactive.")

normMode = input.string(
     "Percent",
     "Normalization",
     options = ["Percent", "Volatility (ATR)"],
     group = grpCore,
     tooltip = "Percent: measures the raw percent distance from the baseline. Volatility (ATR): normalizes that distance by ATR-percent so readings are adjusted for volatility.")

atrLen = input.int(
     14,
     "ATR Length",
     minval = 1,
     group = grpCore,
     active = normMode == "Volatility (ATR)",
     tooltip = "ATR lookback. Used only when Normalization = Volatility (ATR).")

// ============================================================================
// Signal Line
// ============================================================================

grpSig = "2) Signal Line"

showSig = input.bool(
     true,
     "Show Signal Line",
     group = grpSig,
     tooltip = "Plots a moving average of the oscillator. A cross over or under the signal line can help identify a shift in the momentum of self-strength.")

sigLen = input.int(
     9,
     "Signal Length",
     minval = 1,
     group = grpSig,
     active = showSig,
     tooltip = "Length of the signal-line moving average.")

showHist = input.bool(
     true,
     "Show Histogram",
     group = grpSig,
     tooltip = "Plots oscillator minus signal line. Rising histogram can indicate improving self-strength momentum; falling histogram can indicate fading self-strength momentum.")

// ============================================================================
// Strength Detection
// ============================================================================

grpLead = "3) Strength Detection"

showLead = input.bool(
     true,
     "Flag New Strength Highs",
     group = grpLead,
     tooltip = "Marks when the oscillator prints a new high over the lookback window while still positive. This highlights improving self-strength, not a guaranteed breakout.")

leadLk = input.int(
     50,
     "Strength Lookback",
     minval = 5,
     group = grpLead,
     active = showLead,
     tooltip = "Window used to detect a new self-strength high.")

showZero = input.bool(
     true,
     "Flag Zero-Line Crosses",
     group = grpLead,
     tooltip = "Marks when the oscillator crosses zero. This is ON by default, but users can turn it OFF from the settings.")

// ============================================================================
// Style
// ============================================================================

grpSty = "4) Style"

colBg = input.bool(
     false,
     "Color Background by Regime",
     group = grpSty,
     tooltip = "Tints the pane when strength is positive or negative. OFF by default to reduce visual noise.")

upCol = input.color(
     color.teal,
     "Strong Color",
     group = grpSty,
     tooltip = "Color used when the oscillator is at or above zero.")

dnCol = input.color(
     color.red,
     "Weak Color",
     group = grpSty,
     tooltip = "Color used when the oscillator is below zero.")

sigCol = input.color(
     color.orange,
     "Signal Line Color",
     group = grpSty)

zeroCol = input.color(
     color.gray,
     "Zero Line Color",
     group = grpSty)

// ============================================================================
// Calculation
// NOTE:
// The core calculation below is unchanged.
// ============================================================================

maOf(s, l, t) =>
    t == "EMA" ? ta.ema(s, l) :
     t == "SMA" ? ta.sma(s, l) :
     ta.wma(s, l)

baseline = maOf(src, maLen, maType)

rawPct = baseline != 0 ? (src - baseline) / baseline * 100.0 : 0.0

atrPct = src != 0 ? ta.atr(atrLen) / src * 100.0 : 0.0

rs = normMode == "Volatility (ATR)" ? (atrPct != 0 ? rawPct / atrPct : 0.0) : rawPct

sig = ta.ema(rs, sigLen)

hist = rs - sig

// ============================================================================
// Signals
// NOTE:
// Signal logic is unchanged.
// ============================================================================

newHigh = rs > 0 and rs > ta.highest(rs[1], leadLk)

crossUp = ta.crossover(rs, 0)

crossDn = ta.crossunder(rs, 0)

// ============================================================================
// Plots
// ============================================================================

rsCol = rs >= 0 ? upCol : dnCol

histCol = hist >= 0 ?
     hist >= hist[1] ? color.new(upCol, 0) : color.new(upCol, 60) :
     hist <= hist[1] ? color.new(dnCol, 0) : color.new(dnCol, 60)

plot(
     showHist ? hist : na,
     "Histogram",
     color = histCol,
     style = plot.style_columns)

plot(
     showSig ? sig : na,
     "Signal",
     color = sigCol,
     linewidth = 1)

plot(
     rs,
     "SSO",
     color = rsCol,
     linewidth = 2)

hline(
     0,
     "Zero",
     color = color.new(zeroCol, 0),
     linestyle = hline.style_dashed)

bgcolor(
     colBg ? rs >= 0 ? color.new(upCol, 90) : color.new(dnCol, 90) : na,
     title = "Regime Background")

plotshape(
     showLead and newHigh,
     title = "New Strength High",
     style = shape.triangleup,
     location = location.bottom,
     color = color.new(upCol, 0),
     size = size.tiny)

plotshape(
     showZero and crossUp,
     title = "Cross Above Zero",
     style = shape.circle,
     location = location.bottom,
     color = color.new(upCol, 0),
     size = size.tiny)

plotshape(
     showZero and crossDn,
     title = "Cross Below Zero",
     style = shape.circle,
     location = location.top,
     color = color.new(dnCol, 0),
     size = size.tiny)

// ============================================================================
// Alerts
// ============================================================================

alertcondition(
     crossUp,
     title = "SSO crossed above zero",
     message = "Self Strength Oscillator turned positive relative to its own trend baseline")

alertcondition(
     crossDn,
     title = "SSO crossed below zero",
     message = "Self Strength Oscillator turned negative relative to its own trend baseline")

alertcondition(
     newHigh,
     title = "SSO new strength high",
     message = "Self Strength Oscillator printed a new high over the selected lookback")

// ============================================================================
// End of file
// ============================================================================
````
