# Momentum Line Strategy

- url: https://www.tradingview.com/script/heLIgjIo-Momentum-Line-Strategy/
- type: strategy
- pine_id: PUB;Sdkx0kJpvYkeyYa6A4RomcSCNjVxXswM
- version: 1.0

## Description

I got the idea of an algorithm using a gap, which would behave a bit like RSI, therefore I called it momentum. Don't know if it's very useful or how to improve it,  it can keeps you in trends, however it suffers from whipsawing. My first attempt in programming a strategy.

## Source Code

````pine
//@version=3
strategy("Gap MA", overlay=true)
per=input(35, type=integer, minval=12, step=1)
pp=round(per/3)
a=highest(high,4)
ao=lowest(close[per-2*pp],pp)
A=(a+ao)/2
if open>A 
    strategy.entry("long", true, 1)
else
    strategy.close("long")

if open<A
    strategy.entry("short", false, 1)
else
    strategy.close("short")
plot(A, linewidth=3)
````
