# Momentum Strategy Upgrade BTC/USD

- url: https://www.tradingview.com/script/rzmU4qGz-Momentum-Strategy-Upgrade-BTC-USD/
- type: strategy
- pine_id: PUB;nSFoL1BKow2Ot2mkCw0NmBEVdnSyXHyD
- version: 2.0

## Description

Modified Momentum Strategy.

## Source Code

````pine
//@version=4
strategy("Momentum Strategy", overlay=true)
length = input(12)
price = close

momentum(seria, length) =>
    mom = seria - seria[length]
    mom

mom0 = momentum(price, length)
mom1 = momentum( mom0, 1)

ConditionBuy = mom0 > 0 and mom1 > 0 and crossover(ema(close,5),ema(close,10)) and rsi(close,14) > 50
ConditionSell = mom0 < 0 and mom1 < 0 and crossunder(ema(close,5),ema(close,10)) and rsi(close,14) < 50

if (ConditionBuy)
    strategy.entry("MomLE", strategy.long, comment="MomLE")

else
    strategy.cancel("MomLE")

if (ConditionSell)
    strategy.entry("MomSE", strategy.short, comment="MomSE")

else
    strategy.cancel("MomSE")

//plot(strategy.equity, title="equity", color=color.red, linewidth=2, style=plot.style_areabr)
````
