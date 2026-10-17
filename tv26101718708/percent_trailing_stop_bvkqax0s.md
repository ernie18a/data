# Percent Trailing Stop %

- url: https://www.tradingview.com/script/bVkqAx0s-Percent-Trailing-Stop/
- type: strategy
- pine_id: PUB;gAHrKKp1TBfKK8Jlk8CCogS56OKEawCU
- version: 1.0

## Description

===========
[b]Percent Trailing Stop %[/b]
===========

Another Stop Loss Indicator today - our last Fixed SL/TP script went down quite well, this one is for adding a Percent Trailing Stop from Entry Price to your own strategy.

[i]You can ignore the actual entry/exit orders - they're based on a simple MA cross and are therefore NOT relevant, NOT profitable and NOT recommended![/i]

[b]You should be using this code as a way of adding a % Trailing Stop to your own scripts - hope it helps![/b]

You should also notice that a generally considered [i]losing[/i] strategy (a simple MA cross) could actually become profitable with careful money management - try combining this Trailing Stop script with our [url=https://www.tradingview.com/u/theCrypster/#published-scripts]Fixed Stop/Take Profit[/url] script for really accurate management of your capital.

-----------

Good Luck and Happy Trading!

## Source Code

````pine
// © theCrypster

//@version=4
strategy("Percent Trailing Stop %", overlay=true)

//ENTER SOME SETUP TRADES FOR TSL EXAMPLE
longCondition = crossover(sma(close, 10), sma(close, 20))
if (longCondition)
    strategy.entry("My Long Entry Id", strategy.long)

shortCondition = crossunder(sma(close, 10), sma(close, 20))
if (shortCondition)
    strategy.entry("My Short Entry Id", strategy.short)
    

//TRAILING STOP CODE
trailStop = input(title="Long Trailing Stop (%)", type=input.float, minval=0.0, step=0.1, defval=10) * 0.01

longStopPrice = 0.0
shortStopPrice = 0.0
longStopPrice := if strategy.position_size > 0
    stopValue = close * (1 - trailStop)
    max(stopValue, longStopPrice[1])
else
    0
shortStopPrice := if strategy.position_size < 0
    stopValue = close * (1 + trailStop)
    min(stopValue, shortStopPrice[1])
else
    999999

//PLOT TSL LINES
plot(series=strategy.position_size > 0 ? longStopPrice : na, color=color.red, style=plot.style_linebr, linewidth=1, title="Long Trail Stop", offset=1, title="Long Trail Stop")
plot(series=strategy.position_size < 0 ? shortStopPrice : na, color=color.red, style=plot.style_linebr, linewidth=1, title="Short Trail Stop", offset=1, title="Short Trail Stop")


//EXIT TRADE @ TSL
if strategy.position_size > 0
    strategy.exit(id="Close Long", stop=longStopPrice)
if strategy.position_size < 0
    strategy.exit(id="Close Short", stop=shortStopPrice)
````
