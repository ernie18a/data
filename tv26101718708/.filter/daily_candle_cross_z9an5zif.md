# Daily Candle Cross

- url: https://www.tradingview.com/script/z9AN5ziF-Daily-Candle-Cross/
- type: strategy
- pine_id: PUB;2837
- version: -1.0

## Description

simple cross of daily candle close

## Source Code

````pine
//@version=2
//                     simple cross of daily candle close
//
strategy("DailyCandleCross", shorttitle="DCC", overlay=true, calc_on_order_fills= true, calc_on_every_tick=true, default_qty_type=strategy.percent_of_equity, default_qty_value=75, pyramiding=0)
A=security(tickerid, 'D', close)
B=security(tickerid, 'D', close[1])
C=A>B
if(C)
    strategy.entry("Long", strategy.long)
if(not C)
    strategy.entry("Short", strategy.short)
````
