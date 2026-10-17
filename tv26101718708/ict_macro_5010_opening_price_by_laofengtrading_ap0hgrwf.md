# ICT Macro 50-10 Opening Price by Laofengtrading

- url: https://www.tradingview.com/script/Ap0HGRwf-ICT-Macro-50-10-Opening-Price-by-Laofengtrading/
- type: indicator
- pine_id: PUB;dcd018f5a2ae4ca4a694e56e94150369
- version: 1.0

## Description

ICT macro with opening price by Laofengtrading
This indicator highlights the ICT hourly macro window from xx:50 to the next hour xx:10, based on New York time.
It marks the macro range directly on the chart and plots the opening price from the xx:50 candle. The opening price line extends through the full macro window until xx:10, helping traders quickly identify the key macro open level during each hourly session.
Features:
Highlights the ICT macro window from 50 to 10
Uses fixed New York time
Marks the macro opening price from the xx:50 candle
Extends the opening price line until the macro ends
Customizable macro background color
Customizable opening price line color and width
Optional label display
This tool is designed for traders who use ICT concepts and want a clean visual reference for hourly macro timing and opening price levels.

Update: 20260622

The macro opening price line now plots the full 50-10 macro window immediately when the xx:50 candle opens.

Previously, the line extended gradually as each new candle formed during the macro window. Now, once the xx:50 candle appears, the opening price line is drawn directly from xx:50 to xx:10.

This makes the macro opening price level easier to see in real time.

## Source Code

````pine
//@version=6
indicator("ICT Macro 50-10 Opening Price by Laofengtrading", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// === Inputs ===
showBox = input.bool(true, "Show Macro Area")
boxColor = input.color(color.new(color.green, 85), "Macro Area Color")

showOpenLine = input.bool(true, "Show Macro Open Price")
openLineColor = input.color(color.purple, "Open Line Color")
openLineWidth = input.int(2, "Open Line Width", minval=1, maxval=5)

showLabel = input.bool(false, "Show Label")

timezone = "America/New_York"
macroDurationMs = 20 * 60 * 1000

// === Time Logic ===
m = minute(time, timezone)

inMacro = m >= 50 or m < 10
isMacroStart = m == 50 and m[1] != 50

// === Drawing Variables ===
var box macroBox = na
var line openLine = na
var label macroLabel = na

var float macroOpen = na
var float macroHigh = na
var float macroLow = na
var int macroEndTime = na

// === Start Macro at xx:50 ===
if isMacroStart
    macroOpen := open
    macroHigh := high
    macroLow := low
    macroEndTime := time + macroDurationMs

    if showBox
        macroBox := box.new(
             left=time,
             right=macroEndTime,
             top=macroHigh,
             bottom=macroLow,
             xloc=xloc.bar_time,
             bgcolor=boxColor,
             border_color=color.new(color.white, 85)
         )

    if showOpenLine
        openLine := line.new(
             x1=time,
             y1=macroOpen,
             x2=macroEndTime,
             y2=macroOpen,
             xloc=xloc.bar_time,
             color=openLineColor,
             width=openLineWidth,
             style=line.style_solid
         )

    if showLabel
        macroLabel := label.new(
             x=macroEndTime,
             y=macroOpen,
             xloc=xloc.bar_time,
             text="Macro 50-10\nOpen: " + str.tostring(macroOpen, format.mintick),
             style=label.style_label_left,
             textcolor=color.white,
             color=color.new(color.black, 15),
             size=size.small
         )

// === Update Box Height Only During Macro ===
if inMacro and not na(macroOpen)
    macroHigh := math.max(macroHigh, high)
    macroLow := math.min(macroLow, low)

    if showBox and not na(macroBox)
        box.set_top(macroBox, macroHigh)
        box.set_bottom(macroBox, macroLow)
        box.set_bgcolor(macroBox, boxColor)

    if showOpenLine and not na(openLine)
        line.set_y1(openLine, macroOpen)
        line.set_y2(openLine, macroOpen)
        line.set_color(openLine, openLineColor)
        line.set_width(openLine, openLineWidth)

    if showLabel and not na(macroLabel)
        label.set_x(macroLabel, macroEndTime)
        label.set_y(macroLabel, macroOpen)
        label.set_text(macroLabel, "Macro 50-10\nLength: 20m\nOpen: " + str.tostring(macroOpen, format.mintick))

// === Stop Updating After xx:10 ===
if not inMacro
    macroOpen := na
    macroHigh := na
    macroLow := na
    macroEndTime := na
````
