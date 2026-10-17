# NY ORB 5 Min High/Low

- url: https://www.tradingview.com/script/VLVSbGJG-NY-ORB-5-Min-High-Low/
- type: indicator
- pine_id: PUB;3fb1518e5e434706844f6979e1848f8a
- version: 1.0

## Description

Here’s a clean TradingView description you can use:

NY First 5 Minute High/Low

This indicator marks the high and low of the first 5-minute candle of the New York session, using 9:30–9:35 AM New York time.

The levels are plotted as horizontal lines and extended to the right side of the chart. Each level includes a right-side price tag showing the exact high and low price of the opening 5-minute range.

This can be useful for identifying early session liquidity, opening range reactions, breakout levels, rejection zones, and potential sweep/reversal areas.

## Source Code

````pine
//@version=6
indicator("NY First 5 Min High/Low", overlay=true, max_lines_count=500, max_labels_count=500)

// === Inputs ===
extendLines = input.bool(true, "Extend Lines Right")
showLabels  = input.bool(true, "Show Right-Side Price Tags")
rightOffset = input.int(10, "Right Label Offset", minval=1, maxval=100)

// === NY Time ===
nyHour   = hour(time, "America/New_York")
nyMinute = minute(time, "America/New_York")
nyDay    = dayofmonth(time, "America/New_York")

newDay = ta.change(nyDay) != 0

// NY first 5 min candle window: 9:30–9:34
inFirst5 = nyHour == 9 and nyMinute >= 30 and nyMinute < 35

// After first 5 min candle closes
afterFirst5 = nyHour == 9 and nyMinute >= 35

// === Variables ===
var float first5High = na
var float first5Low  = na
var bool rangeLocked = false

var line highLine = na
var line lowLine  = na

var label highTag = na
var label lowTag  = na

// === Reset each new NY day ===
if newDay
    first5High := na
    first5Low  := na
    rangeLocked := false

    line.delete(highLine)
    line.delete(lowLine)

    label.delete(highTag)
    label.delete(lowTag)

    highLine := na
    lowLine := na
    highTag := na
    lowTag := na

// === Build first 5-min range ===
if inFirst5
    first5High := na(first5High) ? high : math.max(first5High, high)
    first5Low  := na(first5Low) ? low : math.min(first5Low, low)

// === Draw lines once range is locked ===
if afterFirst5 and not rangeLocked and not na(first5High) and not na(first5Low)
    rangeLocked := true

    highLine := line.new(bar_index, first5High, bar_index + 1, first5High, extend=extendLines ? extend.right : extend.none, width=2, color=color.green)
    lowLine  := line.new(bar_index, first5Low, bar_index + 1, first5Low, extend=extendLines ? extend.right : extend.none, width=2, color=color.red)

    if showLabels
        highTag := label.new(bar_index + rightOffset, first5High, "NY 5m High  " + str.tostring(first5High, format.mintick), style=label.style_label_left, textcolor=color.white, color=color.green, size=size.small)
        lowTag  := label.new(bar_index + rightOffset, first5Low, "NY 5m Low  " + str.tostring(first5Low, format.mintick), style=label.style_label_left, textcolor=color.white, color=color.red, size=size.small)

// === Keep labels on the very right side of chart ===
if rangeLocked and showLabels and not na(highTag) and not na(lowTag)
    label.set_x(highTag, bar_index + rightOffset)
    label.set_y(highTag, first5High)
    label.set_text(highTag, "NY 5m High  " + str.tostring(first5High, format.mintick))

    label.set_x(lowTag, bar_index + rightOffset)
    label.set_y(lowTag, first5Low)
    label.set_text(lowTag, "NY 5m Low  " + str.tostring(first5Low, format.mintick))
````
