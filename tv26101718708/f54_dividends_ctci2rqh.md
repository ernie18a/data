# F54 Dividends

- url: https://www.tradingview.com/script/ctCi2rQh-F54-Dividends/
- type: indicator
- pine_id: PUB;5899f8d2ef344968abcaa1365e8bf36f
- version: 1.0

## Description

[b]F54 Dividends[/b]

[b]Overview[/b]
F54 Dividends is an informational indicator that visualises cash dividend events for the active symbol and shows event-level plus cumulative dividend context directly on the chart.

The script is designed for analysis and transparency of dividend history. It does not place orders and does not provide trade execution logic.

[b]Why This Indicator Is Useful[/b]
Dividend income is a core component of total return for income-oriented investors, yet TradingView's default chart view gives no direct visibility into it. This indicator bridges that gap.

[list]
[*][b]Yield on cost at a glance.[/b] Each label shows the dividend ratio relative to the price at the time of the ex-dividend event, so you can immediately see how yield evolved over time as the share price changed.
[*][b]Cumulative income picture.[/b] The YTD, Fixed 12M, and Rolling 12M accumulation modes let you see how much income a position has generated over a meaningful period without switching to a separate data source or spreadsheet.
[*][b]Pattern recognition.[/b] Seeing dividend events overlaid on price action makes it easy to spot payout consistency, growth trends, or cuts alongside the price history that accompanied them.
[*][b]Monthly vs quarterly discrimination.[/b] The script automatically detects likely monthly payers and suppresses per-event noise, showing only quarter-end summaries to keep the chart readable without losing the cumulative picture.
[*][b]Period boundary awareness.[/b] New accumulation periods (calendar year or 12-month anchor) are highlighted with a distinct label colour, so resets are immediately visible rather than hidden in the data.
[/list]

Together these features let you assess a symbol's income quality and consistency directly on the price chart, supporting dividend-focused screening, position review, and historical context gathering.

[b]What The Indicator Shows[/b]
- Detects ex-dividend events from TradingView dividend data.
- Displays per-event dividend amount in EUR.
- Displays per-event dividend ratio relative to a reference close.
- Displays cumulative dividend amount and cumulative dividend ratio according to the selected accumulation mode.
- Limits visible labels to the most recent N events to keep the chart readable.

[b]Accumulation Modes[/b]
- YTD: Resets cumulative values at the start of each calendar year.
- Fixed 12M: Uses a fixed 12-month period anchored by the current month.
- Rolling 12M: Uses a continuously rolling 365-day window.

[b]Inputs[/b]
- Show last N labels: Controls how many recent dividend labels remain visible.
- Accumulation mode: Selects how cumulative values are calculated (YTD, Fixed 12M, Rolling 12M).

[b]How To Read Labels[/b]
Each label includes:
- Dividend amount for the current ex-day.
- Event ratio (R) for the current ex-day.
- Cumulative amount for the selected period.
- Cumulative ratio (R) for the selected period.
- In YTD and Fixed 12M modes, the start of a new accumulation period is highlighted with a teal label.

[b]Notes And Limitations[/b]
- Output depends on TradingView dividend data availability and symbol coverage.
- Currency display is EUR in this script configuration.
- Label visibility may vary with chart scaling and timeframe.
- In Rolling 12M mode, accumulated values are window-based and may fall when older ex-dividend events leave the 12-month window, which can be confusing if a steadily increasing total is expected.
- Past data can be revised by data providers; values are informational.

[b]Compliance And Disclaimer[/b]
This script is for educational and informational purposes only.
It is not investment advice, not a solicitation, and not a guarantee of future results.
Always perform your own research and risk assessment before making investment decisions.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// ©2025-2026 Finanz54

//@version=6
indicator('F54 Dividends', overlay = true)

showLastNLabels = input.int(defval = 6, minval = 1, maxval = 40, title = 'Show last N labels')
accumulationMode = input.string(defval = 'YTD', title = 'Accumulation mode', options = ['YTD', 'Fixed 12M', 'Rolling 12M'])

div = request.dividends(syminfo.tickerid, dividends.gross, barmerge.gaps_on, barmerge.lookahead_off, true, currency.EUR)

// Dividend event detection and yearly accumulation.
isExDay = not na(div) and div > 0
dayChanged = ta.change(time('D')) != 0
isNewExDay = isExDay and (not isExDay[1] or dayChanged)

refClose = not na(close[1]) and close[1] > 0 ? close[1] : close
divRatioPct = isNewExDay and refClose > 0 ? div / refClose * 100.0 : na

msPerDay = 24 * 60 * 60 * 1000
rollingWindowMs = 365 * msPerDay
anchorMonth = month(timenow)

curYear = year(time)
newYear = ta.change(curYear) != 0
var float cumDivAmountYearEur = 0.0
var float sumRefCloseYear = 0.0
var int countExDaysYear = 0
var float cumDivAmount12mEur = 0.0
var float sumRefClose12m = 0.0
var int countExDays12m = 0
var float cumDivAmountRolling12mEur = 0.0
var float sumRefCloseRolling12m = 0.0
var int countExDaysRolling12m = 0
var int current12mPeriodEndYear = na
var int[] exDayTimes = array.new_int()
var float[] exDayDivs = array.new_float()
var float[] exDayRefCloses = array.new_float()

if newYear
    cumDivAmountYearEur := 0.0
    sumRefCloseYear := 0.0
    countExDaysYear := 0

if isNewExDay and not na(divRatioPct)
    cumDivAmountYearEur += div
    sumRefCloseYear += refClose
    countExDaysYear += 1

    array.push(exDayTimes, time)
    array.push(exDayDivs, div)
    array.push(exDayRefCloses, refClose)

    periodEndYear = month(time) > anchorMonth ? year(time) + 1 : year(time)
    if na(current12mPeriodEndYear) or periodEndYear != current12mPeriodEndYear
        cumDivAmount12mEur := 0.0
        sumRefClose12m := 0.0
        countExDays12m := 0
        current12mPeriodEndYear := periodEndYear

    cumDivAmount12mEur += div
    sumRefClose12m += refClose
    countExDays12m += 1

    rollingCutoffTime = time - rollingWindowMs
    calcDivAmountRolling12mEur = 0.0
    calcRefCloseRolling12m = 0.0
    calcCountExDaysRolling12m = 0
    for i = 0 to array.size(exDayTimes) - 1
        if array.get(exDayTimes, i) >= rollingCutoffTime
            calcDivAmountRolling12mEur += array.get(exDayDivs, i)
            calcRefCloseRolling12m += array.get(exDayRefCloses, i)
            calcCountExDaysRolling12m += 1

    cumDivAmountRolling12mEur := calcDivAmountRolling12mEur
    sumRefCloseRolling12m := calcRefCloseRolling12m
    countExDaysRolling12m := calcCountExDaysRolling12m

avgRefCloseYear = countExDaysYear > 0 ? sumRefCloseYear / countExDaysYear : na
cumDivRatioYearPct = not na(avgRefCloseYear) and avgRefCloseYear > 0 ? cumDivAmountYearEur / avgRefCloseYear * 100.0 : na

avgRefClose12m = countExDays12m > 0 ? sumRefClose12m / countExDays12m : na
cumDivRatio12mPct = not na(avgRefClose12m) and avgRefClose12m > 0 ? cumDivAmount12mEur / avgRefClose12m * 100.0 : na
avgRefCloseRolling12m = countExDaysRolling12m > 0 ? sumRefCloseRolling12m / countExDaysRolling12m : na
cumDivRatioRolling12mPct = not na(avgRefCloseRolling12m) and avgRefCloseRolling12m > 0 ? cumDivAmountRolling12mEur / avgRefCloseRolling12m * 100.0 : na

atr14 = ta.atr(14)

prevExYear = ta.valuewhen(isNewExDay, year(time), 1)
prevExMonth = ta.valuewhen(isNewExDay, month(time), 1)
prevExExists = not na(prevExYear) and not na(prevExMonth)
monthIndex = year(time) * 12 + month(time)
prevMonthIndex = prevExExists ? int(prevExYear) * 12 + int(prevExMonth) : na
monthDiff = prevExExists ? monthIndex - prevMonthIndex : na

var int consecutiveMonthlyGaps = 0
if isNewExDay
    if not na(monthDiff) and monthDiff == 1
        consecutiveMonthlyGaps += 1
    else
        consecutiveMonthlyGaps := 0

isLikelyMonthlyDividends = consecutiveMonthlyGaps >= 2
isQuarterEndMonth = month(time) == 3 or month(time) == 6 or month(time) == 9 or month(time) == 12
useYtd = accumulationMode == 'YTD'
useFixed12m = accumulationMode == 'Fixed 12M'
useRolling12m = accumulationMode == 'Rolling 12M'
isYtdPeriodStart = month(time) == 1
isFixed12mPeriodStart = countExDays12m == 1
showPeriodStartForMonthly = useYtd and isYtdPeriodStart or useFixed12m and isFixed12mPeriodStart
showLabelForThisExDay = not isLikelyMonthlyDividends or isQuarterEndMonth or showPeriodStartForMonthly

var label[] dividendLabels = array.new_label()
if isNewExDay and not na(divRatioPct) and showLabelForThisExDay
    periodText = useFixed12m or useRolling12m ? '12M' : 'YTD'
    cumAmountDisplay = useRolling12m ? cumDivAmountRolling12mEur : useFixed12m ? cumDivAmount12mEur : cumDivAmountYearEur
    cumRatioDisplay = useRolling12m ? cumDivRatioRolling12mPct : useFixed12m ? cumDivRatio12mPct : cumDivRatioYearPct
    labelColor = useYtd and isYtdPeriodStart ? color.new(color.green, 20) : useFixed12m and isFixed12mPeriodStart ? color.new(color.teal, 20) : color.new(color.blue, 30)
    safeCumAmountDisplay = na(cumAmountDisplay) ? 0.0 : cumAmountDisplay
    safeCumRatioDisplay = na(cumRatioDisplay) ? 0.0 : cumRatioDisplay

    dividendAmountText = str.tostring(math.round(div * 100.0) / 100.0, '0.00') + ' EUR'
    dividendRatioText = 'R ' + str.tostring(math.round(divRatioPct * 100.0) / 100.0, '0.00') + ' %'
    dividendCumRatioText = str.tostring(math.round(safeCumRatioDisplay * 100.0) / 100.0, '0.00') + ' %'
    dividendCumAmountText = str.tostring(math.round(safeCumAmountDisplay * 100.0) / 100.0, '0.00') + ' EUR'
    labelText = str.tostring(curYear) + ': ' + dividendAmountText + ' | ' + dividendRatioText + '\n ' + periodText + ': ' + dividendCumAmountText + ' | R ' + dividendCumRatioText
    yLabel = high + atr14 * 0.2
    newLabel = label.new(
        bar_index,
        yLabel,
        text = labelText,
        style = label.style_label_down,
        yloc = yloc.abovebar,
        xloc = xloc.bar_index,
        color = labelColor,
        textcolor = color.white,
        size = size.normal,
        textalign = text.align_left,
        force_overlay = true
    )
    array.push(dividendLabels, newLabel)
    while array.size(dividendLabels) > showLastNLabels
        oldestLabel = array.shift(dividendLabels)
        label.delete(oldestLabel)
````
