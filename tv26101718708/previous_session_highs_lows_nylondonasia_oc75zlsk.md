# Previous Session Highs & Lows NY-London-Asia

- url: https://www.tradingview.com/script/OC75zlsK-Previous-Session-Highs-Lows-NY-London-Asia/
- type: indicator
- pine_id: PUB;8c51c7511a4f4add80dc99269337da9d
- version: 1.0

## Description

Marks out PREVIOUS session HIGHS & LOWS for NY session, London Session, and Asia Session.

## Source Code

````pine
//@version=5
indicator("Latest Session Highs & Lows Only", overlay=true, max_lines_count=50, max_labels_count=50)

// Inputs
showAsia   = input.bool(true, "Show Asia Session")
showLondon = input.bool(true, "Show London Session")
showNY     = input.bool(true, "Show New York Session")

asiaSession   = input.session("1700-0000", "Asia Session")
londonSession = input.session("0000-0300", "London Session")
nySession     = input.session("0630-0930", "New York Session")

tz = input.string("America/Los_Angeles", "Session Timezone")

showLabels  = input.bool(true, "Show Labels")
extendLines = input.bool(true, "Extend Lines Right")

// ─────────────────────────────
// ASIA VARIABLES
// ─────────────────────────────
var float asiaHigh = na
var float asiaLow = na
var line asiaHighLine = na
var line asiaLowLine = na
var label asiaHighLabel = na
var label asiaLowLabel = na

var line lastAsiaHighLine = na
var line lastAsiaLowLine = na
var label lastAsiaHighLabel = na
var label lastAsiaLowLabel = na

// ─────────────────────────────
// LONDON VARIABLES
// ─────────────────────────────
var float londonHigh = na
var float londonLow = na
var line londonHighLine = na
var line londonLowLine = na
var label londonHighLabel = na
var label londonLowLabel = na

var line lastLondonHighLine = na
var line lastLondonLowLine = na
var label lastLondonHighLabel = na
var label lastLondonLowLabel = na

// ─────────────────────────────
// NEW YORK VARIABLES
// ─────────────────────────────
var float nyHigh = na
var float nyLow = na
var line nyHighLine = na
var line nyLowLine = na
var label nyHighLabel = na
var label nyLowLabel = na

var line lastNYHighLine = na
var line lastNYLowLine = na
var label lastNYHighLabel = na
var label lastNYLowLabel = na

// Session checks
inAsia = showAsia and not na(time(timeframe.period, asiaSession, tz))
asiaStart = inAsia and not inAsia[1]
asiaEnd = not inAsia and inAsia[1]

inLondon = showLondon and not na(time(timeframe.period, londonSession, tz))
londonStart = inLondon and not inLondon[1]
londonEnd = not inLondon and inLondon[1]

inNY = showNY and not na(time(timeframe.period, nySession, tz))
nyStart = inNY and not inNY[1]
nyEnd = not inNY and inNY[1]

// ─────────────────────────────
// ASIA
// ─────────────────────────────
if asiaStart
    asiaHigh := high
    asiaLow := low
    asiaHighLine := line.new(bar_index, asiaHigh, bar_index, asiaHigh, color=color.blue, width=2, extend=extendLines ? extend.right : extend.none)
    asiaLowLine := line.new(bar_index, asiaLow, bar_index, asiaLow, color=color.new(color.blue, 20), width=2, extend=extendLines ? extend.right : extend.none)
    if showLabels
        asiaHighLabel := label.new(bar_index, asiaHigh, "Asia High", style=label.style_label_down, textcolor=color.white, color=color.blue)
        asiaLowLabel := label.new(bar_index, asiaLow, "Asia Low", style=label.style_label_up, textcolor=color.white, color=color.new(color.blue, 20))

if inAsia
    asiaHigh := math.max(asiaHigh, high)
    asiaLow := math.min(asiaLow, low)

    line.set_y1(asiaHighLine, asiaHigh)
    line.set_y2(asiaHighLine, asiaHigh)
    line.set_x2(asiaHighLine, bar_index)

    line.set_y1(asiaLowLine, asiaLow)
    line.set_y2(asiaLowLine, asiaLow)
    line.set_x2(asiaLowLine, bar_index)

    if showLabels
        label.set_x(asiaHighLabel, bar_index)
        label.set_y(asiaHighLabel, asiaHigh)
        label.set_x(asiaLowLabel, bar_index)
        label.set_y(asiaLowLabel, asiaLow)

if asiaEnd
    if not na(lastAsiaHighLine)
        line.delete(lastAsiaHighLine)
    if not na(lastAsiaLowLine)
        line.delete(lastAsiaLowLine)
    if not na(lastAsiaHighLabel)
        label.delete(lastAsiaHighLabel)
    if not na(lastAsiaLowLabel)
        label.delete(lastAsiaLowLabel)

    lastAsiaHighLine := asiaHighLine
    lastAsiaLowLine := asiaLowLine
    lastAsiaHighLabel := asiaHighLabel
    lastAsiaLowLabel := asiaLowLabel

// ─────────────────────────────
// LONDON
// ─────────────────────────────
if londonStart
    londonHigh := high
    londonLow := low
    londonHighLine := line.new(bar_index, londonHigh, bar_index, londonHigh, color=color.orange, width=2, extend=extendLines ? extend.right : extend.none)
    londonLowLine := line.new(bar_index, londonLow, bar_index, londonLow, color=color.new(color.orange, 20), width=2, extend=extendLines ? extend.right : extend.none)
    if showLabels
        londonHighLabel := label.new(bar_index, londonHigh, "London High", style=label.style_label_down, textcolor=color.white, color=color.orange)
        londonLowLabel := label.new(bar_index, londonLow, "London Low", style=label.style_label_up, textcolor=color.white, color=color.new(color.orange, 20))

if inLondon
    londonHigh := math.max(londonHigh, high)
    londonLow := math.min(londonLow, low)

    line.set_y1(londonHighLine, londonHigh)
    line.set_y2(londonHighLine, londonHigh)
    line.set_x2(londonHighLine, bar_index)

    line.set_y1(londonLowLine, londonLow)
    line.set_y2(londonLowLine, londonLow)
    line.set_x2(londonLowLine, bar_index)

    if showLabels
        label.set_x(londonHighLabel, bar_index)
        label.set_y(londonHighLabel, londonHigh)
        label.set_x(londonLowLabel, bar_index)
        label.set_y(londonLowLabel, londonLow)

if londonEnd
    if not na(lastLondonHighLine)
        line.delete(lastLondonHighLine)
    if not na(lastLondonLowLine)
        line.delete(lastLondonLowLine)
    if not na(lastLondonHighLabel)
        label.delete(lastLondonHighLabel)
    if not na(lastLondonLowLabel)
        label.delete(lastLondonLowLabel)

    lastLondonHighLine := londonHighLine
    lastLondonLowLine := londonLowLine
    lastLondonHighLabel := londonHighLabel
    lastLondonLowLabel := londonLowLabel

// ─────────────────────────────
// NEW YORK
// ─────────────────────────────
if nyStart
    nyHigh := high
    nyLow := low
    nyHighLine := line.new(bar_index, nyHigh, bar_index, nyHigh, color=color.green, width=2, extend=extendLines ? extend.right : extend.none)
    nyLowLine := line.new(bar_index, nyLow, bar_index, nyLow, color=color.new(color.green, 20), width=2, extend=extendLines ? extend.right : extend.none)
    if showLabels
        nyHighLabel := label.new(bar_index, nyHigh, "New York High", style=label.style_label_down, textcolor=color.white, color=color.green)
        nyLowLabel := label.new(bar_index, nyLow, "New York Low", style=label.style_label_up, textcolor=color.white, color=color.new(color.green, 20))

if inNY
    nyHigh := math.max(nyHigh, high)
    nyLow := math.min(nyLow, low)

    line.set_y1(nyHighLine, nyHigh)
    line.set_y2(nyHighLine, nyHigh)
    line.set_x2(nyHighLine, bar_index)

    line.set_y1(nyLowLine, nyLow)
    line.set_y2(nyLowLine, nyLow)
    line.set_x2(nyLowLine, bar_index)

    if showLabels
        label.set_x(nyHighLabel, bar_index)
        label.set_y(nyHighLabel, nyHigh)
        label.set_x(nyLowLabel, bar_index)
        label.set_y(nyLowLabel, nyLow)

if nyEnd
    if not na(lastNYHighLine)
        line.delete(lastNYHighLine)
    if not na(lastNYLowLine)
        line.delete(lastNYLowLine)
    if not na(lastNYHighLabel)
        label.delete(lastNYHighLabel)
    if not na(lastNYLowLabel)
        label.delete(lastNYLowLabel)

    lastNYHighLine := nyHighLine
    lastNYLowLine := nyLowLine
    lastNYHighLabel := nyHighLabel
    lastNYLowLabel := nyLowLabel
````
