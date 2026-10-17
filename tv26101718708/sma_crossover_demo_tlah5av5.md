# SMA Crossover demo

- url: https://www.tradingview.com/script/tlAh5AV5-SMA-Crossover-demo/
- type: strategy
- pine_id: PUB;GtNXBmiN7ZqXlXRLxQkKXJZxo4it2om3
- version: 1.0

## Description

Hi I'm currently in the process of learning to write a script. Here's a very basic SMA 34/5 crossover script. Is somebody able to help me with adding the following functions to the script.

1. Add an alert and indicator to close a short or long trade whenever any candle touches the SMA 34 line?

2. When a SMA 34/5 Crossover has been executed (a Short Trade condition) add an alert/indicator (Titled “Add”) every time a Green bullish candle has closed.

3. When a SMA 34/5 Crossunder has been executed (a Long Trade condition) add an alert/indicator (Titled “Add) every time a Red bearish candle has closed.

4. To used on 15m/30m/1hr/2hr/4hr/1D/1W timeframe charts?

## Source Code

````pine
//@version=3
strategy("SMA Crossover demo", overlay=true)

shortCondition = crossover(sma(close, 34), sma(close, 4))
if (shortCondition)
    strategy.entry("Sell/Short", strategy.short)

longCondition = crossunder(sma(close, 34), sma(close, 4))
if (longCondition)
    strategy.entry("Buy/Long", strategy.long)
````
