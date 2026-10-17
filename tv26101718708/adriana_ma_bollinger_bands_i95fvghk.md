# Adriana MA + Bollinger Bands

- url: https://www.tradingview.com/script/I95FVGhK-Adriana-MA-Bollinger-Bands/
- type: indicator
- pine_id: PUB;f5d0cd9b0ed24555899c9526498e6f86
- version: 2.0

## Description

Simple Moving Averages 20,40,100,200 and Bollinger Bands

## Source Code

````pine
//@version=5
indicator("Adriana MA + Bollinger Bands", overlay=true)

// === Moving Averages ===
ma20 = ta.sma(close, 20)
ma40 = ta.sma(close, 40)
ma100 = ta.sma(close, 100)
ma200 = ta.sma(close, 200)

// === Plot MAs ===
plot(ma20, color=color.yellow, linewidth=2, title="MA 20")
plot(ma40, color=color.red, linewidth=2, title="MA 40")
plot(ma100, color=color.green, linewidth=2, title="MA 100")
plot(ma200, color=color.purple, linewidth=3, title="MA 200")

// === Bollinger Bands ===
bbLength = input.int(20, title="BB Length")
bbStdDev = input.float(2.0, title="BB StdDev")

basis = ta.sma(close, bbLength)
dev = bbStdDev * ta.stdev(close, bbLength)

upper = basis + dev
lower = basis - dev

// === Plot Bollinger Bands ===
plot(basis, color=color.yellow, linewidth=1, title="BB Basis")
upperPlot = plot(upper, color=color.gray, linewidth=1, title="BB Upper")
lowerPlot = plot(lower, color=color.gray, linewidth=1, title="BB Lower")

fill(upperPlot, lowerPlot, color=color.new(color.gray, 90))
````
