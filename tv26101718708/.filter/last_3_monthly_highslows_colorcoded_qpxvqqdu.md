# Last 3 Monthly Highs/Lows Color-Coded

- url: https://www.tradingview.com/script/QPXVqqdU-Last-3-Monthly-Highs-Lows-Color-Coded/
- type: indicator
- pine_id: PUB;4e6ecd49cc804158812502bb48387136
- version: 2.0

## Description

Simple Indicator that tracks the last 3 complete months' Hi/Low

## Source Code

````pine
//@version=6
indicator("Last 3 Monthly Highs/Lows", overlay=true, max_lines_count=20, max_labels_count=20)

// Inputs
showHighs = input.bool(true, "Show Monthly Highs")
showLows  = input.bool(true, "Show Monthly Lows")
showLabels = input.bool(true, "Show Labels")
extendRight = input.bool(true, "Extend Lines Right")
lineWidth = input.int(2, "Line Width", minval=1, maxval=5)

// Detect new month
newMonth = ta.change(time("M")) != 0

// Prior completed monthly values
prevMonthHigh = request.security(syminfo.tickerid, "M", high[1])
prevMonthLow  = request.security(syminfo.tickerid, "M", low[1])
prevMonthTime = request.security(syminfo.tickerid, "M", time[1])

// Store last 3 completed monthly highs/lows
var float[] highs = array.new_float()
var float[] lows  = array.new_float()
var int[] times   = array.new_int()

if newMonth
    array.unshift(highs, prevMonthHigh)
    array.unshift(lows, prevMonthLow)
    array.unshift(times, prevMonthTime)

    if array.size(highs) > 3
        array.pop(highs)
        array.pop(lows)
        array.pop(times)

// Price bubble values
m1High = array.size(highs) > 0 ? array.get(highs, 0) : na
m1Low  = array.size(lows)  > 0 ? array.get(lows, 0)  : na

m2High = array.size(highs) > 1 ? array.get(highs, 1) : na
m2Low  = array.size(lows)  > 1 ? array.get(lows, 1)  : na

m3High = array.size(highs) > 2 ? array.get(highs, 2) : na
m3Low  = array.size(lows)  > 2 ? array.get(lows, 2)  : na

// Right-scale price bubbles using trackprice
plot(showHighs ? m1High : na, "M1 High Price Bubble", color=color.green,  linewidth=1, trackprice=true, style=plot.style_linebr)
plot(showLows  ? m1Low  : na, "M1 Low Price Bubble",  color=color.green,  linewidth=1, trackprice=true, style=plot.style_linebr)

plot(showHighs ? m2High : na, "M2 High Price Bubble", color=color.yellow, linewidth=1, trackprice=true, style=plot.style_linebr)
plot(showLows  ? m2Low  : na, "M2 Low Price Bubble",  color=color.yellow, linewidth=1, trackprice=true, style=plot.style_linebr)

plot(showHighs ? m3High : na, "M3 High Price Bubble", color=color.red,    linewidth=1, trackprice=true, style=plot.style_linebr)
plot(showLows  ? m3Low  : na, "M3 Low Price Bubble",  color=color.red,    linewidth=1, trackprice=true, style=plot.style_linebr)

// Drawing storage
var line[] highLines = array.new_line()
var line[] lowLines  = array.new_line()
var label[] highLabels = array.new_label()
var label[] lowLabels  = array.new_label()

// Clear old drawings and redraw
if barstate.islast
    for l in highLines
        line.delete(l)
    for l in lowLines
        line.delete(l)
    for lb in highLabels
        label.delete(lb)
    for lb in lowLabels
        label.delete(lb)

    array.clear(highLines)
    array.clear(lowLines)
    array.clear(highLabels)
    array.clear(lowLabels)

    for i = 0 to array.size(highs) - 1
        h = array.get(highs, i)
        lo = array.get(lows, i)
        t = array.get(times, i)

        clr = switch i
            0 => color.green
            1 => color.yellow
            => color.red

        ext = extendRight ? extend.right : extend.none
        monthText = "M" + str.tostring(i + 1)

        if showHighs
            hl = line.new(
                 x1=t, y1=h,
                 x2=time, y2=h,
                 xloc=xloc.bar_time,
                 extend=ext,
                 width=lineWidth,
                 color=clr
            )
            array.push(highLines, hl)

            if showLabels
                hLabel = label.new(
                     x=time, y=h,
                     text=monthText + " High: " + str.tostring(h, format.mintick),
                     xloc=xloc.bar_time,
                     style=label.style_label_left,
                     textcolor=color.black,
                     color=clr
                )
                array.push(highLabels, hLabel)

        if showLows
            ll = line.new(
                 x1=t, y1=lo,
                 x2=time, y2=lo,
                 xloc=xloc.bar_time,
                 extend=ext,
                 width=lineWidth,
                 color=clr
            )
            array.push(lowLines, ll)

            if showLabels
                lLabel = label.new(
                     x=time, y=lo,
                     text=monthText + " Low: " + str.tostring(lo, format.mintick),
                     xloc=xloc.bar_time,
                     style=label.style_label_left,
                     textcolor=color.black,
                     color=clr
                )
                array.push(lowLabels, lLabel)
````
