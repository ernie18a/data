# Another Millionaire tool

- url: https://www.tradingview.com/script/8M4DOa99-Another-Millionaire-tool/
- type: strategy
- pine_id: PUB;l5PJXyO3cGDnWpnbonEaPhfG2QuIIQyY
- version: 1.0

## Description

Back with another Millionaire tool script, put like a solid 12 minutes here curve fitting the moving averages. THIS WILL MAKE YOU A MILLIONAIRE. It is so easy, it makes one of the hardest industries very very easy. Works on any market. I'VE DECIDED TO SHARE THE SCRIPT AND MAKE IT PUBLIC SO WE CAN ALL BE RICH TOGETHER, MILLIONAIRES

## Source Code

````pine
//@version=3
strategy("My Strategy", overlay=true)
in1 = input(4,"Length")
in2 = input(5,"Length 2")

longCondition = crossover(ema(close, in1), ema(close, in2))
if (longCondition)
    strategy.entry("My Long Entry Id", strategy.long)

shortCondition = crossunder(ema(close, in1), ema(close, in2))
if (shortCondition)
    strategy.entry("My Short Entry Id", strategy.short)
````
