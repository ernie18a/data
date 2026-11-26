# Locked Daily Bar Lookback v6

- url: https://www.tradingview.com/script/IiIteKzH-Locked-Daily-Bar-Lookback-v6/
- type: indicator
- pine_id: PUB;fec9c1b8116f45969749dddfdfa2942e
- version: 1.0

## Description

Locked daily vertical line that can be used to make a session marker on the daily a set amount of bars previous

## Source Code

````pine
//@version=6
indicator("Locked Daily Bar Lookback v6", overlay=true)

// Inputs
barsBack = input.int(60, title="Daily Bars Lookback", minval=1)
lineColor = input.color(color.blue, title="Line Color")
lineWidth = input.int(2, title="Line Width", minval=1)
lineStyleInput = input.string("Dashed", title="Line Style", options=["Solid", "Dashed", "Dotted"])

// Convert selected style string to Pine Script v6 line styles explicitly
var string lineStyle = line.style_dashed
if lineStyleInput == "Solid"
    lineStyle := line.style_solid
else if lineStyleInput == "Dashed"
    lineStyle := line.style_dashed
else
    lineStyle := line.style_dotted

// Fetch the open time of the target Daily bar using request.security ("D" for Daily)
targetDailyTime = request.security(syminfo.tickerid, "D", time[barsBack])

// Persistent variable to store the line ID
var line vLine = na

// Only execute on the very last bar to save performance
if barstate.islast
    // Delete the previous line from the last tick so it moves cleanly
    if not na(vLine)
        line.delete(vLine)
    
    // Draw the vertical line using time coordinates (xloc.bar_time)
    vLine := line.new(x1=targetDailyTime, y1=low, x2=targetDailyTime, y2=high, 
                      xloc=xloc.bar_time, extend=extend.both, 
                      color=lineColor, style=lineStyle, width=lineWidth)
````
