# Adaptive Momentum Oscillator (MTF Signal Framework)

- url: https://www.tradingview.com/script/lVLjaL7S-Adaptive-Momentum-Oscillator-MTF-Signal-Framework/
- type: indicator
- pine_id: PUB;dcf18ad90a5844acbf871032c04fea23
- version: 4.0

## Description

📖 Overview

The Adaptive Momentum Oscillator is a multi-layer analytical tool designed to evaluate market momentum through a combination of smoothed price deviation, signal averaging, and regime-based visualization.

Instead of relying on a single momentum calculation, the indicator builds a structured view of market behavior by separating:

underlying momentum pressure
signal smoothing
and trend regime states

This allows traders to interpret market conditions with reduced noise and clearer directional context.

⭐ Key Features
🔹 Multi-Layer Momentum Structure

The oscillator combines raw momentum movement with smoothed signal lines to separate short-term fluctuations from broader directional bias.

🔹 Signal Confirmation Logic

Buy and sell conditions are derived from structured momentum shifts rather than single threshold crossings, helping reduce premature signals in choppy conditions.

🔹 Trend Regime Visualization

The indicator highlights different market phases:

bullish expansion zones
bearish expansion zones
neutral or transition phases

This helps contextualize momentum behavior instead of treating all movement equally.

🔹 Histogram Momentum Tracking

The histogram represents the acceleration and deceleration of momentum, allowing traders to observe weakening or strengthening trends.

🔹 Dynamic Signal Behavior

Signals adapt to market conditions instead of using fixed static rules, improving responsiveness during volatility changes.

📊 How to Interpret
🟢 Buy Signal

Indicates that momentum has shifted upward and confirmation conditions are aligned with bullish pressure.

🔴 Sell Signal

Indicates that momentum has shifted downward and bearish pressure dominates recent structure.

📉 Histogram
Increasing bars = strengthening momentum
Decreasing bars = weakening momentum
Color shifts = regime transitions
🎯 Best Applications
Swing trading
Momentum confirmation
Trend filtering
Reversal detection
Market structure analysis
⚠️ Limitations

This indicator should not be used as a standalone trading system.

Momentum signals may lag during rapid reversals, and additional confirmation from price action or risk management is recommended.

💡 Originality

Unlike traditional oscillators such as MACD or RSI, this script is designed as a multi-layer momentum framework, where:

raw momentum
smoothed signal behavior
and regime classification

are combined into a unified structure.

The goal is not to generate isolated signals, but to provide a continuous model of market momentum behavior across different phases.

## Source Code

````pine
//@version=6
// V12.19 — Price-Confirmed Trend-Strength Arrows
indicator("Adaptive Momentum Oscillator (MTF Signal Framework)", shorttitle="FG MACD V12", overlay=false, max_labels_count=500, max_lines_count=500)

//──────────────────────────────────────────────────────────────────────────────
// MACD Core Inputs
//──────────────────────────────────────────────────────────────────────────────
macdGrp = "MACD Core"
fastLen   = input.int(12, "MACD Fast Length", group=macdGrp, minval=1)
slowLen   = input.int(26, "MACD Slow Length", group=macdGrp, minval=1)
signalLen = input.int(47, "MACD Signal Length (SMA)", group=macdGrp, minval=1)

//──────────────────────────────────────────────────────────────────────────────
// Adaptive Zone Inputs
//──────────────────────────────────────────────────────────────────────────────
zoneGrp = "Adaptive Zones"
zonePreset = input.string("Balanced", "Zone Preset", options=["Manual", "Early", "Balanced", "Extreme"], group=zoneGrp, tooltip="Choose a preset or switch to Manual to use the values below.")

zoneLookbackManual = input.int(300, "Manual Zone Lookback Length", group=zoneGrp, minval=20)
zoneMultManual     = input.float(1.3, "Manual Greed/Fear Multiplier", step=0.1, group=zoneGrp)
extMultManual      = input.float(2.5, "Manual Extreme Multiplier", step=0.1, group=zoneGrp)
extOffsetDevManual = input.float(0.15, "Manual Extreme Offset (σ)", step=0.05, group=zoneGrp, minval=0.0)

zoneLookback = zonePreset == "Early" ? 150 : zonePreset == "Balanced" ? 200 : zonePreset == "Extreme" ? 300 : zoneLookbackManual
zoneMult     = zonePreset == "Early" ? 1.0 : zonePreset == "Balanced" ? 1.1 : zonePreset == "Extreme" ? 1.3 : zoneMultManual
extMult      = zonePreset == "Early" ? 1.8 : zonePreset == "Balanced" ? 2.0 : zonePreset == "Extreme" ? 2.5 : extMultManual
extOffsetDev = zonePreset == "Early" ? 0.30 : zonePreset == "Balanced" ? 0.25 : zonePreset == "Extreme" ? 0.15 : extOffsetDevManual

//──────────────────────────────────────────────────────────────────────────────
// Signals & Banners
//──────────────────────────────────────────────────────────────────────────────
sigGrp = "Signals"
showBanners           = input.bool(true, "Show BUY/SELL Banners", group=sigGrp)
showHistSeasonBanners = input.bool(true, "Show Normal H/L Banners", group=sigGrp, tooltip="Shows blue H banners on positive histogram highs and orange L banners on negative histogram lows.")
showInternalHistBanners = input.bool(true, "Show Purple Internal H/L Banners", group=sigGrp, tooltip="Shows purple L banners on positive histogram lows and purple H banners on negative histogram highs.")
cooldownBars          = input.int(8, "Signal Cooldown Bars", group=sigGrp, minval=0)
pivotL                = input.int(2, "Pivot Left Bars (bottom/top)", group=sigGrp, minval=1)
pivotR                = input.int(2, "Pivot Right Bars (confirm)", group=sigGrp, minval=1)
rearmStepSigma        = input.float(0.15, "Repeat Banner Threshold (σ)", group=sigGrp, minval=0.0, step=0.05, tooltip="How much deeper the next MACD pivot must be to qualify as a new BUY/SELL banner in the same extreme session.")
repeatOnPriceBreak    = input.bool(true, "Repeat Banner On New Price Low/High", group=sigGrp, tooltip="If enabled, a lower price low or higher price high can also unlock another banner inside the same extreme session.")
signalPlacement       = input.string("Pivot Bar", "Pivot Signal Placement", options=["Confirmation Bar", "Pivot Bar"], group=sigGrp, tooltip="Pivot signals are known only after the selected Right Bars have closed. Confirmation Bar is the honest default; Pivot Bar draws them backward for visual reference.")

//──────────────────────────────────────────────────────────────────────────────
// Histogram Pressure / Relief
//──────────────────────────────────────────────────────────────────────────────
pressureGrp = "Histogram Pressure"
useClassicHistogramColors = input.bool(true, "Use Classic Histogram Colors", group=pressureGrp, tooltip="Changes only the histogram bar colors. Pressure calculations, arrows, signals, zones, and alerts remain unchanged.")
showBrakeMarkers = input.bool(true, "Show Early Braking Arrows", group=pressureGrp, tooltip="Shows small semi-transparent arrows while momentum is still expanding but its rate of expansion is slowing.")
showReliefMarkers = input.bool(true, "Show Price-Confirmed Relief Arrows", group=pressureGrp, tooltip="Shows solid repeated arrows when histogram relief also passes the selected price-confirmation mode.")
showStrengthMarkers = input.bool(true, "Show Trend-Strength Arrows", group=pressureGrp, tooltip="Shows solid arrows near the histogram base when strong expanding momentum also passes the selected price-confirmation mode.")
arrowConfirmation = input.string("Strict", "Solid Arrow Confirmation", options=["Balanced", "Strict"], group=pressureGrp, tooltip="Applies to solid relief and trend-strength arrows. Balanced requires price direction plus the 3-period EMA. Strict requires a close beyond the previous candle's high or low. Semi-transparent early-braking arrows remain momentum-only warnings.")

// Fixed defaults keep the first version simple. Positive and negative pressure
// are normalized separately so a large move on one side cannot suppress the other.
pressureLookback      = 100
neutralPressureLevel  = 5.0
mediumPressureLevel   = 35.0
strongPressureLevel   = 70.0
extremePressureLevel  = 100.0
earlyBrakeLevel       = 50.0
brakeReduction        = 0.30
curvatureFloor        = 0.005
reliefFloorFraction   = 0.15
reliefRetreatFraction = 0.08
priceConfirmEmaLength = 3

//──────────────────────────────────────────────────────────────────────────────
// MACD Core (RAW)
//──────────────────────────────────────────────────────────────────────────────
fast = math.min(fastLen, slowLen)
slow = math.max(fastLen, slowLen)

macd_raw   = ta.ema(close, fast) - ta.ema(close, slow)
signal_raw = ta.sma(macd_raw, signalLen)
hist_raw   = macd_raw - signal_raw

crossUp   = ta.crossover(macd_raw, signal_raw)
crossDown = ta.crossunder(macd_raw, signal_raw)
confirmedCrossUp   = crossUp and barstate.isconfirmed
confirmedCrossDown = crossDown and barstate.isconfirmed

//──────────────────────────────────────────────────────────────────────────────
// Adaptive Zones
//──────────────────────────────────────────────────────────────────────────────
macdBasis = ta.sma(macd_raw, zoneLookback)
macdDev   = ta.stdev(macd_raw, zoneLookback)

zoneGreed = macdBasis + zoneMult * macdDev
zoneFear  = macdBasis - zoneMult * macdDev

extK     = math.max(0.1, extMult - extOffsetDev)
extGreed = macdBasis + extK * macdDev
extFear  = macdBasis - extK * macdDev

//──────────────────────────────────────────────────────────────────────────────
// Confirmed MACD pivots used by the existing BUY / SELL logic
//──────────────────────────────────────────────────────────────────────────────
pivLow  = ta.pivotlow(macd_raw, pivotL, pivotR)
pivHigh = ta.pivothigh(macd_raw, pivotL, pivotR)

confirmedPivLow  = barstate.isconfirmed and not na(pivLow)
confirmedPivHigh = barstate.isconfirmed and not na(pivHigh)

pivLowPrice  = low[pivotR]
pivHighPrice = high[pivotR]

//──────────────────────────────────────────────────────────────────────────────
// Uncapped Season Pressure
//──────────────────────────────────────────────────────────────────────────────
// Freeze each side's reference when its histogram season begins. The reference
// comes from the strongest same-side histogram bar in the preceding lookback.
// It does not move while the current season expands, so pressure can exceed 100.
positiveHist = math.max(hist_raw, 0.0)
negativeHist = math.max(-hist_raw, 0.0)

rollingPositivePeak  = ta.highest(positiveHist, pressureLookback)
rollingNegativePeak  = ta.highest(negativeHist, pressureLookback)
previousPositivePeak = rollingPositivePeak[1]
previousNegativePeak = rollingNegativePeak[1]
previousHistScale    = ta.stdev(hist_raw[1], pressureLookback)
pressureReady        = not na(previousHistScale)

newPositiveSeason = hist_raw > 0.0 and nz(hist_raw[1], 0.0) <= 0.0
newNegativeSeason = hist_raw < 0.0 and nz(hist_raw[1], 0.0) >= 0.0

var float positiveSeasonReference = na
var float negativeSeasonReference = na

positiveReferenceCandidate = math.max(nz(previousPositivePeak, 0.0), nz(previousHistScale, 0.0))
negativeReferenceCandidate = math.max(nz(previousNegativePeak, 0.0), nz(previousHistScale, 0.0))

if pressureReady and hist_raw > 0.0 and (newPositiveSeason or na(positiveSeasonReference))
    positiveSeasonReference := math.max(positiveReferenceCandidate, 1e-20)

if pressureReady and hist_raw < 0.0 and (newNegativeSeason or na(negativeSeasonReference))
    negativeSeasonReference := math.max(negativeReferenceCandidate, 1e-20)

positivePressure = pressureReady and hist_raw > 0.0 and nz(positiveSeasonReference, 0.0) > 0.0 ? positiveHist / positiveSeasonReference * 100.0 : 0.0
negativePressure = pressureReady and hist_raw < 0.0 and nz(negativeSeasonReference, 0.0) > 0.0 ? negativeHist / negativeSeasonReference * 100.0 : 0.0
activePressure   = hist_raw > 0.0 ? positivePressure : hist_raw < 0.0 ? negativePressure : 0.0

// Expanding momentum uses bright, saturated colors. Contracting momentum uses
// dark, muted colors. Each phase still has four clearly separated strength tiers.
greedRiseWeak     = color.rgb(150, 235, 255)  // #80DEEA — Ice cyan
greedRiseMedium   = color.rgb(120, 225, 255)   // #29B6F6 — Sky blue
greedRiseStrong   = color.rgb(50, 225, 240)    // #2962FF — Electric blue
greedRiseExtreme  = color.rgb(20, 247, 207)   // #7C4DFF — Electric indigo

greedFallWeak     = color.rgb(0, 139, 190, 50)   // #546E7A — Blue-gray
greedFallMedium   = color.rgb(0, 99, 200)     // #006064 — Dark teal
greedFallStrong   = color.rgb(0, 30, 230)    // #0D47A1 — Navy blue
greedFallExtreme  = color.rgb(100, 0, 190)    // #311B92 — Deep indigo

fearFallWeak      = color.rgb(255, 200, 0)   // #FFD740 — Shiny golden yellow
fearFallMedium    = color.rgb(255, 171, 0)    // #FFAB00 — Shiny amber
fearFallStrong    = color.rgb(255, 109, 0)    // #FF6D00 — Shiny deep orange
fearFallExtreme   = color.rgb(255, 0, 51)    // #FF1744 — Shiny vivid red

fearRiseWeak      = color.rgb(208, 178, 168)    // #795548 — Warm brown-gray
fearRiseMedium    = color.rgb(120, 100, 0)    // #A66A00 — Dark amber
fearRiseStrong    = color.rgb(149, 55, 0)    // #BF360C — Burnt orange
fearRiseExtreme   = color.rgb(125, 0, 0)      // #8E0000 — Deep crimson

greedExpanding = hist_raw > 0.0 and hist_raw >= hist_raw[1]
fearExpanding  = hist_raw < 0.0 and hist_raw <= hist_raw[1]

greedBrightColor = positivePressure < mediumPressureLevel ? greedRiseWeak : positivePressure < strongPressureLevel ? greedRiseMedium : positivePressure < extremePressureLevel ? greedRiseStrong : greedRiseExtreme
greedDarkColor   = positivePressure < mediumPressureLevel ? greedFallWeak : positivePressure < strongPressureLevel ? greedFallMedium : positivePressure < extremePressureLevel ? greedFallStrong : greedFallExtreme
fearBrightColor  = negativePressure < mediumPressureLevel ? fearFallWeak : negativePressure < strongPressureLevel ? fearFallMedium : negativePressure < extremePressureLevel ? fearFallStrong : fearFallExtreme
fearDarkColor    = negativePressure < mediumPressureLevel ? fearRiseWeak : negativePressure < strongPressureLevel ? fearRiseMedium : negativePressure < extremePressureLevel ? fearRiseStrong : fearRiseExtreme

positiveColor = greedExpanding ? greedBrightColor : greedDarkColor
negativeColor = fearExpanding ? fearBrightColor : fearDarkColor

histColor = hist_raw > 0.0 ? positiveColor : hist_raw < 0.0 ? negativeColor : na

classicHistColor =
     hist_raw > hist_raw[1] and hist_raw > 0.0 ? color.rgb(0, 209, 237) :
     hist_raw < hist_raw[1] and hist_raw > 0.0 ? color.blue :
     hist_raw < hist_raw[1] and hist_raw <= 0.0 ? color.rgb(255, 0, 0) :
     hist_raw > hist_raw[1] and hist_raw <= 0.0 ? color.maroon :
     color.gray

histogramPlotColor = useClassicHistogramColors ? classicHistColor : histColor

plot(hist_raw, title="Histogram — Uncapped Season Pressure", color=histogramPlotColor, style=plot.style_histogram, linewidth=4)
hline(0, "Zero Line", color=color.gray)

// Track the strongest pressure reached inside the active season. This allows
// solid arrows to continue during relief even as the current pressure declines.
var float positiveSeasonPeakPressure = 0.0
var float negativeSeasonPeakPressure = 0.0

if newPositiveSeason
    positiveSeasonPeakPressure := positivePressure
else if hist_raw > 0.0
    positiveSeasonPeakPressure := math.max(positiveSeasonPeakPressure, positivePressure)
else
    positiveSeasonPeakPressure := 0.0

if newNegativeSeason
    negativeSeasonPeakPressure := negativePressure
else if hist_raw < 0.0
    negativeSeasonPeakPressure := math.max(negativeSeasonPeakPressure, negativePressure)
else
    negativeSeasonPeakPressure := 0.0

// Early braking uses histogram curvature. The histogram is still expanding,
// but its latest increment has shrunk by at least 30% versus the prior increment.
histSlope = hist_raw - hist_raw[1]
priorHistSlope = hist_raw[1] - hist_raw[2]
greedCurvatureMove = math.abs(histSlope - priorHistSlope) >= nz(positiveSeasonReference, 0.0) * curvatureFloor
fearCurvatureMove  = math.abs(histSlope - priorHistSlope) >= nz(negativeSeasonReference, 0.0) * curvatureFloor

greedBrakeSignal = barstate.isconfirmed and hist_raw > 0.0 and positivePressure >= earlyBrakeLevel and histSlope > 0.0 and priorHistSlope > 0.0 and histSlope <= priorHistSlope * (1.0 - brakeReduction) and greedCurvatureMove
fearBrakeSignal  = barstate.isconfirmed and hist_raw < 0.0 and negativePressure >= earlyBrakeLevel and histSlope < 0.0 and priorHistSlope < 0.0 and math.abs(histSlope) <= math.abs(priorHistSlope) * (1.0 - brakeReduction) and fearCurvatureMove

// Solid arrows use either Balanced EMA confirmation or a Strict prior-candle
// breakout. Relief arrows mark meaningful contraction; strength arrows mark
// strong expansion and are suppressed on simultaneous early-braking bars.
priceConfirmEma = ta.ema(close, priceConfirmEmaLength)
balancedBullConfirm = close > close[1] and close > priceConfirmEma
balancedBearConfirm = close < close[1] and close < priceConfirmEma
strictBullConfirm = close > high[1]
strictBearConfirm = close < low[1]

bullPriceConfirm = arrowConfirmation == "Strict" ? strictBullConfirm : balancedBullConfirm
bearPriceConfirm = arrowConfirmation == "Strict" ? strictBearConfirm : balancedBearConfirm

greedReliefDepth = positiveSeasonPeakPressure > 0.0 and positivePressure <= positiveSeasonPeakPressure * (1.0 - reliefRetreatFraction)
fearReliefDepth  = negativeSeasonPeakPressure > 0.0 and negativePressure <= negativeSeasonPeakPressure * (1.0 - reliefRetreatFraction)

greedReliefSignal = barstate.isconfirmed and hist_raw > 0.0 and histSlope < 0.0 and positiveSeasonPeakPressure >= strongPressureLevel and positivePressure >= math.max(neutralPressureLevel, positiveSeasonPeakPressure * reliefFloorFraction) and greedReliefDepth and bearPriceConfirm
fearReliefSignal  = barstate.isconfirmed and hist_raw < 0.0 and histSlope > 0.0 and negativeSeasonPeakPressure >= strongPressureLevel and negativePressure >= math.max(neutralPressureLevel, negativeSeasonPeakPressure * reliefFloorFraction) and fearReliefDepth and bullPriceConfirm

bullStrengthSignal = barstate.isconfirmed and hist_raw > 0.0 and histSlope > 0.0 and positivePressure >= strongPressureLevel and not greedBrakeSignal and bullPriceConfirm
bearStrengthSignal = barstate.isconfirmed and hist_raw < 0.0 and histSlope < 0.0 and negativePressure >= strongPressureLevel and not fearBrakeSignal and bearPriceConfirm

markerPad = math.max(nz(macdDev, 0.0) * 0.05, math.abs(hist_raw) * 0.08)
greedMarkerY = hist_raw + markerPad
fearMarkerY  = hist_raw - markerPad
strengthBaseOffset = math.min(math.abs(hist_raw) * 0.18, markerPad)
bullStrengthMarkerY = strengthBaseOffset
bearStrengthMarkerY = -strengthBaseOffset

upArrowColor = color.rgb(0, 230, 118)
downArrowColor = fearFallExtreme

plotshape(showBrakeMarkers and fearBrakeSignal ? fearMarkerY : na, title="Early Fear Braking", style=shape.triangleup, location=location.absolute, color=color.new(upArrowColor, 60), size=size.tiny)
plotshape(showBrakeMarkers and greedBrakeSignal ? greedMarkerY : na, title="Early Greed Braking", style=shape.triangledown, location=location.absolute, color=color.new(downArrowColor, 60), size=size.tiny)
plotshape(showReliefMarkers and fearReliefSignal ? fearMarkerY : na, title="Fear Relief", style=shape.triangleup, location=location.absolute, color=upArrowColor, size=size.tiny)
plotshape(showReliefMarkers and greedReliefSignal ? greedMarkerY : na, title="Greed Relief", style=shape.triangledown, location=location.absolute, color=downArrowColor, size=size.tiny)
plotshape(showStrengthMarkers and bullStrengthSignal ? bullStrengthMarkerY : na, title="Bullish Trend Strength", style=shape.triangleup, location=location.absolute, color=upArrowColor, size=size.tiny)
plotshape(showStrengthMarkers and bearStrengthSignal ? bearStrengthMarkerY : na, title="Bearish Trend Strength", style=shape.triangledown, location=location.absolute, color=downArrowColor, size=size.tiny)

// Uncapped values remain available in the Data Window.
plot(positivePressure, title="Positive Season Pressure", color=color.new(greedRiseExtreme, 100), display=display.data_window)
plot(negativePressure, title="Negative Season Pressure", color=color.new(fearFallExtreme, 100), display=display.data_window)

//──────────────────────────────────────────────────────────────────────────────
// Zone Lines + Background Highlights
//──────────────────────────────────────────────────────────────────────────────
middleZoneBackground = color.new(#000000, 93)

zoneGreedPlot = plot(zoneGreed, "Greed Zone", color=color.new(color.red, 60))
zoneFearPlot  = plot(zoneFear, "Fear Zone", color=color.new(color.green, 60))
plot(extGreed, "Extreme Greed", color=color.new(color.red, 30))
plot(extFear, "Extreme Fear", color=color.new(color.green, 30))

fill(zoneGreedPlot, zoneFearPlot, color=middleZoneBackground, title="Neutral Middle-Zone Background")

bgcolor(macd_raw >= zoneGreed ? color.new(color.red, 90) : na)
bgcolor(macd_raw <= zoneFear ? color.new(color.green, 90) : na)

//──────────────────────────────────────────────────────────────────────────────
// MACD Lines
//──────────────────────────────────────────────────────────────────────────────
mainCol = macd_raw >= extGreed ? color.red : macd_raw <= extFear ? color.lime : color.new(#04cae4, 0)

plot(macd_raw, "MACD", color=mainCol, linewidth=3)
plot(signal_raw, "Signal", color=color.orange, linewidth=2)

//──────────────────────────────────────────────────────────────────────────────
// Crossover Dots
//──────────────────────────────────────────────────────────────────────────────
plot(confirmedCrossUp ? macd_raw : na, title="Cross Up Dot", style=plot.style_circles, linewidth=4, color=color.lime)
plot(confirmedCrossDown ? macd_raw : na, title="Cross Down Dot", style=plot.style_circles, linewidth=4, color=color.red)

//──────────────────────────────────────────────────────────────────────────────
// Histogram Season Banners
//──────────────────────────────────────────────────────────────────────────────
histPivLow  = ta.pivotlow(hist_raw, pivotL, pivotR)
histPivHigh = ta.pivothigh(hist_raw, pivotL, pivotR)

blueSeasonAtPivot   = hist_raw[pivotR] > 0
orangeSeasonAtPivot = hist_raw[pivotR] < 0

histHighBanner = barstate.isconfirmed and not na(histPivHigh) and blueSeasonAtPivot
histLowBanner  = barstate.isconfirmed and not na(histPivLow) and orangeSeasonAtPivot

internalHistLowBanner  = barstate.isconfirmed and not na(histPivLow) and blueSeasonAtPivot
internalHistHighBanner = barstate.isconfirmed and not na(histPivHigh) and orangeSeasonAtPivot

pivotBannerPadBase = math.max(nz(macdDev[pivotR], 0.0) * 0.35, math.abs(hist_raw[pivotR]) * 0.20)
currentBannerPadBase = math.max(nz(macdDev, 0.0) * 0.35, math.abs(hist_raw) * 0.20)
pivotBannerPad = pivotBannerPadBase == 0.0 ? 0.000001 : pivotBannerPadBase
currentBannerPad = currentBannerPadBase == 0.0 ? 0.000001 : currentBannerPadBase

pivotTopRef = math.max(math.max(zoneGreed[pivotR], extGreed[pivotR]), math.max(macd_raw[pivotR], histPivHigh))
pivotBotRef = math.min(math.min(zoneFear[pivotR], extFear[pivotR]), math.min(macd_raw[pivotR], histPivLow))
currentTopRef = math.max(math.max(zoneGreed, extGreed), math.max(macd_raw, hist_raw))
currentBotRef = math.min(math.min(zoneFear, extFear), math.min(macd_raw, hist_raw))

plotPivotsOnPivotBar = signalPlacement == "Pivot Bar"
histBannerX = plotPivotsOnPivotBar ? bar_index - pivotR : bar_index
histHighBannerY = plotPivotsOnPivotBar ? pivotTopRef + pivotBannerPad : currentTopRef + currentBannerPad
histLowBannerY  = plotPivotsOnPivotBar ? pivotBotRef - pivotBannerPad : currentBotRef - currentBannerPad

if showHistSeasonBanners and histHighBanner
    label.new(histBannerX, histHighBannerY, "H", style=label.style_label_down, textcolor=color.white, color=color.new(color.blue, 20), size=size.small)

if showHistSeasonBanners and histLowBanner
    label.new(histBannerX, histLowBannerY, "L", style=label.style_label_up, textcolor=color.white, color=color.new(color.orange, 20), size=size.small)

internalBannerColor = color.rgb(156, 39, 176)

if showInternalHistBanners and internalHistHighBanner
    label.new(histBannerX, histHighBannerY, "H", style=label.style_label_down, textcolor=color.white, color=internalBannerColor, size=size.small)

if showInternalHistBanners and internalHistLowBanner
    label.new(histBannerX, histLowBannerY, "L", style=label.style_label_up, textcolor=color.white, color=internalBannerColor, size=size.small)

//──────────────────────────────────────────────────────────────────────────────
// BUY / SELL LOGIC
//──────────────────────────────────────────────────────────────────────────────
fearNow  = not na(extFear) and macd_raw <= extFear
greedNow = not na(extGreed) and macd_raw >= extGreed

crossIntoExtFear  = ta.crossunder(macd_raw, extFear)
crossIntoExtGreed = ta.crossover(macd_raw, extGreed)
crossOutOfExtFear = ta.crossover(macd_raw, extFear)
crossOutOfExtGreed = ta.crossunder(macd_raw, extGreed)

enterExtFear  = barstate.isconfirmed and (crossIntoExtFear or (fearNow and na(extFear[1])))
enterExtGreed = barstate.isconfirmed and (crossIntoExtGreed or (greedNow and na(extGreed[1])))

exitExtFear  = barstate.isconfirmed and crossOutOfExtFear
exitExtGreed = barstate.isconfirmed and crossOutOfExtGreed

var bool fearSession  = false
var bool greedSession = false

var float lastBuyMacdPivot  = na
var float lastSellMacdPivot = na
var float lastBuyPriceLow   = na
var float lastSellPriceHigh = na

if enterExtFear
    fearSession := true
    lastBuyMacdPivot := na
    lastBuyPriceLow := na

if enterExtGreed
    greedSession := true
    lastSellMacdPivot := na
    lastSellPriceHigh := na

if exitExtFear
    fearSession := false
    lastBuyMacdPivot := na
    lastBuyPriceLow := na

if exitExtGreed
    greedSession := false
    lastSellMacdPivot := na
    lastSellPriceHigh := na

pivLowSessionValid  = confirmedPivLow and fearSession[pivotR]
pivHighSessionValid = confirmedPivHigh and greedSession[pivotR]

pivLowIsExtreme  = confirmedPivLow and pivLow <= extFear[pivotR]
pivHighIsExtreme = confirmedPivHigh and pivHigh >= extGreed[pivotR]

var int lastBuySigBar  = na
var int lastSellSigBar = na

canFireBuy() =>
    na(lastBuySigBar) or bar_index - lastBuySigBar >= cooldownBars

canFireSell() =>
    na(lastSellSigBar) or bar_index - lastSellSigBar >= cooldownBars

pivStep = nz(macdDev[pivotR], 0.0) * rearmStepSigma

macdLowerLow   = not na(lastBuyMacdPivot) and pivLow < lastBuyMacdPivot - pivStep
macdHigherHigh = not na(lastSellMacdPivot) and pivHigh > lastSellMacdPivot + pivStep

priceLowerLow   = repeatOnPriceBreak and not na(lastBuyPriceLow) and pivLowPrice < lastBuyPriceLow - syminfo.mintick
priceHigherHigh = repeatOnPriceBreak and not na(lastSellPriceHigh) and pivHighPrice > lastSellPriceHigh + syminfo.mintick

buyNewExtreme  = na(lastBuyMacdPivot) or macdLowerLow or priceLowerLow
sellNewExtreme = na(lastSellMacdPivot) or macdHigherHigh or priceHigherHigh

buyCandidate  = pivLowSessionValid and pivLowIsExtreme and buyNewExtreme
sellCandidate = pivHighSessionValid and pivHighIsExtreme and sellNewExtreme

buy  = buyCandidate and canFireBuy()
sell = sellCandidate and canFireSell()

if buyCandidate
    lastBuyMacdPivot := na(lastBuyMacdPivot) ? pivLow : math.min(lastBuyMacdPivot, pivLow)
    lastBuyPriceLow := na(lastBuyPriceLow) ? pivLowPrice : math.min(lastBuyPriceLow, pivLowPrice)

if sellCandidate
    lastSellMacdPivot := na(lastSellMacdPivot) ? pivHigh : math.max(lastSellMacdPivot, pivHigh)
    lastSellPriceHigh := na(lastSellPriceHigh) ? pivHighPrice : math.max(lastSellPriceHigh, pivHighPrice)

if buy
    lastBuySigBar := bar_index

if sell
    lastSellSigBar := bar_index

signalBannerX = plotPivotsOnPivotBar ? bar_index - pivotR : bar_index
buyBannerY = plotPivotsOnPivotBar ? pivLow : macd_raw
sellBannerY = plotPivotsOnPivotBar ? pivHigh : macd_raw

if showBanners and buy
    label.new(signalBannerX, buyBannerY, "BUY", style=label.style_label_up, textcolor=color.black, color=color.lime, size=size.large)

if showBanners and sell
    label.new(signalBannerX, sellBannerY, "SELL", style=label.style_label_down, textcolor=color.white, color=color.red, size=size.large)

//──────────────────────────────────────────────────────────────────────────────
// MINI DASHBOARD
//──────────────────────────────────────────────────────────────────────────────
var table dashboard = table.new(position.top_right, 2, 7)

if barstate.islast
    presetTxt = zonePreset
    sentimentTxt = macd_raw >= extGreed ? "Extreme Greed" : macd_raw <= extFear ? "Extreme Fear" : macd_raw >= zoneGreed ? "Greed" : macd_raw <= zoneFear ? "Fear" : "Neutral"
    sentimentCol = macd_raw >= extGreed ? color.red : macd_raw <= extFear ? color.lime : macd_raw >= zoneGreed ? color.new(color.red, 0) : macd_raw <= zoneFear ? color.new(color.green, 0) : color.gray
    sessionTxt = fearSession ? "Fear Session" : greedSession ? "Greed Session" : "Idle"
    sessionCol = fearSession ? color.lime : greedSession ? color.red : color.gray

    positiveContracting = hist_raw > 0.0 and hist_raw < hist_raw[1]
    negativeContracting = hist_raw < 0.0 and hist_raw > hist_raw[1]
    pressureSide = hist_raw > 0.0 ? "GREED " : hist_raw < 0.0 ? "FEAR " : ""
    pressureStrength = activePressure < mediumPressureLevel ? "WEAK" : activePressure < strongPressureLevel ? "MEDIUM" : activePressure < extremePressureLevel ? "STRONG" : "EXTREME"
    pressurePhase = positiveContracting or negativeContracting ? " RELIEF " : " "
    pressureTxt = activePressure < neutralPressureLevel ? "NEUTRAL" : pressureSide + pressureStrength + pressurePhase + str.tostring(math.round(activePressure))
    pressureCol = activePressure < neutralPressureLevel ? color.silver : histColor

    table.cell(dashboard, 0, 0, "Preset:", text_color=color.white, text_halign=text.align_left, text_size=size.tiny)
    table.cell(dashboard, 1, 0, presetTxt, text_color=color.silver, text_halign=text.align_right, text_size=size.tiny)

    table.cell(dashboard, 0, 1, "Sentiment:", text_color=color.white, text_halign=text.align_left, text_size=size.tiny)
    table.cell(dashboard, 1, 1, sentimentTxt, text_color=sentimentCol, text_halign=text.align_right, text_size=size.tiny)

    table.cell(dashboard, 0, 2, "Lookback:", text_color=color.white, text_halign=text.align_left, text_size=size.tiny)
    table.cell(dashboard, 1, 2, str.tostring(zoneLookback), text_color=color.silver, text_halign=text.align_right, text_size=size.tiny)

    table.cell(dashboard, 0, 3, "Zone Mult:", text_color=color.white, text_halign=text.align_left, text_size=size.tiny)
    table.cell(dashboard, 1, 3, str.tostring(zoneMult, "#.##"), text_color=color.silver, text_halign=text.align_right, text_size=size.tiny)

    table.cell(dashboard, 0, 4, "Ext Mult:", text_color=color.white, text_halign=text.align_left, text_size=size.tiny)
    table.cell(dashboard, 1, 4, str.tostring(extK, "#.##"), text_color=color.silver, text_halign=text.align_right, text_size=size.tiny)

    table.cell(dashboard, 0, 5, "Session:", text_color=color.white, text_halign=text.align_left, text_size=size.tiny)
    table.cell(dashboard, 1, 5, sessionTxt, text_color=sessionCol, text_halign=text.align_right, text_size=size.tiny)

    table.cell(dashboard, 0, 6, "Histogram:", text_color=color.white, text_halign=text.align_left, text_size=size.tiny)
    table.cell(dashboard, 1, 6, pressureTxt, text_color=pressureCol, text_halign=text.align_right, text_size=size.tiny)

//──────────────────────────────────────────────────────────────────────────────
// ALERT CONDITIONS - close-confirmed and aligned with visible signals
//──────────────────────────────────────────────────────────────────────────────
crossIntoFearZone  = ta.crossunder(macd_raw, zoneFear)
crossIntoGreedZone = ta.crossover(macd_raw, zoneGreed)

confirmedEnterFearZone  = crossIntoFearZone and barstate.isconfirmed
confirmedEnterGreedZone = crossIntoGreedZone and barstate.isconfirmed

alertcondition(buy, title="Confirmed BUY Banner", message="Confirmed BUY banner on {{ticker}} — {{interval}}.")
alertcondition(sell, title="Confirmed SELL Banner", message="Confirmed SELL banner on {{ticker}} — {{interval}}.")
alertcondition(confirmedEnterFearZone, title="Entered Fear Zone", message="{{ticker}} entered the Fear zone on {{interval}} after candle close.")
alertcondition(confirmedEnterGreedZone, title="Entered Greed Zone", message="{{ticker}} entered the Greed zone on {{interval}} after candle close.")
alertcondition(histHighBanner, title="Histogram High Banner", message="Confirmed histogram High banner (H) on {{ticker}} — {{interval}}.")
alertcondition(histLowBanner, title="Histogram Low Banner", message="Confirmed histogram Low banner (L) on {{ticker}} — {{interval}}.")
alertcondition(internalHistHighBanner, title="Purple Internal Histogram High Banner", message="Confirmed purple internal histogram High banner (H) on {{ticker}} — {{interval}}.")
alertcondition(internalHistLowBanner, title="Purple Internal Histogram Low Banner", message="Confirmed purple internal histogram Low banner (L) on {{ticker}} — {{interval}}.")
alertcondition(confirmedCrossUp, title="Green Dot / MACD Cross Up", message="Green dot confirmed: MACD crossed above Signal on {{ticker}} — {{interval}}.")
alertcondition(confirmedCrossDown, title="Red Dot / MACD Cross Down", message="Red dot confirmed: MACD crossed below Signal on {{ticker}} — {{interval}}.")

// Luke 16:10 — “Whoever can be trusted with very little can also be trusted with much.”
// May God bless all your investments and trades!
````
