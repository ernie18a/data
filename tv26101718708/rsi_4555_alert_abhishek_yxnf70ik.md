# RSI 45-55 Alert  abhishek

- url: https://www.tradingview.com/script/YXNf70Ik-RSI-45-55-Alert-abhishek/
- type: indicator
- pine_id: PUB;ad8a9bf1fd014d8c9a320349b905f9f1
- version: 1.0

## Description

hello its a RSI when script is between 45-55 its gets plotted on chart to know sideways market

## Source Code

````pine
//@version=5
indicator("RSI 45-55 Alert", overlay=true)

// RSI
rsiValue = ta.rsi(close, 14)

// Condition
inRange = rsiValue >= 45 and rsiValue <= 55

// Background color
bgcolor(inRange ? color.new(color.yellow, 85) : na)

// Signal mark
plotshape(inRange, style=shape.circle, location=location.belowbar, color=color.orange, size=size.tiny)

// Alert
alertcondition(inRange, title="RSI 45-55 Alert", message="RSI is between 45 and 55")
````
