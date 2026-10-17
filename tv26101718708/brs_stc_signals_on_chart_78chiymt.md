# BRS STC Signals on Chart

- url: https://www.tradingview.com/script/78CHIYMt-BRS-STC-Signals-on-Chart/
- type: indicator
- pine_id: PUB;c94c8f9ced824e07828463a61727a216
- version: 1.0

## Description

This indicator displays STC cross with a tiny white cross under candle on chart.

## Source Code

````pine
//@version=6
indicator('Schaff Trend Cycle (Overlay Signals)', shorttitle='STC Signals', overlay=true)

// === Inputs ===
fastLength = input.int(18, 'MACD Fast Length')
slowLength = input.int(33, 'MACD Slow Length')
cycleLength = input.int(5, 'Cycle Length')
d1Length = input.int(3, '1st %D Length')
d2Length = input.int(3, '2nd %D Length')
src = input.source(close, 'Source')
upper = input.int(85, 'Upper Band')
lower = input.int(22, 'Lower Band')

// === STC Calculation (UNCHANGED) ===
macd = ta.rma(src, fastLength) - ta.rma(src, slowLength)
k = nz(fixnan(ta.stoch(macd, macd, macd, cycleLength)))
d = ta.rma(k, d1Length)
kd = nz(fixnan(ta.stoch(d, d, d, cycleLength)))
stc = ta.rma(kd, d2Length)
stc := math.max(math.min(stc, 100), 0)

// === SIGNALS (your exact logic) ===
buySignal  = ta.crossover(stc, lower)
sellSignal = ta.crossunder(stc, upper)

// === PLOT ON CANDLES ===
plotshape(buySignal,  title='BUY',  location=location.belowbar,
     style=shape.cross,   size=size.tiny, color=color.rgb(249, 251, 249))

plotshape(sellSignal, title='SELL', location=location.abovebar,
     style=shape.triangledown, size=size.small, color=color.red)

// === OPTIONAL: STRONG SIGNALS (breakouts) ===
strongBuy  = ta.crossover(stc, upper)
strongSell = ta.crossunder(stc, lower)

plotshape(strongBuy, title='STRONG BUY', location=location.belowbar,
     style=shape.arrowup, size=size.small, color=color.green)

plotshape(strongSell, title='STRONG SELL', location=location.abovebar,
     style=shape.arrowdown, size=size.small, color=color.maroon)

// === OPTIONAL: BAR COLOR ===
barcolor(buySignal ? color.lime : sellSignal ? color.red : na)

// === ALERTS ===
alertcondition(buySignal,  title="STC Buy",  message="STC Buy Signal")
alertcondition(sellSignal, title="STC Sell", message="STC Sell Signal")
````
