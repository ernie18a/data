# Perfect Profit Benchmark

- url: https://www.tradingview.com/script/MvEjNNja-Perfect-Profit-Benchmark/
- type: indicator
- pine_id: PUB;5568d6d794234ebab19635b7f04593f3
- version: 1.0

## Description

Most traders evaluate a strategy only by Net Profit, Profit Factor, or Drawdown. But these metrics do not answer the main question: how effectively did the strategy use the real opportunity provided by the market? [b]Perfect Profit Benchmark[/b] was created for exactly this purpose — it shows not just the profit of a strategy, but its efficiency relative to the ideal swing potential of the instrument.

The script is based on the concept of [b]Perfect Profit and Model Efficiency, described by Robert Pardo[/b] in his approach to evaluating and optimizing trading strategies. The idea is simple: over any selected period, the market contains a certain amount of potential profit. Even a perfect strategy cannot earn more than the price movement itself allowed. Therefore, it is more important to understand not only how much a strategy earned, but what share of the available market movement it was able to capture.

Pardo uses Perfect Profit as an ideal benchmark and compares the result of a real trading model against it. As a practical guideline, the author indicates that an efficiency of 5% or more of the ideal result can already be considered a strong performance level. This makes the metric especially useful: the trader receives not an abstract profit number, but a clear percentage of captured market opportunity.

Perfect Profit Benchmark measures this market capacity through ZigZag swings. The script detects confirmed pivot highs and pivot lows based on a selected reversal percentage, then calculates the ideal profit between these points. Unlike unrealistic bar-by-bar models that assume predicting every next bar, this approach evaluates the market through larger directional swings, making it much closer to real swing/trend trading logic.

[b]The script calculates three key metrics:[/b]
ZigZag Perfect L/S — ideal performance when trading both directions, long and short.
ZigZag Perfect Long — ideal performance from upward swings only.
ZigZag Perfect Short — ideal performance from downward swings only.

The script also shows the total number of swings, the number of long swings, the number of short swings, and the efficiency percentage of your strategy relative to each ideal model. This helps identify where the strategy is stronger: in long moves, short moves, or the overall long/short market structure.

Perfect Profit Benchmark takes into account position size, point value, commission, fixed trading costs, and slippage. This makes the comparison more realistic: each swing is calculated not as raw price movement, but as potential profit after trading costs. The chart displays ZigZag lines, current direction zones, and labels showing the profit of each completed swing, allowing you to visually see where the market provided the main profit opportunities and how much of that movement an ideal model could have captured.

The main value of the script is that it gives the trader a benchmark. If a strategy earned $50,000, that number alone says little. But if the ideal swing potential of the market over the same period was $1,000,000, the strategy captured 5%. If the potential was $200,000, the strategy captured 25%. These are fundamentally different conclusions about the quality of the model.

Perfect Profit Benchmark helps separate a strong strategy from a strategy that simply benefited from a favorable market. It shows how efficiently an algorithm extracts profit from the available movement, where the return ceiling of the instrument is, and how far the current model is from ideal performance.

Test your strategy, enter its Net Profit into Perfect Profit Benchmark, and compare the result with the market’s ideal performance. This is a direct way to understand the real strength of a trading system, its share of captured market movement, and its potential for further optimization.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Smollet

//@version=6
indicator('KYM: Perfect Profit Benchmark', overlay = true, max_lines_count = 500, max_labels_count = 500)

//-------------------------
// Inputs
//-------------------------
reversalPct = input.float(5.0, 'ZigZag reversal, %', minval = 0.1, step = 0.1)

qty = input.float(1.0, 'Contracts / Coins', minval = 0.0)

useSymbolPointValue = input.bool(true, 'Use syminfo.pointvalue')
manualPointValue = input.float(1.0, 'Manual point value', minval = 0.0)

commissionPct = input.float(0.0, 'Commission % per side', minval = 0.0, step = 0.001)
fixedCostSide = input.float(0.0, 'Fixed cost per side, $', minval = 0.0, step = 0.01)
slippageTicks = input.float(0.0, 'Slippage ticks per side', minval = 0.0, step = 0.1)

strategyNetProfit = input.float(0.0, 'Your strategy Net Profit, $')

showZigZag = input.bool(true, 'Show ZigZag lines')
showLabels = input.bool(true, 'Show swing profit labels')
showBg = input.bool(false, 'Show swing direction background')

roundStepInput = input.string('1', 'Label profit rounding', options = ['0.01', '0.1', '1'])

//-------------------------
// Helpers
//-------------------------
pv = useSymbolPointValue ? syminfo.pointvalue : manualPointValue
roundStep = str.tonumber(roundStepInput)

f_side_cost(price) =>
    commission = price * qty * pv * commissionPct / 100.0
    slippage = slippageTicks * syminfo.mintick * pv * qty
    commission + fixedCostSide + slippage

f_reversal_amount(price) =>
    price * reversalPct / 100.0

f_round_to_step(value, step) =>
    math.round(value / step) * step

f_format_int_spaces(value) =>
    s = str.tostring(math.round(value), '#')
    sign = str.substring(s, 0, 1) == '-' ? '-' : ''
    body = sign == '-' ? str.substring(s, 1, str.length(s)) : s
    len = str.length(body)
    out = ''

    for i = 0 to len - 1 by 1
        ch = str.substring(body, i, i + 1)
        left = len - i
        out := out + ch

        if left > 1 and left % 3 == 1
            out := out + ' '
            out

    sign + out

f_format_rounded(value) =>
    rounded = f_round_to_step(value, roundStep)
    roundStep >= 1.0 ? f_format_int_spaces(rounded) : str.tostring(rounded, '#.##')

//-------------------------
// ZigZag state
//-------------------------
var int direction = 0
//  0 = not initialized
//  1 = rising swing, searching pivot high
// -1 = falling swing, searching pivot low

var float candidateHigh = na
var int candidateHighBar = na

var float candidateLow = na
var int candidateLowBar = na

var float lastPivotPrice = na
var int lastPivotBar = na
var int lastPivotType = 0
//  1 = pivot high
// -1 = pivot low

var float swingPerfectLS = 0.0
var float swingPerfectLongOnly = 0.0
var float swingPerfectShortOnly = 0.0

var int swingCount = 0
var int longSwingCount = 0
var int shortSwingCount = 0

var int currentVisualDirection = 0

//-------------------------
// Initialize
//-------------------------
if barstate.isfirst
    candidateHigh := high
    candidateHighBar := bar_index
    candidateLow := low
    candidateLowBar := bar_index
    candidateLowBar

//-------------------------
// New pivot placeholders
//-------------------------
float newPivotPrice = na
int newPivotBar = na
int newPivotType = 0

//-------------------------
// ZigZag detection
//-------------------------
if direction == 0
    if high > candidateHigh
        candidateHigh := high
        candidateHighBar := bar_index
        candidateHighBar

    if low < candidateLow
        candidateLow := low
        candidateLowBar := bar_index
        candidateLowBar

    upMoveFromLow = high - candidateLow
    downMoveFromHigh = candidateHigh - low

    canStartFromLow = candidateLowBar < bar_index and candidateLowBar < candidateHighBar and upMoveFromLow >= f_reversal_amount(candidateLow)

    canStartFromHigh = candidateHighBar < bar_index and candidateHighBar < candidateLowBar and downMoveFromHigh >= f_reversal_amount(candidateHigh)

    if canStartFromLow
        newPivotPrice := candidateLow
        newPivotBar := candidateLowBar
        newPivotType := -1

        direction := 1
        currentVisualDirection := 1

        // Keep current high as candidate for the rising swing.
        candidateHigh := high
        candidateHighBar := bar_index
        candidateHighBar

    else if canStartFromHigh
        newPivotPrice := candidateHigh
        newPivotBar := candidateHighBar
        newPivotType := 1

        direction := -1
        currentVisualDirection := -1

        // Keep current low as candidate for the falling swing.
        candidateLow := low
        candidateLowBar := bar_index
        candidateLowBar

else if direction == 1
    highUpdatedThisBar = false

    if na(candidateHigh) or high > candidateHigh
        candidateHigh := high
        candidateHighBar := bar_index
        highUpdatedThisBar := true
        highUpdatedThisBar

    // Critical rule:
    // If this bar made a new candidate high, the same bar cannot confirm that high as pivot.
    canConfirmHigh = not highUpdatedThisBar and candidateHighBar < bar_index and candidateHigh - low >= f_reversal_amount(candidateHigh)

    if canConfirmHigh
        newPivotPrice := candidateHigh
        newPivotBar := candidateHighBar
        newPivotType := 1

        direction := -1
        currentVisualDirection := -1

        // Reversal bar becomes candidate low for the next falling swing.
        // But it is not allowed to become confirmed pivot low on this same bar.
        candidateLow := low
        candidateLowBar := bar_index
        candidateLowBar

else if direction == -1
    lowUpdatedThisBar = false

    if na(candidateLow) or low < candidateLow
        candidateLow := low
        candidateLowBar := bar_index
        lowUpdatedThisBar := true
        lowUpdatedThisBar

    // Critical rule:
    // If this bar made a new candidate low, the same bar cannot confirm that low as pivot.
    canConfirmLow = not lowUpdatedThisBar and candidateLowBar < bar_index and high - candidateLow >= f_reversal_amount(candidateLow)

    if canConfirmLow
        newPivotPrice := candidateLow
        newPivotBar := candidateLowBar
        newPivotType := -1

        direction := 1
        currentVisualDirection := 1

        // Reversal bar becomes candidate high for the next rising swing.
        // But it is not allowed to become confirmed pivot high on this same bar.
        candidateHigh := high
        candidateHighBar := bar_index
        candidateHighBar

//-------------------------
// Register confirmed pivot
//-------------------------
if not na(newPivotPrice)
    canRegisterPivot = na(lastPivotBar) or newPivotBar != lastPivotBar

    if canRegisterPivot
        hasPreviousPivot = not na(lastPivotPrice)

        float legGross = na
        float legCosts = na
        float legNet = na
        float legNetForCapacity = na

        bool isUpLeg = false
        bool isDownLeg = false

        if hasPreviousPivot
            legGross := math.abs(newPivotPrice - lastPivotPrice) * pv * qty
            legCosts := f_side_cost(lastPivotPrice) + f_side_cost(newPivotPrice)
            legNet := legGross - legCosts
            legNetForCapacity := math.max(legNet, 0.0)

            isUpLeg := newPivotPrice > lastPivotPrice
            isDownLeg := newPivotPrice < lastPivotPrice

            swingPerfectLS := swingPerfectLS + legNetForCapacity

            if isUpLeg
                swingPerfectLongOnly := swingPerfectLongOnly + legNetForCapacity
                longSwingCount := longSwingCount + 1
                longSwingCount

            if isDownLeg
                swingPerfectShortOnly := swingPerfectShortOnly + legNetForCapacity
                shortSwingCount := shortSwingCount + 1
                shortSwingCount

            swingCount := swingCount + 1

            if showZigZag
                lineColor = isUpLeg ? color.new(color.green, 0) : color.new(color.red, 0)
                line.new(lastPivotBar, lastPivotPrice, newPivotBar, newPivotPrice, xloc = xloc.bar_index, extend = extend.none, color = lineColor, width = 2)

            if showLabels
                labelText = f_format_rounded(legNetForCapacity)
                labelStyle = isUpLeg ? label.style_label_down : label.style_label_up
                labelColor = isUpLeg ? color.new(color.green, 0) : color.new(color.red, 0)

                label.new(newPivotBar, newPivotPrice, labelText, xloc = xloc.bar_index, style = labelStyle, color = labelColor, textcolor = color.white, size = size.tiny)

        lastPivotPrice := newPivotPrice
        lastPivotBar := newPivotBar
        lastPivotType := newPivotType
        lastPivotType

//-------------------------
// Background
//-------------------------
bgcolor(showBg and currentVisualDirection == 1 ? color.new(color.green, 88) : na)
bgcolor(showBg and currentVisualDirection == -1 ? color.new(color.red, 88) : na)

//-------------------------
// Efficiency
//-------------------------
effVsLS = swingPerfectLS != 0.0 ? strategyNetProfit / swingPerfectLS * 100.0 : na
effVsLongOnly = swingPerfectLongOnly != 0.0 ? strategyNetProfit / swingPerfectLongOnly * 100.0 : na
effVsShortOnly = swingPerfectShortOnly != 0.0 ? strategyNetProfit / swingPerfectShortOnly * 100.0 : na

//-------------------------
// Table
//-------------------------
var table t = table.new(position.top_right, 2, 10, border_width = 1)

if barstate.islast
    table.cell(t, 0, 0, 'Metric')
    table.cell(t, 1, 0, 'Value')

    table.cell(t, 0, 1, 'ZigZag Perfect L/S')
    table.cell(t, 1, 1, f_format_int_spaces(swingPerfectLS))

    table.cell(t, 0, 2, 'ZigZag Perfect Long')
    table.cell(t, 1, 2, f_format_int_spaces(swingPerfectLongOnly))

    table.cell(t, 0, 3, 'ZigZag Perfect Short')
    table.cell(t, 1, 3, f_format_int_spaces(swingPerfectShortOnly))

    table.cell(t, 0, 4, 'All swings')
    table.cell(t, 1, 4, str.tostring(swingCount))

    table.cell(t, 0, 5, 'Long swings')
    table.cell(t, 1, 5, str.tostring(longSwingCount))

    table.cell(t, 0, 6, 'Short swings')
    table.cell(t, 1, 6, str.tostring(shortSwingCount))

    table.cell(t, 0, 7, 'Efficiency vs L/S')
    table.cell(t, 1, 7, str.tostring(effVsLS, '#.##') + '%')

    table.cell(t, 0, 8, 'Efficiency vs Long')
    table.cell(t, 1, 8, str.tostring(effVsLongOnly, '#.##') + '%')

    table.cell(t, 0, 9, 'Efficiency vs Short')
    table.cell(t, 1, 9, str.tostring(effVsShortOnly, '#.##') + '%')
````
