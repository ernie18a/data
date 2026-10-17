# BTC Tops And Bodems

- url: https://www.tradingview.com/script/1AUqJady-BTC-Tops-And-Bodems/
- type: indicator
- pine_id: PUB;0b51b249ded54be88a709fc4cbd77253
- version: 1.0

## Description

find top and bothems fast in de 1 week chart more accurate than the 2 weeks

## Source Code

````pine
//@version=5
indicator("BTC RSI Bodems", overlay=false, max_labels_count=500, max_lines_count=500)

src = input.source(close, "Source")
rsiLen = input.int(14, "RSI Length", minval=1)
pivotLen = input.int(5, "Pivot Length", minval=1, maxval=20)
showRSI = input.bool(true, "Show RSI")
showLevels = input.bool(true, "Show Levels")

rsi = ta.rsi(src, rsiLen)

pivotLow = not na(ta.pivotlow(rsi, pivotLen, pivotLen))
pivotHigh = not na(ta.pivothigh(rsi, pivotLen, pivotLen))

bottom = pivotLow and rsi[pivotLen] < 40
top = pivotHigh and rsi[pivotLen] > 70

plot(showRSI ? rsi : na, "RSI", color=color.new(color.blue, 0), linewidth=2)
plot(showLevels ? 70 : na, "Overbought", color=color.new(color.red, 0), linewidth=1)
plot(showLevels ? 50 : na, "Midline", color=color.new(color.gray, 0), linewidth=1)
plot(showLevels ? 40 : na, "Oversold", color=color.new(color.green, 0), linewidth=1)

plot(bottom ? rsi[pivotLen] : na, title="Bottom", style=plot.style_circles, color=color.new(color.green, 0), linewidth=6, offset=-pivotLen)
plot(top ? rsi[pivotLen] : na, title="Top", style=plot.style_circles, color=color.new(color.red, 0), linewidth=6, offset=-pivotLen)
````
