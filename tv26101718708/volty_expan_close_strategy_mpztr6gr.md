# Volty Expan Close Strategy

- url: https://www.tradingview.com/script/mPztR6gR-Volty-Expan-Close-Strategy/
- type: strategy
- pine_id: PUB;HoTYvQIdDZh3zFsEZeyqfyigb0th8owr
- version: 1.0

## Description

Volty Expan Close Strategy, didnt really do anything except for change the parameters, would like to use a genetic algo to find the best params but i will leave it like this.

## Source Code

````pine
//@version=4
strategy("Volty Expan Close Strategy", overlay=true)
length = input(11)
numATRs = input(0.55)

atrs = sma(tr, length)*numATRs

if (not na(close[length]))
    strategy.entry("VltClsLE", strategy.long, stop=close+atrs, comment = "VltClsLE")
    strategy.entry("VltClsSE", strategy.short, stop=close-atrs, comment = "VltClsSE")

//plot(strategy.equity, title="equity", color=color.red, linewidth=2, style=plot.style_areabr)
````
