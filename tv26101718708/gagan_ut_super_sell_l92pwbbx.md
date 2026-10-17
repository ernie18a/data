# Gagan UT Super SELL

- url: https://www.tradingview.com/script/L92PWBBx-Gagan-UT-Super-SELL/
- type: indicator
- pine_id: PUB;243cda25355d44a39099e6b42b56ae6d
- version: 1.0

## Description

[b]Gagan Algo sell starts support from 10 second chart [/b]

## Source Code

````pine
//@version=6
indicator(title = 'Gagan Algo Sell', overlay = true)

// ─── Heikin Ashi Function ───
haClose = (open + high + low + close) / 4
haOpen = 0.0
haOpen := na(haOpen[1]) ? (open + close) / 2 : (haOpen[1] + haClose[1]) / 2
haHigh = math.max(high, math.max(haOpen, haClose))
haLow = math.min(low, math.min(haOpen, haClose))

src = haClose

// ─── Inputs ───
keyvalue = input.float(2, title = 'Key Value', step = 0.5)
atrperiod = input(4, title = 'ATR Period')

// ─── Core Logic ───
xATR = ta.atr(atrperiod)
nLoss = keyvalue * xATR

xATRTrailingStop = 0.0
iff_1 = src > nz(xATRTrailingStop[1], 0) ? src - nLoss : src + nLoss
iff_2 = src < nz(xATRTrailingStop[1], 0) and src[1] < nz(xATRTrailingStop[1], 0) ? math.min(nz(xATRTrailingStop[1]), src + nLoss) : iff_1
xATRTrailingStop := src > nz(xATRTrailingStop[1], 0) and src[1] > nz(xATRTrailingStop[1], 0) ? math.max(nz(xATRTrailingStop[1]), src - nLoss) : iff_2

pos = 0
iff_3 = src[1] > nz(xATRTrailingStop[1], 0) and src < nz(xATRTrailingStop[1], 0) ? -1 : nz(pos[1], 0)
pos := src[1] < nz(xATRTrailingStop[1], 0) and src > nz(xATRTrailingStop[1], 0) ? 1 : iff_3

// ─── Trailing Stop Plot ───
trendColor = pos == 1 ? color.green : pos == -1 ? color.red : color.blue
p1 = plot(xATRTrailingStop, color = trendColor, title = 'Trailing Stop', linewidth = 2)
p2 = plot(src, color = na, editable = false)

// ─── Supertrend-style Fill (between price and trailing stop) ───
fill(p1, p2, color = pos == 1 ? color.new(color.green, 80) : color.new(color.red, 80), title = 'Band Fill')

// ─── Signals ───
buy = ta.crossover(src, xATRTrailingStop)
sell = ta.crossunder(src, xATRTrailingStop)

// ─── Shapes (no text) ───
plotshape(buy, title = 'Buy', style = shape.labelup, location = location.belowbar, color = color.new(color.green, 0), size = size.tiny)
plotshape(sell, title = 'Sell', style = shape.labeldown, location = location.abovebar, color = color.new(color.red, 0), size = size.tiny)

// ─── Bar Color ───
barcolor(src > xATRTrailingStop ? color.green : color.red)

// ─── Alerts ───
alertcondition(buy, title = 'Gagan Algo Buy', message = 'Gagan Algo Buy Signal')
alertcondition(sell, title = 'Gagan Algo Sell', message = 'Gagan Algo Sell Signal')
````
