# Caldera Relative Pressure [JOAT]

- url: https://www.tradingview.com/script/sJPQZ2Uy-Caldera-Relative-Pressure-JOAT/
- type: indicator
- pine_id: PUB;27612a175c754d24b07972a4663a3beb
- version: 1.0

## Description

[b]Caldera Relative Pressure [JOAT][/b]

[b]Introduction[/b]

Caldera Relative Pressure is an open-source effort-versus-result oscillator designed to measure whether price movement is being supported by participation, directional efficiency, and close location within the bar. It is built to distinguish clean directional drive from absorption, exhaustion, and two-way rotation.

The problem this script solves is that raw price movement does not explain whether a move is efficient, forced, rejected, or fading. A wide candle on low participation is not the same as a wide candle with expanding participation and strong close location. Caldera converts candle anatomy, relative volume, range behavior, and baseline context into a structured pressure model that is easier to read in real time.

[image]https://www.tradingview.com/x/jcrKPJK1/[/image]

[b]Core Concepts[/b]

[b]1. Effort-Versus-Result Framework[/b]

The script blends three weighted components:

[list]
[*][b]Effort:[/b] candle body and directional spread relative to true range
[*][b]Result:[/b] directional efficiency relative to ATR
[*][b]Location:[/b] where the bar closes inside its own range, adjusted by wick pressure
[/list]

Those three parts are multiplied by relative volume so that quiet moves and committed moves do not receive the same score.

[b]2. Directional Drive Detection[/b]

Bull and bear drive states require a sufficiently large composite pressure reading, positive spread between the composite and its signal line, and close location agreement. This keeps small or conflicted moves from being treated as decisive tape control.

[b]3. Absorption Detection[/b]

Absorption is identified by unusually strong volume combined with limited body progress and asymmetric wick behavior. In practical terms, that means participation increased but result did not expand proportionally. This is often a useful clue that one side is meeting aggressive pressure with passive liquidity.

[b]4. Exhaustion Detection[/b]

The script also tracks exhaustion. It compares the current pressure state with recent pressure extremes and short-term momentum fade. A move can still be directionally positive or negative while simultaneously losing efficiency.

[b]5. Multi-Layer Pressure Visualization[/b]

The pane includes a histogram, composite line, signal line, drive quality line, balance line, participation band, efficiency band, location band, rotation ribbon, and reference ladders. These are separate on purpose:

[list]
[*]The histogram shows raw directional pressure
[*]The composite and signal lines show state and rotation
[*]Drive quality shows how healthy the move is
[*]Participation, efficiency, and location bands show what is contributing to the reading
[/list]

[b]Features[/b]

[list]
[*][b]Composite pressure engine:[/b] Candle anatomy, ATR efficiency, location, and relative participation
[*][b]Bull and bear drive states:[/b] Measures directional initiative
[*][b]Bull and bear absorption states:[/b] Flags high-effort / low-result behavior
[*][b]Bull and bear exhaustion states:[/b] Flags fading pressure after prior extremes
[*][b]Baseline context filter:[/b] Can require price to align with a directional baseline
[*][b]Drive quality and balance lines:[/b] Separate force from quality
[*][b]Participation, efficiency, and location bands:[/b] Show what is driving the current reading
[*][b]Rotation ribbon:[/b] Highlights positive and negative carry
[*][b]Dashboard summary:[/b] State, bias, strength, regime, context, participation, quality, balance, rotation, and compression
[/list]

[b]Input Parameters[/b]

[b]Core Engine:[/b]
[list]
[*]Relative Volume Length
[*]Range Normalization Length
[*]Baseline Context Length
[*]Signal Smoothing
[/list]

[b]Pressure Model:[/b]
[list]
[*]Effort Weight
[*]Result Weight
[*]Location Weight
[*]Drive Threshold
[*]Expansion Threshold
[/list]

[b]State Logic:[/b]
[list]
[*]Absorption Volume Z
[*]Absorption Range Cap
[*]Exhaustion Lookback
[*]Recent State Window
[*]Baseline Context Filter toggle
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the State Row[/b]
The State row tells you whether the market is currently showing directional drive, absorption, exhaustion, or balance. This is the first layer of interpretation.

[b]Step 2: Compare Pressure With Quality[/b]
A strong pressure reading with weak drive quality can be unstable. A smaller pressure reading with improving quality can be more constructive. Use those two together rather than treating histogram height alone as the answer.

[b]Step 3: Inspect Participation, Efficiency, and Location[/b]
These bands explain why the model is leaning in one direction. If participation is strong but efficiency is weak, the move may be absorption. If efficiency and location are strong but participation is weak, the move may be less durable.

[b]Step 4: Watch the Rotation Ribbon[/b]
Rotation tells you whether pressure is continuing, stabilizing, or turning. This can be useful for early changes in internal character even when the headline state has not fully flipped yet.

[b]Indicator Limitations[/b]

[list]
[*]Relative volume is broker and instrument dependent, so the same thresholds may not transfer perfectly across markets
[*]Absorption and exhaustion are contextual states, not guaranteed turning points
[*]High-volatility event bars can temporarily distort effort-versus-result relationships
[*]A baseline filter improves context but can delay state recognition during sharp reversals
[/list]

[b]Originality Statement[/b]

Caldera Relative Pressure is original in the way it turns candle anatomy, participation, efficiency, and location into a layered pressure model with separate drive, absorption, and exhaustion states. The script is not a simple volume oscillator or candle-coloring tool. Its design is centered on explaining how price is moving, not only how far it moved.

[b]Disclaimer[/b]

This script is provided for educational and informational purposes only. It is not financial advice. Pressure readings are based on historical bar data and can misclassify conditions during abnormal liquidity or fast event-driven moves. Always use independent confirmation and prudent risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Caldera Relative Pressure [JOAT]", shorttitle="Caldera Pressure [JOAT]", overlay=false, precision=2, max_bars_back=5000, max_lines_count=80, max_labels_count=40, max_boxes_count=30)

//------------------------------------------------------------------------------
// Caldera Relative Pressure
// Institutional pressure pane for effort-versus-result analysis.
//------------------------------------------------------------------------------

string grpCore = "Core Engine"
string grpSignal = "Pressure Model"
string grpState = "State Logic"
string grpVisual = "Visual System"
string grpDash = "Dashboard"

src = input.source(close, "Source", group=grpCore)
volumeLength = input.int(34, "Relative Volume Length", minval=5, maxval=250, group=grpCore)
rangeLength = input.int(21, "Range Normalization Length", minval=5, maxval=200, group=grpCore)
baselineLength = input.int(55, "Baseline Context Length", minval=5, maxval=200, group=grpCore)
smoothLength = input.int(8, "Signal Smoothing", minval=1, maxval=50, group=grpCore)

effortWeight = input.float(0.40, "Effort Weight", minval=0.05, maxval=1.0, step=0.05, group=grpSignal)
resultWeight = input.float(0.35, "Result Weight", minval=0.05, maxval=1.0, step=0.05, group=grpSignal)
locationWeight = input.float(0.25, "Location Weight", minval=0.05, maxval=1.0, step=0.05, group=grpSignal)
imbalanceThreshold = input.float(18.0, "Drive Threshold", minval=5.0, maxval=60.0, step=0.5, group=grpSignal)
expansionThreshold = input.float(0.75, "Expansion Threshold", minval=0.1, maxval=3.0, step=0.05, group=grpSignal)

absorptionVolumeZ = input.float(1.10, "Absorption Volume Z", minval=0.2, maxval=3.0, step=0.05, group=grpState)
absorptionRangeCap = input.float(0.55, "Absorption Range Cap", minval=0.1, maxval=1.0, step=0.05, group=grpState)
exhaustionLookback = input.int(8, "Exhaustion Lookback", minval=2, maxval=30, group=grpState)
recentStateWindow = input.int(12, "Recent State Window", minval=3, maxval=40, group=grpState)
useTrendContext = input.bool(true, "Use Baseline Context Filter", group=grpState)

themeMode = input.string("Foundry Night", "Theme", options=["Foundry Night", "Slate Current", "Fjord Ember"], group=grpVisual)
showHistogram = input.bool(true, "Show Pressure Histogram", group=grpVisual)
showComposite = input.bool(true, "Show Composite Curve", group=grpVisual)
showSignalBand = input.bool(true, "Show Signal Band", group=grpVisual)
showParticipationBand = input.bool(true, "Show Participation Band", group=grpVisual)
showRotationRibbon = input.bool(true, "Show Rotation Ribbon", group=grpVisual)
showReferenceLadders = input.bool(true, "Show Reference Ladders", group=grpVisual)
showBackgroundState = input.bool(true, "Show State Background", group=grpVisual)
showStateMarkers = input.bool(true, "Show State Markers", group=grpVisual)
showBarTint = input.bool(false, "Tint Price Bars", group=grpVisual)

showDashboard = input.bool(true, "Show Dashboard", group=grpDash)
dashboardPosition = input.string("Top Right", "Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpDash)
dashboardSize = input.string("Medium", "Size", options=["Small", "Medium", "Large"], group=grpDash)

var color bullCore = color.new(#41c594, 0)
var color bearCore = color.new(#d16d66, 0)
var color absorptionBullCore = color.new(#86c1e6, 0)
var color absorptionBearCore = color.new(#d4b07a, 0)
var color accentCore = color.new(#d3ae78, 0)
var color neutralCore = color.new(#98a5b4, 0)
var color panelBg = color.new(#0f141c, 0)
var color panelBgSoft = color.new(#161d27, 0)
var color panelBorder = color.new(#2a3544, 0)
var color textMain = color.new(#e7edf5, 0)
var color textDim = color.new(#93a2b3, 0)

if barstate.isfirst
    if themeMode == "Foundry Night"
        bullCore := color.new(#46c49a, 0)
        bearCore := color.new(#d57268, 0)
        absorptionBullCore := color.new(#84bcdf, 0)
        absorptionBearCore := color.new(#cfac72, 0)
        accentCore := color.new(#d3ae78, 0)
    else if themeMode == "Slate Current"
        bullCore := color.new(#4cb7ae, 0)
        bearCore := color.new(#cb7681, 0)
        absorptionBullCore := color.new(#8ea8d4, 0)
        absorptionBearCore := color.new(#c6b38c, 0)
        accentCore := color.new(#92b3d1, 0)
        panelBg := color.new(#10161f, 0)
        panelBgSoft := color.new(#17212d, 0)
        panelBorder := color.new(#314051, 0)
    else
        bullCore := color.new(#67c28d, 0)
        bearCore := color.new(#df7f63, 0)
        absorptionBullCore := color.new(#9db8d5, 0)
        absorptionBearCore := color.new(#cdb587, 0)
        accentCore := color.new(#c9ba79, 0)
        panelBg := color.new(#141218, 0)
        panelBgSoft := color.new(#1d1821, 0)
        panelBorder := color.new(#392f39, 0)

f_safe_div(float num, float den, float fallback) =>
    math.abs(den) > 1e-10 ? num / den : fallback

f_clamp(float value, float lo, float hi) =>
    math.max(lo, math.min(hi, value))

f_zscore(float seriesValue, int len) =>
    meanValue = ta.sma(seriesValue, len)
    deviation = ta.stdev(seriesValue, len)
    deviation > 0 ? (seriesValue - meanValue) / deviation : 0.0

f_tanh(float value) =>
    expValue = math.exp(2.0 * value)
    (expValue - 1.0) / (expValue + 1.0)

f_scale_unit(float seriesValue, int len) =>
    lowValue = ta.lowest(seriesValue, len)
    highValue = ta.highest(seriesValue, len)
    span = highValue - lowValue
    span > 0 ? ((seriesValue - lowValue) / span) * 2.0 - 1.0 : 0.0

f_pos_from_text(string pos) =>
    pos == "Top Left" ? position.top_left : pos == "Bottom Right" ? position.bottom_right : pos == "Bottom Left" ? position.bottom_left : position.top_right

f_size_from_text(string sizeText) =>
    sizeText == "Small" ? size.small : sizeText == "Large" ? size.large : size.normal

f_state_text(bool bullDrive, bool bearDrive, bool bullAbsorb, bool bearAbsorb, bool bullExhaust, bool bearExhaust) =>
    bullDrive ? "Bull Drive" :
     bearDrive ? "Bear Drive" :
     bullAbsorb ? "Bull Absorption" :
     bearAbsorb ? "Bear Absorption" :
     bullExhaust ? "Bull Exhaustion" :
     bearExhaust ? "Bear Exhaustion" : "Balanced"

f_state_color(bool bullDrive, bool bearDrive, bool bullAbsorb, bool bearAbsorb, bool bullExhaust, bool bearExhaust) =>
    bullDrive ? bullCore :
     bearDrive ? bearCore :
     bullAbsorb ? absorptionBullCore :
     bearAbsorb ? absorptionBearCore :
     bullExhaust ? color.new(bearCore, 10) :
     bearExhaust ? color.new(bullCore, 10) : neutralCore

trueRange = math.max(high - low, syminfo.mintick)
body = close - open
bodyAbs = math.abs(body)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
spreadNorm = body / trueRange
bodyRatio = bodyAbs / trueRange
upperWickRatio = upperWick / trueRange
lowerWickRatio = lowerWick / trueRange
closeLocation = ((close - low) - (high - close)) / trueRange
wickPressure = lowerWickRatio - upperWickRatio

baseline = ta.ema(src, baselineLength)
baselineSlope = baseline - baseline[1]
trendBias = close > baseline and baselineSlope > 0 ? 1 : close < baseline and baselineSlope < 0 ? -1 : 0

relativeVolume = f_safe_div(volume, ta.sma(volume, volumeLength), 1.0)
volumeZ = f_zscore(volume, volumeLength)
rangeZ = f_zscore(trueRange, rangeLength)
resultEfficiency = f_safe_div(body, ta.atr(rangeLength), 0.0)
resultNormalized = f_tanh(f_clamp(resultEfficiency * 4.0, -2.5, 2.5))
locationComponent = f_clamp(closeLocation + wickPressure * 0.5, -1.0, 1.0)
effortComponent = f_clamp(spreadNorm * 0.55 + bodyRatio * math.sign(body) * 0.45, -1.0, 1.0)
pressureRaw = (effortComponent * effortWeight + resultNormalized * resultWeight + locationComponent * locationWeight) * relativeVolume
pressurePulse = pressureRaw * 100.0
pressureComposite = ta.ema(pressurePulse, smoothLength)
pressureSignal = ta.ema(pressureComposite, math.max(2, int(smoothLength * 1.5)))
pressureSpread = pressureComposite - pressureSignal
expansionState = rangeZ > expansionThreshold and math.abs(pressureComposite) > imbalanceThreshold * 0.5
compressionState = math.abs(rangeZ) < 0.10 and math.abs(pressureComposite) < imbalanceThreshold * 0.45
participationScore = f_clamp(f_zscore(relativeVolume, rangeLength), -2.0, 2.0) * 25.0
locationScore = closeLocation * 50.0
efficiencyScore = resultNormalized * 50.0
driveQuality = (participationScore * 0.30) + (locationScore * 0.30) + (efficiencyScore * 0.40)
balanceLine = ta.ema(pressureComposite - driveQuality * 0.25, math.max(2, smoothLength - 1))
rotationalBias = f_scale_unit(pressureComposite, math.max(10, rangeLength))
rotationUp = barstate.isconfirmed and ta.crossover(pressureComposite, pressureSignal)
rotationDown = barstate.isconfirmed and ta.crossunder(pressureComposite, pressureSignal)
participationBand = ta.ema(participationScore, math.max(2, smoothLength))
efficiencyBand = ta.ema(efficiencyScore, math.max(2, smoothLength))
locationBand = ta.ema(locationScore, math.max(2, smoothLength))
rotationRibbon = ta.ema(rotationalBias * 40.0, math.max(2, smoothLength))

bullDriveCore = pressureComposite > imbalanceThreshold and pressureSpread > 0 and closeLocation > 0
bearDriveCore = pressureComposite < -imbalanceThreshold and pressureSpread < 0 and closeLocation < 0
bullDrive = bullDriveCore and (not useTrendContext or trendBias >= 0)
bearDrive = bearDriveCore and (not useTrendContext or trendBias <= 0)

bullAbsorption = volumeZ > absorptionVolumeZ and lowerWickRatio > upperWickRatio and bodyRatio < absorptionRangeCap and closeLocation > 0.10 and pressureComposite > 0 and (not useTrendContext or trendBias >= 0)
bearAbsorption = volumeZ > absorptionVolumeZ and upperWickRatio > lowerWickRatio and bodyRatio < absorptionRangeCap and closeLocation < -0.10 and pressureComposite < 0 and (not useTrendContext or trendBias <= 0)

recentHighPressure = ta.highest(pressureComposite, exhaustionLookback)
recentLowPressure = ta.lowest(pressureComposite, exhaustionLookback)
momentumFade = ta.ema(body, 3) - ta.ema(body, 8)
bullExhaustion = recentHighPressure > imbalanceThreshold and pressureComposite > imbalanceThreshold * 0.55 and pressureComposite < recentHighPressure * 0.88 and momentumFade < 0 and closeLocation < 0.15
bearExhaustion = recentLowPressure < -imbalanceThreshold and pressureComposite < -imbalanceThreshold * 0.55 and pressureComposite > recentLowPressure * 0.88 and momentumFade > 0 and closeLocation > -0.15

stateColor = f_state_color(bullDrive, bearDrive, bullAbsorption, bearAbsorption, bullExhaustion, bearExhaustion)
stateText = f_state_text(bullDrive, bearDrive, bullAbsorption, bearAbsorption, bullExhaustion, bearExhaustion)

confirmedBullDrive = bullDrive and barstate.isconfirmed
confirmedBearDrive = bearDrive and barstate.isconfirmed
confirmedBullAbsorption = bullAbsorption and barstate.isconfirmed
confirmedBearAbsorption = bearAbsorption and barstate.isconfirmed
confirmedBullExhaustion = bullExhaustion and barstate.isconfirmed
confirmedBearExhaustion = bearExhaustion and barstate.isconfirmed

recentBullEvent = ta.barssince(confirmedBullDrive or confirmedBullAbsorption) < recentStateWindow
recentBearEvent = ta.barssince(confirmedBearDrive or confirmedBearAbsorption) < recentStateWindow

histColor =
     pressureComposite >= 0 ? color.from_gradient(pressureComposite, 0.0, 60.0, color.new(bullCore, 72), bullCore) :
     color.from_gradient(math.abs(pressureComposite), 0.0, 60.0, color.new(bearCore, 72), bearCore)
qualityColor =
     driveQuality >= 0 ? color.from_gradient(driveQuality, 0.0, 60.0, color.new(absorptionBullCore, 82), absorptionBullCore) :
     color.from_gradient(math.abs(driveQuality), 0.0, 60.0, color.new(absorptionBearCore, 82), absorptionBearCore)

bandHigh = showSignalBand ? imbalanceThreshold : na
bandLow = showSignalBand ? -imbalanceThreshold : na
qualityGuide = showReferenceLadders ? imbalanceThreshold * 0.5 : na
negativeQualityGuide = showReferenceLadders ? -imbalanceThreshold * 0.5 : na
rotationGuideHigh = showReferenceLadders ? 20.0 : na
rotationGuideLow = showReferenceLadders ? -20.0 : na
plotBandHigh = plot(bandHigh, title="Drive Ceiling", color=color.new(bullCore, 78), linewidth=1, style=plot.style_line)
plotBandLow = plot(bandLow, title="Drive Floor", color=color.new(bearCore, 78), linewidth=1, style=plot.style_line)
plotZero = plot(0, title="Zero Line", color=color.new(neutralCore, 65), linewidth=1)
plotQualityGuide = plot(qualityGuide, title="Quality Ceiling", color=color.new(accentCore, 80), linewidth=1, style=plot.style_line)
plotNegativeQualityGuide = plot(negativeQualityGuide, title="Quality Floor", color=color.new(accentCore, 80), linewidth=1, style=plot.style_line)
plotRotationGuideHigh = plot(rotationGuideHigh, title="Rotation Ceiling", color=color.new(neutralCore, 85), linewidth=1, style=plot.style_line)
plotRotationGuideLow = plot(rotationGuideLow, title="Rotation Floor", color=color.new(neutralCore, 85), linewidth=1, style=plot.style_line)
plotHistogram = plot(showHistogram ? pressureComposite : na, title="Pressure Histogram", style=plot.style_histogram, color=histColor, linewidth=3)
plotComposite = plot(showComposite ? pressureComposite : na, title="Composite Pressure", color=stateColor, linewidth=2)
plotSignal = plot(showComposite ? pressureSignal : na, title="Signal Pressure", color=color.new(neutralCore, 0), linewidth=2)
plotSpread = plot(showSignalBand ? pressureSpread * 1.5 : na, title="Pressure Spread", color=color.new(stateColor, 35), linewidth=1)
plotQuality = plot(showSignalBand ? driveQuality : na, title="Drive Quality", color=qualityColor, linewidth=2)
plotBalance = plot(showSignalBand ? balanceLine : na, title="Balance Line", color=color.new(neutralCore, 25), linewidth=1)
plotParticipation = plot(showParticipationBand ? participationBand : na, title="Participation Band", color=color.new(absorptionBullCore, 10), linewidth=1)
plotEfficiency = plot(showParticipationBand ? efficiencyBand : na, title="Efficiency Band", color=color.new(accentCore, 10), linewidth=1)
plotLocation = plot(showParticipationBand ? locationBand : na, title="Location Band", color=color.new(absorptionBearCore, 10), linewidth=1)
plotRotation = plot(showRotationRibbon ? rotationRibbon : na, title="Rotation Ribbon", color=color.new(stateColor, 20), linewidth=2)
fill(plotComposite, plotSignal, color=color.new(stateColor, 88), title="Composite Fill")
fill(plotBandHigh, plotBandLow, color=color.new(panelBgSoft, 86), title="Balance Band")
fill(plotQuality, plotBalance, color=color.new(qualityColor, 88), title="Quality Fill")
fill(plotParticipation, plotLocation, color=color.new(panelBgSoft, 90), title="Participation Fill")
fill(plotQualityGuide, plotNegativeQualityGuide, color=color.new(accentCore, 94), title="Quality Ladder Fill")
fill(plotRotationGuideHigh, plotRotationGuideLow, color=color.new(neutralCore, 95), title="Rotation Guide Fill")

//------------------------------------------------------------------------------
// Dashboard and alert package
//------------------------------------------------------------------------------
bgcolor(showBackgroundState ? color.new(stateColor, 92) : na)
barcolor(showBarTint ? color.new(stateColor, 45) : na)
plotshape(showStateMarkers ? (confirmedBullDrive ? pressureComposite : na) : na, title="Bull Drive", style=shape.circle, location=location.absolute, size=size.tiny, color=bullCore, text="")
plotshape(showStateMarkers ? (confirmedBearDrive ? pressureComposite : na) : na, title="Bear Drive", style=shape.circle, location=location.absolute, size=size.tiny, color=bearCore, text="")
plotshape(showStateMarkers ? (confirmedBullAbsorption ? pressureComposite : na) : na, title="Bull Absorption", style=shape.diamond, location=location.absolute, size=size.tiny, color=absorptionBullCore, text="")
plotshape(showStateMarkers ? (confirmedBearAbsorption ? pressureComposite : na) : na, title="Bear Absorption", style=shape.diamond, location=location.absolute, size=size.tiny, color=absorptionBearCore, text="")
plotshape(showStateMarkers ? (confirmedBullExhaustion ? pressureComposite : na) : na, title="Bull Exhaustion", style=shape.square, location=location.absolute, size=size.tiny, color=color.new(bearCore, 0), text="")
plotshape(showStateMarkers ? (confirmedBearExhaustion ? pressureComposite : na) : na, title="Bear Exhaustion", style=shape.square, location=location.absolute, size=size.tiny, color=color.new(bullCore, 0), text="")

pressureStrength = math.min(100.0, math.abs(pressureComposite))
directionalBias = pressureComposite > imbalanceThreshold * 0.4 ? "Bid Dominant" : pressureComposite < -imbalanceThreshold * 0.4 ? "Offer Dominant" : "Two-Way"
regimeState = expansionState ? "Expansion" : math.abs(rangeZ) < 0.15 ? "Compression" : "Transitional"
contextState = trendBias > 0 ? "Above Baseline" : trendBias < 0 ? "Below Baseline" : "At Baseline"
recentLedger = recentBullEvent and not recentBearEvent ? "Recent Bid Support" : recentBearEvent and not recentBullEvent ? "Recent Offer Control" : "Balanced Tape"
rotationState = rotationUp ? "Positive Rotation" : rotationDown ? "Negative Rotation" : rotationalBias > 0 ? "Positive Carry" : rotationalBias < 0 ? "Negative Carry" : "Flat Carry"
compressionText = compressionState ? "Compressed" : expansionState ? "Released" : "Normal"

var table dashboard = table.new(position.top_right, 2, 8, frame_color=panelBorder, frame_width=1, bgcolor=panelBg)

if showDashboard and barstate.islast
    dashSize = size.normal
    table.cell(dashboard, 0, 0, "Pressure Summary", text_color=textMain, text_size=dashSize, bgcolor=panelBgSoft)
    table.cell(dashboard, 1, 0, timeframe.period, text_color=textMain, text_size=dashSize, bgcolor=panelBgSoft)
    table.cell(dashboard, 0, 1, "State", text_color=textDim, text_size=dashSize, bgcolor=panelBg)
    table.cell(dashboard, 1, 1, stateText, text_color=stateColor, text_size=dashSize, bgcolor=panelBg)
    table.cell(dashboard, 0, 2, "Bias", text_color=textDim, text_size=dashSize, bgcolor=panelBg)
    table.cell(dashboard, 1, 2, directionalBias, text_color=stateColor, text_size=dashSize, bgcolor=panelBg)
    table.cell(dashboard, 0, 3, "Quality", text_color=textDim, text_size=dashSize, bgcolor=panelBg)
    table.cell(dashboard, 1, 3, str.tostring(driveQuality, "#.0"), text_color=qualityColor, text_size=dashSize, bgcolor=panelBg)
    table.cell(dashboard, 0, 4, "Rotation", text_color=textDim, text_size=dashSize, bgcolor=panelBg)
    table.cell(dashboard, 1, 4, rotationState, text_color=rotationUp ? bullCore : rotationDown ? bearCore : textMain, text_size=dashSize, bgcolor=panelBg)
    table.cell(dashboard, 0, 5, "Context", text_color=textDim, text_size=dashSize, bgcolor=panelBg)
    table.cell(dashboard, 1, 5, contextState, text_color=trendBias == 0 ? textDim : stateColor, text_size=dashSize, bgcolor=panelBg)
    table.cell(dashboard, 0, 6, "Tape", text_color=textDim, text_size=dashSize, bgcolor=panelBg)
    table.cell(dashboard, 1, 6, recentLedger, text_color=textMain, text_size=dashSize, bgcolor=panelBg)
    table.cell(dashboard, 0, 7, "Compression", text_color=textDim, text_size=dashSize, bgcolor=panelBg)
    table.cell(dashboard, 1, 7, compressionText, text_color=compressionState ? accentCore : stateColor, text_size=dashSize, bgcolor=panelBg)
else if not showDashboard and barstate.islast
    table.clear(dashboard, 0, 0, 1, 7)

alertcondition(confirmedBullDrive, title="Caldera Bull Drive", message="Caldera Relative Pressure [JOAT] confirmed bull drive.")
alertcondition(confirmedBearDrive, title="Caldera Bear Drive", message="Caldera Relative Pressure [JOAT] confirmed bear drive.")
alertcondition(confirmedBullAbsorption, title="Caldera Bull Absorption", message="Caldera Relative Pressure [JOAT] confirmed bull absorption.")
alertcondition(confirmedBearAbsorption, title="Caldera Bear Absorption", message="Caldera Relative Pressure [JOAT] confirmed bear absorption.")
alertcondition(confirmedBullExhaustion, title="Caldera Bull Exhaustion", message="Caldera Relative Pressure [JOAT] flagged bull exhaustion.")
alertcondition(confirmedBearExhaustion, title="Caldera Bear Exhaustion", message="Caldera Relative Pressure [JOAT] flagged bear exhaustion.")
alertcondition(rotationUp, title="Caldera Positive Rotation", message="Caldera Relative Pressure [JOAT] crossed above its signal line.")
alertcondition(rotationDown, title="Caldera Negative Rotation", message="Caldera Relative Pressure [JOAT] crossed below its signal line.")
alertcondition(barstate.isconfirmed and expansionState, title="Caldera Expansion State", message="Caldera Relative Pressure [JOAT] entered an expansion state.")
alertcondition(barstate.isconfirmed and compressionState, title="Caldera Compression State", message="Caldera Relative Pressure [JOAT] entered a compression state.")
alertcondition(barstate.isconfirmed and ta.crossover(driveQuality, 0), title="Caldera Quality Reclaim", message="Caldera Relative Pressure [JOAT] drive quality crossed back above zero.")
alertcondition(barstate.isconfirmed and ta.crossunder(driveQuality, 0), title="Caldera Quality Loss", message="Caldera Relative Pressure [JOAT] drive quality crossed below zero.")
````
