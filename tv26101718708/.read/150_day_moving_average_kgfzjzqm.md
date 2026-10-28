# 150 Day Moving Average

- url: https://www.tradingview.com/script/kGfZJzqM-150-Day-Moving-Average/
- type: indicator
- pine_id: PUB;b9c5abcb04fa4c58b4ac92ab5c374a1e
- version: 2.0

## Description

Very simple script. Good for Gold historically. Using version 5 script.

## Source Code

````pine
//@version=6
indicator('150 Day Moving Average', overlay = true)

ma150 = request.security(syminfo.tickerid, 'D', ta.sma(close, 150))

plot(ma150, title = '150 Day MA', color = color.fuchsia, linewidth = 2)
````
