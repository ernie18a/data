# rachitjain strategy

- url: https://www.tradingview.com/script/rP81Z3fZ-rachitjain-strategy/
- type: strategy
- pine_id: PUB;QhKKP7jslTCOKZyHvJfqZdfCVUpIHE06
- version: 1.0

## Description

EMA 15 Crosses over or under 50 EMA

## Source Code

````pine
//@version=2
strategy("rachitjain strategy", overlay=true)

reflines= input(50)
crosslines= input(15)
refhigh=ema(high,reflines)
reflow=ema(low,reflines)
refcross=ema(close,crosslines)

if (refcross>reflow and refcross>refhigh)
    strategy.entry("Buy", strategy.long, comment="Buy")

if (refcross<refhigh and refcross<reflow)
    strategy.entry("Sell", strategy.short, comment="Sell")

plot(reflow, title="low ema", color=red, linewidth=1)
plot(refhigh, title="high ema", color=green, linewidth=1)
plot(refcross, title="cross ema", color=orange, linewidth=1)
````
