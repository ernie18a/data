# MNQ ATH Fixed As Of Yesterday (Locked Anchor)

- url: https://www.tradingview.com/script/ckl9uCX5-MNQ-ATH-Fixed-As-Of-Yesterday-Locked-Anchor/
- type: indicator
- pine_id: PUB;5424ecc070da4d9d83c9f196bb92fd4e
- version: 1.0

## Description

updated version where breakout price starting point is static and extends right

## Source Code

````pine
//@version=5
indicator("MNQ ATH Fixed As Of Yesterday (Locked Anchor)", overlay=true)

// Inputs
lineColor  = input.color(color.red, title="Prior ATH Line Color")
lineWidth  = input.int(2, title="Line Width", minval=1)
textColor  = input.color(color.white, title="Text Color")
textOffset = input.int(40, title="Right Margin Label Offset (Bars)", minval=5, step=5)

// Persistent variable to lock the exact bar index where the daily session starts
var int dailyStartBarIndex = na

// Detect the first candle of a new trading day session
if ta.change(time("D"))
    dailyStartBarIndex := bar_index
    na

// 1. Tracks the lifetime highest point strictly on historical candles
var float macroATH = na
if not barstate.islast
    macroATH := na(macroATH) ? high : math.max(high, macroATH)

// 2. Request that fixed historical ceiling to safely use on your lower timeframe chart
fixedATH = request.security(syminfo.tickerid, "D", macroATH, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// 3. Instantiate the line and label containers exactly once so they cannot flash or disappear
var line athLine = line.new(x1=bar_index, y1=fixedATH, x2=bar_index + 1, y2=fixedATH, xloc=xloc.bar_index, color=lineColor, width=lineWidth, style=line.style_solid, extend=extend.right)
var label athLabel = label.new(x=bar_index + textOffset, y=fixedATH, text="", xloc=xloc.bar_index, color=color.new(color.black, 100), textcolor=textColor, style=label.style_label_center, size=size.normal)

// Fallback anchor if the daily start bar index hasn't been logged yet on chart load
startAnchor = na(dailyStartBarIndex) ? bar_index : dailyStartBarIndex

// 4. Smoothly shift coordinates and text on the live tracking candle
if barstate.islast and not na(fixedATH)
    // Update Line (LOCKED FIX: Using startAnchor ensures the left edge never crawls right)
    line.set_xy1(athLine, startAnchor, fixedATH)
    line.set_xy2(athLine, bar_index + 1, fixedATH)
    line.set_color(athLine, lineColor)
    line.set_width(athLine, lineWidth)
    
    // Update Label (Uses the slider input to push deep into the right-hand blank space)
    label.set_xy(athLabel, bar_index + textOffset, fixedATH)
    label.set_text(athLabel, "PATH: " + str.tostring(fixedATH, "#.##"))
    label.set_textcolor(athLabel, textColor)
````
