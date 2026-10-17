# RSI Crossover Strategy 8rookz

- url: https://www.tradingview.com/script/H1lwanOx-RSI-Crossover-Strategy-8rookz/
- type: strategy
- pine_id: PUB;L4s2cVasnJJSbwymYjZXh2f4ZJ6Ji2JF
- version: 1.0

## Description

RSI Crossover Strategy

used to create entry points for increasing relative strength

## Source Code

````pine
//@version=3
strategy("RSI Crossover Strategy 8rookz", overlay=true)
length = input( 13 )
lengthfast = input( 5 )
// overSold = input( 30 )
// overBought = input( 70 )
price = close

vrsi = rsi(price, length)
vrsiFast = rsi(price, lengthfast)

if (not na(vrsi))
    if (crossover(vrsiFast, vrsi))
        strategy.entry("Long", strategy.long, comment="Long")
    if (crossunder(vrsiFast, vrsi))
        strategy.entry("Short", strategy.short, comment="Short")

//plot(strategy.equity, title="equity", color=red, linewidth=2, style=areabr)
````
