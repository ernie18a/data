# Directional Friction Bands

- url: https://www.tradingview.com/script/uqYhttY9-Directional-Friction-Bands/
- type: indicator
- pine_id: PUB;1bcb13caafc04213805ddcf50ed70250
- version: 1.0

## Description

Directional Friction Bands (DFB) is an asymmetric price-envelope indicator designed to show how easily price has recently been able to travel upward versus downward.

Unlike traditional symmetric volatility bands, DFB evaluates upside and downside movement independently using directional travel, retained progress, close location, wick rejection, and price efficiency.

The yellow center line represents equilibrium. The surrounding zones show directional travel efficiency:

- Wide upper zone = upside travel has recently been easier / more efficient
- Narrow upper zone = upside has encountered more friction
- Wide lower zone = downside travel has recently been easier / more efficient
- Narrow lower zone = downside has encountered more friction
- Both zones narrow = lower directional efficiency / more rotational conditions

The indicator is best interpreted as a visual representation of the market’s current path of least resistance.

Key Features:
- Independent upside and downside efficiency measurement
- Asymmetric price envelope
- Close-retention and wick-rejection logic
- Adaptive compression during choppy conditions
- Faster response to genuine directional transitions
- ATR-normalized so the same framework can be used across different markets
- Optional alerts when directional dominance changes

How to use it
During an uptrend, the upper zone should generally remain wider than the lower zone. During a downtrend, the lower zone should generally dominate.

A pullback does not necessarily change the directional state. If price pulls back but the original directional zone remains dominant, the broader path of least resistance may still be intact.

Pay particular attention when the dominant zone begins to contract while the opposite zone expands. This can indicate a transition in directional efficiency.

The bands are not support/resistance levels, targets, or buy/sell signals. Price may trade outside them during strong impulses. Their purpose is to visualize how efficiently price has recently been able to move in each direction.

DFB can be combined with market structure, VWAP, higher-timeframe context, or other forms of price-action analysis.

In simple terms:
Wide side = easier directional travel.
Narrow side = greater directional friction.

This indicator is intended for analysis and research and should not be used as a standalone trading system.

## Source Code

````pine
//@version=6
indicator("Directional Friction Bands", shorttitle="DFB", overlay=true)

//──────────────────────────────────────────────────────────────────────
// INPUT GROUPS
//──────────────────────────────────────────────────────────────────────

groupCore = "Core Settings"
groupAdvanced = "Advanced Settings"
groupAppearance = "Appearance"

//──────────────────────────────────────────────────────────────────────
// CORE SETTINGS
//──────────────────────────────────────────────────────────────────────

lookback = input.int(24, "Lookback", minval=2, group=groupCore, tooltip="Controls how much recent price behavior contributes to directional travel efficiency.")
centerLength = input.int(36, "Center Length", minval=1, group=groupCore, tooltip="EMA length used as the equilibrium center of the directional envelope.")
bandScale = input.float(1.50, "Band Scale", minval=0.10, step=0.05, group=groupCore, tooltip="Controls the overall visual distance of the travel zones from the equilibrium center. It does not determine directional bias.")

//──────────────────────────────────────────────────────────────────────
// ADVANCED SETTINGS
//──────────────────────────────────────────────────────────────────────

efficiencySmoothing = input.int(5, "Efficiency Smoothing", minval=1, group=groupAdvanced, tooltip="Smooths directional efficiency measurements. Higher values reduce noise but react more slowly.")
minimumBandStrength = input.float(0.15, "Minimum Band Strength", minval=0.0, maxval=0.50, step=0.01, group=groupAdvanced, tooltip="Prevents either directional zone from collapsing completely into the centerline.")
dominanceStrength = input.float(2.00, "Dominance Strength", minval=1.0, maxval=5.0, step=0.1, group=groupAdvanced, tooltip="Controls how strongly differences between upside and downside efficiency are visually separated.")
transitionResponsiveness = input.float(0.35, "Transition Responsiveness", minval=0.0, maxval=1.0, step=0.05, group=groupAdvanced, tooltip="Controls how much recent price behavior influences directional transitions. Higher values react faster.")
enableDominanceAlerts = input.bool(true, "Enable Dominance Alerts", group=groupAdvanced)
requireBarCloseAlerts = input.bool(true, "Require Bar Close For Alerts", group=groupAdvanced)

//──────────────────────────────────────────────────────────────────────
// APPEARANCE
//──────────────────────────────────────────────────────────────────────

showCenterLine = input.bool(true, "Show Center Line", group=groupAppearance)
showBandBoundaries = input.bool(false, "Show Band Boundaries", group=groupAppearance)
showUpsideZone = input.bool(true, "Show Upside Zone", group=groupAppearance)
showDownsideZone = input.bool(true, "Show Downside Zone", group=groupAppearance)

//──────────────────────────────────────────────────────────────────────
// FIXED MODEL PARAMETERS
//──────────────────────────────────────────────────────────────────────

atrLength = 14
retentionWeight = 0.65
wickPenaltyWeight = 0.35
transitionConfirmLength = 3
directionalCompressionWeight = 0.25
minimumCompressionFactor = 0.35
chopLookback = 14
chopPenaltyStrength = 0.15
trendReliefThreshold = 0.55
trendReliefStrength = 0.50

//──────────────────────────────────────────────────────────────────────
// EQUILIBRIUM CENTER
//──────────────────────────────────────────────────────────────────────

center = ta.ema(close, centerLength)

//──────────────────────────────────────────────────────────────────────
// DIRECTIONAL TRAVEL
//
// Travel measures how far price attempted to move in each direction
// relative to the previous close.
//
// Progress measures how much of that movement was retained at the close.
//──────────────────────────────────────────────────────────────────────

previousClose = close[1]
barRange = math.max(high - low, syminfo.mintick)

upTravel = na(previousClose) ? 0.0 : math.max(high - previousClose, 0.0)
downTravel = na(previousClose) ? 0.0 : math.max(previousClose - low, 0.0)

upProgress = na(previousClose) ? 0.0 : math.max(close - previousClose, 0.0)
downProgress = na(previousClose) ? 0.0 : math.max(previousClose - close, 0.0)

//──────────────────────────────────────────────────────────────────────
// RETENTION AND REJECTION
//
// Strong closes near the directional extreme receive more credit.
//
// Directional rejection wicks reduce the quality of retained progress.
//──────────────────────────────────────────────────────────────────────

upCloseRetentionRaw = (close - low) / barRange
downCloseRetentionRaw = (high - close) / barRange

upCloseRetention = math.max(0.0, math.min(1.0, upCloseRetentionRaw))
downCloseRetention = math.max(0.0, math.min(1.0, downCloseRetentionRaw))

upRetentionFactor = (1.0 - retentionWeight) + retentionWeight * upCloseRetention
downRetentionFactor = (1.0 - retentionWeight) + retentionWeight * downCloseRetention

qualifiedUpProgress = upProgress * upRetentionFactor
qualifiedDownProgress = downProgress * downRetentionFactor

upperWick = math.max(high - math.max(open, close), 0.0)
lowerWick = math.max(math.min(open, close) - low, 0.0)

upperWickRatioRaw = upperWick / barRange
lowerWickRatioRaw = lowerWick / barRange

upperWickRatio = math.max(0.0, math.min(1.0, upperWickRatioRaw))
lowerWickRatio = math.max(0.0, math.min(1.0, lowerWickRatioRaw))

upWickFactor = math.max(0.0, 1.0 - wickPenaltyWeight * upperWickRatio)
downWickFactor = math.max(0.0, 1.0 - wickPenaltyWeight * lowerWickRatio)

upQualityProgress = math.max(qualifiedUpProgress * upWickFactor, 0.0)
downQualityProgress = math.max(qualifiedDownProgress * downWickFactor, 0.0)

//──────────────────────────────────────────────────────────────────────
// DIRECTIONAL EFFICIENCY
//
// Exponential memory is used in the release model.
//
// Efficiency = quality-adjusted retained progress / attempted travel.
//──────────────────────────────────────────────────────────────────────

emaUpTravel = ta.ema(upTravel, lookback)
emaDownTravel = ta.ema(downTravel, lookback)

emaUpProgress = ta.ema(upQualityProgress, lookback)
emaDownProgress = ta.ema(downQualityProgress, lookback)

rawUpEfficiency = not na(emaUpTravel) and emaUpTravel > 0.0 ? emaUpProgress / emaUpTravel : 0.0
rawDownEfficiency = not na(emaDownTravel) and emaDownTravel > 0.0 ? emaDownProgress / emaDownTravel : 0.0

rawUpEfficiencyClamped = math.max(0.0, math.min(1.0, rawUpEfficiency))
rawDownEfficiencyClamped = math.max(0.0, math.min(1.0, rawDownEfficiency))

slowUpEfficiencyRaw = ta.ema(rawUpEfficiencyClamped, efficiencySmoothing)
slowDownEfficiencyRaw = ta.ema(rawDownEfficiencyClamped, efficiencySmoothing)

upEfficiency = math.max(0.0, math.min(1.0, slowUpEfficiencyRaw))
downEfficiency = math.max(0.0, math.min(1.0, slowDownEfficiencyRaw))

upFriction = 1.0 - upEfficiency
downFriction = 1.0 - downEfficiency

//──────────────────────────────────────────────────────────────────────
// TRANSITION LOGIC
//
// A faster efficiency estimate helps genuine changes migrate sooner.
//
// It is blended with the slower measure instead of replacing it.
//──────────────────────────────────────────────────────────────────────

fastLength = math.max(2, int(math.round(lookback * 0.35)))

fastUpTravel = ta.ema(upTravel, fastLength)
fastDownTravel = ta.ema(downTravel, fastLength)

fastUpProgress = ta.ema(upQualityProgress, fastLength)
fastDownProgress = ta.ema(downQualityProgress, fastLength)

fastUpEfficiencyRaw = not na(fastUpTravel) and fastUpTravel > 0.0 ? fastUpProgress / fastUpTravel : 0.0
fastDownEfficiencyRaw = not na(fastDownTravel) and fastDownTravel > 0.0 ? fastDownProgress / fastDownTravel : 0.0

fastUpEfficiency = math.max(0.0, math.min(1.0, fastUpEfficiencyRaw))
fastDownEfficiency = math.max(0.0, math.min(1.0, fastDownEfficiencyRaw))

transitionUpEfficiencyRaw = upEfficiency * (1.0 - transitionResponsiveness) + fastUpEfficiency * transitionResponsiveness
transitionDownEfficiencyRaw = downEfficiency * (1.0 - transitionResponsiveness) + fastDownEfficiency * transitionResponsiveness

transitionUpEfficiency = math.max(0.0, math.min(1.0, transitionUpEfficiencyRaw))
transitionDownEfficiency = math.max(0.0, math.min(1.0, transitionDownEfficiencyRaw))

//──────────────────────────────────────────────────────────────────────
// TRANSITION CONFIRMATION
//
// Smooths the directional difference to reduce one-bar dominance flips
// while preserving the shared efficiency midpoint.
//──────────────────────────────────────────────────────────────────────

transitionMeanEfficiency = (transitionUpEfficiency + transitionDownEfficiency) / 2.0
rawTransitionDifference = transitionUpEfficiency - transitionDownEfficiency
confirmedDifference = ta.ema(rawTransitionDifference, transitionConfirmLength)

confirmedUpEfficiencyRaw = transitionMeanEfficiency + confirmedDifference / 2.0
confirmedDownEfficiencyRaw = transitionMeanEfficiency - confirmedDifference / 2.0

confirmedUpEfficiency = math.max(0.0, math.min(1.0, confirmedUpEfficiencyRaw))
confirmedDownEfficiency = math.max(0.0, math.min(1.0, confirmedDownEfficiencyRaw))

//──────────────────────────────────────────────────────────────────────
// COMPRESSION AND TREND RELIEF
//
// Overall envelope width is reduced when directional efficiency is
// balanced and price displacement is poor.
//
// Strong price efficiency progressively relaxes that compression.
//──────────────────────────────────────────────────────────────────────

baseCombinedEfficiencyRaw = (transitionUpEfficiency + transitionDownEfficiency) / 2.0
baseCombinedEfficiency = math.max(0.0, math.min(1.0, baseCombinedEfficiencyRaw))

efficiencyDifference = math.abs(transitionUpEfficiency - transitionDownEfficiency)

compressionDirectionalComponent = math.max(efficiencyDifference, minimumCompressionFactor)
directionalCompressionFactor = (1.0 - directionalCompressionWeight) + directionalCompressionWeight * compressionDirectionalComponent

adjustedCombinedEfficiencyRaw = baseCombinedEfficiency * directionalCompressionFactor
adjustedCombinedEfficiency = math.max(0.0, math.min(1.0, adjustedCombinedEfficiencyRaw))

netDisplacement = na(close[chopLookback]) ? 0.0 : math.abs(close - close[chopLookback])
singleBarTravel = math.abs(close - close[1])
totalPriceTravel = ta.sma(singleBarTravel, chopLookback) * chopLookback

priceEfficiencyRaw = not na(totalPriceTravel) and totalPriceTravel > 0.0 ? netDisplacement / totalPriceTravel : 0.0
priceEfficiency = math.max(0.0, math.min(1.0, priceEfficiencyRaw))

chopAdjustmentFactor = (1.0 - chopPenaltyStrength) + chopPenaltyStrength * priceEfficiency

preReliefCombinedEfficiencyRaw = adjustedCombinedEfficiency * chopAdjustmentFactor
preReliefCombinedEfficiency = math.max(0.0, math.min(1.0, preReliefCombinedEfficiencyRaw))

trendReliefDenominator = math.max(1.0 - trendReliefThreshold, 0.000001)
trendReliefRaw = (priceEfficiency - trendReliefThreshold) / trendReliefDenominator
trendRelief = math.max(0.0, math.min(1.0, trendReliefRaw))

compressionReliefMultiplier = 1.0 + trendReliefStrength * trendRelief

finalCombinedEfficiencyRaw = preReliefCombinedEfficiency * compressionReliefMultiplier
finalCombinedEfficiency = math.max(0.0, math.min(1.0, finalCombinedEfficiencyRaw))

//──────────────────────────────────────────────────────────────────────
// RELATIVE DOMINANCE
//
// The powered share model amplifies meaningful differences between
// upside and downside efficiency without changing absolute efficiency.
//──────────────────────────────────────────────────────────────────────

poweredUp = math.pow(confirmedUpEfficiency, dominanceStrength)
poweredDown = math.pow(confirmedDownEfficiency, dominanceStrength)

poweredTotal = poweredUp + poweredDown

upDirectionalShare = poweredTotal > 0.0 ? poweredUp / poweredTotal : 0.5
downDirectionalShare = poweredTotal > 0.0 ? poweredDown / poweredTotal : 0.5

upDirectionalStrengthRaw = finalCombinedEfficiency * 2.0 * upDirectionalShare
downDirectionalStrengthRaw = finalCombinedEfficiency * 2.0 * downDirectionalShare

upDirectionalStrength = math.max(0.0, math.min(1.0, upDirectionalStrengthRaw))
downDirectionalStrength = math.max(0.0, math.min(1.0, downDirectionalStrengthRaw))

effectiveUpStrength = math.max(upDirectionalStrength, minimumBandStrength)
effectiveDownStrength = math.max(downDirectionalStrength, minimumBandStrength)

//──────────────────────────────────────────────────────────────────────
// BAND CONSTRUCTION
//
// ATR provides only a common price-distance scale.
//
// It does not determine directional dominance.
//──────────────────────────────────────────────────────────────────────

atr = ta.atr(atrLength)
baseDistance = atr * bandScale

upperDistance = baseDistance * effectiveUpStrength
lowerDistance = baseDistance * effectiveDownStrength

upperBand = center + upperDistance
lowerBand = center - lowerDistance

upperDistanceATR = atr > 0.0 ? upperDistance / atr : 0.0
lowerDistanceATR = atr > 0.0 ? lowerDistance / atr : 0.0

//──────────────────────────────────────────────────────────────────────
// VISUALS
//
// Constant colors are used so TradingView exposes clean Style controls.
//──────────────────────────────────────────────────────────────────────

centerColor = color.rgb(236, 211, 93)
upsideColor = color.rgb(155, 92, 75)
downsideColor = color.rgb(65, 139, 128)

upsideFillColor = color.new(upsideColor, 72)
downsideFillColor = color.new(downsideColor, 72)

centerPlot = plot(showCenterLine ? center : na, "Equilibrium Center", color=centerColor, linewidth=2, editable=true)
upperLinePlot = plot(showBandBoundaries ? upperBand : na, "Upside Travel Boundary", color=upsideColor, linewidth=1, editable=true)
lowerLinePlot = plot(showBandBoundaries ? lowerBand : na, "Downside Travel Boundary", color=downsideColor, linewidth=1, editable=true)

upperFillBoundary = plot(upperBand, "Upside Fill Boundary", color=color.new(upsideColor, 100), display=display.none, editable=false)
lowerFillBoundary = plot(lowerBand, "Downside Fill Boundary", color=color.new(downsideColor, 100), display=display.none, editable=false)

upperCenterBoundary = plot(center, "Upside Center Boundary", color=color.new(centerColor, 100), display=display.none, editable=false)
lowerCenterBoundary = plot(center, "Downside Center Boundary", color=color.new(centerColor, 100), display=display.none, editable=false)

fill(upperCenterBoundary, upperFillBoundary, color=showUpsideZone ? upsideFillColor : na, title="Upside Travel Zone", editable=true)
fill(lowerCenterBoundary, lowerFillBoundary, color=showDownsideZone ? downsideFillColor : na, title="Downside Travel Zone", editable=true)

//──────────────────────────────────────────────────────────────────────
// ALERTS
//
// These indicate changes in directional travel dominance.
// They are not buy or sell signals.
//──────────────────────────────────────────────────────────────────────

barAlertConfirmed = not requireBarCloseAlerts or barstate.isconfirmed

upsideDominanceFlip = enableDominanceAlerts and ta.crossover(upDirectionalShare, downDirectionalShare) and barAlertConfirmed
downsideDominanceFlip = enableDominanceAlerts and ta.crossover(downDirectionalShare, upDirectionalShare) and barAlertConfirmed

alertcondition(upsideDominanceFlip, title="DFB Upside Dominance", message="DFB UPSIDE DOMINANCE | {{ticker}} | {{interval}} | Price {{close}}")
alertcondition(downsideDominanceFlip, title="DFB Downside Dominance", message="DFB DOWNSIDE DOMINANCE | {{ticker}} | {{interval}} | Price {{close}}")

//──────────────────────────────────────────────────────────────────────
// DATA WINDOW
//──────────────────────────────────────────────────────────────────────

plot(upEfficiency, "Up Efficiency", color=color.new(color.white, 100), display=display.data_window, editable=false)
plot(downEfficiency, "Down Efficiency", color=color.new(color.white, 100), display=display.data_window, editable=false)

plot(upFriction, "Up Friction", color=color.new(color.white, 100), display=display.data_window, editable=false)
plot(downFriction, "Down Friction", color=color.new(color.white, 100), display=display.data_window, editable=false)

plot(upDirectionalShare, "Up Directional Share", color=color.new(color.white, 100), display=display.data_window, editable=false)
plot(downDirectionalShare, "Down Directional Share", color=color.new(color.white, 100), display=display.data_window, editable=false)

plot(upDirectionalStrength, "Up Directional Strength", color=color.new(color.white, 100), display=display.data_window, editable=false)
plot(downDirectionalStrength, "Down Directional Strength", color=color.new(color.white, 100), display=display.data_window, editable=false)

plot(priceEfficiency, "Price Efficiency", color=color.new(color.white, 100), display=display.data_window, editable=false)

plot(upperDistanceATR, "Upper Distance / ATR", color=color.new(color.white, 100), display=display.data_window, editable=false)
plot(lowerDistanceATR, "Lower Distance / ATR", color=color.new(color.white, 100), display=display.data_window, editable=false)
````
