<!-- tradingview-pine-id: PUB;8fb9a9320e8b419fad0178f9503fe6ba -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# EMA Trend Signals

Source: https://www.tradingview.com/script/mftN9f1e-EMA-Trend-Signals/

## Description

EMA Trend Signals

OVERVIEW
EMA Trend Signals is a clean, lightweight trend-following tool built around two exponential moving averages (EMAs). It colors the trend, highlights the space between the two averages, and marks the exact bars where the fast average crosses the slow one — giving an at-a-glance read on direction and momentum shifts without cluttering the chart.

HOW IT WORKS
The script calculates two EMAs from a source of your choice:
• Fast EMA (default 21) — reacts quickly to recent price.
• Slow EMA (default 55) — represents the broader trend.

The relationship between them defines the regime:
• Fast EMA above the slow EMA → momentum is aligned to the upside → bullish (green).
• Fast EMA below the slow EMA → momentum is aligned to the downside → bearish (red).

An EMA is a weighted average that gives more importance to recent bars, so it follows price faster than a simple moving average while still smoothing out noise. Using two lengths separates short-term momentum (fast) from the prevailing trend (slow); the point where they cross is a classic, widely used signal for a potential shift in control between buyers and sellers.

WHAT IT DRAWS
• Fast EMA line, colored by the active trend (green / red).
• Slow EMA line as a neutral reference.
• A soft fill between the two EMAs, tinted by direction — a wider gap means stronger separation.
• An optional light background tint showing the current regime.
• Triangle markers on the exact bar where a cross occurs (up / down).

HOW TO USE IT
• Trend bias: read green as a long bias and red as a short bias. Many traders only take positions in the direction of the color.
• Signals: the up-triangle (fast crosses above slow) and down-triangle (fast crosses below slow) mark momentum shifts. They perform best in trending conditions and will whipsaw in tight ranges — pair them with your own structure, key levels, or a higher-timeframe filter.
• Tuning: shorten the lengths for faster, more frequent signals; lengthen them for fewer, smoother ones. Change the Source input to apply the logic to hl2, hlc3, and so on.

ALERTS
Two ready-made alerts are included — "EMA Cross Up" and "EMA Cross Down" — so you can be notified the moment a cross happens on any symbol or timeframe.

SETTINGS
• Source — price series the EMAs are built from (default close).
• Fast EMA length — short-term average (default 21).
• Slow EMA length — trend average (default 55).
• Trend background — toggle the regime tint.
• Cross markers — toggle the triangle shapes.

NOTES & LIMITATIONS
Moving-average crosses are lagging by nature: they confirm a move after it has already begun rather than predicting it, and they can produce false signals in sideways markets. This tool is a visual aid for trend direction and momentum shifts — it is not a complete trading system and does not manage risk or position size. Always confirm with your own analysis.

Open-source — feel free to study, use, and build on it.
For research and educational purposes only. This is not financial advice.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © zebris_boris
//
// ──────────────────────────────────────────────────────────────
//  EMA Trend Signals  ·  Boris Tatchou
// ──────────────────────────────────────────────────────────────
//  A clean, lightweight trend tool:
//    • Two EMAs define the trend; the fast line and the fill
//      between them are colored by direction (bull / bear).
//    • Optional soft background tint shows the active regime.
//    • Markers + alerts fire when the fast EMA crosses the slow.
//  Free & open-source. For research/education — not financial advice.
// ──────────────────────────────────────────────────────────────
//@version=6
indicator("EMA Trend Signals", overlay = true)

// ── Inputs ─────────────────────────────────────────────────
src       = input.source(close, "Source",             group = "EMAs")
fastLen   = input.int(21, "Fast EMA length", minval = 1, group = "EMAs")
slowLen   = input.int(55, "Slow EMA length", minval = 1, group = "EMAs")
showBg    = input.bool(true, "Trend background", group = "Display")
showMarks = input.bool(true, "Cross markers",    group = "Display")

// ── Calculation ────────────────────────────────────────────
fast = ta.ema(src, fastLen)
slow = ta.ema(src, slowLen)
bull = fast > slow

crossUp   = ta.crossover(fast, slow)
crossDown = ta.crossunder(fast, slow)

// ── Style ──────────────────────────────────────────────────
colUp    = color.new(#26a69a, 0)
colDown  = color.new(#ef5350, 0)
trendCol = bull ? colUp : colDown

// ── Plots ──────────────────────────────────────────────────
pF = plot(fast, "Fast EMA", color = trendCol,                  linewidth = 2)
pS = plot(slow, "Slow EMA", color = color.new(color.gray, 20), linewidth = 1)
fill(pF, pS, color = color.new(bull ? colUp : colDown, 85), title = "Trend fill")

bgcolor(showBg ? color.new(bull ? colUp : colDown, 92) : na, title = "Trend background")

plotshape(showMarks and crossUp,   "Cross Up",   shape.triangleup,   location.belowbar, colUp,   size = size.small)
plotshape(showMarks and crossDown, "Cross Down", shape.triangledown, location.abovebar, colDown, size = size.small)

// ── Alerts ─────────────────────────────────────────────────
alertcondition(crossUp,   "EMA Cross Up",   "EMA Trend Signals: fast crossed ABOVE slow on {{ticker}} ({{interval}})")
alertcondition(crossDown, "EMA Cross Down", "EMA Trend Signals: fast crossed BELOW slow on {{ticker}} ({{interval}})")
````
