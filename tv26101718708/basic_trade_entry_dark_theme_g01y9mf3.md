# BASIC TRADE ENTRY dark theme

- url: https://www.tradingview.com/script/g01Y9mf3-BASIC-TRADE-ENTRY-dark-theme/
- type: indicator
- pine_id: PUB;0fa0084ec8654e5fb5cdd5ed66f9938c
- version: 1.0

## Description

basic trade entry checklist, white font for dark theme.

## Source Code

````pine
//@version=5
indicator("Trade Entry Checklist", overlay=true)

// ===== CHECKLIST INPUTS =====
bullMS     = input.bool(false, "Bullish Market Structure (MS)")
breakTrend = input.bool(false, "Break of Trend")
breakSR    = input.bool(false, "Break of Support/Resistance")
rsiConf    = input.bool(false, "RSI Confirmation")
obvConf    = input.bool(false, "OBV Confirmation")
rsConf     = input.bool(false, "Relative Strength Confirmation")
noHidden   = input.bool(false, "No Hidden Divergence")
reversal   = input.bool(false, "Reversal Pattern Present")
indices    = input.bool(false, "Indices Confirm Direction")
fibHit     = input.bool(false, "Fib Level Hit")
rrr        = input.bool(false, "Risk-to-Reward ≥ 3:1")

liqGrab    = input.bool(false, "Liquidity Grab (Optional)")
divConv    = input.bool(false, "Divergence into Convergence (Optional)")

// ===== SCORE =====
requiredPassed =
     (bullMS ? 1 : 0) +
     (breakTrend ? 1 : 0) +
     (breakSR ? 1 : 0) +
     (rsiConf ? 1 : 0) +
     (obvConf ? 1 : 0) +
     (rsConf ? 1 : 0) +
     (noHidden ? 1 : 0) +
     (reversal ? 1 : 0) +
     (indices ? 1 : 0) +
     (fibHit ? 1 : 0) +
     (rrr ? 1 : 0)

totalRequired = 11

mark(x) =>
    x ? "☑ " : "☐ "

// ===== PANEL =====
var table t = table.new(position.top_right, 1, 16, border_width=1)

if barstate.islast
    table.cell(t, 0, 0, "TRADE ENTRY CHECKLIST", text_color=color.white)

    table.cell(t, 0, 1,  mark(bullMS)     + "Bullish MS", text_color=color.white)
    table.cell(t, 0, 2,  mark(breakTrend) + "Break of Trend", text_color=color.white)
    table.cell(t, 0, 3,  mark(breakSR)    + "Break S/R", text_color=color.white)
    table.cell(t, 0, 4,  mark(rsiConf)    + "RSI Confirmation", text_color=color.white)
    table.cell(t, 0, 5,  mark(obvConf)    + "OBV Confirmation", text_color=color.white)
    table.cell(t, 0, 6,  mark(rsConf)     + "Relative Strength", text_color=color.white)
    table.cell(t, 0, 7,  mark(noHidden)   + "No Hidden Divergence", text_color=color.white)
    table.cell(t, 0, 8,  mark(reversal)   + "Reversal Pattern", text_color=color.white)
    table.cell(t, 0, 9,  mark(indices)    + "Indices Confirm", text_color=color.white)
    table.cell(t, 0, 10, mark(fibHit)     + "Fib Level Hit", text_color=color.white)
    table.cell(t, 0, 11, mark(rrr)        + "RRR ≥ 3:1", text_color=color.white)

    table.cell(t, 0, 12, "OPTIONAL", text_color=color.white)
    table.cell(t, 0, 13, mark(liqGrab) + "Liquidity Grab", text_color=color.white)
    table.cell(t, 0, 14, mark(divConv) + "Divergence into Convergence", text_color=color.white)

    table.cell(t, 0, 15,
      "Score: " + str.tostring(requiredPassed) +
      "/" + str.tostring(totalRequired),
      text_color=color.white)
````
