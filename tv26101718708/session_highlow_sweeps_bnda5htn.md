# Session High/Low Sweeps

- url: https://www.tradingview.com/script/BndA5htn-Session-High-Low-Sweeps/
- type: indicator
- pine_id: PUB;28ec440d58b045d8a9467025c359f75b
- version: 1.0

## Description

NY, LON, ASIA high and lows, and removes when swept

## Source Code

````pine
//@version=6
indicator("Session High/Low Sweeps", overlay = true, max_lines_count = 500)

// === Inputs ===
showAsia   = input.bool(true, "Show Asia")
showLondon = input.bool(true, "Show London")
showNY     = input.bool(true, "Show New York")

asiaSession   = input.session("1700-0000", "Asia Session")
londonSession = input.session("0100-0400", "London Session")
nySession     = input.session("0830-1100", "New York Session")

lineWidth = input.int(1, "Line Width", minval = 1, maxval = 3)

// === Colors ===
asiaColor   = color.red
londonColor = color.orange
nyColor     = color.blue

// === Session Detection ===
inAsia   = not na(time(timeframe.period, asiaSession))
inLondon = not na(time(timeframe.period, londonSession))
inNY     = not na(time(timeframe.period, nySession))

asiaStart   = inAsia and not inAsia[1]
asiaEnd     = not inAsia and inAsia[1]

londonStart = inLondon and not inLondon[1]
londonEnd   = not inLondon and inLondon[1]

nyStart     = inNY and not inNY[1]
nyEnd       = not inNY and inNY[1]

// === Session High/Low Tracking ===
var float asiaHigh = na
var float asiaLow  = na

var float londonHigh = na
var float londonLow  = na

var float nyHigh = na
var float nyLow  = na

if asiaStart
    asiaHigh := high
    asiaLow  := low
else if inAsia
    asiaHigh := math.max(asiaHigh, high)
    asiaLow  := math.min(asiaLow, low)

if londonStart
    londonHigh := high
    londonLow  := low
else if inLondon
    londonHigh := math.max(londonHigh, high)
    londonLow  := math.min(londonLow, low)

if nyStart
    nyHigh := high
    nyLow  := low
else if inNY
    nyHigh := math.max(nyHigh, high)
    nyLow  := math.min(nyLow, low)

// === Line Storage ===
var line asiaHighLine = na
var line asiaLowLine  = na

var line londonHighLine = na
var line londonLowLine  = na

var line nyHighLine = na
var line nyLowLine  = na

// === Create Lines After Session Ends ===
if asiaEnd and showAsia and not na(asiaHigh) and not na(asiaLow)
    if not na(asiaHighLine)
        line.delete(asiaHighLine)
    if not na(asiaLowLine)
        line.delete(asiaLowLine)

    asiaHighLine := line.new(bar_index, asiaHigh, bar_index + 1, asiaHigh, extend = extend.right, color = asiaColor, style = line.style_dashed, width = lineWidth)
    asiaLowLine  := line.new(bar_index, asiaLow,  bar_index + 1, asiaLow,  extend = extend.right, color = asiaColor, style = line.style_dashed, width = lineWidth)

if londonEnd and showLondon and not na(londonHigh) and not na(londonLow)
    if not na(londonHighLine)
        line.delete(londonHighLine)
    if not na(londonLowLine)
        line.delete(londonLowLine)

    londonHighLine := line.new(bar_index, londonHigh, bar_index + 1, londonHigh, extend = extend.right, color = londonColor, style = line.style_dashed, width = lineWidth)
    londonLowLine  := line.new(bar_index, londonLow,  bar_index + 1, londonLow,  extend = extend.right, color = londonColor, style = line.style_dashed, width = lineWidth)

if nyEnd and showNY and not na(nyHigh) and not na(nyLow)
    if not na(nyHighLine)
        line.delete(nyHighLine)
    if not na(nyLowLine)
        line.delete(nyLowLine)

    nyHighLine := line.new(bar_index, nyHigh, bar_index + 1, nyHigh, extend = extend.right, color = nyColor, style = line.style_dashed, width = lineWidth)
    nyLowLine  := line.new(bar_index, nyLow,  bar_index + 1, nyLow,  extend = extend.right, color = nyColor, style = line.style_dashed, width = lineWidth)

// === Remove Lines Once Swept ===
if not na(asiaHighLine) and high > line.get_y1(asiaHighLine)
    line.delete(asiaHighLine)
    asiaHighLine := na

if not na(asiaLowLine) and low < line.get_y1(asiaLowLine)
    line.delete(asiaLowLine)
    asiaLowLine := na

if not na(londonHighLine) and high > line.get_y1(londonHighLine)
    line.delete(londonHighLine)
    londonHighLine := na

if not na(londonLowLine) and low < line.get_y1(londonLowLine)
    line.delete(londonLowLine)
    londonLowLine := na

if not na(nyHighLine) and high > line.get_y1(nyHighLine)
    line.delete(nyHighLine)
    nyHighLine := na

if not na(nyLowLine) and low < line.get_y1(nyLowLine)
    line.delete(nyLowLine)
    nyLowLine := na
````
