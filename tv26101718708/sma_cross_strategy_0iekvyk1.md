# SMA Cross strategy

- url: https://www.tradingview.com/script/0ieKVyK1-SMA-Cross-strategy/
- type: strategy
- pine_id: PUB;OdpIzNcgv5DvHhhmQz0TPHxPdVBd292H
- version: 1.0

## Description

This is a simple strategy which is always profitable and trades better than most premium channels and I give it out for free :) 
Working very good on ETHUSDT futures on binance :)

[image]https://www.tradingview.com/x/XaLr1ZBA/[/image]

## Source Code

````pine
//@version=4
strategy(title="SMA Cross strategy", overlay=true)

short = sma(close, 5)
long = sma(close, 34)
plot(short, color=color.red, linewidth=3)
plot(long, color=color.green, linewidth=3)
//plot(cross(short, long) ? short : na, style=plot.style_cross, linewidth=4)

longcondition = crossover(short, long)
shortcondition = crossunder(short, long)


if longcondition
    strategy.entry("long", strategy.long)

if shortcondition
    strategy.entry("short", strategy.short)
````
