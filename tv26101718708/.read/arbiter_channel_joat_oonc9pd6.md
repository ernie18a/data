# Arbiter Channel [JOAT]

- url: https://www.tradingview.com/script/Oonc9pd6-Arbiter-Channel-JOAT/
- type: indicator
- pine_id: PUB;23a2ff28e3ae4c888b3adb33f8a201e1
- version: 1.0

## Description

[b]Arbiter Channel [JOAT][/b]

[b]Introduction[/b]

Arbiter Channel is an open-source market state overlay built to classify directional control, compression, and expansion using a layered baseline-and-channel framework. The script blends an Ichimoku-inspired composite baseline, body-aware tolerance channels, and a confirmed-bar trend-state engine to identify whether price is operating in directional acceptance, compression, or expansion. Rather than acting like a generic moving average channel, Arbiter Channel is designed to map the relationship between equilibrium and displacement.

The problem Arbiter Channel solves is false trend interpretation. Price can trade above a moving average without truly being in an efficient trend, and it can look weak during healthy pullbacks inside a broader expansion. Arbiter Channel separates baseline equilibrium, tolerance acceptance, and directional displacement so that the user can tell whether price is simply oscillating around fair value, compressing inside equilibrium, or expanding away from it with intent.

[image]https://www.tradingview.com/x/e13KyVxd/[/image]

[b]Core Concepts[/b]

[b]1. Composite Baseline Construction[/b]

The baseline is built from an Ichimoku-style blend of Conversion, Base, Span A, and Span B components, with user-controlled inclusion and weighting. This creates a smoother and more structurally aware equilibrium anchor than a single moving average:

[pine]
tenkan = donchianMid(convLen)
kijun  = donchianMid(baseLen)
spanA  = math.avg(tenkan, kijun)
spanB  = donchianMid(spanBLen)
[/pine]

[b]2. ATR and Body Tolerance Channel[/b]

Instead of plotting a fixed-width envelope, the channel adapts to both ATR behavior and candle-body pressure. This helps the band respond differently during active displacement than during passive drift. The result is a tolerance corridor where trend acceptance and loss of acceptance become visually obvious.

[b]3. Confirmed-Bar Trend State Machine[/b]

Trend transitions are only registered on confirmed bars. This avoids intrabar flipping and helps keep trend-state changes non-repainting for practical signal use. The script distinguishes directional trend shifts from regime changes, so compression and expansion can evolve without necessarily forcing a full directional flip.

[b]4. Compression and Expansion Regimes[/b]

Arbiter Channel tracks whether price is contracting around equilibrium or extending away from it. This is important because directional trend and volatility regime are not the same thing. A bullish trend can be compressing before expansion, and expansion can fail back into balance.

[b]5. Institutional Visualization Layer[/b]

The overlay uses nested clouds, baseline shadows, state candle tinting, controlled event labels, and a medium top-right dashboard to summarize regime and trend without clutter.

[image][/image]

[b]Features[/b]

[list]
[*][b]Composite baseline engine:[/b] Uses multiple Ichimoku-derived components instead of a single average
[*][b]Adaptive tolerance channels:[/b] Envelope width responds to volatility and body behavior
[*][b]Compression and expansion classification:[/b] Distinguishes rotational balance from directional release
[*][b]Confirmed-bar trend state engine:[/b] Trend shifts only confirm after bar close
[*][b]Outer reclaim events:[/b] Detects price returning inside channel boundaries after extension
[*][b]Cloud-based regime visualization:[/b] Multi-layer fills show equilibrium and displacement zones
[*][b]State candle tinting:[/b] Candles inherit directional context without overwhelming price
[*][b]Top-right dashboard:[/b] Displays current trend, regime, channel state, and internal diagnostics
[*][b]Fully configurable palette:[/b] Built for dark charts with adjustable institutional tones
[*][b]Confirmed alertconditions:[/b] Trend shifts, regime changes, reclaim events, and expansion bursts
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the Trend State[/b]
Start with the dashboard and baseline color. This tells you whether the script currently classifies the market as bullish, bearish, or neutral from a confirmed-bar perspective.

[b]Step 2: Check the Regime[/b]
Compression means price is accepting around equilibrium. Expansion means price is actively displacing. Combining trend with regime helps determine whether to expect continuation or wait for release.

[b]Step 3: Use the Channel Structure[/b]
The inner and outer bands act as context zones. Price holding outside the inner corridor during expansion is stronger than price simply crossing the baseline.

[b]Step 4: Watch Reclaim Events[/b]
When price extends beyond the outer channel and then reclaims back inside it, that event can signal exhaustion, acceptance failure, or a return to balance.

[b]Indicator Limitations[/b]

[list]
[*]The baseline is a structural equilibrium model, not a predictive model
[*]Compression and expansion are relative to the current symbol and timeframe inputs
[*]Strong news events can create abrupt regime transitions that temporarily distort channel interpretation
[*]The script is best used as a context overlay, not as a standalone trade trigger
[/list]

[b]Originality Statement[/b]

Arbiter Channel is original in the way it separates directional trend, equilibrium tolerance, and volatility regime into one coordinated overlay. It is not a simple moving average channel and not a direct copy of Ichimoku. The value comes from combining a composite baseline, adaptive tolerance geometry, and confirmed-bar regime logic into a single context engine.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice and does not guarantee future market behavior. Always use proper risk management.

- Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Arbiter Channel [JOAT]", shorttitle = "ARB [JOAT]", overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 200)

// =============================================================================
// Arbiter Channel [JOAT]
// Institutional overlay framework:
// 1) Composite baseline (Ichimoku-inspired blend)
// 2) ATR + body tolerance channel
// 3) Compression / expansion regime engine
// 4) Confirmed-bar trend-state transitions
// 5) Clean cloud visuals + state candle tinting + top-right dashboard
// =============================================================================

// =============================================================================
// INPUT GROUPS
// =============================================================================
groupBaseline = "01 Baseline Engine"
groupWeights = "02 Baseline Weights"
groupChannel = "03 Channel Engine"
groupRegime = "04 Regime Engine"
groupState = "05 State Machine"
groupVisual = "06 Visual System"
groupDash = "07 Dashboard"
groupLabel = "08 Labels"
groupAlert = "09 Alerts"

// =============================================================================
// BASELINE ENGINE INPUTS
// =============================================================================
convLen = input.int(9, "Conversion Length", minval = 1, group = groupBaseline)
baseLen = input.int(26, "Base Length", minval = 1, group = groupBaseline)
spanBLen = input.int(52, "Span B Length", minval = 1, group = groupBaseline)
baseSmoothLen = input.int(7, "Baseline Smoothing Length", minval = 1, group = groupBaseline)
slopeLookback = input.int(5, "Slope Lookback", minval = 1, group = groupBaseline)

useTenkan = input.bool(true, "Include Conversion", group = groupBaseline)
useKijun = input.bool(true, "Include Base", group = groupBaseline)
useSpanA = input.bool(true, "Include Span A", group = groupBaseline)
useSpanB = input.bool(true, "Include Span B", group = groupBaseline)
useCloseAnchor = input.bool(false, "Include Close Anchor", group = groupBaseline)

// =============================================================================
// BASELINE WEIGHTS
// =============================================================================
weightTenkan = input.float(1.0, "Conversion Weight", minval = 0.0, step = 0.1, group = groupWeights)
weightKijun = input.float(1.3, "Base Weight", minval = 0.0, step = 0.1, group = groupWeights)
weightSpanA = input.float(1.0, "Span A Weight", minval = 0.0, step = 0.1, group = groupWeights)
weightSpanB = input.float(1.1, "Span B Weight", minval = 0.0, step = 0.1, group = groupWeights)
weightCloseAnchor = input.float(0.4, "Close Anchor Weight", minval = 0.0, step = 0.1, group = groupWeights)

// =============================================================================
// CHANNEL ENGINE INPUTS
// =============================================================================
atrLen = input.int(14, "ATR Length", minval = 1, group = groupChannel)
atrMult = input.float(1.35, "ATR Multiplier", minval = 0.1, step = 0.05, group = groupChannel)
bodyLen = input.int(20, "Body Average Length", minval = 1, group = groupChannel)
bodyMult = input.float(1.10, "Body Multiplier", minval = 0.1, step = 0.05, group = groupChannel)
widthSmoothing = input.int(5, "Width Smoothing", minval = 1, group = groupChannel)
innerRatio = input.float(0.55, "Inner Channel Ratio", minval = 0.1, maxval = 1.0, step = 0.05, group = groupChannel)
minTickWidth = input.float(2.0, "Minimum Width in Ticks", minval = 0.1, step = 0.1, group = groupChannel)

// =============================================================================
// REGIME ENGINE INPUTS
// =============================================================================
regimeLen = input.int(34, "Regime Lookback", minval = 5, group = groupRegime)
compressionBodyFactor = input.float(0.75, "Compression Body Factor", minval = 0.1, step = 0.05, group = groupRegime)
compressionRangeFactor = input.float(0.80, "Compression Range Factor", minval = 0.1, step = 0.05, group = groupRegime)
compressionAtrFactor = input.float(0.85, "Compression ATR Factor", minval = 0.1, step = 0.05, group = groupRegime)
expansionBodyFactor = input.float(1.30, "Expansion Body Factor", minval = 0.1, step = 0.05, group = groupRegime)
expansionRangeFactor = input.float(1.20, "Expansion Range Factor", minval = 0.1, step = 0.05, group = groupRegime)
expansionDistanceFactor = input.float(1.05, "Expansion Distance Threshold", minval = 0.1, step = 0.05, group = groupRegime)
volumeLen = input.int(20, "Volume Baseline Length", minval = 1, group = groupRegime)
expansionVolumeFactor = input.float(1.05, "Expansion Volume Factor", minval = 0.1, step = 0.05, group = groupRegime)

// =============================================================================
// STATE MACHINE INPUTS
// =============================================================================
neutralizeOnCompression = input.bool(true, "Neutralize During Compression", group = groupState)
requireSlopeAgreement = input.bool(true, "Require Slope Agreement", group = groupState)
allowInnerReclaimSignals = input.bool(true, "Enable Outer Reclaim Events", group = groupState)

// =============================================================================
// VISUAL SYSTEM INPUTS
// =============================================================================
showBaseline = input.bool(true, "Show Baseline", group = groupVisual)
showChannel = input.bool(true, "Show Outer Channel", group = groupVisual)
showInnerChannel = input.bool(true, "Show Inner Channel", group = groupVisual)
showCloud = input.bool(true, "Show Trend Cloud", group = groupVisual)
showRegimeBg = input.bool(true, "Show Regime Background", group = groupVisual)
showGlow = input.bool(true, "Enable Line Glow", group = groupVisual)
enableCandleTint = input.bool(true, "Enable State Candle Tint", group = groupVisual)

baseLineWidth = input.int(2, "Baseline Width", minval = 1, maxval = 5, group = groupVisual)
channelWidth = input.int(1, "Channel Width", minval = 1, maxval = 4, group = groupVisual)
cloudTransparency = input.int(84, "Cloud Transparency", minval = 0, maxval = 100, group = groupVisual)
bgTransparency = input.int(92, "Background Transparency", minval = 0, maxval = 100, group = groupVisual)
candleAlphaMin = input.int(30, "Candle Alpha Min", minval = 0, maxval = 100, group = groupVisual)
candleAlphaMax = input.int(80, "Candle Alpha Max", minval = 0, maxval = 100, group = groupVisual)

colorBull = input.color(color.rgb(24, 196, 138), "Bull State Color", group = groupVisual)
colorBear = input.color(color.rgb(235, 84, 118), "Bear State Color", group = groupVisual)
colorNeutral = input.color(color.rgb(130, 142, 164), "Neutral State Color", group = groupVisual)
colorCompression = input.color(color.rgb(86, 120, 212), "Compression Color", group = groupVisual)
colorExpansion = input.color(color.rgb(230, 168, 78), "Expansion Color", group = groupVisual)
colorBalance = input.color(color.rgb(108, 117, 136), "Balanced Regime Color", group = groupVisual)

// =============================================================================
// DASHBOARD INPUTS
// =============================================================================
showDashboard = input.bool(true, "Show Top-Right Dashboard", group = groupDash)
dashTransparency = input.int(72, "Dashboard Background Transparency", minval = 0, maxval = 100, group = groupDash)
dashTextSize = input.string("Small", "Dashboard Text Size", options = ["Tiny", "Small", "Normal"], group = groupDash)

// =============================================================================
// LABEL INPUTS
// =============================================================================
showShiftLabels = input.bool(true, "Show Shift Labels", group = groupLabel)
labelSpacing = input.int(12, "Min Bars Between Labels", minval = 1, group = groupLabel)
labelAlpha = input.int(30, "Label Transparency", minval = 0, maxval = 100, group = groupLabel)

// =============================================================================
// ALERT INPUTS
// =============================================================================
enableTrendAlerts = input.bool(true, "Enable Trend Shift Alerts", group = groupAlert)
enableRegimeAlerts = input.bool(true, "Enable Regime Shift Alerts", group = groupAlert)
enableExpansionAlerts = input.bool(true, "Enable Expansion Alerts", group = groupAlert)

// =============================================================================
// HELPER FUNCTIONS
// =============================================================================
f_donchianMid(int len) =>
    math.avg(ta.lowest(len), ta.highest(len))

f_safeDiv(float num, float den, float fallback) =>
    den != 0.0 ? num / den : fallback

f_clamp(float v, float lo, float hi) =>
    math.max(lo, math.min(hi, v))

f_stateText(int s) =>
    s == 1 ? "Bull" : s == -1 ? "Bear" : "Neutral"

f_regimeText(int s) =>
    s == 1 ? "Expansion" : s == -1 ? "Compression" : "Balanced"

f_dashSize(string s) =>
    s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : size.small

f_alphaFromStrength(float strength, int alphaStrong, int alphaWeak) =>
    clamped = f_clamp(strength, 0.0, 2.0)
    scaled = clamped / 2.0
    a = alphaWeak + (alphaStrong - alphaWeak) * scaled
    int(math.round(a))

// =============================================================================
// CORE SERIES: ICHIMOKU-STYLE COMPONENTS AND COMPOSITE BASELINE
// =============================================================================
tenkan = f_donchianMid(convLen)
kijun = f_donchianMid(baseLen)
spanA = math.avg(tenkan, kijun)
spanB = f_donchianMid(spanBLen)

float blendNumerator = 0.0
float blendDenominator = 0.0

if useTenkan
    blendNumerator += tenkan * weightTenkan
    blendDenominator += weightTenkan

if useKijun
    blendNumerator += kijun * weightKijun
    blendDenominator += weightKijun

if useSpanA
    blendNumerator += spanA * weightSpanA
    blendDenominator += weightSpanA

if useSpanB
    blendNumerator += spanB * weightSpanB
    blendDenominator += weightSpanB

if useCloseAnchor
    blendNumerator += close * weightCloseAnchor
    blendDenominator += weightCloseAnchor

compositeRaw = blendDenominator > 0.0 ? blendNumerator / blendDenominator : close
baseline = ta.ema(compositeRaw, baseSmoothLen)

baselineSlope = baseline - baseline[slopeLookback]
baselineSlopeNorm = f_safeDiv(baselineSlope, syminfo.mintick * 100.0, 0.0)

// =============================================================================
// CORE SERIES: CHANNEL WIDTH MODEL (ATR + BODY BLEND)
// =============================================================================
bodyNow = math.abs(close - open)
bodyAvg = ta.ema(bodyNow, bodyLen)
atrNow = ta.atr(atrLen)
rawWidth = atrNow * atrMult + bodyAvg * bodyMult
smoothedWidth = ta.ema(rawWidth, widthSmoothing)
widthFloor = syminfo.mintick * minTickWidth
channelWidthValue = math.max(smoothedWidth, widthFloor)
innerWidthValue = channelWidthValue * innerRatio

upperChannel = baseline + channelWidthValue
lowerChannel = baseline - channelWidthValue
upperInner = baseline + innerWidthValue
lowerInner = baseline - innerWidthValue

distanceToBase = close - baseline
distanceNorm = f_safeDiv(distanceToBase, channelWidthValue, 0.0)
distanceStrength = math.abs(distanceNorm)

// =============================================================================
// CORE SERIES: REGIME MODEL (COMPRESSION / EXPANSION / BALANCED)
// =============================================================================
rangeNow = high - low
rangeAvg = ta.ema(rangeNow, regimeLen)
atrAvg = ta.ema(atrNow, regimeLen)
volumeAvg = ta.sma(volume, volumeLen)

isCompression =
     bodyNow <= bodyAvg * compressionBodyFactor and
     rangeNow <= rangeAvg * compressionRangeFactor and
     atrNow <= atrAvg * compressionAtrFactor

isExpansion =
     bodyNow >= bodyAvg * expansionBodyFactor and
     rangeNow >= rangeAvg * expansionRangeFactor and
     distanceStrength >= expansionDistanceFactor and
     volume >= volumeAvg * expansionVolumeFactor

regimeCandidate = isCompression ? -1 : isExpansion ? 1 : 0

var int regimeState = 0
regimeShiftToCompression = barstate.isconfirmed and regimeCandidate == -1 and regimeState != -1
regimeShiftToExpansion = barstate.isconfirmed and regimeCandidate == 1 and regimeState != 1
regimeShiftToBalanced = barstate.isconfirmed and regimeCandidate == 0 and regimeState != 0

if barstate.isconfirmed
    regimeState := regimeCandidate

// =============================================================================
// CORE SERIES: TREND STATE MODEL
// =============================================================================
slopeUp = baselineSlope > 0
slopeDown = baselineSlope < 0

breakUp = close > upperChannel
breakDown = close < lowerChannel

candidateBull = requireSlopeAgreement ? (breakUp and slopeUp) : breakUp
candidateBear = requireSlopeAgreement ? (breakDown and slopeDown) : breakDown
candidateNeutral = neutralizeOnCompression and regimeState == -1 and close < upperInner and close > lowerInner

var int trendState = 0
trendShiftUp = barstate.isconfirmed and candidateBull and trendState != 1
trendShiftDown = barstate.isconfirmed and candidateBear and trendState != -1
trendShiftNeutral = barstate.isconfirmed and candidateNeutral and trendState != 0

if barstate.isconfirmed
    if trendShiftUp
        trendState := 1
    else if trendShiftDown
        trendState := -1
    else if trendShiftNeutral
        trendState := 0

// Outer-channel reclaims can be useful as continuation diagnostics.
outerReclaimFromUpper = barstate.isconfirmed and allowInnerReclaimSignals and close[1] > upperChannel[1] and close <= upperChannel and trendState == 1
outerReclaimFromLower = barstate.isconfirmed and allowInnerReclaimSignals and close[1] < lowerChannel[1] and close >= lowerChannel and trendState == -1

// Expansion burst event is a stronger subset of expansion, useful for alerts.
expansionBurst =
     barstate.isconfirmed and
     regimeState == 1 and
     distanceStrength >= expansionDistanceFactor * 1.35 and
     rangeNow > rangeAvg * 1.2

// =============================================================================
// COLOR ENGINE
// =============================================================================
trendColor = trendState == 1 ? colorBull : trendState == -1 ? colorBear : colorNeutral
regimeColor = regimeState == -1 ? colorCompression : regimeState == 1 ? colorExpansion : colorBalance

baseLineColor = color.from_gradient(distanceStrength, 0.0, 2.0, color.new(trendColor, 20), trendColor)
upperColor = color.new(trendColor, 20)
lowerColor = color.new(trendColor, 20)
innerColor = color.new(trendColor, 45)

cloudColorOuter = color.new(trendColor, cloudTransparency)
cloudColorInner = color.new(regimeColor, math.min(cloudTransparency + 4, 98))
bgColorRegime = color.new(regimeColor, bgTransparency)

// =============================================================================
// VISUAL OUTPUTS
// =============================================================================
pBaseGlow = plot(showBaseline and showGlow ? baseline : na, "Baseline Glow", color = color.new(trendColor, 80), linewidth = baseLineWidth + 4)
pBaseMain = plot(showBaseline ? baseline : na, "Composite Baseline", color = baseLineColor, linewidth = baseLineWidth)

pUpperGlow = plot(showChannel and showGlow ? upperChannel : na, "Upper Glow", color = color.new(trendColor, 86), linewidth = channelWidth + 3)
pLowerGlow = plot(showChannel and showGlow ? lowerChannel : na, "Lower Glow", color = color.new(trendColor, 86), linewidth = channelWidth + 3)

pUpperMain = plot(showChannel ? upperChannel : na, "Upper Channel", color = upperColor, linewidth = channelWidth)
pLowerMain = plot(showChannel ? lowerChannel : na, "Lower Channel", color = lowerColor, linewidth = channelWidth)

pInnerUpper = plot(showInnerChannel ? upperInner : na, "Inner Upper", color = innerColor, linewidth = 1)
pInnerLower = plot(showInnerChannel ? lowerInner : na, "Inner Lower", color = innerColor, linewidth = 1)

pCloseHidden = plot(close, "Close Anchor", color = na, display = display.none)

fill(pUpperMain, pLowerMain, color = showCloud ? cloudColorOuter : na, title = "Outer Cloud")
fill(pInnerUpper, pInnerLower, color = showCloud ? cloudColorInner : na, title = "Inner Cloud")
fill(pBaseMain, pCloseHidden, color = showCloud ? color.new(trendColor, 92) : na, title = "Baseline Proximity Shadow")

bgcolor(showRegimeBg ? bgColorRegime : na, title = "Regime Background")

// =============================================================================
// STATE CANDLE TINTING
// =============================================================================
candleAlpha = f_alphaFromStrength(distanceStrength, candleAlphaMin, candleAlphaMax)
candleBaseColor = trendState == 1 ? colorBull : trendState == -1 ? colorBear : colorNeutral
regimeAdjustedColor = regimeState == -1 ? colorCompression : regimeState == 1 ? candleBaseColor : candleBaseColor
candleTintColor = enableCandleTint ? color.new(regimeAdjustedColor, candleAlpha) : na
barcolor(candleTintColor, title = "State Candles")

// =============================================================================
// LABELS (SPARSE, EVENT-DRIVEN ONLY)
// =============================================================================
var int lastTrendLabelBar = na
var int lastRegimeLabelBar = na

canDrawTrendLabel = na(lastTrendLabelBar) or bar_index - lastTrendLabelBar >= labelSpacing
canDrawRegimeLabel = na(lastRegimeLabelBar) or bar_index - lastRegimeLabelBar >= labelSpacing

if showShiftLabels and trendShiftUp and canDrawTrendLabel
    label.new(bar_index, low, "Trend: Bull", style = label.style_label_up, color = color.new(colorBull, labelAlpha), textcolor = color.white, size = size.tiny)
    lastTrendLabelBar := bar_index

if showShiftLabels and trendShiftDown and canDrawTrendLabel
    label.new(bar_index, high, "Trend: Bear", style = label.style_label_down, color = color.new(colorBear, labelAlpha), textcolor = color.white, size = size.tiny)
    lastTrendLabelBar := bar_index

if showShiftLabels and regimeShiftToCompression and canDrawRegimeLabel
    label.new(bar_index, baseline, "Regime: Compression", style = label.style_label_left, color = color.new(colorCompression, labelAlpha), textcolor = color.white, size = size.tiny)
    lastRegimeLabelBar := bar_index

if showShiftLabels and regimeShiftToExpansion and canDrawRegimeLabel
    label.new(bar_index, baseline, "Regime: Expansion", style = label.style_label_left, color = color.new(colorExpansion, labelAlpha), textcolor = color.white, size = size.tiny)
    lastRegimeLabelBar := bar_index

// =============================================================================
// DASHBOARD
// Medium top-right table with clear institutional state readouts.
// Updated only on the last bar for performance.
// =============================================================================
dashSize = f_dashSize(dashTextSize)
var table dash = table.new(position.top_right, 4, 8, border_width = 1, border_color = color.new(color.gray, 70), bgcolor = color.new(color.black, dashTransparency))
dashHeaderA = color.new(color.rgb(17, 29, 55), 4)
dashHeaderB = color.new(color.rgb(33, 57, 102), 12)
dashRowA = color.new(color.rgb(14, 20, 32), 12)
dashRowB = color.new(color.rgb(22, 30, 48), 18)

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "Arbiter", text_color = color.white, text_size = dashSize, bgcolor = dashHeaderA)
    table.cell(dash, 1, 0, "State", text_color = color.white, text_size = dashSize, bgcolor = dashHeaderB)
    table.cell(dash, 2, 0, "Value", text_color = color.white, text_size = dashSize, bgcolor = dashHeaderB)
    table.cell(dash, 3, 0, "Bias", text_color = color.white, text_size = dashSize, bgcolor = dashHeaderB)

    table.cell(dash, 0, 1, "Trend", text_color = color.white, text_size = dashSize, bgcolor = dashRowA)
    table.cell(dash, 1, 1, f_stateText(trendState), text_color = trendColor, text_size = dashSize, bgcolor = dashRowA)
    table.cell(dash, 2, 1, str.tostring(distanceNorm, "#.00"), text_color = color.white, text_size = dashSize, bgcolor = dashRowA)
    table.cell(dash, 3, 1, trendState == 1 ? "Long Bias" : trendState == -1 ? "Short Bias" : "Neutral", text_color = trendColor, text_size = dashSize, bgcolor = dashRowA)

    table.cell(dash, 0, 2, "Regime", text_color = color.white, text_size = dashSize)
    table.cell(dash, 1, 2, f_regimeText(regimeState), text_color = regimeColor, text_size = dashSize)
    table.cell(dash, 2, 2, str.tostring(rangeNow, format.mintick), text_color = color.white, text_size = dashSize)
    table.cell(dash, 3, 2, regimeState == 1 ? "Fast Tape" : regimeState == -1 ? "Tight Tape" : "Mixed", text_color = regimeColor, text_size = dashSize)

    table.cell(dash, 0, 3, "Baseline", text_color = color.white, text_size = dashSize)
    table.cell(dash, 1, 3, str.tostring(baseline, format.mintick), text_color = color.white, text_size = dashSize)
    table.cell(dash, 2, 3, "Slope", text_color = color.white, text_size = dashSize)
    table.cell(dash, 3, 3, str.tostring(baselineSlopeNorm, "#.00"), text_color = slopeUp ? colorBull : slopeDown ? colorBear : colorNeutral, text_size = dashSize)

    table.cell(dash, 0, 4, "Outer Width", text_color = color.white, text_size = dashSize)
    table.cell(dash, 1, 4, str.tostring(channelWidthValue, format.mintick), text_color = color.white, text_size = dashSize)
    table.cell(dash, 2, 4, "Inner Width", text_color = color.white, text_size = dashSize)
    table.cell(dash, 3, 4, str.tostring(innerWidthValue, format.mintick), text_color = color.white, text_size = dashSize)

    table.cell(dash, 0, 5, "Vol State", text_color = color.white, text_size = dashSize)
    table.cell(dash, 1, 5, isCompression ? "Compressed" : isExpansion ? "Expanding" : "Normal", text_color = isCompression ? colorCompression : isExpansion ? colorExpansion : colorNeutral, text_size = dashSize)
    table.cell(dash, 2, 5, "ATR", text_color = color.white, text_size = dashSize)
    table.cell(dash, 3, 5, str.tostring(atrNow, format.mintick), text_color = color.white, text_size = dashSize)

    table.cell(dash, 0, 6, "Breakout", text_color = color.white, text_size = dashSize)
    table.cell(dash, 1, 6, breakUp ? "Upper" : breakDown ? "Lower" : "Inside", text_color = breakUp ? colorBull : breakDown ? colorBear : colorNeutral, text_size = dashSize)
    table.cell(dash, 2, 6, "Reclaim", text_color = color.white, text_size = dashSize)
    table.cell(dash, 3, 6, outerReclaimFromUpper or outerReclaimFromLower ? "Yes" : "No", text_color = outerReclaimFromUpper or outerReclaimFromLower ? colorExpansion : colorNeutral, text_size = dashSize)

    table.cell(dash, 0, 7, "Burst", text_color = color.white, text_size = dashSize)
    table.cell(dash, 1, 7, expansionBurst ? "Triggered" : "Idle", text_color = expansionBurst ? colorExpansion : colorNeutral, text_size = dashSize)
    table.cell(dash, 2, 7, "Close", text_color = color.white, text_size = dashSize)
    table.cell(dash, 3, 7, str.tostring(close, format.mintick), text_color = color.white, text_size = dashSize)

// =============================================================================
// ALERT CONDITIONS
// Non-repainting logic uses confirmed-bar event flags.
// =============================================================================
trendShiftUpEvent = enableTrendAlerts and trendShiftUp
trendShiftDownEvent = enableTrendAlerts and trendShiftDown
trendShiftNeutralEvent = enableTrendAlerts and trendShiftNeutral

regimeCompressionEvent = enableRegimeAlerts and regimeShiftToCompression
regimeExpansionEvent = enableRegimeAlerts and regimeShiftToExpansion
regimeBalancedEvent = enableRegimeAlerts and regimeShiftToBalanced

expansionBurstEvent = enableExpansionAlerts and expansionBurst
outerReclaimUpperEvent = enableExpansionAlerts and outerReclaimFromUpper
outerReclaimLowerEvent = enableExpansionAlerts and outerReclaimFromLower

alertcondition(trendShiftUpEvent, "Arbiter Trend Shift Bull", "Arbiter Channel shifted to bullish trend on a confirmed bar.")
alertcondition(trendShiftDownEvent, "Arbiter Trend Shift Bear", "Arbiter Channel shifted to bearish trend on a confirmed bar.")
alertcondition(trendShiftNeutralEvent, "Arbiter Trend Shift Neutral", "Arbiter Channel shifted to neutral trend on a confirmed bar.")

alertcondition(regimeCompressionEvent, "Arbiter Regime Compression", "Arbiter Channel entered compression regime on a confirmed bar.")
alertcondition(regimeExpansionEvent, "Arbiter Regime Expansion", "Arbiter Channel entered expansion regime on a confirmed bar.")
alertcondition(regimeBalancedEvent, "Arbiter Regime Balanced", "Arbiter Channel returned to balanced regime on a confirmed bar.")

alertcondition(expansionBurstEvent, "Arbiter Expansion Burst", "Arbiter Channel expansion burst detected on a confirmed bar.")
alertcondition(outerReclaimUpperEvent, "Arbiter Upper Reclaim", "Arbiter Channel reclaimed inside upper boundary after extension.")
alertcondition(outerReclaimLowerEvent, "Arbiter Lower Reclaim", "Arbiter Channel reclaimed inside lower boundary after extension.")

// =============================================================================
// INTERNAL EXPORT PLOTS (hidden diagnostics for optional alert placeholders)
// =============================================================================
plot(distanceNorm, "Distance Norm", color = na, display = display.none)
plot(float(trendState), "Trend State Numeric", color = na, display = display.none)
plot(float(regimeState), "Regime State Numeric", color = na, display = display.none)
````
