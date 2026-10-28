# 9/21 Cross

- url: https://www.tradingview.com/script/ovNU9l9w-9-21-Cross/
- type: indicator
- pine_id: PUB;0e9d6114e78a480f9840ef5c510e25a8
- version: 1.0

## Description

9/21 cross. The 9 is the trend. Trade on the crosses.

## Source Code

````pine
// © Anthony - 9/21 EMA Cross w/ VWAP
//@version=5
indicator("9/21 Cross", overlay=true)

ema9 = ta.ema(close, 9)
ema21 = ta.ema(close, 21)
vwapVal = ta.vwap

plot(ema9, "EMA 9", color.lime, 2)
plot(ema21, "EMA 21", color.red, 2)
plot(vwapVal, "VWAP", color.orange, 1, plot.style_circles)

if ta.crossover(ema9, ema21)
    label.new(bar_index, low, "GO LONG", style=label.style_label_up, color=color.green, textcolor=color.white, size=size.small)
if ta.crossunder(ema9, ema21)
    label.new(bar_index, high, "GO SHORT", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small)
````
