# X Candles Back Marker

- url: https://www.tradingview.com/script/G3d4KFyE-X-Candles-Back-Marker/
- type: indicator
- pine_id: PUB;fdda0aaaa62c4002a90595f091fa348a
- version: 1.0

## Description

This Pine Script indicator marks a candle that is a selected number of candles back from the current live candle.

You can choose how many candles back to mark, customize the vertical line color, width, and style, and optionally display a label showing the selected distance. The line automatically updates as new candles form, so it always stays fixed at the chosen distance from the current candle.

## Source Code

````pine
//@version=5
indicator("X Candles Back Marker", overlay=true, max_lines_count=500, max_labels_count=500)

//====================
// Inputs
//====================
candlesBack = input.int(5, "Candles Back From Current Candle", minval=0)

showLine    = input.bool(true, "Show Vertical Line")
showLabel   = input.bool(true, "Show Label")

lineColor   = input.color(color.yellow, "Line Color")
lineWidth   = input.int(2, "Line Width", minval=1, maxval=5)
lineStyleIn = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"])

labelColor  = input.color(color.yellow, "Label Color")
textColor   = input.color(color.black, "Label Text Color")

rangeLookback = input.int(300, "Vertical Line Height Lookback", minval=50)

//====================
// Line Style
//====================
lineStyle =
     lineStyleIn == "Solid"  ? line.style_solid  :
     lineStyleIn == "Dashed" ? line.style_dashed :
                               line.style_dotted

//====================
// Persistent Objects
//====================
var line markerLine = na
var label markerLabel = na

//====================
// Logic
//====================
enoughBars = bar_index >= candlesBack

targetBarIndex = bar_index - candlesBack

topPrice = ta.highest(high, rangeLookback)
botPrice = ta.lowest(low, rangeLookback)

targetHigh = high[candlesBack]
targetLow  = low[candlesBack]

// Only draw/update on the latest candle
if barstate.islast and enoughBars
    // Delete old objects
    if not na(markerLine)
        line.delete(markerLine)

    if not na(markerLabel)
        label.delete(markerLabel)

    // Draw vertical line on target candle
    if showLine
        markerLine := line.new(             x1=targetBarIndex,             y1=botPrice,             x2=targetBarIndex,             y2=topPrice,             xloc=xloc.bar_index,             extend=extend.none,             color=lineColor,             width=lineWidth,             style=lineStyle        )

    // Draw label above target candle
    if showLabel
        markerLabel := label.new(             x=targetBarIndex,             y=targetHigh,             text=str.tostring(candlesBack) + " candles back",             xloc=xloc.bar_index,             style=label.style_label_down,             color=labelColor,             textcolor=textColor,             size=size.small        )
````
