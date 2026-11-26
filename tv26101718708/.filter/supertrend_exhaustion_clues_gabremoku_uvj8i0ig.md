# SuperTrend Exhaustion Clues [Gabremoku]

- url: https://www.tradingview.com/script/uvj8i0ig-SuperTrend-Exhaustion-Clues-Gabremoku/
- type: indicator
- pine_id: PUB;d5d3678474bb457ea33c35e2318aec48
- version: 1.0

## Description

[b]SuperTrend Exhaustion Clues[/b] is a context-aware SuperTrend indicator that separates structural direction from signal timing. Instead of treating every flip as a trade trigger, it classifies market behavior into four states: Transition, Confirmed, Compressed Break, and Exhausted. The goal is to show when trend structure is still healthy, when it is compressing, and when it is weakening enough to start looking for directional clues.

The core logic combines four elements: SuperTrend for directional structure, ADX and DI for trend strength, VWAP and price location for acceptance, and compression detection for squeeze/release context. These components are not merged just for convenience; they work together to decide whether price is merely changing direction structurally or whether it is also showing enough internal confirmation to justify attention.

BUY and SELL signals are not printed on every flip. They are designed to appear only during Exhausted phases, and only when directional clues align with the next likely move. This makes the indicator more selective than a standard SuperTrend and better suited to reading late-stage trend fatigue and early follow-through behavior.

A built-in Signal Profile lets you choose between Responsive, Balanced, and Selective behavior. Responsive lowers the confirmation threshold and is better for faster charts, Balanced is the default middle ground, and Selective raises the bar for cleaner but rarer signals. For this reason, the script is especially useful on lower timeframes, where exhaustion tends to be easier to read and directional clues appear earlier.

For higher timeframes, the script can keep showing state, regime, and clue scores while disabling signals from 4H and above. This helps avoid forcing execution signals where the exhaustion logic is less expressive, while still letting you use the indicator for context and structure.

The visual design is intentionally restrained: bullish states are blue, bearish states are yellow, compression is purple, transition is gray, and exhaustion is red. The SuperTrend line, gradient fill, dashboard, and color legend are meant to make the state of the market easy to read at a glance without cluttering the chart.

How to use it: watch the current state first, then use Exhausted phases as the main area of interest. When the script shows Exhausted and the directional clue score aligns with the next move, that is the moment it is designed to highlight. On 4H and above, the script is better used as a structural context tool rather than a signal engine.

[i]@Gabremoku 
TradingView[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Gabremoku

//@version=6
indicator("SuperTrend Exhaustion Clues [Gabremoku]", overlay=true, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════
//  SuperTrend Exhaustion Clues [Gabremoku]
//  Context-aware SuperTrend with exhaustion-based signal engine
//
//  Core concept:
//  1) SuperTrend defines structural direction.
//  2) State classification tracks Transition / Confirmed /
//     Compressed Break / Exhausted.
//  3) Main BUY / SELL signals do NOT trigger on simple flips.
//  4) Signals appear during Exhausted phases only when
//     directional clues suggest the next likely move.
//  5) Signal Profile adapts sensitivity.
//  6) Signals can be disabled on 4H+ to keep higher timeframes
//     focused on state reading rather than execution timing.
// ═══════════════════════════════════════════════════════════════

// ── INPUTS ─────────────────────────────────────────────────────
grp0 = "⚙️ Core"
atrLen = input.int(10, "ATR Length", minval=1, group=grp0)
factor = input.float(3.0, "Factor", minval=0.1, step=0.1, group=grp0)
src    = input.source(hl2, "Source", group=grp0)

grp00 = "🎛️ Signal Profile"
signalProfile = input.string("Balanced", "Signal Profile", options=["Responsive", "Balanced", "Selective"], group=grp00)

grp01 = "⏱️ Timeframe Logic"
disableSignalsOnHTF = input.bool(true, "Disable Signals On 4H+", group=grp01)

grp1 = "🎨 Colors"
bullColor    = input.color(color.rgb(33, 150, 243), "Bullish Color (Blue)", group=grp1)
bearColor    = input.color(color.rgb(241, 255, 48), "Bearish Color (Yellow)", group=grp1)
squeezeColor = input.color(color.rgb(156, 39, 176), "Compression Color", group=grp1)
neutralColor = input.color(color.rgb(158, 158, 158), "Transition Color", group=grp1)
weakColor    = input.color(color.rgb(244, 67, 54), "Exhausted Color (Red)", group=grp1)

grp2 = "📐 Style"
showSignals      = input.bool(true, "Show Signals", group=grp2)
showBarColors    = input.bool(true, "Color Bars", group=grp2)
showEma          = input.bool(false, "Show EMA Filter", group=grp2)
showLabels       = input.bool(true, "Show Last Value Label", group=grp2)
showFill         = input.bool(true, "Show Gradient Fill", group=grp2)
lineWidth        = input.int(2, "SuperTrend Width", minval=1, maxval=5, group=grp2)
showMinorMarkers = input.bool(false, "Show Minor Continuation Markers", group=grp2)

grp3 = "🧭 Structure Filter"
useEmaFilter = input.bool(false, "Use EMA Structure Filter", group=grp3)
emaLen       = input.int(200, "EMA Length", minval=1, group=grp3)

grp4 = "🗜️ Compression"
enableSqueezeDetection = input.bool(true, "Enable Compression Detection", group=grp4)
enableSqueezeColor     = input.bool(true, "Color ST / Fill During Compression Break", group=grp4)
sqzLookback            = input.int(100, "Compression Lookback", minval=10, group=grp4)
sqzThreshold           = input.float(0.15, "Compression Threshold Percentile", minval=0.01, maxval=0.50, step=0.01, group=grp4)
postSqueezeBars        = input.int(3, "Release Window", minval=1, maxval=20, group=grp4)

grp5 = "🧠 Context"
useAdxContext    = input.bool(true, "Use ADX / DI Context", group=grp5)
diLen            = input.int(14, "DI Length", minval=1, group=grp5)
adxSmoothing     = input.int(14, "ADX Smoothing", minval=1, group=grp5)
adxThreshold     = input.float(18.0, "ADX Threshold", minval=1.0, step=0.5, group=grp5)
requireAdxRising = input.bool(false, "Require Rising ADX", group=grp5)

useVwapContext   = input.bool(true, "Use VWAP Acceptance", group=grp5)
useMagnitudeRise = input.bool(true, "Use Distance Expansion", group=grp5)
confirmedMinScoreInput = input.int(2, "Confirmed Score", minval=1, maxval=4, group=grp5)
breakMinScoreInput     = input.int(2, "Compressed Break Score", minval=1, maxval=4, group=grp5)

grp6 = "🎯 Exhaustion Clues"
clueThresholdInput = input.int(3, "Directional Clue Score", minval=1, maxval=4, group=grp6)
useCounterTrendExhaustion = input.bool(true, "Use Counter-Trend Exhaustion Signals", group=grp6)
useContinuationExhaustion = input.bool(false, "Use Continuation Exhaustion Signals", group=grp6)

grp7 = "🌈 Gradient Logic"
fillAggressive = input.float(1.60, "Fill Aggressiveness", minval=0.5, maxval=4.0, step=0.1, group=grp7)
maxOpacityNear = input.int(100, "Fill Opacity Near ST", minval=0, maxval=100, group=grp7)
minOpacityFar  = input.int(70, "Fill Opacity Far From ST", minval=0, maxval=100, group=grp7)

grp8 = "🪧 Dashboard"
showDashboard      = input.bool(true, "Show Main Dashboard", group=grp8)
dashPosInput       = input.string("Bottom Right", "Main Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grp8)
dashTextSizeInput  = input.string("Small", "Main Dashboard Text Size", options=["Tiny", "Small", "Normal"], group=grp8)

grp9 = "🎨 Color Legend"
showLegend          = input.bool(true, "Show Color Legend", group=grp9)
legendPosInput      = input.string("Top Right", "Legend Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grp9)
legendTextSizeInput = input.string("Small", "Legend Text Size", options=["Tiny", "Small", "Normal"], group=grp9)

// ── PROFILE ADAPTATION ────────────────────────────────────────
confirmedMinScore = confirmedMinScoreInput
breakMinScore     = breakMinScoreInput
clueThreshold     = clueThresholdInput
exhaustionMaxScore = 1
compressionWindow = postSqueezeBars

if signalProfile == "Responsive"
    confirmedMinScore := math.max(1, confirmedMinScoreInput - 1)
    breakMinScore     := math.max(1, breakMinScoreInput - 1)
    clueThreshold     := math.max(1, clueThresholdInput - 1)
    exhaustionMaxScore := 2
    compressionWindow := postSqueezeBars + 2
else if signalProfile == "Selective"
    confirmedMinScore := math.min(4, confirmedMinScoreInput + 1)
    breakMinScore     := math.min(4, breakMinScoreInput + 1)
    clueThreshold     := math.min(4, clueThresholdInput + 1)
    exhaustionMaxScore := 1
    compressionWindow := math.max(1, postSqueezeBars - 1)

// ── TEXT SIZE ─────────────────────────────────────────────────
dashTextSize = size.small
if dashTextSizeInput == "Tiny"
    dashTextSize := size.tiny
else if dashTextSizeInput == "Normal"
    dashTextSize := size.normal

legendTextSize = size.small
if legendTextSizeInput == "Tiny"
    legendTextSize := size.tiny
else if legendTextSizeInput == "Normal"
    legendTextSize := size.normal

// ── POSITIONS ─────────────────────────────────────────────────
dashPos = position.bottom_right
if dashPosInput == "Top Right"
    dashPos := position.top_right
else if dashPosInput == "Top Left"
    dashPos := position.top_left
else if dashPosInput == "Bottom Left"
    dashPos := position.bottom_left

legendPos = position.top_right
if legendPosInput == "Top Left"
    legendPos := position.top_left
else if legendPosInput == "Bottom Right"
    legendPos := position.bottom_right
else if legendPosInput == "Bottom Left"
    legendPos := position.bottom_left

// ── FUNCTIONS ─────────────────────────────────────────────────
clamp(_x, _min, _max) =>
    math.max(_min, math.min(_max, _x))

// ── TIMEFRAME LOGIC ───────────────────────────────────────────
isHTF =
     timeframe.isdaily or
     timeframe.isweekly or
     timeframe.ismonthly or
     (timeframe.isintraday and timeframe.multiplier >= 240)

signalsAllowed = not disableSignalsOnHTF or not isHTF

// ── CORE CALCULATION ──────────────────────────────────────────
atr = ta.atr(atrLen)
ema = ta.ema(close, emaLen)
vwapValue = ta.vwap(hlc3)
[diPlus, diMinus, adx] = ta.dmi(diLen, adxSmoothing)

upperBasic = src + factor * atr
lowerBasic = src - factor * atr

var float upperBand = na
var float lowerBand = na

upperBand := na(upperBand[1]) ? upperBasic : (upperBasic < upperBand[1] or close[1] > upperBand[1] ? upperBasic : upperBand[1])
lowerBand := na(lowerBand[1]) ? lowerBasic : (lowerBasic > lowerBand[1] or close[1] < lowerBand[1] ? lowerBasic : lowerBand[1])

var int trend = 1
trend := na(trend[1]) ? 1 : trend[1]

if trend == -1 and close > upperBand[1]
    trend := 1
else if trend == 1 and close < lowerBand[1]
    trend := -1

superTrend = trend == 1 ? lowerBand : upperBand

// ── COMPRESSION ───────────────────────────────────────────────
channelWidth = upperBand - lowerBand
widthMin     = ta.lowest(channelWidth, sqzLookback)
widthMax     = ta.highest(channelWidth, sqzLookback)
widthNorm    = widthMax != widthMin ? (channelWidth - widthMin) / (widthMax - widthMin) : 0.0
isSqueeze    = enableSqueezeDetection and widthNorm <= sqzThreshold

prevIsSqueeze  = bar_index > 0 ? isSqueeze[1] : false
squeezeRelease = not isSqueeze and prevIsSqueeze

barsSinceSqueeze = ta.barssince(isSqueeze)
barsSinceRelease = ta.barssince(squeezeRelease)

recentCompression =
     (barsSinceSqueeze >= 0 and barsSinceSqueeze <= compressionWindow) or
     (barsSinceRelease >= 0 and barsSinceRelease <= compressionWindow)

// ── MAGNITUDE ─────────────────────────────────────────────────
distRaw  = atr != 0 ? math.abs(close - superTrend) / atr : 0.0
distNorm = clamp(math.pow(clamp(distRaw, 0.0, 1.5) / 1.5, fillAggressive), 0.0, 1.0)
prevDistNorm = bar_index > 0 ? distNorm[1] : distNorm

// ── CONTEXT ───────────────────────────────────────────────────
bullEmaOk = not useEmaFilter or close > ema
bearEmaOk = not useEmaFilter or close < ema

bullStrength = not useAdxContext or (adx >= adxThreshold and diPlus > diMinus and (not requireAdxRising or adx > adx[1]))
bearStrength = not useAdxContext or (adx >= adxThreshold and diMinus > diPlus and (not requireAdxRising or adx > adx[1]))

bullAcceptance = not useVwapContext or (close > vwapValue and close > superTrend)
bearAcceptance = not useVwapContext or (close < vwapValue and close < superTrend)

bullExpansion = not useMagnitudeRise or distNorm > prevDistNorm
bearExpansion = not useMagnitudeRise or distNorm > prevDistNorm

bullCompressionBreak = squeezeRelease and trend == 1
bearCompressionBreak = squeezeRelease and trend == -1

// ── STATE CLASSIFICATION ──────────────────────────────────────
rawBullFlip = trend == 1 and trend[1] == -1
rawBearFlip = trend == -1 and trend[1] == 1

bullQualityScore = 0
bullQualityScore += bullStrength ? 1 : 0
bullQualityScore += bullAcceptance ? 1 : 0
bullQualityScore += bullExpansion ? 1 : 0
bullQualityScore += bullCompressionBreak ? 1 : 0

bearQualityScore = 0
bearQualityScore += bearStrength ? 1 : 0
bearQualityScore += bearAcceptance ? 1 : 0
bearQualityScore += bearExpansion ? 1 : 0
bearQualityScore += bearCompressionBreak ? 1 : 0

bullFlipState =
     bullCompressionBreak and bullQualityScore >= breakMinScore ? "Compressed Break" :
     rawBullFlip and bullQualityScore >= confirmedMinScore ? "Confirmed" :
     rawBullFlip ? "Transition" :
     trend == 1 and bullQualityScore <= exhaustionMaxScore ? "Exhausted" :
     "None"

bearFlipState =
     bearCompressionBreak and bearQualityScore >= breakMinScore ? "Compressed Break" :
     rawBearFlip and bearQualityScore >= confirmedMinScore ? "Confirmed" :
     rawBearFlip ? "Transition" :
     trend == -1 and bearQualityScore <= exhaustionMaxScore ? "Exhausted" :
     "None"

activeState =
     trend == 1 ? bullFlipState : bearFlipState

stateColor =
     activeState == "Compressed Break" ? squeezeColor :
     activeState == "Confirmed" ? (trend == 1 ? bullColor : bearColor) :
     activeState == "Transition" ? neutralColor :
     activeState == "Exhausted" ? weakColor :
     (trend == 1 ? bullColor : bearColor)

trendDirection = trend == 1 ? "Uptrend" : "Downtrend"
regime =
     isSqueeze ? "Compressed" :
     adx >= adxThreshold ? "Trend" :
     "Neutral"

// ── DIRECTIONAL CLUES DURING EXHAUSTION ───────────────────────
bullClueScore = 0
bullClueScore += diPlus > diMinus ? 1 : 0
bullClueScore += close > vwapValue ? 1 : 0
bullClueScore += close > close[1] ? 1 : 0
bullClueScore += distNorm > prevDistNorm ? 1 : 0

bearClueScore = 0
bearClueScore += diMinus > diPlus ? 1 : 0
bearClueScore += close < vwapValue ? 1 : 0
bearClueScore += close < close[1] ? 1 : 0
bearClueScore += distNorm > prevDistNorm ? 1 : 0

bullExhaustedSetupCounter =
     useCounterTrendExhaustion and
     trend == -1 and
     activeState == "Exhausted" and
     bullClueScore >= clueThreshold

bearExhaustedSetupCounter =
     useCounterTrendExhaustion and
     trend == 1 and
     activeState == "Exhausted" and
     bearClueScore >= clueThreshold

bullExhaustedSetupContinuation =
     useContinuationExhaustion and
     trend == 1 and
     activeState == "Exhausted" and
     bullClueScore >= clueThreshold

bearExhaustedSetupContinuation =
     useContinuationExhaustion and
     trend == -1 and
     activeState == "Exhausted" and
     bearClueScore >= clueThreshold

bullSetup = bullExhaustedSetupCounter or bullExhaustedSetupContinuation
bearSetup = bearExhaustedSetupCounter or bearExhaustedSetupContinuation

prevBullSetup = bar_index > 0 ? bullSetup[1] : false
prevBearSetup = bar_index > 0 ? bearSetup[1] : false

// ── SIGNAL ENGINE ─────────────────────────────────────────────
var bool inLongSequence  = false
var bool inShortSequence = false

buySignal =
     signalsAllowed and
     bullSetup and
     not prevBullSetup and
     not inLongSequence

sellSignal =
     signalsAllowed and
     bearSetup and
     not prevBearSetup and
     not inShortSequence

if buySignal
    inLongSequence := true
    inShortSequence := false

if sellSignal
    inShortSequence := true
    inLongSequence := false

minorBullContinuation =
     signalsAllowed and
     showMinorMarkers and
     inLongSequence and
     bullSetup and
     not buySignal

minorBearContinuation =
     signalsAllowed and
     showMinorMarkers and
     inShortSequence and
     bearSetup and
     not sellSignal

sequenceState =
     inLongSequence ? "Long Active" :
     inShortSequence ? "Short Active" :
     bullSetup ? "Bull Setup" :
     bearSetup ? "Bear Setup" :
     "Flat"

signalsState = signalsAllowed ? "Active" : "Off (4H+)"

// ── GRADIENT COLORS ───────────────────────────────────────────
bullNear     = color.new(bullColor, maxOpacityNear)
bullFar      = color.new(bullColor, minOpacityFar)
bearNear     = color.new(bearColor, maxOpacityNear)
bearFar      = color.new(bearColor, minOpacityFar)
sqzFillNear  = color.new(squeezeColor, maxOpacityNear)
sqzFillFar   = color.new(squeezeColor, minOpacityFar)
weakFillNear = color.new(weakColor, maxOpacityNear)
weakFillFar  = color.new(weakColor, minOpacityFar)

bullFillTop    = color.from_gradient(distNorm, 0.0, 1.0, bullNear, bullFar)
bullFillBottom = color.new(color.black, 100)

bearFillTop    = color.new(color.black, 100)
bearFillBottom = color.from_gradient(distNorm, 0.0, 1.0, bearNear, bearFar)

sqzFillTop     = color.from_gradient(distNorm, 0.0, 1.0, sqzFillNear, sqzFillFar)
sqzFillBottom  = color.new(color.black, 100)

weakFillTop    = trend == 1 ? color.from_gradient(distNorm, 0.0, 1.0, weakFillNear, weakFillFar) : color.new(color.black, 100)
weakFillBottom = trend == -1 ? color.from_gradient(distNorm, 0.0, 1.0, weakFillNear, weakFillFar) : color.new(color.black, 100)

activeFillTop =
     not showFill ? color.new(color.black, 100) :
     activeState == "Compressed Break" and enableSqueezeColor ? sqzFillTop :
     activeState == "Exhausted" ? weakFillTop :
     trend == 1 ? bullFillTop : bearFillTop

activeFillBottom =
     not showFill ? color.new(color.black, 100) :
     activeState == "Compressed Break" and enableSqueezeColor ? sqzFillBottom :
     activeState == "Exhausted" ? weakFillBottom :
     trend == 1 ? bullFillBottom : bearFillBottom

// ── PLOTS ─────────────────────────────────────────────────────
stPlot  = plot(superTrend, "SuperTrend", color=stateColor, linewidth=lineWidth, style=plot.style_linebr)
plot(showEma ? ema : na, "EMA Filter", color=color.new(neutralColor, 20), linewidth=1)
pxPlot  = plot(hl2, "Price Proxy", color=color.new(color.black, 100), display=display.none)

fill(pxPlot, stPlot, hl2, superTrend, activeFillTop, activeFillBottom)

// ── BAR COLORS ────────────────────────────────────────────────
barStateColor =
     activeState == "Compressed Break" and enableSqueezeColor ? color.new(squeezeColor, 0) :
     activeState == "Transition" ? color.new(neutralColor, 0) :
     activeState == "Exhausted" ? color.new(weakColor, 0) :
     trend == 1 ? color.new(bullColor, 0) :
     color.new(bearColor, 0)

barcolor(showBarColors ? barStateColor : na)

// ── SIGNALS ───────────────────────────────────────────────────
plotshape(showSignals and buySignal, title="BUY", text="BUY", style=shape.labelup, location=location.belowbar, color=bullColor, textcolor=color.white, size=size.small)
plotshape(showSignals and sellSignal, title="SELL", text="SELL", style=shape.labeldown, location=location.abovebar, color=bearColor, textcolor=color.black, size=size.small)

plotshape(minorBullContinuation, title="Bull Continuation", style=shape.circle, location=location.belowbar, color=bullColor, size=size.tiny)
plotshape(minorBearContinuation, title="Bear Continuation", style=shape.circle, location=location.abovebar, color=bearColor, size=size.tiny)

// ── LAST VALUE LABEL ──────────────────────────────────────────
if barstate.islast and showLabels
    label.delete(label.new(
         bar_index, superTrend,
         "◀ ST: " + str.tostring(superTrend, format.mintick),
         color=color.new(color.black, 100),
         textcolor=stateColor,
         force_overlay=true,
         style=label.style_label_left
     )[1])

// ── MAIN DASHBOARD ────────────────────────────────────────────
var table dash = table.new(dashPos, 2, 9, border_width=1)

if barstate.isfirst
    dash := table.new(dashPos, 2, 9, border_width=1)

if barstate.islast and showDashboard
    table.cell(dash, 0, 0, "State", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 0, activeState, text_color=stateColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 1, "Profile", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 1, signalProfile, text_color=chart.fg_color, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 2, "Signals", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 2, signalsState, text_color=signalsAllowed ? chart.fg_color : weakColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 3, "Regime", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 3, regime, text_color=isSqueeze ? squeezeColor : adx >= adxThreshold ? stateColor : neutralColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 4, "Direction", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 4, trendDirection, text_color=stateColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 5, "Sequence", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 5, sequenceState, text_color=chart.fg_color, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 6, "Bull Clues", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 6, str.tostring(bullClueScore), text_color=bullColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 7, "Bear Clues", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 7, str.tostring(bearClueScore), text_color=bearColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 8, "Compression", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 8, isSqueeze ? "ON" : recentCompression ? "Recent" : "OFF", text_color=isSqueeze ? squeezeColor : recentCompression ? weakColor : chart.fg_color, text_halign=text.align_center, text_size=dashTextSize)

if barstate.islast and not showDashboard
    table.clear(dash, 0, 0, 1, 8)

// ── COLOR LEGEND ──────────────────────────────────────────────
var table legend = table.new(legendPos, 2, 5, border_width=1)

if barstate.isfirst
    legend := table.new(legendPos, 2, 5, border_width=1)

if barstate.islast and showLegend
    table.cell(legend, 0, 0, "Blue", text_color=chart.fg_color, text_halign=text.align_left, text_size=legendTextSize)
    table.cell(legend, 1, 0, "Confirmed Bull", text_color=bullColor, text_halign=text.align_center, text_size=legendTextSize)

    table.cell(legend, 0, 1, "Yellow", text_color=chart.fg_color, text_halign=text.align_left, text_size=legendTextSize)
    table.cell(legend, 1, 1, "Confirmed Bear", text_color=bearColor, text_halign=text.align_center, text_size=legendTextSize)

    table.cell(legend, 0, 2, "Purple", text_color=chart.fg_color, text_halign=text.align_left, text_size=legendTextSize)
    table.cell(legend, 1, 2, "Compressed Break", text_color=squeezeColor, text_halign=text.align_center, text_size=legendTextSize)

    table.cell(legend, 0, 3, "Gray", text_color=chart.fg_color, text_halign=text.align_left, text_size=legendTextSize)
    table.cell(legend, 1, 3, "Transition", text_color=neutralColor, text_halign=text.align_center, text_size=legendTextSize)

    table.cell(legend, 0, 4, "Red", text_color=chart.fg_color, text_halign=text.align_left, text_size=legendTextSize)
    table.cell(legend, 1, 4, "Exhausted", text_color=weakColor, text_halign=text.align_center, text_size=legendTextSize)

if barstate.islast and not showLegend
    table.clear(legend, 0, 0, 1, 4)

// ── ALERTS ────────────────────────────────────────────────────
alertcondition(buySignal, "BUY Signal", "SuperTrend Exhaustion Clues bullish signal")
alertcondition(sellSignal, "SELL Signal", "SuperTrend Exhaustion Clues bearish signal")
alertcondition(activeState == "Compressed Break", "Compressed Break", "SuperTrend classified as compressed break")
alertcondition(activeState == "Exhausted", "Exhausted State", "SuperTrend classified as exhausted")
alertcondition(bullSetup, "Bull Exhaustion Setup", "Bullish directional clues detected during exhaustion")
alertcondition(bearSetup, "Bear Exhaustion Setup", "Bearish directional clues detected during exhaustion")
````
