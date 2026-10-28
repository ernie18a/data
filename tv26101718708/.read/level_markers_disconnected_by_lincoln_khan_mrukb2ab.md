# Level Markers - Disconnected by Lincoln Khan

- url: https://www.tradingview.com/script/MruKb2ab-Level-Markers-Disconnected-by-Lincoln-Khan/
- type: indicator
- pine_id: PUB;6b40204515194754b1d516aa95b64433
- version: 1.0

## Description

Now the script creates exactly 6 lines total:

Premarket High (Light Green)
Premarket Low (Light Green)
Opening Range High (Purple)
Opening Range Low (Purple)
Previous Day High (Light Green)
Previous Day Low (Light Blue)

## Source Code

````pine
//@version=5
indicator("Level Markers - Disconnected", overlay=true)

// ─────────────────────────────
// GET PREVIOUS DAY HIGH/LOW (Yesterday only - do not carry forward)
// ─────────────────────────────
prevDayHigh = request.security(syminfo.tickerid, "D", high[1])
prevDayLow = request.security(syminfo.tickerid, "D", low[1])

// ─────────────────────────────
// PREMARKET HIGH/LOW (4:00 AM - 9:30 AM)
// ─────────────────────────────
var float pmHigh = 0.0
var float pmLow = 0.0

if ta.change(time("D"))
    pmHigh := 0.0
    pmLow := 0.0

inPremarket = not na(time(timeframe.period, "0400-0930"))

// ─────────────────────────────
// OPENING RANGE (9:30 AM - 10:00 AM)
// ─────────────────────────────
var float orHigh = 0.0
var float orLow = 0.0

if ta.change(time("D"))
    orHigh := 0.0
    orLow := 0.0

inOpeningRange = not na(time(timeframe.period, "0930-1000"))

// ─────────────────────────────
// DISPLAY LOGIC - Create 6 straight lines only once per time period
// ─────────────────────────────

var line pmHighLine = na
var line pmLowLine = na
var line orHighLine = na
var line orLowLine = na
var line prevDayHighLine = na
var line prevDayLowLine = na

// Create premarket lines only once at start of premarket
if inPremarket and na(pmHighLine)
    pmHighLine := line.new(bar_index, pmHigh, bar_index + 500, pmHigh, extend=extend.right, color=color.new(color.lime, 0), width=2)
    pmLowLine := line.new(bar_index, pmLow, bar_index + 500, pmLow, extend=extend.right, color=color.new(color.lime, 0), width=2)

// Update premarket values during premarket hours
if inPremarket
    pmHigh := pmHigh == 0.0 ? high : math.max(pmHigh, high)
    pmLow := pmLow == 0.0 ? low : math.min(pmLow, low)
    if not na(pmHighLine)
        line.set_y1(pmHighLine, pmHigh)
        line.set_y2(pmHighLine, pmHigh)
    if not na(pmLowLine)
        line.set_y1(pmLowLine, pmLow)
        line.set_y2(pmLowLine, pmLow)

// Create opening range lines only once at start of OR
if inOpeningRange and na(orHighLine)
    orHighLine := line.new(bar_index, orHigh, bar_index + 500, orHigh, extend=extend.right, color=color.new(color.fuchsia, 0), width=2)
    orLowLine := line.new(bar_index, orLow, bar_index + 500, orLow, extend=extend.right, color=color.new(color.fuchsia, 0), width=2)

// Update opening range values during OR hours
if inOpeningRange
    orHigh := orHigh == 0.0 ? high : math.max(orHigh, high)
    orLow := orLow == 0.0 ? low : math.min(orLow, low)
    if not na(orHighLine)
        line.set_y1(orHighLine, orHigh)
        line.set_y2(orHighLine, orHigh)
    if not na(orLowLine)
        line.set_y1(orLowLine, orLow)
        line.set_y2(orLowLine, orLow)

// Create previous day lines only once after opening range ends
afterOpeningRange = not na(time(timeframe.period, "1000-1600"))
if afterOpeningRange and na(prevDayHighLine)
    prevDayHighLine := line.new(bar_index, prevDayHigh, bar_index + 500, prevDayHigh, extend=extend.right, color=color.new(color.lime, 0), width=2)
    prevDayLowLine := line.new(bar_index, prevDayLow, bar_index + 500, prevDayLow, extend=extend.right, color=color.new(color.aqua, 0), width=2)
````
