# Squeeze Momentum Indicator [AGPro Series]

- url: https://www.tradingview.com/script/5hV7cFAS-Squeeze-Momentum-Indicator-AGPro-Series/
- type: indicator
- pine_id: PUB;b3d0343c14094d83ba2ac28ddedc8438
- version: 5.0

## Description

Squeeze Momentum Indicator [AGPro Series]

🔷 OVERVIEW

Squeeze Momentum Indicator [AGPro Series] is a lower-pane volatility and momentum engine built for traders who want more structure than the classic squeeze workflow usually provides.

At its core, the script studies a very specific sequence in market behavior:

volatility compression,
compression release,
directional pressure after release,
and whether that pressure is strengthening, fading, or slipping back toward balance.

Most squeeze-style indicators stop at a simple yes/no squeeze condition and a basic momentum histogram around the zero line. This script is designed to go further without becoming noisy. It keeps the familiar Bollinger Band vs Keltner Channel compression logic that many traders already understand, but it rebuilds the momentum side around a different internal model so the post-squeeze move can be judged with more nuance.

The result is a more structured answer to an important practical question:

when volatility finally expands, is the move actually carrying useful directional pressure, or is it only a shallow release that may lose energy quickly?

🔷 WHAT THIS SCRIPT DOES

This indicator combines four layers into one compact oscillator workflow:

1. Volatility compression detection
   It identifies squeeze conditions using Bollinger Band and Keltner Channel relationship logic.

2. Compression depth tracking
   It does not only ask whether a squeeze exists. It also tracks how tightly the Bollinger envelope sits inside the Keltner envelope, which helps frame how compressed the market really is.

3. ATR-normalized momentum pressure
   Instead of using the classic legacy-style squeeze momentum formula, this script blends:
   - displacement from equilibrium
   - directional velocity of that equilibrium
   - path efficiency of recent price travel

   This creates a momentum engine that is designed to evaluate the quality of directional pressure after release, not just whether a histogram is above or below zero.

4. Adaptive expansion / fade context
   The script builds dynamic balance and burst zones around momentum, then classifies whether price is:
   - compressing
   - releasing with bullish pressure
   - releasing with bearish pressure
   - continuing directionally
   - fading after an elevated move
   - rotating back toward balance

This makes the tool especially useful for traders who want squeeze timing, but do not want to treat every release as equally meaningful.

🔷 WHAT MAKES THIS DIFFERENT FROM MOST SQUEEZE INDICATORS

The squeeze concept is widely known, but many public versions still revolve around the same structure:
a binary compression state and a very simple momentum histogram.

This script is intentionally different in several ways:

• It treats squeeze as a volatility gate, not as the full identity of the indicator.
• It uses an original blended momentum model rather than reusing the standard linear-regression style momentum formula associated with many older versions.
• It adds adaptive momentum zones so the oscillator can distinguish between ordinary movement and higher-energy expansion.
• It marks not only burst phases, but also momentum fade phases, which helps separate continuation pressure from cooling pressure.
• It includes restrained release labels, release boxes, and a compact information panel so the visual output stays premium and readable instead of overloaded.

In short, this script is not trying to be another cosmetic variation of an old squeeze formula.
Its objective is narrower and more analytical:
measure the quality of post-compression directional pressure in a clean lower-pane environment.

🔷 HOW THIS SCRIPT IS DIFFERENT FROM OTHER AGPRO TOOLS

This part matters because originality and role separation inside a script catalog are important.

Within the AGPro Series, this indicator is intentionally separate from nearby concepts:

• AG Pro Bollinger Bands Squeeze Map
  That script is an on-chart volatility regime map built to show how compression and release behave directly on price.
  This script is different.
  It is a dedicated lower-pane momentum-quality engine focused on what happens after compression begins to resolve.

• AG Pro ROC Momentum Shift Map
  That script studies momentum regime transitions through ROC behavior.
  It is a broader momentum-state classifier.
  This script is narrower by design and specifically anchored to squeeze-release behavior.

• AG Pro Structural Momentum Oscillator
  That script evaluates momentum through internal price structure and bar behavior.
  This script does not try to read momentum that way.
  Its purpose is to organize volatility compression and post-compression expansion into a squeeze-specific workflow.

That distinction is central to this release:
this is not a re-labeled overlap script.
It is a purpose-built squeeze momentum tool with its own logic, its own visual model, and its own analytical role.

🔷 HOW THE ENGINE WORKS

The script begins with a standard compression framework:

- Bollinger Bands define the volatility envelope.
- Keltner Channels define the containment envelope.
- When the Bollinger structure contracts inside the Keltner structure, squeeze conditions are present.

From there, the script moves into a separate momentum model.

Instead of relying on one traditional oscillator formula, the engine blends three components:

1. Displacement from equilibrium
   Measures how far price has moved from its equilibrium anchor relative to ATR.

2. Equilibrium velocity
   Measures whether that equilibrium is moving directionally and how quickly.

3. Path efficiency
   Measures how efficiently price has traveled over the selected lookback instead of simply how far it moved.

Those three components are blended into a normalized momentum-pressure read, then smoothed for cleaner interpretation.

The script then builds two adaptive internal thresholds:

- a balance band
- a burst band

These dynamic bands help classify whether momentum is:
- quiet / balanced
- directional but ordinary
- strong enough to qualify as a burst
- elevated but beginning to fade

This adaptive structure matters because a fixed threshold often reads very differently across symbols, volatility regimes, and timeframes.

🔷 VISUAL DESIGN

The visual design is built around premium clarity rather than signal overload.

The pane includes:

• A momentum histogram with four directional states
  - bullish expansion strengthening
  - bullish pressure fading
  - bearish expansion strengthening
  - bearish pressure fading

• Adaptive upper and lower momentum zones
  These show where momentum is operating in balance versus expansion territory.

• Squeeze markers on the zero line
  These quickly show whether volatility is still compressed or has just released.

• Optional release boxes
  These create rectangular burst zones that make active expansion phases easier to scan visually.

• Restrained release / fade labels
  Labels are intentionally filtered and spaced so the chart remains informative without looking crowded.

• AG Pro information panel
  The panel summarizes squeeze state, phase, bias, momentum, energy, and current signal context.

The goal is to keep the script visually rich, but still clean enough for repeated real-world use.

🔷 HOW TO READ IT

A practical way to interpret the script:

• Squeeze ON
  Volatility is compressed.
  This is preparation, not directional confirmation.

• Bull Burst / Bear Burst
  Compression has released and momentum has cleared the adaptive balance zone with directional pressure.
  This is the main transition event in the workflow.

• Bull Drive / Bear Drive
  The market is still carrying directional pressure after release.

• Bull Fade / Bear Fade
  Momentum remains elevated, but acceleration is cooling.
  This does not automatically mean reversal.
  It means the move is no longer improving in quality.

• Balance
  The market is not in an active burst condition and momentum is closer to neutral internal behavior.

This makes the script useful not only for timing expansion, but also for judging whether that expansion is still healthy or beginning to lose structure.

🔷 WHO THIS MAY BE USEFUL FOR

This script may be useful for traders who want to:

- track volatility compression and release in a dedicated oscillator pane
- filter squeeze releases by actual momentum quality
- distinguish stronger directional expansion from weaker post-release drift
- pair volatility timing with structure, trend, VWAP, or support/resistance analysis
- reduce overreaction to every simple zero-line shift
- organize post-squeeze behavior more cleanly in discretionary workflows

It is especially suitable for users who like the squeeze concept, but want more context than a traditional dot-plus-histogram implementation.

🔷 KEY INPUTS

Core settings include:
- BB Length
- BB StdDev
- KC Length
- KC ATR Multiplier
- True Range toggle for Keltner construction

Momentum settings include:
- Equilibrium Length
- Velocity Length
- Momentum Smoothing
- Adaptive Band Length
- Burst Band Multiplier

Visual and workflow settings include:
- Adaptive momentum zones
- Signal line
- Histogram width
- Release boxes
- Release box persistence
- Label spacing
- Label size
- Panel position
- Theme
- Panel font size

This gives users enough control to adapt the script to different symbols and timeframes without turning the interface into a settings overload.

🔷 LIMITATIONS AND TRANSPARENCY

This indicator is a chart-analysis tool.
It is not a guarantee of breakout continuation, not a prediction engine, and not a substitute for trade planning or risk management.

A few important points should be kept in mind:

- A squeeze can resolve in either direction.
- A valid release can still fail.
- Strong momentum can cool without immediately reversing.
- Some instruments will produce noisier momentum behavior than others.
- Settings may need adjustment depending on timeframe, volatility regime, and instrument structure.

The script is best treated as a decision-support layer for reading volatility expansion and momentum quality more clearly.
It is not presented as a standalone trading system.

🔷 IN ONE SENTENCE

Squeeze Momentum Indicator [AGPro Series] is designed to show not only when volatility is ready to move, but whether the actual post-squeeze move is carrying enough directional pressure, quality, and persistence to deserve attention.

## Source Code

````pine
// -------------------------------------------------
// Squeeze Momentum Indicator [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.2
//
// A premium squeeze momentum workflow built for traders who want to read
// compression, release quality, directional follow-through, and cooling phases
// in one refined lower-pane engine. The script combines BB/KC squeeze logic
// with ATR-normalized momentum pressure, adaptive zones, a confirmed-bar
// follow-through proof metric, and editorial visuals.
// -------------------------------------------------

//@version=6
indicator("Squeeze Momentum Indicator [AGPro Series]", shorttitle = "AG Pro SQZ", overlay = false, precision = 2, max_labels_count = 160, max_boxes_count = 80)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
panelBg       = color.rgb(15, 23, 42)
panelBorder   = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_position(string selected) =>
    switch selected
        "Top Left" => position.top_left
        "Bottom Left" => position.bottom_left
        "Bottom Right" => position.bottom_right
        => position.top_right

f_size(string selected) =>
    switch selected
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

// Luminance-145 contrast ink. Bright fills get dark ink, dark fills get the
// light header ink, so every on-chart badge and filled panel cell stays legible.
f_text_on(color fill) =>
    brightness = 0.299 * color.r(fill) + 0.587 * color.g(fill) + 0.114 * color.b(fill)
    brightness > 145 ? color.rgb(17, 24, 39) : headerText

f_quality_bucket(float score) =>
    score >= 85 ? "Exceptional" : score >= 70 ? "Strong" : score >= 55 ? "Moderate" : score >= 40 ? "Early" : "Weak"

f_compression_grade(float pct) =>
    pct >= 22 ? "Extreme" : pct >= 14 ? "Deep" : pct >= 7 ? "Active" : pct > 0 ? "Light" : "Off"

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupCore = "Core"
src = input.source(close, "Source", group = groupCore, tooltip = "Primary source used by both the squeeze engine and the momentum model.")
bbLength = input.int(20, "BB Length", minval = 5, group = groupCore, tooltip = "Length used for the Bollinger Band envelope. Higher values smooth compression detection.")
bbMult = input.float(2.0, "BB StdDev", minval = 0.5, step = 0.1, group = groupCore, tooltip = "Standard deviation multiplier used to build the Bollinger envelope.")
kcLength = input.int(20, "KC Length", minval = 5, group = groupCore, tooltip = "Length used for the Keltner Channel envelope.")
kcMult = input.float(1.5, "KC ATR Multiplier", minval = 0.5, step = 0.1, group = groupCore, tooltip = "ATR or range multiplier used to size the Keltner Channel.")
useTrueRange = input.bool(true, "Use True Range For KC", group = groupCore, tooltip = "Uses True Range instead of raw high-low range when building the Keltner Channel.")

groupMomentum = "Momentum Engine"
eqLength = input.int(20, "Equilibrium Length", minval = 5, group = groupMomentum, tooltip = "Length of the equilibrium EMA used as the anchor for displacement and velocity.")
velLength = input.int(5, "Velocity Length", minval = 1, group = groupMomentum, tooltip = "Smoothing applied to directional velocity before it is blended into the momentum engine.")
smoothLength = input.int(4, "Momentum Smoothing", minval = 1, group = groupMomentum, tooltip = "Final smoothing applied to the blended pressure output.")
energyLength = input.int(34, "Adaptive Band Length", minval = 10, group = groupMomentum, tooltip = "Lookback used to build adaptive balance and burst zones around momentum.")
burstMultiplier = input.float(1.20, "Burst Band Multiplier", minval = 0.2, step = 0.05, group = groupMomentum, tooltip = "Controls how demanding the upper and lower burst thresholds become.")
qualityLookback = input.int(50, "Quality Lookback", minval = 20, group = groupMomentum, tooltip = "Lookback used to normalize release quality so scores stay more stable across symbols.")
proofWindow = input.int(10, "Follow-Through Window", minval = 3, maxval = 50, group = groupMomentum, tooltip = "Number of confirmed bars used to test whether a qualified release follows through directionally before momentum flips back across the zero line.")

groupVisual = "Visuals"
showAdaptiveZones = input.bool(true, "Show Adaptive Momentum Zones", group = groupVisual, tooltip = "Displays adaptive balance and expansion zones inside the oscillator pane.")
showSignalLine = input.bool(true, "Show Signal Line", group = groupVisual, tooltip = "Plots a smooth signal line on top of the histogram for additional rhythm context.")
histWidth = input.int(4, "Histogram Width", minval = 1, maxval = 6, group = groupVisual, tooltip = "Controls histogram thickness.")
showReleaseBoxes = input.bool(true, "Show Release Boxes", group = groupVisual, tooltip = "Draws rectangular release zones during active bullish or bearish expansion phases.")
zonePersistence = input.int(22, "Release Box Persistence", minval = 5, maxval = 100, group = groupVisual, tooltip = "Maximum number of bars a release box may extend while its direction remains valid.")
maxZoneCount = input.int(14, "Max Boxes Kept", minval = 4, maxval = 40, group = groupVisual, tooltip = "Limits how many release boxes remain on the chart to keep the pane clean and fast.")
showQualityLine = input.bool(false, "Show Quality Line", group = groupVisual, tooltip = "Plots a subtle quality line for users who want a second visual guide without cluttering the default view.")

groupSignals = "Signals"
showReleaseLabels = input.bool(true, "Show Release Labels", group = groupSignals, tooltip = "Prints a label when a qualified squeeze release aligns with directional momentum.")
showCoolingLabels = input.bool(true, "Show Cooling Labels", group = groupSignals, tooltip = "Prints a smaller label when elevated momentum begins to cool.")
minLabelSpacing = input.int(14, "Minimum Label Spacing", minval = 1, maxval = 100, group = groupSignals, tooltip = "Minimum bars required between labels so the pane stays premium and uncluttered.")
maxLabelCount = input.int(20, "Max Labels Kept", minval = 4, maxval = 60, group = groupSignals, tooltip = "Caps the number of visible labels.")
minReleaseQuality = input.float(45.0, "Min Release Quality", minval = 0.0, maxval = 100.0, step = 1.0, group = groupSignals, tooltip = "Minimum release quality score required before a burst label can print.")
minCoolingQuality = input.float(35.0, "Min Cooling Quality", minval = 0.0, maxval = 100.0, step = 1.0, group = groupSignals, tooltip = "Minimum cooling strength required before a cooling label can print. Higher values keep cooling labels more selective.")

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = "Displays the AG Pro summary panel in the oscillator pane.")
themeInput = input.string("Dark", "Theme", options = ["Dark", "Light"], group = groupPanel, tooltip = "Dark uses the AG Pro presentation standard. Light is tuned for brighter chart themes.")
panelPositionInput = input.string("Top Right", "Panel Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = groupPanel, tooltip = "Selects where the information panel is pinned.")
panelFontInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = "Controls panel text size. Default is Normal.")
labelFontInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = "Controls every on-chart release, cooling, and release-zone badge from one setting. Default is Normal.")

// -------------------------------------------------
// Style state
// -------------------------------------------------
panelPosition = f_position(panelPositionInput)
panelTextSize = f_size(panelFontInput)
labelTextSize = f_size(labelFontInput)
isLightTheme = themeInput == "Light"

panelBgColor = isLightTheme ? color.rgb(248, 250, 252) : panelBg
panelBorderColor = isLightTheme ? color.rgb(203, 213, 225) : panelBorder
panelLabelColor = isLightTheme ? color.rgb(71, 85, 105) : panelLabelCol
panelValueColor = isLightTheme ? color.rgb(15, 23, 42) : panelValueCol
rowOddBg = isLightTheme ? color.rgb(255, 255, 255) : color.new(panelBgColor, 0)
rowEvenBg = isLightTheme ? color.rgb(241, 245, 249) : color.rgb(20, 29, 49)

// -------------------------------------------------
// Squeeze engine
// -------------------------------------------------
trueRange = ta.tr(true)
rangeSource = useTrueRange ? trueRange : high - low

bbBasis = nz(ta.ema(src, bbLength), src)
bbDev = nz(ta.stdev(src, bbLength)) * bbMult
bbUpper = bbBasis + bbDev
bbLower = bbBasis - bbDev

kcBasis = nz(ta.ema(src, kcLength), src)
kcRange = nz(ta.ema(rangeSource, kcLength))
kcUpper = kcBasis + kcRange * kcMult
kcLower = kcBasis - kcRange * kcMult

bbWidth = bbUpper - bbLower
kcWidth = math.max(kcUpper - kcLower, syminfo.mintick)
sqzRatio = bbWidth / kcWidth

bool squeezeOn = sqzRatio < 1.0
bool squeezeOnPrev = bar_index > 0 ? squeezeOn[1] : false
bool squeezeStarted = squeezeOn and not squeezeOnPrev
bool squeezeReleased = not squeezeOn and squeezeOnPrev

compressionDepth = math.max(0.0, 1.0 - sqzRatio)
compressionPct = compressionDepth * 100.0
compressionGrade = f_compression_grade(compressionPct)

// -------------------------------------------------
// Momentum engine
// -------------------------------------------------
atrBase = math.max(nz(ta.ema(trueRange, kcLength)), trueRange, syminfo.mintick)
equilibrium = nz(ta.ema(src, eqLength), src)
displacement = (src - equilibrium) / atrBase
velocity = nz(ta.ema(ta.change(equilibrium), velLength) / atrBase)
netMove = src - nz(src[eqLength], src)
pathTravel = nz(math.sum(math.abs(nz(ta.change(src))), eqLength))
efficiency = pathTravel > 0.0 ? netMove / pathTravel : 0.0

rawMomentum = displacement * 0.55 + velocity * 2.00 + efficiency * 0.80
momentum = nz(ta.ema(rawMomentum, smoothLength))
signal = nz(ta.ema(momentum, math.max(2, smoothLength * 2)))
accel = momentum - nz(momentum[1])
energy = math.abs(momentum)
energyMean = nz(ta.ema(energy, energyLength))
energyDev = nz(ta.stdev(energy, energyLength))

balanceBand = math.max(energyMean * 0.45, 0.12)
burstBand = math.max(energyMean + energyDev * burstMultiplier, 0.35)

qualityScale = math.max(nz(ta.highest(energy, qualityLookback)), burstBand)
compressionScore = f_clamp(compressionPct * 3.8, 0.0, 100.0)
thrustScore = f_clamp((energy / math.max(burstBand, 0.01)) * 38.0, 0.0, 100.0)
accelScore = f_clamp((math.abs(accel) / math.max(energyDev, 0.05)) * 22.0, 0.0, 100.0)
efficiencyScore = f_clamp(math.abs(efficiency) * 100.0, 0.0, 100.0)
stabilityScore = f_clamp((energy / math.max(qualityScale, 0.01)) * 100.0, 0.0, 100.0)
releaseQuality = f_clamp(compressionScore * 0.28 + thrustScore * 0.30 + accelScore * 0.14 + efficiencyScore * 0.18 + stabilityScore * 0.10, 0.0, 100.0)
releaseQualityText = f_quality_bucket(releaseQuality)
coolingStrength = f_clamp(thrustScore * 0.60 + efficiencyScore * 0.25 + stabilityScore * 0.15, 0.0, 100.0)

bullExpansion = momentum > 0 and accel >= 0
bullContinuation = momentum > 0 and accel < 0 and momentum > balanceBand
bullCooling = momentum > 0 and accel < 0 and momentum <= balanceBand
bearExpansion = momentum < 0 and accel <= 0
bearContinuation = momentum < 0 and accel > 0 and momentum < -balanceBand
bearCooling = momentum < 0 and accel > 0 and momentum >= -balanceBand
isBalanced = math.abs(momentum) <= balanceBand

bullRelease = squeezeReleased and momentum > balanceBand and accel > 0
bearRelease = squeezeReleased and momentum < -balanceBand and accel < 0
qualifiedBullRelease = bullRelease and releaseQuality >= minReleaseQuality
qualifiedBearRelease = bearRelease and releaseQuality >= minReleaseQuality
bullCoolingEvent = not squeezeOn and momentum > burstBand and accel < 0 and momentum < nz(momentum[1])
bearCoolingEvent = not squeezeOn and momentum < -burstBand and accel > 0 and momentum > nz(momentum[1])

// -------------------------------------------------
// Stop-aware follow-through proof engine
// Confirmed-bar gated. Resolve any open test first, then open a new one.
// Rails are frozen at the moment of release. A directional release "follows
// through" when momentum expands a further step beyond its release reading; it
// "fails" when momentum fizzles back to the balance band before doing so.
// Tests that neither resolve inside the window time out and stay uncounted, so
// the rate reflects only genuine expansion-vs-fizzle outcomes.
// -------------------------------------------------
expandStep = math.max(burstBand * 0.35, balanceBand * 0.50)

var int   proofWins     = 0
var int   proofTotal    = 0
var bool  proofPending  = false
var int   proofDir      = 0
var float proofTarget   = na
var float proofInvalid  = na
var int   proofBarsLeft = 0

if barstate.isconfirmed
    if proofPending
        proofBarsLeft := proofBarsLeft - 1
        if proofDir == 1
            if momentum >= proofTarget
                proofWins  := proofWins + 1
                proofTotal := proofTotal + 1
                proofPending := false
            else if momentum <= proofInvalid
                proofTotal := proofTotal + 1
                proofPending := false
            else if proofBarsLeft <= 0
                proofPending := false
        else if proofDir == -1
            if momentum <= proofTarget
                proofWins  := proofWins + 1
                proofTotal := proofTotal + 1
                proofPending := false
            else if momentum >= proofInvalid
                proofTotal := proofTotal + 1
                proofPending := false
            else if proofBarsLeft <= 0
                proofPending := false
    if not proofPending
        if bullRelease
            proofPending  := true
            proofDir      := 1
            proofTarget   := momentum + expandStep
            proofInvalid  := balanceBand
            proofBarsLeft := proofWindow
        else if bearRelease
            proofPending  := true
            proofDir      := -1
            proofTarget   := momentum - expandStep
            proofInvalid  := -balanceBand
            proofBarsLeft := proofWindow

proofRate  = proofTotal > 0 ? proofWins / proofTotal * 100.0 : 0.0
proofReady = proofTotal >= 6
proofText  = proofReady ? str.tostring(proofRate, "#") + "%" : "Building (" + str.tostring(proofTotal) + ")"
proofFill  = not proofReady ? neutralColor : proofRate >= 55.0 ? bullColor : proofRate >= 45.0 ? neutralColor : bearColor

stateText = squeezeOn ? (compressionPct >= 22 ? "EXTREME COIL" : compressionPct >= 14 ? "DEEP COIL" : "ACTIVE COIL") : qualifiedBullRelease ? "BULL RELEASE" : qualifiedBearRelease ? "BEAR RELEASE" : bullExpansion ? "BULL EXPANSION" : bearExpansion ? "BEAR EXPANSION" : bullContinuation ? "BULL CONTINUATION" : bearContinuation ? "BEAR CONTINUATION" : (bullCooling or bullCoolingEvent) ? "BULL COOLING" : (bearCooling or bearCoolingEvent) ? "BEAR COOLING" : "BALANCE"
biasText = momentum > 0 ? "BULLISH" : momentum < 0 ? "BEARISH" : "NEUTRAL"
compressionText = squeezeOn ? compressionGrade + "  " + str.tostring(compressionPct, "#.0") + "%" : "Released"
qualityLabelText = squeezeOn ? "Setup" : "Quality"
qualityText = squeezeOn ? compressionGrade + " Coil" : releaseQualityText + "  " + str.tostring(releaseQuality, "#")
workflowText = qualifiedBullRelease ? "Track bull release" : qualifiedBearRelease ? "Track bear release" : squeezeOn ? "Prepare for release" : bullContinuation ? "Track bull follow-through" : bearContinuation ? "Track bear follow-through" : (bullCooling or bullCoolingEvent) ? "Review bull cooling" : (bearCooling or bearCoolingEvent) ? "Review bear cooling" : isBalanced ? "Wait for pressure" : "Monitor directional build"
energyRatio = energy / math.max(burstBand, 0.01)

var int stateStartBar = 0
stateChanged = bar_index == 0 or stateText != stateText[1]
if barstate.isconfirmed and stateChanged
    stateStartBar := bar_index
stateAge = math.max(bar_index - stateStartBar + 1, 1)

// -------------------------------------------------
// Visual state
// -------------------------------------------------
bullContinuationColor = color.new(bullColor, 38)
bearContinuationColor = color.new(bearColor, 38)
coolingBullColor = color.new(neutralColor, 12)
coolingBearColor = color.new(neutralColor, 24)
balanceColor = color.new(neutralColor, 48)

histColor = qualifiedBullRelease ? bullColor : qualifiedBearRelease ? bearColor : bullExpansion ? bullColor : bullContinuation ? bullContinuationColor : (bullCooling or bullCoolingEvent) ? coolingBullColor : bearExpansion ? bearColor : bearContinuation ? bearContinuationColor : (bearCooling or bearCoolingEvent) ? coolingBearColor : balanceColor
signalColor = isLightTheme ? color.rgb(67, 56, 202) : accentColor
qualityColor = momentum >= 0 ? color.new(accentColor, 15) : color.new(accentColor, 35)
zeroLineColor = squeezeOn ? headerBg : qualifiedBullRelease ? bullColor : qualifiedBearRelease ? bearColor : color.new(neutralColor, 15)

stateValueColor = (qualifiedBullRelease or bullExpansion or bullContinuation) ? bullColor : (qualifiedBearRelease or bearExpansion or bearContinuation) ? bearColor : squeezeOn ? accentColor : neutralColor
compressionValueColor = squeezeOn ? headerBg : accentColor
qualityValueColor = releaseQuality >= 70 ? bullColor : releaseQuality >= 45 ? neutralColor : bearColor
biasValueColor = momentum > 0 ? bullColor : momentum < 0 ? bearColor : neutralColor
workflowValueColor = qualifiedBullRelease ? bullColor : qualifiedBearRelease ? bearColor : squeezeOn ? accentColor : (bullCooling or bearCooling or bullCoolingEvent or bearCoolingEvent) ? neutralColor : panelValueColor

// -------------------------------------------------
// Plots
// -------------------------------------------------
upperBurstPlot = plot(showAdaptiveZones ? burstBand : na, "Upper Burst Zone", color = color.new(bullColor, 100))
upperBalancePlot = plot(showAdaptiveZones ? balanceBand : na, "Upper Balance Zone", color = color.new(neutralColor, 100))
lowerBalancePlot = plot(showAdaptiveZones ? -balanceBand : na, "Lower Balance Zone", color = color.new(neutralColor, 100))
lowerBurstPlot = plot(showAdaptiveZones ? -burstBand : na, "Lower Burst Zone", color = color.new(bearColor, 100))

fill(upperBurstPlot, upperBalancePlot, color = color.new(bullColor, 93), title = "Bull Expansion Fill")
fill(upperBalancePlot, lowerBalancePlot, color = color.new(neutralColor, 94), title = "Balance Fill")
fill(lowerBalancePlot, lowerBurstPlot, color = color.new(bearColor, 93), title = "Bear Expansion Fill")

plot(momentum, "Momentum Histogram", color = histColor, style = plot.style_histogram, linewidth = histWidth)
plot(showSignalLine ? signal : na, "Signal Line", color = color.new(signalColor, 10), linewidth = 2)
plot(showQualityLine ? releaseQuality / 50.0 - 1.0 : na, "Quality Line", color = qualityColor, linewidth = 1)
plot(0.0, "Zero Line", color = zeroLineColor, linewidth = 2)
plot(squeezeOn and compressionPct < 14 ? 0.0 : na, "Squeeze Active Marker", color = headerBg, style = plot.style_circles, linewidth = 2)
plot(squeezeOn and compressionPct >= 14 ? 0.0 : na, "Deep Squeeze Marker", color = accentColor, style = plot.style_circles, linewidth = 3)
plot(squeezeReleased ? 0.0 : na, "Squeeze Release Marker", color = accentColor, style = plot.style_circles, linewidth = 3)

// -------------------------------------------------
// Release boxes
// -------------------------------------------------
var box bullBox = na
var box bearBox = na
var int bullBoxStart = na
var int bearBoxStart = na
var label bullBoxBadge = na
var label bearBoxBadge = na
var float bullBoxQuality = na
var float bearBoxQuality = na
var array<box> releaseBoxes = array.new_box()
var array<label> releaseBoxBadges = array.new_label()

if showReleaseBoxes
    if qualifiedBullRelease
        bullBox := box.new(left = bar_index, top = burstBand, right = bar_index, bottom = balanceBand, border_color = color.new(bullColor, 70), border_width = 1, xloc = xloc.bar_index, bgcolor = color.new(bullColor, 90))
        bullBoxStart := bar_index
        bullBoxQuality := releaseQuality
        bullBoxBadge := label.new(bar_index, (burstBand + balanceBand) * 0.5, "BULL PHASE | Q " + str.tostring(bullBoxQuality, "#"), xloc = xloc.bar_index, style = label.style_label_center, textcolor = f_text_on(bullColor), color = bullColor, size = labelTextSize, tooltip = "Centered identifier for the active bullish release box. Quality is frozen at release.")
        array.push(releaseBoxes, bullBox)
        array.push(releaseBoxBadges, bullBoxBadge)
    if qualifiedBearRelease
        bearBox := box.new(left = bar_index, top = -balanceBand, right = bar_index, bottom = -burstBand, border_color = color.new(bearColor, 70), border_width = 1, xloc = xloc.bar_index, bgcolor = color.new(bearColor, 90))
        bearBoxStart := bar_index
        bearBoxQuality := releaseQuality
        bearBoxBadge := label.new(bar_index, (-balanceBand - burstBand) * 0.5, "BEAR PHASE | Q " + str.tostring(bearBoxQuality, "#"), xloc = xloc.bar_index, style = label.style_label_center, textcolor = f_text_on(bearColor), color = bearColor, size = labelTextSize, tooltip = "Centered identifier for the active bearish release box. Quality is frozen at release.")
        array.push(releaseBoxes, bearBox)
        array.push(releaseBoxBadges, bearBoxBadge)

    if not na(bullBox)
        bullBoxAlive = momentum >= 0 and not na(bullBoxStart) and bar_index - bullBoxStart <= zonePersistence
        if bullBoxAlive
            box.set_right(bullBox, bar_index)
            box.set_top(bullBox, burstBand)
            box.set_bottom(bullBox, balanceBand)
            label.set_x(bullBoxBadge, int(math.round((bullBoxStart + bar_index) * 0.5)))
            label.set_y(bullBoxBadge, (burstBand + balanceBand) * 0.5)
        else
            bullBox := na
            bullBoxStart := na
            bullBoxBadge := na
            bullBoxQuality := na

    if not na(bearBox)
        bearBoxAlive = momentum <= 0 and not na(bearBoxStart) and bar_index - bearBoxStart <= zonePersistence
        if bearBoxAlive
            box.set_right(bearBox, bar_index)
            box.set_top(bearBox, -balanceBand)
            box.set_bottom(bearBox, -burstBand)
            label.set_x(bearBoxBadge, int(math.round((bearBoxStart + bar_index) * 0.5)))
            label.set_y(bearBoxBadge, (-balanceBand - burstBand) * 0.5)
        else
            bearBox := na
            bearBoxStart := na
            bearBoxBadge := na
            bearBoxQuality := na

    while array.size(releaseBoxes) > maxZoneCount
        box.delete(array.shift(releaseBoxes))
        label.delete(array.shift(releaseBoxBadges))

// -------------------------------------------------
// Labels
// All on-chart labels print on opaque filled badges with luminance-145 ink and
// honor the Label Font Size setting directly (no per-type size downgrades).
// -------------------------------------------------
var int lastLabelBar = na
var int lastLabelDirection = 0
var array<label> eventLabels = array.new_label()

labelGap = math.max(burstBand * 0.22, 0.10)
canPrintLabel = na(lastLabelBar) or bar_index - lastLabelBar >= minLabelSpacing
bullLabelAllowed = canPrintLabel and lastLabelDirection != 1
bearLabelAllowed = canPrintLabel and lastLabelDirection != -1

if showReleaseLabels and qualifiedBullRelease and bullLabelAllowed
    newBullReleaseLabel = label.new(bar_index, math.max(momentum, burstBand) + labelGap, "BULL RELEASE | Q " + str.tostring(releaseQuality, "#"), style = label.style_label_down, textcolor = f_text_on(bullColor), color = bullColor, size = labelTextSize, tooltip = "Qualified bullish squeeze release. The score blends compression depth, thrust, acceleration, efficiency, and stability.")
    array.push(eventLabels, newBullReleaseLabel)
    lastLabelBar := bar_index
    lastLabelDirection := 1

if showReleaseLabels and qualifiedBearRelease and bearLabelAllowed
    newBearReleaseLabel = label.new(bar_index, math.min(momentum, -burstBand) - labelGap, "BEAR RELEASE | Q " + str.tostring(releaseQuality, "#"), style = label.style_label_up, textcolor = f_text_on(bearColor), color = bearColor, size = labelTextSize, tooltip = "Qualified bearish squeeze release. The score blends compression depth, thrust, acceleration, efficiency, and stability.")
    array.push(eventLabels, newBearReleaseLabel)
    lastLabelBar := bar_index
    lastLabelDirection := -1

if showCoolingLabels and bullCoolingEvent and bullLabelAllowed and coolingStrength >= minCoolingQuality
    newBullCoolingLabel = label.new(bar_index, momentum + labelGap, "BULL COOLING | Q " + str.tostring(coolingStrength, "#"), style = label.style_label_down, textcolor = f_text_on(bullColor), color = bullColor, size = labelTextSize, tooltip = "Bullish momentum remains elevated but acceleration has cooled. The score summarizes remaining thrust, efficiency, and stability.")
    array.push(eventLabels, newBullCoolingLabel)
    lastLabelBar := bar_index
    lastLabelDirection := 1

if showCoolingLabels and bearCoolingEvent and bearLabelAllowed and coolingStrength >= minCoolingQuality
    newBearCoolingLabel = label.new(bar_index, momentum - labelGap, "BEAR COOLING | Q " + str.tostring(coolingStrength, "#"), style = label.style_label_up, textcolor = f_text_on(bearColor), color = bearColor, size = labelTextSize, tooltip = "Bearish momentum remains elevated but acceleration has cooled. The score summarizes remaining thrust, efficiency, and stability.")
    array.push(eventLabels, newBearCoolingLabel)
    lastLabelBar := bar_index
    lastLabelDirection := -1

while array.size(eventLabels) > maxLabelCount
    label.delete(array.shift(eventLabels))

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table panel = showPanel ? table.new(panelPosition, 2, 9, frame_color = panelBorderColor, border_color = panelBorderColor, frame_width = 1, border_width = 1) : na

if showPanel and barstate.isfirst
    table.merge_cells(panel, 0, 0, 1, 0)

if showPanel and barstate.islast
    table.cell(panel, 0, 0, "AG Pro Squeeze Momentum", text_color = headerText, bgcolor = headerBg, text_size = panelTextSize, text_halign = text.align_center, tooltip = "Panel title. The published indicator title intentionally keeps the AG Pro tag only in the panel.")

    table.cell(panel, 0, 1, "Workflow", text_color = panelLabelColor, bgcolor = rowOddBg, text_size = panelTextSize, tooltip = "Compact review step derived from the current oscillator lifecycle.")
    table.cell(panel, 1, 1, workflowText, text_color = workflowValueColor, bgcolor = rowOddBg, text_size = panelTextSize)

    table.cell(panel, 0, 2, "State", text_color = panelLabelColor, bgcolor = rowEvenBg, text_size = panelTextSize, tooltip = "Current lifecycle state: coil, release, expansion, continuation, cooling, or balance.")
    table.cell(panel, 1, 2, stateText, text_color = stateValueColor, bgcolor = rowEvenBg, text_size = panelTextSize)

    table.cell(panel, 0, 3, "Bias", text_color = panelLabelColor, bgcolor = rowOddBg, text_size = panelTextSize, tooltip = "Directional bias based on the sign of the blended momentum engine.")
    table.cell(panel, 1, 3, biasText, text_color = biasValueColor, bgcolor = rowOddBg, text_size = panelTextSize)

    table.cell(panel, 0, 4, qualityLabelText, text_color = panelLabelColor, bgcolor = rowEvenBg, text_size = panelTextSize, tooltip = "During squeeze, this row summarizes setup quality through compression grade. After release, it becomes the Release Quality score from 0 to 100.")
    table.cell(panel, 1, 4, qualityText, text_color = qualityValueColor, bgcolor = rowEvenBg, text_size = panelTextSize)

    table.cell(panel, 0, 5, "Follow-Through", text_color = panelLabelColor, bgcolor = rowOddBg, text_size = panelTextSize, tooltip = "Confirmed-bar follow-through rate of directional releases. A release follows through when momentum expands a further step beyond its release reading; it fails when momentum fizzles back to the balance band first. Rails are frozen at the release. Tests that do neither inside the window time out and stay uncounted. Shows Building until at least six tests have resolved.")
    table.cell(panel, 1, 5, proofText, text_color = f_text_on(proofFill), bgcolor = proofFill, text_size = panelTextSize)

    table.cell(panel, 0, 6, "Compression", text_color = panelLabelColor, bgcolor = rowEvenBg, text_size = panelTextSize, tooltip = "Compression Grade summarizes how tightly the Bollinger envelope is contracting inside the Keltner envelope.")
    table.cell(panel, 1, 6, compressionText, text_color = compressionValueColor, bgcolor = rowEvenBg, text_size = panelTextSize)

    table.cell(panel, 0, 7, "Momentum / Burst", text_color = panelLabelColor, bgcolor = rowOddBg, text_size = panelTextSize, tooltip = "Current ATR-normalized momentum and its magnitude as a multiple of the adaptive burst threshold.")
    table.cell(panel, 1, 7, str.tostring(momentum, "#.##") + " | " + str.tostring(energyRatio, "#.##") + "x", text_color = panelValueColor, bgcolor = rowOddBg, text_size = panelTextSize)

    table.cell(panel, 0, 8, "Phase Age", text_color = panelLabelColor, bgcolor = rowEvenBg, text_size = panelTextSize, tooltip = "Confirmed bars elapsed since the current lifecycle state began.")
    table.cell(panel, 1, 8, str.tostring(stateAge) + " bars", text_color = panelValueColor, bgcolor = rowEvenBg, text_size = panelTextSize)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(squeezeStarted, "Squeeze Started", "Squeeze Momentum Indicator [AGPro Series]: squeeze started.")
alertcondition(squeezeReleased, "Squeeze Released", "Squeeze Momentum Indicator [AGPro Series]: squeeze released.")
alertcondition(qualifiedBullRelease, "Bull Release", "Squeeze Momentum Indicator [AGPro Series]: qualified bullish squeeze release detected.")
alertcondition(qualifiedBearRelease, "Bear Release", "Squeeze Momentum Indicator [AGPro Series]: qualified bearish squeeze release detected.")
alertcondition(bullCoolingEvent or bearCoolingEvent, "Cooling Event", "Squeeze Momentum Indicator [AGPro Series]: momentum cooling detected.")
````
