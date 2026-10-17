# Spike EA Trade Indicator

- url: https://www.tradingview.com/script/0TQDuqg4/
- type: indicator
- pine_id: PUB;03135ee9019041309c29b1176211941d
- version: 1.0

## Description

Spike EA Trade Indicator is a simple price-action signal tool inspired by an MT4/MT5 expert advisor logic.

The script detects spike candles by measuring the range between the high and low of a selected previous bar. If the range is greater than or equal to the configured threshold, the candle direction is used to generate a signal. A bullish spike candle produces a buy signal, while a bearish spike candle produces a sell signal.

The default settings are designed around USDJPY on the 15-minute chart. The default spike threshold is 0.5 with a price unit of 1.0, which represents approximately a 0.5 yen candle range on USDJPY.

This indicator displays visual buy and sell signals only. It does not execute trades and does not provide backtesting results.

This script is intended for chart analysis, research, and educational purposes only.
It does not guarantee future performance and should not be considered financial advice.
Please test carefully before using it in any trading decision.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MasayanFX

//@version=6
indicator("Spike EA Trade Indicator", overlay=true)

// Inputs
spikeThreshold = input.float(0.5, "Spike Threshold", minval=0.0, step=0.1)
spikeBar       = input.int(1, "Spike Bar", minval=0)
priceUnit      = input.float(1.0, "Price Unit for Threshold", minval=0.00001, step=0.1)

showBg   = input.bool(true, "Show Signal Background")
showText = input.bool(false, "Show BUY/SELL Text")

// Colors
buyColor  = color.rgb(0, 255, 170)
sellColor = color.rgb(255, 90, 120)

// Indicator Calculations
spikeHigh  = high[spikeBar]
spikeLow   = low[spikeBar]
spikeOpen  = open[spikeBar]
spikeClose = close[spikeBar]

spikeRange = spikeHigh - spikeLow
threshold  = spikeThreshold * priceUnit

// Signal Logic
isSpike = spikeRange >= threshold

buySignal  = isSpike and spikeClose > spikeOpen
sellSignal = isSpike and spikeClose <= spikeOpen

// Plot Lines
plot(threshold, "Spike Threshold", display=display.data_window)

// Background
bgcolor(showBg and buySignal ? color.new(color.rgb(0, 120, 255), 94) : na)
bgcolor(showBg and sellSignal ? color.new(color.rgb(255, 70, 90), 94) : na)

// Signals
plotshape(buySignal and not showText, title="Buy Signal", style=shape.triangleup, location=location.belowbar, color=buyColor, size=size.small)
plotshape(sellSignal and not showText, title="Sell Signal", style=shape.triangledown, location=location.abovebar, color=sellColor, size=size.small)

plotshape(buySignal and showText, title="Buy Signal Text", style=shape.triangleup, location=location.belowbar, color=buyColor, size=size.small, text="BUY")
plotshape(sellSignal and showText, title="Sell Signal Text", style=shape.triangledown, location=location.abovebar, color=sellColor, size=size.small, text="SELL")

// Alerts
alertcondition(buySignal, title="Buy Alert", message="Spike EA Trade Buy Signal")
alertcondition(sellSignal, title="Sell Alert", message="Spike EA Trade Sell Signal")
````
