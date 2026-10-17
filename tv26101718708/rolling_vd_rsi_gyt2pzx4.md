# Rolling VD RSI

- url: https://www.tradingview.com/script/GYt2pZx4-Rolling-VD-RSI/
- type: indicator
- pine_id: PUB;ed0b72b7b84c45e8bab7347ca0f1b57b
- version: 1.0

## Description

Rolling cumulative volume delta RSI. Equation is same as traditional RSI, but uses volume delta as "up day" vs. "down day"

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © vandalsemjj

//@version=6
indicator("Tick-Based Volume Delta RSI", "VD-RSI 1T", precision = 2)

import TradingView/ta/12 as tvta

// ─────────────────────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────────────────────

rsiLength = input.int(14, "VD RSI Length", minval = 1)
smaLength = input.int(9, "Signal SMA Length", minval = 1)

upperLevel = input.float(70.0, "Upper Reference Level", minval = 0, maxval = 100)
lowerLevel = input.float(30.0, "Lower Reference Level", minval = 0, maxval = 100)

// One-tick intrabar data.
// With TradingView/ta/12, this uses bid/ask-informed classification when available.
string lowerTimeframe = "1T"

// Keep the same daily anchor structure as your original CVD script.
string cumulativeAnchor = "1D"

// ─────────────────────────────────────────────────────────────────────────────
// Tick-Based Volume Delta
// ─────────────────────────────────────────────────────────────────────────────

// Returns the opening, high, low, and ending cumulative volume delta
// for each chart bar within the daily anchor period.
[openVD, _, _, lastVD] = tvta.requestVolumeDelta(lowerTimeframe, cumulativeAnchor)

// Extract the standalone volume delta for each chart bar.
// On a daily chart, this is each day's tick-based volume delta.
barDelta = lastVD - openVD

// ─────────────────────────────────────────────────────────────────────────────
// RSI-Style Calculation on Volume Delta
// ─────────────────────────────────────────────────────────────────────────────

// Positive-delta bars are treated like RSI "gains."
// Negative-delta bars are treated like RSI "losses."
positiveDelta = math.max(barDelta, 0.0)
negativeDelta = math.max(-barDelta, 0.0)

// Standard RSI uses Wilder smoothing, represented in Pine by ta.rma().
avgPositiveDelta = ta.rma(positiveDelta, rsiLength)
avgNegativeDelta = ta.rma(negativeDelta, rsiLength)

// RSI-style oscillator based on volume delta.
vdRsi = avgPositiveDelta == 0.0 and avgNegativeDelta == 0.0 ? 50.0 :
     avgNegativeDelta == 0.0 ? 100.0 :
     avgPositiveDelta == 0.0 ? 0.0 :
     100.0 - (100.0 / (1.0 + avgPositiveDelta / avgNegativeDelta))

// SMA signal line applied to the completed oscillator.
signalSma = ta.sma(vdRsi, smaLength)

// ─────────────────────────────────────────────────────────────────────────────
// Plots
// ─────────────────────────────────────────────────────────────────────────────

upperBand = hline(upperLevel, "Upper Reference", color = color.new(color.gray, 50), linestyle = hline.style_dashed)
midLine   = hline(50, "Balance Line", color = color.new(color.gray, 35))
lowerBand = hline(lowerLevel, "Lower Reference", color = color.new(color.gray, 50), linestyle = hline.style_dashed)

fill(upperBand, lowerBand, color = color.new(color.gray, 94))

rsiColor = vdRsi >= 50 ? color.teal : color.red

plot(vdRsi, "Tick-Based VD RSI", color = rsiColor, linewidth = 2)
plot(signalSma, "Signal SMA", color = color.orange, linewidth = 2)

// Keeps the raw delta available in the Data Window without cluttering the pane.
plot(barDelta, "Raw Tick-Based Bar Delta", display = display.data_window)
````
