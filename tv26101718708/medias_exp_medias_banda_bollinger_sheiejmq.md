# Medias Exp. - Medias - Banda Bollinger

- url: https://www.tradingview.com/script/sheieJmq/
- type: indicator
- pine_id: PUB;771852d438f448a0bafae390b522a909
- version: 1.0

## Description

Bando de bollinger y medias móviles de 20, 40, 100 y 200

## Source Code

````pine
//@version=6
indicator(shorttitle = 'EMA-MA-BOLLINGER', title = 'Medias Exp. - Medias - Banda Bollinger', overlay = true, timeframe = '')
length = input.int(20, minval = 1)
src = input(close, title = 'Source')
mult = input.float(2.0, minval = 0.001, maxval = 50, title = 'StdDev')
basis = ta.sma(src, length)
dev = mult * ta.stdev(src, length)
upper = basis + dev
lower = basis - dev
offset = input.int(0, 'Offset', minval = -500, maxval = 500)
plot(basis, 'Basis', color = color.new(#872323, 0), offset = offset)
p1 = plot(upper, 'Upper', color = color.new(color.teal, 0), offset = offset)
p2 = plot(lower, 'Lower', color = color.new(color.teal, 0), offset = offset)
fill(p1, p2, title = 'Background', color = color.new(#198787, 95))

len = input.int(9, minval = 1, title = 'Length')
out = ta.ema(src, len)
plot(out, color = color.new(color.blue, 0), title = 'EMA 9', offset = offset)


len1 = input.int(20, minval = 1, title = 'Length')
out1 = ta.ema(src, len1)
plot(out1, color = color.new(color.red, 0), title = 'EMA 20', offset = offset)

len3 = input.int(40, minval = 1, title = 'Length')
out3 = ta.sma(src, len3)
plot(out3, color = color.new(color.black, 0), style = plot.style_cross, linewidth = 2, title = 'MA 40', offset = offset)

len4 = input.int(75, minval = 1, title = 'Length')
out4 = ta.sma(src, len4)
plot(out4, color = color.new(color.orange, 0), style = plot.style_cross, linewidth = 2, title = 'MA 70', offset = offset)

len5 = input.int(200, minval = 1, title = 'Length')
out5 = ta.sma(src, len5)
plot(out5, color = color.new(color.red, 0), linewidth = 3, style = plot.style_cross, title = 'MA 200', offset = offset)
````
