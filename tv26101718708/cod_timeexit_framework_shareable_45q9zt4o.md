# COD - Time-Exit Framework (Shareable)

- url: https://www.tradingview.com/script/45q9Zt4o-COD-Time-Exit-Framework-Shareable/
- type: indicator
- pine_id: PUB;0493d18ac1174e288dc09a6dbf5f327d
- version: 6.0

## Description

COD - Time-Exit Framework (Shareable) is a multi-timeframe trade-management overlay built for traders who manage exits by both time and momentum.
It combines a structured 10-23 bar decision window, EMA context (10/55/100), and Squeeze Momentum + ADX behavior to help you avoid overholding and only re-enter when confirmation returns.

What it does
Time-based framework

Tracks bars from your entry anchor
Highlights the active management window (minBars to maxBars)
Flags thesis decay after the max-bar threshold
Trend context with EMAs

Plots EMA 10, EMA 55, and EMA 100
Supports target logic around EMA pullback zones
Momentum/strength confirmation

Squeeze Momentum turning-point dots
Green dot logic filtered to negative-to-positive momentum transitions
ADX slope checks to detect strengthening vs weakening trend pressure
Exit and re-entry workflow

Optional post-exit No Buy Mode
Re-entry gate requires confirmation (with optional strict 2-bar mode)
BUY OK marker appears only when reconfirmation criteria are met
Target zone engine

Three modes:
Manual (fixed user-defined zone)
Dynamic EMA (Snapshot on Exit) (captures EMA55/EMA100 at trigger)
Dynamic EMA (Live) (zone updates with moving EMAs)
Configurable zone duration in bars
Visual start/end labels for expected move window
Chart clarity controls

Minimal Mode: EMAs + SM dots only
Full mode: adds timing markers, zone overlays, and diagnostic states
Best use case
Designed for swing/intraday management where entries are confirmed by your system, and exits are controlled by:

elapsed bars,
momentum rollover, and
trend-strength behavior.
Notes
This is a decision-support tool, not automated financial advice.
Works on 4H, D, W, M, and other chart intervals.
Tune lengths/thresholds per market and volatility regime.

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © newbnet
// v1.48 - Alert title COD B/S (not Exit). Buy/Sell alert side. BTCUSD + BTCUSDC.
// Multi-TF buy scan (same reentry gate): see cod-buy-scanner.pine in this repo.

//@version=6
indicator("COD - Buy and Sell", "COD B/S", overlay = true)

//------------------------------------------------------------------------------
// Settings (2 groups)
//------------------------------------------------------------------------------
g0 = "COD · Chart"
g1 = "COD · Filters"

autoDetect = input.bool(true, "Auto cycle (SM green resets)", group = g0, tooltip = "Each squeeze SM green dot starts a new cycle.")

adxStrength = input.float(23.0, "ADX strength", minval = 1.0, step = 0.5, group = g1, tooltip = "Personal line on every timeframe: 0–23 weak/no trend, above 23 = strength only (not direction).")
macdFastLen = input.int(10, "CM Ult fast", minval = 1, inline = "cm", group = g1, tooltip = "Must match CM_MacD_Ult_MTF on the chart.")
macdSlowLen = input.int(14, "slow", minval = 1, inline = "cm", group = g1)
macdSigLen = input.int(2, "signal", minval = 1, inline = "cm", group = g1)
smMacdMode = input.string("Off (squeeze only)", "SM green + MACD", options = ["Off (squeeze only)", "Squeeze + MACD > signal", "Squeeze + MACD cross (same bar)", "Squeeze + MACD cross (within N bars)", "MACD cross + mom<0 (CM-style)"], group = g1, tooltip = "Off = squeeze SM+. CM-style = MACD bull cross while squeeze momentum is still < 0.")
smSkipWeakCycleReset = input.bool(true, "Skip cycle reset on weak SM+", group = g1, tooltip = "Amber SM+ (MACD bull cross while line and signal still below zero) does not reset the cycle.")
dotsCloseOnly = input.bool(true, "Closed bar only", group = g1, tooltip = "No green / orange / red on the live bar. Wait for the clock.")
hideDevelopedBuys = input.bool(true, "Hide developed buys", group = g1, tooltip = "No green / orange when squeeze has already released. Keep compressed or the turn-up from red.")
redsHigherWick = input.bool(true, "Reds = higher wick", group = g1, tooltip = "Hide a new red if its high is lower than the last red in the lookback.")
redWickLook = input.int(12, "Red wick lookback", minval = 3, maxval = 50, group = g1)
alertQuietOn = input.bool(true, "Quiet 9 PM–5 AM", group = g1, tooltip = "No green/red alerts while you sleep. Clock below, not UTC unless you pick UTC.")
alertQuietSess = input.session("2100-0500", "Quiet hours", group = g1)
alertTz = input.string("America/Los_Angeles", "Alert clock", options = ["America/Los_Angeles", "UTC", "America/New_York"], group = g1)
alertSide = input.string("Both", "Alert side", options = ["Both", "Buy only", "Sell only"], group = g1, tooltip = "While long, use Sell only so buy/zero-cross pings do not look like exits. Prefer two separate TradingView alerts (green vs red) instead of Any alert().")

//------------------------------------------------------------------------------
// Fixed internals (previous defaults — not shown in settings)
//------------------------------------------------------------------------------
minimalMode = false
tradeModeOn = false
minBars = 10
maxBars = 23
fastEmaLen = 10
targetEmaLen = 55
slowEmaLen = 100
showTargetZone = true
targetZoneBars = 40
targetZoneMode = "Dynamic EMA (Live)"
targetUpper = 72606.0
targetLower = 71200.0
strictReentry = false
showLastLowLine = false
swingLookback = 20
entryTime = timestamp("2026-04-13T00:00:00")
exitAnchorTime = timestamp("2026-04-15T00:00:00")
tmEntry = 0.0
tmEntryMode = "Swing Low Body Mid"
tmEntryMaxGapPct = 8.0
tmEntryGapPresets = 5.0
tmDipBotMode = "Last Swing Low"
tmDipBotManual = 0.0
tmDipTopMode = "T0 Body High"
tmDipTopManual = 0.0
tmTargetMode = "Last Top Before T0"
tmTargetManual = 0.0
tmTargetLookback = 50
tmTargetPreT0Lookback = 30
tmPivotBars = 3
tmToleranceATR = 0.25
tmSlPct = 2.0
tmSlBase = "Last Swing Low"
tmSlEma100Cap = false
tmSlMinBelowPct = 0.1
tmSlAlignTolerance = true
tmRedExitDots = 2
tmSl1mManual = 12500.0
tmOnlyAddZoneBox = true
adxLen = 14
adxSmooth = 14
sqLen = 20
sqMult = 2.0
kcLen = 20
kcMult = 1.5
useTrueRange = true
macdCrossLookback = 5
smMinusMacdLookback = 3
smMinusStrictCount = true
smAmberOnlyVisual = false

fastColor = color.new(#00E676, 0)
targetColor = color.new(#FF1744, 0)
slowColor = color.new(#E8E8E8, 0)
t0Color = color.new(#40C4FF, 0)
minMarkerColor = color.new(#FFEB3B, 0)
maxMarkerColor = color.new(#FF5252, 0)
exitMarkerColor = color.new(#FFA726, 0)
zoneLabelColor = color.new(#FFA726, 0)
lastLowColor = color.new(#F06292, 0)
windowFill = color.new(#FFEB3B, 70)
decayFill = color.new(#FF5252, 72)
postExitFill = color.new(#FFB74D, 74)
noBuyFill = color.new(#EC407A, 80)
targetZoneFill = color.new(#FFA726, 74)

chartProfile = timeframe.period == "240" ? "4H" : timeframe.period == "1D" ? "1D" : timeframe.period == "1W" ? "1W" : timeframe.period == "1M" ? "1M" : "Custom"
activeProfile = chartProfile
minBarsEff         = activeProfile == "4H" ? 10 : activeProfile == "1D" ? 5 : activeProfile == "1W" ? 3 : activeProfile == "1M" ? 10 : minBars
maxBarsEff         = activeProfile == "4H" ? 23 : activeProfile == "1D" ? 12 : activeProfile == "1W" ? 8 : activeProfile == "1M" ? 23 : maxBars
adxStrengthEff     = adxStrength
swingLookbackEff   = activeProfile == "4H" ? 20 : activeProfile == "1D" ? 30 : activeProfile == "1W" ? 20 : activeProfile == "1M" ? 12 : swingLookback
targetLookbackEff  = activeProfile == "4H" ? 50 : activeProfile == "1D" ? 90 : activeProfile == "1W" ? 26 : activeProfile == "1M" ? 18 : tmTargetLookback
targetPreT0LookbackEff = activeProfile == "4H" ? math.min(tmTargetPreT0Lookback, 50) : activeProfile == "1D" ? math.min(tmTargetPreT0Lookback, 30) : activeProfile == "1W" ? math.min(tmTargetPreT0Lookback, 12) : activeProfile == "1M" ? math.max(tmTargetPreT0Lookback, 48) : tmTargetPreT0Lookback
tmEntryMaxGapPctEff = activeProfile == "4H" or activeProfile == "1D" or activeProfile == "1W" or activeProfile == "1M" ? tmEntryGapPresets : tmEntryMaxGapPct
tmTfMatch = true

//------------------------------------------------------------------------------
// Core calculations
//------------------------------------------------------------------------------
ema10 = ta.ema(close, fastEmaLen)
ema55 = ta.ema(close, targetEmaLen)
ema100 = ta.ema(close, slowEmaLen)
plot(ema10, "EMA10", color = fastColor, linewidth = 2)
plot(ema55, "EMA55", color = targetColor, linewidth = 2)
plot(ema100, "EMA100", color = slowColor, linewidth = 2)

upMove = ta.change(high)
downMove = -ta.change(low)
plusDM = upMove > downMove and upMove > 0 ? upMove : 0.0
minusDM = downMove > upMove and downMove > 0 ? downMove : 0.0
tr = ta.rma(ta.tr, adxLen)
plusDI = 100 * ta.rma(plusDM, adxLen) / tr
minusDI = 100 * ta.rma(minusDM, adxLen) / tr
dx = 100 * math.abs(plusDI - minusDI) / math.max(plusDI + minusDI, 1e-10)
adx = ta.rma(dx, adxSmooth)
adxSlope = adx - adx[1]
adxLosingStrength = adxSlope < 0
adxCrossStrength = ta.crossover(adx, adxStrengthEff)

bbBasis = ta.sma(close, sqLen)
bbDev = sqMult * ta.stdev(close, sqLen)
upperBB = bbBasis + bbDev
lowerBB = bbBasis - bbDev

kcBasis = ta.sma(close, kcLen)
rangeSrc = useTrueRange ? ta.tr : high - low
rangeMA = ta.sma(rangeSrc, kcLen)
upperKC = kcBasis + rangeMA * kcMult
lowerKC = kcBasis - rangeMA * kcMult

sqzOn = lowerBB > lowerKC and upperBB < upperKC
sqzOff = lowerBB < lowerKC and upperBB > upperKC

midpoint = math.avg(math.avg(ta.highest(high, kcLen), ta.lowest(low, kcLen)), ta.sma(close, kcLen))
sqMomentum = ta.linreg(close - midpoint, kcLen, 0)
sqTurningUp = sqMomentum > sqMomentum[1] and sqMomentum[1] <= sqMomentum[2]
sqTurningDown = sqMomentum < sqMomentum[1] and sqMomentum[1] >= sqMomentum[2]
sqRedAndCurvingDown = sqMomentum < 0 and sqMomentum < sqMomentum[1]
macdLine = ta.ema(close, macdFastLen) - ta.ema(close, macdSlowLen)
signalLine = ta.sma(macdLine, macdSigLen)
macdHist = macdLine - signalLine
macdBullCross = ta.crossover(macdLine, signalLine)
macdBearCross = ta.crossunder(macdLine, signalLine)
macdHistBear = ta.crossunder(macdHist, 0)
barsSinceMacdBull = ta.barssince(macdBullCross)
barsSinceMacdBear = ta.barssince(macdBearCross)
sqGreenRaw = sqTurningUp and sqMomentum < 0
sqGreenCm = macdBullCross and sqMomentum < 0
macdRecentCross = not na(barsSinceMacdBull) and barsSinceMacdBull < macdCrossLookback
sqGreenSqMacd =
     smMacdMode == "Off (squeeze only)" ? true :
     smMacdMode == "Squeeze + MACD > signal" ? macdLine > signalLine :
     smMacdMode == "Squeeze + MACD cross (same bar)" ? macdBullCross :
     smMacdMode == "Squeeze + MACD cross (within N bars)" ? macdRecentCross :
     false
sqGreenDot = smMacdMode == "MACD cross + mom<0 (CM-style)" ? sqGreenCm : (sqGreenRaw and sqGreenSqMacd)
sqRedDot = sqTurningDown
barsSinceSqNeg = ta.barssince(sqMomentum <= 0)
squeezeJustTurnedPlus = sqMomentum > 0 and not na(barsSinceSqNeg) and barsSinceSqNeg <= 4
// SM− strict (counts, thesis, bundled alert): ADX weak + recent bear cross + MACD line under zero, excluding same-bar bear cross above zero.
smMinusMacdRecent = not na(barsSinceMacdBear) and barsSinceMacdBear < smMinusMacdLookback
smMinusMacdBearCrossAboveZero = macdBearCross and macdLine > 0 and signalLine > 0
smMinusStrict = sqRedDot and adx < adxStrengthEff and smMinusMacdRecent and macdLine < 0 and not smMinusMacdBearCrossAboveZero
sqRedForCount = smMinusStrictCount ? smMinusStrict : sqRedDot
sqRedForThesis = smMinusStrictCount ? smMinusStrict : sqRedDot
// SM− chart colors vs white MACD zero: amber only while MACD line 1 is still above zero; at or below zero always red (never amber there).
smMinusMacdLineAboveZero = sqRedDot and not na(macdLine) and macdLine > 0
smMinusMacdLineBelowOrAtZero = sqRedDot and not na(macdLine) and macdLine <= 0
// MACD bull cross while line + signal still under zero, WITH squeeze turning up → buy (was orange; user reads this as a good buy).
smPlusMacdCrossBelowZero = macdBullCross and macdLine < 0 and signalLine < 0
smPlusUnconfirmed = sqGreenDot and smPlusMacdCrossBelowZero
smPlusConfirmed = sqGreenDot and not smPlusUnconfirmed
sqGreenCycleReset = sqGreenDot and (not smSkipWeakCycleReset or not smPlusUnconfirmed)
// MACD already crossed (line > signal) below zero, squeeze NOT green yet → lead buy (e.g. 7/20/26 until squeeze catches up).
// Real CM Ult 0-line cross only (not a slow grind toward 0). Draw 2 bars back so 8/24 cross → 8/10 call.
macdZeroCross = ta.crossover(macdLine, 0)
macdLeadBuy = macdLine > signalLine and not sqGreenRaw and macdLine < 0 and not macdZeroCross
macdLeadBuyEvent = macdLeadBuy and not macdLeadBuy[1]
// Sell / exit (downtrend): CM Ult 10/14/2 MACD + hist bear on this bar. EMA10 under EMA55, squeeze red, ADX > 23.
sellExitCircle = macdBearCross and macdHistBear and ema10 < ema55 and sqRedDot and adx > adxStrengthEff
// Light red (downtrend): same cross, squeeze still plus/green, ADX > 23, hunt EMA55. e.g. 05/25.
sellLightRed = macdBearCross and macdHistBear and ema10 < ema55 and adx > adxStrengthEff and sqMomentum > 0 and not sqRedDot
// Uptrend: CM Ult red MACD/hist cross while EMAs still bullish.
// Light = squeeze just came off the negative side (e.g. 06/09/25). Red = developed plus-side squeeze (e.g. 12/16/24).
// 08/04/25 = failed one-bar MACD reclaim (green cross right after a red cross) at the highs.
cmUltBear = macdBearCross and macdHistBear
uptrendEma = ema10 > ema55
sellUptrendLight = cmUltBear and uptrendEma and squeezeJustTurnedPlus
failedMacdReclaim = macdBullCross and macdBearCross[1] and uptrendEma and sqMomentum > 0
sellUptrendRed = failedMacdReclaim or (cmUltBear and uptrendEma and sqMomentum > 0 and adx >= adxStrengthEff and not squeezeJustTurnedPlus)
// Uptrend adjust: ADX < 23, squeeze plus but dropping. e.g. 10/06/25.
sellUptrendAdjust = cmUltBear and uptrendEma and adx < adxStrengthEff and sqMomentum > 0 and sqMomentum < sqMomentum[1]

barOk = not dotsCloseOnly or barstate.isconfirmed
buyCompressedOk = not hideDevelopedBuys or sqzOn or sqGreenRaw
buyDot = smPlusUnconfirmed and barOk and buyCompressedOk
leadDot = macdLeadBuyEvent and barOk and buyCompressedOk

var float lastRedHigh = na
var int lastRedBar = na
wouldSell = sellExitCircle or sellUptrendRed
redInWindow = redsHigherWick and not na(lastRedBar) and (bar_index - lastRedBar) <= redWickLook
keepRed = wouldSell and (not redInWindow or high >= lastRedHigh)
sellDot = keepRed and barOk
lightDot = (sellLightRed or sellUptrendLight) and barOk
adjustDot = sellUptrendAdjust and barOk
if keepRed and barOk
    lastRedHigh := high
    lastRedBar := bar_index

longLikeRead = plusDI > minusDI
shortLikeRead = minusDI > plusDI

//------------------------------------------------------------------------------
// Cycle state machine — resets on each new SM green dot (auto mode)
//------------------------------------------------------------------------------
secondsPerBar = timeframe.in_seconds()
msPerBar = secondsPerBar * 1000

var int   entryBarIdx      = na
var int   exitAnchorBarIdx = na
var int   zoneStartBar     = na
var float zoneSnapUpper    = na
var float zoneSnapLower    = na
var float lastSwingLow     = na
var int   lastSwingLowBar  = na
var bool  noBuyMode        = false

manualEntryBar      = time >= entryTime      and time[1] < entryTime
manualExitAnchorBar = time >= exitAnchorTime and time[1] < exitAnchorTime

// Pre-computed swing-low values (must live at global scope for Pine consistency).
swingLowValue   = ta.lowest(low, swingLookbackEff)
swingLowBarsAgo = ta.barssince(low == swingLowValue)
swingLowBarOff  = math.max(swingLowBarsAgo, 0)
swingLowBodyHigh = math.max(open[swingLowBarOff], close[swingLowBarOff])
swingLowBodyLow  = math.min(open[swingLowBarOff], close[swingLowBarOff])
swingLowBodyMid  = (swingLowBodyHigh + swingLowBodyLow) / 2.0

// Pre-computed values for trade mode (must live at global scope).
atrTrade         = ta.atr(14)
greenDotBodyHigh = math.max(open, close)
recentSwingHigh       = ta.highest(high, targetLookbackEff)
recentSwingHighPreT0  = ta.highest(high[1], targetPreT0LookbackEff)
pivotTopValue         = ta.pivothigh(high, tmPivotBars, tmPivotBars)
lastPivotTop          = ta.valuewhen(not na(pivotTopValue), pivotTopValue, 0)

var float tmTradeEntry   = na
var float tmDipZoneTop   = na
var float tmDipZoneBot   = na
var float tmTargetPrice  = na
var float tmTolerance    = na
var float tmStopLoss     = na
var bool  tmPhase2Hit    = false
var bool  tmThesisBroken = false
var bool  tmTargetHit    = false
var bool  tmSmRedSinceT0 = false
var int   smRedCountSinceT0 = 0

// AUTO MODE: every fresh SM green dot resets the full cycle (optional: not on weak SM+).
if autoDetect and sqGreenCycleReset
    entryBarIdx      := bar_index
    exitAnchorBarIdx := na
    zoneStartBar     := na
    zoneSnapUpper    := na
    zoneSnapLower    := na
    noBuyMode        := false
    lastSwingLow     := swingLowValue
    lastSwingLowBar  := bar_index - swingLowBarsAgo
    // Trade Mode: capture the plan at T0. User can override via inputs any time.
    if tmTfMatch
        if tmEntry > 0
            tmTradeEntry := tmEntry
        else if tmEntryMode == "Swing Low Body High"
            tmTradeEntry := swingLowBodyHigh
        else if tmEntryMode == "Swing Low Body Low"
            tmTradeEntry := swingLowBodyLow
        else if tmEntryMode == "Swing Low Body Mid"
            tmTradeEntry := swingLowBodyMid
        else if tmEntryMode == "T0 Close"
            tmTradeEntry := close
        else
            tmTradeEntry := close
        if tmDipBotMode == "Last Swing Low"
            tmDipZoneBot := swingLowValue
        else
            tmDipZoneBot := tmDipBotManual
        if tmDipTopMode == "T0 Body High"
            tmDipZoneTop := greenDotBodyHigh
        else if tmDipTopMode == "T0 Candle High"
            tmDipZoneTop := high
        else
            tmDipZoneTop := tmDipTopManual
        if tmTargetMode == "Last Top Before T0"
            tmTargetPrice := recentSwingHighPreT0
        else if tmTargetMode == "Last Top (Lookback)"
            tmTargetPrice := recentSwingHigh
        else
            tmTargetPrice := tmTargetManual
        // Optional cap to keep entries closer to swing-low risk anchor.
        if tmEntryMaxGapPctEff > 0 and not na(tmDipZoneBot)
            maxGapEntry = tmDipZoneBot * (1.0 + tmEntryMaxGapPctEff / 100.0)
            tmTradeEntry := math.min(tmTradeEntry, maxGapEntry)
        tmTolerance    := tmDipZoneBot - atrTrade * tmToleranceATR
        slBasePrice    = tmSlBase == "Last Swing Low" and not na(tmDipZoneBot) ? tmDipZoneBot : tmTradeEntry
        slPctLevel     = slBasePrice * (1.0 - tmSlPct / 100.0)
        slEmaLevel     = ema100 - syminfo.mintick
        tmStopLossRaw  = tmSlEma100Cap and not na(ema100) and slEmaLevel < slPctLevel ? slEmaLevel : slPctLevel
        slFloorTick    = tmDipZoneBot - syminfo.mintick
        slFloorPct     = tmDipZoneBot * (1.0 - tmSlMinBelowPct / 100.0)
        slFloor        = math.min(slFloorTick, slFloorPct)
        tmStopLoss    := tmSlBase == "Last Swing Low" and not na(tmDipZoneBot) ? math.min(tmStopLossRaw, slFloor) : tmStopLossRaw
        if tmSlAlignTolerance and not na(tmTolerance)
            tmStopLoss := tmTolerance - syminfo.mintick
        if activeProfile == "1M"
            tmStopLoss := tmSl1mManual > 0 ? tmSl1mManual : na
    else
        tmTradeEntry   := na
        tmDipZoneTop   := na
        tmDipZoneBot   := na
        tmTargetPrice  := na
        tmTolerance    := na
        tmStopLoss     := na
    tmPhase2Hit    := false
    tmThesisBroken := false
    tmTargetHit    := false
    tmSmRedSinceT0 := false
    smRedCountSinceT0 := 0

// MANUAL MODE: use the provided timestamps as anchors.
if not autoDetect and manualEntryBar
    entryBarIdx := bar_index
if not autoDetect and manualExitAnchorBar
    exitAnchorBarIdx := bar_index
    noBuyMode        := true

barsFromEntry = na(entryBarIdx) ? na : (bar_index - entryBarIdx)
isEntryBar    = not na(entryBarIdx) and bar_index == entryBarIdx
isMinBar      = not na(entryBarIdx) and (bar_index - entryBarIdx) == minBarsEff
isMaxBar      = not na(entryBarIdx) and (bar_index - entryBarIdx) == maxBarsEff

inExitWindow = not na(barsFromEntry) and barsFromEntry >= minBarsEff and barsFromEntry <= maxBarsEff
thesisDecay  = not na(barsFromEntry) and barsFromEntry > maxBarsEff
preWindow    = not na(barsFromEntry) and barsFromEntry < minBarsEff

// Exit setups evaluated against the current cycle's window (both ways — no Long/Short switch).
exitLongSetup  = inExitWindow and adxLosingStrength and sqRedAndCurvingDown
exitShortSetup = inExitWindow and adxLosingStrength and (sqMomentum > 0 and sqMomentum > sqMomentum[1])
exitSetup      = exitLongSetup or exitShortSetup

// AUTO MODE: first exit-setup bar inside the window arms the exit anchor and No-Buy mode.
if autoDetect and exitSetup and na(exitAnchorBarIdx)
    exitAnchorBarIdx := bar_index
    noBuyMode        := true

barsFromExitAnchor = na(exitAnchorBarIdx) ? na : (bar_index - exitAnchorBarIdx)
isExitAnchorBar    = not na(exitAnchorBarIdx) and bar_index == exitAnchorBarIdx
inPostExitWindow   = not na(barsFromExitAnchor) and barsFromExitAnchor >= minBarsEff and barsFromExitAnchor <= maxBarsEff

//------------------------------------------------------------------------------
// Re-entry gate + target zone
//------------------------------------------------------------------------------
reentryConfirm      = smPlusConfirmed and adxSlope > 0 and longLikeRead
reentryConfirm2Bars = reentryConfirm and reentryConfirm[1]
reentryGate         = strictReentry ? reentryConfirm2Bars : reentryConfirm

zoneTrigger = targetZoneMode == "Manual" ? isExitAnchorBar : exitSetup
canStartNewZone = na(zoneStartBar) or (bar_index - zoneStartBar > targetZoneBars)
if zoneTrigger and canStartNewZone
    zoneStartBar  := bar_index
    zoneSnapUpper := math.max(ema55, ema100)
    zoneSnapLower := math.min(ema55, ema100)

barsFromZoneStart = na(zoneStartBar) ? na : (bar_index - zoneStartBar)
zoneActive        = not na(barsFromZoneStart) and barsFromZoneStart >= 0 and barsFromZoneStart <= targetZoneBars
isZoneStartBar    = not na(barsFromZoneStart) and barsFromZoneStart == 0
isExitZoneEndBar  = not na(barsFromZoneStart) and barsFromZoneStart == targetZoneBars

if noBuyMode and reentryGate
    noBuyMode := false

//------------------------------------------------------------------------------
// Trade Mode: one-scenario-per-cycle signal detection
//------------------------------------------------------------------------------
// Track whether any squeeze SM red fired since T0 (weak or confirmed) — turns off Phase-2 adds.
if sqRedDot and not na(tmTradeEntry)
    tmSmRedSinceT0 := true
// Red-dot exit count / multi-red logic: use strict confirmed SM− only when that option is on.
if sqRedForCount and not na(entryBarIdx)
    smRedCountSinceT0 += 1

// Phase-2 add: bar wicks into the add zone, no red yet, not already triggered.
tmPhase2Signal = tradeModeOn and tmTfMatch and not na(tmDipZoneTop) and not na(tmDipZoneBot) and low <= tmDipZoneTop and low >= tmDipZoneBot and not tmSmRedSinceT0 and not tmPhase2Hit
if tmPhase2Signal
    tmPhase2Hit := true

// Thesis broken: SM red dot OR close below the tolerance line (Last Swing Low - n*ATR).
tmThesisBreakSignal = tradeModeOn and tmTfMatch and not na(tmTradeEntry) and not tmThesisBroken and (sqRedForThesis or (not na(tmTolerance) and close < tmTolerance))
if tmThesisBreakSignal
    tmThesisBroken := true

// Target hit: high reaches target for the first time.
tmTargetHitSignal = tradeModeOn and tmTfMatch and not na(tmTargetPrice) and not tmTargetHit and not na(tmTradeEntry) and high >= tmTargetPrice
if tmTargetHitSignal
    tmTargetHit := true

// User risk preference exit cue: 1, 2, or 3 SM red dots since T0.
tmRedExitSignal = tradeModeOn and tmTfMatch and not na(entryBarIdx) and smRedCountSinceT0 >= tmRedExitDots and smRedCountSinceT0[1] < tmRedExitDots

//------------------------------------------------------------------------------
// Day context: cycle-finished / exhaustion bias helper
//------------------------------------------------------------------------------
dayTf = timeframe.period == "1D"
dayCycleFinished = dayTf and not na(entryBarIdx) and thesisDecay and noBuyMode and sqMomentum < 0 and smRedCountSinceT0 >= 2
daySidewaysDropBias = dayTf and not na(entryBarIdx) and thesisDecay and sqMomentum < 0 and smRedCountSinceT0 >= 1
dayExhaustionWatch = dayTf and adx > adxStrengthEff and adxSlope <= 0 and sqMomentum < sqMomentum[3]

//------------------------------------------------------------------------------
// Chart: EMAs + buy/sell dots only (Style tab stays short)
//------------------------------------------------------------------------------
dotPad = atrTrade * 0.6
plotshape(buyDot ? low - dotPad : na, "Buy", shape.circle, location.absolute, color = #00E676, size = size.tiny)
plotshape(leadDot ? low - dotPad : na, "Buy lead", shape.circle, location.absolute, color = #FF9100, size = size.tiny)
plotshape(macdZeroCross ? low[2] - dotPad[2] : na, "Buy (MACD zero)", shape.circle, location.absolute, color = #00E676, size = size.tiny, offset = -2)
plotshape(sellDot ? high + dotPad : na, "Sell", shape.circle, location.absolute, color = #FF1744, size = size.tiny)
plotshape(lightDot ? high + dotPad : na, "Sell light", shape.circle, location.absolute, color = #FF8A80, size = size.tiny)
plotshape(adjustDot ? high + dotPad : na, "Adjust (uptrend)", shape.circle, location.absolute, color = #FF1744, size = size.tiny)

//------------------------------------------------------------------------------
// Alerts — green / red dots, Coinbase BTC 1H and 4H only
//------------------------------------------------------------------------------
exitAnySetup = exitLongSetup or exitShortSetup
codAlertAny = exitAnySetup or sqGreenCycleReset or smMinusStrict or reentryGate or tmPhase2Signal or tmThesisBreakSignal or tmTargetHitSignal or tmRedExitSignal
isBtcCoinbase = syminfo.ticker == "BTCUSD" or syminfo.ticker == "BTCUSDC"
isBtc1h4h = isBtcCoinbase and (timeframe.period == "60" or timeframe.period == "240")
inQuietHours = alertQuietOn and not na(time(timeframe.period, alertQuietSess, alertTz))
dotTfName = timeframe.period == "60" ? "1H" : timeframe.period == "240" ? "4H" : timeframe.period
wantBuyAlert = alertSide == "Both" or alertSide == "Buy only"
wantSellAlert = alertSide == "Both" or alertSide == "Sell only"
greenDotAlert = isBtc1h4h and not inQuietHours and wantBuyAlert and (buyDot or macdZeroCross)
redDotAlert = isBtc1h4h and not inQuietHours and wantSellAlert and sellDot
if greenDotAlert
    alert("COD BUY " + dotTfName + " " + syminfo.ticker + " @ " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
if redDotAlert
    alert("COD SELL " + dotTfName + " " + syminfo.ticker + " @ " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
alertcondition(greenDotAlert, "COD — BUY green / zero (1H 4H)", "COD BUY {{interval}} {{ticker}} @ {{close}}")
alertcondition(redDotAlert, "COD — SELL red (1H 4H)", "COD SELL {{interval}} {{ticker}} @ {{close}}")
alertcondition(codAlertAny, "COD — any signal (bundle)", "COD: A bundled condition fired — check the chart (exit / cycle / sell confirmation / buy re-entry / trade plan).")
````
