# Naji H H Range Window Number NRWN

- url: https://www.tradingview.com/script/4wvH3WPG-Naji-H-H-Range-Window-Number-NRWN/
- type: indicator
- pine_id: PUB;b12aa83de707440e9927f954fdd358d1
- version: 1.0

## Description

Short Description
Compares today’s price movement during a selected intraday time window against the same window from previous days.

Full Description
Relative Range Window helps identify whether the market is moving normally, unusually quietly, or unusually strongly during a chosen part of the trading day.

Choose a start point such as market open or a custom time, choose an end point such as now, a fixed number of hours after the start, or a custom time, then select how many previous days to compare against. The indicator shows one percentage number:

100% = current movement is normal
Below 100% = current movement is quieter than usual
Above 100% = current movement is stronger than usual

The comparison can use median/typical range or mean/average range, with median being useful for reducing the effect of extreme news days.

## Source Code

````pine
//@version=6
indicator("Range Window Number", shorttitle="RWN", overlay=true, max_bars_back=5000)
daysBack = input.int(30, "Days back", minval=1, maxval=100)
startMode = input.string("Market open", "Start", options=["Market open", "Custom time"])
marketSession = input.session("0930-1600", "Market hours")
startHour = input.int(1, "Start hour", minval=0, maxval=23, active=startMode == "Custom time")
startMinute = input.int(0, "Start minute", minval=0, maxval=59, active=startMode == "Custom time")
endMode = input.string("Now", "End", options=["Now", "Hours after start", "Custom time"])
endHours = input.float(5.0, "Hours after start", minval=0.25, step=0.25, active=endMode == "Hours after start")
endHour = input.int(9, "End hour", minval=0, maxval=23, active=endMode == "Custom time")
endMinute = input.int(0, "End minute", minval=0, maxval=59, active=endMode == "Custom time")
averageType = input.string("Mean", "Average type", options=["Mean", "Median"])
msHour = 60 * 60 * 1000
inSession = not na(time(timeframe.period, marketSession))
sessionOpen = inSession and inSession[1] != true
customStart = timestamp(syminfo.timezone, year(time), month(time), dayofmonth(time), startHour, startMinute)
customStartBar = time >= customStart and nz(time[1], 0) < customStart
startBar = startMode == "Market open" ? sessionOpen : customStartBar
var int startIndex = na
var int startTime = na
var int endIndex = na
var float winHigh = na
var float winLow = na
var array<int> starts = array.new_int()
if startBar
    startIndex := bar_index
    startTime := time
    endIndex := bar_index
    winHigh := high
    winLow := low
    array.unshift(starts, bar_index)
    if array.size(starts) > daysBack + 2
        array.pop(starts)
hasStart = not na(startIndex)
customEnd = timestamp(syminfo.timezone, year(time), month(time), dayofmonth(time), endHour, endMinute)
customEnd := hasStart and customEnd <= startTime ? customEnd + 24 * msHour : customEnd
hoursEnd = hasStart ? startTime + int(endHours * msHour) : na
endAllowed =
     endMode == "Now" ? (startMode == "Market open" ? inSession : time < startTime + 24 * msHour) :
     endMode == "Hours after start" ? time <= hoursEnd :
     time <= customEnd
insideWindow = hasStart and bar_index >= startIndex and endAllowed
if insideWindow and not startBar
    winHigh := math.max(winHigh, high)
    winLow := math.min(winLow, low)
    endIndex := bar_index
currentTicks = hasStart ? (winHigh - winLow) / syminfo.mintick : na
windowTicks = insideWindow ? currentTicks : na
elapsedBars = hasStart ? endIndex - startIndex : na
median(array<float> values) =>
    int n = array.size(values)
    if n == 0
        na
    else
        array<float> sorted = array.copy(values)
        array.sort(sorted, order.ascending)
        int mid = int(math.floor(n / 2))
        n % 2 == 1 ? array.get(sorted, mid) : (array.get(sorted, mid - 1) + array.get(sorted, mid)) / 2.0
array<float> previous = array.new_float()
if hasStart and array.size(starts) > 1
    for i = 1 to math.min(daysBack, array.size(starts) - 1)
        int oldStart = array.get(starts, i)
        int oldEnd = oldStart + elapsedBars
        int barsBack = bar_index - oldEnd
        if barsBack >= 0 and barsBack < 5000
            float oldValue = windowTicks[barsBack]
            if not na(oldValue)
                array.push(previous, oldValue)
count = array.size(previous)
avgTicks = count > 0 ? (averageType == "Mean" ? array.avg(previous) : median(previous)) : na
percent = not na(avgTicks) and avgTicks != 0 ? currentTicks / avgTicks * 100 : na
// Hidden plot only exists because TradingView requires one script output.
plot(percent, "Hidden value", display=display.none)
var table t = table.new(position.top_right, 1, 4, border_width=1)
if barstate.islast
    table.cell(t, 0, 0, na(percent) ? "No data yet" : str.tostring(percent, "#.##") + "%", text_size=size.huge, text_color=color.white, bgcolor=na(percent) ? color.gray : percent < 70 ? color.green : percent > 130 ? color.red : color.blue)
    table.cell(t, 0, 1, na(currentTicks) ? "Current: n/a" : "Current: " + str.tostring(currentTicks, "#.##") + " ticks")
    table.cell(t, 0, 2, na(avgTicks) ? "Average: n/a" : "Average: " + str.tostring(avgTicks, "#.##") + " ticks")
    table.cell(t, 0, 3, "Compared days: " + str.tostring(count))
````
