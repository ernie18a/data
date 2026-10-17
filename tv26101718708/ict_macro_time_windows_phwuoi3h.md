# ICT Macro Time Windows

- url: https://www.tradingview.com/script/PHwuOi3h-ICT-Macro-Time-Windows/
- type: indicator
- pine_id: PUB;669e4519a68c49be810a7dba03512559
- version: 1.0

## Description

For everyone who wants to display The ICT Macros on their chart

## Source Code

````pine
//@version=5
indicator("Macro Time Windows - Infinite UTC-4", overlay=true, max_lines_count=500, max_labels_count=500)

// =========================
// Inputs
// =========================
lineColor         = input.color(color.new(color.gray, 78), "Line Color")
lineWidth         = input.int(1, "Line Width", minval=1, maxval=5)
showLabels        = input.bool(true, "Show Time Labels")
textColor         = input.color(color.new(color.gray, 25), "Text Color")
labelOffsetTicks  = input.int(20, "Live Label Offset Below Price (Ticks)", minval=1, maxval=500)
timezoneInput     = input.string("Etc/GMT+4", "Time Zone")

pastMacros        = input.int(8, "Past Macro Windows", minval=0, maxval=100)
futureMacros      = input.int(2, "Future Macro Windows", minval=0, maxval=20)
futureLookback    = input.int(300, "Future Label Midpoint Lookback", minval=20, maxval=5000)

showBackground    = input.bool(true, "Show Macro Background")
backgroundColor   = input.color(color.new(color.gray, 92), "Macro Background Color")

// =========================
// Helper Functions
// =========================
formatTime(_h, _m) =>
    hh = str.tostring(_h)
    mm = str.tostring(_m)
    hh := str.length(hh) == 1 ? "0" + hh : hh
    mm := str.length(mm) == 1 ? "0" + mm : mm
    hh + ":" + mm

isMacroMinute(_m) =>
    _m == 10 or _m == 50

isInsideMacroWindow(_m) =>
    _m >= 50 or _m < 10

// =========================
// Time Logic
// =========================
barHour   = hour(time, timezoneInput)
barMinute = minute(time, timezoneInput)

isMacroLine = timeframe.isintraday and isMacroMinute(barMinute)

// 1 macro window = 1 hour span (:50 to :10)
pastWindowMs = pastMacros * 60 * 60 * 1000
isWithinPastRange = (timenow - time) <= pastWindowMs

// =========================
// Background Fill
// =========================
insideMacroWindow = timeframe.isintraday and isInsideMacroWindow(barMinute)
showBgNow = showBackground and isWithinPastRange and insideMacroWindow

bgcolor(showBgNow ? backgroundColor : na)

// =========================
// Storage for Future Objects
// =========================
var line[]  futureLines  = array.new_line()
var label[] futureLabels = array.new_label()

// =========================
// Past / Current Macro Lines
// =========================
if isMacroLine and isWithinPastRange
    line.new(
         x1 = bar_index,
         y1 = 0,
         x2 = bar_index,
         y2 = 1,
         xloc = xloc.bar_index,
         extend = extend.both,
         color = lineColor,
         width = lineWidth,
         style = line.style_solid
     )

    if showLabels
        liveLabelY = low - (syminfo.mintick * labelOffsetTicks)

        label.new(
             x = bar_index,
             y = liveLabelY,
             text = formatTime(barHour, barMinute),
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_none,
             textcolor = textColor,
             size = size.tiny
         )

// =========================
// Future Macro Lines
// =========================
if barstate.islast and timeframe.isintraday
    if array.size(futureLines) > 0
        for i = 0 to array.size(futureLines) - 1
            line.delete(array.get(futureLines, i))

    if array.size(futureLabels) > 0
        for i = 0 to array.size(futureLabels) - 1
            label.delete(array.get(futureLabels, i))

    array.clear(futureLines)
    array.clear(futureLabels)

    tfSecs = timeframe.in_seconds()
    tfMins = tfSecs / 60.0

    if tfSecs > 0 and futureMacros > 0
        currentTotalMinutes = barHour * 60 + barMinute
        linesNeeded = futureMacros * 2
        found = 0

        futureHigh = ta.highest(high, futureLookback)
        futureLow  = ta.lowest(low, futureLookback)
        futureLabelY = (futureHigh + futureLow) / 2.0

        for i = 1 to 500
            candidate = currentTotalMinutes + i
            candidateMinute = candidate % 60

            if isMacroMinute(candidateMinute)
                found += 1

                barsAhead = int(math.round((candidate - currentTotalMinutes) / tfMins))
                futureX = bar_index + barsAhead

                futureHour = int(math.floor(candidate / 60)) % 24
                futureMin  = candidate % 60

                newLine = line.new(
                     x1 = futureX,
                     y1 = 0,
                     x2 = futureX,
                     y2 = 1,
                     xloc = xloc.bar_index,
                     extend = extend.both,
                     color = lineColor,
                     width = lineWidth,
                     style = line.style_solid
                 )
                array.push(futureLines, newLine)

                if showLabels
                    newLabel = label.new(
                         x = futureX,
                         y = futureLabelY,
                         text = formatTime(futureHour, futureMin),
                         xloc = xloc.bar_index,
                         yloc = yloc.price,
                         style = label.style_none,
                         textcolor = textColor,
                         size = size.tiny
                     )
                    array.push(futureLabels, newLabel)

                if found >= linesNeeded
                    break
````
