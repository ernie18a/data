# Helix Regime Corridor [JOAT]

- url: https://www.tradingview.com/script/HHt8vsCE-Helix-Regime-Corridor-JOAT/
- type: indicator
- pine_id: PUB;0b8fae81afa74c2195ab1e800490fa0b
- version: 1.0

## Description

[b]Helix Regime Corridor [JOAT][/b]

[b]Introduction[/b]

Helix Regime Corridor is an open-source regime and entry-state indicator built around adaptive ATR bands, structural CHoCH events, regression context, transition memory, and risk rails. It is designed to show when price is moving under bullish control, bearish control, or a less decisive transition state.

The script solves the problem of treating every trend flip the same. It requires directional control, structure, volatility, and confluence scoring before marking a confirmed shift.

[image]https://www.tradingview.com/x/SbAxdGeC/[/image]

[b]Core Concepts[/b]

[b]1. Adaptive Regime Corridor[/b]
The central trend average and surrounding ATR bands adapt to current market volatility. The corridor shows whether price is operating above, below, or inside the active control area.

[b]2. Confirmed Holds[/b]
The script can require price to hold beyond the corridor for a configurable number of bars. This helps reduce single-candle fakeouts.

[b]3. CHoCH-Assisted Structure[/b]
Pivot highs and lows identify structural change. Bullish or bearish CHoCH events can support a new regime shift when price breaks prior structure.

[b]4. Regression Context[/b]
An optional regression field provides broader directional context and helps identify whether the active shift is aligned with the recent linear price path.

[b]5. Transition Memory[/b]
The script tracks transition behavior over a configurable memory window. This adds a probability-style context layer without claiming certainty.

[b]Features[/b]

[list]
[*][b]Adaptive ATR corridor:[/b] Volatility-adjusted bands frame bullish and bearish control.
[*][b]Regime shift detection:[/b] Identifies confirmed changes into bullish or bearish control.
[*][b]CHoCH structure:[/b] Optional structure-assisted entries using pivot confirmation.
[*][b]Confluence scoring:[/b] Signals require score alignment rather than a single moving-average cross.
[*][b]Risk rails:[/b] Entry, stop, TP1, TP2, and TP3 references can be drawn for confirmed shifts.
[*][b]Candle tinting:[/b] Bars can be colored by current state.
[*][b]Optional regression channel:[/b] Adds broader context when desired.
[*][b]HUD:[/b] Shows regime, score, transition, ADX/ATR, regression, structure, and bias.
[*][b]Alerts:[/b] Long shift, short shift, bull regime, bear regime, bullish CHoCH, and bearish CHoCH.
[/list]

[b]Input Parameters[/b]

[b]Core:[/b] Operating Preset, Adaptive Average Length, ATR Length, ATR Band Multiplier, Confirmed Hold Bars.

[b]Structure and Signals:[/b] Pivot Left, Pivot Right, Regression Context Length, Transition Memory, Directional Strength Length, Minimum Shift Score, Allow CHoCH-Assisted Entries, Signal Cooldown Bars.

[b]Risk and Visuals:[/b] Structure Stop Lookback, Stop ATR Buffer, TP1 R, TP2 R, TP3 R, Rail Projection Bars, Adaptive Bands, Trend Cloud, Regression Channel, Candle Tint, Pivot Marks, HUD.

[b]How to Use This Indicator[/b]

[b]Step 1: Read the regime[/b]
Use the corridor and dashboard to identify whether price is under bullish control, bearish control, or a weaker transitional state.

[b]Step 2: Wait for score confirmation[/b]
Long and short shifts are only marked when the configured confluence score is reached.

[b]Step 3: Compare structure[/b]
CHoCH events help explain whether a shift is supported by structural change or only by band behavior.

[b]Indicator Limitations[/b]

[list]
[*]Pivot structure confirms after the required right-side bars complete.
[*]Adaptive bands can lag sharp reversals because they are volatility-based.
[*]Transition memory summarizes recent behavior; it does not forecast future price.
[*]Risk rails do not account for spread, slippage, or order execution.
[/list]

[b]Originality Statement[/b]

Helix Regime Corridor is original in its combination of adaptive ATR control bands, hold confirmation, CHoCH structure, regression context, transition memory, confluence scoring, and risk rails. The components are combined to classify regime and produce cleaner shift states rather than simply plotting a trend band.

[b]Disclaimer[/b]

This script is for educational and informational use only. It is not financial advice and does not recommend any trade. Trend and regime models can fail in ranges, news events, and abnormal volatility. Always manage risk independently.

Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Helix Regime Corridor [JOAT]", shorttitle="HRC [JOAT]", overlay=true, max_labels_count=300, max_lines_count=300, max_boxes_count=120)

// Helix Regime Corridor is a non-repainting regime and entry-state engine.
// It blends adaptive ATR bands, CHoCH pivots, regression context, transition
// probability, and risk rails into one clean on-chart system.

//--------------------------------------------------------------------------
// Institutional palette
//--------------------------------------------------------------------------
bullColor       = color.rgb(48, 214, 189)
bearColor       = color.rgb(236, 92, 140)
controlColor    = color.rgb(82, 185, 255)
volColor        = color.rgb(128, 111, 255)
strongBullColor = color.rgb(114, 255, 188)
strongBearColor = color.rgb(255, 96, 180)
neutralColor    = color.rgb(143, 152, 171)
darkPanel       = color.rgb(10, 14, 20)
darkCell        = color.rgb(24, 28, 36)
hudBg           = color.new(darkPanel, 12)
hudBorder       = color.new(color.rgb(56, 64, 82), 38)

//--------------------------------------------------------------------------
// Inputs
//--------------------------------------------------------------------------
groupCore = "Core"
preset = input.string("Intraday", "Operating preset", options=["Scalping", "Intraday", "Swing", "High-Volatility", "Low-Noise", "Visual Showcase"], group=groupCore)
src = input.source(hlc3, "Source", group=groupCore)
trendLenInput = input.int(48, "Adaptive average length", minval=8, group=groupCore)
atrLen = input.int(14, "ATR length", minval=2, group=groupCore)
bandMultInput = input.float(1.85, "ATR band multiplier", minval=0.4, step=0.05, group=groupCore)
holdBars = input.int(2, "Confirmed hold bars", minval=1, maxval=8, group=groupCore)

groupStructure = "Structure"
pivotLeft = input.int(4, "Pivot left", minval=1, group=groupStructure)
pivotRight = input.int(4, "Pivot right", minval=1, group=groupStructure)
regLen = input.int(120, "Regression context length", minval=30, maxval=300, group=groupStructure)
markovLen = input.int(34, "Transition memory", minval=8, maxval=120, group=groupStructure)
dmiLen = input.int(14, "Directional strength length", minval=5, group=groupStructure)

groupSignals = "Signals"
minScore = input.int(74, "Minimum shift score", minval=35, maxval=95, group=groupSignals)
allowChochEntries = input.bool(true, "Allow CHoCH-assisted entries", group=groupSignals)
showSignalLabels = input.bool(true, "Show entry-state labels", group=groupSignals)
showRiskRails = input.bool(true, "Show Trade Plan Rails", group=groupSignals)
signalCooldownBars = input.int(14, "Signal cooldown bars", minval=0, maxval=100, group=groupSignals)

groupRisk = "Risk"
stopLookback = input.int(12, "Structure stop lookback", minval=3, maxval=80, group=groupRisk)
stopAtrBuffer = input.float(0.35, "Stop ATR buffer", minval=0.05, step=0.05, group=groupRisk)
tpOneR = input.float(0.85, "TP1 R multiple", minval=0.25, step=0.25, group=groupRisk)
tpTwoR = input.float(1.35, "TP2 R multiple", minval=0.5, step=0.25, group=groupRisk)
tpThreeR = input.float(2.6, "TP3 R multiple", minval=0.75, step=0.25, group=groupRisk)
railBars = input.int(22, "Rail projection bars", minval=8, maxval=120, group=groupRisk)

groupVisual = "Visuals"
showCandleTint = input.bool(true, "Tint candles by state", group=groupVisual)
showBands = input.bool(true, "Show adaptive bands", group=groupVisual)
showRegression = input.bool(false, "Show regression channel", group=groupVisual)
showCloud = input.bool(true, "Show trend cloud", group=groupVisual)
showPivotMarks = input.bool(false, "Show compact pivot marks", group=groupVisual)

groupHud = "Dashboard"
showHud = input.bool(true, "Show Sentinel HUD", group=groupHud)
hudSizeInput = input.string("Small", "HUD size", options=["Tiny", "Small", "Normal"], group=groupHud)

groupPerf = "Performance"
maxEventLabels = input.int(44, "Maximum labels", minval=20, maxval=250, group=groupPerf)
maxRiskLines = input.int(48, "Maximum risk lines", minval=20, maxval=240, group=groupPerf)
maxSignalBoxes = input.int(20, "Maximum signal boxes", minval=10, maxval=100, group=groupPerf)

//--------------------------------------------------------------------------
// Utility functions
//--------------------------------------------------------------------------
f_clamp(float value, float lo, float hi) =>
    math.min(math.max(value, lo), hi)

f_score_color(float score) =>
    score >= 82 ? controlColor : score >= minScore ? strongBullColor : neutralColor

f_dir_color(int direction, float strength) =>
    direction == 1 ? color.from_gradient(f_clamp(strength, 0.0, 1.0), 0.0, 1.0, bullColor, strongBullColor) :
     direction == -1 ? color.from_gradient(f_clamp(strength, 0.0, 1.0), 0.0, 1.0, bearColor, strongBearColor) :
     neutralColor

f_regime_text(int state) =>
    state == 1 ? "BULL CONTROL" : state == -1 ? "BEAR CONTROL" : "BALANCED"

f_quality_text(float score) =>
    score >= 85 ? "A-TIER" : score >= 75 ? "ACTIVE" : score >= minScore ? "WATCH" : "WAIT"

f_size(string choice) =>
    choice == "Tiny" ? size.tiny : choice == "Normal" ? size.normal : size.small

f_trim_labels(array<label> store, int maxCount) =>
    while array.size(store) > maxCount
        label oldLabel = array.shift(store)
        label.delete(oldLabel)

f_trim_lines(array<line> store, int maxCount) =>
    while array.size(store) > maxCount
        line oldLine = array.shift(store)
        line.delete(oldLine)

f_trim_boxes(array<box> store, int maxCount) =>
    while array.size(store) > maxCount
        box oldBox = array.shift(store)
        box.delete(oldBox)

f_new_rail(array<line> store, int x1, float y, int x2, color railColor, string styleKind, int width) =>
    line rail = line.new(x1, y, x2, y, xloc=xloc.bar_index, extend=extend.none, color=railColor, style=styleKind, width=width)
    array.push(store, rail)

//--------------------------------------------------------------------------
// Preset handling and adaptive core
//--------------------------------------------------------------------------
presetFactor =
     preset == "Scalping" ? 0.78 :
     preset == "Swing" ? 1.18 :
     preset == "High-Volatility" ? 1.32 :
     preset == "Low-Noise" ? 1.08 :
     preset == "Visual Showcase" ? 0.92 :
     1.0

trendLen = math.max(8, int(math.round(trendLenInput * presetFactor)))
bandMult = bandMultInput * (preset == "High-Volatility" ? 1.18 : preset == "Scalping" ? 0.88 : 1.0)

atr = ta.atr(atrLen)
atrAvg = ta.sma(atr, math.max(atrLen * 2, 20))
atrRatio = atrAvg > 0.0 ? atr / atrAvg : 1.0
atrNorm = f_clamp(atrRatio, 0.65, 1.85)

fastBasis = ta.ema(src, math.max(2, int(math.round(trendLen * 0.45))))
slowBasis = ta.ema(src, trendLen)
effMove = math.abs(src - src[trendLen])
effNoise = ta.sma(math.abs(src - src[1]), trendLen) * trendLen
efficiency = effNoise > 0.0 ? f_clamp(effMove / effNoise, 0.0, 1.0) : 0.0
basis = slowBasis + (fastBasis - slowBasis) * efficiency

bandWidth = atr * bandMult * atrNorm
upperBand = basis + bandWidth
lowerBand = basis - bandWidth
innerUpper = basis + bandWidth * 0.42
innerLower = basis - bandWidth * 0.42

//--------------------------------------------------------------------------
// Structure, transition probability, and regime state
//--------------------------------------------------------------------------
ph = ta.pivothigh(high, pivotLeft, pivotRight)
pl = ta.pivotlow(low, pivotLeft, pivotRight)

var float lastSwingHigh = na
var float lastSwingLow = na
var int lastSwingHighBar = na
var int lastSwingLowBar = na

if not na(ph)
    lastSwingHigh := ph
    lastSwingHighBar := bar_index - pivotRight

if not na(pl)
    lastSwingLow := pl
    lastSwingLowBar := bar_index - pivotRight

bullImpulse = close > basis and close > close[1] and close >= high - (high - low) * 0.32
bearImpulse = close < basis and close < close[1] and close <= low + (high - low) * 0.32
bullPressure = ta.sma(bullImpulse ? 1.0 : 0.0, markovLen)
bearPressure = ta.sma(bearImpulse ? 1.0 : 0.0, markovLen)
transitionEdge = bullPressure - bearPressure

[plusDI, minusDI, adxValue] = ta.dmi(dmiLen, dmiLen)
directionalBias = plusDI > minusDI ? 1 : minusDI > plusDI ? -1 : 0

regBase = ta.linreg(src, regLen, 0)
regSlope = regBase - regBase[1]
regDev = ta.stdev(src - regBase, regLen)
regUpper = regBase + regDev * 1.45
regLower = regBase - regDev * 1.45
regBias = regSlope > 0 ? 1 : regSlope < 0 ? -1 : 0

bullHold = math.sum(close > upperBand ? 1.0 : 0.0, holdBars) == holdBars
bearHold = math.sum(close < lowerBand ? 1.0 : 0.0, holdBars) == holdBars

var int regime = 0
priorRegime = nz(regime[1], 0)
candidateRegime = priorRegime
if bullHold and transitionEdge > -0.12
    candidateRegime := 1
else if bearHold and transitionEdge < 0.12
    candidateRegime := -1
else if priorRegime == 1 and close < innerLower and transitionEdge < -0.18
    candidateRegime := 0
else if priorRegime == -1 and close > innerUpper and transitionEdge > 0.18
    candidateRegime := 0

chochUp = barstate.isconfirmed and not na(lastSwingHigh) and close > lastSwingHigh and close[1] <= lastSwingHigh
chochDn = barstate.isconfirmed and not na(lastSwingLow) and close < lastSwingLow and close[1] >= lastSwingLow

shiftUp = barstate.isconfirmed and priorRegime != 1 and candidateRegime == 1
shiftDn = barstate.isconfirmed and priorRegime != -1 and candidateRegime == -1

if barstate.isconfirmed
    regime := candidateRegime

//--------------------------------------------------------------------------
// Confluence score for actionable shifts
//--------------------------------------------------------------------------
distAtr = atr > 0.0 ? math.abs(close - basis) / atr : 0.0
locationScoreBull = close > basis ? 14.0 : close > innerLower ? 7.0 : 0.0
locationScoreBear = close < basis ? 14.0 : close < innerUpper ? 7.0 : 0.0
structureScoreBull = chochUp ? 22.0 : not na(lastSwingHigh) and close > lastSwingHigh ? 14.0 : 0.0
structureScoreBear = chochDn ? 22.0 : not na(lastSwingLow) and close < lastSwingLow ? 14.0 : 0.0
trendScoreBull = regBias == 1 ? 18.0 : regBias == 0 ? 8.0 : 0.0
trendScoreBear = regBias == -1 ? 18.0 : regBias == 0 ? 8.0 : 0.0
powerScoreBull = f_clamp((transitionEdge + 0.5) * 28.0, 0.0, 28.0)
powerScoreBear = f_clamp((0.5 - transitionEdge) * 28.0, 0.0, 28.0)
adxScore = f_clamp(adxValue / 35.0, 0.0, 1.0) * 18.0
volScore = atrNorm >= 0.8 and atrNorm <= 1.65 ? 10.0 : 4.0

bullScore = locationScoreBull + structureScoreBull + trendScoreBull + powerScoreBull + adxScore + volScore
bearScore = locationScoreBear + structureScoreBear + trendScoreBear + powerScoreBear + adxScore + volScore

var int lastShiftSignalBar = na
signalCooldownReady = na(lastShiftSignalBar) or bar_index - lastShiftSignalBar > signalCooldownBars
longTrigger = barstate.isconfirmed and signalCooldownReady and (shiftUp or allowChochEntries and chochUp and candidateRegime >= 0) and bullScore >= minScore
shortTrigger = barstate.isconfirmed and signalCooldownReady and (shiftDn or allowChochEntries and chochDn and candidateRegime <= 0) and bearScore >= minScore
if longTrigger or shortTrigger
    lastShiftSignalBar := bar_index

activeDir = longTrigger ? 1 : shortTrigger ? -1 : regime
activeScore = longTrigger ? bullScore : shortTrigger ? bearScore : regime == 1 ? bullScore : regime == -1 ? bearScore : math.max(bullScore, bearScore)

//--------------------------------------------------------------------------
// Risk rails and object management
//--------------------------------------------------------------------------
longStop = math.min(ta.lowest(low, stopLookback), lowerBand) - atr * stopAtrBuffer
shortStop = math.max(ta.highest(high, stopLookback), upperBand) + atr * stopAtrBuffer
longRisk = math.max(close - longStop, syminfo.mintick)
shortRisk = math.max(shortStop - close, syminfo.mintick)
longTp1 = close + longRisk * tpOneR
longTp2 = close + longRisk * tpTwoR
longTp3 = close + longRisk * tpThreeR
shortTp1 = close - shortRisk * tpOneR
shortTp2 = close - shortRisk * tpTwoR
shortTp3 = close - shortRisk * tpThreeR

var array<label> eventLabels = array.new<label>()
var array<line> riskRails = array.new<line>()
var array<box> signalZones = array.new<box>()

if (longTrigger or shortTrigger) and showRiskRails
    signalDir = longTrigger ? 1 : -1
    signalColor = signalDir == 1 ? bullColor : bearColor
    rewardColor = strongBullColor
    riskColor = strongBearColor
    entryPrice = close
    stopPrice = signalDir == 1 ? longStop : shortStop
    tpOnePrice = signalDir == 1 ? longTp1 : shortTp1
    tpTwoPrice = signalDir == 1 ? longTp2 : shortTp2
    railEnd = bar_index + railBars
    rewardTop = math.max(entryPrice, tpTwoPrice)
    rewardBottom = math.min(entryPrice, tpTwoPrice)
    riskTop = math.max(entryPrice, stopPrice)
    riskBottom = math.min(entryPrice, stopPrice)
    array.push(signalZones, box.new(bar_index, rewardTop, railEnd, rewardBottom, xloc=xloc.bar_index, border_color=color.new(rewardColor, 18), bgcolor=color.new(rewardColor, 88)))
    array.push(signalZones, box.new(bar_index, riskTop, railEnd, riskBottom, xloc=xloc.bar_index, border_color=color.new(riskColor, 18), bgcolor=color.new(riskColor, 88)))
    f_new_rail(riskRails, bar_index, entryPrice, railEnd, color.new(color.white, 0), line.style_solid, 2)
    f_new_rail(riskRails, bar_index, stopPrice, railEnd, color.new(riskColor, 0), line.style_solid, 2)
    f_new_rail(riskRails, bar_index, tpOnePrice, railEnd, color.new(bullColor, 4), line.style_solid, 1)
    f_new_rail(riskRails, bar_index, tpTwoPrice, railEnd, color.new(rewardColor, 0), line.style_solid, 2)
    planText = (signalDir == 1 ? "BUY SHIFT" : "SELL SHIFT") + "\nQ " + str.tostring(math.round(signalDir == 1 ? bullScore : bearScore)) + "\nEntry " + str.tostring(entryPrice, format.mintick) + "\nStop " + str.tostring(stopPrice, format.mintick) + "\nTP1 " + str.tostring(tpOnePrice, format.mintick) + "\nTP2 " + str.tostring(tpTwoPrice, format.mintick)
    array.push(eventLabels, label.new(railEnd, entryPrice, planText, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(signalColor, 8), textcolor=color.white, size=size.small))

if showSignalLabels and longTrigger
    label longLabel = label.new(bar_index, low - atr * 0.18, "LONG\nQ " + str.tostring(math.round(bullScore)), xloc=xloc.bar_index, style=label.style_label_up, color=color.new(bullColor, 8), textcolor=color.white, size=f_size(hudSizeInput))
    array.push(eventLabels, longLabel)

if showSignalLabels and shortTrigger
    label shortLabel = label.new(bar_index, high + atr * 0.18, "SHORT\nQ " + str.tostring(math.round(bearScore)), xloc=xloc.bar_index, style=label.style_label_down, color=color.new(bearColor, 8), textcolor=color.white, size=f_size(hudSizeInput))
    array.push(eventLabels, shortLabel)

if showSignalLabels and showPivotMarks and not na(ph)
    label highMark = label.new(bar_index - pivotRight, ph, "Swing High", xloc=xloc.bar_index, style=label.style_label_down, color=color.new(bearColor, 35), textcolor=color.white, size=size.tiny)
    array.push(eventLabels, highMark)

if showSignalLabels and showPivotMarks and not na(pl)
    label lowMark = label.new(bar_index - pivotRight, pl, "Swing Low", xloc=xloc.bar_index, style=label.style_label_up, color=color.new(bullColor, 35), textcolor=color.white, size=size.tiny)
    array.push(eventLabels, lowMark)

f_trim_labels(eventLabels, maxEventLabels)
f_trim_lines(riskRails, maxRiskLines)
f_trim_boxes(signalZones, maxSignalBoxes)

//--------------------------------------------------------------------------
// Visual rendering
//--------------------------------------------------------------------------
strengthBlend = f_clamp(distAtr / 2.4, 0.0, 1.0)
stateColor = f_dir_color(regime, strengthBlend)
scoreTint = activeDir == 1 ? color.from_gradient(f_clamp(activeScore / 100.0, 0.0, 1.0), 0.0, 1.0, bullColor, strongBullColor) :
     activeDir == -1 ? color.from_gradient(f_clamp(activeScore / 100.0, 0.0, 1.0), 0.0, 1.0, bearColor, strongBearColor) :
     neutralColor

barcolor(showCandleTint ? color.new(scoreTint, regime == 0 ? 28 : 0) : na)

bandColor = regime == 1 ? bullColor : regime == -1 ? bearColor : volColor
basisPlot = plot(basis, "Sentinel basis", color=color.new(controlColor, 0), linewidth=2)
upperGlowPlot = plot(showBands ? upperBand : na, "Upper band glow", color=color.new(bandColor, 80), linewidth=5)
lowerGlowPlot = plot(showBands ? lowerBand : na, "Lower band glow", color=color.new(bandColor, 80), linewidth=5)
upperPlot = plot(showBands ? upperBand : na, "Upper sentinel band", color=color.new(bandColor, 8), linewidth=1)
lowerPlot = plot(showBands ? lowerBand : na, "Lower sentinel band", color=color.new(bandColor, 8), linewidth=1)
innerUpperPlot = plot(showBands ? innerUpper : na, "Upper control band", color=color.new(controlColor, 62), linewidth=1)
innerLowerPlot = plot(showBands ? innerLower : na, "Lower control band", color=color.new(controlColor, 62), linewidth=1)
fill(upperGlowPlot, lowerGlowPlot, color=showCloud ? color.new(bandColor, regime == 0 ? 93 : 88) : na, title="Sentinel cloud")
fill(innerUpperPlot, innerLowerPlot, color=showCloud ? color.new(controlColor, 94) : na, title="Control core")

regPlot = plot(showRegression ? regBase : na, "Regression spine", color=color.new(controlColor, 10), linewidth=2)
regUpPlot = plot(showRegression ? regUpper : na, "Regression upper", color=color.new(bullColor, 42), linewidth=1)
regDnPlot = plot(showRegression ? regLower : na, "Regression lower", color=color.new(bearColor, 42), linewidth=1)
fill(regUpPlot, regDnPlot, color=showRegression ? color.new(volColor, 92) : na, title="Regression field")

plot(lastSwingHigh, "Last structure high", color=color.new(bearColor, 70), linewidth=1, style=plot.style_linebr)
plot(lastSwingLow, "Last structure low", color=color.new(bullColor, 70), linewidth=1, style=plot.style_linebr)

//--------------------------------------------------------------------------
// HUD
//--------------------------------------------------------------------------
var table sentinelHud = table.new(position.top_right, 2, 8, frame_color=hudBorder, border_color=hudBorder, bgcolor=hudBg)

if barstate.islast and showHud
    table.cell(sentinelHud, 0, 0, "SENTINEL SHIFT", text_color=color.white, bgcolor=color.new(controlColor, 60), text_size=f_size(hudSizeInput))
    table.cell(sentinelHud, 1, 0, "JOAT", text_color=color.white, bgcolor=color.new(volColor, 70), text_size=f_size(hudSizeInput))
    table.cell(sentinelHud, 0, 1, "Regime", text_color=color.white, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(sentinelHud, 1, 1, f_regime_text(regime), text_color=stateColor, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(sentinelHud, 0, 2, "Score", text_color=color.white, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(sentinelHud, 1, 2, str.tostring(math.round(activeScore)) + " / " + f_quality_text(activeScore), text_color=f_score_color(activeScore), bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(sentinelHud, 0, 3, "Transition", text_color=color.white, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(sentinelHud, 1, 3, str.tostring(transitionEdge, format.mintick), text_color=transitionEdge >= 0 ? bullColor : bearColor, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(sentinelHud, 0, 4, "ADX / ATR", text_color=color.white, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(sentinelHud, 1, 4, str.tostring(adxValue, format.mintick) + " / " + str.tostring(atrNorm, format.mintick), text_color=adxValue > 20 ? controlColor : neutralColor, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(sentinelHud, 0, 5, "Regression", text_color=color.white, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(sentinelHud, 1, 5, regBias == 1 ? "RISING" : regBias == -1 ? "FALLING" : "FLAT", text_color=regBias == 1 ? bullColor : regBias == -1 ? bearColor : neutralColor, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(sentinelHud, 0, 6, "Structure", text_color=color.white, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(sentinelHud, 1, 6, chochUp ? "BULL CHoCH" : chochDn ? "BEAR CHoCH" : "STABLE", text_color=chochUp ? bullColor : chochDn ? bearColor : neutralColor, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(sentinelHud, 0, 7, "Bias", text_color=color.white, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(sentinelHud, 1, 7, directionalBias == 1 ? "+DI LEAD" : directionalBias == -1 ? "-DI LEAD" : "EVEN", text_color=directionalBias == 1 ? bullColor : directionalBias == -1 ? bearColor : neutralColor, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))

//--------------------------------------------------------------------------
// Alerts
//--------------------------------------------------------------------------
alertcondition(longTrigger, "HRC long shift", "Helix Regime Corridor [JOAT] confirmed a long shift with confluence.")
alertcondition(shortTrigger, "HRC short shift", "Helix Regime Corridor [JOAT] confirmed a short shift with confluence.")
alertcondition(shiftUp, "HRC bull regime", "Helix Regime Corridor [JOAT] changed to bullish control.")
alertcondition(shiftDn, "HRC bear regime", "Helix Regime Corridor [JOAT] changed to bearish control.")
alertcondition(chochUp, "HRC bullish CHoCH", "Helix Regime Corridor [JOAT] confirmed bullish structure change.")
alertcondition(chochDn, "HRC bearish CHoCH", "Helix Regime Corridor [JOAT] confirmed bearish structure change.")
````
