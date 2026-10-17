# EMA x 4

- url: https://www.tradingview.com/script/x2smMcu1-EMA-x-4/
- type: indicator
- pine_id: PUB;eaf227dc7c314757b6f20638afcde1d2
- version: 1.0

## Description

EMA x 4
Intraday - 9
Swing - 21
Trend - 50
Smart Money - 200
For the WYCKS

## Source Code

````pine
//@version=6
indicator(title = 'EMA x 4', shorttitle = 'EMA x 4', overlay = true)
len50 = input.int(9, minval = 1, title = 'Intraday')
src50 = input(close, title = 'Source')
out50 = ta.ema(src50, len50)
plot(out50, title = 'Intraday', color = color.new(#01ff20, 0), linewidth = 1)

len100 = input.int(21, minval = 1, title = 'Swing')
src100 = input(close, title = 'Source')
out100 = ta.ema(src100, len100)
plot(out100, title = 'Swing', color = color.new(#00e2ff, 0), linewidth = 1)

len200 = input.int(50, minval = 1, title = 'Trend')
src200 = input(close, title = 'Source')
out200 = ta.ema(src200, len200)
plot(out200, title = 'Trend', color = color.new(#ffe500, 0), linewidth = 2)

len400 = input.int(200, minval = 1, title = 'Smart Money')
src400 = input(close, title = 'Source')
out400 = ta.ema(src400, len400)
plot(out400, title = 'Smart Money', color = color.new(#ff0000, 0), linewidth = 2)
````
