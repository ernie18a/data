# Stochastic RSI Reversal Signals abhishek

- url: https://www.tradingview.com/script/sii5mbjt-Stochastic-RSI-Reversal-Signals-abhishek/
- type: indicator
- pine_id: PUB;76092c99db07456dac21e8cc5e6ec84a
- version: 1.0

## Description

its a stochastic indicator on chart when it reaches 85 and 15 for entry exit trades

## Source Code

````pine
//@version=5
indicator("Stochastic RSI Reversal Signals", overlay=true)

// ===== Stochastic RSI Settings =====
rsiLength = 14
stochLength = 14
kLength = 3
dLength = 3

// ===== Calculate Stochastic RSI =====
rsiValue = ta.rsi(close, rsiLength)

stochRSI = ta.stoch(rsiValue, rsiValue, rsiValue, stochLength)

k = ta.sma(stochRSI, kLength)
d = ta.sma(k, dLength)

// ===== Reversal Conditions =====

// Overbought reversal near 85
sellSignal = ta.crossunder(k, d) and k >= 85

// Oversold reversal near 15
buySignal = ta.crossover(k, d) and k <= 15

// ===== Buy Signal =====
plotshape(buySignal,
     title="BUY Reversal",
     location=location.belowbar,
     style=shape.labelup,
     color=color.lime,
     text="BUY",
     textcolor=color.black,
     size=size.small)

// ===== Sell Signal =====
plotshape(sellSignal,
     title="SELL Reversal",
     location=location.abovebar,
     style=shape.labeldown,
     color=color.red,
     text="SELL",
     textcolor=color.white,
     size=size.small)

// ===== Alerts =====
alertcondition(buySignal,
     title="BUY Reversal Alert",
     message="Stochastic RSI reversal from 15 level")

alertcondition(sellSignal,
     title="SELL Reversal Alert",
     message="Stochastic RSI reversal from 85 level")
````
