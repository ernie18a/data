# Cartograph Bands [JOAT]

- url: https://www.tradingview.com/script/To56mBmH-Cartograph-Bands-JOAT/
- type: indicator
- pine_id: PUB;a57d22f33a9c4ce68c6b210ddf15a2f3
- version: 1.0

## Description

[b]Cartograph Bands [JOAT][/b]

[b]Introduction[/b]

Cartograph Bands is an open-source price-space mapping overlay that translates internal momentum and regime pressure into adaptive bands around price. Instead of displaying momentum in a separate pane and forcing the user to mentally translate it back into price context, the script projects a composite regime score directly into layered price envelopes.

The problem Cartograph Bands solves is disconnected interpretation. Oscillators can show strength or weakness, but they often fail to communicate where that state matters on the chart. Cartograph Bands closes that gap by converting internal regime intensity into inner, outer, and far price-space bands, then combining that with multi-timeframe confirmation and volatility-state transitions.

[image]https://www.tradingview.com/x/uStUKcXs/[/image]

[b]Core Concepts[/b]

[b]1. Composite Momentum Engine[/b]

The script blends several internal measurements including RSI, CMO, ROC normalization, and slope behavior to create a bounded momentum/regime score. This reduces reliance on any single oscillator.

[b]2. Price-Space Mapping[/b]

That composite score is mapped into adaptive offsets around price using ATR and standard deviation inputs. The result is a set of bands that express regime intensity as chart structure rather than as a separate panel line.

[b]3. Layered Band Geometry[/b]

Three band families are used:

[list]
[*]Inner bands for local equilibrium
[*]Outer bands for state extension
[*]Far bands for exceptional displacement
[/list]

[b]4. Non-Repainting Higher Timeframe Confirmation[/b]

Confirmed higher-timeframe values are requested using offset expressions and lookahead handling intended to avoid future leakage on historical bars.

[b]5. Compression and Expansion State Tracking[/b]

Cartograph Bands also classifies whether the current market state is compressing or expanding, which gives context to outer-band tests and re-entry events.

[b]Features[/b]

[list]
[*][b]Composite momentum model:[/b] Multiple internal regime factors instead of one oscillator
[*][b]Mapped price-space bands:[/b] Regime intensity projected directly onto chart structure
[*][b]Inner, outer, and far layers:[/b] Different depths of price displacement
[*][b]MTF confirmation dashboard:[/b] Top-right summary with higher-timeframe agreement context
[*][b]Compression and expansion tracking:[/b] Identifies volatility-state transitions
[*][b]Outer-band re-entry events:[/b] Useful for exhaustion or reacquisition studies
[*][b]State candle tinting:[/b] Visual context without heavy marker clutter
[*][b]Gradient cloud system:[/b] Layered institutional-style fills
[*][b]Confirmed-signal mode:[/b] Optional bar-close confirmation behavior
[*][b]Alertconditions:[/b] Regime flips, re-entry, expansion, compression, and MTF conflict
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the Band State[/b]
Price inside the inner structure implies local balance. Sustained travel into outer and far layers implies stronger directional pressure.

[b]Step 2: Check the Dashboard[/b]
Use the dashboard to confirm whether the chart-timeframe state aligns with higher-timeframe conditions.

[b]Step 3: Watch Re-entry Behavior[/b]
Re-entry from outside the outer band can highlight exhaustion or failed extension, especially when expansion begins to fade.

[b]Step 4: Use Compression and Expansion as Context[/b]
A compression state reduces the importance of directional interpretation. Expansion after compression matters more than random outer-band wandering.

[b]Indicator Limitations[/b]

[list]
[*]The mapping is adaptive, so band distance changes with symbol volatility
[*]Higher-timeframe context is intentionally confirmed and may feel slower than live-developing HTF tools
[*]Band interaction alone should not be treated as a complete trade system
[*]The script maps internal regime state into price context, but it does not forecast exact reversal points
[/list]

[b]Originality Statement[/b]

Cartograph Bands is original in the way it blends multiple internal regime measurements and projects them into layered price-space geometry. Its value is not just an oscillator or just bands, but the interaction between regime scoring, mapped offsets, MTF confirmation, and state transitions.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. All mapped bands are analytical references derived from historical price behavior and should be used with sound judgment and risk management.

- Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Cartograph Bands [JOAT]", shorttitle = "CTB [JOAT]", overlay = true, max_labels_count = 200, max_lines_count = 200)
//------------------------------------------------------------------------------
// Input Groups
//------------------------------------------------------------------------------
groupEngine = "Engine"
groupMapping = "Mapping"
groupState = "State"
groupMTF = "MTF Confirmation"
groupVisual = "Visual"
groupDashboard = "Dashboard"
groupLabels = "Labels"
groupAlerts = "Alerts"

//------------------------------------------------------------------------------
// Engine Inputs
//------------------------------------------------------------------------------
rsiLength = input.int(14, "RSI Length", minval = 2, group = groupEngine)
cmoLength = input.int(21, "CMO Length", minval = 2, group = groupEngine)
rocLength = input.int(8, "ROC Length", minval = 1, group = groupEngine)
slopeLength = input.int(34, "Slope Length", minval = 2, group = groupEngine)

smoothMomentum = input.int(8, "Momentum Smoothing", minval = 1, group = groupEngine)
smoothRegime = input.int(21, "Regime Smoothing", minval = 1, group = groupEngine)
basisLength = input.int(34, "Price Basis Length", minval = 2, group = groupEngine)

//------------------------------------------------------------------------------
// Mapping Inputs
//------------------------------------------------------------------------------
atrLength = input.int(14, "ATR Length", minval = 1, group = groupMapping)
stdevLength = input.int(55, "Stdev Length", minval = 5, group = groupMapping)

mapBase = input.float(0.90, "Mapping Base Multiplier", minval = 0.1, step = 0.05, group = groupMapping)
mapAmp = input.float(0.60, "Momentum Expansion Weight", minval = 0.0, step = 0.05, group = groupMapping)
mapRegimeBoost = input.float(0.35, "Regime Expansion Weight", minval = 0.0, step = 0.05, group = groupMapping)
mapClip = input.float(2.0, "Center Shift Multiplier", minval = 0.2, step = 0.1, group = groupMapping)

innerMult = input.float(0.90, "Inner Band Multiplier", minval = 0.2, step = 0.05, group = groupMapping)
outerMult = input.float(1.60, "Outer Band Multiplier", minval = 0.4, step = 0.05, group = groupMapping)
farMult = input.float(2.40, "Far Band Multiplier", minval = 0.8, step = 0.1, group = groupMapping)

//------------------------------------------------------------------------------
// State Inputs
//------------------------------------------------------------------------------
bullThreshold = input.float(0.20, "Bull Regime Threshold", minval = 0.0, maxval = 1.0, step = 0.01, group = groupState)
bearThreshold = input.float(-0.20, "Bear Regime Threshold", minval = -1.0, maxval = 0.0, step = 0.01, group = groupState)

widthLookback = input.int(120, "Band Width Lookback", minval = 20, group = groupState)
compressionThreshold = input.float(-0.70, "Compression Z-Threshold", step = 0.05, group = groupState)
expansionThreshold = input.float(0.80, "Expansion Z-Threshold", step = 0.05, group = groupState)

//------------------------------------------------------------------------------
// MTF Inputs
//------------------------------------------------------------------------------
useMtf = input.bool(true, "Enable MTF Confirmation", group = groupMTF)
tfFast = input.timeframe("60", "Fast HTF", group = groupMTF)
tfMid = input.timeframe("240", "Mid HTF", group = groupMTF)
tfSlow = input.timeframe("D", "Slow HTF", group = groupMTF)

//------------------------------------------------------------------------------
// Visual Inputs
//------------------------------------------------------------------------------
showInner = input.bool(true, "Show Inner Bands", group = groupVisual)
showOuter = input.bool(true, "Show Outer Bands", group = groupVisual)
showFar = input.bool(true, "Show Far Bands", group = groupVisual)
showCloud = input.bool(true, "Show Band Cloud", group = groupVisual)
showBarTint = input.bool(true, "Enable Candle Tint", group = groupVisual)
showBackdrop = input.bool(true, "Enable State Backdrop", group = groupVisual)

lineWidthCenter = input.int(2, "Center Line Width", minval = 1, maxval = 5, group = groupVisual)
lineWidthBands = input.int(1, "Band Line Width", minval = 1, maxval = 4, group = groupVisual)
lineWidthGlow = input.int(4, "Glow Width", minval = 2, maxval = 12, group = groupVisual)

colorBull = input.color(color.rgb(38, 166, 154), "Bull Primary Color", group = groupVisual)
colorBear = input.color(color.rgb(239, 83, 80), "Bear Primary Color", group = groupVisual)
colorNeutral = input.color(color.rgb(129, 140, 151), "Neutral Color", group = groupVisual)
colorCompression = input.color(color.rgb(120, 144, 156), "Compression Color", group = groupVisual)
colorExpansion = input.color(color.rgb(255, 167, 38), "Expansion Color", group = groupVisual)

//------------------------------------------------------------------------------
// Dashboard Inputs
//------------------------------------------------------------------------------
showDashboard = input.bool(true, "Show Dashboard", group = groupDashboard)
dashText = input.color(color.rgb(236, 239, 241), "Text Color", group = groupDashboard)
dashFrame = input.color(color.rgb(63, 73, 84), "Frame Color", group = groupDashboard)
dashBg = input.color(color.new(color.rgb(15, 23, 30), 18), "Background Color", group = groupDashboard)

//------------------------------------------------------------------------------
// Label Inputs
//------------------------------------------------------------------------------
showRegimeLabels = input.bool(false, "Show Regime Labels", group = groupLabels)
minLabelSpacing = input.int(24, "Min Bars Between Labels", minval = 1, group = groupLabels)

//------------------------------------------------------------------------------
// Alert Inputs
//------------------------------------------------------------------------------
confirmSignals = input.bool(true, "Alerts On Confirmed Bars Only", group = groupAlerts)

//------------------------------------------------------------------------------
// Utility Functions
//------------------------------------------------------------------------------
f_clamp(float value, float floorValue, float ceilValue) =>
    math.max(floorValue, math.min(ceilValue, value))

f_safe_div(float num, float den) =>
    den == 0.0 ? 0.0 : num / den

f_state_from_score(float score, float bullLevel, float bearLevel) =>
    score > bullLevel ? 1 : score < bearLevel ? -1 : 0

f_state_text(int state) =>
    state == 1 ? "Bull" : state == -1 ? "Bear" : "Neutral"

f_state_color(int state, color bullColor, color bearColor, color neutralColor) =>
    state == 1 ? bullColor : state == -1 ? bearColor : neutralColor

f_signed_gradient(float score, color negColor, color midColor, color posColor) =>
    score >= 0 ? color.from_gradient(score, 0.0, 1.0, midColor, posColor) : color.from_gradient(score, -1.0, 0.0, negColor, midColor)

// Confirmed higher-timeframe value helper.
// This pattern uses lookahead_on + [1] so the script reads only confirmed HTF bars.
f_htf_confirmed(string tf, series float src) =>
    request.security(syminfo.tickerid, tf, src[1], lookahead = barmerge.lookahead_on, gaps = barmerge.gaps_off)

f_fmt2(float value) =>
    str.tostring(value, "#.##")

f_fmt3(float value) =>
    str.tostring(value, "#.###")

//------------------------------------------------------------------------------
// Momentum Engine
//------------------------------------------------------------------------------
rsiRaw = ta.rsi(close, rsiLength)
rsiComponent = f_clamp((rsiRaw - 50.0) / 50.0, -1.0, 1.0)

cmoRaw = ta.cmo(close, cmoLength)
cmoComponent = f_clamp(cmoRaw / 100.0, -1.0, 1.0)

rocRaw = ta.roc(close, rocLength)
rocMean = ta.sma(rocRaw, stdevLength)
rocDev = ta.stdev(rocRaw, stdevLength)
rocZ = f_safe_div(rocRaw - rocMean, rocDev)
rocComponent = f_clamp(rocZ / 2.5, -1.0, 1.0)

slopeRaw = ta.linreg(close, slopeLength, 0) - ta.linreg(close, slopeLength, 1)
slopeNormalizer = math.max(ta.atr(atrLength) * 0.35, syminfo.mintick * 10.0)
slopeComponent = f_clamp(f_safe_div(slopeRaw, slopeNormalizer), -1.0, 1.0)

momentumComposite = 0.32 * rsiComponent + 0.24 * cmoComponent + 0.24 * rocComponent + 0.20 * slopeComponent
momentumScore = f_clamp(ta.ema(momentumComposite, smoothMomentum), -1.0, 1.0)

regimeDriver = 0.65 * momentumScore + 0.35 * ta.ema(slopeComponent, smoothMomentum)
regimeScore = f_clamp(ta.ema(regimeDriver, smoothRegime), -1.0, 1.0)

regimeState = f_state_from_score(regimeScore, bullThreshold, bearThreshold)
regimeStatePrev = nz(regimeState[1], 0)

flipToBullRaw = regimeState == 1 and regimeStatePrev != 1
flipToBearRaw = regimeState == -1 and regimeStatePrev != -1

//------------------------------------------------------------------------------
// Price-Space Mapping
//------------------------------------------------------------------------------
basisPrice = ta.ema(close, basisLength)
atrMap = ta.atr(atrLength)
stdevMap = ta.stdev(close, stdevLength)

volUnitBase = math.max(atrMap, stdevMap * 0.75)
volUnit = math.max(volUnitBase, syminfo.mintick * 10.0)

adaptiveStepRaw = volUnit * mapBase
adaptiveStepMomentum = adaptiveStepRaw * (1.0 + math.abs(momentumScore) * mapAmp)
adaptiveStep = adaptiveStepMomentum * (1.0 + math.abs(regimeScore) * mapRegimeBoost)
adaptiveStepFinal = math.max(adaptiveStep, syminfo.mintick * 10.0)

centerShift = regimeScore * adaptiveStepFinal * mapClip
centerMapped = basisPrice + centerShift

innerOffset = adaptiveStepFinal * innerMult
outerOffset = adaptiveStepFinal * outerMult
farOffset = adaptiveStepFinal * farMult

upperInner = centerMapped + innerOffset
lowerInner = centerMapped - innerOffset

upperOuter = centerMapped + outerOffset
lowerOuter = centerMapped - outerOffset

upperFar = centerMapped + farOffset
lowerFar = centerMapped - farOffset

//------------------------------------------------------------------------------
// Width State (Compression / Expansion)
//------------------------------------------------------------------------------
outerWidth = upperOuter - lowerOuter
outerWidthMean = ta.sma(outerWidth, widthLookback)
outerWidthDev = ta.stdev(outerWidth, widthLookback)
outerWidthZ = f_safe_div(outerWidth - outerWidthMean, outerWidthDev)

isCompression = outerWidthZ < compressionThreshold
isExpansion = outerWidthZ > expansionThreshold
volatilityState = isCompression ? -1 : isExpansion ? 1 : 0

compressionStartRaw = volatilityState == -1 and nz(volatilityState[1], 0) != -1
expansionStartRaw = volatilityState == 1 and nz(volatilityState[1], 0) != 1
expansionReleaseRaw = volatilityState == 1 and nz(volatilityState[1], 0) == -1

//------------------------------------------------------------------------------
// Re-entry Events (after temporary excursion outside outer envelope)
//------------------------------------------------------------------------------
outsideUpperPrev = close[1] > upperOuter[1]
outsideLowerPrev = close[1] < lowerOuter[1]

reentryFromUpperRaw = outsideUpperPrev and close <= upperOuter and close >= upperInner
reentryFromLowerRaw = outsideLowerPrev and close >= lowerOuter and close <= lowerInner

//------------------------------------------------------------------------------
// Signal Confirmation Gate
//------------------------------------------------------------------------------
signalGate = confirmSignals ? barstate.isconfirmed : true

flipToBull = signalGate and flipToBullRaw
flipToBear = signalGate and flipToBearRaw

compressionStart = signalGate and compressionStartRaw
expansionStart = signalGate and expansionStartRaw
expansionRelease = signalGate and expansionReleaseRaw

reentryFromUpper = signalGate and reentryFromUpperRaw
reentryFromLower = signalGate and reentryFromLowerRaw

//------------------------------------------------------------------------------
// MTF Confirmed States
//------------------------------------------------------------------------------
mtfRegimeFast = useMtf ? f_htf_confirmed(tfFast, regimeScore) : na
mtfRegimeMid = useMtf ? f_htf_confirmed(tfMid, regimeScore) : na
mtfRegimeSlow = useMtf ? f_htf_confirmed(tfSlow, regimeScore) : na

mtfMomentumFast = useMtf ? f_htf_confirmed(tfFast, momentumScore) : na
mtfMomentumMid = useMtf ? f_htf_confirmed(tfMid, momentumScore) : na
mtfMomentumSlow = useMtf ? f_htf_confirmed(tfSlow, momentumScore) : na

stateFast = useMtf ? f_state_from_score(mtfRegimeFast, bullThreshold, bearThreshold) : 0
stateMid = useMtf ? f_state_from_score(mtfRegimeMid, bullThreshold, bearThreshold) : 0
stateSlow = useMtf ? f_state_from_score(mtfRegimeSlow, bullThreshold, bearThreshold) : 0

bullVotes = (stateFast == 1 ? 1 : 0) + (stateMid == 1 ? 1 : 0) + (stateSlow == 1 ? 1 : 0)
bearVotes = (stateFast == -1 ? 1 : 0) + (stateMid == -1 ? 1 : 0) + (stateSlow == -1 ? 1 : 0)

mtfConsensus = bullVotes >= 2 ? 1 : bearVotes >= 2 ? -1 : 0
mtfConsensusText = f_state_text(mtfConsensus)
mtfConflict = useMtf and regimeState != 0 and mtfConsensus != 0 and regimeState != mtfConsensus

alignmentCount = (stateFast == regimeState ? 1 : 0) + (stateMid == regimeState ? 1 : 0) + (stateSlow == regimeState ? 1 : 0)

//------------------------------------------------------------------------------
// Color System
//------------------------------------------------------------------------------
centerColor = f_signed_gradient(regimeScore, colorBear, colorNeutral, colorBull)
momentumColor = f_signed_gradient(momentumScore, colorBear, colorNeutral, colorBull)

innerLineColor = color.new(centerColor, 0)
outerLineColor = color.new(centerColor, 18)
farLineColor = color.new(centerColor, 44)

glowCenter = color.new(centerColor, 75)
glowBands = color.new(centerColor, 82)

volatilityColor = volatilityState == -1 ? colorCompression : volatilityState == 1 ? colorExpansion : color.new(centerColor, 20)
backdropColor = volatilityState == -1 ? color.new(colorCompression, 90) : volatilityState == 1 ? color.new(colorExpansion, 90) : color.new(centerColor, 94)

//------------------------------------------------------------------------------
// Plotting
//------------------------------------------------------------------------------
pCenter = plot(centerMapped, "Mapped Center", color = innerLineColor, linewidth = lineWidthCenter)
plot(centerMapped, "Mapped Center Glow", color = glowCenter, linewidth = lineWidthGlow)

pUpperInner = plot(showInner ? upperInner : na, "Upper Inner", color = innerLineColor, linewidth = lineWidthBands)
pLowerInner = plot(showInner ? lowerInner : na, "Lower Inner", color = innerLineColor, linewidth = lineWidthBands)
plot(showInner ? upperInner : na, "Upper Inner Glow", color = glowBands, linewidth = lineWidthGlow)
plot(showInner ? lowerInner : na, "Lower Inner Glow", color = glowBands, linewidth = lineWidthGlow)

pUpperOuter = plot(showOuter ? upperOuter : na, "Upper Outer", color = outerLineColor, linewidth = lineWidthBands)
pLowerOuter = plot(showOuter ? lowerOuter : na, "Lower Outer", color = outerLineColor, linewidth = lineWidthBands)
plot(showOuter ? upperOuter : na, "Upper Outer Glow", color = color.new(outerLineColor, 86), linewidth = lineWidthGlow)
plot(showOuter ? lowerOuter : na, "Lower Outer Glow", color = color.new(outerLineColor, 86), linewidth = lineWidthGlow)

pUpperFar = plot(showFar ? upperFar : na, "Upper Far", color = farLineColor, linewidth = lineWidthBands)
pLowerFar = plot(showFar ? lowerFar : na, "Lower Far", color = farLineColor, linewidth = lineWidthBands)

innerCloudColor = showCloud ? color.new(centerColor, 86) : na
upperLayerCloudColor = showCloud ? color.new(centerColor, 92) : na
lowerLayerCloudColor = showCloud ? color.new(centerColor, 92) : na
upperFarLayerColor = showCloud ? color.new(volatilityColor, 94) : na
lowerFarLayerColor = showCloud ? color.new(volatilityColor, 94) : na
backdropColorApplied = showBackdrop ? backdropColor : na
barTintColor = showBarTint ? color.new(momentumColor, 70) : na

fill(pUpperInner, pLowerInner, color = innerCloudColor, title = "Inner Cloud")
fill(pUpperOuter, pUpperInner, color = upperLayerCloudColor, title = "Upper Layer Cloud")
fill(pLowerOuter, pLowerInner, color = lowerLayerCloudColor, title = "Lower Layer Cloud")
fill(pUpperFar, pUpperOuter, color = upperFarLayerColor, title = "Upper Far Layer")
fill(pLowerFar, pLowerOuter, color = lowerFarLayerColor, title = "Lower Far Layer")

bgcolor(backdropColorApplied, title = "Volatility State Backdrop")
barcolor(barTintColor, title = "Momentum Candle Tint")

//------------------------------------------------------------------------------
// Optional Regime Labels
//------------------------------------------------------------------------------
var int lastLabelBar = na
canPrintLabel = na(lastLabelBar) or bar_index - lastLabelBar >= minLabelSpacing

if showRegimeLabels and canPrintLabel and (flipToBull or flipToBear)
    txt = flipToBull ? "Regime -> Bull" : "Regime -> Bear"
    lblStyle = flipToBull ? label.style_label_up : label.style_label_down
    lblY = flipToBull ? lowerInner : upperInner
    lblColor = flipToBull ? color.new(colorBull, 18) : color.new(colorBear, 18)
    label.new(bar_index, lblY, txt, style = lblStyle, color = lblColor, textcolor = dashText, size = size.tiny)
    lastLabelBar := bar_index

//------------------------------------------------------------------------------
// Dashboard
//------------------------------------------------------------------------------
var table dash = table.new(position.top_right, 4, 10, border_color = dashFrame, border_width = 1, bgcolor = dashBg)
dashHeaderA = color.new(color.rgb(19, 31, 54), 6)
dashHeaderB = color.new(color.rgb(35, 63, 109), 14)
dashRowA = color.new(color.rgb(17, 24, 38), 18)
dashRowB = color.new(color.rgb(24, 35, 53), 22)
dashAccent = color.new(color.rgb(92, 149, 235), 28)

if barstate.islast
    if showDashboard
        table.cell(dash, 0, 0, "Cartograph", text_color = dashText, bgcolor = dashHeaderA, text_size = size.normal)
        table.cell(dash, 1, 0, "Chart", text_color = dashText, bgcolor = dashHeaderB, text_size = size.normal)
        table.cell(dash, 2, 0, "MTF", text_color = dashText, bgcolor = dashHeaderB, text_size = size.normal)
        table.cell(dash, 3, 0, "Value", text_color = dashText, bgcolor = dashHeaderB, text_size = size.normal)

        table.cell(dash, 0, 1, "Regime", text_color = dashText, bgcolor = dashAccent)
        table.cell(dash, 1, 1, f_state_text(regimeState), text_color = dashText, bgcolor = color.new(f_state_color(regimeState, colorBull, colorBear, colorNeutral), 75))
        table.cell(dash, 2, 1, mtfConsensusText, text_color = dashText, bgcolor = color.new(f_state_color(mtfConsensus, colorBull, colorBear, colorNeutral), 78))
        table.cell(dash, 3, 1, f_fmt3(regimeScore), text_color = dashText, bgcolor = dashAccent)

        table.cell(dash, 0, 2, "Momentum", text_color = dashText, bgcolor = dashRowA)
        table.cell(dash, 1, 2, f_fmt3(momentumScore), text_color = dashText, bgcolor = color.new(momentumColor, 80))
        table.cell(dash, 2, 2, "Votes", text_color = dashText, bgcolor = dashRowA)
        table.cell(dash, 3, 2, str.tostring(bullVotes) + "/" + str.tostring(bearVotes), text_color = dashText, bgcolor = dashRowA)

        table.cell(dash, 0, 3, "Width Z", text_color = dashText, bgcolor = dashRowB)
        table.cell(dash, 1, 3, f_fmt2(outerWidthZ), text_color = dashText, bgcolor = dashRowB)
        table.cell(dash, 2, 3, "State", text_color = dashText, bgcolor = dashRowB)
        table.cell(dash, 3, 3, volatilityState == -1 ? "Compression" : volatilityState == 1 ? "Expansion" : "Balanced", text_color = dashText, bgcolor = color.new(volatilityColor, 72))

        table.cell(dash, 0, 4, "Fast TF", text_color = dashText, bgcolor = dashRowA)
        table.cell(dash, 1, 4, tfFast, text_color = dashText, bgcolor = dashRowA)
        table.cell(dash, 2, 4, f_state_text(stateFast), text_color = dashText, bgcolor = color.new(f_state_color(stateFast, colorBull, colorBear, colorNeutral), 78))
        table.cell(dash, 3, 4, useMtf ? f_fmt3(mtfRegimeFast) : "OFF", text_color = dashText)

        table.cell(dash, 0, 5, "Mid TF", text_color = dashText, bgcolor = dashRowB)
        table.cell(dash, 1, 5, tfMid, text_color = dashText, bgcolor = dashRowB)
        table.cell(dash, 2, 5, f_state_text(stateMid), text_color = dashText, bgcolor = color.new(f_state_color(stateMid, colorBull, colorBear, colorNeutral), 78))
        table.cell(dash, 3, 5, useMtf ? f_fmt3(mtfRegimeMid) : "OFF", text_color = dashText)

        table.cell(dash, 0, 6, "Slow TF", text_color = dashText, bgcolor = dashRowA)
        table.cell(dash, 1, 6, tfSlow, text_color = dashText, bgcolor = dashRowA)
        table.cell(dash, 2, 6, f_state_text(stateSlow), text_color = dashText, bgcolor = color.new(f_state_color(stateSlow, colorBull, colorBear, colorNeutral), 78))
        table.cell(dash, 3, 6, useMtf ? f_fmt3(mtfRegimeSlow) : "OFF", text_color = dashText)

        table.cell(dash, 0, 7, "Alignment", text_color = dashText, bgcolor = dashRowB)
        table.cell(dash, 1, 7, str.tostring(alignmentCount) + "/3", text_color = dashText, bgcolor = color.new(colorNeutral, 84))
        table.cell(dash, 2, 7, "Conflict", text_color = dashText, bgcolor = dashRowB)
        table.cell(dash, 3, 7, mtfConflict ? "YES" : "NO", text_color = dashText, bgcolor = color.new(mtfConflict ? colorBear : colorBull, 80))

        table.cell(dash, 0, 8, "Outer Width", text_color = dashText, bgcolor = dashRowA)
        table.cell(dash, 1, 8, f_fmt2(outerWidth), text_color = dashText, bgcolor = dashRowA)
        table.cell(dash, 2, 8, "Step", text_color = dashText, bgcolor = dashRowA)
        table.cell(dash, 3, 8, f_fmt3(adaptiveStepFinal), text_color = dashText, bgcolor = dashRowA)

        table.cell(dash, 0, 9, "Mode", text_color = dashText, bgcolor = dashRowB)
        table.cell(dash, 1, 9, confirmSignals ? "Confirmed" : "Live", text_color = dashText, bgcolor = color.new(confirmSignals ? colorBull : colorExpansion, 82))
        table.cell(dash, 2, 9, "Symbol", text_color = dashText, bgcolor = dashRowB)
        table.cell(dash, 3, 9, syminfo.ticker, text_color = dashText, bgcolor = dashRowB)
    else
        // Keep table clean when hidden.
        for r = 0 to 9
            for c = 0 to 3
                table.cell(dash, c, r, "", text_color = color.new(dashText, 100), bgcolor = color.new(dashBg, 100))

//------------------------------------------------------------------------------
// Alert Conditions
//------------------------------------------------------------------------------
alertcondition(flipToBull, "CTB Regime Flip Bull", "Cartograph Bands [JOAT]: Regime flipped to Bull.")
alertcondition(flipToBear, "CTB Regime Flip Bear", "Cartograph Bands [JOAT]: Regime flipped to Bear.")

alertcondition(reentryFromUpper, "CTB Outer Re-entry From Upper", "Cartograph Bands [JOAT]: Price re-entered from above the outer band.")
alertcondition(reentryFromLower, "CTB Outer Re-entry From Lower", "Cartograph Bands [JOAT]: Price re-entered from below the outer band.")

alertcondition(compressionStart, "CTB Compression Start", "Cartograph Bands [JOAT]: Compression state started.")
alertcondition(expansionStart, "CTB Expansion Start", "Cartograph Bands [JOAT]: Expansion state started.")
alertcondition(expansionRelease, "CTB Compression Release", "Cartograph Bands [JOAT]: Compression released into expansion.")

alertcondition(signalGate and mtfConflict, "CTB MTF Conflict", "Cartograph Bands [JOAT]: Chart regime conflicts with MTF consensus.")

//------------------------------------------------------------------------------
// Hidden debug plots (available for alert placeholders if needed)
//------------------------------------------------------------------------------
plot(regimeScore, "Regime Score (Hidden)", color = na, display = display.none)
plot(momentumScore, "Momentum Score (Hidden)", color = na, display = display.none)
plot(outerWidthZ, "Outer Width Z (Hidden)", color = na, display = display.none)
````
