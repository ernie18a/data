# MACD River Strategy

- url: https://www.tradingview.com/script/kSxDplwf/
- type: strategy
- pine_id: PUB;zrcW2yyW5G0f8YkYrPLbdASuBJdBH2KI
- version: 1.0

## Description

It uses two MACD filter values instead of one increasing the profits

## Source Code

````pine
//@version=3
//MACD River is an MACD extention 
//It uses two signal filter values, creating a open channel (like a river)  where no operation occurs.
//
//by @Aldovitch [br]
//
strategy("MACD River Strategy", overlay=true)

fastLength = input(12)
slowlength = input(26)
MACDLength = input(9)

longBorder = input(1)
shortBorder = input(-1)

MACD = ema(close, fastLength) - ema(close, slowlength)
aMACD = ema(MACD, MACDLength)
delta = MACD - aMACD

if (crossover(delta, longBorder))
    strategy.entry("MACD River Long Entry", strategy.long, comment="macdRiver Buy")
    
if (crossunder(delta, shortBorder))
    strategy.entry("MACD River Short Entry", strategy.short, comment="macdRiver Sell")

//plot(strategy.equity, title="equity", color=red, linewidth=2, style=areabr)
````
