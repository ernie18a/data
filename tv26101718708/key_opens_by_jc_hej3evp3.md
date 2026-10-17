# Key Opens By JC

- url: https://www.tradingview.com/script/hEJ3evp3-Key-Opens-By-JC/
- type: indicator
- pine_id: PUB;83ccda593da54f28b8bda9002c25769b
- version: 1.0

## Description

This indicator will provide key open for 10am, Asia, and Midnight marked out with a customizable ray with small discreet labeling to keep the charts clean.

## Source Code

````pine
//@version=6
indicator('Key Futures Opens', overlay = true)

// ─── LINE SETTINGS ───────────────────────────────────────────────────────────
lineWidth = input.int(1, 'Line Width')
lineLength = input.int(20, 'Line Length (bars)')

// ─── LABEL SETTINGS ──────────────────────────────────────────────────────────
labelSize = input.string(size.tiny, 'Label Size', options = [size.tiny, size.small, size.normal, size.large])
labelOffset = input.int(5, 'Label Offset (bars right)', minval = 0, maxval = 50)
gapMult = input.float(0.3, 'Gap Below Line (ATR mult)', minval = 0.05, maxval = 2.0, step = 0.05)

// ─── ASIAN OPEN ──────────────────────────────────────────────────────────────
asianText = input.string('Asian Open  3:00 PM', 'Asian Open Label', group = 'Asian Open')
asianLineColor = input.color(color.black, 'Asian Line Color', group = 'Asian Open')
asianTextColor = input.color(color.black, 'Asian Text Color', group = 'Asian Open')

// ─── MIDNIGHT OPEN ───────────────────────────────────────────────────────────
midnightText = input.string('Midnight Open  9:00 PM', 'Midnight Open Label', group = 'Midnight Open')
midnightLineColor = input.color(color.black, 'Midnight Line Color', group = 'Midnight Open')
midnightTextColor = input.color(color.black, 'Midnight Text Color', group = 'Midnight Open')

// ─── NY OPEN ─────────────────────────────────────────────────────────────────
nyText = input.string('NY Open  7:00 AM', 'NY Open Label', group = 'NY Open')
nyLineColor = input.color(color.black, 'NY Line Color', group = 'NY Open')
nyTextColor = input.color(color.black, 'NY Text Color', group = 'NY Open')

// ─── TIMES (America/Phoenix = MST, no DST) ───────────────────────────────────
isAsianOpen = hour(time, 'America/Phoenix') == 15 and minute(time, 'America/Phoenix') == 0
isMidnightOpen = hour(time, 'America/Phoenix') == 21 and minute(time, 'America/Phoenix') == 0
isNYOpen = hour(time, 'America/Phoenix') == 7 and minute(time, 'America/Phoenix') == 0

atrGap = ta.atr(14) * gapMult

// ─── DRAW ────────────────────────────────────────────────────────────────────
if isAsianOpen
    line.new(bar_index, close, bar_index + lineLength, close, extend = extend.none, color = asianLineColor, width = lineWidth)
    label.new(bar_index + labelOffset, close - atrGap, asianText, style = label.style_none, textcolor = asianTextColor, size = labelSize, xloc = xloc.bar_index, yloc = yloc.price, textalign = text.align_left)

if isMidnightOpen
    line.new(bar_index, close, bar_index + lineLength, close, extend = extend.none, color = midnightLineColor, width = lineWidth)
    label.new(bar_index + labelOffset, close - atrGap, midnightText, style = label.style_none, textcolor = midnightTextColor, size = labelSize, xloc = xloc.bar_index, yloc = yloc.price, textalign = text.align_left)

if isNYOpen
    line.new(bar_index, close, bar_index + lineLength, close, extend = extend.none, color = nyLineColor, width = lineWidth)
    label.new(bar_index + labelOffset, close - atrGap, nyText, style = label.style_none, textcolor = nyTextColor, size = labelSize, xloc = xloc.bar_index, yloc = yloc.price, textalign = text.align_left)
````
