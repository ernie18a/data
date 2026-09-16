<!-- tradingview-pine-id: PUB;038d7bad82d745f1b8a2c70e0dc244dd -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# EMA Trend Pro

Source: https://www.tradingview.com/script/I74w6eYG-EMA-Trend-Pro/

## Description

EMA Trend Pro

OVERVIEW
EMA Trend Pro is a dual moving-average trend tool with built-in confluence filters. It colors the trend, marks momentum shifts when the fast average crosses the slow one, and — unlike a plain moving-average cross — filters those signals through a higher-timeframe trend check and an ATR-based range check to cut down on false signals. A compact info panel keeps the current state visible at a glance.

HOW IT WORKS
The script builds two moving averages from a source of your choice, and you can select the averaging method (EMA, SMA, WMA, RMA, or VWMA):
• Fast MA (default 21) — reacts quickly to recent price.
• Slow MA (default 55) — represents the broader trend.

Their relationship defines the regime:
• Fast above slow → momentum aligned to the upside → bullish (green).
• Fast below slow → momentum aligned to the downside → bearish (red).

A moving average smooths price into a single line; an exponential MA weights recent bars more heavily so it tracks price faster than a simple average. Using two lengths separates short-term momentum (fast) from the prevailing trend (slow), and the point where they cross is a classic signal for a potential shift of control between buyers and sellers.

THE FILTERS (what makes this more than a plain cross)
A raw moving-average cross has two well-known weaknesses: it fires against the larger trend, and it whipsaws when the market is flat. EMA Trend Pro addresses both:

• Higher-timeframe (HTF) filter — the same two averages are also computed on a higher timeframe you choose. Long signals are only allowed when the HTF trend is up, and short signals only when it is down. This keeps you trading with the larger trend instead of against it. The HTF values are read without lookahead, so historical signals do not repaint.

• ATR separation filter — the Average True Range (ATR) measures how much price typically moves per bar. This filter ignores any cross where the two averages are closer together than a chosen multiple of ATR, which removes the low-conviction crosses that happen when the averages are tangled in a tight range.

Both filters are optional and independent, so you can run the tool as a simple cross, a trend-aligned system, or a strict range-aware system.

WHAT IT DRAWS
• Fast MA line, colored by the active trend (green / red).
• Slow MA line as a neutral reference.
• A fill between the two averages, tinted by direction — a wider gap means stronger separation.
• Optional background tint and optional bar coloring for the current regime.
• Triangle markers on the exact bar where a filtered signal occurs (up / down).

INFO PANEL
A small top-right table shows, at a glance:
• Trend — current lower-timeframe direction.
• HTF — the higher-timeframe direction and the timeframe used.
• Signal — LONG, SHORT, or none on the current bar.

HOW TO USE IT
• Trend bias: read green as a long bias and red as a short bias.
• Signals: the up / down triangles mark filtered momentum shifts. With the HTF filter on, they only appear in the direction of the larger trend.
• Reduce noise: enable the ATR separation filter, or raise its multiplier, to keep only stronger crosses.
• Tuning: shorter lengths give faster, more frequent signals; longer lengths give fewer, smoother ones. Try different MA types and a higher timeframe that suits your trading style (for example, a 4H filter for signals taken on lower timeframes).

SETTINGS
• MA type — averaging method (EMA / SMA / WMA / RMA / VWMA).
• Source — price series the averages are built from (default close).
• Fast length / Slow length — the two averages (defaults 21 / 55).
• Higher-timeframe filter + Higher timeframe — enable and choose the HTF trend check.
• Min separation filter + Min separation (× ATR) — enable and set the range filter.
• Trend fill / Trend background / Color bars by trend / Signal markers / Info panel — display toggles.

ALERTS
Four ready-made alerts: filtered Long and Short signals, plus Trend flip up and Trend flip down — so you can be notified on any symbol or timeframe.

NOTES & LIMITATIONS
Moving-average crosses are lagging by nature: they confirm a move after it has begun rather than predicting it. The filters reduce false signals but cannot remove them, and a higher-timeframe filter naturally produces fewer, later entries in exchange for better alignment. This tool is a visual aid for trend direction and momentum shifts — it is not a complete trading system and does not manage risk or position size. Always confirm with your own analysis.

Open-source — feel free to study, use, and build on it.
For research and educational purposes only. This is not financial advice.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © zebris_boris
//
// ──────────────────────────────────────────────────────────────
//  EMA Trend Pro  ·  Boris Tatchou
// ──────────────────────────────────────────────────────────────
//  A dual moving-average trend tool with confluence filters:
//    • Selectable MA type (EMA / SMA / WMA / RMA / VWMA).
//    • Higher-timeframe trend filter — signals only fire when the
//      lower-timeframe cross agrees with the HTF trend.
//    • ATR separation filter — ignores crosses in tight ranges to
//      cut whipsaw.
//    • Trend fill, background tint, bar coloring, an info panel,
//      and alerts for signals and trend flips.
//  Free & open-source. For research/education — not financial advice.
// ──────────────────────────────────────────────────────────────
//@version=6
indicator("EMA Trend Pro", overlay = true)

// ── Moving averages ────────────────────────────────────────
maType  = input.string("EMA", "MA type", options = ["EMA", "SMA", "WMA", "RMA", "VWMA"], group = "Moving averages")
src     = input.source(close, "Source",  group = "Moving averages")
fastLen = input.int(21, "Fast length", minval = 1, group = "Moving averages")
slowLen = input.int(55, "Slow length", minval = 1, group = "Moving averages")

// ── Filters ────────────────────────────────────────────────
useHtf  = input.bool(true, "Higher-timeframe filter", group = "Filters", tooltip = "Only allow long signals when the HTF trend is up, and short signals when it is down.")
htfTf   = input.timeframe("240", "Higher timeframe",  group = "Filters")
useAtr  = input.bool(false, "Min separation filter",  group = "Filters", tooltip = "Ignore crosses where the two averages are closer than the threshold — reduces whipsaw in tight ranges.")
atrMult = input.float(0.25, "Min separation (× ATR)", minval = 0.0, step = 0.05, group = "Filters")

// ── Display ────────────────────────────────────────────────
showFill  = input.bool(true,  "Trend fill",           group = "Display")
showBg    = input.bool(false, "Trend background",     group = "Display")
colorBars = input.bool(false, "Color bars by trend",  group = "Display")
showMarks = input.bool(true,  "Signal markers",       group = "Display")
showPanel = input.bool(true,  "Info panel",           group = "Display")

// ── Moving-average helper ──────────────────────────────────
ma(source, len) =>
    switch maType
        "SMA"  => ta.sma(source, len)
        "WMA"  => ta.wma(source, len)
        "RMA"  => ta.rma(source, len)
        "VWMA" => ta.vwma(source, len)
        =>        ta.ema(source, len)

// ── Calculation ────────────────────────────────────────────
fast = ma(src, fastLen)
slow = ma(src, slowLen)
bull = fast > slow

[htfFast, htfSlow] = request.security(syminfo.tickerid, htfTf, [ma(src, fastLen), ma(src, slowLen)], lookahead = barmerge.lookahead_off)
htfBull = htfFast > htfSlow

atr   = ta.atr(14)
sep   = math.abs(fast - slow)
sepOk = not useAtr or sep >= atrMult * atr

xUp   = ta.crossover(fast, slow)
xDown = ta.crossunder(fast, slow)

longSig  = xUp   and (not useHtf or htfBull)     and sepOk
shortSig = xDown and (not useHtf or not htfBull) and sepOk

// ── Style ──────────────────────────────────────────────────
colUp    = color.new(#26a69a, 0)
colDown  = color.new(#ef5350, 0)
trendCol = bull ? colUp : colDown

// ── Plots ──────────────────────────────────────────────────
pF = plot(fast, "Fast MA", color = trendCol,                  linewidth = 2)
pS = plot(slow, "Slow MA", color = color.new(color.gray, 20), linewidth = 1)
fill(pF, pS, color = showFill ? color.new(bull ? colUp : colDown, 85) : na, title = "Trend fill")

bgcolor(showBg ? color.new(bull ? colUp : colDown, 92) : na, title = "Trend background")
barcolor(colorBars ? trendCol : na, title = "Trend bars")

plotshape(showMarks and longSig,  "Long signal",  shape.triangleup,   location.belowbar, colUp,   size = size.small)
plotshape(showMarks and shortSig, "Short signal", shape.triangledown, location.abovebar, colDown, size = size.small)

// ── Info panel ─────────────────────────────────────────────
var table panel = table.new(position.top_right, 2, 3, border_width = 1, frame_color = color.new(color.gray, 60), bgcolor = color.new(color.black, 20))
if showPanel and barstate.islast
    table.cell(panel, 0, 0, "Trend",  text_color = color.gray, text_size = size.small)
    table.cell(panel, 1, 0, bull ? "▲ Bull" : "▼ Bear", text_color = trendCol, text_size = size.small)
    table.cell(panel, 0, 1, "HTF",    text_color = color.gray, text_size = size.small)
    table.cell(panel, 1, 1, (htfBull ? "▲ " : "▼ ") + htfTf, text_color = htfBull ? colUp : colDown, text_size = size.small)
    _sTxt = longSig ? "LONG" : shortSig ? "SHORT" : "—"
    _sCol = longSig ? colUp : shortSig ? colDown : color.gray
    table.cell(panel, 0, 2, "Signal", text_color = color.gray, text_size = size.small)
    table.cell(panel, 1, 2, _sTxt, text_color = _sCol, text_size = size.small)

// ── Alerts ─────────────────────────────────────────────────
alertcondition(longSig,  "Long signal",  "EMA Trend Pro: LONG on {{ticker}} ({{interval}})")
alertcondition(shortSig, "Short signal", "EMA Trend Pro: SHORT on {{ticker}} ({{interval}})")
alertcondition(bull and not bull[1], "Trend flip up",   "EMA Trend Pro: trend flipped BULLISH on {{ticker}} ({{interval}})")
alertcondition(not bull and bull[1], "Trend flip down", "EMA Trend Pro: trend flipped BEARISH on {{ticker}} ({{interval}})")
````
