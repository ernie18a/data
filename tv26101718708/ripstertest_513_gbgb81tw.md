# RipsterTest 5-13

- url: https://www.tradingview.com/script/gBGb81Tw-RipsterTest-5-13/
- type: strategy
- pine_id: PUB;uQ7hxUyqmyhOFFld3N94OXxodnmhjyKB
- version: 1.0

## Description

5-13 cross on 30 min

## Source Code

````pine
//@version=4
strategy("RipsterTest", overlay=true)

ema5=ema(close,5)
ema13=ema(close,13)

long = ema5 > ema13
short = strategy.openprofit >300

strategy.entry ("long",strategy.long,1000,when=long)
//strategy.entry ("short",strategy.short,1000,when=short)

strategy.close("long",when=short)
//strategy.close("short",when=long)
````
