# [Dragon] AOI v1.3

- url: https://www.tradingview.com/script/wqVBED7E-Dragon-AOI-v1-3/
- type: indicator
- pine_id: PUB;e467419e928b451d95bdb7a779ac5fa6
- version: 4.0

## Description

[Dragon] AOI v1.3 is an intraday futures trading indicator designed to help identify structured areas of interest using session-based levels, VWAPs, ORB levels, and custom Fibonacci ranges.

Each fib includes configurable direction modes, negative levels, preset fib templates, label controls, and optional .786 highlighting.

This tool is intended to help traders identify price areas where multiple technical levels may align. It does not provide buy or sell signals. Traders should use their own execution model, risk management, and confirmation process before entering trades.

Built primarily for Futures intraday trading, but settings can be adjusted for other futures instruments and session-based workflows.

This indicator is designed for identifying confluence areas, not generating automatic trade entries. Use it with a defined entry model and risk plan.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © long_nguyen6248

// Credit / Inspiration:
// The fib-levels, VWAPS, ORB, & session H/L concepts used in this indicator were inspired by ASFX, Max Option, & P2P.
// The implementation, layout, session logic, and AOI structure were built and customized
// for my own trading workflow.

//@version=6
indicator("[Dragon] AOI v1.3.1", "AOI v1.3.1", true, max_lines_count = 500, max_labels_count = 500, max_bars_back = 5000)

//====================================================
// GLOBAL SETTINGS
//====================================================
displayMode = display.all - display.status_line
vwapSource = input.source(ohlc4, "VWAP Source", display = displayMode)
timezonePreset = input.string("America/Chicago", "Main Timezone", options = ["America/Chicago", "America/New_York", "America/Los_Angeles", "Europe/London", "Asia/Tokyo", "Asia/Ho_Chi_Minh", "Custom"])
customTimezone = input.string("America/Chicago", "Custom Timezone")
mainTZ = timezonePreset == "Custom" ? customTimezone : timezonePreset


//====================================================
// AOI FIB ENGINE v1.3.1
//====================================================
groupAoiControls = "AOI Fib Controls"
showAoiAsiaFib = input.bool(true, "Show Fib 1: Sydney/Tokyo", group = groupAoiControls)
showAoiNineFib = input.bool(true, "Show Fib 2: 9AM 1H Candle", group = groupAoiControls)
aoiFibDisplayMode = input.string("Fib 2 Overrides Fib 1", "Fib Auto Display Behavior", options = ["Fib 2 Overrides Fib 1", "Fib 1 Overrides Fib 2", "Allow Both"], group = groupAoiControls)
aoiUseP2PStyle = input.bool(false, "Dark Color Style", group = groupAoiControls)

groupAoiLevels = "AOI Fib Level Checkboxes"
aoiShowLevel0 = input.bool(true, "Show 0", group = groupAoiLevels)
aoiShowLevel236 = input.bool(true, "Show 0.236", group = groupAoiLevels)
aoiShowLevel382 = input.bool(false, "Show 0.382", group = groupAoiLevels)
aoiShowLevel50 = input.bool(false, "Show 0.5", group = groupAoiLevels)
aoiShowLevel618 = input.bool(false, "Show 0.618", group = groupAoiLevels)
aoiShowLevel786 = input.bool(true, "Show 0.786", group = groupAoiLevels)
aoiShowLevel1 = input.bool(true, "Show 1", group = groupAoiLevels)
aoiShowLevelNeg236 = input.bool(true, "Show -0.236", group = groupAoiLevels)
aoiShowLevelNeg382 = input.bool(false, "Show -0.382", group = groupAoiLevels)
aoiShowLevelNeg50 = input.bool(false, "Show -0.5", group = groupAoiLevels)
aoiShowLevelNeg618 = input.bool(false, "Show -0.618", group = groupAoiLevels)
aoiShowLevelNeg786 = input.bool(true, "Show -0.786", group = groupAoiLevels)
aoiShowLevelNeg1 = input.bool(true, "Show -1", group = groupAoiLevels)

groupAoiAsia = "AOI Fib 1 Settings: Sydney / Tokyo"
aoiAsiaSession = input.session("1700-0400", "Sydney/Tokyo Window", group = groupAoiAsia)
aoiAsiaDirectionMode = input.string("Auto: Open vs Close", "Sydney/Tokyo Direction", options = ["Manual Bullish", "Manual Bearish", "Neutral / Both Directions", "Auto: Open vs Close"], group = groupAoiAsia)
aoiAsiaFlipDirection = input.bool(false, "Flip Sydney/Tokyo Direction", group = groupAoiAsia)
aoiAsiaAfter10Mode = input.string("Hide After 10AM", "Sydney/Tokyo Fib After 10AM", options = ["Hide After 10AM", "Keep Showing"], group = groupAoiAsia)

groupAoiNine = "AOI Fib 2 Settings: 9AM 1H Candle"
aoiNineSession = input.session("0900-1000", "9AM Candle Window", group = groupAoiNine)
aoiNineDirectionMode = input.string("Auto: Candle Open vs Close", "9AM Candle Direction", options = ["Auto: Candle Open vs Close", "Manual Bullish", "Manual Bearish", "Neutral / Both Directions"], group = groupAoiNine)
aoiNineFlipDirection = input.bool(false, "Flip Fib 2 Direction", group = groupAoiNine)

groupAoiStyle = "AOI Fib Style / Advanced"
aoiMainFibColor = input.color(color.rgb(40, 40, 40), "Fib 1 Main Color", group = groupAoiStyle)
aoiReverseFibColor = input.color(color.rgb(190, 120, 25), "Fib 1 Reverse Color", group = groupAoiStyle)
aoiNineMainFibColor = input.color(color.rgb(20, 80, 170), "Fib 2 Main Color", group = groupAoiStyle)
aoiNineReverseFibColor = input.color(color.rgb(170, 90, 180), "Fib 2 Reverse Color", group = groupAoiStyle)
aoiP2PMainFibColor = input.color(color.rgb(0, 145, 155), "P2P Main Fib Color", group = groupAoiStyle)
aoiP2PReverseFibColor = input.color(color.rgb(0, 95, 105), "P2P Reverse Fib Color", group = groupAoiStyle)
aoiP2PHighlight786Color = input.color(color.rgb(105, 30, 165), "P2P 0.786 Highlight Color", group = groupAoiStyle)
aoiHighlight786 = input.bool(true, "Highlight 0.786 / -0.786", group = groupAoiStyle)
aoiHighlight786Color = input.color(color.rgb(255, 180, 0), "0.786 Highlight Color", group = groupAoiStyle)
aoiLineWidth = input.int(1, "Line Width", minval = 1, maxval = 4, group = groupAoiStyle)
aoiHighlightLineWidth = input.int(2, "0.786 Highlight Width", minval = 1, maxval = 5, group = groupAoiStyle)
aoiLineStyleInput = input.string("Solid", "Line Style", options = ["Solid", "Dashed", "Dotted"], group = groupAoiStyle)
aoiLineExtendInput = input.string("Extend Right", "Line Extension", options = ["Extend Right", "No Extension"], group = groupAoiStyle)
aoiShowLabels = input.bool(true, "Show Labels", group = groupAoiStyle)
aoiLabelOffsetBars = input.int(25, "Label Offset Bars", minval = 1, maxval = 300, group = groupAoiStyle)
aoiLabelSizeInput = input.string("Tiny", "Label Size", options = ["Tiny", "Small", "Normal"], group = groupAoiStyle)
aoiShowStatusTable = input.bool(true, "Show Status Table", group = groupAoiStyle)
aoiTablePosInput = input.string("Bottom Left", "Table Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = groupAoiStyle)
aoiTableTextSizeInput = input.string(
     "Small",
     "Table Text Size",
     options = ["Tiny", "Small", "Normal"],
     group = groupAoiStyle
)

aoiTableTextSize = aoiTableTextSizeInput == "Tiny"   ? size.tiny : aoiTableTextSizeInput == "Small"  ? size.small : size.normal

getAoiLabelSize(_size) =>
    switch _size
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal

getAoiTablePos(_pos) =>
    switch _pos
        "Top Right" => position.top_right
        "Top Left" => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left

aoiFibLevel(_start, _end, _ratio) =>
    _start + ((_end - _start) * _ratio)

aoiTimeAfter10(_tz) =>
    hour(time, _tz) > 10 or (hour(time, _tz) == 10 and minute(time, _tz) >= 0)

aoiPriceText(_price) =>
    str.tostring(_price, format.mintick)

aoiIs786Level(_ratio) =>
    _ratio == 0.786 or _ratio == -0.786

var float[] aoiFibRatios = array.from(0.0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0, -0.236, -0.382, -0.5, -0.618, -0.786, -1.0)
var string[] aoiFibNames = array.from("0", "0.236", "0.382", "0.5", "0.618", "0.786", "1", "-0.236", "-0.382", "-0.5", "-0.618", "-0.786", "-1")

aoiLevelEnabled(_index) =>
    float r = array.get(aoiFibRatios, _index)
    r == 0.0 ? aoiShowLevel0 :
     r == 0.236 ? aoiShowLevel236 :
     r == 0.382 ? aoiShowLevel382 :
     r == 0.5 ? aoiShowLevel50 :
     r == 0.618 ? aoiShowLevel618 :
     r == 0.786 ? aoiShowLevel786 :
     r == 1.0 ? aoiShowLevel1 :
     r == -0.236 ? aoiShowLevelNeg236 :
     r == -0.382 ? aoiShowLevelNeg382 :
     r == -0.5 ? aoiShowLevelNeg50 :
     r == -0.618 ? aoiShowLevelNeg618 :
     r == -0.786 ? aoiShowLevelNeg786 :
     r == -1.0 ? aoiShowLevelNeg1 : false

// AOI Fib 1 capture
inAoiAsia = not na(time(timeframe.period, aoiAsiaSession, mainTZ))
aoiAsiaStart = inAoiAsia and not inAoiAsia[1]
aoiAsiaEnd = not inAoiAsia and inAoiAsia[1]

var float aoiAsiaBuildOpen = na
var float aoiAsiaBuildHigh = na
var float aoiAsiaBuildLow = na
var float aoiAsiaBuildClose = na
var float aoiAsiaLockedOpen = na
var float aoiAsiaLockedHigh = na
var float aoiAsiaLockedLow = na
var float aoiAsiaLockedClose = na
var int aoiAsiaEndBar = na
var bool aoiAsiaLocked = false

if aoiAsiaStart
    aoiAsiaBuildOpen := open
    aoiAsiaBuildHigh := high
    aoiAsiaBuildLow := low
    aoiAsiaBuildClose := close
    aoiAsiaLockedOpen := na
    aoiAsiaLockedHigh := na
    aoiAsiaLockedLow := na
    aoiAsiaLockedClose := na
    aoiAsiaEndBar := na
    aoiAsiaLocked := false

if inAoiAsia
    aoiAsiaBuildHigh := na(aoiAsiaBuildHigh) ? high : math.max(aoiAsiaBuildHigh, high)
    aoiAsiaBuildLow := na(aoiAsiaBuildLow) ? low : math.min(aoiAsiaBuildLow, low)
    aoiAsiaBuildClose := close

if aoiAsiaEnd and not na(aoiAsiaBuildOpen)
    aoiAsiaLockedOpen := aoiAsiaBuildOpen
    aoiAsiaLockedHigh := aoiAsiaBuildHigh
    aoiAsiaLockedLow := aoiAsiaBuildLow
    aoiAsiaLockedClose := aoiAsiaBuildClose
    aoiAsiaEndBar := bar_index
    aoiAsiaLocked := true

// AOI Fib 2 capture
inAoiNine = not na(time(timeframe.period, aoiNineSession, mainTZ))
aoiNineStart = inAoiNine and not inAoiNine[1]
aoiNineEnd = not inAoiNine and inAoiNine[1]

var float aoiNineBuildOpen = na
var float aoiNineBuildHigh = na
var float aoiNineBuildLow = na
var float aoiNineBuildClose = na
var float aoiNineLockedOpen = na
var float aoiNineLockedHigh = na
var float aoiNineLockedLow = na
var float aoiNineLockedClose = na
var int aoiNineEndBar = na
var bool aoiNineLocked = false

if aoiNineStart
    aoiNineBuildOpen := open
    aoiNineBuildHigh := high
    aoiNineBuildLow := low
    aoiNineBuildClose := close
    aoiNineLockedOpen := na
    aoiNineLockedHigh := na
    aoiNineLockedLow := na
    aoiNineLockedClose := na
    aoiNineEndBar := na
    aoiNineLocked := false

if inAoiNine
    aoiNineBuildHigh := na(aoiNineBuildHigh) ? high : math.max(aoiNineBuildHigh, high)
    aoiNineBuildLow := na(aoiNineBuildLow) ? low : math.min(aoiNineBuildLow, low)
    aoiNineBuildClose := close

if aoiNineEnd and not na(aoiNineBuildOpen)
    aoiNineLockedOpen := aoiNineBuildOpen
    aoiNineLockedHigh := aoiNineBuildHigh
    aoiNineLockedLow := aoiNineBuildLow
    aoiNineLockedClose := aoiNineBuildClose
    aoiNineEndBar := bar_index
    aoiNineLocked := true

resolveAoiDirection(_mode, _open, _close, _flipDirection) =>
    int autoDir = 0
    if not na(_open) and not na(_close)
        autoDir := _close > _open ? 1 : _close < _open ? -1 : 0
    bool drawPrimary = false
    bool drawReverse = false
    if _mode == "Manual Bullish"
        drawPrimary := true
        drawReverse := false
    else if _mode == "Manual Bearish"
        drawPrimary := false
        drawReverse := true
    else if _mode == "Neutral / Both Directions"
        drawPrimary := true
        drawReverse := true
    else
        if autoDir == 1
            drawPrimary := true
            drawReverse := false
        else if autoDir == -1
            drawPrimary := false
            drawReverse := true
        else
            drawPrimary := true
            drawReverse := true
    if _flipDirection and not (drawPrimary and drawReverse)
        bool temp = drawPrimary
        drawPrimary := drawReverse
        drawReverse := temp
    [drawPrimary, drawReverse]

[aoiAsiaDrawPrimary, aoiAsiaDrawReverse] = resolveAoiDirection(aoiAsiaDirectionMode, aoiAsiaLockedOpen, aoiAsiaLockedClose, aoiAsiaFlipDirection)
[aoiNineDrawPrimary, aoiNineDrawReverse] = resolveAoiDirection(aoiNineDirectionMode, aoiNineLockedOpen, aoiNineLockedClose, aoiNineFlipDirection)

aoiIsAfter10 = aoiTimeAfter10(mainTZ)
aoiAsiaRawCanShow = showAoiAsiaFib and aoiAsiaLocked and not inAoiAsia and not na(aoiAsiaLockedHigh) and not na(aoiAsiaLockedLow) and (aoiAsiaAfter10Mode == "Keep Showing" or not aoiIsAfter10)
aoiNineRawCanShow = showAoiNineFib and aoiNineLocked and not inAoiNine and not na(aoiNineLockedHigh) and not na(aoiNineLockedLow)
aoiAsiaCanShow = aoiAsiaRawCanShow and (aoiFibDisplayMode == "Allow Both" or not (aoiFibDisplayMode == "Fib 2 Overrides Fib 1" and aoiNineRawCanShow))
aoiNineCanShow = aoiNineRawCanShow and (aoiFibDisplayMode == "Allow Both" or not (aoiFibDisplayMode == "Fib 1 Overrides Fib 2" and aoiAsiaRawCanShow))

getAoiLineStyle(_style) =>
    _style == "Dashed" ? line.style_dashed :
     _style == "Dotted" ? line.style_dotted :
     line.style_solid

aoiLineExtend = aoiLineExtendInput == "Extend Right" ? extend.right : extend.none
aoiLineStyle = getAoiLineStyle(aoiLineStyleInput)
aoiLabelSize = getAoiLabelSize(aoiLabelSizeInput)

aoiIsP2PMode = aoiUseP2PStyle
var line[] aoiAsiaPrimaryLines = array.new<line>(13, na)
var label[] aoiAsiaPrimaryLabels = array.new<label>(13, na)
var line[] aoiAsiaReverseLines = array.new<line>(13, na)
var label[] aoiAsiaReverseLabels = array.new<label>(13, na)
var line[] aoiNinePrimaryLines = array.new<line>(13, na)
var label[] aoiNinePrimaryLabels = array.new<label>(13, na)
var line[] aoiNineReverseLines = array.new<line>(13, na)
var label[] aoiNineReverseLabels = array.new<label>(13, na)

deleteAoiFibObjects(_lines, _labels) =>
    for i = 0 to array.size(_lines) - 1
        line _ln = array.get(_lines, i)
        if not na(_ln)
            line.delete(_ln)
            array.set(_lines, i, na)
        label _lb = array.get(_labels, i)
        if not na(_lb)
            label.delete(_lb)
            array.set(_labels, i, na)

syncAoiFib(_lines, _labels, _show, _startPrice, _endPrice, _x1, _baseClr, _p2pBaseClr) =>
    if not _show or na(_startPrice) or na(_endPrice) or na(_x1)
        deleteAoiFibObjects(_lines, _labels)
    else
        for i = 0 to array.size(aoiFibRatios) - 1
            bool enabled = aoiLevelEnabled(i)
            float ratio = array.get(aoiFibRatios, i)
            string name = array.get(aoiFibNames, i)
            float y = aoiFibLevel(_startPrice, _endPrice, ratio)
            color activeBaseColor = aoiIsP2PMode ? _p2pBaseClr : _baseClr
            bool isHighlight = aoiHighlight786 and aoiIs786Level(ratio)
            color activeHighlightColor = aoiIsP2PMode ? aoiP2PHighlight786Color : aoiHighlight786Color
            color finalColor = isHighlight ? activeHighlightColor : activeBaseColor
            int finalWidth = isHighlight ? aoiHighlightLineWidth : aoiLineWidth
            line _ln = array.get(_lines, i)
            label _lb = array.get(_labels, i)
            if enabled
                if na(_ln)
                    _ln := line.new(_x1, y, bar_index, y, xloc = xloc.bar_index, extend = aoiLineExtend, color = finalColor, style = aoiLineStyle, width = finalWidth)
                    array.set(_lines, i, _ln)
                else
                    line.set_x1(_ln, _x1)
                    line.set_y1(_ln, y)
                    line.set_x2(_ln, bar_index)
                    line.set_y2(_ln, y)
                    line.set_extend(_ln, aoiLineExtend)
                    line.set_color(_ln, finalColor)
                    line.set_style(_ln, aoiLineStyle)
                    line.set_width(_ln, finalWidth)
                if aoiShowLabels
                    string txt = name + " (" + aoiPriceText(y) + ")"
                    int labelX = bar_index + aoiLabelOffsetBars
                    if na(_lb)
                        _lb := label.new(labelX, y, txt, xloc = xloc.bar_index, style = label.style_none, textcolor = finalColor, size = aoiLabelSize)
                        array.set(_labels, i, _lb)
                    else
                        label.set_x(_lb, labelX)
                        label.set_y(_lb, y)
                        label.set_text(_lb, txt)
                        label.set_textcolor(_lb, finalColor)
                        label.set_size(_lb, aoiLabelSize)
                else
                    if not na(_lb)
                        label.delete(_lb)
                        array.set(_labels, i, na)
            else
                if not na(_ln)
                    line.delete(_ln)
                    array.set(_lines, i, na)
                if not na(_lb)
                    label.delete(_lb)
                    array.set(_labels, i, na)

// Primary / Manual Bullish orientation matches your manual TradingView bullish fib behavior.
aoiAsiaPrimaryStart = aoiAsiaLockedHigh
aoiAsiaPrimaryEnd = aoiAsiaLockedLow
aoiAsiaReverseStart = aoiAsiaLockedLow
aoiAsiaReverseEnd = aoiAsiaLockedHigh

aoiNinePrimaryStart = aoiNineLockedHigh
aoiNinePrimaryEnd = aoiNineLockedLow
aoiNineReverseStart = aoiNineLockedLow
aoiNineReverseEnd = aoiNineLockedHigh

syncAoiFib(aoiAsiaPrimaryLines, aoiAsiaPrimaryLabels, aoiAsiaCanShow and aoiAsiaDrawPrimary, aoiAsiaPrimaryStart, aoiAsiaPrimaryEnd, aoiAsiaEndBar, aoiMainFibColor, aoiP2PMainFibColor)
syncAoiFib(aoiAsiaReverseLines, aoiAsiaReverseLabels, aoiAsiaCanShow and aoiAsiaDrawReverse, aoiAsiaReverseStart, aoiAsiaReverseEnd, aoiAsiaEndBar, aoiReverseFibColor, aoiP2PReverseFibColor)
syncAoiFib(aoiNinePrimaryLines, aoiNinePrimaryLabels, aoiNineCanShow and aoiNineDrawPrimary, aoiNinePrimaryStart, aoiNinePrimaryEnd, aoiNineEndBar, aoiNineMainFibColor, aoiP2PMainFibColor)
syncAoiFib(aoiNineReverseLines, aoiNineReverseLabels, aoiNineCanShow and aoiNineDrawReverse, aoiNineReverseStart, aoiNineReverseEnd, aoiNineEndBar, aoiNineReverseFibColor, aoiP2PReverseFibColor)

var table aoiStatusTable = table.new(getAoiTablePos(aoiTablePosInput), 1, 2, border_width = 1)

aoiActiveSessionText = aoiNineCanShow and aoiAsiaCanShow ? "Active: Fib 1 + Fib 2" : aoiNineCanShow ? "Active: Fib 2" : aoiAsiaCanShow ? "Active: Fib 1" : inAoiAsia ? "Building: Fib 1" : inAoiNine ? "Building: Fib 2" : "Active: None"

if barstate.islast and aoiShowStatusTable
    table.cell(aoiStatusTable, 0, 0, "[Dragon] AOI", text_color = color.white, bgcolor = color.new(color.black, 0), text_size = aoiTableTextSize)
    table.cell(aoiStatusTable, 0, 1, aoiActiveSessionText, text_color = color.white, bgcolor = color.new(color.gray, 75), text_size = aoiTableTextSize)

if barstate.islast and not aoiShowStatusTable
    table.clear(aoiStatusTable, 0, 0)



//====================================================
// VWAPS: START OF DAY + START OF NY
//====================================================
groupVWAP = "VWAPs"
showDayVWAP = input.bool(true, "Show Start of Day VWAP", group = groupVWAP)
dayVWAPColor = input.color(color.rgb(55, 55, 55), "Start of Day VWAP Color", group = groupVWAP)
dayVWAPWidth = input.int(2, "Start of Day VWAP Width", minval = 1, maxval = 5, group = groupVWAP)
dayVWAPStyleInput = input.string("Dotted", "Start of Day VWAP Style", options = ["Solid", "Dashed", "Dotted"], group = groupVWAP)
dayVWAPAnchorSession = input.session("1700-1701", "Start of Day Anchor", group = groupVWAP)
dayVWAPDisplaySession = input.session("1700-0830", "Start of Day Display Window", group = groupVWAP)
showDayVWAPOnlyOutsideNY = input.bool(true, "Auto Hide Start of Day VWAP During NY", group = groupVWAP)

showNYVWAP = input.bool(true, "Show Start of NY VWAP", group = groupVWAP)
nyVWAPColor = input.color(color.rgb(0, 95, 35), "Start of NY VWAP Color", group = groupVWAP)
nyVWAPWidth = input.int(2, "Start of NY VWAP Width", minval = 1, maxval = 5, group = groupVWAP)
nyVWAPStyleInput = input.string("Dotted", "Start of NY VWAP Style", options = ["Solid", "Dashed", "Dotted"], group = groupVWAP)
nyVWAPAnchorSession = input.session("0830-0831", "Start of NY Anchor", group = groupVWAP)
nyVWAPDisplaySession = input.session("0830-1600", "NY VWAP Display Window", group = groupVWAP)
showNYVWAPOnlyDuringNY = input.bool(true, "Show NY VWAP Only During NY Session", group = groupVWAP)

type AoiVwapLine
    chart.point[] points
    polyline[] lines

getVwapLineStyle(_style) =>
    _style == "Dashed" ? line.style_dashed :
     _style == "Dotted" ? line.style_dotted :
     line.style_solid

renderAoiVwapPolyline(_source, _anchor, _show, _color, _style, _width) =>
    var AoiVwapLine vwapArray = AoiVwapLine.new(array.new<chart.point>(na), array.new<polyline>(na))

    if _anchor
        if vwapArray.points.size() > 0 and vwapArray.lines.size() > 0
            vwapArray.lines.last().delete()
        vwapArray.lines.clear()
        vwapArray.points.clear()
        vwapArray.points.push(chart.point.from_time(time, _source))
    else
        if vwapArray.points.size() > 0
            vwapArray.points.push(chart.point.from_time(time, _source))
            if vwapArray.points.size() == 2002
                vwapArray.points.remove(1)

    if barstate.islast and _show and vwapArray.points.size() > 1
        if vwapArray.lines.size() > 0
            vwapArray.lines.last().delete()
            vwapArray.lines.clear()
        vwapArray.lines.push(polyline.new(vwapArray.points, false, false, line_color = _color, line_width = _width, line_style = getVwapLineStyle(_style), xloc = xloc.bar_time))

    if barstate.islast and not _show and vwapArray.lines.size() > 0
        vwapArray.lines.last().delete()
        vwapArray.lines.clear()

renderAoiVwap(_showInput, _source, _anchor, _displayFilter, _color, _style, _width) =>
    [vwapValue, _, _] = ta.vwap(_source, _anchor, 1)
    bool canCalc = _showInput and timeframe.isintraday and ta.cum(volume) > 0 and not na(vwapValue)
    bool canDisplay = canCalc and _displayFilter
    if canCalc
        renderAoiVwapPolyline(vwapValue, _anchor, canDisplay, _color, _style, _width)

inDayVWAPAnchor = not na(time(timeframe.period, dayVWAPAnchorSession, mainTZ))
dayVWAPAnchor = inDayVWAPAnchor and not inDayVWAPAnchor[1]
inDayVWAPDisplay = not na(time(timeframe.period, dayVWAPDisplaySession, mainTZ))

inNYVWAPAnchor = not na(time(timeframe.period, nyVWAPAnchorSession, mainTZ))
nyVWAPAnchor = inNYVWAPAnchor and not inNYVWAPAnchor[1]
inNYVWAPDisplay = not na(time(timeframe.period, nyVWAPDisplaySession, mainTZ))

showDayVWAPNow = showDayVWAPOnlyOutsideNY ? inDayVWAPDisplay : true
showNYVWAPNow = showNYVWAPOnlyDuringNY ? inNYVWAPDisplay : true

renderAoiVwap(showDayVWAP, vwapSource, dayVWAPAnchor, showDayVWAPNow, dayVWAPColor, dayVWAPStyleInput, dayVWAPWidth)
renderAoiVwap(showNYVWAP, vwapSource, nyVWAPAnchor, showNYVWAPNow, nyVWAPColor, nyVWAPStyleInput, nyVWAPWidth)

//====================================================
// NY 15-MIN ORB
//====================================================
groupORB = "NY 15m ORB"
showORB = input.bool(true, "Show NY 15m ORB", group = groupORB)
orbSession = input.session("0830-0845", "ORB Window", group = groupORB)
orbDisplaySession = input.session("0830-1600", "ORB Display Window", group = groupORB)
orbHighColor = input.color(color.rgb(41, 83, 2), "ORB High Color", group = groupORB)
orbLowColor = input.color(color.rgb(116, 10, 7), "ORB Low Color", group = groupORB)
orbMidColor = input.color(color.rgb(29, 47, 58, 40), "ORB Midline Color", group = groupORB)
orbWidth = input.int(1, "ORB Line Width", minval = 1, maxval = 5, group = groupORB)
orbLineStyleInput = input.string("Solid", "ORB High/Low Line Style", options = ["Solid", "Dashed", "Dotted"], group = groupORB)
orbMidLineStyleInput = input.string("Solid", "ORB Midline Style", options = ["Solid", "Dashed", "Dotted"], group = groupORB)
showORBMid = input.bool(true, "Show ORB Midline", group = groupORB)
showORBLabels = input.bool(true, "Show ORB Labels", group = groupORB)
orbLabelOffsetBars = input.int(25, "ORB Label Offset Bars", minval = 1, maxval = 50, group = groupORB)

orbInBuild = not na(time(timeframe.period, orbSession, mainTZ))
orbInDisplay = not na(time(timeframe.period, orbDisplaySession, mainTZ))
orbStart = orbInBuild and not orbInBuild[1]
orbEnd = not orbInBuild and orbInBuild[1]

var float orbBuildHigh = na
var float orbBuildLow = na
var float orbLockedHigh = na
var float orbLockedLow = na
var int orbStartBar = na
var int orbEndBar = na
var bool orbLocked = false

var line orbHighLine = na
var line orbLowLine = na
var line orbMidLine = na
var label orbHighLabel = na
var label orbLowLabel = na
var label orbMidLabel = na

orbLineStyle = getAoiLineStyle(orbLineStyleInput)
orbMidLineStyle = getAoiLineStyle(orbMidLineStyleInput)

f_delLine(_ln) =>
    if not na(_ln)
        line.delete(_ln)

f_delLabel(_lb) =>
    if not na(_lb)
        label.delete(_lb)

if orbStart
    orbBuildHigh := high
    orbBuildLow := low
    orbLockedHigh := na
    orbLockedLow := na
    orbStartBar := bar_index
    orbEndBar := na
    orbLocked := false
    f_delLine(orbHighLine), f_delLine(orbLowLine), f_delLine(orbMidLine)
    f_delLabel(orbHighLabel), f_delLabel(orbLowLabel), f_delLabel(orbMidLabel)
    orbHighLine := na, orbLowLine := na, orbMidLine := na
    orbHighLabel := na, orbLowLabel := na, orbMidLabel := na

if orbInBuild
    orbBuildHigh := na(orbBuildHigh) ? high : math.max(orbBuildHigh, high)
    orbBuildLow := na(orbBuildLow) ? low : math.min(orbBuildLow, low)

if orbEnd and not na(orbBuildHigh) and not na(orbBuildLow)
    orbLockedHigh := orbBuildHigh
    orbLockedLow := orbBuildLow
    orbEndBar := bar_index
    orbLocked := true

orbCanDraw = showORB and orbLocked and orbInDisplay and not na(orbLockedHigh) and not na(orbLockedLow)
orbMid = (orbLockedHigh + orbLockedLow) / 2.0

if orbCanDraw
    if na(orbHighLine)
        orbHighLine := line.new(orbStartBar, orbLockedHigh, bar_index, orbLockedHigh, xloc = xloc.bar_index, extend = extend.none, color = orbHighColor, style = orbLineStyle, width = orbWidth)
        orbLowLine := line.new(orbStartBar, orbLockedLow, bar_index, orbLockedLow, xloc = xloc.bar_index, extend = extend.none, color = orbLowColor, style = orbLineStyle, width = orbWidth)
        if showORBMid
            orbMidLine := line.new(orbStartBar, orbMid, bar_index, orbMid, xloc = xloc.bar_index, extend = extend.none, color = orbMidColor, style = orbMidLineStyle, width = orbWidth)
    else
        line.set_x1(orbHighLine, orbStartBar), line.set_y1(orbHighLine, orbLockedHigh), line.set_x2(orbHighLine, bar_index), line.set_y2(orbHighLine, orbLockedHigh)
        line.set_x1(orbLowLine, orbStartBar), line.set_y1(orbLowLine, orbLockedLow), line.set_x2(orbLowLine, bar_index), line.set_y2(orbLowLine, orbLockedLow)
        line.set_color(orbHighLine, orbHighColor), line.set_color(orbLowLine, orbLowColor), line.set_width(orbHighLine, orbWidth), line.set_width(orbLowLine, orbWidth), line.set_style(orbHighLine, orbLineStyle), line.set_style(orbLowLine, orbLineStyle)
        if showORBMid
            if na(orbMidLine)
                orbMidLine := line.new(orbStartBar, orbMid, bar_index, orbMid, xloc = xloc.bar_index, extend = extend.none, color = orbMidColor, style = orbMidLineStyle, width = orbWidth)
            else
                line.set_x1(orbMidLine, orbStartBar), line.set_y1(orbMidLine, orbMid), line.set_x2(orbMidLine, bar_index), line.set_y2(orbMidLine, orbMid), line.set_color(orbMidLine, orbMidColor), line.set_width(orbMidLine, orbWidth), line.set_style(orbMidLine, orbMidLineStyle)
        else
            f_delLine(orbMidLine), orbMidLine := na

    if showORBLabels
        int labelX = bar_index + orbLabelOffsetBars
        if na(orbHighLabel)
            orbHighLabel := label.new(labelX, orbLockedHigh, "ORB High", xloc = xloc.bar_index, style = label.style_none, textcolor = orbHighColor, size = size.tiny)
            orbLowLabel := label.new(labelX, orbLockedLow, "ORB Low", xloc = xloc.bar_index, style = label.style_none, textcolor = orbLowColor, size = size.tiny)
            if showORBMid
                orbMidLabel := label.new(labelX, orbMid, "ORB Mid", xloc = xloc.bar_index, style = label.style_none, textcolor = orbMidColor, size = size.tiny)
        else
            label.set_x(orbHighLabel, labelX), label.set_y(orbHighLabel, orbLockedHigh), label.set_textcolor(orbHighLabel, orbHighColor)
            label.set_x(orbLowLabel, labelX), label.set_y(orbLowLabel, orbLockedLow), label.set_textcolor(orbLowLabel, orbLowColor)
            if showORBMid
                if na(orbMidLabel)
                    orbMidLabel := label.new(labelX, orbMid, "ORB Mid", xloc = xloc.bar_index, style = label.style_none, textcolor = orbMidColor, size = size.tiny)
                else
                    label.set_x(orbMidLabel, labelX), label.set_y(orbMidLabel, orbMid), label.set_textcolor(orbMidLabel, orbMidColor)
            else
                f_delLabel(orbMidLabel), orbMidLabel := na
    else
        f_delLabel(orbHighLabel), f_delLabel(orbLowLabel), f_delLabel(orbMidLabel)
        orbHighLabel := na, orbLowLabel := na, orbMidLabel := na
else
    f_delLine(orbHighLine), f_delLine(orbLowLine), f_delLine(orbMidLine)
    f_delLabel(orbHighLabel), f_delLabel(orbLowLabel), f_delLabel(orbMidLabel)
    orbHighLine := na, orbLowLine := na, orbMidLine := na
    orbHighLabel := na, orbLowLabel := na, orbMidLabel := na

//====================================================
// PRIOR SESSION H/L
//====================================================
groupSess = "Prior Session H/L"
showSessionHL = input.bool(true, "Show Prior Session H/L", group = groupSess)

showAsiaHL = input.bool(true, "Show Asia H/L", group = groupSess)
asiaHLSession = input.session("2000-0000", "Asia H/L Session", group = groupSess)
asiaSessHLColor = input.color(color.rgb(107, 6, 6), "Asia H/L Color", group = groupSess)

showLondonHL = input.bool(true, "Show London H/L", group = groupSess)
londonHLSession = input.session("0200-0500", "London H/L Session", group = groupSess)
ldnSessHLColor = input.color(color.rgb(8, 45, 124), "London H/L Color", group = groupSess)

showPMHL = input.bool(true, "Show PM H/L", group = groupSess)
pmHLSession = input.session("0700-0830", "PM H/L Session", group = groupSess)
pmSessHLColor = input.color(color.rgb(88, 55, 4), "PM H/L Color", group = groupSess)

showNYHL = input.bool(true, "Show NY H/L", group = groupSess)
nyHLSession = input.session("0830-1200", "NY H/L Session", group = groupSess)
nySessHLColor = input.color(color.rgb(96, 5, 114), "NY H/L Color", group = groupSess)

showNYPMHL = input.bool(true, "Show NYPM H/L", group = groupSess)
nypmHLSession = input.session("1330-1600", "NYPM H/L Session", group = groupSess)
nypmSessHLColor = input.color(color.rgb(93, 4, 128), "NYPM H/L Color", group = groupSess)

sessHLWidth = input.int(1, "Session H/L Width", minval = 1, maxval = 4, group = groupSess)
priorSessionTransparency = input.int(35, "Prior Session H/L Transparency", minval = 0, maxval = 90, group = groupSess)
showSessionLabels = input.bool(true, "Show Session H/L Labels", group = groupSess)
sessLabelOffsetBars = input.int(6, "Session Label Offset Bars", minval = 1, maxval = 30, group = groupSess)
sessLabelCollisionTicks = input.int(8, "Label Collision Threshold (ticks)", minval = 1, maxval = 50, group = groupSess)
sessLabelNudgeTicks = input.int(4, "Label Nudge Distance (ticks)", minval = 1, maxval = 50, group = groupSess)

sessInAsia = not na(time(timeframe.period, asiaHLSession, mainTZ))
sessInLondon = not na(time(timeframe.period, londonHLSession, mainTZ))
sessInPM = not na(time(timeframe.period, pmHLSession, mainTZ))
sessInNY = not na(time(timeframe.period, nyHLSession, mainTZ))
sessInNYPM = not na(time(timeframe.period, nypmHLSession, mainTZ))

sessAsiaStart = sessInAsia and not sessInAsia[1]
sessAsiaEnd = not sessInAsia and sessInAsia[1]
sessLdnStart = sessInLondon and not sessInLondon[1]
sessLdnEnd = not sessInLondon and sessInLondon[1]
sessPMStart = sessInPM and not sessInPM[1]
sessPMEnd = not sessInPM and sessInPM[1]
sessNyStart = sessInNY and not sessInNY[1]
sessNyEnd = not sessInNY and sessInNY[1]
sessNyPMStart = sessInNYPM and not sessInNYPM[1]
sessNyPMEnd = not sessInNYPM and sessInNYPM[1]

var float asiaBuildHigh = na
var float asiaBuildLow = na
var float asiaPrevHigh = na
var float asiaPrevLow = na
var int asiaPrevEndBar = na

var float ldnBuildHigh = na
var float ldnBuildLow = na
var float ldnPrevHigh = na
var float ldnPrevLow = na
var int ldnPrevEndBar = na

var float pmBuildHigh = na
var float pmBuildLow = na
var float pmPrevHigh = na
var float pmPrevLow = na
var int pmPrevEndBar = na

var float nyBuildHigh = na
var float nyBuildLow = na
var float nyPrevHigh = na
var float nyPrevLow = na
var int nyPrevEndBar = na

var float nypmBuildHigh = na
var float nypmBuildLow = na
var float nypmPrevHigh = na
var float nypmPrevLow = na
var int nypmPrevEndBar = na

var bool asiaHighTaken = false
var bool asiaLowTaken = false
var bool ldnHighTaken = false
var bool ldnLowTaken = false
var bool pmHighTaken = false
var bool pmLowTaken = false
var bool nyHighTaken = false
var bool nyLowTaken = false
var bool nypmHighTaken = false
var bool nypmLowTaken = false

if sessAsiaStart
    asiaBuildHigh := high
    asiaBuildLow := low
else if sessInAsia
    asiaBuildHigh := math.max(nz(asiaBuildHigh, high), high)
    asiaBuildLow := math.min(nz(asiaBuildLow, low), low)
if sessAsiaEnd
    asiaPrevHigh := asiaBuildHigh
    asiaPrevLow := asiaBuildLow
    asiaPrevEndBar := bar_index
    asiaHighTaken := false
    asiaLowTaken := false
    asiaBuildHigh := na
    asiaBuildLow := na

if sessLdnStart
    ldnBuildHigh := high
    ldnBuildLow := low
else if sessInLondon
    ldnBuildHigh := math.max(nz(ldnBuildHigh, high), high)
    ldnBuildLow := math.min(nz(ldnBuildLow, low), low)
if sessLdnEnd
    ldnPrevHigh := ldnBuildHigh
    ldnPrevLow := ldnBuildLow
    ldnPrevEndBar := bar_index
    ldnHighTaken := false
    ldnLowTaken := false
    ldnBuildHigh := na
    ldnBuildLow := na

if sessPMStart
    pmBuildHigh := high
    pmBuildLow := low
else if sessInPM
    pmBuildHigh := math.max(nz(pmBuildHigh, high), high)
    pmBuildLow := math.min(nz(pmBuildLow, low), low)
if sessPMEnd
    pmPrevHigh := pmBuildHigh
    pmPrevLow := pmBuildLow
    pmPrevEndBar := bar_index
    pmHighTaken := false
    pmLowTaken := false
    pmBuildHigh := na
    pmBuildLow := na

if sessNyStart
    nyBuildHigh := high
    nyBuildLow := low
else if sessInNY
    nyBuildHigh := math.max(nz(nyBuildHigh, high), high)
    nyBuildLow := math.min(nz(nyBuildLow, low), low)
if sessNyEnd
    nyPrevHigh := nyBuildHigh
    nyPrevLow := nyBuildLow
    nyPrevEndBar := bar_index
    nyHighTaken := false
    nyLowTaken := false
    nyBuildHigh := na
    nyBuildLow := na

if sessNyPMStart
    nypmBuildHigh := high
    nypmBuildLow := low
else if sessInNYPM
    nypmBuildHigh := math.max(nz(nypmBuildHigh, high), high)
    nypmBuildLow := math.min(nz(nypmBuildLow, low), low)
if sessNyPMEnd
    nypmPrevHigh := nypmBuildHigh
    nypmPrevLow := nypmBuildLow
    nypmPrevEndBar := bar_index
    nypmHighTaken := false
    nypmLowTaken := false
    nypmBuildHigh := na
    nypmBuildLow := na

// Session precedence. No overlaps by default, but this protects you if you edit sessions later.
currentSession = sessInNYPM ? 5 : sessInNY ? 4 : sessInPM ? 3 : sessInLondon ? 2 : sessInAsia ? 1 : 0
var int activeSessionStartBar = na
if currentSession != currentSession[1]
    activeSessionStartBar := currentSession != 0 ? bar_index : na

showAsiaHLNow = showSessionHL and showAsiaHL and currentSession != 1
showLondonHLNow = showSessionHL and showLondonHL and currentSession != 2
showPMHLNow = showSessionHL and showPMHL and currentSession != 3
showNYHLNow = showSessionHL and showNYHL and currentSession != 4
showNYPMHLNow = showSessionHL and showNYPMHL and currentSession != 5

if showAsiaHLNow
    if not asiaHighTaken and not na(asiaPrevHigh) and high > asiaPrevHigh
        asiaHighTaken := true
    if not asiaLowTaken and not na(asiaPrevLow) and low < asiaPrevLow
        asiaLowTaken := true
if showLondonHLNow
    if not ldnHighTaken and not na(ldnPrevHigh) and high > ldnPrevHigh
        ldnHighTaken := true
    if not ldnLowTaken and not na(ldnPrevLow) and low < ldnPrevLow
        ldnLowTaken := true
if showPMHLNow
    if not pmHighTaken and not na(pmPrevHigh) and high > pmPrevHigh
        pmHighTaken := true
    if not pmLowTaken and not na(pmPrevLow) and low < pmPrevLow
        pmLowTaken := true
if showNYHLNow
    if not nyHighTaken and not na(nyPrevHigh) and high > nyPrevHigh
        nyHighTaken := true
    if not nyLowTaken and not na(nyPrevLow) and low < nyPrevLow
        nyLowTaken := true
if showNYPMHLNow
    if not nypmHighTaken and not na(nypmPrevHigh) and high > nypmPrevHigh
        nypmHighTaken := true
    if not nypmLowTaken and not na(nypmPrevLow) and low < nypmPrevLow
        nypmLowTaken := true

var line asiaHighLine = na
var line asiaLowLine = na
var line ldnHighLine = na
var line ldnLowLine = na
var line pmHighLine = na
var line pmLowLine = na
var line nyHighLine = na
var line nyLowLine = na
var line nypmHighLine = na
var line nypmLowLine = na

var label asiaHighLabel = na
var label asiaLowLabel = na
var label ldnHighLabel = na
var label ldnLowLabel = na
var label pmHighLabel = na
var label pmLowLabel = na
var label nyHighLabel = na
var label nyLowLabel = na
var label nypmHighLabel = na
var label nypmLowLabel = na

// Keeps prior session H/L line on chart after sweep.
// Line stops extending once swept, but does not delete unless the session/toggle is off.
f_syncSessionLine(_ln, _show, _isTaken, _level, _x1, _clr, _width) =>
    line _out = _ln
    bool _canDraw = _show and not na(_level) and not na(_x1)

    if _canDraw
        if na(_out)
            _out := line.new(
                 x1 = _x1,
                 y1 = _level,
                 x2 = bar_index,
                 y2 = _level,
                 xloc = xloc.bar_index,
                 extend = extend.none,
                 color = _clr,
                 width = _width
             )
        else
            line.set_x1(_out, _x1)
            line.set_y1(_out, _level)
            line.set_y2(_out, _level)
            line.set_extend(_out, extend.none)
            line.set_color(_out, _clr)
            line.set_width(_out, _width)

            // Keep extending only until swept.
            // After sweep, x2 stays frozen at the last unswept bar.
            if not _isTaken
                line.set_x2(_out, bar_index)
    else
        if not na(_out)
            line.delete(_out)
            _out := na

    _out

f_syncSessionLabel(_lb, _ln, _show, _txt, _xOffset, _y, _txtColor) =>
    label _out = _lb
    bool _canDraw = _show and not na(_ln) and not na(_y)
    if _canDraw
        int _x = line.get_x2(_ln) + _xOffset
        if na(_out)
            _out := label.new(_x, _y, _txt, xloc = xloc.bar_index, style = label.style_none, textcolor = _txtColor, size = size.tiny)
        else
            label.set_x(_out, _x)
            label.set_y(_out, _y)
            label.set_text(_out, _txt)
            label.set_textcolor(_out, _txtColor)
            label.set_size(_out, size.tiny)
    else
        if not na(_out)
            label.delete(_out)
            _out := na
    _out


// Line visibility:
// Lines remain visible after sweep, but stop extending once taken.
asiaHighActive = showAsiaHLNow and not na(asiaPrevHigh) and not na(asiaPrevEndBar)
asiaLowActive = showAsiaHLNow and not na(asiaPrevLow) and not na(asiaPrevEndBar)

ldnHighActive = showLondonHLNow and not na(ldnPrevHigh) and not na(ldnPrevEndBar)
ldnLowActive = showLondonHLNow and not na(ldnPrevLow) and not na(ldnPrevEndBar)

pmHighActive = showPMHLNow and not na(pmPrevHigh) and not na(pmPrevEndBar)
pmLowActive = showPMHLNow and not na(pmPrevLow) and not na(pmPrevEndBar)

nyHighActive = showNYHLNow and not na(nyPrevHigh) and not na(nyPrevEndBar)
nyLowActive = showNYHLNow and not na(nyPrevLow) and not na(nyPrevEndBar)

nypmHighActive = showNYPMHLNow and not na(nypmPrevHigh) and not na(nypmPrevEndBar)
nypmLowActive = showNYPMHLNow and not na(nypmPrevLow) and not na(nypmPrevEndBar)


// Label visibility:
// Labels disappear immediately once swept/taken.
asiaHighLabelActive = asiaHighActive and not asiaHighTaken
asiaLowLabelActive = asiaLowActive and not asiaLowTaken

ldnHighLabelActive = ldnHighActive and not ldnHighTaken
ldnLowLabelActive = ldnLowActive and not ldnLowTaken

pmHighLabelActive = pmHighActive and not pmHighTaken
pmLowLabelActive = pmLowActive and not pmLowTaken

nyHighLabelActive = nyHighActive and not nyHighTaken
nyLowLabelActive = nyLowActive and not nyLowTaken

nypmHighLabelActive = nypmHighActive and not nypmHighTaken
nypmLowLabelActive = nypmLowActive and not nypmLowTaken



asiaSessLineColor = color.new(asiaSessHLColor, priorSessionTransparency)
ldnSessLineColor = color.new(ldnSessHLColor, priorSessionTransparency)
pmSessLineColor = color.new(pmSessHLColor, priorSessionTransparency)
nySessLineColor = color.new(nySessHLColor, priorSessionTransparency)
nypmSessLineColor = color.new(nypmSessHLColor, priorSessionTransparency)

asiaHighLine := f_syncSessionLine(asiaHighLine, asiaHighActive, asiaHighTaken, asiaPrevHigh, asiaPrevEndBar, asiaSessLineColor, sessHLWidth)
asiaLowLine := f_syncSessionLine(asiaLowLine, asiaLowActive, asiaLowTaken, asiaPrevLow, asiaPrevEndBar, asiaSessLineColor, sessHLWidth)

ldnHighLine := f_syncSessionLine(ldnHighLine, ldnHighActive, ldnHighTaken, ldnPrevHigh, ldnPrevEndBar, ldnSessLineColor, sessHLWidth)
ldnLowLine := f_syncSessionLine(ldnLowLine, ldnLowActive, ldnLowTaken, ldnPrevLow, ldnPrevEndBar, ldnSessLineColor, sessHLWidth)

pmHighLine := f_syncSessionLine(pmHighLine, pmHighActive, pmHighTaken, pmPrevHigh, pmPrevEndBar, pmSessLineColor, sessHLWidth)
pmLowLine := f_syncSessionLine(pmLowLine, pmLowActive, pmLowTaken, pmPrevLow, pmPrevEndBar, pmSessLineColor, sessHLWidth)

nyHighLine := f_syncSessionLine(nyHighLine, nyHighActive, nyHighTaken, nyPrevHigh, nyPrevEndBar, nySessLineColor, sessHLWidth)
nyLowLine := f_syncSessionLine(nyLowLine, nyLowActive, nyLowTaken, nyPrevLow, nyPrevEndBar, nySessLineColor, sessHLWidth)

nypmHighLine := f_syncSessionLine(nypmHighLine, nypmHighActive, nypmHighTaken, nypmPrevHigh, nypmPrevEndBar, nypmSessLineColor, sessHLWidth)
nypmLowLine := f_syncSessionLine(nypmLowLine, nypmLowActive, nypmLowTaken, nypmPrevLow, nypmPrevEndBar, nypmSessLineColor, sessHLWidth)
if barstate.islast
    if showSessionLabels
        asiaHighLabel := f_syncSessionLabel(asiaHighLabel, asiaHighLine, asiaHighLabelActive, "Asia High", sessLabelOffsetBars, asiaPrevHigh, asiaSessLineColor)
        asiaLowLabel := f_syncSessionLabel(asiaLowLabel, asiaLowLine, asiaLowLabelActive, "Asia Low", sessLabelOffsetBars, asiaPrevLow, asiaSessLineColor)

        ldnHighLabel := f_syncSessionLabel(ldnHighLabel, ldnHighLine, ldnHighLabelActive, "London High", sessLabelOffsetBars, ldnPrevHigh, ldnSessLineColor)
        ldnLowLabel := f_syncSessionLabel(ldnLowLabel, ldnLowLine, ldnLowLabelActive, "London Low", sessLabelOffsetBars, ldnPrevLow, ldnSessLineColor)

        pmHighLabel := f_syncSessionLabel(pmHighLabel, pmHighLine, pmHighLabelActive, "PM High", sessLabelOffsetBars, pmPrevHigh, pmSessLineColor)
        pmLowLabel := f_syncSessionLabel(pmLowLabel, pmLowLine, pmLowLabelActive, "PM Low", sessLabelOffsetBars, pmPrevLow, pmSessLineColor)

        nyHighLabel := f_syncSessionLabel(nyHighLabel, nyHighLine, nyHighLabelActive, "NY High", sessLabelOffsetBars, nyPrevHigh, nySessLineColor)
        nyLowLabel := f_syncSessionLabel(nyLowLabel, nyLowLine, nyLowLabelActive, "NY Low", sessLabelOffsetBars, nyPrevLow, nySessLineColor)

        nypmHighLabel := f_syncSessionLabel(nypmHighLabel, nypmHighLine, nypmHighLabelActive, "NYPM High", sessLabelOffsetBars, nypmPrevHigh, nypmSessLineColor)
        nypmLowLabel := f_syncSessionLabel(nypmLowLabel, nypmLowLine, nypmLowLabelActive, "NYPM Low", sessLabelOffsetBars, nypmPrevLow, nypmSessLineColor)
    else
        f_delLabel(asiaHighLabel), f_delLabel(asiaLowLabel), f_delLabel(ldnHighLabel), f_delLabel(ldnLowLabel), f_delLabel(pmHighLabel), f_delLabel(pmLowLabel), f_delLabel(nyHighLabel), f_delLabel(nyLowLabel), f_delLabel(nypmHighLabel), f_delLabel(nypmLowLabel)
        asiaHighLabel := na, asiaLowLabel := na, ldnHighLabel := na, ldnLowLabel := na, pmHighLabel := na, pmLowLabel := na, nyHighLabel := na, nyLowLabel := na, nypmHighLabel := na, nypmLowLabel := na
````
