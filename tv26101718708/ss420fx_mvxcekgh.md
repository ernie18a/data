# SS420FX

- url: https://www.tradingview.com/script/MvXcEkgh-SS420FX/
- type: strategy
- pine_id: PUB;3851
- version: 2.0

## Description

[b]Two Moving_Average cross's & Daily_Candle cross[/b]
Based on Hull_MA
Developed by Alan Hull, it is an indicator, that solves the problem with making a moving average more reactive to current price activity. The Hull Moving Average almost eliminates lag and manages to improve smoothing.
The HMA manages to stick to rapid changes in price activity, as it has superior smoothing over a Simple Moving Average of the same period. The HMA employs Weighted Moving Averages (WMA) and dampens the smoothing effect. It can be calculated as follows:
[b]HMA(n) = WMA(2*WMA(n/2) – WMA(n)), sqrt(n))[/b]

## Source Code

````pine
//@version=3
study("script removed")
plot(close)
````
