# Velorum Deviation Corridor [JOAT]

- url: https://www.tradingview.com/script/p4E1vcEg-Velorum-Deviation-Corridor-JOAT/
- type: indicator
- pine_id: PUB;d0bb876ca4b34f88a7c9cf50eae4ee49
- version: 1.0

## Description

[b]Velorum Deviation Corridor [JOAT][/b]

[b]Introduction[/b]

Velorum Deviation Corridor is an open-source adaptive price envelope designed to measure directional bias, stretch, and compression around a dynamic baseline. The script does not treat all volatility the same. It allows different baseline engines and different width engines, then converts that information into an overlay corridor that can show trend continuation, overextension, and volatility contraction in one place.

The problem this script solves is that static envelopes often fail when market speed changes. A fixed moving average with a fixed-width band may lag badly during acceleration and overreact during compression. Velorum addresses that by pairing adaptive baseline logic with multiple volatility models, then confirming state shifts only after bars close. The result is a directional overlay that can function as a trend frame, pullback map, and stretch monitor.

[image]https://www.tradingview.com/x/5qXkMgl4/[/image]

[b]Core Concepts[/b]

[b]1. Adaptive Baseline Selection[/b]

The script allows the user to choose among several baseline models: EMA, Hull, Adaptive KAMA, VIDYA, FRAMA, and Gaussian smoothing. This makes the corridor usable across different styles. Faster baselines react more quickly to rotation. More adaptive baselines try to react quickly in clean trends and slow down in noisy environments.

[b]2. Multi-Model Width Estimation[/b]

The width engine can use ATR, standard deviation, Parkinson volatility, efficiency range, or a hybrid model. This matters because volatility can be defined in different ways. ATR captures absolute travel, standard deviation captures dispersion, Parkinson emphasizes high-low structure, and the hybrid approach blends multiple aspects into one corridor width.

[pine]
widthModel = input.string("Hybrid Volatility", "Width Model",
     options = ["ATR", "Standard Deviation", "Parkinson", "Efficiency Range", "Hybrid Volatility"])
[/pine]

[b]3. Compression and Expansion Detection[/b]

The script tracks corridor width over a rolling lookback and compares it against a compression percentile. When width contracts into the lower part of its recent range, the script identifies a compression state. When width expands with directional slope and position agreement, the script identifies expansion. This helps distinguish quiet consolidation from meaningful travel.

[b]4. Trend State and Stretch Logic[/b]

Trend state is determined by baseline slope, price position relative to the corridor, and confirmation bars. The script also measures stretch so users can see whether price is trading inside the value area of the corridor, near the edge, or outside it. That makes it useful for both continuation logic and reversion-aware caution.

[b]5. Transition Ribbon, Reaction Shelves, and Drift Lanes[/b]

The overlay uses outer bands, inner bands, corridor fills, glow layers, and a narrow transition ribbon around the baseline. It also projects on-chart structure when important corridor events occur. Confirmed constructive and defensive shifts can create forward shelf boxes. Confirmed excursions outside the corridor can create upper and lower drift lanes. Compression and expansion transitions can also stamp temporary forward boxes directly on the chart, turning the corridor into a working structure map instead of only a band set.

[image][/image]

[b]Features[/b]

[list]
[*][b]Six baseline models:[/b] EMA, Hull, Adaptive KAMA, VIDYA, FRAMA, and Gaussian
[*][b]Five width engines:[/b] ATR, standard deviation, Parkinson, efficiency range, and hybrid volatility
[*][b]Compression detection:[/b] Width percentile model highlights contraction phases
[*][b]Trend confirmation bars:[/b] Direction changes require confirmation before they are treated as valid
[*][b]Stretch context:[/b] Shows whether price is centered, extended, or outside the corridor
[*][b]Layered overlay:[/b] Baseline, glow, inner bands, outer bands, fills, and transition ribbon
[*][b]Reaction shelves:[/b] Confirmed constructive and defensive shifts can project forward box zones on the chart
[*][b]Drift lanes:[/b] Confirmed closes outside the corridor can stamp directional lane boxes
[*][b]Compression shelf and expansion release:[/b] Corridor state transitions can create temporary forward structure boxes
[*][b]On-chart labels:[/b] Shelf, lane, and release labels appear directly on the price chart
[*][b]Compact dashboard summary:[/b] Trend state, regime, stretch, strength, and confirmed shift in a smaller top-right panel
[*][b]Confirmed-bar alerts:[/b] Lift, fade, compression, and expansion events
[/list]

[b]Input Parameters[/b]

[b]Core Engine:[/b]
[list]
[*]Source
[*]Baseline Model
[*]Baseline Length
[*]Fast and Slow Components for adaptive models
[/list]

[b]Trend State:[/b]
[list]
[*]Trend Confirmation Bars
[*]Slope Lookback
[*]Trend Strength Length
[*]Compression Lookback
[*]Compression Percentile
[/list]

[b]Width Model:[/b]
[list]
[*]Width Model
[*]Width Length
[*]Width Multiplier
[*]Elasticity Factor
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Identify the Baseline Bias[/b]
Start with price relative to the baseline and the dashboard's Trend State row. If price is holding above a rising baseline, the corridor is acting as bullish structure. If price is holding below a falling baseline, the corridor is acting as bearish structure.

[b]Step 2: Check Compression Before Breakouts[/b]
Compression phases are useful because directional expansions often begin after width contracts. If the chart is tinted for compression and width percentile is low, watch for a confirmed shift rather than treating every small move as a new trend.

[b]Step 3: Use Inner vs Outer Bands Differently[/b]
The inner bands are the working area for pullbacks and value. The outer bands represent more extended travel. When price repeatedly walks an outer band, that is continuation behavior. When price snaps outside and immediately loses follow-through, that is often stretch rather than sustainable expansion.

[b]Step 4: Use Reaction Shelves and Drift Lanes as Forward Reference[/b]
When a confirmed constructive or defensive shift occurs, Velorum can project a forward shelf box. When price closes beyond the outer corridor, it can print a drift lane. These structures are intended to mark the part of the chart where continuation behavior should stay organized. If price immediately loses those zones, the move is weakening.

[b]Step 5: Treat Confirmed Shift as the State Change[/b]
The confirmed shift output is still the important regime event. Intrabar movement can test both sides of the corridor, but the script only promotes a new state after bar confirmation and only stamps new corridor structures after confirmation.

[b]Indicator Limitations[/b]

[list]
[*]No single baseline model is best for every market; users may need to select a model appropriate for their instrument and timeframe
[*]Compression does not guarantee breakout direction, only reduced width
[*]A fast corridor can overreact in noisy markets while a slow corridor can lag during sharp reversals
[*]Stretch beyond the outer band can persist longer than expected in strong trends
[*]Reaction shelves and drift lanes are contextual structure tools, not guaranteed support or resistance
[/list]

[b]Originality Statement[/b]

Velorum Deviation Corridor is original in the way it separates the baseline problem from the width problem and lets those two adaptive layers interact in one confirmed-state overlay. The script is not simply a renamed moving average envelope. It combines multiple smoothing families, multiple volatility families, width percentile compression logic, stretch-state interpretation, transition-ribbon state framing, and event-driven forward shelf and lane boxes into one cohesive corridor framework.

[b]Disclaimer[/b]

This script is provided for educational and informational purposes only. It is not financial advice. Corridor behavior is based on historical price action and can lag, compress, or expand unpredictably during unusual market conditions. Always evaluate signals in context and use appropriate risk controls.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Velorum Deviation Corridor [JOAT]", shorttitle="Velorum Corridor [JOAT]", overlay=true, max_bars_back=5000, max_lines_count=100, max_labels_count=50, max_boxes_count=30)

//------------------------------------------------------------------------------
// Input groups
//------------------------------------------------------------------------------
string grpCore = "Core Engine"
string grpTrend = "Trend State"
string grpWidth = "Width Model"
string grpVisual = "Visual System"
string grpDash = "Dashboard"
string grpLevels = "Context Bands"

//------------------------------------------------------------------------------
// Core inputs
//------------------------------------------------------------------------------
src = input.source(close, "Source", group=grpCore)
basisModel = input.string("Adaptive KAMA", "Baseline Model", options=["EMA", "Hull", "Adaptive KAMA", "VIDYA", "FRAMA", "Gaussian"], group=grpCore)
basisLength = input.int(55, "Baseline Length", minval=5, maxval=300, group=grpCore)
fastLength = input.int(4, "Fast Component", minval=1, maxval=50, group=grpCore)
slowLength = input.int(34, "Slow Component", minval=5, maxval=100, group=grpCore)

//------------------------------------------------------------------------------
// Trend state inputs
//------------------------------------------------------------------------------
trendConfirmBars = input.int(2, "Trend Confirmation Bars", minval=1, maxval=10, group=grpTrend)
slopeLength = input.int(5, "Slope Lookback", minval=1, maxval=20, group=grpTrend)
trendStrengthLength = input.int(34, "Trend Strength Length", minval=5, maxval=150, group=grpTrend)
compressionLookback = input.int(120, "Compression Lookback", minval=20, maxval=300, group=grpTrend)
compressionPercentile = input.float(20.0, "Compression Percentile", minval=5.0, maxval=40.0, step=1.0, group=grpTrend)

//------------------------------------------------------------------------------
// Width inputs
//------------------------------------------------------------------------------
widthModel = input.string("Hybrid Volatility", "Width Model", options=["ATR", "Standard Deviation", "Parkinson", "Efficiency Range", "Hybrid Volatility"], group=grpWidth)
widthLength = input.int(34, "Width Length", minval=5, maxval=200, group=grpWidth)
widthMultiplier = input.float(2.2, "Width Multiplier", minval=0.2, maxval=8.0, step=0.1, group=grpWidth)
elasticityFactor = input.float(0.35, "Elasticity Factor", minval=0.0, maxval=1.0, step=0.05, group=grpWidth)

//------------------------------------------------------------------------------
// Context inputs
//------------------------------------------------------------------------------
showInnerBands = input.bool(true, "Show Inner Bands", group=grpLevels)
showOuterBands = input.bool(true, "Show Outer Bands", group=grpLevels)
showContextFill = input.bool(true, "Show Corridor Fill", group=grpLevels)
showCompressionTint = input.bool(true, "Show Compression Tint", group=grpLevels)
showStateTint = input.bool(false, "Tint Bars By State", group=grpLevels)

//------------------------------------------------------------------------------
// Visual inputs
//------------------------------------------------------------------------------
showBasis = input.bool(true, "Show Baseline", group=grpVisual)
showGlow = input.bool(true, "Show Glow Layer", group=grpVisual)
showTransitionRibbon = input.bool(true, "Show Transition Ribbon", group=grpVisual)
themeMode = input.string("Midnight Copper", "Theme", options=["Midnight Copper", "Harbor Slate", "Quartz Ember"], group=grpVisual)
showReactionZones = input.bool(true, "Show Reaction Zones", group=grpVisual)
showShiftLabels = input.bool(true, "Show Shift Labels", group=grpVisual)
showCompressionShelf = input.bool(true, "Show Compression Shelf", group=grpVisual)

//------------------------------------------------------------------------------
// Dashboard inputs
//------------------------------------------------------------------------------
showDashboard = input.bool(true, "Show Dashboard", group=grpDash)
dashboardPosition = input.string("Top Right", "Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpDash)
dashboardSize = input.string("Medium", "Size", options=["Small", "Medium", "Large"], group=grpDash)

//------------------------------------------------------------------------------
// Theme colors
//------------------------------------------------------------------------------
var color bullCore = color.new(#29c78d, 0)
var color bearCore = color.new(#d36a5f, 0)
var color neutralCore = color.new(#9aa4b2, 0)
var color accentCore = color.new(#d2a86b, 0)
var color panelBg = color.new(#0d1219, 0)
var color panelBgSoft = color.new(#131b24, 0)
var color panelBorder = color.new(#273240, 0)
var color textMain = color.new(#e7edf4, 0)
var color textDim = color.new(#90a0b3, 0)

if barstate.isfirst
    if themeMode == "Midnight Copper"
        bullCore := color.new(#2bc48a, 0)
        bearCore := color.new(#cc6d61, 0)
        neutralCore := color.new(#93a0ad, 0)
        accentCore := color.new(#d8a46f, 0)
        panelBg := color.new(#0d1219, 0)
        panelBgSoft := color.new(#141b24, 0)
        panelBorder := color.new(#2a3544, 0)
    else if themeMode == "Harbor Slate"
        bullCore := color.new(#4db5a3, 0)
        bearCore := color.new(#c66e73, 0)
        neutralCore := color.new(#9aa7b7, 0)
        accentCore := color.new(#85a8d0, 0)
        panelBg := color.new(#10151d, 0)
        panelBgSoft := color.new(#171f29, 0)
        panelBorder := color.new(#2f3c4b, 0)
    else
        bullCore := color.new(#6cc28d, 0)
        bearCore := color.new(#e07f62, 0)
        neutralCore := color.new(#a1abb6, 0)
        accentCore := color.new(#d9ba73, 0)
        panelBg := color.new(#151216, 0)
        panelBgSoft := color.new(#1d1820, 0)
        panelBorder := color.new(#3a2d35, 0)

//------------------------------------------------------------------------------
// Helper functions
//------------------------------------------------------------------------------
f_safe_div(float num, float den, float fallback) =>
    math.abs(den) > 1e-10 ? num / den : fallback

f_clamp(float v, float lo, float hi) =>
    math.max(lo, math.min(hi, v))

f_sum_abs_delta(float seriesValue, int len) =>
    float total = 0.0
    for i = 0 to len - 1
        total += math.abs(seriesValue[i] - nz(seriesValue[i + 1], seriesValue[i]))
    total

f_trim_boxes(array<box> bxArray, int maxCount) =>
    while array.size(bxArray) > maxCount
        oldBox = array.shift(bxArray)
        box.delete(oldBox)

f_trim_labels(array<label> lbArray, int maxCount) =>
    while array.size(lbArray) > maxCount
        oldLabel = array.shift(lbArray)
        label.delete(oldLabel)

f_hull(float seriesValue, int len) =>
    halfLen = math.max(1, int(math.round(len * 0.5)))
    sqrtLen = math.max(1, int(math.round(math.sqrt(len))))
    ta.wma(2.0 * ta.wma(seriesValue, halfLen) - ta.wma(seriesValue, len), sqrtLen)

f_kama(float seriesValue, int len, int fastLen, int slowLen) =>
    fastAlpha = 2.0 / (fastLen + 1.0)
    slowAlpha = 2.0 / (slowLen + 1.0)
    directional = math.abs(seriesValue - nz(seriesValue[len], seriesValue))
    volatility = f_sum_abs_delta(seriesValue, len)
    er = f_safe_div(directional, volatility, 0.0)
    sc = math.pow(er * (fastAlpha - slowAlpha) + slowAlpha, 2)
    var float kamaState = na
    kamaState := na(kamaState[1]) ? seriesValue : nz(kamaState[1]) + sc * (seriesValue - nz(kamaState[1]))
    kamaState

f_vidya(float seriesValue, int len) =>
    alpha = 2.0 / (len + 1.0)
    cmo = math.abs(ta.cmo(seriesValue, len)) / 100.0
    var float vidyaState = na
    vidyaState := na(vidyaState[1]) ? seriesValue : alpha * cmo * seriesValue + (1.0 - alpha * cmo) * nz(vidyaState[1])
    vidyaState

f_frama(float seriesValue, int len) =>
    halfLen = math.max(1, int(math.floor(len * 0.5)))
    n1 = f_safe_div(ta.highest(high, halfLen) - ta.lowest(low, halfLen), halfLen, 0.0)
    n2 = f_safe_div(ta.highest(high[halfLen], halfLen) - ta.lowest(low[halfLen], halfLen), halfLen, 0.0)
    n3 = f_safe_div(ta.highest(high, len) - ta.lowest(low, len), len, 0.0)
    dim = n3 > 0 and n1 + n2 > 0 ? (math.log(n1 + n2) - math.log(n3)) / math.log(2) : 1.5
    alpha = f_clamp(math.exp(-4.6 * (dim - 1.0)), 0.01, 1.0)
    var float framaState = na
    framaState := na(framaState[1]) ? seriesValue : alpha * seriesValue + (1.0 - alpha) * nz(framaState[1])
    framaState

f_gaussian(float seriesValue, int len) =>
    beta = 2.415 * (1.0 - math.cos(2.0 * math.pi / len)) / (1.0 + math.cos(2.0 * math.pi / len))
    alpha = -beta + math.sqrt(beta * beta + 2.0 * beta)
    var float gaussianState = na
    gaussianState := na(gaussianState[1]) ? seriesValue : alpha * seriesValue + (1.0 - alpha) * nz(gaussianState[1])
    gaussianState

f_basis(float seriesValue, string mode, int len) =>
    if mode == "EMA"
        ta.ema(seriesValue, len)
    else if mode == "Hull"
        f_hull(seriesValue, len)
    else if mode == "Adaptive KAMA"
        f_kama(seriesValue, len, fastLength, slowLength)
    else if mode == "VIDYA"
        f_vidya(seriesValue, len)
    else if mode == "FRAMA"
        f_frama(seriesValue, len)
    else
        f_gaussian(seriesValue, len)

f_parkinson(int len) =>
    sumLog = 0.0
    for i = 0 to len - 1
        hiLo = math.log(math.max(high[i], syminfo.mintick) / math.max(low[i], syminfo.mintick))
        sumLog += hiLo * hiLo
    math.sqrt(f_safe_div(sumLog, 4.0 * len * math.log(2.0), 0.0)) * close

f_efficiency_width(float seriesValue, int len) =>
    directional = math.abs(seriesValue - nz(seriesValue[len], seriesValue))
    path = f_sum_abs_delta(seriesValue, len)
    ratio = f_safe_div(directional, path, 0.0)
    rangeCore = ta.highest(high, len) - ta.lowest(low, len)
    rangeCore * (1.0 - ratio)

f_width(float seriesValue, float basisValue, string mode, int len) =>
    stDevWidth = ta.stdev(seriesValue, len)
    atrWidth = ta.atr(len)
    parkWidth = f_parkinson(len)
    efficiencyWidth = f_efficiency_width(seriesValue, len)
    if mode == "ATR"
        atrWidth
    else if mode == "Standard Deviation"
        stDevWidth
    else if mode == "Parkinson"
        parkWidth
    else if mode == "Efficiency Range"
        efficiencyWidth
    else
        0.45 * atrWidth + 0.35 * stDevWidth + 0.20 * efficiencyWidth

f_position_text(float pct) =>
    pct > 1.0 ? "Exterior High" : pct < 0.0 ? "Exterior Low" : pct > 0.75 ? "Upper Interior" : pct < 0.25 ? "Lower Interior" : "Core Interior"

f_table_pos(string positionInput) =>
    if positionInput == "Top Right"
        position.top_right
    else if positionInput == "Top Left"
        position.top_left
    else if positionInput == "Bottom Right"
        position.bottom_right
    else
        position.bottom_left

f_table_size(string sizeInput) =>
    if sizeInput == "Small"
        size.small
    else if sizeInput == "Large"
        size.large
    else
        size.normal

//------------------------------------------------------------------------------
// Core calculations
//------------------------------------------------------------------------------
basis = f_basis(src, basisModel, basisLength)
rawWidth = f_width(src, basis, widthModel, widthLength)

basisSlope = basis - nz(basis[slopeLength], basis)
atrBaseline = ta.atr(14)
stretchBase = rawWidth * widthMultiplier
elasticity = f_safe_div(math.abs(src - basis), nz(rawWidth, syminfo.mintick), 0.0)
elasticWidth = stretchBase * (1.0 - elasticityFactor) + stretchBase * elasticity * elasticityFactor
corridorWidth = math.max(syminfo.mintick, elasticWidth)

upperOuter = basis + corridorWidth
lowerOuter = basis - corridorWidth
upperInner = basis + corridorWidth * 0.5
lowerInner = basis - corridorWidth * 0.5

positionPct = f_safe_div(src - lowerOuter, upperOuter - lowerOuter, 0.5)
trendStrengthRaw = math.abs(basisSlope) / math.max(atrBaseline, syminfo.mintick)
trendStrength = ta.ema(trendStrengthRaw, trendStrengthLength)

widthPct = f_safe_div(corridorWidth, math.max(math.abs(basis), syminfo.mintick), 0.0) * 100.0
compressionThreshold = ta.percentile_linear_interpolation(widthPct, compressionLookback, compressionPercentile)
expansionThreshold = ta.percentile_linear_interpolation(widthPct, compressionLookback, 100.0 - compressionPercentile)
isCompression = widthPct <= compressionThreshold
isExpansion = widthPct >= expansionThreshold

longBiasRaw = src > basis and basisSlope > 0
shortBiasRaw = src < basis and basisSlope < 0
longBiasConfirmed = ta.lowest(longBiasRaw ? 1 : 0, trendConfirmBars) == 1
shortBiasConfirmed = ta.lowest(shortBiasRaw ? 1 : 0, trendConfirmBars) == 1

trendState = longBiasConfirmed ? 1 : shortBiasConfirmed ? -1 : 0
statePulse = trendState == 1 ? bullCore : trendState == -1 ? bearCore : neutralCore
stretchState = positionPct > 1.0 ? 2 : positionPct > 0.75 ? 1 : positionPct < 0.0 ? -2 : positionPct < 0.25 ? -1 : 0

regimeText = isCompression ? "Compressed" : isExpansion ? "Expanded" : "Balanced"
trendText = trendState == 1 ? "Constructive" : trendState == -1 ? "Defensive" : "Neutral"
positionText = f_position_text(positionPct)

confirmedShiftUp = barstate.isconfirmed and trendState == 1 and nz(trendState[1]) != 1
confirmedShiftDown = barstate.isconfirmed and trendState == -1 and nz(trendState[1]) != -1
compressionStart = barstate.isconfirmed and isCompression and not isCompression[1]
expansionStart = barstate.isconfirmed and isExpansion and not isExpansion[1]
confirmedUpperDrift = barstate.isconfirmed and close > upperOuter
confirmedLowerDrift = barstate.isconfirmed and close < lowerOuter

//------------------------------------------------------------------------------
// Visual colors
//------------------------------------------------------------------------------
outerColor = trendState == 1 ? bullCore : trendState == -1 ? bearCore : neutralCore
innerColor = trendState == 1 ? color.new(bullCore, 15) : trendState == -1 ? color.new(bearCore, 15) : color.new(neutralCore, 10)
basisColor = trendState == 1 ? color.new(accentCore, 0) : trendState == -1 ? color.new(accentCore, 10) : color.new(neutralCore, 0)
fillColorOuter = trendState == 1 ? color.new(bullCore, 88) : trendState == -1 ? color.new(bearCore, 88) : color.new(neutralCore, 92)
fillColorInner = trendState == 1 ? color.new(bullCore, 80) : trendState == -1 ? color.new(bearCore, 80) : color.new(neutralCore, 88)
compressionColor = color.new(accentCore, 90)

var array<box> corridorZones = array.new<box>()
var array<label> corridorLabels = array.new<label>()

if showReactionZones and confirmedShiftUp
    shiftZone = box.new(bar_index - 1, upperInner + corridorWidth * 0.12, bar_index + 12, basis - corridorWidth * 0.12, xloc=xloc.bar_index, border_color=color.new(bullCore, 28), bgcolor=color.new(bullCore, 90), border_width=2, force_overlay=true)
    array.push(corridorZones, shiftZone)
    if showShiftLabels
        array.push(corridorLabels, label.new(bar_index + 13, upperInner, "Constructive Shelf", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(bullCore, 10), textcolor=textMain, size=size.small, force_overlay=true))

if showReactionZones and confirmedShiftDown
    fadeZone = box.new(bar_index - 1, basis + corridorWidth * 0.12, bar_index + 12, lowerInner - corridorWidth * 0.12, xloc=xloc.bar_index, border_color=color.new(bearCore, 28), bgcolor=color.new(bearCore, 90), border_width=2, force_overlay=true)
    array.push(corridorZones, fadeZone)
    if showShiftLabels
        array.push(corridorLabels, label.new(bar_index + 13, lowerInner, "Defensive Shelf", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(bearCore, 10), textcolor=textMain, size=size.small, force_overlay=true))

if showReactionZones and confirmedUpperDrift
    upperLane = box.new(bar_index - 1, upperOuter + corridorWidth * 0.18, bar_index + 10, upperInner, xloc=xloc.bar_index, border_color=color.new(accentCore, 35), bgcolor=color.new(accentCore, 92), border_width=1, force_overlay=true)
    array.push(corridorZones, upperLane)
    if showShiftLabels
        array.push(corridorLabels, label.new(bar_index + 11, upperOuter + corridorWidth * 0.1, "Upper Drift Lane", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(accentCore, 12), textcolor=textMain, size=size.tiny, force_overlay=true))

if showReactionZones and confirmedLowerDrift
    lowerLane = box.new(bar_index - 1, lowerInner, bar_index + 10, lowerOuter - corridorWidth * 0.18, xloc=xloc.bar_index, border_color=color.new(accentCore, 35), bgcolor=color.new(accentCore, 92), border_width=1, force_overlay=true)
    array.push(corridorZones, lowerLane)
    if showShiftLabels
        array.push(corridorLabels, label.new(bar_index + 11, lowerOuter - corridorWidth * 0.1, "Lower Drift Lane", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(accentCore, 12), textcolor=textMain, size=size.tiny, force_overlay=true))

if showCompressionShelf and compressionStart
    compressionZone = box.new(bar_index - 1, upperInner, bar_index + 8, lowerInner, xloc=xloc.bar_index, border_color=color.new(accentCore, 45), bgcolor=color.new(accentCore, 92), border_width=1, force_overlay=true)
    array.push(corridorZones, compressionZone)
    if showShiftLabels
        array.push(corridorLabels, label.new(bar_index + 9, basis, "Compression Shelf", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(accentCore, 15), textcolor=textMain, size=size.tiny, force_overlay=true))

if showReactionZones and expansionStart
    expansionZone = box.new(bar_index - 1, upperOuter, bar_index + 8, lowerOuter, xloc=xloc.bar_index, border_color=color.new(statePulse, 55), bgcolor=color.new(statePulse, 94), border_width=1, force_overlay=true)
    array.push(corridorZones, expansionZone)
    if showShiftLabels
        array.push(corridorLabels, label.new(bar_index + 9, basis, "Expansion Release", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(statePulse, 10), textcolor=textMain, size=size.tiny, force_overlay=true))

f_trim_boxes(corridorZones, 10)
f_trim_labels(corridorLabels, 10)

//------------------------------------------------------------------------------
// Plot layer
//------------------------------------------------------------------------------
pBasis = plot(showBasis ? basis : na, "Baseline", basisColor, 2)
pBasisGlow = plot(showGlow ? basis : na, "Baseline Glow", color.new(basisColor, 70), 5)

pUpperOuter = plot(showOuterBands ? upperOuter : na, "Upper Outer", outerColor, 2)
pLowerOuter = plot(showOuterBands ? lowerOuter : na, "Lower Outer", outerColor, 2)
pUpperInner = plot(showInnerBands ? upperInner : na, "Upper Inner", innerColor, 1)
pLowerInner = plot(showInnerBands ? lowerInner : na, "Lower Inner", innerColor, 1)

fill(pUpperOuter, pLowerOuter, showContextFill ? fillColorOuter : na)
fill(pUpperInner, pLowerInner, showContextFill ? fillColorInner : na)

transitionTop = plot(showTransitionRibbon ? basis + corridorWidth * 0.16 : na, "Transition Top", color.new(statePulse, 100), 1)
transitionBottom = plot(showTransitionRibbon ? basis - corridorWidth * 0.16 : na, "Transition Bottom", color.new(statePulse, 100), 1)
fill(transitionTop, transitionBottom, showTransitionRibbon ? color.new(statePulse, 86) : na)

bgcolor(showCompressionTint and isCompression ? compressionColor : na, title="Compression State")
barcolor(showStateTint ? color.new(statePulse, 78) : na)

//------------------------------------------------------------------------------
// Context levels
//------------------------------------------------------------------------------
plot(confirmedUpperDrift ? upperOuter : na, "Upper Drift Tag", color.new(bearCore, 0), 2, plot.style_circles)
plot(confirmedLowerDrift ? lowerOuter : na, "Lower Drift Tag", color.new(bullCore, 0), 2, plot.style_circles)

//------------------------------------------------------------------------------
// Dashboard
//------------------------------------------------------------------------------
var table dash = table.new(position.top_right, 2, 6, bgcolor=color.new(panelBg, 0), border_width=1, border_color=color.new(panelBorder, 0), frame_width=1, frame_color=color.new(panelBorder, 30))

if showDashboard and barstate.islast
    table.clear(dash, 0, 0, 1, 5)
    dashSize = size.normal
    strengthText = trendStrength > 0.9 ? "High" : trendStrength > 0.45 ? "Moderate" : "Low"
    stretchText = stretchState >= 2 ? "Upper Extreme" : stretchState == 1 ? "Upper Pressure" : stretchState <= -2 ? "Lower Extreme" : stretchState == -1 ? "Lower Pressure" : "Centered"
    trendColor = trendState == 1 ? bullCore : trendState == -1 ? bearCore : neutralCore
    regimeColor = isCompression ? accentCore : isExpansion ? trendColor : neutralCore
    shiftText = confirmedShiftUp ? "Confirmed Lift" : confirmedShiftDown ? "Confirmed Fade" : "Stable"
    shiftColor = confirmedShiftUp ? bullCore : confirmedShiftDown ? bearCore : neutralCore

    table.cell(dash, 0, 0, "Corridor Summary", text_color=textMain, text_size=dashSize, bgcolor=color.new(panelBgSoft, 0), text_halign=text.align_left)
    table.cell(dash, 1, 0, timeframe.period, text_color=accentCore, text_size=size.small, bgcolor=color.new(panelBgSoft, 0), text_halign=text.align_right)
    table.cell(dash, 0, 1, "Trend State", text_color=textDim, text_size=dashSize, bgcolor=panelBg)
    table.cell(dash, 1, 1, trendText, text_color=trendColor, text_size=dashSize, bgcolor=panelBg, text_halign=text.align_right)
    table.cell(dash, 0, 2, "Regime", text_color=textDim, text_size=dashSize, bgcolor=panelBg)
    table.cell(dash, 1, 2, regimeText, text_color=regimeColor, text_size=dashSize, bgcolor=panelBg, text_halign=text.align_right)
    table.cell(dash, 0, 3, "Stretch", text_color=textDim, text_size=dashSize, bgcolor=panelBg)
    table.cell(dash, 1, 3, stretchText, text_color=trendColor, text_size=dashSize, bgcolor=panelBg, text_halign=text.align_right)
    table.cell(dash, 0, 4, "Strength", text_color=textDim, text_size=dashSize, bgcolor=panelBg)
    table.cell(dash, 1, 4, strengthText, text_color=trendColor, text_size=dashSize, bgcolor=panelBg, text_halign=text.align_right)
    table.cell(dash, 0, 5, "Shift", text_color=textDim, text_size=dashSize, bgcolor=panelBg)
    table.cell(dash, 1, 5, shiftText, text_color=shiftColor, text_size=dashSize, bgcolor=panelBg, text_halign=text.align_right)

//------------------------------------------------------------------------------
// Alert conditions
//------------------------------------------------------------------------------
alertcondition(confirmedShiftUp, "Velorum Confirmed Lift", "Velorum corridor confirmed a constructive shift.")
alertcondition(confirmedShiftDown, "Velorum Confirmed Fade", "Velorum corridor confirmed a defensive shift.")
alertcondition(compressionStart, "Velorum Compression", "Velorum corridor entered compression.")
alertcondition(expansionStart, "Velorum Expansion", "Velorum corridor entered expansion.")
````
