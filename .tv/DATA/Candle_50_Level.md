<!-- tradingview-pine-id: PUB;3c914b596fdb42de920be1bca20763d3 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Candle 50% Level

Source: https://www.tradingview.com/script/HuLF1iGW-Candle-50-Level/

## Description

Candle 50% Level

Marks the midpoint of every candle with a horizontal tick drawn directly on the bar.

The 50% level of a candle is a natural reference point — a close above it says buyers 
controlled the second half of the bar, a close below it says sellers did. This plots 
that level on every candle so you can read it at a glance instead of measuring by eye, 
and it doubles as a ready-made retracement reference for the prior bar.

HOW IT WORKS
The tick is rendered using the chart's own candle geometry, so it is always centred on 
the bar and matches its width at any zoom level.

The mark is coloured by where the candle closed relative to its own level, independent 
of whether the candle itself is up or down:
  • Green — closed above the 50% level (strength into the close)
  • Red   — closed below the 50% level (weakness into the close)
  • Grey  — closed exactly on it

SETTINGS
  • Measure across — Range (high–low) for the true bar midpoint, or Body (open–close) 
    for the midpoint of the real body only.
  • Level % — defaults to 50. Set 25 or 75 for quarter levels; 0 is the bottom of the 
    measured span, 100 the top.
  • Thickness — measured in price ticks, so the mark stays proportional as you zoom.
  • Optional price label on recent bars.

ALERTS
Two conditions fire when price closes above or below the previous candle's 50% level.

NOTE
Colouring is meaningful in Range mode. In Body mode the close is by definition the top 
or bottom of the body, so the tick would simply mirror the candle's own colour.

---

## Source Code

````pine
//@version=6
// =============================================================================
//  Candle 50% Level
//  Marks the 50% point of every candle with a horizontal tick drawn exactly on
//  the candle, using the chart's own candle geometry (plotcandle), so it can
//  never sit off-centre or overhang at any zoom level.
//    - "Range" mode measures high -> low   (true bar midpoint)
//    - "Body"  mode measures open -> close (midpoint of the real body)
//  The tick is green when the candle closed above its level, red when below.
// =============================================================================
indicator("Candle 50% Level", "C50", overlay = true, max_labels_count = 500)

// ─── Calculation inputs ──────────────────────────────────────────────────────
string calcMode = input.string("Range (high–low)", "Measure across", options = ["Range (high–low)", "Body (open–close)"], tooltip = "Range = midpoint of the whole candle including wicks. Body = midpoint of the open-to-close body only.")
float  pct      = input.float(50.0, "Level %", minval = 0, maxval = 100, step = 1, tooltip = "0% = bottom of the measured span, 100% = top. 50% is the midpoint.")

// ─── Display inputs ──────────────────────────────────────────────────────────
string GS       = "Style"
int    thickTck = input.int(0, "Thickness (in price ticks)", minval = 0, maxval = 20, group = GS, tooltip = "0 draws a hairline. Raise it to thicken the mark — it is measured in price ticks, so it stays proportional as you zoom.")
color  aboveCol = input.color(#26a69a, "Closed above level", group = GS)
color  belowCol = input.color(#ef5350, "Closed below level", group = GS)
color  equalCol = input.color(#b2b5be, "Closed at level",    group = GS)
bool   showLbl  = input.bool(false, "Show price label", group = GS)
int    lblBars  = input.int(50, "Label: last N bars", minval = 1, maxval = 500, group = GS)

// ─── Level ───────────────────────────────────────────────────────────────────
bool  useBody = calcMode == "Body (open–close)"
float top     = useBody ? math.max(open, close) : high
float bot     = useBody ? math.min(open, close) : low
float lvl     = bot + (top - bot) * pct / 100.0

// Colour by where the close finished relative to the level, not by candle colour.
color col = close > lvl ? aboveCol : close < lvl ? belowCol : equalCol

// ─── Draw ────────────────────────────────────────────────────────────────────
// A zero-height candle renders as a horizontal bar occupying exactly the same
// slot as the price candle, so it is centred by construction — no x-coordinate
// arithmetic, nothing to drift.
float halfH = thickTck * syminfo.mintick / 2.0
plotcandle(lvl - halfH, lvl + halfH, lvl - halfH, lvl + halfH, "50% level", color = col, bordercolor = col, wickcolor = na)

if showLbl and bar_index > last_bar_index - lblBars
    label.new(bar_index, lvl, str.tostring(lvl, format.mintick), style = label.style_label_left, color = color.new(col, 90), textcolor = col, size = size.tiny)

// Exposed for the Data Window and for other scripts / alerts.
plot(lvl, "50% value", display = display.data_window)

// ─── Alerts (based on the PREVIOUS candle's level, so they're actionable) ─────
alertcondition(ta.crossover(close, lvl[1]),  "Close above prior 50%", "Price closed above the previous candle's 50% level")
alertcondition(ta.crossunder(close, lvl[1]), "Close below prior 50%", "Price closed below the previous candle's 50% level")
````
