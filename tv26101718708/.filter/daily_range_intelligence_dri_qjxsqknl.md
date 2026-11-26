# Daily Range Intelligence (DRI)

- url: https://www.tradingview.com/script/QjxSQKNl-Daily-Range-Intelligence-DRI/
- type: indicator
- pine_id: PUB;c0fd847d90c24ec2804fc368d2c4cadc
- version: 1.0

## Description

[b]Daily Range Intelligence (DRI)[/b] is an intraday context tool designed to help traders understand how much of the expected daily range has already been used.

It measures the current day’s range relative to the Average True Range (ATR) and presents this information in a clean, visual format to support decision-making.

This indicator does not generate trading signals. It is intended to provide context about volatility and range expansion.

[b]Core Concept[/b]

Markets tend to move within a statistical range. By comparing the current range to ATR, traders can evaluate whether price still has room to expand or if it is operating in extended conditions.

[b]How to Interpret the Range[/b]
[list]
[*]Below 50% of ATR  
The market has used a relatively small portion of its expected range. This indicates that price may still have room to expand.

[*]Between 80% and 120% of ATR  
The market is operating in a decision zone, where both continuation and rotation scenarios are possible.

[*]Above 120% of ATR  
The market has exceeded its typical range. This is commonly associated with slower conditions or consolidation.
[/list]

[b]Important Note on ATR Levels[/b]

Reaching 100% of ATR does not imply that price must reverse or stop moving. Markets can continue to expand beyond their average range, especially during strong directional sessions. The ATR level is a reference point for context, not a limit or constraint.

[b]What the Indicator Displays[/b]
[list]
[*]Current day range relative to ATR (percentage)
[*]A simplified status view (Expansion, Decision, Exhaustion)
[*]A compact dashboard for quick interpretation
[*]An optional ATR 100% level to highlight when the expected range has been reached
[*]Reference zones based on previous day and session ranges
[/list]

[b]How It Helps[/b]

DRI helps answer key intraday questions such as:
[list]
[*]Has the market already moved significantly today?
[*]Is there still room for expansion?
[*]Are current conditions better suited for continuation or patience?
[/list]

[b]Usage Notes[/b]

This tool is designed to be used alongside price action and technical analysis.

It does not predict direction and should not be used in isolation. Always combine it with your own analysis and risk management approach.

Market conditions can vary, and no single metric should be used as a standalone decision tool.

## Source Code

````pine
//@version=6
indicator("Daily Range Intelligence (DRI)", overlay=true, max_boxes_count=50, max_lines_count=200, max_labels_count=200)

//====================================================
// INPUTS
//====================================================
grpVis = "Visual"
showPrevDayZone   = input.bool(true,  "Show Previous Day Golden Zone", group=grpVis)
showPremarketZone = input.bool(true,  "Show Premarket Golden Zone", group=grpVis)
showMorningZone   = input.bool(true,  "Show Morning Impulse Golden Zone", group=grpVis)
showDashboard     = input.bool(true,  "Show Dashboard", group=grpVis)
dashboardMode     = input.string("Compact", "Dashboard Mode", options=["Full", "Compact"], group=grpVis)
dashboardOffsetRows = input.int(1, "Dashboard Vertical Offset (rows)", minval=0, maxval=8, group=grpVis)
showZoneMidLines  = input.bool(true,  "Show 50% / 61.8% Lines", group=grpVis)
extendZonesRight  = input.bool(true,  "Extend Zones To The Right", group=grpVis)

grpSess = "Sessions"
premarketSession = input.session("0400-0930", "Premarket Session", group=grpSess)
morningSession   = input.session("0930-1100", "Morning Impulse Session", group=grpSess)
regularSession   = input.session("0930-1600", "Regular Session", group=grpSess)

grpCalc = "Calculations"
atrLength            = input.int(14, "Daily ATR Length", minval=1, group=grpCalc)
atrAlertThresholdPct = input.float(100.0, "ATR Alert Threshold %", minval=1, step=1, group=grpCalc)
useBodyFilter        = input.bool(false, "Use Candle Bodies For Golden Zones (experimental)", group=grpCalc)

grpATRLine = "ATR 100% Level"
showATR100Line        = input.bool(true, "Show ATR 100% Line", group=grpATRLine)
atr100LabelText       = input.string("ATR 100%", "ATR 100% Label", group=grpATRLine)
atr100LineColor       = input.color(color.rgb(145, 61, 211), "ATR 100% Line Color", group=grpATRLine)
atr100LineWidth       = input.int(2, "ATR 100% Line Width", minval=1, maxval=4, group=grpATRLine)
atr100LineStyleInput  = input.string("Solid", "ATR 100% Line Style", options=["Solid", "Dashed", "Dotted"], group=grpATRLine)
atr100LabelOffsetBars = input.int(6, "ATR 100% Label Offset (bars)", minval=1, maxval=50, group=grpATRLine)
atr100LabelSide       = input.string("On Line", "ATR 100% Label Position", options=["On Line", "Above", "Below"], group=grpATRLine)
atr100LabelOffsetTicks = input.int(0, "ATR 100% Label Vertical Offset (ticks)", minval=0, maxval=500, group=grpATRLine)

grpStyle = "Style"
prevZoneColor    = input.color(color.new(color.orange, 82), "Previous Day Zone Color", group=grpStyle)
pmZoneColor      = input.color(color.new(color.yellow, 84), "Premarket Zone Color", group=grpStyle)
morningZoneColor = input.color(color.new(color.red, 86), "Morning Impulse Zone Color", group=grpStyle)
midLineColor     = input.color(color.new(color.purple, 10), "50% / 61.8% Line Color", group=grpStyle)
borderColor      = input.color(color.new(color.gray, 35), "Zone Border Color", group=grpStyle)

//====================================================
// HELPERS
//====================================================
f_inSession(_sess) =>
    not na(time(timeframe.period, _sess))

f_rangeHigh(_useBody) =>
    _useBody ? math.max(open, close) : high

f_rangeLow(_useBody) =>
    _useBody ? math.min(open, close) : low

f_status(_pct) =>
    na(_pct) ? "N/A" :
     _pct < 50   ? "EXPANSION" :
     _pct < 80   ? "NORMAL" :
     _pct <= 120 ? "DECISION" :
     "EXHAUSTION"

f_signalText(_pct) =>
    na(_pct) ? "N/A" :
     _pct < 50   ? "GREEN" :
     _pct < 80   ? "GREEN" :
     _pct <= 120 ? "YELLOW" :
     "RED"

f_shortHint(_gapPct, _todayPct, _pmPct, _threshold) =>
    na(_gapPct) or na(_todayPct) ? "Waiting..." :
     _todayPct < 50 ? "Expansion potential" :
     _todayPct < 80 ? "Normal range use" :
     _todayPct <= 120 ? "Decision zone" :
     "Exhaustion risk"

f_zoneBounds(_low, _high) =>
    _range = _high - _low
    _z50 = _low + _range * 0.50
    _z618 = _low + _range * 0.618
    [_z50, _z618]

f_createOrUpdateBox(_box, _left, _right, _top, _bottom, _bg, _border) =>
    box _result = _box
    if na(_result)
        _result := box.new(_left, _top, _right, _bottom, xloc=xloc.bar_index, bgcolor=_bg, border_color=_border)
    else
        box.set_left(_result, _left)
        box.set_right(_result, _right)
        box.set_top(_result, _top)
        box.set_bottom(_result, _bottom)
        box.set_bgcolor(_result, _bg)
        box.set_border_color(_result, _border)
    _result

f_createOrUpdateLine(_line, _x1, _y, _x2, _col) =>
    line _result = _line
    if na(_result)
        _result := line.new(_x1, _y, _x2, _y, xloc=xloc.bar_index, extend=extend.none, color=_col, style=line.style_dashed, width=1)
    else
        line.set_x1(_result, _x1)
        line.set_x2(_result, _x2)
        line.set_y1(_result, _y)
        line.set_y2(_result, _y)
        line.set_color(_result, _col)
    _result

f_bgByPct(_pct) =>
    na(_pct) ? color.rgb(90, 90, 90) :
     _pct < 50   ? color.rgb(46, 125, 50) :
     _pct < 80   ? color.rgb(46, 125, 50) :
     _pct <= 120 ? color.rgb(183, 135, 39) :
     color.rgb(156, 39, 39)

f_txtByPct(_pct) =>
    na(_pct) ? color.white :
     _pct <= 120 and _pct >= 80 ? color.black :
     color.white

f_lineStyle(_style) =>
    _style == "Dashed" ? line.style_dashed :
     _style == "Dotted" ? line.style_dotted :
     line.style_solid

//====================================================
// DAILY REFERENCES
//====================================================
dailyATR       = request.security(syminfo.tickerid, "D", ta.atr(atrLength), barmerge.gaps_off, barmerge.lookahead_off)
prevDayHighRaw = request.security(syminfo.tickerid, "D", high[1],  barmerge.gaps_off, barmerge.lookahead_off)
prevDayLowRaw  = request.security(syminfo.tickerid, "D", low[1],   barmerge.gaps_off, barmerge.lookahead_off)
prevDayClose   = request.security(syminfo.tickerid, "D", close[1], barmerge.gaps_off, barmerge.lookahead_off)

//====================================================
// SESSION FLAGS
//====================================================
inPremarket = f_inSession(premarketSession)
inMorning   = f_inSession(morningSession)
inRegular   = f_inSession(regularSession)

newDay = ta.change(time("D")) != 0

//====================================================
// REAL RTH OPEN FOR GAP CALCULATION
//====================================================
var float rthOpen = na

if newDay
    rthOpen := na

if inRegular and not inRegular[1]
    rthOpen := open

float gapValue = na
string gapLabel = "Overnight"

if not na(rthOpen)
    gapValue := rthOpen - prevDayClose
    gapLabel := "Open Gap"
else
    gapValue := close - prevDayClose
    gapLabel := "Overnight"

gapAbs = math.abs(gapValue)
gapPctATR = dailyATR > 0 ? (gapAbs / dailyATR) * 100 : na

//====================================================
// TRACK PREMARKET RANGE
//====================================================
var float pmHigh = na
var float pmLow = na
var int pmStartBar = na
var int pmEndBar = na

if newDay
    pmHigh := na
    pmLow := na
    pmStartBar := na
    pmEndBar := na

if inPremarket
    pmHigh := na(pmHigh) ? f_rangeHigh(useBodyFilter) : math.max(pmHigh, f_rangeHigh(useBodyFilter))
    pmLow := na(pmLow) ? f_rangeLow(useBodyFilter) : math.min(pmLow, f_rangeLow(useBodyFilter))
    pmStartBar := na(pmStartBar) ? bar_index : pmStartBar
    pmEndBar := bar_index

pmRange = (not na(pmHigh) and not na(pmLow)) ? (pmHigh - pmLow) : na

float pmZ50 = na
float pmZ618 = na
if not na(pmHigh) and not na(pmLow)
    [pmZ50, pmZ618] = f_zoneBounds(pmLow, pmHigh)

//====================================================
// TRACK FULL DAY RANGE
//====================================================
var float dayHigh = na
var float dayLow = na
var int dayHighBar = na
var int dayLowBar = na

if newDay
    dayHigh := f_rangeHigh(useBodyFilter)
    dayLow := f_rangeLow(useBodyFilter)
    dayHighBar := bar_index
    dayLowBar := bar_index
else
    _currHigh = f_rangeHigh(useBodyFilter)
    _currLow  = f_rangeLow(useBodyFilter)

    if na(dayHigh) or _currHigh > dayHigh
        dayHigh := _currHigh
        dayHighBar := bar_index

    if na(dayLow) or _currLow < dayLow
        dayLow := _currLow
        dayLowBar := bar_index

todayRange = dayHigh - dayLow

//====================================================
// PREVIOUS DAY GOLDEN ZONE
//====================================================
float prevZ50 = na
float prevZ618 = na
if not na(prevDayLowRaw) and not na(prevDayHighRaw)
    [prevZ50, prevZ618] = f_zoneBounds(prevDayLowRaw, prevDayHighRaw)

//====================================================
// MORNING IMPULSE RANGE
//====================================================
var float morningHigh = na
var float morningLow = na
var int morningStartBar = na
var int morningEndBar = na

if newDay
    morningHigh := na
    morningLow := na
    morningStartBar := na
    morningEndBar := na

if inMorning
    morningHigh := na(morningHigh) ? f_rangeHigh(useBodyFilter) : math.max(morningHigh, f_rangeHigh(useBodyFilter))
    morningLow := na(morningLow) ? f_rangeLow(useBodyFilter) : math.min(morningLow, f_rangeLow(useBodyFilter))
    morningStartBar := na(morningStartBar) ? bar_index : morningStartBar
    morningEndBar := bar_index

morningRange = (not na(morningHigh) and not na(morningLow)) ? (morningHigh - morningLow) : na

float morningZ50 = na
float morningZ618 = na
if not na(morningHigh) and not na(morningLow)
    [morningZ50, morningZ618] = f_zoneBounds(morningLow, morningHigh)

//====================================================
// PERCENTAGES VS ATR
//====================================================
todayPctATR   = dailyATR > 0 ? (todayRange / dailyATR) * 100 : na
pmPctATR      = (dailyATR > 0 and not na(pmRange)) ? (pmRange / dailyATR) * 100 : na
morningPctATR = (dailyATR > 0 and not na(morningRange)) ? (morningRange / dailyATR) * 100 : na

dayStatus = f_status(todayPctATR)
trafficText = f_signalText(todayPctATR)

//====================================================
// ATR 100% LEVEL
//====================================================
var bool atr100Triggered = false
var float atr100Level = na
var int atr100StartBar = na
var line atr100Line = na
var label atr100LineLabel = na

if newDay
    atr100Triggered := false
    atr100Level := na
    atr100StartBar := na
    if not na(atr100Line)
        line.delete(atr100Line)
        atr100Line := na
    if not na(atr100LineLabel)
        label.delete(atr100LineLabel)
        atr100LineLabel := na

atrThresholdEvent = not atr100Triggered and not na(todayPctATR) and todayPctATR >= 100

if atrThresholdEvent
    atr100Triggered := true
    atr100StartBar := bar_index
    bullishExpansion = dayLowBar <= dayHighBar
    atr100Level := bullishExpansion ? (dayLow + dailyATR) : (dayHigh - dailyATR)

if showATR100Line and atr100Triggered and not na(atr100Level)
    if na(atr100Line)
        atr100Line := line.new(atr100StartBar, atr100Level, bar_index + 1, atr100Level, xloc=xloc.bar_index, extend=extend.right, color=atr100LineColor, width=atr100LineWidth, style=f_lineStyle(atr100LineStyleInput))
    else
        line.set_x1(atr100Line, atr100StartBar)
        line.set_y1(atr100Line, atr100Level)
        line.set_x2(atr100Line, bar_index + 1)
        line.set_y2(atr100Line, atr100Level)
        line.set_extend(atr100Line, extend.right)
        line.set_color(atr100Line, atr100LineColor)
        line.set_width(atr100Line, atr100LineWidth)
        line.set_style(atr100Line, f_lineStyle(atr100LineStyleInput))

    labelX = bar_index + atr100LabelOffsetBars
    priceOffset = syminfo.mintick * atr100LabelOffsetTicks
    labelY = atr100LabelSide == "Above" ? atr100Level + priceOffset : atr100LabelSide == "Below" ? atr100Level - priceOffset : atr100Level

    if na(atr100LineLabel)
        atr100LineLabel := label.new(labelX, labelY, atr100LabelText, xloc=xloc.bar_index, style=label.style_label_left, textcolor=color.white, color=atr100LineColor, size=size.small)
    else
        label.set_x(atr100LineLabel, labelX)
        label.set_y(atr100LineLabel, labelY)
        label.set_text(atr100LineLabel, atr100LabelText)
        label.set_textcolor(atr100LineLabel, color.white)
        label.set_style(atr100LineLabel, label.style_label_left)
        label.set_color(atr100LineLabel, atr100LineColor)
else
    if not na(atr100Line)
        line.delete(atr100Line)
        atr100Line := na
    if not na(atr100LineLabel)
        label.delete(atr100LineLabel)
        atr100LineLabel := na

//====================================================
// DRAW ZONES
//====================================================
var box prevBox = na
var line prevLine50 = na
var line prevLine618 = na

var box pmBox = na
var line pmLine50 = na
var line pmLine618 = na

var box morningBox = na
var line morningLine50 = na
var line morningLine618 = na

rightEdge = extendZonesRight ? bar_index + 100 : bar_index

if showPrevDayZone and not na(prevZ50) and not na(prevZ618)
    prevTop = math.max(prevZ50, prevZ618)
    prevBot = math.min(prevZ50, prevZ618)
    prevLeft = bar_index - 20
    prevBox := f_createOrUpdateBox(prevBox, prevLeft, rightEdge, prevTop, prevBot, prevZoneColor, borderColor)
    if showZoneMidLines
        prevLine50 := f_createOrUpdateLine(prevLine50, prevLeft, prevZ50, rightEdge, midLineColor)
        prevLine618 := f_createOrUpdateLine(prevLine618, prevLeft, prevZ618, rightEdge, midLineColor)

if showPremarketZone and not na(pmZ50) and not na(pmZ618) and not na(pmStartBar)
    pmTop = math.max(pmZ50, pmZ618)
    pmBot = math.min(pmZ50, pmZ618)
    pmLeft = pmStartBar
    pmRight = extendZonesRight ? bar_index + 100 : nz(pmEndBar, bar_index)
    pmBox := f_createOrUpdateBox(pmBox, pmLeft, pmRight, pmTop, pmBot, pmZoneColor, borderColor)
    if showZoneMidLines
        pmLine50 := f_createOrUpdateLine(pmLine50, pmLeft, pmZ50, pmRight, midLineColor)
        pmLine618 := f_createOrUpdateLine(pmLine618, pmLeft, pmZ618, pmRight, midLineColor)

if showMorningZone and not na(morningZ50) and not na(morningZ618) and not na(morningStartBar)
    mgTop = math.max(morningZ50, morningZ618)
    mgBot = math.min(morningZ50, morningZ618)
    mgLeft = morningStartBar
    mgRight = extendZonesRight ? bar_index + 100 : nz(morningEndBar, bar_index)
    morningBox := f_createOrUpdateBox(morningBox, mgLeft, mgRight, mgTop, mgBot, morningZoneColor, borderColor)
    if showZoneMidLines
        morningLine50 := f_createOrUpdateLine(morningLine50, mgLeft, morningZ50, mgRight, midLineColor)
        morningLine618 := f_createOrUpdateLine(morningLine618, mgLeft, morningZ618, mgRight, midLineColor)

//====================================================
// PRICE INSIDE ZONES
//====================================================
priceInPrevZone = not na(prevZ50) and not na(prevZ618) and close <= math.max(prevZ50, prevZ618) and close >= math.min(prevZ50, prevZ618)
priceInPmZone = not na(pmZ50) and not na(pmZ618) and close <= math.max(pmZ50, pmZ618) and close >= math.min(pmZ50, pmZ618)
priceInMorningZone = not na(morningZ50) and not na(morningZ618) and close <= math.max(morningZ50, morningZ618) and close >= math.min(morningZ50, morningZ618)

//====================================================
// DASHBOARDS
//====================================================
headerBg   = color.rgb(45, 50, 63)
labelBg    = color.rgb(52, 58, 74)
neutralBg  = color.rgb(70, 76, 92)
hintBg     = color.rgb(57, 76, 115)
locationBg = color.rgb(61, 92, 92)
spacerBg   = color.new(color.black, 100)

var table dashFull = table.new(position.top_right, 2, 20, border_width=1)
var table dashCompact = table.new(position.top_center, 4, 12, border_width=1)

if barstate.islast
    table.clear(dashFull, 0, 0, 1, 19)
    table.clear(dashCompact, 0, 0, 3, 11)

    if showDashboard
        baseRow = dashboardOffsetRows

        if dashboardMode == "Full"
            if baseRow > 0
                for i = 0 to baseRow - 1
                    table.cell(dashFull, 0, i, " ", bgcolor=spacerBg, text_color=spacerBg)
                    table.cell(dashFull, 1, i, " ", bgcolor=spacerBg, text_color=spacerBg)

            table.cell(dashFull, 0, baseRow + 0, "DAILY RANGE INTEL", text_color=color.white, bgcolor=headerBg, text_size=size.large)
            table.cell(dashFull, 1, baseRow + 0, syminfo.ticker, text_color=color.white, bgcolor=headerBg, text_size=size.large)

            table.cell(dashFull, 0, baseRow + 1, "ATR(" + str.tostring(atrLength) + ")", text_color=color.white, bgcolor=labelBg, text_size=size.large)
            table.cell(dashFull, 1, baseRow + 1, str.tostring(dailyATR, format.mintick), text_color=color.white, bgcolor=neutralBg, text_size=size.large)

            table.cell(dashFull, 0, baseRow + 2, gapLabel, text_color=color.white, bgcolor=labelBg, text_size=size.large)
            table.cell(dashFull, 1, baseRow + 2, str.tostring(gapValue, format.mintick) + " (" + str.tostring(gapPctATR, "#.0") + "%)", text_color=f_txtByPct(gapPctATR), bgcolor=f_bgByPct(gapPctATR), text_size=size.large)

            table.cell(dashFull, 0, baseRow + 3, "Premarket", text_color=color.white, bgcolor=labelBg, text_size=size.large)
            table.cell(dashFull, 1, baseRow + 3, na(pmRange) ? "n/a" : str.tostring(pmRange, format.mintick) + " (" + str.tostring(pmPctATR, "#.0") + "%)", text_color=f_txtByPct(pmPctATR), bgcolor=f_bgByPct(pmPctATR), text_size=size.large)

            table.cell(dashFull, 0, baseRow + 4, "Today Range", text_color=color.white, bgcolor=labelBg, text_size=size.large)
            table.cell(dashFull, 1, baseRow + 4, str.tostring(todayRange, format.mintick) + " (" + str.tostring(todayPctATR, "#.0") + "%)", text_color=f_txtByPct(todayPctATR), bgcolor=f_bgByPct(todayPctATR), text_size=size.large)

            table.cell(dashFull, 0, baseRow + 5, "Morning", text_color=color.white, bgcolor=labelBg, text_size=size.large)
            table.cell(dashFull, 1, baseRow + 5, na(morningRange) ? "n/a" : str.tostring(morningRange, format.mintick) + " (" + str.tostring(morningPctATR, "#.0") + "%)", text_color=f_txtByPct(morningPctATR), bgcolor=f_bgByPct(morningPctATR), text_size=size.large)

            table.cell(dashFull, 0, baseRow + 6, "Range State", text_color=color.white, bgcolor=labelBg, text_size=size.large)
            table.cell(dashFull, 1, baseRow + 6, dayStatus, text_color=f_txtByPct(todayPctATR), bgcolor=f_bgByPct(todayPctATR), text_size=size.large)

            table.cell(dashFull, 0, baseRow + 7, "Hint", text_color=color.white, bgcolor=labelBg, text_size=size.large)
            table.cell(dashFull, 1, baseRow + 7, f_shortHint(gapPctATR, todayPctATR, pmPctATR, atrAlertThresholdPct), text_color=color.white, bgcolor=hintBg, text_size=size.large)

            zoneText = priceInPmZone ? "Inside PM Zone" : priceInMorningZone ? "Inside Morning Zone" : priceInPrevZone ? "Inside Prev Day Zone" : "Outside Zones"
            table.cell(dashFull, 0, baseRow + 8, "Location", text_color=color.white, bgcolor=labelBg, text_size=size.large)
            table.cell(dashFull, 1, baseRow + 8, zoneText, text_color=color.white, bgcolor=locationBg, text_size=size.large)

            thresholdText = "Alert @ " + str.tostring(atrAlertThresholdPct, "#") + "%"
            table.cell(dashFull, 0, baseRow + 9, "Threshold", text_color=color.white, bgcolor=labelBg, text_size=size.large)
            table.cell(dashFull, 1, baseRow + 9, thresholdText, text_color=color.white, bgcolor=neutralBg, text_size=size.large)

        if dashboardMode == "Compact"
            if baseRow > 0
                for i = 0 to baseRow - 1
                    table.cell(dashCompact, 0, i, " ", bgcolor=spacerBg, text_color=spacerBg)
                    table.cell(dashCompact, 1, i, " ", bgcolor=spacerBg, text_color=spacerBg)
                    table.cell(dashCompact, 2, i, " ", bgcolor=spacerBg, text_color=spacerBg)
                    table.cell(dashCompact, 3, i, " ", bgcolor=spacerBg, text_color=spacerBg)

            compactBg1 = headerBg
            compactBg2 = f_bgByPct(todayPctATR)
            compactTxt2 = f_txtByPct(todayPctATR)
            hintText  = f_shortHint(gapPctATR, todayPctATR, pmPctATR, atrAlertThresholdPct)

            table.cell(dashCompact, 0, baseRow + 0, syminfo.ticker, text_color=color.white, bgcolor=compactBg1, text_size=size.normal)
            table.cell(dashCompact, 1, baseRow + 0, "ATR " + str.tostring(dailyATR, format.mintick), text_color=color.white, bgcolor=compactBg1, text_size=size.normal)
            table.cell(dashCompact, 2, baseRow + 0, trafficText, text_color=compactTxt2, bgcolor=compactBg2, text_size=size.normal)
            table.cell(dashCompact, 3, baseRow + 0, "Used " + str.tostring(todayPctATR, "#.0") + "%", text_color=compactTxt2, bgcolor=compactBg2, text_size=size.normal)

            table.cell(dashCompact, 0, baseRow + 1, "DRI", text_color=color.white, bgcolor=labelBg, text_size=size.normal)
            table.cell(dashCompact, 1, baseRow + 1, dayStatus, text_color=compactTxt2, bgcolor=compactBg2, text_size=size.normal)
            table.cell(dashCompact, 2, baseRow + 1, hintText, text_color=color.white, bgcolor=hintBg, text_size=size.normal)
            table.cell(dashCompact, 3, baseRow + 1, str.tostring(todayRange, format.mintick), text_color=color.white, bgcolor=neutralBg, text_size=size.normal)

//====================================================
// ALERTS
//====================================================
alertcondition(not na(gapPctATR) and gapPctATR >= atrAlertThresholdPct, "Gap exceeded ATR threshold", "Gap exceeded ATR threshold")
alertcondition(not na(pmPctATR) and pmPctATR >= atrAlertThresholdPct, "Premarket exceeded ATR threshold", "Premarket range exceeded ATR threshold")
alertcondition(not na(todayPctATR) and todayPctATR >= atrAlertThresholdPct, "Day range exceeded ATR threshold", "Current day range exceeded ATR threshold")
alertcondition(priceInPmZone, "Price inside Premarket Golden Zone", "Price is inside the Premarket Golden Zone")
alertcondition(priceInMorningZone, "Price inside Morning Impulse Golden Zone", "Price is inside the Morning Impulse Golden Zone")
alertcondition(priceInPrevZone, "Price inside Previous Day Golden Zone", "Price is inside the Previous Day Golden Zone")
alertcondition(atrThresholdEvent, "ATR 100% reached", "Price reached the ATR 100% level for the day")
````
