<!-- tradingview-pine-id: PUB;11860a220d804f12b65973446faa3cba -->
<!-- tradingviewscripts-format: 1 -->
# SPX Next-Day Movement Statistics V1

Source: https://www.tradingview.com/script/MNpq7JFO-SPX-Next-Day-Movement-Statistics-V1/

## Description

This indicator is designed to analyze the next-day movement of the S&P 500 Index (SPX) using the previous regular-session close as the reference entry price.

It is intended for traders who want to study how often SPX reaches a specified upside or downside target during the following trading session.

Main Features
Uses the previous SPX regular-session close as the entry reference.
Calculates customizable Call and Put targets in SPX points.
Identifies whether the upside or downside target was reached.
Shows which target was reached first.
Marks cases where both targets were reached within the same 5-minute candle.
Calculates the maximum upside and downside movement from the previous close.
Tracks Higher High and Lower Low occurrences compared with the previous session.
Provides overall and monthly statistics.
Includes a movement distribution table for multiple target distances.
Allows users to select a specific backtest period.
Statistics Included
Call Target hit rate
Put Target hit rate
Either Direction hit rate
Both Directions hit rate
No Target rate
Call First rate
Put First rate
Same Candle occurrences
Average upside movement
Average downside movement
Largest upside and downside movements
Monthly performance statistics
Recommended Usage

This indicator is designed for the 5-minute SPX chart.

For more accurate First-Hit results, a lower timeframe may provide better sequencing. If both targets are reached within the same 5-minute candle, the indicator reports the result as Both Same Candle, because the exact intrabar order cannot be confirmed.

---

## Source Code

````pine
//@version=6
indicator(
     "SPX Next-Day Movement Statistics V1",
     shorttitle = "SPX Next-Day V1",
     overlay = true,
     max_labels_count = 500
)

//=============================================================================
// Inputs
//=============================================================================

string TZ = "America/New_York"

regularSession = input.session(
     "0930-1600",
     "Regular Market Session"
)

targetPoints = input.float(
     20.0,
     "Target Distance — SPX Points",
     minval = 1.0,
     step = 1.0
)

startDate = input.time(
     timestamp("2025-01-01"),
     "Backtest Start Date"
)

endDate = input.time(
     timestamp("2027-12-31"),
     "Backtest End Date"
)

showEntry = input.bool(true, "Show Entry Price")
showTargets = input.bool(true, "Show Call and Put Targets")
showSignals = input.bool(true, "Show First-Hit Signals")
showMonthlyTable = input.bool(true, "Show Monthly Table")

monthsToShow = input.int(
     12,
     "Months to Show",
     minval = 1,
     maxval = 18
)

//=============================================================================
// Session detection
//=============================================================================

bool inSession = not na(
     time(
         timeframe.period,
         regularSession,
         TZ
     )
)

int dayKey =
     year(time, TZ) * 10000 +
     month(time, TZ) * 100 +
     dayofmonth(time, TZ)

int monthKey =
     year(time, TZ) * 100 +
     month(time, TZ)

bool newSession =
     inSession and
     (
         not inSession[1] or
         dayKey != dayKey[1]
     )

//=============================================================================
// Session price storage
//=============================================================================

var float sessionHigh = na
var float sessionLow = na
var float sessionClose = na

// Previous session information used for the next-day test
var float entryPrice = na
var float callTarget = na
var float putTarget = na

var float referenceHigh = na
var float referenceLow = na

var int activeDayKey = na
var int activeMonthKey = na

var bool testActive = false
var bool callHit = false
var bool putHit = false

// 0 = no target
// 1 = call first
// 2 = put first
// 3 = both on same candle
var int firstHit = 0

var float maximumUpMove = 0.0
var float maximumDownMove = 0.0

//=============================================================================
// Overall statistics
//=============================================================================

var int totalDays = 0

var int callHitDays = 0
var int putHitDays = 0
var int bothHitDays = 0
var int noHitDays = 0

var int callFirstDays = 0
var int putFirstDays = 0
var int sameBarDays = 0

var int higherHighDays = 0
var int lowerLowDays = 0

var float totalUpMove = 0.0
var float totalDownMove = 0.0

var float largestUpMove = 0.0
var float largestDownMove = 0.0

//=============================================================================
// Monthly arrays
//=============================================================================

var monthKeys = array.new_int()
var monthDays = array.new_int()

var monthCalls = array.new_int()
var monthPuts = array.new_int()
var monthBoth = array.new_int()
var monthNone = array.new_int()

var monthCallFirst = array.new_int()
var monthPutFirst = array.new_int()

var monthHH = array.new_int()
var monthLL = array.new_int()

//=============================================================================
// Functions
//=============================================================================

getMonthIndex(int key) =>
    int index = array.indexof(monthKeys, key)

    if index == -1
        array.push(monthKeys, key)
        array.push(monthDays, 0)

        array.push(monthCalls, 0)
        array.push(monthPuts, 0)
        array.push(monthBoth, 0)
        array.push(monthNone, 0)

        array.push(monthCallFirst, 0)
        array.push(monthPutFirst, 0)

        array.push(monthHH, 0)
        array.push(monthLL, 0)

        index := array.size(monthKeys) - 1

    index

increaseArrayValue(array<int> dataArray, int index) =>
    array.set(
         dataArray,
         index,
         array.get(dataArray, index) + 1
    )

getPercentage(int value, int total) =>
    total > 0 ? value * 100.0 / total : 0.0

getMonthName(int key) =>
    int yearNumber = int(math.floor(key / 100))
    int monthNumber = key % 100

    string name = switch monthNumber
        1  => "Jan"
        2  => "Feb"
        3  => "Mar"
        4  => "Apr"
        5  => "May"
        6  => "Jun"
        7  => "Jul"
        8  => "Aug"
        9  => "Sep"
        10 => "Oct"
        11 => "Nov"
        12 => "Dec"
        => "N/A"

    name + " " + str.tostring(yearNumber)

//=============================================================================
// Variables used for plotting first-hit signals
//=============================================================================

bool callFirstSignal = false
bool putFirstSignal = false
bool sameBarSignal = false

// Reset every candle
callFirstSignal := false
putFirstSignal := false
sameBarSignal := false

//=============================================================================
// Finalize previous test when a new session begins
//=============================================================================

if newSession
    if testActive
        bool madeHigherHigh =
             not na(referenceHigh) and
             sessionHigh > referenceHigh

        bool madeLowerLow =
             not na(referenceLow) and
             sessionLow < referenceLow

        totalDays += 1

        if callHit
            callHitDays += 1

        if putHit
            putHitDays += 1

        if callHit and putHit
            bothHitDays += 1

        if not callHit and not putHit
            noHitDays += 1

        if firstHit == 1
            callFirstDays += 1

        if firstHit == 2
            putFirstDays += 1

        if firstHit == 3
            sameBarDays += 1

        if madeHigherHigh
            higherHighDays += 1

        if madeLowerLow
            lowerLowDays += 1

        totalUpMove += maximumUpMove
        totalDownMove += maximumDownMove

        largestUpMove := math.max(
             largestUpMove,
             maximumUpMove
        )

        largestDownMove := math.max(
             largestDownMove,
             maximumDownMove
        )

        //---------------------------------------------------------------------
        // Monthly statistics
        //---------------------------------------------------------------------

        int index = getMonthIndex(activeMonthKey)

        increaseArrayValue(monthDays, index)

        if callHit
            increaseArrayValue(monthCalls, index)

        if putHit
            increaseArrayValue(monthPuts, index)

        if callHit and putHit
            increaseArrayValue(monthBoth, index)

        if not callHit and not putHit
            increaseArrayValue(monthNone, index)

        if firstHit == 1
            increaseArrayValue(monthCallFirst, index)

        if firstHit == 2
            increaseArrayValue(monthPutFirst, index)

        if madeHigherHigh
            increaseArrayValue(monthHH, index)

        if madeLowerLow
            increaseArrayValue(monthLL, index)

    //-------------------------------------------------------------------------
    // Save previous session before resetting the new session
    //-------------------------------------------------------------------------

    float previousClose = sessionClose
    float previousHigh = sessionHigh
    float previousLow = sessionLow

    bool dateAllowed =
         time >= startDate and
         time <= endDate

    if not na(previousClose) and dateAllowed
        entryPrice := previousClose

        callTarget := entryPrice + targetPoints
        putTarget := entryPrice - targetPoints

        referenceHigh := previousHigh
        referenceLow := previousLow

        activeDayKey := dayKey
        activeMonthKey := monthKey

        callHit := false
        putHit := false
        firstHit := 0

        maximumUpMove := 0.0
        maximumDownMove := 0.0

        testActive := true
    else
        testActive := false

    // Start tracking the new session
    sessionHigh := high
    sessionLow := low
    sessionClose := close

//=============================================================================
// Update session values
//=============================================================================

if inSession and not newSession
    sessionHigh := na(sessionHigh) ?
         high :
         math.max(sessionHigh, high)

    sessionLow := na(sessionLow) ?
         low :
         math.min(sessionLow, low)

    sessionClose := close

//=============================================================================
// Test today's movement from yesterday's close
//=============================================================================

bool validTestBar =
     testActive and
     inSession and
     dayKey == activeDayKey

if validTestBar
    maximumUpMove := math.max(
         maximumUpMove,
         high - entryPrice
    )

    maximumDownMove := math.max(
         maximumDownMove,
         entryPrice - low
    )

    bool newCallHit =
         not callHit and
         high >= callTarget

    bool newPutHit =
         not putHit and
         low <= putTarget

    if firstHit == 0
        if newCallHit and newPutHit
            firstHit := 3
            sameBarSignal := true

        else if newCallHit
            firstHit := 1
            callFirstSignal := true

        else if newPutHit
            firstHit := 2
            putFirstSignal := true

    if newCallHit
        callHit := true

    if newPutHit
        putHit := true

//=============================================================================
// Lines
//=============================================================================

plot(
     showEntry and validTestBar ?
         entryPrice :
         na,
     title = "Previous Close",
     color = color.blue,
     linewidth = 2,
     style = plot.style_linebr
)

plot(
     showTargets and validTestBar ?
         callTarget :
         na,
     title = "Call Target",
     color = color.green,
     linewidth = 1,
     style = plot.style_linebr
)

plot(
     showTargets and validTestBar ?
         putTarget :
         na,
     title = "Put Target",
     color = color.red,
     linewidth = 1,
     style = plot.style_linebr
)

//=============================================================================
// Signals
//=============================================================================

plotshape(
     showSignals and callFirstSignal,
     title = "Call First",
     text = "CALL\nFIRST",
     style = shape.labelup,
     location = location.belowbar,
     color = color.green,
     textcolor = color.white,
     size = size.tiny
)

plotshape(
     showSignals and putFirstSignal,
     title = "Put First",
     text = "PUT\nFIRST",
     style = shape.labeldown,
     location = location.abovebar,
     color = color.red,
     textcolor = color.white,
     size = size.tiny
)

plotshape(
     showSignals and sameBarSignal,
     title = "Both Same Candle",
     text = "BOTH",
     style = shape.labeldown,
     location = location.abovebar,
     color = color.orange,
     textcolor = color.white,
     size = size.tiny
)

//=============================================================================
// Calculations
//=============================================================================

float callRate = getPercentage(callHitDays, totalDays)
float putRate = getPercentage(putHitDays, totalDays)

float callFirstRate = getPercentage(
     callFirstDays,
     totalDays
)

float putFirstRate = getPercentage(
     putFirstDays,
     totalDays
)

float hhRate = getPercentage(
     higherHighDays,
     totalDays
)

float llRate = getPercentage(
     lowerLowDays,
     totalDays
)

float averageUp =
     totalDays > 0 ?
     totalUpMove / totalDays :
     0.0

float averageDown =
     totalDays > 0 ?
     totalDownMove / totalDays :
     0.0

//=============================================================================
// Main table
//=============================================================================

var table statsTable = table.new(
     position.top_right,
     2,
     13,
     border_width = 1
)

if barstate.islast
    table.cell(
         statsTable,
         0,
         0,
         "SPX NEXT-DAY",
         bgcolor = color.blue,
         text_color = color.white
    )

    table.cell(
         statsTable,
         1,
         0,
         str.tostring(targetPoints, "#") + " pts",
         bgcolor = color.blue,
         text_color = color.white
    )

    table.cell(statsTable, 0, 1, "Completed Days")
    table.cell(statsTable, 1, 1, str.tostring(totalDays))

    table.cell(statsTable, 0, 2, "Call Target")
    table.cell(
         statsTable,
         1,
         2,
         str.tostring(callHitDays) +
         " | " +
         str.tostring(callRate, "#.0") +
         "%"
    )

    table.cell(statsTable, 0, 3, "Put Target")
    table.cell(
         statsTable,
         1,
         3,
         str.tostring(putHitDays) +
         " | " +
         str.tostring(putRate, "#.0") +
         "%"
    )

    table.cell(statsTable, 0, 4, "Call First")
    table.cell(
         statsTable,
         1,
         4,
         str.tostring(callFirstDays) +
         " | " +
         str.tostring(callFirstRate, "#.0") +
         "%"
    )

    table.cell(statsTable, 0, 5, "Put First")
    table.cell(
         statsTable,
         1,
         5,
         str.tostring(putFirstDays) +
         " | " +
         str.tostring(putFirstRate, "#.0") +
         "%"
    )

    table.cell(statsTable, 0, 6, "Both Hit")
    table.cell(statsTable, 1, 6, str.tostring(bothHitDays))

    table.cell(statsTable, 0, 7, "No Target")
    table.cell(statsTable, 1, 7, str.tostring(noHitDays))

    table.cell(statsTable, 0, 8, "Higher High")
    table.cell(
         statsTable,
         1,
         8,
         str.tostring(higherHighDays) +
         " | " +
         str.tostring(hhRate, "#.0") +
         "%"
    )

    table.cell(statsTable, 0, 9, "Lower Low")
    table.cell(
         statsTable,
         1,
         9,
         str.tostring(lowerLowDays) +
         " | " +
         str.tostring(llRate, "#.0") +
         "%"
    )

    table.cell(statsTable, 0, 10, "Average Up")
    table.cell(
         statsTable,
         1,
         10,
         str.tostring(averageUp, "#.00") + " pts"
    )

    table.cell(statsTable, 0, 11, "Average Down")
    table.cell(
         statsTable,
         1,
         11,
         str.tostring(averageDown, "#.00") + " pts"
    )

    table.cell(statsTable, 0, 12, "Largest Up / Down")
    table.cell(
         statsTable,
         1,
         12,
         str.tostring(largestUpMove, "#.0") +
         " / " +
         str.tostring(largestDownMove, "#.0")
    )

//=============================================================================
// Monthly table
//=============================================================================

var table monthlyTable = table.new(
     position.bottom_right,
     7,
     19,
     border_width = 1
)

if barstate.islast
    table.clear(monthlyTable, 0, 0, 6, 18)

    if showMonthlyTable
        table.cell(monthlyTable, 0, 0, "Month", bgcolor = color.blue, text_color = color.white)
        table.cell(monthlyTable, 1, 0, "Days", bgcolor = color.blue, text_color = color.white)
        table.cell(monthlyTable, 2, 0, "Call", bgcolor = color.green, text_color = color.white)
        table.cell(monthlyTable, 3, 0, "Put", bgcolor = color.red, text_color = color.white)
        table.cell(monthlyTable, 4, 0, "C First", bgcolor = color.green, text_color = color.white)
        table.cell(monthlyTable, 5, 0, "P First", bgcolor = color.red, text_color = color.white)
        table.cell(monthlyTable, 6, 0, "HH / LL", bgcolor = color.orange, text_color = color.white)

        int availableMonths = array.size(monthKeys)

        int displayCount = math.min(
             monthsToShow,
             availableMonths
        )

        if displayCount > 0
            int firstIndex =
                 availableMonths -
                 displayCount

            for row = 0 to displayCount - 1
                int index = firstIndex + row
                int tableRow = row + 1

                int days = array.get(monthDays, index)
                int calls = array.get(monthCalls, index)
                int puts = array.get(monthPuts, index)

                int callsFirst = array.get(monthCallFirst, index)
                int putsFirst = array.get(monthPutFirst, index)

                int higherHighs = array.get(monthHH, index)
                int lowerLows = array.get(monthLL, index)

                table.cell(
                     monthlyTable,
                     0,
                     tableRow,
                     getMonthName(
                         array.get(monthKeys, index)
                     )
                )

                table.cell(
                     monthlyTable,
                     1,
                     tableRow,
                     str.tostring(days)
                )

                table.cell(
                     monthlyTable,
                     2,
                     tableRow,
                     str.tostring(calls) +
                     "\n" +
                     str.tostring(
                         getPercentage(calls, days),
                         "#"
                     ) +
                     "%"
                )

                table.cell(
                     monthlyTable,
                     3,
                     tableRow,
                     str.tostring(puts) +
                     "\n" +
                     str.tostring(
                         getPercentage(puts, days),
                         "#"
                     ) +
                     "%"
                )

                table.cell(
                     monthlyTable,
                     4,
                     tableRow,
                     str.tostring(callsFirst)
                )

                table.cell(
                     monthlyTable,
                     5,
                     tableRow,
                     str.tostring(putsFirst)
                )

                table.cell(
                     monthlyTable,
                     6,
                     tableRow,
                     str.tostring(higherHighs) +
                     " / " +
                     str.tostring(lowerLows)
                )

//=============================================================================
// Timeframe warning
//=============================================================================

var label warningLabel = na

if barstate.islast
    if not timeframe.isintraday
        if na(warningLabel)
            warningLabel := label.new(
                 bar_index,
                 high,
                 "Use an intraday chart.\nRecommended timeframe: 5 minutes.",
                 style = label.style_label_down,
                 color = color.red,
                 textcolor = color.white
            )
    else
        if not na(warningLabel)
            label.delete(warningLabel)
            warningLabel := na
````
