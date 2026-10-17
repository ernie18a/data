# Session Opening Range Suite

- url: https://www.tradingview.com/script/aGbNVhUe-Session-Opening-Range-Suite/
- type: indicator
- pine_id: PUB;d0841709efb1427d96137714a60d6a30
- version: 1.0

## Description

The Session Opening Range Suite measures and tracks the opening 30-minute range for the three major futures trading sessions:

[list]
[*]Asia: 8:00 PM – 8:30 PM EST
[*]London: 3:00 AM – 3:30 AM EST
[*]New York: 9:30 AM – 10:00 AM EST
[/list]

For each session, the dashboard displays:

[list]
[*]Session Status (Waiting, Measuring, Complete)
[*]Opening Range in both Points and Ticks
[*]Historical Average opening range (Points / Ticks)
[*]Percentage of today's range relative to the historical average
[*]Volatility Classification (Low, Normal, High)
[/list]

During the active 30-minute opening range, the dashboard updates live with the current range. Once the session is complete, the percentage and volatility classification are calculated using the finalized opening range.

Additional features include:

[list]
[*]Automatic reset at 6:00 PM EST each trading day
[*]Customizable dashboard colors
[*]Adjustable historical average lookback period
[*]User-defined volatility thresholds
[/list]

Designed for traders who monitor session volatility and compare today's opening range against historical conditions to better understand market context.

## Source Code

````pine
//@version=6
indicator("Session Opening Range Suite", overlay=true)

tz = input.string("America/New_York", "Timezone")

grpSess = "Session Windows"
asiaWindow   = input.session("2000-2030", "Asia Range", group=grpSess)
londonWindow = input.session("0300-0330", "London Range", group=grpSess)
nyWindow     = input.session("0930-1000", "New York Range", group=grpSess)

grpAvg = "Average Settings"
avgLength = input.int(20, "Number of Days", minval=1, group=grpAvg)

grpLogic = "Volatility Thresholds"
lowThreshold  = input.int(80, "Low Volatility (%)", group=grpLogic)
highThreshold = input.int(120, "High Volatility (%)", group=grpLogic)

grpTable = "Table Settings"
headerBgColor   = input.color(color.rgb(35, 35, 35), "Header Background", group=grpTable)
headerTextColor = input.color(color.white, "Header Text", group=grpTable)
tableBgColor    = input.color(color.new(color.black, 85), "Cell Background", group=grpTable)
textColor       = input.color(color.white, "Default Text", group=grpTable)

inSess(sess) =>
    not na(time(timeframe.period, sess, tz))

resetNow = inSess("1800-1801") and not inSess("1800-1801")[1]

calcRange(sess, arr, resetSignal) =>
    active = inSess(sess)
    start = active and not active[1]
    finish = not active and active[1]

    var float hi = na
    var float lo = na
    var float finalRange = na
    var string status = "Waiting"
    var bool complete = false

    if resetSignal
        hi := na
        lo := na
        finalRange := na
        status := "Waiting"
        complete := false

    if start
        hi := high
        lo := low
        finalRange := high - low
        status := "Measuring"
        complete := false

    if active
        hi := math.max(hi, high)
        lo := math.min(lo, low)
        finalRange := hi - lo
        status := "Measuring"
        complete := false

    if finish
        finalRange := hi - lo
        array.push(arr, finalRange)
        if array.size(arr) > avgLength
            array.shift(arr)
        status := "Complete"
        complete := true

    avg = array.size(arr) > 0 ? array.avg(arr) : na
    pct = complete and not na(avg) and avg != 0 and not na(finalRange) ? finalRange / avg * 100 : na

    [finalRange, status, avg, pct, complete]

toPtsTicks(x) =>
    na(x) ? "—" : str.tostring(math.round(x)) + " / " + str.tostring(math.round(x / syminfo.mintick))

toPct(x) =>
    na(x) ? "—" : str.tostring(math.round(x)) + "%"

sizeRead(pct, complete) =>
    not complete or na(pct) ? "—" :
     pct < lowThreshold ? "Low" :
     pct > highThreshold ? "High" :
     "Normal"

var array<float> asiaArr = array.new<float>()
var array<float> londonArr = array.new<float>()
var array<float> nyArr = array.new<float>()

[asiaRange, asiaStatus, asiaAvg, asiaPct, asiaComplete] = calcRange(asiaWindow, asiaArr, resetNow)
[londonRange, londonStatus, londonAvg, londonPct, londonComplete] = calcRange(londonWindow, londonArr, resetNow)
[nyRange, nyStatus, nyAvg, nyPct, nyComplete] = calcRange(nyWindow, nyArr, resetNow)

var table dash = table.new(position.top_right, 6, 4, border_width=1)

if barstate.islast
    table.cell(dash, 0, 0, "Session", text_color=headerTextColor, bgcolor=headerBgColor)
    table.cell(dash, 1, 0, "Status", text_color=headerTextColor, bgcolor=headerBgColor)
    table.cell(dash, 2, 0, "Points / Ticks", text_color=headerTextColor, bgcolor=headerBgColor)
    table.cell(dash, 3, 0, "Average", text_color=headerTextColor, bgcolor=headerBgColor)
    table.cell(dash, 4, 0, "Percentage", text_color=headerTextColor, bgcolor=headerBgColor)
    table.cell(dash, 5, 0, "Size", text_color=headerTextColor, bgcolor=headerBgColor)

    table.cell(dash, 0, 1, "Asia", text_color=textColor, bgcolor=tableBgColor)
    table.cell(dash, 1, 1, asiaStatus, text_color=textColor, bgcolor=tableBgColor)
    table.cell(dash, 2, 1, toPtsTicks(asiaRange), text_color=textColor, bgcolor=tableBgColor)
    table.cell(dash, 3, 1, toPtsTicks(asiaAvg), text_color=textColor, bgcolor=tableBgColor)
    table.cell(dash, 4, 1, toPct(asiaPct), text_color=textColor, bgcolor=tableBgColor)
    table.cell(dash, 5, 1, sizeRead(asiaPct, asiaComplete), text_color=textColor, bgcolor=tableBgColor)

    table.cell(dash, 0, 2, "London", text_color=textColor, bgcolor=tableBgColor)
    table.cell(dash, 1, 2, londonStatus, text_color=textColor, bgcolor=tableBgColor)
    table.cell(dash, 2, 2, toPtsTicks(londonRange), text_color=textColor, bgcolor=tableBgColor)
    table.cell(dash, 3, 2, toPtsTicks(londonAvg), text_color=textColor, bgcolor=tableBgColor)
    table.cell(dash, 4, 2, toPct(londonPct), text_color=textColor, bgcolor=tableBgColor)
    table.cell(dash, 5, 2, sizeRead(londonPct, londonComplete), text_color=textColor, bgcolor=tableBgColor)

    table.cell(dash, 0, 3, "New York", text_color=textColor, bgcolor=tableBgColor)
    table.cell(dash, 1, 3, nyStatus, text_color=textColor, bgcolor=tableBgColor)
    table.cell(dash, 2, 3, toPtsTicks(nyRange), text_color=textColor, bgcolor=tableBgColor)
    table.cell(dash, 3, 3, toPtsTicks(nyAvg), text_color=textColor, bgcolor=tableBgColor)
    table.cell(dash, 4, 3, toPct(nyPct), text_color=textColor, bgcolor=tableBgColor)
    table.cell(dash, 5, 3, sizeRead(nyPct, nyComplete), text_color=textColor, bgcolor=tableBgColor)
````
