# Buy/Sell Strat

- url: https://www.tradingview.com/script/6LlBdksu-Buy-Sell-Strat/
- type: strategy
- pine_id: PUB;0009d0ac4e3b4be6ba9be835c2d6f853
- version: 4.0

## Description

This strategy will produce a buy or sell signal when the following criteria are met:

9 EMA crosses 21 EMA
Recently closed candlestick has 15% higher average volume than previous 5 candles
A candlestick reversal pattern
Price crosses 9 EMA

Feel free to use and modify as you see fit. Happy trading!

## Source Code

````pine
//@version=5
//Author: shuby1569
strategy("Buy/Sell Strat", overlay = true, default_qty_value=100, default_qty_type=strategy.fixed)


fastSourceInput = input(close, "Fast EMA Source")
fastLengthInput = input(9, "Fast EMA Length")
slowSourceInput = input(close, "Slow EMA Source")
slowLengthInput = input(21, "Slow EMA Length")

a = ta.ema(fastSourceInput, fastLengthInput)
b = ta.ema(slowSourceInput, slowLengthInput)
crossUp = ta.crossover(a, b)
crossDown = ta.crossunder(a, b)
close_condition_long = close < a
close_condition_short = close > a

float volAvg = 0
for i = 1 to 5
    volAvg := volAvg + volume[i]
volAvg := volAvg / 5

if (crossUp)
    strategy.entry("long", strategy.long, when = ((volume * 0.85) > volAvg and close > a))
    
if (crossDown)
    strategy.entry("short", strategy.short, when = ((volume * 0.85) > volAvg and close < a))
    
if (close_condition_long)
    strategy.close("long")

if (close_condition_short)
    strategy.close("short")

plot(a, title = "Fast EMA", color = color.green)
plot(b, title = "Slow EMA", color = color.blue)
````
