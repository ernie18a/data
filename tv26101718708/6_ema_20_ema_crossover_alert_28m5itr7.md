# 6 EMA 20 EMA Crossover Alert

- url: https://www.tradingview.com/script/28m5iTr7-6-EMA-20-EMA-Crossover-Alert/
- type: indicator
- pine_id: PUB;cdb6a870490244dead0866b8317a644f
- version: 1.0

## Description

6 EMA 20 EMA Crossover Alert

The 6 EMA / 20 EMA setup is a simple trend-following tool using two exponential moving averages on a chart in TradingView.

The 6 EMA reacts quickly to price and tracks short-term momentum. The 20 EMA moves slower and represents the broader, short-term trend.

When the 6 EMA crosses above the 20 EMA, it suggests momentum is turning bullish. When it crosses below, it signals potential bearish momentum.

In plain English, it’s a quick way to see when short-term price action is starting to overpower the current trend.

## Source Code

````pine
//@version=5
indicator("EMA Cross Alert", overlay=true)

ema6 = ta.ema(close, 6)
ema20 = ta.ema(close, 20)

plot(ema6, color=color.rgb(33, 243, 107))
plot(ema20, color=color.red)

bullCross = ta.crossover(ema6, ema20)
bearCross = ta.crossunder(ema6, ema20)

alertcondition(bullCross, title="Bullish Cross", message="6 EMA crossed ABOVE 20 EMA")
alertcondition(bearCross, title="Bearish Cross", message="6 EMA crossed BELOW 20 EMA")
````
