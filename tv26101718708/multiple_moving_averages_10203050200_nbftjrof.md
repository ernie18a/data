#  Multiple Moving Averages (10/20/30/50/200)

- url: https://www.tradingview.com/script/nBFTjrof-Multiple-Moving-Averages-10-20-30-50-200/
- type: indicator
- pine_id: PUB;3cc3f174f6fd4de2a62396bf99b2cfd1
- version: 1.0

## Description

This indicator displays 5 key Simple Moving Averages (10, 20, 30, 50, and 200 periods) commonly used in technical analysis and trading. These MAs help traders identify trend direction, momentum shifts, dynamic support/resistance levels, and potential entry/exit signals through crossovers.

## Source Code

````pine
//@version=6
indicator(
     title       = "Custom Multiple Moving Averages (10/20/30/50/200)",
     shorttitle  = "MAs 10-200",
     overlay     = true,
     max_lines_count   = 500,
     max_labels_count  = 500
)

// ── Description ──
// This indicator plots the most commonly used moving averages:
// • 10 MA  → Short-term momentum
// • 20 MA  → Short to medium-term trend
// • 30 MA  → Medium-term trend
// • 50 MA  → Medium to long-term trend (often used as dynamic support/resistance)
// • 200 MA → Long-term trend (major institutional benchmark)

// ── Inputs ──
show10  = input.bool(true,  title="Show 10 MA",  group="Moving Averages")
show20  = input.bool(true,  title="Show 20 MA",  group="Moving Averages")
show30  = input.bool(true,  title="Show 30 MA",  group="Moving Averages")
show50  = input.bool(true,  title="Show 50 MA",  group="Moving Averages")
show200 = input.bool(true,  title="Show 200 MA", group="Moving Averages")

// ── Moving Averages Calculation ──
ma10  = ta.sma(close, 10)
ma20  = ta.sma(close, 20)
ma30  = ta.sma(close, 30)
ma50  = ta.sma(close, 50)
ma200 = ta.sma(close, 200)

// ── Plotting ──
plot(show10  ? ma10  : na, color=#FF6B6B, linewidth=2, title="10 MA")
plot(show20  ? ma20  : na, color=#4ECDC4, linewidth=2, title="20 MA")
plot(show30  ? ma30  : na, color=#45B7D1, linewidth=2, title="30 MA")
plot(show50  ? ma50  : na, color=#96CEB4, linewidth=2, title="50 MA")
plot(show200 ? ma200 : na, color=#FF9F1C, linewidth=3, title="200 MA")

// Optional background fill between 50MA and 200MA (helps visualize trend strength)
fillColor = ma50 > ma200 ? color.new(#96CEB4, 90) : color.new(#FF6B6B, 90)
fill(plot(ma50), plot(ma200), color=fillColor, title="50MA - 200MA Trend Fill")
````
