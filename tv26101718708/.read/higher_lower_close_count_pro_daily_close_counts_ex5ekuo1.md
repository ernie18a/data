# Higher / Lower Close Count PRO+ (Daily close counts)

- url: https://www.tradingview.com/script/ex5eKUo1-Higher-Lower-Close-Count-PRO-Daily-close-counts/
- type: indicator
- pine_id: PUB;2dad018b54824876ac91bae3cd7ade04
- version: 1.0

## Description

Simply counts the number of days closed higher or lower as a reference point to gauge where you are versus historical runs

Displays in table the historical days closed higher or lower on the instrument regardless of weekly or monthly display wanted to display the max up and down days to put rallies into historical context 

user can switch off table display, or change number of run events. 

need to look at it in daily view to see current set up and compare to historical to see if an instrument is at a potential inflection point or the rally is long in the tooth

I hope you have successful trading and you find this useful at extreme runs to see how rare an event this is or can the market carry the instrument further. 

It may be useful tool to go back an analyse the count runs in stocks quickly in bear (or bull) market rallies. You could code that, so this is open for anyone to take it further.  If you find it useful please drop a note to say so and make my day happier, that I was able to help.

## Source Code

````pine
//@version=6
indicator("Higher / Lower Close Count PRO+", overlay = true, max_labels_count = 500)

//==============================================================================
// INDICATOR HELP
//==============================================================================
//
// This indicator counts consecutive higher closes and lower closes.
//
// BULLISH RUN
// A bullish run increases while each close is higher than the previous close.
//
// BEARISH RUN
// A bearish run increases while each close is lower than the previous close.
//
// IMPORTANT
// This version only stores the FINAL value of each completed streak.
// Example:
//   bullish run = 1,2,3,4,5
// Only 5 is kept.
//
// CHART LABELS
// - Can use visible bars only, or whole history, depending on user setting.
// - Bullish labels plot above price.
// - Bearish labels plot below price.
//
// TABLE
// - Uses ALL loaded historical data.
// - Shows the longest completed runs only.
// - Does not repeat intermediate values from the same run.
//
// WEEKLY / MONTHLY
// - On weekly and monthly charts, streaks are still calculated from DAILY closes.
//
//==============================================================================

//==============================================================================
// INPUTS
//==============================================================================
groupDisplay = "Display Controls"
showMode     = input.string("Both", "Show", options = ["Both", "Bullish Only", "Bearish Only"], group = groupDisplay)
scopeMode    = input.string("Visible Bars On Screen", "Chart Label Scope", options = ["Visible Bars On Screen", "Whole History"], group = groupDisplay)
showLabels   = input.bool(true, "Show Chart Numbers", group = groupDisplay)
showTable    = input.bool(true, "Show Summary Table", group = groupDisplay)
topCountIn   = input.int(10, "Maximum Table Rows / Labels", minval = 1, maxval = 100, group = groupDisplay)
minRun       = input.int(2, "Minimum Run Length", minval = 1, maxval = 10000, group = groupDisplay)

groupStyle   = "Style"
bullColor    = input.color(color.green, "Bullish Colour", group = groupStyle)
bearColor    = input.color(color.red, "Bearish Colour", group = groupStyle)
tblBullBg    = input.color(color.new(color.green, 80), "Table Bullish Background", group = groupStyle)
tblBearBg    = input.color(color.new(color.red, 80), "Table Bearish Background", group = groupStyle)
tblHeadBg    = input.color(color.new(color.gray, 20), "Table Header Background", group = groupStyle)
tblTextCol   = input.color(color.white, "Table Text Colour", group = groupStyle)

groupLabels  = "Label Size"
labelSizeStr = input.string("Small", "Chart Number Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupLabels)

groupTable   = "Table Options"
tablePosStr  = input.string("Top Right", "Table Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = groupTable)
showTypeCol  = input.bool(true, "Show Direction In Table", group = groupTable)
showDateCol  = input.bool(true, "Show Date In Table", group = groupTable)
showPriceCol = input.bool(true, "Show Price In Table", group = groupTable)

//==============================================================================
// CONVERSIONS
//==============================================================================
labelSize =
     labelSizeStr == "Tiny"   ? size.tiny :
     labelSizeStr == "Small"  ? size.small :
     labelSizeStr == "Normal" ? size.normal :
     labelSizeStr == "Large"  ? size.large :
     size.huge

tablePos =
     tablePosStr == "Top Right"    ? position.top_right :
     tablePosStr == "Top Left"     ? position.top_left :
     tablePosStr == "Bottom Right" ? position.bottom_right :
     position.bottom_left

showBull = showMode == "Both" or showMode == "Bullish Only"
showBear = showMode == "Both" or showMode == "Bearish Only"

useDailyInsideHTF = timeframe.isweekly or timeframe.ismonthly
useVisibleOnly    = scopeMode == "Visible Bars On Screen"

leftVisible  = chart.left_visible_bar_time
rightVisible = chart.right_visible_bar_time

//==============================================================================
// STORAGE
//==============================================================================
var label[] drawnLabels = array.new_label()

// Label candidates: respect user label scope
var int[]   labelTimes  = array.new_int()
var float[] labelPrices = array.new_float()
var int[]   labelVals   = array.new_int()
var int[]   labelDirs   = array.new_int()

// Table candidates: always full loaded history
var int[]   tableTimes  = array.new_int()
var float[] tablePrices = array.new_float()
var int[]   tableVals   = array.new_int()
var int[]   tableDirs   = array.new_int()

var table t = table.new(tablePos, 5, 100, border_width = 1)

//==============================================================================
// RESET ARRAYS ON FULL RECALC
//==============================================================================
if barstate.isfirst
    array.clear(labelTimes)
    array.clear(labelPrices)
    array.clear(labelVals)
    array.clear(labelDirs)

    array.clear(tableTimes)
    array.clear(tablePrices)
    array.clear(tableVals)
    array.clear(tableDirs)

//==============================================================================
// HELPER TO SAVE COMPLETED RUN
//==============================================================================
saveRun(_time, _price, _runLen, _dir) =>
    if _runLen >= minRun
        inLabelScope = useVisibleOnly ? (_time >= leftVisible and _time <= rightVisible) : true

        if (_dir == 1 and showBull) or (_dir == -1 and showBear)
            // chart labels
            if inLabelScope
                array.push(labelTimes, _time)
                array.push(labelPrices, _price)
                array.push(labelVals, _runLen)
                array.push(labelDirs, _dir)

            // table always uses full history
            array.push(tableTimes, _time)
            array.push(tablePrices, _price)
            array.push(tableVals, _runLen)
            array.push(tableDirs, _dir)

//==============================================================================
// NORMAL TIMEFRAME LOGIC
// Only save the final value when a run ends
//==============================================================================
var int   bullRun_chart      = 0
var int   bearRun_chart      = 0
var float bullRunEndPrice_ch = na
var float bearRunEndPrice_ch = na
var int   bullRunEndTime_ch  = na
var int   bearRunEndTime_ch  = na

if not useDailyInsideHTF
    if not na(close[1])
        if close > close[1]
            if bearRun_chart > 0
                saveRun(bearRunEndTime_ch, bearRunEndPrice_ch, bearRun_chart, -1)
            bullRun_chart += 1
            bullRunEndPrice_ch := close
            bullRunEndTime_ch  := time
            bearRun_chart := 0
            bearRunEndPrice_ch := na
            bearRunEndTime_ch  := na

        else if close < close[1]
            if bullRun_chart > 0
                saveRun(bullRunEndTime_ch, bullRunEndPrice_ch, bullRun_chart, 1)
            bearRun_chart += 1
            bearRunEndPrice_ch := close
            bearRunEndTime_ch  := time
            bullRun_chart := 0
            bullRunEndPrice_ch := na
            bullRunEndTime_ch  := na

        else
            if bullRun_chart > 0
                saveRun(bullRunEndTime_ch, bullRunEndPrice_ch, bullRun_chart, 1)
            if bearRun_chart > 0
                saveRun(bearRunEndTime_ch, bearRunEndPrice_ch, bearRun_chart, -1)

            bullRun_chart := 0
            bearRun_chart := 0
            bullRunEndPrice_ch := na
            bearRunEndPrice_ch := na
            bullRunEndTime_ch  := na
            bearRunEndTime_ch  := na

    // Save final active run at last bar
    if barstate.islast
        if bullRun_chart > 0
            saveRun(bullRunEndTime_ch, bullRunEndPrice_ch, bullRun_chart, 1)
        if bearRun_chart > 0
            saveRun(bearRunEndTime_ch, bearRunEndPrice_ch, bearRun_chart, -1)

//==============================================================================
// WEEKLY / MONTHLY MODE USING DAILY CLOSES
// Only save the final value when a daily-based run ends
//==============================================================================
var float prevDailyClose = na
var int   bullRun_daily  = 0
var int   bearRun_daily  = 0
var float bullRunEndPrice_d = na
var float bearRunEndPrice_d = na
var int   bullRunEndTime_d  = na
var int   bearRunEndTime_d  = na

if useDailyInsideHTF
    dailyCloses = request.security_lower_tf(syminfo.tickerid, "D", close)
    dailyTimes  = request.security_lower_tf(syminfo.tickerid, "D", time)

    dailyCount = array.size(dailyCloses)

    if dailyCount > 0
        for i = 0 to dailyCount - 1
            dClose = array.get(dailyCloses, i)
            dTime  = array.get(dailyTimes, i)

            if not na(prevDailyClose)
                if dClose > prevDailyClose
                    if bearRun_daily > 0
                        saveRun(bearRunEndTime_d, bearRunEndPrice_d, bearRun_daily, -1)
                    bullRun_daily += 1
                    bullRunEndPrice_d := dClose
                    bullRunEndTime_d  := dTime
                    bearRun_daily := 0
                    bearRunEndPrice_d := na
                    bearRunEndTime_d  := na

                else if dClose < prevDailyClose
                    if bullRun_daily > 0
                        saveRun(bullRunEndTime_d, bullRunEndPrice_d, bullRun_daily, 1)
                    bearRun_daily += 1
                    bearRunEndPrice_d := dClose
                    bearRunEndTime_d  := dTime
                    bullRun_daily := 0
                    bullRunEndPrice_d := na
                    bullRunEndTime_d  := na

                else
                    if bullRun_daily > 0
                        saveRun(bullRunEndTime_d, bullRunEndPrice_d, bullRun_daily, 1)
                    if bearRun_daily > 0
                        saveRun(bearRunEndTime_d, bearRunEndPrice_d, bearRun_daily, -1)

                    bullRun_daily := 0
                    bearRun_daily := 0
                    bullRunEndPrice_d := na
                    bearRunEndPrice_d := na
                    bullRunEndTime_d  := na
                    bearRunEndTime_d  := na

            prevDailyClose := dClose

    if barstate.islast
        if bullRun_daily > 0
            saveRun(bullRunEndTime_d, bullRunEndPrice_d, bullRun_daily, 1)
        if bearRun_daily > 0
            saveRun(bearRunEndTime_d, bearRunEndPrice_d, bearRun_daily, -1)

//==============================================================================
// DRAWING
//==============================================================================
if barstate.islast
    // Remove old labels
    oldCount = array.size(drawnLabels)
    if oldCount > 0
        for i = 0 to oldCount - 1
            label.delete(array.get(drawnLabels, i))
    array.clear(drawnLabels)

    if showTable
        table.clear(t, 0, 0, 4, 99)

    //--------------------------------------------------------------------------
    // LABELS: choose top longest completed runs from label scope
    //--------------------------------------------------------------------------
    totalLabelCandidates = array.size(labelVals)

    if showLabels and totalLabelCandidates > 0
        usedLabel = array.new_bool(totalLabelCandidates, false)
        labelPicks = math.min(topCountIn, totalLabelCandidates)

        for pick = 0 to labelPicks - 1
            bestIdx = -1
            bestVal = -1

            for j = 0 to totalLabelCandidates - 1
                alreadyUsed = array.get(usedLabel, j)
                thisVal     = array.get(labelVals, j)

                if not alreadyUsed and thisVal > bestVal
                    bestVal := thisVal
                    bestIdx := j

            if bestIdx != -1
                array.set(usedLabel, bestIdx, true)

                bestTime  = array.get(labelTimes, bestIdx)
                bestPrice = array.get(labelPrices, bestIdx)
                bestRun   = array.get(labelVals, bestIdx)
                bestDir   = array.get(labelDirs, bestIdx)

                isBull = bestDir == 1
                txtCol = isBull ? bullColor : bearColor

                lbl = label.new(
                     x = bestTime,
                     y = bestPrice,
                     text = str.tostring(bestRun),
                     xloc = xloc.bar_time,
                     yloc = isBull ? yloc.abovebar : yloc.belowbar,
                     style = label.style_none,
                     textcolor = txtCol,
                     size = labelSize
                 )
                array.push(drawnLabels, lbl)

    //--------------------------------------------------------------------------
    // TABLE: choose top longest completed runs from ALL history
    //--------------------------------------------------------------------------
    totalTableCandidates = array.size(tableVals)

    if showTable
        colRun  = 0
        colType = 1
        colDate = 2
        colPx   = 3
        colTf   = 4

        table.cell(t, colRun, 0, "Run", text_color = tblTextCol, bgcolor = tblHeadBg)
        table.cell(t, colType, 0, showTypeCol ? "Type" : "", text_color = tblTextCol, bgcolor = tblHeadBg)
        table.cell(t, colDate, 0, showDateCol ? "Date" : "", text_color = tblTextCol, bgcolor = tblHeadBg)
        table.cell(t, colPx, 0, showPriceCol ? "Close" : "", text_color = tblTextCol, bgcolor = tblHeadBg)
        table.cell(t, colTf, 0, useDailyInsideHTF ? "Base TF" : "Chart TF", text_color = tblTextCol, bgcolor = tblHeadBg)

        if totalTableCandidates > 0
            usedTable = array.new_bool(totalTableCandidates, false)
            tablePicks = math.min(topCountIn, totalTableCandidates)
            row = 1

            for pick = 0 to tablePicks - 1
                bestIdx = -1
                bestVal = -1

                for j = 0 to totalTableCandidates - 1
                    alreadyUsed = array.get(usedTable, j)
                    thisVal     = array.get(tableVals, j)

                    if not alreadyUsed and thisVal > bestVal
                        bestVal := thisVal
                        bestIdx := j

                if bestIdx != -1
                    array.set(usedTable, bestIdx, true)

                    bestTime  = array.get(tableTimes, bestIdx)
                    bestPrice = array.get(tablePrices, bestIdx)
                    bestRun   = array.get(tableVals, bestIdx)
                    bestDir   = array.get(tableDirs, bestIdx)

                    isBull = bestDir == 1
                    dirTxt = isBull ? "Bull" : "Bear"
                    bgCol  = isBull ? tblBullBg : tblBearBg
                    baseTxt = useDailyInsideHTF ? "Daily" : timeframe.period
                    dateTxt = str.format("{0,date,yyyy-MM-dd}", bestTime)
                    priceTxt = str.tostring(bestPrice, format.mintick)

                    table.cell(t, colRun, row, str.tostring(bestRun), text_color = tblTextCol, bgcolor = bgCol)
                    table.cell(t, colType, row, showTypeCol ? dirTxt : "", text_color = tblTextCol, bgcolor = bgCol)
                    table.cell(t, colDate, row, showDateCol ? dateTxt : "", text_color = tblTextCol, bgcolor = bgCol)
                    table.cell(t, colPx, row, showPriceCol ? priceTxt : "", text_color = tblTextCol, bgcolor = bgCol)
                    table.cell(t, colTf, row, baseTxt, text_color = tblTextCol, bgcolor = bgCol)

                    row += 1
        else
            table.cell(t, 0, 1, "No completed runs found", text_color = tblTextCol, bgcolor = tblHeadBg)
````
