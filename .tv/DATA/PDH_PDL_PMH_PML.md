<!-- tradingview-pine-id: PUB;e7320b9351054281ab4f474df0a5fe65 -->
<!-- tradingviewscripts-format: 1 -->
# PDH PDL PMH PML

Source: https://www.tradingview.com/script/LZ7dApfA-PDH-PDL-ATH/

## Description

Plots key reference levels for price action and support/resistance analysis:

[*]Previous Day High/Low (PDH/PDL)
[*]Previous Week High/Low (PWH/PWL)
[*]Previous Month High/Low (PMH/PML)
[*]All-Time High (ATH) — calculated from a fixed monthly context, so it stays accurate regardless of your chart's timeframe
[*]Daily/Weekly/Monthly Open lines

Each level can be toggled on/off independently, with fully customizable colors. Lines and labels refresh automatically on each new bar.

---

## Source Code

````pine
//@version=6
indicator("PDH PDL PMH PML", overlay=true)

// Line and text color settings
colorHigh = input.color(color.red, title="Color for High Line and Text")
colorLow = input.color(color.green, title="Color for Low Line and Text")
colorDayOpen = input.color(color.blue, title="Color for Daily Open Line and Text")
colorWeekOpen = input.color(color.orange, title="Color for Weekly Open Line and Text")
colorMonthOpen = input.color(color.purple, title="Color for Monthly Open Line and Text")
colorMonthHigh = input.color(color.white, title="Color for Previous Month High Line and Text")
colorMonthLow = input.color(color.white, title="Color for Previous Month Low Line and Text")
colorATH = input.color(color.yellow, title="Color for All-Time High Line and Text")

// Settings to enable/disable levels
showPDH = input(true, title="Show PDH Level")
showPDL = input(true, title="Show PDL Level")
showPWH = input(true, title="Show PWH Level")
showPWL = input(true, title="Show PWL Level")
showPMH = input(true, title="Show PMH Level")
showPML = input(true, title="Show PML Level")
showDO = input(true, title="Show Daily Open Level")
showWO = input(true, title="Show Weekly Open Level")
showMO = input(true, title="Show Monthly Open Level")
showATH = input(true, title="Show All-Time High Level")

// Yesterday's high and low
yesterdayHigh = request.security(syminfo.tickerid, "D", high[1])
yesterdayLow = request.security(syminfo.tickerid, "D", low[1])

// Previous week high and low
previousWeekHigh = request.security(syminfo.tickerid, "W", high[1])
previousWeekLow = request.security(syminfo.tickerid, "W", low[1])

// Previous month high and low
previousMonthHigh = request.security(syminfo.tickerid, "M", high[1])
previousMonthLow = request.security(syminfo.tickerid, "M", low[1])

// All-time high — calculated in a fixed Monthly context so the result
// stays consistent regardless of the chart's current timeframe
// (an intraday chart only loads a short window of bars, which would
// otherwise understate the true historical high)
athRunningMax() =>
    var float ath = na
    ath := na(ath) ? high : math.max(ath, high)
    ath

allTimeHigh = request.security(syminfo.tickerid, "M", athRunningMax())

// Day, week, and month open
dayOpen = request.security(syminfo.tickerid, "D", open[0], lookahead=barmerge.lookahead_on)
weekOpen = request.security(syminfo.tickerid, "W", open[0], lookahead=barmerge.lookahead_on)
monthOpen = request.security(syminfo.tickerid, "M", open[0], lookahead=barmerge.lookahead_on)

// Delete old lines and labels
var line highLine = na
var line lowLine = na
var line weekHighLine = na
var line weekLowLine = na
var line monthHighLine = na
var line monthLowLine = na
var line openLine = na
var line weekOpenLine = na
var line monthOpenLine = na
var line athLine = na
var label highLabel = na
var label lowLabel = na
var label weekHighLabel = na
var label weekLowLabel = na
var label monthHighLabel = na
var label monthLowLabel = na
var label openLabel = na
var label weekOpenLabel = na
var label monthOpenLabel = na
var label athLabel = na

if not na(highLine)
    line.delete(highLine)
if not na(lowLine)
    line.delete(lowLine)
if not na(weekHighLine)
    line.delete(weekHighLine)
if not na(weekLowLine)
    line.delete(weekLowLine)
if not na(monthHighLine)
    line.delete(monthHighLine)
if not na(monthLowLine)
    line.delete(monthLowLine)
if not na(openLine)
    line.delete(openLine)
if not na(weekOpenLine)
    line.delete(weekOpenLine)
if not na(monthOpenLine)
    line.delete(monthOpenLine)
if not na(athLine)
    line.delete(athLine)
if not na(highLabel)
    label.delete(highLabel)
if not na(lowLabel)
    label.delete(lowLabel)
if not na(weekHighLabel)
    label.delete(weekHighLabel)
if not na(weekLowLabel)
    label.delete(weekLowLabel)
if not na(monthHighLabel)
    label.delete(monthHighLabel)
if not na(monthLowLabel)
    label.delete(monthLowLabel)
if not na(openLabel)
    label.delete(openLabel)
if not na(weekOpenLabel)
    label.delete(weekOpenLabel)
if not na(monthOpenLabel)
    label.delete(monthOpenLabel)
if not na(athLabel)
    label.delete(athLabel)

// Create new lines and labels
if showPDH and not na(yesterdayHigh)
    highLine := line.new(x1=bar_index, y1=yesterdayHigh, x2=bar_index + 2, y2=yesterdayHigh, color=colorHigh, width=1, style=line.style_solid)
    highLabel := label.new(x=bar_index + 2, y=yesterdayHigh, text="PDH", xloc=xloc.bar_index, yloc=yloc.price, textcolor=colorHigh, style=label.style_none, size=size.small, textalign=text.align_right)

if showPDL and not na(yesterdayLow)
    lowLine := line.new(x1=bar_index, y1=yesterdayLow, x2=bar_index + 2, y2=yesterdayLow, color=colorLow, width=1, style=line.style_solid)
    lowLabel := label.new(x=bar_index + 2, y=yesterdayLow, text="PDL", xloc=xloc.bar_index, yloc=yloc.price, textcolor=colorLow, style=label.style_none, size=size.small, textalign=text.align_right)

if showPWH and not na(previousWeekHigh)
    weekHighLine := line.new(x1=bar_index, y1=previousWeekHigh, x2=bar_index + 2, y2=previousWeekHigh, color=colorHigh, width=1, style=line.style_solid)
    weekHighLabel := label.new(x=bar_index + 2, y=previousWeekHigh, text="PWH", xloc=xloc.bar_index, yloc=yloc.price, textcolor=colorHigh, style=label.style_none, size=size.small, textalign=text.align_right)

if showPWL and not na(previousWeekLow)
    weekLowLine := line.new(x1=bar_index, y1=previousWeekLow, x2=bar_index + 2, y2=previousWeekLow, color=colorLow, width=1, style=line.style_solid)
    weekLowLabel := label.new(x=bar_index + 2, y=previousWeekLow, text="PWL", xloc=xloc.bar_index, yloc=yloc.price, textcolor=colorLow, style=label.style_none, size=size.small, textalign=text.align_right)

if showPMH and not na(previousMonthHigh)
    monthHighLine := line.new(x1=bar_index, y1=previousMonthHigh, x2=bar_index + 2, y2=previousMonthHigh, color=colorMonthHigh, width=1, style=line.style_solid)
    monthHighLabel := label.new(x=bar_index + 2, y=previousMonthHigh, text="PMH", xloc=xloc.bar_index, yloc=yloc.price, textcolor=colorMonthHigh, style=label.style_none, size=size.small, textalign=text.align_right)

if showPML and not na(previousMonthLow)
    monthLowLine := line.new(x1=bar_index, y1=previousMonthLow, x2=bar_index + 2, y2=previousMonthLow, color=colorMonthLow, width=1, style=line.style_solid)
    monthLowLabel := label.new(x=bar_index + 2, y=previousMonthLow, text="PML", xloc=xloc.bar_index, yloc=yloc.price, textcolor=colorMonthLow, style=label.style_none, size=size.small, textalign=text.align_right)

if showDO and not na(dayOpen)
    openLine := line.new(x1=bar_index, y1=dayOpen, x2=bar_index + 2, y2=dayOpen, color=colorDayOpen, width=1, style=line.style_solid)
    openLabel := label.new(x=bar_index + 2, y=dayOpen, text="D", xloc=xloc.bar_index, yloc=yloc.price, textcolor=colorDayOpen, style=label.style_none, size=size.small, textalign=text.align_right)

if showWO and not na(weekOpen)
    weekOpenLine := line.new(x1=bar_index, y1=weekOpen, x2=bar_index + 2, y2=weekOpen, color=colorWeekOpen, width=1, style=line.style_solid)
    weekOpenLabel := label.new(x=bar_index + 2, y=weekOpen, text="W", xloc=xloc.bar_index, yloc=yloc.price, textcolor=colorWeekOpen, style=label.style_none, size=size.small, textalign=text.align_right)

if showMO and not na(monthOpen)
    monthOpenLine := line.new(x1=bar_index, y1=monthOpen, x2=bar_index + 2, y2=monthOpen, color=colorMonthOpen, width=1, style=line.style_solid)
    monthOpenLabel := label.new(x=bar_index + 2, y=monthOpen, text="M", xloc=xloc.bar_index, yloc=yloc.price, textcolor=colorMonthOpen, style=label.style_none, size=size.small, textalign=text.align_right)

if showATH and not na(allTimeHigh)
    athLine := line.new(x1=bar_index, y1=allTimeHigh, x2=bar_index + 2, y2=allTimeHigh, color=colorATH, width=1, style=line.style_solid)
    athLabel := label.new(x=bar_index + 2, y=allTimeHigh, text="ATH", xloc=xloc.bar_index, yloc=yloc.price, textcolor=colorATH, style=label.style_none, size=size.small, textalign=text.align_right)
````
