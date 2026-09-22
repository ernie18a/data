<!-- tradingview-pine-id: PUB;f4f30e60d1f44d6991f602ec7401c173 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# RangeDetector

Source: https://www.tradingview.com/script/zAAYiaIH-Range-Detector-Library/

## Description

Library: Range Detector

For more information about the Range Detector, see the indicator version:
https://www.tradingview.com/script/pB6xqZvV-Range-Detector-NJ/

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CryptoNejc

//@version=6
library("RangeDetector", true)

export detect() =>

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

    // ✧═════════════════✧
    // ║      PIVOTS      ║
    // ✧═════════════════✧

    pivotHigh = ta.pivothigh(high, 7, 7)

    pivotLow = ta.pivotlow(low, 7, 7)

    pivotBar = bar_index - 7

    // ✧════════════════════════✧
    // ║      CURRENT RANGE      ║
    // ✧════════════════════════✧

    rangeReady = not na(newHigh) and not na(newLow) and newHigh > newLow

    rangeSize = rangeReady ? newHigh - newLow : na

    upperTol = rangeReady ? newHigh + rangeSize * 0.22 : na

    lowerTol = rangeReady ? newLow - rangeSize * 0.22 : na

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
        secondConfLevel = newLow + currentRange * 0.5

        if barsHigh < barsLow
            firstConfLevel = newLow + currentRange * 0.70

            if not reachedFirstConf and high >= firstConfLevel
                reachedFirstConf := true
                reachedFirstConfBar := bar_index

            if reachedFirstConf and bar_index > reachedFirstConfBar and low <= secondConfLevel
                inRange := true

        else if barsLow < barsHigh
            firstConfLevel = newHigh - currentRange * 0.70

            if not reachedFirstConf and low <= firstConfLevel
                reachedFirstConf := true
                reachedFirstConfBar := bar_index

            if reachedFirstConf and bar_index > reachedFirstConfBar and high >= secondConfLevel
                inRange := true

    // ✧════════════════════════════✧
    // ║      CANDIDATE TIMEOUT      ║
    // ✧════════════════════════════✧

    candidateExpired = not inRange and not na(candidateStartBar) and bar_index - candidateStartBar >= 75

    if candidateExpired

        newHigh := na
        newLow := na

        barsHigh := na
        barsLow := na

        candidateStartBar := na

        reachedFirstConf := false
        reachedFirstConfBar := na

        resetBar := bar_index

    inRange
````
