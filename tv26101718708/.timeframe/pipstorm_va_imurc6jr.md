# Pipstorm VA

- url: https://www.tradingview.com/script/IMurC6Jr-Pipstorm-VA/
- type: indicator
- pine_id: PUB;6cf8ab220a464d25a0a299984c156b1c
- version: 1.0

## Description

Pipstorm VA helps traders detect trend direction, momentum shifts, and potential reversal zones. The indicator provides visual signals for easier market analysis and trade planning

## Source Code

````pine
//@version=6
indicator("Pipstorm VA", shorttitle="Pipstorm VA", overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500)

// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
// © vinubalagopalap

// ==============================================================================
// INTERNAL VISIBLECHART REPLACEMENT
// ==============================================================================

barIsVisible() =>
    time >= chart.left_visible_bar_time and time <= chart.right_visible_bar_time

// ==============================================================================
// INPUT OPTIONS
// ==============================================================================

LS0='Solid'
LS1='Dashed'
LS2='Dotted'

BX0='DR'
BX1='IDR'

XL0='Follow Time'
XL1='Session End'
XL2='ADR End'
XL3='ODR End'
XL4='RDR End'

STDLT0='Dynamic'
STDLT1='Static'

// ==============================================================================
// CONSTANTS
// ==============================================================================

TIMEZONE = 'America/New_York'
ONE_HOUR = 3600 * 1000
ONE_DAY = 24 * ONE_HOUR

// ==============================================================================
// INPUTS
// ==============================================================================

var GRP1 = "Time Settings"

exchangeOffset      = input.int(0,"Exchange Offset (hours)", group=GRP1, display = display.none)

regularTime         = input.session('0930-1030', 'RDR Time', group=GRP1, display = display.none)
regularExtend       = input.session('1030-1600', 'RDR Lines Time', group=GRP1, display = display.none)

afterTime           = input.session('1930-2030', 'ADR Time', group=GRP1, display = display.none)
afterExtend         = input.session('2030-0200', 'ADR Lines Time', group=GRP1, display = display.none)

overnightTime       = input.session('0300-0400', 'ODR Time', group=GRP1, display = display.none)
overnightExtend     = input.session('0400-0830', 'ODR Lines Time', group=GRP1, display = display.none)

var GRP2 = "General Settings"

showRegular         = input.bool(true, 'Regular', group=GRP2, inline='session', display = display.none)
showAfter           = input.bool(true, 'After', group=GRP2, inline='session', display = display.none)
showOvernight       = input.bool(true, 'Overnight', group=GRP2, inline='session', display = display.none)

drlines             = input.bool(true, 'Show DR Lines ?', group=GRP2, display = display.none)
idrlines            = input.bool(true, 'Show IDR Lines ?', group=GRP2, display = display.none)

middledrline        = input.bool(false, 'Show Middle DR Line ?', group=GRP2, display = display.none)
middleidrline       = input.bool(true, 'Show Middle IDR Line ?', group=GRP2, display = display.none)

openline            = input.bool(true, 'Show Opening Line ?', group=GRP2, inline='openline', display = display.none)
extendopLines       = input.bool(true, 'Extend', group=GRP2, inline='openline', display = display.none)

extendopLinesType   = input.string(XL1, '', options=[XL0,XL1,XL2,XL3,XL4], group=GRP2, inline='openline', display = display.none)

showBackground      = input.bool(true, 'Show DR/IDR Box ?', group=GRP2, display = display.none)

boxType             = input.string(BX1, 'Box DR or IDR ?', options=[BX0,BX1], group=GRP2, display = display.none)

extenddrLines       = input.bool(true, 'Extend DR Lines ?', group=GRP2, display = display.none)
extendidrLines      = input.bool(true, 'Extend IDR Lines ?', group=GRP2, display = display.none)

showAllHistory      = input.bool(false, 'Show complete history ?', group=GRP2, display = display.none)

useBoxColors        = input.bool(false, 'Box color based on open and close', group=GRP2, display = display.none)

extendToEndOfRDR    = input.bool(false, 'Extend lines of all ranges to end of most recent Regular session?', group=GRP2, display = display.none)

showStdLines                = input.bool(false, 'Show STD Lines ?', group=GRP2, inline='stdlines', display = display.none)
showStdLinesAll             = input.bool(true, 'All', group=GRP2, inline='stdlines', display = display.none)
showStdLineLabels           = input.bool(true, 'Labels', group=GRP2, inline='stdlines', display = display.none)

stdLineType                 = input.string(STDLT1, '', [STDLT0,STDLT1], group=GRP2, inline='stdlines', display = display.none)

stdLineDynamicExtraPos      = input.int(0, 'Dynamic (+)', minval=0, group=GRP2, display = display.none)
stdLineDynamicExtraNeg      = input.int(0, 'Dynamic (-)', minval=0, group=GRP2, display = display.none)
stdLineDynamicExtraAuto     = input.bool(false, 'Auto', group=GRP2, display = display.none)

stdLineStaticExtraPos       = input.int(10, 'Static (+)', minval=0, group=GRP2, display = display.none)
stdLineStaticExtraNeg       = input.int(10, 'Static (-)', minval=0, group=GRP2, display = display.none)

var GRP3 = "Styles"

linesWidth          = input.int(1, 'Box And Lines Width ?', minval=1, maxval=4, group=GRP3, display = display.none)

drLineColor         = input.color(color.gray, 'DR Line Color', group=GRP3, display = display.none)
drLineStyle         = input.string(LS0, 'Style', options=[LS0,LS1,LS2], group=GRP3, display = display.none)

idrLineColor        = input.color(color.red, 'IDR Line Color', group=GRP3, display = display.none)
idrLineStyle        = input.string(LS1, 'Style', options=[LS0,LS1,LS2], group=GRP3, display = display.none)

middleLineColor     = input.color(color.gray, 'Middle Line Color', group=GRP3, display = display.none)
middleLineStyle     = input.string(LS2, 'Style', options=[LS0,LS1,LS2], group=GRP3, display = display.none)

opLineColor         = input.color(color.green, 'Opening Line', group=GRP3, display = display.none)
opLineStyle         = input.string(LS2, '', options=[LS0,LS1,LS2], group=GRP3, display = display.none)

stdLineColor        = input.color(color.gray, 'STD Lines', group=GRP3, display = display.none)
stdLineStyle        = input.string(LS2, '', options=[LS0,LS1,LS2], group=GRP3, display = display.none)

backgroundColor     = input.color(color.new(color.gray, 75), 'Box Background Color', group=GRP3, display = display.none)

boxBorderSize       = input.int(0, title="Box border size", minval=0, group=GRP3, display = display.none)

upBoxColor          = input.color(color.new(color.green, 85), 'Up box', group=GRP3, display = display.none)
upBorderColor       = input.color(color.green, 'border', group=GRP3, display = display.none)

downBoxColor        = input.color(color.new(color.red, 85), 'Down box', group=GRP3, display = display.none)
downBorderColor     = input.color(color.red, 'border', group=GRP3, display = display.none)

// ==============================================================================
// CONSTANTS
// ==============================================================================

exchangeOffsetMS = exchangeOffset * 3600000

// ==============================================================================
// VARIABLES
// ==============================================================================

var int     startTime           = na
var int     endTime             = na
var string  currentSession      = na

var line    lowrdrl             = na
var line    highrdrl            = na

var line    lowridrl            = na
var line    highridrl           = na

var line    middlerdrl          = na
var line    middleridrl         = na

var line    drLineOpen          = na

var box     bgBox               = na

var line[]  stdLines            = array.new<line>()
var float[] stdLevels           = array.new<float>()
var label[] stdLabels           = array.new<label>()

var float   rdrlow              = na
var float   rdrhigh             = na

var float   ridrlow             = na
var float   ridrhigh            = na

var float   rdrmiddle           = na
var float   ridrmiddle          = na

var float   sessionOpen         = na

var float   regidrlow           = na
var float   regidrhigh          = na

var float   sessionHigh         = na
var float   sessionLow          = na

var int     stdLinesStartTime   = na
var int     stdLinesStopTime    = na

var bool    use_m5              = false

var bool    drBrokenUp          = false
var bool    drBrokenDown        = false

var float   adrHigh             = na
var float   adrLow              = na

var float   odrHigh             = na
var float   odrLow              = na

var float   rdrStoredHigh       = na
var float   rdrStoredLow        = na

var bool    adrBullBroken       = false
var bool    adrBearBroken       = false

var bool    odrBullBroken       = false
var bool    odrBearBroken       = false

var bool    rdrBullBroken       = false
var bool    rdrBearBroken       = false

// ==============================================================================
// FUNCTIONS
// ==============================================================================

f_insession(_session) =>
    not na(time(timeframe.period, _session, TIMEZONE))

f_timestrToHM(_timeStr) =>
    var int hourInt = na
    var int minuteInt = na

    if str.length(_timeStr) == 4
        hourInt := int(str.tonumber(str.substring(_timeStr, 0, 2)))
        minuteInt := int(str.tonumber(str.substring(_timeStr, 2, 4)))

    [hourInt, minuteInt]

f_sessionTime(_session, _timezone=syminfo.timezone, _part=0) =>
    var int ts = na

    if str.length(_session) == 9 and (_part == 0 or _part == 1)

        arraySessionSplit = str.split(_session, '-')

        timeStrTo = array.get(arraySessionSplit, _part)

        [hourTo, minuteTo] = f_timestrToHM(timeStrTo)

        ts := timestamp(_timezone, year, month, dayofmonth, hourTo, minuteTo)

    ts

f_sessionStartTime(_session, _timezone=syminfo.timezone) =>
    f_sessionTime(_session, _timezone, 0)

f_sessionStopTime(_session, _timezone=syminfo.timezone) =>
    f_sessionTime(_session, _timezone, 1)

f_timestamp_to_date(int _ts = na, string _tz = na) =>
    timestamp(_tz, year(_ts, _tz), month(_ts, _tz), dayofmonth(_ts, _tz))

f_lineStyle(_inputOption) =>
    switch(_inputOption)
        LS0 => line.style_solid
        LS1 => line.style_dashed
        LS2 => line.style_dotted
        => line.style_solid

f_newline(_color, _style) =>
    line.new(na, na, na, na, xloc=xloc.bar_time, color=_color, style=_style, width=linesWidth)

f_newdrline() =>
    f_newline(drLineColor, f_lineStyle(drLineStyle))

f_newidrline() =>
    f_newline(idrLineColor, f_lineStyle(idrLineStyle))

f_newmdline() =>
    f_newline(middleLineColor, f_lineStyle(middleLineStyle))

f_newopline() =>
    f_newline(opLineColor, f_lineStyle(opLineStyle))

f_newstdline() =>
    f_newline(stdLineColor, f_lineStyle(stdLineStyle))

f_newbox() =>
    box.new(na, na, na, na, xloc=xloc.bar_time, bgcolor=backgroundColor, border_width=boxBorderSize)

f_moveLine(_line, _x1, _y, _x2) =>
    line.set_xy1(_line, _x1 + exchangeOffsetMS, _y)
    line.set_xy2(_line, _x2 + exchangeOffsetMS, _y)
    _line

f_movebox(_box, _left, _top, _right, _bottom, _bordercolor, _bgcolor) =>
    box.set_lefttop(_box, _left + exchangeOffsetMS, _top)
    box.set_rightbottom(_box, _right + exchangeOffsetMS, _bottom)
    box.set_border_color(_box, _bordercolor)
    box.set_bgcolor(_box, _bgcolor)

f_newLabel() =>
    label.new(na, na, '', xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_left, color=color(na), textcolor=stdLineColor)

f_moveLabel(_label, _x, _y, _text) =>
    label.set_xy(_label, _x, _y)
    label.set_text(_label, _text)
    _label

f_drawStdLine(_fromTime, _toTime, _level, float _stdLabelValue=na) =>
    if not na(_level)

        if not array.includes(stdLevels, _level)

            array.push(stdLevels, _level)

            array.push(stdLines, f_moveLine(f_newstdline(), _fromTime, _level, _toTime))

            if showStdLineLabels
                array.push(stdLabels, f_moveLabel(f_newLabel(), _toTime, _level, str.format('{0}',_stdLabelValue)))

f_drawStdLines(_fromTime, _toTime, bool _clear=false) =>

    var float stdStepFactor = 0.5
    var float stdStep = na

    var float stdLevel = na
    var float stdLabelValue = na

    var int nrLevelsPos = na
    var int nrLevelsNeg = na

    if _clear and not showStdLinesAll and array.size(stdLevels) > 0

        for tmpIndex = 0 to array.size(stdLines)-1

            line.delete(array.get(stdLines, tmpIndex))

            if showStdLineLabels
                label.delete(array.get(stdLabels, tmpIndex))

    if _clear

        array.clear(stdLevels)
        array.clear(stdLines)

        if showStdLineLabels
            array.clear(stdLabels)

    stdStep := math.abs(regidrhigh-regidrlow) * stdStepFactor

    if stdStep != 0

        switch stdLineType

            STDLT0 =>
                nrLevelsPos := math.ceil(math.max(sessionHigh - regidrhigh, 0) / stdStep) + (stdLineDynamicExtraAuto ? 0 : stdLineDynamicExtraPos)
                nrLevelsNeg := math.ceil(math.max(regidrlow - sessionLow, 0) / stdStep) + (stdLineDynamicExtraAuto ? 0 : stdLineDynamicExtraNeg)

            STDLT1 =>
                nrLevelsPos := stdLineStaticExtraPos
                nrLevelsNeg := stdLineStaticExtraNeg

        if nrLevelsPos >= 1

            for cnt = 1 to nrLevelsPos

                stdLevel := regidrhigh + (cnt * stdStep)

                stdLabelValue := cnt * stdStepFactor

                f_drawStdLine(_fromTime, _toTime, stdLevel, stdLabelValue)

        if nrLevelsNeg >= 1

            for cnt = 1 to nrLevelsNeg

                stdLevel := regidrlow - (cnt * stdStep)

                stdLabelValue := cnt * (-stdStepFactor)

                f_drawStdLine(_fromTime, _toTime, stdLevel, stdLabelValue)

// ==============================================================================
// LOWER TF HANDLING
// ==============================================================================

if barstate.isfirst
    use_m5 := timeframe.in_seconds() < 300

[m5_open, m5_high, m5_low, m5_close] = request.security(syminfo.tickerid, '5', [open, high, low, close], lookahead=barmerge.lookahead_on)

open_value  = use_m5 ? m5_open  : open
high_value  = use_m5 ? m5_high  : high
low_value   = use_m5 ? m5_low   : low
close_value = use_m5 ? m5_close : close

// ==============================================================================
// SESSION STATES
// ==============================================================================

inRegularSession    = f_insession(regularTime) and showRegular
inRegularExtend     = f_insession(regularExtend) and showRegular

inAfterSession      = f_insession(afterTime) and showAfter
inAfterExtend       = f_insession(afterExtend) and showAfter

inOvernightSession  = f_insession(overnightTime) and showOvernight
inOvernightExtend   = f_insession(overnightExtend) and showOvernight

inSession           = inRegularSession or inOvernightSession or inAfterSession
inExtend            = inRegularExtend or inOvernightExtend or inAfterExtend

enterSession        = inSession and not inSession[1]
enterExtend         = inExtend and not inExtend[1]

leaveRegularSession = not inRegularSession and inRegularSession[1]
enterRegularExtend  = inRegularExtend and not inRegularExtend[1]

leaveAfterSession     = not inAfterSession and inAfterSession[1]
leaveOvernightSession = not inOvernightSession and inOvernightSession[1]

if leaveAfterSession
    adrHigh := rdrhigh
    adrLow  := rdrlow

if leaveOvernightSession
    odrHigh := rdrhigh
    odrLow  := rdrlow

if leaveRegularSession
    rdrStoredHigh := rdrhigh
    rdrStoredLow  := rdrlow

// ==============================================================================
// DR BREAK DETECTION
// ==============================================================================

var GRP4 = "Break Detection"

breakTF = timeframe.period

showBreakLabels = input.bool(true, "Show Break Labels", group=GRP4)

breakBullColor = input.color(color.green, "Bullish Break Color", group=GRP4)
breakBearColor = input.color(color.red, "Bearish Break Color", group=GRP4)

[tfOpen, tfClose] = request.security(
     syminfo.tickerid,
     breakTF,
     [open, close],
     lookahead = barmerge.lookahead_off
 )

// ==============================================================================
// MAIN LOGIC
// ==============================================================================

if timeframe.isintraday

    if enterSession
        currentSession := inRegularSession ? regularTime : inOvernightSession ? overnightTime : inAfterSession ? afterTime : na

    else if enterExtend
        currentSession := inRegularExtend ? regularExtend : inOvernightExtend ? overnightExtend : inAfterExtend ? afterExtend : na

    if inSession

        if not inSession[1]

            startTime := time

            sessionOpen := open_value

            rdrhigh := high_value
            rdrlow := low_value

            ridrlow := math.min(open_value, close_value)
            ridrhigh := math.max(open_value, close_value)

            if showBackground
                bgBox := f_newbox()

            if drlines
                highrdrl := f_newdrline()
                lowrdrl := f_newdrline()

            if idrlines
                highridrl := f_newidrline()
                lowridrl := f_newidrline()

            if middledrline
                middlerdrl := f_newmdline()

            if middleidrline
                middleridrl := f_newmdline()

            if openline
                drLineOpen := f_newopline()

        rdrhigh := math.max(high_value, rdrhigh)
        rdrlow := math.min(low_value, rdrlow)

        ridrhigh := math.max(open_value, close_value, ridrhigh)
        ridrlow := math.min(open_value, close_value, ridrlow)

        rdrmiddle := math.avg(rdrhigh, rdrlow)
        ridrmiddle := math.avg(ridrhigh, ridrlow)

    if leaveRegularSession

        regidrhigh := ridrhigh
        regidrlow := ridrlow

        if inRegularExtend

            stdLinesStartTime := f_sessionStartTime(regularExtend, TIMEZONE)
            stdLinesStopTime := f_sessionStopTime(overnightExtend, TIMEZONE) + ONE_DAY * (dayofweek == dayofweek.friday and syminfo.type != 'crypto' ? 3 : 1)

    if enterRegularExtend

        sessionHigh := high_value
        sessionLow := low_value

    sessionHigh := math.max(sessionHigh, high_value)
    sessionLow := math.min(sessionLow, low_value)

    if showBackground and inSession

        boxUp = close_value > sessionOpen

        boxBorderColor = useBoxColors ? (boxUp ? upBorderColor : downBorderColor) : backgroundColor

        boxBackgroundColor = useBoxColors ? (boxUp ? upBoxColor : downBoxColor) : backgroundColor

        boxHigh = boxType == BX0 ? rdrhigh : ridrhigh
        boxLow = boxType == BX0 ? rdrlow : ridrlow

        f_movebox(bgBox, startTime, boxHigh, time, boxLow, boxBorderColor, boxBackgroundColor)

    if extendToEndOfRDR

        if syminfo.type == 'warrant' or syminfo.type == 'structured' or syminfo.type == 'right'

            endTime := time

        else if time > (timenow - 2 * ONE_DAY)

            if f_timestamp_to_date(f_sessionStopTime(currentSession, TIMEZONE), TIMEZONE) == f_timestamp_to_date(timenow, TIMEZONE)

                endTime := f_sessionStopTime(regularExtend, TIMEZONE)

            else
                endTime := time

        else
            endTime := time

    else
        endTime := time

    if drlines and (inSession or (extenddrLines and inExtend))

        f_moveLine(highrdrl, startTime, rdrhigh, endTime)
        f_moveLine(lowrdrl, startTime, rdrlow, endTime)

        if middledrline
            f_moveLine(middlerdrl, startTime, rdrmiddle, endTime)

    if idrlines and (inSession or (extendidrLines and inExtend))

        f_moveLine(highridrl, startTime, ridrhigh, endTime)
        f_moveLine(lowridrl, startTime, ridrlow, endTime)

        if middleidrline
            f_moveLine(middleridrl, startTime, ridrmiddle, endTime)

    if openline and (inSession or (extendopLines and inExtend))
        f_moveLine(drLineOpen, startTime, sessionOpen, endTime)

    if showStdLines
        f_drawStdLines(stdLinesStartTime, stdLinesStopTime, enterRegularExtend)

// ==============================================================================
// FIRST CLOSE BEYOND DR LEVEL
// ==============================================================================

// ADR
adrBullBreak = inAfterExtend and not adrBullBroken and not na(adrHigh) and close > adrHigh and close[1] <= adrHigh

adrBearBreak = inAfterExtend and not adrBearBroken and not na(adrLow) and close < adrLow and close[1] >= adrLow

// ODR
odrBullBreak = inOvernightExtend and not odrBullBroken and not na(odrHigh) and close > odrHigh and close[1] <= odrHigh

odrBearBreak = inOvernightExtend and not odrBearBroken and not na(odrLow) and close < odrLow and close[1] >= odrLow

// RDR
rdrBullBreak = inRegularExtend and not rdrBullBroken and not na(rdrStoredHigh) and close > rdrStoredHigh and close[1] <= rdrStoredHigh

rdrBearBreak = inRegularExtend and not rdrBearBroken and not na(rdrStoredLow) and close < rdrStoredLow and close[1] >= rdrStoredLow

bullishBreak = adrBullBreak or odrBullBreak or rdrBullBreak

bearishBreak = adrBearBreak or odrBearBreak or rdrBearBreak

// ADR
if adrBullBreak
    adrBullBroken := true

if adrBearBreak
    adrBearBroken := true

// ODR
if odrBullBreak
    odrBullBroken := true

if odrBearBreak
    odrBearBroken := true

// RDR
if rdrBullBreak
    rdrBullBroken := true

if rdrBearBreak
    rdrBearBroken := true


isToday = dayofmonth(time) == dayofmonth(timenow) and
          month(time) == month(timenow) and
          year(time) == year(timenow)

// ==============================================================================
// HIGHLIGHT BREAK CANDLES
// ==============================================================================

barcolor(
     bullishBreak and isToday ? color.rgb(70, 26, 146) :
     bearishBreak and isToday ? color.rgb(70, 26, 146) :
     na
 )

// ==============================================================================
// BULLISH BREAK LABEL
// ==============================================================================

if bullishBreak and isToday

    drBrokenUp := true

    if showBreakLabels
        if adrBullBreak
            adrBullBroken := true

        if odrBullBreak
            odrBullBroken := true

        if rdrBullBreak
            rdrBullBroken := true

        label.new(
             bar_index,
             high,
             "↑",
             style = label.style_none,
             textcolor = color.rgb(70, 26, 146),
             size = size.normal
         )

// ==============================================================================
// BEARISH BREAK LABEL
// ==============================================================================

if bearishBreak and isToday

    drBrokenDown := true

    if showBreakLabels

        if adrBearBreak
            adrBearBroken := true

        if odrBearBreak
            odrBearBroken := true

        if rdrBearBreak
            rdrBearBroken := true

        label.new(
             bar_index,
             high,
             "↓",
             style = label.style_none,
             textcolor = color.rgb(70, 26, 146),
             size = size.normal
         )

// ==============================================================================
// RESET BREAK STATES
// ==============================================================================

if leaveAfterSession
    adrBullBroken := false
    adrBearBroken := false

if leaveOvernightSession
    odrBullBroken := false
    odrBearBroken := false

if leaveRegularSession
    rdrBullBroken := false
    rdrBearBroken := false


plot(adrHigh, "ADR High", color=color.green, display = display.none)
plot(adrLow, "ADR Low", color=color.green, display = display.none)

plot(odrHigh, "ODR High", color=color.aqua, display = display.none)
plot(odrLow, "ODR Low", color=color.aqua, display = display.none)

plot(rdrStoredHigh, "RDR High", color=color.maroon, display = display.none)
plot(rdrStoredLow, "RDR Low", color=color.maroon, display = display.none)
// import Sessions and KillZones Library
import TFlab/SessionAndKillZoneLibrary_TradingFinder/1 as Sess

// Global Setting
ShowMoreInfo = input.bool(false, 'Show More Info', inline = 'More' , group = 'Global Setting')
ColorMoreInfo = input.color(#0c3299, '', inline = 'More' , group = 'Global Setting')

//Session Asia
show_AsiaSess = input(true, 'Asia Session',inline = 'sesasia', group = 'Asia Session', tooltip = 'Sydney + Tokyo')
Asia_SessTime = input.session('2300-0600', '',  group = 'Asia Session')
Asia_color = input.color(#fa7b05, '', inline = 'sesasia', group = 'Asia Session')
show_AsiaKill = input(true, 'Asia Kill Zone', group = 'Asia Session')
Asia_KillTime = input.session('2300-0355', '', group = 'Asia Session')

//Session London
show_LondonSess = input(true, 'London Session',  inline = 'seslondon', group = ' London Session', tooltip = 'Frankfurt + London') 
London_SessTime = input.session('0700-1425', '',  group = ' London Session')
London_color = input.color(#118502, '', inline = 'seslondon', group = ' London Session')
show_LondonKill = input(true, 'London Kill Zone',  group = ' London Session') 
London_KillTime = input.session('0700-0955', '', group = ' London Session')

//Session AM NewYork
show_amNewyorkSess = input(true, 'NewYork AM Session', inline = 'sesamNewyork', group = 'NewYork AM Session') 
amNewyork_SessTime = input.session('1430-1925', '',  group = 'NewYork AM Session')
amNewyork_color = input.color(#b40f0f, '', inline = 'sesamNewyork', group = 'NewYork AM Session')
show_amNewyorkKill = input(true, 'NewYork Am Kill Zone',  group = 'NewYork AM Session') 
amNewyork_KillTime = input.session('1430-1655', '', group = 'NewYork AM Session')

//Session AM NewYork
show_pmNewyorkSess = input(true, 'NewYork PM Session', inline = 'sespmNewyork', group = 'NewYork PM Session') 
pmNewyork_SessTime = input.session('1930-2255', '',  group = 'NewYork PM Session')
pmNewyork_color = input.color(#0c6dff, '', inline = 'sespmNewyork', group = 'NewYork PM Session')
show_pmNewyorkKill = input(true, 'NewYork PM Kill Zone',  group = 'NewYork PM Session') 
pmNewyork_KillTime = input.session('1930-2055', '', group = 'NewYork PM Session')

// Call Sessions and KillZones Library
Sess.SessionDetector('Asia'  , Asia_SessTime, Asia_KillTime, show_AsiaSess, show_AsiaKill, 'Session', ShowMoreInfo ,Asia_color,ColorMoreInfo)
Sess.SessionDetector('London', London_SessTime, London_KillTime, show_LondonSess, show_LondonKill, 'Session', ShowMoreInfo ,London_color,ColorMoreInfo)
Sess.SessionDetector('NY am' , amNewyork_SessTime, amNewyork_KillTime, show_amNewyorkSess, show_amNewyorkKill, 'Session', ShowMoreInfo ,amNewyork_color,ColorMoreInfo)
Sess.SessionDetector('NY pm' , pmNewyork_SessTime, pmNewyork_KillTime, show_pmNewyorkSess, show_pmNewyorkKill, 'Session', ShowMoreInfo ,pmNewyork_color,ColorMoreInfo)
````
