# RichmondHillCM - BTC vs Business Cycle (ISM PMI)

- url: https://www.tradingview.com/script/GwltutlG-RichmondHillCM-BTC-vs-Business-Cycle-ISM-PMI/
- type: indicator
- pine_id: PUB;eef986d302b44efe88278a599c8d63b5
- version: 1.0

## Description

[b]BTC vs Business Cycle (ISM PMI)[/b]

This indicator overlays the U.S. ISM Manufacturing PMI against Bitcoin price to help you frame BTC within the broader macro/business cycle. The idea is simple: manufacturing activity is a classic gauge of economic momentum, and BTC has historically behaved differently in expansionary versus contractionary macro environments. This tool makes that relationship visible at a glance.

[b]What it does[/b]

It pulls monthly PMI data and monthly BTC price, then normalizes Bitcoin into the PMI's 40–70 range so both can be read on the same scale. The PMI line is color-coded by regime, and Bitcoin is plotted alongside it for easy comparison.

[b]Regime classification[/b]

[b]Expansion [/b]— PMI at or above 50 (amber)
[b]Strong Expansion / Bull [/b]— PMI at or above the Bull Threshold, default 55 (green)
[b]Contraction [/b]— PMI below 50 (red)

The 50 level marks the expansion/contraction boundary, and a configurable Bull Threshold marks the stronger-momentum zone. Background shading highlights contraction and strong-bull periods, and labels mark the moments PMI crosses 50 in either direction.

[b]Reading the panel[/b]
A live info table (top-right) summarizes the current PMI value, the active regime, whether BTC is in a "bull-supportive" macro environment, and the latest BTC price.

[b]Inputs
[/b]

PMI Symbol — the data feed for PMI. Availability depends on your TradingView data access. If the default doesn't load, try alternates such as FRED:NAPM, ECONOMICS:USPMI, or another ISM/PMI source your plan supports.
Bull PMI Threshold — adjusts where the "strong expansion" zone begins.
Shade Regimes — toggles background shading on/off.

[b]Notes[/b]
This is a macro-context tool, not a timing or entry/exit signal generator. PMI is monthly and released with a lag, so treat it as a regime backdrop rather than a trade trigger. Not financial advice — do your own research.

## Source Code

````pine
//@version=6
// ============================================================================
//  RHCM SMART SIGNALS SUITE  —  multi-component confluence toolkit (template)
// ----------------------------------------------------------------------------
//  Components:
// Try these symbols in order if one fails — change in inputs
// Option A (free): "FRED:NAPM"
// Option B (free): "QUANDL:ISM/MAN_PMI"
// Option C (paid): "ECONOMICS:USPMI"
// Option D (paid): "ISM:MAN_PMI"
// ============================================================================
indicator("RichmondHillCM - BTC vs Business Cycle (ISM PMI)", overlay=false, max_bars_back=5000)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
show_shading = input.bool(true, "Shade Regimes")
bull_thresh  = input.float(55.0, "Bull PMI Threshold", minval=50.0, maxval=70.0)

// ─────────────────────────────────────────────
// DATA
// Try these symbols in order if one fails — change in inputs
// Option A (free): "FRED:NAPM"
// Option B (free): "QUANDL:ISM/MAN_PMI"
// Option C (paid): "ECONOMICS:USPMI"
// Option D (paid): "ISM:MAN_PMI"
// ─────────────────────────────────────────────
pmi_sym   = input.symbol("ECONOMICS:USBCOI", "PMI Symbol (try ECONOMICS:USBCOI)")
pmi_raw   = request.security(pmi_sym, "M", close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
btc_close = request.security("BITSTAMP:BTCUSD", "M", close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// ─────────────────────────────────────────────
// NORMALIZE BTC into PMI scale (40–70)
//   v6: guard the range against na so the ternary condition is a real bool
// ─────────────────────────────────────────────
btc_min  = ta.lowest(btc_close, 500)
btc_max  = ta.highest(btc_close, 500)
range_ok = not na(btc_min) and not na(btc_max) and btc_max != btc_min
btc_norm = range_ok ? 40 + (btc_close - btc_min) / (btc_max - btc_min) * 30 : 55.0

// ─────────────────────────────────────────────
// PMI REGIME CLASSIFICATION
//   v6: booleans can no longer be na, so gate every comparison on has_pmi.
//   When PMI data is missing, all three flags resolve to false (no shading).
// ─────────────────────────────────────────────
has_pmi        = not na(pmi_raw)
is_expansion   = has_pmi and pmi_raw >= 50
is_contraction = has_pmi and pmi_raw < 50
is_strong_bull = has_pmi and pmi_raw >= bull_thresh

// ─────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────
pmi_color    = is_strong_bull ? color.new(#00ff88, 0) : is_expansion ? color.new(#f0a500, 0) : color.new(#ff3355, 0)
regime_color = is_strong_bull ? color.new(#00ff88, 0) : is_expansion ? color.new(#f0a500, 0) : color.new(#ff3355, 0)
btc_bull_col = is_expansion ? color.green : color.red

// ─────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────
plot(pmi_raw,  "ISM PMI",          color=pmi_color,              linewidth=2, style=plot.style_line)
plot(btc_norm, "BTC (normalized)", color=color.new(#f7931a, 50), linewidth=1, style=plot.style_line)

hline(50,          "Expansion/Contraction", color=color.new(color.white, 40), linestyle=hline.style_dashed, linewidth=1)
hline(bull_thresh, "Bull Threshold",        color=color.new(#00ff88, 60),    linestyle=hline.style_dotted, linewidth=1)

// ─────────────────────────────────────────────
// BACKGROUND SHADING
// ─────────────────────────────────────────────
bgcolor(show_shading and is_contraction ? color.new(#ff3355, 85) : na, title="Contraction")
bgcolor(show_shading and is_strong_bull ? color.new(#00ff88, 90) : na, title="Strong Bull")

// ─────────────────────────────────────────────
// TRANSITION LABELS
// ─────────────────────────────────────────────
if ta.crossover(pmi_raw, 50)
    label.new(bar_index, pmi_raw, "PMI > 50\nBull", style=label.style_label_up, color=color.new(#00ff88, 10), textcolor=color.black, size=size.small)

if ta.crossunder(pmi_raw, 50)
    label.new(bar_index, pmi_raw, "PMI < 50\nRisk", style=label.style_label_down, color=color.new(#ff3355, 10), textcolor=color.white, size=size.small)

// ─────────────────────────────────────────────
// INFO TABLE
// ─────────────────────────────────────────────
var table t = table.new(position.top_right, 2, 4, bgcolor=color.new(color.black, 75), border_color=color.new(color.gray, 50), border_width=1, frame_width=1)

regime_txt   = is_strong_bull ? "STRONG EXPANSION" : is_expansion ? "EXPANSION" : "CONTRACTION"
btc_bull_txt = is_expansion ? "YES" : "RISK"

if barstate.islast
    table.cell(t, 0, 0, "ISM PMI",    text_color=color.gray,  text_size=size.small)
    table.cell(t, 1, 0, str.tostring(pmi_raw, "#.#"), text_color=color.white, text_size=size.small)
    table.cell(t, 0, 1, "Regime",     text_color=color.gray,  text_size=size.small)
    table.cell(t, 1, 1, regime_txt,   text_color=regime_color, text_size=size.small)
    table.cell(t, 0, 2, "BTC Bull?",  text_color=color.gray,  text_size=size.small)
    table.cell(t, 1, 2, btc_bull_txt, text_color=btc_bull_col, text_size=size.small)
    table.cell(t, 0, 3, "BTC Price",  text_color=color.gray,  text_size=size.small)
    table.cell(t, 1, 3, "$" + str.tostring(btc_close, "#,###"), text_color=color.new(#f7931a, 0), text_size=size.small)
````
