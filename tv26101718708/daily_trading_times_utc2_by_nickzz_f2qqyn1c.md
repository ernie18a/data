# Daily Trading Times (UTC+2) By NickZZ

- url: https://www.tradingview.com/script/f2qqYN1c-Daily-Trading-Times-UTC-2-By-NickZZ/
- type: indicator
- pine_id: PUB;5878e2345d874cb4a9632411c6380a29
- version: 1.0

## Description

The best times to trade marked on the chart if you are trading ILM and IFVG , this indicator will help you find the time you need to start looking for setup and the time to fully exit the markets for the day .

## Source Code

````pine
//@version=5
indicator("Daily Trading Times (UTC+2)", overlay=true)

// ─────────────────────────────────────────────
// Settings
lineColor = color.orange
lineStyle = line.style_dashed
lineWidth = 1
tz = "GMT+2"

// ─────────────────────────────────────────────
// Build timestamps for TODAY in UTC+2
y = year(time, tz)
m = month(time, tz)
d = dayofmonth(time, tz)

t1 = timestamp(tz, y, m, d, 16, 0) // 4 PM UTC+2
t2 = timestamp(tz, y, m, d, 18, 0) // 6 PM UTC+2

// ─────────────────────────────────────────────
// Detect first bar AFTER the target time
isT1 = time >= t1 and time[1] < t1
isT2 = time >= t2 and time[1] < t2

// ─────────────────────────────────────────────
// Draw vertical lines
if isT1
    line.new(x1 = t1,y1 = low,x2 = t1,y2 = high,xloc = xloc.bar_time,extend = extend.both,color = lineColor,style = lineStyle,width = lineWidth)

if isT2
    line.new(x1 = t2,y1 = low,x2 = t2,y2 = high,xloc = xloc.bar_time,extend = extend.both,color = lineColor,style = lineStyle,width = lineWidth)
````
