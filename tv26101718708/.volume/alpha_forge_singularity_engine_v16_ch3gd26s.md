# Alpha Forge Singularity Engine v1.6

- url: https://www.tradingview.com/script/ch3Gd26S-Alpha-Forge-Singularity-Engine-v1-6/
- type: indicator
- pine_id: PUB;737d73d5da884b678ae5b71a537ced9e
- version: 1.0

## Description

The Singularity Engine is a market energy and force-based oscillator designed to identify moments of abnormal market pressure, directional expansion, compression, aftershock behavior, and potential liquidity trap conditions.

Instead of acting like a traditional momentum oscillator, Singularity attempts to read the market field around price action:

Is energy building?
Is directional force increasing?
Did price enter a high-pressure expansion phase?
Is the market drifting after a major impulse?
Are traders potentially trapped after a sweep?
Has the latest signal reached a user-defined TP or SL?

The goal is not to predict price, but to provide a structured view of market behavior and context.

Core Concept

Singularity uses a custom market energy model built from:

Candle body movement
Total candle range
ATR-based expansion
Volume mass
Close location within the candle
Directional force

This creates a normalized energy score and directional force reading that are used to classify the current market state.

The engine can identify states such as:

Bull Singularity
Bear Singularity
Bull / Bear Force Burst
Charging
Aftershock
Bull / Bear Drift
Recovery
Possible or Confirmed Trap
Coiling
Stable Field
Void / No Edge
Optional Overlay BUY / SELL Signals

Users can choose to display BUY / SELL labels directly on the price chart.

Overlay signals are optional and can be controlled from the settings panel.

Signal modes include:

Conservative
Only uses full Singularity events.

Standard
Uses Singularity events, Force Bursts, and Recovery conditions.

Aggressive
Also allows Charging conditions for earlier but more active signals.

Users can also choose whether grades appear on the overlay labels, such as:

BUY A
SELL A+
BUY B+
Signal Grading

Singularity includes an internal grading model that scores BUY and SELL conditions using energy, directional force, volume mass, range expansion, trend context, recovery behavior, and charging behavior.

Available grades:

A+
A
B+
B
C

Users can filter overlay signals by minimum grade:

A+ only
A and above
B+ and above
B and above
C and above
All

This allows users to control how selective or active the overlay signals are.

TP / SL Tracker

v1.6 includes an optional latest signal trade tracker.

When an overlay BUY or SELL signal appears, the tracker can monitor that latest signal using user-defined take profit and stop loss settings.

Users can choose:

Percent-based TP / SL
ATR-based TP / SL
Track BUY signals
Track SELL signals
Show active entry line
Show active TP / SL lines
Show TP / SL result markers
Keep only the latest TP / SL marker

Example result markers:

TP ✓
SL ✕

The tracker is visual only. It is designed to help users quickly see whether the most recent signal reached the selected TP or SL level.

HUD Dashboard

The Alpha Forge HUD provides a quick readout of the current market field.

The dashboard includes:

Current Field
Energy Score
Live Force
Active Grade
Last Signal
Bars Ago
Trade Status
Result
Last Entry
Last TP
Last SL
Impulse Memory
Mode

This allows users to see whether the market is actively expanding, cooling, drifting, recovering, or entering a higher-risk trap/aftershock phase.

Filters

The indicator includes optional filters for additional control:

EMA trend filter
Higher-timeframe bias filter
Session filter
Grade filter
Signal cooldown
Trap cooldown
Singularity cooldown
Burst cooldown

These settings allow the tool to be adjusted for different markets and timeframes.

Trap Logic

Singularity includes liquidity sweep and rejection logic.

Trap mode can be set to:

Possible
Labels possible long or short trap conditions immediately after a sweep/rejection.

Confirmed
Waits for follow-through confirmation before labeling a trap condition.

This helps users distinguish between early warning signals and more confirmed trap behavior.

Best Used For

The Singularity Engine can be used on:

Stocks
Crypto
Forex
Indices
Intraday charts
Swing-trading timeframes

It is especially useful for traders who want to see abnormal energy events, directional pressure, continuation risk, exhaustion risk, and post-signal TP/SL tracking in one clean interface.

Important Notes

This indicator is not a standalone trading system and does not guarantee future results. The BUY / SELL labels and TP / SL tracker are visual tools based on the selected settings. Users should combine this tool with their own analysis, risk management, and market context.

Signals can behave differently across tickers, timeframes, volatility conditions, and session types. Always test and tune settings before relying on any indicator in live conditions.

Suggested Starting Settings

For general testing:

Overlay Signal Mode: Standard
Minimum Overlay Grade: B+
TP / SL Mode: Percent
Take Profit %: 2.0
Stop Loss %: 1.0
Trap Mode: Possible
Use EMA Trend Filter: Off
Use Higher Timeframe Bias Filter: Off
Use Session Filter: Off
Oscillator Label Mode: Standard

For cleaner signals:

Overlay Signal Mode: Conservative
Minimum Overlay Grade: A
Oscillator Label Mode: Minimal

For more active signals:

Overlay Signal Mode: Aggressive
Minimum Overlay Grade: B

Read the field. Track the force. Follow the expansion.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © Alpha Forge

//@version=6
indicator("Alpha Forge Singularity Engine v1.6", "AF Singularity v1.6", overlay=false, max_labels_count=500, max_lines_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALPHA FORGE COLORS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

color AF_CYAN      = color.rgb(41, 211, 255)
color AF_CYAN_SOFT = color.rgb(28, 200, 255)
color AF_SILVER    = color.rgb(192, 192, 192)
color AF_NEUTRAL   = color.rgb(93, 107, 122)
color AF_MAGENTA   = color.rgb(255, 0, 255)
color AF_ORANGE    = color.rgb(255, 170, 0)
color AF_RED       = color.rgb(255, 70, 70)
color AF_GREEN     = color.rgb(0, 255, 140)
color AF_VOID      = color.rgb(10, 13, 18)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupCore = "Core Engine"
energyLen       = input.int(20, "Energy Window", minval=5, group=groupCore)
normLen         = input.int(100, "Normalization Length", minval=20, group=groupCore)
volumeLen       = input.int(50, "Volume Mass Length", minval=10, group=groupCore)
sensitivity     = input.float(1.8, "Critical Mass Sensitivity", minval=0.5, step=0.1, group=groupCore)
minCritical     = input.float(68.0, "Minimum Singularity Score", minval=40, maxval=100, step=1, group=groupCore)

groupForce = "Directional Force"
forceLen        = input.int(5, "Force Smoothing", minval=1, group=groupForce)
forceThreshold  = input.float(16.0, "Directional Confirmation", minval=1, maxval=80, step=1, group=groupForce)
forceBurstLevel = input.float(60.0, "Force Burst Level", minval=20, maxval=100, step=1, group=groupForce)

groupCharge = "Charging / Compression"
compressionLen  = input.int(30, "Compression Length", minval=10, group=groupCharge)
compressionMult = input.float(0.90, "Compression Factor", minval=0.3, maxval=1.5, step=0.05, group=groupCharge)
chargeMin       = input.float(25.0, "Charging Minimum Energy", minval=5, maxval=80, step=1, group=groupCharge)
chargeMax       = input.float(72.0, "Charging Maximum Energy", minval=20, maxval=95, step=1, group=groupCharge)

groupMemory = "Impulse Memory"
memoryBars      = input.int(100, "Impulse Memory Bars", minval=5, maxval=300, group=groupMemory)
aftershockBars  = input.int(10, "Aftershock Bars", minval=1, maxval=50, group=groupMemory)
driftForceMax   = input.float(25.0, "Drift Max Force", minval=5, maxval=80, step=1, group=groupMemory)

groupTrend = "Trend / Filters"
useTrendFilter = input.bool(false, "Use EMA Trend Filter for BUY / SELL", group=groupTrend)
trendFastLen   = input.int(21, "Fast Trend EMA", minval=1, group=groupTrend)
trendSlowLen   = input.int(50, "Slow Trend EMA", minval=2, group=groupTrend)
useSessionFilter = input.bool(false, "Use Session Filter for BUY / SELL", group=groupTrend)
tradeSession     = input.session("0930-1600", "Signal Session", group=groupTrend)
useMTFFilter     = input.bool(false, "Use Higher Timeframe Bias Filter", group=groupTrend)
mtfTimeframe     = input.timeframe("15", "Higher Timeframe", group=groupTrend)
mtfFastLen       = input.int(21, "HTF Fast EMA", minval=1, group=groupTrend)
mtfSlowLen       = input.int(50, "HTF Slow EMA", minval=2, group=groupTrend)

groupGrade = "Signal Grades"
minOverlayGrade = input.string("B+", "Minimum Overlay Grade", options=["A+", "A", "B+", "B", "C", "All"], group=groupGrade)
showGradeInOverlay = input.bool(true, "Show Grade on BUY / SELL Label", group=groupGrade)

groupTrap = "Trap / Rejection Logic"
trapLookback    = input.int(10, "Liquidity Sweep Lookback", minval=3, group=groupTrap)
wickRatio       = input.float(0.45, "Rejection Wick Ratio", minval=0.1, maxval=0.9, step=0.05, group=groupTrap)
trapCooldown    = input.int(25, "Trap Label Cooldown Bars", minval=1, maxval=100, group=groupTrap)
trapMode        = input.string("Possible", "Trap Mode", options=["Possible", "Confirmed"], group=groupTrap)

groupVisual = "Visuals"
showHUD         = input.bool(true, "Show Alpha Forge HUD", group=groupVisual)
showLastSignalHUD = input.bool(true, "Show Last Signal in HUD", group=groupVisual)
labelMode       = input.string("Standard", "Oscillator Label Mode", options=["Minimal", "Standard", "Full"], group=groupVisual)
showZones       = input.bool(true, "Show Background Zones", group=groupVisual)
showBarColor    = input.bool(false, "Color Price Candles", group=groupVisual)
hudPosition     = input.string("Top Right", "HUD Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=groupVisual)
singularityCooldown = input.int(8, "Singularity Label Cooldown", minval=1, maxval=50, group=groupVisual)
burstCooldown       = input.int(12, "Burst Label Cooldown", minval=1, maxval=50, group=groupVisual)

groupOverlay = "Overlay Signals"
showOverlaySignals = input.bool(true, "Show BUY / SELL on Price Chart", group=groupOverlay)
overlaySignalMode  = input.string("Standard", "Overlay Signal Mode", options=["Conservative", "Standard", "Aggressive"], group=groupOverlay)
buyText            = input.string("BUY", "Buy Label Text", group=groupOverlay)
sellText           = input.string("SELL", "Sell Label Text", group=groupOverlay)
overlayCooldown    = input.int(12, "BUY / SELL Cooldown Bars", minval=1, maxval=100, group=groupOverlay)
buyLabelColor      = input.color(AF_CYAN, "BUY Label Color", group=groupOverlay)
sellLabelColor     = input.color(AF_RED, "SELL Label Color", group=groupOverlay)
buyTextColor       = input.color(color.black, "BUY Text Color", group=groupOverlay)
sellTextColor      = input.color(color.white, "SELL Text Color", group=groupOverlay)

groupRisk = "TP / SL Tracker"
showTPSLMarkers = input.bool(true, "Show TP / SL Marker for Latest Signal", group=groupRisk)
trackBuys       = input.bool(true, "Track BUY Signals", group=groupRisk)
trackSells      = input.bool(true, "Track SELL Signals", group=groupRisk)
tpSlMode        = input.string("Percent", "TP / SL Mode", options=["Percent", "ATR"], group=groupRisk)
tpPercent       = input.float(2.0, "Take Profit %", minval=0.1, step=0.1, group=groupRisk)
slPercent       = input.float(1.0, "Stop Loss %", minval=0.1, step=0.1, group=groupRisk)
tpAtrMult       = input.float(2.0, "Take Profit ATR Multiplier", minval=0.1, step=0.1, group=groupRisk)
slAtrMult       = input.float(1.0, "Stop Loss ATR Multiplier", minval=0.1, step=0.1, group=groupRisk)
showEntryLine   = input.bool(true, "Show Active Entry Line", group=groupRisk)
showTPSLLines   = input.bool(true, "Show Active TP / SL Lines", group=groupRisk)
conservativeSameBar = input.bool(true, "Same-Bar Hit Uses SL First", group=groupRisk)
keepOnlyLatestResult = input.bool(true, "Keep Only Latest TP / SL Marker", group=groupRisk)
tpMarkerText    = input.string("TP ✓", "TP Marker Text", group=groupRisk)
slMarkerText    = input.string("SL ✕", "SL Marker Text", group=groupRisk)
tpMarkerColor   = input.color(AF_GREEN, "TP Marker Color", group=groupRisk)
slMarkerColor   = input.color(AF_RED, "SL Marker Color", group=groupRisk)

groupAlerts = "Alerts"
enableChargingAlerts = input.bool(true, "Charging Alerts", group=groupAlerts)
enableBullAlerts     = input.bool(true, "Bull Singularity Alerts", group=groupAlerts)
enableBearAlerts     = input.bool(true, "Bear Singularity Alerts", group=groupAlerts)
enableTrapAlerts     = input.bool(true, "Trap Risk Alerts", group=groupAlerts)
enableBurstAlerts    = input.bool(true, "Force Burst Alerts", group=groupAlerts)
enableOverlayAlerts  = input.bool(true, "Overlay BUY / SELL Alerts", group=groupAlerts)
enableTPSLAlerts     = input.bool(true, "TP / SL Alerts", group=groupAlerts)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HELPER FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_clamp(_value, _min, _max) =>
    math.max(_min, math.min(_value, _max))

f_norm(_src, _len) =>
    _low = ta.lowest(_src, _len)
    _high = ta.highest(_src, _len)
    _range = _high - _low
    _range == 0 ? 0.0 : f_clamp(((_src - _low) / _range) * 100.0, 0.0, 100.0)

f_pos(_p) =>
    _p == "Top Right" ? position.top_right :
     _p == "Top Left" ? position.top_left :
     _p == "Bottom Right" ? position.bottom_right :
     position.bottom_left

f_can_fire(_lastBar, _cooldown) =>
    na(_lastBar) or bar_index - _lastBar > _cooldown

f_grade_rank(_grade) =>
    _grade == "A+" ? 5 :
     _grade == "A" ? 4 :
     _grade == "B+" ? 3 :
     _grade == "B" ? 2 :
     _grade == "C" ? 1 :
     0

f_grade_from_score(_score) =>
    _score >= 92 ? "A+" :
     _score >= 82 ? "A" :
     _score >= 72 ? "B+" :
     _score >= 60 ? "B" :
     _score >= 45 ? "C" :
     ""

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CORE ENERGY ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

avgVol = ta.sma(volume, volumeLen)
massRaw = avgVol != 0 ? volume / avgVol : 1.0
mass = f_clamp(massRaw, 0.10, 5.00)

bodyPct  = close != 0 ? math.abs(close - open) / close * 100.0 : 0.0
rangePct = close != 0 ? (high - low) / close * 100.0 : 0.0
atrPct   = close != 0 ? ta.atr(14) / close * 100.0 : 0.0

rangeExpansion = atrPct != 0 ? f_clamp(rangePct / atrPct, 0.25, 4.00) : 1.0

barRange = high - low
closeLocation = barRange != 0 ? (close - low) / barRange : 0.5
closeLocationCentered = math.abs(closeLocation - 0.5) * 2.0

structureEnergy = (bodyPct * 0.60) + (rangePct * 0.40)
locationBoost   = 1.0 + closeLocationCentered * 0.35
rawEnergy       = mass * structureEnergy * rangeExpansion * locationBoost

avgEnergy = ta.sma(rawEnergy, energyLen)
stdEnergy = ta.stdev(rawEnergy, energyLen)
criticalRaw = avgEnergy + stdEnergy * sensitivity

energyScore = f_norm(rawEnergy, normLen)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DIRECTIONAL FORCE ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

directionPct = close != 0 ? ((close - open) / close) * 100.0 : 0.0
signedRange = close >= open ? rangePct : -rangePct
closeBias = (closeLocation - 0.5) * 2.0

forceRawBase = ((directionPct * 0.65) + (signedRange * 0.20) + (closeBias * atrPct * 0.15)) * mass
forceRaw = ta.ema(forceRawBase, forceLen)

forceMax = ta.highest(math.abs(forceRaw), normLen)
forceScore = forceMax != 0 ? f_clamp((forceRaw / forceMax) * 100.0, -100.0, 100.0) : 0.0

bullForce = forceScore >= forceThreshold
bearForce = forceScore <= -forceThreshold

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TREND / SESSION / MTF FILTERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

trendFast = ta.ema(close, trendFastLen)
trendSlow = ta.ema(close, trendSlowLen)

bullTrend = trendFast >= trendSlow
bearTrend = trendFast <= trendSlow

inSession = not useSessionFilter or not na(time(timeframe.period, tradeSession))

mtfFast = request.security(syminfo.tickerid, mtfTimeframe, ta.ema(close, mtfFastLen), barmerge.gaps_off, barmerge.lookahead_off)
mtfSlow = request.security(syminfo.tickerid, mtfTimeframe, ta.ema(close, mtfSlowLen), barmerge.gaps_off, barmerge.lookahead_off)

mtfBull = mtfFast >= mtfSlow
mtfBear = mtfFast <= mtfSlow

trendPassBull = not useTrendFilter or bullTrend
trendPassBear = not useTrendFilter or bearTrend

mtfPassBull = not useMTFFilter or mtfBull
mtfPassBear = not useMTFFilter or mtfBear

filterPassBull = trendPassBull and mtfPassBull and inSession
filterPassBear = trendPassBear and mtfPassBear and inSession

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SINGULARITY CONDITIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

singularity = rawEnergy > criticalRaw and energyScore >= minCritical

bullSingularityRaw = singularity and bullForce
bearSingularityRaw = singularity and bearForce
neutralSingularityRaw = singularity and not bullForce and not bearForce

var int lastBullSingLabelBar = na
var int lastBearSingLabelBar = na
var int lastNeutralSingLabelBar = na

bullSingularity = bullSingularityRaw and f_can_fire(lastBullSingLabelBar, singularityCooldown)
bearSingularity = bearSingularityRaw and f_can_fire(lastBearSingLabelBar, singularityCooldown)
neutralSingularity = neutralSingularityRaw and f_can_fire(lastNeutralSingLabelBar, singularityCooldown)

if bullSingularity
    lastBullSingLabelBar := bar_index

if bearSingularity
    lastBearSingLabelBar := bar_index

if neutralSingularity
    lastNeutralSingLabelBar := bar_index

bullForceBurstRaw = forceScore >= forceBurstLevel and energyScore < minCritical
bearForceBurstRaw = forceScore <= -forceBurstLevel and energyScore < minCritical

var int lastBullBurstBar = na
var int lastBearBurstBar = na

bullForceBurst = bullForceBurstRaw and f_can_fire(lastBullBurstBar, burstCooldown)
bearForceBurst = bearForceBurstRaw and f_can_fire(lastBearBurstBar, burstCooldown)

if bullForceBurst
    lastBullBurstBar := bar_index

if bearForceBurst
    lastBearBurstBar := bar_index

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COMPRESSION / CHARGING ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

avgAtrPct = ta.sma(atrPct, compressionLen)
rangeCompression = atrPct < avgAtrPct * compressionMult

volumeCreep = mass > 0.95 or ta.rising(mass, 3)
forceBuilding = math.abs(forceScore) > forceThreshold or ta.rising(math.abs(forceScore), 3)

charging = not singularity and rangeCompression and volumeCreep and forceBuilding and energyScore >= chargeMin and energyScore <= chargeMax

bullCharging = charging and forceScore > 0
bearCharging = charging and forceScore < 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// IMPULSE MEMORY ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

barsSinceBullSing = ta.barssince(bullSingularityRaw)
barsSinceBearSing = ta.barssince(bearSingularityRaw)
barsSinceAnySing  = ta.barssince(singularity)

bullMemory = not na(barsSinceBullSing) and barsSinceBullSing <= memoryBars and (na(barsSinceBearSing) or barsSinceBullSing < barsSinceBearSing)
bearMemory = not na(barsSinceBearSing) and barsSinceBearSing <= memoryBars and (na(barsSinceBullSing) or barsSinceBearSing < barsSinceBullSing)

aftershock = not singularity and not na(barsSinceAnySing) and barsSinceAnySing <= aftershockBars

bullAftershock = aftershock and bullMemory
bearAftershock = aftershock and bearMemory

bullDrift = not singularity and not aftershock and bullMemory and math.abs(forceScore) <= driftForceMax
bearDrift = not singularity and not aftershock and bearMemory and math.abs(forceScore) <= driftForceMax

bullRecovery = bearMemory and forceScore >= forceBurstLevel
bearRecovery = bullMemory and forceScore <= -forceBurstLevel

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRAP / LIQUIDITY SWEEP ENGINE v1.6
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

priorHigh = ta.highest(high[1], trapLookback)
priorLow  = ta.lowest(low[1], trapLookback)

upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

upperReject = barRange > 0 and upperWick / barRange >= wickRatio
lowerReject = barRange > 0 and lowerWick / barRange >= wickRatio

possibleLongTrapRaw = high > priorHigh and close < priorHigh and upperReject
possibleShortTrapRaw = low < priorLow and close > priorLow and lowerReject

confirmedLongTrapRaw = possibleLongTrapRaw[1] and close < low[1]
confirmedShortTrapRaw = possibleShortTrapRaw[1] and close > high[1]

longTrapRaw = trapMode == "Confirmed" ? confirmedLongTrapRaw : possibleLongTrapRaw
shortTrapRaw = trapMode == "Confirmed" ? confirmedShortTrapRaw : possibleShortTrapRaw

var int lastLongTrapBar = na
var int lastShortTrapBar = na

longTrapSignal = longTrapRaw and f_can_fire(lastLongTrapBar, trapCooldown)
shortTrapSignal = shortTrapRaw and f_can_fire(lastShortTrapBar, trapCooldown)

if longTrapSignal
    lastLongTrapBar := bar_index

if shortTrapSignal
    lastShortTrapBar := bar_index

trapRisk = longTrapSignal or shortTrapSignal

longTrapText = trapMode == "Confirmed" ? "CONFIRMED\nLONG TRAP" : "POSSIBLE\nLONG TRAP"
shortTrapText = trapMode == "Confirmed" ? "CONFIRMED\nSHORT TRAP" : "POSSIBLE\nSHORT TRAP"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNAL GRADING ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullBaseScore =
     (energyScore * 0.35) +
     (math.max(forceScore, 0) * 0.35) +
     (mass > 1 ? 10 : 0) +
     (rangeExpansion > 1 ? 8 : 0) +
     (bullTrend ? 7 : 0) +
     (bullRecovery ? 8 : 0) +
     (bullCharging ? 5 : 0)

bearBaseScore =
     (energyScore * 0.35) +
     (math.max(-forceScore, 0) * 0.35) +
     (mass > 1 ? 10 : 0) +
     (rangeExpansion > 1 ? 8 : 0) +
     (bearTrend ? 7 : 0) +
     (bearRecovery ? 8 : 0) +
     (bearCharging ? 5 : 0)

bullSignalScore = f_clamp(bullBaseScore, 0, 100)
bearSignalScore = f_clamp(bearBaseScore, 0, 100)

bullGrade = f_grade_from_score(bullSignalScore)
bearGrade = f_grade_from_score(bearSignalScore)

minGradeRank = minOverlayGrade == "All" ? 0 : f_grade_rank(minOverlayGrade)

bullGradePass = minOverlayGrade == "All" or f_grade_rank(bullGrade) >= minGradeRank
bearGradePass = minOverlayGrade == "All" or f_grade_rank(bearGrade) >= minGradeRank

activeBullSetup = bullSingularityRaw or bullForceBurstRaw or bullRecovery or bullCharging
activeBearSetup = bearSingularityRaw or bearForceBurstRaw or bearRecovery or bearCharging

activeGrade = activeBullSetup ? bullGrade :
     activeBearSetup ? bearGrade :
     ""

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STATE ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string state = "VOID"
color stateColor = AF_NEUTRAL

if bullSingularityRaw
    state := "BULL SINGULARITY"
    stateColor := AF_CYAN
else if bearSingularityRaw
    state := "BEAR SINGULARITY"
    stateColor := AF_RED
else if neutralSingularityRaw
    state := "NEUTRAL SHOCK"
    stateColor := AF_MAGENTA
else if bullForceBurstRaw
    state := "BULL FORCE BURST"
    stateColor := AF_CYAN
else if bearForceBurstRaw
    state := "BEAR FORCE BURST"
    stateColor := AF_RED
else if bullCharging
    state := "BULL CHARGING"
    stateColor := AF_ORANGE
else if bearCharging
    state := "BEAR CHARGING"
    stateColor := AF_ORANGE
else if bullAftershock
    state := "BULL AFTERSHOCK"
    stateColor := AF_MAGENTA
else if bearAftershock
    state := "BEAR AFTERSHOCK"
    stateColor := AF_MAGENTA
else if bullRecovery
    state := "BULL RECOVERY"
    stateColor := AF_CYAN
else if bearRecovery
    state := "BEAR RECOVERY"
    stateColor := AF_RED
else if bullDrift
    state := "BULL DRIFT"
    stateColor := AF_SILVER
else if bearDrift
    state := "BEAR DRIFT"
    stateColor := AF_SILVER
else if longTrapSignal
    state := trapMode == "Confirmed" ? "CONFIRMED LONG TRAP" : "POSSIBLE LONG TRAP"
    stateColor := AF_ORANGE
else if shortTrapSignal
    state := trapMode == "Confirmed" ? "CONFIRMED SHORT TRAP" : "POSSIBLE SHORT TRAP"
    stateColor := AF_ORANGE
else if rangeCompression and energyScore < chargeMin
    state := "COILING"
    stateColor := AF_NEUTRAL
else if energyScore < 15 and math.abs(forceScore) < 15
    state := "VOID / NO EDGE"
    stateColor := AF_NEUTRAL
else
    state := "STABLE FIELD"
    stateColor := AF_SILVER

string mode = "WAIT"

if bullSingularityRaw
    mode := "BULL EXPANSION"
else if bearSingularityRaw
    mode := "BEAR EXPANSION"
else if bullForceBurstRaw
    mode := "WATCH LONG"
else if bearForceBurstRaw
    mode := "WATCH SHORT"
else if bullCharging
    mode := "ARMED LONG"
else if bearCharging
    mode := "ARMED SHORT"
else if bullAftershock or bearAftershock
    mode := "MANAGE RISK"
else if bullRecovery
    mode := "WATCH RECLAIM"
else if bearRecovery
    mode := "WATCH REJECT"
else if bullDrift
    mode := "BULL COOLING"
else if bearDrift
    mode := "BEAR COOLING"
else if longTrapSignal
    mode := "LONGS AT RISK"
else if shortTrapSignal
    mode := "SHORTS AT RISK"
else if rangeCompression
    mode := "BUILDING"
else
    mode := "WAIT"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OVERLAY BUY / SELL SIGNAL ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullOverlayRaw =
     overlaySignalMode == "Conservative" ? bullSingularityRaw :
     overlaySignalMode == "Standard" ? bullSingularityRaw or bullForceBurstRaw or bullRecovery :
     bullSingularityRaw or bullForceBurstRaw or bullRecovery or bullCharging

bearOverlayRaw =
     overlaySignalMode == "Conservative" ? bearSingularityRaw :
     overlaySignalMode == "Standard" ? bearSingularityRaw or bearForceBurstRaw or bearRecovery :
     bearSingularityRaw or bearForceBurstRaw or bearRecovery or bearCharging

bullOverlayFiltered = bullOverlayRaw and filterPassBull and bullGradePass
bearOverlayFiltered = bearOverlayRaw and filterPassBear and bearGradePass

var int lastBuyOverlayBar = na
var int lastSellOverlayBar = na

buyOverlaySignal = showOverlaySignals and bullOverlayFiltered and f_can_fire(lastBuyOverlayBar, overlayCooldown)
sellOverlaySignal = showOverlaySignals and bearOverlayFiltered and f_can_fire(lastSellOverlayBar, overlayCooldown)

if buyOverlaySignal
    lastBuyOverlayBar := bar_index

if sellOverlaySignal
    lastSellOverlayBar := bar_index

buyOverlayLabelText = showGradeInOverlay and bullGrade != "" ? buyText + " " + bullGrade : buyText
sellOverlayLabelText = showGradeInOverlay and bearGrade != "" ? sellText + " " + bearGrade : sellText

// Last signal memory for HUD.
var string lastSignalText = "NONE"
var string lastSignalGrade = ""
var int lastSignalBar = na
var color lastSignalColor = AF_NEUTRAL

if buyOverlaySignal
    lastSignalText := buyOverlayLabelText
    lastSignalGrade := bullGrade
    lastSignalBar := bar_index
    lastSignalColor := AF_CYAN

if sellOverlaySignal
    lastSignalText := sellOverlayLabelText
    lastSignalGrade := bearGrade
    lastSignalBar := bar_index
    lastSignalColor := AF_RED

barsAgoText = na(lastSignalBar) ? "—" : str.tostring(bar_index - lastSignalBar)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TP / SL TRACKER v1.6
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var bool tradeActive = false
var bool tradeResolved = false
var int tradeDir = 0
var float tradeEntry = na
var float tradeTP = na
var float tradeSL = na
var int tradeEntryBar = na
var string tradeGrade = ""
var string tradeSideText = "NONE"
var string tradeResultText = "NONE"
var label lastResultLabel = na

atrNow = ta.atr(14)

newLongTrade = buyOverlaySignal and trackBuys
newShortTrade = sellOverlaySignal and trackSells

if newLongTrade
    tradeActive := true
    tradeResolved := false
    tradeResultText := "ACTIVE"
    tradeDir := 1
    tradeEntry := close
    tradeEntryBar := bar_index
    tradeGrade := bullGrade
    tradeSideText := "BUY"
    tradeTP := tpSlMode == "Percent" ? tradeEntry * (1 + tpPercent / 100.0) : tradeEntry + atrNow * tpAtrMult
    tradeSL := tpSlMode == "Percent" ? tradeEntry * (1 - slPercent / 100.0) : tradeEntry - atrNow * slAtrMult

if newShortTrade
    tradeActive := true
    tradeResolved := false
    tradeResultText := "ACTIVE"
    tradeDir := -1
    tradeEntry := close
    tradeEntryBar := bar_index
    tradeGrade := bearGrade
    tradeSideText := "SELL"
    tradeTP := tpSlMode == "Percent" ? tradeEntry * (1 - tpPercent / 100.0) : tradeEntry - atrNow * tpAtrMult
    tradeSL := tpSlMode == "Percent" ? tradeEntry * (1 + slPercent / 100.0) : tradeEntry + atrNow * slAtrMult

canCheckTrade = tradeActive and not tradeResolved and not na(tradeEntryBar) and bar_index > tradeEntryBar

longTPHit = canCheckTrade and tradeDir == 1 and high >= tradeTP
longSLHit = canCheckTrade and tradeDir == 1 and low <= tradeSL

shortTPHit = canCheckTrade and tradeDir == -1 and low <= tradeTP
shortSLHit = canCheckTrade and tradeDir == -1 and high >= tradeSL

rawTPHit = longTPHit or shortTPHit
rawSLHit = longSLHit or shortSLHit

sameBarBothHit = showTPSLMarkers and rawTPHit and rawSLHit

tpFinalHit = showTPSLMarkers and ((rawTPHit and not rawSLHit) or (sameBarBothHit and not conservativeSameBar))
slFinalHit = showTPSLMarkers and ((rawSLHit and not rawTPHit) or (sameBarBothHit and conservativeSameBar))

hitDir = tradeDir

if tpFinalHit or slFinalHit
    tradeResolved := true
    tradeActive := false
    tradeResultText := tpFinalHit ? "TP HIT" : "SL HIT"

tradeStatus =
     tradeActive ? tradeSideText + " ACTIVE" :
     tradeResolved ? "RESOLVED" :
     "NONE"

tradeTPText = na(tradeTP) ? "—" : str.tostring(tradeTP, format.mintick)
tradeSLText = na(tradeSL) ? "—" : str.tostring(tradeSL, format.mintick)
tradeEntryText = na(tradeEntry) ? "—" : str.tostring(tradeEntry, format.mintick)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LABEL VISIBILITY MODES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

showMinimalLabels = labelMode == "Minimal"
showStandardLabels = labelMode == "Standard"
showFullLabels = labelMode == "Full"

showSingularityLabels = showMinimalLabels or showStandardLabels or showFullLabels
showTrapLabels = showStandardLabels or showFullLabels
showChargeLabels = showStandardLabels or showFullLabels
showBurstLabels = showFullLabels

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

energyColor =
     bullSingularityRaw ? AF_CYAN :
     bearSingularityRaw ? AF_RED :
     neutralSingularityRaw ? AF_MAGENTA :
     bullForceBurstRaw ? AF_CYAN :
     bearForceBurstRaw ? AF_RED :
     charging ? AF_ORANGE :
     aftershock ? color.new(AF_MAGENTA, 20) :
     bullMemory ? color.new(AF_CYAN, 20) :
     bearMemory ? color.new(AF_RED, 20) :
     AF_SILVER

plot(energyScore, "Energy Score", color=color.new(energyColor, 0), style=plot.style_columns, linewidth=2)
plot(forceScore, "Directional Force", color=forceScore >= 0 ? AF_CYAN : AF_RED, linewidth=2)

hline(100, "Max Field", color=color.new(AF_NEUTRAL, 80))
hline(75, "Critical Zone", color=color.new(AF_MAGENTA, 65))
hline(50, "Neutral Field", color=color.new(AF_NEUTRAL, 75))
hline(0, "Zero", color=color.new(AF_NEUTRAL, 80))
hline(-50, "Bear Force", color=color.new(AF_NEUTRAL, 85))
hline(-100, "Max Bear Force", color=color.new(AF_NEUTRAL, 85))

plot(minCritical, "Singularity Threshold", color=color.new(AF_MAGENTA, 35), style=plot.style_linebr)

plot(showEntryLine and tradeActive ? tradeEntry : na, "Active Entry", color=color.new(AF_SILVER, 0), linewidth=1, style=plot.style_linebr, force_overlay=true)
plot(showTPSLLines and tradeActive ? tradeTP : na, "Active TP", color=color.new(AF_GREEN, 0), linewidth=1, style=plot.style_linebr, force_overlay=true)
plot(showTPSLLines and tradeActive ? tradeSL : na, "Active SL", color=color.new(AF_RED, 0), linewidth=1, style=plot.style_linebr, force_overlay=true)

bgcolor(showZones and bullSingularityRaw ? color.new(AF_CYAN, 88) : na)
bgcolor(showZones and bearSingularityRaw ? color.new(AF_RED, 88) : na)
bgcolor(showZones and bullForceBurstRaw ? color.new(AF_CYAN, 92) : na)
bgcolor(showZones and bearForceBurstRaw ? color.new(AF_RED, 92) : na)
bgcolor(showZones and charging ? color.new(AF_ORANGE, 91) : na)
bgcolor(showZones and aftershock ? color.new(AF_MAGENTA, 92) : na)
bgcolor(showZones and trapRisk ? color.new(AF_ORANGE, 88) : na)

barcolor(showBarColor and bullSingularityRaw ? color.new(AF_CYAN, 0) :
     showBarColor and bearSingularityRaw ? color.new(AF_RED, 0) :
     showBarColor and bullForceBurstRaw ? color.new(AF_CYAN, 15) :
     showBarColor and bearForceBurstRaw ? color.new(AF_RED, 15) :
     showBarColor and charging ? color.new(AF_ORANGE, 0) :
     na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OSCILLATOR EVENT LABELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if showSingularityLabels and bullSingularity
    label.new(bar_index, energyScore, "BULL\nSINGULARITY", style=label.style_label_down, textcolor=color.black, color=AF_CYAN, size=size.small)

if showSingularityLabels and bearSingularity
    label.new(bar_index, energyScore, "BEAR\nSINGULARITY", style=label.style_label_down, textcolor=color.white, color=AF_RED, size=size.small)

if showSingularityLabels and neutralSingularity
    label.new(bar_index, energyScore, "NEUTRAL\nSHOCK", style=label.style_label_down, textcolor=color.white, color=AF_MAGENTA, size=size.small)

if showBurstLabels and bullForceBurst
    label.new(bar_index, forceScore, "BULL\nBURST", style=label.style_label_down, textcolor=color.black, color=AF_CYAN, size=size.tiny)

if showBurstLabels and bearForceBurst
    label.new(bar_index, forceScore, "BEAR\nBURST", style=label.style_label_up, textcolor=color.white, color=AF_RED, size=size.tiny)

if showChargeLabels and bullCharging
    label.new(bar_index, energyScore, "BULL\nCHARGING", style=label.style_label_up, textcolor=color.black, color=AF_ORANGE, size=size.tiny)

if showChargeLabels and bearCharging
    label.new(bar_index, energyScore, "BEAR\nCHARGING", style=label.style_label_down, textcolor=color.black, color=AF_ORANGE, size=size.tiny)

if showTrapLabels and shortTrapSignal
    label.new(bar_index, forceScore, shortTrapText, style=label.style_label_up, textcolor=color.black, color=AF_CYAN, size=size.tiny)

if showTrapLabels and longTrapSignal
    label.new(bar_index, forceScore, longTrapText, style=label.style_label_down, textcolor=color.white, color=AF_RED, size=size.tiny)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PRICE CHART BUY / SELL LABELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if buyOverlaySignal
    label.new(bar_index, low, buyOverlayLabelText, xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, textcolor=buyTextColor, color=buyLabelColor, size=size.small, force_overlay=true)

if sellOverlaySignal
    label.new(bar_index, high, sellOverlayLabelText, xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down, textcolor=sellTextColor, color=sellLabelColor, size=size.small, force_overlay=true)

// TP / SL result markers.
if tpFinalHit
    if keepOnlyLatestResult and not na(lastResultLabel)
        label.delete(lastResultLabel)
    lastResultLabel := label.new(bar_index, hitDir == 1 ? high : low, tpMarkerText, xloc=xloc.bar_index, yloc=hitDir == 1 ? yloc.abovebar : yloc.belowbar, style=hitDir == 1 ? label.style_label_down : label.style_label_up, textcolor=color.black, color=tpMarkerColor, size=size.small, force_overlay=true)

if slFinalHit
    if keepOnlyLatestResult and not na(lastResultLabel)
        label.delete(lastResultLabel)
    lastResultLabel := label.new(bar_index, hitDir == 1 ? low : high, slMarkerText, xloc=xloc.bar_index, yloc=hitDir == 1 ? yloc.belowbar : yloc.abovebar, style=hitDir == 1 ? label.style_label_up : label.style_label_down, textcolor=color.white, color=slMarkerColor, size=size.small, force_overlay=true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALPHA FORGE HUD v1.6
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var table hud = table.new(f_pos(hudPosition), 2, 14, bgcolor=color.new(AF_VOID, 5), border_width=1, border_color=AF_CYAN)

if showHUD and barstate.islast
    table.cell(hud, 0, 0, "ALPHA FORGE", text_color=AF_CYAN, text_size=size.small, bgcolor=color.new(AF_VOID, 0))
    table.cell(hud, 1, 0, "SINGULARITY", text_color=AF_CYAN, text_size=size.small, bgcolor=color.new(AF_VOID, 0))

    table.cell(hud, 0, 1, "FIELD", text_color=AF_SILVER, text_size=size.small)
    table.cell(hud, 1, 1, state, text_color=stateColor, text_size=size.small)

    table.cell(hud, 0, 2, "ENERGY", text_color=AF_SILVER, text_size=size.small)
    table.cell(hud, 1, 2, str.tostring(energyScore, "#.0") + " / 100", text_color=energyColor, text_size=size.small)

    table.cell(hud, 0, 3, "LIVE FORCE", text_color=AF_SILVER, text_size=size.small)
    table.cell(hud, 1, 3, str.tostring(forceScore, "#.0"), text_color=forceScore >= 0 ? AF_CYAN : AF_RED, text_size=size.small)

    table.cell(hud, 0, 4, "ACTIVE GRADE", text_color=AF_SILVER, text_size=size.small)
    table.cell(hud, 1, 4, activeGrade == "" ? "—" : activeGrade, text_color=activeGrade == "A+" or activeGrade == "A" ? AF_CYAN : activeGrade == "B+" or activeGrade == "B" ? AF_ORANGE : AF_NEUTRAL, text_size=size.small)

    table.cell(hud, 0, 5, "LAST SIGNAL", text_color=AF_SILVER, text_size=size.small)
    table.cell(hud, 1, 5, showLastSignalHUD ? lastSignalText : "OFF", text_color=showLastSignalHUD ? lastSignalColor : AF_NEUTRAL, text_size=size.small)

    table.cell(hud, 0, 6, "BARS AGO", text_color=AF_SILVER, text_size=size.small)
    table.cell(hud, 1, 6, showLastSignalHUD ? barsAgoText : "OFF", text_color=showLastSignalHUD ? AF_SILVER : AF_NEUTRAL, text_size=size.small)

    table.cell(hud, 0, 7, "TRADE", text_color=AF_SILVER, text_size=size.small)
    table.cell(hud, 1, 7, tradeStatus, text_color=tradeActive ? (tradeDir == 1 ? AF_CYAN : AF_RED) : tradeResolved ? AF_GREEN : AF_NEUTRAL, text_size=size.small)

    table.cell(hud, 0, 8, "RESULT", text_color=AF_SILVER, text_size=size.small)
    table.cell(hud, 1, 8, tradeResultText, text_color=tradeResultText == "TP HIT" ? AF_GREEN : tradeResultText == "SL HIT" ? AF_RED : AF_NEUTRAL, text_size=size.small)

    table.cell(hud, 0, 9, tradeActive ? "ENTRY" : "LAST ENTRY", text_color=AF_SILVER, text_size=size.small)
    table.cell(hud, 1, 9, tradeEntryText, text_color=AF_SILVER, text_size=size.small)

    table.cell(hud, 0, 10, tradeActive ? "TP" : "LAST TP", text_color=AF_SILVER, text_size=size.small)
    table.cell(hud, 1, 10, tradeTPText, text_color=AF_GREEN, text_size=size.small)

    table.cell(hud, 0, 11, tradeActive ? "SL" : "LAST SL", text_color=AF_SILVER, text_size=size.small)
    table.cell(hud, 1, 11, tradeSLText, text_color=AF_RED, text_size=size.small)

    table.cell(hud, 0, 12, "IMPULSE", text_color=AF_SILVER, text_size=size.small)
    table.cell(hud, 1, 12, bullMemory ? "BULL MEMORY" : bearMemory ? "BEAR MEMORY" : "NONE", text_color=bullMemory ? AF_CYAN : bearMemory ? AF_RED : AF_NEUTRAL, text_size=size.small)

    table.cell(hud, 0, 13, "MODE", text_color=AF_SILVER, text_size=size.small)
    table.cell(hud, 1, 13, mode, text_color=stateColor, text_size=size.small)

if not showHUD and barstate.islast
    table.clear(hud, 0, 0, 1, 13)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(enableChargingAlerts and bullCharging, "AF Bull Charging", "Alpha Forge Singularity Engine: Bullish field is charging.")
alertcondition(enableChargingAlerts and bearCharging, "AF Bear Charging", "Alpha Forge Singularity Engine: Bearish field is charging.")

alertcondition(enableBullAlerts and bullSingularityRaw, "AF Bull Singularity", "Alpha Forge Singularity Engine: Bullish singularity detected.")
alertcondition(enableBearAlerts and bearSingularityRaw, "AF Bear Singularity", "Alpha Forge Singularity Engine: Bearish singularity detected.")

alertcondition(enableBurstAlerts and bullForceBurstRaw, "AF Bull Force Burst", "Alpha Forge Singularity Engine: Bullish force burst detected.")
alertcondition(enableBurstAlerts and bearForceBurstRaw, "AF Bear Force Burst", "Alpha Forge Singularity Engine: Bearish force burst detected.")

alertcondition(enableTrapAlerts and shortTrapSignal, "AF Short Trap", "Alpha Forge Singularity Engine: Short trap condition detected.")
alertcondition(enableTrapAlerts and longTrapSignal, "AF Long Trap", "Alpha Forge Singularity Engine: Long trap condition detected.")

alertcondition(enableOverlayAlerts and buyOverlaySignal, "AF Singularity BUY", "Alpha Forge Singularity Engine: BUY signal on price chart.")
alertcondition(enableOverlayAlerts and sellOverlaySignal, "AF Singularity SELL", "Alpha Forge Singularity Engine: SELL signal on price chart.")

alertcondition(enableTPSLAlerts and tpFinalHit, "AF TP Hit", "Alpha Forge Singularity Engine: Latest tracked signal reached take profit.")
alertcondition(enableTPSLAlerts and slFinalHit, "AF SL Hit", "Alpha Forge Singularity Engine: Latest tracked signal hit stop loss.")

alertcondition(singularity, "AF Critical Mass", "Alpha Forge Singularity Engine: Critical market energy detected.")
````
