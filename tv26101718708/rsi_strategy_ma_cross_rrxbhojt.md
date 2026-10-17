# RSI Strategy & MA Cross

- url: https://www.tradingview.com/script/rrXBHOjt-RSI-Strategy-MA-Cross/
- type: strategy
- pine_id: PUB;0Gbev51IVkAqteEeaTSQL7cKX3xAFBN9
- version: 1.0

## Description

Combination of two strategy. 
MA Cross strategy is using 2 sma at 9 & 21. It can be configured through the source code.
RSI strategy to decide whether the stock/crypto is currently overbought/oversold.
Useful for quick entry and exit trade.

## Source Code

````pine
//@version=4
strategy("RSI Strategy & MA Cross", overlay=true)
short = sma(close, 9)
long = sma(close, 21)
plot(short, color = color.red)
plot(long, color = color.green)
plot(cross(short, long) ? short : na, style = plot.style_cross, linewidth = 4)

length = input( 14 )
overSold = input( 30 )
overBought = input( 70 )
price = close

vrsi = rsi(price, length)

if (not na(vrsi))
    if (crossover(vrsi, overSold))
        strategy.entry("RsiLE", strategy.long, comment="RsiLongEntry")
    if (crossunder(vrsi, overBought))
        strategy.entry("RsiSE", strategy.short, comment="RsiShortEntry")

//plot(strategy.equity, title="equity", color=color.red, linewidth=2, style=plot.style_areabr)
````
