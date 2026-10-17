# EXPANSION MODEL

- url: https://www.tradingview.com/script/Qu5RWcEi-EXPANSION-MODEL/
- type: strategy
- pine_id: PUB;dd419679cbbf48f3899b9672f4e31bfd
- version: 1.0

## Description

Trading algo has been optimized to pin point key areas in the market where large order reside.
Works best with XXXUSD pairs as a trend following model.

## Source Code

````pine
//@version=5
strategy("MACD 21/60 Long & Short Strategy",
     overlay=true,
     initial_capital=10000,
     default_qty_type=strategy.percent_of_equity,
     default_qty_value=10)

// === INPUTS ===
fastLen   = input.int(21, "MACD Fast EMA")
slowLen   = input.int(60, "MACD Slow EMA")
signalLen = input.int(9,  "Signal Length")

// === MACD CALCULATION ===
[macdLine, signalLine, hist] = ta.macd(close, fastLen, slowLen, signalLen)

// === ENTRY CONDITIONS ===
longCondition  = ta.crossover(macdLine, signalLine)
shortCondition = ta.crossunder(macdLine, signalLine)

// === EXIT CONDITIONS ===
exitLong  = ta.crossunder(macdLine, signalLine)
exitShort = ta.crossover(macdLine, signalLine)

// === STRATEGY EXECUTION ===
if longCondition
    strategy.entry("LONG", strategy.long)

if shortCondition
    strategy.entry("SHORT", strategy.short)

if exitLong
    strategy.close("LONG")

if exitShort
    strategy.close("SHORT")

// === VISUALS ===
hline(0, "Zero Line", color=color.gray)

plot(macdLine,   title="MACD (21-60)",   color=color.blue, linewidth=2)
plot(signalLine, title="Signal",         color=color.orange, linewidth=2)

plot(hist,
     title="Histogram",
     style=plot.style_columns,
     color=hist >= 0 ? color.green : color.red)
````
