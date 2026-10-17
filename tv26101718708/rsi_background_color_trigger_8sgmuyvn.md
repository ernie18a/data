# RSI Background Color Trigger

- url: https://www.tradingview.com/script/8SgMUyVN-RSI-Background-Color-Trigger/
- type: indicator
- pine_id: PUB;00fa2107b5974dd7978316e769e8e6f5
- version: 1.0

## Description

rsi having background colour red when rsi is 50 or goes below 50 and background colour is green when rsi is above 50

## Source Code

````pine
//@version=5
indicator("RSI Background Color Trigger", overlay=false)

// Input settings for RSI
rsiLength = input.int(14, title="RSI Length")
rsiSource = input.source(close, title="RSI Source")

// Calculate RSI
rsiValue = ta.rsi(rsiSource, rsiLength)

// Determine background color based on RSI value
// Green when above 50, Red when 50 or below
bgColor = rsiValue > 50 ? color.new(color.green, 85) : color.new(color.red, 85)

// Plot the background color
bgcolor(bgColor)

// Plot the RSI line and reference levels for visual clarity
plot(rsiValue, title="RSI", color=color.blue, linewidth=2)
hline(70, "Overbought", color=color.gray, linestyle=hline.style_dashed)
hline(50, "Middle Line", color=color.purple, linestyle=hline.style_solid, linewidth=1)
hline(30, "Oversold", color=color.gray, linestyle=hline.style_dashed)
````
