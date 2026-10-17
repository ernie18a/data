# fx_gy_77

- url: https://www.tradingview.com/script/ODSsYiTg-fx-gy-77/
- type: strategy
- pine_id: PUB;cyC5A6x48WWXJi2XwDQthM2I8xFcCQLT
- version: 1.0

## Description

fx_gy_77

version one of script request to be built

## Source Code

````pine
//@version=4
strategy("fx_gy_77", overlay=false)

isr = stoch(rsi(open,10),high,low,10)

[macdLine, signalLine, histLine] = macd(close, 12, 26, 9)

//plot(macdLine, color=color.blue)
//plot(signalLine, color=color.orange)
//plot(histLine, color=color.red, style=plot.style_histogram)

plot(isr)

longCondition = crossover(signalLine,macdLine)
if (longCondition)
    strategy.entry("My Long Entry Id", strategy.long)

shortCondition = crossunder(signalLine,macdLine)
if (shortCondition)
    strategy.entry("My Short Entry Id", strategy.short)
````
