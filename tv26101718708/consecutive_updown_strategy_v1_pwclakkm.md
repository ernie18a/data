# Consecutive Up/Down Strategy V1

- url: https://www.tradingview.com/script/PWCLAkkM-Consecutive-Up-Down-Strategy-V1/
- type: strategy
- pine_id: PUB;BBzqG2w2Qu2khK5PH3aLlqF6vEXbxhiY
- version: 1.0

## Description

Consecutive Up/Down Strategy V1

## Source Code

````pine
//@version=4
strategy("Consecutive Up/Down Strategy", overlay=true)

consecutiveBarsUp = input(2)
consecutiveBarsDown = input(2)

price = close

ups = 0.0
ups := price > price[1] ? nz(ups[1]) + 1 : 0

dns = 0.0
dns := price < price[1] ? nz(dns[1]) + 1 : 0

if (ups >= consecutiveBarsUp)
    strategy.entry("ConsUpLE", strategy.long, comment="ConsUpLE")
    strategy.exit("ConsUpLE",loss=100)
    
if (dns >= consecutiveBarsDown)
    strategy.entry("ConsDnSE", strategy.short, comment="ConsUpLE")
    strategy.exit("ConsDnSE",loss=100)

//plot(strategy.equity, title="equity", color=color.red, linewidth=2, style=plot.style_areabr)
````
