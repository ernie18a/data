# 5 EMA & 50 EMA Cross 

- url: https://www.tradingview.com/script/0ucyUzuu-5-EMA-50-EMA-Cross/
- type: indicator
- pine_id: PUB;e9cda73963a948fa9af053fc68698045
- version: 1.0

## Description

ITS A 5 AND 50 CROSSOVER 
generally made for scalping when ema cross you can trade with buy or sell

## Source Code

````pine
//@version=5
indicator("5 EMA & 50 EMA Cross", overlay=true)

// EMA calculations
ema5 = ta.ema(close, 5)
ema50 = ta.ema(close, 50)

// Cross conditions
buySignal = ta.crossover(ema5, ema50)
sellSignal = ta.crossunder(ema5, ema50)

// Plot EMAs
plot(ema5, color=color.green, linewidth=2, title="5 EMA")
plot(ema50, color=color.red, linewidth=2, title="50 EMA")

// Buy label
plotshape(buySignal, title="BUY", location=location.belowbar, 
     color=color.lime, style=shape.labelup, text="BUY")

// Sell label
plotshape(sellSignal, title="SELL", location=location.abovebar, 
     color=color.red, style=shape.labeldown, text="SELL")

// Alerts
alertcondition(buySignal, title="Buy Alert", 
     message="5 EMA crossed ABOVE 50 EMA")

alertcondition(sellSignal, title="Sell Alert", 
     message="5 EMA crossed BELOW 50 EMA")
````
