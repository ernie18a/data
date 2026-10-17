# Structure & Trend Context

- url: https://www.tradingview.com/script/gGKIAiB0-Structure-Trend-Context/
- type: indicator
- pine_id: PUB;f106d8600b3b401cbb34310c5e1bdac1
- version: 1.0

## Description

Structure & Trend Context is a clean overlay that visualises market structure and trend direction without cluttering the chart. It is built as a context tool to support your own analysis, not as a signal system.

What it shows
- Trend filter: a fast and a slow EMA define the prevailing direction. The slow EMA is colour-coded by bias (up / down / neutral).
- Volatility band: an ATR band around the fast EMA gives a sense of normal price travel and dynamic over-/under-extension.
- Swing structure: the most recent confirmed swing high and swing low are tracked and drawn as reference levels.
- Structure breaks (BoS): a marker appears only when price closes beyond the prior swing by an ATR buffer while in trend. Each level is locked after it breaks, so markers stay rare and meaningful rather than firing on every minor poke.
- Context panel: a compact top-right table showing current trend bias, last higher high and last lower low.

How to use it
Read the chart first. Use the trend filter and band for context, the swing levels for reference, and treat a structure break as one piece of confluence, not a standalone trigger. Raise "Swing sensitivity" on higher timeframes or noisy assets to keep only the larger structure.

Inputs
Every layer (band, swing levels, structure markers, raw pivots, panel, bar tint) has its own toggle, and the EMA, ATR and pivot lengths are fully adjustable.

Notes
This indicator is a visualisation aid for discretionary analysis. It does not predict price, does not generate buy or sell recommendations, and is not financial advice. Markers are confirmed on bar close and do not repaint. Open-source — adapt it to your own workflow.

## Source Code

````pine
//@version=6
indicator("Structure & Trend Context", shorttitle="STC", overlay=true, max_labels_count=60)

// ── Inputs ──────────────────────────────────────────────
g_str = "Structure"
pivotLen    = input.int(8, "Swing sensitivity", minval=2, maxval=30, group=g_str, tooltip="Higher = fewer, more significant swings.")
breakBuffer = input.float(0.25, "Break confirmation (ATR)", minval=0.0, step=0.05, group=g_str, tooltip="Price must clear the swing by this fraction of ATR to register a break. Filters out marginal pokes.")

g_trend = "Trend"
fastLen = input.int(21, "Fast EMA", minval=2, group=g_trend)
slowLen = input.int(55, "Slow EMA", minval=3, group=g_trend)

g_vol = "Volatility band"
atrLen   = input.int(14, "ATR length", minval=2, group=g_vol)
bandMult = input.float(1.5, "Band width (ATR)", minval=0.2, step=0.1, group=g_vol)

g_disp = "Display"
showBand   = input.bool(true,  "Volatility band", group=g_disp)
showBreaks = input.bool(true,  "Structure-break markers", group=g_disp)
showSwings = input.bool(true,  "Swing high/low levels", group=g_disp)
showPivots = input.bool(false, "Raw pivot markers", group=g_disp)
showPanel  = input.bool(true,  "Context panel", group=g_disp)
tintBars   = input.bool(false, "Subtle trend bar tint", group=g_disp)

// ── Calculations ────────────────────────────────────────
emaFast = ta.ema(close, fastLen)
emaSlow = ta.ema(close, slowLen)
atr     = ta.atr(atrLen)

trendUp   = emaFast > emaSlow and close > emaSlow
trendDown = emaFast < emaSlow and close < emaSlow
bias = trendUp ? 1 : trendDown ? -1 : 0

// Track most recent confirmed swings; lock each level so it breaks only once
var float swingHigh = na
var float swingLow  = na
var bool  highOpen  = false
var bool  lowOpen   = false

ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low,  pivotLen, pivotLen)

if not na(ph)
    swingHigh := ph
    highOpen  := true
if not na(pl)
    swingLow := pl
    lowOpen  := true

// Significant break: confirmed close beyond the swing by an ATR buffer, in trend
breakUp   = highOpen and not na(swingHigh) and close > swingHigh + atr * breakBuffer and trendUp   and barstate.isconfirmed
breakDown = lowOpen  and not na(swingLow)  and close < swingLow  - atr * breakBuffer and trendDown and barstate.isconfirmed
if breakUp
    highOpen := false
if breakDown
    lowOpen := false

// ── Palette ─────────────────────────────────────────────
colUp   = color.rgb(38, 166, 91)
colDown = color.rgb(192, 57, 43)
colNeut = color.rgb(130, 130, 140)
biasCol = bias == 1 ? colUp : bias == -1 ? colDown : colNeut

// ── Plots ───────────────────────────────────────────────
upper = emaFast + atr * bandMult
lower = emaFast - atr * bandMult
pU = plot(showBand ? upper : na, "Band upper", color=color.new(biasCol, 78), linewidth=1)
pL = plot(showBand ? lower : na, "Band lower", color=color.new(biasCol, 78), linewidth=1)
fill(pU, pL, color=color.new(biasCol, 94))

plot(emaFast, "Fast EMA", color=color.new(color.gray, 25), linewidth=1)
plot(emaSlow, "Slow EMA", color=color.new(biasCol, 0), linewidth=2)

plot(showSwings ? swingHigh : na, "Swing high", color=color.new(colUp, 60),  style=plot.style_linebr)
plot(showSwings ? swingLow  : na, "Swing low",  color=color.new(colDown, 60), style=plot.style_linebr)

plotshape(showPivots and not na(ph), "Pivot high", style=shape.triangledown, location=location.abovebar, offset=-pivotLen, color=color.new(colDown, 50), size=size.tiny)
plotshape(showPivots and not na(pl), "Pivot low",  style=shape.triangleup,   location=location.belowbar, offset=-pivotLen, color=color.new(colUp, 50),  size=size.tiny)

plotshape(showBreaks and breakUp,   "Bullish structure break", style=shape.triangleup,   location=location.belowbar, color=colUp,   text="BoS", textcolor=color.white, size=size.tiny)
plotshape(showBreaks and breakDown, "Bearish structure break", style=shape.triangledown, location=location.abovebar, color=colDown, text="BoS", textcolor=color.white, size=size.tiny)

barcolor(tintBars ? (bias == 1 ? color.new(colUp, 75) : bias == -1 ? color.new(colDown, 75) : na) : na)

// ── Context panel ───────────────────────────────────────
if showPanel and barstate.islast
    var table p = table.new(position.top_right, 2, 3, frame_color=color.new(color.gray, 60), frame_width=1, border_color=color.new(color.gray, 80), border_width=1)
    biasTxt = bias == 1 ? "Uptrend" : bias == -1 ? "Downtrend" : "Neutral"
    table.cell(p, 0, 0, "Trend",   text_color=color.gray, text_size=size.small)
    table.cell(p, 1, 0, biasTxt,   text_color=biasCol,    text_size=size.small)
    table.cell(p, 0, 1, "Last HH", text_color=color.gray, text_size=size.small)
    table.cell(p, 1, 1, na(swingHigh) ? "—" : str.tostring(swingHigh, format.mintick), text_color=color.gray, text_size=size.small)
    table.cell(p, 0, 2, "Last LL", text_color=color.gray, text_size=size.small)
    table.cell(p, 1, 2, na(swingLow) ? "—" : str.tostring(swingLow, format.mintick), text_color=color.gray, text_size=size.small)

// ── Alerts (neutral wording, no performance claims) ─────
alertcondition(breakUp,   "Bullish structure break", "Price closed above the prior swing high while the trend filter is positive.")
alertcondition(breakDown, "Bearish structure break", "Price closed below the prior swing low while the trend filter is negative.")
````
