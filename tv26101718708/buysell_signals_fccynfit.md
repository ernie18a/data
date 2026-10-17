# Buy/Sell Signals

- url: https://www.tradingview.com/script/FcCYNfIT-Buy-Sell-Signals/
- type: indicator
- pine_id: PUB;4d88f89b8ac249e9974ab22dbe4e00b8
- version: 1.0

## Description

It is going to help you when to buy and when to sell.

## Source Code

````pine
//@version=6
indicator("Buy/Sell Signals", overlay=true)

emaFast  = ta.ema(close, 20)
emaSlow  = ta.ema(close, 50)
emaTrend = ta.ema(close, 200)
rsi      = ta.rsi(close, 14)

buy  = ta.crossover(emaFast, emaSlow)  and close > emaTrend and rsi > 40 and rsi < 70
sell = ta.crossunder(emaFast, emaSlow) and close < emaTrend and rsi < 60 and rsi > 30

plotshape(buy,  title="Buy",  style=shape.labelup,   location=location.belowbar, color=color.green, textcolor=color.white, text="BUY")
plotshape(sell, title="Sell", style=shape.labeldown, location=location.abovebar, color=color.red,   textcolor=color.white, text="SELL")

alertcondition(buy,  title="Buy",  message="BUY signal")
alertcondition(sell, title="Sell", message="SELL signal")
````
