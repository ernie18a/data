<!-- tradingview-pine-id: PUB;23785f76545a4749b311b2472fc5c7d9 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Volatility Position Risk Planner [Pineify]

Source: https://www.tradingview.com/script/yQx66rz6-Volatility-Position-Risk-Planner-Pineify/

## Description

Volatility Position Risk Planner [Pineify]

Overview

This indicator converts a trade idea into a stress-sized quantity. Its corridor separates target, nominal risk, and reserve; a ledger identifies the binding constraint.

Problem Definition

A basic position size calculator divides account risk by entry-to-stop distance. It ignores fills beyond a stop during gaps, slippage, and per-unit cash costs. A tight stop can also produce notional exposure disproportionate to the account. The result may satisfy nominal loss math while violating another capital limit. This script instead asks what quantity fits both a stated stress-loss budget and an exposure ceiling under the units supplied by the user.

Design Rationale

Technical invalidation and execution uncertainty are separate. The stop says where the setup fails; ATR gap allowance and tick slippage extend a stress boundary. Cash cost remains in currency units. This replaces inflating one ATR multiplier, which would mix stop logic and reserve.

Risk and notional capacity are calculated independently. The smaller candidate is rounded down, leaving some budget unused but avoiding either limit. The target uses stress price distance for a consistent visual scale; it is not a forecast.

Key Features

[*]ATR, structure, or wider-of-both stop logic.
[*]Separate gap, slippage, and cash-cost reserves.
[*]Risk and exposure candidates with a binding constraint.
[*]Step rounding plus utilization and headroom diagnostics.

How It Works

Current close rolls with price; Manual price fixes entry. ATR comes from chart OHLC. Stop distance is ATR times its factor, directional distance to structure, or the wider valid distance. The stop is tick-normalized.

The reserve adds ATR times Gap reserve and slippage ticks, producing a stress edge. Nominal unit risk is stop distance times point value plus cash cost; stress unit risk uses the full distance to that edge. Account size times risk percent, divided by stress unit risk, gives the risk candidate.

Entry times point value estimates unit notional. Account size times Maximum notional exposure, divided by unit notional, gives the exposure candidate. The smaller quantity is rounded down by step. Nominal risk, stress risk, reserve cash, both utilizations, and unused budget are then reconciled. Warm-up, wrongly sided stops, invalid units or prices, and sub-step quantities are rejected.

How Multiple Indicators Work Together

This is a causal chain, not a signal stack. ATR scales stop and gap allowance; structure supplies price invalidation. Point value converts distance into cash risk. Risk budget limits stress loss; exposure limits concentration. Removing ATR ignores current range, removing structure loses chart context, and removing either capital constraint leaves one dimension unchecked. Corridor and ledger expose each link.

Trading Ideas and Insights

Compare the same setup under different volatility, reserve, and exposure assumptions. RISK means stress-loss capacity is tighter; EXPOSURE means concentration controls size; BOTH means candidates are close within half a quantity step. A large amber zone relative to red shows that execution assumptions materially reduce size. Headroom is cash left after rounding, not permission to exceed the constraint.

Unique Aspects

The structural contribution is a two-stage constraint lattice. Technical invalidation and execution overrun first become auditable loss layers. The stress-loss candidate then competes with an independent exposure candidate before step rounding. The ledger reconciles final quantity to both budgets and names the binding one, showing how much risk belongs to the stop, how much to reserve, and when exposure overrides them.

How to Use

[*]Choose direction and a rolling or manual entry.
[*]Select ATR, structure, or combined stop logic; verify stop direction.
[*]Enter reserve, cost, account, point value, step, and exposure data from broker specifications.
[*]Proceed only at PLAN READY; note quantity and binding constraint.
[*]Read amber as a stress boundary, not another order or a guaranteed fill limit.

Customization

ATR length and multiple control the volatility stop. Gap reserve adds a scaled allowance; slippage ticks add a fixed allowance. Cash cost must share the account-currency and quantity convention. Exposure above 100% should be deliberate leverage, not assumed margin. Visual switches hide corridor, candidates, labels, or ledger without altering calculations or alerts. Projection bars change drawing length only.

Assumptions and Limitations

This calculator omits liquidity, partial fills, spreads, rejection, margin tiers, liquidation, currency conversion, financing, tax, and minimum notional. A gap can exceed reserve, so stress risk is a scenario, not maximum loss. Point value, cost, step, currency, and exposure need compatible units; metadata may differ from a broker contract.

Current close, ATR, corridor, and quantity can change intrabar. Manual entry is fixed, but ATR values still move. Confirmed-bar alerts can miss a reversed intrabar touch, and gaps can cross boundaries before processing. Drawings show only the latest plan. The script estimates no probability, return, win rate, or stop quality. Nonstandard charts and illiquid markets can make ATR a poor execution proxy.

Conclusion

This planner separates risk, reserve, and exposure. Reliability still depends on verified units, stop logic, and realistic stress assumptions.

---

## Source Code

````pine
//@version=6
indicator("Volatility Position Risk Planner [Pineify]", overlay = true, max_lines_count = 12, max_labels_count = 12, max_boxes_count = 6)

string GROUP_PLAN = "Plan"
string GROUP_RESERVE = "Stress Reserve"
string GROUP_BUDGET = "Capital Constraints"
string GROUP_VISUAL = "Visuals"

string direction = input.string("Long", "Trade direction", options = ["Long", "Short"], group = GROUP_PLAN)
string entryMode = input.string("Current close", "Reference entry", options = ["Current close", "Manual price"], tooltip = "Current close creates a rolling plan. Manual price fixes the entry reference and enables the stress-edge touch alert.", group = GROUP_PLAN)
float manualEntry = input.price(0.0, "Manual entry price", tooltip = "Must be greater than zero when Reference entry is Manual price.", group = GROUP_PLAN)
string stopMethod = input.string("ATR", "Nominal stop method", options = ["ATR", "Structure", "Wider of ATR and structure"], group = GROUP_PLAN)
int atrLength = input.int(14, "ATR length", minval = 2, maxval = 500, group = GROUP_PLAN)
float atrMultiple = input.float(2.0, "ATR stop multiple", minval = 0.1, maxval = 20.0, step = 0.1, group = GROUP_PLAN)
float structureStop = input.price(0.0, "Structure stop price", tooltip = "For a long plan this must be below entry; for a short plan it must be above entry.", group = GROUP_PLAN)
float rewardMultiple = input.float(2.0, "Target multiple of stress distance", minval = 0.25, maxval = 20.0, step = 0.25, group = GROUP_PLAN)

float gapReserveAtr = input.float(0.35, "Gap reserve (ATR)", minval = 0.0, maxval = 10.0, step = 0.05, tooltip = "Adds a volatility-scaled price reserve beyond the nominal stop. It is a stress allowance, not a second stop order.", group = GROUP_RESERVE)
int slippageTicks = input.int(2, "Slippage reserve (ticks)", minval = 0, maxval = 100000, group = GROUP_RESERVE)
float roundTripCost = input.float(0.0, "Round-trip cash cost per quantity", minval = 0.0, maxval = 1000000000.0, step = 0.01, tooltip = "Cash cost per share, contract, coin, or lot unit in the account currency. Verify the unit convention for the symbol.", group = GROUP_RESERVE)

float accountSize = input.float(10000.0, "Account size", minval = 0.01, maxval = 1000000000000.0, group = GROUP_BUDGET)
float riskPercent = input.float(1.0, "Risk budget per plan (%)", minval = 0.01, maxval = 100.0, step = 0.05, group = GROUP_BUDGET)
bool useSymbolPointValue = input.bool(true, "Use syminfo.pointvalue", tooltip = "Disable this and enter a verified manual point value when the symbol metadata does not match the broker contract, lot, or account-currency convention.", group = GROUP_BUDGET)
float manualPointValue = input.float(1.0, "Manual point value", minval = 0.00000001, maxval = 1000000000000.0, group = GROUP_BUDGET)
float quantityStep = input.float(1.0, "Quantity step", minval = 0.00000001, maxval = 1000000000.0, tooltip = "All candidate quantities are rounded down to this increment.", group = GROUP_BUDGET)
float maxExposurePercent = input.float(100.0, "Maximum notional exposure (% of account)", minval = 0.01, maxval = 100000.0, step = 1.0, tooltip = "This is an independent capital constraint, not a margin estimate. Values above 100% represent explicitly permitted leverage.", group = GROUP_BUDGET)

bool showCorridor = input.bool(true, "Show three-zone corridor", group = GROUP_VISUAL)
bool showCandidates = input.bool(true, "Show ATR and structure candidates", group = GROUP_VISUAL)
bool showLabels = input.bool(true, "Show corridor labels", group = GROUP_VISUAL)
bool showDashboard = input.bool(true, "Show constraint ledger", group = GROUP_VISUAL)
int projectionBars = input.int(40, "Projection bars", minval = 5, maxval = 200, group = GROUP_VISUAL)

floorToStep(float value, float step) =>
    math.floor(value / step + 0.0000000001) * step

priceText(float value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

numberText(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.########")

moneyText(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.##")

percentText(float value) =>
    na(value) ? "n/a" : str.tostring(value * 100.0, "#.##") + "%"

bool isLong = direction == "Long"
bool isManualEntry = entryMode == "Manual price"
float entryPrice = isManualEntry ? manualEntry : close
float atrValue = ta.atr(atrLength)
float atrDistance = atrValue * atrMultiple
float atrStop = isLong ? entryPrice - atrDistance : entryPrice + atrDistance
float structureDistance = isLong ? entryPrice - structureStop : structureStop - entryPrice
bool entryValid = not na(entryPrice) and entryPrice > 0.0
bool atrValid = entryValid and not na(atrDistance) and atrDistance >= syminfo.mintick and atrStop > 0.0
bool structureValid = entryValid and structureStop > 0.0 and structureDistance >= syminfo.mintick

float nominalDistanceRaw = na
string stopSource = "None"
bool nominalStopValid = false
if stopMethod == "ATR"
    nominalDistanceRaw := atrDistance
    stopSource := "ATR"
    nominalStopValid := atrValid
else if stopMethod == "Structure"
    nominalDistanceRaw := structureDistance
    stopSource := "Structure"
    nominalStopValid := structureValid
else
    nominalDistanceRaw := math.max(atrDistance, structureDistance)
    stopSource := atrDistance >= structureDistance ? "ATR wider" : "Structure wider"
    nominalStopValid := atrValid and structureValid

float nominalStopRaw = nominalStopValid ? (isLong ? entryPrice - nominalDistanceRaw : entryPrice + nominalDistanceRaw) : na
float nominalStop = nominalStopValid ? math.round(nominalStopRaw / syminfo.mintick) * syminfo.mintick : na
float nominalDistance = nominalStopValid ? math.abs(entryPrice - nominalStop) : na
float gapReserveDistance = not na(atrValue) ? atrValue * gapReserveAtr : na
float slippageDistance = slippageTicks * syminfo.mintick
float reserveDistanceRaw = not na(gapReserveDistance) ? gapReserveDistance + slippageDistance : na
float stressEdgeRaw = nominalStopValid and not na(reserveDistanceRaw) ? (isLong ? nominalStop - reserveDistanceRaw : nominalStop + reserveDistanceRaw) : na
float stressEdge = not na(stressEdgeRaw) ? math.round(stressEdgeRaw / syminfo.mintick) * syminfo.mintick : na
float stressDistance = not na(stressEdge) ? math.abs(entryPrice - stressEdge) : na
bool stressEdgeValid = nominalStopValid and not na(stressDistance) and stressDistance >= nominalDistance and stressEdge > 0.0

float pointValue = useSymbolPointValue ? syminfo.pointvalue : manualPointValue
bool pointValueValid = not na(pointValue) and pointValue > 0.0
float riskBudget = accountSize * riskPercent * 0.01
float exposureBudget = accountSize * maxExposurePercent * 0.01
float nominalUnitRisk = stressEdgeValid and pointValueValid ? nominalDistance * pointValue + roundTripCost : na
float stressUnitRisk = stressEdgeValid and pointValueValid ? stressDistance * pointValue + roundTripCost : na
float unitNotional = entryValid and pointValueValid ? entryPrice * pointValue : na
float riskLimitedQuantity = not na(stressUnitRisk) and stressUnitRisk > 0.0 ? riskBudget / stressUnitRisk : na
float exposureLimitedQuantity = not na(unitNotional) and unitNotional > 0.0 ? exposureBudget / unitNotional : na
float rawQuantity = not na(riskLimitedQuantity) and not na(exposureLimitedQuantity) ? math.min(riskLimitedQuantity, exposureLimitedQuantity) : na
float positionQuantity = not na(rawQuantity) ? floorToStep(rawQuantity, quantityStep) : na
string bindingConstraint = na(riskLimitedQuantity) or na(exposureLimitedQuantity) ? "NONE" : math.abs(riskLimitedQuantity - exposureLimitedQuantity) <= quantityStep * 0.5 ? "BOTH" : riskLimitedQuantity < exposureLimitedQuantity ? "RISK" : "EXPOSURE"

float actualNominalRisk = not na(positionQuantity) and not na(nominalUnitRisk) ? positionQuantity * nominalUnitRisk : na
float actualStressRisk = not na(positionQuantity) and not na(stressUnitRisk) ? positionQuantity * stressUnitRisk : na
float reserveCash = not na(actualStressRisk) and not na(actualNominalRisk) ? math.max(actualStressRisk - actualNominalRisk, 0.0) : na
float riskUtilization = riskBudget > 0.0 and not na(actualStressRisk) ? actualStressRisk / riskBudget : na
float reserveShare = not na(actualStressRisk) and actualStressRisk > 0.0 ? reserveCash / actualStressRisk : na
float notionalExposure = not na(positionQuantity) and not na(unitNotional) ? positionQuantity * unitNotional : na
float exposureUtilization = exposureBudget > 0.0 and not na(notionalExposure) ? notionalExposure / exposureBudget : na
float riskHeadroom = not na(actualStressRisk) ? math.max(riskBudget - actualStressRisk, 0.0) : na

float targetPriceRaw = stressEdgeValid ? (isLong ? entryPrice + stressDistance * rewardMultiple : entryPrice - stressDistance * rewardMultiple) : na
float targetPrice = not na(targetPriceRaw) ? math.round(targetPriceRaw / syminfo.mintick) * syminfo.mintick : na
bool targetValid = not na(targetPrice) and targetPrice > 0.0
bool quantityValid = not na(positionQuantity) and positionQuantity >= quantityStep
bool planValid = entryValid and nominalStopValid and stressEdgeValid and targetValid and pointValueValid and riskBudget > 0.0 and exposureBudget > 0.0 and quantityValid

string diagnostic = not entryValid ? "INVALID ENTRY" : stopMethod == "ATR" and not atrValid ? "ATR WARM-UP" : stopMethod == "Structure" and not structureValid ? "INVALID STRUCTURE STOP" : stopMethod == "Wider of ATR and structure" and not atrValid ? "ATR WARM-UP" : stopMethod == "Wider of ATR and structure" and not structureValid ? "INVALID STRUCTURE STOP" : not nominalStopValid ? "INVALID NOMINAL STOP" : not stressEdgeValid ? "INVALID STRESS EDGE" : not pointValueValid ? "INVALID POINT VALUE" : not targetValid ? "INVALID TARGET" : na(riskLimitedQuantity) or riskLimitedQuantity < quantityStep ? "RISK BUDGET BELOW STEP" : na(exposureLimitedQuantity) or exposureLimitedQuantity < quantityStep ? "EXPOSURE CAP BELOW STEP" : not quantityValid ? "QUANTITY BELOW STEP" : "PLAN READY"

color riskColor = color.rgb(232, 78, 91)
color reserveColor = color.rgb(235, 151, 48)
color rewardColor = color.rgb(28, 177, 143)
color entryColor = color.rgb(54, 142, 255)
color atrColor = color.rgb(155, 105, 255)
color structureColor = color.rgb(244, 194, 74)
color neutralColor = color.rgb(131, 143, 157)
color bindingColor = bindingConstraint == "RISK" ? riskColor : bindingConstraint == "EXPOSURE" ? reserveColor : bindingConstraint == "BOTH" ? entryColor : neutralColor
color utilizationColor = planValid ? color.from_gradient(math.min(math.max(riskUtilization, 0.0), 1.0), 0.0, 1.0, rewardColor, reserveColor) : riskColor

var box nominalRiskBox = na
var box reserveBox = na
var box rewardBox = na
var line entryLine = na
var line stopLine = na
var line stressLine = na
var line targetLine = na
var line atrLine = na
var line structureLine = na
var label entryLabel = na
var label stopLabel = na
var label stressLabel = na
var label targetLabel = na

if barstate.islast
    if not na(nominalRiskBox)
        box.delete(nominalRiskBox)
    if not na(reserveBox)
        box.delete(reserveBox)
    if not na(rewardBox)
        box.delete(rewardBox)
    if not na(entryLine)
        line.delete(entryLine)
    if not na(stopLine)
        line.delete(stopLine)
    if not na(stressLine)
        line.delete(stressLine)
    if not na(targetLine)
        line.delete(targetLine)
    if not na(atrLine)
        line.delete(atrLine)
    if not na(structureLine)
        line.delete(structureLine)
    if not na(entryLabel)
        label.delete(entryLabel)
    if not na(stopLabel)
        label.delete(stopLabel)
    if not na(stressLabel)
        label.delete(stressLabel)
    if not na(targetLabel)
        label.delete(targetLabel)

    nominalRiskBox := na
    reserveBox := na
    rewardBox := na
    entryLine := na
    stopLine := na
    stressLine := na
    targetLine := na
    atrLine := na
    structureLine := na
    entryLabel := na
    stopLabel := na
    stressLabel := na
    targetLabel := na

    int rightBar = bar_index + projectionBars
    if showCorridor and planValid
        nominalRiskBox := box.new(left = bar_index, top = math.max(entryPrice, nominalStop), right = rightBar, bottom = math.min(entryPrice, nominalStop), xloc = xloc.bar_index, border_color = color.new(riskColor, 28), bgcolor = color.new(riskColor, 84))
        reserveBox := box.new(left = bar_index, top = math.max(nominalStop, stressEdge), right = rightBar, bottom = math.min(nominalStop, stressEdge), xloc = xloc.bar_index, border_color = color.new(reserveColor, 18), bgcolor = color.new(reserveColor, 78))
        rewardBox := box.new(left = bar_index, top = math.max(entryPrice, targetPrice), right = rightBar, bottom = math.min(entryPrice, targetPrice), xloc = xloc.bar_index, border_color = color.new(rewardColor, 30), bgcolor = color.new(rewardColor, 88))
        entryLine := line.new(x1 = bar_index, y1 = entryPrice, x2 = rightBar, y2 = entryPrice, xloc = xloc.bar_index, color = entryColor, width = 3)
        stopLine := line.new(x1 = bar_index, y1 = nominalStop, x2 = rightBar, y2 = nominalStop, xloc = xloc.bar_index, color = riskColor, width = 2)
        stressLine := line.new(x1 = bar_index, y1 = stressEdge, x2 = rightBar, y2 = stressEdge, xloc = xloc.bar_index, color = reserveColor, style = line.style_dashed, width = 2)
        targetLine := line.new(x1 = bar_index, y1 = targetPrice, x2 = rightBar, y2 = targetPrice, xloc = xloc.bar_index, color = rewardColor, width = 2)

    if showCandidates and entryValid
        if atrValid
            atrLine := line.new(x1 = bar_index, y1 = atrStop, x2 = rightBar, y2 = atrStop, xloc = xloc.bar_index, color = color.new(atrColor, 12), style = line.style_dashed, width = 1)
        if structureValid
            structureLine := line.new(x1 = bar_index, y1 = structureStop, x2 = rightBar, y2 = structureStop, xloc = xloc.bar_index, color = color.new(structureColor, 8), style = line.style_dotted, width = 2)

    if showLabels and planValid
        entryLabel := label.new(x = rightBar, y = entryPrice, text = " ENTRY " + priceText(entryPrice), xloc = xloc.bar_index, style = label.style_label_left, color = entryColor, textcolor = color.white, size = size.small)
        stopLabel := label.new(x = rightBar, y = nominalStop, text = " STOP " + priceText(nominalStop), xloc = xloc.bar_index, style = label.style_label_left, color = riskColor, textcolor = color.white, size = size.small)
        stressLabel := label.new(x = rightBar, y = stressEdge, text = " RESERVE EDGE " + priceText(stressEdge), xloc = xloc.bar_index, style = label.style_label_left, color = reserveColor, textcolor = color.black, size = size.small)
        targetLabel := label.new(x = rightBar, y = targetPrice, text = " TARGET " + priceText(targetPrice), xloc = xloc.bar_index, style = label.style_label_left, color = rewardColor, textcolor = color.white, size = size.small)

var table ledger = table.new(position.top_right, 3, 10, bgcolor = color.new(chart.bg_color, 4), frame_color = color.new(chart.fg_color, 65), frame_width = 1, border_color = color.new(chart.fg_color, 86))
if barstate.islast
    table.clear(ledger, 0, 0, 2, 9)
    if showDashboard
        table.cell(ledger, 0, 0, "RISK RESERVE", text_color = color.white, bgcolor = color.new(entryColor, 4), text_size = size.small)
        table.cell(ledger, 1, 0, direction, text_color = color.white, bgcolor = color.new(entryColor, 4), text_size = size.small)
        table.cell(ledger, 2, 0, bindingConstraint, text_color = color.white, bgcolor = color.new(bindingColor, 4), text_size = size.small)
        table.cell(ledger, 0, 1, "Status", text_color = chart.fg_color, text_size = size.small)
        table.cell(ledger, 1, 1, diagnostic, text_color = planValid ? rewardColor : riskColor, text_size = size.small)
        table.cell(ledger, 2, 1, isManualEntry ? "FIXED ENTRY" : "ROLLING", text_color = neutralColor, text_size = size.small)
        table.cell(ledger, 0, 2, "Entry / stop", text_color = chart.fg_color, text_size = size.small)
        table.cell(ledger, 1, 2, priceText(entryPrice), text_color = entryColor, text_size = size.small)
        table.cell(ledger, 2, 2, priceText(nominalStop), text_color = riskColor, text_size = size.small)
        table.cell(ledger, 0, 3, "Reserve edge", text_color = chart.fg_color, text_size = size.small)
        table.cell(ledger, 1, 3, priceText(stressEdge), text_color = reserveColor, text_size = size.small)
        table.cell(ledger, 2, 3, percentText(reserveShare), text_color = reserveColor, text_size = size.small)
        table.cell(ledger, 0, 4, "Final quantity", text_color = chart.fg_color, text_size = size.small)
        table.cell(ledger, 1, 4, numberText(positionQuantity), text_color = bindingColor, text_size = size.small)
        table.cell(ledger, 2, 4, "step " + numberText(quantityStep), text_color = neutralColor, text_size = size.small)
        table.cell(ledger, 0, 5, "Risk candidate", text_color = chart.fg_color, text_size = size.small)
        table.cell(ledger, 1, 5, numberText(riskLimitedQuantity), text_color = riskColor, text_size = size.small)
        table.cell(ledger, 2, 5, moneyText(riskBudget), text_color = riskColor, text_size = size.small)
        table.cell(ledger, 0, 6, "Exposure candidate", text_color = chart.fg_color, text_size = size.small)
        table.cell(ledger, 1, 6, numberText(exposureLimitedQuantity), text_color = reserveColor, text_size = size.small)
        table.cell(ledger, 2, 6, moneyText(exposureBudget), text_color = reserveColor, text_size = size.small)
        table.cell(ledger, 0, 7, "Stress risk used", text_color = chart.fg_color, text_size = size.small)
        table.cell(ledger, 1, 7, moneyText(actualStressRisk), text_color = utilizationColor, text_size = size.small)
        table.cell(ledger, 2, 7, percentText(riskUtilization), text_color = utilizationColor, text_size = size.small)
        table.cell(ledger, 0, 8, "Nominal / reserve", text_color = chart.fg_color, text_size = size.small)
        table.cell(ledger, 1, 8, moneyText(actualNominalRisk), text_color = riskColor, text_size = size.small)
        table.cell(ledger, 2, 8, moneyText(reserveCash), text_color = reserveColor, text_size = size.small)
        table.cell(ledger, 0, 9, "Exposure / headroom", text_color = chart.fg_color, text_size = size.small)
        table.cell(ledger, 1, 9, percentText(exposureUtilization), text_color = bindingConstraint == "EXPOSURE" ? reserveColor : neutralColor, text_size = size.small)
        table.cell(ledger, 2, 9, moneyText(riskHeadroom), text_color = rewardColor, text_size = size.small)

bool planBecameValid = barstate.isconfirmed and planValid and not planValid[1]
bool constraintChanged = barstate.isconfirmed and planValid and planValid[1] and bindingConstraint != bindingConstraint[1]
bool stressTouched = isManualEntry and planValid and (isLong ? low <= stressEdge : high >= stressEdge)
bool newStressTouch = barstate.isconfirmed and stressTouched and not stressTouched[1]


alertcondition(planBecameValid, "Risk plan became valid", "Volatility Position Risk Planner: the confirmed inputs now produce a valid stress-sized position plan.")
alertcondition(constraintChanged, "Binding constraint changed", "Volatility Position Risk Planner: the confirmed binding constraint changed between risk budget and notional exposure.")
alertcondition(newStressTouch, "Stress reserve edge touched", "Volatility Position Risk Planner: price touched the confirmed manual-entry stress reserve edge. This does not imply a fill or a guaranteed loss limit.")
````
