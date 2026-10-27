# Options Target Calculator

- url: https://www.tradingview.com/script/lHh1kXT5-Options-Target-Calculator/
- type: indicator
- pine_id: PUB;bd7e528bee83429a8478b0041316f358
- version: 1.0

## Description

Computes Options Price Target

Inputs: 
Option Type: Call or Put Dropdown
Stock Entry Price =>  Underlying Entry Price
Stock Price Target => Underlying Target Price
Options Entry Price  => Entry Option Premium
Delta Value => Delta (abs value)

Options Delta example https://imgur.com/a/JNPdLqP

## Source Code

````pine
//@version=6
indicator(title="Options Target Calculator", shorttitle="Options Target", overlay=true, max_lines_count=500, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════
entryPrice   = input.float(0.0,  title="Underlying Entry Price", group="Trade", tooltip="Price of the underlying when you enter. Set to 0 to auto-use the current close.")
targetPrice  = input.float(0.0,  title="Underlying Target Price", group="Trade", tooltip="Where you expect the underlying to go.")
optType      = input.string("Call", title="Option Type", options=["Call", "Put"], group="Option")
delta        = input.float(0.50, title="Delta (abs value)", minval=0.01, maxval=1.0, step=0.01, group="Option", tooltip="Option delta magnitude (0–1). For puts enter the absolute value; the sign is handled automatically.")
entryPremium = input.float(1.00, title="Entry Option Premium", minval=0.0, step=0.05, group="Option", tooltip="Option price (per share) when you enter.")
contracts    = input.int(1, title="Number of Contracts", minval=1, group="Option")
sharesPerCt  = input.int(100, title="Shares per Contract", minval=1, group="Option")

showLevels   = input.bool(true, title="Draw Entry / Target Lines", group="Display")
tablePos     = input.string("middle_right", title="Table Position", options=["top_left","top_center","top_right","middle_left","middle_center","middle_right","bottom_left","bottom_center","bottom_right"], group="Display")
tableSz      = input.string("normal", title="Table Text Size", options=["tiny","small","normal","large"], group="Display")

// ═══════════════════════════════════════════════════════════════════
// CALCULATIONS
// ═══════════════════════════════════════════════════════════════════
isCall      = optType == "Call"
signedDelta = isCall ? delta : -delta

effEntry    = entryPrice > 0 ? entryPrice : close
undMove     = targetPrice - effEntry                    // $ move in the underlying
undMovePct  = effEntry != 0 ? undMove / effEntry * 100 : na

// Option premium move via delta (linear approximation)
optMove        = signedDelta * undMove                  // per-share premium change
projPremium    = math.max(entryPremium + optMove, 0.0)  // premium can't go below 0
optMovePct     = entryPremium > 0 ? optMove / entryPremium * 100 : na

// Dollar P/L
plPerContract  = optMove * sharesPerCt
plTotal        = plPerContract * contracts
costBasis      = entryPremium * sharesPerCt * contracts
projValue      = projPremium * sharesPerCt * contracts

// ═══════════════════════════════════════════════════════════════════
// LEVEL LINES
// ═══════════════════════════════════════════════════════════════════
var line entryLn  = na
var line targetLn = na
var label entryLb = na
var label targetLb = na

if showLevels and barstate.islast
    line.delete(entryLn)
    line.delete(targetLn)
    label.delete(entryLb)
    label.delete(targetLb)

    entryLn  := line.new(bar_index - 50, effEntry, bar_index + 10, effEntry, color=color.new(color.gray, 20), width=1, style=line.style_dashed)
    targetLn := line.new(bar_index - 50, targetPrice, bar_index + 10, targetPrice, color=color.new(isCall ? #00E676 : #FF5252, 20), width=1, style=line.style_dashed)

    entryLb  := label.new(bar_index + 10, effEntry, "Entry  " + str.tostring(effEntry, format.mintick), style=label.style_none, textcolor=color.gray, size=size.small)
    targetLb := label.new(bar_index + 10, targetPrice, "Target  " + str.tostring(targetPrice, format.mintick), style=label.style_none, textcolor=isCall ? #00E676 : #FF5252, size=size.small)

// ═══════════════════════════════════════════════════════════════════
// RESULTS TABLE
// ═══════════════════════════════════════════════════════════════════
f_pos(s) =>
    s == "top_left"      ? position.top_left      :
     s == "top_center"   ? position.top_center    :
     s == "top_right"    ? position.top_right     :
     s == "middle_left"  ? position.middle_left   :
     s == "middle_center"? position.middle_center :
     s == "middle_right" ? position.middle_right  :
     s == "bottom_left"  ? position.bottom_left   :
     s == "bottom_center"? position.bottom_center : position.bottom_right

f_size(s) =>
    s == "tiny" ? size.tiny : s == "small" ? size.small : s == "large" ? size.large : size.normal

if barstate.islast
    bullC = #00E676
    bearC = #FF5252
    plColor = plTotal >= 0 ? bullC : bearC

    var table t = na
    table.delete(t)
    t := table.new(f_pos(tablePos), 2, 9, bgcolor=color.new(#1E1E1E, 10), border_width=1, border_color=color.new(#787B86, 60))
    sz = f_size(tableSz)

    table.cell(t, 0, 0, optType + " Target Calc", text_color=#42A5F5, text_size=sz, text_halign=text.align_left)
    table.cell(t, 1, 0, "Δ " + str.tostring(delta, "#.##"), text_color=color.white, text_size=sz, text_halign=text.align_right)

    table.cell(t, 0, 1, "Entry (underlying)", text_color=color.white, text_size=sz, text_halign=text.align_left)
    table.cell(t, 1, 1, str.tostring(effEntry, format.mintick), text_color=color.white, text_size=sz, text_halign=text.align_right)

    table.cell(t, 0, 2, "Target (underlying)", text_color=color.white, text_size=sz, text_halign=text.align_left)
    table.cell(t, 1, 2, str.tostring(targetPrice, format.mintick), text_color=color.white, text_size=sz, text_halign=text.align_right)

    table.cell(t, 0, 3, "Underlying Move", text_color=color.white, text_size=sz, text_halign=text.align_left)
    table.cell(t, 1, 3, str.tostring(undMove, format.mintick) + "  (" + str.tostring(undMovePct, "#.##") + "%)", text_color=undMove >= 0 ? bullC : bearC, text_size=sz, text_halign=text.align_right)

    table.cell(t, 0, 4, "Entry Premium", text_color=color.white, text_size=sz, text_halign=text.align_left)
    table.cell(t, 1, 4, str.tostring(entryPremium, "#.##"), text_color=color.white, text_size=sz, text_halign=text.align_right)

    table.cell(t, 0, 5, "Proj. Premium", text_color=color.white, text_size=sz, text_halign=text.align_left)
    table.cell(t, 1, 5, str.tostring(projPremium, "#.##") + "  (" + str.tostring(optMovePct, "#.##") + "%)", text_color=plColor, text_size=sz, text_halign=text.align_right)

    table.cell(t, 0, 6, "Cost Basis", text_color=color.white, text_size=sz, text_halign=text.align_left)
    table.cell(t, 1, 6, "$" + str.tostring(costBasis, "#.##"), text_color=color.white, text_size=sz, text_halign=text.align_right)

    table.cell(t, 0, 7, "Proj. Value", text_color=color.white, text_size=sz, text_halign=text.align_left)
    table.cell(t, 1, 7, "$" + str.tostring(projValue, "#.##"), text_color=plColor, text_size=sz, text_halign=text.align_right)

    table.cell(t, 0, 8, "Est. P/L", text_color=color.white, text_size=sz, text_halign=text.align_left)
    table.cell(t, 1, 8, "$" + str.tostring(plTotal, "#.##"), text_color=plColor, text_size=sz, text_halign=text.align_right)
````
