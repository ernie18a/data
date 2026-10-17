# Spike EA Trade Strategy

- url: https://www.tradingview.com/script/8pUGH47d/
- type: strategy
- pine_id: PUB;11abbaf191e54230a2dc397ff8efb1a0
- version: 2.0

## Description

Spike EA Trade Strategy is a price-action backtesting script inspired by an MT4/MT5 expert advisor logic.

The strategy detects spike candles by measuring the range between the high and low of a selected previous bar. If the range is greater than or equal to the configured threshold, the candle direction is used for trade direction. A bullish spike candle triggers a long setup, while a bearish spike candle triggers a short setup.

The default settings are designed around USDJPY on the 15-minute chart. The default spike threshold is 0.5 with a price unit of 1.0, which represents approximately a 0.5 yen candle range on USDJPY.

The strategy version includes approximate stop loss and take profit price-distance settings for TradingView Strategy Tester. Broker-specific execution details such as spread, slippage, order rejection, margin checks, lot handling, and MT4/MT5 magic number management are not replicated.

This script is intended for chart analysis, backtesting support, research, and educational purposes only.
It does not guarantee future performance and should not be considered financial advice.
Please test carefully before using it in any trading decision.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MasayanFX

//@version=6
strategy("Spike EA Trade Strategy", overlay=true, fill_orders_on_standard_ohlc=true, pyramiding=0)

// Inputs
spikeThreshold = input.float(0.5, "Spike Threshold", minval=0.0, step=0.1)
spikeBar       = input.int(1, "Spike Bar", minval=0)
priceUnit      = input.float(1.0, "Price Unit for Threshold", minval=0.00001, step=0.1)

stopDistance = input.float(4.0, "Stop Loss Price Distance", minval=0.0)
takeDistance = input.float(5.0, "Take Profit Price Distance", minval=0.0)

showBg      = input.bool(true, "Show Signal Background")
showSignals = input.bool(false, "Show Additional Signals")

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

// Entry Logic
isSpike = spikeRange >= threshold

buySignal  = isSpike and spikeClose > spikeOpen
sellSignal = isSpike and spikeClose <= spikeOpen

// Orders
if buySignal
    if strategy.position_size < 0
        strategy.close("Short")
    else if strategy.position_size == 0
        strategy.entry("Long", strategy.long)

if sellSignal
    if strategy.position_size > 0
        strategy.close("Long")
    else if strategy.position_size == 0
        strategy.entry("Short", strategy.short)

// Exit Logic
if strategy.position_size > 0
    strategy.exit("Long Exit", "Long", stop=strategy.position_avg_price - stopDistance, limit=strategy.position_avg_price + takeDistance)

if strategy.position_size < 0
    strategy.exit("Short Exit", "Short", stop=strategy.position_avg_price + stopDistance, limit=strategy.position_avg_price - takeDistance)

// Plot Lines
plot(threshold, "Spike Threshold", display=display.data_window)

// Background
bgcolor(showBg and buySignal ? color.new(color.rgb(0, 120, 255), 94) : na)
bgcolor(showBg and sellSignal ? color.new(color.rgb(255, 70, 90), 94) : na)

// Optional Signals
plotshape(showSignals and buySignal, title="Buy Signal", style=shape.triangleup, location=location.belowbar, color=buyColor, size=size.tiny)
plotshape(showSignals and sellSignal, title="Sell Signal", style=shape.triangledown, location=location.abovebar, color=sellColor, size=size.tiny)
````
