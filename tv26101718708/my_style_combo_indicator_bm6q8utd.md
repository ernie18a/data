# my Style Combo Indicator

- url: https://www.tradingview.com/script/BM6q8utD-my-Style-Combo-Indicator/
- type: indicator
- pine_id: PUB;644c3080d3a747cc941b3730b8070d14
- version: 1.0

## Description

wtChannelLen = input.int(10, "WT Channel Length")
wtAverageLen = input.int(21, "WT Average Length")
wtMaLen      = input.int(4, "WT Signal Length")

emaFastLen   = input.int(20, "Fast EMA")
emaMidLen    = input.int(50, "Mid EMA")
emaSlowLen   = input.int(200, "Slow EMA")

macdFast     = input.int(12, "MACD Fast")
macdSlow     = input.int(26, "MACD Slow")
macdSignal   = input.int(9, "MACD Signal")

obLevel      = input.int(60, "Overbought")
osLevel      = input.int(-60, "Oversold")

## Source Code

````pine
//@version=5
indicator("Ghost Style Combo Indicator", overlay=false)

// =====================================================
// INPUTS
// =====================================================

wtChannelLen = input.int(10, "WT Channel Length")
wtAverageLen = input.int(21, "WT Average Length")
wtMaLen      = input.int(4, "WT Signal Length")

emaFastLen   = input.int(20, "Fast EMA")
emaMidLen    = input.int(50, "Mid EMA")
emaSlowLen   = input.int(200, "Slow EMA")

macdFast     = input.int(12, "MACD Fast")
macdSlow     = input.int(26, "MACD Slow")
macdSignal   = input.int(9, "MACD Signal")

obLevel      = input.int(60, "Overbought")
osLevel      = input.int(-60, "Oversold")

// =====================================================
// EMA TREND
// =====================================================

emaFast = ta.ema(close, emaFastLen)
emaMid  = ta.ema(close, emaMidLen)
emaSlow = ta.ema(close, emaSlowLen)

bullTrend = emaFast > emaMid and emaMid > emaSlow
bearTrend = emaFast < emaMid and emaMid < emaSlow

// =====================================================
// WAVETREND
// =====================================================

ap  = hlc3
esa = ta.ema(ap, wtChannelLen)
d   = ta.ema(math.abs(ap - esa), wtChannelLen)
ci  = (ap - esa) / (0.015 * d)

wt1 = ta.ema(ci, wtAverageLen)
wt2 = ta.sma(wt1, wtMaLen)

// =====================================================
// MACD
// =====================================================

[macdLine, signalLine, histLine] = ta.macd(close, macdFast, macdSlow, macdSignal)

// =====================================================
// SIGNALS
// =====================================================

buySignal  = ta.crossover(wt1, wt2) and wt1 < osLevel and bullTrend
sellSignal = ta.crossunder(wt1, wt2) and wt1 > obLevel and bearTrend

// =====================================================
// PLOTS
// =====================================================

hline(obLevel, "Overbought", color=color.red)
hline(0, "Middle", color=color.gray)
hline(osLevel, "Oversold", color=color.green)

plot(wt1, color=color.aqua, linewidth=2, title="WT1")
plot(wt2, color=color.orange, linewidth=2, title="WT2")

// Wave Fill
fill(plot(wt1), plot(wt2), color=wt1 > wt2 ? color.new(color.green, 80) : color.new(color.red, 80))

// Buy / Sell Dots
plotshape(buySignal, title="BUY", location=location.bottom, color=color.lime, style=shape.circle, size=size.small)
plotshape(sellSignal, title="SELL", location=location.top, color=color.red, style=shape.circle, size=size.small)

// MACD Histogram
plot(histLine, title="MACD Histogram", style=plot.style_columns,
     color=histLine >= 0 ? color.green : color.red)

// =====================================================
// ALERTS
// =====================================================

alertcondition(buySignal, title="Buy Alert", message="Ghost Combo BUY Signal")
alertcondition(sellSignal, title="Sell Alert", message="Ghost Combo SELL Signal")
````
