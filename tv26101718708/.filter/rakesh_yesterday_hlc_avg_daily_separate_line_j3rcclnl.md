# Rakesh {Yesterday HLC Avg (Daily Separate Line)}

- url: https://www.tradingview.com/script/J3RcCLnL-Rakesh-Yesterday-HLC-Avg-Daily-Separate-Line/
- type: indicator
- pine_id: PUB;a09e01d3d6c544e6bc80f33ad693ec6a
- version: 1.0

## Description

rakesh script high and low and close avarage concepts

## Source Code

````pine
//@version=5
indicator("Yesterday HLC Avg (Daily Separate Line)", overlay=true)

// detect new day
newDay = ta.change(time("D"))

// yesterday values
yHigh  = request.security(syminfo.tickerid, "D", high[1])
yLow   = request.security(syminfo.tickerid, "D", low[1])
yClose = request.security(syminfo.tickerid, "D", close[1])

// average
avg = (yHigh + yLow + yClose) / 3

// store today's level
var float todayLevel = na

if newDay
    todayLevel := avg

// show only today's session line
plot(todayLevel, style=plot.style_linebr, linewidth=2, color=color.blue)
````
