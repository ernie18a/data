# Simple Sentiment Indicator

- url: https://www.tradingview.com/script/MHmKWj5V-Simple-Sentiment-Indicator/
- type: indicator
- pine_id: PUB;f1fc915539fd4950a09b2684d43f41f9
- version: 1.0

## Description

Indicator Description:  
The Simple Sentiment Indicator is a clean and easy‑to‑use trend‑following tool based on the relationship between price and a simple moving average (SMA). It helps traders quickly identify bullish and bearish sentiment by detecting crossovers between the closing price and the moving average.

When price crosses above the SMA, the indicator highlights a potential bullish shift and displays a BUY label. When price crosses below the SMA, it signals a potential bearish shift and displays a SELL label. Background colors reinforce the sentiment visually, making trend changes easy to spot at a glance.

Key Features:

Simple Moving Average with adjustable length

Automatic BUY and SELL signals based on price crossovers

Background color highlighting bullish and bearish sentiment

Clear visual labels above/below candles

Works on all markets and timeframes

Ideal for beginners and trend‑following strategies

How to Use:

BUY signals appear when price crosses above the SMA

SELL signals appear when price crosses below the SMA

Use the indicator as a trend confirmation tool

Combine with support/resistance, volume, or higher‑timeframe analysis for stronger confluence

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © rauser

//@version=5
indicator("Simple Sentiment Indicator", overlay=true)

// Parametry klouzavého průměru
length = input(14, title="MA Length")
src = close

// Výpočet klouzavého průměru
ma = ta.sma(src, length)

// Generování signálů
longSignal = ta.crossover(src, ma)
shortSignal = ta.crossunder(src, ma)

// Zobrazování signálů na grafu
plot(ma, color=color.blue, title="MA")
bgcolor(longSignal ? color.new(color.green, 90) : na, title="Long Signal")
bgcolor(shortSignal ? color.new(color.red, 90) : na, title="Short Signal")

// Vykreslení šipek
plotshape(longSignal, style=shape.labelup, location=location.belowbar, color=color.green, size=size.small, title="Buy Signal", text="BUY")
plotshape(shortSignal, style=shape.labeldown, location=location.abovebar, color=color.red, size=size.small, title="Sell Signal", text="SELL")
````
