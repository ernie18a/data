# NQ EMA VWAP Strategy

- url: https://www.tradingview.com/script/0mSobwAz-NQ-EMA-VWAP-Strategy/
- type: strategy
- pine_id: PUB;4b8d3d0f8aa54aab9481ee80b1f7912c
- version: 1.0

## Description

LONG:

Price above VWAP
EMA 20 crosses above EMA 50

SHORT:

Price below VWAP
EMA 20 crosses below EMA 50

## Source Code

````pine
//@version=5
strategy("NQ EMA VWAP Strategy", overlay=true)

// Indicators
ema20 = ta.ema(close, 20)
ema50 = ta.ema(close, 50)
vwap = ta.vwap(close)

// Conditions
longCondition = ema20 > ema50 and ema20[1] <= ema50[1] and close > vwap
shortCondition = ema20 < ema50 and ema20[1] >= ema50[1] and close < vwap

// Entries
if (longCondition)
    strategy.entry("Long", strategy.long)

if (shortCondition)
    strategy.entry("Short", strategy.short)

// Plots
plot(ema20)
plot(ema50)
plot(vwap)
````
