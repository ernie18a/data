# RSI Strategy 

- url: https://www.tradingview.com/script/bOHHYhBt-RSI-Strategy/
- type: strategy
- pine_id: PUB;zGj1YdsHtu9X4hUZ67sJ6RMYsJcxsjiS
- version: 1.0

## Description

simplified labels to "BUY" and "SELL"

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
        strategy.entry("BUY", strategy.long, comment="BUY")
    if (crossunder(vrsi, overBought))
        strategy.entry("SELL", strategy.short, comment="SELL")

//plot(strategy.equity, title="equity", color=color.red, linewidth=2, style=plot.style_areabr)
````
