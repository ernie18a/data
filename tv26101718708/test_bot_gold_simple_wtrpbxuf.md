# TEST BOT GOLD SIMPLE

- url: https://www.tradingview.com/script/wTrpBxuf/
- type: indicator
- pine_id: PUB;aa488d9825834345801cb2d1fc53d985
- version: 1.0

## Description

2026
One system:

Based on real OB 🟡
Filtered SMA 21/200 📊
Integrated MSS/BOS 🧠
Automatic SL/TP 🔥s

## Source Code

````pine
//@version=6
indicator("TEST BOT GOLD SIMPLE", overlay=true)

// === SMA ===
sma21 = ta.sma(close, 21)
sma200 = ta.sma(close, 200)

// === CONDITIONS ===
buySignal = close > sma200 and close > sma21 and close[1] < sma21
sellSignal = close < sma200 and close < sma21 and close[1] > sma21

// === AFFICHAGE ===
plotshape(buySignal, location=location.belowbar, style=shape.labelup, text="BUY")
plotshape(sellSignal, location=location.abovebar, style=shape.labeldown, text="SELL")

// === ALERTES ===
alertcondition(buySignal, "BUY", "BUY GOLD")
alertcondition(sellSignal, "SELL", "SELL GOLD")
````
