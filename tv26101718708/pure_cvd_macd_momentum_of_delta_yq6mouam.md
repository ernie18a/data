# Pure CVD MACD (Momentum of Delta)

- url: https://www.tradingview.com/script/yq6mOUAm-Pure-CVD-MACD-Momentum-of-Delta/
- type: indicator
- pine_id: PUB;20bcc4199aa849d895bfcdbab956ee7c
- version: 1.0

## Description

Overview
Traditional MACD indicators are fantastic at measuring the momentum of price, but they are entirely blind to the actual order flow driving that price. The Pure CVD MACD shifts the focus from the result (price action) to the cause (market aggression).

Instead of asking "Are there more buyers or sellers?", this indicator asks "Is the buying or selling pressure accelerating or decelerating?"

Built using Pine Script Version 6 and the new ta.requestVolumeDelta function, this script calculates a classic MACD (Moving Average Convergence Divergence) entirely on the raw Cumulative Volume Delta (CVD), completely independent of price. This provides an institutional-grade look at the momentum of order flow.

How It Works
The script calculates a continuous Cumulative Volume Delta line by scanning lower timeframe data to find the exact net difference between buying and selling volume. It then applies standard MACD logic to that CVD line:

MACD Line (Blue): The difference between a Fast EMA and Slow EMA of the volume delta.

Signal Line (Orange): An EMA of the MACD Line itself.

Histogram: The visual difference between the MACD Line and the Signal Line, color-coded to show momentum shifts.

Key Order Flow Concepts to Trade

Momentum Shifts (Zero-Line Crossovers): When the histogram crosses above the zero line (Blue crosses over Orange), the volume delta is gaining bullish momentum. Even if the macro trend is down, this shows aggressive buyers are stepping in and accelerating their pace. A cross below zero signals accelerating bearish pressure.

Exhaustion (Histogram Fades): Watch for the color fades (Teal to Dark Teal, or Red to Dark Red). If you are watching a massive sell-off and the histogram prints a "Dark Red" bar, the selling pressure is decelerating. Sellers are running out of ammunition, often signaling an impending reversal.

Hidden Divergence: Compare the Pure CVD MACD to the price chart. If the price is grinding upward to make a Higher High, but the CVD MACD is crossing bearishly below its Signal Line, the breakout is running on fumes and a trap is likely being set.

Settings Breakdown

Anchor & Lower Timeframe: Defines the starting point for the cumulative delta and the timeframe used to calculate the intra-bar buying/selling volume. By default, it automatically selects the best lower timeframe.

Fast / Slow EMA Lengths (Default 12, 26): The lookback periods used to track the short-term vs. long-term trend of the volume delta.

Signal EMA Length (Default 9): The trigger line used to spot early momentum shifts in the delta.

Best Practices
Because this indicator measures the momentum of order flow rather than absolute volume, it pairs exceptionally well with structural price analysis or liquidity zones. When price taps a major support level and the Pure CVD MACD prints a bullish divergence or a histogram fade, you have highly confluent evidence that the level will hold.

## Source Code

````pine
//@version=6
indicator("Pure CVD MACD (Momentum of Delta)", "Pure CVD MACD", overlay=false)

import TradingView/ta/8

// ==========================================
// 1. CVD SETTINGS & DATA FETCH
// ==========================================
anchorInput = input.timeframe("1D", "Anchor period", group="Delta Settings")
lowerTimeframeInput = input.timeframe("1", "Lower Timeframe for Delta", group="Delta Settings")

// Fetch the Delta for the current candle
[openVolume, maxVolume, minVolume, lastVolume] = ta.requestVolumeDelta(lowerTimeframeInput, anchorInput)
candleDelta = lastVolume - openVolume

// Accumulate the delta to create the continuous CVD line
var float cvdLine = 0.0
cvdLine += nz(candleDelta)

// ==========================================
// 2. MACD SETTINGS
// ==========================================
fastLen = input.int(12, "Fast EMA Length", minval=1, group="MACD Settings")
slowLen = input.int(26, "Slow EMA Length", minval=1, group="MACD Settings")
sigLen  = input.int(9, "Signal EMA Length", minval=1, group="MACD Settings")

// ==========================================
// 3. MACD CALCULATIONS
// ==========================================
// Calculate the Fast and Slow EMAs of the actual CVD line
fastEma = ta.ema(cvdLine, fastLen)
slowEma = ta.ema(cvdLine, slowLen)

// MACD Line is the difference between the Fast and Slow EMAs (Convergence/Divergence)
macdLine = fastEma - slowEma

// Signal Line is an EMA of the MACD Line itself
signalLine = ta.ema(macdLine, sigLen)

// Histogram is the difference between the MACD Line and the Signal Line
hist = macdLine - signalLine

// ==========================================
// 4. PLOTTING VISUALS
// ==========================================
// Histogram Colors: 
// Teal = Positive and growing | Dark Teal = Positive but shrinking
// Red = Negative and growing | Dark Red = Negative but shrinking
histColor = hist >= 0 ? (hist > hist[1] ? color.teal : color.new(color.teal, 50)) : (hist < hist[1] ? color.red : color.new(color.red, 50))

// Draw Zero Line
hline(0, "Zero Line", color=color.new(color.gray, 50), linestyle=hline.style_dashed)

// Plot Histogram
plot(hist, title="Histogram", style=plot.style_columns, color=histColor)

// Plot MACD and Signal Lines
plot(macdLine, title="MACD Line", color=color.blue, linewidth=2)
plot(signalLine, title="Signal Line", color=color.orange, linewidth=1)// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © hillol_prakkan
````
