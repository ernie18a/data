# IBD Growth Moving Averages 

- url: https://www.tradingview.com/script/Blg8JqAq-IBD-Growth-Moving-Averages/
- type: indicator
- pine_id: PUB;905f4e5269d648aebb92175d8b2aa6c1
- version: 2.0

## Description

A clean moving average overlay designed for growth stock, momentum, and trend-following traders.

Includes:

* 5-Day SMA (Red)
* 10-Day SMA (Green)
* 21-Day EMA (Blue)
* 50-Day SMA (Gold)
* 200-Day SMA (Purple)

This combination blends short-term trend, intermediate trend, and long-term trend analysis into a single lightweight indicator. Inspired by commonly used moving averages among growth investors, breakout traders, and market timing practitioners.

Designed to reduce chart clutter by combining five widely-followed moving averages into a single indicator slot.

## Source Code

````pine
//@version=6
indicator("Captain MAs", overlay=true)

plot(ta.sma(close, 5), color=color.red, linewidth=2)
plot(ta.sma(close, 10), color=color.green, linewidth=2)
plot(ta.ema(close, 21), color=color.blue, linewidth=2)
plot(ta.sma(close, 50), color=color.rgb(255,215,0), linewidth=2)
plot(ta.sma(close, 200), color=color.purple, linewidth=2)
````
