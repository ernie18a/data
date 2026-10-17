# BACKTEST TRADING-BOT 

- url: https://www.tradingview.com/script/yuR0orIU-BACKTEST-TRADING-BOT/
- type: strategy
- pine_id: PUB;JXxVMONT3leAanIjSg0N7Q1IVMR0dIov
- version: 1.0

## Description

BACKTEST TRADING-BOT

## Source Code

````pine
//@version=3
strategy("My Strategy", overlay=true)

BuyCondition = crossover(ema(close, 26), ema(close,12))
SellCondition = crossunder(ema(close, 26), ema(close, 12))
plot(ema(close,26),color=blue)
plot(ema(close,12), color=red)
if (BuyCondition)
    strategy.entry("Buy", strategy.long)

if (SellCondition)
    strategy.entry("Sell", strategy.short)
````
