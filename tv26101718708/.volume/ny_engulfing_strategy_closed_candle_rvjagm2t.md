# NY Engulfing Strategy (Closed Candle)

- url: https://www.tradingview.com/script/RvJAGm2t-NY-Engulfing-Strategy-Closed-Candle/
- type: indicator
- pine_id: PUB;ec4fe00194cf4679984e67be0dcaec0f
- version: 1.0

## Description

This indicator back tests engulfing candles with the trend

## Source Code

````pine
//@version=5
indicator("Universal Trend Engulfing (Closed Candle)", overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

//================ HELPERS =================//
max2(a, b) => a > b ? a : b
min2(a, b) => a < b ? a : b
abs2(x)    => x >= 0 ? x : -x

bodyHigh(_o, _c) => max2(_o, _c)
bodyLow(_o, _c)  => min2(_o, _c)

//================ INPUTS =================//
instrumentPreset = input.string("NAS100", "Preset Reference", options=["US30", "NAS100", "S&P500"])

maType       = input.string("SMA", "MA Type", options=["SMA","EMA","WMA","VWMA","RMA","HMA"])
maLen        = input.int(20, "MA Length", minval=1)
useSlope     = input.bool(true, "MA Slope Filter")

useMAPximity = input.bool(false, "Use MA Proximity Filter")
maProxPoints = input.float(20.0, "MA Proximity Points", step=0.25, minval=0.0)

useSession    = input.bool(true, "Use Session Filter")
sessionInput  = input.session("0940-1645", "Allowed Trading Session")
timezoneInput = input.string("America/New_York", "Session Timezone")
closeAt455EST = input.bool(true, "Close Open Trade At 4:55 PM EST")

maxTradesPerDay   = input.int(3, "Max Trades Per Day", minval=1)
stopAfterFirstWin = input.bool(false, "Stop Trading After First Win Of Day")

showSignals  = input.bool(true, "Show Signals")
showPosition = input.bool(true, "Show SL/TP Boxes")

allowTwoCandleEngulf = input.bool(false, "Allow 2-Candle Engulf")

slManual = input.float(60.0, "SL Points", step=0.25, minval=0.25)
tpManual = input.float(50.0, "TP Points", step=0.25, minval=0.25)

// Manual values always win
slPoints = slManual
tpPoints = tpManual

boxOpacity = input.int(50, "Box Opacity (0 solid - 100 invisible)", minval=0, maxval=100)

lookbackDays   = input.int(10000, "Stats Lookback (Days)", minval=1)
riskPerTrade   = input.float(1.0, "Risk % Per Trade", minval=0.1, step=0.1)
useCompounding = input.bool(false, "Use Compounding")

compactMode = input.bool(false, "Compact Stats Display")

//================ MA =================//
ma =
     maType == "SMA"  ? ta.sma(close, maLen) :
     maType == "EMA"  ? ta.ema(close, maLen) :
     maType == "WMA"  ? ta.wma(close, maLen) :
     maType == "VWMA" ? ta.vwma(close, maLen) :
     maType == "RMA"  ? ta.rma(close, maLen) :
     ta.hma(close, maLen)

plot(ma, "MA", color=color.yellow, linewidth=2)

//================ SESSION =================//
// Evaluate session on the previous (closed) bar's timestamp to avoid lookahead
sessionTime = time(timeframe.period, sessionInput, timezoneInput)
inSession   = not na(sessionTime[1])
sessionOK   = useSession ? inSession : true

close455Ts = timestamp(
     "America/New_York",
     year(time, "America/New_York"),
     month(time, "America/New_York"),
     dayofmonth(time, "America/New_York"),
     16,
     55)

close455Window = time >= close455Ts and time[1] < close455Ts

//================ DAILY LIMITS =================//
dayKey = year(time, timezoneInput) * 10000 + month(time, timezoneInput) * 100 + dayofmonth(time, timezoneInput)

var int lastDayKey  = na
var int tradesToday = 0
var bool wonToday   = false

if na(lastDayKey) or dayKey != lastDayKey
    lastDayKey  := dayKey
    tradesToday := 0
    wonToday    := false

canTradeToday = tradesToday < maxTradesPerDay and (not stopAfterFirstWin or not wonToday)

//================ BAR SAFETY =================//
// We need at least 3 confirmed bars behind us:
//   [1] = engulfing candle (just closed)
//   [2] = candle being engulfed
//   [3] = reference for 2-candle engulf
enoughBars = bar_index >= 3

//================ ENGULF LOGIC (all on confirmed closed bars) =================//
// [1] = engulfing bar (closed last bar)
// [2] = prior bar (the one being engulfed)
// [3] = bar before that (for 2-candle engulf reference)

prevBodyHigh = enoughBars ? bodyHigh(open[1], close[1]) : na
prevBodyLow  = enoughBars ? bodyLow(open[1], close[1])  : na

refBodyHigh2 = enoughBars ? bodyHigh(open[2], close[2]) : na
refBodyLow2  = enoughBars ? bodyLow(open[2], close[2])  : na

refBodyHigh3 = enoughBars ? bodyHigh(open[3], close[3]) : na
refBodyLow3  = enoughBars ? bodyLow(open[3], close[3])  : na

// Candle [1] direction
candleBull = enoughBars ? close[1] > open[1] : false
candleBear = enoughBars ? close[1] < open[1] : false

// 1-candle engulf: [1] engulfs [2]
bullOneCandle = enoughBars and candleBull and open[1] <= refBodyLow2  and close[1] >= refBodyHigh2
bearOneCandle = enoughBars and candleBear and open[1] >= refBodyHigh2 and close[1] <= refBodyLow2

// 2-candle engulf: [1]+[2] together engulf [3]
twoBodyHigh = enoughBars ? max2(bodyHigh(open[1], close[1]), bodyHigh(open[2], close[2])) : na
twoBodyLow  = enoughBars ? min2(bodyLow(open[1], close[1]),  bodyLow(open[2], close[2]))  : na

bullTwoCandle = enoughBars and candleBull and twoBodyLow <= refBodyLow3  and twoBodyHigh >= refBodyHigh3
bearTwoCandle = enoughBars and candleBear and twoBodyHigh >= refBodyHigh3 and twoBodyLow <= refBodyLow3

bullSignal = enoughBars and (bullOneCandle or (allowTwoCandleEngulf and bullTwoCandle))
bearSignal = enoughBars and (bearOneCandle or (allowTwoCandleEngulf and bearTwoCandle))

// Entry is the body high/low of the candle being engulfed (confirmed closed levels)
bullEntry = bullOneCandle ? refBodyHigh2 : refBodyHigh3
bearEntry = bearOneCandle ? refBodyLow2  : refBodyLow3

//================ TREND (based on closed bar [1]) =================//
bullTrend = enoughBars and close[1] > ma[1] and bullEntry > ma[1] and (not useSlope or ma[1] > ma[2])
bearTrend = enoughBars and close[1] < ma[1] and bearEntry < ma[1] and (not useSlope or ma[1] < ma[2])

//================ MA PROXIMITY =================//
bullNearMA = not useMAPximity or (not na(bullEntry) and abs2(bullEntry - ma[1]) <= maProxPoints)
bearNearMA = not useMAPximity or (not na(bearEntry) and abs2(bearEntry - ma[1]) <= maProxPoints)

//================ SIGNAL CONDITIONS =================//
// Entry triggers on the open of the CURRENT bar, after the engulf closed last bar.
// All conditions based on confirmed data only — zero lookahead.
rawLong  = enoughBars and bullSignal and bullTrend and bullNearMA and not na(bullEntry)
rawShort = enoughBars and bearSignal and bearTrend and bearNearMA and not na(bearEntry)

//================ STATE =================//
var bool  inTrade  = false
var float entry    = na
var float sl       = na
var float tp       = na
var int   dir      = 0
var int   entryBar = na

var box activeRisk   = na
var box activeReward = na

//================ PERFORMANCE STORAGE =================//
var int[]   results       = array.new_int()
var int[]   resultTimes   = array.new_int()
var float[] resultPct     = array.new_float()
var int[]   resultDayKeys = array.new_int()

cutoff = timenow - lookbackDays * 24 * 60 * 60 * 1000

//================ ENTRY =================//
// Enter at current bar's open — the bar that opened after the engulf closed.
// No intrabar logic, no high/low snooping.
newLong  = rawLong  and not inTrade and sessionOK and canTradeToday
newShort = rawShort and not inTrade and sessionOK and canTradeToday

if newLong
    entry    := bullEntry
    sl       := entry - slPoints
    tp       := entry + tpPoints
    dir      := 1
    inTrade  := true
    entryBar := bar_index
    tradesToday += 1

    if showPosition
        activeRisk   := box.new(entryBar, entry, entryBar + 1, sl, bgcolor=color.new(color.red,   boxOpacity), border_width=0)
        activeReward := box.new(entryBar, tp,    entryBar + 1, entry, bgcolor=color.new(color.green, boxOpacity), border_width=0)

if newShort
    entry    := bearEntry
    sl       := entry + slPoints
    tp       := entry - tpPoints
    dir      := -1
    inTrade  := true
    entryBar := bar_index
    tradesToday += 1

    if showPosition
        activeRisk   := box.new(entryBar, sl,    entryBar + 1, entry, bgcolor=color.new(color.red,   boxOpacity), border_width=0)
        activeReward := box.new(entryBar, entry, entryBar + 1, tp,    bgcolor=color.new(color.green, boxOpacity), border_width=0)

//================ EXTEND BOXES =================//
if inTrade and showPosition
    rightEdge = max2(bar_index, entryBar + 1)
    if not na(activeRisk)
        box.set_right(activeRisk, rightEdge)
    if not na(activeReward)
        box.set_right(activeReward, rightEdge)

//================ EXIT =================//
// SL/TP checked against current bar's high/low — this is valid because
// we are already IN the trade. Using high/low for exit is standard and
// does not cause lookahead or repainting.
if inTrade
    hitSL = dir == 1 ? low  <= sl : high >= sl
    hitTP = dir == 1 ? high >= tp : low  <= tp
    force455Close = closeAt455EST and close455Window

    if hitSL or hitTP or force455Close
        tradeResult = 0
        tradePct    = 0.0
        riskR       = riskPerTrade / 100.0
        rewardR     = riskR * (tpPoints / slPoints)

        if hitTP and not hitSL
            tradeResult := 1
            tradePct    := rewardR * 100.0
        else if hitSL and not hitTP
            tradeResult := -1
            tradePct    := -riskR * 100.0
        else if hitSL and hitTP
            // Both hit same bar — conservative: take the loss
            tradeResult := -1
            tradePct    := -riskR * 100.0
        else if force455Close
            tradeResult := dir == 1 ? (close >= entry ? 1 : -1) : (close <= entry ? 1 : -1)
            tradePct    := tradeResult == 1 ? rewardR * 100.0 : -riskR * 100.0

        if tradeResult == 1
            wonToday := true

        array.push(results,       tradeResult)
        array.push(resultTimes,   time)
        array.push(resultPct,     tradePct)
        array.push(resultDayKeys, dayKey)

        // Trim old results outside lookback window
        while array.size(resultTimes) > 0
            if array.get(resultTimes, 0) < cutoff
                array.shift(resultTimes)
                array.shift(results)
                array.shift(resultPct)
                array.shift(resultDayKeys)
            else
                break

        inTrade      := false
        entry        := na
        sl           := na
        tp           := na
        dir          := 0
        entryBar     := na
        activeRisk   := na
        activeReward := na

//================ SIGNALS =================//
plotshape(showSignals and newLong,  location=location.belowbar, color=color.green, style=shape.labelup,   text="LONG",  textcolor=color.white, size=size.small)
plotshape(showSignals and newShort, location=location.abovebar, color=color.red,   style=shape.labeldown, text="SHORT", textcolor=color.white, size=size.small)

//================ STATS TABLE =================//
var table t = table.new(position.top_right, 2, 32, border_width=1)

wins   = 0
losses = 0
equity = 100.0
peakEquity  = 100.0
maxDrawdown = 0.0

currentWinStreak  = 0
currentLossStreak = 0
maxWinStreak      = 0
maxLossStreak     = 0

resultCount = array.size(results)

if resultCount > 0
    for i = 0 to resultCount - 1
        r      = array.get(results, i)
        riskR  = riskPerTrade / 100.0
        rewardR = riskR * (tpPoints / slPoints)

        if r == 1
            wins             += 1
            currentWinStreak += 1
            currentLossStreak := 0
            maxWinStreak      := max2(maxWinStreak, currentWinStreak)
            equity            := useCompounding ? equity * (1 + rewardR) : equity + (100 * rewardR)
        else
            losses            += 1
            currentLossStreak += 1
            currentWinStreak  := 0
            maxLossStreak     := max2(maxLossStreak, currentLossStreak)
            equity            := useCompounding ? equity * (1 - riskR) : equity - (100 * riskR)

        peakEquity := max2(peakEquity, equity)
        dd         = peakEquity > 0 ? ((peakEquity - equity) / peakEquity) * 100.0 : 0.0
        maxDrawdown := max2(maxDrawdown, dd)

totalTrades = wins + losses
winRate     = totalTrades > 0 ? (wins * 100.0) / totalTrades : 0.0
profitPct   = equity - 100.0

winningDays   = 0
losingDays    = 0
breakevenDays = 0
threeWinDays  = 0
threeLossDays = 0
sumDayR       = 0.0

if resultCount > 0
    currentDay       = array.get(resultDayKeys, 0)
    currentDayPnl    = 0.0
    currentDayWins   = 0
    currentDayLosses = 0

    for i = 0 to resultCount - 1
        dk  = array.get(resultDayKeys, i)
        pnl = array.get(resultPct, i)
        r   = array.get(results, i)

        if dk == currentDay
            currentDayPnl += pnl
            if r == 1
                currentDayWins += 1
            else if r == -1
                currentDayLosses += 1
        else
            if currentDayPnl > 0
                winningDays += 1
            else if currentDayPnl < 0
                losingDays += 1
            else
                breakevenDays += 1

            if currentDayWins   >= 3
                threeWinDays  += 1
            if currentDayLosses >= 3
                threeLossDays += 1

            sumDayR += currentDayPnl / riskPerTrade

            currentDay       := dk
            currentDayPnl    := pnl
            currentDayWins   := r == 1  ? 1 : 0
            currentDayLosses := r == -1 ? 1 : 0

    // Final day
    if currentDayPnl > 0
        winningDays += 1
    else if currentDayPnl < 0
        losingDays += 1
    else
        breakevenDays += 1

    if currentDayWins   >= 3
        threeWinDays  += 1
    if currentDayLosses >= 3
        threeLossDays += 1

    sumDayR += currentDayPnl / riskPerTrade

countedDays     = winningDays + losingDays
winningDayPct   = countedDays > 0 ? (winningDays * 100.0) / countedDays : 0.0
allDays         = winningDays + losingDays + breakevenDays
avgRPerDay      = allDays > 0 ? sumDayR / allDays : 0.0

headerBg = color.rgb(25, 25, 25)
labelBg  = color.black
valueBg  = color.black
headerTx = color.white
labelTx  = color.white

perfColor(v)     => v > 0 ? color.lime : v < 0 ? color.red : color.white
drawdownColor(v) => v > 0 ? color.red  : color.white

cellLabel(_row, _txt)           => table.cell(t, 0, _row, _txt,  bgcolor=labelBg, text_color=labelTx)
cellValue(_row, _txt, _color)   => table.cell(t, 1, _row, _txt,  bgcolor=valueBg, text_color=_color)

if barstate.islast
    table.clear(t, 0, 0, 1, 31)

    row = 0

    settingsHeader = compactMode ? "SET"  : "SETTINGS"
    perfHeader     = compactMode ? "PERF" : "PERFORMANCE"

    table.cell(t, 0, row, settingsHeader, bgcolor=headerBg, text_color=headerTx)
    table.cell(t, 1, row, "",             bgcolor=headerBg, text_color=headerTx)
    row += 1

    cellLabel(row, "Session")
    cellValue(row, useSession ? sessionInput : "All Day", color.white)
    row += 1

    cellLabel(row, compactMode ? "TZ" : "Timezone")
    cellValue(row, timezoneInput, color.white)
    row += 1

    cellLabel(row, compactMode ? "Trades/Day" : "Max Trades/Day")
    cellValue(row, str.tostring(maxTradesPerDay), color.white)
    row += 1

    cellLabel(row, compactMode ? "SL" : "SL Points")
    cellValue(row, str.tostring(slPoints, "#.##"), color.white)
    row += 1

    cellLabel(row, compactMode ? "TP" : "TP Points")
    cellValue(row, str.tostring(tpPoints, "#.##"), color.white)
    row += 1

    if allowTwoCandleEngulf
        cellLabel(row, compactMode ? "2C" : "2-Candle")
        cellValue(row, "ON", color.white)
        row += 1

    if useMAPximity
        cellLabel(row, compactMode ? "MA Prox" : "MA Proximity")
        cellValue(row, "ON", color.white)
        row += 1

        cellLabel(row, compactMode ? "Prox Pts" : "Prox Points")
        cellValue(row, str.tostring(maProxPoints, "#.##"), color.white)
        row += 1

    if useSlope
        cellLabel(row, compactMode ? "MA Slope" : "MA Slope")
        cellValue(row, "ON", color.white)
        row += 1

    if stopAfterFirstWin
        cellLabel(row, compactMode ? "Stop 1W" : "Stop After Win")
        cellValue(row, "ON", color.white)
        row += 1

    if closeAt455EST
        cellLabel(row, compactMode ? "Close 4:55" : "Close At 4:55")
        cellValue(row, "ON", color.white)
        row += 1

    cellLabel(row, compactMode ? "Lookback" : "Lookback Days")
    cellValue(row, str.tostring(lookbackDays), color.white)
    row += 1

    cellLabel(row, compactMode ? "Compound" : "Compounding")
    cellValue(row, useCompounding ? "ON" : "OFF", color.white)
    row += 1

    table.cell(t, 0, row, perfHeader, bgcolor=headerBg, text_color=headerTx)
    table.cell(t, 1, row, "",         bgcolor=headerBg, text_color=headerTx)
    row += 1

    cellLabel(row, compactMode ? "W / L" : "Wins / Losses")
    cellValue(row, str.tostring(wins) + " / " + str.tostring(losses), color.white)
    row += 1

    cellLabel(row, compactMode ? "Win %" : "Win Rate")
    cellValue(row, str.tostring(winRate, "#.##") + "%", perfColor(winRate - 50))
    row += 1

    cellLabel(row, compactMode ? "Profit %" : "% Profit")
    cellValue(row, str.tostring(profitPct, "#.##") + "%", perfColor(profitPct))
    row += 1

    cellLabel(row, compactMode ? "DD %" : "Drawdown %")
    cellValue(row, str.tostring(maxDrawdown, "#.##") + "%", drawdownColor(maxDrawdown))
    row += 1

    cellLabel(row, compactMode ? "Win Day %" : "Winning Day %")
    cellValue(row, str.tostring(winningDayPct, "#.##") + "%", perfColor(winningDayPct - 50))
    row += 1

    cellLabel(row, compactMode ? "Avg R/Day" : "Avg R Per Day")
    cellValue(row, str.tostring(avgRPerDay, "#.##"), perfColor(avgRPerDay))
    row += 1

    cellLabel(row, compactMode ? "Max CW" : "Max Consec Wins")
    cellValue(row, str.tostring(maxWinStreak), perfColor(maxWinStreak))
    row += 1

    cellLabel(row, compactMode ? "Max CL" : "Max Consec Losses")
    cellValue(row, str.tostring(maxLossStreak), drawdownColor(maxLossStreak))
    row += 1

    cellLabel(row, compactMode ? "3W Days" : "3 Win Days")
    cellValue(row, str.tostring(threeWinDays), perfColor(threeWinDays))
    row += 1

    cellLabel(row, compactMode ? "3L Days" : "3 Loss Days")
    cellValue(row, str.tostring(threeLossDays), drawdownColor(threeLossDays))
    row += 1
````
