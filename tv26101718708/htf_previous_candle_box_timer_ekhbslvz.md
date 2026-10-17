# HTF Previous Candle Box & Timer

- url: https://www.tradingview.com/script/eKhBSLVz-HTF-Previous-Candle-Box-Timer/
- type: indicator
- pine_id: PUB;821d058b57594cd4955ee6f46acacac2
- version: 1.0

## Description

15 min previous box for lower time frame with count down timer

## Source Code

````pine
//@version=6
indicator("HTF Previous Candle Box & Timer", overlay=true, max_boxes_count=500)

// --- Inputs ---
tfInput = input.timeframe("15", "Higher Timeframe", tooltip="The timeframe of the candle to draw and track")

grpStyle = "Style Settings"
upColor = input.color(color.new(#089981, 80), "Up Box Color", group=grpStyle)
downColor = input.color(color.new(#f23645, 80), "Down Box Color", group=grpStyle)
borderColor = input.color(color.new(color.gray, 50), "Border Color", group=grpStyle)
showTimer = input.bool(true, "Show Timer Widget", group=grpStyle)

// --- HTF Candle Tracking ---
var float htfO = na
var float htfH = na
var float htfL = na
var int htfStartTime = na

// Check if a new higher timeframe bar has started
isNewHTF = ta.change(time(tfInput)) != 0

// Track the current HTF candle and draw the previous one when it closes
if isNewHTF
    // Draw the box for the completed HTF candle
    if not na(htfStartTime)
        htfC = close[1]
        boxColor = htfC >= htfO ? upColor : downColor
        box.new(htfStartTime, htfH, time[1], htfL, xloc=xloc.bar_time, border_color=borderColor, bgcolor=boxColor)
    
    // Reset values for the new HTF candle
    htfO := open
    htfH := high
    htfL := low
    htfStartTime := time
else
    // Update the high and low of the ongoing HTF candle
    htfH := math.max(nz(htfH, high), high)
    htfL := math.min(nz(htfL, low), low)

// --- Timer Widget ---
var table timerTable = table.new(position.bottom_right, 1, 1)

if barstate.isrealtime and showTimer
    htfTimeClose = time_close(tfInput)
    if not na(htfTimeClose)
        timeRemaining = htfTimeClose - timenow
        if timeRemaining > 0
            // Calculate minutes and seconds remaining
            mins = math.floor(timeRemaining / 60000)
            secs = math.floor((timeRemaining % 60000) / 1000)
            
            // Format time string safely avoiding modulo on negative numbers
            timeStr = str.tostring(mins, "00") + ":" + str.tostring(secs, "00")
            
            // Update table
            table.cell(timerTable, 0, 0, "New " + tfInput + " Candle in: " + timeStr, 
                       bgcolor=color.new(chart.bg_color, 20), 
                       text_color=chart.fg_color, 
                       text_size=size.normal)
````
