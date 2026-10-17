# NOVA TEST TRADING

- url: https://www.tradingview.com/script/uHTXPCov-NOVA-TEST-TRADING/
- type: indicator
- pine_id: PUB;35f77b56c61c4f0e8a2ca97c56b9757c
- version: 1.0

## Description

This is an indicator that helps you to understand the markets

## Source Code

````pine
//@version=5
indicator("NOVA TEST SIGNALS", overlay=true)

// ===== MACD MUY LENTO =====
fastLength = input.int(50, title="MACD Fast Length")
slowLength = input.int(200, title="MACD Slow Length")
signalLength = input.int(20, title="MACD Signal Length")

// ===== MACD =====
[macdLine, signalLine, hist] = ta.macd(close, fastLength, slowLength, signalLength)

// ===== COLOR =====
isBull = hist >= 0

bullColor = color.blue
bearColor = color.red

barcolor(isBull ? bullColor : bearColor)

// ===== CAMBIOS =====
buySignal = isBull and not isBull[1]
sellSignal = not isBull and isBull[1]

// ===== SEÑALES =====
plotshape(buySignal, title="BUY",
     location=location.belowbar,
     color=color.blue,
     textcolor=color.white,
     style=shape.labelup,
     text="BUY")

plotshape(sellSignal, title="SELL",
     location=location.abovebar,
     color=color.red,
     textcolor=color.white,
     style=shape.labeldown,
     text="SELL")

// ===== ALERTAS =====
alertcondition(buySignal, title="BUY", message="MACD bullish trend")
alertcondition(sellSignal, title="SELL", message="MACD bearish trend")
````
