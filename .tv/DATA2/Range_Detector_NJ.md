<!-- tradingview-pine-id: PUB;fdd9b4383c8148b2929a075c687ca137 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Range Detector [NJ]

Source: https://www.tradingview.com/script/pB6xqZvV-Range-Detector-NJ/

## Description

✧ OVERVIEW ✧

Range Detector identifies and highlights potential ranging market structures using pivot highs and lows combined with a two-stage confirmation process.
Confirmed ranges are displayed as boxes and remain active until price closes beyond the allowed tolerance.
[image]https://www.tradingview.com/x/ny0xJIAJ/[/image]

✧ SETTINGS ✧

Range Tolerance %
Controls how far price may close beyond the range before it is invalidated.

Range First Confirmation %
Controls the first retracement required after both range boundaries have formed.

Range Second Confirmation %
Controls the second reversal required after the first confirmation.

Bars to Confirm the Range
Controls how long the current candidate structure may remain unconfirmed before it expires.

Pivot High/Low Lookback
Controls pivot sensitivity. Lower values detect smaller and more frequent swings, while higher values focus on larger market structures.

✧ HOW IT WORKS ✧
[image]https://www.tradingview.com/x/ReXqIF0L/[/image]
Range Formation
The indicator uses pivot highs and lows to define potential range boundaries. Newer same-side pivots may replace earlier ones until both boundaries are established.

Two-Stage Confirmation
A range is confirmed only after two rotations.
With the default 70% / 50% settings:
High → Low: price retraces 70% toward the high, then returns to 50%.
Low → High: price retraces 70% toward the low, then returns to 50%.

Range Invalidation
The range remains active until price closes beyond a boundary by more than the selected tolerance, measured as a percentage of the range height.

Candidate Timeout
Unconfirmed candidates must complete the confirmation sequence within the selected number of bars. Otherwise, they are discarded. The timer may restart if a newer same-side pivot replaces the current candidate.

✧ VISUALIZATION ✧
[image]https://www.tradingview.com/x/SKkeKrUA/[/image]
Once confirmed, the range is displayed as a box between its upper and lower boundaries.

The box is drawn retrospectively from the earliest pivot used to form the range and extends forward until the range is invalidated.

Because pivot highs and lows require future bars to be confirmed, the beginning of a range can appear several bars before the indicator could have known that the pivot was valid in real time.

✧ USAGE ✧

Range Detector can be used to identify areas of:

Sideways price action
Consolidation
Mean-reversion conditions
Support and resistance
Potential breakout structures

The detected zones can provide additional market structure context for range trading, breakout analysis, or filtering trend-following setups.

As with any technical indicator, it is best used alongside other forms of analysis rather than as a standalone entry or exit signal.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CryptoNejc

//@version=6
indicator("Range Detector [NJ]", "RD [NJ]", overlay = true)

// ✧═════════════════✧
// ║      INPUTS      ║
// ✧═════════════════✧

t1 = "How far price may close beyond the range before invalidation."
t2 = "Required first retracement after the range boundaries are formed."
t3 = "Required return level after the first confirmation."
t4 = "Maximum bars allowed for the current range candidate to be confirmed."
t5 = "Sensitivity of pivot high/low detection."

showTolerance = input.bool(true, "Show tolerance lines")
rangeTol = input.int(22, "Range tolerance %", minval = 0, maxval = 100, tooltip = t1) / 100
rangeConf1 = input.int(70, "Range first confirmation %", minval = 10, maxval = 100, tooltip = t2) / 100
rangeConf2 = input.int(50, "Range second confirmation %", minval = 0, maxval = 100, tooltip = t3) / 100
confirmationTime = input.int(75, "Bars to confirm the range", minval = 1, tooltip = t4)
pivotLen = input.int(7, "Pivot high/low lookback", minval = 1, tooltip = t5)

// ✧════════════════════✧
// ║      VARIABLES      ║
// ✧════════════════════✧

var float newHigh = na
var float newLow  = na

var int barsHigh = na
var int barsLow  = na

var int candidateStartBar = na

var int resetBar = na

var bool inRange = false

var bool reachedFirstConf = false
var int reachedFirstConfBar = na

var box rangeBox = na

var line upperTolLine = na
var line lowerTolLine = na

// ✧═════════════════✧
// ║      PIVOTS      ║
// ✧═════════════════✧

pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)

pivotLow = ta.pivotlow(low, pivotLen, pivotLen)

pivotBar = bar_index - pivotLen

// ✧════════════════════════✧
// ║      CURRENT RANGE      ║
// ✧════════════════════════✧

rangeReady = not na(newHigh) and not na(newLow) and newHigh > newLow

rangeSize = rangeReady ? newHigh - newLow : na

upperTol = rangeReady ? newHigh + rangeSize * rangeTol : na

lowerTol = rangeReady ? newLow - rangeSize * rangeTol : na

// ✧══════════════════════════════════════════════════✧
// ║      INVALIDATE CANDIDATE OR CONFIRMED RANGE      ║
// ✧══════════════════════════════════════════════════✧

rangeInvalidated = rangeReady and (close > upperTol or close < lowerTol)

if rangeInvalidated

    newHigh := na
    newLow := na

    barsHigh := na
    barsLow := na

    candidateStartBar := na

    reachedFirstConf := false
    reachedFirstConfBar := na

    inRange := false

    resetBar := bar_index

    rangeBox := na
    
    upperTolLine := na
    lowerTolLine := na

// ✧════════════════════════════════✧
// ║      BUILD A NEW CANDIDATE      ║
// ✧════════════════════════════════✧

if not inRange
    validPivotHigh = not na(pivotHigh) and (na(resetBar) or pivotBar >= resetBar)
    validPivotLow = not na(pivotLow) and (na(resetBar) or pivotBar >= resetBar)

    if na(newHigh) and na(newLow)

        if validPivotHigh and not validPivotLow

            newHigh := pivotHigh
            barsHigh := pivotBar

            candidateStartBar := bar_index

            reachedFirstConf := false
            reachedFirstConfBar := na


        else if validPivotLow and not validPivotHigh

            newLow := pivotLow
            barsLow := pivotBar

            candidateStartBar := bar_index

            reachedFirstConf := false
            reachedFirstConfBar := na

    else if not na(newHigh) and na(newLow)

        if validPivotHigh and pivotBar > barsHigh

            newHigh := pivotHigh
            barsHigh := pivotBar

            candidateStartBar := bar_index

            reachedFirstConf := false
            reachedFirstConfBar := na

        if validPivotLow and pivotBar > barsHigh

            if pivotLow < newHigh

                newLow := pivotLow
                barsLow := pivotBar

            else

                newHigh := na
                barsHigh := na

                newLow := pivotLow
                barsLow := pivotBar

                candidateStartBar := bar_index

                reachedFirstConf := false
                reachedFirstConfBar := na

    else if not na(newLow) and na(newHigh)

        if validPivotLow and pivotBar > barsLow

            newLow := pivotLow
            barsLow := pivotBar

            candidateStartBar := bar_index

            reachedFirstConf := false
            reachedFirstConfBar := na

        if validPivotHigh and pivotBar > barsLow

            if pivotHigh > newLow

                newHigh := pivotHigh
                barsHigh := pivotBar

            else

                newLow := na
                barsLow := na

                newHigh := pivotHigh
                barsHigh := pivotBar

                candidateStartBar := bar_index

                reachedFirstConf := false
                reachedFirstConfBar := na

// ✧═════════════════════════════════════════════════════════✧
// ║      RECALCULATE RANGE AFTER POSSIBLE PIVOT CHANGES      ║
// ✧═════════════════════════════════════════════════════════✧

candidateReady = not inRange and not na(newHigh) and not na(newLow) and newHigh > newLow

// ✧════════════════════════✧
// ║      CONFIRM RANGE      ║
// ✧════════════════════════✧

if candidateReady
    currentRange = newHigh - newLow
    secondConfLevel = newLow + currentRange * rangeConf2

    if barsHigh < barsLow
        firstConfLevel = newLow + currentRange * rangeConf1

        if not reachedFirstConf and high >= firstConfLevel
            reachedFirstConf := true
            reachedFirstConfBar := bar_index

        if reachedFirstConf and bar_index > reachedFirstConfBar and low <= secondConfLevel
            inRange := true

    else if barsLow < barsHigh
        firstConfLevel = newHigh - currentRange * rangeConf1

        if not reachedFirstConf and low <= firstConfLevel
            reachedFirstConf := true
            reachedFirstConfBar := bar_index

        if reachedFirstConf and bar_index > reachedFirstConfBar and high >= secondConfLevel
            inRange := true

// ✧════════════════════════════✧
// ║      CANDIDATE TIMEOUT      ║
// ✧════════════════════════════✧

candidateExpired = not inRange and not na(candidateStartBar) and bar_index - candidateStartBar >= confirmationTime

if candidateExpired

    newHigh := na
    newLow := na

    barsHigh := na
    barsLow := na

    candidateStartBar := na

    reachedFirstConf := false
    reachedFirstConfBar := na

    resetBar := bar_index

// ✧═══════════════════════════════✧
// ║      PLOT CONFIRMED RANGE      ║
// ✧═══════════════════════════════✧

if inRange and na(rangeBox)
    rangeBox := box.new(left = math.min(barsHigh, barsLow), top = newHigh, right = bar_index, bottom = newLow, xloc = xloc.bar_index, border_color = color.rgb(0, 136, 100), border_width = 1, bgcolor = color.new(color.rgb(0, 136, 100), 80))

// ✧══════════════════════════════✧
// ║      EXTEND ACTIVE RANGE      ║
// ✧══════════════════════════════✧

if inRange and not na(rangeBox)
    box.set_right(rangeBox, bar_index)

// ✧══════════════════════════✧
// ║      TOLERANCE LINES      ║
// ✧══════════════════════════✧

if inRange and showTolerance and na(upperTolLine)
    rangeStart = math.min(barsHigh, barsLow)
    upperTolLine := line.new(x1 = rangeStart, y1 = upperTol, x2 = bar_index, y2 = upperTol, xloc = xloc.bar_index, color = color.rgb(120, 0, 32), style = line.style_dashed)
    lowerTolLine := line.new( x1 = rangeStart, y1 = lowerTol, x2 = bar_index, y2 = lowerTol, xloc = xloc.bar_index, color = color.rgb(120, 0, 32), style = line.style_dashed)

if inRange and showTolerance
    if not na(upperTolLine)
        line.set_x2(upperTolLine, bar_index)
    if not na(lowerTolLine)
        line.set_x2(lowerTolLine, bar_index)
````
