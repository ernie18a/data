# NTMI Naji's Trending Market Index made by Naji EL HAJJ HASSAN

- url: https://www.tradingview.com/script/mvOvZhha-NTMI-Naji-s-Trending-Market-Index-made-by-Naji-EL-HAJJ-HASSAN/
- type: indicator
- pine_id: PUB;fd143c0c3a1e45839158d4f0d7f5f3bc
- version: 1.0

## Description

This is the functional final version, with time zones for clean market time open and close. Compares today’s price movement during a selected intraday time window against the same window from previous days.

Full Description
Relative Trending [i]Relative [/i]Index helps identify whether the market is moving normally, unusually quietly, or unusually strongly during a chosen part of the trading day.

Choose a start point such as market open or a custom time, choose an end point such as now, a fixed number of hours after the start, or a custom time, then select how many previous days to compare against. The indicator shows one percentage number:

100% = current movement is normal
Below 100% = current movement is quieter than usual
Above 100% = current movement is stronger than usual

The comparison can use median/typical range or mean/average range, with median being useful for reducing the effect of extreme news days.

## Source Code

````pine
//@version=6
indicator("Range Window Number", shorttitle="RWN", overlay=false, max_bars_back=5000)
daysBack = input.int(30, "Days back", minval=1, maxval=100)
startMode = input.string("Market open", "Start", options=["Market open", "Custom time"])
marketSession = input.session("0930-1600", "Market hours")
timeZoneMode = input.string("Exchange", "Time zone", options=["Exchange", "Etc/UTC", "Europe/Zurich", "Europe/London", "America/New_York", "America/Chicago", "Asia/Dubai", "Asia/Tokyo"])
startHour = input.int(1, "Start hour", minval=0, maxval=23, active=startMode == "Custom time")
startMinute = input.int(0, "Start minute", minval=0, maxval=59, active=startMode == "Custom time")
endMode = input.string("Now", "End", options=["Now", "Hours after start", "Custom time"])
endHours = input.float(5.0, "Hours after start", minval=0.25, step=0.25, active=endMode == "Hours after start")
endHour = input.int(9, "End hour", minval=0, maxval=23, active=endMode == "Custom time")
endMinute = input.int(0, "End minute", minval=0, maxval=59, active=endMode == "Custom time")
comparisonMethod = input.string("Median", "Comparison method", options=["Median", "Average"])
quietLevel = input.float(70.0, "Quiet below %", minval=1)
activeLevel = input.float(130.0, "Active above %", minval=1)
quietColor = input.color(color.lime, "Quiet color")
normalColor = input.color(color.blue, "Normal color")
activeColor = input.color(color.red, "Active color")
textColor = input.color(color.white, "Text color")
msHour = 60 * 60 * 1000
timeZone = timeZoneMode == "Exchange" ? syminfo.timezone : timeZoneMode
inSession = not na(time(timeframe.period, marketSession, timeZone))
sessionOpen = inSession and inSession[1] != true
customStart = timestamp(timeZone, year(time), month(time), dayofmonth(time), startHour, startMinute)
customStartBar = time >= customStart and nz(time[1], 0) < customStart
startBar = startMode == "Market open" ? sessionOpen : customStartBar
var int startIndex = na
var int startTime = na
var int endIndex = na
var int activeDay = na
var float winHigh = na
var float winLow = na
var array<int> storedDays = array.new_int()
var array<int> storedOffsets = array.new_int()
var array<float> storedValues = array.new_float()
if startBar
    startIndex := bar_index
    startTime := time
    endIndex := bar_index
    activeDay := timestamp(timeZone, year(time), month(time), dayofmonth(time), 0, 0)
    winHigh := high
    winLow := low
hasStart = not na(startIndex)
customEnd = timestamp(timeZone, year(time), month(time), dayofmonth(time), endHour, endMinute)
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
elapsedBars = hasStart ? endIndex - startIndex : na
// Store one value for every day and every elapsed-bar offset.
// This makes "Days back" work without relying on huge historical bar lookbacks.
if insideWindow and not na(activeDay) and not na(elapsedBars) and not na(currentTicks)
    array.push(storedDays, activeDay)
    array.push(storedOffsets, elapsedBars)
    array.push(storedValues, currentTicks)
    if array.size(storedValues) > 100000
        array.shift(storedDays)
        array.shift(storedOffsets)
        array.shift(storedValues)
median(array<float> values) =>
    int n = array.size(values)
    if n == 0
        na
    else
        array<float> sorted = array.copy(values)
        array.sort(sorted, order.ascending)
        int mid = int(math.floor(n / 2))
        n % 2 == 1 ? array.get(sorted, mid) : (array.get(sorted, mid - 1) + array.get(sorted, mid)) / 2.0
arrayHasDay(array<int> values, int dayValue) =>
    bool found = false
    int n = array.size(values)
    if n > 0
        for i = 0 to n - 1
            if array.get(values, i) == dayValue
                found := true
    found
array<float> previous = array.new_float()
array<int> usedDays = array.new_int()
int storedCount = array.size(storedValues)
if hasStart and storedCount > 0 and not na(elapsedBars)
    for j = 0 to storedCount - 1
        int i = storedCount - 1 - j
        int oldDay = array.get(storedDays, i)
        int oldOffset = array.get(storedOffsets, i)
        if oldDay != activeDay and oldOffset == elapsedBars and not arrayHasDay(usedDays, oldDay)
            array.push(previous, array.get(storedValues, i))
            array.push(usedDays, oldDay)
            if array.size(previous) >= daysBack
                break
comparedDays = array.size(previous)
comparisonTicks = comparedDays > 0 ? (comparisonMethod == "Average" ? array.avg(previous) : median(previous)) : na
percent = not na(comparisonTicks) and comparisonTicks != 0 ? currentTicks / comparisonTicks * 100 : na
stateColor = na(percent) ? color.gray : percent < quietLevel ? quietColor : percent > activeLevel ? activeColor : normalColor
plot(percent, "Range %", color=stateColor, linewidth=3)
hline(100, "100% normal", color=color.gray)
hline(quietLevel, "Quiet level", color=color.new(quietColor, 35), linestyle=hline.style_dashed)
hline(activeLevel, "Active level", color=color.new(activeColor, 35), linestyle=hline.style_dashed)
var table t = table.new(position.middle_center, 1, 5, border_color=color.white, border_width=2)
mainText = na(percent) ? "NO DATA" : str.tostring(percent, "#.##") + "%"
currentText = na(currentTicks) ? "Current: n/a" : "Current: " + str.tostring(currentTicks, "#.##") + " ticks"
comparisonText = na(comparisonTicks) ? "Comparison: n/a" : comparisonMethod + ": " + str.tostring(comparisonTicks, "#.##") + " ticks"
daysText = "Compared days used: " + str.tostring(comparedDays) + " / " + str.tostring(daysBack)
table.cell(t, 0, 0, mainText, text_size=size.huge, text_color=textColor, bgcolor=stateColor)
table.cell(t, 0, 1, "Range Window Number", text_color=textColor, bgcolor=color.black)
table.cell(t, 0, 2, currentText, text_color=textColor, bgcolor=color.black)
table.cell(t, 0, 3, comparisonText, text_color=textColor, bgcolor=color.black)
table.cell(t, 0, 4, daysText, text_color=textColor, bgcolor=color.black)
````
