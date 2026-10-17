# 09:30 AM ET Vertical Line

- url: https://www.tradingview.com/script/DY2vK1Ai-09-30-AM-ET-Vertical-Line/
- type: indicator
- pine_id: PUB;cd2f2956d1374715b1f6cef77b00550b
- version: 1.0

## Description

This indicator draws a vertical line at exactly 09:30 AM Eastern Time (America/New_York) on every weekday.
It automatically handles Daylight Saving Time (EST ↔ EDT).
The line is fully customizable (color, style, width) and extends across the entire chart height.
It works reliably on intraday charts (1m, 5m, 15m, etc.).

## Source Code

````pine
//@version=6
indicator("09:30 AM ET Vertical Line", 
     overlay=true, 
     max_lines_count=500, 
     max_bars_back=5000)

// ═══════════════════════════════════════════════════════════════
//                           INPUTS (Settings)
// ═══════════════════════════════════════════════════════════════
// These appear in the indicator settings panel so you can change them without editing code.

showLine   = input.bool(true, "Show 09:30 Line", group="General")
lineColor  = input.color(color.red, "Line Color", group="Appearance")
lineWidth  = input.int(2, "Line Width", minval=1, maxval=5, group="Appearance")
lineStyle  = input.string(line.style_dashed, "Line Style", 
              options=[line.style_solid, line.style_dashed, line.style_dotted], 
              group="Appearance")

// ═══════════════════════════════════════════════════════════════
//                    TIME CALCULATION (The Core Logic)
// ═══════════════════════════════════════════════════════════════

// Target time: 09:30 in Eastern Time
// "America/New_York" automatically handles EST and EDT (Daylight Saving)
targetHour   = 9
targetMinute = 30

// Create a timestamp for 09:30 on the SAME DATE as the current bar
// year, month, dayofmonth come from the current bar being processed
t = timestamp("America/New_York", year, month, dayofmonth, targetHour, targetMinute, 0)

// Only show the line on weekdays (Mon–Fri)
// This prevents lines on weekends (useful for stock charts)
isWeekday = dayofweek != dayofweek.saturday and dayofweek != dayofweek.sunday

// ═══════════════════════════════════════════════════════════════
//              ROBUST TRIGGER CONDITION (Very Important)
// ═══════════════════════════════════════════════════════════════
// We don't use "time == t" because on some timeframes there might not be a bar 
// that opens *exactly* at 09:30.
// This condition fires on the first bar that crosses or includes 09:30.
crossesTarget = time >= t and time[1] < t

// ═══════════════════════════════════════════════════════════════
//                        DRAW THE VERTICAL LINE
// ═══════════════════════════════════════════════════════════════
if showLine and isWeekday and crossesTarget
    line.new(
         x1     = t,           // X position = the exact 09:30 timestamp
         y1     = low,         // Starting price (low of the bar)
         x2     = t,           // Same X = vertical line
         y2     = high,        // Ending price (high of the bar)
         xloc   = xloc.bar_time,   // Use time (not bar index) for accurate placement
         extend = extend.both,     // Makes the line go up and down across the whole chart
         color  = lineColor,
         style  = lineStyle,
         width  = lineWidth
    )
````
