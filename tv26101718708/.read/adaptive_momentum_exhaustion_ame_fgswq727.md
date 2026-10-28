# Adaptive Momentum Exhaustion (AME)

- url: https://www.tradingview.com/script/fGsWQ727-Adaptive-Momentum-Exhaustion-AME/
- type: indicator
- pine_id: PUB;d82c49d6ade3413d82fdaf956b4958e5
- version: 1.0

## Description

Adaptive Momentum Exhaustion (AME) is a trend-following indicator designed to identify high-probability continuation trades while filtering out weak and overextended price movements.

Unlike traditional momentum indicators, AME normalizes momentum using the Average True Range (ATR), making it adaptive to changing market volatility. It combines four key market factors:

- Momentum: Measures the strength of price movement relative to volatility.
- Trend: Uses the 20 EMA and 50 EMA to determine the prevailing market direction.
- Volume: Confirms that price movement is supported by above-average trading activity.
- Exhaustion: Uses RSI and Bollinger Bands to avoid entering trades after the market has become overbought or oversold.

A Buy signal is generated only when bullish momentum is strong, the market is in an uptrend, trading volume is above average, and price is not showing signs of exhaustion.

A Sell signal is generated only when bearish momentum is strong, the market is in a downtrend, trading volume is above average, and price is not showing signs of exhaustion.

The objective of AME is to reduce false signals, avoid late entries, and improve trade quality by waiting for strong, healthy trends instead of chasing exhausted price moves. It is best suited for trending markets and can be applied across stocks, forex, cryptocurrencies, and commodities on multiple timeframes.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ExpertTraderASK

//@version=6
indicator("Adaptive Momentum Exhaustion (AME)", shorttitle="AME", overlay=true)

// === Inputs ===
momLen      = input.int(10, "Momentum Length", minval=1)
atrLen      = input.int(14, "ATR Length", minval=1)
fastLen     = input.int(20, "Fast EMA")
slowLen     = input.int(50, "Slow EMA")
rsiLen      = input.int(14, "RSI Length")
bbLen       = input.int(20, "BB Length")
bbMult      = input.float(2.0, "BB Multiplier")

// === Core Calculations ===
atr = ta.atr(atrLen)

// Normalized Momentum
momentum = (close - close[momLen]) / atr

// Trend Strength
fastEMA = ta.ema(close, fastLen)
slowEMA = ta.ema(close, slowLen)
trendBull = fastEMA > slowEMA
trendBear = fastEMA < slowEMA

// Relative Volume
volFactor = volume / ta.sma(volume, 20)

// Bollinger Bands
basis = ta.sma(close, bbLen)
dev = ta.stdev(close, bbLen) * bbMult
upper = basis + dev
lower = basis - dev

// Exhaustion
rsi = ta.rsi(close, rsiLen)
bullExhaust = rsi > 70 and close > upper
bearExhaust = rsi < 30 and close < lower

// === Entry Rules ===
buySignal =
     momentum > 1.5 and
     trendBull and
     volFactor > 1.2 and
     not bullExhaust

sellSignal =
     momentum < -1.5 and
     trendBear and
     volFactor > 1.2 and
     not bearExhaust

// === Plots ===
plot(fastEMA, color=color.green, linewidth=2, title="Fast EMA")
plot(slowEMA, color=color.orange, linewidth=2, title="Slow EMA")

plotshape(buySignal,
     title="BUY",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.lime,
     size=size.small,
     text="BUY")

plotshape(sellSignal,
     title="SELL",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.small,
     text="SELL")

bgcolor(buySignal ? color.new(color.green,85) :
       sellSignal ? color.new(color.red,85) : na)

// Alerts
alertcondition(buySignal, title="AME Buy", message="Adaptive Momentum Exhaustion BUY")
alertcondition(sellSignal, title="AME Sell", message="Adaptive Momentum Exhaustion SELL")
````
