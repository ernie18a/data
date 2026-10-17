# Session Vertical Lines

- url: https://www.tradingview.com/script/YBxMRGLj-Session-Vertical-Lines/
- type: indicator
- pine_id: PUB;27ac81600fdd4a31a4c177b871bbd830
- version: 1.0

## Description

Vertical Lines plots two customizable vertical lines on your chart using New York time. Set your preferred start and end times in the settings, then easily customize each line’s color, width, and style.

Perfect for marking key market sessions such as pre-market, New York open, cash session ranges, news windows, or any important time-based levels. Built specifically for traders who want clean visual session markers without clutter.

Features:
• Uses fixed New York time (handles DST automatically)  
• Separate start and end line colors  
• Adjustable line width and style  
• Clean and lightweight design  
• Works on all timeframes

Ideal for futures, indices, forex, and stocks traders who track New York session activity.

## Source Code

````pine
//@version=5
indicator("NY Session Vertical Lines", overlay=true)

// === Inputs ===
startTime = input.string("07:30", "Start Time NY (HH:MM)")
endTime   = input.string("09:30", "End Time NY (HH:MM)")

startColor = input.color(color.green, "Start Line Color")
endColor   = input.color(color.red, "End Line Color")

lineWidth = input.int(2, "Line Width", minval=1, maxval=5)
lineStyle = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"])

// === Timezone ===
tz = "America/New_York"

// === Line Style ===
style = line.style_solid
if lineStyle == "Dashed"
    style := line.style_dashed
if lineStyle == "Dotted"
    style := line.style_dotted

// === Convert Input Time ===
startHour   = str.tonumber(str.substring(startTime, 0, 2))
startMinute = str.tonumber(str.substring(startTime, 3, 5))

endHour     = str.tonumber(str.substring(endTime, 0, 2))
endMinute   = str.tonumber(str.substring(endTime, 3, 5))

// === New York Time ===
nyHour   = hour(time, tz)
nyMinute = minute(time, tz)

// === Detect Times ===
isStart = nyHour == startHour and nyMinute == startMinute
isEnd   = nyHour == endHour and nyMinute == endMinute

// === Draw Vertical Lines ===
if isStart
    line.new(bar_index, low - 1000, bar_index, high + 1000,
         extend=extend.both, color=startColor, width=lineWidth, style=style)

if isEnd
    line.new(bar_index, low - 1000, bar_index, high + 1000,
         extend=extend.both, color=endColor, width=lineWidth, style=style)
````
