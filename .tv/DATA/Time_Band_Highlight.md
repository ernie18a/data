<!-- tradingview-pine-id: PUB;c62c3de7de5843eab8fd1a60323d7331 -->
<!-- tradingviewscripts-format: 1 -->
# Time Band Highlight

Source: https://www.tradingview.com/script/8wvArBhD-Time-Band-Highlight/

## Description

Use to identify a highlighted color band on the chart for a start time and end time.

For intraday times only.

---

## Source Code

````pine
//@version=6
indicator("Time Band Highlight", overlay=true, max_boxes_count=500, max_labels_count=500)

// ---- Inputs ----
startTime    = input.time(timestamp("2024-01-01 09:50 -0500"), "Start Time", confirm=false)
endTime      = input.time(timestamp("2024-01-01 10:10 -0500"), "End Time", confirm=false)
bandColor    = input.color(color.new(color.yellow, 0), "Band Color")
shadePct     = input.float(0, "Lighten (+) / Darken (-) %", minval=-100, maxval=100, step=5)
transparency = input.int(85, "Transparency", minval=0, maxval=100)
borderColor  = input.color(color.new(color.gray, 0), "Border Color")
borderWidth  = input.int(1, "Border Width (px)", minval=1, maxval=5)

labelText  = input.string("Time Band", "Label Text")
labelPos   = input.string("Top Center", "Label Position", options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"])
labelColor = input.color(color.black, "Label Text Color")
labelSize  = input.string(size.normal, "Label Size", options=[size.tiny, size.small, size.normal, size.large])

// ---- Session detection ----
startHour = hour(startTime)
startMin  = minute(startTime)
endHour   = hour(endTime)
endMin    = minute(endTime)

sessionStr = str.format("{0,number,00}{1,number,00}-{2,number,00}{3,number,00}", startHour, startMin, endHour, endMin)

inSession     = not na(time(timeframe.period, sessionStr, "America/New_York"))
inSessionPrev = not na(time(timeframe.period, sessionStr, "America/New_York")[1])

sessionStart = inSession and not inSessionPrev
sessionEnd   = inSessionPrev and not inSession

// ---- Lighten/Darken function ----
shadeColor(col, pct) =>
    r = color.r(col)
    g = color.g(col)
    b = color.b(col)
    if pct > 0
        r := r + (255 - r) * pct / 100
        g := g + (255 - g) * pct / 100
        b := b + (255 - b) * pct / 100
    else if pct < 0
        r := r * (100 + pct) / 100
        g := g * (100 + pct) / 100
        b := b * (100 + pct) / 100
    color.rgb(math.round(r), math.round(g), math.round(b))

finalColor = color.new(shadeColor(bandColor, shadePct), transparency)

// ---- Track running high/low during session, then overshoot for "full height" look ----
var float sessHigh = na
var float sessLow  = na
var box bx  = na
var label lbl = na

if sessionStart
    sessHigh := high
    sessLow  := low
else if inSession
    sessHigh := math.max(sessHigh, high)
    sessLow  := math.min(sessLow, low)

topVal    = sessHigh * 1.5
bottomVal = sessLow * 0.5

getXY(leftBar, rightBar, top, bottom, pos) =>
    xLeft   = leftBar
    xRight  = rightBar
    xCenter = math.round((leftBar + rightBar) / 2)
    yTop    = top
    yBottom = bottom
    yMid    = (top + bottom) / 2
    switch pos
        "Top Left"      => [xLeft, yTop]
        "Top Center"    => [xCenter, yTop]
        "Top Right"     => [xRight, yTop]
        "Middle Left"   => [xLeft, yMid]
        "Middle Center" => [xCenter, yMid]
        "Middle Right"  => [xRight, yMid]
        "Bottom Left"   => [xLeft, yBottom]
        "Bottom Center" => [xCenter, yBottom]
        "Bottom Right"  => [xRight, yBottom]
        => [xCenter, yMid]

if sessionStart
    bx := box.new(left=bar_index, top=topVal, right=bar_index, bottom=bottomVal, border_color=borderColor, border_width=borderWidth, bgcolor=finalColor, extend=extend.none)

if inSession and not na(bx)
    box.set_right(bx, bar_index)
    box.set_top(bx, topVal)
    box.set_bottom(bx, bottomVal)

    [lx, ly] = getXY(box.get_left(bx), bar_index, topVal, bottomVal, labelPos)
    if not na(lbl)
        label.delete(lbl)
    lbl := label.new(x=lx, y=ly, text=labelText, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_center, textcolor=labelColor, size=labelSize, color=color.new(color.white, 100))
````
