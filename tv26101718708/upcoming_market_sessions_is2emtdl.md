# Upcoming Market Sessions

- url: https://www.tradingview.com/script/is2eMtDL-Upcoming-Market-Sessions/
- type: indicator
- pine_id: PUB;5cfe82805b124c04bc7a1d96d59212f2
- version: 2.0

## Description

Upcoming Market Sessions

This lightweight script projects the exact starting times of the major global trading sessions directly into the future blank space of your chart. It features a customizable timezone selection and individual toggle switches for each market session to keep your workspace clean.

[b]Why this script was created:[/b]
This indicator is built to make forecasting significantly easier by clearly highlighting upcoming session starts for the next 24 hours. When drawing out future price action, it is easy to find yourself constantly checking the bottom time axis to see which session your setup will land in.

This script gives a direct visual indication of exactly when you need to be back at your charts, and instantly shows if your forecasted move is landing inside a high-volume session for your traded instrument.

[b]Features:[/b]
[list=1]
[*]Future Projections: Draws clean, vertical session lines into the future empty space where candles haven't formed yet.
[*]Flexible Session Toggles: Turn individual session lines (Sydney, Tokyo, London, New York) on or off depending on your asset.
[*]Customizable Inputs: Easily adjust the exact start hours (HHMM) and matching display colors directly in the indicator settings.
[/list]

## Source Code

````pine
//@version=6
indicator("Upcoming Market Sessions", overlay=true, max_lines_count=20, max_labels_count=20)

// --- Inputs ---
tzInput   = input.string("GMT+8", title="Timezone", options=["GMT+8", "GMT+0", "America/New_York", "Europe/London", "Asia/Tokyo"])
lineColor = input.color(color.new(color.gray, 30), title="Line Color")
textColor = input.color(color.white, title="Label Color")

// Session Toggles & Times
showSyd   = input.bool(true, title="Show Sydney")
sydTime   = input.string("0600", title="Sydney Start (HHMM)")

showTok   = input.bool(true, title="Show Tokyo")
tokTime   = input.string("0800", title="Tokyo Start (HHMM)")

showLon   = input.bool(true, title="Show London")
lonTime   = input.string("1500", title="London Start (HHMM)")

showNY    = input.bool(true, title="Show New York")
nyTime    = input.string("2000", title="New York Start (HHMM)")

// --- Arrays to track and clear old live drawings ---
var line[] activeLines = array.new_line()
var label[] activeLabels = array.new_label()

// --- Drawing Logic ---
drawFuture(sessionTime, labelText) =>
    sHour = int(str.tonumber(str.substring(sessionTime, 0, 2)))
    sMin  = int(str.tonumber(str.substring(sessionTime, 2, 4)))
    
    // Calculate today's specific session timestamp
    targetToday = timestamp(tzInput, year(timenow, tzInput), month(timenow, tzInput), dayofmonth(timenow, tzInput), sHour, sMin)
    
    // Shift forward by 24h if it already passed timenow
    targetFuture = targetToday < timenow ? targetToday + (24 * 60 * 60 * 1000) : targetToday
    
    // Create new drawings
    newLine  = line.new(x1=targetFuture, y1=low, x2=targetFuture, y2=high, xloc=xloc.bar_time, extend=extend.both, color=lineColor, style=line.style_dotted, width=1)
    newLabel = label.new(x=targetFuture, y=high, xloc=xloc.bar_time, text=labelText, color=color.new(color.black, 100), textcolor=textColor, style=label.style_label_down, size=size.small)
    
    // Store IDs to delete them on the next tick
    array.push(activeLines, newLine)
    array.push(activeLabels, newLabel)

// --- Execution ---
if barstate.islast and timeframe.isintraday
    // Clear drawings from the previous live tick
    if array.size(activeLines) > 0
        for i = 0 to array.size(activeLines) - 1
            line.delete(array.get(activeLines, i))
            label.delete(array.get(activeLabels, i))
        array.clear(activeLines)
        array.clear(activeLabels)

    // Draw updated lines
    if showSyd
        drawFuture(sydTime, "S")
    if showTok
        drawFuture(tokTime, "T")
    if showLon
        drawFuture(lonTime, "L")
    if showNY
        drawFuture(nyTime, "NY")
````
