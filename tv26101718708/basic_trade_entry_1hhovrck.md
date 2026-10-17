# BASIC TRADE ENTRY 

- url: https://www.tradingview.com/script/1HHOVrCk-BASIC-TRADE-ENTRY/
- type: indicator
- pine_id: PUB;649d3b71aed348d4976c1db060d28347
- version: 1.0

## Description

trade entry checklist, double click to click boxes.

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
    table.cell(t, 0, 0, "TRADE ENTRY CHECKLIST")

    table.cell(t, 0, 1,  mark(bullMS)     + "Bullish MS")
    table.cell(t, 0, 2,  mark(breakTrend) + "Break of Trend")
    table.cell(t, 0, 3,  mark(breakSR)    + "Break S/R")
    table.cell(t, 0, 4,  mark(rsiConf)    + "RSI Confirmation")
    table.cell(t, 0, 5,  mark(obvConf)    + "OBV Confirmation")
    table.cell(t, 0, 6,  mark(rsConf)     + "Relative Strength")
    table.cell(t, 0, 7,  mark(noHidden)   + "No Hidden Divergence")
    table.cell(t, 0, 8,  mark(reversal)   + "Reversal Pattern")
    table.cell(t, 0, 9,  mark(indices)    + "Indices Confirm")
    table.cell(t, 0, 10, mark(fibHit)     + "Fib Level Hit")
    table.cell(t, 0, 11, mark(rrr)        + "RRR ≥ 3:1")

    table.cell(t, 0, 12, "OPTIONAL")
    table.cell(t, 0, 13, mark(liqGrab) + "Liquidity Grab")
    table.cell(t, 0, 14, mark(divConv) + "Divergence into Convergence")

    table.cell(t, 0, 15,
      "Score: " + str.tostring(requiredPassed) +
      "/" + str.tostring(totalRequired))
````
