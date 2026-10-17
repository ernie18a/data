# ACM22 not repainted

- url: https://www.tradingview.com/script/07bnTGTj-acm22-not-repainted/
- type: strategy
- pine_id: PUB;lIEdqEQoYjyvUxpUuDz33medaYbMT58E
- version: 2.0

## Description

Делал данный скрипт для FORTS.Идеально подойдет тем,кто использует трейлинг стопы.В основе стратегии лежит RSI.Как по мне,хорошая вещь для проверки стратегии и ее оптимизиации.На скрине 50 контрактов,так что не сильно радуйтесь,а просто делите на 50 и получите показатели на 1 контракт.
[url=http://skrinshoter.ru/p/310518/xERSsz.png]
Script make for futures on MICEX.U can change paramets of RSI,traling stop and stop loss .On a ps 50 futures USDollar-russian ruble.Use for testing and optimisation.

## Source Code

````pine
//@version=3
strategy("ACM22", overlay=true)

a = input(10, minval=1, title="RSI lenght")
D = input(70, minval=1, title="High level RSI")
F = input(30, minval=1, title="Low level RSI")
sl = input(60, minval=1, title="Stop loss")
TrP = input(20, minval=1, title="Trail points")
TrO = input(10, minval=1, title="Trail offset")

longCondition = rsi(close,a) > D
if (longCondition)
    strategy.entry("long", strategy.long)
strategy.exit("exit", "long", loss = sl, trail_points = TrP, trail_offset = TrO )
 
shortCondition = rsi(close,a) < F
if (shortCondition)
    strategy.entry("short", strategy.short)
    
strategy.exit("exit", "short",loss = sl, trail_points = TrP, trail_offset = TrO )
````
