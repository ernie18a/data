# Trend Following Long Only Strategy

- url: https://www.tradingview.com/script/EEn8pjzB-Trend-Following-Long-Only-Strategy/
- type: strategy
- pine_id: PUB;pGYChG0h2RYYCJVfO8Gjzx2rIFn4yepy
- version: 3.0

## Description

This script tries to ride bull trends and stay out of the market in bear trends.

## Source Code

````pine
//@version=4
strategy("Trend Following Long Only Strategy", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=100)

lookback_length = input(200, type=input.integer, minval=1, title="Lookback Length")
smoother_length = input(3, type=input.integer, minval=1, title="Smoother Length")
atr_length = input(10, type=input.integer, minval=1, title="ATR Length")
atr_multiplier = input(0.5, type=input.float, minval=0.0, title="ATR Multiplier")

vola = atr(atr_length) * atr_multiplier
price = sma(close, 3)

l = ema(lowest(low, lookback_length), smoother_length)
h = ema(highest(high, lookback_length), smoother_length)
center = (h + l) * 0.5
upper = center + vola
lower = center - vola
trend = ema(price > upper ? 1 : (price < lower ? -1 : 0), 3)
c1 = trend < 0 ? upper : (trend > 0 ? lower: center)

buy_signal = crossover(trend, 0.0) 
sell_signal = crossunder(trend, 0.0)

strategy.entry("Buy", strategy.long, when=buy_signal)
strategy.close("Buy", when=sell_signal)

phigh = plot(h, color=color.green)
plow = plot(l, color=color.red)
pcenter = plot(center, color=color.black)
pclose = plot(close, transp=100)


clr = trend > 0.0 ? color.green : (trend < -0.0 ? color.red : color.yellow)
fill(pcenter, pclose, color=clr, transp=85)
fill(phigh, pcenter, color=color.green, transp=95)
fill(plow, pcenter, color=color.red, transp=95)
````
