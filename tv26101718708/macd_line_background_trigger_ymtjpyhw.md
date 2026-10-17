# MACD Line Background Trigger

- url: https://www.tradingview.com/script/ymtjpYhW-MACD-Line-Background-Trigger/
- type: indicator
- pine_id: PUB;1b602367b8054324baa461a833c4c041
- version: 1.0

## Description

macd having background red when macd line is below 0 and background colour green when macd line is above 0

## Source Code

````pine
//@version=5
indicator("MACD Line Background Trigger", overlay=false)

// Input settings for MACD
fastLength = input.int(12, title="Fast Length")
slowLength = input.int(26, title="Slow Length")
src = input.source(close, title="Source")
signalLength = input.int(9, title="Signal Smoothing")

// Calculate MACD values
[macdLine, signalLine, _] = ta.macd(src, fastLength, slowLength, signalLength)

// Determine background color based on MACD line position
// Green when MACD line is above 0, Red when 0 or below
bgColor = macdLine > 0 ? color.new(color.green, 85) : color.new(color.red, 85)

// Plot the background color
bgcolor(bgColor)

// Plot MACD lines and center line for visual clarity
plot(macdLine, title="MACD Line", color=color.blue, linewidth=2)
plot(signalLine, title="Signal Line", color=color.orange, linewidth=1)
hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dashed)
````
