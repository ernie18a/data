<!-- tradingview-pine-id: PUB;3467cbf6644b429b8a2c8ddf50c041b9 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# 1H → Sweep + Transition + Continuation

Source: https://www.tradingview.com/script/x9vp97dJ-SPY-1H-IND-Sweep-Transition-Continuation/

## Description

This script is specifically calibrated for 3+ DTE swing options, focusing on suppressing institutional noise, false breakouts & gamma-pinning churn around major strike levels.  It compresses dynamic look-backs to a 12d major & 3d  tactical window with a tight 3-bar confirmation window — if SPY fails to reclaim swept liquidity within 3 hours, the engine treats the move as a genuine breakout rather than a sweep trap.  It elevates the volume and conviction requirements to 1.15 RVOL & 0.15 daily ATR displacement, filtering out standard market-on-close imbalance churn.  Additionally, it integrates a CBOE VIX Bollinger Band macro filter as a score modifier (boosting CALL [REV] setups when VIX spikes into extreme upper bands) & enforces tight extension ceilings (1.5 daily ATR for continuation, 1.25 daily ATR for transition) to prevent buying into institutional supply walls.

SPY risk parameters strictly cap initial entry risk at 1.25 daily ATR, instantly discarding setups that require wide stops far from key structure.  The script utilizes a balanced runner engine — trailing activates early at 1.25R with a 1.5 daily ATR trailing distance to protect options delta and combat time decay during multi-day consolidations.  This locks in gains on quick $2+ price moves while giving the underlying contract enough room to navigate normal 1H retests.

Script has a unified 2-stage signal engine and priority routing pipeline

[*]Intra-bar Awareness — generates real-time visual warnings while a 1H bar builds, providing early situational awareness without polluting backtests.
[*]Closed-Bar Execution — enforces requireConfirmedBar = true by default, ensuring all historical trade evaluations, back-test metrics & execution labels rest strictly on closed candles to eliminate repainting.
[*]Pathway Tagging — every trade label explicitly identifies its triggering engine route — [REV] (Reversal Sweep), [TRANS] (Trend Transition), or [CONT] (Trend Continuation), while automatically routing stop calculations to match the corresponding setup’s structural risk.

---

## Source Code

````pine
//@version=6
indicator("1H → Sweep + Transition + Continuation", overlay=true, max_labels_count=500)

// =====================================================
// INPUTS & PARAMETERS (SPY OPTIMIZED)
// =====================================================

// Dynamic Levels Calibration
majorPivotLookback = input.int(12, "Major Daily Liquidity Lookback (Days)", minval=5, group="Dynamic Levels (SPY Defaults)")
tacticalLookback   = input.int(3, "Tactical Daily Liquidity Lookback (Days)", minval=2, group="Dynamic Levels (SPY Defaults)")
confirmWindow      = input.int(3, "Bars Allowed for Confirmation After Sweep", minval=1, maxval=6, group="Dynamic Levels (SPY Defaults)")

pivotLeft           = input.int(2, "Swing Pivot Left Bars", minval=1, maxval=10, group="Structure")
pivotRight          = input.int(2, "Swing Pivot Right Bars", minval=1, maxval=10, group="Structure")
internalLookback    = input.int(3, "Internal Structure Lookback", minval=2, maxval=10, group="Structure")
requireSwingBreak   = input.bool(false, "Require Confirmed Swing MSS/BOS", group="Structure")
allowInternalMSS    = input.bool(true, "Allow Internal MSS as Secondary Confirmation", group="Structure")
useStructureExit    = input.bool(true, "Exit on Opposing Swing Structure Break", group="Structure")
structureExitBuffer = input.float(0.10, "Structure Exit Buffer (x Daily ATR)", step=0.05, minval=0.0, group="Structure")

atrPeriod = input.int(14, "ATR Period for Risk Management", group="RV Expected Range")
rvPeriod  = input.int(20, "Realized Volatility Lookback (Days)", group="RV Expected Range")
swingDays = input.int(5, "RV Range Horizon (Trading Days)", minval=1, maxval=20, group="RV Expected Range")
emMult    = input.float(1.0, "RV Range Standard Deviation (1.0 = 1σ)", step=0.1, group="RV Expected Range")

cooldownBars          = input.int(2, "Bars Cooldown Post-Exit", minval=0, group="Filters")
minSignalScore        = input.int(4, "Minimum Trend-Aligned Signal Score", minval=2, maxval=15, group="Filters")
counterTrendExtra     = input.int(1, "Extra Score Required Countertrend", minval=0, maxval=5, group="Filters")
counterTrendMajorOnly = input.bool(false, "Countertrend Requires Major/Confluent Sweep", group="Filters")

// DEFAULTED TO TRUE: Ensures historical baseline and evaluation stay clean
requireConfirmedBar   = input.bool(true, "Require Confirmed Candle Close", group="Filters")

// SPY Macro Inter-Market Confirmation (VIX)
useVixFilter          = input.bool(true, "Use VIX Macro Modifier (+1 Confluence Score)", group="Macro Confirmation (VIX)")
vixTicker             = input.string("CBOE:VIX", "VIX Symbol", group="Macro Confirmation (VIX)")
vixBbLength           = input.int(20, "VIX Bollinger Length", group="Macro Confirmation (VIX)")

// SPY Displacement / RVOL
useTimeNormalizedRVOL = input.bool(true, "Use Time-of-Day Normalized RVOL (RTH Only)", group="Volume & Displacement (SPY Defaults)")
rvolThreshold         = input.float(1.15, "Strong Relative Volume Threshold", step=0.05, group="Volume & Displacement (SPY Defaults)")
rvolMemorySessions    = input.int(20, "RVOL Slot Memory (Sessions, EMA)", minval=5, maxval=100, group="Volume & Displacement (SPY Defaults)")
displaceAtrMult       = input.float(0.15, "Minimum Displacement Body (x Daily ATR)", step=0.05, group="Volume & Displacement (SPY Defaults)")
minBodyRangeRatio     = input.float(0.50, "Minimum Displacement Body/Range", step=0.05, minval=0.20, maxval=1.0, group="Volume & Displacement (SPY Defaults)")
minCloseLocation      = input.float(0.50, "Close Location Toward Candle Extreme", step=0.05, minval=0.40, maxval=1.0, group="Volume & Displacement (SPY Defaults)")

useHTFTrend   = input.bool(true, "Use Daily 20/50 EMA Trend Alignment", group="HTF Trend")
fastEmaLength = input.int(20, "Daily Fast EMA", group="HTF Trend")
slowEmaLength = input.int(50, "Daily Slow EMA", group="HTF Trend")

// SPY TREND CONTINUATION INPUTS
useTrendContinuation = input.bool(true, "Enable Trend Continuation Entries", group="Trend Continuation (SPY Defaults)")
continuationLookback  = input.int(5, "Continuation Breakout Lookback", minval=2, maxval=20, group="Trend Continuation (SPY Defaults)")
continuationScoreMin  = input.int(4, "Minimum Continuation Score", minval=3, maxval=10, group="Trend Continuation (SPY Defaults)")
maxExtensionATR       = input.float(1.50, "Maximum Extension Above Daily 20 EMA (ATR)", step=0.25, group="Trend Continuation (SPY Defaults)")
continuationStopAtr   = input.float(0.50, "Continuation Stop Below Breakout (x Daily ATR)", step=0.05, minval=0.25, maxval=2.0, group="Trend Continuation (SPY Defaults)")

// SPY TREND TRANSITION INPUTS
useTrendTransition        = input.bool(true, "Enable Trend Transition Entries", group="Trend Transition (SPY Defaults)")
transitionLookback         = input.int(10, "Transition Structure Lookback", minval=5, maxval=30, group="Trend Transition (SPY Defaults)")
transitionScoreMin        = input.int(5, "Minimum Transition Score", minval=3, maxval=10, group="Trend Transition (SPY Defaults)")
transitionStopAtr         = input.float(0.50, "Transition Stop Buffer (x Daily ATR)", step=0.05, minval=0.25, maxval=2.0, group="Trend Transition (SPY Defaults)")
transitionMaxExtensionATR = input.float(1.25, "Maximum Transition Extension (x Daily ATR)", step=0.25, minval=0.5, maxval=4.0, group="Trend Transition (SPY Defaults)")

// SPY RISK MANAGEMENT
stopAtrMult     = input.float(0.25, "Structural Stop Buffer (x Daily ATR)", step=0.05, group="Swing Risk Management (SPY Defaults)")
maxRiskAtr      = input.float(1.25, "Maximum Entry Risk (x Daily ATR)", step=0.05, group="Swing Risk Management (SPY Defaults)")
tpRMult         = input.float(2.5, "Hard Take Profit Target (R Multiple)", step=0.25, group="Swing Risk Management (SPY Defaults)")
useTakeProfit   = input.bool(false, "Enable Hard Take Profit Exit", group="Swing Risk Management (SPY Defaults)")
minHoldSessions = input.int(1, "Minimum Sessions Before Profit Exit", minval=1, maxval=10, group="Swing Risk Management (SPY Defaults)")

// BALANCED SPY 3+ DTE RUNNER MANAGEMENT (MIDDLE CONFIGURATION)
useTrailingStop      = input.bool(true, "Enable Runner Trailing Stop", group="Runner Management (SPY 3+ DTE Balanced)")
trailStartR          = input.float(1.25, "Activate Runner At R (Balanced 1.25R)", step=0.25, minval=0.5, maxval=3.0, group="Runner Management (SPY 3+ DTE Balanced)")
trailAtrMult         = input.float(1.50, "Volatility Trail Distance (Balanced 1.50 ATR)", step=0.25, group="Runner Management (SPY 3+ DTE Balanced)")
useStructuralTrail   = input.bool(true, "Blend Trail With Confirmed Swing Structure", group="Runner Management (SPY 3+ DTE Balanced)")
trailStructureBuffer = input.float(0.20, "Swing Trail Buffer (x Daily ATR)", step=0.05, minval=0.0, group="Runner Management (SPY 3+ DTE Balanced)")

showArmedLabels       = input.bool(true, "Show ARMED Sweep Labels (Intrabar)", group="Visuals")
showStructureLevels   = input.bool(false, "Show Confirmed Swing Structure", group="Visuals")
showSignalScore       = input.bool(true, "Show Score / Setup Class on Entry", group="Visuals")
showContinuationDebug = input.bool(false, "Show Continuation Debug", group="Visuals")
showTransitionDebug   = input.bool(false, "Show Transition Debug", group="Visuals")

bullGreen   = color.new(#089981, 0)
bearRed     = color.new(#F23645, 0)
armedOrange = color.new(#FF9800, 0)
c_exit_tp   = color.new(#2962FF, 0)
c_exit_sl   = color.new(#FF9800, 0)
c_trail     = color.new(#9C27B0, 0)
c_structure = color.new(#2962FF, 0)
c_band_fill = color.new(#E0D0E8, 70)
c_band_line = color.new(#9C27B0, 30)
c_white     = color.white

// =====================================================
// MACRO VIX DATA RETRIEVAL
// =====================================================

vixClose = request.security(vixTicker, timeframe.period, close)
[vixBasis, vixUpper, vixLower] = request.security(vixTicker, timeframe.period, ta.bb(close, vixBbLength, 2.0))

bool vixSpikeExtreme = not na(vixClose) and not na(vixUpper) and vixClose > vixUpper
bool vixCompressing  = not na(vixClose) and not na(vixBasis) and vixClose < vixBasis

// =====================================================
// REPAINT-SAFE HTF DATA
// =====================================================

dailyOpen = request.security(syminfo.tickerid, "D", open, lookahead=barmerge.lookahead_on)
dailyATR  = request.security(syminfo.tickerid, "D", ta.atr(atrPeriod)[1], lookahead=barmerge.lookahead_on)

[dailyFastEMA, dailySlowEMA, dailySlowPrev] = request.security(
    syminfo.tickerid, "D",
    [ta.ema(close, fastEmaLength)[1], ta.ema(close, slowEmaLength)[1], ta.ema(close, slowEmaLength)[2]],
    lookahead=barmerge.lookahead_on
)

bool htfBull = dailyFastEMA > dailySlowEMA and dailySlowEMA > dailySlowPrev
bool htfBear = dailyFastEMA < dailySlowEMA and dailySlowEMA < dailySlowPrev

bool bullContinuationRegime = useTrendContinuation and dailyFastEMA > dailyFastEMA[1] and close > dailyFastEMA
bool bearContinuationRegime = useTrendContinuation and dailyFastEMA < dailyFastEMA[1] and close < dailyFastEMA

// =====================================================
// TREND TRANSITION REGIME & RECLAIM
// =====================================================

float fastEMASlopeATR = not na(dailyATR) ? (dailyFastEMA - dailyFastEMA[1]) / dailyATR : na
bool fastEMANotFallingHard = not na(fastEMASlopeATR) and fastEMASlopeATR > -0.15

bool bullTransitionRegime = useTrendTransition and close > dailyFastEMA and fastEMANotFallingHard and not htfBear
bool bearTransitionRegime = useTrendTransition and close < dailyFastEMA and fastEMASlopeATR < 0.15 and not htfBull

bool bullFastEMAReclaim = close > dailyFastEMA and close[1] <= dailyFastEMA[1]
bool bearFastEMAReclaim = close < dailyFastEMA and close[1] >= dailyFastEMA[1]

float extensionFromFastEMA = not na(dailyATR) ? (close - dailyFastEMA) / dailyATR : na
bool bullNotExtended = not na(extensionFromFastEMA) and extensionFromFastEMA <= maxExtensionATR
bool bearNotExtended = not na(extensionFromFastEMA) and extensionFromFastEMA >= -maxExtensionATR

majorHigh = request.security(syminfo.tickerid, "D", ta.highest(high, majorPivotLookback)[1], lookahead=barmerge.lookahead_on)
majorLow  = request.security(syminfo.tickerid, "D", ta.lowest(low, majorPivotLookback)[1], lookahead=barmerge.lookahead_on)

tacticalHigh = request.security(syminfo.tickerid, "D", ta.highest(high, tacticalLookback)[1], lookahead=barmerge.lookahead_on)
tacticalLow  = request.security(syminfo.tickerid, "D", ta.lowest(low, tacticalLookback)[1], lookahead=barmerge.lookahead_on)

dailySigma = request.security(syminfo.tickerid, "D", ta.stdev(math.log(close / close[1]), rvPeriod)[1], lookahead=barmerge.lookahead_on)

rvExpectedMove = dailyOpen * dailySigma * math.sqrt(swingDays) * emMult
upperRV1Sigma  = dailyOpen + rvExpectedMove
lowerRV1Sigma  = dailyOpen - rvExpectedMove

dailySigmaAvg = request.security(syminfo.tickerid, "D", ta.sma(ta.stdev(math.log(close / close[1]), rvPeriod), 10)[1], lookahead=barmerge.lookahead_on)
rvExpanding = not na(dailySigmaAvg) and dailySigma > dailySigmaAvg

// =====================================================
// ROBUST TIME-NORMALIZED RVOL
// =====================================================

var int sessionSlot = 0
bool isRTH = not na(time(timeframe.period, "0930-1600:23456"))

if timeframe.change("D")
    sessionSlot := 0
else if isRTH
    sessionSlot += 1

var float[] slotVolEMA = array.new_float(0)
var int[] slotObs      = array.new_int(0)

while array.size(slotVolEMA) <= sessionSlot
    array.push(slotVolEMA, na)
    array.push(slotObs, 0)

float slotAvgBefore = array.get(slotVolEMA, sessionSlot)
int slotCountBefore = array.get(slotObs, sessionSlot)
float simpleVolAvg  = ta.sma(volume, 20)

float normalizedRVOL =
     not na(slotAvgBefore) and slotAvgBefore > 0
     ? volume / slotAvgBefore
     : not na(simpleVolAvg) and simpleVolAvg > 0
     ? volume / simpleVolAvg
     : 0.0

float relativeVolume = useTimeNormalizedRVOL and timeframe.isintraday ? normalizedRVOL : (not na(simpleVolAvg) and simpleVolAvg > 0 ? volume / simpleVolAvg : 0.0)
bool strongVolume = relativeVolume >= rvolThreshold

float slotAlpha = 2.0 / (rvolMemorySessions + 1.0)

if barstate.isconfirmed and (isRTH or not timeframe.isintraday)
    float newSlotAvg = na(slotAvgBefore) ? volume : slotAvgBefore + slotAlpha * (volume - slotAvgBefore)
    array.set(slotVolEMA, sessionSlot, newSlotAvg)
    array.set(slotObs, sessionSlot, slotCountBefore + 1)

sessionVWAP = ta.vwap(hlc3)

bodySize          = math.abs(close - open)
barRange          = math.max(high - low, syminfo.mintick)
bodyRangeRatio    = bodySize / barRange
bullCloseLocation = (close - low) / barRange
bearCloseLocation = (high - close) / barRange

bullDisplacement = not na(dailyATR) and close > open and bodySize >= dailyATR * displaceAtrMult and bodyRangeRatio >= minBodyRangeRatio and bullCloseLocation >= minCloseLocation
bearDisplacement = not na(dailyATR) and close < open and bodySize >= dailyATR * displaceAtrMult and bodyRangeRatio >= minBodyRangeRatio and bearCloseLocation >= minCloseLocation

// =====================================================
// CONFIRMED SWING STRUCTURE + INTERNAL STRUCTURE
// =====================================================

pivotHigh = ta.pivothigh(high, pivotLeft, pivotRight)
pivotLow  = ta.pivotlow(low, pivotLeft, pivotRight)

var float lastSwingHigh = na
var float lastSwingLow  = na
var float prevSwingHigh = na
var float prevSwingLow  = na

if not na(pivotHigh)
    prevSwingHigh := lastSwingHigh
    lastSwingHigh := pivotHigh

if not na(pivotLow)
    prevSwingLow := lastSwingLow
    lastSwingLow := pivotLow

internalHigh = ta.highest(high, internalLookback)[1]
internalLow  = ta.lowest(low, internalLookback)[1]

bullInternalMSS = not na(internalHigh) and close > internalHigh and close[1] <= internalHigh
bearInternalMSS = not na(internalLow) and close < internalLow and close[1] >= internalLow

bullSwingBreak = not na(lastSwingHigh) and close > lastSwingHigh and close[1] <= lastSwingHigh
bearSwingBreak = not na(lastSwingLow) and close < lastSwingLow and close[1] >= lastSwingLow

bullSwingSequence = not na(prevSwingHigh) and not na(lastSwingHigh) and lastSwingHigh > prevSwingHigh
bearSwingSequence = not na(prevSwingLow) and not na(lastSwingLow) and lastSwingLow < prevSwingLow

bullBOS = bullSwingBreak and bullSwingSequence
bearBOS = bearSwingBreak and bearSwingSequence

bullMSS = bullSwingBreak and not bullSwingSequence
bearMSS = bearSwingBreak and not bearSwingSequence

bool bullStructureOK = requireSwingBreak ? bullSwingBreak : bullSwingBreak or (allowInternalMSS and bullInternalMSS)
bool bearStructureOK = requireSwingBreak ? bearSwingBreak : bearSwingBreak or (allowInternalMSS and bearInternalMSS)

// =====================================================
// TREND CONTINUATION STRUCTURE
// =====================================================

continuationHigh = ta.highest(high, continuationLookback)[1]
continuationLow  = ta.lowest(low, continuationLookback)[1]

bullContinuationBreak = bullContinuationRegime and not na(continuationHigh) and close > continuationHigh and close[1] <= continuationHigh
bearContinuationBreak = bearContinuationRegime and not na(continuationLow) and close < continuationLow and close[1] >= continuationLow

bool bullContinuationStructure = bullSwingBreak or bullInternalMSS
bool bearContinuationStructure = bearSwingBreak or bearInternalMSS

// =====================================================
// TREND TRANSITION STRUCTURE & ARMED STATE
// =====================================================

float transitionHigh = ta.highest(high, transitionLookback)[1]
float transitionLow  = ta.lowest(low, transitionLookback)[1]

bool bullTransitionBreak = not na(transitionHigh) and close > transitionHigh and close[1] <= transitionHigh
bool bearTransitionBreak = not na(transitionLow) and close < transitionLow and close[1] >= transitionLow

bool bullTransitionStructure = bullInternalMSS or bullSwingBreak or bullBOS
bool bearTransitionStructure = bearInternalMSS or bearSwingBreak or bearBOS

int transitionStructureMemory = 10

bool bullRecentTransitionStructure = ta.barssince(bullTransitionStructure) <= transitionStructureMemory
bool bearRecentTransitionStructure = ta.barssince(bearTransitionStructure) <= transitionStructureMemory

confirmedBar = requireConfirmedBar ? barstate.isconfirmed : true

var bool bullTransitionArmed = false
var bool bearTransitionArmed = false
var int bullTransitionArmBar = na
var int bearTransitionArmBar = na

int transitionWindow = 20

var bool bullTransitionQualified = false
var bool bearTransitionQualified = false

var int bullTransitionQualifiedBar = na
var int bearTransitionQualifiedBar = na

if confirmedBar and bullFastEMAReclaim
    bullTransitionArmed := true
    bullTransitionArmBar := bar_index
    bearTransitionArmed := false
    bearTransitionArmBar := na
    bearTransitionQualified := false
    bearTransitionQualifiedBar := na

if confirmedBar and bearFastEMAReclaim
    bearTransitionArmed := true
    bearTransitionArmBar := bar_index
    bullTransitionArmed := false
    bullTransitionArmBar := na
    bullTransitionQualified := false
    bullTransitionQualifiedBar := na

bool bullTransitionActive = bullTransitionArmed and not na(bullTransitionArmBar) and (bar_index - bullTransitionArmBar <= transitionWindow)
bool bearTransitionActive = bearTransitionArmed and not na(bearTransitionArmBar) and (bar_index - bearTransitionArmBar <= transitionWindow)

if bullTransitionArmed and not bullTransitionActive
    bullTransitionArmed := false
    bullTransitionArmBar := na

if bearTransitionArmed and not bearTransitionActive
    bearTransitionArmed := false
    bearTransitionArmBar := na

// =====================================================
// SWEEP TRIGGERS & FROZEN RV RANGE PIPELINE
// =====================================================

bullMajorSweep    = low < majorLow and close > majorLow
bearMajorSweep    = high > majorHigh and close < majorHigh
bullTacticalSweep = low < tacticalLow and close > tacticalLow
bearTacticalSweep = high > tacticalHigh and close < tacticalHigh
bullRVSweep       = low < lowerRV1Sigma and close > lowerRV1Sigma
bearRVSweep       = high > upperRV1Sigma and close < upperRV1Sigma

bullSweepCount = (bullMajorSweep ? 1 : 0) + (bullTacticalSweep ? 1 : 0) + (bullRVSweep ? 1 : 0)
bearSweepCount = (bearMajorSweep ? 1 : 0) + (bearTacticalSweep ? 1 : 0) + (bearRVSweep ? 1 : 0)

bullishSweep = bullSweepCount > 0
bearishSweep = bearSweepCount > 0

bullReclaim = close > dailyOpen or (timeframe.isintraday and close > sessionVWAP)
bearReclaim = close < dailyOpen or (timeframe.isintraday and close < sessionVWAP)

int bullSweepScore = bullMajorSweep ? 3 : (bullTacticalSweep or bullRVSweep ? 2 : 0)
int bearSweepScore = bearMajorSweep ? 3 : (bearTacticalSweep or bearRVSweep ? 2 : 0)

if bullSweepCount >= 2
    bullSweepScore += bullSweepCount - 1
if bearSweepCount >= 2
    bearSweepScore += bearSweepCount - 1

var bool bullArmed = false
var bool bearArmed = false
var int bullArmBar = na
var int bearArmBar = na
var float bullSweepLow = na
var float bearSweepHigh = na
var int bullArmSweepScore = 0
var int bearArmSweepScore = 0
var int bullArmSweepCount = 0
var int bearArmSweepCount = 0
var bool bullArmMajor = false
var bool bearArmMajor = false
var bool bullArmRV = false
var bool bearArmRV = false
var bool bullArmTactical = false
var bool bearArmTactical = false

var float frozenUpperRV = na
var float frozenLowerRV = na

if bullArmed and not na(bullArmBar) and bar_index - bullArmBar > confirmWindow
    bullArmed := false
    frozenUpperRV := na
    frozenLowerRV := na

if bearArmed and not na(bearArmBar) and bar_index - bearArmBar > confirmWindow
    bearArmed := false
    frozenUpperRV := na
    frozenLowerRV := na

bool armBull = confirmedBar and bullishSweep and not bearishSweep
bool armBear = confirmedBar and bearishSweep and not bullishSweep

if confirmedBar and bullishSweep and bearishSweep
    armBull := close > open
    armBear := close < open

if armBull
    bullArmed := true
    bullArmBar := bar_index
    bullSweepLow := low
    bullArmSweepScore := bullSweepScore
    bullArmSweepCount := bullSweepCount
    bullArmMajor := bullMajorSweep
    bullArmRV := bullRVSweep
    bullArmTactical := bullTacticalSweep
    frozenUpperRV := upperRV1Sigma
    frozenLowerRV := lowerRV1Sigma
    bearArmed := false

if armBear
    bearArmed := true
    bearArmBar := bar_index
    bearSweepHigh := high
    bearArmSweepScore := bearSweepScore
    bearArmSweepCount := bearSweepCount
    bearArmMajor := bearMajorSweep
    bearArmRV := bearRVSweep
    bearArmTactical := bearTacticalSweep
    frozenUpperRV := upperRV1Sigma
    frozenLowerRV := lowerRV1Sigma
    bullArmed := false

bullSetupInvalidated = bullArmed and not na(bullSweepLow) and close < bullSweepLow - dailyATR * structureExitBuffer
bearSetupInvalidated = bearArmed and not na(bearSweepHigh) and close > bearSweepHigh + dailyATR * structureExitBuffer

if confirmedBar and (bullSetupInvalidated or bearSetupInvalidated)
    bullArmed := false
    bearArmed := false
    frozenUpperRV := na
    frozenLowerRV := na

// INTRABAR ARMED LABELS FOR EARLY SITUATIONAL AWARENESS
if showArmedLabels and not barstate.isconfirmed
    if bullishSweep and not bullArmed
        label.new(bar_index, low - dailyATR * 0.20, "ARMED CALL", style=label.style_label_up, color=armedOrange, textcolor=c_white, size=size.tiny)
    if bearishSweep and not bearArmed
        label.new(bar_index, high + dailyATR * 0.20, "ARMED PUT", style=label.style_label_down, color=armedOrange, textcolor=c_white, size=size.tiny)

// =====================================================
// CONFLUENCE SCORING & SIGNALS (REVERSAL ENGINE)
// =====================================================

int bullScore = bullArmed ? bullArmSweepScore : 0
int bearScore = bearArmed ? bearArmSweepScore : 0

bool bullTrendAligned = not useHTFTrend or htfBull
bool bearTrendAligned = not useHTFTrend or htfBear

if bullArmed
    if bullTrendAligned
        bullScore += 2
    if bullSwingBreak
        bullScore += bullBOS ? 3 : 2
    else if allowInternalMSS and bullInternalMSS
        bullScore += 1
    if bullReclaim
        bullScore += 1
    if strongVolume
        bullScore += 1
    if bullDisplacement
        bullScore += 1
    if rvExpanding
        bullScore += 1
    if useVixFilter and vixSpikeExtreme
        bullScore += 1

if bearArmed
    if bearTrendAligned
        bearScore += 2
    if bearSwingBreak
        bearScore += bearBOS ? 3 : 2
    else if allowInternalMSS and bearInternalMSS
        bearScore += 1
    if bearReclaim
        bearScore += 1
    if strongVolume
        bearScore += 1
    if bearDisplacement
        bearScore += 1
    if rvExpanding
        bearScore += 1
    if useVixFilter and vixCompressing
        bearScore += 1

bullBarsSinceSweep = bullArmed and not na(bullArmBar) ? bar_index - bullArmBar : 999
bearBarsSinceSweep = bearArmed and not na(bearArmBar) ? bar_index - bearArmBar : 999

bullWithinWindow = bullBarsSinceSweep >= 1 and bullBarsSinceSweep <= confirmWindow
bearWithinWindow = bearBarsSinceSweep >= 1 and bearBarsSinceSweep <= confirmWindow

bullCountertrendEligible = not counterTrendMajorOnly or bullArmMajor or bullArmSweepCount >= 2
bearCountertrendEligible = not counterTrendMajorOnly or bearArmMajor or bearArmSweepCount >= 2

bullRequiredScore = bullTrendAligned ? minSignalScore : minSignalScore + counterTrendExtra
bearRequiredScore = bearTrendAligned ? minSignalScore : minSignalScore + counterTrendExtra

validCall = bullArmed and bullWithinWindow and (not requireSwingBreak or bullStructureOK) and bullScore >= bullRequiredScore and (bullTrendAligned or bullCountertrendEligible) and confirmedBar
validPut  = bearArmed and bearWithinWindow and (not requireSwingBreak or bearStructureOK) and bearScore >= bearRequiredScore and (bearTrendAligned or bearCountertrendEligible) and confirmedBar

rawCall = validCall and not validCall[1]
rawPut  = validPut and not validPut[1] and not rawCall

// =====================================================
// TREND CONTINUATION SCORING & SIGNALS
// =====================================================

int bullContinuationScore = 0
int bearContinuationScore = 0

if bullContinuationRegime
    bullContinuationScore += 2
if bearContinuationRegime
    bearContinuationScore += 2

if bullSwingSequence
    bullContinuationScore += 1
if bearSwingSequence
    bearContinuationScore += 1

if bullInternalMSS
    bullContinuationScore += 1
if bearInternalMSS
    bearContinuationScore += 1

if bullSwingBreak
    bullContinuationScore += bullBOS ? 2 : 1
if bearSwingBreak
    bearContinuationScore += bearBOS ? 2 : 1

if bullDisplacement
    bullContinuationScore += 1
if bearDisplacement
    bearContinuationScore += 1

if strongVolume
    bullContinuationScore += 1
    bearContinuationScore += 1

if rvExpanding
    bullContinuationScore += 1
    bearContinuationScore += 1

if useVixFilter and vixCompressing
    bullContinuationScore += 1

validContinuationCall = useTrendContinuation and bullContinuationBreak and bullContinuationStructure and bullNotExtended and bullContinuationScore >= continuationScoreMin and confirmedBar
validContinuationPut  = useTrendContinuation and bearContinuationBreak and bearContinuationStructure and bearNotExtended and bearContinuationScore >= continuationScoreMin and confirmedBar

rawContinuationCall = validContinuationCall and not validContinuationCall[1]
rawContinuationPut  = validContinuationPut and not validContinuationPut[1]

// =====================================================
// TREND TRANSITION SCORING & SIGNALS
// =====================================================

int bullTransitionScore = 0
int bearTransitionScore = 0

if bullTransitionRegime
    bullTransitionScore += 2
if bearTransitionRegime
    bearTransitionScore += 2

if bullRecentTransitionStructure
    bullTransitionScore += 1
if bearRecentTransitionStructure
    bearTransitionScore += 1

if bullDisplacement
    bullTransitionScore += 1
if bearDisplacement
    bearTransitionScore += 1

if strongVolume
    bullTransitionScore += 1
    bearTransitionScore += 1

if rvExpanding
    bullTransitionScore += 1
    bearTransitionScore += 1

float transitionExtension = not na(dailyATR) ? (close - dailyFastEMA) / dailyATR : na

bool bullTransitionNotExtended = not na(transitionExtension) and transitionExtension <= transitionMaxExtensionATR
bool bearTransitionNotExtended = not na(transitionExtension) and transitionExtension >= -transitionMaxExtensionATR

bool validTransitionCall = bullTransitionActive and bullTransitionRegime and bullRecentTransitionStructure and bullTransitionNotExtended and bullTransitionScore >= transitionScoreMin and confirmedBar
bool validTransitionPut  = bearTransitionActive and bearTransitionRegime and bearRecentTransitionStructure and bearTransitionNotExtended and bearTransitionScore >= transitionScoreMin and confirmedBar

// =====================================================
// TRANSITION QUALIFICATION STATE ENGINE
// =====================================================

int transitionExecutionWindow = 5

if confirmedBar and validTransitionCall and not bullTransitionQualified
    bullTransitionQualified := true
    bullTransitionQualifiedBar := bar_index

if confirmedBar and validTransitionPut and not bearTransitionQualified
    bearTransitionQualified := true
    bearTransitionQualifiedBar := bar_index

bool bullTransitionExecutionActive = bullTransitionQualified and not na(bullTransitionQualifiedBar) and bar_index - bullTransitionQualifiedBar <= transitionExecutionWindow
bool bearTransitionExecutionActive = bearTransitionQualified and not na(bearTransitionQualifiedBar) and bar_index - bearTransitionQualifiedBar <= transitionExecutionWindow

if bullTransitionQualified and not bullTransitionExecutionActive
    bullTransitionQualified := false
    bullTransitionQualifiedBar := na

if bearTransitionQualified and not bearTransitionExecutionActive
    bearTransitionQualified := false
    bearTransitionQualifiedBar := na

// =====================================================
// TRADE STATE & EXIT SIMULATION (INDICATOR MODE)
// =====================================================

var float[] activeTrade = array.new_float(7, 0.0)

var int sessionCounter = 0
if timeframe.change("D")
    sessionCounter += 1

var int entrySession = na
var float highestSinceEntry = na
var float lowestSinceEntry  = na
var bool runnerActivated      = false

var float lockedLongStructure  = na
var float lockedShortStructure = na

float curPos         = array.get(activeTrade, 0)
float curSL          = array.get(activeTrade, 1)
float curTP          = array.get(activeTrade, 2)
float curEntryBar    = array.get(activeTrade, 3)
float curEntryPrice  = array.get(activeTrade, 5)
float curInitialRisk = array.get(activeTrade, 6)

bool drawExit    = false
string exitMsg   = ""
color exitColor  = na
int exitDir      = 0

sessionsHeld = not na(entrySession) ? sessionCounter - entrySession : 0
canProfitExit = sessionsHeld >= minHoldSessions

if curPos == 1.0 and not na(lastSwingLow)
    lockedLongStructure := na(lockedLongStructure) ? lastSwingLow : math.max(lockedLongStructure, lastSwingLow)
if curPos == -1.0 and not na(lastSwingHigh)
    lockedShortStructure := na(lockedShortStructure) ? lastSwingHigh : math.min(lockedShortStructure, lastSwingHigh)

bullStructureExit = curPos == 1.0 and useStructureExit and bearSwingBreak and (na(lockedLongStructure) or close < lockedLongStructure - dailyATR * structureExitBuffer)
bearStructureExit = curPos == -1.0 and useStructureExit and bullSwingBreak and (na(lockedShortStructure) or close > lockedShortStructure + dailyATR * structureExitBuffer)

float activeTrail = na
if curPos == 1.0 and runnerActivated and not na(highestSinceEntry)
    float volTrail = highestSinceEntry - dailyATR * trailAtrMult
    float structTrail = useStructuralTrail and not na(lockedLongStructure) ? lockedLongStructure - dailyATR * trailStructureBuffer : na
    activeTrail := not na(structTrail) ? math.max(volTrail, structTrail) : volTrail

if curPos == -1.0 and runnerActivated and not na(lowestSinceEntry)
    float volTrail = lowestSinceEntry + dailyATR * trailAtrMult
    float structTrail = useStructuralTrail and not na(lockedShortStructure) ? lockedShortStructure + dailyATR * trailStructureBuffer : na
    activeTrail := not na(structTrail) ? math.min(volTrail, structTrail) : volTrail

if not na(dailyATR) and curPos != 0.0 and bar_index > curEntryBar
    if curPos == 1.0
        if low <= curSL
            drawExit := true
            exitMsg := "SL Sell CALL @ " + str.tostring(curSL, "#.##")
            exitColor := c_exit_sl
            exitDir := 1
            array.set(activeTrade, 0, 0.0)
            array.set(activeTrade, 4, bar_index)
        else if confirmedBar and bullStructureExit
            drawExit := true
            exitMsg := "Sell CALL @ " + str.tostring(close, "#.##")
            exitColor := c_structure
            exitDir := 1
            array.set(activeTrade, 0, 0.0)
            array.set(activeTrade, 4, bar_index)
        else if canProfitExit and useTrailingStop and runnerActivated and not na(activeTrail) and low <= activeTrail
            drawExit := true
            exitMsg := "TRAIL Sell CALL @ " + str.tostring(activeTrail, "#.##")
            exitColor := c_trail
            exitDir := 1
            array.set(activeTrade, 0, 0.0)
            array.set(activeTrade, 4, bar_index)
        else if canProfitExit and useTakeProfit and high >= curTP
            drawExit := true
            exitMsg := "TP Sell CALL @ " + str.tostring(curTP, "#.##")
            exitColor := c_exit_tp
            exitDir := 1
            array.set(activeTrade, 0, 0.0)
            array.set(activeTrade, 4, bar_index)

    else if curPos == -1.0
        if high >= curSL
            drawExit := true
            exitMsg := "SL Sell PUT @ " + str.tostring(curSL, "#.##")
            exitColor := c_exit_sl
            exitDir := -1
            array.set(activeTrade, 0, 0.0)
            array.set(activeTrade, 4, bar_index)
        else if confirmedBar and bearStructureExit
            drawExit := true
            exitMsg := "Sell PUT @ " + str.tostring(close, "#.##")
            exitColor := c_structure
            exitDir := -1
            array.set(activeTrade, 0, 0.0)
            array.set(activeTrade, 4, bar_index)
        else if canProfitExit and useTrailingStop and runnerActivated and not na(activeTrail) and high >= activeTrail
            drawExit := true
            exitMsg := "TRAIL Sell PUT @ " + str.tostring(activeTrail, "#.##")
            exitColor := c_trail
            exitDir := -1
            array.set(activeTrade, 0, 0.0)
            array.set(activeTrade, 4, bar_index)
        else if canProfitExit and useTakeProfit and low <= curTP
            drawExit := true
            exitMsg := "TP Sell PUT @ " + str.tostring(curTP, "#.##")
            exitColor := c_exit_tp
            exitDir := -1
            array.set(activeTrade, 0, 0.0)
            array.set(activeTrade, 4, bar_index)

if drawExit
    highestSinceEntry := na
    lowestSinceEntry  := na
    entrySession      := na
    runnerActivated   := false
    lockedLongStructure  := na
    lockedShortStructure := na

float updatedPos = array.get(activeTrade, 0)
if updatedPos == 1.0
    highestSinceEntry := na(highestSinceEntry) ? high : math.max(highestSinceEntry, high)
if updatedPos == -1.0
    lowestSinceEntry := na(lowestSinceEntry) ? low : math.min(lowestSinceEntry, low)

if updatedPos == 1.0 and not runnerActivated and curInitialRisk > 0 and confirmedBar
    if (close - curEntryPrice) / curInitialRisk >= trailStartR
        runnerActivated := true

if updatedPos == -1.0 and not runnerActivated and curInitialRisk > 0 and confirmedBar
    if (curEntryPrice - close) / curInitialRisk >= trailStartR
        runnerActivated := true

// =====================================================
// ENTRY RISK VALIDATION & ROUTING (TRIPLE ENGINE)
// =====================================================

callStructuralSL = not na(bullSweepLow) ? bullSweepLow - dailyATR * stopAtrMult : na
putStructuralSL  = not na(bearSweepHigh) ? bearSweepHigh + dailyATR * stopAtrMult : na

float bullBreakoutStop = continuationHigh - dailyATR * continuationStopAtr
float bearBreakoutStop = continuationLow + dailyATR * continuationStopAtr

float continuationCallBase = not na(lastSwingLow) ? math.max(lastSwingLow, bullBreakoutStop) : bullBreakoutStop
float continuationPutBase  = not na(lastSwingHigh) ? math.min(lastSwingHigh, bearBreakoutStop) : bearBreakoutStop

continuationCallSL = continuationCallBase
continuationPutSL  = continuationPutBase

// TRANSITION BREAKOUT STOPS
float transitionCallBreakoutStop = transitionHigh - dailyATR * transitionStopAtr
float transitionPutBreakoutStop  = transitionLow + dailyATR * transitionStopAtr

float transitionCallBase = not na(lastSwingLow) ? math.max(lastSwingLow, dailyFastEMA, transitionCallBreakoutStop) : math.max(dailyFastEMA, transitionCallBreakoutStop)
float transitionPutBase  = not na(lastSwingHigh) ? math.min(lastSwingHigh, dailyFastEMA, transitionPutBreakoutStop) : math.min(dailyFastEMA, transitionPutBreakoutStop)

float transitionCallSL = transitionCallBase
float transitionPutSL  = transitionPutBase

callRisk             = not na(callStructuralSL) ? close - callStructuralSL : na
putRisk              = not na(putStructuralSL) ? putStructuralSL - close : na
continuationCallRisk = close - continuationCallSL
continuationPutRisk  = continuationPutSL - close
transitionCallRisk   = close - transitionCallSL
transitionPutRisk    = transitionPutSL - close

callRiskValid             = not na(callRisk) and callRisk > 0 and callRisk <= dailyATR * maxRiskAtr
putRiskValid              = not na(putRisk) and putRisk > 0 and putRisk <= dailyATR * maxRiskAtr
continuationCallRiskValid = continuationCallRisk > 0 and continuationCallRisk <= dailyATR * maxRiskAtr
continuationPutRiskValid  = continuationPutRisk > 0 and continuationPutRisk <= dailyATR * maxRiskAtr
transitionCallRiskValid   = transitionCallRisk > 0 and transitionCallRisk <= dailyATR * maxRiskAtr
transitionPutRiskValid    = transitionPutRisk > 0 and transitionPutRisk <= dailyATR * maxRiskAtr

pastCooldown = array.get(activeTrade, 4) == 0.0 or bar_index - array.get(activeTrade, 4) > cooldownBars
flatAndReady = curPos == 0.0 and pastCooldown and not na(dailyATR)

bool rawTransitionCall = bullTransitionExecutionActive and transitionCallRiskValid and confirmedBar
bool rawTransitionPut  = bearTransitionExecutionActive and transitionPutRiskValid and confirmedBar

// PATHWAY PRIORITY & TAGGING
bool callIsReversal     = rawCall
bool callIsTransition   = rawTransitionCall and not rawCall
bool callIsContinuation = rawContinuationCall and not rawCall and not rawTransitionCall

bool putIsReversal      = rawPut
bool putIsTransition    = rawTransitionPut and not rawPut
bool putIsContinuation  = rawContinuationPut and not rawPut and not rawTransitionPut

string callPathwayTag = callIsReversal ? "[REV]" : callIsTransition ? "[TRANS]" : "[CONT]"
string putPathwayTag  = putIsReversal ? "[REV]" : putIsTransition ? "[TRANS]" : "[CONT]"

enterCall = flatAndReady and (
     (callIsReversal and callRiskValid) or
     (callIsTransition and transitionCallRiskValid) or
     (callIsContinuation and continuationCallRiskValid)
 )

enterPut = flatAndReady and not enterCall and (
     (putIsReversal and putRiskValid) or
     (putIsTransition and transitionPutRiskValid) or
     (putIsContinuation and continuationPutRiskValid)
 )

float selectedCallSL = callIsReversal ? callStructuralSL : callIsTransition ? transitionCallSL : continuationCallSL
float selectedPutSL  = putIsReversal ? putStructuralSL : putIsTransition ? transitionPutSL : continuationPutSL

float selectedCallRisk = callIsReversal ? callRisk : callIsTransition ? transitionCallRisk : continuationCallRisk
float selectedPutRisk  = putIsReversal ? putRisk : putIsTransition ? transitionPutRisk : continuationPutRisk

if enterCall
    float callTP = close + selectedCallRisk * tpRMult

    array.set(activeTrade, 0, 1.0)
    array.set(activeTrade, 1, selectedCallSL)
    array.set(activeTrade, 2, callTP)
    array.set(activeTrade, 3, bar_index)
    array.set(activeTrade, 5, close)
    array.set(activeTrade, 6, selectedCallRisk)

    entrySession := sessionCounter
    highestSinceEntry := high
    lowestSinceEntry := na
    runnerActivated := false
    lockedLongStructure := lastSwingLow
    lockedShortStructure := na

    bullArmed := false
    bullArmBar := na
    bullSweepLow := na

    bullTransitionArmed := false
    bullTransitionArmBar := na
    bullTransitionQualified := false
    bullTransitionQualifiedBar := na

    label.new(
         bar_index,
         low - dailyATR * 0.40,
         "CALL " + callPathwayTag +
         "\nEP: " + str.tostring(close, "#.##") +
         "\nTP: " + str.tostring(callTP, "#.##") +
         "\nSL: " + str.tostring(selectedCallSL, "#.##"),
         style=label.style_label_up,
         color=bullGreen,
         textcolor=c_white,
         size=size.small)

if enterPut
    float putTP = close - selectedPutRisk * tpRMult

    array.set(activeTrade, 0, -1.0)
    array.set(activeTrade, 1, selectedPutSL)
    array.set(activeTrade, 2, putTP)
    array.set(activeTrade, 3, bar_index)
    array.set(activeTrade, 5, close)
    array.set(activeTrade, 6, selectedPutRisk)

    entrySession := sessionCounter
    lowestSinceEntry := low
    highestSinceEntry := na
    runnerActivated := false
    lockedShortStructure := lastSwingHigh
    lockedLongStructure := na

    bearArmed := false
    bearArmBar := na
    bearSweepHigh := na

    bearTransitionArmed := false
    bearTransitionArmBar := na
    bearTransitionQualified := false
    bearTransitionQualifiedBar := na

    label.new(
         bar_index,
         high + dailyATR * 0.40,
         "PUT " + putPathwayTag +
         "\nEP: " + str.tostring(close, "#.##") +
         "\nTP: " + str.tostring(putTP, "#.##") +
         "\nSL: " + str.tostring(selectedPutSL, "#.##"),
         style=label.style_label_down,
         color=bearRed,
         textcolor=c_white,
         size=size.small)

// =====================================================
// PLOTS & VISUALS
// =====================================================

pUpper = plot(upperRV1Sigma, "Upper RV 1σ Band", color=c_band_line, linewidth=1, style=plot.style_stepline)
pLower = plot(lowerRV1Sigma, "Lower RV 1σ Band", color=c_band_line, linewidth=1, style=plot.style_stepline)
fill(pUpper, pLower, color=c_band_fill, title="RV Volatility Cloud")

plot(showStructureLevels ? lastSwingHigh : na, "Last Confirmed Swing High", color=color.new(bearRed, 45), style=plot.style_stepline)
plot(showStructureLevels ? lastSwingLow : na, "Last Confirmed Swing Low", color=color.new(bullGreen, 45), style=plot.style_stepline)
plot(useTrailingStop and runnerActivated ? activeTrail : na, "Active Trail (1.50 ATR)", color=c_trail, linewidth=2, style=plot.style_linebr)

// =====================================================
// EXIT LABELS
// =====================================================

if drawExit
    label.new(bar_index, exitDir == 1 ? high + dailyATR * 0.70 : low - dailyATR * 0.70, exitMsg, style=exitDir == 1 ? label.style_label_down : label.style_label_up, color=exitColor, textcolor=c_white, size=size.small)
````
