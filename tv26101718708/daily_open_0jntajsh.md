# Daily Open

- url: https://www.tradingview.com/script/0jntajSH-Daily-Open/
- type: indicator
- pine_id: PUB;445eb3eba4b84e51b88f9b557eff42b6
- version: 1.0

## Description

the better daily opening i guess 

starts at the beginning of the day for those who want to see the daily opening and it stretches to just before the next daily opening u can the color and opacity enjoy

## Source Code

````pine
//@version=6
indicator('Daily Open', overlay = true, max_lines_count=500)

// --- Color Settings ---
string GROUP_COLORS = 'Line Colors'
colorMain = input.color(color.blue, 'Daily Open', group = GROUP_COLORS)
colorPrev = input.color(color.silver, 'Previous Days Open', group = GROUP_COLORS)
colorAvg  = input.color(color.gray, 'Average', group = GROUP_COLORS)

// --- Time Settings ---
string GROUP_CUSTOMTIME  = 'Custom Daily Open Time'
string INLINE_CUSTOMTIME = GROUP_CUSTOMTIME

showPrevInput = input.int(0, 'Days to Continue Printing Daily Open', minval = 0, maxval = 2, display = display.none)
showAvgInput  = input.bool(false, 'Show Average of Current and Previous Daily Open')

utcDailyInput = input.bool(false, 'Use 00:00 UTC as Daily Open', group = GROUP_CUSTOMTIME,
      tooltip = 'Overrides the custom time settings below.')

cusDailyInput = input.bool(false, 'Use Custom Time', inline = GROUP_CUSTOMTIME, group = GROUP_CUSTOMTIME, 
      tooltip = 'Uses the main chart\'s timezone.')
      
cusHourInput  = input.int(17, 'Hour', minval = 0, maxval = 23, inline = GROUP_CUSTOMTIME, group = GROUP_CUSTOMTIME, display = display.none)
cusMinInput   = input.int(00, 'Minute', minval = 0, maxval = 59, step = 15, inline = GROUP_CUSTOMTIME, group = GROUP_CUSTOMTIME, display = display.none)

bool utcDaily = time == time_tradingday
bool customDaily = time == timestamp(year, month, dayofmonth, cusHourInput, cusMinInput, 0)
bool defaultDaily = ta.change(time("D")) > 0

// Determine when a new day starts based on inputs
dailyAnchor = utcDailyInput ? utcDaily : (cusDailyInput ? customDaily : defaultDaily)

// Store previous open prices
var float open0 = na
var float open1 = na
var float open2 = na

// Store line IDs
var line line0 = na
var line line1 = na
var line line2 = na
var line avg0  = na
var line avg1  = na

if dailyAnchor
    // Shift prices back one day
    open2 := open1
    open1 := open0
    open0 := open

    // Draw brand new line segments using user-selected colors
    line0 := line.new(bar_index, open0, bar_index, open0, color=colorMain, width=2)
    
    if showPrevInput > 0
        line1 := line.new(bar_index, open1, bar_index, open1, color=colorPrev, width=2)
    if showPrevInput > 1
        line2 := line.new(bar_index, open2, bar_index, open2, color=colorPrev, width=2)
        
    if showAvgInput and not na(open1)
        avg0 := line.new(bar_index, math.avg(open0, open1), bar_index, math.avg(open0, open1), color=colorAvg, width=1)
    if showAvgInput and showPrevInput > 0 and not na(open2)
        avg1 := line.new(bar_index, math.avg(open1, open2), bar_index, math.avg(open1, open2), color=colorPrev, width=1)
else
    // Stretch existing lines forward if it's not a new day
    if not na(line0)
        line.set_x2(line0, bar_index)
    if not na(line1)
        line.set_x2(line1, bar_index)
    if not na(line2)
        line.set_x2(line2, bar_index)
    if not na(avg0)
        line.set_x2(avg0, bar_index)
    if not na(avg1)
        line.set_x2(avg1, bar_index)
````
