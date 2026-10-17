# Slow Stochastic OB/OS Strategy

- url: https://www.tradingview.com/script/5A9ic6K5-Slow-Stochastic-OB-OS-Strategy/
- type: strategy
- pine_id: PUB;NVFA72SoFheNjkO7BNNlcNE9jOUm89Bf
- version: 1.0

## Description

Same concept as my Slow RSI strategy script
But in Stoch format

I'm finding that i like Slow Stoch better than Slow RSi


This chart also includes exit guards. 

It's up to you to decide if you want to pyramid or not. This chart is set at pyramid = 3

## Source Code

````pine
strategy(title="Slow Stochastic OB/OS Strategy", overlay=false, pyramiding=0, calc_on_order_fills=true, initial_capital=100000, default_qty_type=strategy.percent_of_equity, currency="USD", default_qty_value=100)

smoothK = input(400, step=5) 
price = input(ohlc4)
SMAsmoothK = input(275, step=5)
k = sma(stoch(price, high, low, smoothK), SMAsmoothK)
plot(k, color=white)


smoothD = input(10, step=2)
d = sma(k, smoothD)
plot(d, color=red)


OB = input(78.5, step=0.5)
OS = input(23, step=0.5)
hline(OB, linewidth=1, color=red)
hline(OS,linewidth=1, color=green)
hline(50,linewidth=1, color=gray)


long = crossover(d, OS)
short = crossunder(d, OB)

strategy.entry("Long", strategy.long, when=long) //_signal or long) //or closeshort_signal)
strategy.entry("Short", strategy.short, when=short) //_signal or short) // or closelong_signal)

//If you want to try to play with exits you can activate these!

closelong = crossover(d, OB)
closeshort = crossunder(d, OS)

strategy.close("Long", when=closelong)
strategy.close("Short", when=closeshort)
````
