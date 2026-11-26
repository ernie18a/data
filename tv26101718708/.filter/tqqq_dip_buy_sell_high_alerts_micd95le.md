# TQQQ Dip Buy / Sell High Alerts

- url: https://www.tradingview.com/script/Micd95le-TQQQ-Dip-Buy-Sell-High-Alerts/
- type: indicator
- pine_id: PUB;f79fe26ff429434fa4ececad4aa43f79
- version: 1.0

## Description

Buy dips, sell high based on chatgpt. Testing the results.

## Source Code

````pine
//@version=5

indicator("TQQQ Dip Buy / Sell High Alerts", overlay=true)

// Inputs

emaFastLen = input.int(9, "Fast EMA")

emaSlowLen = input.int(20, "Slow EMA")

rsiLen = input.int(14, "RSI Length")

rsiDip = input.int(45, "RSI Dip Zone")

rsiHigh = input.int(70, "RSI Sell High Zone")

// Indicators

ema9 = ta.ema(close, emaFastLen)

ema20 = ta.ema(close, emaSlowLen)

vwap = ta.vwap(close)

rsi = ta.rsi(close, rsiLen)

volAvg = ta.sma(volume, 20)

// Trend conditions

uptrend = close > vwap and ema9 > ema20

strongVolume = volume > volAvg

// Buy dip logic

dipToEma = low <= ema9 and close > ema9

dipToVwap = low <= vwap and close > vwap

bounceCandle = close > open and close > high[1]

// Buy signal

buyDipSignal = uptrend and strongVolume and (dipToEma or dipToVwap) and bounceCandle and rsi > rsiDip

// Sell high logic

extendedAboveEma = close > ema9 * 1.035

rsiOverbought = rsi > rsiHigh

redCandle = close < open

sellHighSignal = uptrend and (extendedAboveEma or rsiOverbought) and redCandle

// Breakdown / stop alert

breakdownSignal = close < vwap or ema9 < ema20

// Plot lines

plot(ema9, "EMA 9")

plot(ema20, "EMA 20")

plot(vwap, "VWAP")

// Plot signals

plotshape(buyDipSignal, title="Buy Dip", style=shape.labelup, text="BUY DIP", location=location.belowbar)

plotshape(sellHighSignal, title="Sell High", style=shape.labeldown, text="SELL HIGH", location=location.abovebar)

plotshape(breakdownSignal, title="Breakdown", style=shape.labeldown, text="EXIT", location=location.abovebar)

// Alerts

alertcondition(buyDipSignal, title="TQQQ Buy Dip", message="TQQQ Buy Dip Signal: price held EMA/VWAP in uptrend with volume.")

alertcondition(sellHighSignal, title="TQQQ Sell High", message="TQQQ Sell High Signal: price extended or RSI overbought.")

alertcondition(breakdownSignal, title="TQQQ Exit / Breakdown", message="TQQQ Exit Signal: price lost VWAP or EMA 9 crossed below EMA 20.")
````
