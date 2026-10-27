# PDH Breakout alert

- url: https://www.tradingview.com/script/n8Ukm2rt-PDH-Breakout-alert/
- type: indicator
- pine_id: PUB;9188b98365af49d1a43479fdce6c058a
- version: 1.0

## Description

previous day break alert it alerts the chart candle closes previous day high .

## Source Code

````pine
//@version=6
indicator("PDH Breakout", overlay=true)

// Previous Day High
pdh = request.security(syminfo.tickerid, "D", high[1])

// Breakout condition
pdhBreakout = close > pdh and close[1] <= pdh

// Plot PDH
plot(pdh, title="Previous Day High", color=color.orange, linewidth=2)

// Mark breakout signals
plotshape(pdhBreakout, title="PDH Breakout", location=location.belowbar,
     color=color.green, style=shape.triangleup, size=size.small)

// Alert
alertcondition(pdhBreakout, title="PDH Breakout Alert",
     message="Price broke above Previous Day High")
````
