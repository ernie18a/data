# Simple EMA20 Strategy + Stochastic

- url: https://www.tradingview.com/script/Tm6chRE1-Simple-EMA20-Strategy-Stochastic/
- type: strategy
- pine_id: PUB;aa40ec4a32724c1e98ff255b4c6ea9aa
- version: 3.0

## Description

This is a Trend Following Strategy.
The intent of this strategy is to catchthe price as it trends higher than the 20-period EMA and sell immediately after the price closes below it.
I have implemented calculations from Stochastic to make sure the price is coming from an oversold area.
There is also a check to see if the 20-period EMA is trending higher than before.

## Source Code

````pine
// ©dragolite95
//@version=5
strategy("Simple EMA20 Strat", overlay=true, margin_long=100, margin_short=100)

// Stochastic
periodK = input.int(14, title="%K Length", minval=1)
smoothK = input.int(1, title="%K Smoothing", minval=1)
periodD = input.int(3, title="%D Smoothing", minval=1)
k = ta.sma(ta.stoch(close, high, low, periodK), smoothK)
d = ta.sma(k, periodD)

// Input for long and short entries
longCheck = input.bool(true, title="Long Entries")
shortCheck = input.bool(true, title="Short Entries")

// EMA
emaLength = input.int(20, title="EMA Period", minval=1)
ema = ta.ema(close, emaLength)

// Plotting EMA on chart
plot(series=ema, title="ema 20", color=color.blue)

// Long
if(longCheck)
    if(low > ema and k > d and ema > ema[20] and barstate.isconfirmed)
        strategy.entry("long", strategy.long)
    if(close < ema)
        strategy.close("long")
    
// Short
if(shortCheck)
    if(high < ema and k < d and ema < ema[20] and barstate.isconfirmed)
        strategy.entry("short", strategy.short)
    if(close > ema)
        strategy.close("short")
````
