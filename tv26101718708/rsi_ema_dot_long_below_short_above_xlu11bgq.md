# RSI EMA Dot (Long Below / Short Above)

- url: https://www.tradingview.com/script/xLU11bGQ-RSI-EMA-Dot-Long-Below-Short-Above/
- type: indicator
- pine_id: PUB;acf8ea0e9fa94e30ad69e69cac74ff20
- version: 1.0

## Description

RSI EMA Cross Dot Indicator
This indicator identifies potential reversal points by combining RSI extremes with momentum shifts.
A signal is generated when the RSI (14) crosses its EMA (14) after being in an extreme zone:
Long signal (green dot below the candle):
RSI was below 20 (oversold) and then crosses above its EMA.
Short signal (red dot above the candle):
RSI was above 80 (overbought) and then crosses below its EMA.
Dots are plotted directly on the chart:
Long signals appear below the candle
Short signals appear above the candle
This helps highlight potential market reversals after extreme conditions, making it useful for identifying high-probability reaction zones.

## Source Code

````pine
//@version=5
indicator("RSI EMA Dot (Long Below / Short Above)", overlay=true)

rsi = ta.rsi(close, 14)
rsiEma = ta.ema(rsi, 14)

// Extremzonen
wasOversold   = ta.lowest(rsi, 5) < 30
wasOverbought = ta.highest(rsi, 5) > 70

// Cross
bull = ta.crossover(rsi, rsiEma) and wasOversold
bear = ta.crossunder(rsi, rsiEma) and wasOverbought

// Abstand
offset = syminfo.mintick * 30

// Positionen
yLong  = low  - offset   // unter Kerze
yShort = high + offset   // über Kerze

// 🔥 Long (unten)
plot(bull ? yLong : na, style=plot.style_circles, color=color.new(color.lime, 75), linewidth=5)
plot(bull ? yLong : na, style=plot.style_circles, color=color.lime, linewidth=4)

// 🔥 Short (oben)
plot(bear ? yShort : na, style=plot.style_circles, color=color.new(color.red, 60), linewidth=5)
plot(bear ? yShort : na, style=plot.style_circles, color=color.red, linewidth=4)
````
