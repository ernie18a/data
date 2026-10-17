# Vealth1st - 2X Opposite Candle Alert

- url: https://www.tradingview.com/script/rym71x7Q-Vealth1st-2X-Opposite-Candle-Alert/
- type: indicator
- pine_id: PUB;d3d2792aa4224788b65f3ab034613509
- version: 2.0

## Description

This indicator identifies potential bullish and bearish reversal signals by comparing the body sizes and colors of two consecutive candles.

How It Works

BUY Signal

The previous candle must be red (bearish).

The current candle must be green (bullish).

The current candle's body must be at least 2 times the previous candle's body.

The signal is confirmed only after the current candle closes.

SELL Signal

The previous candle must be green (bullish).

The current candle must be red (bearish).

The current candle's body must be at least 2 times the previous candle's body.

The signal is confirmed only after the current candle closes.

Key Features

Automatic BUY and SELL signal labels on the chart.

Configurable candle body multiplier.

Separate TradingView alert conditions for bullish and bearish signals.

Candle-close confirmation to avoid signals based on incomplete candles.

Suitable for XAUUSD and other instruments and timeframes.

Recommended Usage

The indicator is designed for use on the 15-minute XAUUSD chart. Traders can use the signals as part of their technical analysis and combine them with support and resistance, trend direction, or other confirmation methods.

Disclaimer

This indicator identifies candle patterns based on predefined conditions. It does not guarantee profitable trades or predict future price movements. Always apply appropriate risk management and test the indicator before using it in live trading.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © rahul304

 //@version=6
indicator("Vealth1st - 2X Opposite Candle Alert", overlay=true)

// Settings
bodyMultiplier = input.float(2.0, "Required Body Multiplier", minval=1.0, step=0.5)
minBodyPercent = input.float(70.0, "Minimum Body % of Candle Range", minval=1.0, maxval=100.0, step=5.0)

// Previous candle measurements
previousBody = math.abs(close[1] - open[1])

// Current candle measurements
currentBody = math.abs(close - open)
currentRange = high - low

// Candle colors
previousGreen = close[1] > open[1]
previousRed = close[1] < open[1]

currentGreen = close > open
currentRed = close < open

// Current body must be at least 2x previous body
bodyIsLargeEnough = currentBody >= previousBody * bodyMultiplier

// Current body must be at least 70% of total candle height
bodyIsLargeEnoughOfRange = currentRange > 0 and currentBody / currentRange >= minBodyPercent / 100.0

// Confirm signals at candle close
buySignal = previousRed and currentGreen and bodyIsLargeEnough and bodyIsLargeEnoughOfRange and barstate.isconfirmed
sellSignal = previousGreen and currentRed and bodyIsLargeEnough and bodyIsLargeEnoughOfRange and barstate.isconfirmed

// Chart labels
plotshape(buySignal, title="BUY Signal", style=shape.labelup, location=location.belowbar, color=color.green, text="BUY", textcolor=color.white, size=size.small)

plotshape(sellSignal, title="SELL Signal", style=shape.labeldown, location=location.abovebar, color=color.red, text="SELL", textcolor=color.white, size=size.small)

// TradingView alerts
alertcondition(buySignal, title="BUY Alert", message="BUY: Opposite green candle body is at least 2x previous red body and 70% of candle range. {{ticker}} {{interval}} Close: {{close}}")

alertcondition(sellSignal, title="SELL Alert", message="SELL: Opposite red candle body is at least 2x previous green body and 70% of candle range. {{ticker}} {{interval}} Close: {{close}}")
````
