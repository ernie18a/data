<!-- tradingview-pine-id: PUB;ca42d45d30f34823a99db6801ed0475a -->
<!-- tradingviewscripts-format: 1 -->
# Unbroken-PDHs/PDLs

Source: https://www.tradingview.com/script/4NcWP8Kv-Unbroken-PDHs-PDLs/

## Description

This Indicator marks lines for those Previous daily candle Highs & Lows which are not yet broken. 

This indicator helps to find the external liquidity on daily timeframe and very useful for intraday in Nifty, Bank Nifty, Sensex , if you really play liquidity. It is also very helpful to catch reversal trade.

This indicator also provides the option for back test. If you choose custom date in mode option then lines will be marked w.r.t custom date.

Hope you will like this indicator.

---

## Source Code

````pine
//@version=6
indicator("Unbroken-PDHs/PDLs", overlay = true, max_lines_count = 500)

// Show on intraday + daily
showDaily = timeframe.isintraday or timeframe.isdaily

// Inputs
pdhColor  = input.color(color.green, "PDH color")
pdlColor  = input.color(color.red, "PDL color")

lineStyleInput = input.string(
    "Solid",
    "Line Style",
    options = ["Solid", "Dashed", "Dotted"])

lineWidth = input.int(1, "Line Width", minval = 1, maxval = 5)

maxLevels = input.int(10, "Max valid daily levels", minval = 1)

levelMode = input.string(
    "Both",
    "Levels to Show",
    options = ["Both", "PDH Only", "PDL Only"])

showPDH = levelMode != "PDL Only"
showPDL = levelMode != "PDH Only"

mode = input.string("Live", "Mode", options = ["Live", "Custom Date"])

backtestDate = input.time(
     timestamp("02 Jul 2026 00:00 +0530"),
     "Backtest Date")

lineStyle = switch lineStyleInput
    "Solid"  => line.style_solid
    "Dashed" => line.style_dashed
    => line.style_dotted


// Arrays for VALID daily highs and lows
var float[] dHighArr = array.new_float()
var float[] dLowArr  = array.new_float()

// Arrays to store the starting bar of each level
var int[] dHighBar = array.new_int()
var int[] dLowBar  = array.new_int()

var line[] highLines = array.new_line()
var line[] lowLines  = array.new_line()

// Previous completed daily candle

prevHigh = request.security(
     syminfo.tickerid,
     "D",
     high[1],
     lookahead = barmerge.lookahead_on)

prevLow = request.security(
     syminfo.tickerid,
     "D",
     low[1],
     lookahead = barmerge.lookahead_on)

// Detect start of a new day on the chart timeframe. [web:27][web:32]
isNewDay = timeframe.change("D")

processBar = mode == "Live" or time <= backtestDate

// Track first bar of each day
var int currentDayStartBar = na
var int previousDayStartBar = na

if na(currentDayStartBar)
    currentDayStartBar := bar_index

if isNewDay
    previousDayStartBar := currentDayStartBar
    currentDayStartBar := bar_index

// ------------------------
// Update stack at start of new day
// ------------------------

if processBar and isNewDay
  

    // Ignore first day / missing data
    if not na(prevHigh) and not na(prevLow)
        // 1) Add yesterday's high/low to the stack
                // --------------------
        // Remove swept PDHs
        // --------------------
        if showPDH
            int i = array.size(dHighArr) - 1

            while i >= 0
                float h = array.get(dHighArr, i)

                if h >= prevLow and h <= prevHigh
                    line.delete(array.get(highLines, i))

                    array.remove(highLines, i)
                    array.remove(dHighArr, i)
                    array.remove(dHighBar, i)

                i -= 1

        // --------------------
        // Remove swept PDLs
        // --------------------
        if showPDL
            int j = array.size(dLowArr) - 1

            while j >= 0
                float l = array.get(dLowArr, j)

                if l >= prevLow and l <= prevHigh
                    line.delete(array.get(lowLines, j))

                    array.remove(lowLines, j)
                    array.remove(dLowArr, j)
                    array.remove(dLowBar, j)

                j -= 1

        // ---------- NOW PASTE THE PUSH BLOCK HERE ----------

        if showPDH
            array.push(dHighArr, prevHigh)
            array.push(dHighBar, previousDayStartBar)

            line hLine = line.new(
                previousDayStartBar,
                prevHigh,
                bar_index,
                prevHigh,
                extend = extend.right,
                color = pdhColor,
                style = lineStyle,
                width = lineWidth)

            array.push(highLines, hLine)

        if showPDL
            array.push(dLowArr, prevLow)
            array.push(dLowBar, previousDayStartBar)

            line lLine = line.new(
                previousDayStartBar,
                prevLow,
                bar_index,
                prevLow,
                extend = extend.right,
                color = pdlColor,
                style = lineStyle,
                width = lineWidth)

            array.push(lowLines, lLine)

        // Respect maxLevels...

        // 2) HIGH logic: remove all previous highs < prevHigh
        // Only if there is at least 2 elements (so size-1 >= 1)
       

        // 3) LOW logic: remove all previous lows > prevLow
       

        // 4) Respect maxLevels
        while showPDH and array.size(dHighArr) > maxLevels
            line.delete(array.shift(highLines))
            array.shift(dHighArr)
            array.shift(dHighBar)
        while showPDL and array.size(dLowArr) > maxLevels
            line.delete(array.shift(lowLines))
            array.shift(dLowArr)
            array.shift(dLowBar)

// ------------------------
// Plot valid PDHs/PDLs
// ------------------------

// ------------------------
// Update existing lines
// ------------------------

if showDaily and processBar
    // Extend PDH lines
    if showPDH and array.size(highLines) > 0
        for i = 0 to array.size(highLines) - 1
            line.set_x2(array.get(highLines, i), bar_index)

    // Extend PDL lines
    if showPDL and array.size(lowLines) > 0
        for i = 0 to array.size(lowLines) - 1
            line.set_x2(array.get(lowLines, i), bar_index)

//====================================================
// Invisible plots for right price scale markers
// Newest level = 1, Oldest level = 10
//====================================================

//====================================================
// Invisible plots for right price scale markers
//====================================================

// ---------- PDHs ----------
plot(showPDH and array.size(dHighArr) > 0 ? array.get(dHighArr, array.size(dHighArr)-1) : na, title="PDH 1", color=color.new(pdhColor,100), editable=false)
plot(showPDH and array.size(dHighArr) > 1 ? array.get(dHighArr, array.size(dHighArr)-2) : na, title="PDH 2", color=color.new(pdhColor,100), editable=false)
plot(showPDH and array.size(dHighArr) > 2 ? array.get(dHighArr, array.size(dHighArr)-3) : na, title="PDH 3", color=color.new(pdhColor,100), editable=false)
plot(showPDH and array.size(dHighArr) > 3 ? array.get(dHighArr, array.size(dHighArr)-4) : na, title="PDH 4", color=color.new(pdhColor,100), editable=false)
plot(showPDH and array.size(dHighArr) > 4 ? array.get(dHighArr, array.size(dHighArr)-5) : na, title="PDH 5", color=color.new(pdhColor,100), editable=false)
plot(showPDH and array.size(dHighArr) > 5 ? array.get(dHighArr, array.size(dHighArr)-6) : na, title="PDH 6", color=color.new(pdhColor,100), editable=false)
plot(showPDH and array.size(dHighArr) > 6 ? array.get(dHighArr, array.size(dHighArr)-7) : na, title="PDH 7", color=color.new(pdhColor,100), editable=false)
plot(showPDH and array.size(dHighArr) > 7 ? array.get(dHighArr, array.size(dHighArr)-8) : na, title="PDH 8", color=color.new(pdhColor,100), editable=false)
plot(showPDH and array.size(dHighArr) > 8 ? array.get(dHighArr, array.size(dHighArr)-9) : na, title="PDH 9", color=color.new(pdhColor,100), editable=false)
plot(showPDH and array.size(dHighArr) > 9 ? array.get(dHighArr, array.size(dHighArr)-10) : na, title="PDH 10", color=color.new(pdhColor,100), editable=false)

// ---------- PDLs ----------
plot(showPDL and array.size(dLowArr) > 0 ? array.get(dLowArr, array.size(dLowArr)-1) : na, title="PDL 1", color=color.new(pdlColor,100), editable=false)
plot(showPDL and array.size(dLowArr) > 1 ? array.get(dLowArr, array.size(dLowArr)-2) : na, title="PDL 2", color=color.new(pdlColor,100), editable=false)
plot(showPDL and array.size(dLowArr) > 2 ? array.get(dLowArr, array.size(dLowArr)-3) : na, title="PDL 3", color=color.new(pdlColor,100), editable=false)
plot(showPDL and array.size(dLowArr) > 3 ? array.get(dLowArr, array.size(dLowArr)-4) : na, title="PDL 4", color=color.new(pdlColor,100), editable=false)
plot(showPDL and array.size(dLowArr) > 4 ? array.get(dLowArr, array.size(dLowArr)-5) : na, title="PDL 5", color=color.new(pdlColor,100), editable=false)
plot(showPDL and array.size(dLowArr) > 5 ? array.get(dLowArr, array.size(dLowArr)-6) : na, title="PDL 6", color=color.new(pdlColor,100), editable=false)
plot(showPDL and array.size(dLowArr) > 6 ? array.get(dLowArr, array.size(dLowArr)-7) : na, title="PDL 7", color=color.new(pdlColor,100), editable=false)
plot(showPDL and array.size(dLowArr) > 7 ? array.get(dLowArr, array.size(dLowArr)-8) : na, title="PDL 8", color=color.new(pdlColor,100), editable=false)
plot(showPDL and array.size(dLowArr) > 8 ? array.get(dLowArr, array.size(dLowArr)-9) : na, title="PDL 9", color=color.new(pdlColor,100), editable=false)
plot(showPDL and array.size(dLowArr) > 9 ? array.get(dLowArr, array.size(dLowArr)-10) : na, title="PDL 10", color=color.new(pdlColor,100), editable=false)
````
