# Try to go long at a moving average

- url: https://www.tradingview.com/script/9EOcyAJt-Try-to-go-long-at-a-moving-average/
- type: strategy
- pine_id: PUB;QoUhW0jwuJDP4zeEuoK7LzDB6wOzQuJx
- version: 2.0

## Description

A simple experimental strategy that tries to go long at a moving average bounce / support level, and looks for upside.

## Source Code

````pine
//@version=3
strategy("Try to go long at SMA", overlay=true, pyramiding=1000)

ma = sma(close, input(200, title="moving average period"))
bounce = low <= ma and close >= ma

if(bounce)
    strategy.entry("buy", strategy.long, 10, stop=ma)
else
    strategy.cancel("buy")

strategy.exit("stop", "buy", limit=strategy.position_avg_price * 1.1, stop=strategy.position_avg_price * (1 - atr(14)), when=strategy.position_size > 0)

// strategy.close("buy", when=strategy.position_size > 0)
````
