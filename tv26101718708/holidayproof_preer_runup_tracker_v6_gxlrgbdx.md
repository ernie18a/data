# Holiday-Proof Pre-ER Run-Up Tracker (v6)

- url: https://www.tradingview.com/script/gXlrgbdX-Holiday-Proof-Pre-ER-Run-Up-Tracker-v6/
- type: indicator
- pine_id: PUB;b4d1d08d408a44bba5692cdc8a790b69
- version: 3.0

## Description

Calculates the pre-earnings move X # of weeks before earnings, from Monday opening price to closing price of the last weekday before earnings (typically Friday). It adjusts for holidays.

Start and exit arrows indicate the date range used for calculations.

Average and median values ignore whether the move was up or down.

## Source Code

````pine
//@version=6
indicator("Holiday-Proof Pre-ER Run-Up Tracker (v6 + Max Move)", overlay=true, max_labels_count=500)

// 1. User Inputs
weeksBefore  = input.int(2, title="Weeks Before ER to Start (e.g. 2)", minval=1)
displayMode  = input.string("Percent", title="Display Mode", options=["Percent", "Dollar", "ATR"])
atrLength    = input.int(10, title="ATR Length", minval=1) 
cyclesToShow = input.int(6, title="Cycles to Track", minval=1, maxval=20)
tableStyle   = input.string("Average & Median + Individuals", title="Table Display Mode", options=["Average & Median + Individuals", "Average & Median Only"])
showShapes   = input.bool(true, title="Display Start/Exit Visual Arrows?")

// 2. Continuous Data Streams
currentATR = ta.atr(atrLength) 

// 3. Detect Actual Historical Earnings Days
epsActual = request.earnings(syminfo.tickerid, earnings.actual, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
isEarningsDay = ta.change(epsActual) != 0.0

// Constants for Calendar Math (in Milliseconds)
ONE_DAY_MS = 86400000

var float[] historicalMoves = array.new_float(0)
var float[] historicalMaxMoves = array.new_float(0) 

// Helper function to format strings based on display mode
formatMove(float value, string mode, bool forceAbsolute = false) =>
    string formatted = ""
    if mode == "Percent"
        formatted := str.tostring(math.round(value, 2)) + "%"
    else if mode == "ATR"
        formatted := str.tostring(math.round(value, 2)) + " x ATR"
    else if mode == "Dollar"
        if forceAbsolute
            formatted := "$" + str.tostring(math.round(value, 2))
        else
            string prefix = value >= 0.0 ? "+$" : "-$"
            formatted := prefix + str.tostring(math.abs(math.round(value, 2)))
    formatted

// 4. Calculate Windows Forward/Backward using True Time Metrics
if isEarningsDay
    int erDayOfWeek = dayofweek(time)
    int daysToErMonday = erDayOfWeek - dayofweek.monday
    int erMondayTime = time - (daysToErMonday * ONE_DAY_MS)
    
    int targetMondayTime = erMondayTime - (weeksBefore * 7 * ONE_DAY_MS)
    int targetFridayTime = erMondayTime - (1 * 7 * ONE_DAY_MS) + (4 * ONE_DAY_MS) 
    
    float entryPrice = na
    float entryATR = na
    int entryBarIdx = na
    
    float exitPrice = na
    int exitBarIdx = na
    
    int startLookbackIdx = na
    int endLookbackIdx = na
    
    // Pass 1: Scan for Friday/Thursday first, strictly constrained to the week before ER
    for lookback = 0 to 250
        int barTime = time[lookback]
        if (barTime <= targetFridayTime and barTime >= targetFridayTime - (3 * ONE_DAY_MS))
            if dayofweek(barTime) == dayofweek.friday or dayofweek(barTime) == dayofweek.thursday 
                exitPrice := close[lookback]
                exitBarIdx := bar_index[lookback]
                endLookbackIdx := lookback
                break 

    // Pass 2: Search for Monday in the target starting week (Strict 3-day window constraints)
    for lookback = 0 to 250
        int barTime = time[lookback]
        if (barTime >= targetMondayTime and barTime <= targetMondayTime + (3 * ONE_DAY_MS))
            if dayofweek(barTime) == dayofweek.monday
                entryPrice := open[lookback] 
                entryATR := currentATR[lookback]
                entryBarIdx := bar_index[lookback]
                startLookbackIdx := lookback
                break

    // Fallback: Only checks Tuesday of the *same* target week if Monday was a market holiday
    if na(entryPrice)
        for lookback = 0 to 250
            int barTime = time[lookback]
            if (barTime >= targetMondayTime and barTime <= targetMondayTime + (3 * ONE_DAY_MS))
                if dayofweek(barTime) == dayofweek.tuesday
                    entryPrice := open[lookback] 
                    entryATR := currentATR[lookback]
                    entryBarIdx := bar_index[lookback]
                    startLookbackIdx := lookback
                    break

    if not na(entryPrice) and not na(exitPrice) and not na(startLookbackIdx) and not na(endLookbackIdx)
        if showShapes
            label.new(x=entryBarIdx, y=na, text="▲\nSTART", color=color.new(color.white, 100), textcolor=color.aqua, style=label.style_none, yloc=yloc.belowbar)
            label.new(x=exitBarIdx, y=na, text="EXIT\n▼", color=color.new(color.white, 100), textcolor=color.fuchsia, style=label.style_none, yloc=yloc.abovebar)
            
        float highestHighInRange = high[endLookbackIdx]
        float lowestLowInRange = low[endLookbackIdx]
        
        for scanIdx = endLookbackIdx to startLookbackIdx
            if high[scanIdx] > highestHighInRange
                highestHighInRange := high[scanIdx]
            if low[scanIdx] < lowestLowInRange
                lowestLowInRange := low[scanIdx]
                
        float maxUpwardDollarMove = highestHighInRange - entryPrice
        float maxDownwardDollarMove = lowestLowInRange - entryPrice
        
        float maxRawMove = math.abs(maxUpwardDollarMove) >= math.abs(maxDownwardDollarMove) ? maxUpwardDollarMove : maxDownwardDollarMove

        float rawDiff = exitPrice - entryPrice
        float calculatedMove = na
        float calculatedMaxMove = na
        
        if displayMode == "Percent" and entryPrice > 0.0
            calculatedMove := (rawDiff / entryPrice) * 100.0
            calculatedMaxMove := (maxRawMove / entryPrice) * 100.0
        else if displayMode == "Dollar"
            calculatedMove := rawDiff
            calculatedMaxMove := maxRawMove
        else if displayMode == "ATR" and entryATR > 0.0
            calculatedMove := rawDiff / entryATR
            calculatedMaxMove := maxRawMove / entryATR
            
        if not na(calculatedMove) and not na(calculatedMaxMove)
            array.unshift(historicalMoves, calculatedMove)
            array.unshift(historicalMaxMoves, calculatedMaxMove)
            
            color textCol = calculatedMove >= 0.0 ? color.green : color.red
            label.new(bar_index, high, text=formatMove(calculatedMove, displayMode), color=textCol, textcolor=color.white, style=label.style_label_down, yloc=yloc.abovebar)

// 5. Build Dynamic Double-Column Aggregator Table
bool showIndividuals = (tableStyle == "Average & Median + Individuals")

int rowsToDisplay = 0
if array.size(historicalMoves) > 0
    rowsToDisplay := math.min(cyclesToShow, array.size(historicalMoves))

int maxTableRows = 1 + cyclesToShow + 2
var table infoTable = table.new(position = position.top_right, columns = 3, rows = maxTableRows, bgcolor = color.new(color.black, 20), border_width = 1, border_color = color.gray)

// TEXT SIZE MODIFIER: Shrunk from default to small
string tblTextSize = size.small 

if barstate.islast and rowsToDisplay > 0
    table.cell(infoTable, 0, 0, "Past Cycle", text_color=color.white, bgcolor=color.gray, text_size=tblTextSize)
    table.cell(infoTable, 1, 0, "Close Move", text_color=color.white, bgcolor=color.gray, text_size=tblTextSize)
    table.cell(infoTable, 2, 0, "Peak Move", text_color=color.white, bgcolor=color.gray, text_size=tblTextSize)
    
    float runningAbsoluteSum = 0.0
    float runningMaxAbsoluteSum = 0.0
    var float[] absMovesArray = array.new_float(0)
    var float[] absMaxMovesArray = array.new_float(0)
    array.clear(absMovesArray)
    array.clear(absMaxMovesArray)
    
    int currentRow = 1
    for i = 0 to rowsToDisplay - 1
        float moveVal = array.get(historicalMoves, i)
        float maxMoveVal = array.get(historicalMaxMoves, i)
        
        float absVal = math.abs(moveVal)
        float absMaxVal = math.abs(maxMoveVal)
        
        runningAbsoluteSum := runningAbsoluteSum + absVal
        runningMaxAbsoluteSum := runningMaxAbsoluteSum + absMaxVal
        
        array.push(absMovesArray, absVal)
        array.push(absMaxMovesArray, absMaxVal)
        
        if showIndividuals
            color textCol = moveVal >= 0.0 ? color.green : color.red
            color maxTextCol = maxMoveVal >= 0.0 ? color.green : color.red
            
            table.cell(infoTable, 0, currentRow, str.format("ER -{0}", i + 1), text_color=color.white, text_size=tblTextSize)
            table.cell(infoTable, 1, currentRow, formatMove(moveVal, displayMode), text_color=textCol, text_size=tblTextSize)
            table.cell(infoTable, 2, currentRow, formatMove(maxMoveVal, displayMode), text_color=maxTextCol, text_size=tblTextSize)
            currentRow := currentRow + 1
        
    // Averages Calculations
    float historicalAbsoluteAverage = runningAbsoluteSum / rowsToDisplay
    float historicalMaxAbsoluteAverage = runningMaxAbsoluteSum / rowsToDisplay
    
    table.cell(infoTable, 0, currentRow, str.format("ABS AVG ({0} Qtrs)", rowsToDisplay), text_color=color.orange, bgcolor=color.new(color.gray, 50), text_size=tblTextSize)
    table.cell(infoTable, 1, currentRow, formatMove(historicalAbsoluteAverage, displayMode, true), text_color=color.orange, bgcolor=color.new(color.gray, 50), text_size=tblTextSize)
    table.cell(infoTable, 2, currentRow, formatMove(historicalMaxAbsoluteAverage, displayMode, true), text_color=color.orange, bgcolor=color.new(color.gray, 50), text_size=tblTextSize)
    currentRow := currentRow + 1
    
    // Medians Calculations
    array.sort(absMovesArray)
    array.sort(absMaxMovesArray)
    float historicalAbsoluteMedian = na
    float historicalMaxAbsoluteMedian = na
    int midIndex = math.floor(rowsToDisplay / 2)
    
    if rowsToDisplay % 2 == 0
        historicalAbsoluteMedian := (array.get(absMovesArray, midIndex - 1) + array.get(absMovesArray, midIndex)) / 2.0
        historicalMaxAbsoluteMedian := (array.get(absMaxMovesArray, midIndex - 1) + array.get(absMaxMovesArray, midIndex)) / 2.0
    else
        historicalAbsoluteMedian := array.get(absMovesArray, midIndex)
        historicalMaxAbsoluteMedian := array.get(absMaxMovesArray, midIndex)
        
    table.cell(infoTable, 0, currentRow, "ABS MEDIAN", text_color=color.yellow, bgcolor=color.new(color.gray, 50), text_size=tblTextSize)
    table.cell(infoTable, 1, currentRow, formatMove(historicalAbsoluteMedian, displayMode, true), text_color=color.yellow, bgcolor=color.new(color.gray, 50), text_size=tblTextSize)
    table.cell(infoTable, 2, currentRow, formatMove(historicalMaxAbsoluteMedian, displayMode, true), text_color=color.yellow, bgcolor=color.new(color.gray, 50), text_size=tblTextSize)
````
