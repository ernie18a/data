# IPO Day High Line (<= 1000 Trading Days)

- url: https://www.tradingview.com/script/HJ56DZm5-IPO-Day-High-Line-1000-Trading-Days/
- type: indicator
- pine_id: PUB;8ea384a509fd4e83a92ce65f6fe1992b
- version: 1.0

## Description

This script is about the stocks listed in the last 1000 trading days. It searches for the highest price point on the listing's day and draws a horizontal line.

It is assumed that newly listed stocks have completed their base formation once they cross the highest price point of day one. It is useful for traders when the stock is listed in the last 1000 Days. I have kept it simple; feedback and improvements appreciated. 

Since we are looking for 1st Day's high, it works better on daily timeframe.

## Source Code

````pine
//@version=5
indicator("IPO Day High Line (<= 1000 Trading Days)", overlay=true, max_lines_count=1)

maxDays = input.int(1000, "Maximum trading days since listing", minval=1)

// Variables to store first available bar info
var float listingDayHigh = na
var int listingBarIndex = na
var line ipoHighLine = na

// Capture the first available bar on the chart/symbol
if barstate.isfirst
    listingDayHigh := high
    listingBarIndex := bar_index

// Total number of bars available from listing to current bar
barsSinceListing = bar_index - listingBarIndex + 1
isRecentListing = barsSinceListing <= maxDays

// Draw/update the horizontal line only for stocks listed within last 750 trading days
if barstate.islast
    if not na(ipoHighLine)
        line.delete(ipoHighLine)

    if isRecentListing and not na(listingDayHigh)
        ipoHighLine := line.new(
             x1 = listingBarIndex,
             y1 = listingDayHigh,
             x2 = bar_index,
             y2 = listingDayHigh,
             extend = extend.right,
             color = color.orange,
             width = 3
         )
````
