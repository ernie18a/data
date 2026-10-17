# SMA&RSI Strategy

- url: https://www.tradingview.com/script/b1slRLyF-SMA-RSI-Strategy/
- type: strategy
- pine_id: PUB;ByogVD8OeKkD3PGfujXpGWsZFikgscTe
- version: 1.0

## Description

Just a simple little SMA & RSI Strategy.

Enjoy

## Source Code

````pine
//@version=3
strategy(title="SMA&RSI Strategy", shorttitle="SMARSI", overlay = true, default_qty_type = strategy.percent_of_equity, default_qty_value = 100, commission_value = 0.25)
src = close, len = input(2, minval=1, title="Length")
up = rma(max(change(src), 0), len)
down = rma(-min(change(src), 0), len)
rsi = down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))

fastSMA = sma(close, 5)
slowSMA = sma(close, 200)

longCond = ((rsi < 10) and (close > slowSMA) and (close < fastSMA))
shortCond = ((rsi > 90) and (close < slowSMA) and (close > fastSMA))

if longCond
    strategy.entry('long', strategy.long)
if shortCond
    strategy.entry('short', strategy.short)
````
