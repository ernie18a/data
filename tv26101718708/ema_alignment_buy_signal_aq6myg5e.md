# EMA Alignment Buy Signal

- url: https://www.tradingview.com/script/Aq6myg5E-EMA-Alignment-Buy-Signal/
- type: indicator
- pine_id: PUB;3d75799b68b64947ab39e0055b0239ee
- version: 1.0

## Description

[b]EMA Alignment Buy Signal
[/b]
This indicator identifies bullish trend alignment using four exponential moving averages: 9 EMA, 20 EMA, 50 EMA, and 200 EMA.

A BUY signal is generated when the full candle is positioned above the 9 EMA and the moving averages are aligned in bullish order:

Low > 9 EMA > 20 EMA > 50 EMA > 200 EMA

This means the candle’s low must be above the 9 EMA, confirming that the entire candle is trading above the fastest EMA. The signal only appears when the condition first becomes true, helping reduce repeated signals during the same trend continuation.

The indicator plots all four EMAs directly on the chart and displays a BUY label below the candle when the bullish alignment condition is met.

Works on the chart timeframe you select. For example, on a 5-minute chart it uses 5-minute EMA values, and on a 1-hour chart it uses 1-hour EMA values.

[b]Included:
[/b][list]
[*]9 EMA
[*]20 EMA
[*]50 EMA
[*]200 EMA
[*]BUY signal label
[*]Alert condition for BUY signals
[/list]

[b]BUY condition:
[/b]Candle Low > 9 EMA > 20 EMA > 50 EMA > 200 EMA

## Source Code

````pine
//@version=6
indicator('EMA Alignment Buy Signal', overlay = true)

ema9 = ta.ema(close, 9)
ema20 = ta.ema(close, 20)
ema50 = ta.ema(close, 50)
ema200 = ta.ema(close, 200)

condition = low > ema9 and ema9 > ema20 and ema20 > ema50 and ema50 > ema200

buySignal = condition and not condition[1]

plot(ema9, title = '9 EMA', color = color.orange)
plot(ema20, title = '20 EMA', color = color.blue)
plot(ema50, title = '50 EMA', color = color.purple)
plot(ema200, title = '200 EMA', color = color.white)

plotshape(buySignal, title = 'Buy Signal', style = shape.labelup, location = location.belowbar, text = 'BUY', color = color.green, textcolor = color.white, size = size.small)

alertcondition(buySignal, title = 'Buy Alert', message = 'BUY: Low > 9 EMA > 20 EMA > 50 EMA > 200 EMA')
````
