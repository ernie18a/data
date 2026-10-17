# lokendra Revert-Strategy

- url: https://www.tradingview.com/script/jLA1nKu6-lokendra-Revert-Strategy/
- type: strategy
- pine_id: PUB;m3jvrcoQMEAoxRjSlQ0E95xG42ki9Hvh
- version: 1.0

## Description

this reversal strategy is to be used with hull moving average (9,18) with each intersection shows the the buy-sell point which will give more accuracy when my reversal strategy give candle turning point towards the change of trend indication by showing buy sell point

## Source Code

````pine
//@version=3
strategy("lokendra Reversal Strategy", overlay=true)

leftBars = input(4)
rightBars = input(2)

swh = pivothigh(leftBars, rightBars)
swl = pivotlow(leftBars, rightBars)

swh_cond = not na(swh)

hprice = 0.0
hprice := swh_cond ? swh : hprice[1]

le = false
le := swh_cond ? true : (le[1] and high > hprice ? false : le[1])

if (le)
    strategy.entry("PivRevLE", strategy.long, comment="BUY**", stop=hprice + syminfo.mintick)

swl_cond = not na(swl)

lprice = 0.0
lprice := swl_cond ? swl : lprice[1]


se = false
se := swl_cond ? true : (se[1] and low < lprice ? false : se[1])

if (se)
    strategy.entry("PivRevSE", strategy.short, comment="SELL**", stop=lprice - syminfo.mintick)

//plot(strategy.equity, title="equity", color=red, linewidth=2, style=areabr)
````
