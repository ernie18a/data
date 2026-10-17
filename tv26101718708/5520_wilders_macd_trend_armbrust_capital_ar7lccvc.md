# 55/20 Wilder's MACD Trend Armbrust Capital

- url: https://www.tradingview.com/script/AR7LCcVC-55-20-Wilder-s-MACD-Trend-Armbrust-Capital/
- type: strategy
- pine_id: PUB;f32a145ec546492982edd4835a0358b6
- version: 1.0

## Description

55/20 Wilder's MACD Trend Armbrust Capital
For CTA analysis of W bar trend, D bar hedge

## Source Code

````pine
//@version=5
strategy("55/20 Wilder's MACD Trend", overlay=true)
fastLength = input(20)
slowLength = input(55)
signalLength = input(10, title="Signal Length")
price = close[0]
mafast = ta.rma(price, fastLength)
maslow = ta.rma(price, slowLength)
if (ta.crossover(mafast, maslow))
	strategy.entry("MA2CrossLE", strategy.long, comment="MA2CrossLE")
if (ta.crossunder(mafast, maslow))
	strategy.entry("MA2CrossSE", strategy.short, comment="MA2CrossSE")
//plot(strategy.equity, title="equity", color=color.red, linewidth=2, style=plot.style_areabr)
````
