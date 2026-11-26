# NZ  15m Range

- url: https://www.tradingview.com/script/wkDlZMMm-NZ-15m-Range/
- type: indicator
- pine_id: PUB;05e68eb560f14a669ace272d9e3d8c0b
- version: 1.0

## Description

personal 15m orb trading strategies using it from new Zealand using the first 15min candle stick on the bell open

## Source Code

````pine
//@version=5
indicator("NZ 1:30 AM 15m Range", overlay=true, max_lines_count=500)

tz = "Pacific/Auckland"

// Get 15-minute candle data regardless of chart timeframe
htfTime = request.security(syminfo.tickerid, "15", time, barmerge.gaps_off, barmerge.lookahead_off)
htfHigh = request.security(syminfo.tickerid, "15", high, barmerge.gaps_off, barmerge.lookahead_off)
htfLow  = request.security(syminfo.tickerid, "15", low,  barmerge.gaps_off, barmerge.lookahead_off)

// Variables
var float rangeHigh = na
var float rangeLow = na
var int startTime = na
var int endTime = na

var line highLine = na
var line lowLine = na

// Detect the 1:30 AM 15-minute candle
is130Candle =
     hour(htfTime, tz) == 1 and
     minute(htfTime, tz) == 30

// Only execute once when a new 15m candle appears
newHTFBar = ta.change(htfTime) != 0

if newHTFBar and is130Candle

    rangeHigh := htfHigh
    rangeLow := htfLow

    // Start = 1:30 candle open
    startTime := htfTime

    // End = same day 9:00 AM NZ time
    endTime := timestamp(
         tz,
         year(htfTime, tz),
         month(htfTime, tz),
         dayofmonth(htfTime, tz),
         9,
         0)

    // Delete previous day's lines
    if not na(highLine)
        line.delete(highLine)

    if not na(lowLine)
        line.delete(lowLine)

    // Draw new lines
    highLine := line.new(
         startTime,
         rangeHigh,
         endTime,
         rangeHigh,
         xloc=xloc.bar_time,
         color=color.rgb(0, 0, 0),
         width=1)

    lowLine := line.new(
         startTime,
         rangeLow,
         endTime,
         rangeLow,
         xloc=xloc.bar_time,
         color=color.rgb(0, 0, 0),
         width=1)
````
