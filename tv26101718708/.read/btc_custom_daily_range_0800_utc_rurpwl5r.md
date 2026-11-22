# BTC Custom Daily Range (08:00 UTC)

- url: https://www.tradingview.com/script/RURpwL5r-BTC-Custom-Daily-Range-08-00-UTC/
- type: indicator
- pine_id: PUB;b8b9dd0c36974c2890185cdc21fc9b43
- version: 1.0

## Description

This script Marks the session from 08:00 UTC (1:30 PM IST) to 08:00 UTC next day Calculates high − low within that window Prints it as a table on chart. May be useful for traders keen on option selling, to choose the right contracts and gain from probable theta decay

## Source Code

````pine
//@version=6
indicator("BTC Custom Daily Range (08:00 UTC)", overlay=true)

//---------------------------
// SETTINGS
//---------------------------
sessionStartHour = 8      // UTC
sessionStartMin  = 0

//---------------------------
// VARIABLES
//---------------------------
var float sessHigh = na
var float sessLow  = na

var table t = table.new(position.top_right, 2, 16, border_width = 1)

var ranges = array.new_float()
var dates  = array.new_string()

//---------------------------
// DETECT NEW SESSION
//---------------------------

newSession = (hour(time, "UTC") == sessionStartHour and minute(time, "UTC") == sessionStartMin)

if newSession

    // Store previous session
    if not na(sessHigh)

        rng = sessHigh - sessLow

        array.unshift(ranges, rng)

        d = str.format("{0,date,dd-MMM}", time)

        array.unshift(dates, d)

        if array.size(ranges) > 14
            array.pop(ranges)
            array.pop(dates)

    // Reset
    sessHigh := high
    sessLow := low

else

    sessHigh := math.max(sessHigh, high)
    sessLow := math.min(sessLow, low)

//---------------------------
// DRAW SESSION HIGH LOW
//---------------------------

plot(sessHigh, color=color.green, linewidth=1)
plot(sessLow, color=color.red, linewidth=1)

//---------------------------
// TABLE
//---------------------------

if barstate.islast

    table.clear(t,0,0)

    table.cell(t,0,0,"Date",bgcolor=color.blue,text_color=color.white)

    table.cell(t,1,0,"Range",bgcolor=color.blue,text_color=color.white)

    maxRows = math.min(array.size(ranges),14)

    for i=0 to maxRows-1

        table.cell(t,0,i+1,array.get(dates,i))

        table.cell(
             t,
             1,
             i+1,
             str.tostring(math.round(array.get(ranges,i))),
             text_color=color.yellow)
````
