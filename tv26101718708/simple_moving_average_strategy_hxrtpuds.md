# Simple Moving Average Strategy

- url: https://www.tradingview.com/script/hXrtpUdS-Simple-Moving-Average-Strategy/
- type: strategy
- pine_id: PUB;2505
- version: -1.0

## Description

This is a modification of [url=https://www.tradingview.com/script/AssaJmAa-AutoView-MovingAvg-Cross-Video-Attached/][AUTOVIEW] MOVINGAVG CROSS[/url] with different inputs of bar lengths that work with a great average percentage with not much drawdown. I ran the strategy tester with GBPUSD on 1 hour time frame.

## Source Code

````pine

strategy(title="Mbit Moving Average",overlay=true)

length = input(520)
confirmBars = input(27)
price = close
ma = sma(price, length)

bcond = price > ma

bcount = bcond ? nz(bcount[1]) + 1 : 0

scond = price < ma

scount = scond ? nz(scount[1]) + 1 : 0

long =  scount == confirmBars

short = bcount == confirmBars


//Strategy

strategy.entry("long", strategy.long, when=long)

strategy.entry("short",strategy.short, when=short)
````
