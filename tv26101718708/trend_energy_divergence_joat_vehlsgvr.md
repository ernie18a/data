# Trend Energy Divergence [JOAT]

- url: https://www.tradingview.com/script/vehlsGvr-Trend-Energy-Divergence-JOAT/
- type: indicator
- pine_id: PUB;9ba97b586d91410fbccd3d2c4822fbd9
- version: 1.0

## Description

[b]Trend Energy Divergence [JOAT][/b]

[b]Introduction[/b]

TED Trend Energy Divergence is an open-source oscillator that measures trend energy from EMA spread, linear-regression slope, projected support/resistance pressure, confirmed structure, and pivot divergence.

The indicator is built for trend-quality context. It shows whether the current move has internal energy, whether structure agrees with that energy, and whether confirmed divergence is appearing against it.

[image]https://www.tradingview.com/x/8HWY4Zje/[/image]

[b]Core Concepts[/b]

[b]1. Normalized EMA Spread[/b]
Fast and slow EMA spread is normalized by ATR so the oscillator adapts across symbols and timeframes.

[b]2. Slope Pressure[/b]
Linear-regression slope contributes directional pressure to the energy model.

[b]3. Projected Support and Resistance[/b]
Confirmed pivots build simple projected support and resistance references. Closing beyond those projections adds break pressure.

[b]4. Confirmed Divergence[/b]
Pivot highs and lows are compared with oscillator values at the pivot offset to identify bullish or bearish divergence.

[b]5. Energy Signal Line[/b]
Trend energy is smoothed and compared with a signal line to show positive or negative shifts.

[b]Features[/b]

[list]
[*][b]ATR-normalized energy:[/b] Adapts the oscillator to volatility
[*][b]EMA and slope model:[/b] Blends trend spread and regression pressure
[*][b]Structure-aware pressure:[/b] Adds support/resistance break pressure
[*][b]Confirmed divergence:[/b] Uses confirmed pivots and offset oscillator values
[*][b]Regime dashboard:[/b] Shows trend, expansion, or balance context
[*][b]Projected levels:[/b] Displays pane-level support and resistance projections
[*][b]Alerts:[/b] Includes bull shift, bear shift, and divergence confirmations
[/list]

[b]Input Parameters[/b]

[b]Trend Engine:[/b]
[list]
[*]Fast EMA
[*]Slow EMA
[*]Signal Smoothing
[*]Energy Smoothing
[*]ATR Length
[*]Slope Length
[/list]

[b]Structure:[/b]
[list]
[*]Pivot Left and Pivot Right
[*]Structure Lookback
[*]ADX/DMI Trend Threshold
[/list]

[b]How to Use[/b]

[b]Step 1:[/b] Read the oscillator relative to the zero line and signal line.

[b]Step 2:[/b] Treat upper/lower confirmation bands as higher-conviction energy zones.

[b]Step 3:[/b] Watch divergence states as early warnings that the current move may be losing quality.

[b]Step 4:[/b] Use the dashboard to confirm whether the environment is Trend, Expansion, or Balance.

[b]Limitations[/b]

[list]
[*]Divergence confirms after pivots confirm, so it is intentionally delayed
[*]Oscillators can remain extended during strong trends
[*]Projected support/resistance is model-based, not a guaranteed reaction point
[*]The indicator is not a complete trade management system
[/list]

[b]Originality Statement[/b]

TED is an original JOAT oscillator combining ATR-normalized trend spread, slope, projected structure pressure, and confirmed divergence into one Pine Script v6 energy model.

[b]Disclaimer[/b]

This script is for educational and informational purposes only. It is not financial advice and does not guarantee future results. Trading involves risk, and users should apply their own risk management.

Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Trend Energy Divergence [JOAT]", "TED [JOAT]", overlay=false, max_bars_back=500, max_lines_count=25, max_labels_count=25)

//-----------------------------------------------------------------------------
// Inputs
//-----------------------------------------------------------------------------
tedGroupTrend = "Trend Engine"
tedGroupStructure = "Structure"
tedGroupSignals = "Signals"
tedGroupVisuals = "Visuals"
tedGroupDash = "Dashboard"

fastLen = input.int(12, "Fast EMA", minval=1, group=tedGroupTrend)
slowLen = input.int(34, "Slow EMA", minval=2, group=tedGroupTrend)
signalLen = input.int(9, "Signal Smoothing", minval=1, group=tedGroupTrend)
energyLen = input.int(8, "Energy Smoothing", minval=1, group=tedGroupTrend)
atrLen = input.int(14, "ATR Length", minval=1, group=tedGroupTrend)
slopeLen = input.int(20, "Slope Length", minval=2, group=tedGroupTrend)

pivotLeft = input.int(3, "Pivot Left", minval=1, group=tedGroupStructure)
pivotRight = input.int(3, "Pivot Right", minval=1, group=tedGroupStructure)
structureLen = input.int(55, "Structure Lookback", minval=5, group=tedGroupStructure)
adxLen = input.int(14, "ADX Length", minval=1, group=tedGroupStructure)
adxTrend = input.float(18.0, "Trend Threshold", minval=1.0, step=0.5, group=tedGroupStructure)

upperBand = input.float(1.25, "Upper Confirmation", minval=0.1, step=0.05, group=tedGroupSignals)
lowerBand = input.float(-1.25, "Lower Confirmation", minval=-10.0, step=0.05, group=tedGroupSignals)
showAlerts = input.bool(true, "Enable Alerts", group=tedGroupSignals)
showImpulse = input.bool(true, "Show Impulse Rail", group=tedGroupVisuals)

showDashboard = input.bool(true, "Show Dashboard", group=tedGroupDash)
dashboardTransp = input.int(82, "Dashboard Transparency", minval=0, maxval=100, group=tedGroupDash)

bullColor = input.color(color.rgb(32, 196, 159), "Bull Color", group=tedGroupVisuals)
bearColor = input.color(color.rgb(240, 90, 112), "Bear Color", group=tedGroupVisuals)
signalColor = input.color(color.rgb(240, 190, 85), "Signal Color", group=tedGroupVisuals)
neutralColor = input.color(color.rgb(160, 170, 185), "Neutral Color", group=tedGroupVisuals)
violetColor = input.color(color.rgb(166, 120, 255), "Divergence Color", group=tedGroupVisuals)
zeroColor = input.color(color.rgb(88, 98, 118), "Zero Color", group=tedGroupVisuals)

//-----------------------------------------------------------------------------
// Helpers
//-----------------------------------------------------------------------------
f_clamp(float v, float lo, float hi) =>
    math.min(math.max(v, lo), hi)

f_norm(float v, float scale) =>
    scale == 0.0 ? 0.0 : v / scale

f_regimeText(float adxValue, float atrPct, float spreadValue, float atrPctAvg, float trendThreshold) =>
    adxValue >= trendThreshold and math.abs(spreadValue) > 0.2 ? "Trend" : atrPct > atrPctAvg ? "Expansion" : "Balance"

//-----------------------------------------------------------------------------
// Core series
//-----------------------------------------------------------------------------
atrValue = ta.atr(atrLen)
atrSafe = math.max(atrValue, syminfo.mintick)

fastEma = ta.ema(close, fastLen)
slowEma = ta.ema(close, slowLen)
signalEma = ta.ema(ta.ema(close, fastLen) - ta.ema(close, slowLen), signalLen)

emaSpread = fastEma - slowEma
emaSpreadNorm = f_norm(emaSpread, atrSafe)
signalNorm = f_norm(signalEma, atrSafe)

linNow = ta.linreg(close, slopeLen, 0)
linPrev = ta.linreg(close, slopeLen, 1)
slopeValue = linNow - linPrev
slopeNorm = f_norm(slopeValue, atrSafe)

[diPlus, diMinus, adxValue] = ta.dmi(adxLen, adxLen)
atrPct = f_norm(atrValue, close)
atrPctAvg = nz(ta.sma(atrPct, structureLen), atrPct)
regimeText = f_regimeText(adxValue, atrPct, emaSpreadNorm, atrPctAvg, adxTrend)

//-----------------------------------------------------------------------------
// Confirmed structure tracking
//-----------------------------------------------------------------------------
ph = ta.pivothigh(high, pivotLeft, pivotRight)
pl = ta.pivotlow(low, pivotLeft, pivotRight)

var float prevHighPivot = na
var float lastHighPivot = na
var int prevHighBar = na
var int lastHighBar = na

var float prevLowPivot = na
var float lastLowPivot = na
var int prevLowBar = na
var int lastLowBar = na

if not na(ph)
    prevHighPivot := lastHighPivot
    prevHighBar := lastHighBar
    lastHighPivot := ph
    lastHighBar := bar_index - pivotRight

if not na(pl)
    prevLowPivot := lastLowPivot
    prevLowBar := lastLowBar
    lastLowPivot := pl
    lastLowBar := bar_index - pivotRight

bullStructure = not na(lastHighPivot) and not na(prevHighPivot) and not na(lastLowPivot) and not na(prevLowPivot) and lastHighPivot > prevHighPivot and lastLowPivot > prevLowPivot
bearStructure = not na(lastHighPivot) and not na(prevHighPivot) and not na(lastLowPivot) and not na(prevLowPivot) and lastHighPivot < prevHighPivot and lastLowPivot < prevLowPivot
structureBias = bullStructure ? 1.0 : bearStructure ? -1.0 : 0.0

//-----------------------------------------------------------------------------
// Support and resistance trendline projections from confirmed pivots
//-----------------------------------------------------------------------------
var float resSlope = na
var float resIntercept = na
var float supSlope = na
var float supIntercept = na

if not na(ph) and not na(prevHighPivot) and not na(prevHighBar) and not na(lastHighBar)
    highBars = lastHighBar - prevHighBar
    if highBars > 0
        resSlope := (lastHighPivot - prevHighPivot) / highBars
        resIntercept := lastHighPivot - resSlope * lastHighBar

if not na(pl) and not na(prevLowPivot) and not na(prevLowBar) and not na(lastLowBar)
    lowBars = lastLowBar - prevLowBar
    if lowBars > 0
        supSlope := (lastLowPivot - prevLowPivot) / lowBars
        supIntercept := lastLowPivot - supSlope * lastLowBar

resLevel = not na(resSlope) and not na(resIntercept) ? resSlope * bar_index + resIntercept : na
supLevel = not na(supSlope) and not na(supIntercept) ? supSlope * bar_index + supIntercept : na

breakPressure = 0.0
if not na(resLevel) and close > resLevel
    breakPressure += f_clamp((close - resLevel) / atrSafe, 0.0, 3.0)
if not na(supLevel) and close < supLevel
    breakPressure -= f_clamp((supLevel - close) / atrSafe, 0.0, 3.0)

//-----------------------------------------------------------------------------
// Divergence tracking on confirmed pivots
//-----------------------------------------------------------------------------
var float lastBearDivPrice = na
var float lastBearDivOsc = na
var float lastBullDivPrice = na
var float lastBullDivOsc = na
var bool bullDivergence = false
var bool bearDivergence = false

bullDivergence := false
bearDivergence := false

oscAtPivotHigh = not na(ph) ? (emaSpreadNorm[pivotRight] + slopeNorm[pivotRight] + signalNorm[pivotRight]) : na
oscAtPivotLow = not na(pl) ? (emaSpreadNorm[pivotRight] + slopeNorm[pivotRight] + signalNorm[pivotRight]) : na

if not na(ph) and not na(oscAtPivotHigh)
    bearDivergence := not na(lastBearDivPrice) and ph > lastBearDivPrice and oscAtPivotHigh < lastBearDivOsc
    lastBearDivPrice := ph
    lastBearDivOsc := oscAtPivotHigh

if not na(pl) and not na(oscAtPivotLow)
    bullDivergence := not na(lastBullDivPrice) and pl < lastBullDivPrice and oscAtPivotLow > lastBullDivOsc
    lastBullDivPrice := pl
    lastBullDivOsc := oscAtPivotLow

divergenceBias = bullDivergence ? 1.0 : bearDivergence ? -1.0 : 0.0

//-----------------------------------------------------------------------------
// Trend energy model
//-----------------------------------------------------------------------------
structureWindow = ta.highest(high, structureLen) - ta.lowest(low, structureLen)
structureRangeNorm = f_norm(structureWindow, atrSafe)

rawEnergy =
     emaSpreadNorm * 0.70 +
     slopeNorm * 0.35 +
     signalNorm * 0.20 +
     breakPressure * 0.95 +
     structureBias * 0.80 +
     divergenceBias * 0.70 +
     math.sign(close - ta.sma(close, slowLen)) * 0.20 +
     f_clamp(structureRangeNorm, 0.0, 3.0) * 0.05

trendEnergy = ta.ema(rawEnergy, energyLen)
trendSignal = ta.ema(trendEnergy, signalLen)
trendDelta = trendEnergy - trendSignal

energyUp = trendDelta > 0 and trendEnergy > upperBand
energyDown = trendDelta < 0 and trendEnergy < lowerBand
energyScore = f_clamp(50.0 + trendEnergy * 18.0 + trendDelta * 22.0, 0.0, 100.0)
impulseState = energyScore >= 70 ? 1 : energyScore <= 30 ? -1 : 0

confirmedBullShift = barstate.isconfirmed and energyUp and (bullStructure or breakPressure > 0) and not bearDivergence
confirmedBearShift = barstate.isconfirmed and energyDown and (bearStructure or breakPressure < 0) and not bullDivergence

//-----------------------------------------------------------------------------
// Visuals
//-----------------------------------------------------------------------------
hline(0.0, "Zero", color=zeroColor, linestyle=hline.style_dotted)
hline(upperBand, "Upper", color=color.new(bullColor, 65), linestyle=hline.style_dashed)
hline(lowerBand, "Lower", color=color.new(bearColor, 65), linestyle=hline.style_dashed)
hline(2.0, "Exhaustion Upper", color=color.new(violetColor, 78), linestyle=hline.style_dotted)
hline(-2.0, "Exhaustion Lower", color=color.new(violetColor, 78), linestyle=hline.style_dotted)

histColor =
     trendEnergy >= 0 and trendDelta >= 0 ? color.new(bullColor, 10) :
     trendEnergy >= 0 and trendDelta < 0 ? color.new(bullColor, 45) :
     trendEnergy < 0 and trendDelta <= 0 ? color.new(bearColor, 10) :
     color.new(bearColor, 45)

energyPlot = plot(trendEnergy, "Trend Energy", color=histColor, style=plot.style_columns, linewidth=2)
signalPlot = plot(trendSignal, "Signal", color=color.new(signalColor, 0), linewidth=2)
deltaPlot = plot(trendDelta, "Energy Delta", color=color.new(trendDelta >= 0 ? bullColor : bearColor, 20), linewidth=2)
pressurePlot = plot(breakPressure, "Normalized Break Pressure", color=color.new(violetColor, 0), linewidth=1, style=plot.style_area)
zeroPlot = plot(0.0, "Baseline", color=color.new(zeroColor, 100), display=display.none)
fill(energyPlot, signalPlot, color=trendEnergy >= trendSignal ? color.new(bullColor, 82) : color.new(bearColor, 82))
fill(energyPlot, zeroPlot, color=trendEnergy >= 0 ? color.new(bullColor, 88) : color.new(bearColor, 88))
plot(showImpulse and confirmedBullShift ? lowerBand : na, "Confirmed Bull Shift", color=color.new(bullColor, 0), linewidth=4, style=plot.style_circles)
plot(showImpulse and confirmedBearShift ? upperBand : na, "Confirmed Bear Shift", color=color.new(bearColor, 0), linewidth=4, style=plot.style_circles)
plot(showImpulse and bullDivergence ? 0.0 : na, "Bull Divergence Pulse", color=color.new(violetColor, 0), linewidth=3, style=plot.style_circles)
plot(showImpulse and bearDivergence ? 0.0 : na, "Bear Divergence Pulse", color=color.new(violetColor, 0), linewidth=3, style=plot.style_circles)

bgcolor(impulseState > 0 ? color.new(bullColor, 91) : impulseState < 0 ? color.new(bearColor, 91) : bullDivergence ? color.new(violetColor, 90) : bearDivergence ? color.new(violetColor, 90) : na)

//-----------------------------------------------------------------------------
// Alerts
//-----------------------------------------------------------------------------
alertcondition(showAlerts and confirmedBullShift, "TED Bull Shift", "Trend Energy Divergence turned bullish on a confirmed bar.")
alertcondition(showAlerts and confirmedBearShift, "TED Bear Shift", "Trend Energy Divergence turned bearish on a confirmed bar.")
alertcondition(showAlerts and bullDivergence, "TED Bull Divergence", "Confirmed bullish divergence detected.")
alertcondition(showAlerts and bearDivergence, "TED Bear Divergence", "Confirmed bearish divergence detected.")

//-----------------------------------------------------------------------------
// Dashboard
//-----------------------------------------------------------------------------
var table dash = table.new(position.top_right, 2, 9, frame_color=color.new(color.rgb(28, 34, 46), dashboardTransp), border_color=color.new(color.rgb(65, 75, 92), dashboardTransp))

if showDashboard and barstate.islast
    trendStateText = confirmedBullShift ? "Bull Shift" : confirmedBearShift ? "Bear Shift" : trendDelta > 0 ? "Positive" : trendDelta < 0 ? "Negative" : "Flat"
    structureText = bullStructure ? "HH / HL" : bearStructure ? "LH / LL" : "Mixed"
    divText = bullDivergence ? "Bull Divergence" : bearDivergence ? "Bear Divergence" : "None"
    regimeColor = regimeText == "Trend" ? color.new(signalColor, 0) : regimeText == "Expansion" ? color.new(bullColor, 0) : color.new(neutralColor, 0)
    energyColor = trendEnergy >= 0 ? color.new(bullColor, 0) : color.new(bearColor, 0)
    biasColor = structureBias > 0 ? color.new(bullColor, 0) : structureBias < 0 ? color.new(bearColor, 0) : color.new(neutralColor, 0)
    divColor = bullDivergence ? color.new(bullColor, 0) : bearDivergence ? color.new(bearColor, 0) : color.new(neutralColor, 0)
    scoreColor = trendEnergy > trendSignal ? color.new(bullColor, 0) : color.new(bearColor, 0)

    table.cell(dash, 0, 0, "TED", text_color=color.white, bgcolor=color.new(color.rgb(20, 24, 32), dashboardTransp))
    table.cell(dash, 1, 0, "Trend Energy", text_color=color.white, bgcolor=color.new(color.rgb(20, 24, 32), dashboardTransp))

    table.cell(dash, 0, 1, "Regime", text_color=color.white, bgcolor=color.new(color.rgb(24, 28, 38), dashboardTransp))
    table.cell(dash, 1, 1, regimeText, text_color=regimeColor, bgcolor=color.new(color.rgb(24, 28, 38), dashboardTransp))

    table.cell(dash, 0, 2, "Structure", text_color=color.white, bgcolor=color.new(color.rgb(24, 28, 38), dashboardTransp))
    table.cell(dash, 1, 2, structureText, text_color=biasColor, bgcolor=color.new(color.rgb(24, 28, 38), dashboardTransp))

    table.cell(dash, 0, 3, "Energy", text_color=color.white, bgcolor=color.new(color.rgb(24, 28, 38), dashboardTransp))
    table.cell(dash, 1, 3, str.tostring(trendEnergy, format.mintick), text_color=energyColor, bgcolor=color.new(color.rgb(24, 28, 38), dashboardTransp))

    table.cell(dash, 0, 4, "Signal", text_color=color.white, bgcolor=color.new(color.rgb(24, 28, 38), dashboardTransp))
    table.cell(dash, 1, 4, str.tostring(trendSignal, format.mintick), text_color=scoreColor, bgcolor=color.new(color.rgb(24, 28, 38), dashboardTransp))

    table.cell(dash, 0, 5, "Divergence", text_color=color.white, bgcolor=color.new(color.rgb(24, 28, 38), dashboardTransp))
    table.cell(dash, 1, 5, divText, text_color=divColor, bgcolor=color.new(color.rgb(24, 28, 38), dashboardTransp))

    table.cell(dash, 0, 6, "State", text_color=color.white, bgcolor=color.new(color.rgb(24, 28, 38), dashboardTransp))
    table.cell(dash, 1, 6, trendStateText, text_color=scoreColor, bgcolor=color.new(color.rgb(24, 28, 38), dashboardTransp))

    table.cell(dash, 0, 7, "Score", text_color=color.white, bgcolor=color.new(color.rgb(24, 28, 38), dashboardTransp))
    table.cell(dash, 1, 7, str.tostring(energyScore, "#"), text_color=energyScore >= 70 ? bullColor : energyScore <= 30 ? bearColor : neutralColor, bgcolor=color.new(color.rgb(24, 28, 38), dashboardTransp))

    table.cell(dash, 0, 8, "Pressure", text_color=color.white, bgcolor=color.new(color.rgb(24, 28, 38), dashboardTransp))
    table.cell(dash, 1, 8, str.tostring(breakPressure, "#.00"), text_color=breakPressure > 0 ? bullColor : breakPressure < 0 ? bearColor : neutralColor, bgcolor=color.new(color.rgb(24, 28, 38), dashboardTransp))
````
