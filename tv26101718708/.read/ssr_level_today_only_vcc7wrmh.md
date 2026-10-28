# SSR Level (Today Only)

- url: https://www.tradingview.com/script/vCc7wRMH-SSR-Level-Today-Only/
- type: indicator
- pine_id: PUB;74ff0e851f704fdbb3a847fdbf3a6070
- version: 1.0

## Description

Draws a line at 90% of the previous days closing (SSR trigger).

## Source Code

````pine
//@version=5
indicator("SSR Level (Today Only)", overlay=true)

// --- 1. Calculate SSR Level ---
// Fetch previous day's close accurately regardless of current intraday timeframe.
// We use "D" for daily resolution and close[1] to get the prior day's close.
prevClose = request.security(syminfo.tickerid, "D", close[1], gaps=barmerge.gaps_off)
ssrLevel  = prevClose * 0.90

// --- 2. Track Current Day's Start ---
// We identify the first bar of the current trading day to start our line.
var int startOfDayTime = na
isNewDay = ta.change(time("D"))
if isNewDay
    startOfDayTime := time

// --- 3. Create Drawing Objects (Only Once) ---
// By using the 'var' keyword, we only create ONE line and ONE label for the entire chart.
// This guarantees it will not plot on historical days, keeping your chart clean.
var line ssrLine = line.new(
     x1=na, y1=na, x2=na, y2=na,
     xloc=xloc.bar_time,
     extend=extend.right, // Extends the line to the right edge of the chart
     color=color.purple,
     style=line.style_dashed,
     width=1
 )

var label ssrLabel = label.new(
     x=na, y=na,
     text="SSR",
     xloc=xloc.bar_time,
     yloc=yloc.price,
     color=color.new(color.white, 100), // 100% transparent background
     style=label.style_label_down,      // The pointer pushes the text to sit just above the line
     textcolor=color.purple,
     size=size.normal
 )

// --- 4. Update Objects on the Last Bar ---
// We only update the coordinates on the final, real-time bar.
if barstate.islast and not na(ssrLevel)
    // Anchor the line to the start of today and project it forward
    line.set_xy1(ssrLine, startOfDayTime, ssrLevel)
    line.set_xy2(ssrLine, time, ssrLevel)

    // Anchor the label to the current bar's time, riding along the line
    label.set_xy(ssrLabel, time, ssrLevel)

// --- 5. Display on Price Axis ---
// We use a plot that is hidden from the chart itself (display.price_scale) just to add the price tag on the y-axis.
plot(ssrLevel, title="SSR Price Axis", color=color.purple, display=display.price_scale)
````
