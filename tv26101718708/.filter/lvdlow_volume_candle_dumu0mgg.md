# LVD-Low Volume Candle 

- url: https://www.tradingview.com/script/DUmU0MGg-LVD-Low-Volume-Candle/
- type: indicator
- pine_id: PUB;6b1c9cc97a54430aac48ea9a74967112
- version: 1.0

## Description

// Highlight LOW Volume Candle with a Line for Intraday 
// Low Volume candle will move dynamically

## Source Code

````pine
//@version=5
// Highlight LOW Volume Candle with a Line in 5 Min TF 
// Low Volume candle will move dynamically 
// Developed by Deepakz Goel 

indicator("LVD-D1 Line", overlay=true, max_lines_count=50)

isNewDay = ta.change(time("D"))

var float lowestVol = na
var line lowVolLine = na

// Reset on new day
if isNewDay
    lowestVol := volume

    if not na(lowVolLine)
        line.delete(lowVolLine)

    lowVolLine := line.new(
         x1 = bar_index,
         y1 = low,
         x2 = bar_index,
         y2 = high,
         xloc = xloc.bar_index,
         extend = extend.both,
         color = color.blue,
         width = 2,
         style = line.style_solid
     )

// Detect new lowest volume candle
if not isNewDay and volume < lowestVol

    lowestVol := volume

    // Remove previous line
    if not na(lowVolLine)
        line.delete(lowVolLine)

    // Draw new solid vertical line
    lowVolLine := line.new(
         x1 = bar_index,
         y1 = low,
         x2 = bar_index,
         y2 = high,
         xloc = xloc.bar_index,
         extend = extend.both,
         color = color.blue,
         width = 2,
         style = line.style_solid
     )
````
