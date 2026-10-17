# Ribbon Cross Strategy 

- url: https://www.tradingview.com/script/BplsmJNL-Ribbon-Cross-Strategy/
- type: strategy
- pine_id: PUB;100487c3c3394bfb95229d88ecab4ff3
- version: 1.0

## Description

This strategy uses a simple moving-average ribbon crossover system with a customizable entry filter. You can choose whether trades trigger near the fast or slow average, allowing flexibility in capturing early or confirmed trend moves.

It’s best suited for [b]index trading on intraday timeframes[/b], helping identify short-term trend reversals and continuations with clear visual cues and backtestable logic.

## Source Code

````pine
//@version=5
strategy("Ribbon Cross Strategy ", 
     overlay=true, margin_long=100, margin_short=100, initial_capital=100000)

//────────────────────────────
// Inputs
//────────────────────────────
smaFastLen = input.int(8, "Fast SMA Length", minval=1)
smaSlowLen = input.int(34, "Slow SMA Length", minval=1)
useClose   = input.source(close, "Source")

entryNear  = input.string("Fast SMA", "Entry Near", options=["Fast SMA", "Slow SMA"])
tolerance  = input.float(0.002, "Proximity % (0.002 = 0.2%)", step=0.0001)

//────────────────────────────
// SMAs
//────────────────────────────
smaFast = ta.sma(useClose, smaFastLen)
smaSlow = ta.sma(useClose, smaSlowLen)

// Plot
plot(smaFast, color=color.new(color.teal, 0), title="SMA 8", linewidth=2)
plot(smaSlow, color=color.new(color.orange, 0), title="SMA 34", linewidth=2)

//────────────────────────────
// Entry Conditions
//────────────────────────────
longCond  = ta.crossover(smaFast, smaSlow)
shortCond = ta.crossunder(smaFast, smaSlow)

// Proximity logic (choose SMA)
selectedSMA = entryNear == "Fast SMA" ? smaFast : smaSlow
nearSelected = math.abs(close - selectedSMA) / selectedSMA < tolerance

//────────────────────────────
// Strategy Entries
//────────────────────────────
if (longCond and nearSelected)
    strategy.entry("Long", strategy.long)

if (shortCond and nearSelected)
    strategy.entry("Short", strategy.short)

// Optional Exit Rules (Close on opposite signal)
if (ta.crossunder(smaFast, smaSlow))
    strategy.close("Long", comment="Exit Long")

if (ta.crossover(smaFast, smaSlow))
    strategy.close("Short", comment="Exit Short")

//────────────────────────────
// Background color for visual
//────────────────────────────
bgcolor(longCond ? color.new(color.green, 85) : shortCond ? color.new(color.red, 85) : na)
````
