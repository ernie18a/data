# Put Strike Ladder [ThetaLoop]

- url: https://www.tradingview.com/script/XkLTQ5f1-Put-Strike-Ladder-ThetaLoop/
- type: indicator
- pine_id: PUB;f6431f4460c84718b7ddda3665317756
- version: 1.0

## Description

The Put Strike Ladder is a chart-side cheat sheet for cash-secured-put
research. It draws several candidate put strikes below current price and
labels each rung with the numbers you actually compare when picking a strike:

- Strike price
- Percent out-of-the-money
- Collateral required per contract (strike × 100)
- Distance from current price in ATR(14) units
- Distance from the 200-day SMA in percent

Spacing can be `Auto` (heuristic by price level) or `Manual` (set your own
dollar step to match the option-chain). Optional inputs let you assume a
premium per share to see static yield, or enter an account size to see the
collateral on the top rung as a percent of the account.

This is a map of the option-chain landscape. It is not a trade recommendation,
it does not predict which strike will work, and it does not call live option
prices.

[b]Disclaimer[/b]
Educational and research tool only. Not investment, financial, or tax advice.
Options involve substantial risk and are not suitable for every investor.
Past results do not guarantee future outcomes.

[b]Inputs the user must change before use
[/b]- `Spacing Mode` — `Auto` is fine; switch to `Manual` if you want to match a
  specific option-chain step
- `Manual Spacing ($)` — only if mode = Manual
- `Max Ladder Levels` — how many rungs to draw
- `Assumed Premium per Share` *(optional)* — to display static yield
- `Account Size` *(optional)* — to display collateral / account percent

## Source Code

````pine
// ============================================================================
// ThetaLoop Put Strike Ladder
// ============================================================================
// Version: 1.0 (Pine Script v6)
//
// Plots a ladder of candidate put strikes below current price for
// cash-secured-put research. Each rung shows strike, % OTM, collateral
// per contract, distance in ATR units, and distance to the 200-day SMA.
// Spacing can be auto (heuristic by price) or manual. This is a map of
// the option chain landscape, not a recommendation.
// ============================================================================

//@version=6
indicator("ThetaLoop Put Strike Ladder", shorttitle="TL Ladder", overlay=true, max_lines_count=100, max_labels_count=50)

// ==========================================
// 1. INPUTS
// ==========================================

modeIn         = input.string("Auto", "Spacing Mode", options=["Auto", "Manual"], group="Ladder")
manualStep     = input.float (2.5,    "Manual Spacing ($)", minval=0.01, step=0.5, group="Ladder")
maxLevels      = input.int   (8,      "Max Ladder Levels",  minval=1, maxval=20,   group="Ladder")
premiumAssumed = input.float (0.0,    "Assumed Premium per Share (optional)", minval=0.0, step=0.05, group="Optional Context")
accountSize    = input.float (0.0,    "Account Size (optional)",              minval=0.0, step=100,  group="Optional Context")
extendBars     = input.int   (14,     "Lines extend bars", minval=3, maxval=100, group="Visuals")
labelOffset    = input.int   (3,      "Label offset bars", minval=1, maxval=50, group="Visuals")

// ==========================================
// 2. AUTO STEP HEURISTIC
// ==========================================

autoStep(p) =>
    float result = na
    if p < 25
        result := 0.5
    else if p < 100
        result := 1.0
    else if p < 250
        result := 2.5
    else if p < 500
        result := 5.0
    else
        result := 10.0
    result

step   = modeIn == "Manual" ? manualStep : autoStep(close)
atr14  = ta.atr(14)
sma200 = ta.sma(close, 200)

// First rung: nearest step below spot
baseStrike = math.floor(close / step) * step
firstStrike = baseStrike >= close ? baseStrike - step : baseStrike

fmtSigned(x, pattern) =>
    na(x) ? "n/a" : (x > 0 ? "+" : "") + str.tostring(x, pattern)

// ==========================================
// 3. RENDER LADDER
// ==========================================

var line[]  ladderLines  = array.new<line>()
var label[] ladderLabels = array.new<label>()

if barstate.islast
    while array.size(ladderLines) > 0
        line.delete(array.shift(ladderLines))
    while array.size(ladderLabels) > 0
        label.delete(array.shift(ladderLabels))

    for i = 0 to maxLevels - 1
        strikeLevel = firstStrike - step * i
        if strikeLevel <= 0
            break

        otmPct      = close      > 0  ? (close - strikeLevel) / close * 100.0 : na
        collateral  = strikeLevel * 100.0
        atrDist     = atr14      > 0  ? (close - strikeLevel) / atr14         : na
        smaDist     = not na(sma200) and sma200 != 0 ? (strikeLevel - sma200) / sma200 * 100.0 : na

        transparency = math.min(80, 18 + i * 5)
        ln = line.new(bar_index - extendBars, strikeLevel,
                      bar_index + extendBars, strikeLevel,
                      color=color.new(color.rgb(37, 99, 235), transparency),
                      width=1, style=line.style_dashed)
        array.push(ladderLines, ln)

        atrTxt = na(atrDist) ? "" : "  " + str.tostring(atrDist, "#.##") + " ATR"
        smaTxt = na(smaDist) ? "" : "  vs SMA200 " + fmtSigned(smaDist, "#.#") + "%"
        labelTxt = "Strike $" + str.tostring(strikeLevel, format.mintick) +
                   "   " + str.tostring(otmPct, "#.#") + "% OTM" +
                   "   Cash $" + str.tostring(collateral, "#") +
                   atrTxt + smaTxt

        lb = label.new(bar_index + labelOffset, strikeLevel, labelTxt,
                       style=label.style_label_left,
                       color=color.rgb(30, 64, 175),
                       textcolor=color.white, size=size.small)
        array.push(ladderLabels, lb)

// ==========================================
// 4. CONTEXT TABLE
// ==========================================

var table t = table.new(position.top_right, 2, 7, frame_color=color.rgb(71, 85, 105), frame_width=1, border_color=color.rgb(51, 65, 85), border_width=1)
if barstate.islast
    yieldEst = premiumAssumed > 0 and firstStrike > 0 ? premiumAssumed / firstStrike * 100.0 : na
    capPct   = accountSize    > 0 and firstStrike > 0 ? firstStrike * 100.0 / accountSize * 100.0 : na

    headerBg = color.rgb(35, 38, 45)
    cellBg   = color.rgb(17, 24, 39)
    metricFg = color.rgb(203, 213, 225)
    valueFg  = color.rgb(241, 245, 249)

    table.cell(t, 0, 0, "Metric", bgcolor=headerBg, text_color=color.white)
    table.cell(t, 1, 0, "Value",  bgcolor=headerBg, text_color=color.white)

    table.cell(t, 0, 1, "Current Price", bgcolor=cellBg, text_color=metricFg)
    table.cell(t, 1, 1, str.tostring(close, format.mintick), bgcolor=cellBg, text_color=valueFg)

    table.cell(t, 0, 2, "Step Size", bgcolor=cellBg, text_color=metricFg)
    table.cell(t, 1, 2, "$" + str.tostring(step, "#.##") + "  (" + modeIn + ")", bgcolor=cellBg, text_color=valueFg)

    table.cell(t, 0, 3, "ATR(14)", bgcolor=cellBg, text_color=metricFg)
    table.cell(t, 1, 3, na(atr14) ? "n/a" : str.tostring(atr14, "#.##"), bgcolor=cellBg, text_color=valueFg)

    table.cell(t, 0, 4, "SMA(200)", bgcolor=cellBg, text_color=metricFg)
    table.cell(t, 1, 4, na(sma200) ? "n/a" : str.tostring(sma200, format.mintick), bgcolor=cellBg, text_color=valueFg)

    table.cell(t, 0, 5, "Static Yield (assumed prem)", bgcolor=cellBg, text_color=metricFg)
    table.cell(t, 1, 5, na(yieldEst) ? "n/a" : str.tostring(yieldEst, "#.##") + " % per contract", bgcolor=cellBg, text_color=valueFg)

    table.cell(t, 0, 6, "Top-Rung Cash / Account", bgcolor=cellBg, text_color=metricFg)
    table.cell(t, 1, 6, na(capPct) ? "n/a" : str.tostring(capPct, "#.##") + " %", bgcolor=cellBg, text_color=valueFg)
````
