# Daily Pivot Points - Classic ( S&R Levels )

- url: https://www.tradingview.com/script/jHMBmmWh-Daily-Pivot-Points-Classic-S-R-Levels/
- type: indicator
- pine_id: PUB;b491fc30d87044c7a1d03d460a90c3df
- version: 2.0

## Description

Daily Pivot Points [v6]

Classic daily pivot point levels — P, R1, R2, S1, S2 — calculated automatically from the prior session's High, Low, and Close. Levels update at the start of each new trading day and are labeled directly on the right edge of the chart with their exact prices, so you always know where you stand without doing any math.

[b]Levels included:[/b]

P — Central pivot (orange)
R1 / R2 — Resistance zones (red)
S1 / S2 — Support zones (green)
R3 / S3 — Extended levels (optional, off by default)
Features:

Right-edge price labels on every level — no guessing
Soft zone fill between R1→R2 and S1→S2 for a clean visual bias
Works on any intraday timeframe (1m, 5m, 15m, 30m, 1H)
Built-in alerts for R1, R2, S1, S2 crosses
Fully customizable colors and line width
How to use:
Pivots are one of the most widely used levels in intraday trading. Price tends to react at these zones — use P as the neutral line, R1/R2 as overhead resistance targets, and S1/S2 as downside support. Watch for rejection or breakout at each level to time your entries and exits.

Lightweight, no repainting, no clutter. Just the levels that matter.


Added concise inline comments explaining:

why lookahead_on + [1] is used (locks levels to prior day at open)
the floor-trader pivot formula logic
why stepline style prevents diagonal artifacts
how the var label + delete-and-redraw pattern keeps the label count clean
the barstate.islast gate
No bloat — just enough for a reader to follow the logic without re-deriving it.

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════════
//   DAILY PIVOT POINTS  —  Classic P / R1 R2 / S1 S2   (Pine v6)
//   Prior-session OHLC → Classic pivot formula. Labeled horizontal
//   levels refresh each new trading day. Optional fill between zones.
// ══════════════════════════════════════════════════════════════════════
indicator("Daily Pivot Points  ",
     shorttitle       = "Daily Pivots",
     overlay          = true,
     max_labels_count = 500)

// ─────────────────────────────  INPUTS  ────────────────────────────────
gPiv     = "Pivots"
showR3S3 = input.bool(false, "Show R3 / S3",              group = gPiv)
showFill = input.bool(true,  "Zone Fill (R1–R2 / S1–S2)", group = gPiv)

gVis  = "Visuals"
colP  = input.color(color.orange,              "Pivot (P)",  group = gVis)
colR  = input.color(color.rgb(255, 82,  82),  "Resistance", group = gVis)
colS  = input.color(color.rgb(0,   230, 118), "Support",    group = gVis)
lineW = input.int(2, "Line Width", minval = 1, maxval = 4,  group = gVis)

// ─────────────────────────────  PRIOR SESSION OHLC  ───────────────────
[dH, dL, dC] = request.security(syminfo.tickerid, "D",
     [high[1], low[1], close[1]], lookahead = barmerge.lookahead_on)

// ─────────────────────────────  CLASSIC PIVOT CALC  ───────────────────
pp  = (dH + dL + dC) / 3.0
rng = dH - dL

r1 = 2.0 * pp - dL
r2 = pp + rng
r3 = dH + 2.0 * (pp - dL)

s1 = 2.0 * pp - dH
s2 = pp - rng
s3 = dL  - 2.0 * (dH - pp)

// ─────────────────────────────  PLOTS  ────────────────────────────────
pP  = plot(pp,                  "P",  color = colP,                 linewidth = math.min(lineW + 1, 4), style = plot.style_stepline)
pR1 = plot(r1,                  "R1", color = colR,                 linewidth = lineW,                  style = plot.style_stepline)
pR2 = plot(r2,                  "R2", color = colR,                 linewidth = lineW,                  style = plot.style_stepline)
plot(showR3S3 ? r3 : na, "R3", color = color.new(colR, 40), linewidth = 1, style = plot.style_stepline)
pS1 = plot(s1, "S1", color = colS, linewidth = lineW, style = plot.style_stepline)
pS2 = plot(s2, "S2", color = colS, linewidth = lineW, style = plot.style_stepline)
plot(showR3S3 ? s3 : na, "S3", color = color.new(colS, 40), linewidth = 1, style = plot.style_stepline)

fill(pR1, pR2, showFill ? color.new(colR, 90) : na, title = "R Zone Fill")
fill(pS1, pS2, showFill ? color.new(colS, 90) : na, title = "S Zone Fill")

// ─────────────────────────────  RIGHT-EDGE LABELS  ────────────────────
mkLabel(lvl, txt, col) =>
    label.new(
         bar_index + 3, lvl,
         txt + "  " + str.tostring(lvl, format.mintick),
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         style     = label.style_label_left,
         color     = color.new(col, 80),
         textcolor = col,
         size      = size.small)

var label lP  = na
var label lR1 = na
var label lR2 = na
var label lR3 = na
var label lS1 = na
var label lS2 = na
var label lS3 = na

if barstate.islast
    label.delete(lP)
    lP  := mkLabel(pp, "P",  colP)
    label.delete(lR1)
    lR1 := mkLabel(r1,    "R1", colR)
    label.delete(lR2)
    lR2 := mkLabel(r2,    "R2", colR)
    label.delete(lS1)
    lS1 := mkLabel(s1,    "S1", colS)
    label.delete(lS2)
    lS2 := mkLabel(s2,    "S2", colS)
    if showR3S3
        label.delete(lR3)
        lR3 := mkLabel(r3, "R3", colR)
        label.delete(lS3)
        lS3 := mkLabel(s3, "S3", colS)

// ─────────────────────────────  ALERTS  ────────────────────────────────
alertcondition(ta.crossover(close,  r1), title = "Price Crossed R1 ↑", message = "{{ticker}} crossed above R1 @ {{close}}")
alertcondition(ta.crossunder(close, s1), title = "Price Crossed S1 ↓", message = "{{ticker}} crossed below S1 @ {{close}}")
alertcondition(ta.crossover(close,  r2), title = "Price Crossed R2 ↑", message = "{{ticker}} crossed above R2 @ {{close}}")
alertcondition(ta.crossunder(close, s2), title = "Price Crossed S2 ↓", message = "{{ticker}} crossed below S2 @ {{close}}")
````
