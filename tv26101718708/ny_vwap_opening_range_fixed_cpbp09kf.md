# NY VWAP + Opening Range (Fixed)

- url: https://www.tradingview.com/script/CPbP09Kf-NY-VWAP-Opening-Range-Fixed/
- type: indicator
- pine_id: PUB;c5ff8d485a0746a191f1e173694162ce
- version: 1.0

## Description

This indicator combines a New York session VWAP with a 15-minute Opening Range (ORB) from 9:30–9:45 AM EST.

It calculates and plots:

A session-based VWAP that only appears during 9:30 AM–4:00 PM EST, with an optional extension beyond the session.
The Opening Range High and Low based on the first 15 minutes of the NY session.
Horizontal ORB levels that remain on the chart and build historical reference over time.
Simple text labels (ORB-H and ORB-L) marking the key levels.

The tool is designed to help identify intraday bias, support/resistance zones, and breakout levels using early-session price structure aligned with institutional trading hours.

## Source Code

````pine
//@version=5
indicator("NY VWAP + Opening Range (Fixed)", overlay=true)

//====================================================
// INPUTS
//====================================================
extendVWAP = input.bool(false, "Extend VWAP After Session")

orHighColor = input.color(color.lime, "OR High Color")
orLowColor  = input.color(color.red, "OR Low Color")
lineWidth   = input.int(2, "OR Line Width", minval=1, maxval=5)

//====================================================
// NY SESSION
//====================================================
sessionTime = "0930-1600"
t = time(timeframe.period, sessionTime, "America/New_York")

inSession = not na(t)
newSession = inSession and na(t[1])
endSession = not inSession and inSession[1]

//====================================================
// VWAP (SESSION ONLY)
//====================================================
var float pv = 0.0
var float vol = 0.0
var float lastVWAP = na

if newSession
    pv := 0.0
    vol := 0.0

if inSession
    pv += hlc3 * volume
    vol += volume

vwap = vol > 0 ? pv / vol : na

if endSession
    lastVWAP := vwap[1]

finalVWAP = inSession ? vwap : (extendVWAP ? lastVWAP : na)

plot(finalVWAP, title="NY VWAP", color=color.orange, linewidth=2, style=plot.style_linebr)

//====================================================
// OPENING RANGE (9:30–9:45) — RESTORED PROPERLY
//====================================================
nyHour   = hour(time, "America/New_York")
nyMinute = minute(time, "America/New_York")

isOR  = (nyHour == 9 and nyMinute >= 30 and nyMinute < 45)
at945 = (nyHour == 9 and nyMinute == 45)

// reset daily OR values
var float orHigh = na
var float orLow  = na

if ta.change(time("D"))
    orHigh := na
    orLow := na

// build OR correctly
if isOR
    orHigh := na(orHigh) ? high : math.max(orHigh, high)
    orLow  := na(orLow)  ? low  : math.min(orLow, low)

//====================================================
// LINES (KEEP FULL HISTORY)
//====================================================
var line hiLine = na
var line loLine = na

if at945 and not na(orHigh)
    hiLine := line.new(bar_index, orHigh, bar_index, orHigh, color=orHighColor, width=lineWidth)
    loLine := line.new(bar_index, orLow,  bar_index, orLow,  color=orLowColor, width=lineWidth)

// extend only during session
inSessionTime = (nyHour >= 9 and nyHour < 16)

if inSessionTime and hiLine != na
    line.set_x2(hiLine, bar_index)
    line.set_x2(loLine, bar_index)

//====================================================
// LABELS (TEXT ONLY, NO BOX)
//====================================================
var label hiLabel = na
var label loLabel = na

if at945
    hiLabel := label.new(bar_index, orHigh, "ORB-H", style=label.style_none, textcolor=color.black, size=size.small)
    loLabel := label.new(bar_index, orLow,  "ORB-L", style=label.style_none, textcolor=color.black, size=size.small)

if inSessionTime and hiLabel != na
    label.set_x(hiLabel, bar_index)
    label.set_x(loLabel, bar_index)
````
