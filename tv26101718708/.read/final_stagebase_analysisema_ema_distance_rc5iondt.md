# FINAL STAGE/BASE ANALYSIS/EMA/% EMA DISTANCE

- url: https://www.tradingview.com/script/rC5ioNdT-FINAL-STAGE-BASE-ANALYSIS-EMA-EMA-DISTANCE/
- type: indicator
- pine_id: PUB;3261e3f89c3b4a198f27adc35b13bd6c
- version: 1.0

## Description

FINAL STAGE/BASE ANALYSIS/EMA/% EMA DISTANCE. if you find any problems, do share with me.

## Source Code

````pine
//@version=6
indicator("Weinstein-O'Neil Master Engine PRO", overlay=true, max_lines_count=500, max_labels_count=500)

//=====================================================================
// INPUTS
//=====================================================================

groupWein = "Weinstein Settings"

maLength      = input.int(30, "Weekly MA Length", group=groupWein)
minBaseWeeks  = input.int(4, "Min Weeks For Standard Base", minval=2, group=groupWein)
minAdvancePct = input.float(20.0, "Min Advance Between Bases %", minval=5.0, group=groupWein)

groupUI = "UI Controls"

tablePosInput = input.string("Bottom Left", "Dashboard Position",
 options=["Top Right", "Bottom Right", "Top Left", "Bottom Left", "Middle Right"],
 group=groupUI)

showLabelsInput = input.bool(true, "Show Base Labels", group=groupUI)
showEMAs        = input.bool(true, "Show EMA Lines", group=groupUI)
showStageMA     = input.bool(true, "Show Weekly Stage MA", group=groupUI)

groupEMA = "EMA Settings"

emaLen1 = input.int(10, "EMA 10", group=groupEMA)
emaLen2 = input.int(21, "EMA 21", group=groupEMA)
emaLen3 = input.int(55, "EMA 55", group=groupEMA)
emaLen4 = input.int(200, "EMA 200", group=groupEMA)

//=====================================================================
// WEINSTEIN ENGINE
//=====================================================================

f_weinstein_engine(int len, int minWeeks, float minAdvance) =>

    smaVal = ta.sma(close, len)
    slope  = smaVal - smaVal[2]

    atrVal   = ta.atr(14)
    flatFlag = math.abs(slope) < (atrVal * 0.05)

    int stage = 1

    if close > smaVal and slope > 0 and not flatFlag
        stage := 2
    else if close < smaVal and slope < 0 and not flatFlag
        stage := 4
    else if close > smaVal and flatFlag
        stage := 1
    else
        stage := 3

    //=========================================================
    // VARIABLES
    //=========================================================

    var int   baseCount         = 0
    var float stage2Low         = na
    var float currentBaseLow    = na
    var float currentBaseHigh   = na
    var float lastBreakoutPrice = na
    var int   baseStartBar      = na

    isStage2          = stage == 2
    justEnteredStage2 = isStage2 and stage[1] != 2

    //=========================================================
    // NEW STAGE 2
    //=========================================================

    if justEnteredStage2

        baseCount         := 1
        stage2Low         := low
        currentBaseLow    := low
        currentBaseHigh   := high
        lastBreakoutPrice := high
        baseStartBar      := bar_index

    //=========================================================
    // ACTIVE STAGE 2
    //=========================================================

    else if isStage2

        currentBaseLow  := math.min(nz(currentBaseLow, low), low)
        currentBaseHigh := math.max(nz(currentBaseHigh, high), high)

        //=====================================================
        // HARD RESET
        //=====================================================

        if low < nz(stage2Low)

            baseCount         := 1
            stage2Low         := low
            currentBaseLow    := low
            currentBaseHigh   := high
            lastBreakoutPrice := high
            baseStartBar      := bar_index

        //=====================================================
        // BASE LOGIC
        //=====================================================

        baseDuration = bar_index - nz(baseStartBar)

        explosiveMove = ((currentBaseHigh - currentBaseLow) / currentBaseLow) * 100 >= 90

        validBaseDuration = (baseDuration >= minWeeks) or ((baseDuration >= 2) and explosiveMove)

        breakout = close > currentBaseHigh[1]

        advancePct = ((close - nz(lastBreakoutPrice, close)) / nz(lastBreakoutPrice, close)) * 100

        validAdvance = advancePct >= minAdvance

        //=====================================================
        // NEW BASE CONFIRMED
        //=====================================================

        if breakout and validBaseDuration and validAdvance

            baseCount += 1

            currentBaseLow    := low
            currentBaseHigh   := high
            lastBreakoutPrice := close
            baseStartBar      := bar_index

    //=========================================================
    // RESET
    //=========================================================

    else

        baseCount         := 0
        stage2Low         := na
        currentBaseLow    := na
        currentBaseHigh   := na
        lastBreakoutPrice := na
        baseStartBar      := na

    [stage, baseCount, smaVal, slope, currentBaseHigh, currentBaseLow]

//=====================================================================
// WEEKLY CONTEXT
//=====================================================================

[wStage, wBase, wSma, wSlope, wBaseHigh, wBaseLow] = request.security(syminfo.tickerid, "W", f_weinstein_engine(maLength, minBaseWeeks, minAdvancePct), barmerge.gaps_off)

//=====================================================================
// WEEKLY MA
//=====================================================================

plot(showStageMA ? wSma : na,
 title="Weekly 30 MA",
 color=wSlope > 0 ? color.lime : color.red,
 linewidth=3)

//=====================================================================
// EMA VALUES
// NOW EMA CHANGES ACCORDING TO CHART TIMEFRAME
//=====================================================================

e1 = ta.ema(close, emaLen1)
e2 = ta.ema(close, emaLen2)
e3 = ta.ema(close, emaLen3)
e4 = ta.ema(close, emaLen4)

//=====================================================================
// DAILY EMA DISTANCE ONLY FOR TABLE
//=====================================================================

dailyClose = request.security(syminfo.tickerid, "D", close)

dailyEma10 = request.security(syminfo.tickerid, "D", ta.ema(close, emaLen1))
dailyEma21 = request.security(syminfo.tickerid, "D", ta.ema(close, emaLen2))
dailyEma55 = request.security(syminfo.tickerid, "D", ta.ema(close, emaLen3))

dist1 = ((dailyClose - dailyEma10) / dailyEma10) * 100
dist2 = ((dailyClose - dailyEma21) / dailyEma21) * 100
dist3 = ((dailyClose - dailyEma55) / dailyEma55) * 100

//=====================================================================
// EMA PLOTS
//=====================================================================

plot(showEMAs ? e1 : na, color=color.aqua, linewidth=2, title="EMA 10")
plot(showEMAs ? e2 : na, color=color.yellow, linewidth=2, title="EMA 21")
plot(showEMAs ? e3 : na, color=color.orange, linewidth=2, title="EMA 55")
plot(showEMAs ? e4 : na, color=color.purple, linewidth=3, title="EMA 200")

//=====================================================================
// LABELS
//=====================================================================

isWeekly = timeframe.isweekly

baseIncreased = wBase > nz(wBase[1])

if isWeekly and showLabelsInput and baseIncreased and wStage == 2

    label.new(
     bar_index,
     low,
     "B" + str.tostring(wBase),
     style=label.style_label_up,
     color=color.green,
     textcolor=color.white,
     yloc=yloc.belowbar,
     size=size.tiny)

//=====================================================================
// TABLE POSITION
//=====================================================================

tPos = tablePosInput == "Top Right" ? position.top_right :
       tablePosInput == "Bottom Right" ? position.bottom_right :
       tablePosInput == "Top Left" ? position.top_left :
       tablePosInput == "Bottom Left" ? position.bottom_left :
       position.middle_right

//=====================================================================
// SMALL DASHBOARD
//=====================================================================

var table dashboard = table.new(
 tPos,
 2,
 5,
 bgcolor=color.new(color.black, 15),
 border_width=1)

//=====================================================================
// TABLE DATA
//=====================================================================

if barstate.islast

    table.clear(dashboard, 0, 0, 1, 4)

    string stageBaseText = "Stage " + str.tostring(wStage) + " | B" + str.tostring(wBase)

    string baseRangeText = str.tostring(wBaseHigh, "#.##") + " / " + str.tostring(wBaseLow, "#.##")

    //=========================================================
    // ROW 1
    //=========================================================

    table.cell(
     dashboard,
     0,
     0,
     "Weekly",
     text_color=color.white,
     text_size=size.small)

    table.cell(
     dashboard,
     1,
     0,
     stageBaseText,
     text_color=color.white,
     bgcolor=wStage == 2 ? color.green : color.red,
     text_size=size.small)

    //=========================================================
    // ROW 2
    //=========================================================

    table.cell(
     dashboard,
     0,
     1,
     "Base H/L",
     text_color=color.white,
     text_size=size.small)

    table.cell(
     dashboard,
     1,
     1,
     baseRangeText,
     text_color=color.white,
     text_size=size.small)

    //=========================================================
    // ROW 3
    //=========================================================

    table.cell(
     dashboard,
     0,
     2,
     "D EMA10 %",
     text_color=color.white,
     text_size=size.small)

    table.cell(
     dashboard,
     1,
     2,
     str.tostring(dist1, "#.##") + "%",
     text_color=dist1 >= 0 ? color.lime : color.red,
     text_size=size.small)

    //=========================================================
    // ROW 4
    //=========================================================

    table.cell(
     dashboard,
     0,
     3,
     "D EMA21 %",
     text_color=color.white,
     text_size=size.small)

    table.cell(
     dashboard,
     1,
     3,
     str.tostring(dist2, "#.##") + "%",
     text_color=dist2 >= 0 ? color.lime : color.red,
     text_size=size.small)

    //=========================================================
    // ROW 5
    //=========================================================

    table.cell(
     dashboard,
     0,
     4,
     "D EMA55 %",
     text_color=color.white,
     text_size=size.small)

    table.cell(
     dashboard,
     1,
     4,
     str.tostring(dist3, "#.##") + "%",
     text_color=dist3 >= 0 ? color.lime : color.red,
     text_size=size.small)
````
