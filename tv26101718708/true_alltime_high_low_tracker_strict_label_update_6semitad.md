# True All-Time High & Low Tracker (Strict Label Update)

- url: https://www.tradingview.com/script/6SeMitad-True-All-Time-High-Low-Tracker-Strict-Label-Update/
- type: indicator
- pine_id: PUB;9598af9faddd443e84e684c42617e83f
- version: 1.0

## Description

True all time high and low, gives support and resistance

## Source Code

````pine
//@version=6
indicator("True All-Time High & Low Tracker (Strict Label Update)", overlay=true, linktoseries=true)

// ==========================================
// User Interface Styling Inputs
// ==========================================
athLineColor = input.color(color.green, title="True ATH Line Color", group="Visual Customization")
atlLineColor = input.color(color.red, title="True ATL Line Color", group="Visual Customization")
lineWidth    = input.int(2, title="Lines Thickness Width", minval=1, group="Visual Customization")
lineStyleIn  = input.string("Dashed", title="Global Lines Style", options=["Solid", "Dashed", "Dotted"], group="Visual Customization")
textColor    = input.color(color.white, title="Margin Label Font Color", group="Visual Customization")
textOffset   = input.int(10, title="Right Margin Floating Label Offset (Bars)", minval=2, group="Visual Customization")

// Map menu options to native Pine Script line styles
chosenStyle = switch lineStyleIn
    "Solid"  => line.style_solid
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted
    => line.style_dashed

// ==========================================
// UNBREAKABLE GLOBAL EXTREMES ENGINE
// ==========================================
var float trueATH = na
var float trueATL = na
var int   athTimestamp = na
var int   atlTimestamp = na

// Calculate global extremes dynamically on all historical closed bars
if not barstate.isrealtime
    if na(trueATH) or high > trueATH
        trueATH := high
        athTimestamp := time
    if na(trueATL) or low < trueATL
        trueATL := low
        atlTimestamp := time
else
    // Keep evaluating live candles in real-time without drawing delays
    if high > trueATH
        trueATH := high
        athTimestamp := time
    if low < trueATL
        trueATL := low
        atlTimestamp := time

// ==========================================
// UNPURGEABLE DRAWING LAYER CONTROLLERS
// ==========================================
var line athLine   = line.new(x1=na, y1=na, x2=na, y2=na, xloc=xloc.bar_time, color=athLineColor, width=lineWidth, style=chosenStyle, extend=extend.right)
var line atlLine   = line.new(x1=na, y1=na, x2=na, y2=na, xloc=xloc.bar_time, color=atlLineColor, width=lineWidth, style=chosenStyle, extend=extend.right)
var label athLabel = label.new(x=na, y=na, text="", xloc=xloc.bar_time, color=color.new(color.black, 100), textcolor=textColor, style=label.style_label_left, size=size.normal)
var label atlLabel = label.new(x=na, y=na, text="", xloc=xloc.bar_time, color=color.new(color.black, 100), textcolor=textColor, style=label.style_label_left, size=size.normal)

// Update coordinates securely on the final active bar to prevent slanting or canvas warping
if barstate.islast
    // Calculate precise millisecond bar width based on active chart resolution
    int barWidthMil = timeframe.isminutes ? timeframe.multiplier * 60000 : 
                      timeframe.isdaily ? 86400000 : 
                      timeframe.isseconds ? timeframe.multiplier * 1000 : 300000
                      
    int timeOffsetMil = barWidthMil * textOffset

    // Map True All-Time High Line and ATH Label parameters
    if not na(athTimestamp) and not na(trueATH)
        line.set_xy1(athLine, athTimestamp, trueATH)
        line.set_xy2(athLine, time, trueATH)
        line.set_style(athLine, chosenStyle)
        line.set_width(athLine, lineWidth)
        
        // UPDATED LABEL TEXT TO ATH
        label.set_xy(athLabel, time + timeOffsetMil, trueATH)
        label.set_text(athLabel, "ATH: " + str.tostring(trueATH, "#.##"))
        label.set_textcolor(athLabel, textColor)

    // Map True All-Time Low Line and ATL Label parameters
    if not na(atlTimestamp) and not na(trueATL)
        line.set_xy1(atlLine, atlTimestamp, trueATL)
        line.set_xy2(atlLine, time, trueATL)
        line.set_style(atlLine, chosenStyle)
        line.set_width(atlLine, lineWidth)
        
        // UPDATED LABEL TEXT TO ATL
        label.set_xy(atlLabel, time + timeOffsetMil, trueATL)
        label.set_text(atlLabel, "ATL: " + str.tostring(trueATL, "#.##"))
        label.set_textcolor(atlLabel, textColor)
````
