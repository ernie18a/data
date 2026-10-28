# Obsidian Trend Relay [JOAT]

- url: https://www.tradingview.com/script/YH1DnW4I-Obsidian-Trend-Relay-JOAT/
- type: indicator
- pine_id: PUB;64baa338b7d64f74a482a06dc4739772
- version: 1.0

## Description

[b]Obsidian Trend Relay [JOAT][/b]

[b]Introduction[/b]

Obsidian Trend Relay is an open-source multi-timeframe trend and risk-ladder indicator. It combines zero-lag EMA logic, SuperTrend, an EMA ribbon, three higher-timeframe confirmation votes, prediction threshold rails, proximity warnings, candle coloring, risk ladder boxes, right-side price labels, and a top-right dashboard.

The script is built for users who want a directional trend context layer with structured visual planning. It does not claim to forecast price. Instead, it shows when local trend, ribbon structure, SuperTrend, and higher-timeframe votes align or conflict.

[image]https://www.tradingview.com/x/khzRKMcf/[/image]

[b]Core Concepts[/b]

[b]1. Zero-Lag EMA Core[/b]

The zero-lag component reduces the smoothing delay of a standard EMA by comparing the first EMA against a second smoothing pass. This creates a responsive trend anchor used for reclaim and rejection logic.

[pine]
// Conceptual summary
// zlema = 2 * ema(source, length) - ema(ema(source, length), length)
[/pine]

[b]2. SuperTrend and EMA Ribbon[/b]

SuperTrend provides an ATR-based directional rail. The EMA ribbon checks whether fast, mid, slow, and base averages are stacked in directional order. Both must be read together with the zero-lag line.

[b]3. Multi-Timeframe Relay Votes[/b]

Three higher-timeframe checks compare zero-lag and EMA structure using request.security() with lookahead off. The dashboard displays each vote and the total confluence score.

[b]4. Prediction and Proximity Rails[/b]

The prediction engine creates upper/lower threshold rails around the trend anchor. Proximity warnings identify when price is near a key transition rail and may be close to a directional decision point.

[b]5. Risk Ladder[/b]

When a relay signal appears, the script can draw a reward box, risk box, warning zone, entry, stop, and T1/T2/T3 rails. These are visual planning tools only.

[b]Features[/b]

[list]
[*][b]Zero-lag trend anchor:[/b] Responsive baseline for reclaim and rejection context
[*][b]SuperTrend filter:[/b] ATR-based directional rail
[*][b]EMA ribbon:[/b] Visual trend stack using multiple moving averages
[*][b]Three HTF votes:[/b] Higher-timeframe confluence with lookahead off
[*][b]Prediction rails:[/b] Upper/lower threshold bands around the zero-lag engine
[*][b]Proximity warning:[/b] Highlights price near key trend rails
[*][b]Risk ladder boxes:[/b] Draws risk, warning, reward, entry, stop, and T1/T2/T3 levels
[*][b]Gradient candle tinting:[/b] Colors candles from confluence and trend state
[*][b]Top-right dashboard:[/b] Shows local trend, ribbon, HTF votes, prediction, proximity, and ladder state
[*][b]Confirmed-bar logic:[/b] Relay and ladder events use confirmed bars
[/list]

[b]Input Parameters[/b]

[b]Trend Engine:[/b]
[list]
[*]Source
[*]Zero Lag Length
[*]SuperTrend ATR Length
[*]SuperTrend Factor
[*]Ribbon Fast, Mid, Slow, and Base lengths
[/list]

[b]MTF and Risk:[/b]
[list]
[*]Higher Timeframe 1, 2, and 3
[*]Minimum Confluence Votes
[*]Stop ATR Mult
[*]Target ATR Mult
[*]Show Risk Ladder
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Check confluence[/b]
Use the dashboard to see whether the local trend and higher timeframes agree.

[b]Step 2: Read the ribbon[/b]
A clean stacked ribbon provides stronger trend context than a mixed ribbon.

[b]Step 3: Watch proximity rails[/b]
Proximity warnings indicate price is near a transition threshold.

[b]Step 4: Treat the ladder as a visual plan[/b]
The risk ladder maps possible risk and reward levels, but it does not execute trades or ensure outcomes.

[b]Indicator Limitations[/b]

[list]
[*]Higher-timeframe values can update during an unfinished higher-timeframe candle
[*]Trend tools can lag during sharp reversals
[*]Risk ladder levels are visual only
[*]Sideways markets may generate mixed confluence readings
[/list]

[b]Originality Statement[/b]

Obsidian Trend Relay combines zero-lag trend anchoring, SuperTrend, EMA ribbon stacking, three higher-timeframe votes, prediction thresholds, proximity warnings, and managed risk ladders into one open-source Pine v6 trend relay. Its purpose is to organize trend alignment and risk visualization in one coherent chart layer.

[b]Disclaimer[/b]

This script is for educational and informational use only. It is not financial advice or a promise of future results. Always use independent judgment and risk management.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Obsidian Trend Relay [JOAT]", "OTR [JOAT]", overlay=true, max_labels_count=180, max_lines_count=260, max_boxes_count=80)

// -----------------------------------------------------------------------------
// Inputs
// -----------------------------------------------------------------------------
src            = input.source(close, "Source")
zlemaLen       = input.int(34, "Zero Lag Length", minval=2)
stAtrLen       = input.int(10, "SuperTrend ATR Length", minval=1)
stFactor       = input.float(3.0, "SuperTrend Factor", minval=0.5, step=0.1)
emaFastLen     = input.int(8, "Ribbon Fast", minval=1)
emaMidLen      = input.int(13, "Ribbon Mid", minval=1)
emaSlowLen     = input.int(21, "Ribbon Slow", minval=1)
emaBaseLen     = input.int(34, "Ribbon Base", minval=1)
riskAtrLen     = input.int(14, "Risk ATR Length", minval=1)
stopAtrMult    = input.float(1.55, "Stop ATR Mult", minval=0.25, step=0.05)
targetAtrMult  = input.float(2.75, "Target ATR Mult", minval=0.5, step=0.05)
confluenceMin  = input.int(3, "Minimum Confluence Votes", minval=1, maxval=7)
htf1           = input.timeframe("240", "Higher Timeframe 1")
htf2           = input.timeframe("D", "Higher Timeframe 2")
htf3           = input.timeframe("W", "Higher Timeframe 3")
predictionLen  = input.int(8, "Zero-Lag Prediction Length", minval=2, maxval=50)
predictionMult = input.float(0.85, "Prediction Threshold ATR", minval=0.10, step=0.05)
proximityMult  = input.float(0.45, "Proximity Warning ATR", minval=0.10, step=0.05)
showPrediction = input.bool(true, "Show Prediction Rails")
showRiskLadder = input.bool(true, "Show Risk Ladder Boxes")
showRightLabels = input.bool(true, "Show Right-Side Ladder Labels")
ladderBars     = input.int(42, "Risk Ladder Projection Bars", minval=8, maxval=160)
labelOffset    = input.int(3, "Right Label Offset", minval=1, maxval=25)

// -----------------------------------------------------------------------------
// Palette
// -----------------------------------------------------------------------------
cBg            = color.rgb(10, 13, 19)
cPanel         = color.rgb(16, 21, 30)
cSlate         = color.rgb(98, 116, 139)
cCyan          = color.rgb(0, 204, 255)
cTeal          = color.rgb(0, 190, 150)
cGreen         = color.rgb(109, 214, 126)
cAmber         = color.rgb(255, 181, 72)
cRed           = color.rgb(233, 87, 74)
cViolet        = color.rgb(173, 132, 255)
cBlue          = color.rgb(31, 146, 255)
cRose          = color.rgb(255, 64, 129)
cGrid          = color.rgb(48, 58, 72)
cSoftBull      = color.new(cTeal, 82)
cSoftBear      = color.new(cRed, 82)

// -----------------------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------------------
f_clamp11(x) =>
    math.max(-1.0, math.min(1.0, x))

f_clamp01(x) =>
    math.max(0.0, math.min(1.0, x))

f_safeDiv(num, den) =>
    den == 0.0 ? 0.0 : num / den

f_zlema(_src, _len) =>
    _ema1 = ta.ema(_src, _len)
    2.0 * _ema1 - ta.ema(_ema1, _len)

f_vote(_bull, _bear) =>
    _bull ? 1 : _bear ? -1 : 0

f_biasText(_score) =>
    _score >= 80 ? "Expansion" :
     _score >= 65 ? "Directional" :
     _score >= 50 ? "Balanced" :
     _score >= 35 ? "Repair" : "Compression"

f_fmt(x) =>
    na(x) ? "n/a" : str.tostring(x, format.mintick)

f_sideText(x) =>
    x > 0.30 ? "Bull Relay" :
     x < -0.30 ? "Bear Relay" : "Neutral Relay"

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
// Core trend architecture
// -----------------------------------------------------------------------------
atr = ta.atr(riskAtrLen)
atrSafe = math.max(nz(atr, syminfo.mintick), syminfo.mintick)

emaFast = ta.ema(src, emaFastLen)
emaMid  = ta.ema(src, emaMidLen)
emaSlow = ta.ema(src, emaSlowLen)
emaBase = ta.ema(src, emaBaseLen)
zlema   = f_zlema(src, zlemaLen)

[stLine, stDir] = ta.supertrend(stFactor, stAtrLen)

ribbonBull = emaFast > emaMid and emaMid > emaSlow and emaSlow > emaBase
ribbonBear = emaFast < emaMid and emaMid < emaSlow and emaSlow < emaBase

localSlopeBull = zlema > zlema[1] and emaFast > emaFast[1]
localSlopeBear = zlema < zlema[1] and emaFast < emaFast[1]

localBull = close > stLine and zlema > emaSlow and ribbonBull and localSlopeBull
localBear = close < stLine and zlema < emaSlow and ribbonBear and localSlopeBear

// -----------------------------------------------------------------------------
// MTF confluence engine
// -----------------------------------------------------------------------------
htfZlema1 = request.security(syminfo.tickerid, htf1, f_zlema(src, zlemaLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
htfFast1  = request.security(syminfo.tickerid, htf1, ta.ema(src, emaFastLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
htfSlow1  = request.security(syminfo.tickerid, htf1, ta.ema(src, emaSlowLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

htfZlema2 = request.security(syminfo.tickerid, htf2, f_zlema(src, zlemaLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
htfFast2  = request.security(syminfo.tickerid, htf2, ta.ema(src, emaFastLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
htfSlow2  = request.security(syminfo.tickerid, htf2, ta.ema(src, emaSlowLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

htfZlema3 = request.security(syminfo.tickerid, htf3, f_zlema(src, zlemaLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
htfFast3  = request.security(syminfo.tickerid, htf3, ta.ema(src, emaFastLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
htfSlow3  = request.security(syminfo.tickerid, htf3, ta.ema(src, emaSlowLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

htfBull1 = htfZlema1 > htfSlow1 and htfFast1 > htfSlow1 and htfZlema1 > htfFast1
htfBear1 = htfZlema1 < htfSlow1 and htfFast1 < htfSlow1 and htfZlema1 < htfFast1
htfBull2 = htfZlema2 > htfSlow2 and htfFast2 > htfSlow2 and htfZlema2 > htfFast2
htfBear2 = htfZlema2 < htfSlow2 and htfFast2 < htfSlow2 and htfZlema2 < htfFast2
htfBull3 = htfZlema3 > htfSlow3 and htfFast3 > htfSlow3 and htfZlema3 > htfFast3
htfBear3 = htfZlema3 < htfSlow3 and htfFast3 < htfSlow3 and htfZlema3 < htfFast3

voteLocal = f_vote(localBull, localBear)
voteHtf1  = f_vote(htfBull1, htfBear1)
voteHtf2  = f_vote(htfBull2, htfBear2)
voteHtf3  = f_vote(htfBull3, htfBear3)
voteTrend = f_vote(close > stLine, close < stLine)
voteRibbon = f_vote(ribbonBull, ribbonBear)
votePredict = f_vote(zlema > zlema[1] and close > zlema, zlema < zlema[1] and close < zlema)

voteTotal = voteLocal + voteHtf1 + voteHtf2 + voteHtf3 + voteTrend + voteRibbon + votePredict
confluenceScore = math.max(0.0, math.min(100.0, 50.0 + 8.0 * voteTotal + 5.0 * f_clamp11((zlema - emaSlow) / atrSafe)))

regimeBull = barstate.isconfirmed and voteTotal >= confluenceMin and voteTotal > 0
regimeBear = barstate.isconfirmed and voteTotal <= -confluenceMin and voteTotal < 0
regimeFlat = not regimeBull and not regimeBear

// -----------------------------------------------------------------------------
// Zero-lag prediction and proximity engine
// -----------------------------------------------------------------------------
zlemaVelocity = zlema - nz(zlema[1], zlema)
zlemaVelocitySm = ta.ema(zlemaVelocity, predictionLen)
zlemaAcceleration = zlemaVelocitySm - nz(zlemaVelocitySm[1], zlemaVelocitySm)
predictedZlema = zlema + zlemaVelocitySm + zlemaAcceleration * 0.50
predictionUpper = predictedZlema + atrSafe * predictionMult
predictionLower = predictedZlema - atrSafe * predictionMult
predictionBias = f_clamp11(f_safeDiv(predictedZlema - zlema, math.max(atrSafe, syminfo.mintick)))
predictionExpansion = math.abs(predictionBias) > 0.20 and math.abs(zlemaVelocitySm) > atrSafe * 0.05

zlemaProximity = f_clamp01(1.0 - f_safeDiv(math.abs(close - zlema), math.max(atrSafe * proximityMult, syminfo.mintick)))
stProximity = f_clamp01(1.0 - f_safeDiv(math.abs(close - stLine), math.max(atrSafe * proximityMult, syminfo.mintick)))
proximityScore = math.max(zlemaProximity, stProximity)
proximityBullWarning = barstate.isconfirmed and proximityScore > 0.70 and voteTotal > 0 and close >= zlema
proximityBearWarning = barstate.isconfirmed and proximityScore > 0.70 and voteTotal < 0 and close <= zlema
relayDistance = f_safeDiv(close - zlema, math.max(atrSafe, syminfo.mintick))
relayPressure = f_clamp11(0.55 * f_clamp11(relayDistance) + 0.45 * predictionBias)

// -----------------------------------------------------------------------------
// Risk rails
// -----------------------------------------------------------------------------
riskAnchor = (zlema + stLine) * 0.5
longStop = riskAnchor - atrSafe * stopAtrMult
longTarget = riskAnchor + atrSafe * targetAtrMult
shortStop = riskAnchor + atrSafe * stopAtrMult
shortTarget = riskAnchor - atrSafe * targetAtrMult

activeStop = regimeBull ? longStop : regimeBear ? shortStop : na
activeTarget = regimeBull ? longTarget : regimeBear ? shortTarget : na
activeMid = regimeBull or regimeBear ? riskAnchor : na

// -----------------------------------------------------------------------------
// Visual system
// -----------------------------------------------------------------------------
trendGradient = color.from_gradient(f_clamp11((zlema - emaSlow) / math.max(atr * 1.2, syminfo.mintick)), -1.0, 1.0, cRed, cTeal)
predictionColor = predictionBias >= 0 ? color.from_gradient(predictionBias, 0.0, 1.0, cCyan, cTeal) : color.from_gradient(-predictionBias, 0.0, 1.0, cRose, cRed)
pressureColor = color.from_gradient(relayPressure, -1.0, 1.0, cRed, cTeal)
zlemaColor = regimeBull ? cTeal : regimeBear ? cRed : cSlate
stColor = close >= stLine ? color.new(cGreen, 0) : color.new(cRed, 0)
ribbonFillColor = ribbonBull ? color.new(cTeal, 86) : ribbonBear ? color.new(cRed, 86) : color.new(cAmber, 90)

plotFast = plot(emaFast, "Ribbon Fast", color=color.new(cCyan, 10), linewidth=1)
plotMid = plot(emaMid, "Ribbon Mid", color=color.new(cViolet, 15), linewidth=1)
plotSlow = plot(emaSlow, "Ribbon Slow", color=color.new(cAmber, 10), linewidth=1)
plotBase = plot(emaBase, "Ribbon Base", color=color.new(cSlate, 5), linewidth=1)
plotZlema = plot(zlema, "Zero Lag EMA", color=zlemaColor, linewidth=3)
plotSt = plot(stLine, "SuperTrend", color=stColor, linewidth=2)
plotPred = plot(showPrediction ? predictedZlema : na, "Predicted Zero Lag", color=predictionColor, linewidth=2)
plotPredUpper = plot(showPrediction ? predictionUpper : na, "Prediction Upper Threshold", color=color.new(cCyan, 65), linewidth=1)
plotPredLower = plot(showPrediction ? predictionLower : na, "Prediction Lower Threshold", color=color.new(cRose, 65), linewidth=1)

fill(plotFast, plotMid, color=color.new(cCyan, 92), title="Fast-Mid Wash")
fill(plotMid, plotSlow, color=color.new(cViolet, 92), title="Mid-Slow Wash")
fill(plotSlow, plotBase, color=color.new(cAmber, 92), title="Slow-Base Wash")
fill(plotZlema, plotSt, color=ribbonFillColor, title="Trend Cloud")
fill(plotPredUpper, plotPred, color=color.new(cCyan, 93), title="Prediction Upper Glow")
fill(plotPred, plotPredLower, color=color.new(cRose, 93), title="Prediction Lower Glow")

plot(activeMid, "Risk Anchor", color=color.new(cSlate, 42), linewidth=1, style=plot.style_linebr)
plot(activeStop, "Active Stop Rail", color=regimeBull ? color.new(cRed, 0) : color.new(cTeal, 0), linewidth=2, style=plot.style_linebr)
plot(activeTarget, "Active Target Rail", color=regimeBull ? color.new(cGreen, 0) : color.new(cAmber, 0), linewidth=2, style=plot.style_linebr)
plot(proximityBullWarning or proximityBearWarning ? zlema : na, "Proximity Warning Rail", color=proximityBullWarning ? cCyan : proximityBearWarning ? cRose : na, linewidth=3, style=plot.style_linebr)

barTint = regimeBull ? color.from_gradient(confluenceScore, 50.0, 100.0, color.new(cSlate, 0), color.new(cTeal, 0)) :
     regimeBear ? color.from_gradient(confluenceScore, 50.0, 100.0, color.new(cSlate, 0), color.new(cRed, 0)) :
     color.from_gradient(confluenceScore, 0.0, 100.0, color.new(cRed, 0), color.new(cTeal, 0))

barcolor(barTint)
bgcolor(regimeBull ? color.new(cTeal, 94) : regimeBear ? color.new(cRed, 94) : confluenceScore >= 65 ? color.new(cAmber, 96) : na)
plotshape(proximityBullWarning, "Bull Proximity Pulse", shape.circle, location.belowbar, color.new(cCyan, 35), size=size.small, text="")
plotshape(proximityBearWarning, "Bear Proximity Pulse", shape.circle, location.abovebar, color.new(cRose, 35), size=size.small, text="")

// -----------------------------------------------------------------------------
// Signals
// -----------------------------------------------------------------------------
bullRelay = regimeBull and close > zlema and close > stLine and ribbonBull
bearRelay = regimeBear and close < zlema and close < stLine and ribbonBear
zlemaCrossUp = ta.crossover(close, zlema)
zlemaCrossDown = ta.crossunder(close, zlema)
reclaimBull = barstate.isconfirmed and zlemaCrossUp and voteTotal >= confluenceMin - 1
reclaimBear = barstate.isconfirmed and zlemaCrossDown and voteTotal <= -(confluenceMin - 1)

alertcondition(bullRelay, "Obsidian Bull Relay", "Obsidian Trend Relay bullish condition confirmed")
alertcondition(bearRelay, "Obsidian Bear Relay", "Obsidian Trend Relay bearish condition confirmed")
alertcondition(reclaimBull, "Obsidian Bull Reclaim", "Obsidian Trend Relay bullish reclaim confirmed")
alertcondition(reclaimBear, "Obsidian Bear Reclaim", "Obsidian Trend Relay bearish reclaim confirmed")
alertcondition(proximityBullWarning, "Obsidian Bull Proximity", "Obsidian Trend Relay bullish proximity warning confirmed")
alertcondition(proximityBearWarning, "Obsidian Bear Proximity", "Obsidian Trend Relay bearish proximity warning confirmed")

// -----------------------------------------------------------------------------
// Risk ladder boxes and right-side ladder labels
// -----------------------------------------------------------------------------
var int ladderDir = 0
var int ladderStartBar = na
var bool ladderLive = false
var float ladderEntry = na
var float ladderStop = na
var float ladderTarget1 = na
var float ladderTarget2 = na
var float ladderTarget3 = na
var float ladderWarning = na
var box ladderRewardBox = na
var box ladderRiskBox = na
var box ladderWarningBox = na
var line ladderEntryLine = na
var line ladderStopLine = na
var line ladderTarget1Line = na
var line ladderTarget2Line = na
var line ladderTarget3Line = na
var line ladderWarningLine = na
var label ladderEntryLabel = na
var label ladderStopLabel = na
var label ladderTarget1Label = na
var label ladderTarget2Label = na
var label ladderTarget3Label = na
var label ladderWarningLabel = na
var label ladderStateLabel = na

newBullLadder = showRiskLadder and (bullRelay or reclaimBull)
newBearLadder = showRiskLadder and (bearRelay or reclaimBear)
newLadder = barstate.isconfirmed and (newBullLadder or newBearLadder)

if newLadder
    f_deleteBox(ladderRewardBox)
    f_deleteBox(ladderRiskBox)
    f_deleteBox(ladderWarningBox)
    f_deleteLine(ladderEntryLine)
    f_deleteLine(ladderStopLine)
    f_deleteLine(ladderTarget1Line)
    f_deleteLine(ladderTarget2Line)
    f_deleteLine(ladderTarget3Line)
    f_deleteLine(ladderWarningLine)
    f_deleteLabel(ladderEntryLabel)
    f_deleteLabel(ladderStopLabel)
    f_deleteLabel(ladderTarget1Label)
    f_deleteLabel(ladderTarget2Label)
    f_deleteLabel(ladderTarget3Label)
    f_deleteLabel(ladderWarningLabel)
    f_deleteLabel(ladderStateLabel)
    ladderDir := newBullLadder ? 1 : -1
    ladderStartBar := bar_index
    ladderLive := true
    ladderEntry := close
    longStopSeed = nz(activeStop, low - atrSafe * stopAtrMult)
    shortStopSeed = nz(activeStop, high + atrSafe * stopAtrMult)
    ladderStop := ladderDir == 1 ? math.min(longStopSeed, low - atrSafe * 0.15) : math.max(shortStopSeed, high + atrSafe * 0.15)
    ladderRisk = math.max(math.abs(ladderEntry - ladderStop), atrSafe * 0.55)
    ladderTarget1 := ladderEntry + ladderDir * ladderRisk * 1.00
    ladderTarget2 := ladderEntry + ladderDir * ladderRisk * 1.75
    ladderTarget3 := ladderEntry + ladderDir * ladderRisk * 2.60
    ladderWarning := ladderDir == 1 ? ladderEntry - ladderRisk * 0.35 : ladderEntry + ladderRisk * 0.35
    rewardTop = math.max(ladderEntry, math.max(ladderTarget2, ladderTarget3))
    rewardBot = math.min(ladderEntry, math.min(ladderTarget2, ladderTarget3))
    riskTop = math.max(ladderEntry, ladderStop)
    riskBot = math.min(ladderEntry, ladderStop)
    warningTop = math.max(ladderEntry, ladderWarning)
    warningBot = math.min(ladderEntry, ladderWarning)
    ladderRewardBox := box.new(left=bar_index, top=rewardTop, right=bar_index + ladderBars, bottom=rewardBot, xloc=xloc.bar_index, border_color=ladderDir == 1 ? color.new(cTeal, 15) : color.new(cRed, 15), bgcolor=ladderDir == 1 ? color.new(cTeal, 87) : color.new(cRed, 87))
    ladderRiskBox := box.new(left=bar_index, top=riskTop, right=bar_index + ladderBars, bottom=riskBot, xloc=xloc.bar_index, border_color=ladderDir == 1 ? color.new(cRed, 20) : color.new(cTeal, 20), bgcolor=ladderDir == 1 ? color.new(cRed, 89) : color.new(cTeal, 89))
    ladderWarningBox := box.new(left=bar_index, top=warningTop, right=bar_index + ladderBars, bottom=warningBot, xloc=xloc.bar_index, border_color=color.new(cAmber, 35), bgcolor=color.new(cAmber, 92))
    ladderEntryLine := line.new(bar_index, ladderEntry, bar_index + labelOffset, ladderEntry, xloc=xloc.bar_index, extend=extend.none, color=cAmber, style=line.style_dashed, width=1)
    ladderStopLine := line.new(bar_index, ladderStop, bar_index + labelOffset, ladderStop, xloc=xloc.bar_index, extend=extend.none, color=cRed, style=line.style_solid, width=2)
    ladderTarget1Line := line.new(bar_index, ladderTarget1, bar_index + labelOffset, ladderTarget1, xloc=xloc.bar_index, extend=extend.none, color=ladderDir == 1 ? cTeal : cRed, style=line.style_dotted, width=1)
    ladderTarget2Line := line.new(bar_index, ladderTarget2, bar_index + labelOffset, ladderTarget2, xloc=xloc.bar_index, extend=extend.none, color=ladderDir == 1 ? cTeal : cRed, style=line.style_dotted, width=1)
    ladderTarget3Line := line.new(bar_index, ladderTarget3, bar_index + labelOffset, ladderTarget3, xloc=xloc.bar_index, extend=extend.none, color=ladderDir == 1 ? cTeal : cRed, style=line.style_solid, width=2)
    ladderWarningLine := line.new(bar_index, ladderWarning, bar_index + labelOffset, ladderWarning, xloc=xloc.bar_index, extend=extend.none, color=cAmber, style=line.style_dotted, width=1)
    ladderEntryLabel := label.new(bar_index + labelOffset, ladderEntry, "Entry  " + f_fmt(ladderEntry), xloc=xloc.bar_index, yloc=yloc.price, color=color.new(cPanel, 0), style=label.style_label_left, textcolor=cAmber, size=size.small)
    ladderStopLabel := label.new(bar_index + labelOffset, ladderStop, "Stop  " + f_fmt(ladderStop), xloc=xloc.bar_index, yloc=yloc.price, color=color.new(cPanel, 0), style=label.style_label_left, textcolor=cRed, size=size.small)
    ladderTarget1Label := label.new(bar_index + labelOffset, ladderTarget1, "T1  " + f_fmt(ladderTarget1), xloc=xloc.bar_index, yloc=yloc.price, color=color.new(cPanel, 0), style=label.style_label_left, textcolor=ladderDir == 1 ? cTeal : cRed, size=size.small)
    ladderTarget2Label := label.new(bar_index + labelOffset, ladderTarget2, "T2  " + f_fmt(ladderTarget2), xloc=xloc.bar_index, yloc=yloc.price, color=color.new(cPanel, 0), style=label.style_label_left, textcolor=ladderDir == 1 ? cTeal : cRed, size=size.small)
    ladderTarget3Label := label.new(bar_index + labelOffset, ladderTarget3, "T3  " + f_fmt(ladderTarget3), xloc=xloc.bar_index, yloc=yloc.price, color=color.new(cPanel, 0), style=label.style_label_left, textcolor=ladderDir == 1 ? cTeal : cRed, size=size.small)
    ladderWarningLabel := label.new(bar_index + labelOffset, ladderWarning, "Warning  " + f_fmt(ladderWarning), xloc=xloc.bar_index, yloc=yloc.price, color=color.new(cPanel, 0), style=label.style_label_left, textcolor=cAmber, size=size.small)
    ladderStateLabel := label.new(bar_index, ladderDir == 1 ? low - atrSafe * 0.65 : high + atrSafe * 0.65, ladderDir == 1 ? "Bull Relay" : "Bear Relay", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(cBg, 5), style=label.style_label_left, textcolor=ladderDir == 1 ? cTeal : cRed, size=size.small)

ladderTargetHit = barstate.isconfirmed and ((ladderLive and ladderDir == 1 and high >= ladderTarget3) or (ladderLive and ladderDir == -1 and low <= ladderTarget3))
ladderStopHit = barstate.isconfirmed and ((ladderLive and ladderDir == 1 and low <= ladderStop) or (ladderLive and ladderDir == -1 and high >= ladderStop))
ladderWarningHit = barstate.isconfirmed and ((ladderLive and ladderDir == 1 and low <= ladderWarning) or (ladderLive and ladderDir == -1 and high >= ladderWarning))

if ladderTargetHit or ladderStopHit
    ladderLive := false

ladderColor = ladderDir == 1 ? cTeal : ladderDir == -1 ? cRed : cSlate
ladderLiveColor = ladderLive ? ladderColor : cSlate
ladderRight = bar_index + labelOffset
ladderBoxRight = math.max(bar_index + labelOffset, nz(ladderStartBar, bar_index) + ladderBars)

if barstate.islast and showRiskLadder and ladderDir != 0 and not na(ladderEntry) and not na(ladderRewardBox)
    rewardTopLive = math.max(ladderEntry, math.max(ladderTarget2, ladderTarget3))
    rewardBotLive = math.min(ladderEntry, math.min(ladderTarget2, ladderTarget3))
    riskTopLive = math.max(ladderEntry, ladderStop)
    riskBotLive = math.min(ladderEntry, ladderStop)
    warningTopLive = math.max(ladderEntry, ladderWarning)
    warningBotLive = math.min(ladderEntry, ladderWarning)
    box.set_lefttop(ladderRewardBox, ladderStartBar, rewardTopLive)
    box.set_rightbottom(ladderRewardBox, ladderBoxRight, rewardBotLive)
    box.set_lefttop(ladderRiskBox, ladderStartBar, riskTopLive)
    box.set_rightbottom(ladderRiskBox, ladderBoxRight, riskBotLive)
    box.set_lefttop(ladderWarningBox, ladderStartBar, warningTopLive)
    box.set_rightbottom(ladderWarningBox, ladderBoxRight, warningBotLive)
    box.set_bgcolor(ladderRewardBox, ladderLive ? (ladderDir == 1 ? color.new(cTeal, 87) : color.new(cRed, 87)) : color.new(cSlate, 93))
    box.set_bgcolor(ladderRiskBox, ladderLive ? (ladderDir == 1 ? color.new(cRed, 89) : color.new(cTeal, 89)) : color.new(cSlate, 94))
    box.set_bgcolor(ladderWarningBox, ladderWarningHit ? color.new(cAmber, 86) : color.new(cAmber, 93))
    line.set_xy1(ladderEntryLine, ladderStartBar, ladderEntry)
    line.set_xy2(ladderEntryLine, ladderRight, ladderEntry)
    line.set_xy1(ladderStopLine, ladderStartBar, ladderStop)
    line.set_xy2(ladderStopLine, ladderRight, ladderStop)
    line.set_xy1(ladderTarget1Line, ladderStartBar, ladderTarget1)
    line.set_xy2(ladderTarget1Line, ladderRight, ladderTarget1)
    line.set_xy1(ladderTarget2Line, ladderStartBar, ladderTarget2)
    line.set_xy2(ladderTarget2Line, ladderRight, ladderTarget2)
    line.set_xy1(ladderTarget3Line, ladderStartBar, ladderTarget3)
    line.set_xy2(ladderTarget3Line, ladderRight, ladderTarget3)
    line.set_xy1(ladderWarningLine, ladderStartBar, ladderWarning)
    line.set_xy2(ladderWarningLine, ladderRight, ladderWarning)
    label.set_xy(ladderEntryLabel, ladderRight, ladderEntry)
    label.set_text(ladderEntryLabel, "Entry  " + f_fmt(ladderEntry))
    label.set_xy(ladderStopLabel, ladderRight, ladderStop)
    label.set_text(ladderStopLabel, "Stop  " + f_fmt(ladderStop))
    label.set_xy(ladderTarget1Label, ladderRight, ladderTarget1)
    label.set_text(ladderTarget1Label, "T1  " + f_fmt(ladderTarget1))
    label.set_textcolor(ladderTarget1Label, ladderLiveColor)
    label.set_xy(ladderTarget2Label, ladderRight, ladderTarget2)
    label.set_text(ladderTarget2Label, "T2  " + f_fmt(ladderTarget2))
    label.set_textcolor(ladderTarget2Label, ladderLiveColor)
    label.set_xy(ladderTarget3Label, ladderRight, ladderTarget3)
    label.set_text(ladderTarget3Label, "T3  " + f_fmt(ladderTarget3))
    label.set_textcolor(ladderTarget3Label, ladderLiveColor)
    label.set_xy(ladderWarningLabel, ladderRight, ladderWarning)
    label.set_text(ladderWarningLabel, "Warning  " + f_fmt(ladderWarning))
    label.set_textcolor(ladderWarningLabel, ladderWarningHit ? cAmber : cSlate)
    label.set_xy(ladderStateLabel, ladderRight, ladderDir == 1 ? low - atrSafe * 0.65 : high + atrSafe * 0.65)
    label.set_text(ladderStateLabel, ladderLive ? (ladderDir == 1 ? "Bull Relay" : "Bear Relay") : ladderTargetHit ? "Target Resolved" : ladderStopHit ? "Stop Resolved" : "Paused Relay")
    label.set_textcolor(ladderStateLabel, ladderLiveColor)

if barstate.islast and not showRiskLadder
    f_deleteBox(ladderRewardBox)
    f_deleteBox(ladderRiskBox)
    f_deleteBox(ladderWarningBox)
    f_deleteLine(ladderEntryLine)
    f_deleteLine(ladderStopLine)
    f_deleteLine(ladderTarget1Line)
    f_deleteLine(ladderTarget2Line)
    f_deleteLine(ladderTarget3Line)
    f_deleteLine(ladderWarningLine)
    f_deleteLabel(ladderEntryLabel)
    f_deleteLabel(ladderStopLabel)
    f_deleteLabel(ladderTarget1Label)
    f_deleteLabel(ladderTarget2Label)
    f_deleteLabel(ladderTarget3Label)
    f_deleteLabel(ladderWarningLabel)
    f_deleteLabel(ladderStateLabel)
    ladderRewardBox := na
    ladderRiskBox := na
    ladderWarningBox := na
    ladderEntryLine := na
    ladderStopLine := na
    ladderTarget1Line := na
    ladderTarget2Line := na
    ladderTarget3Line := na
    ladderWarningLine := na
    ladderEntryLabel := na
    ladderStopLabel := na
    ladderTarget1Label := na
    ladderTarget2Label := na
    ladderTarget3Label := na
    ladderWarningLabel := na
    ladderStateLabel := na

alertcondition(ladderTargetHit, "Obsidian Ladder Target", "Obsidian Trend Relay ladder target reached")
alertcondition(ladderStopHit, "Obsidian Ladder Stop", "Obsidian Trend Relay ladder stop reached")

// -----------------------------------------------------------------------------
// Dashboard
// -----------------------------------------------------------------------------
var table dash = table.new(position.top_right, 3, 14, bgcolor=color.new(cBg, 10), frame_color=color.new(cCyan, 65), frame_width=1, border_color=color.new(cGrid, 70), border_width=1)
dashText = size.small

if barstate.islast
    table.cell(dash, 0, 0, "Obsidian Trend Relay", text_color=color.white, bgcolor=color.new(cPanel, 0), text_size=dashText)
    table.cell(dash, 1, 0, regimeBull ? "Bull" : regimeBear ? "Bear" : "Flat", text_color=regimeBull ? cTeal : regimeBear ? cRed : cAmber, bgcolor=color.new(cPanel, 0), text_size=dashText)

    table.cell(dash, 0, 1, "ZLEMA", text_color=color.white, bgcolor=color.new(cPanel, 10), text_size=dashText)
    table.cell(dash, 1, 1, str.tostring(zlema, format.mintick), text_color=zlemaColor, bgcolor=color.new(cPanel, 10), text_size=dashText)

    table.cell(dash, 0, 2, "SuperTrend", text_color=color.white, bgcolor=color.new(cPanel, 10), text_size=dashText)
    table.cell(dash, 1, 2, str.tostring(stLine, format.mintick), text_color=stColor, bgcolor=color.new(cPanel, 10), text_size=dashText)

    table.cell(dash, 0, 3, "Ribbon", text_color=color.white, bgcolor=color.new(cPanel, 10), text_size=dashText)
    table.cell(dash, 1, 3, ribbonBull ? "Bull" : ribbonBear ? "Bear" : "Mixed", text_color=ribbonBull ? cTeal : ribbonBear ? cRed : cAmber, bgcolor=color.new(cPanel, 10), text_size=dashText)

    table.cell(dash, 0, 4, "HTF 1", text_color=color.white, bgcolor=color.new(cPanel, 10), text_size=dashText)
    table.cell(dash, 1, 4, htfBull1 ? "Bull" : htfBear1 ? "Bear" : "Neutral", text_color=htfBull1 ? cTeal : htfBear1 ? cRed : cSlate, bgcolor=color.new(cPanel, 10), text_size=dashText)

    table.cell(dash, 0, 5, "HTF 2", text_color=color.white, bgcolor=color.new(cPanel, 10), text_size=dashText)
    table.cell(dash, 1, 5, htfBull2 ? "Bull" : htfBear2 ? "Bear" : "Neutral", text_color=htfBull2 ? cTeal : htfBear2 ? cRed : cSlate, bgcolor=color.new(cPanel, 10), text_size=dashText)

    table.cell(dash, 0, 6, "Confluence", text_color=color.white, bgcolor=color.new(cPanel, 10), text_size=dashText)
    table.cell(dash, 1, 6, str.tostring(confluenceScore, "#.0") + " / 100", text_color=confluenceScore >= 70 ? cTeal : confluenceScore >= 50 ? cAmber : cRed, bgcolor=color.new(cPanel, 10), text_size=dashText)

    table.cell(dash, 0, 7, "Rail State", text_color=color.white, bgcolor=color.new(cPanel, 10), text_size=dashText)
    table.cell(dash, 1, 7, f_biasText(confluenceScore), text_color=confluenceScore >= 70 ? cTeal : confluenceScore >= 50 ? cAmber : cSlate, bgcolor=color.new(cPanel, 10), text_size=dashText)

    table.cell(dash, 2, 0, f_sideText(relayPressure), text_color=relayPressure >= 0 ? cTeal : cRed, bgcolor=color.new(cPanel, 0), text_size=dashText)
    table.cell(dash, 2, 1, "Pred " + f_fmt(predictedZlema), text_color=predictionColor, bgcolor=color.new(cPanel, 10), text_size=dashText)
    table.cell(dash, 2, 2, "Votes " + str.tostring(voteTotal) + " / 7", text_color=voteTotal > 0 ? cTeal : voteTotal < 0 ? cRed : cSlate, bgcolor=color.new(cPanel, 10), text_size=dashText)
    table.cell(dash, 2, 3, predictionExpansion ? "Expanding" : "Cooling", text_color=predictionExpansion ? cCyan : cSlate, bgcolor=color.new(cPanel, 10), text_size=dashText)
    table.cell(dash, 2, 4, "V1 " + str.tostring(voteHtf1), text_color=voteHtf1 > 0 ? cTeal : voteHtf1 < 0 ? cRed : cSlate, bgcolor=color.new(cPanel, 10), text_size=dashText)
    table.cell(dash, 2, 5, "V2 " + str.tostring(voteHtf2), text_color=voteHtf2 > 0 ? cTeal : voteHtf2 < 0 ? cRed : cSlate, bgcolor=color.new(cPanel, 10), text_size=dashText)
    table.cell(dash, 2, 6, "V3 " + str.tostring(voteHtf3), text_color=voteHtf3 > 0 ? cTeal : voteHtf3 < 0 ? cRed : cSlate, bgcolor=color.new(cPanel, 10), text_size=dashText)
    table.cell(dash, 2, 7, proximityScore > 0.70 ? "Near Rail" : "Clear", text_color=proximityScore > 0.70 ? cAmber : cSlate, bgcolor=color.new(cPanel, 10), text_size=dashText)

    table.cell(dash, 0, 8, "HTF 3", text_color=color.white, bgcolor=color.new(cPanel, 10), text_size=dashText)
    table.cell(dash, 1, 8, htfBull3 ? "Bull" : htfBear3 ? "Bear" : "Neutral", text_color=htfBull3 ? cTeal : htfBear3 ? cRed : cSlate, bgcolor=color.new(cPanel, 10), text_size=dashText)
    table.cell(dash, 2, 8, htf3, text_color=cSlate, bgcolor=color.new(cPanel, 10), text_size=dashText)

    table.cell(dash, 0, 9, "Prediction", text_color=color.white, bgcolor=color.new(cPanel, 10), text_size=dashText)
    table.cell(dash, 1, 9, str.tostring(predictionBias, "#.00"), text_color=predictionColor, bgcolor=color.new(cPanel, 10), text_size=dashText)
    table.cell(dash, 2, 9, "Band " + f_fmt(predictionUpper) + " / " + f_fmt(predictionLower), text_color=predictionColor, bgcolor=color.new(cPanel, 10), text_size=dashText)

    table.cell(dash, 0, 10, "Proximity", text_color=color.white, bgcolor=color.new(cPanel, 10), text_size=dashText)
    table.cell(dash, 1, 10, str.tostring(proximityScore * 100.0, "#.0") + "%", text_color=proximityScore > 0.70 ? cAmber : cSlate, bgcolor=color.new(cPanel, 10), text_size=dashText)
    table.cell(dash, 2, 10, proximityBullWarning ? "Bull Rail" : proximityBearWarning ? "Bear Rail" : "Open", text_color=proximityBullWarning ? cCyan : proximityBearWarning ? cRose : cSlate, bgcolor=color.new(cPanel, 10), text_size=dashText)

    table.cell(dash, 0, 11, "Ladder", text_color=color.white, bgcolor=color.new(cPanel, 10), text_size=dashText)
    table.cell(dash, 1, 11, ladderDir == 1 ? "Long" : ladderDir == -1 ? "Short" : "None", text_color=ladderDir == 1 ? cTeal : ladderDir == -1 ? cRed : cSlate, bgcolor=color.new(cPanel, 10), text_size=dashText)
    table.cell(dash, 2, 11, ladderLive ? "Active" : ladderDir != 0 ? "Idle" : "Waiting", text_color=ladderLive ? ladderColor : cSlate, bgcolor=color.new(cPanel, 10), text_size=dashText)

    table.cell(dash, 0, 12, "Ladder Prices", text_color=color.white, bgcolor=color.new(cPanel, 10), text_size=dashText)
    table.cell(dash, 1, 12, "Entry " + f_fmt(ladderEntry), text_color=cAmber, bgcolor=color.new(cPanel, 10), text_size=dashText)
    table.cell(dash, 2, 12, "T3 " + f_fmt(ladderTarget3), text_color=ladderDir == 0 ? cSlate : ladderColor, bgcolor=color.new(cPanel, 10), text_size=dashText)

    table.cell(dash, 0, 13, "JOAT", text_color=cViolet, bgcolor=color.new(cBg, 0), text_size=dashText)
    table.cell(dash, 1, 13, "Confirmed", text_color=color.white, bgcolor=color.new(cBg, 0), text_size=dashText)
    table.cell(dash, 2, 13, "Lookahead Off", text_color=cSlate, bgcolor=color.new(cBg, 0), text_size=dashText)
````
