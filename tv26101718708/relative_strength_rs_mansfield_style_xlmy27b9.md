# Relative Strength (RS) - Mansfield Style

- url: https://www.tradingview.com/script/xLMY27b9-Relative-Strength-RS-Mansfield-Style/
- type: indicator
- pine_id: PUB;cae4b99173a1442d90adf5fb095d3105
- version: 1.0

## Description

Relative Strength (RS) measures how a symbol performs against a chosen
benchmark. Instead of plotting the raw price ratio — whose scale differs
from one symbol to another and makes comparison difficult — this script
normalizes the ratio (symbol close / benchmark close) against its own
simple moving average over a configurable lookback "Period". The result
is a zero-centered line that reads the same way on any symbol:

- RS above 0 and rising → the asset is outperforming the benchmark
- RS below 0 and falling → the asset is underperforming
- Zero-line crossings → shifts in relative leadership

Only the direction and the position relative to zero matter, not the
absolute value.

█ HOW IT WORKS

1. The script requests the benchmark's close on the selected timeframe.
2. It computes the raw ratio: symbol close / benchmark close.
3. The ratio is divided by its SMA over the "Period" lookback, minus 1 —
   expressing how far the current relative strength stands above or
   below its recent average.
4. An optional moving average of RS can be displayed as a signal line.

█ INPUTS

- Comparative Symbol: the benchmark (an index such as SPX, a sector
  index, or any peer symbol — e.g. compare gold against silver).
- Period (default 50): normalization lookback. Shorter = more reactive,
  longer = smoother and slower.
- Show Moving Average / Moving Average Period: optional smoothing line.
- Timeframe: leave empty to use the chart's timeframe, or select a
  higher timeframe for multi-timeframe analysis.

█ HOW TO USE

Apply the indicator to any symbol. When RS holds above zero, the asset
is leading its benchmark — favor it for relative-strength strategies
(buy strength). When RS holds below zero, the asset is lagging — avoid
it or rotate out. Zero-line crossovers flag early changes in relative
leadership, and two built-in alerts fire on these crossings.

RS is a relative tool, not a timing tool: an asset can outperform a
falling benchmark while still declining in absolute terms. Combine it
with your own trend or entry criteria.

█ CREDITS

The normalization method follows the Mansfield Relative Strength
concept popularized by Stan Weinstein in "Secrets for Profiting in
Bull and Bear Markets".

█ NOTE ON HIGHER TIMEFRAMES

When a higher timeframe is selected in the Timeframe input, the value
of the current forming bar updates until that bar closes. Historical
values do not repaint.

## Source Code

````pine
//@version=6
// Relative Strength (RS) — measures an asset's strength versus a benchmark.
// The ratio (asset / benchmark) is normalized against its own average over
// the lookback "Period", producing a zero-centered line: above 0 means the
// asset is outperforming the benchmark, below 0 means it is underperforming.
// Only the direction matters, not the absolute value.
indicator("Relative Strength (RS)", "RS")

// ---------- Inputs ----------
benchSym = input.symbol("SP:SPX", "Comparative Symbol", tooltip = "Benchmark to compare against, e.g. SPX, a sector index, or a peer symbol")
period   = input.int(50, "Period", minval = 1, tooltip = "Normalization lookback. RS is measured relative to its average ratio over this many bars.")
showMA   = input.bool(false, "Show Moving Average")
maPeriod = input.int(10, "Moving Average Period", minval = 1)
tf       = input.timeframe("", "Timeframe", tooltip = "Leave empty to use the chart timeframe. Note: a higher timeframe updates on the current forming bar until it closes.")

// ---------- Data (MTF-aware) ----------
assetClose = request.security(syminfo.tickerid, tf, close)
benchClose = request.security(benchSym,        tf, close)

// ---------- Normalized RS ----------
ratio    = assetClose / benchClose        // raw ratio: asset / benchmark
baseline = ta.sma(ratio, period)          // average ratio over the Period
rs       = ratio / baseline - 1           // zero-centered relative strength

// ---------- Optional smoothing ----------
signal = ta.sma(rs, maPeriod)

// ---------- Plots ----------
plot(rs, "RS", color = color.blue, linewidth = 2)
plot(showMA ? signal : na, "Signal MA", color = color.gray, linewidth = 1)
hline(0, "Zero", color = color.gray, linestyle = hline.style_dashed)

// ---------- Alerts ----------
alertcondition(ta.crossover(rs, 0),  "RS crossed above zero", "Asset started outperforming the benchmark")
alertcondition(ta.crossunder(rs, 0), "RS crossed below zero", "Asset started underperforming the benchmark")
````
