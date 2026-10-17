# Torsion Range [JOAT]

- url: https://www.tradingview.com/script/kMmK5LD1-Torsion-Range-JOAT/
- type: indicator
- pine_id: PUB;9752eb587d574027b5a6bb6eb13fcb6c
- version: 1.0

## Description

[b]Torsion Range [JOAT][/b]

[b]Introduction[/b]

Torsion Range is an open-source compression, expansion, and wave-energy panel designed to track whether the market is coiling, releasing, trending, or exhausting. The script combines wave direction, weighted energy accumulation, compression scoring, and exhaustion logic into one regime-aware panel.

The problem Torsion Range solves is fragmentation between wave tools and volatility tools. Traditional wave studies often ignore whether the market is compressing or expanding, while compression indicators often ignore directional wave state. Torsion Range merges both worlds so the user can monitor directional energy and structural volatility state together.

[image]https://www.tradingview.com/x/TylNp4VE/[/image]

[b]Core Concepts[/b]

[b]1. Wave Direction Engine[/b]

The script supports multiple methods for determining directional wave state, including impulse, pressure, and hybrid behavior. This allows the model to adapt to different styles of price movement.

[b]2. Weighted Energy Accumulation[/b]

Wave state is not just directional. It is weighted by body, range, ATR context, and optional relative volume to produce a more informative torsion core.

[b]3. Compression Index[/b]

A 0-100 compression framework is built from fast and slow comparisons of range, body, and energy behavior. This allows the indicator to identify tight conditions before release.

[b]4. Release and Exhaustion Logic[/b]

Confirmed-bar release events occur when compression gives way to directional expansion. Exhaustion logic looks for overstretched waves with weakening internal behavior.

[b]5. Dashboard and Regime Visualization[/b]

The panel includes adaptive colors, background overlays, event flashes, and a top-right dashboard that summarizes wave state, bias, compression, and most recent event.

[b]Features[/b]

[list]
[*][b]Multi-method wave direction:[/b] Impulse, pressure, or hybrid state engine
[*][b]Weighted energy accumulation:[/b] Uses price and optional relative volume
[*][b]Compression scoring:[/b] Tracks coiling conditions on a normalized scale
[*][b]Confirmed release logic:[/b] Detects transition from compression to directional expansion
[*][b]Exhaustion detection:[/b] Flags overextended wave conditions
[*][b]Adaptive gradient styling:[/b] Institutional panel presentation for dark charts
[*][b]Regime overlays and event flashes:[/b] Highlights important state transitions cleanly
[*][b]Top-right dashboard:[/b] Summarizes live wave and compression state
[*][b]Confirmed event mode:[/b] Optional bar-close only event gating
[*][b]Alertconditions:[/b] Wave flips, release events, and exhaustion states
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the Wave State[/b]
Determine whether directional energy currently favors bullish, bearish, or neutral behavior.

[b]Step 2: Check Compression[/b]
High compression means stored energy but not yet confirmed release. Low compression with directional energy implies active movement rather than coiling.

[b]Step 3: Watch Release Events[/b]
Release events matter most when they occur after genuine compression and align with the active wave bias.

[b]Step 4: Respect Exhaustion[/b]
Exhaustion conditions can warn that a strong wave is becoming less efficient, even if trend has not yet fully reversed.

[b]Indicator Limitations[/b]

[list]
[*]Compression and exhaustion are relative, not absolute, conditions
[*]Wave direction depends on the selected method and will respond differently across market types
[*]This panel does not identify exact reversal bars and should not be treated as one
[*]Release events are strongest when combined with separate structural context
[/list]

[b]Originality Statement[/b]

Torsion Range is original in its fusion of wave-state persistence, weighted energy accumulation, compression analysis, and exhaustion logic within one panel. It is not a basic Weis-style clone and not a plain volatility gauge. Its value comes from combining directional energy and volatility state into a single workflow.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Compression, release, and exhaustion states are analytical conditions derived from historical chart behavior and do not guarantee future outcomes.

- Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Torsion Range [JOAT]", shorttitle="TRG [JOAT]", overlay=false, precision=2, max_labels_count=500)
// -----------------------------------------------------------------------------
// Group: Core Architecture
// -----------------------------------------------------------------------------
groupCore = "Core Architecture"
waveMethod = input.string("Hybrid", "Wave Direction Method", options=["Impulse", "Pressure", "Hybrid"], group=groupCore)
signalSource = input.source(close, "Signal Source", group=groupCore)
confirmedEventsOnly = input.bool(true, "Confirmed Bar Event Mode", group=groupCore)
useVolumeWeight = input.bool(true, "Use Relative Volume In Energy", group=groupCore)

// -----------------------------------------------------------------------------
// Group: Wave Construction
// -----------------------------------------------------------------------------
groupWave = "Wave Construction"
trendLookback = input.int(20, "Directional Lookback", minval=2, group=groupWave)
impulseThreshold = input.float(3.0, "Impulse Threshold", minval=0.0, step=0.25, group=groupWave)
pressureLength = input.int(21, "Pressure EMA Length", minval=1, group=groupWave)
pressureThreshold = input.float(0.045, "Pressure Threshold", minval=0.0, step=0.001, group=groupWave)
bodyWeight = input.float(0.65, "Body Weight", minval=0.0, maxval=2.0, step=0.05, group=groupWave)
rangeWeight = input.float(0.35, "Range Weight", minval=0.0, maxval=2.0, step=0.05, group=groupWave)
volumeLength = input.int(34, "Relative Volume Length", minval=2, group=groupWave)
atrLength = input.int(21, "ATR Length", minval=1, group=groupWave)
energySmoothLength = input.int(5, "Energy Smooth Length", minval=1, group=groupWave)
waveNormLookback = input.int(220, "Wave Normalization Lookback", minval=20, group=groupWave)

// -----------------------------------------------------------------------------
// Group: Compression / Expansion
// -----------------------------------------------------------------------------
groupCompression = "Compression and Expansion"
compressionFast = input.int(14, "Compression Fast Length", minval=1, group=groupCompression)
compressionSlow = input.int(55, "Compression Slow Length", minval=2, group=groupCompression)
compressionThreshold = input.float(61.0, "Compression Threshold (0-100)", minval=0.0, maxval=100.0, step=0.5, group=groupCompression)
minCompressionBars = input.int(6, "Minimum Bars To Qualify Compression", minval=1, group=groupCompression)
releaseImpulseLength = input.int(13, "Release Impulse EMA Length", minval=1, group=groupCompression)
releaseImpulseThreshold = input.float(0.34, "Release Impulse Threshold", minval=0.0, step=0.01, group=groupCompression)
expansionBandBoost = input.float(0.45, "Expansion Band Boost", minval=0.0, step=0.01, group=groupCompression)

// -----------------------------------------------------------------------------
// Group: Regime and Exhaustion
// -----------------------------------------------------------------------------
groupRegime = "Regime and Exhaustion"
signalLength = input.int(13, "Signal Length", minval=1, group=groupRegime)
coreSmoothLength = input.int(5, "Core Smooth Length", minval=1, group=groupRegime)
baseBandLevel = input.float(44.0, "Base Regime Band", minval=5.0, maxval=95.0, step=0.5, group=groupRegime)
adaptiveBandLength = input.int(55, "Adaptive Band Length", minval=5, group=groupRegime)
neutralBandBase = input.float(12.0, "Neutral Band Base", minval=1.0, step=0.5, group=groupRegime)
neutralBandCompressionBoost = input.float(10.0, "Neutral Band Boost From Compression", minval=0.0, step=0.5, group=groupRegime)
minWaveAgeForExhaustion = input.int(10, "Min Wave Age For Exhaustion", minval=1, group=groupRegime)
exhaustionStretchLength = input.int(34, "Exhaustion Stretch Length", minval=2, group=groupRegime)
exhaustionStretchThreshold = input.float(6.0, "Exhaustion Stretch Threshold", minval=0.0, step=0.25, group=groupRegime)
exhaustionBandOffset = input.float(9.0, "Exhaustion Band Offset", minval=0.0, step=0.5, group=groupRegime)

// -----------------------------------------------------------------------------
// Group: Visual System
// -----------------------------------------------------------------------------
groupVisual = "Visual System"
showWaveColumns = input.bool(true, "Show Wave Columns", group=groupVisual)
showGlowLayer = input.bool(true, "Show Glow Layer", group=groupVisual)
showRegimeBackground = input.bool(true, "Show Regime Background", group=groupVisual)
showCompressionOverlay = input.bool(true, "Show Compression Overlay", group=groupVisual)
showEventLabels = input.bool(true, "Show Event Labels", group=groupVisual)
maxEventLabels = input.int(80, "Max Event Labels", minval=10, maxval=300, group=groupVisual)

// -----------------------------------------------------------------------------
// Group: Dashboard
// -----------------------------------------------------------------------------
groupDash = "Dashboard"
showDashboard = input.bool(true, "Show Dashboard", group=groupDash)
dashboardTextSize = input.string("Small", "Dashboard Text Size", options=["Tiny", "Small", "Normal"], group=groupDash)

// -----------------------------------------------------------------------------
// Group: Color System (dark mode)
// -----------------------------------------------------------------------------
groupColor = "Color System"
bullCoreColor = input.color(color.rgb(75, 197, 142), "Bull Core Color", group=groupColor)
bearCoreColor = input.color(color.rgb(235, 106, 120), "Bear Core Color", group=groupColor)
neutralCoreColor = input.color(color.rgb(130, 140, 160), "Neutral Core Color", group=groupColor)
signalColor = input.color(color.rgb(230, 192, 122), "Signal Color", group=groupColor)
compressionColor = input.color(color.rgb(84, 143, 229), "Compression Color", group=groupColor)
releaseColor = input.color(color.rgb(121, 173, 255), "Release Color", group=groupColor)
exhaustionColor = input.color(color.rgb(244, 177, 109), "Exhaustion Color", group=groupColor)
bullBgColor = input.color(color.rgb(24, 66, 49), "Bull Background", group=groupColor)
bearBgColor = input.color(color.rgb(74, 31, 36), "Bear Background", group=groupColor)
compressionBgColor = input.color(color.rgb(19, 43, 74), "Compression Background", group=groupColor)

// -----------------------------------------------------------------------------
// Utilities
// -----------------------------------------------------------------------------
f_clamp(float v, float lo, float hi) =>
    math.max(lo, math.min(hi, v))

f_sign(float v) =>
    v > 0 ? 1 : v < 0 ? -1 : 0

f_safe_div(float num, float den, float fallback) =>
    den == 0.0 ? fallback : num / den

f_text_size(string mode) =>
    mode == "Tiny" ? size.tiny : mode == "Normal" ? size.normal : size.small

f_push_event_label(array<label> store, string txt, float y, color bg, color fg, int maxKeep) =>
    lbl = label.new(bar_index, y, txt, style=label.style_label_left, textcolor=fg, color=bg, size=size.tiny)
    array.push(store, lbl)
    if array.size(store) > maxKeep
        oldest = array.shift(store)
        label.delete(oldest)

// -----------------------------------------------------------------------------
// Core Source Series
// -----------------------------------------------------------------------------
body = math.abs(close - open)
fullRange = high - low
safeRange = math.max(fullRange, syminfo.mintick)
atrValue = ta.atr(atrLength)
safeAtr = math.max(atrValue, syminfo.mintick)
relVolumeBase = ta.sma(volume, volumeLength)
relVolume = f_safe_div(volume, relVolumeBase, 1.0)
volWeight = useVolumeWeight ? relVolume : 1.0

// Weighted bar energy drives wave accumulation.
energyRaw = body * bodyWeight + fullRange * rangeWeight
energyWeighted = energyRaw * volWeight
energyNormalized = f_safe_div(energyWeighted, safeAtr, 0.0)
energySmoothed = ta.ema(energyNormalized, energySmoothLength)

// -----------------------------------------------------------------------------
// Direction Engine
// -----------------------------------------------------------------------------
impulseUnit = close > close[1] ? 1.0 : close < close[1] ? -1.0 : 0.0
impulseScore = math.sum(impulseUnit, trendLookback)
impulseDir = impulseScore > impulseThreshold ? 1 : impulseScore < -impulseThreshold ? -1 : 0

pressureRaw = f_safe_div(signalSource - open, safeRange, 0.0)
pressureDrift = ta.ema(pressureRaw, pressureLength)
pressureDir = pressureDrift > pressureThreshold ? 1 : pressureDrift < -pressureThreshold ? -1 : 0

hybridScore = impulseScore * 0.55 + pressureDrift * 100.0 * 0.45
hybridDir = hybridScore > impulseThreshold ? 1 : hybridScore < -impulseThreshold ? -1 : 0

dirInput = waveMethod == "Impulse" ? impulseDir : waveMethod == "Pressure" ? pressureDir : hybridDir

// Persistent wave direction with carry-forward for neutral readings.
var int waveDirection = 0
if barstate.isfirst
    waveDirection := dirInput == 0 ? 1 : dirInput
else
    prevDirection = nz(waveDirection[1], 1)
    waveDirection := dirInput == 0 ? prevDirection : dirInput

waveDirectionPrev = nz(waveDirection[1], waveDirection)
waveFlipRaw = waveDirection != waveDirectionPrev
isBullWave = waveDirection == 1
isBearWave = waveDirection == -1

// -----------------------------------------------------------------------------
// Wave Accumulation Engine
// -----------------------------------------------------------------------------
signedEnergy = energySmoothed * waveDirection

var float waveAccumulator = 0.0
if barstate.isfirst
    waveAccumulator := signedEnergy
else
    waveAccumulator := waveFlipRaw ? signedEnergy : nz(waveAccumulator[1]) + signedEnergy

var int waveAge = 0
if barstate.isfirst
    waveAge := 1
else
    waveAge := waveFlipRaw ? 1 : nz(waveAge[1]) + 1

waveMagnitudePeak = ta.highest(math.abs(waveAccumulator), waveNormLookback)
safePeak = math.max(waveMagnitudePeak, 1e-6)
torsionRaw = 100.0 * f_safe_div(waveAccumulator, safePeak, 0.0)
torsionRawClamped = f_clamp(torsionRaw, -100.0, 100.0)
torsionCore = ta.ema(torsionRawClamped, coreSmoothLength)
torsionSignal = ta.ema(torsionCore, signalLength)
torsionSlope = torsionCore - torsionCore[1]
torsionAbs = math.abs(torsionCore)

// -----------------------------------------------------------------------------
// Compression and Expansion Engine
// -----------------------------------------------------------------------------
rangeFast = ta.ema(fullRange, compressionFast)
rangeSlow = ta.ema(fullRange, compressionSlow)
bodyFast = ta.ema(body, compressionFast)
bodySlow = ta.ema(body, compressionSlow)
energyFast = ta.ema(energyNormalized, compressionFast)
energySlow = ta.ema(energyNormalized, compressionSlow)

rangeRatio = f_safe_div(rangeFast, math.max(rangeSlow, syminfo.mintick), 1.0)
bodyRatio = f_safe_div(bodyFast, math.max(bodySlow, syminfo.mintick), 1.0)
energyRatio = f_safe_div(energyFast, math.max(energySlow, 1e-6), 1.0)

ratioComposite = rangeRatio * 0.45 + bodyRatio * 0.35 + energyRatio * 0.20
compressionIndex = f_clamp((2.0 - ratioComposite) * 50.0, 0.0, 100.0)
isCompression = compressionIndex >= compressionThreshold

var int compressionBarCount = 0
if isCompression
    compressionBarCount := nz(compressionBarCount[1]) + 1
else
    compressionBarCount := 0

releaseImpulse = energyFast - ta.ema(energyFast, releaseImpulseLength)
releaseBias = torsionCore > torsionSignal ? 1 : torsionCore < torsionSignal ? -1 : waveDirection

leftCompressionPocket = not isCompression and isCompression[1] and nz(compressionBarCount[1], 0) >= minCompressionBars
releaseQualified = leftCompressionPocket and math.abs(releaseImpulse) >= releaseImpulseThreshold

// -----------------------------------------------------------------------------
// Adaptive Regime Bands
// -----------------------------------------------------------------------------
adaptiveBandBoost = ta.ema(torsionAbs, adaptiveBandLength) * expansionBandBoost * 0.1
upperAdaptiveBand = f_clamp(baseBandLevel + adaptiveBandBoost, 8.0, 95.0)
lowerAdaptiveBand = -upperAdaptiveBand

neutralBandWidth = neutralBandBase + (compressionIndex / 100.0) * neutralBandCompressionBoost
neutralTop = neutralBandWidth
neutralBottom = -neutralBandWidth

// -----------------------------------------------------------------------------
// Exhaustion Engine
// -----------------------------------------------------------------------------
stretchSeries = torsionAbs - ta.ema(torsionAbs, exhaustionStretchLength)
longExhaustBand = upperAdaptiveBand + exhaustionBandOffset
shortExhaustBand = lowerAdaptiveBand - exhaustionBandOffset

longExhaustSetup = waveDirection == 1 and waveAge >= minWaveAgeForExhaustion and torsionCore >= longExhaustBand and torsionSlope < 0 and stretchSeries >= exhaustionStretchThreshold
shortExhaustSetup = waveDirection == -1 and waveAge >= minWaveAgeForExhaustion and torsionCore <= shortExhaustBand and torsionSlope > 0 and stretchSeries >= exhaustionStretchThreshold

// -----------------------------------------------------------------------------
// Confirmed-Bar Event Logic (non-repainting signal framework)
// -----------------------------------------------------------------------------
eventGate = confirmedEventsOnly ? barstate.isconfirmed : true

waveFlipUp = eventGate and waveFlipRaw and waveDirection == 1
waveFlipDown = eventGate and waveFlipRaw and waveDirection == -1

compressionRelease = eventGate and releaseQualified
compressionReleaseUp = compressionRelease and releaseBias == 1
compressionReleaseDown = compressionRelease and releaseBias == -1

exhaustionUp = eventGate and longExhaustSetup
exhaustionDown = eventGate and shortExhaustSetup
exhaustionAny = exhaustionUp or exhaustionDown

// Track latest event text for dashboard context.
var string latestEvent = "Idle"
if waveFlipUp
    latestEvent := "Wave Flip Up"
else if waveFlipDown
    latestEvent := "Wave Flip Down"
else if compressionReleaseUp
    latestEvent := "Compression Release Up"
else if compressionReleaseDown
    latestEvent := "Compression Release Down"
else if exhaustionUp
    latestEvent := "Wave Exhaustion Up"
else if exhaustionDown
    latestEvent := "Wave Exhaustion Down"

// -----------------------------------------------------------------------------
// Visual Color Construction
// -----------------------------------------------------------------------------
coreLineColor = torsionCore >= 0 ? color.from_gradient(torsionCore, 0, 100, color.new(bullCoreColor, 35), bullCoreColor) : color.from_gradient(-torsionCore, 0, 100, color.new(bearCoreColor, 35), bearCoreColor)
columnColor = waveDirection == 1 ? color.from_gradient(torsionAbs, 0, 100, color.new(bullCoreColor, 72), color.new(bullCoreColor, 20)) : waveDirection == -1 ? color.from_gradient(torsionAbs, 0, 100, color.new(bearCoreColor, 72), color.new(bearCoreColor, 20)) : color.new(neutralCoreColor, 55)
compressionLineColor = color.from_gradient(compressionIndex, 0, 100, color.new(neutralCoreColor, 60), compressionColor)

bgRegime = waveDirection == 1 ? color.new(bullBgColor, 90) : waveDirection == -1 ? color.new(bearBgColor, 90) : color.new(neutralCoreColor, 94)
bgCompression = color.new(compressionBgColor, 87)
bgReleaseFlash = compressionReleaseUp ? color.new(releaseColor, 82) : compressionReleaseDown ? color.new(releaseColor, 86) : na
bgExhaustionFlash = exhaustionAny ? color.new(exhaustionColor, 84) : na

// -----------------------------------------------------------------------------
// Main Plots
// -----------------------------------------------------------------------------
pUpperBand = plot(upperAdaptiveBand, "Upper Adaptive Band", color=color.new(neutralCoreColor, 60), linewidth=1)
pLowerBand = plot(lowerAdaptiveBand, "Lower Adaptive Band", color=color.new(neutralCoreColor, 60), linewidth=1)
pNeutralTop = plot(neutralTop, "Neutral Top", color=color.new(neutralCoreColor, 78), linewidth=1)
pNeutralBottom = plot(neutralBottom, "Neutral Bottom", color=color.new(neutralCoreColor, 78), linewidth=1)

fill(pUpperBand, pLowerBand, color=color.new(neutralCoreColor, 94), title="Regime Field")
fill(pNeutralTop, pNeutralBottom, color=color.new(compressionColor, 90), title="Compression Neutral Pocket")

pZero = plot(0, "Zero", color=color.new(neutralCoreColor, 80), linewidth=1, style=plot.style_line)
pTorsionColumns = plot(showWaveColumns ? torsionRawClamped : na, "Wave Columns", color=columnColor, style=plot.style_columns, linewidth=2)
pCoreGlow = plot(showGlowLayer ? torsionCore : na, "Core Glow", color=color.new(coreLineColor, 78), linewidth=7)
pCore = plot(torsionCore, "Torsion Core", color=coreLineColor, linewidth=2)
pSignal = plot(torsionSignal, "Torsion Signal", color=signalColor, linewidth=2)
pCompression = plot(compressionIndex - 50.0, "Compression Index (Centered)", color=compressionLineColor, linewidth=2)

fill(pCore, pZero, color=torsionCore >= 0 ? color.new(bullCoreColor, 86) : color.new(bearCoreColor, 86), title="Core Fill")
fill(pCore, pSignal, color=color.new(signalColor, 90), title="Core-Signal Spread")
fill(pCompression, pZero, color=color.new(compressionColor, 88), title="Compression Fill")

// Background layers for contextual states.
bgcolor(showRegimeBackground ? bgRegime : na, title="Regime Background")
bgcolor(showCompressionOverlay and isCompression ? bgCompression : na, title="Compression Overlay")
bgcolor(bgReleaseFlash, title="Release Flash")
bgcolor(bgExhaustionFlash, title="Exhaustion Flash")

// -----------------------------------------------------------------------------
// Optional Event Labels (kept minimal and bounded)
// -----------------------------------------------------------------------------
var array<label> eventLabelStore = array.new_label()
labelTextColor = color.rgb(15, 20, 28)

if showEventLabels and waveFlipUp
    f_push_event_label(eventLabelStore, "Flip Up", torsionCore, color.new(bullCoreColor, 10), labelTextColor, maxEventLabels)
if showEventLabels and waveFlipDown
    f_push_event_label(eventLabelStore, "Flip Down", torsionCore, color.new(bearCoreColor, 10), labelTextColor, maxEventLabels)
if showEventLabels and compressionReleaseUp
    f_push_event_label(eventLabelStore, "Release Up", torsionCore, color.new(releaseColor, 8), labelTextColor, maxEventLabels)
if showEventLabels and compressionReleaseDown
    f_push_event_label(eventLabelStore, "Release Down", torsionCore, color.new(releaseColor, 8), labelTextColor, maxEventLabels)
if showEventLabels and exhaustionUp
    f_push_event_label(eventLabelStore, "Exhaustion Up", torsionCore, color.new(exhaustionColor, 8), labelTextColor, maxEventLabels)
if showEventLabels and exhaustionDown
    f_push_event_label(eventLabelStore, "Exhaustion Down", torsionCore, color.new(exhaustionColor, 8), labelTextColor, maxEventLabels)

// -----------------------------------------------------------------------------
// Dashboard
// -----------------------------------------------------------------------------
var table dash = table.new(position.top_right, 2, 10, border_width=1, frame_color=color.new(neutralCoreColor, 40), border_color=color.new(neutralCoreColor, 60), bgcolor=color.new(color.rgb(10, 14, 22), 15))
dashHeader = color.new(color.rgb(38, 28, 58), 10)
dashAccent = color.new(color.rgb(82, 58, 138), 18)
dashRowA = color.new(color.rgb(14, 18, 29), 10)
dashRowB = color.new(color.rgb(20, 25, 39), 14)

stateText = waveDirection == 1 ? "Bull" : waveDirection == -1 ? "Bear" : "Neutral"
stateColor = waveDirection == 1 ? bullCoreColor : waveDirection == -1 ? bearCoreColor : neutralCoreColor
compressionText = isCompression ? "Compressed" : "Released"
biasText = releaseBias == 1 ? "Upward" : releaseBias == -1 ? "Downward" : "Flat"
eventModeText = confirmedEventsOnly ? "Confirmed" : "Live"
textSize = f_text_size(dashboardTextSize)

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "TRG [JOAT]", text_color=color.white, text_size=textSize, bgcolor=dashHeader)
    table.cell(dash, 1, 0, "Status", text_color=color.white, text_size=textSize, bgcolor=dashHeader)

    table.cell(dash, 0, 1, "Wave State", text_color=color.white, text_size=textSize, bgcolor=dashAccent)
    table.cell(dash, 1, 1, stateText, text_color=stateColor, text_size=textSize, bgcolor=dashAccent)

    table.cell(dash, 0, 2, "Wave Age", text_color=color.white, text_size=textSize, bgcolor=dashRowA)
    table.cell(dash, 1, 2, str.tostring(waveAge), text_color=color.white, text_size=textSize, bgcolor=dashRowA)

    table.cell(dash, 0, 3, "Torsion", text_color=color.white, text_size=textSize, bgcolor=dashRowB)
    table.cell(dash, 1, 3, str.tostring(torsionCore, "#.##"), text_color=coreLineColor, text_size=textSize, bgcolor=dashRowB)

    table.cell(dash, 0, 4, "Signal", text_color=color.white, text_size=textSize, bgcolor=dashRowA)
    table.cell(dash, 1, 4, str.tostring(torsionSignal, "#.##"), text_color=signalColor, text_size=textSize, bgcolor=dashRowA)

    table.cell(dash, 0, 5, "Compression", text_color=color.white, text_size=textSize, bgcolor=dashRowB)
    table.cell(dash, 1, 5, str.tostring(compressionIndex, "#.##"), text_color=compressionLineColor, text_size=textSize, bgcolor=dashRowB)

    table.cell(dash, 0, 6, "Comp Bars", text_color=color.white, text_size=textSize, bgcolor=dashRowA)
    table.cell(dash, 1, 6, str.tostring(compressionBarCount), text_color=color.white, text_size=textSize, bgcolor=dashRowA)

    table.cell(dash, 0, 7, "Release Bias", text_color=color.white, text_size=textSize)
    table.cell(dash, 1, 7, biasText, text_color=releaseBias == 1 ? bullCoreColor : releaseBias == -1 ? bearCoreColor : neutralCoreColor, text_size=textSize)

    table.cell(dash, 0, 8, "Event Mode", text_color=color.white, text_size=textSize)
    table.cell(dash, 1, 8, eventModeText, text_color=color.white, text_size=textSize)

    table.cell(dash, 0, 9, "Last Event", text_color=color.white, text_size=textSize)
    table.cell(dash, 1, 9, latestEvent, text_color=color.white, text_size=textSize)

// -----------------------------------------------------------------------------
// Alert Conditions
// -----------------------------------------------------------------------------
alertcondition(waveFlipUp, title="TRG Wave Flip Up", message="Torsion Range [JOAT]: confirmed wave flip to bullish regime.")
alertcondition(waveFlipDown, title="TRG Wave Flip Down", message="Torsion Range [JOAT]: confirmed wave flip to bearish regime.")
alertcondition(compressionReleaseUp, title="TRG Compression Release Up", message="Torsion Range [JOAT]: confirmed compression release with upward bias.")
alertcondition(compressionReleaseDown, title="TRG Compression Release Down", message="Torsion Range [JOAT]: confirmed compression release with downward bias.")
alertcondition(exhaustionUp, title="TRG Exhaustion Up", message="Torsion Range [JOAT]: confirmed bullish-wave exhaustion conditions.")
alertcondition(exhaustionDown, title="TRG Exhaustion Down", message="Torsion Range [JOAT]: confirmed bearish-wave exhaustion conditions.")
alertcondition(exhaustionAny, title="TRG Exhaustion Any", message="Torsion Range [JOAT]: confirmed wave exhaustion state.")

// -----------------------------------------------------------------------------
// End of indicator.
// -----------------------------------------------------------------------------
````
