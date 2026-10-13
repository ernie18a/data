<!-- tradingview-pine-id: PUB;49481c573b594c41aede31f45f33e041 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Mansfield Relative Strength vs Benchmark

Source: https://www.tradingview.com/script/SehLBRqK-Relative-Strength-vs-Benchmark-Mansfield-RS/

## Description

What this does
This indicator measures whether a stock is outperforming or underperforming a chosen benchmark index, using the Mansfield Relative Strength method — a technique long used by momentum/trend traders but rarely available as a simple, ready-to-use tool.

Why not just plot a price ratio?
A raw stock-price-to-index-price ratio only tells you if the ratio is rising or falling — the actual number means nothing on its own, and it's easy to misread. Mansfield RS fixes this by measuring how far that ratio has moved away from its own recent average, giving you a clean oscillator that centers on a zero line:

[*]Above zero (green) — the stock is outperforming its own recent relative trend against the benchmark.
[*]Below zero (red) — it's underperforming.
[*]The zero-line cross is the actual signal — marked with triangles — not the absolute level.

Settings

[*]Benchmark / Index — pick any index or stock to compare against (defaults to NSE:NIFTY, but works with any sector index or benchmark you want).
[*]Smoothing MA Length (default 200) — controls how far back the "recent average" baseline looks. Shorter = faster, noisier signals. Longer = slower, more meaningful regime changes.

How to use it
Best used as context alongside your own price-action or trend analysis — not as a standalone buy/sell trigger. A bullish setup that's also showing strong relative strength is a meaningfully different situation than the same setup on a stock quietly underperforming the market. Works especially well for filtering which names in a watchlist deserve attention first.

Alerts
Built-in alerts fire when relative strength turns positive or negative (zero-line cross).

Disclaimer
This is a context/screening tool, not a standalone trading signal. Not financial advice — always confirm with your own analysis and risk management.

---

## Source Code

````pine
//@version=6
indicator("Mansfield Relative Strength vs Benchmark", overlay=false)

// ================= INPUTS =================
benchmarkSymbol = input.symbol("NSE:NIFTY", "Benchmark / Index")
maLen           = input.int(200, "Smoothing MA Length", minval=10)

// ================= CALCULATION =================
benchClose = request.security(benchmarkSymbol, timeframe.period, close)

ratio   = close / benchClose
ratioMA = ta.sma(ratio, maLen)
rsm     = (ratio / ratioMA - 1) * 100

// ================= PLOT =================
rsmColor = rsm >= 0 ? color.new(color.green, 0) : color.new(color.red, 0)

plot(rsm, title="Mansfield RS", color=rsmColor, style=plot.style_columns)
hline(0, title="Zero Line", color=color.gray, linestyle=hline.style_solid)

bgcolor(rsm >= 0 ? color.new(color.green, 92) : color.new(color.red, 92))

// ================= ZERO-LINE CROSS MARKERS =================
crossUp   = ta.crossover(rsm, 0)
crossDown = ta.crossunder(rsm, 0)

plotshape(crossUp, title="Turned Outperformer", style=shape.triangleup, location=location.bottom, color=color.green, size=size.tiny)
plotshape(crossDown, title="Turned Underperformer", style=shape.triangledown, location=location.top, color=color.red, size=size.tiny)

// ================= ALERTS =================
alertcondition(crossUp, title="RS Turned Positive", message="{{ticker}}: relative strength turned positive vs benchmark")
alertcondition(crossDown, title="RS Turned Negative", message="{{ticker}}: relative strength turned negative vs benchmark")
````
