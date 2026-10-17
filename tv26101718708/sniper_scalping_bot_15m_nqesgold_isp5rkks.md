# Sniper Scalping Bot 15M (NQ/ES/Gold)

- url: https://www.tradingview.com/script/isp5rkkS-Sniper-Scalping-Bot-15M-NQ-ES-Gold/
- type: strategy
- pine_id: PUB;5df22933f7294611a55ea9b7f2143424
- version: 1.0

## Description

this script tells you H,L, and M for the day. If you read the chart correctly you can never miss. pay attention to the signals but don't take every move .

## Source Code

````pine
//@version=6
strategy("Sniper Scalping Bot 15M (NQ/ES/Gold)", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=10)

// EMAs
ema20 = ta.ema(close, 20)
ema50 = ta.ema(close, 50)
ema200 = ta.ema(close, 200)

// RSI
rsi = ta.rsi(close, 14)

// Trend
bull = close > ema200
bear = close < ema200

// Entries (clean sniper)
longCond = bull and ta.crossover(close, ema20) and rsi > 55
shortCond = bear and ta.crossunder(close, ema20) and rsi < 45

// Risk (tight)
tp = 30
sl = 15

if longCond
    strategy.entry("Long", strategy.long)
    strategy.exit("TP/SL Long", from_entry="Long", profit=tp, loss=sl)

if shortCond
    strategy.entry("Short", strategy.short)
    strategy.exit("TP/SL Short", from_entry="Short", profit=tp, loss=sl)


// Visuals
plot(ema20, color=color.blue)
plot(ema50, color=color.orange)
plot(ema200, color=color.red)
````
