# Gabremoku Clouds

- url: https://www.tradingview.com/script/XTAVGPWK-Gabremoku-Clouds/
- type: indicator
- pine_id: PUB;3c49f75f9c1d418f96f386247b662c17
- version: 2.0

## Description

[b]Gabremoku Clouds[/b] is a volume-driven equilibrium cloud built to highlight fair-value zones, directional acceptance, and compression/expansion phases in a cleaner and more forward-looking way than traditional cloud indicators. Instead of using classic Ichimoku spans or standard deviation bands, this script builds its structure around a custom volume-weighted equilibrium line and a surrounding cloud whose width is based on Volume-Weighted Average Spread (VWAS). The result is a cloud that reacts not only to price movement, but also to how price is distributed under volume, making it useful for reading consensus, imbalance, and market acceptance.

A key idea behind this indicator is that not all price movement has the same meaning. When volume concentrates inside a tighter range, the cloud compresses and signals balance or consensus. When price expands with broader spread and weaker concentration, the cloud widens and reflects uncertainty or directional transition. This gives the indicator a different purpose from standard volatility envelopes: it is designed less as a generic overbought/oversold tool and more as a market structure and equilibrium map.

The script also includes a 26-period forward projection of the equilibrium cloud. This projected area is calculated from current and historical information only, then shifted forward visually to provide a future reference zone without using lookahead logic. Its purpose is not to predict price in an absolute sense, but to suggest where balance may migrate next if the current slope and cloud conditions remain consistent.

[b]What it helps identify[/b]
Trend acceptance when price holds above or below the cloud with supporting volume.

Fair-value reclaims when price rotates back into equilibrium after displacement.

Squeeze-to-expansion transitions when the cloud compresses and then releases into directional movement.

Exhaustion when price reaches a fresh extreme while volume momentum decelerates.

[b]How to use it[/b]
Use the current cloud to judge whether price is trading in balance, in directional acceptance, or in transition.

Use the projected cloud as a forward reference area for continuation, reversion, or future balance.

Treat the signals as contextual tools, not standalone trade instructions. They work best when combined with price structure, market context, and risk management.

[b]What is new[/b]
[b]Gabremoku Clouds[/b] is not a mashup of existing tools. Its core logic is built around a custom equilibrium model that combines volume-weighted price location with volume-weighted spread behavior, then extends that structure into a forward cloud projection. The goal is to give traders a more informative cloud: one that reflects where value is forming now, how stable that value is, and where it may shift next.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Gabremoku

//@version=6
indicator("Gabremoku Clouds with Reversion Bubbles [Gabremoku]", overlay=true, max_labels_count=500)

// ── INPUTS ─────────────────────────────────────────────────────
grp0 = "⚙️ Core"
src             = input.source(close, "Source", group=grp0)
eqPeriod        = input.int(26, "Equilibrium Period", group=grp0, minval=5, maxval=200)
cloudMult       = input.float(1.5, "Cloud Multiplier", group=grp0, minval=0.5, maxval=5.0, step=0.1)
slopeLen        = input.int(3, "Slope Length", group=grp0, minval=1, maxval=20)

grp1 = "📊 Volume"
volAvgPeriod    = input.int(20, "Volume Average Period", group=grp1, minval=5, maxval=200)
volHighThresh   = input.float(1.5, "High Volume Threshold", group=grp1, minval=1.0, maxval=5.0, step=0.1)
volLowThresh    = input.float(0.7, "Low Volume Threshold", group=grp1, minval=0.1, maxval=1.0, step=0.1)
velLookback     = input.int(3, "Volume Velocity Lookback", group=grp1, minval=1, maxval=20)

grp2 = "🔮 Projection"
showProjection        = input.bool(false, "Show Projected Equilibrium", group=grp2)
projectionForward     = input.int(26, "Projection Forward", group=grp2, minval=1, maxval=100)
projectionSlopeLen    = input.int(5, "Projection Slope Length", group=grp2, minval=1, maxval=50)
projectionSmoothLen   = input.int(13, "Projection Smoothing Length", group=grp2, minval=2, maxval=100)
projectionSlopeSmooth = input.int(5, "Projection Slope Smoothing", group=grp2, minval=1, maxval=50)
projectionDamping     = input.float(0.55, "Projection Damping", group=grp2, minval=0.10, maxval=1.00, step=0.05)

grp9 = "🌸 Adaptive Kumo"
showKumo            = input.bool(false, "Show Adaptive Kumo", group=grp9)
kumoShift           = input.int(13, "Kumo Shift Forward", group=grp9, minval=1, maxval=100)
kumoTenkanLen       = input.int(9, "Span A — Short Period", group=grp9, minval=3, maxval=50)
kumoKijunLen        = input.int(26, "Span A — Long Period", group=grp9, minval=10, maxval=100)
kumoSpanBLen        = input.int(52, "Span B — Wide Period", group=grp9, minval=20, maxval=200)
kumoLineTransp      = input.int(45, "Kumo Line Transparency", group=grp9, minval=0, maxval=100)
kumoNearTransp      = input.int(88, "Kumo Gradient Near Transparency", group=grp9, minval=0, maxval=100)
kumoFarTransp       = input.int(96, "Kumo Gradient Far Transparency", group=grp9, minval=0, maxval=100)

grpSig = "🎯 Signals"
showLongShort       = input.bool(true, "Show LONG / SHORT Signals", group=grpSig)
showExhaustion      = input.bool(true, "Include Exhaustion Reversals", group=grpSig)
showSqzBreak        = input.bool(true, "Include Squeeze Breakouts", group=grpSig)
minConfluence       = input.int(2, "Min Confluence to Fire (1–3)", group=grpSig, minval=1, maxval=3)

grp11 = "🫧 Bubble Bands"
showBubbleSignals      = input.bool(true, "Show Bubble Signals", group=grp11)
keepHistoricalBubbles  = input.bool(true, "Keep Historical Bubbles", group=grp11)
bubbleMode             = input.string("Reentry", "Bubble Trigger Mode", options=["Touch", "Reentry"], group=grp11)
bubbleBandMult         = input.float(2.0, "Bubble Band (VWAS Multiplier)", minval=0.5, maxval=5.0, step=0.1, group=grp11)
flatSlopeThreshold     = input.float(2.5, "Flat Slope Threshold", minval=0.5, maxval=10.0, step=0.1, group=grp11)
bubbleCooldown         = input.int(5, "Bubble Cooldown Bars", minval=0, maxval=100, group=grp11)
useKumoFilter          = input.bool(true, "Use Kumo Direction Filter", group=grp11)
useContractionOnly     = input.bool(true, "Only in Contraction Regime", group=grp11)

grp3 = "🎨 Colors"
bullColor              = input.color(color.rgb(47, 102, 255), "Bull Color", group=grp3)
bearColor              = input.color(color.rgb(241, 222, 52), "Bear Color", group=grp3)
neutralColor           = input.color(color.rgb(120, 120, 130), "Neutral Color", group=grp3)
squeezeColor           = input.color(color.rgb(170, 0, 255), "Squeeze Color", group=grp3)
bubbleLongMarkerColor  = input.color(color.rgb(0, 200, 140), "Long Bubble Marker Color", group=grp3)
bubbleShortMarkerColor = input.color(color.rgb(255, 82, 82), "Short Bubble Marker Color", group=grp3)
bubbleLowerLineColor   = input.color(color.rgb(0, 120, 90), "Bubble Lower Line Color", group=grp3)
bubbleUpperLineColor   = input.color(color.rgb(120, 35, 35), "Bubble Upper Line Color", group=grp3)

grp4 = "🔮 Projection Colors"
projBullColor       = input.color(color.rgb(47, 102, 255), "Projection Bull Color", group=grp4)
projBearColor       = input.color(color.rgb(241, 222, 52), "Projection Bear Color", group=grp4)
projNeutralColor    = input.color(color.rgb(120, 120, 130), "Projection Neutral Color", group=grp4)
projSqueezeColor    = input.color(color.rgb(170, 0, 255), "Projection Squeeze Color", group=grp4)

grp5 = "📐 Style"
showCloud       = input.bool(true, "Show VWEB Cloud", group=grp5)
showMidline     = input.bool(true, "Show VWEB Midline", group=grp5)
showBarColors   = input.bool(false, "Color Bars", group=grp5)
midlineWidth    = input.int(2, "Midline Width", group=grp5, minval=1, maxval=5)
cloudLineWidth  = input.int(1, "Cloud Border Width", group=grp5, minval=1, maxval=5)

grp6 = "🗜️ Squeeze"
sqzLookback     = input.int(50, "Squeeze Lookback", group=grp6, minval=10, maxval=500)
sqzThreshold    = input.float(0.15, "Squeeze Threshold", group=grp6, minval=0.01, maxval=0.50, step=0.01)
highlightSqzBg  = input.bool(false, "Highlight Squeeze Background", group=grp6)

grp7 = "⚠️ Exhaustion"
exhLookback     = input.int(20, "Exhaustion Lookback", group=grp7, minval=5, maxval=100)
exhDistanceMult = input.float(0.25, "Min Distance From Cloud", group=grp7, minval=0.05, maxval=2.0, step=0.05)
exhDecelMin     = input.float(0.20, "Min Volume Deceleration", group=grp7, minval=0.05, maxval=2.0, step=0.05)

grp8 = "🪧 Dashboard"
showDashboard      = input.bool(true, "Show Dashboard", group=grp8)
dashPosInput       = input.string("Bottom Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grp8)
dashTextSizeInput  = input.string("Small", "Dashboard Text Size", options=["Tiny", "Small", "Normal"], group=grp8)

grp10 = "🏷️ End Labels"
showEndLabels      = input.bool(true, "Show End Labels", group=grp10)
labelOffsetBars    = input.int(2, "Label Offset Bars", group=grp10, minval=1, maxval=20)


// ── HELPERS ────────────────────────────────────────────────────
clamp(_x, _min, _max) =>
    math.max(_min, math.min(_max, _x))

dashTextSize = size.small
if dashTextSizeInput == "Tiny"
    dashTextSize := size.tiny
else if dashTextSizeInput == "Normal"
    dashTextSize := size.normal

dashPos = position.bottom_right
if dashPosInput == "Top Right"
    dashPos := position.top_right
else if dashPosInput == "Top Left"
    dashPos := position.top_left
else if dashPosInput == "Bottom Left"
    dashPos := position.bottom_left


// ── CORE SERIES ────────────────────────────────────────────────
typicalPrice = (high + low + close) / 3.0
spread       = high - low

sumVol       = math.sum(volume, eqPeriod)
sumVolPrice  = math.sum(volume * typicalPrice, eqPeriod)
sumVolSpread = math.sum(volume * spread, eqPeriod)

equilibrium     = sumVol != 0 ? sumVolPrice / sumVol : typicalPrice
vwas            = sumVol != 0 ? sumVolSpread / sumVol : spread
cloudUpper      = equilibrium + cloudMult * vwas
cloudLower      = equilibrium - cloudMult * vwas
cloudWidth      = cloudUpper - cloudLower
cloudPos        = cloudWidth != 0 ? (src - equilibrium) / (cloudWidth / 2.0) : 0.0
cloudPosClamped = clamp(cloudPos, -2.0, 2.0)


// ── VOLUME REGIME ──────────────────────────────────────────────
volAvg           = ta.sma(volume, volAvgPeriod)
volRatio         = volAvg != 0 ? volume / volAvg : 1.0
volHigh          = volRatio >= volHighThresh
volLow           = volRatio <= volLowThresh
volIntensity     = volHigh ? "High" : volLow ? "Low" : "Normal"
volVelocity      = volRatio - volRatio[velLookback]
volAccel         = volVelocity > 0.10
volDecel         = volVelocity < -0.10
volVelocityState = volAccel ? "Accel" : volDecel ? "Decel" : "Flat"


// ── SQUEEZE ────────────────────────────────────────────────────
vwasMin   = ta.lowest(vwas, sqzLookback)
vwasMax   = ta.highest(vwas, sqzLookback)
vwasNorm  = vwasMax != vwasMin ? (vwas - vwasMin) / (vwasMax - vwasMin) : 0.0
isSqueeze = vwasNorm <= sqzThreshold


// ── STATE ──────────────────────────────────────────────────────
eqRising  = equilibrium > equilibrium[slopeLen]
eqFalling = equilibrium < equilibrium[slopeLen]

state =
     isSqueeze ? "Squeeze" :
     src > cloudUpper and volHigh ? "Accepted Above" :
     src < cloudLower and volHigh ? "Accepted Below" :
     src > equilibrium and eqRising ? "Bull Bias" :
     src < equilibrium and eqFalling ? "Bear Bias" :
     "Neutral"

stateColor =
     isSqueeze ? squeezeColor :
     state == "Accepted Above" ? bullColor :
     state == "Accepted Below" ? bearColor :
     state == "Bull Bias" ? bullColor :
     state == "Bear Bias" ? bearColor :
     neutralColor


// ── ADAPTIVE KUMO ──────────────────────────────────────────────
sumVolShort = math.sum(volume, kumoTenkanLen)
sumVolLong  = math.sum(volume, kumoKijunLen)

vwepShort   = sumVolShort != 0 ? math.sum(volume * typicalPrice, kumoTenkanLen) / sumVolShort : typicalPrice
vwepLong    = sumVolLong  != 0 ? math.sum(volume * typicalPrice, kumoKijunLen) / sumVolLong  : typicalPrice

kumoSpanA   = (vwepShort + vwepLong) / 2.0
kumoSpanB   = (ta.highest(typicalPrice, kumoSpanBLen) + ta.lowest(typicalPrice, kumoSpanBLen)) / 2.0
kumoBull    = kumoSpanA >= kumoSpanB

kumoThickness    = math.abs(kumoSpanA - kumoSpanB)
kumoThicknessMin = ta.lowest(kumoThickness, kumoSpanBLen)
kumoThicknessMax = ta.highest(kumoThickness, kumoSpanBLen)
kumoMagNorm      = kumoThicknessMax != kumoThicknessMin ? (kumoThickness - kumoThicknessMin) / (kumoThicknessMax - kumoThicknessMin) : 0.0

kumoNearAlpha = int(math.round(kumoNearTransp - (kumoMagNorm * 18)))
kumoFarAlpha  = int(math.round(kumoFarTransp  - (kumoMagNorm * 10)))

kumoNearAlpha := clamp(kumoNearAlpha, 0, 100)
kumoFarAlpha  := clamp(kumoFarAlpha, 0, 100)


// ── PROJECTION EQUILIBRIUM ─────────────────────────────────────
eqProjectionBase   = ta.ema(equilibrium, projectionSmoothLen)
eqSlopeRaw         = eqProjectionBase - eqProjectionBase[projectionSlopeLen]
eqSlopePerBar      = projectionSlopeLen != 0 ? eqSlopeRaw / projectionSlopeLen : 0.0
eqSlopePerBarSmth  = ta.ema(eqSlopePerBar, projectionSlopeSmooth)
projEquilibrium    = eqProjectionBase + (eqSlopePerBarSmth * projectionForward * projectionDamping)

projBull = projEquilibrium > eqProjectionBase
projBear = projEquilibrium < eqProjectionBase


// ── CONFLUENCE SCORE ───────────────────────────────────────────
confBull =
     (state == "Bull Bias" or state == "Accepted Above" ? 1 : 0) +
     (kumoBull ? 1 : 0) +
     (projBull ? 1 : 0)

confBear =
     (state == "Bear Bias" or state == "Accepted Below" ? 1 : 0) +
     (not kumoBull ? 1 : 0) +
     (projBear ? 1 : 0)

confScore    = math.max(confBull, confBear)
confBullSide = confBull >= confBear
confStr      = confScore == 3 ? "★★★ Full" : confScore == 2 ? "★★☆ Partial" : "★☆☆ Low"
confColor    = confScore == 3 ? (confBullSide ? bullColor : bearColor) : confScore == 2 ? (confBullSide ? color.new(bullColor, 40) : color.new(bearColor, 40)) : neutralColor


// ── RAW SIGNAL CONDITIONS ──────────────────────────────────────
reclaimLong    = ta.crossover(src, cloudLower) and src < equilibrium and volHigh and kumoBull
rejectionShort = ta.crossunder(src, cloudUpper) and src > equilibrium and volHigh and not kumoBull

sqzBreakBull   = isSqueeze[1] and not isSqueeze and src > equilibrium and volHigh and kumoBull
sqzBreakBear   = isSqueeze[1] and not isSqueeze and src < equilibrium and volHigh and not kumoBull

newHigh        = high >= ta.highest(high, exhLookback)[1]
newLow         = low  <= ta.lowest(low, exhLookback)[1]
farAboveCloud  = src > cloudUpper and (src - cloudUpper) > (vwas * exhDistanceMult)
farBelowCloud  = src < cloudLower and (cloudLower - src) > (vwas * exhDistanceMult)
strongDecel    = volVelocity < -exhDecelMin
exhaustBear    = newHigh and farAboveCloud and strongDecel and not kumoBull
exhaustBull    = newLow  and farBelowCloud and strongDecel and kumoBull


// ── BUBBLE BAND ENGINE ─────────────────────────────────────────
bubbleUpperLine = equilibrium + vwas * bubbleBandMult
bubbleLowerLine = equilibrium - vwas * bubbleBandMult
bubbleSlopeAbs  = math.abs(equilibrium - equilibrium[eqPeriod - 1])
isContraction   = bubbleSlopeAbs < (vwas * flatSlopeThreshold)

allowBubbleRegime = useContractionOnly ? isContraction : true
allowBullBubble   = useKumoFilter ? kumoBull : true
allowBearBubble   = useKumoFilter ? not kumoBull : true

bubbleTouchLong    = low <= bubbleLowerLine
bubbleTouchShort   = high >= bubbleUpperLine
bubbleReentryLong  = low < bubbleLowerLine and close > bubbleLowerLine and close < equilibrium
bubbleReentryShort = high > bubbleUpperLine and close < bubbleUpperLine and close > equilibrium

rawBubbleLong  = bubbleMode == "Touch" ? bubbleTouchLong : bubbleReentryLong
rawBubbleShort = bubbleMode == "Touch" ? bubbleTouchShort : bubbleReentryShort

var int lastBullBubbleBar = na
var int lastBearBubbleBar = na

cooldownBullOk = na(lastBullBubbleBar) or bar_index - lastBullBubbleBar > bubbleCooldown
cooldownBearOk = na(lastBearBubbleBar) or bar_index - lastBearBubbleBar > bubbleCooldown

bubbleLongSignal  = showBubbleSignals and allowBubbleRegime and allowBullBubble and rawBubbleLong and cooldownBullOk
bubbleShortSignal = showBubbleSignals and allowBubbleRegime and allowBearBubble and rawBubbleShort and cooldownBearOk

if bubbleLongSignal
    lastBullBubbleBar := bar_index
if bubbleShortSignal
    lastBearBubbleBar := bar_index

var label[] histBubbles = array.new<label>()
if keepHistoricalBubbles and showBubbleSignals
    if bubbleLongSignal
        array.push(histBubbles, label.new(bar_index, low, text="", style=label.style_circle, color=bubbleLongMarkerColor, size=size.small))
    if bubbleShortSignal
        array.push(histBubbles, label.new(bar_index, high, text="", style=label.style_circle, color=bubbleShortMarkerColor, size=size.small))


// ── LONG / SHORT SIGNALS ───────────────────────────────────────
longTouchRaw  = low <= bubbleLowerLine
shortTouchRaw = high >= bubbleUpperLine

var int signalSide = 0
longSignal  = false
shortSignal = false

if showLongShort
    if longTouchRaw and signalSide <= 0
        longSignal := true
        signalSide := 1
    else if shortTouchRaw and signalSide >= 0
        shortSignal := true
        signalSide := -1

lastSignalSrc = longSignal ? "Bubble Lower Line Touch" : shortSignal ? "Bubble Upper Line Touch" : ""

var string lastSignalType = "—"
var string lastSignalSource = "—"
if longSignal
    lastSignalType   := "LONG"
    lastSignalSource := lastSignalSrc
else if shortSignal
    lastSignalType   := "SHORT"
    lastSignalSource := lastSignalSrc


// ── VISUALS ────────────────────────────────────────────────────
cloudAlphaNear = volHigh ? 72 : volLow ? 90 : 82
cloudAlphaFar  = volHigh ? 82 : volLow ? 95 : 88

upperFillColor =
     state == "Accepted Above" or state == "Bull Bias" ? color.new(bullColor, cloudAlphaNear) :
     state == "Accepted Below" or state == "Bear Bias" ? color.new(bearColor, cloudAlphaNear) :
     isSqueeze ? color.new(squeezeColor, cloudAlphaNear) :
     color.new(neutralColor, cloudAlphaNear)

lowerFillColor =
     state == "Accepted Above" or state == "Bull Bias" ? color.new(bullColor, cloudAlphaFar) :
     state == "Accepted Below" or state == "Bear Bias" ? color.new(bearColor, cloudAlphaFar) :
     isSqueeze ? color.new(squeezeColor, cloudAlphaFar) :
     color.new(neutralColor, cloudAlphaFar)

midlineColor =
     isSqueeze ? squeezeColor :
     math.abs(cloudPosClamped) <= 0.15 ? neutralColor :
     cloudPosClamped > 0 ? bullColor : bearColor

borderColor =
     isSqueeze ? color.new(squeezeColor, 15) :
     state == "Accepted Above" or state == "Bull Bias" ? color.new(bullColor, 20) :
     state == "Accepted Below" or state == "Bear Bias" ? color.new(bearColor, 20) :
     color.new(neutralColor, 20)

projLineColor =
     isSqueeze ? color.new(projSqueezeColor, 82) :
     projBull ? color.new(projBullColor, 84) :
     projBear ? color.new(projBearColor, 84) :
     color.new(projNeutralColor, 86)

kumoLineA =
     kumoBull ? color.new(bullColor, kumoLineTransp) :
     color.new(bearColor, kumoLineTransp)

kumoLineB =
     kumoBull ? color.new(bullColor, kumoLineTransp + 12) :
     color.new(bearColor, kumoLineTransp + 12)

kumoFillNear =
     kumoBull ? color.new(bullColor, kumoNearAlpha) :
     color.new(bearColor, kumoNearAlpha)

kumoFillFar =
     kumoBull ? color.new(bullColor, kumoFarAlpha) :
     color.new(bearColor, kumoFarAlpha)


// ── PLOTS ──────────────────────────────────────────────────────
midPlot   = plot(showMidline ? equilibrium : na, "Equilibrium", color=midlineColor, linewidth=midlineWidth)
upperPlot = plot(showCloud ? cloudUpper : na, "Cloud Upper", color=borderColor, linewidth=cloudLineWidth)
lowerPlot = plot(showCloud ? cloudLower : na, "Cloud Lower", color=borderColor, linewidth=cloudLineWidth)

fill(upperPlot, midPlot, cloudUpper, equilibrium, upperFillColor, color.new(color.black, 100))
fill(midPlot, lowerPlot, equilibrium, cloudLower, color.new(color.black, 100), lowerFillColor)

kumoAPlot = plot(showKumo ? kumoSpanA : na, "Kumo Span A", color=kumoLineA, linewidth=1, offset=kumoShift)
kumoBPlot = plot(showKumo ? kumoSpanB : na, "Kumo Span B", color=kumoLineB, linewidth=1, offset=kumoShift)
kumoMid   = (kumoSpanA + kumoSpanB) / 2.0
kumoMidPlot = plot(showKumo ? kumoMid : na, "Kumo Mid", color=color.new(color.black, 100), linewidth=1, offset=kumoShift)

fill(kumoAPlot, kumoMidPlot, kumoSpanA, kumoMid, kumoFillNear, color.new(color.black, 100))
fill(kumoMidPlot, kumoBPlot, kumoMid, kumoSpanB, color.new(color.black, 100), kumoFillFar)

projPlot = plot(showProjection ? projEquilibrium : na, "Projected Equilibrium", color=projLineColor, linewidth=1, offset=projectionForward)

plot(showBubbleSignals ? bubbleUpperLine : na, "Bubble Upper Line", color=color.new(bubbleUpperLineColor, 20), linewidth=1, style=plot.style_line)
plot(showBubbleSignals ? bubbleLowerLine : na, "Bubble Lower Line", color=color.new(bubbleLowerLineColor, 20), linewidth=1, style=plot.style_line)

bgcolor(highlightSqzBg and isSqueeze ? color.new(squeezeColor, 90) : na, title="Squeeze Background")

barcolor(
     showBarColors ?
     isSqueeze ? color.new(squeezeColor, 40) :
     src > cloudUpper ? color.new(bullColor, 0) :
     src < cloudLower ? color.new(bearColor, 0) :
     src > equilibrium ? color.new(bullColor, 65) :
     src < equilibrium ? color.new(bearColor, 65) : na
     : na)

plotshape(showLongShort and longSignal, title="LONG",
     text="▲ L", style=shape.labelup,
     location=location.belowbar,
     color=bullColor, textcolor=color.white,
     size=size.small)

plotshape(showLongShort and shortSignal, title="SHORT",
     text="▼ S", style=shape.labeldown,
     location=location.abovebar,
     color=bearColor, textcolor=color.black,
     size=size.small)

plotshape(showBubbleSignals and not keepHistoricalBubbles and bubbleLongSignal, title="Long Bubble", text="", style=shape.circle, location=location.belowbar, color=bubbleLongMarkerColor, size=size.small)
plotshape(showBubbleSignals and not keepHistoricalBubbles and bubbleShortSignal, title="Short Bubble", text="", style=shape.circle, location=location.abovebar, color=bubbleShortMarkerColor, size=size.small)


// ── END LABELS ─────────────────────────────────────────────────
var label lblKumoA = na
var label lblKumoB = na
var label lblProj  = na

if barstate.islast and showEndLabels
    label.delete(lblKumoA)
    label.delete(lblKumoB)
    label.delete(lblProj)

    if showKumo
        lblKumoA := label.new(bar_index + kumoShift + labelOffsetBars, kumoSpanA, "Adaptive Kumo A", xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.black, 100), textcolor=color.new(kumoBull ? bullColor : bearColor, 28), size=size.small)
        lblKumoB := label.new(bar_index + kumoShift + labelOffsetBars, kumoSpanB, "Adaptive Kumo B", xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.black, 100), textcolor=color.new(kumoBull ? bullColor : bearColor, 42), size=size.small)

    if showProjection
        lblProj := label.new(bar_index + projectionForward + labelOffsetBars, projEquilibrium, "Projected Equilibrium", xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.black, 100), textcolor=color.new(projBull ? projBullColor : projBear ? projBearColor : projNeutralColor, 72), size=size.small)


// ── DASHBOARD ─────────────────────────────────────────────────
cloudLocation    = src > cloudUpper ? "Above" : src < cloudLower ? "Below" : "Inside"
slopeState       = eqRising ? "Rising" : eqFalling ? "Falling" : "Flat"
projState        = projBull ? "Upward" : projBear ? "Downward" : "Flat"
kumoState        = kumoBull ? "Bullish" : "Bearish"
lastSignalColor  = lastSignalType == "LONG" ? bullColor : lastSignalType == "SHORT" ? bearColor : neutralColor
bubbleState      = bubbleLongSignal ? "Long Bubble" : bubbleShortSignal ? "Short Bubble" : "Idle"
bubbleStateColor = bubbleLongSignal ? bubbleLongMarkerColor : bubbleShortSignal ? bubbleShortMarkerColor : neutralColor

var table dash = table.new(dashPos, 2, 12, border_width=1)

if barstate.isfirst
    dash := table.new(dashPos, 2, 12, border_width=1)

if barstate.islast and showDashboard
    table.cell(dash, 0, 0, "State", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 0, state, text_color=stateColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 1, "Kumo", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 1, kumoState, text_color=kumoBull ? bullColor : bearColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 2, "Projection", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 2, projState, text_color=projBull ? bullColor : projBear ? bearColor : neutralColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 3, "Confluence", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 3, confStr, text_color=confColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 4, "Slope", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 4, slopeState, text_color=eqRising ? bullColor : eqFalling ? bearColor : neutralColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 5, "Vol Intensity", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 5, volIntensity, text_color=volHigh ? bullColor : volLow ? bearColor : neutralColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 6, "Vol Velocity", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 6, volVelocityState, text_color=volAccel ? bullColor : volDecel ? bearColor : neutralColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 7, "VWAS", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 7, str.tostring(vwas, "#.00"), text_color=chart.fg_color, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 8, "Last Signal", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 8, lastSignalType, text_color=lastSignalColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 9, "Trigger", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 9, lastSignalSource, text_color=lastSignalColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 10, "Bubble", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 10, bubbleState, text_color=bubbleStateColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 11, "Regime", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 11, isContraction ? "Contraction" : "Expansion", text_color=isContraction ? color.orange : neutralColor, text_halign=text.align_center, text_size=dashTextSize)

if barstate.islast and not showDashboard
    table.clear(dash, 0, 0, 1, 11)
````
