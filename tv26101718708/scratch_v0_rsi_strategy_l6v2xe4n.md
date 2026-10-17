# scratch v0 RSI Strategy

- url: https://www.tradingview.com/script/l6v2XE4n-scratch-v0-rsi-strategy/
- type: strategy
- pine_id: PUB;JekmjngVMpSSiijfaIQ0AdetySndijbM
- version: 1.0

## Description

scratch v0 RSI Strategy use with alerts

## Source Code

````pine
//@version=3
strategy("RSI Strategy", overlay=true, default_qty_value=1000000, pyramiding=100)
length = input( 7 )
overSold = input( 30 )
overBought = input( 70 )
price = close

vrsi = rsi(price, length)

if (not na(vrsi))
    if (crossover(vrsi, overSold))
        strategy.entry("RsiLE", strategy.long, comment="RsiLE")
    if (crossunder(vrsi, overBought))
        strategy.entry("RsiSE", strategy.short, comment="RsiSE")

//plot(strategy.equity, title="equity", color=red, linewidth=2, style=areabr)
````
