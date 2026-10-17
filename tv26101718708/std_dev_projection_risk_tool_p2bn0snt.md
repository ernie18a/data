# Std Dev Projection + Risk Tool

- url: https://www.tradingview.com/script/p2bn0Snt-Std-Dev-Projection-Risk-Tool/
- type: indicator
- pine_id: PUB;843e7245c0eb4b84b6ebad201d36b1d8
- version: 4.0

## Description

[b]Std Dev Projection + Risk Tool[/b]

A drag-based planning tool for NQ/MNQ (or any futures/instrument) that turns two anchor points — your Entry and your Stop — into a full trade plan: projected R-multiple targets, position sizing, and dollar risk, all updated live as you drag.

[b]How it works:[/b] Drop two points on the chart: Entry (Level 0) and Stop (Level 1). Everything else is calculated automatically from that single leg:

[list]
[*]Direction (long/short) is auto-detected from where Stop sits relative to Entry
[*]R-multiple target lines (1R, 2R, 2.5R, 4R by default — fully customizable) project outward from Entry based on your stop distance
[*]Position sizing calculates your max contracts either as a % of account or a fixed $ risk amount per trade
[*]A risk summary table (top-right) shows stop distance, $ risk per contract, max contracts, and total $ risk at a glance
[/list]

[b]Features[/b]

[list]
[*]Micro (MNQ) / Mini (NQ) / Custom contract switcher — size your risk correctly even if you're charting one and trading the other
[*]Toggle labels to show $ amount, R-multiple, and/or contracts-to-risk independently
[*]Adjustable label offset so targets stay visible past your price action
[*]Two risk sizing modes: % of account or a flat $ amount per trade
[*]Fully customizable R-target levels (comma-separated list)
[/list]

[b]How to use[/b]

A
[list=1]
[*]dd to chart, open Settings
[*]Drag the Entry and Stop handles onto your actual planned trade
[*]Set your Contract Size, Risk Sizing Mode, and risk amount under Risk Management
[*]Read your position size and R-targets directly off the chart
[/list]

[b]Disclaimer:[/b] This is a risk-calculation and visualization tool only — it does not generate trade signals, predict price direction, or execute trades. All position sizing outputs are for planning purposes; verify contract specs and risk parameters against your own broker/platform before trading. Trading futures involves substantial risk of loss and is not suitable for all investors. Past performance and projected levels are not indicative of future results.

## Source Code

````pine
//@version=6
indicator("Std Dev Projection + Risk Tool", overlay=true, max_lines_count=200, max_labels_count=200)

// ============================================================================
// HOW TO USE
// 1. Drag-based tool: open Settings, you'll see 2 draggable points on chart -
//    "Entry (Level 0)" and "Stop (Level 1)". Drop them on your actual entry
//    and stop. Everything else - projections, R-targets, risk sizing - is
//    calculated off just these two points.
// 2. R-Target lines (1R, 2R, 3R, etc) auto-plot off the Entry/Stop distance,
//    editable as a comma list under R-Multiple Targets.
// 3. Direction (long/short) is auto-detected: if Stop is below Entry, it's
//    treated as long (targets project upward); if Stop is above Entry, short
//    (targets project downward).
// 4. Pick Micro (MNQ) / Mini (NQ) / Custom to set $ per point, independent
//    of what you're actually charting.
// 5. To update for a new day: open Settings > Inputs and type new numbers
//    directly into Price - Entry (Level 0) and Price - Stop (Level 1) - no
//    need to hunt for the drag handle if price has moved far from where it
//    was last set.
// 6. If your stop is too wide to fit even 1 contract within your risk
//    budget, a dotted purple line appears showing where Entry would need to
//    move (Stop held fixed) to afford exactly 1 contract.
// IMPORTANT: if you paste updated code into this same indicator, TradingView
// keeps previously dragged anchor positions. If something looks off after an
// update, remove and re-add the indicator to get fresh defaults.
// ============================================================================

// --- Anchors: Entry = Level 0, Stop = Level 1 ---
grpAnchor = "Entry / Stop Anchors"
t0 = input.time(timestamp("2026-07-29 09:30 -0500"), "Time - Entry (Level 0)", group = grpAnchor)
p0 = input.price(27600.0,                             "Price - Entry (Level 0)", group = grpAnchor)
t1 = input.time(timestamp("2026-07-29 10:00 -0500"), "Time - Stop (Level 1)",  group = grpAnchor)
p1 = input.price(27610.0,                             "Price - Stop (Level 1)", group = grpAnchor)

// --- Display settings ---
grpLevels     = "Display"
entryColor    = input.color(color.new(color.lime, 0), "Entry Line Color", group = grpLevels)
stopColor     = input.color(color.new(color.red, 0), "Stop Line Color", group = grpLevels)
extendRight   = input.bool(true, "Extend Lines Right", group = grpLevels)
labelSizeIn   = input.string(size.small, "Label Size", options = [size.tiny, size.small, size.normal, size.large], group = grpLevels)
showDollarAmt = input.bool(true, "Show $ Amount on Labels", group = grpLevels)
showContracts = input.bool(true, "Show Contracts To Risk on Labels", group = grpLevels)
labelOffset   = input.int(60, "Label Offset Past Last Bar (bars) - increase if labels aren't reaching your chart's right edge", minval = 0, group = grpLevels)

// --- Contract / risk management ---
grpRisk       = "Risk Management"
contractType  = input.string("Micro (MNQ - $2/pt)", "Contract Size", options = ["Micro (MNQ - $2/pt)", "Mini (NQ - $20/pt)", "Custom"], group = grpRisk)
customPointVal = input.float(2.0, "Custom Point Value ($/pt) - used only if Contract Size = Custom", group = grpRisk)
pointValue    = contractType == "Micro (MNQ - $2/pt)" ? 2.0 : contractType == "Mini (NQ - $20/pt)" ? 20.0 : customPointVal
riskMode      = input.string("Fixed $ Amount", "Risk Sizing Mode", options = ["% of Account", "Fixed $ Amount"], group = grpRisk)
accountSize   = input.float(50000.0, "Account Size ($) - used only if mode = % of Account", group = grpRisk)
riskPct       = input.float(1.0, "Risk % Per Trade - used only if mode = % of Account", minval = 0.0, group = grpRisk)
riskDollarFixed = input.float(200.0, "Fixed $ Risk Per Trade - used only if mode = Fixed $ Amount", minval = 0.0, group = grpRisk)

// --- R-multiple targets ---
grpTargets   = "R-Multiple Targets"
showTargets  = input.bool(true, "Show R Targets", group = grpTargets)
targetRStr   = input.string("1,2,2.5,4", "R Targets (comma separated)", group = grpTargets)
targetColor  = input.color(color.new(color.orange, 0), "Target Line Color", group = grpTargets)

// --- Suggested entry when 0 contracts fit ---
grpSuggest       = "Suggested Entry (when 0 contracts fit)"
showSuggestEntry = input.bool(true, "Show Suggested Entry Line", group = grpSuggest)
suggestColor     = input.color(color.new(color.purple, 0), "Suggested Entry Line Color", group = grpSuggest)

// --- Risk table display ---
grpTable      = "Risk Table"
showTable     = input.bool(true, "Show Risk Summary Table", group = grpTable)
tablePosStr   = input.string("Top Right", "Table Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = grpTable)
tablePos = switch tablePosStr
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    "Bottom Right"  => position.bottom_right
    => position.top_right

// --- persistent drawing objects ---
var array<line>  targetLines  = array.new<line>()
var array<label> targetLabels = array.new<label>()
var line entryLine = na
var line stopLine  = na
var label entryLabel = na
var label stopLabel  = na
var line suggestLine = na
var label suggestLabel = na
var table infoTable  = na
if showTable and na(infoTable)
    infoTable := table.new(tablePos, 2, 8, bgcolor = color.new(color.black, 75), border_width = 1, border_color = color.new(color.white, 50))

if barstate.islast
    // clear old lines/labels
    if array.size(targetLines) > 0
        for ln in targetLines
            line.delete(ln)
        array.clear(targetLines)
    if array.size(targetLabels) > 0
        for lb in targetLabels
            label.delete(lb)
        array.clear(targetLabels)
    line.delete(entryLine)
    line.delete(stopLine)
    label.delete(entryLabel)
    label.delete(stopLabel)
    line.delete(suggestLine)
    label.delete(suggestLabel)

    entryPrice = p0
    stopPrice  = p1
    stopDist   = math.abs(entryPrice - stopPrice)
    dollarRiskPerContract = stopDist * pointValue
    riskBudget   = riskMode == "% of Account" ? accountSize * riskPct / 100 : riskDollarFixed
    maxContracts = dollarRiskPerContract > 0 ? math.floor(riskBudget / dollarRiskPerContract) : 0
    totalRisk    = maxContracts * dollarRiskPerContract
    direction    = stopPrice < entryPrice ? 1 : -1   // long if stop below entry, short if stop above entry
    rightEdgeX   = bar_index + labelOffset
    extendMode   = extendRight ? extend.right : extend.none

    entryLine := line.new(x1 = t0, y1 = entryPrice, x2 = t1, y2 = entryPrice, xloc = xloc.bar_time, extend = extendMode, color = entryColor, width = 2, style = line.style_solid)
    stopLine  := line.new(x1 = t0, y1 = stopPrice,  x2 = t1, y2 = stopPrice,  xloc = xloc.bar_time, extend = extendMode, color = stopColor,  width = 2, style = line.style_solid)

    entryTxt = "Entry"
    stopTxt = "SL"
    if showContracts
        stopTxt := stopTxt + "  x" + str.tostring(maxContracts)
    if showDollarAmt
        stopTxt := stopTxt + "  -$" + str.tostring(totalRisk, "#.##")

    entryLabel := label.new(x = rightEdgeX, y = entryPrice, text = entryTxt, xloc = xloc.bar_index, style = label.style_label_right, size = labelSizeIn, color = color.new(entryColor, 10), textcolor = color.black)
    stopLabel  := label.new(x = rightEdgeX, y = stopPrice,  text = stopTxt,  xloc = xloc.bar_index, style = label.style_label_right, size = labelSizeIn, color = color.new(stopColor, 10),  textcolor = color.white)

    // Suggested entry: if 0 contracts fit at current stop distance, show where
    // Entry would need to move (Stop held fixed) to afford exactly 1 contract.
    if showSuggestEntry and maxContracts == 0 and stopDist > 0 and pointValue > 0
        maxAllowedDist = riskBudget / pointValue
        suggestedEntryPrice = stopPrice + direction * maxAllowedDist

        suggestLine := line.new(x1 = t0, y1 = suggestedEntryPrice, x2 = t1, y2 = suggestedEntryPrice, xloc = xloc.bar_time, extend = extendMode, color = suggestColor, width = 2, style = line.style_dotted)

        suggestTxt = "1x Entry  $" + str.tostring(riskBudget, "#.##")
        suggestLabel := label.new(x = rightEdgeX, y = suggestedEntryPrice, text = suggestTxt, xloc = xloc.bar_index, style = label.style_label_right, size = labelSizeIn, color = color.new(suggestColor, 10), textcolor = color.white)

    // R-multiple target lines
    if showTargets and stopDist > 0
        targetArr = str.split(targetRStr, ",")
        for i = 0 to array.size(targetArr) - 1
            rVal = str.tonumber(array.get(targetArr, i))
            targetPrice = entryPrice + direction * rVal * stopDist
            dollarAtTarget = rVal * dollarRiskPerContract * maxContracts

            tln = line.new(x1 = t0, y1 = targetPrice, x2 = t1, y2 = targetPrice, xloc = xloc.bar_time, extend = extend.right, color = targetColor, width = 1, style = line.style_dashed)
            array.push(targetLines, tln)

            ttxt = str.tostring(rVal, "#.##") + "R"
            if showDollarAmt
                ttxt := ttxt + "  $" + str.tostring(dollarAtTarget, "#.##")
            tlb = label.new(x = rightEdgeX, y = targetPrice, text = ttxt, xloc = xloc.bar_index, style = label.style_label_right, size = labelSizeIn, color = color.new(targetColor, 10), textcolor = color.white)
            array.push(targetLabels, tlb)

    // risk summary table
    if showTable and not na(infoTable)
        table.cell(infoTable, 0, 0, "Risk Summary (" + contractType + ")", text_color = color.white, bgcolor = color.new(color.blue, 60), text_size = size.small)
        table.cell(infoTable, 1, 0, "", bgcolor = color.new(color.blue, 60))

        table.cell(infoTable, 0, 1, "Point Value", text_color = color.white, text_size = size.small)
        table.cell(infoTable, 1, 1, "$" + str.tostring(pointValue, "#.##"), text_color = color.white, text_size = size.small)

        table.cell(infoTable, 0, 2, "Stop Distance (pts)", text_color = color.white, text_size = size.small)
        table.cell(infoTable, 1, 2, str.tostring(stopDist, format.mintick), text_color = color.white, text_size = size.small)

        table.cell(infoTable, 0, 3, "$ Risk / Contract", text_color = color.white, text_size = size.small)
        table.cell(infoTable, 1, 3, "$" + str.tostring(dollarRiskPerContract, "#.##"), text_color = color.white, text_size = size.small)

        table.cell(infoTable, 0, 4, riskMode == "% of Account" ? "Account Size" : "Risk Mode", text_color = color.white, text_size = size.small)
        table.cell(infoTable, 1, 4, riskMode == "% of Account" ? "$" + str.tostring(accountSize, "#.##") : "Fixed $", text_color = color.white, text_size = size.small)

        table.cell(infoTable, 0, 5, "Risk Budget", text_color = color.white, text_size = size.small)
        table.cell(infoTable, 1, 5, riskMode == "% of Account" ? str.tostring(riskPct, "#.##") + "%  /  $" + str.tostring(riskBudget, "#.##") : "$" + str.tostring(riskBudget, "#.##"), text_color = color.white, text_size = size.small)

        table.cell(infoTable, 0, 6, "Max Contracts", text_color = color.white, text_size = size.small)
        table.cell(infoTable, 1, 6, str.tostring(maxContracts), text_color = color.yellow, text_size = size.small)

        table.cell(infoTable, 0, 7, "Total $ Risk", text_color = color.white, text_size = size.small)
        table.cell(infoTable, 1, 7, "$" + str.tostring(totalRisk, "#.##"), text_color = color.yellow, text_size = size.small)
````
