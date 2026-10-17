# EMA 21

- url: https://www.tradingview.com/script/xkJj8qVy-EMA-21/
- type: indicator
- pine_id: PUB;d50e615065f44f4f8f0372c7e3f86264
- version: 1.0

## Description

This is a clean, lightweight script that plots the 21-period Exponential Moving Average (EMA) directly on your chart.

## Source Code

````pine
//@version=5
indicator("EMA 21 Indicator", overlay=true)

// הגדרת אורך הממוצע
emaLength = 21

// חישוב ה-EMA
emaValue = ta.ema(close, emaLength)

// פקודת הציור - צבע כחול, עובי 2
plot(emaValue, title="EMA 21", color=color.rgb(0, 173, 0), linewidth=2)

// בונוס: צביעת הרקע כאשר המחיר מעל או מתחת ל-EMA
// bgcolor(close > emaValue ? color.new(color.green, 90) : color.new(color.red, 90))
````
