# Hourly Midpoint Levels

- url: https://www.tradingview.com/script/RWIgWTI2-Hourly-Midpoint-Levels/
- type: indicator
- pine_id: PUB;d0dfc460352e4a4898b3d1e5c9eae3b3
- version: 1.0

## Description

Plots the 50% midpoint of past 1-hour candles as dotted horizontal levels on any chart. Designed for lower timeframes like 5m and 15m so you can see recent hourly mid-levels clearly, with adjustable lookback and optional left/right line extension.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © sagelaiho


//@version=6
indicator("Hourly Midpoint Levels", shorttitle = "H1 Mid 50%", overlay = true, max_lines_count = 500)

string grpGeneral = "General"
string grpStyle = "Style"

int lookbackHours = input.int(30, "Lookback 1H Candles", minval = 1, maxval = 300, group = grpGeneral, tooltip = "Number of past 1-hour candles to draw midpoint levels for.")
color levelColor = input.color(color.new(color.rgb(120, 120, 120), 0), "Line Color", group = grpStyle)
int levelWidth = input.int(1, "Line Width", minval = 1, maxval = 3, group = grpStyle)
string extendModeInput = input.string("None", "Line Extension", options = ["None", "Left", "Right", "Both"], group = grpStyle)

const string HOURLY_TF = "60"
const int MAX_STORED_HOURS = 500

f_extend_mode(string value) =>
    value == "Left" ? extend.left :
     value == "Right" ? extend.right :
     value == "Both" ? extend.both :
     extend.none

var array<int> hourlyOpens = array.new_int()
var array<int> hourlyCloses = array.new_int()
var array<float> hourlyMids = array.new_float()
var array<line> drawnLines = array.new_line()
var int aggHourOpen = na
var int aggHourClose = na
var float aggHourHigh = na
var float aggHourLow = na

f_trim_storage() =>
    while array.size(hourlyOpens) > MAX_STORED_HOURS
        array.shift(hourlyOpens)
        array.shift(hourlyCloses)
        array.shift(hourlyMids)

f_upsert_hour(int openTs, int closeTs, float highVal, float lowVal) =>
    if not na(openTs) and not na(closeTs) and not na(highVal) and not na(lowVal)
        float midpoint = (highVal + lowVal) * 0.5
        int sz = array.size(hourlyOpens)
        if sz == 0
            array.push(hourlyOpens, openTs)
            array.push(hourlyCloses, closeTs)
            array.push(hourlyMids, midpoint)
        else
            int lastIdx = sz - 1
            int lastOpen = array.get(hourlyOpens, lastIdx)
            if openTs == lastOpen
                array.set(hourlyCloses, lastIdx, closeTs)
                array.set(hourlyMids, lastIdx, midpoint)
            else if openTs > lastOpen
                array.push(hourlyOpens, openTs)
                array.push(hourlyCloses, closeTs)
                array.push(hourlyMids, midpoint)
        f_trim_storage()

int chartSeconds = timeframe.in_seconds()
int hourlySeconds = timeframe.in_seconds(HOURLY_TF)

if chartSeconds < hourlySeconds
    int currentHourOpen = time(HOURLY_TF)
    int currentHourClose = time_close(HOURLY_TF)

    if na(aggHourOpen) or currentHourOpen != aggHourOpen
        aggHourOpen := currentHourOpen
        aggHourClose := currentHourClose
        aggHourHigh := high
        aggHourLow := low
    else
        aggHourClose := currentHourClose
        aggHourHigh := math.max(aggHourHigh, high)
        aggHourLow := math.min(aggHourLow, low)

    f_upsert_hour(aggHourOpen, aggHourClose, aggHourHigh, aggHourLow)
else if chartSeconds == hourlySeconds
    f_upsert_hour(time, time_close, high, low)
else
    array<int> subHourOpens = request.security_lower_tf(syminfo.tickerid, HOURLY_TF, time)
    array<int> subHourCloses = request.security_lower_tf(syminfo.tickerid, HOURLY_TF, time_close)
    array<float> subHourHighs = request.security_lower_tf(syminfo.tickerid, HOURLY_TF, high)
    array<float> subHourLows = request.security_lower_tf(syminfo.tickerid, HOURLY_TF, low)

    int subCount = array.size(subHourOpens)
    if subCount > 0
        for i = 0 to subCount - 1
            f_upsert_hour(
                 array.get(subHourOpens, i),
                 array.get(subHourCloses, i),
                 array.get(subHourHighs, i),
                 array.get(subHourLows, i))

if barstate.islast
    while array.size(drawnLines) > 0
        line.delete(array.pop(drawnLines))

    int available = math.min(lookbackHours, array.size(hourlyOpens))
    extendMode = f_extend_mode(extendModeInput)
    if available > 0
        for i = 0 to available - 1
            int idx = array.size(hourlyOpens) - 1 - i
            line level = line.new(
                 array.get(hourlyOpens, idx),
                 array.get(hourlyMids, idx),
                 array.get(hourlyCloses, idx),
                 array.get(hourlyMids, idx),
                 xloc = xloc.bar_time,
                 extend = extendMode,
                 color = levelColor,
                 style = line.style_dotted,
                 width = levelWidth)
            array.push(drawnLines, level)
````
