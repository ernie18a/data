# Composite Breadth Score

- url: https://www.tradingview.com/script/p4NAkswD-Composite-Breadth-Score/
- type: indicator
- pine_id: PUB;876501f323f74289b64f37935d365874
- version: 1.0

## Description

█ [b]OVERVIEW[/b]

Composite Breadth Score (CBS) condenses three independent measures of market breadth into a single normalized 0-100 reading, giving you one line that answers the question: how healthy is market participation right now? The three components are participation breadth (percentage of stocks above their 200-day moving average), momentum breadth (McClellan Summation Index, percentile-ranked), and leadership breadth (ratio of new 52-week highs to total new highs plus new lows).

When all three dimensions confirm each other, the composite score pushes toward extremes. When they diverge, the score compresses toward the midline, surfacing deterioration that single-indicator approaches can miss.


█ [b]CONCEPTS[/b]

[b]Why three dimensions?[/b]
A market can rise on narrowing participation (a few mega-caps dragging an index higher while most stocks lag). It can also rise with broad participation but deteriorating momentum, or with strong momentum but collapsing leadership. Each failure mode shows up in a different breadth measure. CBS fuses all three so you do not have to watch three separate panes.

[b]Component definitions[/b]

1 — [i]Participation[/i]: the percentage of S&P 500 constituents trading above their 200-day moving average. This is sourced from `S5TH` (primary) or `MMTH` (fallback). Already scaled 0-100. Measures how many stocks are in long-term uptrends.

2 — [i]Momentum[/i]: the McClellan Summation Index, computed as the running cumulative total of the McClellan Oscillator (19/39-period EMA differential of NYSE advancing minus declining issues). Because the Summation Index has no fixed range, it is normalized to 0-100 via percentile rank over a configurable lookback (default 252 bars, roughly one year of daily data).

3 — [i]Leadership[/i]: new 52-week highs divided by the sum of new highs and new lows, multiplied by 100. When this reads above 50, new highs dominate; below 50, new lows dominate. Captures whether the market's leading edge is expanding or contracting.

[b]Composite calculation[/b]
Each component is weighted (default equal at 33.3% each) and combined into a single score. Weights are user-adjustable. If the participation symbol is unavailable on your data feed, the indicator automatically reweights using only the two remaining components.


█ [b]HOW TO USE[/b]

[b]Reading the score[/b]
• Above 75: all three breadth dimensions are strong. Market internals confirm the trend. Historically associated with broad, durable rallies, though sustained readings above 75 can precede mean-reversion pullbacks.
• 50 midline: the dividing line between net-positive and net-negative breadth. Crossovers and crossunders of 50 are the most actionable signals for trend direction.
• Below 25: breadth is weak across all three dimensions. Market internals are not supporting price. Common during corrections, bear markets, or the exhaustion phase of a rally.

[b]Divergence analysis[/b]
The most valuable use case is divergence: the price index (S&P 500, for example) makes a new high while CBS makes a lower high. This indicates narrowing participation, fading momentum, or deteriorating leadership, often well before price reverses.

Toggle [i]Show Individual Components[/i] in the indicator settings to overlay all three normalized streams. This lets you identify which dimension is diverging.

[b]Trend confirmation[/b]
CBS crossing above 50 from below, particularly when all three components are rising, is a broad confirmation signal. The inverse (crossing below 50 with all three falling) confirms deterioration.


█ [b]FEATURES[/b]

• Fully configurable component weights, allowing you to emphasize whichever breadth dimension matters most to your approach.
• Adjustable McClellan EMA periods (default 19/39) and Summation Index percentile lookback (default 252).
• Configurable overbought, oversold, and participation warning thresholds.
• All data symbols exposed as inputs so you can substitute alternative advancing/declining or new high/new low feeds.
• Status table in the top-right corner showing current values and color-coded health for each component at a glance.
• Nine built-in alert conditions:
 — Composite crossing above/below overbought, oversold, and midline levels
 — McClellan Summation crossing above/below zero
 — New Highs/New Lows ratio flipping bullish or bearish
 — Participation dropping below the warning threshold


█ [b]LIMITATIONS[/b]

• The McClellan Summation normalization uses percentile rank, which requires the full lookback period (default 252 bars) of data history to stabilize. Values during the initial warm-up period are unreliable.
• Participation data depends on `S5TH` or `MMTH` being available on your TradingView data plan. If neither resolves, the indicator degrades gracefully to a two-component composite and marks participation as "N/A" in the status table.
• The indicator is designed for daily timeframes on US equity indices. Using it on intraday charts or non-US markets will produce results based on whatever the underlying NYSE/S&P symbols report on that timeframe, which may not be meaningful.
• New highs and new lows data reflects NYSE-listed issues, which includes ETFs, preferreds, and closed-end funds. This is the standard feed; common-stock-only filtering is not available via these symbols.


█ [b]NOTES[/b]

The default equal weighting (33.3/33.3/33.3) treats all three breadth dimensions as equally important. You may find that adjusting weights improves the signal for your specific use case. For example, weighting participation more heavily produces a score that better captures structural regime shifts, while weighting leadership more heavily makes the score more sensitive to short-term rotations.

The indicator can be applied to any chart symbol. All data is pulled from fixed external symbols regardless of what chart you are viewing.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
// © Composite Breadth Indicator

//@version=6
indicator("Composite Breadth Score", shorttitle="CBS", overlay=false, precision=1)

// ─── INPUTS ───────────────────────────────────────────────────────────────────

// Weights
g_weights     = "Component Weights"
w_part        = input.float(33.3, "Participation Weight (%)", minval=0, maxval=100, group=g_weights)
w_momentum    = input.float(33.3, "Momentum Weight (%)", minval=0, maxval=100, group=g_weights)
w_leadership  = input.float(33.3, "Leadership Weight (%)", minval=0, maxval=100, group=g_weights)

// McClellan
g_mcclellan   = "McClellan Settings"
mc_fast       = input.int(19, "Fast EMA Period", minval=1, group=g_mcclellan)
mc_slow       = input.int(39, "Slow EMA Period", minval=1, group=g_mcclellan)
mc_rank_len   = input.int(252, "Summation Percentile Lookback", minval=50, group=g_mcclellan)

// Thresholds
g_thresh      = "Thresholds"
ob_level      = input.float(75, "Overbought Level", group=g_thresh)
os_level      = input.float(25, "Oversold Level", group=g_thresh)
part_warn     = input.float(40, "Participation Warning Level (%)", group=g_thresh)

// Display
g_display     = "Display"
show_components = input.bool(false, "Show Individual Components", group=g_display)

// Symbols
g_symbols     = "Data Symbols"
sym_part_1    = input.string("S5TH", "Participation Symbol (primary)", group=g_symbols)
sym_part_2    = input.string("MMTH", "Participation Symbol (fallback)", group=g_symbols)
sym_adv       = input.string("USI:ADVN.NY", "Advancing Issues", group=g_symbols)
sym_dec       = input.string("USI:DECL.NY", "Declining Issues", group=g_symbols)
sym_hi        = input.string("USI:HIGN.NY", "New Highs", group=g_symbols)
sym_lo        = input.string("USI:LOWN.NY", "New Lows", group=g_symbols)


// ─── DATA RETRIEVAL ───────────────────────────────────────────────────────────

// Participation: % of stocks above 200-day MA (already 0-100)
raw_part_1 = request.security(sym_part_1, timeframe.period, close, ignore_invalid_symbol=true)
raw_part_2 = request.security(sym_part_2, timeframe.period, close, ignore_invalid_symbol=true)

part_available_1 = not na(raw_part_1)
part_available_2 = not na(raw_part_2)
participation = part_available_1 ? raw_part_1 : part_available_2 ? raw_part_2 : na

// Advancing / Declining issues for McClellan
advances = request.security(sym_adv, timeframe.period, close, ignore_invalid_symbol=true)
declines = request.security(sym_dec, timeframe.period, close, ignore_invalid_symbol=true)

// New Highs / New Lows
new_highs = request.security(sym_hi, timeframe.period, close, ignore_invalid_symbol=true)
new_lows  = request.security(sym_lo, timeframe.period, close, ignore_invalid_symbol=true)


// ─── McCLELLAN OSCILLATOR & SUMMATION INDEX ──────────────────────────────────

ad_diff      = nz(advances) - nz(declines)
ema_fast     = ta.ema(ad_diff, mc_fast)
ema_slow     = ta.ema(ad_diff, mc_slow)
mcclellan_osc = ema_fast - ema_slow

// Summation Index: cumulative McClellan Oscillator
var float mc_summation = 0.0
mc_summation += nz(mcclellan_osc)

// Normalize via percentile rank over lookback
mc_norm = ta.percentrank(mc_summation, mc_rank_len)


// ─── NEW HIGHS / NEW LOWS NORMALIZATION ──────────────────────────────────────

nh = nz(new_highs)
nl = nz(new_lows)
nh_nl_total = nh + nl
leadership = nh_nl_total > 0 ? (nh / nh_nl_total) * 100 : 50.0


// ─── COMPOSITE SCORE ─────────────────────────────────────────────────────────

total_weight = w_part + w_momentum + w_leadership
safe_total   = total_weight > 0 ? total_weight : 100.0

composite = na(participation)
     ? (nz(mc_norm) * w_momentum + nz(leadership) * w_leadership) / (w_momentum + w_leadership)
     : (nz(participation) * w_part + nz(mc_norm) * w_momentum + nz(leadership) * w_leadership) / safe_total


// ─── PLOTTING ────────────────────────────────────────────────────────────────

// Composite
comp_color = composite >= ob_level ? color.new(color.green, 20) :
     composite <= os_level ? color.new(color.red, 20) :
     color.new(color.blue, 20)
plot(composite, "Composite Breadth Score", color=comp_color, linewidth=2)

// Reference lines
h_ob = hline(ob_level, "Overbought", color=color.new(color.green, 60), linestyle=hline.style_dashed)
h_mid = hline(50, "Midline", color=color.new(color.gray, 60), linestyle=hline.style_dotted)
h_os = hline(os_level, "Oversold", color=color.new(color.red, 60), linestyle=hline.style_dashed)
fill(h_ob, h_os, color=color.new(color.gray, 92))

// Optional component plots
plot(show_components ? participation : na, "Participation (% > 200MA)", color=color.new(color.teal, 40), linewidth=1)
plot(show_components ? mc_norm : na, "McClellan Summation (Normalized)", color=color.new(color.orange, 40), linewidth=1)
plot(show_components ? leadership : na, "Leadership (NH/NL Ratio)", color=color.new(color.purple, 40), linewidth=1)


// ─── DATA STATUS TABLE ──────────────────────────────────────────────────────

var table status_tbl = table.new(position.top_right, 2, 4, bgcolor=color.new(color.black, 80), border_width=1)
if barstate.islast
    table.cell(status_tbl, 0, 0, "Component", text_color=color.white, text_size=size.small)
    table.cell(status_tbl, 1, 0, "Value", text_color=color.white, text_size=size.small)

    part_str = na(participation) ? "N/A" : str.tostring(participation, "#.0")
    part_clr = na(participation) ? color.gray : participation < part_warn ? color.red : color.green
    table.cell(status_tbl, 0, 1, "Participation", text_color=part_clr, text_size=size.small)
    table.cell(status_tbl, 1, 1, part_str, text_color=part_clr, text_size=size.small)

    mc_str = str.tostring(mc_norm, "#.0")
    mc_clr = mc_norm < 30 ? color.red : mc_norm > 70 ? color.green : color.yellow
    table.cell(status_tbl, 0, 2, "Momentum", text_color=mc_clr, text_size=size.small)
    table.cell(status_tbl, 1, 2, mc_str, text_color=mc_clr, text_size=size.small)

    ld_str = str.tostring(leadership, "#.0")
    ld_clr = leadership < 30 ? color.red : leadership > 70 ? color.green : color.yellow
    table.cell(status_tbl, 0, 3, "Leadership", text_color=ld_clr, text_size=size.small)
    table.cell(status_tbl, 1, 3, ld_str, text_color=ld_clr, text_size=size.small)


// ─── ALERTS ──────────────────────────────────────────────────────────────────

// Composite threshold crosses
alertcondition(ta.crossover(composite, ob_level), "CBS Overbought Cross", "Composite Breadth Score crossed above overbought level")
alertcondition(ta.crossunder(composite, os_level), "CBS Oversold Cross", "Composite Breadth Score crossed below oversold level")
alertcondition(ta.crossover(composite, 50), "CBS Bullish Cross", "Composite Breadth Score crossed above 50 (midline)")
alertcondition(ta.crossunder(composite, 50), "CBS Bearish Cross", "Composite Breadth Score crossed below 50 (midline)")

// McClellan Summation zero cross
alertcondition(ta.crossover(mc_summation, 0), "McClellan Summation Bullish", "McClellan Summation Index crossed above zero")
alertcondition(ta.crossunder(mc_summation, 0), "McClellan Summation Bearish", "McClellan Summation Index crossed below zero")

// New Highs / New Lows flip
alertcondition(ta.crossunder(leadership, 50), "NH-NL Bearish Flip", "New Lows now exceed New Highs")
alertcondition(ta.crossover(leadership, 50), "NH-NL Bullish Flip", "New Highs now exceed New Lows")

// Participation warning
alertcondition(ta.crossunder(participation, part_warn), "Participation Warning", "% above 200-day MA dropped below warning threshold")
````
