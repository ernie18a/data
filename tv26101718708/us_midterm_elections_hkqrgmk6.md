# US Midterm Elections

- url: https://www.tradingview.com/script/hkqrGMK6-US-Midterm-Elections/
- type: indicator
- pine_id: PUB;4f874fc478cb40b9be3cb6089e2bd825
- version: 4.0

## Description

US Midterm Elections is a macro event indicator that highlights historical and future U.S. midterm election dates directly on the chart.

Useful for analyzing correlations between political cycles and market behavior across equities, crypto, indices, bonds, and macro assets.

Features:
• Historical and future midterm election markers  
• Highlighted upcoming election  
• Custom labels and styling  
• Clean macro cycle visualization  

Built for long-term market cycle and sentiment analysis.

## Source Code

````pine
//@version=6
indicator("US Midterm Elections", overlay=true, max_lines_count=500, max_labels_count=500)

showLabels      = input.bool(true, "Show labels")
showPast        = input.bool(true, "Show past elections")
showFuture      = input.bool(true, "Show future elections")
highlightNext   = input.bool(true, "Highlight next election")

lineColor       = input.color(color.orange, "Past election line color")
futureLineColor = input.color(color.orange, "Future election line color")
nextLineColor   = input.color(color.red, "Next election line color")
labelBgColor    = input.color(color.orange, "Label background color")
nextLabelColor  = input.color(color.red, "Next election label color")
labelTextColor  = input.color(color.white, "Text color")

futureCycles    = input.int(4, "Number of future elections", minval=1, maxval=10)

// 1 year zones — ON by default
showPreYearZone  = input.bool(true, "Show 1 year before midterms")
showPostYearZone = input.bool(true, "Show 1 year after midterms")

// CORES NOVAS
preYearColorInput  = input.color(color.rgb(33, 150, 243), "1 year before zone color")
postYearColorInput = input.color(color.rgb(255, 193, 7), "1 year after zone color")

zoneTransparency = input.int(95, "Zone transparency", minval=0, maxval=100)

var lines = array.new_line()
var labels = array.new_label()
var fills = array.new_linefill()

clearObjects() =>
    for l in lines
        line.delete(l)
    for lb in labels
        label.delete(lb)
    for f in fills
        linefill.delete(f)

    array.clear(lines)
    array.clear(labels)
    array.clear(fills)

getMidtermDate(y) =>
    nov1 = timestamp("America/New_York", y, 11, 1, 0, 0)
    dow = dayofweek(nov1)
    daysToMonday = dow <= dayofweek.monday ? dayofweek.monday - dow : 7 - (dow - dayofweek.monday)
    electionDay = 1 + daysToMonday + 1
    timestamp("America/New_York", y, 11, electionDay, 0, 0)

formatDate(y) =>
    eventTime = getMidtermDate(y)
    dayNumber = dayofmonth(eventTime, "America/New_York")
    str.tostring(dayNumber) + " Nov " + str.tostring(y)

getEventLow(eventTime) =>
    ta.valuewhen(time >= eventTime and time[1] < eventTime, low, 0)

createFullHeightZone(leftTime, rightTime, zoneColor) =>
    leftLine = line.new(
         x1=leftTime,
         y1=low,
         x2=leftTime,
         y2=high,
         xloc=xloc.bar_time,
         extend=extend.both,
         color=color.new(zoneColor, 100),
         width=1
    )

    rightLine = line.new(
         x1=rightTime,
         y1=low,
         x2=rightTime,
         y2=high,
         xloc=xloc.bar_time,
         extend=extend.both,
         color=color.new(zoneColor, 100),
         width=1
    )

    fillZone = linefill.new(
         leftLine,
         rightLine,
         color.new(zoneColor, zoneTransparency)
    )

    array.push(lines, leftLine)
    array.push(lines, rightLine)
    array.push(fills, fillZone)

createEvent(eventTime, eventName, nextEventTime) =>
    isFuture = eventTime > timenow
    canShow = (isFuture and showFuture) or (not isFuture and showPast)
    isNextEvent = eventTime == nextEventTime

    eventLow = getEventLow(eventTime)

    if canShow
        oneYearMs = 365 * 24 * 60 * 60 * 1000

        if showPreYearZone
            createFullHeightZone(
                 eventTime - oneYearMs,
                 eventTime,
                 preYearColorInput
            )

        if showPostYearZone
            createFullHeightZone(
                 eventTime,
                 eventTime + oneYearMs,
                 postYearColorInput
            )

        eventLineColor = isNextEvent and highlightNext ? nextLineColor : isFuture ? futureLineColor : lineColor
        eventLineWidth = isNextEvent and highlightNext ? 3 : 2

        newLine = line.new(
             x1=eventTime,
             y1=low,
             x2=eventTime,
             y2=high,
             xloc=xloc.bar_time,
             extend=extend.both,
             color=eventLineColor,
             width=eventLineWidth,
             style=line.style_dashed
        )
        array.push(lines, newLine)

        if showLabels
            yBase = isFuture ? ta.lowest(low, 300) : eventLow

            newLabel = label.new(
                 x=eventTime,
                 y=yBase,
                 text=eventName,
                 xloc=xloc.bar_time,
                 style=label.style_label_up,
                 color=isNextEvent and highlightNext ? nextLabelColor : labelBgColor,
                 textcolor=labelTextColor,
                 size=size.normal,
                 textalign=text.align_center
            )
            array.push(labels, newLabel)

if barstate.islast
    clearObjects()

    firstYear = 1994
    currentYear = year(timenow, "America/New_York")
    lastYear = currentYear + futureCycles * 4 + 4

    int nextEventTime = na

    for y = firstYear to lastYear
        if (y - 1994) % 4 == 0
            eventTime = getMidtermDate(y)

            if eventTime > timenow
                if na(nextEventTime) or eventTime < nextEventTime
                    nextEventTime := eventTime

    for y = firstYear to lastYear
        if (y - 1994) % 4 == 0
            eventTime = getMidtermDate(y)
            labelText = eventTime == nextEventTime ? "US MIDTERMS\n" + formatDate(y) : "US Midterms\n" + formatDate(y)

            createEvent(eventTime, labelText, nextEventTime)
````
