# US Elections Forward Returns and Market Cycles

- url: https://www.tradingview.com/script/zyMJz4UA-US-Elections-Forward-Returns-and-Market-Cycles/
- type: indicator
- pine_id: PUB;4f0c8ad7963f4e76987147259f718a0e
- version: 1.0

## Description

[b]Overview
[/b]
This script explores how the market has behaved between U.S. election cycles over the last 100 years.

It marks:

[list=1]
[*]Presidential elections (solid lines with president labels)
[*]Mid-term elections (dashed lines)
[*]Forward returns from each election to the next
[/list]

It also includes a summary table to compare return characteristics across different election types and political parties.

[b]What it shows[/b]
Each election is used as a consistent starting point. The script calculates the market return from that point to the next election event, allowing you to compare:

[list=1]
[*]Republican vs Democratic presidential periods
[*]Mid-term vs presidential cycles
[*]Strength (average return) vs consistency (win rate)
[/list]

Returns are color-coded using a continuous gradient:

Warmer colors = weaker or negative periods
Greens / lime = stronger positive periods
Summary table

The table (bottom-right) aggregates results into groups and displays:

N, number of observations
Avg, average forward return
Win %, percentage of positive periods
Best / Worst, range of outcomes

Hover over the column headers for simple explanations of each metric.

[b]How to use
[/b]Apply to a broad index (e.g., S&P 500)
Use a higher timeframe for clearer long-term patterns
Compare groups using both Avg and Win % to assess strength vs consistency

[b]Limitations
[/b]This is historical analysis, not a predictive model
Election cycles are only one of many factors affecting markets
Sample sizes are limited for some groups
Results depend on the symbol and timeframe used


[b]Purpose
[/b]
This script is intended to provide a structured way to observe and compare market behavior across election cycles, using consistent definitions and transparent calculations.

Generally speaking it is factual to say over the last 100 years poor stock market performance was observed during a republican presidency with the strongest market crashes. Democratic presidents saw the strongest stock market returns.

Probably just alinement half of all followers!

Ww

## Source Code

````pine
//@version=6
indicator("US Elections - Presidential + Midterms (100 Years)", overlay=true, max_lines_count=500, max_labels_count=500)

// ===== Settings =====
showPresidential = input.bool(true, "Show presidential elections?")
showMidterms     = input.bool(true, "Show mid-terms?")
showSummaryTable = input.bool(true, "Show summary table?")

repColor = input.color(color.red, "Republican color")
demColor = input.color(color.blue, "Democratic color")
midColor = input.color(color.gray, "Mid-term color")

presWidth = input.int(2, "Presidential line width", minval=1, maxval=5)
midWidth  = input.int(1, "Mid-term line width", minval=1, maxval=5)

presLabelSizeInput    = input.string("Small", "President Label Size", options=["Tiny", "Small", "Normal", "Large", "Huge"])
retLabelSizeInput     = input.string("Small", "Return Label Base Size", options=["Tiny", "Small", "Normal", "Large", "Huge"])
summaryTableSizeInput = input.string("Small", "Summary Table Size", options=["Tiny", "Small", "Normal", "Large", "Huge"])
emphasizeReturns      = input.bool(true, "Auto-emphasize strong returns?")

// ===== Size helpers =====
labelSizeFromString(sz) =>
    if sz == "Tiny"
        size.tiny
    else if sz == "Small"
        size.small
    else if sz == "Normal"
        size.normal
    else if sz == "Large"
        size.large
    else
        size.huge

presLabelSize    = labelSizeFromString(presLabelSizeInput)
retBaseSize      = labelSizeFromString(retLabelSizeInput)
summaryTableSize = labelSizeFromString(summaryTableSizeInput)

returnSize(retPct) =>
    if not emphasizeReturns
        retBaseSize
    else if math.abs(retPct) >= 50
        size.huge
    else if math.abs(retPct) >= 30
        size.large
    else if math.abs(retPct) >= 15
        size.normal
    else
        retBaseSize

// ===== Continuous gradient helpers =====
clampFloat(v, lo, hi) =>
    math.max(lo, math.min(hi, v))

lerpFloat(a, b, t) =>
    a + (b - a) * t

blendColor(c1, c2, tIn) =>
    t = clampFloat(tIn, 0.0, 1.0)
    r = math.round(lerpFloat(color.r(c1), color.r(c2), t))
    g = math.round(lerpFloat(color.g(c1), color.g(c2), t))
    b = math.round(lerpFloat(color.b(c1), color.b(c2), t))
    color.rgb(int(r), int(g), int(b))

returnColor(retPct) =>
    v = clampFloat(retPct, -40.0, 70.0)

    hotRed      = color.rgb(180, 0, 0)
    red         = color.rgb(220, 50, 47)
    orange      = color.rgb(255, 140, 0)
    amber       = color.rgb(255, 200, 0)
    yellow      = color.rgb(255, 215, 0)
    yellowGreen = color.rgb(170, 220, 60)
    green       = color.rgb(0, 185, 80)
    lime        = color.rgb(0, 255, 0)

    result = yellow

    if v < -25
        t = (v + 40.0) / 15.0
        result := blendColor(hotRed, red, t)
    else if v < -10
        t = (v + 25.0) / 15.0
        result := blendColor(red, orange, t)
    else if v < 0
        t = (v + 10.0) / 10.0
        result := blendColor(orange, amber, t)
    else if v < 10
        t = v / 10.0
        result := blendColor(yellow, yellowGreen, t)
    else if v < 25
        t = (v - 10.0) / 15.0
        result := blendColor(yellowGreen, green, t)
    else
        t = (v - 25.0) / 45.0
        result := blendColor(green, lime, t)

    result

returnTextColor(retPct) =>
    if retPct > -10 and retPct < 20
        color.black
    else
        color.white

// ===== Summary table helpers =====
fmtPct(v) =>
    if na(v)
        "n/a"
    else
        signText = v > 0 ? "+" : ""
        signText + str.tostring(v, "#.##") + "%"

fmtWin(v) =>
    if na(v)
        "n/a"
    else
        str.tostring(v, "#.0") + "%"

safeAvg(sumVal, countVal) =>
    if countVal > 0
        sumVal / countVal
    else
        na

safeWinPct(winCount, totalCount) =>
    if totalCount > 0
        100.0 * winCount / totalCount
    else
        na

winRateToRetScale(winPct) =>
    if na(winPct)
        0.0
    else
        (winPct - 50.0) * 0.8

// ===== Event storage =====
var eventTimes     = array.new_int()
var eventIsPres    = array.new_bool()
var eventTopText   = array.new_string()
var eventLineColor = array.new_color()
var eventClose     = array.new_float()
var eventLow       = array.new_float()
var eventHigh      = array.new_float()

var lineIds        = array.new_line()
var topLabelIds    = array.new_label()
var bottomLabelIds = array.new_label()

var table summaryTbl = table.new(position.bottom_right, 6, 8, border_width=1)

headerTooltipGroup = "What this tells you:\nThis row groups election periods into buckets so you can compare how markets behaved after Republican presidential wins, Democratic presidential wins, mid-term elections, all presidential elections, and all elections combined."
headerTooltipN = "N means sample size.\nIt tells you how many election periods are included in that row.\nA bigger number usually gives a more reliable picture."
headerTooltipAvg = "Avg means average forward return.\nIt shows the typical market move from that election until the next election.\nPositive numbers mean the market usually rose. Negative numbers mean it usually fell."
headerTooltipWin = "Win % means how often the forward return was positive.\nFor example, 75% means 3 out of 4 election periods ended with gains by the next election.\nThis helps you judge consistency, not just magnitude."
headerTooltipBest = "Best shows the strongest forward return in that group.\nIt highlights the most bullish election period in the sample."
headerTooltipWorst = "Worst shows the weakest forward return in that group.\nIt highlights the most bearish election period in the sample."
headerTooltipLeaderAvg = "Leader Avg points to the group with the highest average forward return.\nThis helps you see which party or election period produced the strongest typical performance."
headerTooltipLeaderWin = "Leader Win points to the group with the highest Win %.\nThis helps you see which party or election period was the most consistently positive."

addEvent(ts, isPres, txt, col) =>
    array.push(eventTimes, ts)
    array.push(eventIsPres, isPres)
    array.push(eventTopText, txt)
    array.push(eventLineColor, col)
    array.push(eventClose, na)
    array.push(eventLow, na)
    array.push(eventHigh, na)

clearLines() =>
    while array.size(lineIds) > 0
        line.delete(array.pop(lineIds))

clearTopLabels() =>
    while array.size(topLabelIds) > 0
        label.delete(array.pop(topLabelIds))

clearBottomLabels() =>
    while array.size(bottomLabelIds) > 0
        label.delete(array.pop(bottomLabelIds))

setTableCell(col, row, txt, bg, txtCol) =>
    table.cell(summaryTbl, col, row, txt, bgcolor=bg, text_color=txtCol, text_size=summaryTableSize)

setTableCellTip(col, row, txt, bg, txtCol, tip) =>
    table.cell(summaryTbl, col, row, txt, bgcolor=bg, text_color=txtCol, text_size=summaryTableSize, tooltip=tip)

clearSummaryTable() =>
    for r = 0 to 7
        for c = 0 to 5
            table.cell(summaryTbl, c, r, "", bgcolor=color.new(color.black, 100), text_color=color.new(color.white, 100), text_size=summaryTableSize)

renderStatRow(rowIdx, rowName, rowColor, nVal, avgVal, winVal, bestVal, worstVal) =>
    setTableCell(0, rowIdx, rowName, rowColor, color.white)
    setTableCell(1, rowIdx, str.tostring(nVal), color.new(color.silver, 15), color.black)

    avgBg = na(avgVal) ? color.new(color.gray, 70) : returnColor(avgVal)
    avgTx = na(avgVal) ? color.white : returnTextColor(avgVal)
    setTableCell(2, rowIdx, fmtPct(avgVal), avgBg, avgTx)

    winScaled = winRateToRetScale(winVal)
    winBg = na(winVal) ? color.new(color.gray, 70) : returnColor(winScaled)
    winTx = na(winVal) ? color.white : returnTextColor(winScaled)
    setTableCell(3, rowIdx, fmtWin(winVal), winBg, winTx)

    bestBg = na(bestVal) ? color.new(color.gray, 70) : returnColor(bestVal)
    bestTx = na(bestVal) ? color.white : returnTextColor(bestVal)
    setTableCell(4, rowIdx, fmtPct(bestVal), bestBg, bestTx)

    worstBg = na(worstVal) ? color.new(color.gray, 70) : returnColor(worstVal)
    worstTx = na(worstVal) ? color.white : returnTextColor(worstVal)
    setTableCell(5, rowIdx, fmtPct(worstVal), worstBg, worstTx)

// ===== Drawing helpers =====
drawPres(ts, txt, col, y1, y2, topY) =>
    ln = line.new(x1=ts, y1=y1, x2=ts, y2=y2, xloc=xloc.bar_time, extend=extend.both, color=col, width=presWidth, style=line.style_solid)
    array.push(lineIds, ln)
    lb = label.new(x=ts, y=topY, text=txt, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_down, color=col, textcolor=color.white, size=presLabelSize)
    array.push(topLabelIds, lb)

drawMid(ts, y1, y2) =>
    ln = line.new(x1=ts, y1=y1, x2=ts, y2=y2, xloc=xloc.bar_time, extend=extend.both, color=midColor, width=midWidth, style=line.style_dashed)
    array.push(lineIds, ln)

drawReturnLabel(ts, retPct, y) =>
    signText = retPct >= 0 ? "+" : ""
    txt = signText + str.tostring(retPct, "#.##") + "% to next election"
    col = returnColor(retPct)
    txtCol = returnTextColor(retPct)
    sz = returnSize(retPct)
    lb = label.new(x=ts, y=y, text=txt, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_up, color=col, textcolor=txtCol, size=sz)
    array.push(bottomLabelIds, lb)

// ===== Populate events once =====
if barstate.isfirst
    addEvent(timestamp("America/New_York", 1924, 11, 4, 0, 0), true,  "Calvin Coolidge",        repColor)
    addEvent(timestamp("America/New_York", 1926, 11, 2, 0, 0), false, "",                        midColor)
    addEvent(timestamp("America/New_York", 1928, 11, 6, 0, 0), true,  "Herbert Hoover",         repColor)
    addEvent(timestamp("America/New_York", 1930, 11, 4, 0, 0), false, "",                        midColor)
    addEvent(timestamp("America/New_York", 1932, 11, 8, 0, 0), true,  "Franklin D. Roosevelt", demColor)
    addEvent(timestamp("America/New_York", 1934, 11, 6, 0, 0), false, "",                        midColor)
    addEvent(timestamp("America/New_York", 1936, 11, 3, 0, 0), true,  "Franklin D. Roosevelt", demColor)
    addEvent(timestamp("America/New_York", 1938, 11, 8, 0, 0), false, "",                        midColor)
    addEvent(timestamp("America/New_York", 1940, 11, 5, 0, 0), true,  "Franklin D. Roosevelt", demColor)
    addEvent(timestamp("America/New_York", 1942, 11, 3, 0, 0), false, "",                        midColor)
    addEvent(timestamp("America/New_York", 1944, 11, 7, 0, 0), true,  "Franklin D. Roosevelt", demColor)
    addEvent(timestamp("America/New_York", 1946, 11, 5, 0, 0), false, "",                        midColor)
    addEvent(timestamp("America/New_York", 1948, 11, 2, 0, 0), true,  "Harry S. Truman",        demColor)
    addEvent(timestamp("America/New_York", 1950, 11, 7, 0, 0), false, "",                        midColor)
    addEvent(timestamp("America/New_York", 1952, 11, 4, 0, 0), true,  "Dwight D. Eisenhower",   repColor)
    addEvent(timestamp("America/New_York", 1954, 11, 2, 0, 0), false, "",                        midColor)
    addEvent(timestamp("America/New_York", 1956, 11, 6, 0, 0), true,  "Dwight D. Eisenhower",   repColor)
    addEvent(timestamp("America/New_York", 1958, 11, 4, 0, 0), false, "",                        midColor)
    addEvent(timestamp("America/New_York", 1960, 11, 8, 0, 0), true,  "John F. Kennedy",        demColor)
    addEvent(timestamp("America/New_York", 1962, 11, 6, 0, 0), false, "",                        midColor)
    addEvent(timestamp("America/New_York", 1964, 11, 3, 0, 0), true,  "Lyndon B. Johnson",      demColor)
    addEvent(timestamp("America/New_York", 1966, 11, 8, 0, 0), false, "",                        midColor)
    addEvent(timestamp("America/New_York", 1968, 11, 5, 0, 0), true,  "Richard Nixon",          repColor)
    addEvent(timestamp("America/New_York", 1970, 11, 3, 0, 0), false, "",                        midColor)
    addEvent(timestamp("America/New_York", 1972, 11, 7, 0, 0), true,  "Richard Nixon",          repColor)
    addEvent(timestamp("America/New_York", 1974, 11, 5, 0, 0), false, "",                        midColor)
    addEvent(timestamp("America/New_York", 1976, 11, 2, 0, 0), true,  "Jimmy Carter",           demColor)
    addEvent(timestamp("America/New_York", 1978, 11, 7, 0, 0), false, "",                        midColor)
    addEvent(timestamp("America/New_York", 1980, 11, 4, 0, 0), true,  "Ronald Reagan",          repColor)
    addEvent(timestamp("America/New_York", 1982, 11, 2, 0, 0), false, "",                        midColor)
    addEvent(timestamp("America/New_York", 1984, 11, 6, 0, 0), true,  "Ronald Reagan",          repColor)
    addEvent(timestamp("America/New_York", 1986, 11, 4, 0, 0), false, "",                        midColor)
    addEvent(timestamp("America/New_York", 1988, 11, 8, 0, 0), true,  "George H. W. Bush",      repColor)
    addEvent(timestamp("America/New_York", 1990, 11, 6, 0, 0), false, "",                        midColor)
    addEvent(timestamp("America/New_York", 1992, 11, 3, 0, 0), true,  "Bill Clinton",           demColor)
    addEvent(timestamp("America/New_York", 1994, 11, 8, 0, 0), false, "",                        midColor)
    addEvent(timestamp("America/New_York", 1996, 11, 5, 0, 0), true,  "Bill Clinton",           demColor)
    addEvent(timestamp("America/New_York", 1998, 11, 3, 0, 0), false, "",                        midColor)
    addEvent(timestamp("America/New_York", 2000, 11, 7, 0, 0), true,  "George W. Bush",         repColor)
    addEvent(timestamp("America/New_York", 2002, 11, 5, 0, 0), false, "",                        midColor)
    addEvent(timestamp("America/New_York", 2004, 11, 2, 0, 0), true,  "George W. Bush",         repColor)
    addEvent(timestamp("America/New_York", 2006, 11, 7, 0, 0), false, "",                        midColor)
    addEvent(timestamp("America/New_York", 2008, 11, 4, 0, 0), true,  "Barack Obama",           demColor)
    addEvent(timestamp("America/New_York", 2010, 11, 2, 0, 0), false, "",                        midColor)
    addEvent(timestamp("America/New_York", 2012, 11, 6, 0, 0), true,  "Barack Obama",           demColor)
    addEvent(timestamp("America/New_York", 2014, 11, 4, 0, 0), false, "",                        midColor)
    addEvent(timestamp("America/New_York", 2016, 11, 8, 0, 0), true,  "Donald Trump",           repColor)
    addEvent(timestamp("America/New_York", 2018, 11, 6, 0, 0), false, "",                        midColor)
    addEvent(timestamp("America/New_York", 2020, 11, 3, 0, 0), true,  "Joe Biden",              demColor)
    addEvent(timestamp("America/New_York", 2022, 11, 8, 0, 0), false, "",                        midColor)
    addEvent(timestamp("America/New_York", 2024, 11, 5, 0, 0), true,  "Donald Trump",           repColor)

// ===== Capture event bar data =====
for i = 0 to array.size(eventTimes) - 1
    ts = array.get(eventTimes, i)
    crossed = time >= ts and (bar_index == 0 or time[1] < ts)
    if crossed
        if na(array.get(eventClose, i))
            array.set(eventClose, i, close)
        if na(array.get(eventLow, i))
            array.set(eventLow, i, low)
        if na(array.get(eventHigh, i))
            array.set(eventHigh, i, high)

// ===== Redraw on last bar =====
if barstate.islast
    clearLines()
    clearTopLabels()
    clearBottomLabels()

    for i = 0 to array.size(eventTimes) - 1
        ts = array.get(eventTimes, i)
        isPres = array.get(eventIsPres, i)
        topTxt = array.get(eventTopText, i)
        lineCol = array.get(eventLineColor, i)
        yLo = array.get(eventLow, i)
        yHi = array.get(eventHigh, i)

        bool showThis = false
        if isPres
            showThis := showPresidential
        else
            showThis := showMidterms

        if showThis and not na(yLo) and not na(yHi)
            padLo = yLo * 0.98
            padHi = yHi * 1.02

            if isPres
                drawPres(ts, topTxt, lineCol, padLo, padHi, padHi)
            else
                drawMid(ts, padLo, padHi)

            if i < array.size(eventTimes) - 1
                c0 = array.get(eventClose, i)
                c1 = array.get(eventClose, i + 1)
                if not na(c0) and not na(c1)
                    retPct = (c1 / c0 - 1.0) * 100.0
                    drawReturnLabel(ts, retPct, padLo)

    // ===== Summary stats =====
    float repSum = 0.0
    float demSum = 0.0
    float midSum = 0.0
    float presSum = 0.0
    float allSum = 0.0

    int repCount = 0
    int demCount = 0
    int midCount = 0
    int presCount = 0
    int allCount = 0

    int repWins = 0
    int demWins = 0
    int midWins = 0
    int presWins = 0
    int allWins = 0

    float repBest = na
    float demBest = na
    float midBest = na
    float presBest = na
    float allBest = na

    float repWorst = na
    float demWorst = na
    float midWorst = na
    float presWorst = na
    float allWorst = na

    for i = 0 to array.size(eventTimes) - 2
        c0 = array.get(eventClose, i)
        c1 = array.get(eventClose, i + 1)

        if not na(c0) and not na(c1)
            retPct = (c1 / c0 - 1.0) * 100.0
            isPres = array.get(eventIsPres, i)
            rowColor = array.get(eventLineColor, i)

            allSum += retPct
            allCount += 1
            if retPct > 0
                allWins += 1
            if na(allBest) or retPct > allBest
                allBest := retPct
            if na(allWorst) or retPct < allWorst
                allWorst := retPct

            if isPres
                presSum += retPct
                presCount += 1
                if retPct > 0
                    presWins += 1
                if na(presBest) or retPct > presBest
                    presBest := retPct
                if na(presWorst) or retPct < presWorst
                    presWorst := retPct

                if rowColor == repColor
                    repSum += retPct
                    repCount += 1
                    if retPct > 0
                        repWins += 1
                    if na(repBest) or retPct > repBest
                        repBest := retPct
                    if na(repWorst) or retPct < repWorst
                        repWorst := retPct

                if rowColor == demColor
                    demSum += retPct
                    demCount += 1
                    if retPct > 0
                        demWins += 1
                    if na(demBest) or retPct > demBest
                        demBest := retPct
                    if na(demWorst) or retPct < demWorst
                        demWorst := retPct
            else
                midSum += retPct
                midCount += 1
                if retPct > 0
                    midWins += 1
                if na(midBest) or retPct > midBest
                    midBest := retPct
                if na(midWorst) or retPct < midWorst
                    midWorst := retPct

    repAvg = safeAvg(repSum, repCount)
    demAvg = safeAvg(demSum, demCount)
    midAvg = safeAvg(midSum, midCount)
    presAvg = safeAvg(presSum, presCount)
    allAvg = safeAvg(allSum, allCount)

    repWinPct = safeWinPct(repWins, repCount)
    demWinPct = safeWinPct(demWins, demCount)
    midWinPct = safeWinPct(midWins, midCount)
    presWinPct = safeWinPct(presWins, presCount)
    allWinPct = safeWinPct(allWins, allCount)

    string leaderAvgName = "n/a"
    float leaderAvgVal = na

    if not na(repAvg)
        leaderAvgName := "Republican"
        leaderAvgVal := repAvg
    if not na(demAvg)
        if na(leaderAvgVal) or demAvg > leaderAvgVal
            leaderAvgName := "Democratic"
            leaderAvgVal := demAvg
    if not na(midAvg)
        if na(leaderAvgVal) or midAvg > leaderAvgVal
            leaderAvgName := "Midterms"
            leaderAvgVal := midAvg

    string leaderWinName = "n/a"
    float leaderWinVal = na

    if not na(repWinPct)
        leaderWinName := "Republican"
        leaderWinVal := repWinPct
    if not na(demWinPct)
        if na(leaderWinVal) or demWinPct > leaderWinVal
            leaderWinName := "Democratic"
            leaderWinVal := demWinPct
    if not na(midWinPct)
        if na(leaderWinVal) or midWinPct > leaderWinVal
            leaderWinName := "Midterms"
            leaderWinVal := midWinPct

    if showSummaryTable
        clearSummaryTable()

        setTableCellTip(0, 0, "Group", color.new(color.black, 0), color.white, headerTooltipGroup)
        setTableCellTip(1, 0, "N", color.new(color.black, 0), color.white, headerTooltipN)
        setTableCellTip(2, 0, "Avg", color.new(color.black, 0), color.white, headerTooltipAvg)
        setTableCellTip(3, 0, "Win %", color.new(color.black, 0), color.white, headerTooltipWin)
        setTableCellTip(4, 0, "Best", color.new(color.black, 0), color.white, headerTooltipBest)
        setTableCellTip(5, 0, "Worst", color.new(color.black, 0), color.white, headerTooltipWorst)

        renderStatRow(1, "Republican", repColor, repCount, repAvg, repWinPct, repBest, repWorst)
        renderStatRow(2, "Democratic", demColor, demCount, demAvg, demWinPct, demBest, demWorst)
        renderStatRow(3, "Midterms", midColor, midCount, midAvg, midWinPct, midBest, midWorst)
        renderStatRow(4, "Presidential", color.new(color.silver, 0), presCount, presAvg, presWinPct, presBest, presWorst)
        renderStatRow(5, "All Elections", color.new(color.teal, 0), allCount, allAvg, allWinPct, allBest, allWorst)

        leaderAvgBg = na(leaderAvgVal) ? color.new(color.gray, 70) : returnColor(leaderAvgVal)
        leaderAvgTx = na(leaderAvgVal) ? color.white : returnTextColor(leaderAvgVal)
        leaderWinScaled = winRateToRetScale(leaderWinVal)
        leaderWinBg = na(leaderWinVal) ? color.new(color.gray, 70) : returnColor(leaderWinScaled)
        leaderWinTx = na(leaderWinVal) ? color.white : returnTextColor(leaderWinScaled)

        setTableCellTip(0, 6, "Leader Avg", color.new(color.navy, 0), color.white, headerTooltipLeaderAvg)
        setTableCell(1, 6, leaderAvgName, leaderAvgBg, leaderAvgTx)
        setTableCell(2, 6, fmtPct(leaderAvgVal), leaderAvgBg, leaderAvgTx)
        setTableCell(3, 6, "", color.new(color.black, 100), color.white)
        setTableCell(4, 6, "", color.new(color.black, 100), color.white)
        setTableCell(5, 6, "", color.new(color.black, 100), color.white)

        setTableCellTip(0, 7, "Leader Win", color.new(color.purple, 0), color.white, headerTooltipLeaderWin)
        setTableCell(1, 7, leaderWinName, leaderWinBg, leaderWinTx)
        setTableCell(2, 7, fmtWin(leaderWinVal), leaderWinBg, leaderWinTx)
        setTableCell(3, 7, "", color.new(color.black, 100), color.white)
        setTableCell(4, 7, "", color.new(color.black, 100), color.white)
        setTableCell(5, 7, "", color.new(color.black, 100), color.white)
    else
        clearSummaryTable()
````
