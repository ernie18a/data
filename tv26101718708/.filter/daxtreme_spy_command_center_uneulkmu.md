# DaXtreme SPY Command Center

- url: https://www.tradingview.com/script/UNeUlKMu-DaXtreme-SPY-Command-Center/
- type: indicator
- pine_id: PUB;0308a92e1628487eb4fbbf8a460fd6b4
- version: 2.0

## Description

**DaXtreme SPY Command Center** is a rule-based trading system designed specifically for SPY options trading. Rather than predicting market direction, it waits for multiple independent confirmations before generating a trade signal. The strategy is built around a 9:30–9:45 AM Opening Range Breakout (ORB), using the ORB High and ORB Low as the session's primary decision levels. Once the opening range is established, the script evaluates trend, momentum, participation, and market structure before issuing a BUY CALL or BUY PUT signal.

The system combines VWAP, the 9 EMA, and the 21 EMA to identify trend direction. Price must remain on the correct side of VWAP while the 9 EMA aligns with the 21 EMA and continues sloping in the direction of the trade. It also uses both a 5-minute RSI for overall market bias and an Entry RSI for immediate momentum confirmation. A Cumulative Volume Delta (CVD) proxy measures buying and selling pressure to help confirm institutional participation.

To reduce low-quality trades, the script includes several guardrails. An Extended Move Filter prevents entries after price has already moved too far from the 9 EMA, reducing the likelihood of chasing exhausted moves. A VWAP Chop Filter suppresses signals during sideways conditions where price repeatedly crosses VWAP without establishing direction. A Pullback Rejection Filter requires price to break the ORB, retest the level, and reject back in the direction of the trend before a signal is allowed, improving entry quality over simple breakout strategies.

Each potential trade receives a Signal Score from 0 to 10 based on ten independent confirmations, including VWAP position, EMA alignment, EMA trend, ORB retest, pullback rejection, RSI strength, CVD direction, and extension status. This score is converted into a trade grade ranging from A+ to C, allowing only high-quality setups to generate alerts. A configurable minimum score lets the trader control how selective the system should be.

The integrated Command Center dashboard provides a real-time overview of the current market environment. It displays the active Signal Score, star rating, trade grade, trade status, ORB High and Low, VWAP bias, 9 EMA trend, 5-minute RSI, Entry RSI, CVD direction, confidence percentage, market state, contract mode, and ORB status. Market conditions are classified as Trend, Range, Chop, or Squeeze to help the trader adapt expectations throughout the session.

Trade status progresses through a structured workflow of WAIT, CALL READY, BUY CALL, MANAGE CALL, PUT READY, BUY PUT, MANAGE PUT, and EXIT, giving clear guidance throughout the life of each trade. Exit warnings are generated whenever price loses the 9 EMA or VWAP for long positions, or reclaims those levels during short positions, signaling that the original trade thesis may be weakening.

The Command Center is optimized for SPY on the 5-minute timeframe and is intended for both 0DTE and 1DTE option contracts. It is designed to reduce emotional decision-making by requiring multiple layers of confirmation before entry and by providing objective guidance for trade management and exits. The overall philosophy is simple: trade only when structure, trend, momentum, and participation all agree, allowing quality to take precedence over quantity.

## Source Code

````pine
//@version=6
indicator("DaXtreme SPY Command Center V2", overlay=true, max_labels_count=500, max_lines_count=500)

//==============================
// INPUTS
//==============================
orbSession = input.session("0930-0945", "ORB Window")
contractMode = input.string("1DTE", "Contract Mode", options=["0DTE", "1DTE", "2-7DTE Weekly", "8-14DTE", "15-21DTE", "22-28DTE", "Custom 0-28DTE"])
customDTE = input.int(7, "Custom DTE", minval=0, maxval=28)
minSignalScore = input.int(7, "Minimum Signal Score", minval=1, maxval=10)

showORB = input.bool(true, "Show ORB High/Low")
showVWAP = input.bool(true, "Show VWAP")
showEMA9 = input.bool(true, "Show 9 EMA")
showEMA21 = input.bool(true, "Show 21 EMA")
showMenu = input.bool(true, "Show Command Center")
showSignals = input.bool(true, "Show BUY/SELL Labels")

requireRetest = input.bool(true, "Require ORB Retest")
requirePullbackReject = input.bool(true, "Require Pullback/Rejection")
oneSignalPerSide = input.bool(true, "One Signal Per Direction Per Day")

useTrendFilter = input.bool(true, "Use EMA Trend Filter")
useExtendedFilter = input.bool(true, "Block Extended Entries")
useChopFilter = input.bool(true, "Block VWAP Chop")

zeroDTE_MaxDistanceFromEMA = input.float(0.18, "0DTE Max Distance From 9 EMA (%)", step=0.01)
oneDTE_MaxDistanceFromEMA = input.float(0.28, "1DTE Max Distance From 9 EMA (%)", step=0.01)
weeklyDTE_MaxDistanceFromEMA = input.float(0.35, "2-7DTE Max Distance From 9 EMA (%)", step=0.01)
twoWeekDTE_MaxDistanceFromEMA = input.float(0.45, "8-14DTE Max Distance From 9 EMA (%)", step=0.01)
threeWeekDTE_MaxDistanceFromEMA = input.float(0.55, "15-21DTE Max Distance From 9 EMA (%)", step=0.01)
fourWeekDTE_MaxDistanceFromEMA = input.float(0.65, "22-28DTE Max Distance From 9 EMA (%)", step=0.01)

zeroDTE_MinDistanceFromVWAP = input.float(0.05, "0DTE Min Distance From VWAP (%)", step=0.01)
oneDTE_MinDistanceFromVWAP = input.float(0.03, "1DTE Min Distance From VWAP (%)", step=0.01)
weeklyDTE_MinDistanceFromVWAP = input.float(0.03, "2-7DTE Min Distance From VWAP (%)", step=0.01)
twoWeekDTE_MinDistanceFromVWAP = input.float(0.025, "8-14DTE Min Distance From VWAP (%)", step=0.005)
threeWeekDTE_MinDistanceFromVWAP = input.float(0.02, "15-21DTE Min Distance From VWAP (%)", step=0.005)
fourWeekDTE_MinDistanceFromVWAP = input.float(0.02, "22-28DTE Min Distance From VWAP (%)", step=0.005)

biasRsiLen = input.int(14, "5m RSI Length", minval=1)
entryRsiLen = input.int(9, "Entry RSI Length", minval=1)
entryTF = input.string("1", "Entry RSI Timeframe", options=["1", "5"])

deltaLookback = input.int(8, "CVD Delta Smoothing Length", minval=1)

exitOnEMA9Cross = input.bool(true, "Exit Warning On 9 EMA Cross")
exitOnVWAPCross = input.bool(true, "Exit Warning On VWAP Cross")

showTakeProfitLevels = input.bool(true, "Show TP Levels")
keepTPLevelsAfterExit = input.bool(true, "Keep TP Levels After Exit")
showTPHitLabels = input.bool(true, "Show TP Hit Labels")
tpMethod = input.string("ATR", "TP Method", options=["ATR", "ORB Range"])
tpAtrLen = input.int(14, "TP ATR Length", minval=1)
tpAtrMultiplier = input.float(1.0, "TP ATR Multiplier", minval=0.1, step=0.1)
tp1Multiple = input.float(1.0, "TP1 Multiple", minval=0.1, step=0.1)
tp2Multiple = input.float(1.5, "TP2 Multiple", minval=0.1, step=0.1)
tp3Multiple = input.float(2.0, "TP3 Multiple", minval=0.1, step=0.1)

//==============================
// DAY RESET
//==============================
newDay = ta.change(time("D")) != 0

//==============================
// ORB
//==============================
inORB = not na(time(timeframe.period, orbSession))

var float orbHigh = na
var float orbLow = na
var bool orbLocked = false

if newDay
    orbHigh := na
    orbLow := na
    orbLocked := false

if inORB
    orbHigh := na(orbHigh) ? high : math.max(orbHigh, high)
    orbLow := na(orbLow) ? low : math.min(orbLow, low)

if not inORB and not na(orbHigh) and not na(orbLow)
    orbLocked := true

//==============================
// INDICATORS
//==============================
vwapValue = ta.vwap(hlc3)
ema9 = ta.ema(close, 9)
ema21 = ta.ema(close, 21)
tpAtr = ta.atr(tpAtrLen)

biasRsi = request.security(syminfo.tickerid, "5", ta.rsi(close, biasRsiLen), barmerge.gaps_off, barmerge.lookahead_off)
entryRsi = request.security(syminfo.tickerid, entryTF, ta.rsi(close, entryRsiLen), barmerge.gaps_off, barmerge.lookahead_off)

aboveVWAP = close > vwapValue
belowVWAP = close < vwapValue

aboveEMA9 = close > ema9
belowEMA9 = close < ema9

emaTrendBull = ema9 > ema9[1] and ema9[1] > ema9[2]
emaTrendBear = ema9 < ema9[1] and ema9[1] < ema9[2]

emaStackBull = ema9 > ema21
emaStackBear = ema9 < ema21

//==============================
// CVD / DELTA PROXY
//==============================
signValue(x) =>
    x > 0 ? 1.0 : x < 0 ? -1.0 : 0.0

deltaBarRaw = volume * signValue(close - open)
deltaBarSmooth = ta.ema(deltaBarRaw, deltaLookback)

var float cvd = 0.0

if newDay
    cvd := deltaBarRaw
else
    cvd += deltaBarRaw

cvdRising = cvd > cvd[1]
cvdFalling = cvd < cvd[1]

//==============================
// DTE MODE
//==============================
resolvedDTE = contractMode == "0DTE" ? 0 : contractMode == "1DTE" ? 1 : contractMode == "2-7DTE Weekly" ? 7 : contractMode == "8-14DTE" ? 14 : contractMode == "15-21DTE" ? 21 : contractMode == "22-28DTE" ? 28 : customDTE
dteBucket = resolvedDTE == 0 ? "0DTE" : resolvedDTE == 1 ? "1DTE" : resolvedDTE <= 7 ? "2-7DTE" : resolvedDTE <= 14 ? "8-14DTE" : resolvedDTE <= 21 ? "15-21DTE" : "22-28DTE"

//==============================
// GUARDRAILS
//==============================
maxDistanceFromEMA = resolvedDTE == 0 ? zeroDTE_MaxDistanceFromEMA : resolvedDTE == 1 ? oneDTE_MaxDistanceFromEMA : resolvedDTE <= 7 ? weeklyDTE_MaxDistanceFromEMA : resolvedDTE <= 14 ? twoWeekDTE_MaxDistanceFromEMA : resolvedDTE <= 21 ? threeWeekDTE_MaxDistanceFromEMA : fourWeekDTE_MaxDistanceFromEMA
minDistanceFromVWAP = resolvedDTE == 0 ? zeroDTE_MinDistanceFromVWAP : resolvedDTE == 1 ? oneDTE_MinDistanceFromVWAP : resolvedDTE <= 7 ? weeklyDTE_MinDistanceFromVWAP : resolvedDTE <= 14 ? twoWeekDTE_MinDistanceFromVWAP : resolvedDTE <= 21 ? threeWeekDTE_MinDistanceFromVWAP : fourWeekDTE_MinDistanceFromVWAP

distanceFromEMA9Pct = math.abs(close - ema9) / close * 100
distanceFromVWAPPct = math.abs(close - vwapValue) / close * 100

notExtended = not useExtendedFilter or distanceFromEMA9Pct <= maxDistanceFromEMA
notChoppy = not useChopFilter or distanceFromVWAPPct >= minDistanceFromVWAP

//==============================
// BREAKOUTS
//==============================
longBreak = orbLocked and not na(orbHigh) and ta.crossover(close, orbHigh)
shortBreak = orbLocked and not na(orbLow) and ta.crossunder(close, orbLow)

//==============================
// BASE FILTERS
//==============================
longTrendOK = not useTrendFilter or (emaTrendBull and emaStackBull)
shortTrendOK = not useTrendFilter or (emaTrendBear and emaStackBear)

longBaseOK = aboveVWAP and aboveEMA9 and longTrendOK and notExtended and notChoppy
shortBaseOK = belowVWAP and belowEMA9 and shortTrendOK and notExtended and notChoppy

//==============================
// ARM STATE
//==============================
var bool longArmed = false
var bool shortArmed = false

if newDay
    longArmed := false
    shortArmed := false

if longBreak and longBaseOK
    longArmed := true
    shortArmed := false

if shortBreak and shortBaseOK
    shortArmed := true
    longArmed := false

//==============================
// RETEST + REJECTION
//==============================
longORBRetest = orbLocked and longArmed and not na(orbHigh) and low <= orbHigh and close > orbHigh
shortORBRetest = orbLocked and shortArmed and not na(orbLow) and high >= orbLow and close < orbLow

longPullbackReject = low <= ema9 and close > ema9 and close > open
shortPullbackReject = high >= ema9 and close < ema9 and close < open

longRetestOK = requireRetest ? longORBRetest : longBreak
shortRetestOK = requireRetest ? shortORBRetest : shortBreak

longRejectOK = requirePullbackReject ? longPullbackReject : true
shortRejectOK = requirePullbackReject ? shortPullbackReject : true

//==============================
// SIGNAL SCORE
//==============================
longScore = 0
longScore += aboveVWAP ? 1 : 0
longScore += aboveEMA9 ? 1 : 0
longScore += emaTrendBull ? 1 : 0
longScore += emaStackBull ? 1 : 0
longScore += longRetestOK ? 1 : 0
longScore += longRejectOK ? 1 : 0
longScore += biasRsi > 55 ? 1 : 0
longScore += entryRsi > 55 ? 1 : 0
longScore += cvdRising ? 1 : 0
longScore += notExtended ? 1 : 0

shortScore = 0
shortScore += belowVWAP ? 1 : 0
shortScore += belowEMA9 ? 1 : 0
shortScore += emaTrendBear ? 1 : 0
shortScore += emaStackBear ? 1 : 0
shortScore += shortRetestOK ? 1 : 0
shortScore += shortRejectOK ? 1 : 0
shortScore += biasRsi < 45 ? 1 : 0
shortScore += entryRsi < 45 ? 1 : 0
shortScore += cvdFalling ? 1 : 0
shortScore += notExtended ? 1 : 0

activeScore = longScore > shortScore ? longScore : shortScore
confidence = activeScore * 10

grade = activeScore >= 10 ? "A+" : activeScore == 9 ? "A" : activeScore == 8 ? "B+" : activeScore == 7 ? "B" : activeScore == 6 ? "C" : "NO TRADE"

stars = activeScore >= 10 ? "★★★★★★★★★★" : activeScore == 9 ? "★★★★★★★★★☆" : activeScore == 8 ? "★★★★★★★★☆☆" : activeScore == 7 ? "★★★★★★★☆☆☆" : activeScore == 6 ? "★★★★★★☆☆☆☆" : activeScore == 5 ? "★★★★★☆☆☆☆☆" : activeScore == 4 ? "★★★★☆☆☆☆☆☆" : activeScore == 3 ? "★★★☆☆☆☆☆☆☆" : activeScore == 2 ? "★★☆☆☆☆☆☆☆☆" : activeScore == 1 ? "★☆☆☆☆☆☆☆☆☆" : "☆☆☆☆☆☆☆☆☆☆"

//==============================
// FINAL SIGNALS
//==============================
rawLongSignal = longRetestOK and longRejectOK and longBaseOK and longScore >= minSignalScore
rawShortSignal = shortRetestOK and shortRejectOK and shortBaseOK and shortScore >= minSignalScore

var bool longTriggeredToday = false
var bool shortTriggeredToday = false

if newDay
    longTriggeredToday := false
    shortTriggeredToday := false

finalLong = rawLongSignal and (not oneSignalPerSide or not longTriggeredToday)
finalShort = rawShortSignal and (not oneSignalPerSide or not shortTriggeredToday)

if finalLong
    longTriggeredToday := true
    longArmed := false

if finalShort
    shortTriggeredToday := true
    shortArmed := false

//==============================
// POSITION STATE
//==============================
var int tradeState = 0

if newDay
    tradeState := 0

if finalLong
    tradeState := 1

if finalShort
    tradeState := -1

//==============================
// TP LEVEL STATE
//==============================
var float activeEntry = na
var float activeTP1 = na
var float activeTP2 = na
var float activeTP3 = na
var int tpDirection = 0
var int tpEntryBar = na
var bool tp1Hit = false
var bool tp2Hit = false
var bool tp3Hit = false

if newDay
    activeEntry := na
    activeTP1 := na
    activeTP2 := na
    activeTP3 := na
    tpDirection := 0
    tpEntryBar := na
    tp1Hit := false
    tp2Hit := false
    tp3Hit := false

orbRange = not na(orbHigh) and not na(orbLow) ? math.abs(orbHigh - orbLow) : tpAtr
tpUnit = tpMethod == "ATR" ? tpAtr * tpAtrMultiplier : orbRange
tpUnit := math.max(tpUnit, syminfo.mintick)

if finalLong
    activeEntry := close
    activeTP1 := close + tpUnit * tp1Multiple
    activeTP2 := close + tpUnit * tp2Multiple
    activeTP3 := close + tpUnit * tp3Multiple
    tpDirection := 1
    tpEntryBar := bar_index
    tp1Hit := false
    tp2Hit := false
    tp3Hit := false

if finalShort
    activeEntry := close
    activeTP1 := close - tpUnit * tp1Multiple
    activeTP2 := close - tpUnit * tp2Multiple
    activeTP3 := close - tpUnit * tp3Multiple
    tpDirection := -1
    tpEntryBar := bar_index
    tp1Hit := false
    tp2Hit := false
    tp3Hit := false

tpLevelsActive = showTakeProfitLevels and not na(activeEntry) and (keepTPLevelsAfterExit or tradeState != 0)

tp1HitNow = tpLevelsActive and not tp1Hit and bar_index > tpEntryBar and ((tpDirection == 1 and high >= activeTP1) or (tpDirection == -1 and low <= activeTP1))
tp2HitNow = tpLevelsActive and not tp2Hit and bar_index > tpEntryBar and ((tpDirection == 1 and high >= activeTP2) or (tpDirection == -1 and low <= activeTP2))
tp3HitNow = tpLevelsActive and not tp3Hit and bar_index > tpEntryBar and ((tpDirection == 1 and high >= activeTP3) or (tpDirection == -1 and low <= activeTP3))

if tp1HitNow
    tp1Hit := true
    if showTPHitLabels
        label.new(bar_index, activeTP1, "TP1", style=label.style_label_left, color=color.lime, textcolor=color.black)

if tp2HitNow
    tp2Hit := true
    if showTPHitLabels
        label.new(bar_index, activeTP2, "TP2", style=label.style_label_left, color=color.green, textcolor=color.white)

if tp3HitNow
    tp3Hit := true
    if showTPHitLabels
        label.new(bar_index, activeTP3, "TP3", style=label.style_label_left, color=color.teal, textcolor=color.white)

//==============================
// EXIT WARNINGS
//==============================
longExitWarning = tradeState == 1 and ((exitOnEMA9Cross and close < ema9) or (exitOnVWAPCross and close < vwapValue))
shortExitWarning = tradeState == -1 and ((exitOnEMA9Cross and close > ema9) or (exitOnVWAPCross and close > vwapValue))

if longExitWarning or shortExitWarning
    tradeState := 0

//==============================
// MARKET STATE
//==============================
trendState = (emaTrendBull and emaStackBull and aboveVWAP) or (emaTrendBear and emaStackBear and belowVWAP)
squeezeState = distanceFromEMA9Pct < 0.05 and distanceFromVWAPPct < 0.05
marketState = squeezeState ? "SQUEEZE" : not notChoppy ? "CHOP" : trendState ? "TREND" : "RANGE"

//==============================
// TRADE STATUS
//==============================
tradeStatus = finalLong ? "BUY CALL" : finalShort ? "BUY PUT" : longExitWarning or shortExitWarning ? "EXIT" : tradeState == 1 ? "MANAGE CALL" : tradeState == -1 ? "MANAGE PUT" : longArmed ? "CALL READY" : shortArmed ? "PUT READY" : "WAIT"

//==============================
// PLOTS
//==============================
plot(showORB and orbLocked ? orbHigh : na, "ORB High", color=color.lime, linewidth=2, style=plot.style_linebr)
plot(showORB and orbLocked ? orbLow : na, "ORB Low", color=color.red, linewidth=2, style=plot.style_linebr)

plot(showVWAP ? vwapValue : na, "VWAP", color=color.orange, linewidth=2)
plot(showEMA9 ? ema9 : na, "9 EMA", color=color.blue, linewidth=2)
plot(showEMA21 ? ema21 : na, "21 EMA", color=color.purple, linewidth=1)

plotshape(showSignals and finalLong, title="BUY CALL", style=shape.labelup, location=location.belowbar, color=color.lime, text="BUY CALL", textcolor=color.black, size=size.small)
plotshape(showSignals and finalShort, title="BUY PUT", style=shape.labeldown, location=location.abovebar, color=color.red, text="BUY PUT", textcolor=color.white, size=size.small)

plotshape(longExitWarning, title="CALL EXIT", style=shape.labeldown, location=location.abovebar, color=color.orange, text="EXIT", textcolor=color.black, size=size.tiny)
plotshape(shortExitWarning, title="PUT EXIT", style=shape.labelup, location=location.belowbar, color=color.orange, text="EXIT", textcolor=color.black, size=size.tiny)

plot(tpLevelsActive ? activeEntry : na, "Entry Level", color=color.white, linewidth=1, style=plot.style_linebr)
plot(tpLevelsActive ? activeTP1 : na, "TP1", color=color.lime, linewidth=1, style=plot.style_linebr)
plot(tpLevelsActive ? activeTP2 : na, "TP2", color=color.green, linewidth=1, style=plot.style_linebr)
plot(tpLevelsActive ? activeTP3 : na, "TP3", color=color.teal, linewidth=2, style=plot.style_linebr)

//==============================
// COMMAND CENTER TABLE
//==============================
var table dash = table.new(position.top_right, 2, 20, border_width=1)

formatPrice(x) =>
    na(x) ? "n/a" : str.tostring(x, format.mintick)

if barstate.islast and showMenu
    table.cell(dash, 0, 0, "DaXtreme SPY V2", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 0, syminfo.ticker, text_color=color.yellow, bgcolor=color.black)

    table.cell(dash, 0, 1, "Signal Score", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 1, str.tostring(activeScore) + "/10", text_color=activeScore >= 8 ? color.lime : activeScore >= 7 ? color.yellow : color.red)

    table.cell(dash, 0, 2, "Stars", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 2, stars, text_color=activeScore >= 8 ? color.lime : activeScore >= 7 ? color.yellow : color.red)

    table.cell(dash, 0, 3, "Grade", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 3, grade, text_color=activeScore >= 8 ? color.lime : activeScore >= 7 ? color.yellow : color.red)

    table.cell(dash, 0, 4, "Status", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 4, tradeStatus, text_color=finalLong or tradeState == 1 ? color.lime : finalShort or tradeState == -1 ? color.red : color.yellow)

    table.cell(dash, 0, 5, "ORB H", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 5, na(orbHigh) ? "n/a" : str.tostring(orbHigh, format.mintick), text_color=color.lime)

    table.cell(dash, 0, 6, "ORB L", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 6, na(orbLow) ? "n/a" : str.tostring(orbLow, format.mintick), text_color=color.red)

    table.cell(dash, 0, 7, "VWAP", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 7, aboveVWAP ? "Above" : belowVWAP ? "Below" : "At", text_color=aboveVWAP ? color.lime : belowVWAP ? color.red : color.yellow)

    table.cell(dash, 0, 8, "9 EMA Trend", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 8, emaTrendBull ? "Bullish" : emaTrendBear ? "Bearish" : "Flat", text_color=emaTrendBull ? color.lime : emaTrendBear ? color.red : color.yellow)

    table.cell(dash, 0, 9, "5m RSI", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 9, str.tostring(biasRsi, "#.0"), text_color=biasRsi > 55 ? color.lime : biasRsi < 45 ? color.red : color.yellow)

    table.cell(dash, 0, 10, "Entry RSI", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 10, str.tostring(entryRsi, "#.0"), text_color=entryRsi > 55 ? color.lime : entryRsi < 45 ? color.red : color.yellow)

    table.cell(dash, 0, 11, "CVD", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 11, cvdRising ? "Rising " + str.tostring(cvd, "#") : cvdFalling ? "Falling " + str.tostring(cvd, "#") : "Flat", text_color=cvdRising ? color.lime : cvdFalling ? color.red : color.yellow)

    table.cell(dash, 0, 12, "Confidence", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 12, str.tostring(confidence) + "%", text_color=confidence >= 80 ? color.lime : confidence >= 70 ? color.yellow : color.red)

    table.cell(dash, 0, 13, "Market State", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 13, marketState, text_color=marketState == "TREND" ? color.lime : marketState == "CHOP" ? color.red : color.yellow)

    table.cell(dash, 0, 14, "Contract Mode", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 14, contractMode, text_color=color.aqua)

    table.cell(dash, 0, 15, "DTE Bucket", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 15, dteBucket, text_color=color.aqua)

    table.cell(dash, 0, 16, "ORB Status", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 16, orbLocked ? "Locked" : "Building", text_color=orbLocked ? color.lime : color.orange)

    table.cell(dash, 0, 17, "Entry", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 17, formatPrice(activeEntry), text_color=color.white)

    table.cell(dash, 0, 18, "TP1 / TP2", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 18, formatPrice(activeTP1) + " / " + formatPrice(activeTP2), text_color=color.lime)

    table.cell(dash, 0, 19, "TP3", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 19, formatPrice(activeTP3), text_color=color.teal)

//==============================
// ALERTS
//==============================
alertcondition(finalLong, title="BUY CALL", message="BUY CALL: SPY ORB Command Center V2 signal")
alertcondition(finalShort, title="BUY PUT", message="BUY PUT: SPY ORB Command Center V2 signal")
alertcondition(longExitWarning, title="CALL EXIT WARNING", message="CALL EXIT: Price lost 9 EMA or VWAP")
alertcondition(shortExitWarning, title="PUT EXIT WARNING", message="PUT EXIT: Price reclaimed 9 EMA or VWAP")

alertcondition(tp1HitNow, title="TP1 HIT", message="TP1 hit: DaXtreme SPY Command Center V2")
alertcondition(tp2HitNow, title="TP2 HIT", message="TP2 hit: DaXtreme SPY Command Center V2")
alertcondition(tp3HitNow, title="TP3 HIT", message="TP3 hit: DaXtreme SPY Command Center V2")
````
