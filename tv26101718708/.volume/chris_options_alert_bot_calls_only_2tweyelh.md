# Chris Options Alert Bot - Calls Only

- url: https://www.tradingview.com/script/2TweYELh-Chris-Options-Alert-Bot-Calls-Only/
- type: indicator
- pine_id: PUB;46ee6200b77e4cf6a4c6b47d951b45df
- version: 1.0

## Description

new chart reader that i am trying to see if it notifies me correctly.

## Source Code

````pine
//@version=5
indicator("Chris Options Alert Bot - Calls Only", overlay=true)

// Indicators
ema9 = ta.ema(close, 9)
ema20 = ta.ema(close, 20)
ema50 = ta.ema(close, 50)
rsi = ta.rsi(close, 14)
vwap = ta.vwap(close)

volAvg = ta.sma(volume, 20)
volSpike = volume > volAvg * 1.5

prevHigh = request.security(syminfo.tickerid, "D", high[1])
prevLow = request.security(syminfo.tickerid, "D", low[1])

// Buy Call Scalp
buyCallScalp =
     close > vwap and
     ema9 > ema20 and
     rsi >= 50 and rsi <= 72 and
     close > prevHigh and
     volSpike

// Buy Call Swing
buyCallSwing =
     close > ema20 and
     ema20 > ema50 and
     rsi >= 50 and rsi <= 65 and
     volume > volAvg and
     close > prevHigh

// Sell Call Watch
sellCallWatch =
     close < vwap and
     close < ema9 and
     rsi >= 65 and
     volume < volAvg

// Plots
plot(ema9, "EMA 9")
plot(ema20, "EMA 20")
plot(ema50, "EMA 50")
plot(vwap, "VWAP")

plotshape(buyCallScalp, title="Buy Call Scalp", style=shape.labelup, text="CALL SCALP", location=location.belowbar)
plotshape(buyCallSwing, title="Buy Call Swing", style=shape.labelup, text="CALL SWING", location=location.belowbar)
plotshape(sellCallWatch, title="Sell Call Watch", style=shape.labeldown, text="SELL CALL", location=location.abovebar)

// Alerts
alertcondition(buyCallScalp, title="BUY CALL SCALP", message="BUY CALL SCALP: {{ticker}} | Price: {{close}} | Breakout + volume spike | Exp: This Friday or next Friday | Target delta: .35-.60 | Stop: -25% option value")

alertcondition(buyCallSwing, title="BUY CALL SWING", message="BUY CALL SWING: {{ticker}} | Price: {{close}} | Daily trend breakout | Exp: Next Friday preferred | Target delta: .45-.65 | Stop below breakout level")

alertcondition(sellCallWatch, title="SELL CALL WATCH", message="SELL CALL WATCH: {{ticker}} | Price: {{close}} | Weakness/rejection setup | Sell call above resistance only, preferably covered")
````
