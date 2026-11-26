# MNQ VWAP Time Window Backtest

- url: https://www.tradingview.com/script/bLA2mCZE-MNQ-VWAP-Time-Window-Backtest/
- type: indicator
- pine_id: PUB;533e1eb18e5b47e0800c57e5cbfb2147
- version: 1.0

## Description

Backtests whether MNQ crosses session VWAP during specific Central Time extended-hours windows (20:00, 01:00, and 03:00–04:59), with selectable intrabar or close-cross logic, and shows the percentage of tested days that had at least one VWAP cross.

## Source Code

````pine
//@version=6
indicator("MNQ VWAP Time Window Backtest", overlay=true, max_labels_count=500)

// -----------------------------
// Inputs
// -----------------------------
tz = input.string("America/Chicago", "Test Timezone")
crossMode = input.string("Intrabar", "Cross Type", options=["Intrabar", "Close Cross"])

// Session windows in Central Time
sess1 = input.session("2000-2059", "Window 1 (20:00-20:59)")
sess2 = input.session("0100-0159", "Window 2 (01:00-01:59)")
sess3 = input.session("0300-0459", "Window 3 (03:00-04:59)")

// -----------------------------
// VWAP
// -----------------------------
vwapValue = ta.vwap
plot(vwapValue, "VWAP", linewidth=2)

// -----------------------------
// Helpers
// -----------------------------
inSess1 = not na(time(timeframe.period, sess1 + ":1234567", tz))
inSess2 = not na(time(timeframe.period, sess2 + ":1234567", tz))
inSess3 = not na(time(timeframe.period, sess3 + ":1234567", tz))

newSess1 = inSess1 and not inSess1[1]
newSess2 = inSess2 and not inSess2[1]
newSess3 = inSess3 and not inSess3[1]

endSess1 = not inSess1 and inSess1[1]
endSess2 = not inSess2 and inSess2[1]
endSess3 = not inSess3 and inSess3[1]

// Cross logic
closeCross = ta.crossover(close, vwapValue) or ta.crossunder(close, vwapValue)
intraBarCross = low <= vwapValue and high >= vwapValue

didCross = crossMode == "Close Cross" ? closeCross : intraBarCross

// -----------------------------
// Per-window state
// -----------------------------
var int totalDays1 = 0
var int totalDays2 = 0
var int totalDays3 = 0

var int daysWithCross1 = 0
var int daysWithCross2 = 0
var int daysWithCross3 = 0

var int totalCrosses1 = 0
var int totalCrosses2 = 0
var int totalCrosses3 = 0

var bool crossedThisWindow1 = false
var bool crossedThisWindow2 = false
var bool crossedThisWindow3 = false

// Reset at window start
if newSess1
    totalDays1 += 1
    crossedThisWindow1 := false

if newSess2
    totalDays2 += 1
    crossedThisWindow2 := false

if newSess3
    totalDays3 += 1
    crossedThisWindow3 := false

// Count crosses while inside each window
if inSess1 and didCross
    totalCrosses1 += 1
    crossedThisWindow1 := true

if inSess2 and didCross
    totalCrosses2 += 1
    crossedThisWindow2 := true

if inSess3 and didCross
    totalCrosses3 += 1
    crossedThisWindow3 := true

// At end of window, count whether that window had at least one cross
if endSess1 and crossedThisWindow1
    daysWithCross1 += 1

if endSess2 and crossedThisWindow2
    daysWithCross2 += 1

if endSess3 and crossedThisWindow3
    daysWithCross3 += 1

// Percent calculations
pct1 = totalDays1 > 0 ? (daysWithCross1 / totalDays1) * 100 : na
pct2 = totalDays2 > 0 ? (daysWithCross2 / totalDays2) * 100 : na
pct3 = totalDays3 > 0 ? (daysWithCross3 / totalDays3) * 100 : na

// Visual markers
plotshape(inSess1 and didCross, title="Cross in 20:00 hour", style=shape.circle, location=location.abovebar, size=size.tiny)
plotshape(inSess2 and didCross, title="Cross in 01:00 hour", style=shape.circle, location=location.abovebar, size=size.tiny)
plotshape(inSess3 and didCross, title="Cross in 03:00-04:59 block", style=shape.circle, location=location.abovebar, size=size.tiny)

// Summary table
var table t = table.new(position.top_right, 4, 4, border_width=1)

if barstate.islast
    table.cell(t, 0, 0, "Window")
    table.cell(t, 1, 0, "Days Tested")
    table.cell(t, 2, 0, "Days With Cross")
    table.cell(t, 3, 0, "%")

    table.cell(t, 0, 1, "20:00")
    table.cell(t, 1, 1, str.tostring(totalDays1))
    table.cell(t, 2, 1, str.tostring(daysWithCross1))
    table.cell(t, 3, 1, str.tostring(pct1, "#.##"))

    table.cell(t, 0, 2, "01:00")
    table.cell(t, 1, 2, str.tostring(totalDays2))
    table.cell(t, 2, 2, str.tostring(daysWithCross2))
    table.cell(t, 3, 2, str.tostring(pct2, "#.##"))

    table.cell(t, 0, 3, "03:00-04:59")
    table.cell(t, 1, 3, str.tostring(totalDays3))
    table.cell(t, 2, 3, str.tostring(daysWithCross3))
    table.cell(t, 3, 3, str.tostring(pct3, "#.##"))
````
