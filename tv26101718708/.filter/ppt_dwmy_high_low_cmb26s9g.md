# PPT D/W/M/Y High Low

- url: https://www.tradingview.com/script/CMb26s9g-PPT-D-W-M-Y-High-Low/
- type: indicator
- pine_id: PUB;8972b8079c924e9ab3206c146a260e63
- version: 2.0

## Description

Plots the highest high and lowest low of four rolling windows, each measured back from the current moment:

Daily (DH / DL): last 24 hours
Weekly (WH / WL): last 7 days
Monthly (MH / ML): last 30 days
Yearly (YH / YL): last 365 days

These are rolling windows, not calendar periods. The weekly level always covers the past 7 days, whatever day of the week it is. Each level includes the bar that's still forming, so the lines update in real time when price makes a new high or low.

Each level is drawn as a horizontal line from the start of its window to a small colored tag at the right of the chart, so you can see which level is which at a glance.

Settings

Color, line style (solid, dashed or dotted), width and on/off for each set of levels
Option to extend lines to the left edge of the chart
Tag distance from the last bar, and tag size

Notes

The start of each window is found in steps: 5 minutes for daily, 15 minutes for weekly, 1 hour for monthly and 1 day for yearly. The high and low values are exact.
For markets that aren't open around the clock, the 24-hour window may contain no trading on weekends or holidays. The daily lines then stay hidden until trading resumes.

## Source Code

````pine
//@version=6
indicator("PPT D/W/M/Y High Low", shorttitle = "PPT D/W/M/Y High Low", overlay = true, max_lines_count = 20, max_labels_count = 20)

// ── Helpers ──────────────────────────────────────────────────────
lineStyle(string s) =>
    switch s
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

// Black text on light box, white text on dark box
textFor(color c) =>
    (color.r(c) * 0.299 + color.g(c) * 0.587 + color.b(c) * 0.114) > 150 ? color.black : color.white

labelSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Normal" => size.normal
        => size.small

// Highest high / lowest low of every bar that closed within the last `windowMs`
// milliseconds of now. Only bars inside the window are ever stored.
rollingHL(int windowMs) =>
    var array<int>   ts = array.new<int>()
    var array<float> hs = array.new<float>()
    var array<float> ls = array.new<float>()
    cutoff = timenow - windowMs
    if time_close > cutoff
        ts.push(time_close)
        hs.push(high)
        ls.push(low)
    while ts.size() > 0 and ts.first() <= cutoff
        ts.shift()
        hs.shift()
        ls.shift()
    [hs.size() > 0 ? hs.max() : na, ls.size() > 0 ? ls.min() : na]

// ── Inputs ───────────────────────────────────────────────────────
gD = "Daily: last 24 hours"
showD  = input.bool(true, "Show", group = gD)
colD   = input.color(#009688, "Color", inline = "d", group = gD)
styD   = input.string("Dashed", "Style", options = ["Solid", "Dashed", "Dotted"], inline = "d", group = gD)
wD     = input.int(2, "Width", minval = 1, maxval = 4, inline = "d", group = gD)

gW = "Weekly: last 7 days"
showW  = input.bool(true, "Show", group = gW)
colW   = input.color(#FF00FF, "Color", inline = "w", group = gW)
styW   = input.string("Dashed", "Style", options = ["Solid", "Dashed", "Dotted"], inline = "w", group = gW)
wW     = input.int(2, "Width", minval = 1, maxval = 4, inline = "w", group = gW)

gM = "Monthly: last 30 days"
showM  = input.bool(true, "Show", group = gM)
colM   = input.color(#FF9800, "Color", inline = "m", group = gM)
styM   = input.string("Dashed", "Style", options = ["Solid", "Dashed", "Dotted"], inline = "m", group = gM)
wM     = input.int(2, "Width", minval = 1, maxval = 4, inline = "m", group = gM)

gY = "Yearly: last 365 days"
showY  = input.bool(true, "Show", group = gY)
colY   = input.color(#7F00FF, "Color", inline = "y", group = gY)
styY   = input.string("Dashed", "Style", options = ["Solid", "Dashed", "Dotted"], inline = "y", group = gY)
wY     = input.int(2, "Width", minval = 1, maxval = 4, inline = "y", group = gY)

gL = "Display"
extLeft   = input.bool(false, "Extend lines to left edge of chart", tooltip = "Off: each line starts where its window begins (24 hours, 7, 30 or 365 days ago).", group = gL)
lblOffset = input.int(20, "Box distance right of last bar", minval = 1, maxval = 100, group = gL)
lblSizeIn = input.string("Small", "Box size", options = ["Tiny", "Small", "Normal"], group = gL)

// ── Data ─────────────────────────────────────────────────────────
// Rolling windows are measured back from the current time. Each one is read from
// a resolution fine enough for its window: 5-minute bars for 24 hours, 15-minute
// bars for 7 days, hourly bars for 30 days, daily bars for 365 days. Only the last
// chart bar is drawn, so lookahead just gives the live values of the still-forming bars.
DAY_MS = 24 * 60 * 60 * 1000

[dH, dL] = request.security(syminfo.tickerid, "5",  rollingHL(DAY_MS),       lookahead = barmerge.lookahead_on)
[wH, wL] = request.security(syminfo.tickerid, "15", rollingHL(7 * DAY_MS),   lookahead = barmerge.lookahead_on)
[mH, mL] = request.security(syminfo.tickerid, "60", rollingHL(30 * DAY_MS),  lookahead = barmerge.lookahead_on)
[yH, yL] = request.security(syminfo.tickerid, "D",  rollingHL(365 * DAY_MS), lookahead = barmerge.lookahead_on)

// ── Drawing ──────────────────────────────────────────────────────
var array<line>  lines  = array.new<line>()
var array<label> labels = array.new<label>()

drawLevel(float price, int startTime, color col, int width, string sty, string txt) =>
    if not na(price)
        x2 = time + lblOffset * timeframe.in_seconds() * 1000
        lines.push(line.new(startTime, price, x2, price, xloc = xloc.bar_time, color = col, width = width, style = lineStyle(sty), extend = extLeft ? extend.left : extend.none))
        labels.push(label.new(x2, price, txt, xloc = xloc.bar_time, color = col, textcolor = textFor(col), style = label.style_label_center, size = labelSize(lblSizeIn)))

if barstate.islast
    for l in lines
        l.delete()
    for lb in labels
        lb.delete()
    lines.clear()
    labels.clear()

    if showY
        drawLevel(yH, timenow - 365 * DAY_MS, colY, wY, styY, "YH")
        drawLevel(yL, timenow - 365 * DAY_MS, colY, wY, styY, "YL")
    if showM
        drawLevel(mH, timenow - 30 * DAY_MS, colM, wM, styM, "MH")
        drawLevel(mL, timenow - 30 * DAY_MS, colM, wM, styM, "ML")
    if showW
        drawLevel(wH, timenow - 7 * DAY_MS, colW, wW, styW, "WH")
        drawLevel(wL, timenow - 7 * DAY_MS, colW, wW, styW, "WL")
    if showD
        drawLevel(dH, timenow - DAY_MS, colD, wD, styD, "DH")
        drawLevel(dL, timenow - DAY_MS, colD, wD, styD, "DL")
````
