# RSI small trade strategy

- url: https://www.tradingview.com/script/uccqZ4eB-RSI-small-trade-strategy/
- type: strategy
- pine_id: PUB;2695
- version: -1.0

## Description

Trialling a small gains strategy.
Unfortunately it caps out at 2000 trades otherwise I would be improving the maximum loss of stopping out trades once the RSI entered an overbought or oversold region

## Source Code

````pine
//@version=2
strategy("RSI small trade strategy", overlay=true, precision=5, currency="AUD")
length = input( 7 )
overSold = input( 30 )
overBought = input( 70 )
midline = input (50)
price = close

vrsi = rsi(price, length)

//long
strategy.entry("RsiLE", strategy.long, qty=10000,comment="RsiLE", when = crossunder(vrsi, midline) )
//strategy.exit("RsiLE Exit","RsiLE",loss=200)
//short
strategy.entry("RsiSE", strategy.short, qty=10000, comment="RsiSE", when = crossover(vrsi, midline))
//strategy.exit("RsiSE Exit","RsiSE",loss=200)
//strategy.close_all(when = vrsi > overBought or vrsi < overSold)
plot(strategy.equity, title="equity", color=blue, linewidth=2, style=areabr, transp=80)
````
