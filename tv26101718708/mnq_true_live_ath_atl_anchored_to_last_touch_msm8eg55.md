# MNQ True Live ATH & ATL (Anchored to Last Touch)

- url: https://www.tradingview.com/script/Msm8eg55-MNQ-True-Live-ATH-ATL-Anchored-to-Last-Touch/
- type: indicator
- pine_id: PUB;54dbf51116324f0786bfb8df7d54fdb4
- version: 2.0

## Description

current all time high and low starting at touch and extending far right

## Source Code

````pine
//@version=5
indicator("MNQ True Live ATH & ATL (Touch Anchor Fixed)", overlay=true)

// Inputs
athLineColor = input.color(color.green, title="True ATH Line Color")
atlLineColor = input.color(color.red, title="True ATL Line Color")
lineWidth    = input.int(2, title="Lines Width", minval=1)
textColor    = input.color(color.white, title="Text Color")
textOffset   = input.int(10, title="Right Margin Label Offset (Bars)", minval=2)

// Persistent variables for levels and their touch anchors
var float globalATH = na
var float globalATL = na
var int athTouchBar = na
var int atlTouchBar = na

// 1. Core global processing loop (Runs on every historical and real-time tick)
if na(globalATH)
    globalATH := high
    athTouchBar := bar_index
else if high >= globalATH
    globalATH := high
    athTouchBar := bar_index

if na(globalATL)
    globalATL := low
    atlTouchBar := bar_index
else if low <= globalATL
    globalATL := low
    atlTouchBar := bar_index

// 2. Instantiate exactly ONE persistent line and label container for each level
var line athLine = line.new(x1=na, y1=na, x2=na, y2=na, xloc=xloc.bar_index, color=athLineColor, width=lineWidth, style=line.style_solid, extend=extend.right)
var line atlLine = line.new(x1=na, y1=na, x2=na, y2=na, xloc=xloc.bar_index, color=atlLineColor, width=lineWidth, style=line.style_solid, extend=extend.right)

var label athLabel = label.new(x=na, y=na, text="", xloc=xloc.bar_index, color=color.new(color.black, 100), textcolor=textColor, style=label.style_label_left, size=size.normal)
var label atlLabel = label.new(x=na, y=na, text="", xloc=xloc.bar_index, color=color.new(color.black, 100), textcolor=textColor, style=label.style_label_left, size=size.normal)

// 3. Render loop safely isolated from real-time calculation memory rollbacks
// Fixed: Using a direct state check ensures variables won't drop coordinates mid-tick
if barstate.islast or barstate.isconfirmed
    if not na(globalATH) and not na(athTouchBar)
        line.set_xy1(athLine, athTouchBar, globalATH)
        line.set_xy2(athLine, bar_index + 1, globalATH)
        line.set_color(athLine, athLineColor)
        line.set_width(athLine, lineWidth)
        
        label.set_xy(athLabel, bar_index + textOffset, globalATH)
        label.set_text(athLabel, "ATH: " + str.tostring(globalATH, "#.##"))
        label.set_textcolor(athLabel, textColor)
        
    if not na(globalATL) and not na(atlTouchBar)
        line.set_xy1(atlLine, atlTouchBar, globalATL)
        line.set_xy2(atlLine, bar_index + 1, globalATL)
        line.set_color(atlLine, atlLineColor)
        line.set_width(atlLine, lineWidth)
        
        label.set_xy(atlLabel, bar_index + textOffset, globalATL)
        label.set_text(atlLabel, "ATL: " + str.tostring(globalATL, "#.##"))
        label.set_textcolor(atlLabel, textColor)
````
