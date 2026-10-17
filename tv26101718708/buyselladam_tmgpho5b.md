# BUY-SELL-ADAM

- url: https://www.tradingview.com/script/TmgPHO5B-BUY-SELL-ADAM/
- type: strategy
- pine_id: PUB;jYkzVG9vvVRf82IdHtA0dyqcRwijpVUe
- version: 1.0

## Description

The Buy and Sell chart follow  signals overbuy , oversold

## Source Code

````pine


//////// TANG-GIAM

//@version=3
strategy("BUY-SELL-ADAM", overlay=true, default_qty_type = strategy.percent_of_equity, default_qty_value = 10)

maxIdLossPcnt = input(2, "thua toi da (%)", type=float)

strategy.risk.max_intraday_loss(maxIdLossPcnt, strategy.percent_of_equity)

if (close >= open[0.5] and open > close[1])
    strategy.entry("BUY",strategy.long)

if (close <= open[0.7] and open <=close[2])
    strategy.entry("SELL", strategy.short)

//plot(strategy.equity, title="equity", color=red, linewidth=30, style=areabr)
````
