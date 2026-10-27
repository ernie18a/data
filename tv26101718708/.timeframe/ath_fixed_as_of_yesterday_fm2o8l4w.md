# ATH Fixed As Of Yesterday

- url: https://www.tradingview.com/script/fM2o8L4w-ATH-Fixed-As-Of-Yesterday/
- type: indicator
- pine_id: PUB;fa6904be46a549efbb2b84c282b2580d
- version: 2.0

## Description

Allows you see previous all time high when all time high is broken , takes all time of yesterday so that it isnt constantly moving.

## Source Code

````pine
//@version=5
indicator("MNQ ATH Fixed As Of Yesterday (Locked Anchor)", overlay=true)

// Inputs
lineColor  = input.color(color.red, title="Prior ATH Line Color")
lineWidth  = input.int(2, title="Line Width", minval=1)
textColor  = input.color(color.white, title="Text Color")
textOffset = input.int(40, title="Right Margin Label Offset (Bars)", minval=5, step=5)

// Persistent variables
var float macroATH = na

// 1. Tracks the lifetime highest point strictly on historical candles
if not barstate.isrealtime
    macroATH := na(macroATH) ? high : math.max(high, macroATH)

// 2. Request historical ceiling.
historicalATH = request.security(syminfo.tickerid, "D", macroATH, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
validATH = nz(historicalATH, macroATH)

// 3. Use Plot instead of Line Drawings (Plots never disappear and don't lag)
plot(validATH, title="ATH Line", color=lineColor, linewidth=lineWidth, style=plot.style_line)

// 4. Handle the Right Margin Label safely so it updates and stays visible
var label athLabel = label.new(x=bar_index + textOffset, y=na, text="", xloc=xloc.bar_index, color=color.new(color.black, 100), textcolor=textColor, style=label.style_label_left, size=size.normal)

if barstate.islast and not na(validATH)
    label.set_xy(athLabel, bar_index + textOffset, validATH)
    label.set_text(athLabel, "PATH: " + str.tostring(validATH, "#.##"))
````
