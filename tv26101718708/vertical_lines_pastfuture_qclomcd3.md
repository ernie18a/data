# Vertical Lines Past+Future

- url: https://www.tradingview.com/script/QClOMCD3-Vertical-Lines-Past-Future/
- type: indicator
- pine_id: PUB;1f3e7e44e10c424db71d235eadb84b0c
- version: 2.0

## Description

This indicator plots up to 5 vertical lines at specific times, both on previous days AND the upcoming instances of the current day. 

Change times, colors, style and width.
With time zone support.

The indicator fetches the midnight UNIX timestamp and adds the duration till the specified times from midnight to get the x-values for the positioning of upcoming lines.

One limitation is that when a chart is set to RTH the indicator will only start to plot the upcoming lines when the session has started.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CantThinkofOne

//@version=6
indicator("Vertical Lines Past+Future", "V_Lines", overlay = true, scale = scale.none, max_lines_count = 500)

// Timezone
timezoneInput = input.string("UTC-4:00", "Time zone", tooltip = "See bottom right for UTC offset or location e.g., America/New_York.")

ShowLine1 = input.bool(true, title="", inline= "1", group="Vertical Lines")
Time_HH1 = input.int(7, "Hour", minval=0, maxval=23, inline= "1", group="Vertical Lines")
Time_mm1 = input.int(00, "Minute", minval=0, maxval=59, inline="1", group="Vertical Lines")
Color1 = input.color(#272C3B, "Color", inline="1", group="Vertical Lines")

ShowLine2 = input.bool(true, title="", inline="2", group="Vertical Lines")
Time_HH2 = input.int(8, "Hour", minval=0, maxval=23, inline="2", group="Vertical Lines")
Time_mm2 = input.int(00, "Minute", minval=0, maxval=59, inline="2", group="Vertical Lines")
Color2 = input.color(#272C3B, "Color", inline="2", group="Vertical Lines")

ShowLine3 = input.bool(true, title="", inline="3", group="Vertical Lines")
Time_HH3 = input.int(9, "Hour", minval=0, maxval=23, inline="3", group="Vertical Lines")
Time_mm3 = input.int(30, "Minute", minval=0, maxval=59, inline="3", group="Vertical Lines")
Color3 = input.color(#272C3B, "Color", inline="3", group="Vertical Lines")

ShowLine4 = input.bool(false, title="", inline="4", group="Vertical Lines")
Time_HH4 = input.int(16, "Hour", minval=0, maxval=23, inline="4", group="Vertical Lines")
Time_mm4 = input.int(00, "Minute", minval=0, maxval=59, inline="4", group="Vertical Lines")
Color4 = input.color(#272C3B, "Color", inline="4", group="Vertical Lines")

ShowLine5 = input.bool(false, title="", inline="5", group="Vertical Lines")
Time_HH5 = input.int(16, "Hour", minval=0, maxval=23, inline="5", group="Vertical Lines")
Time_mm5 = input.int(30, "Minute", minval=0, maxval=59, inline="5", group="Vertical Lines")
Color5 = input.color(#272C3B, "Color", inline="5", group="Vertical Lines")


InputStyle =  input.string("Solid", "Line Style", options = ["Solid", "Dashed", "Dotted"], inline="6", group="Vertical Lines")
lineStyle = switch InputStyle
    "Solid"  => line.style_solid
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted
 //   => line.style_solid

LineWidth = input.int(1, "Line Width", options = [1,2,3,4,5], inline="6", group="Vertical Lines")

InputFutureLines = input.bool(true, "Show Future Lines", group="Vertical Lines")

// ───── Culculations ─────
// Previous Lines
barHour = hour(time, timezoneInput)
barMinute = minute(time, timezoneInput)

// Conditions
PreviousLines1 = ShowLine1 and barHour == Time_HH1 and barMinute == Time_mm1
PreviousLines2 = ShowLine2 and barHour == Time_HH2 and barMinute == Time_mm2
PreviousLines3 = ShowLine3 and barHour == Time_HH3 and barMinute == Time_mm3
PreviousLines4 = ShowLine4 and barHour == Time_HH4 and barMinute == Time_mm4
PreviousLines5 = ShowLine5 and barHour == Time_HH5 and barMinute == Time_mm5

// Current Day Lines
// Get the midnight timestamp of the current real-world day (using timenow)
int currentYear  = year(time, timezoneInput)
int currentMonth = month(time, timezoneInput)
int currentDay   = dayofmonth(time, timezoneInput)

// Construct the midnight timestamp (ms)
int UNIXmidnight = timestamp(timezoneInput, currentYear, currentMonth, currentDay, 0, 0, 0)

// Assign the number of milliseconds in hourly and minute units to "const" variables for calculations.
const int ONE_HOUR   =   3600000
const int ONE_MINUTE =     60000

UNIXperiod1  = (Time_HH1 * ONE_HOUR) + (Time_mm1 * ONE_MINUTE)
UNIXperiod2  = Time_HH2 * ONE_HOUR + Time_mm2 * ONE_MINUTE
UNIXperiod3  = Time_HH3 * ONE_HOUR + Time_mm3 * ONE_MINUTE
UNIXperiod4  = Time_HH4 * ONE_HOUR + Time_mm4 * ONE_MINUTE
UNIXperiod5  = Time_HH5 * ONE_HOUR + Time_mm5 * ONE_MINUTE

CurrentDayLine1 = UNIXmidnight + UNIXperiod1
CurrentDayLine2 = UNIXmidnight + UNIXperiod2
CurrentDayLine3 = UNIXmidnight + UNIXperiod3
CurrentDayLine4 = UNIXmidnight + UNIXperiod4
CurrentDayLine5 = UNIXmidnight + UNIXperiod5

// Conditions
ShowFutureLine1 = ShowLine1 and InputFutureLines and barstate.islast
ShowFutureLine2 = ShowLine2 and InputFutureLines and barstate.islast
ShowFutureLine3 = ShowLine3 and InputFutureLines and barstate.islast
ShowFutureLine4 = ShowLine4 and InputFutureLines and barstate.islast
ShowFutureLine5 = ShowLine5 and InputFutureLines and barstate.islast

// Previous Days
if PreviousLines1
    line.new(bar_index, low, bar_index, high, xloc = xloc.bar_index, extend = extend.both, color = Color1, style = lineStyle, width = LineWidth)

if PreviousLines2
    line.new(bar_index, low, bar_index, high, xloc = xloc.bar_index, extend = extend.both, color = Color2, style = lineStyle, width = LineWidth)

if PreviousLines3
    line.new(bar_index, low, bar_index, high, xloc = xloc.bar_index, extend = extend.both, color = Color3, style = lineStyle, width = LineWidth)

if PreviousLines4
    line.new(bar_index, low, bar_index, high, xloc = xloc.bar_index, extend = extend.both, color = Color4, style = lineStyle, width = LineWidth)

if PreviousLines5
    line.new(bar_index, low, bar_index, high, xloc = xloc.bar_index, extend = extend.both, color = Color5, style = lineStyle, width = LineWidth)

// Current Day
if ShowFutureLine1
    line.new(CurrentDayLine1, low, CurrentDayLine1, high, xloc = xloc.bar_time, extend = extend.both, color = Color1, style = lineStyle, width = LineWidth)

if ShowFutureLine2
    line.new(CurrentDayLine2, low, CurrentDayLine2, high, xloc = xloc.bar_time, extend = extend.both, color = Color2, style = lineStyle, width = LineWidth)

if ShowFutureLine3
    line.new(CurrentDayLine3, low, CurrentDayLine3, high, xloc = xloc.bar_time, extend = extend.both, color = Color3, style = lineStyle, width = LineWidth)

if ShowFutureLine4
    line.new(CurrentDayLine4, low, CurrentDayLine4, high, xloc = xloc.bar_time, extend = extend.both, color = Color4, style = lineStyle, width = LineWidth)

if ShowFutureLine5
    line.new(CurrentDayLine5, low, CurrentDayLine5, high, xloc = xloc.bar_time, extend = extend.both, color = Color5, style = lineStyle, width = LineWidth)
````
