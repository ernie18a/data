# Dual-Session ORB (NY + Asia)

- url: https://www.tradingview.com/script/3eijDrco-Dual-Session-ORB-NY-Asia/
- type: indicator
- pine_id: PUB;9a4c53aea03145fc8eb58ddb7f9c2f35
- version: 1.0

## Description

•	Dual session tracking — NY and Asia ranges build and trigger independently, so you can monitor both without switching charts
	•	Entry Mode: choose Immediate Breakout (enter as soon as price closes beyond the range) or Retest Entry (wait for a pullback and reclaim before entering, filtering out weak breaks)
	•	Minimum Breakout Distance filter — require a meaningful move past the level (in points or % of range) before a signal counts, reducing noise from marginal pokes
	•	Stop Loss Mode: Opposite Range Side, ATR-based (with a configurable minimum floor so stops don’t shrink below a usable size), or flat Fixed Points
	•	Take Profit Mode: Risk:Reward multiple (auto-scales with your stop) or flat Fixed Points
	•	Break-even + partial signal — automatically moves your stop to entry once price reaches your chosen R-multiple, with a visual marker
	•	Time-based exit — auto-closes a trade after a set number of bars if neither TP nor SL is hit
	•	Bar-close confirmation — signals only lock in once a candle fully closes, preventing repainting on live/forming candles
	•	Built-in alerts for entries and break-even triggers on both sessions

Notes on use:
This script is a trade-management and visualization tool, not a signal-generation guarantee. Opening range breakout strategies are sensitive to instrument volatility, session liquidity, and market conditions — always backtest across a meaningful sample size and forward-test (paper trading) before using with real capital. Stop/target sizing should be tuned to the specific instrument and timeframe you’re trading; defaults are a starting point, not a recommendation.

This is not financial advice. Past performance in backtesting or replay does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("Dual-Session ORB (NY + Asia)", overlay=true, max_lines_count=500, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════════
// SESSION 1 : NY OPEN
// ═══════════════════════════════════════════════════════════════════
sessionInput         = input.session("0930-0945", "NY Session (opening range)", tooltip="Format: HHMM-HHMM", group="Session 1 - NY")
tzInput              = input.string("America/New_York", "NY Session Timezone", group="Session 1 - NY")
orHighColor          = input.color(color.lime, "NY OR High Color", group="Session 1 - NY")
orLowColor           = input.color(color.red, "NY OR Low Color", group="Session 1 - NY")
orFillColor          = input.color(color.gray, "NY OR Fill Color", group="Session 1 - NY")

// ═══════════════════════════════════════════════════════════════════
// SESSION 2 : ASIA (TOKYO OPEN, default)
// ═══════════════════════════════════════════════════════════════════
enableSession2       = input.bool(true, "Enable Session 2 (Asia)", group="Session 2 - Asia")
session2Input        = input.session("1800-1815", "Asia Session (opening range)", tooltip="Default = 18:00 ET Asia open. Format: HHMM-HHMM", group="Session 2 - Asia")
tz2Input             = input.string("America/New_York", "Asia Session Timezone", group="Session 2 - Asia")
or2HighColor         = input.color(color.aqua, "Asia OR High Color", group="Session 2 - Asia")
or2LowColor          = input.color(color.orange, "Asia OR Low Color", group="Session 2 - Asia")
or2FillColor         = input.color(color.blue, "Asia OR Fill Color", group="Session 2 - Asia")

// ═══════════════════════════════════════════════════════════════════
// SHARED SETTINGS (apply identically to both sessions)
// ═══════════════════════════════════════════════════════════════════
extendLines          = input.bool(true, "Extend OR High/Low Lines Through Session", group="Shared Settings")
cutoffMinutes        = input.int(120, "Signal Validity Window (minutes after each session ends)", minval=1, tooltip="Breakout entries are only allowed within this many minutes after each session's opening range closes.", group="Shared Settings")
fillTransparency     = input.int(92, "OR Range Fill Transparency", minval=0, maxval=100, group="Shared Settings")

showBreakoutSignals  = input.bool(true, "Show Breakout Signals", group="Breakout Filter")
onlyFirstBreak       = input.bool(true, "Only Take First Breakout per Session", group="Breakout Filter")
minBreakoutMode      = input.string("None", "Minimum Breakout Distance", options=["None", "Points", "Percent of Range"], group="Breakout Filter")
minBreakoutPoints    = input.float(5.0, "  Min Distance (points)", minval=0.0, step=0.5, group="Breakout Filter")
minBreakoutPercent   = input.float(10.0, "  Min Distance (% of OR range)", minval=0.0, step=1.0, group="Breakout Filter")
requireConfirmedBar  = input.bool(true, "Only Confirm Signals on Bar Close", tooltip="Recommended for live trading. Prevents the signal from flashing on/off or moving before the bar actually closes. Lag equals your chart timeframe - use a lower chart timeframe (e.g. 1m) if you want faster confirmed signals.", group="Breakout Filter")

entryMode            = input.string("Immediate Breakout", "Entry Mode", options=["Immediate Breakout", "Retest Entry"], group="Entry Mode")

showTradeLevels      = input.bool(true, "Show Entry / SL / TP Lines", group="Trade Levels")
slMode               = input.string("Fixed Points", "Stop Loss Mode", options=["Opposite Range Side", "ATR-based", "Fixed Points"], group="Trade Levels")
slBufferPoints       = input.float(0.0, "  SL Buffer (points, Opposite Range mode)", minval=0.0, step=0.25, group="Trade Levels")
atrLength            = input.int(14, "  ATR Length (ATR-based mode)", minval=1, group="Trade Levels")
atrTimeframe         = input.timeframe("5", "  ATR Timeframe (ATR-based mode)", tooltip="Calculates ATR from this timeframe regardless of your chart timeframe.", group="Trade Levels")
atrMultiplier        = input.float(1.5, "  ATR Multiplier (ATR-based mode)", minval=0.1, step=0.1, group="Trade Levels")
minStopPoints        = input.float(15.0, "  Minimum Stop Distance (points floor, ATR-based mode)", minval=0.0, step=0.5, group="Trade Levels")
slFixedPoints        = input.float(10.0, "  SL Fixed Points (Fixed Points mode)", minval=0.5, step=0.5, group="Trade Levels")
tpMode               = input.string("Risk:Reward", "Take Profit Mode", options=["Risk:Reward", "Fixed Points"], group="Trade Levels")
riskReward           = input.float(2.0, "  TP Risk:Reward Multiple (Risk:Reward mode)", minval=0.1, step=0.1, group="Trade Levels")
fixedTPPoints        = input.float(12.0, "  TP Fixed Points (Fixed Points mode)", minval=0.5, step=0.5, group="Trade Levels")
maxBarsInTrade       = input.int(12, "Max Bars in Trade (time exit)", minval=1, group="Trade Levels")
entryColor           = input.color(color.blue, "Entry Line Color", group="Trade Levels")
slColor              = input.color(color.red, "Stop Loss Line Color", group="Trade Levels")
tpColor              = input.color(color.green, "Take Profit Line Color", group="Trade Levels")
timeExitColor        = input.color(color.orange, "Time Exit Marker Color", group="Trade Levels")
autoHideLabelBars    = input.int(5, "Auto-hide Exit Label After (bars)", minval=1, group="Trade Levels")

showBEPartial        = input.bool(true, "Show Move-to-BE / Take Partial Signal", group="Break-Even & Partial")
beTriggerRR          = input.float(1.0, "Trigger at This Multiple of Risk (R)", minval=0.1, step=0.1, group="Break-Even & Partial")
bePartialColor       = input.color(color.purple, "BE / Partial Marker Color", group="Break-Even & Partial")

atrValue = request.security(syminfo.tickerid, atrTimeframe, ta.atr(atrLength), lookahead=barmerge.lookahead_off)

// ═══════════════════════════════════════════════════════════════════
// STATE : SESSION 1 (NY)
// ═══════════════════════════════════════════════════════════════════
var float orHigh              = na
var float orLow               = na
var bool  orLocked            = false
var bool  brokeUp             = false
var bool  brokeDown           = false
var int   sessionEndTimeMs    = na
var bool  awaitingRetestLong  = false
var bool  awaitingRetestShort = false
var bool  retestTouchedLong   = false
var bool  retestTouchedShort  = false
var float retestLevelLong     = na
var float retestLevelShort    = na

var line  entryLine   = na
var line  slLine      = na
var line  tpLine      = na
var label entryLabel  = na
var label slLabel     = na
var label tpLabel     = na
var label exitLabel   = na
var label bePartialLabel = na
var int   exitLabelBar    = na

var bool  tradeActive        = false
var int   tradeDirection     = na
var int   tradeEntryBar      = na
var float tradeEntryPrice    = na
var float tradeSL            = na
var float tradeTP            = na
var float tradeRisk          = na
var bool  bePartialTriggered = false

// ═══════════════════════════════════════════════════════════════════
// STATE : SESSION 2 (ASIA)
// ═══════════════════════════════════════════════════════════════════
var float or2High              = na
var float or2Low               = na
var bool  or2Locked            = false
var bool  brokeUp2             = false
var bool  brokeDown2           = false
var int   sessionEndTimeMs2    = na
var bool  awaitingRetestLong2  = false
var bool  awaitingRetestShort2 = false
var bool  retestTouchedLong2   = false
var bool  retestTouchedShort2  = false
var float retestLevelLong2     = na
var float retestLevelShort2    = na

var line  entryLine2   = na
var line  slLine2      = na
var line  tpLine2      = na
var label entryLabel2  = na
var label slLabel2     = na
var label tpLabel2     = na
var label exitLabel2   = na
var label bePartialLabel2 = na
var int   exitLabelBar2    = na

var bool  tradeActive2        = false
var int   tradeDirection2     = na
var int   tradeEntryBar2      = na
var float tradeEntryPrice2    = na
var float tradeSL2            = na
var float tradeTP2            = na
var float tradeRisk2          = na
var bool  bePartialTriggered2 = false

// ───────────────────────────── Helper functions ─────────────────────────────
deleteTradeLevels() =>
    if not na(entryLine)
        line.delete(entryLine)
    if not na(slLine)
        line.delete(slLine)
    if not na(tpLine)
        line.delete(tpLine)
    if not na(entryLabel)
        label.delete(entryLabel)
    if not na(slLabel)
        label.delete(slLabel)
    if not na(tpLabel)
        label.delete(tpLabel)
    if not na(exitLabel)
        label.delete(exitLabel)
    if not na(bePartialLabel)
        label.delete(bePartialLabel)

deleteTradeLevels2() =>
    if not na(entryLine2)
        line.delete(entryLine2)
    if not na(slLine2)
        line.delete(slLine2)
    if not na(tpLine2)
        line.delete(tpLine2)
    if not na(entryLabel2)
        label.delete(entryLabel2)
    if not na(slLabel2)
        label.delete(slLabel2)
    if not na(tpLabel2)
        label.delete(tpLabel2)
    if not na(exitLabel2)
        label.delete(exitLabel2)
    if not na(bePartialLabel2)
        label.delete(bePartialLabel2)

// ═══════════════════════════════════════════════════════════════════
// SESSION 1 (NY) LOGIC
// ═══════════════════════════════════════════════════════════════════
inSession     = not na(time(timeframe.period, sessionInput, tzInput))
isNewSession  = inSession and not inSession[1]
isSessionEnd  = not inSession and inSession[1]

if isNewSession
    orHigh              := high
    orLow               := low
    orLocked            := false
    brokeUp             := false
    brokeDown           := false
    awaitingRetestLong  := false
    awaitingRetestShort := false
    retestTouchedLong   := false
    retestTouchedShort  := false
    tradeActive         := false
    bePartialTriggered  := false
    sessionEndTimeMs    := na
    deleteTradeLevels()
    exitLabelBar        := na

if inSession
    orHigh := math.max(nz(orHigh, high), high)
    orLow  := math.min(nz(orLow, low), low)

if isSessionEnd
    orLocked := true
    sessionEndTimeMs := time

plotCondition = extendLines ? (inSession or orLocked) : inSession
hPlot = plot(plotCondition ? orHigh : na, "NY OR High", orHighColor, 2)
lPlot = plot(plotCondition ? orLow  : na, "NY OR Low",  orLowColor,  2)
fill(hPlot, lPlot, color=color.new(orFillColor, fillTransparency), title="NY OR Range Fill")

orRange = orHigh - orLow
minDistance = minBreakoutMode == "Points" ? minBreakoutPoints : minBreakoutMode == "Percent of Range" ? orRange * minBreakoutPercent / 100.0 : 0.0
withinCutoff = not na(sessionEndTimeMs) and (time - sessionEndTimeMs) <= cutoffMinutes * 60 * 1000

rawLongBreak  = orLocked and withinCutoff and not na(orHigh) and close > orHigh and (close - orHigh) >= minDistance and (not onlyFirstBreak or not brokeUp) and (not requireConfirmedBar or barstate.isconfirmed)
rawShortBreak = orLocked and withinCutoff and not na(orLow)  and close < orLow  and (orLow - close)  >= minDistance and (not onlyFirstBreak or not brokeDown) and (not requireConfirmedBar or barstate.isconfirmed)

if rawLongBreak
    brokeUp := true
if rawShortBreak
    brokeDown := true

var bool longBreak  = false
var bool shortBreak = false
longBreak  := false
shortBreak := false

if entryMode == "Immediate Breakout"
    longBreak  := rawLongBreak and not tradeActive
    shortBreak := rawShortBreak and not tradeActive
else
    if rawLongBreak and not awaitingRetestLong
        awaitingRetestLong := true
        retestTouchedLong  := false
        retestLevelLong    := orHigh
    if rawShortBreak and not awaitingRetestShort
        awaitingRetestShort := true
        retestTouchedShort  := false
        retestLevelShort    := orLow

    if awaitingRetestLong
        if low <= retestLevelLong
            retestTouchedLong := true
        if retestTouchedLong and close > retestLevelLong and not tradeActive and (not requireConfirmedBar or barstate.isconfirmed)
            longBreak          := true
            awaitingRetestLong  := false
            retestTouchedLong   := false

    if awaitingRetestShort
        if high >= retestLevelShort
            retestTouchedShort := true
        if retestTouchedShort and close < retestLevelShort and not tradeActive and (not requireConfirmedBar or barstate.isconfirmed)
            shortBreak            := true
            awaitingRetestShort   := false
            retestTouchedShort    := false

plotshape(showBreakoutSignals and entryMode == "Retest Entry" and rawLongBreak,  "NY Breakout (awaiting retest)", shape.circle, location.belowbar, color.new(color.lime, 40), size=size.tiny)
plotshape(showBreakoutSignals and entryMode == "Retest Entry" and rawShortBreak, "NY Breakout (awaiting retest)", shape.circle, location.abovebar, color.new(color.red, 40),  size=size.tiny)
plotshape(showBreakoutSignals and longBreak,  "NY Bullish Entry", shape.triangleup,   location.belowbar, color.lime, size=size.small)
plotshape(showBreakoutSignals and shortBreak, "NY Bearish Entry", shape.triangledown, location.abovebar, color.red,  size=size.small)

alertcondition(longBreak,  title="NY ORB Bullish Entry", message="NY ORB long entry confirmed")
alertcondition(shortBreak, title="NY ORB Bearish Entry", message="NY ORB short entry confirmed")

if showTradeLevels and (longBreak or shortBreak) and not tradeActive
    deleteTradeLevels()
    exitLabelBar := na

    float entryPrice = close
    float slPrice = na
    if slMode == "ATR-based"
        float atrStopDist = math.max(atrValue * atrMultiplier, minStopPoints)
        slPrice := longBreak ? entryPrice - atrStopDist : entryPrice + atrStopDist
    else if slMode == "Fixed Points"
        slPrice := longBreak ? entryPrice - slFixedPoints : entryPrice + slFixedPoints
    else
        slPrice := longBreak ? orLow - slBufferPoints : orHigh + slBufferPoints

    float riskPts = math.abs(entryPrice - slPrice)
    float tpPrice = na
    if tpMode == "Fixed Points"
        tpPrice := longBreak ? entryPrice + fixedTPPoints : entryPrice - fixedTPPoints
    else
        tpPrice := longBreak ? entryPrice + riskPts * riskReward : entryPrice - riskPts * riskReward

    tradeActive        := true
    tradeDirection      := longBreak ? 1 : -1
    tradeEntryBar       := bar_index
    tradeEntryPrice     := entryPrice
    tradeSL             := slPrice
    tradeTP             := tpPrice
    tradeRisk           := riskPts
    bePartialTriggered  := false

    entryLine := line.new(bar_index, entryPrice, bar_index, entryPrice, extend=extend.right, color=entryColor, width=2, style=line.style_solid)
    slLine    := line.new(bar_index, slPrice,    bar_index, slPrice,    extend=extend.right, color=slColor,    width=2, style=line.style_dashed)
    tpLine    := line.new(bar_index, tpPrice,    bar_index, tpPrice,    extend=extend.right, color=tpColor,    width=2, style=line.style_dashed)

    entryLabel := label.new(bar_index, entryPrice, "NY Entry " + str.tostring(entryPrice, format.mintick), style=label.style_label_left, color=entryColor, textcolor=color.white, size=size.small)
    slLabel    := label.new(bar_index, slPrice,    "SL " + str.tostring(slPrice, format.mintick),       style=label.style_label_left, color=slColor,    textcolor=color.white, size=size.small)
    tpLabel    := label.new(bar_index, tpPrice,    "TP " + str.tostring(tpPrice, format.mintick),       style=label.style_label_left, color=tpColor,    textcolor=color.white, size=size.small)

bePartialFire = false
if showBEPartial and tradeActive and not bePartialTriggered and bar_index > tradeEntryBar
    float favorableMove = tradeDirection == 1 ? high - tradeEntryPrice : tradeEntryPrice - low
    if favorableMove >= tradeRisk * beTriggerRR
        bePartialFire := true
        bePartialTriggered := true
        tradeSL := tradeEntryPrice
        line.set_y1(slLine, tradeEntryPrice)
        line.set_y2(slLine, tradeEntryPrice)
        if not na(slLabel)
            label.delete(slLabel)
        slLabel := label.new(bar_index, tradeEntryPrice, "SL -> BE " + str.tostring(tradeEntryPrice, format.mintick), style=label.style_label_left, color=slColor, textcolor=color.white, size=size.small)
        bePartialLabel := label.new(bar_index, tradeDirection == 1 ? high : low, "Move SL to BE\nTake Partial", style=tradeDirection == 1 ? label.style_label_down : label.style_label_up, color=bePartialColor, textcolor=color.white, size=size.small)

alertcondition(bePartialFire, title="NY ORB Move SL to BE / Take Partial", message="NY trade hit your R multiple")

if tradeActive and bar_index > tradeEntryBar
    bool hitTP = tradeDirection == 1 ? high >= tradeTP : low <= tradeTP
    bool hitSL = tradeDirection == 1 ? low <= tradeSL  : high >= tradeSL
    bool timeUp = (bar_index - tradeEntryBar) >= maxBarsInTrade

    string exitReason = na
    if hitTP and hitSL
        // both levels touched in the same bar - can't know which hit first from OHLC alone.
        // conservative assumption: whichever level is closer to this bar's open was likely hit first.
        float distToTP = math.abs(open - tradeTP)
        float distToSL = math.abs(open - tradeSL)
        exitReason := distToSL <= distToTP ? (bePartialTriggered ? "BE Stop Hit" : "SL Hit") : "TP Hit"
    else if hitTP
        exitReason := "TP Hit"
    else if hitSL
        exitReason := bePartialTriggered ? "BE Stop Hit" : "SL Hit"
    else if timeUp
        exitReason := "Time Exit"

    if not na(exitReason)
        line.set_x2(entryLine, bar_index)
        line.set_extend(entryLine, extend.none)
        line.set_x2(slLine, bar_index)
        line.set_extend(slLine, extend.none)
        line.set_x2(tpLine, bar_index)
        line.set_extend(tpLine, extend.none)

        float exitPrice = exitReason == "TP Hit" ? tradeTP : (exitReason == "SL Hit" or exitReason == "BE Stop Hit") ? tradeSL : close
        color exitColor = exitReason == "Time Exit" ? timeExitColor : (exitReason == "TP Hit" ? tpColor : slColor)
        exitLabel := label.new(bar_index, exitPrice, exitReason, style=label.style_label_left, color=exitColor, textcolor=color.white, size=size.small)
        exitLabelBar := bar_index
        tradeActive := false

if not na(exitLabelBar) and bar_index - exitLabelBar >= autoHideLabelBars
    if not na(exitLabel)
        label.delete(exitLabel)
    exitLabel := na
    exitLabelBar := na

bgcolor(inSession ? color.new(color.blue, 92) : na, title="NY Opening Range Window")

// ═══════════════════════════════════════════════════════════════════
// SESSION 2 (ASIA) LOGIC — mirrors Session 1
// ═══════════════════════════════════════════════════════════════════
inSession2     = enableSession2 and not na(time(timeframe.period, session2Input, tz2Input))
isNewSession2  = inSession2 and not inSession2[1]
isSessionEnd2  = not inSession2 and inSession2[1]

if isNewSession2
    or2High              := high
    or2Low               := low
    or2Locked            := false
    brokeUp2             := false
    brokeDown2            := false
    awaitingRetestLong2  := false
    awaitingRetestShort2 := false
    retestTouchedLong2   := false
    retestTouchedShort2  := false
    tradeActive2         := false
    bePartialTriggered2  := false
    sessionEndTimeMs2    := na
    deleteTradeLevels2()
    exitLabelBar2        := na

if inSession2
    or2High := math.max(nz(or2High, high), high)
    or2Low  := math.min(nz(or2Low, low), low)

if isSessionEnd2
    or2Locked := true
    sessionEndTimeMs2 := time

plotCondition2 = extendLines ? (inSession2 or or2Locked) : inSession2
h2Plot = plot(plotCondition2 ? or2High : na, "Asia OR High", or2HighColor, 2)
l2Plot = plot(plotCondition2 ? or2Low  : na, "Asia OR Low",  or2LowColor,  2)
fill(h2Plot, l2Plot, color=color.new(or2FillColor, fillTransparency), title="Asia OR Range Fill")

or2Range = or2High - or2Low
minDistance2 = minBreakoutMode == "Points" ? minBreakoutPoints : minBreakoutMode == "Percent of Range" ? or2Range * minBreakoutPercent / 100.0 : 0.0
withinCutoff2 = not na(sessionEndTimeMs2) and (time - sessionEndTimeMs2) <= cutoffMinutes * 60 * 1000

rawLongBreak2  = enableSession2 and or2Locked and withinCutoff2 and not na(or2High) and close > or2High and (close - or2High) >= minDistance2 and (not onlyFirstBreak or not brokeUp2) and (not requireConfirmedBar or barstate.isconfirmed)
rawShortBreak2 = enableSession2 and or2Locked and withinCutoff2 and not na(or2Low)  and close < or2Low  and (or2Low - close)  >= minDistance2 and (not onlyFirstBreak or not brokeDown2) and (not requireConfirmedBar or barstate.isconfirmed)

if rawLongBreak2
    brokeUp2 := true
if rawShortBreak2
    brokeDown2 := true

var bool longBreak2  = false
var bool shortBreak2 = false
longBreak2  := false
shortBreak2 := false

if entryMode == "Immediate Breakout"
    longBreak2  := rawLongBreak2 and not tradeActive2
    shortBreak2 := rawShortBreak2 and not tradeActive2
else
    if rawLongBreak2 and not awaitingRetestLong2
        awaitingRetestLong2 := true
        retestTouchedLong2  := false
        retestLevelLong2    := or2High
    if rawShortBreak2 and not awaitingRetestShort2
        awaitingRetestShort2 := true
        retestTouchedShort2  := false
        retestLevelShort2    := or2Low

    if awaitingRetestLong2
        if low <= retestLevelLong2
            retestTouchedLong2 := true
        if retestTouchedLong2 and close > retestLevelLong2 and not tradeActive2 and (not requireConfirmedBar or barstate.isconfirmed)
            longBreak2          := true
            awaitingRetestLong2  := false
            retestTouchedLong2   := false

    if awaitingRetestShort2
        if high >= retestLevelShort2
            retestTouchedShort2 := true
        if retestTouchedShort2 and close < retestLevelShort2 and not tradeActive2 and (not requireConfirmedBar or barstate.isconfirmed)
            shortBreak2            := true
            awaitingRetestShort2   := false
            retestTouchedShort2    := false

plotshape(showBreakoutSignals and entryMode == "Retest Entry" and rawLongBreak2,  "Asia Breakout (awaiting retest)", shape.circle, location.belowbar, color.new(color.aqua, 40), size=size.tiny)
plotshape(showBreakoutSignals and entryMode == "Retest Entry" and rawShortBreak2, "Asia Breakout (awaiting retest)", shape.circle, location.abovebar, color.new(color.orange, 40),  size=size.tiny)
plotshape(showBreakoutSignals and longBreak2,  "Asia Bullish Entry", shape.triangleup,   location.belowbar, color.aqua, size=size.small)
plotshape(showBreakoutSignals and shortBreak2, "Asia Bearish Entry", shape.triangledown, location.abovebar, color.orange, size=size.small)

alertcondition(longBreak2,  title="Asia ORB Bullish Entry", message="Asia ORB long entry confirmed")
alertcondition(shortBreak2, title="Asia ORB Bearish Entry", message="Asia ORB short entry confirmed")

if showTradeLevels and (longBreak2 or shortBreak2) and not tradeActive2
    deleteTradeLevels2()
    exitLabelBar2 := na

    float entryPrice2 = close
    float slPrice2 = na
    if slMode == "ATR-based"
        float atrStopDist2 = math.max(atrValue * atrMultiplier, minStopPoints)
        slPrice2 := longBreak2 ? entryPrice2 - atrStopDist2 : entryPrice2 + atrStopDist2
    else if slMode == "Fixed Points"
        slPrice2 := longBreak2 ? entryPrice2 - slFixedPoints : entryPrice2 + slFixedPoints
    else
        slPrice2 := longBreak2 ? or2Low - slBufferPoints : or2High + slBufferPoints

    float riskPts2 = math.abs(entryPrice2 - slPrice2)
    float tpPrice2 = na
    if tpMode == "Fixed Points"
        tpPrice2 := longBreak2 ? entryPrice2 + fixedTPPoints : entryPrice2 - fixedTPPoints
    else
        tpPrice2 := longBreak2 ? entryPrice2 + riskPts2 * riskReward : entryPrice2 - riskPts2 * riskReward

    tradeActive2        := true
    tradeDirection2      := longBreak2 ? 1 : -1
    tradeEntryBar2       := bar_index
    tradeEntryPrice2     := entryPrice2
    tradeSL2             := slPrice2
    tradeTP2             := tpPrice2
    tradeRisk2           := riskPts2
    bePartialTriggered2  := false

    entryLine2 := line.new(bar_index, entryPrice2, bar_index, entryPrice2, extend=extend.right, color=entryColor, width=2, style=line.style_solid)
    slLine2    := line.new(bar_index, slPrice2,    bar_index, slPrice2,    extend=extend.right, color=slColor,    width=2, style=line.style_dashed)
    tpLine2    := line.new(bar_index, tpPrice2,    bar_index, tpPrice2,    extend=extend.right, color=tpColor,    width=2, style=line.style_dashed)

    entryLabel2 := label.new(bar_index, entryPrice2, "Asia Entry " + str.tostring(entryPrice2, format.mintick), style=label.style_label_left, color=entryColor, textcolor=color.white, size=size.small)
    slLabel2    := label.new(bar_index, slPrice2,    "SL " + str.tostring(slPrice2, format.mintick),       style=label.style_label_left, color=slColor,    textcolor=color.white, size=size.small)
    tpLabel2    := label.new(bar_index, tpPrice2,    "TP " + str.tostring(tpPrice2, format.mintick),       style=label.style_label_left, color=tpColor,    textcolor=color.white, size=size.small)

bePartialFire2 = false
if showBEPartial and tradeActive2 and not bePartialTriggered2 and bar_index > tradeEntryBar2
    float favorableMove2 = tradeDirection2 == 1 ? high - tradeEntryPrice2 : tradeEntryPrice2 - low
    if favorableMove2 >= tradeRisk2 * beTriggerRR
        bePartialFire2 := true
        bePartialTriggered2 := true
        tradeSL2 := tradeEntryPrice2
        line.set_y1(slLine2, tradeEntryPrice2)
        line.set_y2(slLine2, tradeEntryPrice2)
        if not na(slLabel2)
            label.delete(slLabel2)
        slLabel2 := label.new(bar_index, tradeEntryPrice2, "SL -> BE " + str.tostring(tradeEntryPrice2, format.mintick), style=label.style_label_left, color=slColor, textcolor=color.white, size=size.small)
        bePartialLabel2 := label.new(bar_index, tradeDirection2 == 1 ? high : low, "Move SL to BE\nTake Partial", style=tradeDirection2 == 1 ? label.style_label_down : label.style_label_up, color=bePartialColor, textcolor=color.white, size=size.small)

alertcondition(bePartialFire2, title="Asia ORB Move SL to BE / Take Partial", message="Asia trade hit your R multiple")

if tradeActive2 and bar_index > tradeEntryBar2
    bool hitTP2 = tradeDirection2 == 1 ? high >= tradeTP2 : low <= tradeTP2
    bool hitSL2 = tradeDirection2 == 1 ? low <= tradeSL2  : high >= tradeSL2
    bool timeUp2 = (bar_index - tradeEntryBar2) >= maxBarsInTrade

    string exitReason2 = na
    if hitTP2 and hitSL2
        float distToTP2 = math.abs(open - tradeTP2)
        float distToSL2 = math.abs(open - tradeSL2)
        exitReason2 := distToSL2 <= distToTP2 ? (bePartialTriggered2 ? "BE Stop Hit" : "SL Hit") : "TP Hit"
    else if hitTP2
        exitReason2 := "TP Hit"
    else if hitSL2
        exitReason2 := bePartialTriggered2 ? "BE Stop Hit" : "SL Hit"
    else if timeUp2
        exitReason2 := "Time Exit"

    if not na(exitReason2)
        line.set_x2(entryLine2, bar_index)
        line.set_extend(entryLine2, extend.none)
        line.set_x2(slLine2, bar_index)
        line.set_extend(slLine2, extend.none)
        line.set_x2(tpLine2, bar_index)
        line.set_extend(tpLine2, extend.none)

        float exitPrice2 = exitReason2 == "TP Hit" ? tradeTP2 : (exitReason2 == "SL Hit" or exitReason2 == "BE Stop Hit") ? tradeSL2 : close
        color exitColor2 = exitReason2 == "Time Exit" ? timeExitColor : (exitReason2 == "TP Hit" ? tpColor : slColor)
        exitLabel2 := label.new(bar_index, exitPrice2, exitReason2, style=label.style_label_left, color=exitColor2, textcolor=color.white, size=size.small)
        exitLabelBar2 := bar_index
        tradeActive2 := false

if not na(exitLabelBar2) and bar_index - exitLabelBar2 >= autoHideLabelBars
    if not na(exitLabel2)
        label.delete(exitLabel2)
    exitLabel2 := na
    exitLabelBar2 := na

bgcolor(inSession2 ? color.new(color.aqua, 92) : na, title="Asia Opening Range Window")
````
