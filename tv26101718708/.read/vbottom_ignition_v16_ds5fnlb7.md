# VBottom Ignition v1.6

- url: https://www.tradingview.com/script/Ds5fNlb7-VBottom-Ignition-v1-6/
- type: indicator
- pine_id: PUB;267ae8648ac34f158f212f22835f903f
- version: 1.0

## Description

A stock/crypto/instrument that has finished consolidating at the bottom and is beginning an explosive markup phase."

It attempts to capture:

End of downtrend.
Volatility contraction.
Institutional accumulation.
Trend shift.
Momentum ignition.
Early breakout before the crowd notices.

## Source Code

````pine
//@version=6
indicator("VCP + Contextual Continuation + Bottom Ignition v1.6", overlay=true, max_labels_count=500)

// ───── Inputs
baseLen          = input.int(20, "VCP Consolidation Lookback", minval=8)
shelfLen         = input.int(12, "VCP Shelf Lookback", minval=5)
breakoutBuffer   = input.float(0.10, "Breakout/Breakdown Buffer %", step=0.05)

emaFastLen       = input.int(20, "Fast EMA")
emaSlowLen       = input.int(50, "Slow EMA")

rangeTightMax    = input.float(12.0, "Max VCP Base Range %", step=0.5)
shelfFlatMax     = input.float(4.0, "Max Shelf Variation %", step=0.25)

atrLen           = input.int(14, "ATR Length")
atrCompressMax   = input.float(1.15, "ATR Compression Max", step=0.05)

bbLen            = input.int(20, "BB Length")
bbMult           = input.float(2.0, "BB Multiplier")
bbCompressMax    = input.float(1.20, "BB Width Compression Max", step=0.05)

volLen           = input.int(20, "Volume Average Length")
volMultiplier    = input.float(1.05, "Breakout RVOL", step=0.1)

rsiLen           = input.int(14, "RSI Length")
longRsiMin       = input.float(48, "Long Minimum RSI")
shortRsiMax      = input.float(52, "Short Maximum RSI")

minScore         = input.int(4, "Minimum VCP Quality Score", minval=3, maxval=8)
cooldownBars     = input.int(8, "Cooldown Bars", minval=1)

swingLeft        = input.int(2, "Swing Left Bars", minval=1)
swingRight       = input.int(1, "Swing Right Bars", minval=1)
initialAtrStop   = input.float(1.5, "Initial ATR Stop", step=0.1)

tradeDirection   = input.string("Both", "Trade Direction", options=["Both", "Long Only", "Short Only"])
allowPyramidingSignals = input.bool(false, "Allow Continuation Adds While In Trade")
useCloseExit     = input.bool(true, "Exit Only On Candle Close")

useMarketTrendFilter = input.bool(true, "Block Longs In Downtrend / Shorts In Uptrend")
trendFilterMode      = input.string("50/200 EMA", "Market Trend Filter Mode", options=["50/200 EMA", "20/50 EMA"])
trendEmaFastLen      = input.int(50, "Trend Fast EMA", minval=1)
trendEmaSlowLen      = input.int(200, "Trend Slow EMA", minval=1)

// ───── Consolidation Avoidance Filter
useNoTradeConsolidationFilter = input.bool(true, "Avoid Trades During Consolidation")
adxLen          = input.int(14, "ADX Length", minval=1)
adxSmoothing    = input.int(14, "ADX Smoothing", minval=1)
minAdx          = input.float(18.0, "Minimum ADX To Trade", step=0.5)
emaSlopeLen     = input.int(5, "EMA Slope Lookback", minval=1)
minEmaSlopePct  = input.float(0.15, "Minimum EMA Slope %", step=0.05)

// ───── Bottom Reversal / Trend Ignition Inputs
useBottomIgnition          = input.bool(true, "Use Bottom Reversal / Trend Ignition")
bottomLookback             = input.int(80, "Bottom Major Low Lookback", minval=20)
bottomBaseLen              = input.int(20, "Bottom Base Breakout Lookback", minval=8)
bottomNearLowPct           = input.float(35.0, "Max Distance From Major Low %", step=1)
bottomRangeMax             = input.float(45.0, "Max Bottom Base Range %", step=1)
bottomMinScore             = input.int(5, "Minimum Bottom Ignition Score", minval=3, maxval=8)
bottomRsiMin               = input.float(45.0, "Bottom RSI Minimum", step=1)
bottomUseVolumeIfExists    = input.bool(false, "Require Volume For Bottom Ignition If Available")
bottomBypassTrendFilter    = input.bool(true, "Allow Bottom Ignition Before Market Trend Turns")
bottomBypassConsolFilter   = input.bool(true, "Allow Bottom Ignition Before ADX Trend Confirms")

useContinuationScanner = input.bool(true, "Use Continuation Breakout Scanner")
contLen                = input.int(30, "Continuation Base Lookback", minval=10)
contShelfLen           = input.int(10, "Continuation Shelf Lookback", minval=5)
contRangeMax           = input.float(15.0, "Max Continuation Range %", step=0.5)
contShelfFlatMax       = input.float(5.0, "Max Continuation Shelf Variation %", step=0.25)
contMinScore           = input.int(3, "Minimum Continuation Score", minval=2, maxval=7)
useStrictTrend         = input.bool(false, "Use Strict EMA Trend Filter")
maxExtensionPct        = input.float(25.0, "Max Distance From Fast EMA %", step=0.5)

// ───── Contextual Continuation Inputs
useContextContinuation = input.bool(true, "Use Contextual Continuation Strength")
impulseLookback        = input.int(20, "Impulse Lookback", minval=5)
pullbackLookback       = input.int(10, "Pullback Lookback", minval=3)
minImpulsePct          = input.float(8.0, "Minimum Prior Impulse %", step=0.5)
maxPullbackPct         = input.float(55.0, "Max Pullback Of Impulse %", step=5)
minContextScore        = input.int(5, "Minimum Context Score", minval=3, maxval=9)
contextRvolMin         = input.float(0.80, "Context Minimum RVOL", step=0.05)
contextRvolStrong      = input.float(1.00, "Context Strong RVOL", step=0.05)
nearHighPct            = input.float(85.0, "Close Near Impulse High %", step=1)

showDashboard    = input.bool(true, "Show Dashboard")
showEmaFast      = input.bool(false, "Show 20 EMA")
showEmaSlow      = input.bool(false, "Show 50 EMA")
showTrendFilter  = input.bool(false, "Show Market Trend Filter EMAs")
showLongShelf    = input.bool(false, "Show Long Resistance Shelf")
showShortShelf   = input.bool(false, "Show Short Support Shelf")
showLongTrail    = input.bool(true, "Show Long Trailing SL")
showShortTrail   = input.bool(true, "Show Short Trailing SL")
showEntryMarkers = input.bool(true, "Show Entry Markers")
showExitMarkers  = input.bool(false, "Show Exit Markers")

// ───── Core Indicators
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

[plusDI, minusDI, adx] = ta.dmi(adxLen, adxSmoothing)

emaSlopePct = emaFast[emaSlopeLen] > 0 ? math.abs((emaFast - emaFast[emaSlopeLen]) / emaFast[emaSlopeLen]) * 100 : na
trendHasStrength = adx >= minAdx
emaHasSlope = emaSlopePct >= minEmaSlopePct

notConsolidating =
     not useNoTradeConsolidationFilter or
     (trendHasStrength and emaHasSlope)

trendFilterFast = trendFilterMode == "50/200 EMA" ? ta.ema(close, trendEmaFastLen) : emaFast
trendFilterSlow = trendFilterMode == "50/200 EMA" ? ta.ema(close, trendEmaSlowLen) : emaSlow

marketUptrend = close > trendFilterSlow and trendFilterFast > trendFilterSlow
marketDowntrend = close < trendFilterSlow and trendFilterFast < trendFilterSlow

allowLongByMarketTrend = not useMarketTrendFilter or marketUptrend
allowShortByMarketTrend = not useMarketTrendFilter or marketDowntrend

atr = ta.atr(atrLen)
atrAvg = ta.sma(atr, atrLen)
atrCompression = atrAvg > 0 ? atr / atrAvg : na
atrCompressed = atrCompression <= atrCompressMax

bbBasis = ta.sma(close, bbLen)
bbDev = ta.stdev(close, bbLen) * bbMult
bbUpper = bbBasis + bbDev
bbLower = bbBasis - bbDev
bbWidth = bbBasis > 0 ? (bbUpper - bbLower) / bbBasis : na
bbWidthAvg = ta.sma(bbWidth, bbLen)
bbCompression = bbWidthAvg > 0 ? bbWidth / bbWidthAvg : na
bbCompressed = bbCompression <= bbCompressMax

avgVolume = ta.sma(volume, volLen)
rvol = avgVolume > 0 ? volume / avgVolume : 0
volumeExpansion = rvol >= volMultiplier
hasVolume = avgVolume > 0 and volume > 0

rsi = ta.rsi(close, rsiLen)

baseHigh = ta.highest(high, baseLen)
baseLow  = ta.lowest(low, baseLen)
baseRangePct = baseLow > 0 ? ((baseHigh - baseLow) / baseLow) * 100 : na
tightBase = baseRangePct <= rangeTightMax

third = math.max(math.floor(baseLen / 3), 1)

// ───── Long VCP Logic
longTrendOk = useStrictTrend ? close > emaFast and emaFast > emaSlow : close > emaFast

resistanceShelf = ta.highest(high[1], shelfLen)
resistanceShelfLow = ta.lowest(high[1], shelfLen)
resistanceVariation = resistanceShelf > 0 ? ((resistanceShelf - resistanceShelfLow) / resistanceShelf) * 100 : na
flatResistance = resistanceVariation <= shelfFlatMax

longBreakoutLevel = resistanceShelf * (1 + breakoutBuffer / 100)
longBreakout = close > longBreakoutLevel and close > open

longLow1 = ta.lowest(low[third * 2], third)
longLow2 = ta.lowest(low[third], third)
longLow3 = ta.lowest(low, third)
higherLows = longLow1 < longLow2 and longLow2 <= longLow3

longRsiOk = rsi >= longRsiMin
longDistanceFromEma = emaFast > 0 ? ((close - emaFast) / emaFast) * 100 : na
longNotExtended = longDistanceFromEma <= maxExtensionPct

longScore = 0
longScore += longTrendOk ? 1 : 0
longScore += flatResistance ? 1 : 0
longScore += tightBase ? 1 : 0
longScore += higherLows ? 1 : 0
longScore += atrCompressed ? 1 : 0
longScore += bbCompressed ? 1 : 0
longScore += volumeExpansion ? 1 : 0
longScore += longRsiOk ? 1 : 0

// ───── Short VCP Logic
shortTrendOk = useStrictTrend ? close < emaFast and emaFast < emaSlow : close < emaFast

supportShelf = ta.lowest(low[1], shelfLen)
supportShelfHigh = ta.highest(low[1], shelfLen)
supportVariation = supportShelf > 0 ? ((supportShelfHigh - supportShelf) / supportShelf) * 100 : na
flatSupport = supportVariation <= shelfFlatMax

shortBreakdownLevel = supportShelf * (1 - breakoutBuffer / 100)
shortBreakdown = close < shortBreakdownLevel and close < open

shortHigh1 = ta.highest(high[third * 2], third)
shortHigh2 = ta.highest(high[third], third)
shortHigh3 = ta.highest(high, third)
lowerHighs = shortHigh1 > shortHigh2 and shortHigh2 >= shortHigh3

shortRsiOk = rsi <= shortRsiMax
shortDistanceFromEma = emaFast > 0 ? ((emaFast - close) / emaFast) * 100 : na
shortNotExtended = shortDistanceFromEma <= maxExtensionPct

shortScore = 0
shortScore += shortTrendOk ? 1 : 0
shortScore += flatSupport ? 1 : 0
shortScore += tightBase ? 1 : 0
shortScore += lowerHighs ? 1 : 0
shortScore += atrCompressed ? 1 : 0
shortScore += bbCompressed ? 1 : 0
shortScore += volumeExpansion ? 1 : 0
shortScore += shortRsiOk ? 1 : 0

// ───── Continuation Scanner
contHigh = ta.highest(high, contLen)
contLow  = ta.lowest(low, contLen)
contRangePct = contLow > 0 ? ((contHigh - contLow) / contLow) * 100 : na
contTightRange = contRangePct <= contRangeMax

contResistance = ta.highest(high[1], contShelfLen)
contResistanceLow = ta.lowest(high[1], contShelfLen)
contResistanceVar = contResistance > 0 ? ((contResistance - contResistanceLow) / contResistance) * 100 : na
contFlatResistance = contResistanceVar <= contShelfFlatMax

contSupport = ta.lowest(low[1], contShelfLen)
contSupportHigh = ta.highest(low[1], contShelfLen)
contSupportVar = contSupport > 0 ? ((contSupportHigh - contSupport) / contSupport) * 100 : na
contFlatSupport = contSupportVar <= contShelfFlatMax

contLongBreakout = close > contResistance * (1 + breakoutBuffer / 100) and close > open
contShortBreakdown = close < contSupport * (1 - breakoutBuffer / 100) and close < open

contThird = math.max(math.floor(contLen / 3), 1)

contLongLow1 = ta.lowest(low[contThird * 2], contThird)
contLongLow2 = ta.lowest(low[contThird], contThird)
contLongLow3 = ta.lowest(low, contThird)
contHigherLows = contLongLow1 <= contLongLow2 and contLongLow2 <= contLongLow3

contShortHigh1 = ta.highest(high[contThird * 2], contThird)
contShortHigh2 = ta.highest(high[contThird], contThird)
contShortHigh3 = ta.highest(high, contThird)
contLowerHighs = contShortHigh1 >= contShortHigh2 and contShortHigh2 >= contShortHigh3

contLongTrendOk = close > emaFast
contShortTrendOk = close < emaFast

contLongRsiOk = rsi >= longRsiMin
contShortRsiOk = rsi <= shortRsiMax

contLongNotExtended = longDistanceFromEma <= maxExtensionPct
contShortNotExtended = shortDistanceFromEma <= maxExtensionPct

contLongScore = 0
contLongScore += contLongTrendOk ? 1 : 0
contLongScore += contFlatResistance ? 1 : 0
contLongScore += contTightRange ? 1 : 0
contLongScore += contHigherLows ? 1 : 0
contLongScore += volumeExpansion ? 1 : 0
contLongScore += contLongRsiOk ? 1 : 0
contLongScore += bbCompressed or atrCompressed ? 1 : 0

contShortScore = 0
contShortScore += contShortTrendOk ? 1 : 0
contShortScore += contFlatSupport ? 1 : 0
contShortScore += contTightRange ? 1 : 0
contShortScore += contLowerHighs ? 1 : 0
contShortScore += volumeExpansion ? 1 : 0
contShortScore += contShortRsiOk ? 1 : 0
contShortScore += bbCompressed or atrCompressed ? 1 : 0

classicContinuationLong =
     useContinuationScanner and
     contLongBreakout and
     contLongScore >= contMinScore and
     contLongNotExtended

classicContinuationShort =
     useContinuationScanner and
     contShortBreakdown and
     contShortScore >= contMinScore and
     contShortNotExtended

// ───── Contextual Continuation Strength
impulseLow = ta.lowest(low, impulseLookback)
impulseHigh = ta.highest(high, impulseLookback)

priorImpulsePct = impulseLow > 0 ? ((impulseHigh - impulseLow) / impulseLow) * 100 : na
strongPriorImpulse = priorImpulsePct >= minImpulsePct

recentLow = ta.lowest(low, pullbackLookback)
recentHigh = ta.highest(high, pullbackLookback)

pullbackDepthPct = impulseHigh > impulseLow ? ((impulseHigh - recentLow) / (impulseHigh - impulseLow)) * 100 : na
shallowPullback = pullbackDepthPct <= maxPullbackPct

rallyPullbackDepthPct = impulseHigh > impulseLow ? ((recentHigh - impulseLow) / (impulseHigh - impulseLow)) * 100 : na
shallowBearPullback = rallyPullbackDepthPct <= maxPullbackPct

holdingFastEma = close > emaFast
holdingSlowEma = close > emaSlow
emaStackBullish = emaFast > emaSlow

holdingBelowFastEma = close < emaFast
holdingBelowSlowEma = close < emaSlow
emaStackBearish = emaFast < emaSlow

momentumHoldingLong = rsi >= 50
momentumHoldingShort = rsi <= 50

volumeHealthy = rvol >= contextRvolMin
volumeExpansionSoft = rvol >= contextRvolStrong

nearImpulseHigh = impulseHigh > 0 ? close >= impulseHigh * (nearHighPct / 100) : false
nearImpulseLow = impulseLow > 0 ? close <= impulseLow * (2 - nearHighPct / 100) : false

contextLongScore = 0
contextLongScore += strongPriorImpulse ? 1 : 0
contextLongScore += shallowPullback ? 1 : 0
contextLongScore += holdingFastEma ? 1 : 0
contextLongScore += holdingSlowEma ? 1 : 0
contextLongScore += emaStackBullish ? 1 : 0
contextLongScore += momentumHoldingLong ? 1 : 0
contextLongScore += volumeHealthy ? 1 : 0
contextLongScore += volumeExpansionSoft ? 1 : 0
contextLongScore += nearImpulseHigh ? 1 : 0

contextShortScore = 0
contextShortScore += strongPriorImpulse ? 1 : 0
contextShortScore += shallowBearPullback ? 1 : 0
contextShortScore += holdingBelowFastEma ? 1 : 0
contextShortScore += holdingBelowSlowEma ? 1 : 0
contextShortScore += emaStackBearish ? 1 : 0
contextShortScore += momentumHoldingShort ? 1 : 0
contextShortScore += volumeHealthy ? 1 : 0
contextShortScore += volumeExpansionSoft ? 1 : 0
contextShortScore += nearImpulseLow ? 1 : 0

contextualContinuationLong =
     useContinuationScanner and
     useContextContinuation and
     contLongBreakout and
     contextLongScore >= minContextScore and
     longNotExtended

contextualContinuationShort =
     useContinuationScanner and
     useContextContinuation and
     contShortBreakdown and
     contextShortScore >= minContextScore and
     shortNotExtended

continuationLongSignal = classicContinuationLong or contextualContinuationLong
continuationShortSignal = classicContinuationShort or contextualContinuationShort

// ───── Bottom Reversal / Trend Ignition Logic
bottomMajorLow = ta.lowest(low, bottomLookback)

nearBottomZone = bottomMajorLow > 0 ? close <= bottomMajorLow * (1 + bottomNearLowPct / 100) : false

bottomResistance = ta.highest(high[1], bottomBaseLen)
bottomSupport = ta.lowest(low, bottomBaseLen)
bottomBaseRangePct = bottomSupport > 0 ? ((bottomResistance - bottomSupport) / bottomSupport) * 100 : na
bottomBaseAcceptable = bottomBaseRangePct <= bottomRangeMax

bottomBreakout = close > bottomResistance * (1 + breakoutBuffer / 100) and close > open

bottomEmaRecovery = close > emaFast
bottomEmaSlopeTurning = emaFast > emaFast[1]
bottomRsiRecovery = rsi >= bottomRsiMin
bottomRsiCross50 = ta.crossover(rsi, 50)

bottomVolumeOk =
     not bottomUseVolumeIfExists or
     not hasVolume or
     volumeExpansion

bottomScore = 0
bottomScore += nearBottomZone ? 1 : 0
bottomScore += bottomBaseAcceptable ? 1 : 0
bottomScore += bottomBreakout ? 1 : 0
bottomScore += bottomEmaRecovery ? 1 : 0
bottomScore += bottomEmaSlopeTurning ? 1 : 0
bottomScore += bottomRsiRecovery ? 1 : 0
bottomScore += bottomRsiCross50 ? 1 : 0
bottomScore += bottomVolumeOk ? 1 : 0

bottomIgnitionLong =
     useBottomIgnition and
     bottomBreakout and
     bottomScore >= bottomMinScore and
     longNotExtended

// ───── State
var int lastSignalBar = na
canSignal = na(lastSignalBar) or bar_index - lastSignalBar >= cooldownBars

var bool inLong = false
var bool inShort = false
var float longTrailStop = na
var float shortTrailStop = na
var float entryPrice = na

confirmedSwingLow = ta.pivotlow(low, swingLeft, swingRight)
confirmedSwingHigh = ta.pivothigh(high, swingLeft, swingRight)

// ───── Entry Signals
vcpLongSignal =
     longBreakout and
     longScore >= minScore and
     longNotExtended

vcpShortSignal =
     shortBreakdown and
     shortScore >= minScore and
     shortNotExtended

longSignalRaw = vcpLongSignal or continuationLongSignal
shortSignalRaw = vcpShortSignal or continuationShortSignal

longAllowed = tradeDirection == "Both" or tradeDirection == "Long Only"
shortAllowed = tradeDirection == "Both" or tradeDirection == "Short Only"

normalLongGate =
     allowLongByMarketTrend and
     notConsolidating

bottomLongGate =
     (bottomBypassTrendFilter or allowLongByMarketTrend) and
     (bottomBypassConsolFilter or notConsolidating)

longSignal =
     longAllowed and
     canSignal and
     not inShort and
     (not inLong or allowPyramidingSignals) and
     (
         (longSignalRaw and normalLongGate) or
         (bottomIgnitionLong and bottomLongGate)
     )

shortSignal =
     shortAllowed and
     allowShortByMarketTrend and
     notConsolidating and
     shortSignalRaw and
     canSignal and
     not inLong and
     (not inShort or allowPyramidingSignals)

// ───── Long / Short State Management
if longSignal
    inLong := true
    inShort := false
    entryPrice := close
    longTrailStop := math.min(close - atr * initialAtrStop, low)
    shortTrailStop := na
    lastSignalBar := bar_index

if shortSignal
    inShort := true
    inLong := false
    entryPrice := close
    shortTrailStop := math.max(close + atr * initialAtrStop, high)
    longTrailStop := na
    lastSignalBar := bar_index

if inLong and not na(confirmedSwingLow)
    longTrailStop := na(longTrailStop) ? confirmedSwingLow : math.max(longTrailStop, confirmedSwingLow)

if inShort and not na(confirmedSwingHigh)
    shortTrailStop := na(shortTrailStop) ? confirmedSwingHigh : math.min(shortTrailStop, confirmedSwingHigh)

// ───── Exits
longExit = inLong and not na(longTrailStop) and (useCloseExit ? close < longTrailStop : low < longTrailStop)
shortExit = inShort and not na(shortTrailStop) and (useCloseExit ? close > shortTrailStop : high > shortTrailStop)

if longExit
    inLong := false
    longTrailStop := na

if shortExit
    inShort := false
    shortTrailStop := na

// ───── Price Chart Plots Only
plot(showEmaFast ? emaFast : na, "20 EMA", color=color.orange)
plot(showEmaSlow ? emaSlow : na, "50 EMA", color=color.blue)
plot(showTrendFilter ? trendFilterFast : na, "Market Trend Fast EMA", color=color.yellow)
plot(showTrendFilter ? trendFilterSlow : na, "Market Trend Slow EMA", color=color.purple)

plot(showLongShelf ? resistanceShelf : na, "Long Resistance Shelf", color=color.red, linewidth=2, style=plot.style_stepline)
plot(showShortShelf ? supportShelf : na, "Short Support Shelf", color=color.blue, linewidth=2, style=plot.style_stepline)

plot(showLongTrail and inLong ? longTrailStop : na, "Long Trailing SL", color=color.lime, linewidth=2, style=plot.style_linebr)
plot(showShortTrail and inShort ? shortTrailStop : na, "Short Trailing SL", color=color.red, linewidth=2, style=plot.style_linebr)

// ───── Entry Markers
plotshape(showEntryMarkers and longSignal and bottomIgnitionLong, title="LONG Bottom Ignition", style=shape.triangleup, location=location.belowbar, color=color.aqua, size=size.small)
plotshape(showEntryMarkers and longSignal and vcpLongSignal and not bottomIgnitionLong, title="LONG VCP Entry", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small)
plotshape(showEntryMarkers and longSignal and continuationLongSignal and not vcpLongSignal and not bottomIgnitionLong, title="LONG Continuation Entry", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.tiny)

plotshape(showEntryMarkers and shortSignal and vcpShortSignal, title="SHORT VCP Entry", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)
plotshape(showEntryMarkers and shortSignal and continuationShortSignal and not vcpShortSignal, title="SHORT Continuation Entry", style=shape.triangledown, location=location.abovebar, color=color.maroon, size=size.tiny)

// ───── Optional Exit Markers
plotshape(showExitMarkers and longExit, title="LONG Exit", style=shape.triangleup, location=location.belowbar, color=color.red, size=size.tiny)
plotshape(showExitMarkers and shortExit, title="SHORT Exit", style=shape.triangledown, location=location.abovebar, color=color.lime, size=size.tiny)

// ───── Dashboard
dashPosition = input.string("Middle Right", "Dashboard Position", options=["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"])

dashPos =
     dashPosition == "Top Right" ? position.top_right :
     dashPosition == "Top Left" ? position.top_left :
     dashPosition == "Middle Right" ? position.middle_right :
     dashPosition == "Middle Left" ? position.middle_left :
     dashPosition == "Bottom Right" ? position.bottom_right :
     position.bottom_left

var table dash = table.new(dashPos, 2, 13, border_width=1, frame_width=2)

headerBg  = color.rgb(28, 34, 48)
labelBg   = color.rgb(24, 29, 39)
valueBg   = color.rgb(18, 22, 30)
bullBg    = color.rgb(0, 120, 80)
bearBg    = color.rgb(150, 35, 35)
neutralBg = color.rgb(90, 90, 90)
warnBg    = color.rgb(170, 120, 20)
igniteBg  = color.rgb(0, 120, 150)

txtWhite = color.white
txtMuted = color.rgb(190, 195, 205)

statusBg(_txt) =>
    _txt == "LONG" or _txt == "UP" or _txt == "BUY" or _txt == "TRADE" ? bullBg :
     _txt == "SHORT" or _txt == "DOWN" or _txt == "SELL" or _txt == "BLOCK" ? bearBg :
     _txt == "IGNITE" ? igniteBg :
     _txt == "EXIT" ? warnBg :
     neutralBg

if showDashboard and barstate.islast
    table.clear(dash, 0, 0, 1, 12)

    posTxt = inLong ? "LONG" : inShort ? "SHORT" : "WAIT"
    trendTxt = marketUptrend ? "UP" : marketDowntrend ? "DOWN" : "SIDE"
    sigTxt = bottomIgnitionLong and longSignal ? "IGNITE" : longSignal ? "BUY" : shortSignal ? "SELL" : longExit or shortExit ? "EXIT" : "-"
    cooldownTxt = canSignal ? "READY" : "COOLDOWN"
    consolidationTxt = notConsolidating ? "TRADE" : "BLOCK"

    activeTrail = inLong ? longTrailStop : inShort ? shortTrailStop : na
    riskPct = inLong and not na(activeTrail) ? ((close - activeTrail) / close) * 100 :
              inShort and not na(activeTrail) ? ((activeTrail - close) / close) * 100 : na

    table.cell(dash, 0, 0, "IGNITION", text_color=txtWhite, bgcolor=headerBg, text_size=size.small)
    table.cell(dash, 1, 0, timeframe.period, text_color=txtWhite, bgcolor=headerBg, text_size=size.small)

    table.cell(dash, 0, 1, "Position", text_color=txtMuted, bgcolor=labelBg, text_size=size.small)
    table.cell(dash, 1, 1, posTxt, text_color=txtWhite, bgcolor=statusBg(posTxt), text_size=size.small)

    table.cell(dash, 0, 2, "Trend", text_color=txtMuted, bgcolor=labelBg, text_size=size.small)
    table.cell(dash, 1, 2, trendTxt, text_color=txtWhite, bgcolor=statusBg(trendTxt), text_size=size.small)

    table.cell(dash, 0, 3, "Signal", text_color=txtMuted, bgcolor=labelBg, text_size=size.small)
    table.cell(dash, 1, 3, sigTxt, text_color=txtWhite, bgcolor=statusBg(sigTxt), text_size=size.small)

    table.cell(dash, 0, 4, "Consol", text_color=txtMuted, bgcolor=labelBg, text_size=size.small)
    table.cell(dash, 1, 4, consolidationTxt, text_color=txtWhite, bgcolor=statusBg(consolidationTxt), text_size=size.small)

    table.cell(dash, 0, 5, "ADX/Slope", text_color=txtMuted, bgcolor=labelBg, text_size=size.small)
    table.cell(dash, 1, 5, str.tostring(adx, "#.##") + " / " + str.tostring(emaSlopePct, "#.##") + "%", text_color=txtWhite, bgcolor=valueBg, text_size=size.small)

    table.cell(dash, 0, 6, "VCP L/S", text_color=txtMuted, bgcolor=labelBg, text_size=size.small)
    table.cell(dash, 1, 6, str.tostring(longScore) + " / " + str.tostring(shortScore), text_color=txtWhite, bgcolor=valueBg, text_size=size.small)

    table.cell(dash, 0, 7, "Cont L/S", text_color=txtMuted, bgcolor=labelBg, text_size=size.small)
    table.cell(dash, 1, 7, str.tostring(contLongScore) + " / " + str.tostring(contShortScore), text_color=txtWhite, bgcolor=valueBg, text_size=size.small)

    table.cell(dash, 0, 8, "Ctx L/S", text_color=txtMuted, bgcolor=labelBg, text_size=size.small)
    table.cell(dash, 1, 8, str.tostring(contextLongScore) + " / " + str.tostring(contextShortScore), text_color=txtWhite, bgcolor=valueBg, text_size=size.small)

    table.cell(dash, 0, 9, "Bottom", text_color=txtMuted, bgcolor=labelBg, text_size=size.small)
    table.cell(dash, 1, 9, str.tostring(bottomScore) + " / 8", text_color=txtWhite, bgcolor=bottomIgnitionLong ? igniteBg : valueBg, text_size=size.small)

    table.cell(dash, 0, 10, "RVOL / RSI", text_color=txtMuted, bgcolor=labelBg, text_size=size.small)
    table.cell(dash, 1, 10, str.tostring(rvol, "#.##") + " / " + str.tostring(rsi, "#.##"), text_color=txtWhite, bgcolor=volumeExpansion ? bullBg : neutralBg, text_size=size.small)

    table.cell(dash, 0, 11, "Cooldown", text_color=txtMuted, bgcolor=labelBg, text_size=size.small)
    table.cell(dash, 1, 11, cooldownTxt, text_color=txtWhite, bgcolor=canSignal ? bullBg : warnBg, text_size=size.small)

    table.cell(dash, 0, 12, "SL / Risk", text_color=txtMuted, bgcolor=labelBg, text_size=size.small)
    table.cell(dash, 1, 12, not na(activeTrail) ? str.tostring(activeTrail, "#.####") + " / " + str.tostring(riskPct, "#.##") + "%" : "-", text_color=txtWhite, bgcolor=not na(activeTrail) ? warnBg : neutralBg, text_size=size.small)

if not showDashboard and barstate.islast
    table.clear(dash, 0, 0, 1, 12)

// ───── Alerts
alertcondition(longSignal, title="LONG Entry", message="LONG BUY: VCP/Continuation/Bottom Ignition breakout on {{ticker}} at {{close}}")
alertcondition(shortSignal, title="SHORT Entry", message="SHORT SELL: VCP/Continuation breakdown on {{ticker}} at {{close}}")
alertcondition(longExit, title="LONG Exit", message="LONG EXIT: Close below trailing SL on {{ticker}} at {{close}}")
alertcondition(shortExit, title="SHORT Exit", message="SHORT EXIT: Close above trailing SL on {{ticker}} at {{close}}")
````
