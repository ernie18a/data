# ICT Session Highs / Lows

- url: https://www.tradingview.com/script/3ifJKesn-ICT-Session-Highs-Lows/
- type: indicator
- pine_id: PUB;b13b4c18fe9e4845b95b8807b8dac1c9
- version: 1.0

## Description

ICT 2022 playlist defined session times highs and lows - @Ryanfutures on X.

## Source Code

````pine
//@version=6
indicator("ICT Session Highs/Lows", overlay=true, max_boxes_count=500, max_lines_count=500)

// ---- Session time inputs (all in NY time) ----
asiaSess   = input.session("1900-2100", "Asia Session (NY time)")
londonSess = input.session("0200-0500", "London Session (NY time)")
nySess     = input.session("0700-1000", "New York Session (NY time)")

showAsia   = input.bool(true, "Show Asia")
showLondon = input.bool(true, "Show London")
showNY     = input.bool(true, "Show New York")

colAsia   = input.color(color.new(color.orange, 0), "Asia Color")
colLondon = input.color(color.new(color.blue, 0), "London Color")
colNY     = input.color(color.new(color.green, 0), "New York Color")

tz = "America/New_York"

// ---- Session detection ----
inAsia   = not na(time(timeframe.period, asiaSess, tz))
inLondon = not na(time(timeframe.period, londonSess, tz))
inNY     = not na(time(timeframe.period, nySess, tz))

f_track(inSession) =>
    var float hi = na
    var float lo = na
    var int startBar = na
    bool firstBar = inSession and not inSession[1]
    bool justEnded = not inSession and inSession[1]
    if firstBar
        hi := high
        lo := low
        startBar := bar_index
    else if inSession
        hi := math.max(hi, high)
        lo := math.min(lo, low)
    [hi, lo, startBar, firstBar, justEnded]

// ---- Asia ----
var box asiaBox = na
[asiaHi, asiaLo, asiaStart, asiaFirst, asiaEnded] = f_track(inAsia)

if showAsia and inAsia
    if asiaFirst
        asiaBox := box.new(bar_index, asiaHi, bar_index, asiaLo, border_color=colAsia, bgcolor=color.new(colAsia, 85), border_width=1)
    else
        box.set_rightbottom(asiaBox, bar_index, asiaLo)
        box.set_top(asiaBox, asiaHi)

if showAsia and asiaEnded
    label.new(bar_index, asiaHi, "Asia High", color=color.new(color.white, 100), textcolor=colAsia, style=label.style_label_left, size=size.small)
    label.new(bar_index, asiaLo, "Asia Low", color=color.new(color.white, 100), textcolor=colAsia, style=label.style_label_left, size=size.small)

// ---- London ----
var box londonBox = na
[londonHi, londonLo, londonStart, londonFirst, londonEnded] = f_track(inLondon)

if showLondon and inLondon
    if londonFirst
        londonBox := box.new(bar_index, londonHi, bar_index, londonLo, border_color=colLondon, bgcolor=color.new(colLondon, 85), border_width=1)
    else
        box.set_rightbottom(londonBox, bar_index, londonLo)
        box.set_top(londonBox, londonHi)

if showLondon and londonEnded
    label.new(bar_index, londonHi, "London High", color=color.new(color.white, 100), textcolor=colLondon, style=label.style_label_left, size=size.small)
    label.new(bar_index, londonLo, "London Low", color=color.new(color.white, 100), textcolor=colLondon, style=label.style_label_left, size=size.small)

// ---- New York ----
var box nyBox = na
[nyHi, nyLo, nyStart, nyFirst, nyEnded] = f_track(inNY)

if showNY and inNY
    if nyFirst
        nyBox := box.new(bar_index, nyHi, bar_index, nyLo, border_color=colNY, bgcolor=color.new(colNY, 85), border_width=1)
    else
        box.set_rightbottom(nyBox, bar_index, nyLo)
        box.set_top(nyBox, nyHi)

if showNY and nyEnded
    label.new(bar_index, nyHi, "NY High", color=color.new(color.white, 100), textcolor=colNY, style=label.style_label_left, size=size.small)
    label.new(bar_index, nyLo, "NY Low", color=color.new(color.white, 100), textcolor=colNY, style=label.style_label_left, size=size.small)
````
