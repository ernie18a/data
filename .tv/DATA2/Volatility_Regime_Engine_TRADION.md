<!-- tradingview-pine-id: PUB;4fe796e7cf864543b614860ab0d75937 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Volatility Regime Engine [TRADION]

Source: https://www.tradingview.com/script/UQc0mmwX/

## Description

Volatility Regime Engine [TRADION] is a multi-layer market regime analysis framework designed to identify changes in volatility structure, expansion/compression cycles, directional pressure, and continuation quality.

Rather than treating volatility as a single measurement, the engine evaluates multiple dimensions of market behavior to determine whether price is transitioning into compression, expansion, continuation, exhaustion, or a potentially unstable regime.

The objective is not simply to detect high or low volatility, but to identify how volatility is evolving, whether directional participation supports the move, and whether the current regime has sufficient quality to persist.

CORE ARCHITECTURE

The engine combines several analytical components into a unified regime model:

Volatility Regime

Evaluates the current volatility environment and classifies market conditions according to contraction and expansion behavior.

Fast & Confirmed Scores

Two-stage scoring separates early regime detection from confirmed conditions.

The Fast Score reacts more quickly to developing volatility changes, while the Confirmed Score provides a more stable assessment of established conditions.

This architecture is designed to balance responsiveness with confirmation.

ATR Regime

Measures volatility behavior relative to the instrument's recent range structure, helping distinguish subdued conditions from elevated or extreme volatility environments.

Bandwidth Analysis

Tracks contraction and expansion in the underlying price distribution to identify volatility compression and developing expansion phases.

Relative Volume (RVOL)

Provides participation context by comparing current activity with its historical baseline.

Directional & Setup Bias

Evaluates whether the developing volatility structure favors bullish or bearish conditions.

Bull and Bear Setup Scores quantify the relative strength of each side, while Dominance summarizes the resulting directional imbalance.

Cycle Engine

The Cycle Bias and Cycle State components classify the current phase of the volatility cycle.

Possible conditions include developing ignition, expansion, continuation and exhaustion phases.

This allows the indicator to distinguish between a market that is merely volatile and one that may be entering a structured directional expansion.

Ignition Detection

Ignition logic searches for early evidence that volatility is beginning to transition from a dormant or compressed state into directional expansion.

Bull Ignition and Bear Ignition events are designed as regime-transition signals, not standalone trade entries.

Release Quality

When volatility begins to release, the engine evaluates the quality of that transition.

Release Quality, Quality Grade and Follow Through help determine whether an expansion is developing sufficient structural confirmation or losing momentum.

Macro Continuation

Continuation logic reduces repetitive signaling once a directional regime has already been established.

This allows the engine to distinguish between:

initial ignition,
confirmed release,
established continuation,
and potential exhaustion.

Higher-Timeframe Context

Higher-timeframe regime information is incorporated into the scoring architecture to determine whether the active regime is supported or opposed by broader volatility conditions.

The HTF Quality Modifier adjusts regime quality according to this alignment.

False Expansion Risk

Not every volatility expansion develops into a sustainable move.

The False Expansion Risk model evaluates contextual conditions that may indicate a weak or unstable expansion and classifies the risk accordingly.

This component is intended to provide an additional layer of caution when volatility increases without sufficient structural support.

VISUAL ENGINE

The lower oscillator provides a compact visualization of regime behavior.

Histogram structure represents changes in volatility state and regime intensity, while the accompanying momentum structure helps visualize directional pressure and developing transitions.

Background regime zones provide additional context for compression, expansion and directional phases.

Event markers highlight significant transitions such as:

BULL IGNITION
Potential bullish volatility ignition.

BEAR IGNITION
Potential bearish volatility ignition.

BULL RELEASE
Bullish expansion gaining confirmation.

BEAR RELEASE
Bearish expansion gaining confirmation.

EXHAUST
Potential exhaustion of an extended volatility phase.

Continuation states are intentionally filtered to reduce unnecessary signal repetition.

DASHBOARD

The integrated dashboard provides a real-time summary of the engine, including:

Regime
Fast Score
Confirmed Score
ATR Regime
Bandwidth State
RVOL
Direction
Setup Bias
Bull / Bear Setup
Dominance
Breakout Memory
Cycle Bias
Cycle State
Ignition Score
Macro Continuation
Release Quality
Quality Grade
Follow Through
HTF Regime
HTF Quality Modifier
Risk Adjustment
False Expansion Risk
Active Event

The dashboard is designed to provide a compact overview of the current volatility environment without requiring interpretation of every individual component.

HOW TO USE

Volatility Regime Engine [TRADION] is designed primarily as a market-context and regime-analysis tool.

It can be used to:

identify volatility compression before potential expansion,
detect early bullish or bearish ignition,
evaluate the quality of developing volatility releases,
distinguish expansion from established continuation,
identify potential exhaustion conditions,
compare directional setup strength,
evaluate higher-timeframe regime alignment,
and assess the risk of unstable or false expansion.

The indicator should not be interpreted as a mechanical buy/sell system. Signals represent changes in volatility structure and should be evaluated together with price action, market structure, trend context, support/resistance and appropriate risk management.

NON-REPAINTING DESIGN

The engine is designed around confirmed-bar calculations for signal generation. Historical signals are not intentionally repositioned after confirmation.

Higher-timeframe information is handled with confirmation-oriented logic to minimize look-ahead bias.

IMPORTANT

Volatility expansion does not necessarily imply bullish price movement. Expansion can occur in either direction.

The primary purpose of the engine is to determine when the volatility environment is changing, which side currently has structural dominance, and whether that transition has sufficient quality to develop into continuation.

Volatility Regime Engine [TRADION] is intended for technical analysis, research and educational purposes only. It does not constitute financial or investment advice.

---

## Source Code

````pine
//@version=6
indicator("Volatility Regime Engine [TRADION]", shorttitle="VRE [TRADION]", overlay=false, precision=1, max_labels_count=400)

//====================================================================
// VOLATILITY REGIME ENGINE [TRADION]
// V2.1 - CONTEXT-AWARE RISK ENGINE
//
// ✓ Symmetric Bull / Bear scoring
// ✓ Breakout memory
// ✓ One-shot ignition
// ✓ Signal cooldown
// ✓ Macro continuation lock
// ✓ Minimum quality for continuation
// ✓ Context-aware false expansion risk
// ✓ HTF alignment risk modifier
// ✓ Dominance risk modifier
// ✓ Direction / cycle alignment modifier
// ✓ Quality-aware follow through
// ✓ Persistent event memory
// ✓ Bar-close confirmed signals
//====================================================================


//====================================================================
// 01 - GENERAL
//====================================================================

groupGeneral = "01 • GENERAL"

showDashboard = input.bool(true, "Show Dashboard", group=groupGeneral)
showSignals = input.bool(true, "Show Main Signals", group=groupGeneral)
showInvalidations = input.bool(false, "Show Cycle Invalidations", group=groupGeneral)
showContinuation = input.bool(true, "Show Continuation Signals", group=groupGeneral)
showBackground = input.bool(true, "Show Background", group=groupGeneral)

confirmedSmoothLen = input.int(5, "Confirmed Score Smoothing", minval=1, maxval=30, group=groupGeneral)
fastSmoothLen = input.int(3, "Fast Score Smoothing", minval=1, maxval=15, group=groupGeneral)


//====================================================================
// 02 - ATR ENGINE
//====================================================================

groupATR = "02 • ATR ENGINE"

atrLen = input.int(14, "ATR Length", minval=2, group=groupATR)
atrBaseLen = input.int(50, "ATR Baseline", minval=10, group=groupATR)

fastAtrLen = input.int(7, "Fast ATR", minval=2, maxval=30, group=groupATR)
fastAtrBaseLen = input.int(21, "Fast ATR Baseline", minval=5, maxval=100, group=groupATR)

atrNormLen = input.int(100, "ATR Normalization", minval=30, maxval=500, group=groupATR)


//====================================================================
// 03 - COMPRESSION ENGINE
//====================================================================

groupCompression = "03 • COMPRESSION ENGINE"

bbLen = input.int(20, "Bollinger Length", minval=5, group=groupCompression)
bbMult = input.float(2.0, "Bollinger Multiplier", minval=0.5, maxval=5.0, step=0.1, group=groupCompression)

kcLen = input.int(20, "Keltner Length", minval=5, group=groupCompression)
kcMult = input.float(1.5, "Keltner Multiplier", minval=0.5, maxval=5.0, step=0.1, group=groupCompression)

bandNormLen = input.int(100, "Bandwidth Normalization", minval=30, maxval=500, group=groupCompression)
minCompressionBars = input.int(3, "Minimum Compression Bars", minval=1, maxval=30, group=groupCompression)


//====================================================================
// 04 - HISTORICAL VOLATILITY
//====================================================================

groupHV = "04 • HISTORICAL VOLATILITY"

hvLen = input.int(20, "HV Length", minval=5, group=groupHV)
hvNormLen = input.int(100, "HV Normalization", minval=30, maxval=500, group=groupHV)


//====================================================================
// 05 - RELATIVE VOLUME
//====================================================================

groupVolume = "05 • RELATIVE VOLUME"

volumeLen = input.int(20, "Volume Average", minval=5, group=groupVolume)

fastBreakoutRVOL = input.float(1.15, "Fast Breakout RVOL", minval=0.5, maxval=5.0, step=0.05, group=groupVolume)
confirmedRVOL = input.float(1.30, "Confirmed RVOL", minval=0.5, maxval=5.0, step=0.05, group=groupVolume)


//====================================================================
// 06 - DIRECTION / PRICE ACTION
//====================================================================

groupDirection = "06 • DIRECTION / PRICE ACTION"

emaFastLen = input.int(21, "Fast EMA", minval=2, group=groupDirection)
emaSlowLen = input.int(55, "Slow EMA", minval=5, group=groupDirection)

rocLen = input.int(10, "ROC Length", minval=2, group=groupDirection)

microBreakoutLen = input.int(5, "Micro Breakout Length", minval=2, maxval=30, group=groupDirection)
breakoutMemoryBars = input.int(6, "Breakout Memory Bars", minval=1, maxval=20, group=groupDirection)

impulseATR = input.float(0.40, "Impulse Body / ATR", minval=0.10, maxval=3.0, step=0.05, group=groupDirection)


//====================================================================
// 07 - REGIME LEVELS
//====================================================================

groupRegime = "07 • REGIME LEVELS"

compressionLevel = input.float(30.0, "Compression Level", minval=10, maxval=45, step=1, group=groupRegime)
earlyLevel = input.float(38.0, "Ignition Armed Level", minval=20, maxval=60, step=1, group=groupRegime)
fastBreakoutLevel = input.float(58.0, "Fast Breakout Level", minval=40, maxval=80, step=1, group=groupRegime)
expansionLevel = input.float(60.0, "Confirmed Expansion", minval=45, maxval=80, step=1, group=groupRegime)
extremeLevel = input.float(80.0, "Extreme Expansion", minval=60, maxval=95, step=1, group=groupRegime)


//====================================================================
// 08 - STATE MACHINE
//====================================================================

groupState = "08 • STATE MACHINE"

normalIgnitionPoints = input.int(5, "Normal Ignition Confirmations", minval=3, maxval=8, group=groupState)

setupDominance = input.float(12.0, "Setup Dominance Required", minval=0, maxval=50, step=1, group=groupState)
reversalSetupMinimum = input.float(58.0, "Reversal Setup Minimum", minval=30, maxval=90, step=1, group=groupState)

signalCooldownBars = input.int(12, "Same Direction Signal Cooldown", minval=3, maxval=50, group=groupState)

continuationMinBars = input.int(5, "Continuation Minimum Bars", minval=2, maxval=30, group=groupState)
continuationScoreMin = input.float(55.0, "Continuation Fast Score", minval=30, maxval=90, step=1, group=groupState)
continuationSetupMin = input.float(58.0, "Continuation Setup Score", minval=30, maxval=90, step=1, group=groupState)
continuationDominanceMin = input.float(20.0, "Continuation Dominance", minval=5, maxval=60, step=1, group=groupState)
continuationQualityMin = input.float(50.0, "Continuation Minimum Quality", minval=40, maxval=90, step=5, group=groupState)

resetFastLevel = input.float(32.0, "Reset Fast Score", minval=10, maxval=50, step=1, group=groupState)
resetConfirmedLevel = input.float(38.0, "Reset Confirmed Score", minval=10, maxval=55, step=1, group=groupState)

resetBarsRequired = input.int(4, "Reset Confirmation Bars", minval=2, maxval=20, group=groupState)
minimumCycleBars = input.int(5, "Minimum Bars Between Ignitions", minval=1, maxval=50, group=groupState)


//====================================================================
// 09 - HTF
//====================================================================

groupHTF = "09 • HIGHER TIMEFRAME"

useHTF = input.bool(true, "Use HTF Confirmation", group=groupHTF)

higherTF = input.timeframe("240", "Higher Timeframe", group=groupHTF)

htfExpansionBonus = input.float(10.0, "HTF Expansion Quality Bonus", minval=0, maxval=25, step=1, group=groupHTF)
htfCompressionPenalty = input.float(5.0, "HTF Compression Quality Penalty", minval=0, maxval=25, step=1, group=groupHTF)


//====================================================================
// 10 - CONTEXT AWARE RISK
//====================================================================

groupRisk = "10 • CONTEXT-AWARE RISK"

riskHTFExpansionReduction = input.int(2, "HTF Expansion Risk Reduction", minval=0, maxval=5, group=groupRisk)
riskStrongDominanceReduction = input.int(1, "Strong Dominance Risk Reduction", minval=0, maxval=5, group=groupRisk)
riskDirectionAlignmentReduction = input.int(1, "Direction Alignment Risk Reduction", minval=0, maxval=5, group=groupRisk)
riskBreakoutAlignmentReduction = input.int(1, "Recent Breakout Risk Reduction", minval=0, maxval=5, group=groupRisk)

strongDominanceRiskLevel = input.float(30.0, "Strong Dominance Threshold", minval=10, maxval=80, step=5, group=groupRisk)


//====================================================================
// 11 - COLORS
//====================================================================

bullColor = color.rgb(0, 235, 140)
bullStrong = color.rgb(0, 255, 80)

bearColor = color.rgb(255, 75, 95)
bearStrong = color.rgb(255, 35, 55)

compressionColor = color.rgb(175, 80, 255)
earlyColor = color.rgb(255, 210, 0)
expansionColor = color.rgb(0, 190, 255)
extremeColor = color.rgb(255, 150, 0)
orangeColor = color.rgb(255, 135, 0)
neutralColor = color.rgb(135, 150, 175)

panelBG = color.rgb(16, 22, 31)
panelBG2 = color.rgb(23, 30, 41)
borderColor = color.rgb(65, 80, 100)


//====================================================================
// 12 - HELPER
//====================================================================

f_norm(float value, int length) =>
    float lo = ta.lowest(value, length)
    float hi = ta.highest(value, length)
    float rg = hi - lo
    float result = rg > 0 ? 100.0 * (value - lo) / rg : 50.0
    math.max(0.0, math.min(100.0, result))


//====================================================================
// 13 - ATR CORE
//====================================================================

atr = ta.atr(atrLen)
atrBase = ta.sma(atr, atrBaseLen)

atrRatio = atrBase > 0 ? atr / atrBase : 1.0

atrScore = f_norm(atrRatio, atrNormLen)

fastATR = ta.atr(fastAtrLen)
fastATRBase = ta.sma(fastATR, fastAtrBaseLen)

fastATRRatio = fastATRBase > 0 ? fastATR / fastATRBase : 1.0

fastATRScore = f_norm(fastATRRatio, fastAtrBaseLen)


//====================================================================
// 14 - ATR ACCELERATION
//====================================================================

atrDelta = atrRatio - atrRatio[1]
atrPrevDelta = atrRatio[1] - atrRatio[2]

atrRising = atrDelta > 0
atrAccelerating = atrDelta > 0 and atrDelta > atrPrevDelta
atrTurningUp = atrDelta > 0 and atrPrevDelta <= 0

fastATRExpansion = fastATRRatio > fastATRRatio[1]


//====================================================================
// 15 - BOLLINGER / BANDWIDTH
//====================================================================

bbBasis = ta.sma(close, bbLen)

bbDev = ta.stdev(close, bbLen) * bbMult

bbUpper = bbBasis + bbDev
bbLower = bbBasis - bbDev

bbWidth = bbBasis != 0 ? (bbUpper - bbLower) / math.abs(bbBasis) : 0.0

bbScore = f_norm(bbWidth, bandNormLen)
fastBBScore = f_norm(bbWidth, 30)

bbDelta = bbWidth - bbWidth[1]
bbPrevDelta = bbWidth[1] - bbWidth[2]

bandwidthRising = bbDelta > 0
bandwidthAccelerating = bbDelta > 0 and bbDelta > bbPrevDelta
bandwidthTurningUp = bbDelta > 0 and bbPrevDelta <= 0


//====================================================================
// 16 - KELTNER / SQUEEZE
//====================================================================

kcBasis = ta.ema(close, kcLen)
kcATR = ta.atr(kcLen)

kcUpper = kcBasis + kcATR * kcMult
kcLower = kcBasis - kcATR * kcMult

squeezeOn = bbUpper < kcUpper and bbLower > kcLower


//====================================================================
// 17 - HISTORICAL VOLATILITY
//====================================================================

safePrevClose = close[1] > 0 ? close[1] : close

logReturn = math.log(close / safePrevClose)

historicalVolatility = ta.stdev(logReturn, hvLen) * math.sqrt(365.0) * 100.0

hvScore = f_norm(historicalVolatility, hvNormLen)


//====================================================================
// 18 - RVOL
//====================================================================

volumeAverage = ta.sma(volume, volumeLen)

rvol = volumeAverage > 0 ? volume / volumeAverage : 0.0

float rvolScore = 0.0

if rvol >= 2.0
    rvolScore := 100.0
else if rvol >= confirmedRVOL
    rvolScore := 80.0
else if rvol >= 1.0
    rvolScore := 60.0
else if rvol >= 0.75
    rvolScore := 40.0
else
    rvolScore := math.max(0.0, rvol * 40.0)


//====================================================================
// 19 - DIRECTION
//====================================================================

emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

roc = ta.roc(close, rocLen)
rocDelta = roc - roc[1]

bullMomentumAcceleration = roc > roc[1] and rocDelta > 0
bearMomentumAcceleration = roc < roc[1] and rocDelta < 0

bullTrend = close > emaFast and emaFast > emaSlow
bearTrend = close < emaFast and emaFast < emaSlow

bullDirection = bullTrend and roc > 0
bearDirection = bearTrend and roc < 0

fastEMARising = emaFast > emaFast[1]
fastEMAFalling = emaFast < emaFast[1]


//====================================================================
// 20 - PRICE IMPULSE
//====================================================================

bodySize = math.abs(close - open)

bodyATR = atr > 0 ? bodySize / atr : 0.0

bullImpulse = close > open and close > emaFast and bodyATR >= impulseATR
bearImpulse = close < open and close < emaFast and bodyATR >= impulseATR

strongBullImpulse = bullImpulse and close > high[1]
strongBearImpulse = bearImpulse and close < low[1]


//====================================================================
// 21 - MICRO BREAKOUT
//====================================================================

microResistance = ta.highest(high, microBreakoutLen)[1]
microSupport = ta.lowest(low, microBreakoutLen)[1]

bullMicroBreakout = barstate.isconfirmed and not na(microResistance) and close > microResistance and close > emaFast and fastEMARising

bearMicroBreakout = barstate.isconfirmed and not na(microSupport) and close < microSupport and close < emaFast and fastEMAFalling


//====================================================================
// 22 - BREAKOUT MEMORY
//====================================================================

bullBreakoutBars = ta.barssince(bullMicroBreakout)
bearBreakoutBars = ta.barssince(bearMicroBreakout)

bullBreakoutRecent = not na(bullBreakoutBars) and bullBreakoutBars <= breakoutMemoryBars
bearBreakoutRecent = not na(bearBreakoutBars) and bearBreakoutBars <= breakoutMemoryBars


//====================================================================
// 23 - CONFIRMED SCORE
//====================================================================

float confirmedAccelerationScore = 0.0

if atrAccelerating and bandwidthAccelerating
    confirmedAccelerationScore := 100.0
else if atrRising and bandwidthRising
    confirmedAccelerationScore := 60.0

confirmedScoreRaw =
     atrScore * 0.30 +
     bbScore * 0.25 +
     hvScore * 0.20 +
     rvolScore * 0.15 +
     confirmedAccelerationScore * 0.10

confirmedScore = math.max(0.0, math.min(100.0, confirmedScoreRaw))

confirmedSignal = ta.ema(confirmedScore, confirmedSmoothLen)


//====================================================================
// 24 - FAST SCORE
//====================================================================

float impulseScore = 0.0

if strongBullImpulse or strongBearImpulse
    impulseScore := 100.0
else if bullImpulse or bearImpulse
    impulseScore := 70.0
else if bodyATR >= 0.30
    impulseScore := 40.0


float momentumAccelerationScore = 0.0

if bullMomentumAcceleration or bearMomentumAcceleration
    momentumAccelerationScore := 100.0
else if math.abs(roc) > math.abs(roc[1])
    momentumAccelerationScore := 60.0


float atrEarlyScore = fastATRScore

if atrTurningUp
    atrEarlyScore := math.max(atrEarlyScore, 70.0)

if atrAccelerating
    atrEarlyScore := math.max(atrEarlyScore, 85.0)

if fastATRExpansion
    atrEarlyScore := math.max(atrEarlyScore, 65.0)


float bandwidthEarlyScore = fastBBScore

if bandwidthTurningUp
    bandwidthEarlyScore := math.max(bandwidthEarlyScore, 70.0)

if bandwidthAccelerating
    bandwidthEarlyScore := math.max(bandwidthEarlyScore, 85.0)


float breakoutScore = 0.0

if bullMicroBreakout or bearMicroBreakout
    breakoutScore := 100.0
else if bullBreakoutRecent or bearBreakoutRecent
    breakoutScore := 60.0


fastScoreRaw =
     atrEarlyScore * 0.20 +
     bandwidthEarlyScore * 0.20 +
     impulseScore * 0.20 +
     momentumAccelerationScore * 0.15 +
     breakoutScore * 0.15 +
     rvolScore * 0.10

fastScore = math.max(0.0, math.min(100.0, fastScoreRaw))

fastSignal = ta.ema(fastScore, fastSmoothLen)


//====================================================================
// 25 - COMPRESSION
//====================================================================

statisticalCompression = atrScore < 35 and bbScore < 30

scoreCompression = confirmedScore < compressionLevel

compressionActive = squeezeOn or statisticalCompression or scoreCompression

var int compressionBars = 0

if compressionActive
    compressionBars += 1
else
    compressionBars := 0

var int lastCompressionDuration = 0

if compressionActive
    lastCompressionDuration := compressionBars

compressionExit =
     barstate.isconfirmed and
     not compressionActive and
     compressionActive[1] and
     lastCompressionDuration >= minCompressionBars


//====================================================================
// 26 - BULL / BEAR SETUP SCORES
//====================================================================

float bullSetupRaw = 0.0
float bearSetupRaw = 0.0


if close > emaFast
    bullSetupRaw += 12.0

if close < emaFast
    bearSetupRaw += 12.0


if emaFast > emaSlow
    bullSetupRaw += 12.0

if emaFast < emaSlow
    bearSetupRaw += 12.0


if fastEMARising
    bullSetupRaw += 8.0

if fastEMAFalling
    bearSetupRaw += 8.0


if roc > 0
    bullSetupRaw += 10.0

if roc < 0
    bearSetupRaw += 10.0


if bullMomentumAcceleration
    bullSetupRaw += 12.0

if bearMomentumAcceleration
    bearSetupRaw += 12.0


if bullImpulse
    bullSetupRaw += 10.0

if bearImpulse
    bearSetupRaw += 10.0


if bullMicroBreakout
    bullSetupRaw += 18.0
else if bullBreakoutRecent
    bullSetupRaw += 10.0


if bearMicroBreakout
    bearSetupRaw += 18.0
else if bearBreakoutRecent
    bearSetupRaw += 10.0


if fastScore >= earlyLevel

    if bullDirection or bullMomentumAcceleration
        bullSetupRaw += 8.0

    if bearDirection or bearMomentumAcceleration
        bearSetupRaw += 8.0


if rvol >= fastBreakoutRVOL

    if close >= open
        bullSetupRaw += 5.0

    if close <= open
        bearSetupRaw += 5.0


if atrRising and bandwidthRising

    if bullMomentumAcceleration
        bullSetupRaw += 5.0

    if bearMomentumAcceleration
        bearSetupRaw += 5.0


bullSetupScore = math.max(0.0, math.min(100.0, bullSetupRaw))
bearSetupScore = math.max(0.0, math.min(100.0, bearSetupRaw))


//====================================================================
// 27 - DOMINANCE
//====================================================================

setupDifference = bullSetupScore - bearSetupScore

bullDominant = setupDifference >= setupDominance
bearDominant = setupDifference <= -setupDominance

dominanceAbs = math.abs(setupDifference)

string dominanceText = "NEUTRAL"

if bullDominant
    dominanceText := "+" + str.tostring(dominanceAbs, "#") + " BULL"
else if bearDominant
    dominanceText := "-" + str.tostring(dominanceAbs, "#") + " BEAR"


//====================================================================
// 28 - HTF ENGINE
//====================================================================

f_htfScore() =>
    float _atr = ta.atr(atrLen)
    float _atrBase = ta.sma(_atr, atrBaseLen)
    float _atrRatio = _atrBase > 0 ? _atr / _atrBase : 1.0
    float _atrScore = f_norm(_atrRatio, atrNormLen)

    float _bbBasis = ta.sma(close, bbLen)
    float _bbDev = ta.stdev(close, bbLen) * bbMult
    float _bbUpper = _bbBasis + _bbDev
    float _bbLower = _bbBasis - _bbDev
    float _bbWidth = _bbBasis != 0 ? (_bbUpper - _bbLower) / math.abs(_bbBasis) : 0.0
    float _bbScore = f_norm(_bbWidth, bandNormLen)

    float _safePrev = close[1] > 0 ? close[1] : close
    float _ret = math.log(close / _safePrev)
    float _hv = ta.stdev(_ret, hvLen) * math.sqrt(365.0) * 100.0
    float _hvScore = f_norm(_hv, hvNormLen)

    float _volMA = ta.sma(volume, volumeLen)
    float _rvol = _volMA > 0 ? volume / _volMA : 0.0

    float _rvolScore = 0.0

    if _rvol >= 2.0
        _rvolScore := 100.0
    else if _rvol >= confirmedRVOL
        _rvolScore := 80.0
    else if _rvol >= 1.0
        _rvolScore := 60.0
    else
        _rvolScore := 40.0

    float _score =
         _atrScore * 0.35 +
         _bbScore * 0.30 +
         _hvScore * 0.20 +
         _rvolScore * 0.15

    math.max(0.0, math.min(100.0, _score))


htfScore =
     request.security(
         syminfo.tickerid,
         higherTF,
         f_htfScore()[1],
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_on
     )


string htfRegime = "OFF"

if useHTF
    if htfScore >= extremeLevel
        htfRegime := "EXTREME"
    else if htfScore >= expansionLevel
        htfRegime := "EXPANSION"
    else if htfScore < compressionLevel
        htfRegime := "COMPRESSION"
    else
        htfRegime := "NORMAL"


//====================================================================
// 29 - BASE FALSE EXPANSION RISK
//====================================================================

int baseFalseRiskPoints = 0

baseFalseRiskPoints += rvol < 0.80 ? 2 : 0
baseFalseRiskPoints += not atrRising ? 2 : 0
baseFalseRiskPoints += not bandwidthRising ? 2 : 0
baseFalseRiskPoints += bodyATR < 0.30 ? 1 : 0
baseFalseRiskPoints += confirmedScore < compressionLevel ? 2 : 0
baseFalseRiskPoints += not bullBreakoutRecent and not bearBreakoutRecent ? 1 : 0


//====================================================================
// 30 - CONTEXT-AWARE RISK REDUCTION
//====================================================================

int riskReduction = 0


htfSupportsExpansion =
     useHTF and
     (
         htfRegime == "EXPANSION" or
         htfRegime == "EXTREME"
     )


strongDominance =
     dominanceAbs >= strongDominanceRiskLevel


bullContextAligned =
     bullDirection and
     bullDominant


bearContextAligned =
     bearDirection and
     bearDominant


directionContextAligned =
     bullContextAligned or
     bearContextAligned


breakoutContextAligned =
     (
         bullContextAligned and bullBreakoutRecent
     ) or
     (
         bearContextAligned and bearBreakoutRecent
     )


if htfSupportsExpansion
    riskReduction += riskHTFExpansionReduction


if strongDominance
    riskReduction += riskStrongDominanceReduction


if directionContextAligned
    riskReduction += riskDirectionAlignmentReduction


if breakoutContextAligned
    riskReduction += riskBreakoutAlignmentReduction


falseRiskPoints =
     math.max(
         0,
         baseFalseRiskPoints - riskReduction
     )


//====================================================================
// 31 - FINAL FALSE EXPANSION RISK
//====================================================================

string falseRisk = "LOW"

if falseRiskPoints >= 8
    falseRisk := "VERY HIGH"
else if falseRiskPoints >= 5
    falseRisk := "HIGH"
else if falseRiskPoints >= 3
    falseRisk := "MEDIUM"


riskAllowsContinuation =
     falseRisk == "LOW" or
     falseRisk == "MEDIUM"


//====================================================================
// 32 - IGNITION POINTS
//====================================================================

int bullPoints = 0

bullPoints += atrRising ? 1 : 0
bullPoints += bandwidthRising ? 1 : 0
bullPoints += bullImpulse ? 1 : 0
bullPoints += bullMomentumAcceleration ? 1 : 0
bullPoints += bullBreakoutRecent ? 1 : 0
bullPoints += fastScore >= earlyLevel ? 1 : 0
bullPoints += close > emaFast ? 1 : 0
bullPoints += compressionExit ? 1 : 0


int bearPoints = 0

bearPoints += atrRising ? 1 : 0
bearPoints += bandwidthRising ? 1 : 0
bearPoints += bearImpulse ? 1 : 0
bearPoints += bearMomentumAcceleration ? 1 : 0
bearPoints += bearBreakoutRecent ? 1 : 0
bearPoints += fastScore >= earlyLevel ? 1 : 0
bearPoints += close < emaFast ? 1 : 0
bearPoints += compressionExit ? 1 : 0


//====================================================================
// 33 - STATE VARIABLES
//====================================================================

var int cycleState = 0
var int cycleDirection = 0

var int lastIgnitionBar = na

var int lastBullSignalBar = na
var int lastBearSignalBar = na

var int resetCounter = 0
var int invalidationBar = na

var bool continuationFired = false

var int macroContinuationLock = 0

var string activeEvent = "WAITING"
var color activeEventColor = neutralColor


//====================================================================
// 34 - MACRO CONTINUATION LOCK
//====================================================================

macroBullCondition =
     bullDirection and
     bullDominant


macroBearCondition =
     bearDirection and
     bearDominant


if macroContinuationLock == 1 and macroBearCondition
    macroContinuationLock := 0


if macroContinuationLock == -1 and macroBullCondition
    macroContinuationLock := 0


//====================================================================
// 35 - SIGNAL COOLDOWN
//====================================================================

bullCooldownOK =
     na(lastBullSignalBar) or
     bar_index - lastBullSignalBar >= signalCooldownBars


bearCooldownOK =
     na(lastBearSignalBar) or
     bar_index - lastBearSignalBar >= signalCooldownBars


//====================================================================
// 36 - HARD RESET
//====================================================================

resetCondition =
     fastScore < resetFastLevel and
     confirmedScore < resetConfirmedLevel and
     not bullBreakoutRecent and
     not bearBreakoutRecent


if resetCondition
    resetCounter += 1
else
    resetCounter := 0


minimumCycleAgeOK =
     na(lastIgnitionBar) or
     bar_index - lastIgnitionBar >= minimumCycleBars


hardReset =
     resetCounter >= resetBarsRequired and
     minimumCycleAgeOK


if hardReset

    cycleState := 0
    cycleDirection := 0

    continuationFired := false

    activeEvent := "RESET / WAITING"
    activeEventColor := neutralColor


//====================================================================
// 37 - OPPOSITE CYCLE INVALIDATION
//====================================================================

bullCycleInvalidation =
     barstate.isconfirmed and
     cycleState < 0 and
     bullSetupScore >= reversalSetupMinimum and
     bullDominant and
     bullBreakoutRecent and
     fastScore >= earlyLevel and
     falseRisk != "VERY HIGH"


bearCycleInvalidation =
     barstate.isconfirmed and
     cycleState > 0 and
     bearSetupScore >= reversalSetupMinimum and
     bearDominant and
     bearBreakoutRecent and
     fastScore >= earlyLevel and
     falseRisk != "VERY HIGH"


if bullCycleInvalidation

    cycleState := 0
    cycleDirection := 0

    resetCounter := 0
    continuationFired := false

    invalidationBar := bar_index

    activeEvent := "BEAR CYCLE INVALIDATED"
    activeEventColor := bullColor


if bearCycleInvalidation

    cycleState := 0
    cycleDirection := 0

    resetCounter := 0
    continuationFired := false

    invalidationBar := bar_index

    activeEvent := "BULL CYCLE INVALIDATED"
    activeEventColor := bearColor


canArmThisBar =
     na(invalidationBar) or
     bar_index > invalidationBar


//====================================================================
// 38 - ARMED
//====================================================================

bullArmedCondition =
     barstate.isconfirmed and
     canArmThisBar and
     cycleState == 0 and
     bullCooldownOK and
     fastScore >= earlyLevel and
     bullSetupScore >= 50 and
     bullDominant and
     (
         bullMomentumAcceleration or
         bullBreakoutRecent or
         bullDirection
     )


bearArmedCondition =
     barstate.isconfirmed and
     canArmThisBar and
     cycleState == 0 and
     bearCooldownOK and
     fastScore >= earlyLevel and
     bearSetupScore >= 50 and
     bearDominant and
     (
         bearMomentumAcceleration or
         bearBreakoutRecent or
         bearDirection
     )


if bullArmedCondition

    cycleState := 1
    cycleDirection := 1

    activeEvent := "BULL ARMED"
    activeEventColor := earlyColor


if bearArmedCondition

    cycleState := -1
    cycleDirection := -1

    activeEvent := "BEAR ARMED"
    activeEventColor := earlyColor


//====================================================================
// 39 - IGNITION
//====================================================================

fastCrossEarly =
     ta.crossover(
         fastScore,
         earlyLevel
     )


normalBullIgnition =
     barstate.isconfirmed and
     cycleState == 1 and
     bullCooldownOK and
     bullPoints >= normalIgnitionPoints and
     bullDominant and
     falseRisk != "VERY HIGH" and
     (
         bullBreakoutRecent or
         compressionExit or
         fastCrossEarly
     )


normalBearIgnition =
     barstate.isconfirmed and
     cycleState == -1 and
     bearCooldownOK and
     bearPoints >= normalIgnitionPoints and
     bearDominant and
     falseRisk != "VERY HIGH" and
     (
         bearBreakoutRecent or
         compressionExit or
         fastCrossEarly
     )


fastBullIgnition =
     barstate.isconfirmed and
     cycleState == 1 and
     bullCooldownOK and
     fastScore >= fastBreakoutLevel and
     bullSetupScore >= 60 and
     bullDominant and
     rvol >= fastBreakoutRVOL and
     bullBreakoutRecent and
     falseRisk != "VERY HIGH"


fastBearIgnition =
     barstate.isconfirmed and
     cycleState == -1 and
     bearCooldownOK and
     fastScore >= fastBreakoutLevel and
     bearSetupScore >= 60 and
     bearDominant and
     rvol >= fastBreakoutRVOL and
     bearBreakoutRecent and
     falseRisk != "VERY HIGH"


bullIgnition =
     normalBullIgnition or
     fastBullIgnition


bearIgnition =
     normalBearIgnition or
     fastBearIgnition


if bullIgnition

    cycleState := 2
    cycleDirection := 1

    lastIgnitionBar := bar_index
    lastBullSignalBar := bar_index

    continuationFired := false

    activeEvent :=
         fastBullIgnition
         ? "FAST BULL IGNITION"
         : "BULL IGNITION"

    activeEventColor := bullStrong


if bearIgnition

    cycleState := -2
    cycleDirection := -1

    lastIgnitionBar := bar_index
    lastBearSignalBar := bar_index

    continuationFired := false

    activeEvent :=
         fastBearIgnition
         ? "FAST BEAR IGNITION"
         : "BEAR IGNITION"

    activeEventColor := bearStrong


//====================================================================
// 40 - RELEASE
//====================================================================

bullRelease =
     barstate.isconfirmed and
     cycleState == 2 and
     confirmedScore >= expansionLevel and
     bullSetupScore >= bearSetupScore and
     (
         bullDirection or
         bullBreakoutRecent
     )


bearRelease =
     barstate.isconfirmed and
     cycleState == -2 and
     confirmedScore >= expansionLevel and
     bearSetupScore >= bullSetupScore and
     (
         bearDirection or
         bearBreakoutRecent
     )


if bullRelease

    cycleState := 3

    activeEvent := "BULL RELEASE CONFIRMED"
    activeEventColor := bullColor


if bearRelease

    cycleState := -3

    activeEvent := "BEAR RELEASE CONFIRMED"
    activeEventColor := bearColor


//====================================================================
// 41 - RELEASE QUALITY
//====================================================================

int bullQualityPoints = 0

bullQualityPoints += fastScore >= fastBreakoutLevel ? 2 : 0
bullQualityPoints += confirmedScore >= expansionLevel ? 2 : 0
bullQualityPoints += atrAccelerating ? 1 : 0
bullQualityPoints += bandwidthAccelerating ? 1 : 0
bullQualityPoints += rvol >= fastBreakoutRVOL ? 1 : 0
bullQualityPoints += bullBreakoutRecent ? 1 : 0
bullQualityPoints += bullDirection ? 1 : 0
bullQualityPoints += bullDominant ? 1 : 0


int bearQualityPoints = 0

bearQualityPoints += fastScore >= fastBreakoutLevel ? 2 : 0
bearQualityPoints += confirmedScore >= expansionLevel ? 2 : 0
bearQualityPoints += atrAccelerating ? 1 : 0
bearQualityPoints += bandwidthAccelerating ? 1 : 0
bearQualityPoints += rvol >= fastBreakoutRVOL ? 1 : 0
bearQualityPoints += bearBreakoutRecent ? 1 : 0
bearQualityPoints += bearDirection ? 1 : 0
bearQualityPoints += bearDominant ? 1 : 0


bullBaseQuality =
     math.min(
         100.0,
         bullQualityPoints * 10.0
     )


bearBaseQuality =
     math.min(
         100.0,
         bearQualityPoints * 10.0
     )


baseReleaseQuality =
     bullSetupScore > bearSetupScore
     ? bullBaseQuality
     : bearSetupScore > bullSetupScore
     ? bearBaseQuality
     : math.max(
         bullBaseQuality,
         bearBaseQuality
     )


//====================================================================
// 42 - HTF QUALITY MODIFIER
//====================================================================

float htfModifier = 0.0

if useHTF

    if htfRegime == "EXPANSION" or htfRegime == "EXTREME"
        htfModifier := htfExpansionBonus

    else if htfRegime == "COMPRESSION"
        htfModifier := -htfCompressionPenalty


releaseQuality =
     math.max(
         0.0,
         math.min(
             100.0,
             baseReleaseQuality + htfModifier
         )
     )


//====================================================================
// 43 - QUALITY GRADE
//====================================================================

string qualityGrade = "C"

if releaseQuality >= 80
    qualityGrade := "A+"
else if releaseQuality >= 65
    qualityGrade := "A"
else if releaseQuality >= 50
    qualityGrade := "B"


qualityAllowsContinuation =
     releaseQuality >= continuationQualityMin


//====================================================================
// 44 - CONTINUATION ENGINE
//====================================================================

barsSinceIgnition =
     na(lastIgnitionBar)
     ? 100000
     : bar_index - lastIgnitionBar


bullScoreReacceleration =
     fastScore > fastScore[1] and
     fastSignal >= fastSignal[1]


bearScoreReacceleration =
     fastScore > fastScore[1] and
     fastSignal >= fastSignal[1]


bullSetupReacceleration =
     bullSetupScore > bullSetupScore[1]


bearSetupReacceleration =
     bearSetupScore > bearSetupScore[1]


bullMacroLockOK =
     macroContinuationLock != 1


bearMacroLockOK =
     macroContinuationLock != -1


bullContinuation =
     barstate.isconfirmed and
     showContinuation and
     cycleDirection == 1 and
     not continuationFired and
     bullMacroLockOK and
     barsSinceIgnition >= continuationMinBars and
     fastScore >= continuationScoreMin and
     bullSetupScore >= continuationSetupMin and
     setupDifference >= continuationDominanceMin and
     bullDominant and
     bullDirection and
     close > emaFast and
     bullScoreReacceleration and
     bullSetupReacceleration and
     qualityAllowsContinuation and
     riskAllowsContinuation and
     not bullIgnition and
     not bullRelease


bearContinuation =
     barstate.isconfirmed and
     showContinuation and
     cycleDirection == -1 and
     not continuationFired and
     bearMacroLockOK and
     barsSinceIgnition >= continuationMinBars and
     fastScore >= continuationScoreMin and
     bearSetupScore >= continuationSetupMin and
     setupDifference <= -continuationDominanceMin and
     bearDominant and
     bearDirection and
     close < emaFast and
     bearScoreReacceleration and
     bearSetupReacceleration and
     qualityAllowsContinuation and
     riskAllowsContinuation and
     not bearIgnition and
     not bearRelease


bullContinuationEvent =
     bullContinuation


bearContinuationEvent =
     bearContinuation


if bullContinuationEvent

    continuationFired := true
    macroContinuationLock := 1

    activeEvent := "BULL CONTINUATION"
    activeEventColor := bullColor


if bearContinuationEvent

    continuationFired := true
    macroContinuationLock := -1

    activeEvent := "BEAR CONTINUATION"
    activeEventColor := bearColor


//====================================================================
// 45 - EXPANSION STATE
//====================================================================

bullExpansionEvent =
     barstate.isconfirmed and
     cycleState == 3 and
     confirmedScore >= expansionLevel


bearExpansionEvent =
     barstate.isconfirmed and
     cycleState == -3 and
     confirmedScore >= expansionLevel


if bullExpansionEvent

    cycleState := 4

    if not bullContinuationEvent
        activeEvent := "BULL EXPANSION"
        activeEventColor := bullColor


if bearExpansionEvent

    cycleState := -4

    if not bearContinuationEvent
        activeEvent := "BEAR EXPANSION"
        activeEventColor := bearColor


//====================================================================
// 46 - EXTREME
//====================================================================

bullExtremeEvent =
     barstate.isconfirmed and
     cycleDirection == 1 and
     confirmedScore >= extremeLevel and
     confirmedScore[1] < extremeLevel


bearExtremeEvent =
     barstate.isconfirmed and
     cycleDirection == -1 and
     confirmedScore >= extremeLevel and
     confirmedScore[1] < extremeLevel


if bullExtremeEvent

    cycleState := 5

    activeEvent := "BULL EXTREME EXPANSION"
    activeEventColor := extremeColor


if bearExtremeEvent

    cycleState := -5

    activeEvent := "BEAR EXTREME EXPANSION"
    activeEventColor := extremeColor


//====================================================================
// 47 - EXHAUSTION
//====================================================================

scoreRollingOver =
     confirmedScore < confirmedScore[1] and
     confirmedScore[1] < confirmedScore[2]


bandwidthRollingOver =
     bbWidth < bbWidth[1]


volatilityExhaustion =
     barstate.isconfirmed and
     confirmedScore[1] >= extremeLevel and
     scoreRollingOver and
     bandwidthRollingOver


if volatilityExhaustion

    activeEvent := "VOLATILITY EXHAUSTION"
    activeEventColor := orangeColor


//====================================================================
// 48 - REGIME
//====================================================================

string regime = "NORMAL"

if compressionActive
    regime := "COMPRESSION"
else if confirmedScore >= extremeLevel
    regime := "EXTREME EXPANSION"
else if confirmedScore >= expansionLevel
    regime := "EXPANSION"
else if fastScore >= earlyLevel
    regime := "EARLY EXPANSION"


//====================================================================
// 49 - DIRECTION / BIAS
//====================================================================

string directionText = "NEUTRAL"

if bullDirection
    directionText := "BULLISH"
else if bearDirection
    directionText := "BEARISH"
else if bullDominant
    directionText := "EARLY BULL"
else if bearDominant
    directionText := "EARLY BEAR"


string setupBias = "NEUTRAL"

if bullDominant
    setupBias := "BULL"
else if bearDominant
    setupBias := "BEAR"


string cycleBias = "NEUTRAL"

if cycleDirection == 1
    cycleBias := "BULL"
else if cycleDirection == -1
    cycleBias := "BEAR"


//====================================================================
// 50 - CYCLE STATE TEXT
//====================================================================

string cycleStateText = "WAITING"

if cycleState == 1
    cycleStateText := "BULL ARMED"
else if cycleState == -1
    cycleStateText := "BEAR ARMED"
else if cycleState == 2
    cycleStateText := "BULL IGNITION"
else if cycleState == -2
    cycleStateText := "BEAR IGNITION"
else if cycleState == 3
    cycleStateText := "BULL RELEASE"
else if cycleState == -3
    cycleStateText := "BEAR RELEASE"
else if cycleState == 4
    cycleStateText := "BULL EXPANSION"
else if cycleState == -4
    cycleStateText := "BEAR EXPANSION"
else if cycleState == 5
    cycleStateText := "BULL EXTREME"
else if cycleState == -5
    cycleStateText := "BEAR EXTREME"


//====================================================================
// 51 - FOLLOW THROUGH
//====================================================================

string followThrough = "WEAK"


if falseRisk == "VERY HIGH"
    followThrough := "CAUTION"

else if falseRisk == "HIGH"
    followThrough := "CAUTION"

else if releaseQuality < 50
    followThrough := "WEAK"

else if cycleState == 5 or cycleState == -5
    followThrough :=
         releaseQuality >= 65
         ? "EXTREME"
         : "CAUTION"

else if continuationFired and releaseQuality >= 65
    followThrough := "CONTINUATION"

else if continuationFired and releaseQuality >= 50
    followThrough := "CONFIRMED"

else if cycleState == 4 or cycleState == -4
    followThrough :=
         releaseQuality >= 65
         ? "STRONG"
         : "CONFIRMED"

else if cycleState == 3 or cycleState == -3
    followThrough := "CONFIRMED"

else if cycleState == 2 or cycleState == -2
    followThrough := "BUILDING"

else if cycleState == 1 or cycleState == -1
    followThrough := "ARMED"


//====================================================================
// 52 - OSCILLATOR COLORS
//====================================================================

color regimeColor = neutralColor

if compressionActive
    regimeColor := compressionColor

else if confirmedScore >= extremeLevel
    regimeColor := extremeColor

else if confirmedScore >= expansionLevel
    regimeColor :=
         bullDominant
         ? bullColor
         : bearDominant
         ? bearColor
         : expansionColor

else if fastScore >= earlyLevel
    regimeColor :=
         bullDominant
         ? bullColor
         : bearDominant
         ? bearColor
         : earlyColor


color fastLineColor = neutralColor

if bullDominant
    fastLineColor := bullColor
else if bearDominant
    fastLineColor := bearColor
else if fastScore >= earlyLevel
    fastLineColor := earlyColor


//====================================================================
// 53 - OSCILLATOR
//====================================================================

plot(
     confirmedScore,
     title="Confirmed Volatility Score",
     style=plot.style_columns,
     color=regimeColor,
     linewidth=2
)

plot(
     confirmedSignal,
     title="Confirmed Score Signal",
     color=color.white,
     linewidth=2
)

plot(
     fastSignal,
     title="Fast Regime Score",
     color=fastLineColor,
     linewidth=2
)


//====================================================================
// 54 - LEVELS
//====================================================================

hline(
     extremeLevel,
     "Extreme Expansion",
     color=color.new(extremeColor, 20),
     linestyle=hline.style_dashed
)

hline(
     expansionLevel,
     "Expansion",
     color=color.new(expansionColor, 20),
     linestyle=hline.style_dashed
)

hline(
     earlyLevel,
     "Ignition",
     color=color.new(earlyColor, 10),
     linestyle=hline.style_dotted
)

hline(
     compressionLevel,
     "Compression",
     color=color.new(compressionColor, 20),
     linestyle=hline.style_dashed
)


//====================================================================
// 55 - BACKGROUND
//====================================================================

color paneBackground = na


if showBackground

    if compressionActive
        paneBackground := color.new(compressionColor, 94)

    else if cycleState == 1
        paneBackground := color.new(bullColor, 95)

    else if cycleState == -1
        paneBackground := color.new(bearColor, 95)

    else if cycleState == 2
        paneBackground := color.new(bullColor, 89)

    else if cycleState == -2
        paneBackground := color.new(bearColor, 89)

    else if cycleState == 3 or cycleState == 4
        paneBackground := color.new(bullColor, 94)

    else if cycleState == -3 or cycleState == -4
        paneBackground := color.new(bearColor, 94)

    else if cycleState == 5 or cycleState == -5
        paneBackground := color.new(extremeColor, 92)


bgcolor(paneBackground)


//====================================================================
// 56 - SIGNALS
//====================================================================

plotshape(
     showSignals and bullIgnition,
     title="Bull Ignition",
     text="BULL\nIGNITION",
     style=shape.labelup,
     location=location.bottom,
     color=bullStrong,
     textcolor=color.black,
     size=size.small
)

plotshape(
     showSignals and bearIgnition,
     title="Bear Ignition",
     text="BEAR\nIGNITION",
     style=shape.labeldown,
     location=location.top,
     color=bearStrong,
     textcolor=color.white,
     size=size.small
)

plotshape(
     showSignals and bullRelease,
     title="Bull Release",
     text="BULL\nRELEASE",
     style=shape.labelup,
     location=location.bottom,
     color=bullColor,
     textcolor=color.black,
     size=size.tiny
)

plotshape(
     showSignals and bearRelease,
     title="Bear Release",
     text="BEAR\nRELEASE",
     style=shape.labeldown,
     location=location.top,
     color=bearColor,
     textcolor=color.white,
     size=size.tiny
)


//====================================================================
// 57 - CONTINUATION
//====================================================================

plotshape(
     showContinuation and bullContinuationEvent,
     title="Bull Continuation",
     text="BULL\nCONT",
     style=shape.circle,
     location=location.bottom,
     color=bullColor,
     textcolor=color.black,
     size=size.tiny
)

plotshape(
     showContinuation and bearContinuationEvent,
     title="Bear Continuation",
     text="BEAR\nCONT",
     style=shape.circle,
     location=location.top,
     color=bearColor,
     textcolor=color.white,
     size=size.tiny
)


//====================================================================
// 58 - EXTREME / EXHAUSTION
//====================================================================

plotshape(
     showSignals and
     (
         bullExtremeEvent or
         bearExtremeEvent
     ),
     title="Extreme Expansion",
     text="EXTREME",
     style=shape.diamond,
     location=location.top,
     color=extremeColor,
     textcolor=color.black,
     size=size.tiny
)

plotshape(
     showSignals and volatilityExhaustion,
     title="Volatility Exhaustion",
     text="EXHAUST",
     style=shape.labeldown,
     location=location.top,
     color=orangeColor,
     textcolor=color.black,
     size=size.tiny
)


//====================================================================
// 59 - OPTIONAL INVALIDATIONS
//====================================================================

plotshape(
     showInvalidations and bullCycleInvalidation,
     title="Bear Cycle Invalidated",
     text="BEAR\nINVALID",
     style=shape.labelup,
     location=location.bottom,
     color=bullColor,
     textcolor=color.black,
     size=size.tiny
)

plotshape(
     showInvalidations and bearCycleInvalidation,
     title="Bull Cycle Invalidated",
     text="BULL\nINVALID",
     style=shape.labeldown,
     location=location.top,
     color=bearColor,
     textcolor=color.white,
     size=size.tiny
)


//====================================================================
// 60 - PANEL VALUES
//====================================================================

string atrRegimeText = "NORMAL"

if atrScore >= 80
    atrRegimeText := "EXTREME"
else if atrScore >= 60
    atrRegimeText := "HIGH"
else if atrScore <= 25
    atrRegimeText := "LOW"


string bandwidthText = "STABLE"

if bandwidthAccelerating
    bandwidthText := "ACCELERATING"
else if bandwidthRising
    bandwidthText := "EXPANDING"
else if bbWidth < bbWidth[1]
    bandwidthText := "CONTRACTING"


string breakoutMemoryText =
     bullBreakoutRecent
     ? "BULL RECENT"
     : bearBreakoutRecent
     ? "BEAR RECENT"
     : "NONE"


string htfModifierText =
     htfModifier > 0
     ? "+" + str.tostring(htfModifier, "#")
     : str.tostring(htfModifier, "#")


string continuationText = "WAITING"

if macroContinuationLock == 1
    continuationText := "BULL LOCKED"
else if macroContinuationLock == -1
    continuationText := "BEAR LOCKED"
else if cycleDirection != 0
    continuationText := "ARMED"


string riskAdjustmentText =
     riskReduction > 0
     ? "-" + str.tostring(riskReduction)
     : "0"


//====================================================================
// 61 - PANEL COLORS
//====================================================================

color scoreColor = neutralColor

if confirmedScore >= extremeLevel
    scoreColor := extremeColor
else if confirmedScore >= expansionLevel
    scoreColor := expansionColor
else if confirmedScore < compressionLevel
    scoreColor := compressionColor


color directionColor =
     bullDominant
     ? bullColor
     : bearDominant
     ? bearColor
     : neutralColor


color cycleColor =
     cycleDirection == 1
     ? bullColor
     : cycleDirection == -1
     ? bearColor
     : neutralColor


color dominanceColor =
     bullDominant
     ? bullStrong
     : bearDominant
     ? bearStrong
     : neutralColor


color riskColor = bullColor

if falseRisk == "VERY HIGH"
    riskColor := bearStrong
else if falseRisk == "HIGH"
    riskColor := bearColor
else if falseRisk == "MEDIUM"
    riskColor := orangeColor


color gradeColor = neutralColor

if qualityGrade == "A+"
    gradeColor := bullStrong
else if qualityGrade == "A"
    gradeColor := bullColor
else if qualityGrade == "B"
    gradeColor := extremeColor


color followColor = neutralColor

if followThrough == "EXTREME"
    followColor := extremeColor
else if followThrough == "STRONG" or followThrough == "CONTINUATION"
    followColor := bullColor
else if followThrough == "CONFIRMED"
    followColor := expansionColor
else if followThrough == "BUILDING" or followThrough == "ARMED"
    followColor := earlyColor
else if followThrough == "CAUTION"
    followColor := bearColor


//====================================================================
// 62 - DASHBOARD
//====================================================================

var table dashboard =
     table.new(
         position.top_right,
         2,
         24,
         bgcolor=panelBG,
         frame_color=borderColor,
         frame_width=1,
         border_color=borderColor,
         border_width=1,
         force_overlay=true
     )


if barstate.islast

    if showDashboard

        table.cell(dashboard, 0, 0, "VOLATILITY REGIME ENGINE", bgcolor=panelBG2, text_color=expansionColor)
        table.cell(dashboard, 1, 0, "TRADION V2.1", bgcolor=panelBG2, text_color=color.white)


        table.cell(dashboard, 0, 1, "REGIME", text_color=neutralColor)
        table.cell(dashboard, 1, 1, regime, text_color=regimeColor)


        table.cell(dashboard, 0, 2, "FAST SCORE", text_color=neutralColor)
        table.cell(dashboard, 1, 2, str.tostring(fastScore, "#.0") + " / 100", text_color=fastScore >= earlyLevel ? earlyColor : neutralColor)


        table.cell(dashboard, 0, 3, "CONFIRMED SCORE", text_color=neutralColor)
        table.cell(dashboard, 1, 3, str.tostring(confirmedScore, "#.0") + " / 100", text_color=scoreColor)


        table.cell(dashboard, 0, 4, "ATR REGIME", text_color=neutralColor)
        table.cell(dashboard, 1, 4, atrRegimeText, text_color=atrScore >= 60 ? extremeColor : neutralColor)


        table.cell(dashboard, 0, 5, "BANDWIDTH", text_color=neutralColor)
        table.cell(dashboard, 1, 5, bandwidthText, text_color=bandwidthRising ? expansionColor : neutralColor)


        table.cell(dashboard, 0, 6, "RVOL", text_color=neutralColor)
        table.cell(dashboard, 1, 6, str.tostring(rvol, "#.##") + "x", text_color=rvol >= fastBreakoutRVOL ? bullColor : neutralColor)


        table.cell(dashboard, 0, 7, "DIRECTION", text_color=neutralColor)
        table.cell(dashboard, 1, 7, directionText, text_color=directionColor)


        table.cell(dashboard, 0, 8, "SETUP BIAS", text_color=neutralColor)
        table.cell(dashboard, 1, 8, setupBias, text_color=directionColor)


        table.cell(dashboard, 0, 9, "BULL / BEAR SETUP", text_color=neutralColor)
        table.cell(dashboard, 1, 9, str.tostring(bullSetupScore, "#") + " / " + str.tostring(bearSetupScore, "#"), text_color=directionColor)


        table.cell(dashboard, 0, 10, "DOMINANCE", text_color=neutralColor)
        table.cell(dashboard, 1, 10, dominanceText, text_color=dominanceColor)


        table.cell(dashboard, 0, 11, "BREAKOUT MEMORY", text_color=neutralColor)
        table.cell(dashboard, 1, 11, breakoutMemoryText, text_color=bullBreakoutRecent ? bullColor : bearBreakoutRecent ? bearColor : neutralColor)


        table.cell(dashboard, 0, 12, "CYCLE BIAS", text_color=neutralColor)
        table.cell(dashboard, 1, 12, cycleBias, text_color=cycleColor)


        table.cell(dashboard, 0, 13, "CYCLE STATE", text_color=neutralColor)
        table.cell(dashboard, 1, 13, cycleStateText, text_color=cycleColor)


        table.cell(dashboard, 0, 14, "IGNITION B / S", text_color=neutralColor)
        table.cell(dashboard, 1, 14, str.tostring(bullPoints) + " / " + str.tostring(bearPoints), text_color=bullPoints > bearPoints ? bullColor : bearPoints > bullPoints ? bearColor : neutralColor)


        table.cell(dashboard, 0, 15, "MACRO CONTINUATION", text_color=neutralColor)
        table.cell(dashboard, 1, 15, continuationText, text_color=macroContinuationLock == 1 ? bullColor : macroContinuationLock == -1 ? bearColor : earlyColor)


        table.cell(dashboard, 0, 16, "RELEASE QUALITY", text_color=neutralColor)
        table.cell(dashboard, 1, 16, str.tostring(releaseQuality, "#") + " / 100", text_color=gradeColor)


        table.cell(dashboard, 0, 17, "QUALITY GRADE", text_color=neutralColor)
        table.cell(dashboard, 1, 17, qualityGrade, text_color=gradeColor)


        table.cell(dashboard, 0, 18, "FOLLOW THROUGH", text_color=neutralColor)
        table.cell(dashboard, 1, 18, followThrough, text_color=followColor)


        table.cell(dashboard, 0, 19, "HTF REGIME", text_color=neutralColor)
        table.cell(dashboard, 1, 19, useHTF ? htfRegime : "OFF", text_color=useHTF and htfScore >= expansionLevel ? expansionColor : neutralColor)


        table.cell(dashboard, 0, 20, "HTF QUALITY MOD", text_color=neutralColor)
        table.cell(dashboard, 1, 20, useHTF ? htfModifierText : "0", text_color=htfModifier > 0 ? bullColor : htfModifier < 0 ? orangeColor : neutralColor)


        table.cell(dashboard, 0, 21, "RISK ADJUSTMENT", text_color=neutralColor)
        table.cell(dashboard, 1, 21, riskAdjustmentText, text_color=riskReduction > 0 ? bullColor : neutralColor)


        table.cell(dashboard, 0, 22, "FALSE EXPANSION RISK", text_color=neutralColor)
        table.cell(dashboard, 1, 22, falseRisk, text_color=riskColor)


        table.cell(dashboard, 0, 23, "ACTIVE EVENT", bgcolor=panelBG2, text_color=neutralColor)
        table.cell(dashboard, 1, 23, activeEvent, bgcolor=panelBG2, text_color=activeEventColor)


    else

        table.clear(dashboard, 0, 0, 1, 23)


//====================================================================
// 63 - ALERTS
//====================================================================

alertcondition(
     bullIgnition,
     title="TRADION Bull Ignition",
     message="Volatility Regime Engine [TRADION] V2.1: BULL IGNITION confirmed at candle close."
)

alertcondition(
     bearIgnition,
     title="TRADION Bear Ignition",
     message="Volatility Regime Engine [TRADION] V2.1: BEAR IGNITION confirmed at candle close."
)

alertcondition(
     fastBullIgnition,
     title="TRADION Fast Bull Ignition",
     message="Volatility Regime Engine [TRADION] V2.1: FAST BULL IGNITION confirmed."
)

alertcondition(
     fastBearIgnition,
     title="TRADION Fast Bear Ignition",
     message="Volatility Regime Engine [TRADION] V2.1: FAST BEAR IGNITION confirmed."
)

alertcondition(
     bullRelease,
     title="TRADION Bull Release",
     message="Volatility Regime Engine [TRADION] V2.1: BULL RELEASE confirmed."
)

alertcondition(
     bearRelease,
     title="TRADION Bear Release",
     message="Volatility Regime Engine [TRADION] V2.1: BEAR RELEASE confirmed."
)

alertcondition(
     bullContinuationEvent,
     title="TRADION Bull Continuation",
     message="Volatility Regime Engine [TRADION] V2.1: HIGH QUALITY BULL CONTINUATION confirmed."
)

alertcondition(
     bearContinuationEvent,
     title="TRADION Bear Continuation",
     message="Volatility Regime Engine [TRADION] V2.1: HIGH QUALITY BEAR CONTINUATION confirmed."
)

alertcondition(
     bullCycleInvalidation,
     title="TRADION Bear Cycle Invalidated",
     message="Volatility Regime Engine [TRADION] V2.1: Previous BEAR cycle invalidated."
)

alertcondition(
     bearCycleInvalidation,
     title="TRADION Bull Cycle Invalidated",
     message="Volatility Regime Engine [TRADION] V2.1: Previous BULL cycle invalidated."
)

alertcondition(
     bullExtremeEvent,
     title="TRADION Bull Extreme Expansion",
     message="Volatility Regime Engine [TRADION] V2.1: BULL EXTREME EXPANSION confirmed."
)

alertcondition(
     bearExtremeEvent,
     title="TRADION Bear Extreme Expansion",
     message="Volatility Regime Engine [TRADION] V2.1: BEAR EXTREME EXPANSION confirmed."
)

alertcondition(
     volatilityExhaustion,
     title="TRADION Volatility Exhaustion",
     message="Volatility Regime Engine [TRADION] V2.1: VOLATILITY EXHAUSTION confirmed."
)
````
