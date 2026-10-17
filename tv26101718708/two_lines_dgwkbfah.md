# Two Lines

- url: https://www.tradingview.com/script/DgwKBfaH-Two-Lines/
- type: indicator
- pine_id: PUB;4ef37175735b4ba48729fd5d47189988
- version: 1.0

## Description

A simple two vertical lines.
I use them to highlight London and NY open times on the chart.
Enjoy

## Source Code

````pine
//@version=6
indicator('Two Lines', overlay = true, max_lines_count = 500)

// ───── Line 1 Settings ─────
showLine1Input = input.bool(true, 'Show Line 1')

line1Hour = input.int(9, 'Line 1 Hour', minval = 0, maxval = 23)
line1Minute = input.int(0, 'Line 1 Minute', minval = 0, maxval = 59)

line1Color = input.color(color.red, 'Line 1 Color')
line1Width = input.int(1, 'Line 1 Width', minval = 1, maxval = 5)
line1StyleChoice = input.string('Dashed', 'Line 1 Style', options = ['Solid', 'Dashed', 'Dotted'])

line1Style = line1StyleChoice == 'Solid' ? line.style_solid : line1StyleChoice == 'Dashed' ? line.style_dashed : line.style_dotted

// ───── Line 2 Settings ─────
showLine2Input = input.bool(true, 'Show Line 2')

line2Hour = input.int(13, 'Line 2 Hour', minval = 0, maxval = 23)
line2Minute = input.int(0, 'Line 2 Minute', minval = 0, maxval = 59)

line2Color = input.color(color.blue, 'Line 2 Color')
line2Width = input.int(1, 'Line 2 Width', minval = 1, maxval = 5)
line2StyleChoice = input.string('Dashed', 'Line 2 Style', options = ['Solid', 'Dashed', 'Dotted'])

line2Style = line2StyleChoice == 'Solid' ? line.style_solid : line2StyleChoice == 'Dashed' ? line.style_dashed : line.style_dotted

// ───── Current Chart Time ─────
barHour = hour(time)
barMinute = minute(time)

// ───── Conditions ─────
showLine1 = showLine1Input and barHour == line1Hour and barMinute == line1Minute
showLine2 = showLine2Input and barHour == line2Hour and barMinute == line2Minute

// ───── Draw Lines ─────
if showLine1
    line.new(bar_index, low, bar_index, high, xloc = xloc.bar_index, extend = extend.both, color = line1Color, width = line1Width, style = line1Style)

if showLine2
    line.new(bar_index, low, bar_index, high, xloc = xloc.bar_index, extend = extend.both, color = line2Color, width = line2Width, style = line2Style)
````
