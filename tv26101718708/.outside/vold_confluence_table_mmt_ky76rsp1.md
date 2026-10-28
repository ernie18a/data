# VOLD Confluence Table [MMT]

- url: https://www.tradingview.com/script/Ky76RSP1-VOLD-Confluence-Table-MMT/
- type: indicator
- pine_id: PUB;e6be5b49613b450cac33f7ec1e4aa69b
- version: 1.0

## Description

[b]VOLD Confluence Table [MMT][/b] is a compact market-internals dashboard that overlays directly on your main chart and summarizes VOLD, ADD, and TICK into a single, tradeable bias signal and day-type read.

[b]What this indicator shows[/b]

[list]
[*][b]VOLD [/b]: measures whether volume is flowing into advancing or declining stocks on the exchange, giving you the “horsepower” behind the move.
[*][b]ADD[/b]: tracks how many stocks are advancing vs declining, giving a breadth read on participation.
[*][b]TICK[/b]: looks at how many stocks are ticking up vs ticking down right now, acting as a very short-term sentiment and momentum gauge.
[/list]

All three are pulled into a 3‑column table (Label / Value / Signal) plus rows for VOLD trend vs SMA, day type (Trend / Chop / Responsive), and an overall bias + 0–6 confluence score.

[b]Core logic and signals[/b]
[list]
[*]Bull/bear scores are built from six binary conditions each (VOLD sign, strong VOLD, ADD sign, strong ADD, TICK sign, TICK momentum levels). When 5+ of the bull (or bear) conditions align, the indicator flags a potential “Trend Day” in that direction; 4 gives “High Confidence” bias, while low scores on both sides classify the session as “Chop.”
[*]A [b]VOLD SMA filter[/b] on a higher timeframe (default 5‑min) labels whether VOLD is ABOVE or BELOW its SMA and applies a “freight train” rule: strong expanding VOLD above SMA triggers “🚂 NO SHORT,” strong contracting VOLD below SMA triggers “🚂 NO LONG,” discouraging fades against a powerful breadth/volume trend.
[*]Divergence logic highlights when ADD and VOLD disagree (e.g., ADD bullish while VOLD is negative), which often signals distribution/absorption or unstable internals; these are labeled as divergence with a caution bias.
[/list]

[b]How to use it intraday[/b]

[b]Pre-session / first 30–60 minutes[/b]

[list]
[*]Watch the BIAS row and score: a quick push to 4–6 on one side with “✦ TREND” TYPE suggests you lean with that side for the day (buy pullbacks in bull trend, sell bounces in bear trend).
[*]Check the SMA row: “🚂 NO SHORT” or “🚂 NO LONG” means avoid fading the index just because it feels extended; treat counter‑trend scalp ideas as lower probability.
[/list]


[b]During the session[/b]
Use the TYPE row:

[list]
[*]“✦ TREND” → favor continuation setups, avoid fighting the dominant side.
[*]“✕ CHOP” → stand down on trend assumptions, consider mean‑reversion or smaller size.
[*]“◈ RESPONSIVE” → market is two‑sided; treat both extremes carefully and rely more on local structure.
[/list]

Watch VOLD Δ (EXPANDING / CONTRACTING / FLAT) to confirm whether a move in your index is being reinforced by broad volume or starting to lose pressure.

[b]Risk and filter use-cases[/b]

[list]
[*]Use “Chop Detected” / low confluence as a filter to reduce size or skip marginal setups when internals show no clear edge.
[*]Use divergence alerts (ADD vs VOLD) as a reason to tighten risk or take partials if you are heavily positioned and internals stop agreeing with the move.
[/list]

SMA Filter:

[list]
[*]VOLD SMA Length (default 10)
[*]VOLD SMA Timeframe (default 5‑minute)
[*]Shorter lengths or timeframes make the freight-train bias more reactive; longer settings smooth out noise.
[/list]

Alerts
The script includes alert conditions for key regime shifts so you do not have to stare at the table all day:

[list]
[*]Trend Day Bull / Bear (score ≥ 5)
[*]VOLD crossing above/below its SMA (freight train flips)
[*]ADD/VOLD divergence
[*]Chop detected (no edge)
[/list]

These can be tied to popups, sounds, or webhooks so your automation or discretionary workflow can react when internals meaningfully change state.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © TylerNguyen | VOLD Compact Table v5.2
// overlay=true — sits on main price chart

//@version=6
indicator('VOLD Confluence Table [MMT]', shorttitle = 'VOLD✦', overlay = true)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
grp_src = 'Data Sources'
vold_src = input.symbol('USI:VOLD', 'VOLD Symbol', group = grp_src)
add_src = input.symbol('USI:ADD', 'ADD Symbol', group = grp_src)
tick_src = input.symbol('USI:TICK', 'TICK Symbol', group = grp_src)

grp_sma = 'SMA Filter'
vold_sma_len = input.int(10, 'VOLD SMA Length', group = grp_sma, minval = 1)
sma_tf = input.timeframe('5', 'VOLD SMA Timeframe', group = grp_sma)

grp_thresh = 'Thresholds'
vold_strong = input.float(500, 'VOLD Strong Level', group = grp_thresh, step = 100)
add_strong = input.float(1000, 'ADD Strong Level', group = grp_thresh, step = 100)
tick_warn = input.float(500, 'TICK Warn Level', group = grp_thresh, step = 50)
tick_extreme = input.float(800, 'TICK Extreme Level', group = grp_thresh, step = 50)

grp_vis = 'Table'
tbl_pos = input.string('Top Right', 'Position', options = ['Top Right', 'Top Left', 'Bottom Right', 'Bottom Left'], group = grp_vis)
tbl_size = input.string('Small', 'Text Size', options = ['Small', 'Normal', 'Tiny'], group = grp_vis)

// ─────────────────────────────────────────────
// DATA
// ─────────────────────────────────────────────
vold_close = request.security(vold_src, sma_tf, close, gaps = barmerge.gaps_off)
add_close = request.security(add_src, timeframe.period, close, gaps = barmerge.gaps_off)
tick_close = request.security(tick_src, timeframe.period, close, gaps = barmerge.gaps_off)

// ─────────────────────────────────────────────
// SMA + FREIGHT TRAIN
// ─────────────────────────────────────────────
vold_sma = ta.sma(vold_close, vold_sma_len)
vold_above_sma = vold_close > vold_sma
vold_expanding = vold_close > vold_close[1]
vold_contracting = vold_close < vold_close[1]
freight_bull = vold_above_sma and vold_expanding and vold_close > vold_strong
freight_bear = not vold_above_sma and vold_contracting and vold_close < -vold_strong

vold_sma_cross_up = ta.crossover(vold_close, vold_sma)
vold_sma_cross_dn = ta.crossunder(vold_close, vold_sma)

// ─────────────────────────────────────────────
// CONFLUENCE SCORE
// ─────────────────────────────────────────────
vold_bull = vold_close > 0
vold_bear = vold_close < 0
vold_strong_up = vold_close > vold_strong
vold_strong_dn = vold_close < -vold_strong
add_bull = add_close > 0
add_strong_up = add_close > add_strong
add_strong_dn = add_close < -add_strong
tick_bull = tick_close > 0
tick_warn_up = tick_close > tick_warn
tick_warn_dn = tick_close < -tick_warn
tick_extreme_up = tick_close > tick_extreme
tick_extreme_dn = tick_close < -tick_extreme

bull_score = (vold_bull ? 1 : 0) + (vold_strong_up ? 1 : 0) + (add_bull ? 1 : 0) + (add_strong_up ? 1 : 0) + (tick_bull ? 1 : 0) + (tick_warn_up ? 1 : 0)
bear_score = (vold_bear ? 1 : 0) + (vold_strong_dn ? 1 : 0) + (not add_bull ? 1 : 0) + (add_strong_dn ? 1 : 0) + (not tick_bull ? 1 : 0) + (tick_warn_dn ? 1 : 0)

trend_day_bull = bull_score >= 5
trend_day_bear = bear_score >= 5
high_conf_bull = bull_score == 4
high_conf_bear = bear_score == 4
mixed = bull_score < 3 and bear_score < 3
divergence_up = add_bull and vold_bear
divergence_dn = not add_bull and vold_bull

// ─────────────────────────────────────────────
// LABEL HELPERS
// ─────────────────────────────────────────────
txt_size = tbl_size == 'Normal' ? size.normal : tbl_size == 'Tiny' ? size.tiny : size.small

tbl_position = tbl_pos == 'Top Right' ? position.top_right : tbl_pos == 'Top Left' ? position.top_left : tbl_pos == 'Bottom Right' ? position.bottom_right : position.bottom_left

// VOLD
vold_lbl = vold_strong_up ? '▲ STRONG' : vold_strong_dn ? '▼ STRONG' : vold_bull ? '▲' : vold_bear ? '▼' : '→'
vold_col = vold_strong_up ? color.new(#00e5ff, 0) : vold_strong_dn ? color.new(#ff5252, 0) : vold_bull ? color.new(color.teal, 15) : vold_bear ? color.new(color.red, 15) : color.gray

// ADD
add_lbl = add_strong_up ? '▲ STRONG' : add_strong_dn ? '▼ STRONG' : add_bull ? '▲' : '▼'
add_col = add_strong_up ? color.new(#00e5ff, 0) : add_strong_dn ? color.new(#ff5252, 0) : add_bull ? color.new(color.teal, 15) : color.new(color.red, 15)

// TICK
tick_lbl = tick_extreme_up ? '▲ EXTREME' : tick_extreme_dn ? '▼ EXTREME' : tick_warn_up ? '▲ MOM' : tick_warn_dn ? '▼ MOM' : tick_bull ? '▲' : '▼'
tick_col = tick_extreme_up ? color.new(#00e5ff, 0) : tick_extreme_dn ? color.new(#ff5252, 0) : tick_warn_up ? color.new(color.teal, 15) : tick_warn_dn ? color.new(color.red, 15) : color.gray

// SMA — VAL is now ABOVE / BELOW, SIG is the freight train rule
sma_val_lbl = vold_above_sma ? 'ABOVE' : 'BELOW'
sma_val_col = vold_above_sma ? color.new(#00e5ff, 0) : color.new(#ff5252, 0)
freight_lbl = freight_bull ? '🚂 NO SHORT' : freight_bear ? '🚂 NO LONG' : vold_above_sma ? '↑ BIAS LONG' : '↓ BIAS SHORT'
freight_col = freight_bull ? color.new(#00e5ff, 0) : freight_bear ? color.new(#ff5252, 0) : vold_above_sma ? color.new(color.teal, 10) : color.new(color.red, 10)

// TYPE
type_lbl = trend_day_bull or trend_day_bear ? '✦ TREND' : mixed ? '✕ CHOP' : '◈ RESPONSIVE'
type_col = trend_day_bull ? color.new(#00e5ff, 0) : trend_day_bear ? color.new(#ff5252, 0) : mixed ? color.new(color.gray, 30) : color.silver

// VOLD Δ
delta_lbl = vold_expanding ? '↗ EXPANDING' : vold_contracting ? '↘ CONTRACTING' : '→ FLAT'
delta_col = vold_expanding and vold_bull ? color.new(color.teal, 10) : vold_expanding and vold_bear ? color.new(color.red, 10) : vold_contracting ? color.new(#ff5252, 30) : color.gray

// BIAS + Score
bias_lbl = trend_day_bull ? '🟢 TREND BULL  ' + str.tostring(bull_score) + '/6' : trend_day_bear ? '🔴 TREND BEAR  ' + str.tostring(bear_score) + '/6' : high_conf_bull ? '🟡 HI CONF BULL ' + str.tostring(bull_score) + '/6' : high_conf_bear ? '🟡 HI CONF BEAR ' + str.tostring(bear_score) + '/6' : divergence_up ? '⚠ DIV ↑  ' + str.tostring(bull_score) + '/6' : divergence_dn ? '⚠ DIV ↓  ' + str.tostring(bear_score) + '/6' : mixed ? '⬜ CHOP' : '─ NEUTRAL'
bias_col = trend_day_bull ? color.new(#00e5ff, 0) : trend_day_bear ? color.new(#ff5252, 0) : high_conf_bull or high_conf_bear ? color.yellow : divergence_up or divergence_dn ? color.orange : color.gray

// ─────────────────────────────────────────────
// TABLE — 8 rows
// ─────────────────────────────────────────────
if barstate.islast
    var tbl = table.new(tbl_position, 3, 8, bgcolor = color.new(#0a0a12, 10), border_color = color.new(color.white, 78), border_width = 1, frame_color = color.new(color.white, 55), frame_width = 1)

    // Header
    table.cell(tbl, 0, 0, '', bgcolor = color.new(#16213e, 5), text_size = txt_size)
    table.cell(tbl, 1, 0, 'VAL', text_color = color.new(color.white, 25), bgcolor = color.new(#16213e, 5), text_size = txt_size)
    table.cell(tbl, 2, 0, 'SIG', text_color = color.new(color.white, 25), bgcolor = color.new(#16213e, 5), text_size = txt_size)

    // Row 1 — VOLD
    table.cell(tbl, 0, 1, 'VOLD', text_color = color.silver, text_size = txt_size, text_halign = text.align_left)
    table.cell(tbl, 1, 1, str.tostring(vold_close, '#,###'), text_color = vold_col, text_size = txt_size)
    table.cell(tbl, 2, 1, vold_lbl, text_color = vold_col, text_size = txt_size)

    // Row 2 — ADD
    table.cell(tbl, 0, 2, 'ADD', text_color = color.silver, text_size = txt_size, text_halign = text.align_left)
    table.cell(tbl, 1, 2, str.tostring(add_close, '#,###'), text_color = add_col, text_size = txt_size)
    table.cell(tbl, 2, 2, add_lbl, text_color = add_col, text_size = txt_size)

    // Row 3 — TICK
    table.cell(tbl, 0, 3, 'TICK', text_color = color.silver, text_size = txt_size, text_halign = text.align_left)
    table.cell(tbl, 1, 3, str.tostring(tick_close, '#,###'), text_color = tick_col, text_size = txt_size)
    table.cell(tbl, 2, 3, tick_lbl, text_color = tick_col, text_size = txt_size)

    // Row 4 — SMA Freight Train
    table.cell(tbl, 0, 4, 'SMA(' + str.tostring(vold_sma_len) + ')', text_color = color.silver, text_size = txt_size, text_halign = text.align_left)
    table.cell(tbl, 1, 4, sma_val_lbl, text_color = sma_val_col, text_size = txt_size)
    table.cell(tbl, 2, 4, freight_lbl, text_color = freight_col, text_size = txt_size)

    // Row 5 — VOLD Δ
    table.cell(tbl, 0, 5, 'VOLD Δ', text_color = color.silver, text_size = txt_size, text_halign = text.align_left)
    table.cell(tbl, 1, 5, delta_lbl, text_color = delta_col, text_size = txt_size)
    table.cell(tbl, 2, 5, '', text_size = txt_size)

    // Row 6 — TYPE
    table.cell(tbl, 0, 6, 'TYPE', text_color = color.silver, text_size = txt_size, text_halign = text.align_left)
    table.cell(tbl, 1, 6, type_lbl, text_color = type_col, text_size = txt_size)
    table.cell(tbl, 2, 6, '', text_size = txt_size)

    // Row 7 — BIAS + Score
    table.cell(tbl, 0, 7, 'BIAS', text_color = color.silver, text_size = txt_size, text_halign = text.align_left)
    table.cell(tbl, 1, 7, bias_lbl, text_color = bias_col, text_size = txt_size)
    table.cell(tbl, 2, 7, '', text_size = txt_size)


// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────
alertcondition(trend_day_bull, 'Trend Day BULL', 'VOLD: Trend Day BULL — Score 5+')
alertcondition(trend_day_bear, 'Trend Day BEAR', 'VOLD: Trend Day BEAR — Score 5+')
alertcondition(vold_sma_cross_up, 'VOLD Reclaimed SMA', 'VOLD crossed ABOVE SMA — freight train flipped bull')
alertcondition(vold_sma_cross_dn, 'VOLD Lost SMA', 'VOLD crossed BELOW SMA — freight train flipped bear')
alertcondition(divergence_up or divergence_dn, 'ADD/VOLD Divergence', 'VOLD: ADD and VOLD disagreeing — reduce size')
alertcondition(mixed, 'Chop Detected', 'VOLD: No edge — stand down')
````
