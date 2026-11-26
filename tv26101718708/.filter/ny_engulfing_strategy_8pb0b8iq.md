# NY Engulfing Strategy

- url: https://www.tradingview.com/script/8Pb0b8IQ-NY-Engulfing-Strategy/
- type: indicator
- pine_id: PUB;75e302f40fd4496c97774dc05c036103
- version: 1.0

## Description

This backtesting indicator is a rule-based trend strategy designed to identify high-probability engulfing setups during the New York session while enforcing strict trade filters to improve consistency. It combines a moving average for trend direction (with optional slope confirmation), engulfing candle logic based on candle bodies (with optional two-candle patterns), and an optional proximity filter to ensure entries occur near the moving average. Trades are only allowed within a defined session window (default 9:40 AM–4:45 PM EST), with limits on the number of trades per day and optional rules like stopping after the first win or forcing a close at 4:55 PM. The indicator simulates trade outcomes using fixed SL/TP values (with manual inputs always overriding presets), tracks performance over a customizable lookback period, and displays key metrics such as win rate, drawdown, profit percentage, average R per day, streaks, and counts of strong performance days (3 win days and 3 loss days). It also includes intrabar “sticky” entry logic so signals are preserved once price touches an entry level during a candle, providing more realistic backtesting results.

## Source Code

````pine
//@version=5
indicator("Universal Trend Engulfing Intrabar Break", overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

//================ HELPERS =================//
max2(a, b) => a > b ? a : b
min2(a, b) => a < b ? a : b
abs2(x) => x >= 0 ? x : -x

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

slPreset =
     instrumentPreset == "US30"   ? 60.0 :
     instrumentPreset == "NAS100" ? 60.0 :
     15.0

tpPreset =
     instrumentPreset == "US30"   ? 50.0 :
     instrumentPreset == "NAS100" ? 50.0 :
     12.0

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
inSession = not na(time(timeframe.period, sessionInput, timezoneInput))
sessionOK = useSession ? inSession : true

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

var int lastDayKey = na
var int tradesToday = 0
var bool wonToday = false

if na(lastDayKey) or dayKey != lastDayKey
    lastDayKey := dayKey
    tradesToday := 0
    wonToday := false

canTradeToday = tradesToday < maxTradesPerDay and (not stopAfterFirstWin or not wonToday)

//================ BAR SAFETY =================//
enoughBars = bar_index >= 2

//================ ENGULF LOGIC =================//
prevBodyHigh = enoughBars ? bodyHigh(open[1], close[1]) : na
prevBodyLow  = enoughBars ? bodyLow(open[1], close[1])  : na

refBodyHigh2 = enoughBars ? bodyHigh(open[2], close[2]) : na
refBodyLow2  = enoughBars ? bodyLow(open[2], close[2])  : na

currBull = close > open
currBear = close < open

bullOneCandle = enoughBars and currBull and open <= prevBodyLow and close >= prevBodyHigh
bearOneCandle = enoughBars and currBear and open >= prevBodyHigh and close <= prevBodyLow

twoBodyHigh = enoughBars ? max2(bodyHigh(open, close), bodyHigh(open[1], close[1])) : na
twoBodyLow  = enoughBars ? min2(bodyLow(open, close), bodyLow(open[1], close[1]))  : na

bullTwoCandle = enoughBars and currBull and twoBodyLow <= refBodyLow2 and twoBodyHigh >= refBodyHigh2
bearTwoCandle = enoughBars and currBear and twoBodyHigh >= refBodyHigh2 and twoBodyLow <= refBodyLow2

bullSignal = enoughBars and (bullOneCandle or (allowTwoCandleEngulf and bullTwoCandle))
bearSignal = enoughBars and (bearOneCandle or (allowTwoCandleEngulf and bearTwoCandle))

bullEntry = bullOneCandle ? prevBodyHigh : refBodyHigh2
bearEntry = bearOneCandle ? prevBodyLow  : refBodyLow2

//================ TREND =================//
bullTrend = enoughBars and close > ma and bullEntry > ma and (not useSlope or ma > ma[1])
bearTrend = enoughBars and close < ma and bearEntry < ma and (not useSlope or ma < ma[1])

//================ MA PROXIMITY =================//
bullNearMA = not useMAPximity or (not na(bullEntry) and abs2(bullEntry - ma) <= maProxPoints)
bearNearMA = not useMAPximity or (not na(bearEntry) and abs2(bearEntry - ma) <= maProxPoints)

//================ STICKY INTRABAR TOUCH =================//
var bool intrabarLongLatched = false
var bool intrabarShortLatched = false
var int latchedBarIndex = na

if na(latchedBarIndex) or bar_index != latchedBarIndex
    intrabarLongLatched := false
    intrabarShortLatched := false
    latchedBarIndex := bar_index

longTouchedIntrabar  = enoughBars and bullSignal and bullNearMA and bullTrend and not na(bullEntry) and high >= bullEntry
shortTouchedIntrabar = enoughBars and bearSignal and bearNearMA and bearTrend and not na(bearEntry) and low <= bearEntry

if longTouchedIntrabar
    intrabarLongLatched := true

if shortTouchedIntrabar
    intrabarShortLatched := true

//================ STATE =================//
var bool inTrade = false
var float entry = na
var float sl = na
var float tp = na
var int dir = 0
var int entryBar = na

var box activeRisk = na
var box activeReward = na

//================ PERFORMANCE STORAGE =================//
var int[] results = array.new_int()
var int[] resultTimes = array.new_int()
var float[] resultPct = array.new_float()
var int[] resultDayKeys = array.new_int()

cutoff = timenow - lookbackDays * 24 * 60 * 60 * 1000

//================ ENTRY =================//
newLong  = enoughBars and not inTrade and sessionOK and canTradeToday and intrabarLongLatched
newShort = enoughBars and not inTrade and sessionOK and canTradeToday and intrabarShortLatched

if newLong
    entry := bullEntry
    sl := entry - slPoints
    tp := entry + tpPoints
    dir := 1
    inTrade := true
    entryBar := bar_index
    tradesToday += 1

    if showPosition
        activeRisk := box.new(entryBar, entry, entryBar + 1, sl, bgcolor=color.new(color.red, boxOpacity), border_width=0)
        activeReward := box.new(entryBar, tp, entryBar + 1, entry, bgcolor=color.new(color.green, boxOpacity), border_width=0)

if newShort
    entry := bearEntry
    sl := entry + slPoints
    tp := entry - tpPoints
    dir := -1
    inTrade := true
    entryBar := bar_index
    tradesToday += 1

    if showPosition
        activeRisk := box.new(entryBar, sl, entryBar + 1, entry, bgcolor=color.new(color.red, boxOpacity), border_width=0)
        activeReward := box.new(entryBar, entry, entryBar + 1, tp, bgcolor=color.new(color.green, boxOpacity), border_width=0)

//================ EXTEND =================//
if inTrade and showPosition
    rightEdge = max2(bar_index, entryBar + 1)
    if not na(activeRisk)
        box.set_right(activeRisk, rightEdge)
    if not na(activeReward)
        box.set_right(activeReward, rightEdge)

//================ EXIT =================//
if inTrade
    hitSL = dir == 1 ? low <= sl : high >= sl
    hitTP = dir == 1 ? high >= tp : low <= tp
    force455Close = closeAt455EST and close455Window

    if hitSL or hitTP or force455Close
        tradeResult = 0
        tradePct = 0.0
        riskR = riskPerTrade / 100.0
        rewardR = riskR * (tpPoints / slPoints)

        if hitTP and not hitSL
            tradeResult := 1
            tradePct := rewardR * 100.0
        else if hitSL and not hitTP
            tradeResult := -1
            tradePct := -riskR * 100.0
        else if hitSL and hitTP
            tradeResult := -1
            tradePct := -riskR * 100.0
        else if force455Close
            tradeResult := dir == 1 ? (close >= entry ? 1 : -1) : (close <= entry ? 1 : -1)
            tradePct := tradeResult == 1 ? rewardR * 100.0 : -riskR * 100.0

        if tradeResult == 1
            wonToday := true

        array.push(results, tradeResult)
        array.push(resultTimes, time)
        array.push(resultPct, tradePct)
        array.push(resultDayKeys, dayKey)

        while array.size(resultTimes) > 0
            oldest = array.get(resultTimes, 0)
            if oldest < cutoff
                array.shift(resultTimes)
                array.shift(results)
                array.shift(resultPct)
                array.shift(resultDayKeys)
            else
                break

        inTrade := false
        entry := na
        sl := na
        tp := na
        dir := 0
        entryBar := na
        activeRisk := na
        activeReward := na

//================ SIGNALS =================//
plotshape(showSignals and newLong, location=location.belowbar, color=color.green, style=shape.labelup, text="LONG", textcolor=color.white, size=size.small)
plotshape(showSignals and newShort, location=location.abovebar, color=color.red, style=shape.labeldown, text="SHORT", textcolor=color.white, size=size.small)

//================ STATS =================//
var table t = table.new(position.top_right, 2, 32, border_width=1)

wins = 0
losses = 0
equity = 100.0
peakEquity = 100.0
maxDrawdown = 0.0

currentWinStreak = 0
currentLossStreak = 0
maxWinStreak = 0
maxLossStreak = 0

resultCount = array.size(results)

if resultCount > 0
    for i = 0 to resultCount - 1
        r = array.get(results, i)

        riskR = riskPerTrade / 100.0
        rewardR = riskR * (tpPoints / slPoints)

        if r == 1
            wins += 1
            currentWinStreak += 1
            currentLossStreak := 0
            maxWinStreak := max2(maxWinStreak, currentWinStreak)
            equity := useCompounding ? equity * (1 + rewardR) : equity + (100 * rewardR)
        else
            losses += 1
            currentLossStreak += 1
            currentWinStreak := 0
            maxLossStreak := max2(maxLossStreak, currentLossStreak)
            equity := useCompounding ? equity * (1 - riskR) : equity - (100 * riskR)

        peakEquity := max2(peakEquity, equity)
        dd = peakEquity > 0 ? ((peakEquity - equity) / peakEquity) * 100.0 : 0.0
        maxDrawdown := max2(maxDrawdown, dd)

totalTrades = wins + losses
winRate = totalTrades > 0 ? (wins * 100.0) / totalTrades : 0.0
profitPct = equity - 100.0

winningDays = 0
losingDays = 0
breakevenDays = 0
threeWinDays = 0
threeLossDays = 0
sumDayR = 0.0

if resultCount > 0
    currentDay = array.get(resultDayKeys, 0)
    currentDayPnl = 0.0
    currentDayWins = 0
    currentDayLosses = 0

    for i = 0 to resultCount - 1
        dk = array.get(resultDayKeys, i)
        pnl = array.get(resultPct, i)
        r = array.get(results, i)

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

            if currentDayWins >= 3
                threeWinDays += 1
            if currentDayLosses >= 3
                threeLossDays += 1

            sumDayR += currentDayPnl / riskPerTrade

            currentDay := dk
            currentDayPnl := pnl
            currentDayWins := r == 1 ? 1 : 0
            currentDayLosses := r == -1 ? 1 : 0

    if currentDayPnl > 0
        winningDays += 1
    else if currentDayPnl < 0
        losingDays += 1
    else
        breakevenDays += 1

    if currentDayWins >= 3
        threeWinDays += 1
    if currentDayLosses >= 3
        threeLossDays += 1

    sumDayR += currentDayPnl / riskPerTrade

countedDays = winningDays + losingDays
winningDayPct = countedDays > 0 ? (winningDays * 100.0) / countedDays : 0.0
allDays = winningDays + losingDays + breakevenDays
avgRPerDay = allDays > 0 ? sumDayR / allDays : 0.0

headerBg = color.rgb(25, 25, 25)
labelBg  = color.black
valueBg  = color.black
headerTx = color.white
labelTx  = color.white

perfColor(v) =>
    v > 0 ? color.lime : v < 0 ? color.red : color.white

drawdownColor(v) =>
    v > 0 ? color.red : color.white

cellLabel(_row, _txt) =>
    table.cell(t, 0, _row, _txt, bgcolor=labelBg, text_color=labelTx)

cellValue(_row, _txt, _color) =>
    table.cell(t, 1, _row, _txt, bgcolor=valueBg, text_color=_color)

if barstate.islast
    table.clear(t, 0, 0, 1, 31)

    row = 0

    settingsHeader = compactMode ? "SET" : "SETTINGS"
    perfHeader = compactMode ? "PERF" : "PERFORMANCE"

    table.cell(t, 0, row, settingsHeader, bgcolor=headerBg, text_color=headerTx)
    table.cell(t, 1, row, "", bgcolor=headerBg, text_color=headerTx)
    row += 1

    cellLabel(row, compactMode ? "Session" : "Session")
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
    table.cell(t, 1, row, "", bgcolor=headerBg, text_color=headerTx)
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
