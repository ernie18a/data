# BitCoin Simple Buyer

- url: https://www.tradingview.com/script/R5F9Rf4n-BitCoin-Simple-Buyer/
- type: strategy
- pine_id: PUB;0pcKrUg9TXYImWcPM2OAwMvHvxLaeXrY
- version: 1.0

## Description

Many people asking me: How to find the right time to exit BitCoin long position?  First, ​that comes to mind is Do Not use simple Buy-and-Hold strategy, but make short-term trades. Here is the simple algorithm for D1 or 4H timeframes.

## Source Code

````pine
strategy(title = "BitCoin Simple Buyer")

strategy.entry("buy", true, 1, when = close < close[1] and close > sma(close,15))
strategy.exit("exit", "buy", profit = atr(5)*300, loss = atr(5)*80)

plot(strategy.equity)
````
