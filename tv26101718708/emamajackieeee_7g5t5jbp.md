# EMA/MA[jackieeee]

- url: https://www.tradingview.com/script/7g5t5jbp-EMA-MA-jackieeee/
- type: indicator
- pine_id: PUB;e355e33dde654c169eb01d3f0e16527a
- version: 1.0

## Description

Description

This indicator combines multiple EMAs and SMAs in one overlay, allowing traders to track short-, medium-, and long-term trend structure on a single chart. It includes six EMAs and five simple moving averages, each with customizable lengths and sources, making it useful for trend confirmation, dynamic support and resistance, and overall market structure analysis.

## Source Code

````pine
//@version=6
indicator(title = 'EMA/MA[jackieeee]', shorttitle = 'EMA/MA[jackieee]', overlay = true)
len1 = input.int(21, minval = 1, title = 'EMA 1')
len2 = input.int(55, minval = 1, title = 'EMA 2')
len3 = input.int(100, minval = 1, title = 'EMA 3')
len4 = input.int(200, minval = 1, title = 'EMA 4')
len5 = input.int(300, minval = 1, title = 'EMA 5')
len6 = input.int(400, minval = 1, title = 'EMA 6')
len7 = input.int(11, minval = 1, title = 'MA 1')
len8 = input.int(23, minval = 1, title = 'MA 2')
len9 = input.int(25, minval = 1, title = 'MA 3')
len10 = input.int(39, minval = 1, title = 'MA 4')
len11 = input.int(200, minval = 1, title = 'MA 5')

src1 = input(close, title = 'EMA 1 Source')
src2 = input(close, title = 'EMA 2 Source')
src3 = input(close, title = 'EMA 3 Source')
src4 = input(close, title = 'EMA 4 Source')
src5 = input(close, title = 'EMA 5 Source')
src6 = input(close, title = 'EMA 6 Source')
src7 = input(close, title = 'MA 1 Source')
src8 = input(close, title = 'MA 2 Source')
src9 = input(close, title = 'MA 3 Source')
src10 = input(close, title = 'MA 4 Source')
src11 = input(close, title = 'MA 5 Source')

ema1 = ta.ema(src1, len1)
ema2 = ta.ema(src2, len2)
ema3 = ta.ema(src3, len3)
ema4 = ta.ema(src4, len4)
ema5 = ta.ema(src5, len5)
ema6 = ta.ema(src6, len6)
ma1 = ta.sma(src7, len7)
ma2 = ta.sma(src8, len8)
ma3 = ta.sma(src9, len9)
ma4 = ta.sma(src10, len10)
ma5 = ta.sma(src11, len11)

plot(ema1, color = color.new(color.yellow, 0), linewidth = 2, title = 'EMA 1')
plot(ema2, color = color.new(color.lime, 0), linewidth = 2, title = 'EMA 2')
plot(ema3, color = color.new(color.aqua, 0), linewidth = 2, title = 'EMA 3')
plot(ema4, color = color.new(color.purple, 0), linewidth = 2, title = 'EMA 4')
plot(ema5, color = color.new(color.aqua, 0), linewidth = 2, title = 'EMA 5')
plot(ema6, color = color.new(color.purple, 0), linewidth = 2, title = 'EMA 6')
plot(ma1, color = color.new(color.orange, 0), linewidth = 2, title = 'MA 1')
plot(ma2, color = color.new(color.purple, 0), linewidth = 2, title = 'MA 2')
plot(ma3, color = color.new(color.green, 0), linewidth = 2, title = 'MA 3')
plot(ma4, color = color.new(color.red, 0), linewidth = 2, title = 'MA 4')
plot(ma5, color = color.new(color.yellow, 0), linewidth = 2, title = 'MA 5')
````
