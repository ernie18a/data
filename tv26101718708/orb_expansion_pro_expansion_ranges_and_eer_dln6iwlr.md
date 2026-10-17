# ORB Expansion Pro (Expansion Ranges and EER)

- url: https://www.tradingview.com/script/dLN6IwLR-ORB-Expansion-Pro-Expansion-Ranges-and-EER/
- type: indicator
- pine_id: PUB;88cba18c98574a079904e70073662845
- version: 1.0

## Description

ORB Expansion Pro
Description

ORB Expansion Pro transforms the Opening Range Breakout from a simple breakout strategy into a complete market expansion framework.

Most ORB traders focus only on whether price breaks above or below the opening range. The problem is that a breakout alone provides no context about how far price is likely to travel or whether the move is already extended.

ORB Expansion Pro solves that problem by automatically calculating historical Opening Range statistics and projecting expansion levels based on real market behavior.

The indicator tracks Opening Range size, historical averages, expansion multiples, and expected range development to help traders evaluate opportunity, risk, and remaining session potential.

Key Features

✔ Automatic Opening Range calculations

✔ Historical average ORB analysis

✔ Expansion projections beyond the ORB

✔ Expected Expansion Range (EER) levels

✔ Session development tracking

✔ Objective profit target framework

✔ Visual expansion mapping directly on the chart

✔ Designed for futures, stocks, ETFs, and indexes

How Traders Use It
Identify unusually small or large opening ranges
Measure current expansion versus historical expectations
Set objective targets using expansion multiples
Evaluate whether a move is early, mature, or extended
Improve trade management and profit-taking decisions
Avoid chasing moves that have already exhausted expected range
Best Used With
ORB Dashboard Pro
Volume Profile
VWAP
Auction Market Theory
Market Structure Analysis

Real Trading. Real Testing. Real Results.

**  Related Indicators from Traders Workshop

• ORB Expansion Pro
• ORB Dashboard Pro
• ORB Sessions
• Everex Lite
• Flow MA Cloud

## Source Code

````pine
//@version=6
indicator('ORB Expansion Pro', overlay = true, max_lines_count = 500, max_labels_count = 100, max_bars_back = 5000)

//=====================================================================
//  Indicator: ORB Expansion Pro
//  Author: Christopher C. Berg
//  TradingView: chrisberg1961
//  Version: 3.0
//  Release Date: April 2026
//=====================================================================
//
//  EER CALCULATION â€” matched to ORB Dashboard Pro v3
//  ------------------------------------------------------------------
//  EER Expansion pts = Avg Session Range - Today's ORB Range
//  EER Multiplier    = EER Expansion pts / Today's ORB Range
//
//  EER Up = ORB High + EER Expansion pts
//  EER Dn = ORB Low  - EER Expansion pts
//
//  Example: AvgSess=86.42, TodayORB=48.75
//    Expansion pts = 86.42 - 48.75 = 37.67 pts (0.77R)
//
//  Compressed day (ORB=20): 86.42 - 20 = 66.42 pts (3.32R)
//  Wide day    (ORB=60):    86.42 - 60 = 26.42 pts (0.44R)
//
//  Safety: if ORB >= Avg Session Range, EER returns na (no plot)
//=====================================================================

//====================================================
// Inputs
//====================================================
orbMinutes = input.int(30, 'ORB Minutes', options = [5, 10, 15, 30, 45, 60])
orbSession = input.session('0830-1500', 'ORB Session')

showMidline = input.bool(false, 'Show Midline')
showExtensions = input.bool(false, 'Show 1R / 2R / 3R Levels')
numExtensions = input.int(3, 'Extension Levels Above/Below', minval = 1, maxval = 3)
showEERLines = input.bool(false, 'Show EER Avg Lines')

freezeAtSessionEnd = input.bool(true, 'Freeze At Session End')
extendAfterSession = input.bool(false, 'Extend After Session')

statsLookback = input.int(20, 'Stats Lookback Sessions', minval = 3, maxval = 100)
maxSessionsDraw = input.int(20, 'Max Historical Sessions To Draw', minval = 1, maxval = 100)

//----------------------------------------------------
// ORB High
//----------------------------------------------------
orbHighWidth = input.int(3, 'ORB High Width', minval = 1, maxval = 4)
orbHighStyleIn = input.string('Solid', 'ORB High Style', options = ['Solid', 'Dashed', 'Dotted'])

//----------------------------------------------------
// ORB Mid
//----------------------------------------------------
orbMidWidth = input.int(1, 'ORB Mid Width', minval = 1, maxval = 4)
orbMidStyleIn = input.string('Dashed', 'ORB Mid Style', options = ['Solid', 'Dashed', 'Dotted'])

//----------------------------------------------------
// ORB Low
//----------------------------------------------------
orbLowWidth = input.int(3, 'ORB Low Width', minval = 1, maxval = 4)
orbLowStyleIn = input.string('Solid', 'ORB Low Style', options = ['Solid', 'Dashed', 'Dotted'])

//----------------------------------------------------
// Upper Extensions
//----------------------------------------------------
upExtWidth = input.int(1, 'Upper Extensions Width', minval = 1, maxval = 4)
upExtStyleIn = input.string('Dashed', 'Upper Extensions Style', options = ['Solid', 'Dashed', 'Dotted'])

//----------------------------------------------------
// Lower Extensions
//----------------------------------------------------
dnExtWidth = input.int(1, 'Lower Extensions Width', minval = 1, maxval = 4)
dnExtStyleIn = input.string('Dashed', 'Lower Extensions Style', options = ['Solid', 'Dashed', 'Dotted'])

//----------------------------------------------------
// EER
//----------------------------------------------------
eerLineWidth = input.int(1, 'EER Line Width', minval = 1, maxval = 4)
eerLineStyleIn = input.string('Dotted', 'EER Line Style', options = ['Solid', 'Dashed', 'Dotted'])

//----------------------------------------------------
// ORB Info Label
//----------------------------------------------------
showOrbLabel = input.bool(true, 'Show ORB Info Label')
labelTextSizeIn = input.string('Small', 'Label Text Size', options = ['Tiny', 'Small', 'Normal', 'Large'])
labelOffsetTicks = input.int(1, 'Label Offset (Ticks Above ORB)', minval = 1, maxval = 50)

//----------------------------------------------------
// Alerts
//----------------------------------------------------
alertsEnabled = input.bool(true, 'Enable Alerts')
alertOrbBreakouts = input.bool(true, 'Alert: ORB Breakouts')
alertAcceptanceShifts = input.bool(true, 'Alert: Acceptance Above/Below ORB')

//====================================================
// Fixed Colors
//====================================================
orbHighColor = color.rgb(0, 255, 0)
orbMidColor = color.rgb(0, 0, 255)
orbLowColor = color.rgb(255, 0, 0)
upExtColor = color.green
dnExtColor = color.red
eerLineColor = color.aqua
labelBgColor = color.white
labelTxtColor = color.blue

//====================================================
// Helpers
//====================================================
f_line_style(_s) =>
    _s == 'Dashed' ? line.style_dashed : _s == 'Dotted' ? line.style_dotted : line.style_solid

f_label_size(_s) =>
    _s == 'Tiny' ? size.tiny : _s == 'Small' ? size.small : _s == 'Large' ? size.large : size.normal

f_trim_float_array(_arr, _max) =>
    while array.size(_arr) > _max
        array.shift(_arr)

f_trimmed_avg(_arr) =>
    int sz = array.size(_arr)
    float out = na
    if sz == 1
        out := array.get(_arr, 0)
        out
    else if sz == 2
        out := (array.get(_arr, 0) + array.get(_arr, 1)) * 0.5
        out
    else if sz > 2
        float sum = 0.0
        float lo = array.get(_arr, 0)
        float hi = array.get(_arr, 0)
        for i = 0 to sz - 1 by 1
            float v = array.get(_arr, i)
            sum := sum + v
            lo := math.min(lo, v)
            hi := math.max(hi, v)
            hi
        out := (sum - lo - hi) / (sz - 2)
        out
    out

f_push_line(_arr, _line, _max) =>
    array.push(_arr, _line)
    while array.size(_arr) > _max
        line oldLine = array.shift(_arr)
        if not na(oldLine)
            line.delete(oldLine)

f_push_label(_arr, _label, _max) =>
    array.push(_arr, _label)
    while array.size(_arr) > _max
        label oldLabel = array.shift(_arr)
        if not na(oldLabel)
            label.delete(oldLabel)

f_new_hline(_x1, _x2, _y, _color, _width, _style) =>
    line.new(_x1, _y, _x2, _y, xloc = xloc.bar_index, extend = extend.none, color = _color, width = _width, style = _style)

f_update_hline(_line, _x1, _x2, _y, _color, _width, _style) =>
    line.set_xy1(_line, _x1, _y)
    line.set_xy2(_line, _x2, _y)
    line.set_color(_line, _color)
    line.set_width(_line, _width)
    line.set_style(_line, _style)

//====================================================
// Derived styles
//====================================================
orbHighStyle = f_line_style(orbHighStyleIn)
orbMidStyle = f_line_style(orbMidStyleIn)
orbLowStyle = f_line_style(orbLowStyleIn)
upExtStyle = f_line_style(upExtStyleIn)
dnExtStyle = f_line_style(dnExtStyleIn)
eerLineStyle = f_line_style(eerLineStyleIn)
labelTextSize = f_label_size(labelTextSizeIn)

//====================================================
// Session state
//====================================================
inSess = not na(time(timeframe.period, orbSession))
newSess = inSess and not inSess[1]
endSess = not inSess and inSess[1]
orbBars = timeframe.isintraday ? math.ceil(orbMinutes / timeframe.multiplier) : na

//====================================================
// Persistent state
//====================================================
var float orbHigh = na
var float orbLow = na
var float orbMid = na
var float orbRange = na
var float sessHigh = na
var float sessLow = na

// Full RTH session range tracking (from 0830 open)
var float rthHigh = na
var float rthLow = na

var bool orbBuilding = false
var bool orbLocked = false

var int sessStartBar = na
var int orbStartBar = na
var int orbLockBar = na
var int frozenEndBar = na

// Historical arrays â€” ORB ranges and full RTH session ranges
var array<float> orbRangeHist = array.new_float()
var array<float> sessRangeHist = array.new_float()

var line curHighLine = na
var line curMidLine = na
var line curLowLine = na
var line curUp1Line = na
var line curUp2Line = na
var line curUp3Line = na
var line curDn1Line = na
var line curDn2Line = na
var line curDn3Line = na
var line curEerUp = na
var line curEerDn = na
var label curOrbInfoLabel = na

var array<line> histLines = array.new_line()
var array<label> histLabels = array.new_label()

//====================================================
// Session reset â€” archive previous session first
//====================================================
if newSess
    // Archive completed ORB range
    if orbLocked and not na(orbRange) and orbRange > 0
        array.push(orbRangeHist, orbRange)
        f_trim_float_array(orbRangeHist, statsLookback)

    // Archive completed RTH session range
    if not na(rthHigh) and not na(rthLow) and rthHigh > rthLow
        array.push(sessRangeHist, rthHigh - rthLow)
        f_trim_float_array(sessRangeHist, statsLookback)

    // Reset for new session
    orbHigh := na
    orbLow := na
    orbMid := na
    orbRange := na
    sessHigh := na
    sessLow := na
    rthHigh := na
    rthLow := na

    orbBuilding := true
    orbLocked := false

    sessStartBar := bar_index
    orbStartBar := bar_index
    orbLockBar := na
    frozenEndBar := na

    curHighLine := na
    curMidLine := na
    curLowLine := na
    curUp1Line := na
    curUp2Line := na
    curUp3Line := na
    curDn1Line := na
    curDn2Line := na
    curDn3Line := na
    curEerUp := na
    curEerDn := na
    curOrbInfoLabel := na
    curOrbInfoLabel

//====================================================
// Track full RTH range from first bar of session
//====================================================
if inSess
    rthHigh := na(rthHigh) ? high : math.max(rthHigh, high)
    rthLow := na(rthLow) ? low : math.min(rthLow, low)
    rthLow

//====================================================
// ORB build / lock
//====================================================
barsSinceOpen = inSess and not na(sessStartBar) ? bar_index - sessStartBar : na
inOrbWindow = inSess and orbBuilding and not na(barsSinceOpen) and not na(orbBars) and barsSinceOpen < orbBars
lockNow = inSess and orbBuilding and not orbLocked and not na(barsSinceOpen) and not na(orbBars) and barsSinceOpen >= orbBars

if inOrbWindow
    orbHigh := na(orbHigh) ? high : math.max(orbHigh, high)
    orbLow := na(orbLow) ? low : math.min(orbLow, low)
    orbLow

if lockNow
    orbBuilding := false
    orbLocked := true
    orbLockBar := bar_index
    orbMid := (orbHigh + orbLow) * 0.5
    orbRange := orbHigh - orbLow
    sessHigh := high
    sessLow := low
    sessLow

//====================================================
// Track session range after lock
//====================================================
if inSess and orbLocked
    sessHigh := na(sessHigh) ? high : math.max(sessHigh, high)
    sessLow := na(sessLow) ? low : math.min(sessLow, low)
    sessLow

//====================================================
// Freeze marker
//====================================================
if endSess and orbLocked and na(frozenEndBar)
    frozenEndBar := bar_index - 1
    frozenEndBar

//====================================================
// EER â€” matched to Dashboard Pro v3
// EER Expansion pts = Avg Session Range - Today's ORB Range
// Safety: returns na if ORB >= Avg Session Range
//====================================================
float avgOrbRange = f_trimmed_avg(orbRangeHist)
float avgSessRange = f_trimmed_avg(sessRangeHist)

float eerExpPts = not na(avgSessRange) and not na(orbRange) and orbRange > 0 and avgSessRange > orbRange ? avgSessRange - orbRange : na
float eerUpPx = orbLocked and not na(orbHigh) and not na(eerExpPts) ? orbHigh + eerExpPts : na
float eerDnPx = orbLocked and not na(orbLow) and not na(eerExpPts) ? orbLow - eerExpPts : na

//====================================================
// Live current-session line maintenance
//====================================================
if orbLocked
    int liveRightEdge = na

    if inSess
        liveRightEdge := bar_index
        liveRightEdge
    else
        liveRightEdge := nz(frozenEndBar, nz(bar_index[1], bar_index))
        if extendAfterSession
            liveRightEdge := bar_index
            liveRightEdge

    if na(curHighLine)
        curHighLine := f_new_hline(orbStartBar, liveRightEdge, orbHigh, orbHighColor, orbHighWidth, orbHighStyle)
        curHighLine
    else
        f_update_hline(curHighLine, orbStartBar, liveRightEdge, orbHigh, orbHighColor, orbHighWidth, orbHighStyle)

    if na(curLowLine)
        curLowLine := f_new_hline(orbStartBar, liveRightEdge, orbLow, orbLowColor, orbLowWidth, orbLowStyle)
        curLowLine
    else
        f_update_hline(curLowLine, orbStartBar, liveRightEdge, orbLow, orbLowColor, orbLowWidth, orbLowStyle)

    if showMidline and not na(orbMid)
        if na(curMidLine)
            curMidLine := f_new_hline(orbStartBar, liveRightEdge, orbMid, orbMidColor, orbMidWidth, orbMidStyle)
            curMidLine
        else
            f_update_hline(curMidLine, orbStartBar, liveRightEdge, orbMid, orbMidColor, orbMidWidth, orbMidStyle)
    else
        if not na(curMidLine)
            line.delete(curMidLine)
            curMidLine := na
            curMidLine

    if showExtensions and not na(orbRange) and orbRange > 0
        float up1 = orbHigh + orbRange * 1.0
        float dn1 = orbLow - orbRange * 1.0
        float up2 = orbHigh + orbRange * 2.0
        float dn2 = orbLow - orbRange * 2.0
        float up3 = orbHigh + orbRange * 3.0
        float dn3 = orbLow - orbRange * 3.0

        if numExtensions >= 1
            if na(curUp1Line)
                curUp1Line := f_new_hline(orbStartBar, liveRightEdge, up1, upExtColor, upExtWidth, upExtStyle)
                curUp1Line
            else
                f_update_hline(curUp1Line, orbStartBar, liveRightEdge, up1, upExtColor, upExtWidth, upExtStyle)
            if na(curDn1Line)
                curDn1Line := f_new_hline(orbStartBar, liveRightEdge, dn1, dnExtColor, dnExtWidth, dnExtStyle)
                curDn1Line
            else
                f_update_hline(curDn1Line, orbStartBar, liveRightEdge, dn1, dnExtColor, dnExtWidth, dnExtStyle)
        else
            if not na(curUp1Line)
                line.delete(curUp1Line)
                curUp1Line := na
                curUp1Line
            if not na(curDn1Line)
                line.delete(curDn1Line)
                curDn1Line := na
                curDn1Line

        if numExtensions >= 2
            if na(curUp2Line)
                curUp2Line := f_new_hline(orbStartBar, liveRightEdge, up2, upExtColor, upExtWidth, upExtStyle)
                curUp2Line
            else
                f_update_hline(curUp2Line, orbStartBar, liveRightEdge, up2, upExtColor, upExtWidth, upExtStyle)
            if na(curDn2Line)
                curDn2Line := f_new_hline(orbStartBar, liveRightEdge, dn2, dnExtColor, dnExtWidth, dnExtStyle)
                curDn2Line
            else
                f_update_hline(curDn2Line, orbStartBar, liveRightEdge, dn2, dnExtColor, dnExtWidth, dnExtStyle)
        else
            if not na(curUp2Line)
                line.delete(curUp2Line)
                curUp2Line := na
                curUp2Line
            if not na(curDn2Line)
                line.delete(curDn2Line)
                curDn2Line := na
                curDn2Line

        if numExtensions >= 3
            if na(curUp3Line)
                curUp3Line := f_new_hline(orbStartBar, liveRightEdge, up3, upExtColor, upExtWidth, upExtStyle)
                curUp3Line
            else
                f_update_hline(curUp3Line, orbStartBar, liveRightEdge, up3, upExtColor, upExtWidth, upExtStyle)
            if na(curDn3Line)
                curDn3Line := f_new_hline(orbStartBar, liveRightEdge, dn3, dnExtColor, dnExtWidth, dnExtStyle)
                curDn3Line
            else
                f_update_hline(curDn3Line, orbStartBar, liveRightEdge, dn3, dnExtColor, dnExtWidth, dnExtStyle)
        else
            if not na(curUp3Line)
                line.delete(curUp3Line)
                curUp3Line := na
                curUp3Line
            if not na(curDn3Line)
                line.delete(curDn3Line)
                curDn3Line := na
                curDn3Line
    else
        if not na(curUp1Line)
            line.delete(curUp1Line)
            curUp1Line := na
            curUp1Line
        if not na(curUp2Line)
            line.delete(curUp2Line)
            curUp2Line := na
            curUp2Line
        if not na(curUp3Line)
            line.delete(curUp3Line)
            curUp3Line := na
            curUp3Line
        if not na(curDn1Line)
            line.delete(curDn1Line)
            curDn1Line := na
            curDn1Line
        if not na(curDn2Line)
            line.delete(curDn2Line)
            curDn2Line := na
            curDn2Line
        if not na(curDn3Line)
            line.delete(curDn3Line)
            curDn3Line := na
            curDn3Line

    if showEERLines and not na(eerUpPx) and not na(eerDnPx)
        if na(curEerUp)
            curEerUp := f_new_hline(orbStartBar, liveRightEdge, eerUpPx, eerLineColor, eerLineWidth, eerLineStyle)
            curEerUp
        else
            f_update_hline(curEerUp, orbStartBar, liveRightEdge, eerUpPx, eerLineColor, eerLineWidth, eerLineStyle)
        if na(curEerDn)
            curEerDn := f_new_hline(orbStartBar, liveRightEdge, eerDnPx, eerLineColor, eerLineWidth, eerLineStyle)
            curEerDn
        else
            f_update_hline(curEerDn, orbStartBar, liveRightEdge, eerDnPx, eerLineColor, eerLineWidth, eerLineStyle)
    else
        if not na(curEerUp)
            line.delete(curEerUp)
            curEerUp := na
            curEerUp
        if not na(curEerDn)
            line.delete(curEerDn)
            curEerDn := na
            curEerDn

    if showOrbLabel and not na(orbRange)
        string orbTxt = 'ORB ' + str.tostring(orbRange, '#.##') + ' pts / Avg ' + str.tostring(avgOrbRange, '#.##') + ' pts'
        float labelY = orbHigh + syminfo.mintick * labelOffsetTicks * 3

        if na(curOrbInfoLabel)
            curOrbInfoLabel := label.new(orbStartBar, labelY, orbTxt, xloc = xloc.bar_index, style = label.style_label_down, textcolor = labelTxtColor, color = labelBgColor, size = labelTextSize)
            curOrbInfoLabel
        else
            label.set_xy(curOrbInfoLabel, orbStartBar, labelY)
            label.set_text(curOrbInfoLabel, orbTxt)
            label.set_textcolor(curOrbInfoLabel, labelTxtColor)
            label.set_color(curOrbInfoLabel, labelBgColor)
            label.set_size(curOrbInfoLabel, labelTextSize)
            label.set_style(curOrbInfoLabel, label.style_label_down)
    else
        if not na(curOrbInfoLabel)
            label.delete(curOrbInfoLabel)
            curOrbInfoLabel := na
            curOrbInfoLabel

//====================================================
// Archive finished session lines
//====================================================
if endSess and orbLocked and not na(orbRange) and orbRange > 0
    int finalRightEdge = freezeAtSessionEnd ? bar_index - 1 : extendAfterSession ? bar_index : bar_index - 1

    f_push_line(histLines, f_new_hline(orbStartBar, finalRightEdge, orbHigh, orbHighColor, orbHighWidth, orbHighStyle), maxSessionsDraw * 12)
    f_push_line(histLines, f_new_hline(orbStartBar, finalRightEdge, orbLow, orbLowColor, orbLowWidth, orbLowStyle), maxSessionsDraw * 12)

    if showMidline and not na(orbMid)
        f_push_line(histLines, f_new_hline(orbStartBar, finalRightEdge, orbMid, orbMidColor, orbMidWidth, orbMidStyle), maxSessionsDraw * 12)

    if showExtensions
        if numExtensions >= 1
            f_push_line(histLines, f_new_hline(orbStartBar, finalRightEdge, orbHigh + orbRange * 1.0, upExtColor, upExtWidth, upExtStyle), maxSessionsDraw * 12)
            f_push_line(histLines, f_new_hline(orbStartBar, finalRightEdge, orbLow - orbRange * 1.0, dnExtColor, dnExtWidth, dnExtStyle), maxSessionsDraw * 12)
        if numExtensions >= 2
            f_push_line(histLines, f_new_hline(orbStartBar, finalRightEdge, orbHigh + orbRange * 2.0, upExtColor, upExtWidth, upExtStyle), maxSessionsDraw * 12)
            f_push_line(histLines, f_new_hline(orbStartBar, finalRightEdge, orbLow - orbRange * 2.0, dnExtColor, dnExtWidth, dnExtStyle), maxSessionsDraw * 12)
        if numExtensions >= 3
            f_push_line(histLines, f_new_hline(orbStartBar, finalRightEdge, orbHigh + orbRange * 3.0, upExtColor, upExtWidth, upExtStyle), maxSessionsDraw * 12)
            f_push_line(histLines, f_new_hline(orbStartBar, finalRightEdge, orbLow - orbRange * 3.0, dnExtColor, dnExtWidth, dnExtStyle), maxSessionsDraw * 12)

    if showEERLines and not na(eerUpPx) and not na(eerDnPx)
        f_push_line(histLines, f_new_hline(orbStartBar, finalRightEdge, eerUpPx, eerLineColor, eerLineWidth, eerLineStyle), maxSessionsDraw * 12)
        f_push_line(histLines, f_new_hline(orbStartBar, finalRightEdge, eerDnPx, eerLineColor, eerLineWidth, eerLineStyle), maxSessionsDraw * 12)

    if showOrbLabel
        string histOrbTxt = 'ORB ' + str.tostring(orbRange, '#.##') + ' pts / Avg ' + str.tostring(avgOrbRange, '#.##') + ' pts'
        float histLabelY = orbHigh + syminfo.mintick * labelOffsetTicks * 3
        label frozenLabel = label.new(orbStartBar, histLabelY, histOrbTxt, xloc = xloc.bar_index, style = label.style_label_down, textcolor = labelTxtColor, color = labelBgColor, size = labelTextSize)
        f_push_label(histLabels, frozenLabel, maxSessionsDraw)

    if not na(curHighLine)
        line.delete(curHighLine)
        curHighLine := na
        curHighLine
    if not na(curMidLine)
        line.delete(curMidLine)
        curMidLine := na
        curMidLine
    if not na(curLowLine)
        line.delete(curLowLine)
        curLowLine := na
        curLowLine
    if not na(curUp1Line)
        line.delete(curUp1Line)
        curUp1Line := na
        curUp1Line
    if not na(curUp2Line)
        line.delete(curUp2Line)
        curUp2Line := na
        curUp2Line
    if not na(curUp3Line)
        line.delete(curUp3Line)
        curUp3Line := na
        curUp3Line
    if not na(curDn1Line)
        line.delete(curDn1Line)
        curDn1Line := na
        curDn1Line
    if not na(curDn2Line)
        line.delete(curDn2Line)
        curDn2Line := na
        curDn2Line
    if not na(curDn3Line)
        line.delete(curDn3Line)
        curDn3Line := na
        curDn3Line
    if not na(curEerUp)
        line.delete(curEerUp)
        curEerUp := na
        curEerUp
    if not na(curEerDn)
        line.delete(curEerDn)
        curEerDn := na
        curEerDn
    if not na(curOrbInfoLabel)
        label.delete(curOrbInfoLabel)
        curOrbInfoLabel := na
        curOrbInfoLabel

//====================================================
// Alerts
//====================================================
orbBreakoutUp = alertsEnabled and alertOrbBreakouts and orbLocked and barstate.isconfirmed and ta.crossover(close, orbHigh)
orbBreakoutDown = alertsEnabled and alertOrbBreakouts and orbLocked and barstate.isconfirmed and ta.crossunder(close, orbLow)
acceptedAbove = alertsEnabled and alertAcceptanceShifts and orbLocked and barstate.isconfirmed and close > orbHigh and close[1] > orbHigh and not(close[1] > orbHigh and close[2] > orbHigh)
acceptedBelow = alertsEnabled and alertAcceptanceShifts and orbLocked and barstate.isconfirmed and close < orbLow and close[1] < orbLow and not(close[1] < orbLow and close[2] < orbLow)

alertcondition(orbBreakoutUp, title = 'ORB Breakout Up', message = 'ORB Expansion Pro: confirmed close above ORB High')
alertcondition(orbBreakoutDown, title = 'ORB Breakout Down', message = 'ORB Expansion Pro: confirmed close below ORB Low')
alertcondition(acceptedAbove, title = 'Accepted Above ORB', message = 'ORB Expansion Pro: 2 confirmed closes above ORB High')
alertcondition(acceptedBelow, title = 'Accepted Below ORB', message = 'ORB Expansion Pro: 2 confirmed closes below ORB Low')
````
