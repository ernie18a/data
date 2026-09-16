<!-- tradingview-pine-id: PUB;40b3833c8f6044bc9f86897fe8485294 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Rolling Drawdown / Run-up % by YCGH Capital

Source: https://www.tradingview.com/script/c1xDAFeP-Rolling-Drawdown-Run-up-by-YCGH-Capital/

## Description

Rolling Drawdown / Run-up % — Description

This indicator plots two independent metrics on a single oscillator pane, showing how stretched the current price is relative to its own recent high and recent low:

🔴 Rolling Drawdown %
Measures how far the current price is below the highest high of the last N bars (default 20). Shown as a negative percentage — 0% means price is at a new rolling high, while deeper negative values mean price has pulled back further from that peak.

🟢 Rolling Run-up %
Measures how far the current price is above the lowest low of the last N bars. Shown as a positive percentage — 0% means price is at a new rolling low, while higher positive values mean price has climbed further off that bottom.

Both metrics recalculate on a rolling basis, so the reference high/low continuously slides forward with the chart rather than anchoring to an all-time extreme. This makes the indicator responsive to recent volatility and price structure rather than historical outliers.

How to read it

Both lines share a common zero line, so you can see at a glance how far price is stretched in either direction without switching panes.
Because the peak (for drawdown) and trough (for run-up) are found independently within the same window, the two values are not mirror images — a symbol can show a moderate drawdown from its recent high while also showing a strong run-up from its recent low, revealing where price sits within its own recent range.
A live label displays the current drawdown/run-up values plus the deepest drawdown and highest run-up seen in the visible chart range.

Inputs

Rolling Window (bars) — lookback length for both the peak and trough calculations
Price Source — the price used to measure drawdown/run-up (default: close)
Peak Source / Trough Source — the price used to define the rolling extremes (default: high / low)
Custom colors for each line and fill

Alerts

Drawdown crossing below −10% / −20%
Run-up crossing above +10% / +20%

Use cases

Spotting how extended a move is before a potential mean reversion
Quickly comparing pullback depth vs. rally strength on the same instrument
Building alert-driven systems around volatility thresholds without needing separate indicators for drawdown and run-up

---

## Source Code

````pine
//@version=6
indicator("Rolling Drawdown / Run-up % by YCGH Capital", shorttitle="RollDD/RU", overlay=false)

// ───────────────────────────────
// Inputs
// ───────────────────────────────
lookbackDays  = input.int(20, title="Rolling Window (days/bars)", minval=1, tooltip="Number of bars used for both the rolling peak and rolling trough.")
priceSource   = input.source(close, title="Price Source (for both DD & RunUp)")
peakSource    = input.source(high, title="Price Source for Rolling Peak")
troughSource  = input.source(low, title="Price Source for Rolling Trough")
showStats     = input.bool(true, title="Show Deepest DD / Highest RunUp in Visible Range")
ddFillColor   = input.color(color.new(color.red, 70), title="Drawdown Fill Color")
ddLineColor   = input.color(color.red, title="Drawdown Line Color")
ruFillColor   = input.color(color.new(color.green, 70), title="Run-up Fill Color")
ruLineColor   = input.color(color.green, title="Run-up Line Color")

// ───────────────────────────────
// Calculations (independent, each from its own rolling extreme)
// ───────────────────────────────
rollingPeak   = ta.highest(peakSource, lookbackDays)
rollingTrough = ta.lowest(troughSource, lookbackDays)

drawdownPct = (priceSource - rollingPeak) / rollingPeak * 100.0     // <= 0
runupPct    = (priceSource - rollingTrough) / rollingTrough * 100.0 // >= 0

// Track extremes visible on chart (informational)
var float minDD = na
var float maxRU = na
if bar_index == 0
    minDD := drawdownPct
    maxRU := runupPct
else
    minDD := math.min(nz(minDD, drawdownPct), drawdownPct)
    maxRU := math.max(nz(maxRU, runupPct), runupPct)

// ───────────────────────────────
// Plots
// ───────────────────────────────
ddPlot   = plot(drawdownPct, title="Rolling Drawdown %", color=ddLineColor, linewidth=2)
ruPlot   = plot(runupPct, title="Rolling Run-up %", color=ruLineColor, linewidth=2)
zeroLine = plot(0, title="Zero Line", color=color.new(color.gray, 50))

fill(ddPlot, zeroLine, color=ddFillColor, title="Drawdown Fill")
fill(ruPlot, zeroLine, color=ruFillColor, title="Run-up Fill")

hline(0, "0%", color=color.new(color.gray, 80), linestyle=hline.style_dashed)

// ───────────────────────────────
// Label with both readings
// ───────────────────────────────
if showStats and barstate.islast
    label.new(
         bar_index, math.max(runupPct, math.abs(drawdownPct)),
         text="DD: " + str.tostring(drawdownPct, format.percent) + " (deepest: " + str.tostring(minDD, format.percent) + ")" +
              "\nRunUp: " + str.tostring(runupPct, format.percent) + " (highest: " + str.tostring(maxRU, format.percent) + ")",
         style=label.style_label_left,
         color=color.new(color.black, 20),
         textcolor=color.white,
         xloc=xloc.bar_index)

// ───────────────────────────────
// Alerts
// ───────────────────────────────
alertcondition(drawdownPct <= -10, title="Drawdown Below -10%", message="Rolling drawdown has exceeded -10%")
alertcondition(drawdownPct <= -20, title="Drawdown Below -20%", message="Rolling drawdown has exceeded -20%")
alertcondition(runupPct >= 10, title="Run-up Above 10%", message="Rolling run-up has exceeded 10%")
alertcondition(runupPct >= 20, title="Run-up Above 20%", message="Rolling run-up has exceeded 20%")
````
