<!-- tradingview-pine-id: PUB;fd101907560846cfaefc48ff19f0de4d -->
<!-- tradingviewscripts-format: 1 -->
# SageMaster Bullish AI Grid Guardian — Strict v1.4

Source: https://www.tradingview.com/script/Zb5KSjYN-SageMaster-Bullish-AI-Grid-Guardian-strict/

## Description

Under testing. Use paper/demo. 
Match it with Green Light Trend Rider: Confirmation

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0:
// https://mozilla.org/MPL/2.0/

//@version=6
indicator("SageMaster Bullish AI Grid Guardian — Strict v1.4", overlay = true, max_labels_count = 500)

//──────────────────────────────────────────────────────────────────────────────
// STRICT GRID GUARDIAN — GREEN LIGHT TREND RIDER: CONFIRMATION ALIGNED
//
// Intended use:
// • Chart timeframe: 1H
// • Screener: Green Light Trend Rider: Confirmation
// • Higher-timeframe context: 4H
//
// Visible output:
// • START
// • STOP
//
// Normal START and STOP signals: candle close.
// Intrabar crash fail-safe: optional, extreme conditions only.
//──────────────────────────────────────────────────────────────────────────────


//──────────────────────────────────────────────────────────────────────────────
// START ENGINE
//──────────────────────────────────────────────────────────────────────────────
groupStart = "START Engine — Strict Confirmation"

fastEmaLength = input.int(9, "Fast EMA Length", minval = 2, group = groupStart)
slowEmaLength = input.int(21, "Slow EMA Length", minval = 3, group = groupStart)
rsiLength = input.int(14, "RSI Length", minval = 2, group = groupStart)

minimumStartRsi = input.float(45.0, "Minimum START RSI", minval = 1, maxval = 99, step = 0.5, group = groupStart)
maximumStartRsi = input.float(75.0, "Maximum START RSI", minval = 1, maxval = 100, step = 0.5, group = groupStart)

launchLookback = input.int(3, "Momentum START Lookback", minval = 1, group = groupStart)
maxStartRangeATR = input.float(2.30, "Maximum START Candle Range × ATR", minval = 0.5, step = 0.05, group = groupStart)
maxStartBodyATR = input.float(1.35, "Maximum Green START Body × ATR", minval = 0.25, step = 0.05, group = groupStart)
cooldownBars = input.int(5, "Cooldown Bars After STOP", minval = 0, group = groupStart)

useStartVolatilityFilter = input.bool(true, "Use Light ATR% START Filter", group = groupStart)
minimumAtrPercent = input.float(0.003, "Minimum ATR% for START", minval = 0.0001, step = 0.001, group = groupStart)
maximumAtrPercent = input.float(0.080, "Maximum ATR% for START", minval = 0.005, step = 0.005, group = groupStart)


//──────────────────────────────────────────────────────────────────────────────
// CONFIRMATION SCREENER ALIGNMENT
//──────────────────────────────────────────────────────────────────────────────
groupScreener = "Confirmation Screener Alignment"

useFourHourTrendGate = input.bool(true, "Require 4H SMA-200 Bullish Context", group = groupScreener)
higherTimeframe = input.timeframe("240", "Higher Trend Timeframe", group = groupScreener)
sma200Length = input.int(200, "Higher-Timeframe SMA Length", minval = 50, group = groupScreener)

useStartAdxFilter = input.bool(true, "Require 1H ADX Minimum for START", group = groupScreener)
minimumStartAdx = input.float(20.0, "Minimum ADX for START", minval = 1, step = 0.5, group = groupScreener)

useHigherChopFilter = input.bool(true, "Require 4H CHOP Maximum for START", group = groupScreener)
chopLength = input.int(14, "CHOP Length", minval = 2, group = groupScreener)
maximumHigherChop = input.float(65.0, "Maximum 4H CHOP for START", minval = 1, maxval = 100, step = 0.5, group = groupScreener)


//──────────────────────────────────────────────────────────────────────────────
// STRICT STOP ENGINE
//──────────────────────────────────────────────────────────────────────────────
groupStop = "STOP Engine — Strict Protection"

atrLength = input.int(14, "ATR Length", minval = 2, group = groupStop)
supportLookback = input.int(12, "Local Support Lookback", minval = 3, group = groupStop)

useVolumeFilter = input.bool(true, "Use Bearish Volume Confirmation", group = groupStop)
volumeLength = input.int(20, "Average Volume Length", minval = 2, group = groupStop)

riskBodyATR = input.float(1.10, "Risk Score: Bearish Body × ATR", minval = 0.25, step = 0.05, group = groupStop)
riskScoreThreshold = input.int(4, "Confirmed STOP Risk Score", minval = 2, maxval = 12, group = groupStop)
supportBreakBufferATR = input.float(0.15, "Support Break Buffer × ATR", minval = 0.0, step = 0.05, group = groupStop)

profitArmATR = input.float(1.75, "Profit Protection Arms After Gain × ATR", minval = 0.5, step = 0.25, group = groupStop)
profitTrailATR = input.float(1.10, "Profit Giveback Trail × ATR", minval = 0.25, step = 0.05, group = groupStop)

retestToleranceATR = input.float(0.35, "Broken-Support Retest Tolerance × ATR", minval = 0.05, step = 0.05, group = groupStop)
retestRejectBodyATR = input.float(0.25, "Retest Rejection: Bearish Body × ATR", minval = 0.05, step = 0.05, group = groupStop)


//──────────────────────────────────────────────────────────────────────────────
// DIRECTIONAL ADX / BOLLINGER CONTEXT
//──────────────────────────────────────────────────────────────────────────────
groupContext = "Bearish Context — ADX / Bollinger"

useDirectionalAdx = input.bool(true, "Use Directional ADX / DI Confirmation", group = groupContext)
adxLength = input.int(14, "ADX Length", minval = 2, group = groupContext)
adxBearishLevel = input.float(25.0, "Bearish ADX Strength Level", minval = 5, step = 0.5, group = groupContext)

useBearishBollinger = input.bool(true, "Use Lower Bollinger Displacement", group = groupContext)
bbLength = input.int(20, "Bollinger Length", minval = 2, group = groupContext)
bbMultiplier = input.float(2.0, "Bollinger Multiplier", minval = 0.5, step = 0.1, group = groupContext)
lowerBandBufferATR = input.float(0.15, "Lower Band Break Buffer × ATR", minval = 0.0, step = 0.05, group = groupContext)


//──────────────────────────────────────────────────────────────────────────────
// INTRABAR EMERGENCY FAILSAFE
//──────────────────────────────────────────────────────────────────────────────
groupCrash = "Emergency Intrabar Crash Failsafe"

intrabarMode = input.string("Warning Only", "Intrabar Failsafe Mode", options = ["Off", "Warning Only", "Hard Stop"], group = groupCrash)
intrabarShockBodyATR = input.float(2.10, "Emergency: Bearish Body × ATR", minval = 1.0, step = 0.05, group = groupCrash)
intrabarSupportBuffer = input.float(0.15, "Emergency: Support Break Buffer × ATR", minval = 0.0, step = 0.05, group = groupCrash)
intrabarVolumeMultiple = input.float(1.60, "Emergency: Sell Volume × Average", minval = 1.0, step = 0.05, group = groupCrash)


//──────────────────────────────────────────────────────────────────────────────
// JSON / TESTING SETTINGS
//──────────────────────────────────────────────────────────────────────────────
groupJson = "JSON Messenger / Testing"

enableSageMasterCommands = input.bool(false, "Enable SageMaster Commands", group = groupJson)
enableTestSignalLogs = input.bool(true, "Enable Test START / STOP Logs", group = groupJson)
enableQualityReports = input.bool(true, "Enable Delayed QUALITY_REPORT Messages", group = groupJson)

qualityHorizonBars = input.int(24, "Quality Report: Evaluate STOP After Bars", minval = 1, maxval = 500, group = groupJson)
qualityMoveATR = input.float(1.0, "Quality Threshold: Meaningful Move × ATR", minval = 0.25, step = 0.05, group = groupJson)

alertTag = input.string("SageMasterStrictGuardian", "System Tag", group = groupJson)
startEventName = input.string("START_GRID", "SageMaster START Event", group = groupJson)
stopEventName = input.string("STOP_GRID", "SageMaster STOP Event", group = groupJson)
qualityEventName = input.string("QUALITY_REPORT", "Quality Event Name", group = groupJson)


//──────────────────────────────────────────────────────────────────────────────
// HELPER FUNCTIONS
//──────────────────────────────────────────────────────────────────────────────
chopCalc(_length) =>
    sumTr = ta.sma(ta.tr(true), _length) * _length
    priceRange = ta.highest(high, _length) - ta.lowest(low, _length)
    100 * math.log10(sumTr / math.max(priceRange, syminfo.mintick)) / math.log10(_length)

jsonPrice(_value) =>
    na(_value) ? "null" : str.tostring(_value, format.mintick)

jsonDecimal(_value) =>
    na(_value) ? "null" : str.tostring(_value, "#.####")

jsonInteger(_value) =>
    na(_value) ? "null" : str.tostring(_value)


//──────────────────────────────────────────────────────────────────────────────
// CORE CALCULATIONS — 1H EXECUTION
//──────────────────────────────────────────────────────────────────────────────
emaFast = ta.ema(close, fastEmaLength)
emaSlow = ta.ema(close, slowEmaLength)
rsi = ta.rsi(close, rsiLength)
atr = ta.atr(atrLength)
atrPct = atr / close
avgVol = ta.sma(volume, volumeLength)

barRange = math.max(high - low, syminfo.mintick)
bearishBar = close < open
bullishBar = close > open

bearishBodyATR = bearishBar ? (open - close) / atr : 0.0
bullishBodyATR = bullishBar ? (close - open) / atr : 0.0
closeNearLow = (close - low) / barRange <= 0.30

hasVolume = not na(volume) and not na(avgVol)
sellVolumeHigh = hasVolume and bearishBar and volume > avgVol * 1.40

localSupport = ta.lowest(low[1], supportLookback)


//──────────────────────────────────────────────────────────────────────────────
// DIRECTIONAL ADX / DI
//──────────────────────────────────────────────────────────────────────────────
upMove = high - high[1]
downMove = low[1] - low

plusDM = upMove > 0 and upMove > downMove ? upMove : 0.0
minusDM = downMove > 0 and downMove > upMove ? downMove : 0.0

trueRange = math.max(high - low, math.max(math.abs(high - close[1]), math.abs(low - close[1])))
smoothedTR = ta.rma(trueRange, adxLength)

plusDI = 100 * ta.rma(plusDM, adxLength) / math.max(smoothedTR, syminfo.mintick)
minusDI = 100 * ta.rma(minusDM, adxLength) / math.max(smoothedTR, syminfo.mintick)

dx = 100 * math.abs(plusDI - minusDI) / math.max(plusDI + minusDI, syminfo.mintick)
adx = ta.rma(dx, adxLength)

bearishDirectionalPressure = useDirectionalAdx and minusDI > plusDI and adx > adx[1]
strongBearishTrend = useDirectionalAdx and minusDI > plusDI and adx >= adxBearishLevel and adx > adx[1]


//──────────────────────────────────────────────────────────────────────────────
// LOWER BOLLINGER DOWNSIDE CONTEXT
//──────────────────────────────────────────────────────────────────────────────
bbBasis = ta.sma(close, bbLength)
bbDev = bbMultiplier * ta.stdev(close, bbLength)
bbLower = bbBasis - bbDev

bearishLowerBandBreak = useBearishBollinger and close < bbLower - atr * lowerBandBufferATR
bearishBandDisplacement = bearishLowerBandBreak and bearishBar and closeNearLow


//──────────────────────────────────────────────────────────────────────────────
// 4H CONTEXT
//──────────────────────────────────────────────────────────────────────────────
htfClose = request.security(syminfo.tickerid, higherTimeframe, close, lookahead = barmerge.lookahead_off)
htfSma200 = request.security(syminfo.tickerid, higherTimeframe, ta.sma(close, sma200Length), lookahead = barmerge.lookahead_off)
htfSma200Previous = request.security(syminfo.tickerid, higherTimeframe, ta.sma(close, sma200Length)[1], lookahead = barmerge.lookahead_off)
htfChop = request.security(syminfo.tickerid, higherTimeframe, chopCalc(chopLength), lookahead = barmerge.lookahead_off)

higherTrendBullish = not na(htfSma200) and htfClose >= htfSma200 and htfSma200 >= htfSma200Previous
higherChopAcceptable = not na(htfChop) and htfChop <= maximumHigherChop


//──────────────────────────────────────────────────────────────────────────────
// ACTIVE CYCLE STATE
//──────────────────────────────────────────────────────────────────────────────
var bool active = false
var float entryPrice = na
var float entryAtr = na
var float highSinceStart = na
var float lowSinceStart = na
var int entryBar = na
var int lastStopBar = na
var string entryType = ""
var string cycleId = ""

var float brokenSupport = na
var int supportBreakBar = na
var bool retestArmed = false

varip bool intrabarCrashFired = false
varip bool intrabarHardStopFired = false

if barstate.isnew
    intrabarCrashFired := false
    intrabarHardStopFired := false

bool startSignal = false
bool stopSignal = false
string stopReason = ""

float eventEntryPrice = na
float eventExitPrice = na
float eventHighSince = na
float eventLowSince = na
float eventEntryAtr = na
int eventDuration = na
int eventRiskScore = 0
string eventEntryType = ""
string eventCycleId = ""


//──────────────────────────────────────────────────────────────────────────────
// QUALITY REPORT QUEUE
//──────────────────────────────────────────────────────────────────────────────
var pendingStopBars = array.new_int()
var pendingStopTimes = array.new_int()
var pendingEntryPrices = array.new_float()
var pendingStopPrices = array.new_float()
var pendingStopAtrs = array.new_float()
var pendingCycleHighs = array.new_float()
var pendingCycleLows = array.new_float()
var pendingCycleDurations = array.new_int()
var pendingRiskScores = array.new_int()
var pendingPostHighs = array.new_float()
var pendingPostLows = array.new_float()
var pendingReasons = array.new_string()
var pendingEntryTypes = array.new_string()
var pendingCycleIds = array.new_string()


//──────────────────────────────────────────────────────────────────────────────
// STRICT DOWNSIDE-RISK SCORE
//──────────────────────────────────────────────────────────────────────────────
downsideImpulse = bearishBar and bearishBodyATR >= riskBodyATR
fastTrendLost = close < emaFast and emaFast < emaFast[1]
weakMomentum = rsi < 47 and rsi < rsi[1]
bearishSequence = close < close[1] and close[1] < close[2]
supportBrokenNow = not na(localSupport) and close < localSupport - atr * supportBreakBufferATR

int downsideRiskScore = 0
downsideRiskScore += downsideImpulse ? 2 : 0
downsideRiskScore += closeNearLow ? 1 : 0
downsideRiskScore += fastTrendLost ? 1 : 0
downsideRiskScore += weakMomentum ? 1 : 0
downsideRiskScore += supportBrokenNow ? 2 : 0
downsideRiskScore += bearishSequence ? 1 : 0
downsideRiskScore += useVolumeFilter and sellVolumeHigh ? 1 : 0
downsideRiskScore += bearishDirectionalPressure ? 1 : 0
downsideRiskScore += strongBearishTrend ? 1 : 0
downsideRiskScore += bearishLowerBandBreak ? 1 : 0
downsideRiskScore += bearishBandDisplacement ? 1 : 0

confirmedShock = bearishBodyATR >= 1.60 and closeNearLow and (supportBrokenNow or bearishBandDisplacement)


//──────────────────────────────────────────────────────────────────────────────
// INTRABAR CRASH CONDITION
//──────────────────────────────────────────────────────────────────────────────
intrabarSupportBroken = not na(localSupport) and close < localSupport - atr * intrabarSupportBuffer
intrabarSellVolumeHigh = hasVolume and volume > avgVol * intrabarVolumeMultiple

intrabarCrashCondition =
     barstate.isrealtime and
     active and
     intrabarMode != "Off" and
     bearishBar and
     bearishBodyATR >= intrabarShockBodyATR and
     closeNearLow and
     (intrabarSupportBroken or bearishLowerBandBreak) and
     (intrabarSellVolumeHigh or minusDI > plusDI)


//──────────────────────────────────────────────────────────────────────────────
// JSON FUNCTIONS
//──────────────────────────────────────────────────────────────────────────────
makeSignalJson(_messageType, _event, _reason, _entryPrice, _entryType, _riskScore, _cycleId) =>
    payload = "{\"message_type\":\"" + _messageType + "\",\"tag\":\"" + alertTag + "\",\"event\":\"" + _event + "\",\"reason\":\"" + _reason + "\",\"cycle_id\":\"" + _cycleId + "\",\"symbol\":\"" + syminfo.tickerid + "\",\"timeframe\":\"" + timeframe.period + "\",\"bar_time\":" + str.tostring(time) + ",\"price\":" + jsonPrice(close) + ",\"entry_price\":" + jsonPrice(_entryPrice) + ",\"entry_type\":\"" + _entryType + "\",\"atr\":" + jsonPrice(atr) + ",\"rsi\":" + jsonDecimal(rsi) + ",\"adx\":" + jsonDecimal(adx) + ",\"plus_di\":" + jsonDecimal(plusDI) + ",\"minus_di\":" + jsonDecimal(minusDI) + ",\"htf_chop\":" + jsonDecimal(htfChop) + ",\"risk_score\":" + str.tostring(_riskScore) + "}"
    payload

makeQualityJson(_stopTime, _entryPrice, _stopPrice, _stopAtr, _cycleHigh, _cycleLow, _duration, _riskScore, _reason, _entryType, _cycleId, _postHigh, _postLow) =>
    cycleReturnPct = not na(_entryPrice) and _entryPrice != 0 ? ((_stopPrice - _entryPrice) / _entryPrice) * 100 : na
    mfePct = not na(_entryPrice) and _entryPrice != 0 ? ((_cycleHigh - _entryPrice) / _entryPrice) * 100 : na
    maePct = not na(_entryPrice) and _entryPrice != 0 ? ((_cycleLow - _entryPrice) / _entryPrice) * 100 : na
    postStopDropATR = not na(_stopAtr) and _stopAtr > 0 ? (_stopPrice - _postLow) / _stopAtr : na
    postStopReboundATR = not na(_stopAtr) and _stopAtr > 0 ? (_postHigh - _stopPrice) / _stopAtr : na
    verdict = not na(postStopDropATR) and postStopDropATR >= qualityMoveATR ? "GOOD_PROTECTIVE_STOP" : not na(postStopReboundATR) and postStopReboundATR >= qualityMoveATR ? "POSSIBLY_EARLY_STOP" : "MIXED_OR_INCONCLUSIVE"
    payload = "{\"message_type\":\"QUALITY_REPORT\",\"tag\":\"" + alertTag + "\",\"event\":\"" + qualityEventName + "\",\"cycle_id\":\"" + _cycleId + "\",\"symbol\":\"" + syminfo.tickerid + "\",\"timeframe\":\"" + timeframe.period + "\",\"stop_time\":" + str.tostring(_stopTime) + ",\"report_time\":" + str.tostring(time) + ",\"evaluation_bars\":" + str.tostring(qualityHorizonBars) + ",\"stop_reason\":\"" + _reason + "\",\"entry_type\":\"" + _entryType + "\",\"entry_price\":" + jsonPrice(_entryPrice) + ",\"stop_price\":" + jsonPrice(_stopPrice) + ",\"cycle_high\":" + jsonPrice(_cycleHigh) + ",\"cycle_low\":" + jsonPrice(_cycleLow) + ",\"bars_in_cycle\":" + jsonInteger(_duration) + ",\"risk_score_at_stop\":" + str.tostring(_riskScore) + ",\"cycle_return_percent\":" + jsonDecimal(cycleReturnPct) + ",\"mfe_percent\":" + jsonDecimal(mfePct) + ",\"mae_percent\":" + jsonDecimal(maePct) + ",\"post_stop_low\":" + jsonPrice(_postLow) + ",\"post_stop_high\":" + jsonPrice(_postHigh) + ",\"post_stop_drop_atr\":" + jsonDecimal(postStopDropATR) + ",\"post_stop_rebound_atr\":" + jsonDecimal(postStopReboundATR) + ",\"verdict\":\"" + verdict + "\"}"
    payload


//──────────────────────────────────────────────────────────────────────────────
// OPTIONAL INTRABAR CRASH MESSAGE
//──────────────────────────────────────────────────────────────────────────────
if intrabarCrashCondition and not intrabarCrashFired
    intrabarCrashFired := true

    if intrabarMode == "Hard Stop"
        intrabarHardStopFired := true

        if enableSageMasterCommands
            alert(makeSignalJson("COMMAND", stopEventName, "INTRABAR_CRASH_EMERGENCY", entryPrice, entryType, downsideRiskScore, cycleId), alert.freq_all)

        if enableTestSignalLogs
            alert(makeSignalJson("OBSERVATION", "STOP_OBSERVATION", "INTRABAR_CRASH_EMERGENCY", entryPrice, entryType, downsideRiskScore, cycleId), alert.freq_all)

    else if intrabarMode == "Warning Only" and enableTestSignalLogs
        alert(makeSignalJson("OBSERVATION", "CRASH_WARNING", "INTRABAR_CRASH_WARNING", entryPrice, entryType, downsideRiskScore, cycleId), alert.freq_all)


//──────────────────────────────────────────────────────────────────────────────
// ACTIVE GRID — STRICT STOP ENGINE
//──────────────────────────────────────────────────────────────────────────────
if active and barstate.isconfirmed
    highSinceStart := math.max(highSinceStart, high)
    lowSinceStart := math.min(lowSinceStart, low)

    if supportBrokenNow and not retestArmed
        brokenSupport := localSupport
        supportBreakBar := bar_index
        retestArmed := true

    if retestArmed and not na(brokenSupport) and close > brokenSupport + atr * retestToleranceATR
        brokenSupport := na
        supportBreakBar := na
        retestArmed := false

    profitArmed = highSinceStart >= entryPrice + entryAtr * profitArmATR
    profitGiveback = highSinceStart - close >= atr * profitTrailATR
    profitWeakness = bearishBar and (close < emaFast or rsi < 50)
    profitStop = profitArmed and profitGiveback and profitWeakness

    retestReached = retestArmed and not na(brokenSupport) and not na(supportBreakBar) and bar_index > supportBreakBar and high >= brokenSupport - atr * retestToleranceATR
    retestRejected = retestReached and bearishBar and bearishBodyATR >= retestRejectBodyATR and close < brokenSupport and close < emaFast

    if intrabarHardStopFired
        stopSignal := true
        stopReason := "INTRABAR_CRASH_EMERGENCY"
    else if confirmedShock
        stopSignal := true
        stopReason := "DOWNSIDE_SHOCK"
    else if retestRejected
        stopSignal := true
        stopReason := "FAILED_SUPPORT_RETEST"
    else if profitStop
        stopSignal := true
        stopReason := "PROFIT_GIVEBACK"
    else if downsideRiskScore >= riskScoreThreshold
        stopSignal := true
        stopReason := "EARLY_DOWNSIDE_RISK"

    if stopSignal
        eventEntryPrice := entryPrice
        eventExitPrice := close
        eventHighSince := highSinceStart
        eventLowSince := lowSinceStart
        eventEntryAtr := entryAtr
        eventDuration := bar_index - entryBar
        eventRiskScore := downsideRiskScore
        eventEntryType := entryType
        eventCycleId := cycleId

        if enableQualityReports
            array.push(pendingStopBars, bar_index)
            array.push(pendingStopTimes, time)
            array.push(pendingEntryPrices, eventEntryPrice)
            array.push(pendingStopPrices, eventExitPrice)
            array.push(pendingStopAtrs, eventEntryAtr)
            array.push(pendingCycleHighs, eventHighSince)
            array.push(pendingCycleLows, eventLowSince)
            array.push(pendingCycleDurations, eventDuration)
            array.push(pendingRiskScores, eventRiskScore)
            array.push(pendingPostHighs, high)
            array.push(pendingPostLows, low)
            array.push(pendingReasons, stopReason)
            array.push(pendingEntryTypes, eventEntryType)
            array.push(pendingCycleIds, eventCycleId)

        active := false
        lastStopBar := bar_index
        brokenSupport := na
        supportBreakBar := na
        retestArmed := false


//──────────────────────────────────────────────────────────────────────────────
// FLAT — STRICT START ENGINE
//──────────────────────────────────────────────────────────────────────────────
canStart = not active and (na(lastStopBar) or bar_index - lastStopBar > cooldownBars)

trendAcceptable = close >= emaSlow or emaFast >= emaSlow
rsiAcceptable = rsi >= minimumStartRsi and rsi <= maximumStartRsi
volatilityAcceptable = not useStartVolatilityFilter or (atrPct >= minimumAtrPercent and atrPct <= maximumAtrPercent)

htfTrendAcceptable = not useFourHourTrendGate or higherTrendBullish
adxAcceptable = not useStartAdxFilter or adx >= minimumStartAdx
chopAcceptable = not useHigherChopFilter or higherChopAcceptable

notOverextended = barRange <= atr * maxStartRangeATR and bullishBodyATR <= maxStartBodyATR

controlledDipStart = low <= emaFast and close > emaFast and bullishBar
momentumStart = close > ta.highest(high[1], launchLookback) and close > emaFast

entryCrashBlock = bearishBar and bearishBodyATR >= riskBodyATR and closeNearLow

if barstate.isconfirmed and canStart and trendAcceptable and rsiAcceptable and volatilityAcceptable and htfTrendAcceptable and adxAcceptable and chopAcceptable and notOverextended and not entryCrashBlock and (controlledDipStart or momentumStart)
    startSignal := true

    entryType := controlledDipStart ? "CONTROLLED_DIP" : "MOMENTUM_CONTINUATION"
    cycleId := syminfo.tickerid + "_" + timeframe.period + "_" + str.tostring(time)

    eventEntryPrice := close
    eventExitPrice := na
    eventHighSince := high
    eventLowSince := low
    eventEntryAtr := atr
    eventDuration := 0
    eventRiskScore := downsideRiskScore
    eventEntryType := entryType
    eventCycleId := cycleId

    active := true
    entryPrice := close
    entryAtr := atr
    highSinceStart := high
    lowSinceStart := low
    entryBar := bar_index

    brokenSupport := na
    supportBreakBar := na
    retestArmed := false


//──────────────────────────────────────────────────────────────────────────────
// START / STOP JSON ALERTS
//──────────────────────────────────────────────────────────────────────────────
if barstate.isconfirmed
    if startSignal
        if enableSageMasterCommands
            alert(makeSignalJson("COMMAND", startEventName, "ENTRY_TIMING_CONFIRMED", eventEntryPrice, eventEntryType, eventRiskScore, eventCycleId), alert.freq_all)

        if enableTestSignalLogs
            alert(makeSignalJson("OBSERVATION", "START_OBSERVATION", "ENTRY_TIMING_CONFIRMED", eventEntryPrice, eventEntryType, eventRiskScore, eventCycleId), alert.freq_all)

    if stopSignal and not intrabarHardStopFired
        if enableSageMasterCommands
            alert(makeSignalJson("COMMAND", stopEventName, stopReason, eventEntryPrice, eventEntryType, eventRiskScore, eventCycleId), alert.freq_all)

        if enableTestSignalLogs
            alert(makeSignalJson("OBSERVATION", "STOP_OBSERVATION", stopReason, eventEntryPrice, eventEntryType, eventRiskScore, eventCycleId), alert.freq_all)


//──────────────────────────────────────────────────────────────────────────────
// DELAYED QUALITY REPORTS
//──────────────────────────────────────────────────────────────────────────────
if barstate.isconfirmed and enableQualityReports and array.size(pendingStopBars) > 0
    for i = array.size(pendingStopBars) - 1 to 0
        storedPostHigh = array.get(pendingPostHighs, i)
        storedPostLow = array.get(pendingPostLows, i)

        updatedPostHigh = math.max(storedPostHigh, high)
        updatedPostLow = math.min(storedPostLow, low)

        array.set(pendingPostHighs, i, updatedPostHigh)
        array.set(pendingPostLows, i, updatedPostLow)

        storedStopBar = array.get(pendingStopBars, i)
        reportDue = bar_index - storedStopBar >= qualityHorizonBars

        if reportDue
            storedStopTime = array.get(pendingStopTimes, i)
            storedEntryPrice = array.get(pendingEntryPrices, i)
            storedStopPrice = array.get(pendingStopPrices, i)
            storedStopAtr = array.get(pendingStopAtrs, i)
            storedCycleHigh = array.get(pendingCycleHighs, i)
            storedCycleLow = array.get(pendingCycleLows, i)
            storedDuration = array.get(pendingCycleDurations, i)
            storedRiskScore = array.get(pendingRiskScores, i)
            storedReason = array.get(pendingReasons, i)
            storedEntryType = array.get(pendingEntryTypes, i)
            storedCycleId = array.get(pendingCycleIds, i)

            alert(makeQualityJson(storedStopTime, storedEntryPrice, storedStopPrice, storedStopAtr, storedCycleHigh, storedCycleLow, storedDuration, storedRiskScore, storedReason, storedEntryType, storedCycleId, updatedPostHigh, updatedPostLow), alert.freq_all)

            array.remove(pendingStopBars, i)
            array.remove(pendingStopTimes, i)
            array.remove(pendingEntryPrices, i)
            array.remove(pendingStopPrices, i)
            array.remove(pendingStopAtrs, i)
            array.remove(pendingCycleHighs, i)
            array.remove(pendingCycleLows, i)
            array.remove(pendingCycleDurations, i)
            array.remove(pendingRiskScores, i)
            array.remove(pendingPostHighs, i)
            array.remove(pendingPostLows, i)
            array.remove(pendingReasons, i)
            array.remove(pendingEntryTypes, i)
            array.remove(pendingCycleIds, i)


//──────────────────────────────────────────────────────────────────────────────
// VISIBLE OUTPUT — START AND STOP ONLY
//──────────────────────────────────────────────────────────────────────────────
plotshape(startSignal, title = "START", text = "START", style = shape.labelup, location = location.belowbar, color = color.new(color.green, 0), textcolor = color.white, size = size.tiny)

plotshape(stopSignal, title = "STOP", text = "STOP", style = shape.labeldown, location = location.abovebar, color = color.new(color.red, 0), textcolor = color.white, size = size.tiny)

alertcondition(startSignal, title = "Strict AI Grid START", message = "START_GRID")
alertcondition(stopSignal, title = "Strict AI Grid STOP", message = "STOP_GRID")
````
