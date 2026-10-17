# Custom DCL Historical Lines

- url: https://www.tradingview.com/script/Tkbfqkqr-Custom-DCL-Historical-Lines/
- type: indicator
- pine_id: PUB;ab9dc014f2024b71895725650c3186e8
- version: 1.0

## Description

Plots historical daily closing price lines. 
Times and all settings can be customized to  however the user would like them to be. 

compatible with futures and equities.
Likely compatible with other markets but has not been tested.

## Source Code

````pine
//@version=5
indicator(title="Custom DCL Historical Lines", shorttitle="Custom DCL Hist", overlay=true, max_lines_count=500, max_labels_count=500)

// --- CLOSE SETTINGS ---
closeHour = input.int(16, "Daily Close Hour", minval=0, maxval=23)
closeMinute = input.int(0, "Daily Close Minute", minval=0, maxval=59)
closeTimezone = input.string("America/New_York", "Time Zone", options=["exchange", "America/New_York", "Etc/UTC", "Europe/London"])
closeTF = input.string("1", "Close Calculation Timeframe", tooltip="Use 1 for most accurate close calculation on higher timeframe charts.")

// --- DAY FILTER ---
closeDaysInput = input.string("Monday-Friday", "Days to Capture Close", options=["Monday-Friday", "Sunday-Friday"])

// --- DISPLAY SETTINGS ---
showSession = input.session("0930-1600", "Draw Line During Session")
levelsToKeep = input.int(20, "Number of Daily Closes to Keep", minval=1, maxval=200)

// --- LINE SETTINGS ---
lineColor = input.color(color.rgb(80, 144, 163), "Line Color")
lineWidth = input.int(2, "Line Width", minval=1, maxval=5)
lineStyleInput = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"])

// --- LABEL SETTINGS ---
showLabels = input.bool(true, "Show Labels")
showOnlyLatestLabel = input.bool(false, "Show Only Latest Label")

labelPreset = input.string("Closing Price ", "Label Preset", options=["Close", "Daily Close", "Prev Close", "Closing Price ", "PD Close", "Custom Text"])
customLabelText = input.string("Closing Price ", "Custom Label Text")

labelPositionInput = input.string("Right", "Label Position", options=["Left", "Right"])
labelRightOffsetBars = input.int(25, "Right Label Offset Bars", minval=0, maxval=100)

labelSizeInput = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal", "Large"])
labelLookInput = input.string("Text Only", "Label Look", options=["Text Only", "Filled", "Outline"])

labelVerticalOffsetTicks = input.int(6, "Label Vertical Offset Ticks", minval=0, maxval=100)
labelTextColor = input.color(color.black, "Label Text Color")
labelFillColor = input.color(color.rgb(80, 144, 163), "Label Fill / Outline Color")

info = input.bool(true, "ⓘ Timing Note", tooltip="TradingView bars:\n\n• Closes use bar END time.\n• This script calculates the close from the selected lower timeframe.\n\nExample:\nOn a 1-hour chart, the 16:00 close is calculated from the 1-minute chart.")

// --- STYLE LOGIC ---
lineStyle = lineStyleInput == "Dashed" ? line.style_dashed : lineStyleInput == "Dotted" ? line.style_dotted : line.style_solid

labelSize = labelSizeInput == "Tiny" ? size.tiny : labelSizeInput == "Normal" ? size.normal : labelSizeInput == "Large" ? size.large : size.small

labelStyle = labelLookInput == "Text Only" ? label.style_none : labelPositionInput == "Right" ? label.style_label_left : label.style_label_right

labelBgColor = labelLookInput == "Text Only" ? color.new(color.white, 100) : labelLookInput == "Outline" ? color.new(labelFillColor, 85) : labelFillColor

labelPrefix = labelPreset == "Custom Text" ? customLabelText : labelPreset == "Close" ? "Close " : labelPreset == "Daily Close" ? "Daily Close " : labelPreset == "Prev Close" ? "Prev Close " : labelPreset == "PD Close" ? "PD Close " : "Closing Price "

// --- LOWER TIMEFRAME CLOSE LOGIC ---
getCloseData() =>
    closeBarDay = dayofweek(time_close, closeTimezone)

    dayAllowed = closeDaysInput == "Monday-Friday" ? (closeBarDay >= dayofweek.monday and closeBarDay <= dayofweek.friday) : (closeBarDay >= dayofweek.sunday and closeBarDay <= dayofweek.friday)

    closeTargetTime = timestamp(closeTimezone, year(time_close, closeTimezone), month(time_close, closeTimezone), dayofmonth(time_close, closeTimezone), closeHour, closeMinute)

    isTargetClose = barstate.isconfirmed and dayAllowed and time_close >= closeTargetTime and nz(time_close[1], 0) < closeTargetTime

    capturedPrice = ta.valuewhen(isTargetClose, close, 0)
    capturedTime = ta.valuewhen(isTargetClose, time_close, 0)

    [capturedPrice, capturedTime]

[ltfClosePrice, ltfCloseTime] = request.security(syminfo.tickerid, closeTF, getCloseData(), barmerge.gaps_off, barmerge.lookahead_off)

isNewCapturedClose = not na(ltfCloseTime) and ltfCloseTime != nz(ltfCloseTime[1])

inDrawSession = not na(time(timeframe.period, showSession, closeTimezone))

// --- STATE ---
var float activeClosePrice = na
var line activeLine = na
var label activeLabel = na

var lines = array.new_line()
var labels = array.new_label()

// --- EXTEND ACTIVE LINE ---
if not na(activeLine) and inDrawSession
    line.set_x2(activeLine, bar_index)

// --- KEEP ACTIVE LABEL ON FAR RIGHT OF CURRENT CHART ---
if barstate.islast and not na(activeLabel) and not na(activeClosePrice)
    label.set_y(activeLabel, activeClosePrice + labelVerticalOffsetTicks * syminfo.mintick)

    if labelPositionInput == "Right"
        label.set_x(activeLabel, bar_index + labelRightOffsetBars)
    else
        label.set_x(activeLabel, line.get_x1(activeLine))

// --- CREATE NEW CLOSE LEVEL ---
if isNewCapturedClose
    if not na(activeLine)
        line.set_x2(activeLine, bar_index)
        line.set_extend(activeLine, extend.none)

    activeClosePrice := ltfClosePrice

    activeLine := line.new(bar_index, activeClosePrice, bar_index + 1, activeClosePrice, xloc=xloc.bar_index, extend=extend.right, color=lineColor, width=lineWidth, style=lineStyle)
    array.push(lines, activeLine)

    if showLabels
        if showOnlyLatestLabel and not na(activeLabel)
            label.delete(activeLabel)

        labelX = labelPositionInput == "Right" ? bar_index + labelRightOffsetBars : bar_index
        labelY = activeClosePrice + labelVerticalOffsetTicks * syminfo.mintick
        labelText = labelPrefix + str.tostring(activeClosePrice, format.mintick)

        activeLabel := label.new(labelX, labelY, labelText, style=labelStyle, color=labelBgColor, textcolor=labelTextColor, xloc=xloc.bar_index, yloc=yloc.price, size=labelSize)
        array.push(labels, activeLabel)

    if array.size(lines) > levelsToKeep
        line.delete(array.shift(lines))

    if array.size(labels) > levelsToKeep
        label.delete(array.shift(labels))
````
