# Square Root BTC Cycle Predictor

- url: https://www.tradingview.com/script/riWfMjVA/
- type: indicator
- pine_id: PUB;2c8ef28ba0044043b27ee7064e04424f
- version: 1.0

## Description

[b]Welcome to the Square Root Cycle Predictor[/b]

If you have been watching Bitcoin for a few years, you already know it moves in massive and predictable waves. This indicator is designed to map out those waves using a simple but powerful mathematical concept.

[b]The Math Behind the Magic[/b]

Why do we use square roots to predict [symbol="BITSTAMP:BTCUSD"]BITSTAMP:BTCUSD[/symbol] ? The answer is simple. Bitcoin grows exponentially. When you look at a standard price chart, the early years look completely flat and the recent years look like a vertical wall. It is very hard to see the rhythm.

But when you apply a square root scale to the price, that exponential curve transforms into a straight diagonal line. Once the curve is straightened out, the market cycles start to look like a perfect staircase. This indicator measures the height of that staircase in steps.

[b]How It Predicted Previous Cycles[/b]

The beauty of this model is that it relies on historical consistency. When we measure the past cycles on this square root scale, the numbers are incredibly clean.

[list]
[*] Past bull markets have reached their tops at exactly 13, 21, and 23 steps.
[*] Past bear markets have found their bottoms at exactly 8 and 14 steps.
[/list]

The indicator automatically detects these legs and draws the geometric levels right on your chart. It does not guess. It just follows the mathematical staircase that Bitcoin has been climbing since 2015.

[b]What Could Happen Next[/b]

Right now, the indicator is tracking the current bull market. Based on the historical rhythm, it projects two major things for the future.

First, it calculates where the next bear market bottom might be. It looks at three scenarios including a mild drop of 16 steps, a medium drop of 18 steps, and a severe drop of 20 steps from the cycle top. The table on your screen shows the exact price and estimated date for these scenarios.

Second, it projects the next massive bull market peak. It takes the primary bear market bottom and adds 25 steps to it. This projected top aligns beautifully with the historical time it takes to peak after a Bitcoin halving event.

[b]How to Use This Tool[/b]

[list=1]
[*] Look at the large table in the bottom right corner. It gives you the exact prices and dates for the current market status and future projections.
[*] The horizontal grey lines are your geometric support and resistance levels.
[*] The vertical lines show the estimated dates for the next major cycle events.
[*] You can change the settings to adjust the step size or the starting price if you want to test different theories.
[/list]

[quote]Markets are driven by human psychology, but human psychology often follows natural geometric patterns. This tool simply highlights those patterns.[/quote]

[i]Disclaimer: This indicator is built for educational and research purposes only. It is a mathematical hypothesis and not financial advice. Always do your own research and manage your risk.[/i]

## Source Code

````pine
//@version=6
indicator('Square Root Cycle Predictor', shorttitle = 'Sqroot', overlay = true, max_lines_count = 500, max_labels_count = 500)

// ============================================================
// Calculation by EBTURK
// ============================================================

formatMonthYear(int t) =>
    if na(t)
        '—'
    else
        y = year(t, syminfo.timezone)
        m = month(t, syminfo.timezone)
        monthNames = array.from('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec')
        mStr = array.get(monthNames, m - 1)
        mStr + ' ' + str.tostring(y)

// ============================================================
// SECTION M1: SUPPORT/RESISTANCE LADDER
// ============================================================
showLadder = input.bool(true, title = 'Show Ladder', group = 'M1 Ladder')
lowPrice = input.float(15473.78, title = 'Starting Low', minval = 0.0001, group = 'M1 Ladder')
stepVal = input.float(10.0, title = 'Step', minval = 0.0001, group = 'M1 Ladder')
levelsAbove = input.int(24, title = 'Levels Above', minval = 0, maxval = 200, group = 'M1 Ladder')
levelsBelow = input.int(0, title = 'Levels Below', minval = 0, maxval = 200, group = 'M1 Ladder')
showLabels = input.bool(true, title = 'Price Labels', group = 'M1 Ladder')
lineColorIn = input.color(color.new(color.gray, 70), title = 'Line Color', group = 'M1 Ladder')

var array<line> lvlLines = array.new<line>()
var array<label> lvlLabels = array.new<label>()
var bool ladderInit = false

if showLadder and not ladderInit
    baseRoot = math.sqrt(lowPrice)
    for i = -levelsBelow to levelsAbove by 1
        root = baseRoot + i * stepVal
        if root > 0
            float levelPrice = root * root
            ln = line.new(bar_index - 1, levelPrice, bar_index, levelPrice, xloc = xloc.bar_index, extend = extend.both, color = lineColorIn, width = 1, style = line.style_solid)
            array.push(lvlLines, ln)
            if showLabels
                lb = label.new(bar_index, levelPrice, str.tostring(levelPrice, '#,###.##'), xloc = xloc.bar_index, style = label.style_label_right, color = color.new(color.rgb(248, 250, 252, 80), 0), textcolor = color.gray, size = size.tiny)
                array.push(lvlLabels, lb)
    ladderInit := true
    ladderInit

if showLadder and ladderInit and barstate.islast and showLabels
    for i = 0 to array.size(lvlLabels) - 1 by 1
        label.set_x(array.get(lvlLabels, i), bar_index)

// ============================================================
// SECTION M2: CYCLE DETECTION ENGINE
// ============================================================
thresholdPct = input.float(60.0, title = 'Reversal Threshold (%)', minval = 1, maxval = 90, group = 'M2 Cycle')
confirmBars = input.int(3, title = 'Confirmation Bars', minval = 0, maxval = 20, group = 'M2 Cycle')
cycleStepVal = input.float(10.0, title = 'Step Counter', minval = 0.0001, group = 'M2 Cycle')
useHistInit = input.bool(true, title = 'Start from Historical Low', group = 'M2 Cycle')
histLowPrice = input.float(152.0, title = 'Historical Low Price', group = 'M2 Cycle')
histLowTime = input.time(1421193600000, title = 'Historical Low Time (2015-01-14)', group = 'M2 Cycle')

var float runHigh = na
var float runLow = na
var int runHighTime = na
var int runLowTime = na
var string cycState = 'bull'
var float lastConfirmedLow = na
var float lastConfirmedHigh = na
var int lastConfirmedLowTime = na
var int lastConfirmedHighTime = na

var int confirmCount = 0
var string pendingState = 'none'
var float pendingHigh = na
var float pendingLow = na
var int pendingHighTime = na
var int pendingLowTime = na

var array<string> legType = array.new<string>()
var array<float> legStart = array.new<float>()
var array<float> legEnd = array.new<float>()
var array<float> legSteps = array.new<float>()
var array<int> legStartTime = array.new<int>()
var array<int> legEndTime = array.new<int>()

if barstate.isfirst
    if useHistInit and time <= histLowTime
        cycState := 'init_wait'
        lastConfirmedLow := histLowPrice
        lastConfirmedLowTime := histLowTime
        lastConfirmedLowTime
    else
        runHigh := high
        runLow := low
        runHighTime := time
        runLowTime := time
        lastConfirmedLow := low
        lastConfirmedLowTime := time
        cycState := 'bull'
        cycState

if cycState == 'init_wait' and time >= histLowTime
    runHigh := high
    runHighTime := time
    cycState := 'bull'
    cycState

if cycState != 'init_wait' and not barstate.isfirst
    if cycState == 'bull'
        thresholdLevel = runHigh * (1 - thresholdPct / 100)
        thresholdBreached = low <= thresholdLevel
        closedBelow = close <= thresholdLevel

        if thresholdBreached
            if confirmBars == 0
                steps = (math.sqrt(runHigh) - math.sqrt(lastConfirmedLow)) / cycleStepVal
                array.push(legType, 'Bull')
                array.push(legStart, lastConfirmedLow)
                array.push(legEnd, runHigh)
                array.push(legSteps, steps)
                array.push(legStartTime, lastConfirmedLowTime)
                array.push(legEndTime, runHighTime)
                lastConfirmedHigh := runHigh
                lastConfirmedHighTime := runHighTime
                cycState := 'bear'
                runLow := low
                runLowTime := time
                runLowTime
            else
                if pendingState == 'none'
                    pendingState := 'bull_to_bear'
                    pendingHigh := runHigh
                    pendingHighTime := runHighTime
                    confirmCount := closedBelow ? 1 : 0
                    confirmCount
                else if pendingState == 'bull_to_bear'
                    if closedBelow
                        confirmCount := confirmCount + 1
                        confirmCount
                    else
                        confirmCount := 0
                        confirmCount

                if pendingState == 'bull_to_bear' and confirmCount >= confirmBars
                    steps = (math.sqrt(pendingHigh) - math.sqrt(lastConfirmedLow)) / cycleStepVal
                    array.push(legType, 'Bull')
                    array.push(legStart, lastConfirmedLow)
                    array.push(legEnd, pendingHigh)
                    array.push(legSteps, steps)
                    array.push(legStartTime, lastConfirmedLowTime)
                    array.push(legEndTime, pendingHighTime)
                    lastConfirmedHigh := pendingHigh
                    lastConfirmedHighTime := pendingHighTime
                    cycState := 'bear'
                    runLow := low
                    runLowTime := time
                    pendingState := 'none'
                    confirmCount := 0
                    confirmCount
        else
            if high > runHigh
                runHigh := high
                runHighTime := time
                runHighTime
            if pendingState == 'bull_to_bear'
                pendingState := 'none'
                confirmCount := 0
                confirmCount

    else
        thresholdLevel = runLow * (1 + thresholdPct / 100)
        thresholdBreached = high >= thresholdLevel
        closedAbove = close >= thresholdLevel

        if thresholdBreached
            if confirmBars == 0
                steps = (math.sqrt(lastConfirmedHigh) - math.sqrt(runLow)) / cycleStepVal
                array.push(legType, 'Bear')
                array.push(legStart, lastConfirmedHigh)
                array.push(legEnd, runLow)
                array.push(legSteps, steps)
                array.push(legStartTime, lastConfirmedHighTime)
                array.push(legEndTime, runLowTime)
                lastConfirmedLow := runLow
                lastConfirmedLowTime := runLowTime
                cycState := 'bull'
                runHigh := high
                runHighTime := time
                runHighTime
            else
                if pendingState == 'none'
                    pendingState := 'bear_to_bull'
                    pendingLow := runLow
                    pendingLowTime := runLowTime
                    confirmCount := closedAbove ? 1 : 0
                    confirmCount
                else if pendingState == 'bear_to_bull'
                    if closedAbove
                        confirmCount := confirmCount + 1
                        confirmCount
                    else
                        confirmCount := 0
                        confirmCount

                if pendingState == 'bear_to_bull' and confirmCount >= confirmBars
                    steps = (math.sqrt(lastConfirmedHigh) - math.sqrt(pendingLow)) / cycleStepVal
                    array.push(legType, 'Bear')
                    array.push(legStart, lastConfirmedHigh)
                    array.push(legEnd, pendingLow)
                    array.push(legSteps, steps)
                    array.push(legStartTime, lastConfirmedHighTime)
                    array.push(legEndTime, pendingLowTime)
                    lastConfirmedLow := pendingLow
                    lastConfirmedLowTime := pendingLowTime
                    cycState := 'bull'
                    runHigh := high
                    runHighTime := time
                    pendingState := 'none'
                    confirmCount := 0
                    confirmCount
        else
            if low < runLow
                runLow := low
                runLowTime := time
                runLowTime
            if pendingState == 'bear_to_bull'
                pendingState := 'none'
                confirmCount := 0
                confirmCount

// ============================================================
// SECTION M3: PREDICTION ENGINE
// ============================================================
halving4Date = input.time(1713484800000, title = '2024 Halving (2024-04-19)', group = 'M3 Predictions')
primaryBearScenario = input.string('18', title = 'Primary Bear Scenario', options = ['16', '18', '20'], group = 'M3 Predictions')
bearLowDateOffsetDays = input.int(380, title = 'Peak→Trough Days', minval = 1, group = 'M3 Predictions')
bullStepsNext = input.float(25.0, title = 'Next Bull Target Steps', minval = 1, maxval = 100, group = 'M3 Predictions')
bullPeakDateOffsetDays = input.int(500, title = 'Halving→Peak Days', minval = 1, group = 'M3 Predictions')

int DAYS_TO_MS = 24 * 60 * 60 * 1000

var float referenceHigh = na
var int referenceHighTime = na

var float bearLow16 = na
var float bearLow18 = na
var float bearLow20 = na
var float bearLowPrimary = na
var int bearLowDate = na

var int nextHalvingDate = na
var float nextBullPeakPrice = na
var int nextBullPeakDate = na

if barstate.islast
    referenceHigh := cycState == 'bull' ? runHigh : lastConfirmedHigh
    referenceHighTime := cycState == 'bull' ? runHighTime : lastConfirmedHighTime

    if not na(referenceHigh)
        refRoot = math.sqrt(referenceHigh)
        r16 = refRoot - 16 * cycleStepVal
        r18 = refRoot - 18 * cycleStepVal
        r20 = refRoot - 20 * cycleStepVal
        bearLow16 := r16 > 0 ? r16 * r16 : na
        bearLow18 := r18 > 0 ? r18 * r18 : na
        bearLow20 := r20 > 0 ? r20 * r20 : na
        bearLowPrimary := primaryBearScenario == '16' ? bearLow16 : primaryBearScenario == '20' ? bearLow20 : bearLow18
        bearLowPrimary

    if not na(referenceHighTime)
        bearLowDate := referenceHighTime + bearLowDateOffsetDays * DAYS_TO_MS
        bearLowDate

    nextHalvingDate := halving4Date + 1460 * DAYS_TO_MS
    nextBullPeakDate := nextHalvingDate + bullPeakDateOffsetDays * DAYS_TO_MS

    if not na(bearLowPrimary)
        peakRoot = math.sqrt(bearLowPrimary) + bullStepsNext * cycleStepVal
        nextBullPeakPrice := peakRoot * peakRoot
        nextBullPeakPrice

// ============================================================
// SECTION M4: PREDICTION PANEL (BOTTOM RIGHT - MATTE LIGHT)
// ============================================================
showPredPanel = input.bool(true, title = 'Show Prediction Panel', group = 'M3 Predictions')

var table predTbl = na

if barstate.islast and showPredPanel
    if not na(predTbl)
        table.delete(predTbl)

    // Matte light color palette
    bgColor = color.rgb(248, 250, 252) // Very light gray-blue
    headerBg = color.rgb(226, 232, 240) // Light gray-blue
    sectionBgBear = color.rgb(254, 242, 242) // Very light red/pink
    sectionBgBull = color.rgb(240, 253, 244) // Very light green
    sectionBgHalving = color.rgb(255, 251, 235) // Very light yellow
    rowBg1 = color.rgb(241, 245, 249) // Light gray
    rowBg2 = color.rgb(248, 250, 252) // Very light gray
    borderColor = color.rgb(203, 213, 225) // Medium light gray
    textColor = color.rgb(15, 23, 42) // Dark gray/black
    mutedText = color.rgb(100, 116, 139) // Medium gray
    accentRed = color.rgb(220, 38, 38) // Matte red
    accentGreen = color.rgb(22, 163, 74) // Matte green
    accentYellow = color.rgb(202, 138, 4) // Matte yellow

    predTbl := table.new(position.bottom_right, 3, 12, bgcolor = bgColor, border_width = 2, border_color = borderColor)

    // Header
    table.cell(predTbl, 0, 0, '√ Square Root Cycle Predictor', text_color = textColor, bgcolor = headerBg, text_size = size.large, text_halign = text.align_left)
    table.cell(predTbl, 1, 0, 'Date', text_color = textColor, bgcolor = headerBg, text_size = size.normal)
    table.cell(predTbl, 2, 0, 'Price', text_color = textColor, bgcolor = headerBg, text_size = size.normal)

    // Current Status
    statusBg = cycState == 'bull' ? color.rgb(220, 252, 231) : color.rgb(254, 226, 226)
    statusColor = cycState == 'bull' ? accentGreen : accentRed
    statusTxt = cycState == 'bull' ? '● Bull Market' : '● Bear Market'
    table.cell(predTbl, 0, 1, statusTxt, text_color = statusColor, bgcolor = statusBg, text_size = size.large, text_halign = text.align_left)
    table.cell(predTbl, 1, 1, formatMonthYear(referenceHighTime), text_color = mutedText, bgcolor = statusBg, text_size = size.normal)
    table.cell(predTbl, 2, 1, not na(referenceHigh) ? '$' + str.tostring(referenceHigh, '#,###') : '—', text_color = mutedText, bgcolor = statusBg, text_size = size.normal)

    // Bear Market Section Header
    table.cell(predTbl, 0, 2, '▼ BEAR MARKET LOW', text_color = accentRed, bgcolor = sectionBgBear, text_size = size.large, text_halign = text.align_left)
    table.cell(predTbl, 1, 2, 'from peak', text_color = mutedText, bgcolor = sectionBgBear, text_size = size.small)
    table.cell(predTbl, 2, 2, '', bgcolor = sectionBgBear)

    // Bear scenarios
    table.cell(predTbl, 0, 3, '  16 steps (mild)', text_color = textColor, bgcolor = rowBg1, text_size = size.normal, text_halign = text.align_left)
    table.cell(predTbl, 1, 3, '', bgcolor = rowBg1)
    table.cell(predTbl, 2, 3, not na(bearLow16) ? '$' + str.tostring(bearLow16, '#,###') : '—', text_color = mutedText, bgcolor = rowBg1, text_size = size.normal)

    table.cell(predTbl, 0, 4, '  18 steps (medium) ★', text_color = textColor, bgcolor = sectionBgBear, text_size = size.normal, text_halign = text.align_left)
    table.cell(predTbl, 1, 4, not na(bearLowDate) ? formatMonthYear(bearLowDate) : '—', text_color = textColor, bgcolor = sectionBgBear, text_size = size.normal)
    table.cell(predTbl, 2, 4, not na(bearLow18) ? '$' + str.tostring(bearLow18, '#,###') : '—', text_color = accentRed, bgcolor = sectionBgBear, text_size = size.large)

    table.cell(predTbl, 0, 5, '  20 steps (severe)', text_color = textColor, bgcolor = rowBg1, text_size = size.normal, text_halign = text.align_left)
    table.cell(predTbl, 1, 5, '', bgcolor = rowBg1)
    table.cell(predTbl, 2, 5, not na(bearLow20) ? '$' + str.tostring(bearLow20, '#,###') : '—', text_color = mutedText, bgcolor = rowBg1, text_size = size.normal)

    // Bull Market Section Header
    table.cell(predTbl, 0, 6, '▲ NEXT BULL PEAK', text_color = accentGreen, bgcolor = sectionBgBull, text_size = size.large, text_halign = text.align_left)
    table.cell(predTbl, 1, 6, 'from low + ' + str.tostring(bullStepsNext, '#') + ' steps', text_color = mutedText, bgcolor = sectionBgBull, text_size = size.small)
    table.cell(predTbl, 2, 6, '', bgcolor = sectionBgBull)

    // Bull projection
    table.cell(predTbl, 0, 7, '  projected peak', text_color = textColor, bgcolor = sectionBgBull, text_size = size.normal, text_halign = text.align_left)
    table.cell(predTbl, 1, 7, formatMonthYear(nextBullPeakDate), text_color = accentYellow, bgcolor = sectionBgBull, text_size = size.large)
    table.cell(predTbl, 2, 7, not na(nextBullPeakPrice) ? '$' + str.tostring(nextBullPeakPrice, '#,###') : '—', text_color = accentGreen, bgcolor = sectionBgBull, text_size = size.large)

    // Halving Section
    table.cell(predTbl, 0, 8, '⏲ Last Halving', text_color = accentYellow, bgcolor = sectionBgHalving, text_size = size.normal, text_halign = text.align_left)
    table.cell(predTbl, 1, 8, formatMonthYear(halving4Date), text_color = mutedText, bgcolor = sectionBgHalving, text_size = size.normal)
    table.cell(predTbl, 2, 8, '', bgcolor = sectionBgHalving)

    table.cell(predTbl, 0, 9, '⏲ Next Halving (est.)', text_color = accentYellow, bgcolor = sectionBgHalving, text_size = size.normal, text_halign = text.align_left)
    table.cell(predTbl, 1, 9, formatMonthYear(nextHalvingDate), text_color = mutedText, bgcolor = sectionBgHalving, text_size = size.normal)
    table.cell(predTbl, 2, 9, '', bgcolor = sectionBgHalving)

    // Notes
    table.cell(predTbl, 0, 10, '★ = primary scenario', text_color = mutedText, bgcolor = bgColor, text_size = size.small, text_halign = text.align_left)
    table.cell(predTbl, 1, 10, '', bgcolor = bgColor)
    table.cell(predTbl, 2, 10, '', bgcolor = bgColor)

    table.cell(predTbl, 0, 11, 'Hypothesis — not financial advice', text_color = mutedText, bgcolor = bgColor, text_size = size.small, text_halign = text.align_left)
    table.cell(predTbl, 1, 11, '', bgcolor = bgColor)
    table.cell(predTbl, 2, 11, '', bgcolor = bgColor)

// ============================================================
// SECTION M5: FUTURE DATE VERTICAL LINES (LIGHT GREY)
// ============================================================
showProjLines = input.bool(true, title = 'Draw Prediction Lines', group = 'M3 Predictions')
lineTransparency = input.int(60, title = 'Line Transparency', minval = 0, maxval = 90, group = 'M3 Predictions')

var array<line> futureLines = array.new<line>()
var array<label> futureLabels = array.new<label>()

if barstate.islast and showProjLines
    if array.size(futureLines) > 0
        for i = 0 to array.size(futureLines) - 1 by 1
            line.delete(array.get(futureLines, i))
        array.clear(futureLines)
    if array.size(futureLabels) > 0
        for i = 0 to array.size(futureLabels) - 1 by 1
            label.delete(array.get(futureLabels, i))
        array.clear(futureLabels)

    int nowTime = time

    // Light matte colors for lines
    bearLineColor = color.new(color.rgb(220, 38, 38), lineTransparency)
    halvingLineColor = color.new(color.rgb(202, 138, 4), lineTransparency)
    bullLineColor = color.new(color.rgb(22, 163, 74), lineTransparency)

    // Light backgrounds for labels
    bearLabelBg = color.rgb(254, 242, 242)
    halvingLabelBg = color.rgb(255, 251, 235)
    bullLabelBg = color.rgb(240, 253, 244)

    if not na(bearLowDate) and bearLowDate > nowTime
        ln = line.new(bearLowDate, close * 0.3, bearLowDate, close * 3, xloc = xloc.bar_time, extend = extend.both, color = bearLineColor, width = 2, style = line.style_solid)
        array.push(futureLines, ln)
        lblText = '▼ Bear Low\n' + formatMonthYear(bearLowDate) + '\n$' + str.tostring(bearLow18, '#,###')
        lb = label.new(bearLowDate, close * 2.5, lblText, xloc = xloc.bar_time, style = label.style_label_down, color = bearLabelBg, textcolor = color.rgb(15, 23, 42), size = size.normal, textalign = text.align_center)
        array.push(futureLabels, lb)

    if not na(nextHalvingDate) and nextHalvingDate > nowTime
        ln = line.new(nextHalvingDate, close * 0.3, nextHalvingDate, close * 3, xloc = xloc.bar_time, extend = extend.both, color = halvingLineColor, width = 2, style = line.style_dashed)
        array.push(futureLines, ln)
        lblText = '⏲ Halving\n' + formatMonthYear(nextHalvingDate)
        lb = label.new(nextHalvingDate, close * 2.5, lblText, xloc = xloc.bar_time, style = label.style_label_down, color = halvingLabelBg, textcolor = color.rgb(15, 23, 42), size = size.normal, textalign = text.align_center)
        array.push(futureLabels, lb)

    if not na(nextBullPeakDate) and nextBullPeakDate > nowTime
        ln = line.new(nextBullPeakDate, close * 0.3, nextBullPeakDate, close * 3, xloc = xloc.bar_time, extend = extend.both, color = bullLineColor, width = 2, style = line.style_dashed)
        array.push(futureLines, ln)
        lblText = '▲ Bull Peak\n' + formatMonthYear(nextBullPeakDate) + '\n$' + str.tostring(nextBullPeakPrice, '#,###')
        lb = label.new(nextBullPeakDate, close * 2.5, lblText, xloc = xloc.bar_time, style = label.style_label_down, color = bullLabelBg, textcolor = color.rgb(15, 23, 42), size = size.normal, textalign = text.align_center)
        array.push(futureLabels, lb)

// ============================================================
// SECTION M6: CYCLE HISTORY TABLE (SMALL - TOP RIGHT)
// ============================================================
showCycleTable = input.bool(true, title = 'Show Cycle History', group = 'M2 Cycle')

var table cycTbl = na

if barstate.islast and showCycleTable
    if not na(cycTbl)
        table.delete(cycTbl)

    legCount = array.size(legType)
    rowsToShow = math.min(legCount, 3)
    rowCount = rowsToShow + 2

    // Light matte colors
    histBgColor = color.rgb(248, 250, 252)
    histHeaderBg = color.rgb(226, 232, 240)
    histBorderColor = color.rgb(203, 213, 225)
    histTextColor = color.rgb(15, 23, 42)
    histMutedText = color.rgb(100, 116, 139)

    cycTbl := table.new(position.top_right, 4, rowCount, bgcolor = histBgColor, border_width = 1, border_color = histBorderColor)

    table.cell(cycTbl, 0, 0, 'Type', text_color = histTextColor, bgcolor = histHeaderBg, text_size = size.small)
    table.cell(cycTbl, 1, 0, 'Price', text_color = histTextColor, bgcolor = histHeaderBg, text_size = size.small)
    table.cell(cycTbl, 2, 0, 'Steps', text_color = histTextColor, bgcolor = histHeaderBg, text_size = size.small)
    table.cell(cycTbl, 3, 0, 'Date', text_color = histTextColor, bgcolor = histHeaderBg, text_size = size.small)

    startIdx = math.max(0, legCount - rowsToShow)
    rowOffset = 1
    if legCount > 0
        for i = startIdx to legCount - 1 by 1
            isBull = array.get(legType, i) == 'Bull'
            rowBg = isBull ? color.rgb(240, 253, 244) : color.rgb(254, 242, 242)
            textColor = isBull ? color.rgb(22, 163, 74) : color.rgb(220, 38, 38)
            table.cell(cycTbl, 0, rowOffset, array.get(legType, i), text_color = textColor, bgcolor = rowBg, text_size = size.small)
            table.cell(cycTbl, 1, rowOffset, '$' + str.tostring(array.get(legEnd, i), '#,###'), text_color = histTextColor, bgcolor = rowBg, text_size = size.small)
            table.cell(cycTbl, 2, rowOffset, str.tostring(array.get(legSteps, i), '#.#'), text_color = histMutedText, bgcolor = rowBg, text_size = size.small)
            table.cell(cycTbl, 3, rowOffset, formatMonthYear(array.get(legEndTime, i)), text_color = histMutedText, bgcolor = rowBg, text_size = size.small)
            rowOffset := rowOffset + 1
            rowOffset

    ongoingType = cycState == 'bull' ? '▲ Bull (active)' : '▼ Bear (active)'
    ongoingEnd = cycState == 'bull' ? runHigh : runLow
    ongoingSteps = cycState == 'bull' ? (math.sqrt(runHigh) - math.sqrt(lastConfirmedLow)) / cycleStepVal : (math.sqrt(lastConfirmedHigh) - math.sqrt(runLow)) / cycleStepVal
    ongoingEndStr = cycState == 'bull' ? formatMonthYear(runHighTime) : formatMonthYear(runLowTime)

    ongoingBg = color.rgb(255, 251, 235)
    table.cell(cycTbl, 0, rowOffset, ongoingType, text_color = color.rgb(202, 138, 4), bgcolor = ongoingBg, text_size = size.small)
    table.cell(cycTbl, 1, rowOffset, '$' + str.tostring(ongoingEnd, '#,###'), text_color = histTextColor, bgcolor = ongoingBg, text_size = size.small)
    table.cell(cycTbl, 2, rowOffset, str.tostring(ongoingSteps, '#.#'), text_color = histMutedText, bgcolor = ongoingBg, text_size = size.small)
    table.cell(cycTbl, 3, rowOffset, ongoingEndStr, text_color = histMutedText, bgcolor = ongoingBg, text_size = size.small)
````
