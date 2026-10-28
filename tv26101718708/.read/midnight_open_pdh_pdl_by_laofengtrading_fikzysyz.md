# Midnight Open PDH PDL by Laofengtrading

- url: https://www.tradingview.com/script/fIkzYsYZ-Midnight-Open-PDH-PDL-by-Laofengtrading/
- type: indicator
- pine_id: PUB;2ea9bac007474310b7a5010274a8e990
- version: 1.0

## Description

This indicator marks three key daily reference levels on the chart:

Midnight Open:
The New York 00:00 opening price.

PDH:
Previous Daily High, based on the previous daily candle high.

PDL:
Previous Daily Low, based on the previous daily candle low.

Features:

- Marks New York Midnight Open
- Marks Previous Daily High
- Marks Previous Daily Low
- PDH and PDL are based on daily chart data
- Customizable line colors and widths
- Optional labels
- Optional arrow-style, plain, or box labels
- Labels are placed after the line near the latest candle
- PDH and PDL can be displayed on higher timeframes such as 4H and Daily

## Source Code

````pine
//@version=6
indicator("Midnight Open PDH PDL by Laofengtrading", overlay=true, max_lines_count=500, max_labels_count=500)

timezone = "America/New_York"

// === Inputs ===
showMidnightOpen = input.bool(true, "Show Midnight Open")
midnightOpenColor = input.color(color.yellow, "Midnight Open Color")
midnightOpenWidth = input.int(2, "Midnight Open Width", minval=1, maxval=5)

showPDH = input.bool(true, "Show PDH")
pdhColor = input.color(color.green, "PDH Color")
pdhWidth = input.int(2, "PDH Width", minval=1, maxval=5)

showPDL = input.bool(true, "Show PDL")
pdlColor = input.color(color.red, "PDL Color")
pdlWidth = input.int(2, "PDL Width", minval=1, maxval=5)

showOnDailyAndHigher = input.bool(true, "Show On Daily And Higher")

showLabels = input.bool(true, "Show Labels")
labelTextColor = input.color(color.black, "Label Text Color")
labelBgColor = input.color(color.new(color.white, 0), "Label Background Color")
labelOffset = input.int(1, "Label Offset After Line", minval=0, maxval=50)
labelStyleInput = input.string("Arrow", "Label Style", options=["Arrow", "Plain", "Box"])

getLabelStyle() =>
    labelStyleInput == "Arrow" ? label.style_label_left : labelStyleInput == "Plain" ? label.style_none : label.style_label_center

// === Time Logic ===
h = hour(time, timezone)
m = minute(time, timezone)

isMidnight = h == 0 and m == 0
isNewDayFromDaily = ta.change(time("D")) != 0
allowDisplay = showOnDailyAndHigher or timeframe.isintraday

// === Daily Chart Previous High / Low ===
pdhValue = request.security(syminfo.tickerid, "D", high[1], barmerge.gaps_off, barmerge.lookahead_on)
pdlValue = request.security(syminfo.tickerid, "D", low[1], barmerge.gaps_off, barmerge.lookahead_on)

// === Variables ===
var float midnightOpen = na

var line midnightOpenLine = na
var line pdhLine = na
var line pdlLine = na

var label midnightOpenLabel = na
var label pdhLabel = na
var label pdlLabel = na

// Create/update levels when a new daily candle starts.
// Midnight Open only updates on actual NY 00:00 candles.
newPDH_PDL = allowDisplay and (isNewDayFromDaily or na(pdhLine) or na(pdlLine))

if isMidnight
    midnightOpen := open

    if not na(midnightOpenLine)
        line.delete(midnightOpenLine)
    if not na(midnightOpenLabel)
        label.delete(midnightOpenLabel)

    if showMidnightOpen
        midnightOpenLine := line.new(time, midnightOpen, time, midnightOpen, xloc=xloc.bar_time, color=midnightOpenColor, width=midnightOpenWidth)

    if showLabels and showMidnightOpen
        midnightOpenLabel := label.new(bar_index + labelOffset, midnightOpen, "Midnight Open", xloc=xloc.bar_index, style=getLabelStyle(), textcolor=labelTextColor, color=labelBgColor, size=size.small)

if newPDH_PDL
    if not na(pdhLine)
        line.delete(pdhLine)
    if not na(pdlLine)
        line.delete(pdlLine)
    if not na(pdhLabel)
        label.delete(pdhLabel)
    if not na(pdlLabel)
        label.delete(pdlLabel)

    if showPDH and not na(pdhValue)
        pdhLine := line.new(time, pdhValue, time, pdhValue, xloc=xloc.bar_time, color=pdhColor, width=pdhWidth)

    if showPDL and not na(pdlValue)
        pdlLine := line.new(time, pdlValue, time, pdlValue, xloc=xloc.bar_time, color=pdlColor, width=pdlWidth)

    if showLabels
        if showPDH and not na(pdhValue)
            pdhLabel := label.new(bar_index + labelOffset, pdhValue, "PDH", xloc=xloc.bar_index, style=getLabelStyle(), textcolor=labelTextColor, color=labelBgColor, size=size.small)

        if showPDL and not na(pdlValue)
            pdlLabel := label.new(bar_index + labelOffset, pdlValue, "PDL", xloc=xloc.bar_index, style=getLabelStyle(), textcolor=labelTextColor, color=labelBgColor, size=size.small)

// === Extend Lines To Latest Candle ===
if not na(midnightOpenLine)
    line.set_x2(midnightOpenLine, time)
    line.set_y1(midnightOpenLine, midnightOpen)
    line.set_y2(midnightOpenLine, midnightOpen)
    line.set_color(midnightOpenLine, midnightOpenColor)
    line.set_width(midnightOpenLine, midnightOpenWidth)

if not na(pdhLine)
    line.set_x2(pdhLine, time)
    line.set_y1(pdhLine, pdhValue)
    line.set_y2(pdhLine, pdhValue)
    line.set_color(pdhLine, pdhColor)
    line.set_width(pdhLine, pdhWidth)

if not na(pdlLine)
    line.set_x2(pdlLine, time)
    line.set_y1(pdlLine, pdlValue)
    line.set_y2(pdlLine, pdlValue)
    line.set_color(pdlLine, pdlColor)
    line.set_width(pdlLine, pdlWidth)

// === Labels After Line ===
if showLabels
    if not na(midnightOpenLabel)
        label.set_x(midnightOpenLabel, bar_index + labelOffset)
        label.set_y(midnightOpenLabel, midnightOpen)
        label.set_style(midnightOpenLabel, getLabelStyle())
        label.set_textcolor(midnightOpenLabel, labelTextColor)
        label.set_color(midnightOpenLabel, labelBgColor)

    if not na(pdhLabel)
        label.set_x(pdhLabel, bar_index + labelOffset)
        label.set_y(pdhLabel, pdhValue)
        label.set_style(pdhLabel, getLabelStyle())
        label.set_textcolor(pdhLabel, labelTextColor)
        label.set_color(pdhLabel, labelBgColor)

    if not na(pdlLabel)
        label.set_x(pdlLabel, bar_index + labelOffset)
        label.set_y(pdlLabel, pdlValue)
        label.set_style(pdlLabel, getLabelStyle())
        label.set_textcolor(pdlLabel, labelTextColor)
        label.set_color(pdlLabel, labelBgColor)
````
