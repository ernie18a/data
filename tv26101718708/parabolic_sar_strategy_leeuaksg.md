# Parabolic SAR Strategy

- url: https://www.tradingview.com/script/LeEUakSg-Parabolic-SAR-Strategy/
- type: strategy
- pine_id: PUB;NTUl6d9mfeotEPYd1OczTEPNkAYQNxbq
- version: 2.0

## Description

Really questioning how the trailing stop works in the backtesting framework of tradingview/pinescript, I am sure I would not get the same results with the same strategy in MT4.

## Source Code

````pine
//@version=4
strategy("Parabolic SAR Strategy", overlay=true)

start = input(0.02)
increment = input(0.02)
maximum = input(0.2)

psar = sar(start, increment, maximum)

if (psar >= high)
    strategy.entry("ParLE", strategy.long, stop=psar, comment="ParLE")
    
else
    strategy.cancel("ParLE")

if (psar <= low)
    strategy.entry("ParSE", strategy.short, stop=psar, comment="ParSE")
    
else
    strategy.cancel("ParSE")

//plot(strategy.equity, title="equity", color=color.red, linewidth=2, style=plot.style_areabr)
````
