# RSI(2) Buy/Sell Signal

- url: https://www.tradingview.com/script/hcgOCyDZ-RSI-2-Buy-Sell-Signal/
- type: strategy
- pine_id: PUB;M6FUUCCOviYcnXeoRM3jhdWpLuIkNC92
- version: 1.0

## Description

Long/Short entry signaling based on extreme RSI-2 values. The modeling indicates this a good strategy. It's possible to improve profitability by using discretion to enter trades at a more optimal price (i.e. close of the signaled day rather than the open of the following day) and to let the trades run a little longer, but I have not been successful in scripting those scenarios.

## Source Code

````pine
//@version=2
strategy("RSI(2) Buy/Sell Signal", overlay=true, default_qty_type = strategy.percent_of_equity, default_qty_value = 100)

longEntry() => rsi(close, 2) <= 5 and close >= sma(close,200)
longExit() => high >= ema(close, 10)

strategy.entry(id = "Long", long = true, when = longEntry())
strategy.close(id = "Long", when = longExit())

// short strategy isn't sufficiently effective according to the modeling
shortEntry() => rsi(close, 2) >= 95 and close <= sma(close, 200)
shortExit() => low <= ema(close, 10)

strategy.entry(id = "Short", long = false, when = shortEntry())
strategy.close(id = "Short", when = shortExit())
````
