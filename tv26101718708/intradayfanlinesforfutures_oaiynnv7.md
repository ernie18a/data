# IntraDayFanLinesForFutures

- url: https://www.tradingview.com/script/oAIyNNv7-IntraDayFanLinesForFutures/
- type: indicator
- pine_id: PUB;556068e2121c424e9eeb8a7885a0be1b
- version: 1.0

## Description

Using the market session open at 6pm ET as the vertex, the script looks for the highest high and lowest low up until 5am ET (past the "Kill Zone" in the London session).  From the highest high to lowest low, a measured move is created and then divided into eights.

What is special about this?  Strange but true, the algos seem to follow these lines.

Credit given to Bullish Bears Jeremy (bullishbears.com) for the initial concept.

## Source Code

````pine
//@version=6
// Credit to Bullish Bears Jeremy for the original concept
indicator("FanLinesTVRev2", overlay = true, max_lines_count = 100)

//==================== Inputs ====================//
tz                    = input.string("America/New_York", "Timezone")
openHour              = input.int(18, "Open Hour ET", minval = 0, maxval = 23)
openMinute            = input.int(0, "Open Minute ET", minval = 0, maxval = 59)
endHour               = input.int(5, "End Hour ET", minval = 0, maxval = 23)
endMinute             = input.int(0, "End Minute ET", minval = 0, maxval = 59)

boundaryLineWidth     = input.int(2, "Boundary Line Width", minval = 1, maxval = 10)
verticalLineWidth     = input.int(2, "Vertical Line Width", minval = 1, maxval = 10)
fanLineWidth          = input.int(5, "Fan Line Width", minval = 1, maxval = 10)

fanLineColor          = input.color(color.orange, "Fan Line Color")
showVerticalAnchor    = input.bool(true, "Show Vertical Anchor Line")
verticalPaddingTicks  = input.int(20, "Vertical Line Padding Ticks", minval = 0, maxval = 200)
forwardProjectionBars = input.int(10, "Forward Projection Bars", minval = 0, maxval = 100)

//==================== Time logic ====================//
nyHour    = hour(time, tz)
nyMinute  = minute(time, tz)
nyYear    = year(time, tz)
nyMonth   = month(time, tz)
nyDay     = dayofmonth(time, tz)

openMinutes = openHour * 60 + openMinute
endMinutes  = endHour * 60 + endMinute
curMinutes  = nyHour * 60 + nyMinute

// Overnight window: starts at 18:00 and ends next day at 05:00
inWindow = curMinutes >= openMinutes or curMinutes < endMinutes

prevDayTime = time - 24 * 60 * 60 * 1000

// Session key: bars from 18:00 onward belong to that date; bars before 05:00 belong to prior date
sessionKey = curMinutes >= openMinutes ?
     nyYear * 10000 + nyMonth * 100 + nyDay :
     year(prevDayTime, tz) * 10000 + month(prevDayTime, tz) * 100 + dayofmonth(prevDayTime, tz)

//==================== Persistent state ====================//
var int   activeSessionKey = na

var int   vertexBar        = na
var float vertexPrice      = na

var float highestHigh      = na
var int   highestHighBar   = na
var int   highestHighTime  = na

var float lowestLow        = na
var int   lowestLowBar     = na
var int   lowestLowTime    = na

var int   rightAnchorBar   = na
var float rightAnchorPrice = na
var int   rightAnchorTime  = na

var line  boundaryHighLine = na
var line  boundaryLowLine  = na
var line  verticalLineObj  = na
var array<line> fanLines   = array.new_line()

//==================== Utility ====================//
projectPriceToBar(startBar, startPrice, anchorBar, anchorPrice, targetBar) =>
    deltaBars = anchorBar - startBar
    deltaBars == 0 ? anchorPrice : startPrice + ((anchorPrice - startPrice) / deltaBars) * (targetBar - startBar)

//==================== New session reset ====================//
newSession = inWindow and (na(activeSessionKey) or sessionKey != activeSessionKey)

if newSession
    activeSessionKey := sessionKey

    // Delete prior lines
    if not na(boundaryHighLine)
        line.delete(boundaryHighLine)
    if not na(boundaryLowLine)
        line.delete(boundaryLowLine)
    if not na(verticalLineObj)
        line.delete(verticalLineObj)

    if array.size(fanLines) > 0
        for i = 0 to array.size(fanLines) - 1
            ln = array.get(fanLines, i)
            if not na(ln)
                line.delete(ln)
        array.clear(fanLines)

    // Reset session state
    vertexBar        := na
    vertexPrice      := na
    highestHigh      := na
    highestHighBar   := na
    highestHighTime  := na
    lowestLow        := na
    lowestLowBar     := na
    lowestLowTime    := na
    rightAnchorBar   := na
    rightAnchorPrice := na
    rightAnchorTime  := na
    boundaryHighLine := na
    boundaryLowLine  := na
    verticalLineObj  := na

//==================== Session tracking ====================//
if inWindow and activeSessionKey == sessionKey
    if na(vertexBar)
        vertexBar   := bar_index
        vertexPrice := open

    if na(highestHigh) or high >= highestHigh
        highestHigh     := high
        highestHighBar  := bar_index
        highestHighTime := time

    if na(lowestLow) or low <= lowestLow
        lowestLow     := low
        lowestLowBar  := bar_index
        lowestLowTime := time

    if not na(highestHighBar) and not na(lowestLowBar)
        if highestHighTime > lowestLowTime
            rightAnchorBar   := highestHighBar
            rightAnchorPrice := highestHigh
            rightAnchorTime  := highestHighTime
        else if highestHighTime < lowestLowTime
            rightAnchorBar   := lowestLowBar
            rightAnchorPrice := lowestLow
            rightAnchorTime  := lowestLowTime
        else
            // Tie goes bullish
            rightAnchorBar   := highestHighBar
            rightAnchorPrice := highestHigh
            rightAnchorTime  := highestHighTime

//==================== Draw/update only on last bar ====================//
if barstate.islast
    ready = not na(vertexBar) and not na(highestHighBar) and not na(lowestLowBar) and not na(rightAnchorBar)

    if ready
        rng = highestHigh - lowestLow

        if rng > 0
            projBar = bar_index + forwardProjectionBars

            extendedHighPrice = projectPriceToBar(vertexBar, vertexPrice, highestHighBar, highestHigh, projBar)
            extendedLowPrice  = projectPriceToBar(vertexBar, vertexPrice, lowestLowBar, lowestLow, projBar)

            // Boundary high
            if na(boundaryHighLine)
                boundaryHighLine := line.new(
                     vertexBar, vertexPrice,
                     projBar, extendedHighPrice,
                     xloc = xloc.bar_index,
                     extend = extend.none,
                     color = color.red,
                     width = boundaryLineWidth)
            else
                line.set_xy1(boundaryHighLine, vertexBar, vertexPrice)
                line.set_xy2(boundaryHighLine, projBar, extendedHighPrice)
                line.set_color(boundaryHighLine, color.red)
                line.set_width(boundaryHighLine, boundaryLineWidth)

            // Boundary low
            if na(boundaryLowLine)
                boundaryLowLine := line.new(
                     vertexBar, vertexPrice,
                     projBar, extendedLowPrice,
                     xloc = xloc.bar_index,
                     extend = extend.none,
                     color = color.red,
                     width = boundaryLineWidth)
            else
                line.set_xy1(boundaryLowLine, vertexBar, vertexPrice)
                line.set_xy2(boundaryLowLine, projBar, extendedLowPrice)
                line.set_color(boundaryLowLine, color.red)
                line.set_width(boundaryLowLine, boundaryLineWidth)

            // Vertical anchor
            if showVerticalAnchor
                verticalTop    = highestHigh + verticalPaddingTicks * syminfo.mintick
                verticalBottom = lowestLow  - verticalPaddingTicks * syminfo.mintick

                if na(verticalLineObj)
                    verticalLineObj := line.new(
                         rightAnchorBar, verticalTop,
                         rightAnchorBar, verticalBottom,
                         xloc = xloc.bar_index,
                         extend = extend.none,
                         color = color.red,
                         width = verticalLineWidth)
                else
                    line.set_xy1(verticalLineObj, rightAnchorBar, verticalTop)
                    line.set_xy2(verticalLineObj, rightAnchorBar, verticalBottom)
                    line.set_color(verticalLineObj, color.red)
                    line.set_width(verticalLineObj, verticalLineWidth)
            else
                if not na(verticalLineObj)
                    line.delete(verticalLineObj)
                    verticalLineObj := na

            // Create 25 fan lines once
            if array.size(fanLines) == 0
                for _ = 0 to 24
                    array.push(
                        fanLines,
                        line.new(
                            vertexBar, vertexPrice,
                            projBar, vertexPrice,
                            xloc = xloc.bar_index,
                            extend = extend.none,
                            color = fanLineColor,
                            width = fanLineWidth
                        )
                    )

            // Update 25 fan lines
            for i = 0 to 24
                level = -1.0 + 0.125 * i
                anchorTargetPrice   = highestHigh - (level * rng)
                extendedTargetPrice = projectPriceToBar(vertexBar, vertexPrice, rightAnchorBar, anchorTargetPrice, projBar)

                ln = array.get(fanLines, i)
                line.set_xy1(ln, vertexBar, vertexPrice)
                line.set_xy2(ln, projBar, extendedTargetPrice)
                line.set_color(ln, fanLineColor)
                line.set_width(ln, fanLineWidth)
````
