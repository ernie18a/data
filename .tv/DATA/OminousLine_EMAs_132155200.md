<!-- tradingview-pine-id: PUB;c6544601a8e6484da31025c81dba1787 -->
<!-- tradingviewscripts-format: 1 -->
# OminousLine EMAs (13/21/55/200)

Source: https://www.tradingview.com/script/RJrUVjKJ-OminousLine-EMAs-13-21-55-200/

## Description

OminousLine EMAs (13/21/55/200)

OminousLine EMAs is a clean and customizable trend-following indicator that combines four Exponential Moving Averages — EMA 13, 21, 55, and 200 — in a single chart overlay.

The indicator is designed to provide a clear visual overview of short-, medium-, and long-term market trends while keeping the chart simple and easy to read.

EMA Structure

The four default moving averages represent different layers of market momentum:

EMA 13 — Fast-moving EMA for short-term price action and momentum.
EMA 21 — Short-term trend reference that provides a slightly smoother view of price movement.
EMA 55 — Intermediate trend indicator that helps filter short-term market noise.
EMA 200 — Long-term trend reference commonly used to evaluate the broader market direction.
Trend Alignment

The relationship between the four EMAs can help visualize the current market structure.

A bullish EMA alignment may occur when:

EMA 13 > EMA 21 > EMA 55 > EMA 200

When the averages are aligned and separating upward, it can indicate increasing bullish momentum.

A bearish EMA alignment may occur when:

EMA 13 < EMA 21 < EMA 55 < EMA 200

When the averages are aligned and separating downward, it can indicate increasing bearish momentum.

When the EMAs begin moving closer together, it may indicate consolidation or weakening directional momentum.

Dynamic Support & Resistance

Moving averages can also act as dynamic reference areas during trending markets.

Price reactions around the EMA 13, 21, 55, or 200 can provide additional context when analyzing pullbacks, trend continuation, or changes in market structure.

These areas should not be considered fixed support or resistance levels.

Customization

OminousLine EMAs is fully customizable.

For each EMA, users can independently adjust:

EMA length
Visibility
Line color
Line width

Default configuration:

EMA 13 — Orange
EMA 21 — Cyan
EMA 55 — Amber
EMA 200 — Purple

The default colors are designed to provide clear visual separation, particularly on dark chart backgrounds.

How to Use

OminousLine EMAs can be used to help analyze:

Short-, medium-, and long-term trend direction
Bullish and bearish EMA alignment
Changes in momentum
EMA crossovers
EMA compression and expansion
Price interaction with moving averages
Potential dynamic support and resistance areas

The indicator can be used across different markets and timeframes. Traders can customize the EMA periods and appearance to suit their own analysis and trading methodology.

Important Notice

OminousLine EMAs is a visual trend-analysis tool and does not automatically generate buy or sell signals.

EMA alignment, crossovers, and price interactions should not be interpreted as guaranteed trading opportunities. The indicator is intended to complement other forms of technical analysis, market structure analysis, and appropriate risk management.

For informational and educational purposes only. Not financial advice.

---

## Source Code

````pine
//@version=6
indicator("OminousLine EMAs (13/21/55/200)", overlay=true)

// ─────────────────────────────────────
// EMA 13
// ─────────────────────────────────────
ema13Length = input.int(13, title="Length", minval=1, group="EMA 13")
show13      = input.bool(true, "Show EMA 13", group="EMA 13")
ema13Color  = input.color(#FF6D00, "Color", group="EMA 13")
ema13Width  = input.int(2, "Line Width", minval=1, maxval=5, group="EMA 13")

// ─────────────────────────────────────
// EMA 21
// ─────────────────────────────────────
ema21Length = input.int(21, title="Length", minval=1, group="EMA 21")
show21      = input.bool(true, "Show EMA 21", group="EMA 21")
ema21Color  = input.color(#00E5FF, "Color", group="EMA 21")
ema21Width  = input.int(2, "Line Width", minval=1, maxval=5, group="EMA 21")

// ─────────────────────────────────────
// EMA 55
// ─────────────────────────────────────
ema55Length = input.int(55, title="Length", minval=1, group="EMA 55")
show55      = input.bool(true, "Show EMA 55", group="EMA 55")
ema55Color  = input.color(#FFD740, "Color", group="EMA 55")
ema55Width  = input.int(2, "Line Width", minval=1, maxval=5, group="EMA 55")

// ─────────────────────────────────────
// EMA 200
// ─────────────────────────────────────
ema200Length = input.int(200, title="Length", minval=1, group="EMA 200")
show200      = input.bool(true, "Show EMA 200", group="EMA 200")
ema200Color  = input.color(#B388FF, "Color", group="EMA 200")
ema200Width  = input.int(3, "Line Width", minval=1, maxval=5, group="EMA 200")

// ─────────────────────────────────────
// Calculations
// ─────────────────────────────────────
ema13  = ta.ema(close, ema13Length)
ema21  = ta.ema(close, ema21Length)
ema55  = ta.ema(close, ema55Length)
ema200 = ta.ema(close, ema200Length)

// ─────────────────────────────────────
// Plots
// ─────────────────────────────────────
plot(show13 ? ema13 : na, title="EMA 13", color=ema13Color, linewidth=ema13Width)
plot(show21 ? ema21 : na, title="EMA 21", color=ema21Color, linewidth=ema21Width)
plot(show55 ? ema55 : na, title="EMA 55", color=ema55Color, linewidth=ema55Width)
plot(show200 ? ema200 : na, title="EMA 200", color=ema200Color, linewidth=ema200Width)
````
