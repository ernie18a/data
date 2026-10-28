# Multi TF Oversold Reversal Buy signal

- url: https://www.tradingview.com/script/iEnvfj7v-Multi-TF-Oversold-Reversal-Buy-signal/
- type: indicator
- pine_id: PUB;2d3a5cbf15de4d84b26b9eee12b994e4
- version: 1.0

## Description

Multi Timeframe Oversold Reversal
This indicator identifies high probability buy signals by detecting oversold conditions across four timeframes simultaneously and then confirming the reversal with a momentum shift.
A green arrow labeled "OS" appears below the bar when all four timeframes — 15 minute, 1 hour, 4 hour, and daily — are simultaneously showing RSI below 40. This identifies stocks under heavy selling pressure across all timeframes.
A yellow arrow labeled "BUY" appears only when the 15 minute RSI crosses back above 40 immediately following an oversold bar. This confirms that selling momentum is exhausting and the stock is beginning to turn higher. The buy signal will only ever appear directly after a green oversold arrow ensuring the entry is timed to the earliest point of the reversal.
An alert is included that fires when the BUY condition is triggered allowing you to be notified in real time without watching the chart constantly.
This indicator works best on liquid stocks over $20 with good volume. It is most powerful when the buy signal aligns with a key support level or a bullish candlestick pattern such as a hammer or engulfing candle.

## Source Code

````pine


//@version=6
indicator("Multi TF Oversold Reversal", overlay=true)

rsi_15m = request.security(syminfo.tickerid, "15", ta.rsi(close, 14))
rsi_1h  = request.security(syminfo.tickerid, "60", ta.rsi(close, 14))
rsi_4h  = request.security(syminfo.tickerid, "240", ta.rsi(close, 14))
rsi_1d  = request.security(syminfo.tickerid, "D", ta.rsi(close, 14))

// Oversold condition - all 4 below 40
allOversold = rsi_15m < 40 and rsi_1h < 40 and rsi_4h < 40 and rsi_1d < 40

// Was oversold the previous bar
wasOversold = allOversold[1]

// Reversal - 15min RSI crosses back above 40 AND previous bar was oversold
reversalUp = ta.crossover(rsi_15m, 40) and wasOversold

// Plot green arrow for oversold
plotshape(allOversold, title="Oversold", location=location.belowbar, style=shape.arrowup, color=color.green, size=size.normal, text="OS")

// Plot yellow buy arrow only when previous bar had green arrow
plotshape(reversalUp, title="Buy Signal", location=location.abovebar, style=shape.arrowup, color=color.yellow, size=size.normal, text="BUY")
````
