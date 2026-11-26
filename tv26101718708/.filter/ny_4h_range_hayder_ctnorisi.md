# NY 4H Range - Hayder

- url: https://www.tradingview.com/script/cTNOrisI-NY-4H-Range-Hayder/
- type: indicator
- pine_id: PUB;8efb51e005554efc9198f5df0162f368
- version: 1.0

## Description

[b]NY First 4H Candle Range[/b]
[b]Overview[/b]

This indicator marks the high and low of the first 4-hour candle of the New York trading day and projects that range across the remainder of the session as a reference zone.

[b]What makes it different[/b]

Most session-range scripts read the 4H candle directly with `request.security()`, which breaks or misaligns when the chart timeframe is 4H or higher, and which depends on the data feed's own session alignment. This script instead reconstructs the range from lower-timeframe data, so the same values are produced regardless of the chart's timeframe.

[b]Method[/b]

1. [b]Trading day anchor at 17:00 New York[/b]. The script defines the trading day as starting at 17:00 America/New_York, not at midnight. This follows the standard forex/futures rollover rather than the calendar day. The first 4-hour candle therefore spans 17:00 to 21:00 New York time.

2. [b]DST handling without fixed offsets[/b]. The `f_tradeDayStart()` function derives the day boundary by decomposing the current bar's timestamp into New York year/month/day/hour components, deciding whether the bar belongs to the current or previous trading day based on whether the New York hour is at or past 17:00, and rebuilding the anchor with `timestamp()` in the New York timezone. Because the timestamp is rebuilt from calendar components rather than by subtracting a constant offset, daylight saving transitions are handled automatically.

3.[b] Lower-timeframe reconstruction.[/b] Rather than requesting the 4H candle, the script pulls arrays of time, time_close, high, and low from a configurable internal timeframe (default 15m) using `request.security_lower_tf()`. It then iterates those intrabar values and accumulates the running high and low of every bar whose open time is at or after the trading day anchor and whose close time falls at or before the anchor plus four hours. This means the range is computed from actual price data inside the window rather than from a pre-aggregated candle, and it remains correct on 4H and higher charts where a standard security call would fail.

4. [b]Single confirmed draw, no repaint[/b]. The box and boundary lines are created only once the chart's own bar close has passed the end of the 4H window, and a state flag prevents any redraw for that trading day. Nothing is plotted while the window is still forming, and the levels never shift after they appear.

5. [b]Projection[/b]. The range is drawn from the trading day anchor forward to anchor plus 24 hours, covering the full trading day. Each new trading day resets the accumulators and draws a fresh range.

[b]Inputs[/b]

- [b]Internal Calculation Timeframe[/b] (default 15m): the resolution used to reconstruct the 4H window. Lower values give a more precise range at the cost of more data; must be lower than the chart timeframe.

[b]How to use it
[/b]
The 17:00–21:00 New York window covers the futures reopen and the early Asian handoff, a period that frequently establishes the initial liquidity boundaries traders reference through the rest of the day. Watch for acceptance outside the boundary, rejection back inside, or consolidation within it. The script does not interpret this behavior for you.

[b]Limitations[/b]

- Does not generate buy or sell signals, entries, exits, or alerts.
- The internal calculation timeframe must be lower than the chart timeframe; `request.security_lower_tf()` returns no data otherwise.
- Nothing is drawn until the chart's bar close passes 21:00 New York for that trading day.
- Intrabar data availability is limited by your TradingView plan's historical intrabar depth, which caps how far back ranges are drawn.
- Symbols with gaps or missing data inside the 17:00–21:00 window will produce a range built from whatever bars exist.
- A visual reference only, to be used as one component of a complete trading plan.

## Source Code

````pine
//@version=6
indicator("NY 4H Range - Hayder", overlay=true, max_boxes_count=500, max_lines_count=500)

//====================
// Settings
//====================
string TZ = "America/New_York"

calcTF = input.timeframe("15", "Internal Calculation Timeframe")

int MS_HOUR = 60 * 60 * 1000
int MS_DAY  = 24 * MS_HOUR

color RANGE_FILL = color.new(#a2a5b1, 88)
color RANGE_LINE = color.rgb(220, 223, 232)
int   LINE_WIDTH  = 1

//====================
// Lower timeframe data
//====================
array<int>   ltfTime      = request.security_lower_tf(syminfo.tickerid, calcTF, time)
array<int>   ltfTimeClose = request.security_lower_tf(syminfo.tickerid, calcTF, time_close)
array<float> ltfHigh      = request.security_lower_tf(syminfo.tickerid, calcTF, high)
array<float> ltfLow       = request.security_lower_tf(syminfo.tickerid, calcTF, low)

//====================
// Function: get NY trading day start
// Trading day starts at 17:00 New York
//====================
f_tradeDayStart(int t) =>
    int y = year(t, TZ)
    int m = month(t, TZ)
    int d = dayofmonth(t, TZ)
    int h = hour(t, TZ)

    int noonNY = timestamp(TZ, y, m, d, 12, 0)
    int prevNoonNY = noonNY - MS_DAY

    int startY = h >= 17 ? y : year(prevNoonNY, TZ)
    int startM = h >= 17 ? m : month(prevNoonNY, TZ)
    int startD = h >= 17 ? d : dayofmonth(prevNoonNY, TZ)

    timestamp(TZ, startY, startM, startD, 17, 0)

//====================
// Variables
//====================
var int   activeTradeDayStart = na
var int   activeTradeDayEnd   = na
var int   activeFirst4HEnd    = na

var float first4HHigh = na
var float first4HLow  = na

var bool hasFirst4HData = false
var bool rangeDrawn     = false

var box  rangeBox   = na
var line topLine    = na
var line bottomLine = na

//====================
// Process lower timeframe bars
//====================
int n = array.size(ltfTime)

if n > 0
    for i = 0 to n - 1
        int   t  = array.get(ltfTime, i)
        int   tc = array.get(ltfTimeClose, i)
        float h  = array.get(ltfHigh, i)
        float l  = array.get(ltfLow, i)

        int tdStart = f_tradeDayStart(t)
        int tdEnd   = tdStart + MS_DAY
        int f4End   = tdStart + 4 * MS_HOUR

        bool newDay = na(activeTradeDayStart) or tdStart != activeTradeDayStart

        if newDay
            activeTradeDayStart := tdStart
            activeTradeDayEnd   := tdEnd
            activeFirst4HEnd    := f4End

            first4HHigh := na
            first4HLow  := na

            hasFirst4HData := false
            rangeDrawn     := false

        bool barInsideFirst4H = t >= activeTradeDayStart and tc <= activeFirst4HEnd

        if barInsideFirst4H and not rangeDrawn
            first4HHigh := na(first4HHigh) ? h : math.max(first4HHigh, h)
            first4HLow  := na(first4HLow)  ? l : math.min(first4HLow, l)

            hasFirst4HData := true

//====================
// Draw fixed range after first 4H is closed
// Works on 4H because calculation is from 15m internally
//====================
bool first4HClosedOnChart = not na(activeFirst4HEnd) and time_close >= activeFirst4HEnd

if first4HClosedOnChart and hasFirst4HData and not rangeDrawn
    rangeBox := box.new(
         left         = activeTradeDayStart,
         top          = first4HHigh,
         right        = activeTradeDayEnd,
         bottom       = first4HLow,
         xloc         = xloc.bar_time,
         bgcolor      = RANGE_FILL,
         border_color = color.new(color.black, 100),
         border_width = 0
     )

    topLine := line.new(
         x1    = activeTradeDayStart,
         y1    = first4HHigh,
         x2    = activeTradeDayEnd,
         y2    = first4HHigh,
         xloc  = xloc.bar_time,
         color = RANGE_LINE,
         width = LINE_WIDTH
     )

    bottomLine := line.new(
         x1    = activeTradeDayStart,
         y1    = first4HLow,
         x2    = activeTradeDayEnd,
         y2    = first4HLow,
         xloc  = xloc.bar_time,
         color = RANGE_LINE,
         width = LINE_WIDTH
     )

    rangeDrawn := true
````
