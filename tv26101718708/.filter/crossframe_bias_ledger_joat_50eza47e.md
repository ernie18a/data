# Crossframe Bias Ledger [JOAT]

- url: https://www.tradingview.com/script/50ezA47e-Crossframe-Bias-Ledger-JOAT/
- type: indicator
- pine_id: PUB;6c4f63faa9de42e89a47204b1408549f
- version: 1.0

## Description

[b]Crossframe Bias Ledger [JOAT][/b]

[b]Introduction[/b]

Crossframe Bias Ledger is an open-source non-repainting higher-timeframe bias overlay built to align an intermediate timeframe, a major timeframe, and the local chart into one directional map. It uses safely delayed `request.security()` calls, crossframe basis clouds, premium/discount rails, alignment boxes, execution-state labels, and an optional TP/SL scaffold on fresh confirmed alignment shifts.

The script solves directional context across timeframes. Many local signals fail because they are taken against dominant higher-timeframe structure. Crossframe Bias Ledger keeps the user anchored to higher-timeframe alignment while still making the output actionable on the trading timeframe.

[image]https://www.tradingview.com/x/v55N8n6h/[/image]


[b]Core Concepts[/b]

[b]1. Safe Higher-Timeframe Requests[/b]

All higher-timeframe values are retrieved using delayed indexing so incomplete higher-timeframe bars do not leak into the current chart:

[pine]
idxHigher  = barstate.isrealtime ? 1 : 0
idxCurrent = barstate.isrealtime ? 0 : 1
[/pine]

[b]2. Primary and Secondary Trend Stacks[/b]

Fast, slow, and signal EMAs are retrieved from two higher timeframes and converted into directional scores.

[b]3. Premium / Discount Map[/b]

The two higher-timeframe bases define a premium/discount zone. Price trading above the upper rail is treated as premium. Price trading below the lower rail is treated as discount. Price between them is treated as rebalancing.

[b]4. Fresh Alignment Shifts[/b]

When the crossframe score crosses into confirmed bullish or bearish alignment, the script marks this as a fresh state transition and can build an informational TP/SL ladder.

[b]5. Rebalance vs Continuation Logic[/b]

The script distinguishes rebalancing entries inside the premium/discount box from continuation conditions outside it.

[b]Features[/b]

[list]
[*][b]Non-repainting crossframe logic:[/b] Uses safely delayed higher-timeframe requests
[*][b]Dual cloud system:[/b] Primary and secondary timeframe clouds on the chart
[*][b]Premium / discount rails:[/b] Crossframe valuation map between the two HTF bases
[*][b]Bias box:[/b] Forward execution window for the current crossframe state
[*][b]Fresh alignment detection:[/b] Distinguishes a new bull/bear shift from an already active state
[*][b]Continuation and rebalance readouts:[/b] Shows whether price is extending or rebalancing
[*][b]Optional TP/SL ladder:[/b] Informational scaffold for new alignment shifts
[*][b]Top-right dashboard:[/b] Displays state, signal, timeframe bias, location, execution mode, basis, and score
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1:[/b] Read whether the state is aligned up, aligned down, or mixed.

[b]Step 2:[/b] Check if price is trading in premium, discount, or rebalance territory.

[b]Step 3:[/b] Use fresh shifts to identify new state transitions. Use continuation and rebalance readings to differentiate execution style.

[b]Step 4:[/b] Keep local entries aligned with the dominant crossframe bias whenever possible.

[b]Indicator Limitations[/b]

[list]
[*]Higher-timeframe logic is intentionally delayed for safety, so it will not react as quickly as unstable lookahead-based implementations
[*]Premium/discount interpretation depends on the chosen timeframes
[*]Mixed states are intentional and may persist when higher timeframes disagree
[*]The TP/SL ladder is informational and does not place trades
[/list]

[b]Originality Statement[/b]

Crossframe Bias Ledger is original in the way it combines safe higher-timeframe delay logic, dual-basis premium/discount mapping, fresh alignment shifts, and execution-state scaffolding into one open-source overlay. The script is intended to provide a reusable top-down directional framework rather than a generic MTF trend line.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Higher-timeframe alignment may still fail, reverse, or become mixed as new data forms. Always use independent analysis and risk management.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Crossframe Bias Ledger [JOAT]", shorttitle="CBL [JOAT]", overlay=true, max_lines_count=180, max_boxes_count=120, max_labels_count=40)

//------------------------------------------------------------------------------
// Crossframe Bias Ledger [JOAT]
// Non-repainting higher-timeframe bias overlay.
// The script uses confirmed higher-timeframe ranges, stacked clouds, state
// zones, and optional TP/SL scaffolds when a new bias regime is confirmed.
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
groupFrames = "Crossframe Engine"
primaryTf = input.timeframe("240", "Primary Bias Timeframe", group=groupFrames)
secondaryTf = input.timeframe("1D", "Secondary Bias Timeframe", group=groupFrames)
fastLen = input.int(21, "Fast EMA Length", minval=2, maxval=100, group=groupFrames)
slowLen = input.int(55, "Slow EMA Length", minval=3, maxval=200, group=groupFrames)
signalLen = input.int(13, "Signal EMA Length", minval=2, maxval=100, group=groupFrames)
atrLen = input.int(14, "ATR Length", minval=2, maxval=100, group=groupFrames)
cloudMult = input.float(0.8, "Cloud ATR Multiplier", minval=0.1, step=0.1, group=groupFrames)

groupZones = "Range Zones"
showPrimaryRange = input.bool(true, "Show Primary Range Zone", group=groupZones)
showSecondaryRange = input.bool(true, "Show Secondary Range Zone", group=groupZones)
keepRangeZones = input.int(6, "Stored Range Zones", minval=1, maxval=20, group=groupZones)
rangeBoxTransparency = input.int(88, "Range Transparency", minval=50, maxval=98, group=groupZones)

groupRisk = "Bias Scaffold"
showBiasScaffold = input.bool(true, "Show Bias TP/SL Scaffold", group=groupRisk)
scaffoldAtrMult = input.float(1.5, "Stop ATR Multiplier", minval=0.3, step=0.1, group=groupRisk)
tpOneR = input.float(1.0, "TP1 R", minval=0.4, step=0.1, group=groupRisk)
tpTwoR = input.float(2.0, "TP2 R", minval=0.6, step=0.1, group=groupRisk)
tpThreeR = input.float(3.0, "TP3 R", minval=1.0, step=0.1, group=groupRisk)

groupDisplay = "Visual Design"
showPrimaryCloud = input.bool(true, "Show Primary Cloud", group=groupDisplay)
showSecondaryCloud = input.bool(true, "Show Secondary Cloud", group=groupDisplay)
showSignalBoxes = input.bool(true, "Show Alignment Boxes", group=groupDisplay)
showDashboard = input.bool(true, "Show Dashboard", group=groupDisplay)
showBarBias = input.bool(true, "Color Candles", group=groupDisplay)
showBackdrop = input.bool(true, "Show Bias Backdrop", group=groupDisplay)

groupPalette = "Dark Palette"
bullCore = input.color(color.rgb(0, 201, 166), "Bull Core", group=groupPalette)
bearCore = input.color(color.rgb(255, 92, 118), "Bear Core", group=groupPalette)
neutralCore = input.color(color.rgb(148, 163, 184), "Neutral Core", group=groupPalette)
accentCore = input.color(color.rgb(255, 204, 92), "Cloud Accent", group=groupPalette)
panelBg = input.color(color.rgb(11, 18, 32), "Panel Background", group=groupPalette)
panelFrame = input.color(color.rgb(58, 76, 109), "Panel Frame", group=groupPalette)

//------------------------------------------------------------------------------
// Helpers
//------------------------------------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_state_color(float score) =>
    score >= 15 ? bullCore :
     score <= -15 ? bearCore : neutralCore

f_state_text(float score) =>
    score >= 45 ? "Aligned Up" :
     score >= 15 ? "Constructive" :
     score <= -45 ? "Aligned Down" :
     score <= -15 ? "Defensive" : "Mixed"

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
// Safe higher-timeframe requests
//------------------------------------------------------------------------------
idxHigher = barstate.isrealtime ? 1 : 0
idxCurrent = barstate.isrealtime ? 0 : 1

primaryFast = request.security(syminfo.tickerid, primaryTf, ta.ema(close, fastLen)[idxHigher], lookahead=barmerge.lookahead_on)[idxCurrent]
primarySlow = request.security(syminfo.tickerid, primaryTf, ta.ema(close, slowLen)[idxHigher], lookahead=barmerge.lookahead_on)[idxCurrent]
primarySignal = request.security(syminfo.tickerid, primaryTf, ta.ema(close, signalLen)[idxHigher], lookahead=barmerge.lookahead_on)[idxCurrent]
primaryAtr = request.security(syminfo.tickerid, primaryTf, ta.atr(atrLen)[idxHigher], lookahead=barmerge.lookahead_on)[idxCurrent]
[primaryHigh, primaryLow, primaryClose] = request.security(syminfo.tickerid, primaryTf, [high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)

secondaryFast = request.security(syminfo.tickerid, secondaryTf, ta.ema(close, fastLen)[idxHigher], lookahead=barmerge.lookahead_on)[idxCurrent]
secondarySlow = request.security(syminfo.tickerid, secondaryTf, ta.ema(close, slowLen)[idxHigher], lookahead=barmerge.lookahead_on)[idxCurrent]
secondarySignal = request.security(syminfo.tickerid, secondaryTf, ta.ema(close, signalLen)[idxHigher], lookahead=barmerge.lookahead_on)[idxCurrent]
secondaryAtr = request.security(syminfo.tickerid, secondaryTf, ta.atr(atrLen)[idxHigher], lookahead=barmerge.lookahead_on)[idxCurrent]
[secondaryHigh, secondaryLow, secondaryClose] = request.security(syminfo.tickerid, secondaryTf, [high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)

//------------------------------------------------------------------------------
// Score engine
//------------------------------------------------------------------------------
primaryBasis = (primaryFast + primarySlow) * 0.5
secondaryBasis = (secondaryFast + secondarySlow) * 0.5

primaryUpper = primaryBasis + primaryAtr * cloudMult
primaryLower = primaryBasis - primaryAtr * cloudMult
secondaryUpper = secondaryBasis + secondaryAtr * cloudMult
secondaryLower = secondaryBasis - secondaryAtr * cloudMult

localFast = ta.ema(close, fastLen)
localSlow = ta.ema(close, slowLen)
localSignal = ta.ema(close, signalLen)
localAtr = ta.atr(atrLen)
localBasis = (localFast + localSlow) * 0.5

primaryScore = (primaryFast - primarySlow) / math.max(primaryAtr, syminfo.mintick) * 34.0 + (primaryFast - primarySignal) / math.max(primaryAtr, syminfo.mintick) * 10.0
secondaryScore = (secondaryFast - secondarySlow) / math.max(secondaryAtr, syminfo.mintick) * 42.0 + (secondaryFast - secondarySignal) / math.max(secondaryAtr, syminfo.mintick) * 12.0
locationScore = (close - primaryBasis) / math.max(primaryAtr, syminfo.mintick) * 16.0
localScore = (localFast - localSlow) / math.max(localAtr, syminfo.mintick) * 14.0 + (close - localBasis) / math.max(localAtr, syminfo.mintick) * 10.0
ledgerScore = f_clamp(primaryScore + secondaryScore + locationScore + localScore, -100.0, 100.0)

primaryAlignedBull = primaryFast >= primarySlow and primaryClose >= primaryBasis
primaryAlignedBear = primaryFast <= primarySlow and primaryClose <= primaryBasis
secondaryAlignedBull = secondaryFast >= secondarySlow and secondaryClose >= secondaryBasis
secondaryAlignedBear = secondaryFast <= secondarySlow and secondaryClose <= secondaryBasis

confirmedBull = barstate.isconfirmed and ledgerScore >= 20 and primaryAlignedBull and secondaryAlignedBull and close >= localBasis
confirmedBear = barstate.isconfirmed and ledgerScore <= -20 and primaryAlignedBear and secondaryAlignedBear and close <= localBasis
newBullRegime = confirmedBull and not confirmedBull[1]
newBearRegime = confirmedBear and not confirmedBear[1]
mixedState = not confirmedBull and not confirmedBear

//------------------------------------------------------------------------------
// Context zones and alignment boxes
//------------------------------------------------------------------------------
var array<box> primaryZoneBoxes = array.new_box()
var array<box> secondaryZoneBoxes = array.new_box()
var array<box> alignmentBoxes = array.new_box()

if newBullRegime or newBearRegime
    if showPrimaryRange
        color rangeColor = color.new(newBullRegime ? bullCore : bearCore, rangeBoxTransparency)
        box primaryZone = box.new(bar_index, primaryHigh, bar_index + 1, primaryLow, xloc=xloc.bar_index, extend=extend.right, bgcolor=rangeColor, border_color=color.new(newBullRegime ? bullCore : bearCore, 0), border_width=2)
        array.push(primaryZoneBoxes, primaryZone)
        f_trim_boxes(primaryZoneBoxes, keepRangeZones)

    if showSecondaryRange
        color rangeColor = color.new(newBullRegime ? bullCore : bearCore, math.min(rangeBoxTransparency + 4, 96))
        box secondaryZone = box.new(bar_index, secondaryHigh, bar_index + 1, secondaryLow, xloc=xloc.bar_index, extend=extend.right, bgcolor=rangeColor, border_color=color.new(accentCore, 25), border_width=1)
        array.push(secondaryZoneBoxes, secondaryZone)
        f_trim_boxes(secondaryZoneBoxes, keepRangeZones)

    if showSignalBoxes
        float alignTop = math.max(primaryHigh, secondaryHigh)
        float alignBottom = math.min(primaryLow, secondaryLow)
        box alignmentZone = box.new(bar_index, alignTop, bar_index + 12, alignBottom, xloc=xloc.bar_index, extend=extend.none, bgcolor=color.new(newBullRegime ? bullCore : bearCore, 86), border_color=color.new(newBullRegime ? bullCore : bearCore, 0), border_width=2)
        array.push(alignmentBoxes, alignmentZone)
        f_trim_boxes(alignmentBoxes, keepRangeZones)

//------------------------------------------------------------------------------
// Bias scaffold
//------------------------------------------------------------------------------
var line entryLine = na
var line slLine = na
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na
var label entryLabel = na
var label slLabel = na
var label tp1Label = na
var label tp2Label = na
var label tp3Label = na
var line extremeLine = na
var linefill riskFill = na
var linefill rewardFill = na
var int activeBias = 0

if (newBullRegime or newBearRegime) and showBiasScaffold
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

    activeBias := newBullRegime ? 1 : -1
    float entryPrice = close
    float stopAnchor = activeBias == 1 ? math.min(primaryLow, close - localAtr * scaffoldAtrMult) : math.max(primaryHigh, close + localAtr * scaffoldAtrMult)
    float riskDistance = activeBias == 1 ? math.max(entryPrice - stopAnchor, syminfo.mintick * 5) : math.max(stopAnchor - entryPrice, syminfo.mintick * 5)
    float slPrice = activeBias == 1 ? entryPrice - riskDistance : entryPrice + riskDistance
    float tp1Price = activeBias == 1 ? entryPrice + riskDistance * tpOneR : entryPrice - riskDistance * tpOneR
    float tp2Price = activeBias == 1 ? entryPrice + riskDistance * tpTwoR : entryPrice - riskDistance * tpTwoR
    float tp3Price = activeBias == 1 ? entryPrice + riskDistance * tpThreeR : entryPrice - riskDistance * tpThreeR

    color entryColor = activeBias == 1 ? bullCore : bearCore
    color stopColor = color.new(activeBias == 1 ? bearCore : bullCore, 30)
    color targetColor = color.new(activeBias == 1 ? bullCore : bearCore, 28)

    entryLine := line.new(bar_index, entryPrice, bar_index + 1, entryPrice, color=color.new(entryColor, 0), width=2, extend=extend.right)
    slLine := line.new(bar_index, slPrice, bar_index + 1, slPrice, color=stopColor, width=1, style=line.style_dashed, extend=extend.right)
    tp1Line := line.new(bar_index, tp1Price, bar_index + 1, tp1Price, color=targetColor, width=1, extend=extend.right)
    tp2Line := line.new(bar_index, tp2Price, bar_index + 1, tp2Price, color=targetColor, width=1, extend=extend.right)
    tp3Line := line.new(bar_index, tp3Price, bar_index + 1, tp3Price, color=targetColor, width=1, style=line.style_dotted, extend=extend.right)
    extremeLine := line.new(bar_index, tp3Price, bar_index + 1, tp3Price, color=na, extend=extend.right)

    entryLabel := label.new(bar_index, entryPrice, activeBias == 1 ? "Bias Long" : "Bias Short", style=label.style_label_left, color=color.new(entryColor, 0), textcolor=color.white, size=size.small)
    slLabel := label.new(bar_index, slPrice, "SL " + str.tostring(slPrice, format.mintick), style=label.style_label_left, color=stopColor, textcolor=color.white, size=size.small)
    tp1Label := label.new(bar_index, tp1Price, "TP1 " + str.tostring(tp1Price, format.mintick), style=label.style_label_left, color=targetColor, textcolor=color.white, size=size.small)
    tp2Label := label.new(bar_index, tp2Price, "TP2 " + str.tostring(tp2Price, format.mintick), style=label.style_label_left, color=targetColor, textcolor=color.white, size=size.small)
    tp3Label := label.new(bar_index, tp3Price, "TP3 " + str.tostring(tp3Price, format.mintick), style=label.style_label_left, color=targetColor, textcolor=color.white, size=size.small)

    riskFill := linefill.new(entryLine, slLine, color.new(activeBias == 1 ? bearCore : bullCore, 72))
    rewardFill := linefill.new(entryLine, extremeLine, color.new(activeBias == 1 ? bullCore : bearCore, 78))

if activeBias == 1 and barstate.isconfirmed and (close < localBasis or ledgerScore < 0)
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

if activeBias == -1 and barstate.isconfirmed and (close > localBasis or ledgerScore > 0)
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
// Visual layer
//------------------------------------------------------------------------------
plotPrimaryUpper = plot(showPrimaryCloud ? primaryUpper : na, "Primary Upper", color=color.new(accentCore, 45), linewidth=1)
plotPrimaryLower = plot(showPrimaryCloud ? primaryLower : na, "Primary Lower", color=color.new(accentCore, 45), linewidth=1)
plotPrimaryBasis = plot(showPrimaryCloud ? primaryBasis : na, "Primary Basis", color=color.new(accentCore, 0), linewidth=2)
plotSecondaryUpper = plot(showSecondaryCloud ? secondaryUpper : na, "Secondary Upper", color=color.new(bullCore, 65), linewidth=1)
plotSecondaryLower = plot(showSecondaryCloud ? secondaryLower : na, "Secondary Lower", color=color.new(bearCore, 65), linewidth=1)
plotSecondaryBasis = plot(showSecondaryCloud ? secondaryBasis : na, "Secondary Basis", color=color.new(f_state_color(ledgerScore), 0), linewidth=2)
plotLocalBasis = plot(localBasis, "Local Basis", color=color.new(neutralCore, 30), linewidth=1)
plotPrimaryClose = plot(showPrimaryCloud ? primaryClose : na, "Primary Close", color=color.new(accentCore, 80), linewidth=1)
plotSecondaryClose = plot(showSecondaryCloud ? secondaryClose : na, "Secondary Close", color=color.new(f_state_color(ledgerScore), 80), linewidth=1)

fill(plotPrimaryUpper, plotPrimaryLower, color=showPrimaryCloud ? color.new(accentCore, 92) : na, title="Primary Range Cloud")
fill(plotSecondaryUpper, plotSecondaryLower, color=showSecondaryCloud ? color.new(f_state_color(ledgerScore), 93) : na, title="Secondary Range Cloud")
fill(plotPrimaryBasis, plotPrimaryClose, color=showPrimaryCloud ? color.new(accentCore, 88) : na, title="Primary Close Bias")
fill(plotSecondaryBasis, plotSecondaryClose, color=showSecondaryCloud ? color.new(f_state_color(ledgerScore), 88) : na, title="Secondary Close Bias")

barcolor(showBarBias ? color.new(f_state_color(ledgerScore), math.abs(ledgerScore) < 15 ? 72 : 12) : na)
bgcolor(showBackdrop and confirmedBull ? color.new(bullCore, 93) : showBackdrop and confirmedBear ? color.new(bearCore, 93) : showBackdrop and mixedState ? color.new(accentCore, 96) : na, title="Crossframe Backdrop")

plot(primaryHigh, "Primary High", color=showPrimaryRange ? color.new(bullCore, 85) : na, linewidth=1, style=plot.style_linebr)
plot(primaryLow, "Primary Low", color=showPrimaryRange ? color.new(bearCore, 85) : na, linewidth=1, style=plot.style_linebr)
plot(secondaryHigh, "Secondary High", color=showSecondaryRange ? color.new(bullCore, 92) : na, linewidth=1, style=plot.style_linebr)
plot(secondaryLow, "Secondary Low", color=showSecondaryRange ? color.new(bearCore, 92) : na, linewidth=1, style=plot.style_linebr)

//------------------------------------------------------------------------------
// Dashboard
//------------------------------------------------------------------------------
var table dashboard = table.new(position.top_right, 2, 8, bgcolor=color.new(panelBg, 0), border_width=1, border_color=panelFrame, frame_width=1, frame_color=panelFrame)

if barstate.islast and showDashboard
    string primaryText = primaryAlignedBull ? "Positive" : primaryAlignedBear ? "Negative" : "Mixed"
    string secondaryText = secondaryAlignedBull ? "Positive" : secondaryAlignedBear ? "Negative" : "Mixed"
    string locationText = close >= primaryBasis ? "Above Primary" : "Below Primary"
    string scaffoldText = activeBias == 1 ? "Long Scaffold" : activeBias == -1 ? "Short Scaffold" : "Idle"

    table.cell(dashboard, 0, 0, "Ledger", text_color=neutralCore, bgcolor=color.new(panelBg, 0), text_size=size.normal)
    table.cell(dashboard, 1, 0, f_state_text(ledgerScore), text_color=f_state_color(ledgerScore), bgcolor=color.new(panelBg, 0), text_size=size.normal)
    table.cell(dashboard, 0, 1, "Primary", text_color=neutralCore, bgcolor=color.new(panelBg, 0), text_size=size.normal)
    table.cell(dashboard, 1, 1, primaryTf + " | " + primaryText, text_color=primaryAlignedBull ? bullCore : primaryAlignedBear ? bearCore : neutralCore, bgcolor=color.new(panelBg, 0), text_size=size.normal)
    table.cell(dashboard, 0, 2, "Secondary", text_color=neutralCore, bgcolor=color.new(panelBg, 0), text_size=size.normal)
    table.cell(dashboard, 1, 2, secondaryTf + " | " + secondaryText, text_color=secondaryAlignedBull ? bullCore : secondaryAlignedBear ? bearCore : neutralCore, bgcolor=color.new(panelBg, 0), text_size=size.normal)
    table.cell(dashboard, 0, 3, "Location", text_color=neutralCore, bgcolor=color.new(panelBg, 0), text_size=size.normal)
    table.cell(dashboard, 1, 3, locationText, text_color=close >= primaryBasis ? bullCore : bearCore, bgcolor=color.new(panelBg, 0), text_size=size.normal)
    table.cell(dashboard, 0, 4, "Primary Range", text_color=neutralCore, bgcolor=color.new(panelBg, 0), text_size=size.normal)
    table.cell(dashboard, 1, 4, str.tostring(primaryHigh - primaryLow, format.mintick), text_color=accentCore, bgcolor=color.new(panelBg, 0), text_size=size.normal)
    table.cell(dashboard, 0, 5, "Secondary Range", text_color=neutralCore, bgcolor=color.new(panelBg, 0), text_size=size.normal)
    table.cell(dashboard, 1, 5, str.tostring(secondaryHigh - secondaryLow, format.mintick), text_color=accentCore, bgcolor=color.new(panelBg, 0), text_size=size.normal)
    table.cell(dashboard, 0, 6, "Score", text_color=neutralCore, bgcolor=color.new(panelBg, 0), text_size=size.normal)
    table.cell(dashboard, 1, 6, str.tostring(ledgerScore, "#.0"), text_color=f_state_color(ledgerScore), bgcolor=color.new(panelBg, 0), text_size=size.normal)
    table.cell(dashboard, 0, 7, "Scaffold", text_color=neutralCore, bgcolor=color.new(panelBg, 0), text_size=size.normal)
    table.cell(dashboard, 1, 7, scaffoldText, text_color=activeBias == 1 ? bullCore : activeBias == -1 ? bearCore : neutralCore, bgcolor=color.new(panelBg, 0), text_size=size.normal)
else if barstate.islast
    for col = 0 to 1
        for row = 0 to 7
            table.cell(dashboard, col, row, "", text_color=color.new(neutralCore, 100), bgcolor=color.new(panelBg, 100), text_size=size.normal)

//------------------------------------------------------------------------------
// Notes
//------------------------------------------------------------------------------
// 1. Higher-timeframe requests use lookahead_on with historical offsets.
// 2. Range zones are created only when new bull/bear alignment is confirmed.
// 3. The bias scaffold is an informational risk map, not a strategy order model.
// 4. Heavy object creation is event-driven to avoid constant redraw pressure.

//------------------------------------------------------------------------------
// Alerts
//------------------------------------------------------------------------------
alertcondition(newBullRegime, "Crossframe Bull Regime", "Crossframe Bias Ledger [JOAT]: confirmed bull regime alignment")
alertcondition(newBearRegime, "Crossframe Bear Regime", "Crossframe Bias Ledger [JOAT]: confirmed bear regime alignment")
alertcondition(confirmedBull, "Crossframe Bull", "Crossframe Bias Ledger [JOAT]: confirmed constructive alignment")
alertcondition(confirmedBear, "Crossframe Bear", "Crossframe Bias Ledger [JOAT]: confirmed defensive alignment")
````
