# Momentum Covenant Bias [JOAT]

- url: https://www.tradingview.com/script/3eDSnsX5-Momentum-Covenant-Bias-JOAT/
- type: indicator
- pine_id: PUB;07b887e90ac7464e9fbc850ac04e3ea9
- version: 1.0

## Description

[b]Momentum Covenant Bias [JOAT][/b]

[b]Introduction[/b]

Momentum Covenant Bias is an open-source momentum pane designed to classify whether the market is in a constructive, defensive, balanced, or compressed state. It blends WaveTrend timing, RSI displacement, normalized trend distance, compression logic, layered state bands, pane boxes, and an optional force-overlay TP/SL scaffold when fresh confirmed momentum shifts occur.

This indicator is meant to solve timing. Trend and auction context can describe where the market is, but they do not always tell you whether momentum is actually participating in the current move. Momentum Covenant Bias translates several independent momentum dimensions into one composite state engine and presents them in a clean, institutional-style pane.

[image]https://www.tradingview.com/x/yBX1NbEm/[/image]

[b]Core Concepts[/b]

[b]1. WaveTrend Timing[/b]

WaveTrend serves as the primary turning-point rhythm engine. The script uses the relationship between the main line and signal line to measure timing pressure.

[b]2. RSI Displacement[/b]

RSI is evaluated not only relative to 50, but also relative to its own smoothed mean. This helps distinguish raw strength from persistent displacement.

[b]3. Normalized Trend Distance[/b]

Price distance from the slower trend baseline is normalized by ATR so the output remains portable across markets with different price scales.

[b]4. Compression State[/b]

Compression logic compares recent range behavior to a slower baseline. This helps identify lower-energy conditions before expansion.

[b]5. State Boxes and Overlay Scaffold[/b]

The pane includes positive, negative, and compression zones, and can project a force-overlay TP/SL scaffold on the chart when a fresh momentum shift is confirmed.

[b]Features[/b]

[list]
[*][b]Composite momentum score:[/b] Combines WaveTrend, RSI, trend distance, and compression context
[*][b]Signal line:[/b] Smoothed line for momentum transitions
[*][b]Layered state bands:[/b] Positive, negative, and extension zones rendered as gradients
[*][b]Compression boxes:[/b] Visual isolation of low-energy conditions
[*][b]Top-right dashboard:[/b] Displays composite score, signal, wave state, RSI, compression, trend distance, and scaffold status
[*][b]Force-overlay TP/SL scaffold:[/b] Optional informational rails on fresh positive or negative momentum shifts
[*][b]Confirmed-bar state promotion:[/b] Uses confirmed bars for event states instead of unstable intrabar triggers
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1:[/b] Read the composite state first. Balanced states should be interpreted differently from impulse states.

[b]Step 2:[/b] Compare the composite score to the signal line. Fresh separation often matters more than absolute level alone.

[b]Step 3:[/b] Watch compression zones. These can help explain why a market is not yet extending despite directional context elsewhere.

[b]Step 4:[/b] If using the optional scaffold, treat it as a planning aid that reflects momentum state, not as a standalone trade system.

[b]Indicator Limitations[/b]

[list]
[*]Momentum state can reverse quickly in whipsaw markets
[*]Compression logic can remain active for extended periods in slow markets
[*]WaveTrend and RSI are still derivatives of price and can lag during violent reversals
[*]The overlay scaffold is informational and does not execute orders
[/list]

[b]Originality Statement[/b]

Momentum Covenant Bias is original in the way it combines multi-source momentum confirmation, pane state boxes, gradient regime presentation, and force-overlay planning rails in one open-source script. The indicator is intended as a timing layer that complements structure and auction context instead of replacing them.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Momentum conditions are derived from historical price behavior and may fail or reverse without warning. Use proper risk management and independent validation.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Momentum Covenant Bias [JOAT]", shorttitle="MCB [JOAT]", overlay=false, max_bars_back=3000, max_lines_count=140, max_boxes_count=120, max_labels_count=40)

//------------------------------------------------------------------------------
// Momentum Covenant Bias [JOAT]
// Composite momentum pane with WaveTrend timing, RSI displacement,
// normalized trend distance, compression states, pane boxes, layered gradients,
// and an optional force-overlay TP/SL scaffold for confirmed momentum shifts.
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
groupWave = "Wave Engine"
wtChannelLen = input.int(10, "Wave Channel Length", minval=2, maxval=50, group=groupWave)
wtAverageLen = input.int(21, "Wave Average Length", minval=2, maxval=80, group=groupWave)
wtSignalLen = input.int(4, "Wave Signal Length", minval=2, maxval=20, group=groupWave)
wtSource = input.source(hlc3, "Wave Source", group=groupWave)

groupRsi = "RSI Engine"
rsiLength = input.int(14, "RSI Length", minval=2, maxval=50, group=groupRsi)
rsiSmooth = input.int(9, "RSI Smooth Length", minval=2, maxval=40, group=groupRsi)
rsiBand = input.int(10, "RSI Displacement Band", minval=2, maxval=25, group=groupRsi)

groupTrend = "Trend Engine"
trendFastLen = input.int(34, "Trend Fast EMA", minval=5, maxval=100, group=groupTrend)
trendSlowLen = input.int(89, "Trend Slow EMA", minval=10, maxval=200, group=groupTrend)
atrLen = input.int(14, "ATR Length", minval=2, maxval=100, group=groupTrend)
compressionLen = input.int(34, "Compression Length", minval=5, maxval=200, group=groupTrend)

groupRisk = "Momentum Scaffold"
showScaffold = input.bool(true, "Show Force Overlay Scaffold", group=groupRisk)
scaffoldAtrMult = input.float(1.4, "Stop ATR Multiplier", minval=0.3, step=0.1, group=groupRisk)
tpOneR = input.float(1.0, "TP1 R", minval=0.4, step=0.1, group=groupRisk)
tpTwoR = input.float(2.0, "TP2 R", minval=0.6, step=0.1, group=groupRisk)
tpThreeR = input.float(3.0, "TP3 R", minval=1.0, step=0.1, group=groupRisk)

groupDisplay = "Display"
showDashboard = input.bool(true, "Show Dashboard", group=groupDisplay)
showStateBand = input.bool(true, "Show State Bands", group=groupDisplay)
showHistogram = input.bool(true, "Show Composite Histogram", group=groupDisplay)
showBackground = input.bool(true, "Shade Confirmed States", group=groupDisplay)
showCompressionBoxes = input.bool(true, "Show Compression Boxes", group=groupDisplay)
showImpulseBoxes = input.bool(true, "Show Impulse Boxes", group=groupDisplay)

groupTheme = "Dark Palette"
bullCore = input.color(color.rgb(0, 204, 173), "Bull Core", group=groupTheme)
bearCore = input.color(color.rgb(255, 94, 116), "Bear Core", group=groupTheme)
neutralCore = input.color(color.rgb(148, 163, 184), "Neutral Core", group=groupTheme)
accentCore = input.color(color.rgb(244, 196, 84), "Accent", group=groupTheme)
panelBg = input.color(color.rgb(11, 18, 32), "Panel Background", group=groupTheme)
panelFrame = input.color(color.rgb(58, 76, 109), "Panel Frame", group=groupTheme)

//------------------------------------------------------------------------------
// Helpers
//------------------------------------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_bias_color(float score) =>
    score > 12 ? bullCore : score < -12 ? bearCore : neutralCore

f_bias_text(float score) =>
    score > 35 ? "Impulse Bid" :
     score > 12 ? "Constructive" :
     score < -35 ? "Impulse Offer" :
     score < -12 ? "Defensive" : "Balanced"

f_delete_line(line lineRef) =>
    if not na(lineRef)
        line.delete(lineRef)

f_delete_label(label labelRef) =>
    if not na(labelRef)
        label.delete(labelRef)

f_delete_fill(linefill fillRef) =>
    if not na(fillRef)
        linefill.delete(fillRef)

f_trim_boxes(array<box> refArray, int keepCount) =>
    while array.size(refArray) > keepCount
        box stale = array.shift(refArray)
        box.delete(stale)

//------------------------------------------------------------------------------
// WaveTrend block
//------------------------------------------------------------------------------
esa = ta.ema(wtSource, wtChannelLen)
deviation = ta.ema(math.abs(wtSource - esa), wtChannelLen)
ci = deviation != 0 ? (wtSource - esa) / (0.015 * deviation) : 0.0
wtMain = ta.ema(ci, wtAverageLen)
wtSignal = ta.sma(wtMain, wtSignalLen)
wtSpread = wtMain - wtSignal

//------------------------------------------------------------------------------
// RSI displacement block
//------------------------------------------------------------------------------
rsiValue = ta.rsi(close, rsiLength)
rsiMean = ta.ema(rsiValue, rsiSmooth)
rsiDisplacement = rsiValue - 50.0
rsiScore = (rsiValue - rsiMean) + (rsiDisplacement / math.max(rsiBand, 1))

//------------------------------------------------------------------------------
// Trend and compression block
//------------------------------------------------------------------------------
trendFast = ta.ema(close, trendFastLen)
trendSlow = ta.ema(close, trendSlowLen)
atrValue = ta.atr(atrLen)
trendDistance = (close - trendSlow) / math.max(atrValue, syminfo.mintick)
trendSlope = trendFast - trendSlow

rangeNow = ta.sma(high - low, 5)
rangeBase = ta.sma(high - low, compressionLen)
compressionRatio = rangeNow / math.max(rangeBase, syminfo.mintick)
compressionScore = compressionRatio < 0.85 ? 10.0 : compressionRatio > 1.25 ? -4.0 : 0.0

//------------------------------------------------------------------------------
// Composite engine
//------------------------------------------------------------------------------
waveScore = wtSpread * 1.2
trendScore = trendDistance * 10.0 + (trendSlope / math.max(atrValue, syminfo.mintick)) * 8.0
compositeRaw = waveScore + rsiScore + trendScore + compressionScore
compositeScore = f_clamp(compositeRaw, -100.0, 100.0)
signalLine = ta.ema(compositeScore, 8)
stateDelta = compositeScore - signalLine

confirmedPositive = barstate.isconfirmed and compositeScore > 12 and signalLine > 0 and wtMain > wtSignal
confirmedNegative = barstate.isconfirmed and compositeScore < -12 and signalLine < 0 and wtMain < wtSignal
confirmedCompression = barstate.isconfirmed and compressionRatio < 0.85 and math.abs(compositeScore) < 15
newPositive = confirmedPositive and not confirmedPositive[1]
newNegative = confirmedNegative and not confirmedNegative[1]

//------------------------------------------------------------------------------
// Pane state boxes
//------------------------------------------------------------------------------
var array<box> compressionBoxes = array.new_box()
var array<box> impulseBoxes = array.new_box()

if confirmedCompression and not confirmedCompression[1] and showCompressionBoxes
    box compressionBox = box.new(bar_index, 25, bar_index + 12, -25, xloc=xloc.bar_index, bgcolor=color.new(accentCore, 90), border_color=color.new(accentCore, 0), border_width=1)
    array.push(compressionBoxes, compressionBox)
    f_trim_boxes(compressionBoxes, 8)

if (newPositive or newNegative) and showImpulseBoxes
    color boxColor = newPositive ? bullCore : bearCore
    float topBand = newPositive ? 80.0 : 15.0
    float botBand = newPositive ? 15.0 : -80.0
    box impulseBox = box.new(bar_index, topBand, bar_index + 10, botBand, xloc=xloc.bar_index, bgcolor=color.new(boxColor, 90), border_color=color.new(boxColor, 0), border_width=1)
    array.push(impulseBoxes, impulseBox)
    f_trim_boxes(impulseBoxes, 8)

//------------------------------------------------------------------------------
// Overlay scaffold
//------------------------------------------------------------------------------
var line entryLine = na
var line slLine = na
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na
var line extremeLine = na
var label entryLabel = na
var label slLabel = na
var label tp1Label = na
var label tp2Label = na
var label tp3Label = na
var linefill riskFill = na
var linefill rewardFill = na
var int activeBias = 0

if (newPositive or newNegative) and showScaffold
    f_delete_line(entryLine)
    f_delete_line(slLine)
    f_delete_line(tp1Line)
    f_delete_line(tp2Line)
    f_delete_line(tp3Line)
    f_delete_line(extremeLine)
    f_delete_label(entryLabel)
    f_delete_label(slLabel)
    f_delete_label(tp1Label)
    f_delete_label(tp2Label)
    f_delete_label(tp3Label)
    f_delete_fill(riskFill)
    f_delete_fill(rewardFill)

    activeBias := newPositive ? 1 : -1
    float entryPrice = close
    float slPrice = activeBias == 1 ? close - atrValue * scaffoldAtrMult : close + atrValue * scaffoldAtrMult
    float riskDistance = activeBias == 1 ? math.max(close - slPrice, syminfo.mintick * 5) : math.max(slPrice - close, syminfo.mintick * 5)
    float tp1Price = activeBias == 1 ? close + riskDistance * tpOneR : close - riskDistance * tpOneR
    float tp2Price = activeBias == 1 ? close + riskDistance * tpTwoR : close - riskDistance * tpTwoR
    float tp3Price = activeBias == 1 ? close + riskDistance * tpThreeR : close - riskDistance * tpThreeR

    color entryColor = activeBias == 1 ? bullCore : bearCore
    color stopColor = color.new(activeBias == 1 ? bearCore : bullCore, 30)
    color targetColor = color.new(activeBias == 1 ? bullCore : bearCore, 28)

    entryLine := line.new(bar_index, entryPrice, bar_index + 1, entryPrice, color=color.new(entryColor, 0), width=2, extend=extend.right, force_overlay=true)
    slLine := line.new(bar_index, slPrice, bar_index + 1, slPrice, color=stopColor, width=1, style=line.style_dashed, extend=extend.right, force_overlay=true)
    tp1Line := line.new(bar_index, tp1Price, bar_index + 1, tp1Price, color=targetColor, width=1, extend=extend.right, force_overlay=true)
    tp2Line := line.new(bar_index, tp2Price, bar_index + 1, tp2Price, color=targetColor, width=1, extend=extend.right, force_overlay=true)
    tp3Line := line.new(bar_index, tp3Price, bar_index + 1, tp3Price, color=targetColor, width=1, style=line.style_dotted, extend=extend.right, force_overlay=true)
    extremeLine := line.new(bar_index, tp3Price, bar_index + 1, tp3Price, color=na, extend=extend.right, force_overlay=true)

    entryLabel := label.new(bar_index, entryPrice, activeBias == 1 ? "Momentum Long" : "Momentum Short", style=label.style_label_left, color=color.new(entryColor, 0), textcolor=color.white, size=size.small, force_overlay=true)
    slLabel := label.new(bar_index, slPrice, "SL " + str.tostring(slPrice, format.mintick), style=label.style_label_left, color=stopColor, textcolor=color.white, size=size.small, force_overlay=true)
    tp1Label := label.new(bar_index, tp1Price, "TP1 " + str.tostring(tp1Price, format.mintick), style=label.style_label_left, color=targetColor, textcolor=color.white, size=size.small, force_overlay=true)
    tp2Label := label.new(bar_index, tp2Price, "TP2 " + str.tostring(tp2Price, format.mintick), style=label.style_label_left, color=targetColor, textcolor=color.white, size=size.small, force_overlay=true)
    tp3Label := label.new(bar_index, tp3Price, "TP3 " + str.tostring(tp3Price, format.mintick), style=label.style_label_left, color=targetColor, textcolor=color.white, size=size.small, force_overlay=true)

    riskFill := linefill.new(entryLine, slLine, color.new(activeBias == 1 ? bearCore : bullCore, 72))
    rewardFill := linefill.new(entryLine, extremeLine, color.new(activeBias == 1 ? bullCore : bearCore, 78))

if activeBias == 1 and barstate.isconfirmed and compositeScore < 0
    activeBias := 0
    line.set_extend(entryLine, extend.none)
    line.set_extend(slLine, extend.none)
    line.set_extend(tp1Line, extend.none)
    line.set_extend(tp2Line, extend.none)
    line.set_extend(tp3Line, extend.none)
    line.set_x2(entryLine, bar_index)
    line.set_x2(slLine, bar_index)
    line.set_x2(tp1Line, bar_index)
    line.set_x2(tp2Line, bar_index)
    line.set_x2(tp3Line, bar_index)

if activeBias == -1 and barstate.isconfirmed and compositeScore > 0
    activeBias := 0
    line.set_extend(entryLine, extend.none)
    line.set_extend(slLine, extend.none)
    line.set_extend(tp1Line, extend.none)
    line.set_extend(tp2Line, extend.none)
    line.set_extend(tp3Line, extend.none)
    line.set_x2(entryLine, bar_index)
    line.set_x2(slLine, bar_index)
    line.set_x2(tp1Line, bar_index)
    line.set_x2(tp2Line, bar_index)
    line.set_x2(tp3Line, bar_index)

//------------------------------------------------------------------------------
// Visual system
//------------------------------------------------------------------------------
hZero = hline(0, "Zero", color=color.new(neutralCore, 65))
hUpper = hline(25, "Positive Threshold", color=color.new(bullCore, 75))
hLower = hline(-25, "Negative Threshold", color=color.new(bearCore, 75))
hExtremeUp = hline(60, "Positive Extreme", color=color.new(bullCore, 88))
hExtremeDown = hline(-60, "Negative Extreme", color=color.new(bearCore, 88))

stateUpper = showStateBand ? 25.0 : na
stateLower = showStateBand ? -25.0 : na
stateUpperExtreme = showStateBand ? 60.0 : na
stateLowerExtreme = showStateBand ? -60.0 : na
fogUpperOne = showStateBand ? 10.0 : na
fogUpperTwo = showStateBand ? 35.0 : na
fogUpperThree = showStateBand ? 55.0 : na
fogLowerOne = showStateBand ? -10.0 : na
fogLowerTwo = showStateBand ? -35.0 : na
fogLowerThree = showStateBand ? -55.0 : na

pComposite = plot(showHistogram ? compositeScore : na, "Composite Score", style=plot.style_columns, color=color.new(f_bias_color(compositeScore), 15), linewidth=3)
pSignal = plot(signalLine, "Signal", color=color.new(accentCore, 0), linewidth=2)
pWave = plot(wtMain, "Wave Main", color=color.new(bullCore, 50), linewidth=1)
pWaveSignal = plot(wtSignal, "Wave Signal", color=color.new(bearCore, 50), linewidth=1)
pUpper = plot(stateUpper, "State Upper", color=na)
pLower = plot(stateLower, "State Lower", color=na)
pUpperExtreme = plot(stateUpperExtreme, "State Upper Extreme", color=na)
pLowerExtreme = plot(stateLowerExtreme, "State Lower Extreme", color=na)
pFogUpperOne = plot(fogUpperOne, "Fog Upper 1", color=na)
pFogUpperTwo = plot(fogUpperTwo, "Fog Upper 2", color=na)
pFogUpperThree = plot(fogUpperThree, "Fog Upper 3", color=na)
pFogLowerOne = plot(fogLowerOne, "Fog Lower 1", color=na)
pFogLowerTwo = plot(fogLowerTwo, "Fog Lower 2", color=na)
pFogLowerThree = plot(fogLowerThree, "Fog Lower 3", color=na)

fill(pUpper, pLower, color=showStateBand ? color.new(accentCore, 92) : na, title="Primary State Band")
fill(pUpperExtreme, pUpper, color=showStateBand ? color.new(bullCore, 94) : na, title="Positive Extension Band")
fill(pLower, pLowerExtreme, color=showStateBand ? color.new(bearCore, 94) : na, title="Negative Extension Band")
fill(pWave, pWaveSignal, color=stateDelta >= 0 ? color.new(bullCore, 88) : color.new(bearCore, 88), title="Wave Spread Fill")
fill(pFogUpperOne, pFogUpperTwo, color=showStateBand ? color.new(bullCore, 94) : na, title="Upper Fog 1")
fill(pFogUpperTwo, pFogUpperThree, color=showStateBand ? color.new(bullCore, 97) : na, title="Upper Fog 2")
fill(pFogLowerOne, pFogLowerTwo, color=showStateBand ? color.new(bearCore, 94) : na, title="Lower Fog 1")
fill(pFogLowerTwo, pFogLowerThree, color=showStateBand ? color.new(bearCore, 97) : na, title="Lower Fog 2")

bgcolor(showBackground and confirmedPositive ? color.new(bullCore, 93) : showBackground and confirmedNegative ? color.new(bearCore, 93) : showBackground and confirmedCompression ? color.new(accentCore, 94) : na, title="State Background")

//------------------------------------------------------------------------------
// Dashboard
//------------------------------------------------------------------------------
var table dashboard = table.new(position.top_right, 2, 8, bgcolor=color.new(panelBg, 0), border_color=panelFrame, border_width=1, frame_color=panelFrame, frame_width=1)

if barstate.islast and showDashboard
    table.cell(dashboard, 0, 0, "Covenant", text_color=neutralCore, bgcolor=color.new(panelBg, 0), text_size=size.normal)
    table.cell(dashboard, 1, 0, f_bias_text(compositeScore), text_color=f_bias_color(compositeScore), bgcolor=color.new(panelBg, 0), text_size=size.normal)
    table.cell(dashboard, 0, 1, "Composite", text_color=neutralCore, bgcolor=color.new(panelBg, 0), text_size=size.normal)
    table.cell(dashboard, 1, 1, str.tostring(compositeScore, "#.0"), text_color=f_bias_color(compositeScore), bgcolor=color.new(panelBg, 0), text_size=size.normal)
    table.cell(dashboard, 0, 2, "Signal", text_color=neutralCore, bgcolor=color.new(panelBg, 0), text_size=size.normal)
    table.cell(dashboard, 1, 2, str.tostring(signalLine, "#.0"), text_color=color.new(accentCore, 0), bgcolor=color.new(panelBg, 0), text_size=size.normal)
    table.cell(dashboard, 0, 3, "Wave", text_color=neutralCore, bgcolor=color.new(panelBg, 0), text_size=size.normal)
    table.cell(dashboard, 1, 3, wtMain > wtSignal ? "Positive" : "Negative", text_color=wtMain > wtSignal ? bullCore : bearCore, bgcolor=color.new(panelBg, 0), text_size=size.normal)
    table.cell(dashboard, 0, 4, "RSI", text_color=neutralCore, bgcolor=color.new(panelBg, 0), text_size=size.normal)
    table.cell(dashboard, 1, 4, str.tostring(rsiValue, "#.0"), text_color=rsiValue >= 50 ? bullCore : bearCore, bgcolor=color.new(panelBg, 0), text_size=size.normal)
    table.cell(dashboard, 0, 5, "Compression", text_color=neutralCore, bgcolor=color.new(panelBg, 0), text_size=size.normal)
    table.cell(dashboard, 1, 5, confirmedCompression ? "Active" : compressionRatio < 1.0 ? "Contained" : "Expanded", text_color=confirmedCompression ? accentCore : neutralCore, bgcolor=color.new(panelBg, 0), text_size=size.normal)
    table.cell(dashboard, 0, 6, "Trend Distance", text_color=neutralCore, bgcolor=color.new(panelBg, 0), text_size=size.normal)
    table.cell(dashboard, 1, 6, str.tostring(trendDistance, "#.00") + " ATR", text_color=trendDistance >= 0 ? bullCore : bearCore, bgcolor=color.new(panelBg, 0), text_size=size.normal)
    table.cell(dashboard, 0, 7, "Scaffold", text_color=neutralCore, bgcolor=color.new(panelBg, 0), text_size=size.normal)
    table.cell(dashboard, 1, 7, activeBias == 1 ? "Long Active" : activeBias == -1 ? "Short Active" : "Idle", text_color=activeBias == 1 ? bullCore : activeBias == -1 ? bearCore : neutralCore, bgcolor=color.new(panelBg, 0), text_size=size.normal)
else if barstate.islast
    for col = 0 to 1
        for row = 0 to 7
            table.cell(dashboard, col, row, "", text_color=color.new(neutralCore, 100), bgcolor=color.new(panelBg, 100), text_size=size.normal)

//------------------------------------------------------------------------------
// Commentary
//------------------------------------------------------------------------------
// 1. WaveTrend provides turning-point rhythm.
// 2. RSI displacement measures momentum displacement from fair balance.
// 3. Trend distance normalizes location against ATR so the pane remains portable.
// 4. Compression boxes isolate pre-expansion states.
// 5. The force-overlay scaffold is informational and updates only on confirmed shifts.

//------------------------------------------------------------------------------
// Alerts
//------------------------------------------------------------------------------
alertcondition(confirmedPositive, "Confirmed Positive Covenant", "Momentum Covenant Bias [JOAT]: confirmed positive momentum covenant")
alertcondition(confirmedNegative, "Confirmed Negative Covenant", "Momentum Covenant Bias [JOAT]: confirmed negative momentum covenant")
alertcondition(confirmedCompression, "Confirmed Compression Covenant", "Momentum Covenant Bias [JOAT]: confirmed compression state")
````
