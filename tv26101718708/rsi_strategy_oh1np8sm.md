# RSI Strategy

- url: https://www.tradingview.com/script/oh1Np8sM-RSI-Strategy/
- type: strategy
- pine_id: PUB;2rQQwHZnMnmoLgRy6JJzHqHKnofLJDPr
- version: 1.0

## Description

Nothing special in this strategy its just purely and application of RSI in 1hour chart of XAUUSD.

## Source Code

````pine
//@version=4
strategy("RSI Strategy", overlay=true)
length = input( 14 )
overSold = input( 30 )
overBought = input( 70 )
price = close

vrsi = rsi(price, length)

if (not na(vrsi))
    if (crossover(vrsi, overSold))
        strategy.entry("RsiLE", strategy.long, comment="RsiLE")
    if (crossunder(vrsi, overBought))
        strategy.entry("RsiSE", strategy.short, comment="RsiSE")

//plot(strategy.equity, title="equity", color=color.red, linewidth=2, style=plot.style_areabr)
````
