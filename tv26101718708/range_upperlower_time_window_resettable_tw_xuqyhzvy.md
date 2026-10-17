# Range Upper/Lower % - Time Window (Resettable) - TW

- url: https://www.tradingview.com/script/XUQYhzvY-Range-Upper-Lower-Time-Window-Resettable-TW/
- type: indicator
- pine_id: PUB;f02a1056484a4219a2dd8b50e9ec50f0
- version: 1.0

## Description

Easy way to calculate upper/lower percentage of PA within the range.


Step 1:

Mark Range Low

Step 2:

Mark Range High

Step 3:

Mark Start of the push/pull

Step 4:

Mark End of the push/pull

## Source Code

````pine
//@version=6
indicator("Range Upper/Lower % - Time Window (Resettable)", overlay=true, max_boxes_count=10)

//====================
// Inputs
//====================
rangeLowInput  = input.price(0.0, "Range Low", confirm=true)
rangeHighInput = input.price(0.0, "Range High", confirm=true)

startTimeInput = input.time(timestamp("2025-01-01 09:00 +0000"), "Start Date/Time", confirm=true)
endTimeInput   = input.time(timestamp("2025-01-01 12:00 +0000"), "End Date/Time", confirm=true)

mode = input.string("Close", "Classify By", options=["Close", "HL2"])

// 🔁 Reset options
resetOnStart = input.bool(true, "Reset at Start Time")
manualReset  = input.bool(false, "Manual Reset Trigger")

//====================
// Normalize values
//====================
topLevel    = math.max(rangeLowInput, rangeHighInput)
bottomLevel = math.min(rangeLowInput, rangeHighInput)
midLevel    = (topLevel + bottomLevel) / 2.0

timeFrom = math.min(startTimeInput, endTimeInput)
timeTo   = math.max(startTimeInput, endTimeInput)

priceToCheck = mode == "Close" ? close : hl2

//====================
// Conditions
//====================
inWindow = time >= timeFrom and time <= timeTo
inRange  = priceToCheck >= bottomLevel and priceToCheck <= topLevel

upperHit = inWindow and inRange and priceToCheck > midLevel
lowerHit = inWindow and inRange and priceToCheck < midLevel

insideHit = upperHit or lowerHit

//====================
// RESET LOGIC
//====================

// Detect first bar inside window
startEvent = inWindow and not inWindow[1]

// Manual reset trigger (checkbox toggle)
manualEvent = manualReset and not manualReset[1]

// Combine reset triggers
resetEvent = (resetOnStart and startEvent) or manualEvent

//====================
// Accumulators (SAFE)
//====================
var float upperCount  = 0
var float lowerCount  = 0
var float insideCount = 0

if resetEvent
    upperCount  := 0
    lowerCount  := 0
    insideCount := 0

if inWindow
    if insideHit
        insideCount += 1
        if upperHit
            upperCount += 1
        if lowerHit
            lowerCount += 1

//====================
// Percentages
//====================
upperPct = insideCount > 0 ? (upperCount / insideCount) * 100 : na
lowerPct = insideCount > 0 ? (lowerCount / insideCount) * 100 : na

//====================
// Box drawing
//====================
var box upperBox = na
var box lowerBox = na
var line midLine = na

if barstate.islast
    if not na(upperBox)
        box.delete(upperBox)
    if not na(lowerBox)
        box.delete(lowerBox)
    if not na(midLine)
        line.delete(midLine)

    upperBox := box.new(timeFrom, topLevel, timeTo, midLevel,
        xloc=xloc.bar_time,
        bgcolor=color.new(color.orange, 75),
        border_color=color.new(color.black, 40))

    lowerBox := box.new(timeFrom, midLevel, timeTo, bottomLevel,
        xloc=xloc.bar_time,
        bgcolor=color.new(color.black, 80),
        border_color=color.new(color.black, 40))

    midLine := line.new(timeFrom, midLevel, timeTo, midLevel,
        xloc=xloc.bar_time,
        color=color.gray,
        style=line.style_dashed)

//====================
// Table (compact)
//====================
var table t = table.new(position.top_right, 2, 2, border_width=1)

if barstate.islast
    table.cell(t, 0, 0, "Upper %", bgcolor=color.rgb(235,235,235))
    table.cell(t, 1, 0, na(upperPct) ? "n/a" : str.tostring(upperPct, "#.1") + "%",
        bgcolor=color.rgb(235,161,28), text_color=color.white)

    table.cell(t, 0, 1, "Lower %", bgcolor=color.rgb(235,235,235))
    table.cell(t, 1, 1, na(lowerPct) ? "n/a" : str.tostring(lowerPct, "#.1") + "%",
        bgcolor=color.rgb(99,99,99), text_color=color.white)
````
