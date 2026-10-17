# Position Size Calculator

- url: https://www.tradingview.com/script/eTTo78N3/
- type: indicator
- pine_id: PUB;4eb03e537ebd416e92f75b1c429e1959
- version: 1.0

## Description

A simple on-chart position sizing tool. Enter your account size and risk percentage, click your stop-loss (and optionally a target) directly on the chart, and the table shows the position size that keeps your loss at the chosen risk amount if the stop is hit.

How it works

Position size = (account size x risk %) / distance between entry and stop. Entry defaults to the current price, or can be set manually. If a target is set, the reward-to-risk ratio is also displayed. Stop and target levels are drawn on the chart, and the table position is configurable.

Notes and limitations

Sizes are expressed in instrument units; for forex, convert units to lots according to your broker's contract size, and note that P&L currency conversion is not performed. Fees, slippage and gaps are not modeled — a stop-loss order does not guarantee the stop price in fast markets. This is a calculation aid, not trade advice.

## Source Code

````pine
//@version=6
// ============================================================
//  Position Size Calculator
//  Calculates position size from account size, risk % and
//  stop distance. Stop/target prices can be picked directly
//  on the chart via interactive price inputs.
// ============================================================
indicator("Position Size Calculator", overlay = true)

// ---------- Inputs ----------
grpR = "Risk"
acct    = input.float(10000, "Account size",       minval = 0,    group = grpR)
riskPct = input.float(1.0,   "Risk per trade (%)", minval = 0.01, step = 0.1, group = grpR)

grpP = "Prices (click on chart to set)"
useLive = input.bool(true,  "Use current price as entry",       group = grpP)
entryIn = input.price(0.0,  "Entry price (manual)",             group = grpP)
stopIn  = input.price(0.0,  "Stop-loss price",                  group = grpP)
tgtIn   = input.price(0.0,  "Target price (0 = off)",           group = grpP)

grpD = "Display"
posOpt    = input.string("Bottom Right", "Table position",
     options = ["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group = grpD)
showLines = input.bool(true, "Draw stop/target lines", group = grpD)

f_pos(string s) =>
    s == "Top Right" ? position.top_right :
     s == "Bottom Right" ? position.bottom_right :
     s == "Top Left" ? position.top_left : position.bottom_left

// ---------- Lines ----------
plot(showLines and stopIn > 0 ? stopIn : na, "Stop",   color.new(#ef5350, 30), 1, plot.style_linebr)
plot(showLines and tgtIn  > 0 ? tgtIn  : na, "Target", color.new(#26a69a, 30), 1, plot.style_linebr)

// ---------- Table ----------
var table t = table.new(f_pos(posOpt), 2, 6, border_width = 1)

f_cell(int col, int row, string txt, color bg) =>
    table.cell(t, col, row, txt, text_color = color.white, bgcolor = bg, text_size = size.normal)

if barstate.islast
    entry   = useLive or entryIn == 0 ? close : entryIn
    riskAmt = acct * riskPct / 100
    dist    = math.abs(entry - stopIn)
    valid   = stopIn > 0 and dist > 0
    qty     = valid ? riskAmt / dist : na
    rr      = valid and tgtIn > 0 ? math.abs(tgtIn - entry) / dist : na

    hdr = color.new(#131722, 0)
    bdy = color.new(#363a45, 0)

    f_cell(0, 0, "Entry",     hdr)
    f_cell(1, 0, str.tostring(entry, format.mintick), bdy)
    f_cell(0, 1, "Stop",      hdr)
    f_cell(1, 1, valid ? str.tostring(stopIn, format.mintick) : "set on chart", valid ? bdy : color.new(#ef5350, 40))
    f_cell(0, 2, "Risk",      hdr)
    f_cell(1, 2, str.tostring(riskAmt, "#.##") + " (" + str.tostring(riskPct, "#.##") + "%)", bdy)
    f_cell(0, 3, "Stop dist", hdr)
    f_cell(1, 3, valid ? str.tostring(dist, format.mintick) : "-", bdy)
    f_cell(0, 4, "Size",      hdr)
    f_cell(1, 4, valid ? str.tostring(qty, "#.####") + " units" : "-", color.new(#2962ff, 30))
    f_cell(0, 5, "R:R",       hdr)
    f_cell(1, 5, not na(rr) ? "1 : " + str.tostring(rr, "#.##") : "-", bdy)
````
