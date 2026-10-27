# Trading-Sparks - Relative Strength Line

- url: https://www.tradingview.com/script/KjWpC8wP-Trading-Sparks-Relative-Strength-Line/
- type: indicator
- pine_id: PUB;2d3295eef6b046009bb165a3fb5d08cb
- version: 1.0

## Description

Relative Strength Line shows how the chart symbol has performed against a benchmark over a fixed lookback, colours that line by whether relative strength is improving or weakening, and breaks the result into its two parts so it is clear where the relative number comes from.

What it shows
- A line of relative performance in percent over the lookback. Above zero means the symbol beat the benchmark over that window; below zero means it lagged.
- Colour: green while relative strength is improving, red while it is weakening.
- Triangles where the symbol's relative strength makes a new high or low over a longer window.
- A readout with three numbers for the lookback: the symbol's own % change, the benchmark's % change, and the relative % change.

How it works
The ratio close / benchmark close is computed on the chart's timeframe. Relative performance is the percent change of that ratio over the lookback, which equals (1 + symbol %) / (1 + benchmark %) - 1. The regime colour comes from an EMA of the ratio: improving while the EMA rises, weakening while it falls. New relative highs and lows compare the ratio with its highest and lowest values over the longer window.

Why the decomposition readout
A relative-strength line on its own hides the path. A +8% relative reading can mean the symbol rose 10% while the market rose 2%, or fell 2% while the market fell 9%. Those are very different situations for someone who is long. The readout shows both legs next to the relative figure so the reading cannot be mistaken, which is the reason this script exists alongside simpler ratio plots.

How to use it
- Set the benchmark to what the symbol should be judged against: a sector index for a stock, the broad index for a sector, or a peer.
- Adjust the lookback to your holding period (63 bars is about a quarter on a daily chart).
- Shorter regime smoothing reacts sooner but flips more often.
- Alerts are available for regime changes and for new relative highs and lows.

Limitations
- One symbol against one benchmark; it does not rank or compare many symbols.
- Relative strength describes what has already happened. It is not a forecast and not a trade signal.
- The benchmark is requested on the chart's own timeframe with no lookahead, so it does not repaint historical bars; the current bar updates until it closes.

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// RakeshPoluri - © Trading-Sparks — trading-sparks.com

//@version=6
indicator("Trading-Sparks - Relative Strength Line", shorttitle = "RS Line", overlay = false, precision = 2)

// -----------------------------------------------------------------------------
// WHAT THIS SHOWS
//   Relative performance of the chart symbol against a benchmark over a fixed
//   lookback, in percent:
//       relative % = 100 * ((1 + symbol %) / (1 + benchmark %) - 1)
//   which is the same as the change in the ratio close / benchmark over the
//   lookback. Above zero: the symbol beat the benchmark over that window.
//
//   On top of the plain ratio:
//     - Regime colour: the ratio is smoothed with an EMA and the line is green
//       while that EMA is rising, red while it is falling.
//     - New relative high / low markers over a longer window.
//     - A readout that decomposes the relative figure into its two parts:
//       the symbol's own % change and the benchmark's % change, so a positive
//       relative number from a falling stock in a falling market is visible
//       for what it is.
//
// WHAT IT DOES NOT DO
//   No signals, no ranking, no forecast. One symbol against one benchmark.
//
// REPAINTING
//   None. The benchmark is requested on the chart's own timeframe with
//   lookahead off, so there is no higher-timeframe leak. The live bar moves
//   until it closes, as every indicator's does.
// -----------------------------------------------------------------------------

// Inputs
benchSym  = input.symbol("NSE:NIFTY", "Benchmark", tooltip = "Any chartable symbol: an index, a sector index, a stock or an ETF.")
lookback  = input.int(63,  "Performance lookback (bars)", minval = 5,  tooltip = "Relative performance is measured over this many bars. 63 is roughly one quarter of daily bars.")
slopeLen  = input.int(10,  "Regime smoothing (bars)",     minval = 2,  tooltip = "EMA length applied to the ratio. The regime is rising while this EMA rises. Shorter flips sooner and is noisier.")
hlLen     = input.int(126, "New relative high/low window (bars)", minval = 10, tooltip = "Marks bars where the ratio makes its highest or lowest value over this many bars.")
showMarks = input.bool(true, "Mark new relative highs and lows")

// Benchmark on the chart's own timeframe
bench = request.security(benchSym, timeframe.period, close, lookahead = barmerge.lookahead_off)

// Relative strength
rs       = close / bench
rsPct    = 100.0 * (rs / rs[lookback] - 1.0)
symPct   = 100.0 * (close / close[lookback] - 1.0)
benPct   = 100.0 * (bench / bench[lookback] - 1.0)
rsSmooth = ta.ema(rs, slopeLen)
rising   = rsSmooth > rsSmooth[1]

newRelHigh = showMarks and rs >= ta.highest(rs, hlLen)
newRelLow  = showMarks and rs <= ta.lowest(rs, hlLen)

// Plot
colUp     = color.new(#3FB07A, 0)
colDn     = color.new(#E0563B, 0)
colFillUp = color.new(#3FB07A, 85)
colFillDn = color.new(#E0563B, 85)
colMuted  = #8B94A1
colText   = #ECEAE3

hline(0, "Benchmark", color = color.new(colMuted, 40), linestyle = hline.style_dotted)
p  = plot(rsPct, "Relative %", color = rising ? colUp : colDn, linewidth = 2)
p0 = plot(0, "Zero", display = display.none)
fill(p, p0, color = rsPct >= 0 ? colFillUp : colFillDn)

plotshape(newRelHigh ? rsPct : na, "New relative high", style = shape.triangleup,   location = location.absolute, color = colUp, size = size.tiny)
plotshape(newRelLow  ? rsPct : na, "New relative low",  style = shape.triangledown, location = location.absolute, color = colDn, size = size.tiny)

// Readout: the relative figure and its two parts
fmt(x) => (x >= 0 ? "+" : "") + str.tostring(x, "#.##") + "%"
var tbl = table.new(position.top_right, 2, 5, border_width = 0)
if barstate.islast
    table.cell(tbl, 0, 0, "Last " + str.tostring(lookback) + " bars", text_color = colMuted, text_size = size.small)
    table.cell(tbl, 1, 0, "",                          text_color = colMuted, text_size = size.small)
    table.cell(tbl, 0, 1, syminfo.ticker,              text_color = colText,  text_size = size.small)
    table.cell(tbl, 1, 1, fmt(symPct),                 text_color = symPct >= 0 ? colUp : colDn, text_size = size.small)
    table.cell(tbl, 0, 2, "Benchmark",                 text_color = colText,  text_size = size.small)
    table.cell(tbl, 1, 2, fmt(benPct),                 text_color = benPct >= 0 ? colUp : colDn, text_size = size.small)
    table.cell(tbl, 0, 3, "Relative",                  text_color = colText,  text_size = size.small)
    table.cell(tbl, 1, 3, fmt(rsPct),                  text_color = rsPct >= 0 ? colUp : colDn, text_size = size.small)
    table.cell(tbl, 0, 4, "Regime",                    text_color = colText,  text_size = size.small)
    table.cell(tbl, 1, 4, rising ? "Improving" : "Weakening", text_color = rising ? colUp : colDn, text_size = size.small)

// Alerts
alertcondition(rising and not rising[1], "RS regime turned up",   "{{ticker}}: relative strength regime turned up vs benchmark")
alertcondition(not rising and rising[1], "RS regime turned down", "{{ticker}}: relative strength regime turned down vs benchmark")
alertcondition(newRelHigh, "New relative high", "{{ticker}}: new relative-strength high vs benchmark")
alertcondition(newRelLow,  "New relative low",  "{{ticker}}: new relative-strength low vs benchmark")
````
