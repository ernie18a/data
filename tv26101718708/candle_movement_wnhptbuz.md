# Candle Movement % 

- url: https://www.tradingview.com/script/WNHptBUZ-Candle-Movement/
- type: indicator
- pine_id: PUB;7ef5a4e69c7f4ca59eb3b1e9ad183080
- version: 1.0

## Description

Simple script, to show candle movement in percentage on 1D or 1W charts

## Source Code

````pine
//@version=6
indicator("Candle Movement % (Filtered) v6", overlay=true)

// Inputs to customize the look and filter
showLabels   = input.bool(true, title="Show Percentage Labels")
minThreshold = input.float(1.0, title="Minimum % Movement Filter", minval=0.0, step=0.1)
textSize     = input.string(size.small, title="Label Size", options=[size.auto, size.tiny, size.small, size.normal, size.large])
upColor      = input.color(color.green, title="Up Candle Text Color")
downColor    = input.color(color.red, title="Down Candle Text Color")

// Calculate percentage change from Open to Close
candleChangePct = ((close - open) / open) * 100
absChangePct    = math.abs(candleChangePct)

// Determine the placement and color of the label
isUp = close >= open
labelColor = isUp ? upColor : downColor
labelYLocation = isUp ? yloc.abovebar : yloc.belowbar
labelText = str.tostring(absChangePct, "#.##") + "%"

// Plot the label ONLY if it meets or exceeds the user-defined threshold
if showLabels and absChangePct >= minThreshold
    label.new(
         x=bar_index, 
         y=na, 
         text=labelText, 
         yloc=labelYLocation, 
         color=color.new(color.black, 100), // Transparent background
         textcolor=labelColor, 
         style=label.style_none, 
         size=textSize
     )
````
