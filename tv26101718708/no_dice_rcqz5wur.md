# no dice

- url: https://www.tradingview.com/script/rcqZ5wUR-no-dice/
- type: strategy
- pine_id: PUB;gJ9rbCMyZCX3uG1PaDxhX9PGn5S7ZB99
- version: 1.0

## Description

Allow this strategy to run on it's own and try not to get your emotions involved by manually closing positions. Let the strategy do all the work and you will see good returns every month.

## Source Code

````pine
strategy("no dice")

rsi = rsi(close,15)
sma20 = sma(close,20)
sma200 = sma(close,200)
strategy.entry("Entry Signal",strategy.long, when = open < sma200 + 15 and open > sma20 and rsi < 60 and rsi > 52)
strategy.exit("Exit Signal", loss = 650, profit = 1750)
````
