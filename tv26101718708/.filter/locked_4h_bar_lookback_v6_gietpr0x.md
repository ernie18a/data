# Locked 4H Bar Lookback v6

- url: https://www.tradingview.com/script/GietPr0x-Locked-4H-Bar-Lookback-v6/
- type: indicator
- pine_id: PUB;d0b01f912b134606b1de9e4d46f26586
- version: 1.0

## Description

4H Lookback Session, this can be used to lock a vertical line with the 4H timeframe

## Source Code

````pine
//@version=6
indicator("Locked 4H Bar Lookback v6", overlay=true)

// Inputs
barsBack = input.int(60, title="4H Bars Lookback", minval=1)
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

// Fetch the open time of the target 4H bar using request.security
target4HTime = request.security(syminfo.tickerid, "240", time[barsBack])

// Persistent variable to store the line ID
var line vLine = na

// Only execute on the very last bar to save performance
if barstate.islast
    // Delete the previous line from the last tick so it moves cleanly
    if not na(vLine)
        line.delete(vLine)
    
    // Draw the vertical line using time coordinates (xloc.bar_time)
    vLine := line.new(x1=target4HTime, y1=low, x2=target4HTime, y2=high, 
                      xloc=xloc.bar_time, extend=extend.both, 
                      color=lineColor, style=lineStyle, width=lineWidth)
````
