# Inside & Outside Bars

- url: https://www.tradingview.com/script/XWGxvaay-Inside-Outside-Bars/
- type: indicator
- pine_id: PUB;10985613bc10477e86b9c541ff175606
- version: 1.0

## Description

A script for inside and outside bars. The outside bars have been separated between bullish outside bars and bearish outside bars. The script includes provisions to toggle each of the bars on or off, so you can see only the ones you're looking for.

## Source Code

````pine
//@version=6
indicator("Inside Bar + Outside Bars", overlay=true)

showInsideBars = input.bool(true, "Show Inside Bars")
showBullishOutsideBars = input.bool(true, "Show Bullish Outside Bars")
showBearishOutsideBars = input.bool(true, "Show Bearish Outside Bars")

insideBar = high <= high[1] and low >= low[1]
outsideBar = high > high[1] and low < low[1]
bullishOutsideBar = outsideBar and close > open
bearishOutsideBar = outsideBar and close < open

barcolor((showInsideBars and insideBar) ? color.yellow : (showBullishOutsideBars and bullishOutsideBar) ? color.lime : (showBearishOutsideBars and bearishOutsideBar) ? color.red : na)
````
