# MTF Midpoint Levels V1.2

- url: https://www.tradingview.com/script/G5YEdpyX-MTF-Midpoint-Levels-V1-2/
- type: indicator
- pine_id: PUB;a91dc5c49b97499195eed107477412dd
- version: 1.0

## Description

Plots midpoint levels from any user-selected timeframe by drawing the 50%  level of each candle’s high-low range as dotted horizontal lines. Built for  lower timeframes like 5m and 15m so you can project higher-timeframe midpoint  structure clearly, with adjustable lookback, left/right extension options, and  optional previous-period high/low overlays for two custom timeframes.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © sagelaiho

//@version=6
indicator("MTF Midpoint Levels V1.2", shorttitle = "MTF Mid 50%", overlay = true, max_lines_count = 500)

string grpGeneral = "General"
string grpStyle = "Style"
string grpPrev = "Previous High / Low"

string sourceTf = input.timeframe("60", "Midpoint Source Timeframe", group = grpGeneral, tooltip = "Timeframe used to calculate midpoint levels from each candle's 50% high-low range.")
int lookbackBars = input.int(30, "Lookback Source TF Candles", minval = 1, maxval = 300, group = grpGeneral, tooltip = "Number of past source-timeframe candles to draw midpoint levels for.")
color levelColor = input.color(color.new(color.rgb(120, 120, 120), 0), "Line Color", group = grpStyle)
int levelWidth = input.int(1, "Line Width", minval = 1, maxval = 3, group = grpStyle)
string extendModeInput = input.string("None", "Line Extension", options = ["None", "Left", "Right", "Both"], group = grpStyle)
bool showPrevTf1HL = input.bool(false, "Show Previous TF 1 High / Low", group = grpPrev)
string prevTf1 = input.timeframe("60", "Previous TF 1", group = grpPrev, inline = "PTF1")
color prevTf1HighColor = input.color(color.new(color.rgb(170, 95, 95), 0), "High", group = grpPrev, inline = "PTF1C")
color prevTf1LowColor = input.color(color.new(color.rgb(78, 135, 102), 0), "Low", group = grpPrev, inline = "PTF1C")
bool showPrevTf2HL = input.bool(false, "Show Previous TF 2 High / Low", group = grpPrev)
string prevTf2 = input.timeframe("D", "Previous TF 2", group = grpPrev, inline = "PTF2")
color prevTf2HighColor = input.color(color.new(color.rgb(194, 65, 106), 0), "High", group = grpPrev, inline = "PTF2C")
color prevTf2LowColor = input.color(color.new(color.rgb(47, 111, 94), 0), "Low", group = grpPrev, inline = "PTF2C")

const int MAX_STORED_BARS = 500

f_extend_mode(string value) =>
    value == "Left" ? extend.left :
     value == "Right" ? extend.right :
     value == "Both" ? extend.both :
     extend.none

var array<int> hourlyOpens = array.new_int()
var array<int> hourlyCloses = array.new_int()
var array<float> hourlyMids = array.new_float()
var array<line> drawnLines = array.new_line()
var int aggBarOpen = na
var int aggBarClose = na
var float aggBarHigh = na
var float aggBarLow = na
var line prevTf1HighLine = na
var line prevTf1LowLine = na
var line prevTf2HighLine = na
var line prevTf2LowLine = na

f_trim_storage() =>
    while array.size(hourlyOpens) > MAX_STORED_BARS
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

f_set_level_line(line id, int x1, int x2, float y, extMode, color lineColor, int lineW) =>
    if na(y) or na(x1) or na(x2)
        line lineId = na
        if not na(id)
            line.delete(id)
        lineId
    else
        line lineId = id
        if na(lineId)
            lineId := line.new(x1, y, x2, y, xloc = xloc.bar_time, extend = extMode, color = lineColor, style = line.style_dotted, width = lineW)
        else
            line.set_xy1(lineId, x1, y)
            line.set_xy2(lineId, x2, y)
            line.set_extend(lineId, extMode)
            line.set_color(lineId, lineColor)
            line.set_style(lineId, line.style_dotted)
            line.set_width(lineId, lineW)
        lineId

int chartSeconds = timeframe.in_seconds()
int sourceTfSeconds = timeframe.in_seconds(sourceTf)
int currentSourceOpenTs = time(sourceTf)
int currentSourceCloseTs = time_close(sourceTf)
float previousTf1High = request.security(syminfo.tickerid, prevTf1, high[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
float previousTf1Low = request.security(syminfo.tickerid, prevTf1, low[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
int previousTf1OpenTs = request.security(syminfo.tickerid, prevTf1, time[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
int previousTf1CloseTs = request.security(syminfo.tickerid, prevTf1, time_close[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
float previousTf2High = request.security(syminfo.tickerid, prevTf2, high[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
float previousTf2Low = request.security(syminfo.tickerid, prevTf2, low[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
int previousTf2OpenTs = request.security(syminfo.tickerid, prevTf2, time[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
int previousTf2CloseTs = request.security(syminfo.tickerid, prevTf2, time_close[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

if chartSeconds < sourceTfSeconds
    if na(aggBarOpen) or currentSourceOpenTs != aggBarOpen
        aggBarOpen := currentSourceOpenTs
        aggBarClose := currentSourceCloseTs
        aggBarHigh := high
        aggBarLow := low
    else
        aggBarClose := currentSourceCloseTs
        aggBarHigh := math.max(aggBarHigh, high)
        aggBarLow := math.min(aggBarLow, low)

    f_upsert_hour(aggBarOpen, aggBarClose, aggBarHigh, aggBarLow)
else if chartSeconds == sourceTfSeconds
    f_upsert_hour(time, time_close, high, low)
else
    array<int> subHourOpens = request.security_lower_tf(syminfo.tickerid, sourceTf, time)
    array<int> subHourCloses = request.security_lower_tf(syminfo.tickerid, sourceTf, time_close)
    array<float> subHourHighs = request.security_lower_tf(syminfo.tickerid, sourceTf, high)
    array<float> subHourLows = request.security_lower_tf(syminfo.tickerid, sourceTf, low)

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

    int available = math.min(lookbackBars, array.size(hourlyOpens))
    extendMode = f_extend_mode(extendModeInput)
    bool showHourlyMidpointsOnChart = chartSeconds <= sourceTfSeconds
    if available > 0 and showHourlyMidpointsOnChart
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

    if showPrevTf1HL
        prevTf1HighLine := f_set_level_line(prevTf1HighLine, previousTf1OpenTs, previousTf1CloseTs, previousTf1High, extendMode, prevTf1HighColor, levelWidth)
        prevTf1LowLine := f_set_level_line(prevTf1LowLine, previousTf1OpenTs, previousTf1CloseTs, previousTf1Low, extendMode, prevTf1LowColor, levelWidth)
    else
        if not na(prevTf1HighLine)
            line.delete(prevTf1HighLine)
            prevTf1HighLine := na
        if not na(prevTf1LowLine)
            line.delete(prevTf1LowLine)
            prevTf1LowLine := na

    if showPrevTf2HL
        prevTf2HighLine := f_set_level_line(prevTf2HighLine, previousTf2OpenTs, previousTf2CloseTs, previousTf2High, extendMode, prevTf2HighColor, levelWidth)
        prevTf2LowLine := f_set_level_line(prevTf2LowLine, previousTf2OpenTs, previousTf2CloseTs, previousTf2Low, extendMode, prevTf2LowColor, levelWidth)
    else
        if not na(prevTf2HighLine)
            line.delete(prevTf2HighLine)
            prevTf2HighLine := na
        if not na(prevTf2LowLine)
            line.delete(prevTf2LowLine)
            prevTf2LowLine := na
````
