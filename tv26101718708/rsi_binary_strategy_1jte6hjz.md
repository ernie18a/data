# RSI Binary Strategy

- url: https://www.tradingview.com/script/1jTE6hJz-RSI-Binary-Strategy/
- type: strategy
- pine_id: PUB;880P5Bq5KjGqKi4yBSpF1zRIZkpFTjBM
- version: 1.0

## Description

Another basic strategy most people learn at the beginning of their trading carreer (like me) is the RSI strategy. This is an adaptation of the built-in RSI strategy for use in binary options. Who knows, maybe one day i will graduate to CFD trading, but my time for trading in general is limited at the moment and I am very much still at the beginning of this entire topic.

The rather specific values for the RSI bounds and length I saved have been developed for the EURUSD short term (5min.) interval, giving the highest amount of winning vs. loosing trades as of the publishing date of this script, which is the only important factor for binary options in my understanding. Use at your own risk.

Feel free to comment, give me pointers and/or recommendations.

## Source Code

````pine
//@version=3
strategy("RSI Binary Strategy", overlay=false, pyramiding=0)
length = input(6)
overSold = input(13)
overBought = input(82)
timeframe = input(title="Timeframe", type=integer, minval=1, defval=3)
price = input(title="Source", type=source, defval=close)

vrsi = rsi(price, length)

// plot rsi and limits
plot(vrsi, title="RSI", linewidth=2, color=purple)
hline(overSold, linestyle=dashed, color=gray, editable=false)
hline(overBought, linestyle=dashed, color=gray, editable=false)

if (not na(vrsi))
    if (crossunder(vrsi, overSold))
        strategy.entry("RSI long", strategy.long)
    if (crossover(vrsi, overBought))
        strategy.entry("RSI short", strategy.short)

bars = barssince(strategy.opentrades == 0)
strategy.close_all(when=(bars>=timeframe))
````
