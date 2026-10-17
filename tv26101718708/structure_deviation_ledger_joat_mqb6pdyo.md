# Structure Deviation Ledger [JOAT]

- url: https://www.tradingview.com/script/MqB6PdyO-Structure-Deviation-Ledger-JOAT/
- type: indicator
- pine_id: PUB;5b0b982064ce49c984d7afd56bd44173
- version: 1.0

## Description

[b]Structure Deviation Ledger [JOAT][/b]

[b]Introduction[/b]

Structure Deviation Ledger is an open-source structure-tracking overlay designed to monitor how price behaves around a stepped volatility corridor and pivot-derived structure rails. It combines pivot rail continuation, a stateful stepped midpoint, inner and outer ATR corridors, frozen breakout rails, right-edge structural labels, and an optional TP/SL scaffold when confirmed structural displacement occurs.

The purpose of the script is to answer a practical question: is price still behaving inside accepted structure, or has it displaced far enough to qualify as a meaningful structural event? By scoring deviation relative to a stepped corridor and confirmed pivot rails, the indicator provides a cleaner framework for continuation and failure analysis than simple moving-average crossovers.

[image]https://www.tradingview.com/x/MH9UL2c7/[/image]

[b]Core Concepts[/b]

[b]1. Pivot-Derived Structure Rails[/b]

Confirmed pivot highs and lows are connected into forward rails. These rails act as the nearest structural references for continuation or failure.

[b]2. Stepped ATR Corridor[/b]

The script maintains a stepped midpoint derived from a smoothed basis and ATR logic. The midpoint only reanchors when price stretches far enough to justify a structural adjustment.

[b]3. Confirmed Structural Breaks[/b]

A structural break is only promoted when price closes beyond the relevant active rail and also pushes outside the inner corridor. This confirmation rule is designed to reduce weak intrabar noise.

[b]4. Frozen Break Rails[/b]

When a fresh break is confirmed, the script freezes a breakout rail and a related context box so the chart retains forward reference after the initial event.

[b]5. Execution Scaffold[/b]

On fresh structural expansion or structural pressure events, the indicator can build an informational TP/SL ladder using ATR-based stop distance and configurable R multiples.

[b]Features[/b]

[list]
[*][b]Pivot structure rails:[/b] Forward-projected high and low rails derived from confirmed pivots
[*][b]Stepped structure midpoint:[/b] State-aware corridor center that does not update every bar like a normal average
[*][b]Inner and outer ATR corridors:[/b] Layered bands for contained vs displaced price behavior
[*][b]Fresh break detection:[/b] Confirmed-bar breakout logic for upside and downside structural events
[*][b]Frozen break rails and zones:[/b] Persistent post-break context on the chart
[*][b]Right-edge labels:[/b] Live labels for midpoint, inner levels, and active rail reference
[*][b]Optional TP/SL ladder:[/b] Entry, stop, TP1, TP2, TP3 with risk/reward fill
[*][b]Top-right dashboard:[/b] Displays current structural state, deviation, corridor levels, and rail count
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1:[/b] Read whether price is inside the corridor or displacing beyond it.

[b]Step 2:[/b] Compare price to the active high or low rail. These are the nearest structure references.

[b]Step 3:[/b] When a fresh confirmed break appears, use the frozen rail and optional ladder as a planning map, not as a guarantee.

[b]Step 4:[/b] If price returns back through the corridor after a break, treat that as a sign of failed displacement.

[b]Indicator Limitations[/b]

[list]
[*]Pivot rails are naturally delayed because pivots require confirmed bars on both sides
[*]Stepped corridors intentionally lag during transitions in order to avoid unstable shifting
[*]A dense market with many pivots can still generate frequent rail updates
[*]The TP/SL ladder is informational only and does not place orders
[/list]

[b]Originality Statement[/b]

Structure Deviation Ledger is original in the way it merges pivot-derived structural rails, a stepped ATR corridor, frozen breakout context, and execution scaffolding into a single open-source structure overlay. Its goal is to provide a reusable institutional structure map rather than a simplified breakout marker.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Structural breaks and corridor deviations are derived from historical price action and do not guarantee future movement. Always use appropriate risk controls.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Structure Deviation Ledger [JOAT]", shorttitle = "SDL [JOAT]", overlay = true, max_bars_back = 2500, max_lines_count = 320, max_labels_count = 80)

//------------------------------------------------------------------------------
// Structure Deviation Ledger [JOAT]
// Tracks pivot-derived structure rails, wraps price in a stepped ATR corridor,
// and scores confirmed deviation when price pushes beyond accepted structure.
//------------------------------------------------------------------------------

groupPivot = "Structure Rails"
pivotLeft = input.int(9, "Pivot Left", minval = 2, maxval = 30, group = groupPivot)
pivotRight = input.int(9, "Pivot Right", minval = 2, maxval = 30, group = groupPivot)
maxHighRails = input.int(6, "Max High Rails", minval = 1, maxval = 20, group = groupPivot)
maxLowRails = input.int(6, "Max Low Rails", minval = 1, maxval = 20, group = groupPivot)
maxExtendBars = input.int(280, "Rail Extension Bars", minval = 50, maxval = 500, group = groupPivot)

groupChannel = "Deviation Corridor"
stepBaseLen = input.int(21, "Step Basis Length", minval = 5, maxval = 100, group = groupChannel)
stepAtrLen = input.int(14, "ATR Length", minval = 2, maxval = 100, group = groupChannel)
innerAtrMult = input.float(1.4, "Inner ATR Multiplier", minval = 0.2, step = 0.1, group = groupChannel)
outerAtrMult = input.float(2.4, "Outer ATR Multiplier", minval = 0.4, step = 0.1, group = groupChannel)

groupDisplay = "Display"
showCorridor = input.bool(true, "Show Corridor", group = groupDisplay)
showDashboard = input.bool(true, "Show Dashboard", group = groupDisplay)
showCandleState = input.bool(true, "Color Candles", group = groupDisplay)
showBreakBackground = input.bool(true, "Shade Confirmed Breaks", group = groupDisplay)

groupExecution = "Execution Furniture"
showFrozenRails = input.bool(true, "Show Frozen Break Rails", group = groupExecution)
showRightLabels = input.bool(true, "Show Right Edge Labels", group = groupExecution)
showTargetLadder = input.bool(true, "Show TP SL Ladder", group = groupExecution)
stopAtrMult = input.float(1.5, "Stop ATR Multiplier", minval = 0.4, step = 0.1, group = groupExecution)
tpOneR = input.float(1.0, "TP1 R", minval = 0.4, step = 0.1, group = groupExecution)
tpTwoR = input.float(2.0, "TP2 R", minval = 0.8, step = 0.1, group = groupExecution)
tpThreeR = input.float(3.0, "TP3 R", minval = 1.0, step = 0.1, group = groupExecution)

groupTheme = "Dark Palette"
bullCore = input.color(color.rgb(0, 206, 177), "Bull Core", group = groupTheme)
bearCore = input.color(color.rgb(255, 92, 116), "Bear Core", group = groupTheme)
neutralCore = input.color(color.rgb(148, 163, 184), "Neutral Core", group = groupTheme)
accentCore = input.color(color.rgb(244, 196, 84), "Accent", group = groupTheme)
panelBg = input.color(color.rgb(11, 18, 32), "Panel Background", group = groupTheme)
panelFrame = input.color(color.rgb(58, 76, 109), "Panel Frame", group = groupTheme)

//------------------------------------------------------------------------------
// Helpers
//------------------------------------------------------------------------------
f_trim_lines(array<line> linesRef, array<int> bornRef, int maxKeep) =>
    while array.size(linesRef) > maxKeep
        line stale = array.shift(linesRef)
        array.shift(bornRef)
        line.delete(stale)

f_state_color(int bias) =>
    bias > 0 ? bullCore : bias < 0 ? bearCore : neutralCore

f_state_text(int bias) =>
    bias > 0 ? "Positive" : bias < 0 ? "Negative" : "Balanced"

f_line_price(line rail) =>
    line.get_price(rail, bar_index)

f_clear_trade_lines(line a, line b, line c, line d, line e, linefill rf, linefill pf) =>
    if not na(a)
        line.delete(a)
    if not na(b)
        line.delete(b)
    if not na(c)
        line.delete(c)
    if not na(d)
        line.delete(d)
    if not na(e)
        line.delete(e)
    if not na(rf)
        linefill.delete(rf)
    if not na(pf)
        linefill.delete(pf)

//------------------------------------------------------------------------------
// Stepped corridor
//------------------------------------------------------------------------------
stepAtr = ta.atr(stepAtrLen)
baseStep = ta.sma(close, stepBaseLen)

var float stepMid = na
if na(stepMid)
    stepMid := baseStep

innerUpperPrev = stepMid + stepAtr * innerAtrMult
innerLowerPrev = stepMid - stepAtr * innerAtrMult
outerUpperPrev = stepMid + stepAtr * outerAtrMult
outerLowerPrev = stepMid - stepAtr * outerAtrMult

if close > outerUpperPrev
    stepMid := baseStep
else if close < outerLowerPrev
    stepMid := baseStep
else
    stepMid := nz(stepMid[1], baseStep)

innerUpper = stepMid + stepAtr * innerAtrMult
innerLower = stepMid - stepAtr * innerAtrMult
outerUpper = stepMid + stepAtr * outerAtrMult
outerLower = stepMid - stepAtr * outerAtrMult
stepSlope = stepMid - nz(stepMid[1], stepMid)

//------------------------------------------------------------------------------
// Structure rails
//------------------------------------------------------------------------------
pivotHigh = ta.pivothigh(high, pivotLeft, pivotRight)
pivotLow = ta.pivotlow(low, pivotLeft, pivotRight)
highBar = bar_index - pivotRight
lowBar = bar_index - pivotRight

var float prevHighPrice = na
var int prevHighBar = na
var float prevLowPrice = na
var int prevLowBar = na

var array<line> highRails = array.new_line()
var array<int> highBorn = array.new_int()
var array<line> lowRails = array.new_line()
var array<int> lowBorn = array.new_int()

if not na(pivotHigh)
    if not na(prevHighPrice)
        float slope = (pivotHigh - prevHighPrice) / math.max(highBar - prevHighBar, 1)
        int x2 = math.min(highBar + maxExtendBars, bar_index + 500)
        float y2 = pivotHigh + slope * (x2 - highBar)
        line rail = line.new(prevHighBar, prevHighPrice, x2, y2, xloc = xloc.bar_index, color = color.new(bearCore, 10), width = 2)
        array.push(highRails, rail)
        array.push(highBorn, bar_index)
        f_trim_lines(highRails, highBorn, maxHighRails)
    prevHighPrice := pivotHigh
    prevHighBar := highBar

if not na(pivotLow)
    if not na(prevLowPrice)
        float slope = (pivotLow - prevLowPrice) / math.max(lowBar - prevLowBar, 1)
        int x2 = math.min(lowBar + maxExtendBars, bar_index + 500)
        float y2 = pivotLow + slope * (x2 - lowBar)
        line rail = line.new(prevLowBar, prevLowPrice, x2, y2, xloc = xloc.bar_index, color = color.new(bullCore, 10), width = 2)
        array.push(lowRails, rail)
        array.push(lowBorn, bar_index)
        f_trim_lines(lowRails, lowBorn, maxLowRails)
    prevLowPrice := pivotLow
    prevLowBar := lowBar

if array.size(highRails) > 0
    int highCount = array.size(highRails)
    for i = 0 to highCount - 1
        int idx = highCount - 1 - i
        line rail = array.get(highRails, idx)
        int born = array.get(highBorn, idx)
        bool expired = bar_index - born > maxExtendBars
        float activePrice = f_line_price(rail)
        if expired or close > activePrice
            line.delete(rail)
            array.remove(highRails, idx)
            array.remove(highBorn, idx)

if array.size(lowRails) > 0
    int lowCount = array.size(lowRails)
    for i = 0 to lowCount - 1
        int idx = lowCount - 1 - i
        line rail = array.get(lowRails, idx)
        int born = array.get(lowBorn, idx)
        bool expired = bar_index - born > maxExtendBars
        float activePrice = f_line_price(rail)
        if expired or close < activePrice
            line.delete(rail)
            array.remove(lowRails, idx)
            array.remove(lowBorn, idx)

float activeHighRail = array.size(highRails) > 0 ? f_line_price(array.get(highRails, array.size(highRails) - 1)) : na
float activeLowRail = array.size(lowRails) > 0 ? f_line_price(array.get(lowRails, array.size(lowRails) - 1)) : na

//------------------------------------------------------------------------------
// Confirmed structure states
//------------------------------------------------------------------------------
confirmedBreakUp = barstate.isconfirmed and not na(activeHighRail) and close > activeHighRail and close > innerUpper
confirmedBreakDown = barstate.isconfirmed and not na(activeLowRail) and close < activeLowRail and close < innerLower
insideCorridor = close <= innerUpper and close >= innerLower

int bias =
     confirmedBreakUp ? 1 :
     confirmedBreakDown ? -1 :
     close > stepMid and stepSlope >= 0 ? 1 :
     close < stepMid and stepSlope <= 0 ? -1 : 0

deviationScore = ((close - stepMid) / math.max(stepAtr, syminfo.mintick)) * 25.0

//------------------------------------------------------------------------------
// Visual layer
//------------------------------------------------------------------------------
pMid = plot(stepMid, "Step Mid", color = color.new(accentCore, 0), linewidth = 2, style = plot.style_stepline)
pInnerUpper = plot(showCorridor ? innerUpper : na, "Inner Upper", color = color.new(bullCore, 30), linewidth = 1, style = plot.style_stepline)
pInnerLower = plot(showCorridor ? innerLower : na, "Inner Lower", color = color.new(bearCore, 30), linewidth = 1, style = plot.style_stepline)
pOuterUpper = plot(showCorridor ? outerUpper : na, "Outer Upper", color = color.new(bullCore, 70), linewidth = 1, style = plot.style_stepline)
pOuterLower = plot(showCorridor ? outerLower : na, "Outer Lower", color = color.new(bearCore, 70), linewidth = 1, style = plot.style_stepline)

fill(pInnerUpper, pMid, color = showCorridor ? color.new(bullCore, 90) : na, title = "Inner Upper Band")
fill(pMid, pInnerLower, color = showCorridor ? color.new(bearCore, 90) : na, title = "Inner Lower Band")
fill(pOuterUpper, pInnerUpper, color = showCorridor ? color.new(bullCore, 95) : na, title = "Outer Upper Band")
fill(pInnerLower, pOuterLower, color = showCorridor ? color.new(bearCore, 95) : na, title = "Outer Lower Band")

barcolor(showCandleState ? color.new(f_state_color(bias), insideCorridor ? 45 : 5) : na)
bgcolor(showBreakBackground and confirmedBreakUp ? color.new(bullCore, 92) : showBreakBackground and confirmedBreakDown ? color.new(bearCore, 92) : na, title = "Confirmed Structure Break")

plot(activeHighRail, "Active High Rail", color = color.new(bearCore, 0), linewidth = 2, style = plot.style_linebr)
plot(activeLowRail, "Active Low Rail", color = color.new(bullCore, 0), linewidth = 2, style = plot.style_linebr)

//------------------------------------------------------------------------------
// Dashboard
//------------------------------------------------------------------------------
var table dashboard = table.new(position.top_right, 2, 6, bgcolor = color.new(panelBg, 0), border_color = panelFrame, border_width = 1, frame_color = panelFrame, frame_width = 1)

if barstate.islast and showDashboard
    table.cell(dashboard, 0, 0, "Ledger", text_color = neutralCore, bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dashboard, 1, 0, f_state_text(bias), text_color = f_state_color(bias), bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dashboard, 0, 1, "Step Mid", text_color = neutralCore, bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dashboard, 1, 1, str.tostring(stepMid, format.mintick), text_color = accentCore, bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dashboard, 0, 2, "Deviation", text_color = neutralCore, bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dashboard, 1, 2, str.tostring(deviationScore, "#.0"), text_color = f_state_color(bias), bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dashboard, 0, 3, "High Rails", text_color = neutralCore, bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dashboard, 1, 3, str.tostring(array.size(highRails)), text_color = bearCore, bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dashboard, 0, 4, "Low Rails", text_color = neutralCore, bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dashboard, 1, 4, str.tostring(array.size(lowRails)), text_color = bullCore, bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dashboard, 0, 5, "Break State", text_color = neutralCore, bgcolor = color.new(panelBg, 0), text_size = size.normal)
    table.cell(dashboard, 1, 5, confirmedBreakUp ? "Confirmed Up" : confirmedBreakDown ? "Confirmed Down" : "Contained", text_color = f_state_color(bias), bgcolor = color.new(panelBg, 0), text_size = size.normal)

//------------------------------------------------------------------------------
// Frozen rails and target ladder
//------------------------------------------------------------------------------
freshBreakUp = confirmedBreakUp and not confirmedBreakUp[1]
freshBreakDown = confirmedBreakDown and not confirmedBreakDown[1]

var line frozenRail = na
var line frozenMid = na
var box frozenZone = na

if freshBreakUp and showFrozenRails
    if not na(frozenRail)
        line.delete(frozenRail)
    if not na(frozenMid)
        line.delete(frozenMid)
    if not na(frozenZone)
        box.delete(frozenZone)
    frozenRail := line.new(bar_index - 1, activeHighRail, bar_index + maxExtendBars, activeHighRail, color = color.new(bullCore, 0), width = 2, style = line.style_dashed)
    frozenMid := line.new(bar_index - 1, stepMid, bar_index + maxExtendBars, stepMid, color = color.new(accentCore, 15), width = 1, style = line.style_dotted)
    frozenZone := box.new(bar_index - 1, outerUpper, bar_index + math.min(maxExtendBars, 120), innerUpper, bgcolor = color.new(bullCore, 90), border_color = color.new(bullCore, 35))

if freshBreakDown and showFrozenRails
    if not na(frozenRail)
        line.delete(frozenRail)
    if not na(frozenMid)
        line.delete(frozenMid)
    if not na(frozenZone)
        box.delete(frozenZone)
    frozenRail := line.new(bar_index - 1, activeLowRail, bar_index + maxExtendBars, activeLowRail, color = color.new(bearCore, 0), width = 2, style = line.style_dashed)
    frozenMid := line.new(bar_index - 1, stepMid, bar_index + maxExtendBars, stepMid, color = color.new(accentCore, 15), width = 1, style = line.style_dotted)
    frozenZone := box.new(bar_index - 1, innerLower, bar_index + math.min(maxExtendBars, 120), outerLower, bgcolor = color.new(bearCore, 90), border_color = color.new(bearCore, 35))

if not na(frozenRail) and not showFrozenRails
    line.set_color(frozenRail, color.new(neutralCore, 100))
if not na(frozenMid) and not showFrozenRails
    line.set_color(frozenMid, color.new(accentCore, 100))
if not na(frozenZone) and not showFrozenRails
    box.set_bgcolor(frozenZone, color.new(neutralCore, 100))
    box.set_border_color(frozenZone, color.new(neutralCore, 100))

var label lblMid = na
var label lblUpper = na
var label lblLower = na
var label lblRail = na

if barstate.islast and showRightLabels
    if na(lblMid)
        lblMid := label.new(bar_index, stepMid, "", style = label.style_none, textcolor = accentCore, textalign = text.align_right)
        lblUpper := label.new(bar_index, innerUpper, "", style = label.style_none, textcolor = bullCore, textalign = text.align_right)
        lblLower := label.new(bar_index, innerLower, "", style = label.style_none, textcolor = bearCore, textalign = text.align_right)
        float initialRailLevel = not na(activeHighRail) ? activeHighRail : not na(activeLowRail) ? activeLowRail : stepMid
        lblRail := label.new(bar_index, initialRailLevel, "", style = label.style_none, textcolor = neutralCore, textalign = text.align_right)
    label.set_xy(lblMid, bar_index + 3, stepMid)
    label.set_text(lblMid, "Mid " + str.tostring(stepMid, format.mintick))
    label.set_xy(lblUpper, bar_index + 3, innerUpper)
    label.set_text(lblUpper, "U1 " + str.tostring(innerUpper, format.mintick))
    label.set_xy(lblLower, bar_index + 3, innerLower)
    label.set_text(lblLower, "L1 " + str.tostring(innerLower, format.mintick))
    float railLevel = not na(activeHighRail) ? activeHighRail : not na(activeLowRail) ? activeLowRail : stepMid
    label.set_xy(lblRail, bar_index + 3, railLevel)
    label.set_text(lblRail, "Rail " + str.tostring(railLevel, format.mintick))
else if barstate.islast
    if not na(lblMid)
        label.set_text(lblMid, "")
        label.set_text(lblUpper, "")
        label.set_text(lblLower, "")
        label.set_text(lblRail, "")

var line entryLine = na
var line stopLine = na
var line tpOneLine = na
var line tpTwoLine = na
var line tpThreeLine = na
var linefill riskFill = na
var linefill rewardFill = na

if freshBreakUp and showTargetLadder
    f_clear_trade_lines(entryLine, stopLine, tpOneLine, tpTwoLine, tpThreeLine, riskFill, rewardFill)
    float entryPrice = close
    float stopPrice = math.min(innerLower, close - stepAtr * stopAtrMult)
    float risk = math.max(entryPrice - stopPrice, syminfo.mintick * 5.0)
    float tpOne = entryPrice + risk * tpOneR
    float tpTwo = entryPrice + risk * tpTwoR
    float tpThree = entryPrice + risk * tpThreeR
    entryLine := line.new(bar_index, entryPrice, bar_index + 1, entryPrice, color = color.new(bullCore, 0), width = 2, extend = extend.right)
    stopLine := line.new(bar_index, stopPrice, bar_index + 1, stopPrice, color = color.new(bearCore, 0), width = 1, style = line.style_dashed, extend = extend.right)
    tpOneLine := line.new(bar_index, tpOne, bar_index + 1, tpOne, color = color.new(bullCore, 20), width = 1, extend = extend.right)
    tpTwoLine := line.new(bar_index, tpTwo, bar_index + 1, tpTwo, color = color.new(bullCore, 20), width = 1, extend = extend.right)
    tpThreeLine := line.new(bar_index, tpThree, bar_index + 1, tpThree, color = color.new(bullCore, 20), width = 1, style = line.style_dotted, extend = extend.right)
    riskFill := linefill.new(entryLine, stopLine, color.new(bearCore, 90))
    rewardFill := linefill.new(entryLine, tpTwoLine, color.new(bullCore, 90))

if freshBreakDown and showTargetLadder
    f_clear_trade_lines(entryLine, stopLine, tpOneLine, tpTwoLine, tpThreeLine, riskFill, rewardFill)
    float entryPrice = close
    float stopPrice = math.max(innerUpper, close + stepAtr * stopAtrMult)
    float risk = math.max(stopPrice - entryPrice, syminfo.mintick * 5.0)
    float tpOne = entryPrice - risk * tpOneR
    float tpTwo = entryPrice - risk * tpTwoR
    float tpThree = entryPrice - risk * tpThreeR
    entryLine := line.new(bar_index, entryPrice, bar_index + 1, entryPrice, color = color.new(bearCore, 0), width = 2, extend = extend.right)
    stopLine := line.new(bar_index, stopPrice, bar_index + 1, stopPrice, color = color.new(bearCore, 0), width = 1, style = line.style_dashed, extend = extend.right)
    tpOneLine := line.new(bar_index, tpOne, bar_index + 1, tpOne, color = color.new(bullCore, 20), width = 1, extend = extend.right)
    tpTwoLine := line.new(bar_index, tpTwo, bar_index + 1, tpTwo, color = color.new(bullCore, 20), width = 1, extend = extend.right)
    tpThreeLine := line.new(bar_index, tpThree, bar_index + 1, tpThree, color = color.new(bullCore, 20), width = 1, style = line.style_dotted, extend = extend.right)
    riskFill := linefill.new(entryLine, stopLine, color.new(bearCore, 90))
    rewardFill := linefill.new(entryLine, tpTwoLine, color.new(bullCore, 90))

//------------------------------------------------------------------------------
// Alert conditions
//------------------------------------------------------------------------------
alertcondition(confirmedBreakUp, "Confirmed Structure Up", "Structure Deviation Ledger [JOAT]: confirmed upside structure break")
alertcondition(confirmedBreakDown, "Confirmed Structure Down", "Structure Deviation Ledger [JOAT]: confirmed downside structure break")
alertcondition(freshBreakUp, "Fresh Structure Expansion", "Structure Deviation Ledger [JOAT]: fresh upside structure expansion")
alertcondition(freshBreakDown, "Fresh Structure Pressure", "Structure Deviation Ledger [JOAT]: fresh downside structure pressure")
````
