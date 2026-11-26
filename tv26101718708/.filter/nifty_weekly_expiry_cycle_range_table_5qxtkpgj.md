# NIFTY Weekly Expiry Cycle Range Table

- url: https://www.tradingview.com/script/5QXtKpgj-NIFTY-Weekly-Expiry-Cycle-Range-Table/
- type: indicator
- pine_id: PUB;93d3b77c22344c3f905e19087daa28e6
- version: 1.0

## Description

//@description NIFTY Weekly Expiry Cycle Range Table.
// This indicator tracks the NSE weekly expiry cycle from Wednesday to Tuesday,
// storing daily highs, lows, and cumulative ranges across the week.
// The table displays daily range expansion along with cumulative volatility analysis.
// All displayed values are rounded to the nearest integer for better readability.
// Indicator logic, calculations, and range structure remain unchanged.

## Source Code

````pine
//@version=5
indicator("NIFTY Weekly Expiry Cycle Range Table", overlay=true)

// =====================================================
// SETTINGS
// =====================================================
tablePos = position.bottom_left

// =====================================================
// DETECT NSE WEEK CYCLE (WED -> TUE)
// =====================================================
isNewCycle = dayofweek == dayofweek.wednesday and dayofweek != dayofweek[1]

// =====================================================
// DAILY VALUES
// =====================================================
dHigh = request.security(syminfo.tickerid, "D", high)
dLow  = request.security(syminfo.tickerid, "D", low)

// =====================================================
// STORE INDIVIDUAL DAILY DATA
// =====================================================
var float wedHigh = na
var float wedLow  = na

var float thuHigh = na
var float thuLow  = na

var float friHigh = na
var float friLow  = na

var float monHigh = na
var float monLow  = na

var float tueHigh = na
var float tueLow  = na

// =====================================================
// RESET NEW CYCLE
// =====================================================
if isNewCycle
    wedHigh := na
    wedLow  := na

    thuHigh := na
    thuLow  := na

    friHigh := na
    friLow  := na

    monHigh := na
    monLow  := na

    tueHigh := na
    tueLow  := na

// =====================================================
// SAVE DAILY DATA
// =====================================================
if dayofweek == dayofweek.wednesday
    wedHigh := dHigh
    wedLow  := dLow

if dayofweek == dayofweek.thursday
    thuHigh := dHigh
    thuLow  := dLow

if dayofweek == dayofweek.friday
    friHigh := dHigh
    friLow  := dLow

if dayofweek == dayofweek.monday
    monHigh := dHigh
    monLow  := dLow

if dayofweek == dayofweek.tuesday
    tueHigh := dHigh
    tueLow  := dLow

// =====================================================
// CUMULATIVE HIGH / LOW
// =====================================================
high1 = wedHigh
low1  = wedLow

high2 = math.max(wedHigh, thuHigh)
low2  = math.min(wedLow, thuLow)

high3 = math.max(math.max(wedHigh, thuHigh), friHigh)
low3  = math.min(math.min(wedLow, thuLow), friLow)

high4 = math.max(math.max(math.max(wedHigh, thuHigh), friHigh), monHigh)
low4  = math.min(math.min(math.min(wedLow, thuLow), friLow), monLow)

high5 = math.max(math.max(math.max(math.max(wedHigh, thuHigh), friHigh), monHigh), tueHigh)
low5  = math.min(math.min(math.min(math.min(wedLow, thuLow), friLow), monLow), tueLow)

// =====================================================
// RANGES
// =====================================================
range1 = high1 - low1
range2 = high2 - low2
range3 = high3 - low3
range4 = high4 - low4
range5 = high5 - low5

// =====================================================
// DAILY RANGES
// =====================================================
wedRange = wedHigh - wedLow
thuRange = thuHigh - thuLow
friRange = friHigh - friLow
monRange = monHigh - monLow
tueRange = tueHigh - tueLow

// =====================================================
// TABLE
// =====================================================
var table t = table.new(position.bottom_left, 5, 12, border_width=1)

if barstate.islast

    // =================================================
    // HEADER
    // =================================================
    table.cell(t, 0, 0, "Period", bgcolor=color.blue, text_color=color.white)
    table.cell(t, 1, 0, "High", bgcolor=color.blue, text_color=color.white)
    table.cell(t, 2, 0, "Low", bgcolor=color.blue, text_color=color.white)
    table.cell(t, 3, 0, "Range", bgcolor=color.blue, text_color=color.white)
    table.cell(t, 4, 0, "Type", bgcolor=color.blue, text_color=color.white)

    // =================================================
    // DAILY DATA
    // =================================================
    table.cell(t, 0, 1, "Wednesday")
    table.cell(t, 1, 1, str.tostring(math.round(wedHigh)))
    table.cell(t, 2, 1, str.tostring(math.round(wedLow)))
    table.cell(t, 3, 1, str.tostring(math.round(wedRange)))
    table.cell(t, 4, 1, "1 Day", bgcolor=color.green, text_color=color.white)

    table.cell(t, 0, 2, "Thursday")
    table.cell(t, 1, 2, str.tostring(math.round(thuHigh)))
    table.cell(t, 2, 2, str.tostring(math.round(thuLow)))
    table.cell(t, 3, 2, str.tostring(math.round(thuRange)))
    table.cell(t, 4, 2, "Daily", bgcolor=color.teal, text_color=color.white)

    table.cell(t, 0, 3, "Friday")
    table.cell(t, 1, 3, str.tostring(math.round(friHigh)))
    table.cell(t, 2, 3, str.tostring(math.round(friLow)))
    table.cell(t, 3, 3, str.tostring(math.round(friRange)))
    table.cell(t, 4, 3, "Daily", bgcolor=color.orange, text_color=color.white)

    table.cell(t, 0, 4, "Monday")
    table.cell(t, 1, 4, str.tostring(math.round(monHigh)))
    table.cell(t, 2, 4, str.tostring(math.round(monLow)))
    table.cell(t, 3, 4, str.tostring(math.round(monRange)))
    table.cell(t, 4, 4, "Daily", bgcolor=color.purple, text_color=color.white)

    table.cell(t, 0, 5, "Tuesday")
    table.cell(t, 1, 5, str.tostring(math.round(tueHigh)))
    table.cell(t, 2, 5, str.tostring(math.round(tueLow)))
    table.cell(t, 3, 5, str.tostring(math.round(tueRange)))
    table.cell(t, 4, 5, "Expiry", bgcolor=color.red, text_color=color.white)

    // =================================================
    // CUMULATIVE SECTION HEADER
    // =================================================
    table.cell(t, 0, 6, "Cumulative", bgcolor=color.black, text_color=color.white)
    table.cell(t, 1, 6, "", bgcolor=color.black)
    table.cell(t, 2, 6, "", bgcolor=color.black)
    table.cell(t, 3, 6, "", bgcolor=color.black)
    table.cell(t, 4, 6, "", bgcolor=color.black)

    // =================================================
    // 1 DAY
    // =================================================
    table.cell(t, 0, 7, "1 Day")
    table.cell(t, 1, 7, str.tostring(math.round(high1)))
    table.cell(t, 2, 7, str.tostring(math.round(low1)))
    table.cell(t, 3, 7, str.tostring(math.round(range1)))
    table.cell(t, 4, 7,
         range1 > 300 ? "Expanded" : "Normal",
         bgcolor = range1 > 300 ? color.red : color.green,
         text_color=color.white)

    // =================================================
    // 2 DAYS
    // =================================================
    table.cell(t, 0, 8, "2 Days")
    table.cell(t, 1, 8, str.tostring(math.round(high2)))
    table.cell(t, 2, 8, str.tostring(math.round(low2)))
    table.cell(t, 3, 8, str.tostring(math.round(range2)))
    table.cell(t, 4, 8,
         range2 > 400 ? "Expanded" : "Balanced",
         bgcolor = range2 > 400 ? color.orange : color.teal,
         text_color=color.white)

    // =================================================
    // 3 DAYS
    // =================================================
    table.cell(t, 0, 9, "3 Days")
    table.cell(t, 1, 9, str.tostring(math.round(high3)))
    table.cell(t, 2, 9, str.tostring(math.round(low3)))
    table.cell(t, 3, 9, str.tostring(math.round(range3)))
    table.cell(t, 4, 9,
         range3 > 500 ? "Trend" : "Balanced",
         bgcolor = range3 > 500 ? color.red : color.blue,
         text_color=color.white)

    // =================================================
    // 4 DAYS
    // =================================================
    table.cell(t, 0, 10, "4 Days")
    table.cell(t, 1, 10, str.tostring(math.round(high4)))
    table.cell(t, 2, 10, str.tostring(math.round(low4)))
    table.cell(t, 3, 10, str.tostring(math.round(range4)))
    table.cell(t, 4, 10,
         range4 > 600 ? "Volatile" : "Controlled",
         bgcolor = range4 > 600 ? color.maroon : color.green,
         text_color=color.white)

    // =================================================
    // FULL WEEK
    // =================================================
    table.cell(t, 0, 11, "Expiry Week")
    table.cell(t, 1, 11, str.tostring(math.round(high5)))
    table.cell(t, 2, 11, str.tostring(math.round(low5)))
    table.cell(t, 3, 11, str.tostring(math.round(range5)))
    table.cell(t, 4, 11,
         range5 > 700 ? "Extreme" : "Normal",
         bgcolor = range5 > 700 ? color.purple : color.navy,
         text_color=color.white)
````
