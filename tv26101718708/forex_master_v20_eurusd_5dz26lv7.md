# Forex Master v2.0 (EUR/USD)

- url: https://www.tradingview.com/script/5Dz26lv7-Forex-Master-v2-0-EUR-USD/
- type: strategy
- pine_id: PUB;2531
- version: -1.0

## Description

This is version 2 of my Forex Master algorithm originally posted here: 
https://www.tradingview.com/script/Figho5B3-Forex-Master-EUR-USD/

[b]BACKTEST CONDITIONS: [/b]
Initial equity = $100,000 (no leverage) 
Order size = 100% of equity 
Pyramiding = disabled 

[b]TRADING RULES: [/b]
Long entry = EMA5(RSI20) cross> 50 
Profit limit = 50 pips 
Stop loss = 50 pips 

Short entry = EMA5(RSI20) cross< 50 
Profit limit = 50 pips 
Stop loss = 50 pips 

Long entry = Short exit 
Short entry = long exit 

[b]DISCLAIMER: [/b]None of my ideas and posts are investment advice. Past performance is not an indication of future results. This strategy was constructed with the benefit of hindsight and its future performance cannot be guaranteed.

## Source Code

````pine
//@version=2
strategy("FX Master v2.0", overlay=true)

price = close

basis = rsi(price, input(20))
rsiema = ema(basis, input(5))

trigger = input(50)

long_profit = input(500)
long_loss = input(500)

short_profit = input(500)
short_loss = input(500)

strategy.entry("enter long", true, when = crossover(rsiema, trigger))
strategy.exit("exit long", "enter long", profit = long_profit, loss = long_loss)

strategy.entry("enter short", false, when = crossunder(rsiema, trigger))
strategy.exit("exit short", "enter short", profit = short_profit, loss = short_loss)
````
