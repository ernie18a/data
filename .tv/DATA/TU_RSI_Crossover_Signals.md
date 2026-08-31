<!-- tradingview-pine-id: PUB;ca95ef3fb78e41dfbf12026ccf4e2288 -->
<!-- tradingviewscripts-format: 1 -->
# TU RSI Crossover Signals

Source: https://www.tradingview.com/script/qNowfmoK-TU-RSI-Crossover-Signals/

## Description

TU RSI Crossover Signals

Overview
The TU RSI Crossover Signals is a momentum-based indicator designed to identify potential trend reversals and optimal entry/exit points. By analyzing the Relative Strength Index (RSI) in relation to its Simple Moving Average (SMA), it plots intuitive Buy (Green Triangle) and Sell (Red Triangle) signals directly on your chart. 

To reduce false signals in ranging or strongly trending markets, this script includes built-in, customizable RSI zone filters and an optional EMA trend filter to ensure you are trading with the momentum.

How It Works
The core logic of this indicator relies on crossovers between the RSI and its moving average:

[*]Buy Signals: A buy signal is generated when the RSI crosses above its moving average. To ensure this happens at an opportunistic level, the RSI must also be below a user-defined threshold (default is 45).
[*]Sell Signals: A sell signal is generated when the RSI crosses below its moving average. The RSI must also be above a user-defined threshold (default is 65) to capture exhaustion in higher price regions.

Key Features & Customization
This script is highly customizable to fit various assets and timeframes:

[*]RSI Settings: Adjust the baseline RSI Length and the RSI MA Length (both default to 14) to speed up or smooth out signal generation. 
[*]RSI Filters: 
- Max RSI for Buy (Default 45): Prevents buy signals from firing if the asset is already trending too high.
- Min RSI for Sell (Default 65): Prevents sell signals from firing if the asset is already near the bottom of its range.
[*]Trend Momentum Filter (Avoid Falling Knives): 
- By enabling the Require Price > EMA toggle, the script introduces a strict trend filter. 
- When active, Buy signals will only trigger if the closing price is currently trading above the chosen EMA (default 9-period). This is an excellent tool for avoiding false breakouts during strong downtrends. When enabled, the Trend EMA is visually plotted on the chart for reference.

Use Case
This indicator is best used as a confluence tool alongside support/resistance zones, price action, or broader market trend analysis. It excels at finding "dip buy" opportunities and "overbought sell" conditions while keeping you on the right side of the short-term trend.

Disclaimer: This indicator is for educational and technical analysis purposes only and does not constitute financial advice. Always use proper risk management.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © tungmeister

//@version=6

indicator("TU RSI Crossover Signals", overlay = true)

// --- Input Settings ---
rsiLength = input.int(14, title = "RSI Length", minval = 1)
maLength  = input.int(14, title = "RSI MA Length", minval = 1)
src       = input.source(close, title = "Source")

// --- RSI Filter Settings ---
buyFilter  = input.float(45, title = "Max RSI for Buy (Only buy if RSI is below this)")
sellFilter = input.float(65, title = "Min RSI for Sell (Only sell if RSI is above this)")

// --- Momentum Filter Settings ---
useTrendFilter = input.bool(false, title = "Require Price > EMA (Avoid Falling Knives)")
emaLength      = input.int(9, title = "Trend EMA Length")

// --- Calculations ---
rsiVal = ta.rsi(src, rsiLength)
rsiMa  = ta.sma(rsiVal, maLength)
emaVal = ta.ema(src, emaLength)

// --- Crossover Conditions ---
buyCross  = ta.crossover(rsiVal, rsiMa)
sellCross = ta.crossunder(rsiVal, rsiMa)

// --- Momentum Logic ---
// If the trend filter is checked, it forces the price to be above the EMA to consider it a valid buy.
trendIsUp = useTrendFilter ? (close > emaVal) : true

buySignal  = buyCross and (rsiVal < buyFilter) and trendIsUp
sellSignal = sellCross and (rsiVal > sellFilter)

// --- Plot Signals on Price Chart ---
plotshape(
     series   = buySignal, 
     title    = "Buy Signal", 
     style    = shape.triangleup, 
     location = location.belowbar, 
     color    = color.green, 
     size     = size.small
 )

plotshape(
     series   = sellSignal, 
     title    = "Sell Signal", 
     style    = shape.triangledown, 
     location = location.abovebar, 
     color    = color.red, 
     size     = size.small
 )

// --- Plot the Trend EMA ---
plot(useTrendFilter ? emaVal : na, title="Trend EMA", color=color.new(color.blue, 60), linewidth=2)
````
