# HTF Candle Overlay

- url: https://www.tradingview.com/script/N4GGZgHw-HTF-Candle-Overlay/
- type: indicator
- pine_id: PUB;9e1809a379564562a6278af2f11dd5ff
- version: 1.0

## Description

Displays a higher timeframe candlestick overlay on a lower timeframe chart. Heiken-Ashi optional display.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// Higher Timeframe Candle Overlay
// Overlays HTF OHLC candles on a lower timeframe chart using plotcandle(),
// with force_overlay=true so candles scale correctly with the main chart.
// Supports standard or Heikin-Ashi candle style, independent of the LTF chart type.

//@version=5
indicator("HTF Candle Overlay", overlay=true, max_boxes_count=500, max_lines_count=500)

// ─── INPUTS ──────────────────────────────────────────────────────────────────

var string GRP_TF    = "Timeframe"
var string GRP_STYLE = "Style"

htfInput      = input.timeframe("60", title="Higher Timeframe", group=GRP_TF)
useHA         = input.bool(false,     title="Heikin-Ashi Style", group=GRP_TF)

bullColorInput = input.color(color.new(color.teal, 0), title="Bullish Color", group=GRP_STYLE)
bearColorInput = input.color(color.new(color.red,  0), title="Bearish Color", group=GRP_STYLE)
wickColorInput = input.color(color.new(color.gray, 0), title="Wick Color",    group=GRP_STYLE)

// Opacity: 0 = fully invisible, 100 = fully solid (internally inverted to Pine's transparency scale)
bodyOpacity   = input.int(40, title="Finished Body Opacity %   (0=invisible, 100=solid)",   minval=0, maxval=100, group=GRP_STYLE)
unfinOpacity  = input.int(40, title="Unfinished Body Opacity % (0=invisible, 100=solid)",   minval=0, maxval=100, group=GRP_STYLE)
wickOpacity   = input.int(40, title="Wick Opacity %            (0=invisible, 100=solid)",   minval=0, maxval=100, group=GRP_STYLE)

// ─── HTF DATA ────────────────────────────────────────────────────────────────

// Explicitly build a standard ticker to guarantee raw OHLC regardless of chart type.
// If the LTF chart is set to Heikin-Ashi, syminfo.tickerid inherits that context;
// ticker.new() strips the chart-type modifier and always returns standard data.
stdTicker = ticker.new(syminfo.prefix, syminfo.ticker)

// Standard OHLC
// lookahead_on is used here intentionally for a display-only overlay:
// lookahead_off causes a one-period lag (HTF data appears one LTF bar late).
// Since this indicator makes no trading decisions, lookahead_on is safe and
// ensures each HTF candle aligns correctly from its very first LTF bar.
htfOpen   = request.security(stdTicker, htfInput, open,      lookahead=barmerge.lookahead_on)
htfHigh   = request.security(stdTicker, htfInput, high,      lookahead=barmerge.lookahead_on)
htfLow    = request.security(stdTicker, htfInput, low,       lookahead=barmerge.lookahead_on)
htfClose  = request.security(stdTicker, htfInput, close,     lookahead=barmerge.lookahead_on)
htfBarIdx = request.security(stdTicker, htfInput, bar_index, lookahead=barmerge.lookahead_on)

// Heikin-Ashi OHLC — ticker.heikinashi() forces HA calculation regardless of chart type
haTicker  = ticker.heikinashi(stdTicker)
htfHAOpen  = request.security(haTicker, htfInput, open,  lookahead=barmerge.lookahead_on)
htfHAHigh  = request.security(haTicker, htfInput, high,  lookahead=barmerge.lookahead_on)
htfHALow   = request.security(haTicker, htfInput, low,   lookahead=barmerge.lookahead_on)
htfHAClose = request.security(haTicker, htfInput, close, lookahead=barmerge.lookahead_on)

// Select active OHLC based on style toggle
plotOpen  = useHA ? htfHAOpen  : htfOpen
plotHigh  = useHA ? htfHAHigh  : htfHigh
plotLow   = useHA ? htfHALow   : htfLow
plotClose = useHA ? htfHAClose : htfClose

// ─── DETECT UNFINISHED (CURRENT) HTF CANDLE ──────────────────────────────────

// Track the highest HTF bar_index seen — that's always the live/unfinished period
var int maxHTFBar = na
maxHTFBar := math.max(nz(maxHTFBar, htfBarIdx), htfBarIdx)
isUnfinished = htfBarIdx == maxHTFBar

// ─── COLOURS ─────────────────────────────────────────────────────────────────

// Convert opacity (0=invisible, 100=solid) to Pine's transparency (0=solid, 100=invisible)
bodyTransp = 100 - (isUnfinished ? unfinOpacity : bodyOpacity)
wickTransp = 100 - wickOpacity

isBull      = plotClose >= plotOpen
bodyColor   = isBull ? color.new(bullColorInput, bodyTransp) : color.new(bearColorInput, bodyTransp)
borderColor = isBull ? color.new(bullColorInput, math.max(0, bodyTransp - 20))
                     : color.new(bearColorInput, math.max(0, bodyTransp - 20))
wColor      = color.new(wickColorInput, wickTransp)

// ─── PLOT ────────────────────────────────────────────────────────────────────
// plotcandle() with force_overlay=true ensures the candles pin to the main
// chart's price axis and scale correctly when you zoom or scroll.

plotcandle(plotOpen, plotHigh, plotLow, plotClose,
           title        = "HTF Candle",
           color        = bodyColor,
           wickcolor    = wColor,
           bordercolor  = borderColor,
           force_overlay = true)
````
