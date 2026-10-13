<!-- tradingview-pine-id: PUB;74d679f943b045d3b22fbf41765af5a5 -->
<!-- tradingviewscripts-format: 1 -->
# ICT 8 PM New York Levels

Source: https://www.tradingview.com/script/AeyPz1kS-ICT-8-PM-New-York-Levels-J-P/

## Description

//@version=6
indicator('ICT 8 PM New York Levels', overlay = true)

// ===== Inputs =====
candleColor = input.color(color.orange, '8 PM Candle Color')
highColor = input.color(color.lime, 'High Line')
lowColor = input.color(color.red, 'Low Line')
lineWidth = input.int(2, 'Line Width', minval = 1, maxval = 5)

// ===== Detect 8:00 PM New York =====
nyHour = hour(time, 'America/New_York')
nyMin = minute(time, 'America/New_York')

is8PM = nyHour == 20 and nyMin == 0

// ===== Variables =====
var line highLine = na
var line lowLine = na
var label sessionLabel = na

// ===== Draw Levels =====
if is8PM

    // Delete yesterday's levels
    if not na(highLine)
        line.delete(highLine)

    if not na(lowLine)
        line.delete(lowLine)

    if not na(sessionLabel)
        label.delete(sessionLabel)

    // Draw today's High
    highLine := line.new(bar_index, high, bar_index + 1, high, extend = extend.right, color = highColor, width = lineWidth)

    // Draw today's Low
    lowLine := line.new(bar_index, low, bar_index + 1, low, extend = extend.right, color = lowColor, width = lineWidth)

    // Label
    sessionLabel := label.new(bar_index, high, '8 PM NY', style = label.style_label_down, color = color.orange, textcolor = color.black)
    sessionLabel

// ===== Color Candle =====
barcolor(is8PM ? candleColor : na)

---

## Source Code

````pine
//@version=6
indicator('ICT 8 PM New York Levels', overlay = true)

// ===== Inputs =====
candleColor = input.color(color.orange, '8 PM Candle Color')
highColor = input.color(color.lime, 'High Line')
lowColor = input.color(color.red, 'Low Line')
lineWidth = input.int(2, 'Line Width', minval = 1, maxval = 5)

// ===== Detect 8:00 PM New York =====
nyHour = hour(time, 'America/New_York')
nyMin = minute(time, 'America/New_York')

is8PM = nyHour == 20 and nyMin == 0

// ===== Variables =====
var line highLine = na
var line lowLine = na
var label sessionLabel = na

// ===== Draw Levels =====
if is8PM

    // Delete yesterday's levels
    if not na(highLine)
        line.delete(highLine)

    if not na(lowLine)
        line.delete(lowLine)

    if not na(sessionLabel)
        label.delete(sessionLabel)

    // Draw today's High
    highLine := line.new(bar_index, high, bar_index + 1, high, extend = extend.right, color = highColor, width = lineWidth)

    // Draw today's Low
    lowLine := line.new(bar_index, low, bar_index + 1, low, extend = extend.right, color = lowColor, width = lineWidth)

    // Label
    sessionLabel := label.new(bar_index, high, '8 PM NY', style = label.style_label_down, color = color.orange, textcolor = color.black)
    sessionLabel

// ===== Color Candle =====
barcolor(is8PM ? candleColor : na)
````
