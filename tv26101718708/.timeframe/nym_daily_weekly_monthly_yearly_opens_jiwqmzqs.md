# NYM Daily Weekly Monthly Yearly Opens

- url: https://www.tradingview.com/script/JiWQmZqs-NYM-Daily-Weekly-Monthly-Yearly-Opens/
- type: indicator
- pine_id: PUB;d2e91496b9d749a595dd41565babb565
- version: 3.0

## Description

Updated existing Daily Weekly Monthly Yearly Opens with True Daily Open (NYM) on 07:00 by Kyiv

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © kevinwest10
// 2026-07-22

//@version=6
indicator('NYM Daily Weekly Monthly Yearly Opens', shorttitle='NDWMY O', overlay=true)

//---------------------------- Constants ------------------------------

var DEFAULT_LINE_WIDTH = 1
var DEFAULT_TAIL_STYLE = line.style_dotted
var DEFAULT_LABEL_SIZE = size.small
var DEFAULT_LABEL_STYLE = label.style_none

//------------------------------ Inputs -------------------------------

var i_isDailyEnabled = input.bool(defval=true, title='Daily', group='Current Opens', inline='Daily')
var i_dailyColor = input.color(defval=color.green, title='', group='Current Opens', inline='Daily')
var i_isNYMEnabled = input.bool(defval=true, title='True Daily Open', group='Current Opens', inline='TDO')
var i_nymColor = input.color(defval=color.purple, title='', group='Current Opens', inline='TDO')
var i_isWeeklyEnabled = input.bool(defval=true, title='Weekly', group='Current Opens', inline='Weekly')
var i_weeklyColor = input.color(defval=color.orange, title='', group='Current Opens', inline='Weekly')
var i_isMonthlyEnabled = input.bool(defval=true, title='Monthly', group='Current Opens', inline='Monthly')
var i_monthlyColor = input.color(defval=color.red, title='', group='Current Opens', inline='Monthly')
var i_isYearlyEnabled = input.bool(defval=true, title='Yearly', group='Current Opens', inline='Yearly')
var i_yearlyColor = input.color(defval=color.blue, title='', group='Current Opens', inline='Yearly')

var i_isPDailyEnabled = input.bool(defval=true, title='Daily', group='Previous Opens', inline='Daily')
var i_pdailyColor = input.color(defval=color.green, title='', group='Previous Opens', inline='Daily')
var i_isPWeeklyEnabled = input.bool(defval=true, title='Weekly', group='Previous Opens', inline='Weekly')
var i_pweeklyColor = input.color(defval=color.orange, title='', group='Previous Opens', inline='Weekly')
var i_isPMonthlyEnabled = input.bool(defval=true, title='Monthly', group='Previous Opens', inline='Monthly')
var i_pmonthlyColor = input.color(defval=color.red, title='', group='Previous Opens', inline='Monthly')
var i_isPYearlyEnabled = input.bool(defval=true, title='Yearly', group='Previous Opens', inline='Yearly')
var i_pyearlyColor = input.color(defval=color.blue, title='', group='Previous Opens', inline='Yearly')

var i_isMondayHighEnabled = input.bool(defval=true, title='Monday High', group='Current High/Low', inline='Monday High')
var i_mondayHighColor = input.color(defval=color.lime, title='', group='Current High/Low', inline='Monday High')
var i_isMondayLowEnabled = input.bool(defval=true, title='MondayLow', group='Current High/Low', inline='Monday Low')
var i_mondayLowColor = input.color(defval=color.lime, title='', group='Current High/Low', inline='Monday Low')
var i_isDailyHEnabled = input.bool(defval=true, title='Daily High', group='Current High/Low', inline='Daily High')
var i_dailyHColor = input.color(defval=color.green, title='', group='Current High/Low', inline='Daily High')
var i_isDailyLEnabled = input.bool(defval=true, title='Daily Low', group='Current High/Low', inline='Daily Low')
var i_dailyLColor = input.color(defval=color.green, title='', group='Current High/Low', inline='Daily Low')
var i_isWeeklyHEnabled = input.bool(defval=true, title='Weekly High', group='Current High/Low', inline='Weekly High')
var i_weeklyHColor = input.color(defval=color.orange, title='', group='Current High/Low', inline='Weekly High')
var i_isWeeklyLEnabled = input.bool(defval=true, title='Weekly Low', group='Current High/Low', inline='Weekly Low')
var i_weeklyLColor = input.color(defval=color.orange, title='', group='Current High/Low', inline='Weekly Low')
var i_isMonthlyHEnabled = input.bool(defval=true, title='Monthly High', group='Current High/Low', inline='Monthly High')
var i_monthlyHColor = input.color(defval=color.red, title='', group='Current High/Low', inline='Monthly High')
var i_isMonthlyLEnabled = input.bool(defval=true, title='Monthly Low', group='Current High/Low', inline='Monthly Low')
var i_monthlyLColor = input.color(defval=color.red, title='', group='Current High/Low', inline='Monthly Low')
var i_isYearlyHEnabled = input.bool(defval=false, title='Yearly High', group='Current High/Low', inline='Yearly High')
var i_yearlyHColor = input.color(defval=color.orange, title='', group='Current High/Low', inline='Yearly High')
var i_isYearlyLEnabled = input.bool(defval=false, title='Yearly Low', group='Current High/Low', inline='Yearly Low')
var i_yearlyLColor = input.color(defval=color.orange, title='', group='Current High/Low', inline='Yearly Low')

var i_isPDailyHEnabled = input.bool(defval=false, title='Daily High', group='Previous High/Low', inline='Daily High')
var i_pdailyHColor = input.color(defval=color.green, title='', group='Previous High/Low', inline='Daily High')
var i_isPDailyLEnabled = input.bool(defval=false, title='Daily Low', group='Previous High/Low', inline='Daily Low')
var i_pdailyLColor = input.color(defval=color.green, title='', group='Previous High/Low', inline='Daily Low')
var i_isPWeeklyHEnabled = input.bool(defval=false, title='Weekly High', group='Previous High/Low', inline='Weekly High')
var i_pweeklyHColor = input.color(defval=color.orange, title='', group='Previous High/Low', inline='Weekly High')
var i_isPWeeklyLEnabled = input.bool(defval=false, title='Weekly Low', group='Previous High/Low', inline='Weekly Low')
var i_pweeklyLColor = input.color(defval=color.orange, title='', group='Previous High/Low', inline='Weekly Low')
var i_isPMonthlyHEnabled = input.bool(defval=false, title='Monthly High', group='Previous High/Low', inline='Monthly High')
var i_pmonthlyHColor = input.color(defval=color.red, title='', group='Previous High/Low', inline='Monthly High')
var i_isPMonthlyLEnabled = input.bool(defval=false, title='Monthly Low', group='Previous High/Low', inline='Monthly Low')
var i_pmonthlyLColor = input.color(defval=color.red, title='', group='Previous High/Low', inline='Monthly Low')
var i_isPYearlyHEnabled = input.bool(defval=false, title='Yearly High', group='Previous High/Low', inline='Yearly High')
var i_pyearlyHColor = input.color(defval=color.orange, title='', group='Previous High/Low', inline='Yearly High')
var i_isPYearlyLEnabled = input.bool(defval=false, title='Yearly Low', group='Previous High/Low', inline='Yearly Low')
var i_pyearlyLColor = input.color(defval=color.orange, title='', group='Previous High/Low', inline='Yearly Low')

var i_isTailsEnabled = input.bool(defval=true, title='Show Tails', group='Settings')
var i_projectionOffset = input.int(defval=20, title='Offset', group='Settings', minval=1)

var i_doStr = input.string(defval="DO", title="Daily Opening Label", group="Label Captions")
var i_nymStr = input.string(defval="TDO", title="True Daily Open Label", group="Label Captions")
var i_woStr = input.string(defval="WO", title="Weekly Opening Label", group="Label Captions")
var i_moStr = input.string(defval="MO", title="Monthly Opening Label", group="Label Captions")
var i_yoStr = input.string(defval="YO", title="Yearly Opening Label", group="Label Captions")

var i_pdoStr = input.string(defval="PDO", title="Previous Daily Opening Label", group="Label Captions")
var i_pwoStr = input.string(defval="PWO", title="Previous Weekly Opening Label", group="Label Captions")
var i_pmoStr = input.string(defval="PMO", title="Previous Monthly Opening Label", group="Label Captions")
var i_pyoStr = input.string(defval="PYO", title="Previous Yearly Opening Label", group="Label Captions")

var i_dhStr = input.string(defval="DH", title="Daily High Label", group="Label Captions")
var i_dlStr = input.string(defval="DL", title="Daily Low Label", group="Label Captions")
var i_whStr = input.string(defval="WH", title="Weekly High Label", group="Label Captions")
var i_wlStr = input.string(defval="WL", title="Weekly Low Label", group="Label Captions")
var i_mhStr = input.string(defval="MH", title="Monthly High Label", group="Label Captions")
var i_mlStr = input.string(defval="ML", title="Monthly Low Label", group="Label Captions")
var i_yhStr = input.string(defval="YH", title="Yearly High Label", group="Label Captions")
var i_ylStr = input.string(defval="YL", title="Yearly High Label", group="Label Captions")

var i_pdhStr = input.string(defval="PDH", title="Previous Daily High Label", group="Label Captions")
var i_pdlStr = input.string(defval="PDL", title="Previous Daily Low Label", group="Label Captions")
var i_pwhStr = input.string(defval="PWH", title="Previous Weekly High Label", group="Label Captions")
var i_pwlStr = input.string(defval="PWL", title="Previous Weekly Low Label", group="Label Captions")
var i_pmhStr = input.string(defval="PMH", title="Previous Monthly High Label", group="Label Captions")
var i_pmlStr = input.string(defval="PML", title="Previous Monthly Low Label", group="Label Captions")
var i_pyhStr = input.string(defval="PYH", title="Previous Yearly High Label", group="Label Captions")
var i_pylStr = input.string(defval="PYL", title="Previous Yearly Low Label", group="Label Captions")


var i_monhStr = input.string(defval="Monday High", title="Monday High Label", group="Label Captions")
var i_monlStr = input.string(defval="Monday Low", title="Monday Low Label", group="Label Captions")

//----------------------------- Securities -----------------------------

[dailyTime, dailyOpen, dailyHigh, dailyLow] = request.security(syminfo.tickerid, timeframe.isintraday ? '1440' : 'D', [time, open, high, low], lookahead=barmerge.lookahead_off)
[weeklyTime, weeklyOpen, weeklyHigh, weeklyLow] = request.security(syminfo.tickerid, 'W', [time, open, high, low], lookahead=barmerge.lookahead_off)
[monthlyTime, monthlyOpen, monthlyHigh, monthlyLow] = request.security(syminfo.tickerid, 'M', [time, open, high, low], lookahead=barmerge.lookahead_off)
[yearlyTime, yearlyOpen, yearlyHigh, yearlyLow] = request.security(syminfo.tickerid, '12M', [time, open, high, low], lookahead=barmerge.lookahead_off)

[pdailyTime, pdailyOpen, pdailyHigh, pdailyLow] = request.security(syminfo.tickerid, timeframe.isintraday ? '1440' : 'D', [time[1], open[1], high[1], low[1]], lookahead=barmerge.lookahead_off)
[pweeklyTime, pweeklyOpen, pweeklyHigh, pweeklyLow] = request.security(syminfo.tickerid, 'W', [time[1], open[1], high[1], low[1]], lookahead=barmerge.lookahead_off)
[pmonthlyTime, pmonthlyOpen, pmonthlyHigh, pmonthlyLow] = request.security(syminfo.tickerid, 'M', [time[1], open[1], high[1], low[1]], lookahead=barmerge.lookahead_off)
[pyearlyTime, pyearlyOpen, pyearlyHigh, pyearlyLow] = request.security(syminfo.tickerid, '12M', [time[1], open[1], high[1], low[1]], lookahead=barmerge.lookahead_off)

day = dayofweek(timenow)
mondayOffset= day == dayofweek.monday ? 0 : day == dayofweek.tuesday ? 1 : day == dayofweek.wednesday ? 2 : day == dayofweek.thursday ? 3 : day == dayofweek.friday ? 4 : day == dayofweek.saturday ? 5 : 6
[mondayTime, mondayLow, mondayHigh] = request.security(syminfo.tickerid, timeframe.isintraday ? '1440' : 'D', [time[mondayOffset], low[mondayOffset], high[mondayOffset]], lookahead=barmerge.lookahead_off)

//----------------------------- NY Midnight -----------------------------

var float nymOpen = na
var int nymTime = na

nyHour = hour(time, "America/New_York")
nyMinute = minute(time, "America/New_York")

isNYMidnight = nyHour == 0 and nyMinute == 0

if isNYMidnight
    nymOpen := open
    nymTime := time

//--------------------------- Function helpers -------------------------

f_drawLine(_x1, _x2, _y, _color, _width) =>
    var _line = line.new(x1=_x1, x2=_x2, y1=_y, y2=_y, color=_color, width=_width, xloc=xloc.bar_time)

    line.set_xy1(_line, _x1, _y)
    line.set_xy2(_line, _x2, _y)

f_drawLabel(_x, _y, _text, _textcolor, _style, _size) =>
    var _label = label.new(x=_x, y=_y, text=_text, textcolor=_textcolor, style=_style, size=_size, xloc=xloc.bar_time)

    label.set_xy(_label, _x, _y)

f_drawTail(_x1, _x2, _y, _color, _style, _width) =>
    var _line = line.new(x1=_x1, x2=_x2, y1=_y, y2=_y, color=_color, style=_style, width=_width, extend=extend.left, xloc=xloc.bar_time)

    line.set_xy1(_line, _x1, _y)
    line.set_xy2(_line, _x2, _y)

f_getRightOffset(_margin) =>
    _padding = 4
    _bar = math.min(time - time[1], time[1] - time[2])
    time + _bar * (i_projectionOffset + _margin * _padding)

f_drawCompleteLine(v_margin, v_open, v_time, v_color, v_str) => 
    c_rightOffset = f_getRightOffset(v_margin)

    if i_isTailsEnabled
        f_drawTail(time, c_rightOffset, v_open, v_color, DEFAULT_TAIL_STYLE, DEFAULT_LINE_WIDTH)

    f_drawLine(time, c_rightOffset, v_open, v_color, DEFAULT_LINE_WIDTH)
    f_drawLine(v_time, time, v_open, v_color, DEFAULT_LINE_WIDTH)
    f_drawLabel(c_rightOffset, v_open, v_str, v_color, DEFAULT_LABEL_STYLE, DEFAULT_LABEL_SIZE)

//------------------------------- Logic --------------------------------

var canShowDaily = timeframe.isintraday
var canShowWeekly = (timeframe.isintraday or timeframe.isdaily)
var canShowMonthly = (timeframe.isintraday or timeframe.isdaily or timeframe.isweekly)
var canShowYearly = (timeframe.isintraday or timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly and timeframe.multiplier < 12)

wo = weeklyOpen
wt = weeklyTime
mo = monthlyOpen
mt = monthlyTime
yo = yearlyOpen
yt = yearlyTime

// Markets with extended sessions (e.g. TSLA) are available for intradays charts only
// As the yearly, monthly and weekly data come respectively from the 12M, 1M, 1W timeframes, extended hours are excluded
// When user chart option "ext" is toggled on, opens' price and time don't match
// In such case, we visually want to use the extended hour open and time

var float extWeeklyOpen = na
var float extMonthlyOpen = na
var float extYearlyOpen = na
var float extWeeklyHigh = na
var float extMonthlyHigh = na
var float extYearlyHigh = na
var float extWeeklyLow = na
var float extMonthlyLow = na
var float extYearlyLow = na
var int extWeeklyTime = na
var int extMonthlyTime = na
var int extYearlyTime = na

if timeframe.isintraday and syminfo.session == session.extended
    if weekofyear != weekofyear[1]
        extWeeklyOpen := dailyOpen
        extWeeklyHigh := dailyHigh
        extWeeklyLow := dailyLow
        extWeeklyTime := dailyTime
        extWeeklyTime
    if month != month[1]
        extMonthlyOpen := dailyOpen
        extMonthlyHigh := dailyHigh
        extMonthlyLow := dailyLow
        extMonthlyTime := dailyTime
        extMonthlyTime
    if year != year[1]
        extYearlyOpen := dailyOpen
        extYearlyHigh := dailyHigh
        extYearlyLow := dailyLow
        extYearlyTime := dailyTime
        extYearlyTime

    wo := extWeeklyOpen
    wt := extWeeklyTime
    mo := extMonthlyOpen
    mt := extMonthlyTime
    yo := extYearlyOpen
    yt := extYearlyTime
    yt

// On the weekly timeframe, pinescript draws lines from the first weekly candle whose start date belongs to a given month/year
// E.g. if the first weekly candle of the month start date is the 3rd of Feb, then the monthly open line is drawn from this candle
// In such case, we visually want it to be anchored on the previous week which contains the 1st Feb

var int weeklyTimeOnYearChange = na
var int x1YearlyAnchor = na
var int weeklyTimeOnMonthChange = na
var int x1MonthlyAnchor = na

if timeframe.isweekly
    if yearlyTime != yearlyTime[1]
        weeklyTimeOnYearChange := weeklyTime
        x1YearlyAnchor := weeklyTime[1]
        x1YearlyAnchor
    if monthlyTime != monthlyTime[1]
        weeklyTimeOnMonthChange := weeklyTime
        x1MonthlyAnchor := weeklyTime[1]
        x1MonthlyAnchor

    // Theorically we would adjust the position if the weekly start date is different than the 1st
    // Which pratically result actually of the first day of the month/year considering holidays
    if dayofmonth(weeklyTimeOnYearChange) != dayofmonth(yearlyTime)
        yt := x1YearlyAnchor
        yt
    if dayofmonth(weeklyTimeOnMonthChange) != dayofmonth(monthlyTime)
        mt := x1MonthlyAnchor
        mt

//------------------------------ Plotting ------------------------------

if barstate.islast
    //
    // Yearly
    //
    if canShowYearly
        _margin = 0
        if canShowDaily and dailyOpen == yo
            _margin := 1
            _margin
        if canShowWeekly and wo == yo
            _margin += 1
            _margin
        if canShowMonthly and mo == yo
            _margin += 1
            _margin
        if i_isYearlyEnabled
            f_drawCompleteLine(_margin, yearlyOpen, yearlyTime, i_yearlyColor, i_yoStr)
        if i_isPYearlyEnabled
            f_drawCompleteLine(_margin, pyearlyOpen, pyearlyTime, i_pyearlyColor, i_pyoStr)
        if i_isYearlyHEnabled
            f_drawCompleteLine(_margin, yearlyHigh, yearlyTime, i_yearlyHColor, i_yhStr)
        if i_isPYearlyHEnabled
            f_drawCompleteLine(_margin, pyearlyHigh, pyearlyTime, i_pyearlyHColor, i_pyhStr)
        if i_isYearlyLEnabled
            f_drawCompleteLine(_margin, yearlyLow, yearlyTime, i_yearlyLColor, i_ylStr)
        if i_isPYearlyLEnabled
            f_drawCompleteLine(_margin, pyearlyLow, pyearlyTime, i_pyearlyLColor, i_pylStr)

    //
    // Monthly
    //
    if canShowMonthly
        _margin = 0
        if canShowDaily and dailyOpen == mo
            _margin := 1
            _margin
        if canShowMonthly and wo == mo
            _margin += 1
            _margin
        if i_isMonthlyEnabled
            f_drawCompleteLine(_margin, monthlyOpen, monthlyTime, i_monthlyColor, i_moStr)
        if i_isPMonthlyEnabled
            f_drawCompleteLine(_margin, pmonthlyOpen, pmonthlyTime, i_pmonthlyColor, i_pmoStr)
        if i_isMonthlyHEnabled
            f_drawCompleteLine(_margin, monthlyHigh, monthlyTime, i_monthlyHColor, i_mhStr)
        if i_isPMonthlyHEnabled
            f_drawCompleteLine(_margin, pmonthlyHigh, pmonthlyTime, i_pmonthlyHColor, i_pmhStr)
        if i_isMonthlyLEnabled
            f_drawCompleteLine(_margin, monthlyLow, monthlyTime, i_monthlyLColor, i_mlStr)
        if i_isPMonthlyLEnabled
            f_drawCompleteLine(_margin, pmonthlyLow, pmonthlyTime, i_pmonthlyLColor, i_pmlStr)

    //
    // Weekly
    //
    if canShowWeekly
        _margin = 0
        if canShowDaily and dailyOpen == wo
            _margin := 1
            _margin
        if i_isWeeklyEnabled
            f_drawCompleteLine(_margin, weeklyOpen, weeklyTime, i_weeklyColor, i_woStr)
        if i_isPWeeklyEnabled
            f_drawCompleteLine(_margin, pweeklyOpen, pweeklyTime, i_pweeklyColor, i_pwoStr)
        if i_isMondayLowEnabled
            f_drawCompleteLine(0, mondayLow, mondayTime, i_mondayLowColor, i_monlStr)
        if i_isMondayHighEnabled
            f_drawCompleteLine(0, mondayHigh, mondayTime, i_mondayHighColor, i_monhStr)
        if i_isWeeklyHEnabled
            f_drawCompleteLine(_margin, weeklyHigh, weeklyTime, i_weeklyHColor, i_whStr)
        if i_isPWeeklyHEnabled
            f_drawCompleteLine(_margin, pweeklyHigh, pweeklyTime, i_pweeklyHColor, i_pwhStr)
        if i_isWeeklyLEnabled
            f_drawCompleteLine(_margin, weeklyLow, weeklyTime, i_weeklyLColor, i_wlStr)
        if i_isPWeeklyLEnabled
            f_drawCompleteLine(_margin, pweeklyLow, pweeklyTime, i_pweeklyLColor, i_pwlStr)

    //
    // Daily
    //
    if canShowDaily
        if i_isNYMEnabled and not na(nymOpen)
            f_drawCompleteLine(0, nymOpen, nymTime, i_nymColor, i_nymStr)
        if i_isDailyEnabled
            f_drawCompleteLine(0, dailyOpen, dailyTime, i_dailyColor, i_doStr)
        if i_isPDailyEnabled
            f_drawCompleteLine(0, pdailyOpen,pdailyTime, i_pdailyColor, i_pdoStr)
        if i_isDailyHEnabled
            f_drawCompleteLine(0, dailyHigh, dailyTime, i_dailyHColor, i_dhStr)
        if i_isPDailyHEnabled
            f_drawCompleteLine(0, pdailyHigh, pdailyTime, i_pdailyHColor, i_pdhStr)
        if i_isDailyLEnabled
            f_drawCompleteLine(0, dailyLow, dailyTime, i_dailyLColor, i_dlStr)
        if i_isPDailyLEnabled
            f_drawCompleteLine(0, pdailyLow, pdailyTime, i_pdailyLColor, i_pdlStr)
````
