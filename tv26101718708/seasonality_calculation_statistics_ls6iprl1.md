# Seasonality Calculation & Statistics

- url: https://www.tradingview.com/script/Ls6IpRl1-Seasonality-Calculation-Statistics/
- type: indicator
- pine_id: PUB;9be4083b820447589d0353434e50f4b4
- version: 1.0

## Description

[b]Seasonality Calculation & Statistics[/b]

[list]
[*]The Seasonality Calculation & Statistics indicator is a quantitative tool designed to backtest, track, and visually analyze specific seasonal recurring calendar patterns across historical data directly on the daily timeframe
[/list]
[list]
[*]It eliminates guesswork by isolating user-defined date windows (e.g., May 1 to May 15), calculating historical performance metrics, projecting upcoming seasonal cycles, and providing detailed table dashboards
[/list]

Key Features
[list]
[*]Custom Seasonal Windows: Define exact start and end dates (Day/Month) and evaluate both Long and Short seasonal directions
[/list]
[list]
[*]Smart Vertical Timeline Markers: Clean visual boundaries marking every historical cycle and projecting upcoming future opportunities
[/list]
[list]
[*]Shifted Exit Boundary for Visual Clarity: The vertical exit line is deliberately placed one trading day to the right ($t + 1$), cleanly enclosing the entire holding period so you can analyze every historical price bar inside the pattern without overlapping visual obstruction
[/list]
[list]
[*]Three Built-in Statistical Tables: Comprehensive performance summaries, year-by-year logs, and multi-period lookback comparisons
[/list]
[list]
[*]SQN & Risk Metrics: Real-time calculation of System Quality Number (SQN), Win Rate, Average Return, Average Profit, and Maximum/Average Drawdown
[/list]

Visual Chart Elements
[list]
[*]Entry Line & Label: A vertical line (default lime) placed on the entry candle close
[/list]
[list]
[*]Shifted Exit Line & Label: A vertical boundary line (default red) shifted one trading day to the right of the exit candle, framing the trade window perfectly for post-trade review
[/list]
[list]
[*]Result Badges: Clean floating labels displaying the percentage return and maximum intra-trade drawdown for each individual year
[/list]
[list]
[*]Future Projections: Forward-projected dashed lines plotted into empty chart space to highlight when the next seasonal window opens and closes
[/list]

Dashboard Tables
1. Summary Table: Displays overall strategy performance across the entire selected backtest horizon

[list]
[*]Direction (Long / Short)
[/list]
[list]
[*]Calendar Window & Trade Duration
[/list]
[list]
[*]Winning Trades ratio and Win Rate percentage
[/list]
[list]
[*]Average Return and Average Winning Trade Profit
[/list]
[list]
[*]Average Drawdown and Maximum Intra-trade Drawdown
[/list]
[list]
[*]System Quality Number (SQN) to evaluate statistical edge
[/list]

2. Yearly Table: Provides a granular, year-by-year historical audit containing
[list]
[*]Specific trading cycle year
[/list]
[list]
[*]Executed start and end dates
[/list]
[list]
[*]Trade Return (%)
[/list]
[list]
[*]Trade Maximum Drawdown (%)
[/list]

3. Period Summary Table: Breaks down win rates across customizable historical segments (e.g., last 3, 5, 10, or 15 years) to help identify if a seasonal pattern is strengthening, decaying, or completely cooked in modern market regime

How to Use
[list]
[*]Apply the indicator to any asset on the Daily (1D) timeframe
[/list]
[list]
[*]Set your desired seasonal window via Start Day / Start Month and End Day / End Month
[/list]
[list]
[*]Select Long or Short bias
[/list]
[list]
[*]Adjust the lookback starting years to focus on specific economic cycles
[/list]
[list]
[*]Use the projected lines to prepare for upcoming seasonal setups ahead of time
[/list]

## Source Code

````pine
//@version=6
indicator("Seasonality Calculation & Statistics", overlay = true, max_lines_count = 500, max_labels_count = 500)

//====================================================================
// DAILY ONLY
//====================================================================
if not timeframe.isdaily
    runtime.error("Please use this indicator on the Daily timeframe only.")

//====================================================================
// INPUTS
//====================================================================
groupSeason      = "Seasonality"
groupLines       = "Lines"
groupSummary     = "Summary Table"
groupYearly      = "Yearly Table"
groupLookback    = "Period Summary Table"
groupLookbackSet = "Period Settings"
groupRows        = "Summary Table Rows"
groupYearCols    = "Yearly Table Columns"
groupDesign      = "Table Design"

// Use TradingView trading-day dates for seasonal matching.
// This avoids 1-day shifts on instruments whose daily session starts on the previous calendar day.
string calendarTz = "GMT+0"

//----------------------
// Core inputs
//----------------------
tradeSide  = input.string("Long", "Direction", options = ["Long", "Short"], group = groupSeason)
fromYear   = input.int(2010, "Calculate from year", minval = 1900, group = groupSeason)

startDay   = input.int(1,  "Start Day",   minval = 1, maxval = 31, group = groupSeason, inline = "start")
startMonth = input.int(5,  "Start Month", minval = 1, maxval = 12, group = groupSeason, inline = "start")

endDay     = input.int(15, "End Day",     minval = 1, maxval = 31, group = groupSeason, inline = "end")
endMonth   = input.int(5,  "End Month",   minval = 1, maxval = 12, group = groupSeason, inline = "end")

//----------------------
// Line / label inputs
//----------------------
showLines             = input.bool(true, "Show yearly start/end lines", group = groupLines)
showEntryLabels       = input.bool(true, "Show Entry labels", group = groupLines)
showExitLabels        = input.bool(true, "Show Exit labels", group = groupLines)

showResultLabels      = input.bool(true, "Show Result labels", group = groupLines)
showResultLabelDD     = input.bool(true, "Show DD in Result label", group = groupLines)
resultLabelSizeInput  = input.string("Small", "Result Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLines)
resultLabelPosition   = input.string("Auto", "Result Label Position", options = ["Auto", "Above Bar", "Below Bar"], group = groupLines)
resultLabelBarOffset  = input.int(1, "Result Label Bar Offset", minval = -20, maxval = 50, group = groupLines)

showProjectedLines    = input.bool(true, "Project next future start/end lines", group = groupLines)

startLineColor = input.color(color.new(color.lime, 0), "Start", group = groupLines, inline = "sl")
startLineWidth = input.int(2, "", minval = 1, maxval = 5, group = groupLines, inline = "sl")
startLineStyle = input.string("Dashed", "", options = ["Solid", "Dashed", "Dotted"], group = groupLines, inline = "sl")

endLineColor   = input.color(color.new(color.red, 0), "End", group = groupLines, inline = "el")
endLineWidth   = input.int(2, "", minval = 1, maxval = 5, group = groupLines, inline = "el")
endLineStyle   = input.string("Dashed", "", options = ["Solid", "Dashed", "Dotted"], group = groupLines, inline = "el")

entryLabelBgColor   = input.color(color.rgb(36, 40, 52), "Entry BG", group = groupLines, inline = "ent")
entryLabelTextColor = input.color(color.white, "Text", group = groupLines, inline = "ent")
entryLabelSizeInput = input.string("Tiny", "Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLines, inline = "ent")

exitLabelBgColor   = input.color(color.rgb(36, 40, 52), "Exit BG", group = groupLines, inline = "ext")
exitLabelTextColor = input.color(color.white, "Text", group = groupLines, inline = "ext")
exitLabelSizeInput = input.string("Tiny", "Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLines, inline = "ext")

//----------------------
// Summary table inputs
//----------------------
showSummaryTable = input.bool(true, "Show summary table", group = groupSummary)
summaryPosition  = input.string("Top Right", "Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupSummary)
summaryTextSize  = input.string("Normal", "Text Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupSummary)

//----------------------
// Yearly table inputs
//----------------------
showYearlyTable = input.bool(true, "Show yearly table", group = groupYearly)
yearlyPosition  = input.string("Bottom Left", "Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupYearly)
yearlyTextSize  = input.string("Normal", "Text Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupYearly)

//----------------------
// Period summary table inputs
//----------------------
showLookbackTable = input.bool(true, "Show period summary table", group = groupLookback)
lookbackPosition  = input.string("Top Center", "Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupLookback)
lookbackTextSize  = input.string("Normal", "Text Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLookback)

//----------------------
// Period settings
//----------------------
showPeriod1 = input.bool(true, "Use", group = groupLookbackSet, inline = "p1")
period1FromYear = input.int(2022, "From Year", minval = 1900, group = groupLookbackSet, inline = "p1")

showPeriod2 = input.bool(true, "Use", group = groupLookbackSet, inline = "p2")
period2FromYear = input.int(2020, "From Year", minval = 1900, group = groupLookbackSet, inline = "p2")

showPeriod3 = input.bool(true, "Use", group = groupLookbackSet, inline = "p3")
period3FromYear = input.int(2015, "From Year", minval = 1900, group = groupLookbackSet, inline = "p3")

showPeriod4 = input.bool(true, "Use", group = groupLookbackSet, inline = "p4")
period4FromYear = input.int(2010, "From Year", minval = 1900, group = groupLookbackSet, inline = "p4")

//----------------------
// Summary row toggles
//----------------------
showRowDate          = input.bool(true, "Date", group = groupRows)
showRowDirection     = input.bool(true, "Long/Short", group = groupRows)
showRowPeriod        = input.bool(true, "Period", group = groupRows)
showRowWinningTrades = input.bool(true, "Winning Trades", group = groupRows)
showRowAvgReturn     = input.bool(true, "⌀ Return", group = groupRows)
showRowTradeDuration = input.bool(true, "Trade Duration", group = groupRows)
showRowAvgProfit     = input.bool(true, "⌀ Profit", group = groupRows)
showRowMaxDD         = input.bool(true, "Max DD", group = groupRows)
showRowAvgDD         = input.bool(true, "⌀ DD", group = groupRows)
showRowSQN           = input.bool(true, "SQN", group = groupRows)

//----------------------
// Yearly table column toggles
//----------------------
showYearColYear      = input.bool(true, "Year", group = groupYearCols)
showYearColStartDate = input.bool(true, "Start Date", group = groupYearCols)
showYearColEndDate   = input.bool(true, "End Date", group = groupYearCols)
showYearColResult    = input.bool(true, "Profit %", group = groupYearCols)
showYearColDD        = input.bool(true, "DD %", group = groupYearCols)

//----------------------
// Table design
//----------------------
headerBgColor   = input.color(color.rgb(42, 47, 63), "Header Background", group = groupDesign)
bodyBgColor     = input.color(color.rgb(56, 62, 82), "Body Background", group = groupDesign)
borderColor     = input.color(color.rgb(25, 29, 39), "Border", group = groupDesign)

headerTextColor = input.color(color.white, "Header Text", group = groupDesign)
bodyTextColor   = input.color(color.white, "Body Text", group = groupDesign)
accentTextColor = input.color(color.rgb(255, 215, 0), "Accent Text", group = groupDesign)
positiveColor   = input.color(color.rgb(0, 220, 140), "Positive Text", group = groupDesign)
negativeColor   = input.color(color.rgb(255, 95, 95), "Negative Text", group = groupDesign)

sqnTextColor     = input.color(color.rgb(210, 160, 255), "SQN Text", group = groupDesign)

//====================================================================
// CALC START YEAR
//====================================================================
int calcFromYear = fromYear
calcFromYear := showPeriod1 ? math.min(calcFromYear, period1FromYear) : calcFromYear
calcFromYear := showPeriod2 ? math.min(calcFromYear, period2FromYear) : calcFromYear
calcFromYear := showPeriod3 ? math.min(calcFromYear, period3FromYear) : calcFromYear
calcFromYear := showPeriod4 ? math.min(calcFromYear, period4FromYear) : calcFromYear

//====================================================================
// CHART WEEKEND CANDLE DETECTION
//====================================================================
bool chartHasSaturdayCandles = not na(ta.barssince(dayofweek(time_tradingday, calendarTz) == dayofweek.saturday))
bool chartHasSundayCandles   = not na(ta.barssince(dayofweek(time_tradingday, calendarTz) == dayofweek.sunday))
bool chartHasWeekendCandles = chartHasSaturdayCandles or chartHasSundayCandles
int weekendLineShift = chartHasWeekendCandles ? 1 : 0

//====================================================================
// HELPERS
//====================================================================
f_twoDigits(v) =>
    v < 10 ? "0" + str.tostring(v) : str.tostring(v)

f_periodCrossesYear() =>
    endMonth < startMonth or (endMonth == startMonth and endDay < startDay)

f_lineStyle(styleInput) =>
    switch styleInput
        "Solid"  => line.style_solid
        "Dotted" => line.style_dotted
        => line.style_dashed

f_tablePos(posInput) =>
    switch posInput
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_textSize(sizeInput) =>
    switch sizeInput
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Large"  => size.large
        => size.normal

f_labelSize(sizeInput) =>
    switch sizeInput
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Large"  => size.large
        => size.normal

f_dateKey(y, m, d) =>
    y * 10000 + m * 100 + d

f_keyFromTs(ts) =>
    year(ts, calendarTz) * 10000 + month(ts, calendarTz) * 100 + dayofmonth(ts, calendarTz)

f_dateTextShortFromTs(ts) =>
    f_twoDigits(dayofmonth(ts, calendarTz)) + "." + f_twoDigits(month(ts, calendarTz))

f_startKey(cycleYear) =>
    f_dateKey(cycleYear, startMonth, startDay)

f_endKey(cycleYear) =>
    f_dateKey(f_periodCrossesYear() ? cycleYear + 1 : cycleYear, endMonth, endDay)

f_noonTs(y, m, d) =>
    timestamp(syminfo.timezone, y, m, d, 12, 0)

f_fmtPct(v) =>
    na(v) ? "n/a" : str.tostring(v * 100.0, "#.##") + "%"

f_fmtNum(v) =>
    na(v) ? "n/a" : str.tostring(v, "#.##")

f_solidColor(c) =>
    color.new(c, 0)

f_drawCell(tbl, col, row, txt, bg, txtColor, txtSize) =>
    color solidBg = color.rgb(color.r(bg), color.g(bg), color.b(bg))
    table.cell(tbl, col, row, txt, bgcolor = solidBg, text_color = txtColor, text_halign = text.align_center, text_valign = text.align_center, text_size = txtSize)

f_countSummaryRows() =>
    int c = 0
    c += showRowDate ? 1 : 0
    c += showRowDirection ? 1 : 0
    c += showRowPeriod ? 1 : 0
    c += showRowWinningTrades ? 1 : 0
    c += showRowAvgReturn ? 1 : 0
    c += showRowTradeDuration ? 1 : 0
    c += showRowAvgProfit ? 1 : 0
    c += showRowMaxDD ? 1 : 0
    c += showRowAvgDD ? 1 : 0
    c += showRowSQN ? 1 : 0
    c

f_countYearlyCols() =>
    int c = 0
    c += showYearColYear ? 1 : 0
    c += showYearColStartDate ? 1 : 0
    c += showYearColEndDate ? 1 : 0
    c += showYearColResult ? 1 : 0
    c += showYearColDD ? 1 : 0
    c

f_countPeriodCols() =>
    int c = 0
    c += showPeriod1 ? 1 : 0
    c += showPeriod2 ? 1 : 0
    c += showPeriod3 ? 1 : 0
    c += showPeriod4 ? 1 : 0
    c

f_dayHasChartBar(ts) =>
    int wd = dayofweek(ts)
    wd == dayofweek.saturday ? chartHasSaturdayCandles : wd == dayofweek.sunday ? chartHasSundayCandles : true

f_adjustFutureWeekendTs(ts) =>
    int oneDay = 24 * 60 * 60 * 1000
    int adjusted = ts
    int wd = dayofweek(adjusted)

    if wd == dayofweek.saturday and not chartHasSaturdayCandles
        adjusted += oneDay
        wd := dayofweek(adjusted)

    if wd == dayofweek.sunday and not chartHasSundayCandles
        adjusted += oneDay

    adjusted

f_projectedStartTs(cycleYear) =>
    int baseTs = f_noonTs(cycleYear, startMonth, startDay)
    f_adjustFutureWeekendTs(baseTs)

f_projectedEndTs(cycleYear) =>
    int endYear = f_periodCrossesYear() ? cycleYear + 1 : cycleYear
    int baseTs = f_noonTs(endYear, endMonth, endDay)
    f_adjustFutureWeekendTs(baseTs)

f_endLineBarOffset(cycleYear) =>
    int endYear = f_periodCrossesYear() ? cycleYear + 1 : cycleYear
    int rawEndTs = f_noonTs(endYear, endMonth, endDay)

    // Red line marks the first chart bar AFTER the seasonal period.
    // If the selected end date has a real chart bar, the boundary is the next chart bar.
    // If the selected end date is a missing weekend day, the boundary is the first available bar after it.
    f_dayHasChartBar(rawEndTs) ? 1 : 0

f_businessDaysBetween(fromTs, toTs) =>
    int oneDay = 24 * 60 * 60 * 1000
    int count = 0
    if toTs > fromTs
        int t = fromTs + oneDay
        while t <= toTs
            if f_dayHasChartBar(t)
                count += 1
            t += oneDay
    count

f_tradeCountInRange(periodFromYear, periodToYear, yearsArr) =>
    int total = 0
    int n = array.size(yearsArr)
    if n > 0 and periodFromYear <= periodToYear
        for i = 0 to n - 1
            int y = array.get(yearsArr, i)
            if y >= periodFromYear and y <= periodToYear
                total += 1
    total

f_winCountInRange(periodFromYear, periodToYear, yearsArr, resultsArr) =>
    int winsLocal = 0
    int n = array.size(yearsArr)
    if n > 0 and periodFromYear <= periodToYear
        for i = 0 to n - 1
            int y = array.get(yearsArr, i)
            if y >= periodFromYear and y <= periodToYear and array.get(resultsArr, i) > 0
                winsLocal += 1
    winsLocal

f_sumPositiveInRange(periodFromYear, periodToYear, yearsArr, valsArr) =>
    float result = 0.0
    int n = array.size(yearsArr)
    if n > 0 and periodFromYear <= periodToYear
        for i = 0 to n - 1
            int y = array.get(yearsArr, i)
            float v = array.get(valsArr, i)
            if y >= periodFromYear and y <= periodToYear and v > 0
                result += v
    result

f_sumInRange(periodFromYear, periodToYear, yearsArr, valsArr) =>
    float result = 0.0
    int n = array.size(yearsArr)
    if n > 0 and periodFromYear <= periodToYear
        for i = 0 to n - 1
            int y = array.get(yearsArr, i)
            if y >= periodFromYear and y <= periodToYear
                result += array.get(valsArr, i)
    result

f_stdevInRange(periodFromYear, periodToYear, yearsArr, valsArr) =>
    int n = 0
    float mean = 0.0
    int sizeArr = array.size(yearsArr)

    if sizeArr > 0 and periodFromYear <= periodToYear
        for i = 0 to sizeArr - 1
            int y = array.get(yearsArr, i)
            if y >= periodFromYear and y <= periodToYear
                mean += array.get(valsArr, i)
                n += 1

    float result = na
    if n > 1
        mean := mean / n
        float sumSq = 0.0
        for i = 0 to sizeArr - 1
            int y = array.get(yearsArr, i)
            if y >= periodFromYear and y <= periodToYear
                float diff = array.get(valsArr, i) - mean
                sumSq += diff * diff
        result := math.sqrt(sumSq / (n - 1))

    result

f_minInRange(periodFromYear, periodToYear, yearsArr, valsArr) =>
    float result = na
    bool found = false
    int n = array.size(yearsArr)
    if n > 0 and periodFromYear <= periodToYear
        for i = 0 to n - 1
            int y = array.get(yearsArr, i)
            float v = array.get(valsArr, i)
            if y >= periodFromYear and y <= periodToYear
                if not found
                    result := v
                    found := true
                else
                    result := math.min(result, v)
    result

f_periodWinningText(periodFromYear, periodToYear, yearsArr, resultsArr) =>
    int total = 0
    int winsLocal = 0
    int n = array.size(yearsArr)

    if n > 0 and periodFromYear <= periodToYear
        for i = 0 to n - 1
            int y = array.get(yearsArr, i)
            if y >= periodFromYear and y <= periodToYear
                total += 1
                if array.get(resultsArr, i) > 0
                    winsLocal += 1

    float wrLocal = total > 0 ? float(winsLocal) / float(total) : na
    string txt = total > 0 ? str.tostring(winsLocal) + "/" + str.tostring(total) + " (" + f_fmtPct(wrLocal) + ")" : "n/a"
    [txt, wrLocal]

f_periodDiffText(periodFromYear, periodToYear) =>
    int yearsCount = periodToYear >= periodFromYear ? (periodToYear - periodFromYear + 1) : na
    na(yearsCount) ? "n/a" : str.tostring(yearsCount) + " Years"

f_periodRangeWithDiffText(periodFromYear, periodToYear) =>
    int yearsCount = periodToYear >= periodFromYear ? (periodToYear - periodFromYear + 1) : na
    na(yearsCount) ? "n/a" : str.tostring(periodFromYear) + "-" + str.tostring(periodToYear) + " (" + str.tostring(yearsCount) + ")"

f_tradeDurationDays(cycleYear) =>
    int oneDay = 24 * 60 * 60 * 1000
    int startTs = f_noonTs(cycleYear, startMonth, startDay)
    int endYear = f_periodCrossesYear() ? cycleYear + 1 : cycleYear
    int endTs = f_noonTs(endYear, endMonth, endDay)
    startTs <= endTs ? int(math.round((endTs - startTs) / oneDay)) : na

f_tradeDurationText(cycleYear) =>
    int d = f_tradeDurationDays(cycleYear)
    na(d) ? "n/a" : str.tostring(d) + (d == 1 ? " day" : " days")

//====================================================================
// STATE
//====================================================================
bool isLong = tradeSide == "Long"

int currKey = f_keyFromTs(time_tradingday)
int prevKey = bar_index > 0 ? f_keyFromTs(time_tradingday[1]) : na
int currCloseYear = year(time_tradingday, calendarTz)
int currDateNoonTs = f_noonTs(year(time_tradingday, calendarTz), month(time_tradingday, calendarTz), dayofmonth(time_tradingday, calendarTz))

var bool   tradeOpen           = false
var int    nextCycleYear       = calcFromYear
var int    activeCycleYear     = na
var int    lastClosedCycleYear = na
var float  entryClose          = na
var string activeStartDateText = ""
var int    entryBarIndex       = na

var float tradeLowestLow   = na
var float tradeHighestHigh = na

var array<int>    yearlyYears          = array.new<int>()
var array<string> yearlyStartDates     = array.new<string>()
var array<string> yearlyEndDates       = array.new<string>()
var array<float>  yearlyResults        = array.new<float>()
var array<float>  yearlyDDs            = array.new<float>()

var table summaryTable  = na
var table yearlyTable   = na
var table periodTable   = na

var line projectedStartLine = na
var line projectedEndLine   = na

//====================================================================
// SKIP FULLY PASSED CYCLES
//====================================================================
while not tradeOpen and nextCycleYear <= currCloseYear and currKey > f_endKey(nextCycleYear)
    nextCycleYear += 1

//====================================================================
// START / END DETECTION
//====================================================================
bool startCross = not tradeOpen and bar_index > 0 and nextCycleYear >= calcFromYear and currKey >= f_startKey(nextCycleYear) and prevKey < f_startKey(nextCycleYear)
bool endCross   = tradeOpen and bar_index > 0 and currKey >= f_endKey(activeCycleYear) and prevKey < f_endKey(activeCycleYear)

// If the selected end date has no candle, the first later candle triggers endCross.
// In that case the trade must close on the previous real candle, not on the later candle.
bool endSkippedMissingEndBar = false
if endCross
    endSkippedMissingEndBar := currKey > f_endKey(activeCycleYear)

// Update DD extremes only after the entry bar.
// Entry bar intraday high/low must not count because entry happens at close.
if tradeOpen and not na(entryBarIndex) and bar_index > entryBarIndex and not endSkippedMissingEndBar
    tradeLowestLow   := math.min(tradeLowestLow, low)
    tradeHighestHigh := math.max(tradeHighestHigh, high)

//====================================================================
// CLOSE TRADE
//====================================================================
if endCross
    bool showThisCycle = activeCycleYear >= fromYear

    float exitClose = endSkippedMissingEndBar ? close[1] : close
    float tradeRet = isLong ? (exitClose - entryClose) / entryClose : (entryClose - exitClose) / entryClose

    float ddPoints = isLong ? math.max(0.0, entryClose - tradeLowestLow) : math.max(0.0, tradeHighestHigh - entryClose)
    float tradeDD  = entryClose != 0 ? -(ddPoints / entryClose) : na

    string actualEndDateText = endSkippedMissingEndBar ? f_dateTextShortFromTs(time_tradingday[1]) : f_dateTextShortFromTs(time_tradingday)

    array.push(yearlyYears, activeCycleYear)
    array.push(yearlyStartDates, activeStartDateText)
    array.push(yearlyEndDates, actualEndDateText)
    array.push(yearlyResults, tradeRet)
    array.push(yearlyDDs, tradeDD)

    lastClosedCycleYear := activeCycleYear

    int endBoundaryX = endSkippedMissingEndBar ? bar_index : bar_index + 1

    if showLines and showThisCycle
        line.new(
            x1 = endBoundaryX, y1 = low, x2 = endBoundaryX, y2 = high,
            xloc = xloc.bar_index, extend = extend.both,
            color = endLineColor, width = endLineWidth, style = f_lineStyle(endLineStyle)
         )

    if showExitLabels and showThisCycle
        label.new(
             x = endSkippedMissingEndBar ? bar_index - 1 : bar_index,
             y = endSkippedMissingEndBar ? high[1] : high,
             text = "Exit",
             xloc = xloc.bar_index,
             yloc = yloc.abovebar,
             style = label.style_label_down,
             color = exitLabelBgColor,
             textcolor = exitLabelTextColor,
             size = f_labelSize(exitLabelSizeInput)
         )

    if showResultLabels and showThisCycle
        bool resultIsWinner = tradeRet > 0
        color resultBgColor = resultIsWinner ? positiveColor : negativeColor

        bool resultLabelAbove = resultLabelPosition == "Above Bar" ? true : resultLabelPosition == "Below Bar" ? false : resultIsWinner

        int resultLabelX = endBoundaryX + resultLabelBarOffset

        string resultLabelText = "Return: " + f_fmtPct(tradeRet)
        resultLabelText := showResultLabelDD ? resultLabelText + "\nDD: " + f_fmtPct(tradeDD) : resultLabelText

        float resultAnchorHigh = endSkippedMissingEndBar ? high[1] : high
        float resultAnchorLow  = endSkippedMissingEndBar ? low[1] : low

        label.new(
            x = resultLabelX,
            y = resultLabelAbove ? resultAnchorHigh : resultAnchorLow,
            text = resultLabelText,
            xloc = xloc.bar_index,
            yloc = resultLabelAbove ? yloc.abovebar : yloc.belowbar,
            style = label.style_label_left,
            color = resultBgColor,
            textcolor = color.white,
            size = f_labelSize(resultLabelSizeInput)
         )

    tradeOpen           := false
    activeCycleYear     := na
    entryClose          := na
    activeStartDateText := ""
    entryBarIndex       := na
    tradeLowestLow      := na
    tradeHighestHigh    := na
    nextCycleYear       := lastClosedCycleYear + 1

//====================================================================
// OPEN TRADE
//====================================================================
if startCross
    tradeOpen           := true
    activeCycleYear     := nextCycleYear
    entryClose          := close
    activeStartDateText := f_dateTextShortFromTs(time_tradingday)
    entryBarIndex       := bar_index

    tradeLowestLow      := entryClose
    tradeHighestHigh    := entryClose

    bool showThisCycle = activeCycleYear >= fromYear

    // Green start line is placed on the bar whose TradingView trading-day date matches the start date.
    // If that date has no candle, startCross triggers on the next available candle and the line is placed there.
    if showLines and showThisCycle
        line.new(
            x1 = bar_index, y1 = low, x2 = bar_index, y2 = high,
            xloc = xloc.bar_index, extend = extend.both,
            color = startLineColor, width = startLineWidth, style = f_lineStyle(startLineStyle)
         )

    if showEntryLabels and showThisCycle
        label.new(
             x = bar_index,
             y = low,
             text = "Entry",
             xloc = xloc.bar_index,
             yloc = yloc.belowbar,
             style = label.style_label_up,
             color = entryLabelBgColor,
             textcolor = entryLabelTextColor,
             size = f_labelSize(entryLabelSizeInput)
         )

//====================================================================
// STATS (SUMMARY TABLE RANGE ONLY = fromYear -> lastClosedCycleYear)
//====================================================================
int summaryToYear = not na(lastClosedCycleYear) ? lastClosedCycleYear : (fromYear - 1)

int tradeCount = f_tradeCountInRange(fromYear, summaryToYear, yearlyYears)
int wins = f_winCountInRange(fromYear, summaryToYear, yearlyYears, yearlyResults)

float sumResults         = f_sumInRange(fromYear, summaryToYear, yearlyYears, yearlyResults)
float sumPositiveResults = f_sumPositiveInRange(fromYear, summaryToYear, yearlyYears, yearlyResults)
float sumDDs             = f_sumInRange(fromYear, summaryToYear, yearlyYears, yearlyDDs)

float wr        = tradeCount > 0 ? float(wins) / float(tradeCount) : na
float avgReturn = tradeCount > 0 ? sumResults / tradeCount : na
float returnStd = f_stdevInRange(fromYear, summaryToYear, yearlyYears, yearlyResults)
float avgRet    = wins > 0 ? sumPositiveResults / wins : na
float maxDD     = f_minInRange(fromYear, summaryToYear, yearlyYears, yearlyDDs)
float avgDD     = tradeCount > 0 ? sumDDs / tradeCount : na

float sqn = na
if tradeCount > 1 and not na(returnStd) and returnStd > 0.0
    sqn := math.sqrt(tradeCount) * (avgReturn / returnStd)

string dateText          = f_twoDigits(startDay) + "." + f_twoDigits(startMonth) + " - " + f_twoDigits(endDay) + "." + f_twoDigits(endMonth)
string periodText        = tradeCount > 0 ? f_periodRangeWithDiffText(fromYear, lastClosedCycleYear) : str.tostring(fromYear) + "+"
string winningTradesText = str.tostring(wins) + "/" + str.tostring(tradeCount) + " (" + f_fmtPct(wr) + ")"

int tradeDurationRefYear = not na(lastClosedCycleYear) ? lastClosedCycleYear : currCloseYear
string tradeDurationText = f_tradeDurationText(tradeDurationRefYear)

//====================================================================
// DRAW TABLES + FUTURE PROJECTION
//====================================================================
if barstate.islast
    if not na(summaryTable)
        table.delete(summaryTable)
        summaryTable := na

    if not na(yearlyTable)
        table.delete(yearlyTable)
        yearlyTable := na

    if not na(periodTable)
        table.delete(periodTable)
        periodTable := na

    if not na(projectedStartLine)
        line.delete(projectedStartLine)
        projectedStartLine := na

    if not na(projectedEndLine)
        line.delete(projectedEndLine)
        projectedEndLine := na

    //==================================================
    // SUMMARY TABLE
    //==================================================
    if showSummaryTable
        int summaryRows = f_countSummaryRows()
        summaryRows := math.max(summaryRows, 1)

        summaryTable := table.new(f_tablePos(summaryPosition), 2, summaryRows)
        table.set_frame_color(summaryTable, f_solidColor(borderColor))
        table.set_border_color(summaryTable, f_solidColor(borderColor))
        table.set_frame_width(summaryTable, 1)
        table.set_border_width(summaryTable, 1)

        summarySize = f_textSize(summaryTextSize)

        int row = 0

        if summaryRows == 1 and not (showRowDate or showRowDirection or showRowPeriod or showRowWinningTrades or showRowAvgReturn or showRowTradeDuration or showRowAvgProfit or showRowMaxDD or showRowAvgDD or showRowSQN)
            f_drawCell(summaryTable, 0, 0, "Enable", headerBgColor, headerTextColor, summarySize)
            f_drawCell(summaryTable, 1, 0, "Rows", bodyBgColor, bodyTextColor, summarySize)
        else
            if showRowDirection
                f_drawCell(summaryTable, 0, row, "Long/Short", headerBgColor, headerTextColor, summarySize)
                f_drawCell(summaryTable, 1, row, tradeSide, bodyBgColor, accentTextColor, summarySize)
                row += 1

            if showRowDate
                f_drawCell(summaryTable, 0, row, "Date", headerBgColor, headerTextColor, summarySize)
                f_drawCell(summaryTable, 1, row, dateText, bodyBgColor, bodyTextColor, summarySize)
                row += 1

            if showRowPeriod
                f_drawCell(summaryTable, 0, row, "Period", headerBgColor, headerTextColor, summarySize)
                f_drawCell(summaryTable, 1, row, periodText, bodyBgColor, accentTextColor, summarySize)
                row += 1

            if showRowTradeDuration
                f_drawCell(summaryTable, 0, row, "Trade Duration", headerBgColor, headerTextColor, summarySize)
                f_drawCell(summaryTable, 1, row, tradeDurationText, bodyBgColor, bodyTextColor, summarySize)
                row += 1

            if showRowWinningTrades
                color winTextColor = na(wr) ? bodyTextColor : (wr >= 0.5 ? positiveColor : negativeColor)
                f_drawCell(summaryTable, 0, row, "Winning Trades", headerBgColor, headerTextColor, summarySize)
                f_drawCell(summaryTable, 1, row, winningTradesText, bodyBgColor, winTextColor, summarySize)
                row += 1

            if showRowAvgReturn
                color avgReturnColor = na(avgReturn) ? bodyTextColor : (avgReturn >= 0 ? positiveColor : negativeColor)
                f_drawCell(summaryTable, 0, row, "⌀ Return", headerBgColor, headerTextColor, summarySize)
                f_drawCell(summaryTable, 1, row, f_fmtPct(avgReturn), bodyBgColor, avgReturnColor, summarySize)
                row += 1

            if showRowAvgProfit
                color avgRetColor = na(avgRet) ? bodyTextColor : (avgRet >= 0 ? positiveColor : negativeColor)
                f_drawCell(summaryTable, 0, row, "⌀ Profit", headerBgColor, headerTextColor, summarySize)
                f_drawCell(summaryTable, 1, row, f_fmtPct(avgRet), bodyBgColor, avgRetColor, summarySize)
                row += 1

            if showRowAvgDD
                color avgDdColor = na(avgDD) ? bodyTextColor : negativeColor
                f_drawCell(summaryTable, 0, row, "⌀ DD", headerBgColor, headerTextColor, summarySize)
                f_drawCell(summaryTable, 1, row, f_fmtPct(avgDD), bodyBgColor, avgDdColor, summarySize)
                row += 1

            if showRowMaxDD
                color maxDdColor = na(maxDD) ? bodyTextColor : negativeColor
                f_drawCell(summaryTable, 0, row, "Max DD", headerBgColor, headerTextColor, summarySize)
                f_drawCell(summaryTable, 1, row, f_fmtPct(maxDD), bodyBgColor, maxDdColor, summarySize)
                row += 1
                
            if showRowSQN
                color sqnColor = na(sqn) ? bodyTextColor : (sqn >= 0 ? positiveColor : negativeColor)
                f_drawCell(summaryTable, 0, row, "SQN", headerBgColor, headerTextColor, summarySize)
                f_drawCell(summaryTable, 1, row, f_fmtNum(sqn), bodyBgColor, sqnColor, summarySize)
                row += 1

    //==================================================
    // YEARLY TABLE
    //==================================================
    if showYearlyTable
        int yearlyCols = f_countYearlyCols()
        int visibleYears = f_tradeCountInRange(fromYear, summaryToYear, yearlyYears)
        int yearlyRows = math.max(visibleYears + 1, 2)

        yearlyCols := math.max(yearlyCols, 1)
        yearlyRows := math.max(yearlyRows, 1)

        yearlyTable := table.new(f_tablePos(yearlyPosition), yearlyCols, yearlyRows)
        table.set_frame_color(yearlyTable, f_solidColor(borderColor))
        table.set_border_color(yearlyTable, f_solidColor(borderColor))
        table.set_frame_width(yearlyTable, 1)
        table.set_border_width(yearlyTable, 1)

        yearlySize = f_textSize(yearlyTextSize)

        if f_countYearlyCols() == 0
            f_drawCell(yearlyTable, 0, 0, "Enable at least one column", headerBgColor, headerTextColor, yearlySize)
        else
            int col = 0
            int yearCol = na
            int startDateCol = na
            int endDateCol = na
            int resultCol = na
            int ddCol = na

            if showYearColYear
                yearCol := col
                f_drawCell(yearlyTable, col, 0, "Year", headerBgColor, headerTextColor, yearlySize)
                col += 1

            if showYearColStartDate
                startDateCol := col
                f_drawCell(yearlyTable, col, 0, "Start Date", headerBgColor, headerTextColor, yearlySize)
                col += 1

            if showYearColEndDate
                endDateCol := col
                f_drawCell(yearlyTable, col, 0, "End Date", headerBgColor, headerTextColor, yearlySize)
                col += 1

            if showYearColResult
                resultCol := col
                f_drawCell(yearlyTable, col, 0, "Return %", headerBgColor, headerTextColor, yearlySize)
                col += 1

            if showYearColDD
                ddCol := col
                f_drawCell(yearlyTable, col, 0, "DD %", headerBgColor, headerTextColor, yearlySize)
                col += 1

            if visibleYears == 0
                if showYearColYear
                    f_drawCell(yearlyTable, yearCol, 1, "n/a", bodyBgColor, bodyTextColor, yearlySize)
                if showYearColStartDate
                    f_drawCell(yearlyTable, startDateCol, 1, "n/a", bodyBgColor, bodyTextColor, yearlySize)
                if showYearColEndDate
                    f_drawCell(yearlyTable, endDateCol, 1, "n/a", bodyBgColor, bodyTextColor, yearlySize)
                if showYearColResult
                    f_drawCell(yearlyTable, resultCol, 1, "n/a", bodyBgColor, bodyTextColor, yearlySize)
                if showYearColDD
                    f_drawCell(yearlyTable, ddCol, 1, "n/a", bodyBgColor, bodyTextColor, yearlySize)
            else
                int rowY = 1
                for i = array.size(yearlyYears) - 1 to 0
                    int yr = array.get(yearlyYears, i)
                    if yr >= fromYear and yr <= summaryToYear
                        if showYearColYear
                            f_drawCell(yearlyTable, yearCol, rowY, str.tostring(yr), bodyBgColor, bodyTextColor, yearlySize)

                        if showYearColStartDate
                            f_drawCell(yearlyTable, startDateCol, rowY, array.get(yearlyStartDates, i), bodyBgColor, bodyTextColor, yearlySize)

                        if showYearColEndDate
                            f_drawCell(yearlyTable, endDateCol, rowY, array.get(yearlyEndDates, i), bodyBgColor, bodyTextColor, yearlySize)

                        if showYearColResult
                            float yrResult = array.get(yearlyResults, i)
                            color yrResultColor = na(yrResult) ? bodyTextColor : (yrResult >= 0 ? positiveColor : negativeColor)
                            f_drawCell(yearlyTable, resultCol, rowY, f_fmtPct(yrResult), bodyBgColor, yrResultColor, yearlySize)

                        if showYearColDD
                            float yrDD = array.get(yearlyDDs, i)
                            color yrDDColor = na(yrDD) ? bodyTextColor : negativeColor
                            f_drawCell(yearlyTable, ddCol, rowY, f_fmtPct(yrDD), bodyBgColor, yrDDColor, yearlySize)

                        rowY += 1

    //==================================================
    // PERIOD SUMMARY TABLE
    //==================================================
    if showLookbackTable
        int periodCols = f_countPeriodCols()

        if periodCols <= 0
            periodTable := table.new(f_tablePos(lookbackPosition), 1, 1)
            table.set_frame_color(periodTable, f_solidColor(borderColor))
            table.set_border_color(periodTable, f_solidColor(borderColor))
            table.set_frame_width(periodTable, 1)
            table.set_border_width(periodTable, 1)
            f_drawCell(periodTable, 0, 0, "Enable at least one period", headerBgColor, headerTextColor, f_textSize(lookbackTextSize))
        else
            periodTable := table.new(f_tablePos(lookbackPosition), periodCols + 1, 2)
            table.set_frame_color(periodTable, f_solidColor(borderColor))
            table.set_border_color(periodTable, f_solidColor(borderColor))
            table.set_frame_width(periodTable, 1)
            table.set_border_width(periodTable, 1)

            periodSize = f_textSize(lookbackTextSize)
            int pCol = 1
            int refYear = not na(lastClosedCycleYear) ? lastClosedCycleYear : na

            f_drawCell(periodTable, 0, 0, "Period", headerBgColor, headerTextColor, periodSize)
            f_drawCell(periodTable, 0, 1, "Winning Trades", headerBgColor, headerTextColor, periodSize)

            if showPeriod1
                string txt1 = "n/a"
                float wr1 = na
                string lbl1 = not na(refYear) ? f_periodDiffText(period1FromYear, refYear) : "n/a"
                if not na(refYear)
                    [tmpTxt1, tmpWr1] = f_periodWinningText(period1FromYear, refYear, yearlyYears, yearlyResults)
                    txt1 := tmpTxt1
                    wr1 := tmpWr1
                color col1 = na(wr1) ? bodyTextColor : (wr1 >= 0.5 ? positiveColor : negativeColor)
                f_drawCell(periodTable, pCol, 0, lbl1, bodyBgColor, bodyTextColor, periodSize)
                f_drawCell(periodTable, pCol, 1, txt1, bodyBgColor, col1, periodSize)
                pCol += 1

            if showPeriod2
                string txt2 = "n/a"
                float wr2 = na
                string lbl2 = not na(refYear) ? f_periodDiffText(period2FromYear, refYear) : "n/a"
                if not na(refYear)
                    [tmpTxt2, tmpWr2] = f_periodWinningText(period2FromYear, refYear, yearlyYears, yearlyResults)
                    txt2 := tmpTxt2
                    wr2 := tmpWr2
                color col2 = na(wr2) ? bodyTextColor : (wr2 >= 0.5 ? positiveColor : negativeColor)
                f_drawCell(periodTable, pCol, 0, lbl2, bodyBgColor, bodyTextColor, periodSize)
                f_drawCell(periodTable, pCol, 1, txt2, bodyBgColor, col2, periodSize)
                pCol += 1

            if showPeriod3
                string txt3 = "n/a"
                float wr3 = na
                string lbl3 = not na(refYear) ? f_periodDiffText(period3FromYear, refYear) : "n/a"
                if not na(refYear)
                    [tmpTxt3, tmpWr3] = f_periodWinningText(period3FromYear, refYear, yearlyYears, yearlyResults)
                    txt3 := tmpTxt3
                    wr3 := tmpWr3
                color col3 = na(wr3) ? bodyTextColor : (wr3 >= 0.5 ? positiveColor : negativeColor)
                f_drawCell(periodTable, pCol, 0, lbl3, bodyBgColor, bodyTextColor, periodSize)
                f_drawCell(periodTable, pCol, 1, txt3, bodyBgColor, col3, periodSize)
                pCol += 1

            if showPeriod4
                string txt4 = "n/a"
                float wr4 = na
                string lbl4 = not na(refYear) ? f_periodDiffText(period4FromYear, refYear) : "n/a"
                if not na(refYear)
                    [tmpTxt4, tmpWr4] = f_periodWinningText(period4FromYear, refYear, yearlyYears, yearlyResults)
                    txt4 := tmpTxt4
                    wr4 := tmpWr4
                color col4 = na(wr4) ? bodyTextColor : (wr4 >= 0.5 ? positiveColor : negativeColor)
                f_drawCell(periodTable, pCol, 0, lbl4, bodyBgColor, bodyTextColor, periodSize)
                f_drawCell(periodTable, pCol, 1, txt4, bodyBgColor, col4, periodSize)
                pCol += 1

    //==================================================
    // FUTURE PROJECTION
    //==================================================
    if showProjectedLines
        int searchFromYear = math.max(calcFromYear, currCloseYear)
        int futureStartTs = na
        int futureEndTs = na
        int futureEndCycleYear = na

        for y = searchFromYear to searchFromYear + 10
            int candidateStartTs = f_projectedStartTs(y)
            if candidateStartTs > currDateNoonTs
                futureStartTs := candidateStartTs
                break

        for y = searchFromYear to searchFromYear + 10
            int candidateEndTs = f_projectedEndTs(y)
            if candidateEndTs > currDateNoonTs
                futureEndTs := candidateEndTs
                futureEndCycleYear := y
                break

        if not na(futureStartTs)
            int startBarsAhead = f_businessDaysBetween(currDateNoonTs, futureStartTs)
            if startBarsAhead > 0
                projectedStartLine := line.new(
                     x1 = bar_index + startBarsAhead, y1 = low,
                     x2 = bar_index + startBarsAhead, y2 = high,
                     xloc = xloc.bar_index, extend = extend.both,
                     color = startLineColor, width = startLineWidth, style = f_lineStyle(startLineStyle)
                 )

        if not na(futureEndTs)
            int endBarsAhead = f_businessDaysBetween(currDateNoonTs, futureEndTs)
            if endBarsAhead > 0
                int endLineOffset = f_endLineBarOffset(futureEndCycleYear)
                int projectedEndX = bar_index + endBarsAhead + endLineOffset

                projectedEndLine := line.new(
                    x1 = projectedEndX, y1 = low,
                    x2 = projectedEndX, y2 = high,
                    xloc = xloc.bar_index, extend = extend.both,
                    color = endLineColor, width = endLineWidth, style = f_lineStyle(endLineStyle)
                 )
````
