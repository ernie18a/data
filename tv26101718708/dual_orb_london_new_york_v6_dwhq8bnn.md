# Dual ORB (London & New York) | v6

- url: https://www.tradingview.com/script/dWhq8bNn-Dual-ORB-London-New-York-v6/
- type: indicator
- pine_id: PUB;6b3e67ff69a44405920ff2ed18312bbc
- version: 1.0

## Description

This is an indicator which  plots London ORB (9-9:15 am  GMT+2) and New york session (3:30-3:45 pm GMT+2).

After thye market open, the indicator will plot the high and the low of the first 15 minutes candles.

Note that the indicator is customizable

## Source Code

````pine
//@version=6
indicator("Dual ORB (London & New York) | v6", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ─────────────────────────────────────────────
// 🕓 INPUTS
// ─────────────────────────────────────────────
londonSession     = input.session("0800-0815", "London ORB (GMT+2)")
newYorkSession    = input.session("1400-1415", "New York ORB (GMT+2)")

londonEndHour     = input.int(11, "London ORB End (Hour GMT+2)")
newYorkEndHour    = input.int(18, "New York ORB End (Hour GMT+2)")

colorLondonHigh   = input.color(color.teal, "London High Color")
colorLondonLow    = input.color(color.orange, "London Low Color")
colorNewYorkHigh  = input.color(color.green, "New York High Color")
colorNewYorkLow   = input.color(color.red, "New York Low Color")

fillLondonColor   = input.color(color.new(color.teal, 85), "London Fill Color")
fillNewYorkColor  = input.color(color.new(color.green, 85), "New York Fill Color")

// ─────────────────────────────────────────────
// ⏱️ SESSION DETECTION
// ─────────────────────────────────────────────
inLondon     = not na(time(timeframe.period, londonSession, "GMT+2"))
startLondon  = inLondon and not inLondon[1]

inNewYork    = not na(time(timeframe.period, newYorkSession, "GMT+2"))
startNewYork = inNewYork and not inNewYork[1]

// ─────────────────────────────────────────────
// 📈 VARIABLES
// ─────────────────────────────────────────────
var float londonHigh = na
var float londonLow  = na
var float newYorkHigh = na
var float newYorkLow  = na

// ─────────────────────────────────────────────
// 🏙️ LONDON ORB LOGIC
// ─────────────────────────────────────────────
if startLondon
    londonHigh := high
    londonLow  := low
else if inLondon
    londonHigh := math.max(londonHigh, high)
    londonLow  := math.min(londonLow, low)

currentHour = hour(time, "GMT+2")
showLondon = currentHour < londonEndHour

londonHighPlot = plot(showLondon ? londonHigh : na, title="London ORB High", color=colorLondonHigh, linewidth=2)
londonLowPlot  = plot(showLondon ? londonLow  : na, title="London ORB Low", color=colorLondonLow, linewidth=2)

// Fill between London ORB high & low
fill(londonHighPlot, londonLowPlot, color=fillLondonColor, title="London ORB Fill")

// ─────────────────────────────────────────────
// 🗽 NEW YORK ORB LOGIC
// ─────────────────────────────────────────────
if startNewYork
    newYorkHigh := high
    newYorkLow  := low
else if inNewYork
    newYorkHigh := math.max(newYorkHigh, high)
    newYorkLow  := math.min(newYorkLow, low)

showNY = currentHour < newYorkEndHour

nyHighPlot = plot(showNY ? newYorkHigh : na, title="New York ORB High", color=colorNewYorkHigh, linewidth=2)
nyLowPlot  = plot(showNY ? newYorkLow  : na, title="New York ORB Low", color=colorNewYorkLow, linewidth=2)

// Fill between New York ORB high & low
fill(nyHighPlot, nyLowPlot, color=fillNewYorkColor, title="New York ORB Fill")
````
