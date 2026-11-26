# IND007-Seasonality Monthly Window Map

- url: https://www.tradingview.com/script/Ex3epyjG-IND007-Seasonality-Monthly-Window-Map/
- type: indicator
- pine_id: PUB;3f1f1f9bb9a74641b926539d86812033
- version: 1.0

## Description

[b]Seasonality Monthly Window Map[/b] scans historical daily data to find recurring bullish and bearish calendar windows. It helps users quickly see which periods of the year were historically stronger or weaker for the selected asset, then ranks the best windows by hit rate, average move, sample size, and score.

[quote]Use it to add seasonal context before a setup begins, not as a standalone trading signal.[/quote]

[b]==================================================
WARNING
==================================================[/b]

This indicator studies historical seasonal behavior. It does not predict the future and it does not create guaranteed trading opportunities.

The table shows how similar calendar windows behaved in past years. A strong historical window means that the same date range showed repeated directional behavior in the available data. It does not mean the same result must happen again.

[quote]Use this script as a historical seasonality map, not as a standalone buy or sell signal system.[/quote]

[b]==================================================
(1) PURPOSE
==================================================[/b]

[b]Seasonality Monthly Window Map[/b] is a public open-source indicator that scans historical daily data to find recurring bullish and bearish calendar windows.

Its purpose is to help users quickly see which parts of the year were historically stronger, weaker, or neutral for the selected asset.

The indicator is attractive because it reduces thousands of possible calendar windows into a compact table with only the strongest filtered results.

[quote]In simple words: it checks past seasonal behavior, ranks the strongest windows, and shows them in an easy-to-read table.[/quote]

[b]==================================================
(2) HOW IT WORKS
==================================================[/b]

The script works on the [b]Daily timeframe[/b]. It stores historical daily closes by calendar day of the year, then tests many possible start and end date windows.

With the default settings of 15 to 60 days, the script checks up to about [b]15,065 possible seasonal windows[/b]. The exact number changes when the minimum and maximum window length inputs are changed.

For each window, the script checks how that same calendar period performed across past years.

It calculates:

[list]
[*][b]Historical Hit Rate[/b] - how often the window moved in the tested direction.
[*][b]Average Move[/b] - the average percentage move during that window.
[*][b]Sample Count[/b] - how many historical years were available.
[*][b]Score[/b] - the final ranking value used to compare windows.
[/list]

The script then keeps only the windows that pass the selected filters and places the strongest bullish and bearish windows into the table.

[b]==================================================
(3) HOW THE SCORE WORKS
==================================================[/b]

The score is designed to reward windows that are directional, consistent, and supported by enough historical samples.

[pine]
Score = Historical Hit Rate x Directional Average Move x Sample Factor / sqrt(Window Length)
[/pine]

Then the result is multiplied by the Score Scale input and limited to a maximum of 1000.

A higher score usually means:

[list]
[*]the window moved in the same direction more often
[*]the average move was stronger
[*]the window had more historical samples
[*]the window was not unnecessarily long
[/list]

[quote]A high score means the historical window ranked well under the current settings. It does not guarantee future performance.[/quote]

[b]==================================================
(4) TABLE MEANING
==================================================[/b]

The table is designed to show both monthly context and more specific seasonal windows.

[list]
[*][b]MONTH AVG[/b] - average historical performance of the full month.
[*][b]WINDOW[/b] - the seasonal start and end date.
[*][b]HIT%[/b] - historical directional frequency.
[*][b]AVG%[/b] - average percentage move for the window.
[*][b]SCORE[/b] - ranking value for comparison.
[/list]

[b]Color meaning[/b]

[list]
[*][b]Green[/b] - positive / bullish historical behavior.
[*][b]Red[/b] - negative / bearish historical behavior.
[*][b]Yellow[/b] - near-neutral behavior.
[*][b]Dark row[/b] - no strong timing edge under the current filters.
[/list]

The month row gives broad context. The rows below it show more specific historical windows that passed the filters.

[b]==================================================
(5) HOW TO USE IT PROPERLY
==================================================[/b]

[list=1]
[*][b]Use the Daily timeframe.[/b]
The script is built for daily seasonal data.

[*][b]Start with the month row.[/b]
This shows whether the full month was historically positive, negative, or neutral.

[*][b]Then check the window rows.[/b]
These show the strongest filtered seasonal windows inside or around that month.

[*][b]Compare HIT%, AVG%, and SCORE together.[/b]
Do not rely on only one number.

[*][b]Check current trend and chart structure.[/b]
Seasonality should support your analysis, not replace it.

[*][b]Use alerts for awareness only.[/b]
Alerts can notify when a historical window is soon, active, or recently started. They are not trade instructions.
[/list]

[quote]Best use: treat seasonality as confirmation together with trend, structure, liquidity, and risk management.[/quote]

[b]==================================================
(6) IMPORTANT LIMITATION
==================================================[/b]

Seasonality studies often have limited sample size. Many assets may only provide around [b]10 to 20 useful yearly samples[/b], depending on how much historical daily data is available.

This is important because 10 to 20 samples can show a historical tendency, but it is not enough to prove that a pattern is highly reliable.

A high historical hit rate can still be misleading when the sample size is small. Market behavior can also change because of news, macro conditions, liquidity changes, or structural changes in the asset.

[quote]The table should be read as historical context, not statistical certainty.[/quote]

[b]==================================================
(7) ALERTS
==================================================[/b]

The script includes alerts for seasonal windows that are:

[list]
[*]starting soon
[*]starting today
[*]recently started
[*]currently active
[*]passing hit-rate, score, or average-move filters
[*]confirmed by a simple trend or EMA filter
[/list]

Alerts are useful for timing awareness, but they do not replace chart review or risk management.

[b]==================================================
(8) SUMMARY
==================================================[/b]

This indicator scans historical daily data and tests many calendar windows to find seasonal periods that were repeatedly bullish or bearish in the past.

With default settings, it can check up to about [b]15,065 possible windows[/b]. It then filters and ranks them using historical hit rate, average move, sample count, and score.

The main strength of the tool is that it makes seasonal research faster and easier to read.

The main weakness is that historical seasonal data often has a limited number of yearly samples, usually around 10 to 20 for many assets. Because of that, the results should be used as context and confirmation, not as proof or prediction.

[b]==================================================
DISCLAIMER
==================================================[/b]

This script is a public open-source indicator for educational and informational use.

It is not financial advice, investment advice, or a recommendation to buy or sell any asset.

The script studies historical seasonal behavior only. It does not guarantee profitable trades, signal accuracy, or future performance.

Past seasonal behavior may not repeat. Users should always apply their own analysis, position sizing, and risk management before making any trading decision.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ReconHK

//@version=6
indicator("IND007-Seasonality Monthly Window Map", shorttitle="Seasonality Windows", overlay=true, max_bars_back=5000)

//------------------------------------------------------------------------------
// Seasonality Monthly Window Map
//
// Public-library note:
// This indicator studies historical daily seasonal windows. It does not place
// trades, backtest a strategy, or predict future returns. The table shows how
// often past windows moved in one direction and how large the average move was.
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
grpCalc   = "Core Calculation"
grpFilter = "Quality Filters"
grpTable  = "Table Display"
grpTrend  = "Trend Filter"
grpAdv    = "Advanced Settings"
grpAlerts = "Alert Conditions"

minLenD       = input.int(15, "Min window length (days)", minval=1, maxval=200, group=grpCalc)
maxLenD       = input.int(60, "Max window length (days)", minval=2, maxval=300, group=grpCalc)
minSamples    = input.int(10, "Min historical samples (#years)", minval=10, maxval=200, group=grpCalc)
scoreScale    = input.float(4.0, "Score scale", step=0.5, group=grpCalc)

baseMinHitRate = input.float(75.0, "Minimum historical hit rate (%)", step=0.5, group=grpFilter)
baseMinScore   = input.float(500.0, "Minimum historical score", step=1.0, group=grpFilter)
baseRequireAvg = input.bool(true, "Require directional average > 0", group=grpFilter)

panelOpacity = input.int(10, "Table opacity (0 solid .. 100 transparent)", minval=0, maxval=100, group=grpTable)
textSizeOpt  = input.string("Normal", "Table text size", options=["Small", "Normal", "Large"], group=grpTable)
showTable    = input.bool(true, "Show table", group=grpTable)

trendLen = input.int(9, "Trend SMA length", minval=1, maxval=100, group=grpTrend)

topN                = input.int(10, "Rows per side", minval=1, maxval=10, group=grpAdv)
overlapThresholdPct = input.float(70.0, "Reject window overlap above (%)", minval=0, maxval=100, step=5.0, group=grpAdv)
useConfidenceScore  = input.bool(true, "Use sample-size adjustment", group=grpAdv)
confidenceWeight    = input.float(0.15, "Sample-size adjustment weight", minval=0.0, maxval=0.5, step=0.05, group=grpAdv)
neutralBand         = input.float(0.10, "Neutral monthly average band (%)", minval=0.0, step=0.05, group=grpAdv)

alertSoonDays    = input.int(7, "Soon window (days)", minval=1, maxval=30, group=grpAlerts)
alertRecentDays  = input.int(5, "Recent window (days)", minval=1, maxval=30, group=grpAlerts)
alertMinHitRate  = input.float(90.0, "Min historical hit rate %", step=0.5, group=grpAlerts)
alertMinScore1   = input.float(800.0, "Min historical score 1", step=1.0, group=grpAlerts)
alertMinScore2   = input.float(1000.0, "Min historical score 2", step=1.0, group=grpAlerts)
alertMinAvgMove  = input.float(10.0, "Min historical average move %", step=0.5, group=grpAlerts)
useEMA9Filter    = input.bool(true, "Use EMA9 confirmation", group=grpAlerts)

//------------------------------------------------------------------------------
// Helpers and colors
//------------------------------------------------------------------------------
f_size() =>
    textSizeOpt == "Large" ? size.large : textSizeOpt == "Small" ? size.small : size.normal

bgPanel     = color.new(color.black, panelOpacity)
hdrBg       = color.new(color.black, 0)
warnBg      = color.rgb(150, 25, 25)
emptyBg     = color.rgb(45, 45, 45)
bullBg      = color.new(color.green, 0)
bearBg      = color.new(color.red, 0)
mixBg       = color.new(color.yellow, 0)
noPatternBg = color.rgb(170, 35, 35)

f_clampScore(x) =>
    math.min(1000.0, math.max(0.0, x))

f_passFilter(hitRate, score, dirAvg, minHitRate, minScore, requireAvg) =>
    hitRate >= minHitRate and score >= minScore and (requireAvg ? dirAvg > 0 : true)

f_doy(ts) =>
    int y = year(ts)
    int t0 = timestamp(y, 1, 1, 0, 0)
    int msDay = 86400000
    int(math.floor((ts - t0) / msDay)) + 1

f_mdFromDoy365(doy1to365) =>
    int d = doy1to365
    if na(d) or d < 1 or d > 365
        "??-??"
    else
        int m = 1
        int day = d
        int l1 = 31, l2 = 28, l3 = 31, l4 = 30, l5 = 31, l6 = 30, l7 = 31, l8 = 31, l9 = 30, l10 = 31, l11 = 30
        if day > l1
            day -= l1
            m := 2
            if day > l2
                day -= l2
                m := 3
                if day > l3
                    day -= l3
                    m := 4
                    if day > l4
                        day -= l4
                        m := 5
                        if day > l5
                            day -= l5
                            m := 6
                            if day > l6
                                day -= l6
                                m := 7
                                if day > l7
                                    day -= l7
                                    m := 8
                                    if day > l8
                                        day -= l8
                                        m := 9
                                        if day > l9
                                            day -= l9
                                            m := 10
                                            if day > l10
                                                day -= l10
                                                m := 11
                                                if day > l11
                                                    day -= l11
                                                    m := 12
        str.format("{0,number,00}-{1,number,00}", day, m)

f_monthFromDoy365(doy1to365) =>
    int d = doy1to365
    if na(d) or d < 1 or d > 365
        na
    else
        int m = 1
        int day = d
        int l1 = 31, l2 = 28, l3 = 31, l4 = 30, l5 = 31, l6 = 30, l7 = 31, l8 = 31, l9 = 30, l10 = 31, l11 = 30
        if day > l1
            day -= l1
            m := 2
            if day > l2
                day -= l2
                m := 3
                if day > l3
                    day -= l3
                    m := 4
                    if day > l4
                        day -= l4
                        m := 5
                        if day > l5
                            day -= l5
                            m := 6
                            if day > l6
                                day -= l6
                                m := 7
                                if day > l7
                                    day -= l7
                                    m := 8
                                    if day > l8
                                        day -= l8
                                        m := 9
                                        if day > l9
                                            day -= l9
                                            m := 10
                                            if day > l10
                                                day -= l10
                                                m := 11
                                                if day > l11
                                                    day -= l11
                                                    m := 12
        m

f_monthName(m) =>
    m == 1 ? "January" :
     m == 2 ? "February" :
     m == 3 ? "March" :
     m == 4 ? "April" :
     m == 5 ? "May" :
     m == 6 ? "June" :
     m == 7 ? "July" :
     m == 8 ? "August" :
     m == 9 ? "September" :
     m == 10 ? "October" :
     m == 11 ? "November" : "December"

f_monthStartDoy(m) =>
    m == 1 ? 1 : m == 2 ? 32 : m == 3 ? 60 : m == 4 ? 91 : m == 5 ? 121 : m == 6 ? 152 : m == 7 ? 182 : m == 8 ? 213 : m == 9 ? 244 : m == 10 ? 274 : m == 11 ? 305 : 335

f_monthEndDoy(m) =>
    m == 1 ? 31 : m == 2 ? 59 : m == 3 ? 90 : m == 4 ? 120 : m == 5 ? 151 : m == 6 ? 181 : m == 7 ? 212 : m == 8 ? 243 : m == 9 ? 273 : m == 10 ? 304 : m == 11 ? 334 : 365

f_perfBg(v) =>
    na(v) ? emptyBg : v > neutralBand ? bullBg : v < -neutralBand ? bearBg : mixBg

f_sampleFactor(samp, effMinSamples) =>
    float baseConf = math.sqrt(samp / effMinSamples)
    1.0 + (baseConf - 1.0) * confidenceWeight

f_windowOverlapPct(s1, e1, s2, e2) =>
    int inter = math.max(0, math.min(e1, e2) - math.max(s1, s2))
    int len1 = math.max(1, e1 - s1)
    int len2 = math.max(1, e2 - s2)
    float base = math.min(len1, len2)
    base > 0 ? inter * 100.0 / base : 0.0

//------------------------------------------------------------------------------
// Daily series
//------------------------------------------------------------------------------
dClose = request.security(syminfo.tickerid, "D", close, barmerge.gaps_off, barmerge.lookahead_off)
dTime  = request.security(syminfo.tickerid, "D", time,  barmerge.gaps_off, barmerge.lookahead_off)
yy     = request.security(syminfo.tickerid, "D", year(time), barmerge.gaps_off, barmerge.lookahead_off)

doyDaily = f_doy(dTime)
smaTrend = ta.sma(close, trendLen)

//------------------------------------------------------------------------------
// Year x day-of-year storage
//------------------------------------------------------------------------------
const int DAYS_PER_YEAR = 366
var arrYearList = array.new_int()
var arrDayClose = array.new_float()

f_getYearIndex(y) =>
    int sz = array.size(arrYearList)
    int idx = na
    if sz > 0
        for i = 0 to sz - 1
            if array.get(arrYearList, i) == y
                idx := i
    idx

f_ensureYear(y) =>
    int idx = f_getYearIndex(y)
    if na(idx)
        array.push(arrYearList, y)
        for _ = 0 to DAYS_PER_YEAR - 1
            array.push(arrDayClose, na)
        idx := array.size(arrYearList) - 1
    idx

f_pos(yearIdx, doy1to366) =>
    yearIdx * DAYS_PER_YEAR + (doy1to366 - 1)

f_setDay(yearIdx, doy1to366, c) =>
    int p = f_pos(yearIdx, doy1to366)
    if p >= 0 and p < array.size(arrDayClose)
        array.set(arrDayClose, p, c)

f_getClose(yearIdx, doy1to366) =>
    int p = f_pos(yearIdx, doy1to366)
    p >= 0 and p < array.size(arrDayClose) ? array.get(arrDayClose, p) : na

bool newDailyBar = not na(dTime) and (na(dTime[1]) or dTime != dTime[1])
if newDailyBar and doyDaily >= 1 and doyDaily <= 366
    int yIdx = f_ensureYear(yy)
    f_setDay(yIdx, doyDaily, dClose)

//------------------------------------------------------------------------------
// Ranked historical windows
//------------------------------------------------------------------------------
var B_sD    = array.new_int()
var B_eD    = array.new_int()
var B_hit   = array.new_float()
var B_avg   = array.new_float()
var B_davg  = array.new_float()
var B_score = array.new_float()

var S_sD    = array.new_int()
var S_eD    = array.new_int()
var S_hit   = array.new_float()
var S_avg   = array.new_float()
var S_davg  = array.new_float()
var S_score = array.new_float()

f_resetBullWindows() =>
    array.clear(B_sD)
    array.clear(B_eD)
    array.clear(B_hit)
    array.clear(B_avg)
    array.clear(B_davg)
    array.clear(B_score)

f_resetBearWindows() =>
    array.clear(S_sD)
    array.clear(S_eD)
    array.clear(S_hit)
    array.clear(S_avg)
    array.clear(S_davg)
    array.clear(S_score)

f_insertBull(sD, eD, hitRate, avg, dirAvg, score) =>
    bool reject = false
    int sz0 = array.size(B_score)
    if sz0 > 0
        for j = 0 to sz0 - 1
            float ov = f_windowOverlapPct(sD, eD, array.get(B_sD, j), array.get(B_eD, j))
            if ov >= overlapThresholdPct
                reject := true
    if not reject
        int sz = array.size(B_score)
        int ins = 0
        if sz > 0
            for i = 0 to sz - 1
                if score <= array.get(B_score, i)
                    ins += 1
        array.insert(B_sD, ins, sD)
        array.insert(B_eD, ins, eD)
        array.insert(B_hit, ins, hitRate)
        array.insert(B_avg, ins, avg)
        array.insert(B_davg, ins, dirAvg)
        array.insert(B_score, ins, score)
        while array.size(B_score) > topN
            array.pop(B_sD)
            array.pop(B_eD)
            array.pop(B_hit)
            array.pop(B_avg)
            array.pop(B_davg)
            array.pop(B_score)

f_insertBear(sD, eD, hitRate, avg, dirAvg, score) =>
    bool reject = false
    int sz0 = array.size(S_score)
    if sz0 > 0
        for j = 0 to sz0 - 1
            float ov = f_windowOverlapPct(sD, eD, array.get(S_sD, j), array.get(S_eD, j))
            if ov >= overlapThresholdPct
                reject := true
    if not reject
        int sz = array.size(S_score)
        int ins = 0
        if sz > 0
            for i = 0 to sz - 1
                if score <= array.get(S_score, i)
                    ins += 1
        array.insert(S_sD, ins, sD)
        array.insert(S_eD, ins, eD)
        array.insert(S_hit, ins, hitRate)
        array.insert(S_avg, ins, avg)
        array.insert(S_davg, ins, dirAvg)
        array.insert(S_score, ins, score)
        while array.size(S_score) > topN
            array.pop(S_sD)
            array.pop(S_eD)
            array.pop(S_hit)
            array.pop(S_avg)
            array.pop(S_davg)
            array.pop(S_score)

//------------------------------------------------------------------------------
// Month storage
//------------------------------------------------------------------------------
var monthBullSlotIdx   = array.new_int(120, -1)
var monthBearSlotIdx   = array.new_int(120, -1)
var monthBullFillCount = array.new_int(12, 0)
var monthBearFillCount = array.new_int(12, 0)
var monthPerfAvg       = array.new_float(12, na)

f_resetMonthDist() =>
    for i = 0 to 119
        array.set(monthBullSlotIdx, i, -1)
        array.set(monthBearSlotIdx, i, -1)
    for i = 0 to 11
        array.set(monthBullFillCount, i, 0)
        array.set(monthBearFillCount, i, 0)
        array.set(monthPerfAvg, i, na)

f_slot(monthNum, slotNum) =>
    (monthNum - 1) * 10 + slotNum

//------------------------------------------------------------------------------
// Table
//------------------------------------------------------------------------------
const int COLS = 5
const int ROWS = 35
var table tMain = table.new(position.top_right, COLS, ROWS, border_width=2, frame_width=2)

f_clearTable() =>
    for r = 0 to ROWS - 1
        for c = 0 to COLS - 1
            table.cell(tMain, c, r, "", bgcolor=bgPanel, text_color=color.white, text_size=f_size())

f_drawHeader() =>
    table.cell(tMain, 0, 0, "MONTH AVG", bgcolor=hdrBg, text_color=color.white, text_size=f_size())
    table.cell(tMain, 1, 0, "WINDOW",    bgcolor=hdrBg, text_color=color.white, text_size=f_size())
    table.cell(tMain, 2, 0, "HIT%",      bgcolor=hdrBg, text_color=color.white, text_size=f_size())
    table.cell(tMain, 3, 0, "AVG%",      bgcolor=hdrBg, text_color=color.white, text_size=f_size())
    table.cell(tMain, 4, 0, "SCORE",     bgcolor=hdrBg, text_color=color.white, text_size=f_size())

f_drawNoPatternRow(_row) =>
    table.cell(tMain, 0, _row, "",                   bgcolor=bgPanel,     text_color=color.white, text_size=f_size())
    table.cell(tMain, 1, _row, "Monthly avg only",   bgcolor=noPatternBg, text_color=color.white, text_size=f_size())
    table.cell(tMain, 2, _row, "No window",          bgcolor=noPatternBg, text_color=color.white, text_size=f_size())
    table.cell(tMain, 3, _row, "No timing edge",     bgcolor=noPatternBg, text_color=color.white, text_size=f_size())
    table.cell(tMain, 4, _row, "",                   bgcolor=noPatternBg, text_color=color.white, text_size=f_size())

//------------------------------------------------------------------------------
// Main calculation
//------------------------------------------------------------------------------
if barstate.islast
    f_resetBullWindows()
    f_resetBearWindows()
    f_resetMonthDist()
    f_clearTable()

    if showTable
        f_drawHeader()

    int Y = array.size(arrYearList)
    int effMinSamples = math.max(10, math.min(minSamples, Y))
    bool wrongTF = not timeframe.isdaily

    if wrongTF
        if showTable
            table.cell(tMain, 0, 1, "Daily chart", bgcolor=warnBg, text_color=color.white, text_size=size.large)
            table.cell(tMain, 1, 1, "required",    bgcolor=warnBg, text_color=color.white, text_size=size.large)
    else if Y == 0
        if showTable
            table.cell(tMain, 0, 1, "No data",   bgcolor=warnBg, text_color=color.white, text_size=size.large)
            table.cell(tMain, 1, 1, "Load more", bgcolor=warnBg, text_color=color.white, text_size=size.large)
    else
        // Monthly average move, measured from first available close to last available close inside each calendar month.
        for m = 1 to 12
            int sRange = f_monthStartDoy(m)
            int eRange = f_monthEndDoy(m)
            int mSamp = 0
            float mSum = 0.0

            for yIdx = 0 to Y - 1
                float sC = na
                float eC = na
                for d = sRange to eRange
                    float c = f_getClose(yIdx, d)
                    if na(sC) and not na(c)
                        sC := c
                    if not na(c)
                        eC := c
                if not na(sC) and not na(eC)
                    float r = (eC / sC - 1.0) * 100.0
                    mSamp += 1
                    mSum += r

            array.set(monthPerfAvg, m - 1, mSamp > 0 ? mSum / mSamp : na)

        // Search historical windows within the 365-day calendar map.
        for sD = 1 to 365
            for lenD = minLenD to maxLenD
                int eD = sD + lenD
                if eD <= 365
                    int samp = 0
                    int bullHits = 0
                    int bearHits = 0
                    float sumR = 0.0

                    for yIdx = 0 to Y - 1
                        float sC = f_getClose(yIdx, sD)
                        float eC = f_getClose(yIdx, eD)
                        if not na(sC) and not na(eC)
                            float r = (eC / sC - 1.0) * 100.0
                            samp += 1
                            sumR += r
                            if r > 0
                                bullHits += 1
                            if r < 0
                                bearHits += 1

                    if samp >= effMinSamples
                        float avg = sumR / samp
                        float sampleAdj = useConfidenceScore ? f_sampleFactor(samp, effMinSamples) : 1.0

                        float bullHitRate = bullHits * 100.0 / samp
                        float bullDirAvg = avg
                        float bullScoreRaw = (bullHitRate * bullDirAvg * sampleAdj) / math.sqrt(lenD)
                        float bullScore = f_clampScore(bullScoreRaw * scoreScale)
                        if f_passFilter(bullHitRate, bullScore, bullDirAvg, baseMinHitRate, baseMinScore, baseRequireAvg)
                            f_insertBull(sD, eD, bullHitRate, avg, bullDirAvg, bullScore)

                        float bearHitRate = bearHits * 100.0 / samp
                        float bearDirAvg = -avg
                        float bearScoreRaw = (bearHitRate * bearDirAvg * sampleAdj) / math.sqrt(lenD)
                        float bearScore = f_clampScore(bearScoreRaw * scoreScale)
                        if f_passFilter(bearHitRate, bearScore, bearDirAvg, baseMinHitRate, baseMinScore, baseRequireAvg)
                            f_insertBear(sD, eD, bearHitRate, avg, bearDirAvg, bearScore)

        int nBull = array.size(B_score)
        int nBear = array.size(S_score)

        // Assign ranked windows to their starting month.
        if nBull > 0
            for i = 0 to nBull - 1
                int m = f_monthFromDoy365(array.get(B_sD, i))
                if not na(m)
                    int used = array.get(monthBullFillCount, m - 1)
                    if used < 10
                        array.set(monthBullSlotIdx, f_slot(m, used), i)
                        array.set(monthBullFillCount, m - 1, used + 1)

        if nBear > 0
            for i = 0 to nBear - 1
                int m = f_monthFromDoy365(array.get(S_sD, i))
                if not na(m)
                    int used = array.get(monthBearFillCount, m - 1)
                    if used < 10
                        array.set(monthBearSlotIdx, f_slot(m, used), i)
                        array.set(monthBearFillCount, m - 1, used + 1)

        // Draw the table.
        if showTable
            int row = 1
            for m = 1 to 12
                if row > ROWS - 1
                    break

                float mPerf = array.get(monthPerfAvg, m - 1)
                color mBg = f_perfBg(mPerf)
                string monthAvgText = na(mPerf) ? "" : str.tostring(mPerf, "#.##") + "%"
                string monthLabel = monthAvgText == "" ? f_monthName(m) : f_monthName(m) + " (" + monthAvgText + ")"

                table.cell(tMain, 0, row, monthLabel, bgcolor=mBg, text_color=color.black, text_size=f_size())
                table.cell(tMain, 1, row, "", bgcolor=bgPanel, text_color=color.white, text_size=f_size())
                table.cell(tMain, 2, row, "", bgcolor=bgPanel, text_color=color.white, text_size=f_size())
                table.cell(tMain, 3, row, "", bgcolor=bgPanel, text_color=color.white, text_size=f_size())
                table.cell(tMain, 4, row, "", bgcolor=bgPanel, text_color=color.white, text_size=f_size())
                row += 1

                int bullCnt = array.get(monthBullFillCount, m - 1)
                int bearCnt = array.get(monthBearFillCount, m - 1)
                int bi = 0
                int si = 0

                bool hasMonthlyPerf = not na(mPerf)
                bool hasPatternRows = bullCnt > 0 or bearCnt > 0

                if hasMonthlyPerf and not hasPatternRows
                    if row <= ROWS - 1
                        f_drawNoPatternRow(row)
                        row += 1

                while row <= ROWS - 1 and (bi < bullCnt or si < bearCnt)
                    int bullIdx = -1
                    int bearIdx = -1
                    float bullSc = -1.0
                    float bearSc = -1.0

                    if bi < bullCnt
                        int tmpBull = array.get(monthBullSlotIdx, f_slot(m, bi))
                        if tmpBull >= 0 and tmpBull < array.size(B_score)
                            bullIdx := tmpBull
                            bullSc := array.get(B_score, bullIdx)

                    if si < bearCnt
                        int tmpBear = array.get(monthBearSlotIdx, f_slot(m, si))
                        if tmpBear >= 0 and tmpBear < array.size(S_score)
                            bearIdx := tmpBear
                            bearSc := array.get(S_score, bearIdx)

                    bool useBull = bullIdx >= 0 and (bearIdx < 0 or bullSc >= bearSc)

                    if useBull
                        int sD = array.get(B_sD, bullIdx)
                        int eD = array.get(B_eD, bullIdx)
                        float hitRate = array.get(B_hit, bullIdx)
                        float avg = array.get(B_avg, bullIdx)
                        float sc = array.get(B_score, bullIdx)

                        table.cell(tMain, 0, row, f_monthName(m) + " bull", bgcolor=bgPanel, text_color=color.white, text_size=f_size())
                        table.cell(tMain, 1, row, f_mdFromDoy365(sD) + " - " + f_mdFromDoy365(eD), bgcolor=bgPanel, text_color=color.white, text_size=f_size())
                        table.cell(tMain, 2, row, str.tostring(hitRate, "#.##") + "%", bgcolor=bgPanel, text_color=color.white, text_size=f_size())
                        table.cell(tMain, 3, row, str.tostring(avg, "#.##") + "%", bgcolor=f_perfBg(avg), text_color=color.black, text_size=f_size())
                        table.cell(tMain, 4, row, str.tostring(sc, "#.##"), bgcolor=bullBg, text_color=color.black, text_size=f_size())
                        bi += 1
                        row += 1
                    else if bearIdx >= 0
                        int sD = array.get(S_sD, bearIdx)
                        int eD = array.get(S_eD, bearIdx)
                        float hitRate = array.get(S_hit, bearIdx)
                        float avg = array.get(S_avg, bearIdx)
                        float sc = array.get(S_score, bearIdx)

                        table.cell(tMain, 0, row, f_monthName(m) + " bear", bgcolor=bgPanel, text_color=color.white, text_size=f_size())
                        table.cell(tMain, 1, row, f_mdFromDoy365(sD) + " - " + f_mdFromDoy365(eD), bgcolor=bgPanel, text_color=color.white, text_size=f_size())
                        table.cell(tMain, 2, row, str.tostring(hitRate, "#.##") + "%", bgcolor=bgPanel, text_color=color.white, text_size=f_size())
                        table.cell(tMain, 3, row, str.tostring(avg, "#.##") + "%", bgcolor=f_perfBg(avg), text_color=color.black, text_size=f_size())
                        table.cell(tMain, 4, row, str.tostring(sc, "#.##"), bgcolor=bearBg, text_color=color.white, text_size=f_size())
                        si += 1
                        row += 1
                    else
                        break

//------------------------------------------------------------------------------
// Alert conditions
//------------------------------------------------------------------------------
ema9 = ta.ema(close, 9)
trendUp = close > smaTrend
trendDown = close < smaTrend
aboveEMA9 = close > ema9
belowEMA9 = close < ema9
bullEMAok = useEMA9Filter ? aboveEMA9 : true
bearEMAok = useEMA9Filter ? belowEMA9 : true
todayDoy = f_doy(dTime)

bestBullStart = array.size(B_sD) > 0 ? array.get(B_sD, 0) : na
bestBullEnd = array.size(B_eD) > 0 ? array.get(B_eD, 0) : na
bestBullHit = array.size(B_hit) > 0 ? array.get(B_hit, 0) : na
bestBullAvg = array.size(B_avg) > 0 ? array.get(B_avg, 0) : na
bestBullSc = array.size(B_score) > 0 ? array.get(B_score, 0) : na

bestBearStart = array.size(S_sD) > 0 ? array.get(S_sD, 0) : na
bestBearEnd = array.size(S_eD) > 0 ? array.get(S_eD, 0) : na
bestBearHit = array.size(S_hit) > 0 ? array.get(S_hit, 0) : na
bestBearAvg = array.size(S_avg) > 0 ? array.get(S_avg, 0) : na
bestBearSc = array.size(S_score) > 0 ? array.get(S_score, 0) : na

bullStartingSoon = not na(bestBullStart) and bestBullStart > todayDoy and bestBullStart <= todayDoy + alertSoonDays
bullStartedToday = not na(bestBullStart) and bestBullStart == todayDoy
bullRecentlyStarted = not na(bestBullStart) and bestBullStart < todayDoy and bestBullStart >= todayDoy - alertRecentDays
bullNowActive = not na(bestBullStart) and not na(bestBullEnd) and todayDoy >= bestBullStart and todayDoy <= bestBullEnd

bearStartingSoon = not na(bestBearStart) and bestBearStart > todayDoy and bestBearStart <= todayDoy + alertSoonDays
bearStartedToday = not na(bestBearStart) and bestBearStart == todayDoy
bearRecentlyStarted = not na(bestBearStart) and bestBearStart < todayDoy and bestBearStart >= todayDoy - alertRecentDays
bearNowActive = not na(bestBearStart) and not na(bestBearEnd) and todayDoy >= bestBearStart and todayDoy <= bestBearEnd

dailyChartOk = timeframe.isdaily

alertcondition(dailyChartOk and bullStartingSoon and trendUp and bullEMAok, title="Seasonal Bull Window | Soon | Trend Up", message="Historical bullish seasonal window starts soon on {{ticker}} ({{interval}}). Trend filter is up. This is a chart condition, not a trade instruction.")
alertcondition(dailyChartOk and bullStartedToday and trendUp and bullEMAok, title="Seasonal Bull Window | Started Today | Trend Up", message="Historical bullish seasonal window starts today on {{ticker}} ({{interval}}). Trend filter is up. Review chart context and risk.")
alertcondition(dailyChartOk and bullRecentlyStarted and trendUp and bullEMAok, title="Seasonal Bull Window | Recently Started | Trend Up", message="Historical bullish seasonal window recently started on {{ticker}} ({{interval}}). Trend filter is up. Review chart context and risk.")
alertcondition(dailyChartOk and bullNowActive and trendUp and bullEMAok and bestBullHit >= alertMinHitRate, title="Seasonal Bull Window | Active | Hit Rate", message="Historical bullish seasonal window is active on {{ticker}} ({{interval}}). Minimum historical hit-rate filter is met.")
alertcondition(dailyChartOk and bullStartingSoon and trendUp and bullEMAok and bestBullHit >= alertMinHitRate, title="Seasonal Bull Window | Soon | Hit Rate", message="Historical bullish seasonal window starts soon on {{ticker}} ({{interval}}). Minimum historical hit-rate filter is met.")
alertcondition(dailyChartOk and bullStartingSoon and trendUp and bullEMAok and bestBullSc >= alertMinScore1, title="Seasonal Bull Window | Soon | Score 1", message="Historical bullish seasonal window starts soon on {{ticker}} ({{interval}}). Historical score filter 1 is met.")
alertcondition(dailyChartOk and bullStartingSoon and trendUp and bullEMAok and bestBullSc >= alertMinScore2, title="Seasonal Bull Window | Soon | Score 2", message="Historical bullish seasonal window starts soon on {{ticker}} ({{interval}}). Historical score filter 2 is met.")
alertcondition(dailyChartOk and bullNowActive and trendUp and bullEMAok and bestBullAvg >= alertMinAvgMove, title="Seasonal Bull Window | Active | Avg Move", message="Historical bullish seasonal window is active on {{ticker}} ({{interval}}). Historical average-move filter is met.")

alertcondition(dailyChartOk and bearStartingSoon and trendDown and bearEMAok, title="Seasonal Bear Window | Soon | Trend Down", message="Historical bearish seasonal window starts soon on {{ticker}} ({{interval}}). Trend filter is down. This is a chart condition, not a trade instruction.")
alertcondition(dailyChartOk and bearStartedToday and trendDown and bearEMAok, title="Seasonal Bear Window | Started Today | Trend Down", message="Historical bearish seasonal window starts today on {{ticker}} ({{interval}}). Trend filter is down. Review chart context and risk.")
alertcondition(dailyChartOk and bearRecentlyStarted and trendDown and bearEMAok, title="Seasonal Bear Window | Recently Started | Trend Down", message="Historical bearish seasonal window recently started on {{ticker}} ({{interval}}). Trend filter is down. Review chart context and risk.")
alertcondition(dailyChartOk and bearRecentlyStarted and trendDown and bearEMAok and bestBearHit >= alertMinHitRate, title="Seasonal Bear Window | Recently Started | Hit Rate", message="Historical bearish seasonal window recently started on {{ticker}} ({{interval}}). Minimum historical hit-rate filter is met.")
````
