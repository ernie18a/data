# Candle Size Marker

- url: https://www.tradingview.com/script/5micnHYP-Candle-Size-Marker/
- type: indicator
- pine_id: PUB;f5447bf961a04ff59a75ebde457e2aea
- version: 1.0

## Description

Here's a description you can use for the indicator:

Candle Size Marker
Automatically flags candles that exceed a minimum tick threshold, helping you quickly spot unusually large price moves at a glance.
How it works
The indicator measures each candle's range in ticks and compares it against a configurable minimum. When a candle qualifies, an arrow is plotted above or below the bar — green arrows below bullish candles, red arrows above bearish ones. An optional label displays the exact tick count next to each marked candle.
Inputs

Minimum tick move — The tick threshold a candle must reach to be flagged (default: 200)
Use body only — When enabled, measures the open-to-close body instead of the full high-to-low range
Bullish / Bearish arrow color — Customize the arrow colors independently
Show tick count label — Toggles the tick count label on qualifying candles

Alerts
Includes a built-in alert condition (Large candle detected) that fires on any bar meeting the threshold, compatible with TradingView's alert system.
Works on any market and timeframe — tick size is derived automatically from the symbol's mintick value, so no manual adjustment is needed when switching instruments.

## Source Code

````pine
//@version=6
indicator("Candle Size Marker", overlay=true)

// ─── Settings ───────────────────────────────────────────────
tickThreshold = input.int(200,    "Minimum tick move", minval=1, step=10)
useBody       = input.bool(false, "Use body only (ignore wicks)")
bullColor     = input.color(color.new(color.lime, 0), "Bullish arrow color")
bearColor     = input.color(color.new(color.red,  0), "Bearish arrow color")
showLabel     = input.bool(true,  "Show tick count label")

// ─── Logic ──────────────────────────────────────────────────
candleRange = useBody ? math.abs(close - open) : (high - low)
tickMove    = candleRange / syminfo.mintick
isBull      = close >= open
qualifies   = tickMove >= tickThreshold

// ─── Plot arrows ────────────────────────────────────────────
plotshape(qualifies and isBull,
     style    = shape.arrowup,
     location = location.belowbar,
     color    = bullColor,
     size     = size.normal,
     title    = "Bullish large candle")

plotshape(qualifies and not isBull,
     style    = shape.arrowdown,
     location = location.abovebar,
     color    = bearColor,
     size     = size.normal,
     title    = "Bearish large candle")

// ─── Tick count label ───────────────────────────────────────
if qualifies and showLabel
    label.new(
         x         = bar_index,
         y         = isBull ? low - (2 * syminfo.mintick) : high + (2 * syminfo.mintick),
         text      = str.tostring(math.round(tickMove)) + "t",
         style     = isBull ? label.style_label_up : label.style_label_down,
         color     = isBull ? bullColor : bearColor,
         textcolor = color.white,
         size      = size.large)

// ─── Alert ──────────────────────────────────────────────────
alertcondition(qualifies, "Large candle detected", "Large candle detected on this bar")
````
