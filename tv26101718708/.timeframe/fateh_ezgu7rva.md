# fateh 

- url: https://www.tradingview.com/script/EzgU7RVa-fateh/
- type: indicator
- pine_id: PUB;49733064163b4da5a7a9ccc9412ec884
- version: 1.0

## Description

It shows:

Today High / Low
Yesterday High / Low
Weekly High / Low
Monday Open / Weekly Open
Current Session High / Low
VWAP
Asia, London, and New York session open vertical lines

The indicator is designed for traders who want a clean chart with key levels displayed clearly near the current price area. Each level has a right-side label, customizable colors, line thickness, and individual show/hide options.

The current session high and low update live during the selected session and reset when a new session starts. Default active session is New York market hours, 09:30–16:00 New York time.

Session open markers are included for:

Asia Open
London Open
New York Open

Default times are based on New York time, but all session times can be changed manually from the settings.

VWAP is included with customizable color and thickness, using a clean dotted-style visual.

This indicator is useful for intraday trading, futures trading, scalping, support/resistance planning, liquidity level tracking, and session-based market analysis.

## Source Code

````pine
//@version=5
indicator("Babbu Market Levels", overlay=true, max_lines_count=500, max_labels_count=500)

string NY_TZ = "America/New_York"

groupGeneral = "General"
extendLinesRight = input.bool(false, "Extend Lines Far Right", group=groupGeneral, tooltip="When disabled, level lines stop at the current bar area instead of stretching across the full chart.")

groupDaily = "Daily Levels"
showTodayHigh = input.bool(true, "Show Today High", group=groupDaily)
showTodayLow = input.bool(true, "Show Today Low", group=groupDaily)
showYesterdayHigh = input.bool(true, "Show Yesterday High", group=groupDaily)
showYesterdayLow = input.bool(true, "Show Yesterday Low", group=groupDaily)
dailyColor = input.color(color.new(color.orange, 0), "Daily Color", group=groupDaily)
dailyWidth = input.int(3, "Daily Thickness", minval=1, maxval=6, group=groupDaily)

groupWeekly = "Weekly Levels"
showMondayOpen = input.bool(true, "Show Monday Open / Weekly Open", group=groupWeekly)
showWeeklyHigh = input.bool(true, "Show Weekly High", group=groupWeekly)
showWeeklyLow = input.bool(true, "Show Weekly Low", group=groupWeekly)
weeklyColor = input.color(color.new(color.aqua, 0), "Weekly Color", group=groupWeekly)
weeklyWidth = input.int(3, "Weekly Thickness", minval=1, maxval=6, group=groupWeekly)

groupSession = "Current Session Levels"
showSessionHigh = input.bool(true, "Show Current Session High", group=groupSession)
showSessionLow = input.bool(true, "Show Current Session Low", group=groupSession)
activeSession = input.session("0930-1600", "Active Session (New York)", group=groupSession)
sessionColor = input.color(color.new(color.lime, 0), "Session Color", group=groupSession)
sessionWidth = input.int(3, "Session Thickness", minval=1, maxval=6, group=groupSession)

groupVWAP = "VWAP"
showVWAP = input.bool(true, "Show VWAP", group=groupVWAP)
vwapColor = input.color(color.new(color.fuchsia, 0), "VWAP Color", group=groupVWAP)
vwapWidth = input.int(3, "VWAP Thickness", minval=1, maxval=6, group=groupVWAP)

groupVertical = "Session Open Vertical Lines"
showAsiaOpen = input.bool(true, "Show Asia Open", group=groupVertical)
asiaHour = input.int(18, "Asia Hour (NY)", minval=0, maxval=23, group=groupVertical)
asiaMinute = input.int(0, "Asia Minute (NY)", minval=0, maxval=59, group=groupVertical)
showLondonOpen = input.bool(true, "Show London Open", group=groupVertical)
londonHour = input.int(3, "London Hour (NY)", minval=0, maxval=23, group=groupVertical)
londonMinute = input.int(0, "London Minute (NY)", minval=0, maxval=59, group=groupVertical)
showNewYorkOpen = input.bool(true, "Show New York Open", group=groupVertical)
newYorkHour = input.int(9, "New York Hour (NY)", minval=0, maxval=23, group=groupVertical)
newYorkMinute = input.int(30, "New York Minute (NY)", minval=0, maxval=59, group=groupVertical)
sessionOpenLineColor = input.color(color.new(color.gray, 0), "Vertical Line Color", group=groupVertical)
sessionOpenLineWidth = input.int(2, "Vertical Line Thickness", minval=1, maxval=4, group=groupVertical)
sessionOpenLabelColor = input.color(color.new(color.white, 0), "Vertical Label Text Color", group=groupVertical)

f_manage_line(line ln, bool show, float price, int startBar, color lnColor, int lnWidth, bool extendRight) =>
    line outLine = ln
    if show and not na(price) and not na(startBar)
        if na(outLine)
            outLine := line.new(startBar, price, bar_index, price, xloc=xloc.bar_index, extend=extendRight ? extend.right : extend.none, color=lnColor, width=lnWidth)
        else
            line.set_xy1(outLine, startBar, price)
            line.set_xy2(outLine, bar_index, price)
            line.set_extend(outLine, extendRight ? extend.right : extend.none)
            line.set_color(outLine, lnColor)
            line.set_width(outLine, lnWidth)
    else if not na(outLine)
        line.delete(outLine)
        outLine := na
    outLine

f_text_color(color bgColor) =>
    color.r(bgColor) * 0.299 + color.g(bgColor) * 0.587 + color.b(bgColor) * 0.114 > 186 ? color.black : color.white

f_manage_label(label lb, bool show, float price, color bgColor, string txt) =>
    label outLabel = lb
    if show and not na(price)
        int labelX = bar_index + 1
        color txtColor = f_text_color(bgColor)
        if na(outLabel)
            outLabel := label.new(labelX, price, txt, xloc=xloc.bar_index, style=label.style_label_left, textcolor=txtColor, color=bgColor, size=size.normal)
        else
            label.set_xy(outLabel, labelX, price)
            label.set_text(outLabel, txt)
            label.set_textcolor(outLabel, txtColor)
            label.set_color(outLabel, bgColor)
            label.set_style(outLabel, label.style_label_left)
            label.set_size(outLabel, size.normal)
    else if not na(outLabel)
        label.delete(outLabel)
        outLabel := na
    outLabel

f_session_trigger(int h, int m) =>
    int y = year(time, NY_TZ)
    int mo = month(time, NY_TZ)
    int d = dayofmonth(time, NY_TZ)
    int triggerTs = timestamp(NY_TZ, y, mo, d, h, m)
    time >= triggerTs and nz(time[1], time - 1) < triggerTs

f_draw_vertical_open(bool show, bool trigger, string txt, color lineColor, int lineWidth, color txtColor) =>
    if show and trigger
        float span = math.max(nz(ta.atr(14), 0.0), high - low)
        float y1 = low - span * 4.0
        float y2 = high + span * 4.0
        line.new(bar_index, y1, bar_index, y2, xloc=xloc.bar_index, extend=extend.none, color=lineColor, width=lineWidth)
        label.new(bar_index, y2, txt, xloc=xloc.bar_index, style=label.style_label_down, textcolor=f_text_color(lineColor), color=lineColor, size=size.normal)

todayHigh = request.security(syminfo.tickerid, "D", high)
todayLow = request.security(syminfo.tickerid, "D", low)
yesterdayHigh = request.security(syminfo.tickerid, "D", high[1])
yesterdayLow = request.security(syminfo.tickerid, "D", low[1])
weeklyOpen = request.security(syminfo.tickerid, "W", open)
weeklyHigh = request.security(syminfo.tickerid, "W", high)
weeklyLow = request.security(syminfo.tickerid, "W", low)
vwapValue = ta.vwap(hlc3)

newDay = ta.change(time("D")) != 0
newWeek = ta.change(time("W")) != 0

var int todayStartBar = bar_index
var int yesterdayStartBar = na
var int weekStartBar = bar_index

if barstate.isfirst
    todayStartBar := bar_index
    weekStartBar := bar_index

if newDay
    yesterdayStartBar := todayStartBar
    todayStartBar := bar_index

if newWeek
    weekStartBar := bar_index

inActiveSession = not na(time(timeframe.period, activeSession, NY_TZ))
prevInActiveSession = bar_index > 0 ? inActiveSession[1] : false
sessionJustStarted = inActiveSession and not prevInActiveSession

var float currentSessionHigh = na
var float currentSessionLow = na
var int currentSessionStartBar = na

if sessionJustStarted
    currentSessionHigh := high
    currentSessionLow := low
    currentSessionStartBar := bar_index
else if inActiveSession
    currentSessionHigh := na(currentSessionHigh) ? high : math.max(currentSessionHigh, high)
    currentSessionLow := na(currentSessionLow) ? low : math.min(currentSessionLow, low)

var line lnTodayHigh = na
var label lbTodayHigh = na
var line lnTodayLow = na
var label lbTodayLow = na
var line lnYesterdayHigh = na
var label lbYesterdayHigh = na
var line lnYesterdayLow = na
var label lbYesterdayLow = na
var line lnWeeklyOpen = na
var label lbWeeklyOpen = na
var line lnWeeklyHigh = na
var label lbWeeklyHigh = na
var line lnWeeklyLow = na
var label lbWeeklyLow = na
var line lnSessionHigh = na
var label lbSessionHigh = na
var line lnSessionLow = na
var label lbSessionLow = na
var label lbVWAP = na

bool drawTodayHigh = showTodayHigh
bool drawTodayLow = showTodayLow
bool drawYesterdayHigh = showYesterdayHigh and not na(yesterdayStartBar)
bool drawYesterdayLow = showYesterdayLow and not na(yesterdayStartBar)
bool drawWeeklyOpen = showMondayOpen
bool drawWeeklyHigh = showWeeklyHigh
bool drawWeeklyLow = showWeeklyLow
bool drawSessionHigh = showSessionHigh and not na(currentSessionHigh) and not na(currentSessionStartBar)
bool drawSessionLow = showSessionLow and not na(currentSessionLow) and not na(currentSessionStartBar)

lnTodayHigh := f_manage_line(lnTodayHigh, drawTodayHigh, todayHigh, todayStartBar, dailyColor, dailyWidth, extendLinesRight)
lbTodayHigh := f_manage_label(lbTodayHigh, drawTodayHigh, todayHigh, dailyColor, "Today High")

lnTodayLow := f_manage_line(lnTodayLow, drawTodayLow, todayLow, todayStartBar, dailyColor, dailyWidth, extendLinesRight)
lbTodayLow := f_manage_label(lbTodayLow, drawTodayLow, todayLow, dailyColor, "Today Low")

lnYesterdayHigh := f_manage_line(lnYesterdayHigh, drawYesterdayHigh, yesterdayHigh, yesterdayStartBar, dailyColor, dailyWidth, extendLinesRight)
lbYesterdayHigh := f_manage_label(lbYesterdayHigh, drawYesterdayHigh, yesterdayHigh, dailyColor, "Yesterday High")

lnYesterdayLow := f_manage_line(lnYesterdayLow, drawYesterdayLow, yesterdayLow, yesterdayStartBar, dailyColor, dailyWidth, extendLinesRight)
lbYesterdayLow := f_manage_label(lbYesterdayLow, drawYesterdayLow, yesterdayLow, dailyColor, "Yesterday Low")

lnWeeklyOpen := f_manage_line(lnWeeklyOpen, drawWeeklyOpen, weeklyOpen, weekStartBar, weeklyColor, weeklyWidth, extendLinesRight)
lbWeeklyOpen := f_manage_label(lbWeeklyOpen, drawWeeklyOpen, weeklyOpen, weeklyColor, "Monday Open")

lnWeeklyHigh := f_manage_line(lnWeeklyHigh, drawWeeklyHigh, weeklyHigh, weekStartBar, weeklyColor, weeklyWidth, extendLinesRight)
lbWeeklyHigh := f_manage_label(lbWeeklyHigh, drawWeeklyHigh, weeklyHigh, weeklyColor, "Weekly High")

lnWeeklyLow := f_manage_line(lnWeeklyLow, drawWeeklyLow, weeklyLow, weekStartBar, weeklyColor, weeklyWidth, extendLinesRight)
lbWeeklyLow := f_manage_label(lbWeeklyLow, drawWeeklyLow, weeklyLow, weeklyColor, "Weekly Low")

lnSessionHigh := f_manage_line(lnSessionHigh, drawSessionHigh, currentSessionHigh, currentSessionStartBar, sessionColor, sessionWidth, extendLinesRight)
lbSessionHigh := f_manage_label(lbSessionHigh, drawSessionHigh, currentSessionHigh, sessionColor, "Current Session High")

lnSessionLow := f_manage_line(lnSessionLow, drawSessionLow, currentSessionLow, currentSessionStartBar, sessionColor, sessionWidth, extendLinesRight)
lbSessionLow := f_manage_label(lbSessionLow, drawSessionLow, currentSessionLow, sessionColor, "Current Session Low")

plot(showVWAP ? vwapValue : na, title="VWAP", color=vwapColor, linewidth=math.min(vwapWidth, 4), style=plot.style_circles)

if showVWAP and not na(vwapValue)
    int vwapLabelX = bar_index + 1
    if na(lbVWAP)
        lbVWAP := label.new(vwapLabelX, vwapValue, "VWAP", xloc=xloc.bar_index, style=label.style_label_left, textcolor=f_text_color(vwapColor), color=vwapColor, size=size.normal)
    else
        label.set_xy(lbVWAP, vwapLabelX, vwapValue)
        label.set_text(lbVWAP, "VWAP")
        label.set_textcolor(lbVWAP, f_text_color(vwapColor))
        label.set_color(lbVWAP, vwapColor)
        label.set_style(lbVWAP, label.style_label_left)
        label.set_size(lbVWAP, size.normal)
else
    if not na(lbVWAP)
        label.delete(lbVWAP)
        lbVWAP := na

asiaTrigger = f_session_trigger(asiaHour, asiaMinute)
londonTrigger = f_session_trigger(londonHour, londonMinute)
newYorkTrigger = f_session_trigger(newYorkHour, newYorkMinute)

f_draw_vertical_open(showAsiaOpen, asiaTrigger, "Asia Open", sessionOpenLineColor, sessionOpenLineWidth, sessionOpenLabelColor)
f_draw_vertical_open(showLondonOpen, londonTrigger, "London Open", sessionOpenLineColor, sessionOpenLineWidth, sessionOpenLabelColor)
f_draw_vertical_open(showNewYorkOpen, newYorkTrigger, "New York Open", sessionOpenLineColor, sessionOpenLineWidth, sessionOpenLabelColor)
````
