# Asia Range 120% & 161.8% Liquidity Tool

- url: https://www.tradingview.com/script/vuUQOB7x-Asia-Range-120-161-8-Liquidity-Tool/
- type: indicator
- pine_id: PUB;d64ee2de884b4a62bee1a5b4891e3f45
- version: 1.0

## Description

This indicator automatically marks out the Asia session range and plots the 120% and 161.8% extension levels, designed for liquidity sweep strategies and back testing.

What it does,
- Draws the Asia session high and low
- Displays the full range box for clear visual reference
- Shows the range size directly on the chart
- Plots 120% and 161.8% extension levels for trade entries
- Helps identify liquidity sweeps of the Asia range

## Source Code

````pine
//@version=5
indicator("Claire Asia Range + 120/161 Backtest Tool Clean", overlay = true, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500)

// =========================
// Inputs
// =========================
grpSession = "Session"
sessionInput = input.session("0000-0700", "Range session", group = grpSession)
sessionTz    = input.string("Europe/London", "Session timezone", group = grpSession)
showBox      = input.bool(true, "Show session box", group = grpSession)
showMid      = input.bool(false, "Show 50% midline", group = grpSession)

grpLevels = "Levels"
show120   = input.bool(true, "Show 120%", group = grpLevels)
show161   = input.bool(true, "Show 161.8%", group = grpLevels)
show100   = input.bool(false, "Show session high/low extensions", group = grpLevels)

grpFilter = "Backtest filters"
cutoffHour     = input.int(11, "Cutoff hour", minval = 0, maxval = 23, group = grpFilter)
cutoffMinute   = input.int(0, "Cutoff minute", minval = 0, maxval = 59, group = grpFilter)
showCutoffLine = input.bool(false, "Show cutoff vertical marker", group = grpFilter)

grpDisplay = "Display"
extendBars        = input.int(60, "Bars to extend levels right", minval = 1, maxval = 500, group = grpDisplay)
showRangeLabel    = input.bool(true, "Show range label", group = grpDisplay)
maxSessionsToKeep = input.int(150, "Max sessions to keep", minval = 10, maxval = 400, group = grpDisplay)

// =========================
// Session detection
// =========================
inSession     = not na(time(timeframe.period, sessionInput, sessionTz))
sessionStarts = inSession and not inSession[1]
sessionEnds   = not inSession and inSession[1]

// =========================
// Current session values
// =========================
var float sessHigh = na
var float sessLow = na
var int sessStartBar = na
var int sessEndBar = na
var int sessYear = na
var int sessMonth = na
var int sessDay = na

var box liveBox = na

// =========================
// Historical object storage
// =========================
var boxesArr  = array.new_box()
var linesArr  = array.new_line()
var labelsArr = array.new_label()

cleanup_if_needed() =>
    while array.size(boxesArr) > maxSessionsToKeep
        oldBox = array.shift(boxesArr)
        box.delete(oldBox)

    maxLines = maxSessionsToKeep * 8
    while array.size(linesArr) > maxLines
        oldLine = array.shift(linesArr)
        line.delete(oldLine)

    while array.size(labelsArr) > maxSessionsToKeep
        oldLabel = array.shift(labelsArr)
        label.delete(oldLabel)

// =========================
// Start new session
// =========================
if sessionStarts
    sessHigh := high
    sessLow := low
    sessStartBar := bar_index

    sessYear  := year(time, sessionTz)
    sessMonth := month(time, sessionTz)
    sessDay   := dayofmonth(time, sessionTz)

    if not na(liveBox)
        box.delete(liveBox)
    liveBox := na

    if showBox
        liveBox := box.new(
             left = sessStartBar,
             top = sessHigh,
             right = bar_index,
             bottom = sessLow,
             border_color = color.new(color.aqua, 0),
             bgcolor = color.new(color.aqua, 85)
         )

// =========================
// Update live session
// =========================
if inSession
    sessHigh := math.max(nz(sessHigh, high), high)
    sessLow  := math.min(nz(sessLow, low), low)

    if showBox and not na(liveBox)
        box.set_right(liveBox, bar_index)
        box.set_top(liveBox, sessHigh)
        box.set_bottom(liveBox, sessLow)

// =========================
// Finalize completed session
// =========================
if sessionEnds
    sessEndBar := bar_index - 1

    rng   = sessHigh - sessLow
    mid   = (sessHigh + sessLow) / 2.0
    up120 = sessHigh + rng * 0.20
    dn120 = sessLow  - rng * 0.20
    up161 = sessHigh + rng * 0.618
    dn161 = sessLow  - rng * 0.618

    x1 = sessStartBar
    x2 = sessEndBar + extendBars

    // Store finished box
    if showBox and not na(liveBox)
        box.set_right(liveBox, sessEndBar)
        array.push(boxesArr, liveBox)
        liveBox := na

    // Optional session high/low
    if show100
        hiLine = line.new(x1, sessHigh, x2, sessHigh, extend = extend.none, color = color.green, width = 1)
        loLine = line.new(x1, sessLow,  x2, sessLow,  extend = extend.none, color = color.red, width = 1)
        array.push(linesArr, hiLine)
        array.push(linesArr, loLine)

    // Optional midline
    if showMid
        midLine = line.new(x1, mid, x2, mid, extend = extend.none, color = color.gray, width = 1)
        array.push(linesArr, midLine)

    // 120 levels
    if show120
        up120Line = line.new(x1, up120, x2, up120, extend = extend.none, color = color.orange, width = 2)
        dn120Line = line.new(x1, dn120, x2, dn120, extend = extend.none, color = color.orange, width = 2)
        array.push(linesArr, up120Line)
        array.push(linesArr, dn120Line)

    // 161.8 levels
    if show161
        up161Line = line.new(x1, up161, x2, up161, extend = extend.none, color = color.purple, width = 2)
        dn161Line = line.new(x1, dn161, x2, dn161, extend = extend.none, color = color.purple, width = 2)
        array.push(linesArr, up161Line)
        array.push(linesArr, dn161Line)

    // Range label inside the box
    if showRangeLabel
        labelX = math.floor((x1 + sessEndBar) / 2)
        labelY = sessLow + (rng / 2)

        infoLabel = label.new(
             x = labelX,
             y = labelY,
             text = "R: " + str.tostring(rng),
             style = label.style_label_center,
             textcolor = color.white,
             color = color.new(color.black, 35),
             size = size.normal
         )
        array.push(labelsArr, infoLabel)

    // Optional cutoff line
    cutoffTs = timestamp(sessionTz, sessYear, sessMonth, sessDay, cutoffHour, cutoffMinute)
    hitCutoffAfterSession = time >= cutoffTs and time[1] < cutoffTs

    if showCutoffLine and hitCutoffAfterSession
        cutoff = line.new(bar_index, sessLow, bar_index, sessHigh, extend = extend.both, color = color.yellow, width = 1)
        array.push(linesArr, cutoff)

    cleanup_if_needed()

// =========================
// Hidden live plots
// =========================
plot(inSession ? sessHigh : na, title = "Live Session High", display = display.none)
plot(inSession ? sessLow  : na, title = "Live Session Low",  display = display.none)
````
