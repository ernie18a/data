# Cobalt Session Ledger [JOAT]

- url: https://www.tradingview.com/script/ylsVK9tx-Cobalt-Session-Ledger-JOAT/
- type: indicator
- pine_id: PUB;300699b10ba0454bb0bbc47d67d47997
- version: 1.0

## Description

[b]Cobalt Session Ledger [JOAT][/b]

[b]Introduction[/b]

Cobalt Session Ledger is an open-source intraday context indicator focused on session VWAP, synthetic volume delta, liquidity sweeps, absorption, and managed visual trade mapping. It is designed to help users read whether current price action is extending, reverting, sweeping liquidity, or building pressure around the active session's value area.

The script uses a modern dark chart style with cyan, teal, red, amber, and violet accents. It includes VWAP sigma bands, session CVD, sweep and absorption markers, candle coloring, reward/risk boxes, right-side entry/stop/target labels, and a top-right dashboard.

[image]https://www.tradingview.com/x/Qt0mf3IJ/[/image]

[b]Core Concepts[/b]

[b]1. Session VWAP and Sigma Bands[/b]

The session engine accumulates price-volume data during the configured session and computes VWAP. It also derives deviation bands around VWAP so price can be evaluated in sigma terms rather than raw distance.

[pine]
// Conceptual summary
// VWAP = cumulative price * volume / cumulative volume
// sigma bands = VWAP +/- session deviation multiples
[/pine]

[b]2. Synthetic Delta and Session CVD[/b]

Because TradingView symbols often lack true bid/ask delta, the script estimates directional pressure from candle body position, close position, range, and volume. That value is accumulated into a session CVD line and smoothed for dashboard and signal context.

[b]3. Liquidity Sweep Detection[/b]

Confirmed sweeps occur when price probes beyond a recent swing high or low and closes back through it with directional rejection. These events are shown with clean square/circle markers rather than arrows.

[b]4. Absorption and Wick Skew[/b]

Absorption combines volume expansion, compact candle range, and close location. Wick skew helps describe whether rejection is occurring from the upper or lower side of the candle.

[b]5. Managed Ledger Map[/b]

When a confirmed ledger signal appears, the indicator can draw a reward zone, risk zone, entry line, stop line, and T1/T2/T3 targets at the right edge. These are visual planning aids, not executed orders.

[b]Features[/b]

[list]
[*][b]Session VWAP engine:[/b] Uses the configured session and timezone
[*][b]VWAP sigma rails:[/b] Displays inner and outer VWAP deviation shells
[*][b]Session CVD:[/b] Tracks synthetic volume pressure during the session
[*][b]Liquidity sweeps:[/b] Detects confirmed reclaim/rejection events around recent pivots
[*][b]Absorption markers:[/b] Highlights volume compression and close-location absorption
[*][b]Confidence scoring:[/b] Combines VWAP, delta, structure, absorption, volume, and session context
[*][b]Managed trade map:[/b] Draws entry, stop, T1, T2, T3, reward box, and risk box
[*][b]Candle tinting:[/b] Colors bars based on confidence and directional pressure
[*][b]Top-right dashboard:[/b] Shows VWAP, CVD, delta, liquidity, confidence, sigma, entry, targets, and session range
[*][b]Confirmed-bar signals:[/b] Ledger signals are gated with barstate.isconfirmed
[/list]

[b]Input Parameters[/b]

[b]Session:[/b]
[list]
[*]Session Window
[*]Session Timezone
[/list]

[b]Liquidity and Absorption:[/b]
[list]
[*]Liquidity Pivot Length
[*]Volume Spike Multiplier
[*]Absorption Range Ceiling
[*]Bull/Bear Absorption Close Bias
[/list]

[b]Trade Map:[/b]
[list]
[*]Show Managed Trade Map
[*]Show Right-Side Price Labels
[*]Trade Box Projection Bars
[*]Target 1, 2, and 3 R multiples
[*]Signal Cooldown Bars
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Start with VWAP[/b]
Read whether price is above, below, or stretched from session VWAP.

[b]Step 2: Confirm pressure[/b]
Use the CVD and delta rows to determine whether volume pressure supports the price location.

[b]Step 3: Watch sweeps and absorption[/b]
Sweep and absorption events can mark potential exhaustion or reclaim zones.

[b]Step 4: Treat trade boxes as planning overlays[/b]
The ledger box gives a structured visual reference for risk and reward. It does not ensure that the market will reach any level.

[b]Indicator Limitations[/b]

[list]
[*]Synthetic delta is an estimate, not true exchange bid/ask delta
[*]Signals are session-context tools, not automatic trade instructions
[*]Quiet symbols and low-volume sessions can reduce signal quality
[*]The managed trade map is visual only
[/list]

[b]Originality Statement[/b]

Cobalt Session Ledger combines session VWAP sigma analysis, synthetic CVD, sweep/reclaim logic, absorption detection, wick skew, confidence scoring, candle tinting, and managed visual trade mapping into a single open-source Pine v6 session tool. The components work together to classify session pressure and price location rather than act as unrelated overlays.

[b]Disclaimer[/b]

This script is for educational and informational use only. It is not financial advice or a recommendation to buy or sell any instrument. Trading involves risk, and historical context does not ensure future behavior.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Cobalt Session Ledger [JOAT]", "CSL [JOAT]", overlay=true, max_labels_count=180, max_lines_count=260, max_boxes_count=80)

// -----------------------------------------------------------------------------
// Inputs
// -----------------------------------------------------------------------------
sessionSpec      = input.session("0930-1600", "Session Window")
sessionTz        = input.string("America/New_York", "Session Timezone")
pivotLen         = input.int(5, "Liquidity Pivot Length", minval=2, maxval=20)
atrLen           = input.int(14, "ATR Length", minval=1)
volumeLen        = input.int(20, "Volume Baseline Length", minval=5)
deltaSmooth      = input.int(8, "Delta Smoothing", minval=1)
zoneInnerMult    = input.float(0.75, "Inner Zone ATR", minval=0.1, step=0.05)
zoneOuterMult    = input.float(1.55, "Outer Zone ATR", minval=0.2, step=0.05)
volSpikeMult     = input.float(1.55, "Volume Spike Multiplier", minval=0.5, step=0.05)
absorbRangeMult  = input.float(0.78, "Absorption Range Ceiling", minval=0.2, step=0.02)
absorbCloseHi    = input.float(0.68, "Bull Absorption Close Bias", minval=0.5, maxval=0.95, step=0.01)
absorbCloseLo    = input.float(0.32, "Bear Absorption Close Bias", minval=0.05, maxval=0.5, step=0.01)
sigmaSmoothLen   = input.int(5, "VWAP Sigma Smoothing", minval=1, maxval=50)
sigmaOneMult     = input.float(1.0, "VWAP Sigma One", minval=0.25, step=0.05)
sigmaTwoMult     = input.float(2.0, "VWAP Sigma Two", minval=0.50, step=0.05)
sigmaThreeMult   = input.float(3.0, "VWAP Sigma Three", minval=0.75, step=0.05)
showSigmaThree   = input.bool(true, "Show Outer Sigma Envelope")
showTradeMap     = input.bool(true, "Show Managed Trade Map")
showRightLabels  = input.bool(true, "Show Right-Side Price Labels")
projectionBars   = input.int(36, "Trade Box Projection Bars", minval=8, maxval=150)
labelOffset      = input.int(3, "Right Label Offset", minval=1, maxval=25)
rrOne            = input.float(1.00, "Target 1 R Multiple", minval=0.25, step=0.25)
rrTwo            = input.float(1.75, "Target 2 R Multiple", minval=0.50, step=0.25)
rrThree          = input.float(2.60, "Target 3 R Multiple", minval=0.75, step=0.25)
signalCooldown   = input.int(8, "Signal Cooldown Bars", minval=0, maxval=100)

// -----------------------------------------------------------------------------
// Colors
// -----------------------------------------------------------------------------
cBg            = color.rgb(10, 14, 20)
cPanel         = color.rgb(16, 22, 31)
cLineBase      = color.rgb(101, 120, 145)
cCyan          = color.rgb(0, 207, 255)
cTeal          = color.rgb(0, 191, 168)
cLime          = color.rgb(112, 214, 127)
cAmber         = color.rgb(255, 184, 77)
cOrange        = color.rgb(255, 122, 69)
cRed           = color.rgb(231, 76, 60)
cRose          = color.rgb(255, 64, 129)
cBlue          = color.rgb(31, 146, 255)
cViolet        = color.rgb(173, 132, 255)
cGrid          = color.rgb(48, 58, 72)
cMuted         = color.rgb(115, 125, 140)
cSoftBull      = color.new(cTeal, 82)
cSoftBear      = color.new(cRed, 82)
cSoftPulse     = color.new(cAmber, 86)

// -----------------------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------------------
f_clamp11(x) =>
    math.max(-1.0, math.min(1.0, x))

f_clamp01(x) =>
    math.max(0.0, math.min(1.0, x))

f_safeDiv(num, den) =>
    den == 0.0 ? 0.0 : num / den

f_delta(_o, _h, _l, _c, _v) =>
    _range = math.max(_h - _l, syminfo.mintick)
    _closePos = f_safeDiv((_c - _l) - (_h - _c), _range)
    _bodyPos = f_safeDiv(_c - _o, _range)
    _bodyRatio = f_clamp01(math.abs(_c - _o) / _range)
    _impulse = 0.68 * _bodyPos + 0.32 * _closePos
    _v * f_clamp11(_impulse) * (0.30 + 0.70 * _bodyRatio)

f_scoreText(score) =>
    score >= 80 ? "Apex" :
     score >= 65 ? "Firm" :
     score >= 50 ? "Balanced" :
     score >= 35 ? "Soft" : "Dull"

f_fmt(x) =>
    na(x) ? "n/a" : str.tostring(x, format.mintick)

f_biasText(x) =>
    x > 0.35 ? "Bull Control" :
     x < -0.35 ? "Bear Control" : "Two-Way"

f_deleteLine(_ln) =>
    if not na(_ln)
        line.delete(_ln)

f_deleteLabel(_lb) =>
    if not na(_lb)
        label.delete(_lb)

f_deleteBox(_bx) =>
    if not na(_bx)
        box.delete(_bx)

// -----------------------------------------------------------------------------
// Session state
// -----------------------------------------------------------------------------
inSession  = not na(time(timeframe.period, sessionSpec, sessionTz))
newSession = inSession and not inSession[1]

priceSrc   = hlc3
atr        = ta.atr(atrLen)
atrSafe    = math.max(nz(atr, syminfo.mintick), syminfo.mintick)
rangeSafe  = math.max(high - low, syminfo.mintick)

var float sessionPV = na
var float sessionPV2 = na
var float sessionV  = na
var float sessionVWAP = na
var float sessionHigh = na
var float sessionLow = na
var int sessionStartBar = na

if newSession
    sessionPV := priceSrc * volume
    sessionPV2 := priceSrc * priceSrc * volume
    sessionV := volume
    sessionVWAP := priceSrc
    sessionHigh := high
    sessionLow := low
    sessionStartBar := bar_index
else if inSession
    sessionPV := nz(sessionPV[1]) + priceSrc * volume
    sessionPV2 := nz(sessionPV2[1]) + priceSrc * priceSrc * volume
    sessionV := nz(sessionV[1]) + volume
    sessionVWAP := f_safeDiv(sessionPV, math.max(sessionV, 1.0))
    sessionHigh := math.max(nz(sessionHigh[1], high), high)
    sessionLow := math.min(nz(sessionLow[1], low), low)
    sessionStartBar := nz(sessionStartBar[1], bar_index)
else
    sessionPV := nz(sessionPV[1])
    sessionPV2 := nz(sessionPV2[1])
    sessionV := nz(sessionV[1])
    sessionVWAP := nz(sessionVWAP[1])
    sessionHigh := nz(sessionHigh[1])
    sessionLow := nz(sessionLow[1])
    sessionStartBar := nz(sessionStartBar[1])

vwapVarianceRaw = math.max(f_safeDiv(sessionPV2, math.max(sessionV, 1.0)) - sessionVWAP * sessionVWAP, 0.0)
vwapSigmaRaw = math.sqrt(vwapVarianceRaw)
vwapSigma = ta.ema(vwapSigmaRaw, sigmaSmoothLen)
sigmaSafe = math.max(nz(vwapSigma, atrSafe * 0.35), syminfo.mintick)
sigma1Upper = sessionVWAP + sigmaSafe * sigmaOneMult
sigma1Lower = sessionVWAP - sigmaSafe * sigmaOneMult
sigma2Upper = sessionVWAP + sigmaSafe * sigmaTwoMult
sigma2Lower = sessionVWAP - sigmaSafe * sigmaTwoMult
sigma3Upper = sessionVWAP + sigmaSafe * sigmaThreeMult
sigma3Lower = sessionVWAP - sigmaSafe * sigmaThreeMult
sigmaPosition = f_clamp11(f_safeDiv(close - sessionVWAP, math.max(sigmaSafe * 2.0, syminfo.mintick)))
sigmaState = close >= sigma2Upper ? 2 : close >= sigma1Upper ? 1 : close <= sigma2Lower ? -2 : close <= sigma1Lower ? -1 : 0

// -----------------------------------------------------------------------------
// Synthetic delta and CVD
// -----------------------------------------------------------------------------
syntheticDelta = f_delta(open, high, low, close, volume)
deltaBasis     = ta.ema(syntheticDelta, deltaSmooth)
deltaSpread    = ta.stdev(syntheticDelta, deltaSmooth)
deltaSpreadSafe = math.max(nz(deltaSpread, 1.0), 1.0)
deltaNorm      = f_safeDiv(syntheticDelta - nz(deltaBasis, syntheticDelta), deltaSpreadSafe)
var float sessionCVD = na
sessionCVD := newSession ? syntheticDelta : inSession ? nz(sessionCVD[1], 0.0) + syntheticDelta : nz(sessionCVD[1], 0.0)
cvdSignal = ta.ema(sessionCVD, math.max(deltaSmooth * 2, 2))
cvdSlope = sessionCVD - nz(sessionCVD[1], sessionCVD)
cvdPulse = f_clamp11(f_safeDiv(sessionCVD - cvdSignal, math.max(ta.ema(math.abs(sessionCVD - cvdSignal), volumeLen), 1.0)))
cvdCompression = f_clamp01(1.0 - f_safeDiv(math.abs(cvdSlope), math.max(ta.ema(math.abs(cvdSlope), volumeLen), 1.0)))

// ----------------------------------------------------------------------------- 
// Candle anatomy
// ----------------------------------------------------------------------------- 
upperWick  = high - math.max(open, close)
lowerWick  = math.min(open, close) - low
wickSkew   = f_safeDiv(lowerWick - upperWick, rangeSafe)

// -----------------------------------------------------------------------------
// Liquidity structure
// -----------------------------------------------------------------------------
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float swingHigh = na
var float swingLow = na

if not na(ph)
    swingHigh := ph
if not na(pl)
    swingLow := pl

bearSweepRaw = barstate.isconfirmed and not na(swingHigh) and high > swingHigh and close < swingHigh and close < open
bullSweepRaw = barstate.isconfirmed and not na(swingLow) and low < swingLow and close > swingLow and close > open

bearSweep = bearSweepRaw
bullSweep = bullSweepRaw
bullReclaim = bullSweep and close > open and wickSkew > 0.10 and close > nz(sessionVWAP, close)
bearReclaim = bearSweep and close < open and wickSkew < -0.10 and close < nz(sessionVWAP, close)

// -----------------------------------------------------------------------------
// Absorption logic
// -----------------------------------------------------------------------------
volBasis   = ta.sma(volume, volumeLen)
volRatio   = f_safeDiv(volume, math.max(nz(volBasis, volume), 1.0))
closeBias  = f_safeDiv(close - low, rangeSafe)
compactness = f_clamp01(1.0 - f_safeDiv(rangeSafe, math.max(atrSafe * absorbRangeMult, syminfo.mintick)))

bullAbsorbRaw = barstate.isconfirmed and volRatio >= volSpikeMult and compactness > 0.35 and closeBias >= absorbCloseHi and syntheticDelta > 0
bearAbsorbRaw = barstate.isconfirmed and volRatio >= volSpikeMult and compactness > 0.35 and closeBias <= absorbCloseLo and syntheticDelta < 0

bullAbsorb = bullAbsorbRaw
bearAbsorb = bearAbsorbRaw
liquidityPressure = bullSweep ? 1.0 : bearSweep ? -1.0 : bullAbsorb ? 0.65 : bearAbsorb ? -0.65 : 0.0
absorptionText = bullAbsorb ? "Bull Absorb" : bearAbsorb ? "Bear Absorb" : bullSweep ? "Bull Sweep" : bearSweep ? "Bear Sweep" : "Neutral"

// -----------------------------------------------------------------------------
// Confidence model
// -----------------------------------------------------------------------------
vwapBias  = na(sessionVWAP) ? 0.0 : f_clamp11(f_safeDiv(close - sessionVWAP, math.max(atrSafe * 1.25, syminfo.mintick)))
deltaBias = f_clamp11(f_safeDiv(deltaNorm, 2.0))
cvdBias = cvdPulse
structBias = bullSweep ? 1.0 : bearSweep ? -1.0 : 0.0
absorbBias = bullAbsorb ? 0.65 : bearAbsorb ? -0.65 : 0.0
volBias = f_clamp11((volRatio - 1.0) / 1.6)
sessionBias = inSession ? 0.20 : -0.05

confidenceRaw = 50.0 + 16.0 * vwapBias + 15.0 * deltaBias + 13.0 * cvdBias + 18.0 * structBias + 10.0 * absorbBias + 8.0 * volBias + 5.0 * sessionBias
confidence = math.max(0.0, math.min(100.0, confidenceRaw))

directionScore = 0.32 * vwapBias + 0.25 * deltaBias + 0.18 * cvdBias + 0.17 * structBias + 0.08 * absorbBias
directionBlend = f_clamp11(directionScore)

// -----------------------------------------------------------------------------
// Trade rails and zones
// -----------------------------------------------------------------------------
innerBand = atrSafe * zoneInnerMult
outerBand = atrSafe * zoneOuterMult

zoneBullInner = sessionVWAP - innerBand
zoneBullOuter = sessionVWAP - outerBand
zoneBearInner = sessionVWAP + innerBand
zoneBearOuter = sessionVWAP + outerBand
zoneMidUpper = sessionVWAP + atrSafe * 0.12
zoneMidLower = sessionVWAP - atrSafe * 0.12

zoneRole = na(sessionVWAP) ? 0 : close > sessionVWAP ? 1 : close < sessionVWAP ? -1 : 0

// -----------------------------------------------------------------------------
// Visual system
// -----------------------------------------------------------------------------
vwapColor = directionBlend >= 0 ? color.from_gradient(directionBlend, 0.0, 1.0, cCyan, cTeal) : color.from_gradient(-directionBlend, 0.0, 1.0, cOrange, cRed)
sigmaColor = color.from_gradient(sigmaPosition, -1.0, 1.0, cRed, cTeal)
zoneColor = zoneRole > 0 ? color.new(cTeal, 84) : zoneRole < 0 ? color.new(cRed, 84) : color.new(cAmber, 88)
lineColor = confidence >= 70 ? cCyan : confidence >= 50 ? cAmber : cLineBase

vwapPlot = plot(inSession ? sessionVWAP : na, "Session VWAP", color=vwapColor, linewidth=2)
sigUp1Plot = plot(inSession ? sigma1Upper : na, "VWAP Sigma +1", color=color.new(cCyan, 62), linewidth=1)
sigDn1Plot = plot(inSession ? sigma1Lower : na, "VWAP Sigma -1", color=color.new(cTeal, 62), linewidth=1)
sigUp2Plot = plot(inSession ? sigma2Upper : na, "VWAP Sigma +2", color=color.new(cOrange, 50), linewidth=1)
sigDn2Plot = plot(inSession ? sigma2Lower : na, "VWAP Sigma -2", color=color.new(cBlue, 50), linewidth=1)
sigUp3Plot = plot(inSession and showSigmaThree ? sigma3Upper : na, "VWAP Sigma +3", color=color.new(cRed, 42), linewidth=1)
sigDn3Plot = plot(inSession and showSigmaThree ? sigma3Lower : na, "VWAP Sigma -3", color=color.new(cLime, 42), linewidth=1)
bullOuterPlot = plot(inSession ? zoneBullOuter : na, "Bull Outer", color=color.new(cTeal, 90), linewidth=1)
bullInnerPlot = plot(inSession ? zoneBullInner : na, "Bull Inner", color=color.new(cTeal, 80), linewidth=1)
bearInnerPlot = plot(inSession ? zoneBearInner : na, "Bear Inner", color=color.new(cRed, 80), linewidth=1)
bearOuterPlot = plot(inSession ? zoneBearOuter : na, "Bear Outer", color=color.new(cRed, 90), linewidth=1)

fill(sigUp1Plot, sigUp2Plot, color=color.new(cOrange, 88), title="Upper Sigma Wash")
fill(sigDn2Plot, sigDn1Plot, color=color.new(cTeal, 88), title="Lower Sigma Wash")
fill(sigUp2Plot, sigUp3Plot, color=color.new(cRed, 92), title="Extreme Upper Sigma Wash")
fill(sigDn3Plot, sigDn2Plot, color=color.new(cLime, 92), title="Extreme Lower Sigma Wash")
fill(bullOuterPlot, bullInnerPlot, color=color.new(cTeal, 86), title="Bull Zone Fill")
fill(bearInnerPlot, bearOuterPlot, color=color.new(cRed, 86), title="Bear Zone Fill")
fill(vwapPlot, bullInnerPlot, color=color.new(cTeal, 93), title="Lower Rail Wash")
fill(vwapPlot, bearInnerPlot, color=color.new(cRed, 93), title="Upper Rail Wash")

plot(sessionHigh, "Session High", color=color.new(cAmber, 70), linewidth=1, style=plot.style_linebr)
plot(sessionLow, "Session Low", color=color.new(cAmber, 70), linewidth=1, style=plot.style_linebr)
plot(zoneMidUpper, "Mid Upper", color=color.new(cLineBase, 82), linewidth=1, style=plot.style_linebr)
plot(zoneMidLower, "Mid Lower", color=color.new(cLineBase, 82), linewidth=1, style=plot.style_linebr)

barTint = color.from_gradient(confidence, 0.0, 100.0, color.new(cRed, 0), color.new(cTeal, 0))
barcolor(barTint)

bgcolor(confidence >= 82 and zoneRole > 0 ? color.new(cTeal, 92) : confidence >= 82 and zoneRole < 0 ? color.new(cRed, 92) : confidence >= 65 ? color.new(cAmber, 95) : na)

plotshape(bullAbsorb, "Bull Absorption Core", shape.circle, location.belowbar, color.new(cTeal, 0), size=size.tiny)
plotshape(bullAbsorb, "Bull Absorption Glow", shape.circle, location.belowbar, color.new(cTeal, 72), size=size.small)
plotshape(bearAbsorb, "Bear Absorption Core", shape.circle, location.abovebar, color.new(cRed, 0), size=size.tiny)
plotshape(bearAbsorb, "Bear Absorption Glow", shape.circle, location.abovebar, color.new(cRed, 72), size=size.small)
plotshape(bullSweep, "Bull Sweep Square", shape.square, location.belowbar, color.new(cLime, 5), size=size.tiny)
plotshape(bearSweep, "Bear Sweep Square", shape.square, location.abovebar, color.new(cRose, 5), size=size.tiny)

// -----------------------------------------------------------------------------
// Signals
// -----------------------------------------------------------------------------
var int lastSignalBar = na
cooldownReady = na(lastSignalBar) or bar_index - lastSignalBar > signalCooldown
primeBullContext = confidence >= 72 and not na(sessionVWAP) and close > sessionVWAP and syntheticDelta > nz(deltaBasis, syntheticDelta) and sessionCVD >= cvdSignal and sigmaPosition > -0.35
primeBearContext = confidence >= 72 and not na(sessionVWAP) and close < sessionVWAP and syntheticDelta < nz(deltaBasis, syntheticDelta) and sessionCVD <= cvdSignal and sigmaPosition < 0.35
bullLedgerSignal = barstate.isconfirmed and cooldownReady and primeBullContext and not bearSweep and (bullReclaim or bullAbsorb or sigmaState <= 0)
bearLedgerSignal = barstate.isconfirmed and cooldownReady and primeBearContext and not bullSweep and (bearReclaim or bearAbsorb or sigmaState >= 0)

if bullLedgerSignal or bearLedgerSignal
    lastSignalBar := bar_index

plotshape(bullLedgerSignal, "Long Ledger Diamond", shape.diamond, location.belowbar, color.new(cCyan, 0), size=size.small, text="")
plotshape(bearLedgerSignal, "Short Ledger Diamond", shape.diamond, location.abovebar, color.new(cOrange, 0), size=size.small, text="")

// -----------------------------------------------------------------------------
// Managed trade boxes and right-side entry/stop/target rails
// -----------------------------------------------------------------------------
var int tradeDir = 0
var int tradeStartBar = na
var bool tradeLive = false
var float tradeEntry = na
var float tradeStop = na
var float tradeTarget1 = na
var float tradeTarget2 = na
var float tradeTarget3 = na
var box tradeBodyBox = na
var box tradeRiskBox = na
var line tradeEntryLine = na
var line tradeStopLine = na
var line tradeTarget1Line = na
var line tradeTarget2Line = na
var line tradeTarget3Line = na
var label tradeEntryLabel = na
var label tradeStopLabel = na
var label tradeTarget1Label = na
var label tradeTarget2Label = na
var label tradeTarget3Label = na
var label tradeStateLabel = na

newTradeSignal = showTradeMap and (bullLedgerSignal or bearLedgerSignal)

if newTradeSignal
    f_deleteBox(tradeBodyBox)
    f_deleteBox(tradeRiskBox)
    f_deleteLine(tradeEntryLine)
    f_deleteLine(tradeStopLine)
    f_deleteLine(tradeTarget1Line)
    f_deleteLine(tradeTarget2Line)
    f_deleteLine(tradeTarget3Line)
    f_deleteLabel(tradeEntryLabel)
    f_deleteLabel(tradeStopLabel)
    f_deleteLabel(tradeTarget1Label)
    f_deleteLabel(tradeTarget2Label)
    f_deleteLabel(tradeTarget3Label)
    f_deleteLabel(tradeStateLabel)
    tradeDir := bullLedgerSignal ? 1 : -1
    tradeStartBar := bar_index
    tradeLive := true
    tradeEntry := close
    longStopSeed = math.min(low, nz(sigma2Lower, low)) - atrSafe * 0.15
    shortStopSeed = math.max(high, nz(sigma2Upper, high)) + atrSafe * 0.15
    tradeStop := tradeDir == 1 ? longStopSeed : shortStopSeed
    riskUnit = math.max(math.abs(tradeEntry - tradeStop), atrSafe * 0.50)
    tradeTarget1 := tradeEntry + tradeDir * riskUnit * rrOne
    tradeTarget2 := tradeEntry + tradeDir * riskUnit * rrTwo
    tradeTarget3 := tradeEntry + tradeDir * riskUnit * rrThree
    rewardTop = math.max(tradeEntry, math.max(tradeTarget2, tradeTarget3))
    rewardBot = math.min(tradeEntry, math.min(tradeTarget2, tradeTarget3))
    riskTop = math.max(tradeEntry, tradeStop)
    riskBot = math.min(tradeEntry, tradeStop)
    tradeBodyBox := box.new(left=bar_index, top=rewardTop, right=bar_index + projectionBars, bottom=rewardBot, xloc=xloc.bar_index, border_color=tradeDir == 1 ? color.new(cTeal, 18) : color.new(cRed, 18), bgcolor=tradeDir == 1 ? color.new(cTeal, 86) : color.new(cRed, 86))
    tradeRiskBox := box.new(left=bar_index, top=riskTop, right=bar_index + projectionBars, bottom=riskBot, xloc=xloc.bar_index, border_color=tradeDir == 1 ? color.new(cRed, 22) : color.new(cTeal, 22), bgcolor=tradeDir == 1 ? color.new(cRed, 88) : color.new(cTeal, 88))
    tradeEntryLine := line.new(bar_index, tradeEntry, bar_index + labelOffset, tradeEntry, xloc=xloc.bar_index, extend=extend.none, color=cAmber, style=line.style_dashed, width=1)
    tradeStopLine := line.new(bar_index, tradeStop, bar_index + labelOffset, tradeStop, xloc=xloc.bar_index, extend=extend.none, color=cRed, style=line.style_solid, width=2)
    tradeTarget1Line := line.new(bar_index, tradeTarget1, bar_index + labelOffset, tradeTarget1, xloc=xloc.bar_index, extend=extend.none, color=tradeDir == 1 ? cTeal : cRed, style=line.style_dotted, width=1)
    tradeTarget2Line := line.new(bar_index, tradeTarget2, bar_index + labelOffset, tradeTarget2, xloc=xloc.bar_index, extend=extend.none, color=tradeDir == 1 ? cTeal : cRed, style=line.style_dotted, width=1)
    tradeTarget3Line := line.new(bar_index, tradeTarget3, bar_index + labelOffset, tradeTarget3, xloc=xloc.bar_index, extend=extend.none, color=tradeDir == 1 ? cTeal : cRed, style=line.style_solid, width=2)
    tradeEntryLabel := label.new(bar_index + labelOffset, tradeEntry, "Entry  " + f_fmt(tradeEntry), xloc=xloc.bar_index, yloc=yloc.price, color=color.new(cPanel, 0), style=label.style_label_left, textcolor=cAmber, size=size.small)
    tradeStopLabel := label.new(bar_index + labelOffset, tradeStop, "Stop  " + f_fmt(tradeStop), xloc=xloc.bar_index, yloc=yloc.price, color=color.new(cPanel, 0), style=label.style_label_left, textcolor=cRed, size=size.small)
    tradeTarget1Label := label.new(bar_index + labelOffset, tradeTarget1, "T1  " + f_fmt(tradeTarget1), xloc=xloc.bar_index, yloc=yloc.price, color=color.new(cPanel, 0), style=label.style_label_left, textcolor=tradeDir == 1 ? cTeal : cRed, size=size.small)
    tradeTarget2Label := label.new(bar_index + labelOffset, tradeTarget2, "T2  " + f_fmt(tradeTarget2), xloc=xloc.bar_index, yloc=yloc.price, color=color.new(cPanel, 0), style=label.style_label_left, textcolor=tradeDir == 1 ? cTeal : cRed, size=size.small)
    tradeTarget3Label := label.new(bar_index + labelOffset, tradeTarget3, "T3  " + f_fmt(tradeTarget3), xloc=xloc.bar_index, yloc=yloc.price, color=color.new(cPanel, 0), style=label.style_label_left, textcolor=tradeDir == 1 ? cTeal : cRed, size=size.small)
    tradeStateLabel := label.new(bar_index, tradeDir == 1 ? low - atrSafe * 0.55 : high + atrSafe * 0.55, tradeDir == 1 ? "Long Ledger" : "Short Ledger", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(cBg, 5), style=label.style_label_left, textcolor=tradeDir == 1 ? cTeal : cRed, size=size.small)

targetHit = barstate.isconfirmed and ((tradeLive and tradeDir == 1 and high >= tradeTarget3) or (tradeLive and tradeDir == -1 and low <= tradeTarget3))
stopHit = barstate.isconfirmed and ((tradeLive and tradeDir == 1 and low <= tradeStop) or (tradeLive and tradeDir == -1 and high >= tradeStop))
if targetHit or stopHit
    tradeLive := false

tradeColor = tradeDir == 1 ? cTeal : tradeDir == -1 ? cRed : cLineBase
tradeMutedColor = tradeLive ? tradeColor : cMuted
tradeRight = bar_index + labelOffset
tradeBoxRight = math.max(bar_index + labelOffset, nz(tradeStartBar, bar_index) + projectionBars)

if barstate.islast and showTradeMap and tradeDir != 0 and not na(tradeEntry) and not na(tradeBodyBox)
    rewardTopLive = math.max(tradeEntry, math.max(tradeTarget2, tradeTarget3))
    rewardBotLive = math.min(tradeEntry, math.min(tradeTarget2, tradeTarget3))
    riskTopLive = math.max(tradeEntry, tradeStop)
    riskBotLive = math.min(tradeEntry, tradeStop)
    box.set_lefttop(tradeBodyBox, tradeStartBar, rewardTopLive)
    box.set_rightbottom(tradeBodyBox, tradeBoxRight, rewardBotLive)
    box.set_lefttop(tradeRiskBox, tradeStartBar, riskTopLive)
    box.set_rightbottom(tradeRiskBox, tradeBoxRight, riskBotLive)
    box.set_bgcolor(tradeBodyBox, tradeLive ? (tradeDir == 1 ? color.new(cTeal, 86) : color.new(cRed, 86)) : color.new(cMuted, 92))
    box.set_bgcolor(tradeRiskBox, tradeLive ? (tradeDir == 1 ? color.new(cRed, 88) : color.new(cTeal, 88)) : color.new(cMuted, 94))
    line.set_xy1(tradeEntryLine, tradeStartBar, tradeEntry)
    line.set_xy2(tradeEntryLine, tradeRight, tradeEntry)
    line.set_xy1(tradeStopLine, tradeStartBar, tradeStop)
    line.set_xy2(tradeStopLine, tradeRight, tradeStop)
    line.set_xy1(tradeTarget1Line, tradeStartBar, tradeTarget1)
    line.set_xy2(tradeTarget1Line, tradeRight, tradeTarget1)
    line.set_xy1(tradeTarget2Line, tradeStartBar, tradeTarget2)
    line.set_xy2(tradeTarget2Line, tradeRight, tradeTarget2)
    line.set_xy1(tradeTarget3Line, tradeStartBar, tradeTarget3)
    line.set_xy2(tradeTarget3Line, tradeRight, tradeTarget3)
    label.set_xy(tradeEntryLabel, tradeRight, tradeEntry)
    label.set_text(tradeEntryLabel, "Entry  " + f_fmt(tradeEntry))
    label.set_xy(tradeStopLabel, tradeRight, tradeStop)
    label.set_text(tradeStopLabel, "Stop  " + f_fmt(tradeStop))
    label.set_xy(tradeTarget1Label, tradeRight, tradeTarget1)
    label.set_text(tradeTarget1Label, "T1  " + f_fmt(tradeTarget1))
    label.set_textcolor(tradeTarget1Label, tradeMutedColor)
    label.set_xy(tradeTarget2Label, tradeRight, tradeTarget2)
    label.set_text(tradeTarget2Label, "T2  " + f_fmt(tradeTarget2))
    label.set_textcolor(tradeTarget2Label, tradeMutedColor)
    label.set_xy(tradeTarget3Label, tradeRight, tradeTarget3)
    label.set_text(tradeTarget3Label, "T3  " + f_fmt(tradeTarget3))
    label.set_textcolor(tradeTarget3Label, tradeMutedColor)
    label.set_xy(tradeStateLabel, tradeRight, tradeDir == 1 ? low - atrSafe * 0.55 : high + atrSafe * 0.55)
    label.set_text(tradeStateLabel, tradeLive ? (tradeDir == 1 ? "Long Ledger" : "Short Ledger") : targetHit ? "Target Resolved" : stopHit ? "Stop Resolved" : "Paused Ledger")
    label.set_textcolor(tradeStateLabel, tradeMutedColor)

if barstate.islast and not showTradeMap
    f_deleteBox(tradeBodyBox)
    f_deleteBox(tradeRiskBox)
    f_deleteLine(tradeEntryLine)
    f_deleteLine(tradeStopLine)
    f_deleteLine(tradeTarget1Line)
    f_deleteLine(tradeTarget2Line)
    f_deleteLine(tradeTarget3Line)
    f_deleteLabel(tradeEntryLabel)
    f_deleteLabel(tradeStopLabel)
    f_deleteLabel(tradeTarget1Label)
    f_deleteLabel(tradeTarget2Label)
    f_deleteLabel(tradeTarget3Label)
    f_deleteLabel(tradeStateLabel)
    tradeBodyBox := na
    tradeRiskBox := na
    tradeEntryLine := na
    tradeStopLine := na
    tradeTarget1Line := na
    tradeTarget2Line := na
    tradeTarget3Line := na
    tradeEntryLabel := na
    tradeStopLabel := na
    tradeTarget1Label := na
    tradeTarget2Label := na
    tradeTarget3Label := na
    tradeStateLabel := na

alertcondition(bullLedgerSignal, "Cobalt Bull Ledger", "Cobalt Session Ledger bullish condition confirmed")
alertcondition(bearLedgerSignal, "Cobalt Bear Ledger", "Cobalt Session Ledger bearish condition confirmed")
alertcondition(bullSweep, "Cobalt Bull Sweep", "Cobalt Session Ledger detected a bullish liquidity sweep")
alertcondition(bearSweep, "Cobalt Bear Sweep", "Cobalt Session Ledger detected a bearish liquidity sweep")
alertcondition(bullAbsorb, "Cobalt Bull Absorption", "Cobalt Session Ledger detected bullish absorption")
alertcondition(bearAbsorb, "Cobalt Bear Absorption", "Cobalt Session Ledger detected bearish absorption")
alertcondition(targetHit, "Cobalt Target Resolved", "Cobalt Session Ledger managed target reached")
alertcondition(stopHit, "Cobalt Stop Resolved", "Cobalt Session Ledger managed stop reached")

// -----------------------------------------------------------------------------
// Dashboard
// -----------------------------------------------------------------------------
var table dash = table.new(position.top_right, 3, 14, bgcolor=color.new(cBg, 8), frame_color=color.new(cCyan, 65), frame_width=1, border_color=color.new(cGrid, 55), border_width=1)

if barstate.islast
    table.cell(dash, 0, 0, "Cobalt Session Ledger", text_color=color.white, bgcolor=color.new(cPanel, 0), text_size=size.normal)
    table.cell(dash, 1, 0, inSession ? "Live" : "Off", text_color=inSession ? cTeal : cAmber, bgcolor=color.new(cPanel, 0), text_size=size.normal)

    table.cell(dash, 0, 1, "VWAP", text_color=color.white, bgcolor=color.new(cPanel, 10), text_size=size.normal)
    table.cell(dash, 1, 1, str.tostring(sessionVWAP, format.mintick), text_color=vwapColor, bgcolor=color.new(cPanel, 10), text_size=size.normal)

    table.cell(dash, 0, 2, "CVD", text_color=color.white, bgcolor=color.new(cPanel, 10), text_size=size.normal)
    table.cell(dash, 1, 2, str.tostring(sessionCVD, format.mintick), text_color=directionBlend >= 0 ? cTeal : cRed, bgcolor=color.new(cPanel, 10), text_size=size.normal)

    table.cell(dash, 0, 3, "Delta", text_color=color.white, bgcolor=color.new(cPanel, 10), text_size=size.normal)
    table.cell(dash, 1, 3, str.tostring(syntheticDelta, format.mintick), text_color=syntheticDelta >= 0 ? cLime : cOrange, bgcolor=color.new(cPanel, 10), text_size=size.normal)

    table.cell(dash, 0, 4, "Liquidity", text_color=color.white, bgcolor=color.new(cPanel, 10), text_size=size.normal)
    table.cell(dash, 1, 4, bullSweep ? "Bull Sweep" : bearSweep ? "Bear Sweep" : bullAbsorb ? "Bull Absorb" : bearAbsorb ? "Bear Absorb" : "Neutral", text_color=bullSweep or bullAbsorb ? cTeal : bearSweep or bearAbsorb ? cRed : cAmber, bgcolor=color.new(cPanel, 10), text_size=size.normal)

    table.cell(dash, 0, 5, "Confidence", text_color=color.white, bgcolor=color.new(cPanel, 10), text_size=size.normal)
    table.cell(dash, 1, 5, str.tostring(confidence, "#.0") + " / 100", text_color=confidence >= 70 ? cTeal : confidence >= 50 ? cAmber : cRed, bgcolor=color.new(cPanel, 10), text_size=size.normal)

    table.cell(dash, 0, 6, "State", text_color=color.white, bgcolor=color.new(cPanel, 10), text_size=size.normal)
    table.cell(dash, 1, 6, f_scoreText(confidence), text_color=confidence >= 70 ? cTeal : confidence >= 50 ? cAmber : cLineBase, bgcolor=color.new(cPanel, 10), text_size=size.normal)

    table.cell(dash, 0, 7, "Zone", text_color=color.white, bgcolor=color.new(cPanel, 10), text_size=size.normal)
    table.cell(dash, 1, 7, zoneRole > 0 ? "Premium" : zoneRole < 0 ? "Discount" : "Balanced", text_color=zoneRole > 0 ? cOrange : zoneRole < 0 ? cTeal : cAmber, bgcolor=color.new(cPanel, 10), text_size=size.normal)

    table.cell(dash, 2, 0, f_scoreText(confidence), text_color=confidence >= 70 ? cTeal : confidence >= 50 ? cAmber : cRed, bgcolor=color.new(cPanel, 0), text_size=size.normal)
    table.cell(dash, 2, 1, f_biasText(directionBlend), text_color=directionBlend >= 0 ? cTeal : cRed, bgcolor=color.new(cPanel, 10), text_size=size.normal)
    table.cell(dash, 2, 2, cvdSlope >= 0 ? "CVD Rising" : "CVD Falling", text_color=cvdSlope >= 0 ? cTeal : cRed, bgcolor=color.new(cPanel, 10), text_size=size.normal)
    table.cell(dash, 2, 3, volRatio >= volSpikeMult ? "Spike" : "Base", text_color=volRatio >= volSpikeMult ? cAmber : cLineBase, bgcolor=color.new(cPanel, 10), text_size=size.normal)
    table.cell(dash, 2, 4, bullReclaim ? "Reclaim" : bearReclaim ? "Reject" : "Watch", text_color=bullReclaim ? cTeal : bearReclaim ? cRed : cLineBase, bgcolor=color.new(cPanel, 10), text_size=size.normal)
    table.cell(dash, 2, 5, str.tostring(sigmaPosition, "#.00") + " sigma", text_color=sigmaColor, bgcolor=color.new(cPanel, 10), text_size=size.normal)
    table.cell(dash, 2, 6, tradeLive ? "Trade Live" : tradeDir != 0 ? "Trade Idle" : "No Trade", text_color=tradeLive ? tradeColor : cLineBase, bgcolor=color.new(cPanel, 10), text_size=size.normal)
    table.cell(dash, 2, 7, "Stop " + f_fmt(tradeStop), text_color=cRed, bgcolor=color.new(cPanel, 10), text_size=size.normal)

    table.cell(dash, 0, 8, "Sigma +2", text_color=color.white, bgcolor=color.new(cPanel, 10), text_size=size.normal)
    table.cell(dash, 1, 8, f_fmt(sigma2Upper), text_color=cOrange, bgcolor=color.new(cPanel, 10), text_size=size.normal)
    table.cell(dash, 2, 8, "Sigma -2  " + f_fmt(sigma2Lower), text_color=cBlue, bgcolor=color.new(cPanel, 10), text_size=size.normal)

    table.cell(dash, 0, 9, "Entry", text_color=color.white, bgcolor=color.new(cPanel, 10), text_size=size.normal)
    table.cell(dash, 1, 9, f_fmt(tradeEntry), text_color=cAmber, bgcolor=color.new(cPanel, 10), text_size=size.normal)
    table.cell(dash, 2, 9, tradeDir == 1 ? "Long" : tradeDir == -1 ? "Short" : "None", text_color=tradeDir == 1 ? cTeal : tradeDir == -1 ? cRed : cLineBase, bgcolor=color.new(cPanel, 10), text_size=size.normal)

    table.cell(dash, 0, 10, "Targets", text_color=color.white, bgcolor=color.new(cPanel, 10), text_size=size.normal)
    table.cell(dash, 1, 10, "T1 " + f_fmt(tradeTarget1), text_color=tradeDir == 0 ? cLineBase : tradeColor, bgcolor=color.new(cPanel, 10), text_size=size.normal)
    table.cell(dash, 2, 10, "T3 " + f_fmt(tradeTarget3), text_color=tradeDir == 0 ? cLineBase : tradeColor, bgcolor=color.new(cPanel, 10), text_size=size.normal)

    table.cell(dash, 0, 11, "Absorption", text_color=color.white, bgcolor=color.new(cPanel, 10), text_size=size.normal)
    table.cell(dash, 1, 11, str.tostring(compactness * 100.0, "#.0") + "%", text_color=compactness > 0.35 ? cAmber : cLineBase, bgcolor=color.new(cPanel, 10), text_size=size.normal)
    table.cell(dash, 2, 11, "Wick " + str.tostring(wickSkew, "#.00"), text_color=wickSkew >= 0 ? cTeal : cRed, bgcolor=color.new(cPanel, 10), text_size=size.normal)

    table.cell(dash, 0, 12, "Session Range", text_color=color.white, bgcolor=color.new(cPanel, 10), text_size=size.normal)
    table.cell(dash, 1, 12, f_fmt(sessionHigh), text_color=cAmber, bgcolor=color.new(cPanel, 10), text_size=size.normal)
    table.cell(dash, 2, 12, f_fmt(sessionLow), text_color=cAmber, bgcolor=color.new(cPanel, 10), text_size=size.normal)

    table.cell(dash, 0, 13, "JOAT", text_color=cViolet, bgcolor=color.new(cBg, 0), text_size=size.normal)
    table.cell(dash, 1, 13, "Confirmed", text_color=color.white, bgcolor=color.new(cBg, 0), text_size=size.normal)
    table.cell(dash, 2, 13, "No Lookahead", text_color=cLineBase, bgcolor=color.new(cBg, 0), text_size=size.normal)
````
