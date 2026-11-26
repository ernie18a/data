# MTF Support / Resistance Channels

- url: https://www.tradingview.com/script/cNhHt6hZ-MTF-Support-Resistance-Channels/
- type: indicator
- pine_id: PUB;e7af944e03e64918bf65ce37a3778d6c
- version: 1.0

## Description

[b]MTF Support / Resistance Channels[/b]

Filled support and resistance zones built from confirmed pivots across up to three user-selected timeframes, plotted on the chart. Channel thickness is ATR-derived, so zones scale automatically with volatility — no fiddling with absolute pip/dollar widths when you switch instruments. A proximity filter hides distant zones to keep things readable.
The point is to put hourly, daily, and weekly structure on a single chart without stacking three windows or losing context every time you change zoom.

[b]How it works[/b]

For each of the three configured timeframes, the script runs a pivot detector inside request.security (with lookahead_off, so no future-data leak) and stores the most recent N confirmed pivot highs and lows. Each pivot becomes a horizontal channel centered on the pivot price, with half-width = ATR × multiplier computed on the chart's own timeframe. The proximity filter compares each pivot to current close and hides anything more than X% away.
All drawing objects are rebuilt on the last bar so zone widths stay current with the latest ATR reading.

[b]How to read it[/b]

Each timeframe has its own color (defaults: teal for TF1, amber for TF2, purple for TF3). The filled bands are the zones themselves. Labels at the right edge mark the timeframe, whether it's support or resistance, and the exact pivot price.
The most useful signal isn't any individual zone — it's confluence. When a TF1 zone overlaps with a TF2 or TF3 zone, you have multiple timeframes pointing at the same price area, which tends to matter more than any single level on its own.

[b]Inputs[/b]
[list]
[*]Timeframes 1/2/3 — the three higher timeframes to source pivots from. Defaults: 1H, Daily, Weekly. Choose timeframes higher than your chart timeframe.
[*]Pivot Lookback — bars required on each side to confirm a pivot. 2 captures most meaningful swings; 4–5 restricts to major structural pivots only. Default 2.
[*]Zones per direction per TF — how many of the most recent pivots to keep per timeframe per direction. 1 = freshest level only; 3–5 for historical structure; up to 15 for deep multi-level context. Default 1.
[*]Display toggles — turn off resistance, support, or any individual timeframe.
[*]Proximity filter — hide zones further than X% from current close. Default on, 20%.
[*]ATR Length / Multiplier — controls channel half-width. Defaults 14 / 0.3. Increase the multiplier on volatile instruments; decrease on smooth ones.
[*]Colors — one per timeframe.
[/list]

[b]Built-in alerts[/b]
A pivot-confirmation alert is available for each timeframe and direction (six total):
[list]
[*]New TF1 / TF2 / TF3 Resistance Pivot — fires when a new pivot high is confirmed on that timeframe
[*]New TF1 / TF2 / TF3 Support Pivot — fires when a new pivot low is confirmed on that timeframe
[/list]
Each one signals that the projected zone set has been updated with a fresh reference level.

[b]Notes[/b]
Higher-timeframe pivots don't confirm until pivot lookback bars after the actual high or low. On a weekly timeframe with lookback 2, that's two weeks of delay. This is by design — you're getting confirmed structural levels, not real-time fractals — but it's worth keeping in mind when the chart shows a level that visually looks "late."
Pair the pivot lookback with how you intend to use the zones. Lookback 2 with N=3 zones gives you a recent structural map suitable for swing context. Lookback 4 with N=1 gives you only the major levels — less clutter, more meaning per zone.
The ATR multiplier matters more than people expect. 0.3 of a 14-period ATR is a sensible starting point, but a forex pair and a small-cap stock will need very different settings before the bands look right against actual price respect.
This is a structural tool, not a signal generator. It marks where price has historically rejected on multiple horizons.

[i]Five years of work on a trading system left me with dozens of indicators that ultimately didn't earn a place in the final build. They're not failures — they're tools that solved problems I no longer needed solved. So instead of shelving them, I'm publishing the majority of them open-source.
If you're a discretionary trader, take what's useful. If you're a systems builder, the source is yours to dissect, modify, and improve. The best return on five years of work is for it to keep working — for someone.
If you use this script — or part of it — in your own work, please credit the original with a link back to my profile.
Note: these indicators have been updated to Pine Script v6 — some manually, some with AI assistance.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradeSymbiotic
// If you are using (part of) this PineScript - please give credits with tag.

// ─────────────────────────────────────────────────────────────────────────────
//                  MTF Support / Resistance Channels
//                  ─────────────────────────────────────
//   Filled channel zones built from the most recent confirmed pivot highs
//   and lows across up to three user-selected timeframes. Channel half-width
//   is ATR-derived so zone thickness scales automatically with volatility.
//
//   Stack Hourly, Daily, and Weekly S/R zones on any intraday or swing chart.
//   A proximity filter hides distant zones automatically, keeping the chart
//   uncluttered while preserving the levels that actually matter right now.
//
//   Version: 1.0
// ─────────────────────────────────────────────────────────────────────────────

//@version=6
indicator("MTF Support / Resistance Channels", shorttitle="MTF·SR", overlay=true, max_lines_count=500, max_labels_count=500, max_bars_back=500)

// ── Inputs ───────────────────────────────────────────────────────────────────
tf1      = input.timeframe("60", "Timeframe 1", group="Timeframes", tooltip="First higher timeframe. Default: 1 Hour. On a 5–15 min chart, this layers in the key intraday S/R levels.")
tf2      = input.timeframe("D",  "Timeframe 2", group="Timeframes", tooltip="Second higher timeframe. Default: Daily.")
tf3      = input.timeframe("W",  "Timeframe 3", group="Timeframes", tooltip="Third higher timeframe. Default: Weekly.")

piv_len  = input.int(2,   "Pivot Lookback (bars each side)", minval=1, maxval=5, group="Pivots", tooltip="Bars required on each side of a pivot to confirm it on the higher timeframe. 2 captures most meaningful swings; 4–5 restricts to major structural pivots only.")
n_pivots = input.int(1,   "Zones Per Direction Per TF",      minval=1, maxval=15, group="Pivots", tooltip="How many of the most recent resistance (highs) and support (lows) pivots to show per timeframe. 1 = only the freshest level. Increase to 3–5 to see historical structure; up to 15 for deep multi-level context.")

show_res = input.bool(true, "Show Resistance Zones (pivot highs)", group="Display")
show_sup = input.bool(true, "Show Support Zones (pivot lows)", group="Display")
show_tf1 = input.bool(true, "Show TF1 Zones", group="Display")
show_tf2 = input.bool(true, "Show TF2 Zones", group="Display")
show_tf3 = input.bool(true, "Show TF3 Zones", group="Display")

use_prox = input.bool(true,  "Proximity Filter", group="Filter", tooltip="Hide zones further than the specified distance from the current close. Keeps the chart readable without losing the levels that matter.")
prox_pct = input.float(20.0, "Max Distance from Close (%)",  minval=0.5, maxval=30.0, step=0.5, group="Filter", tooltip="A zone whose pivot is more than this percentage away from the current close is hidden.")

atr_len  = input.int(14,    "ATR Length",     minval=1,              group="Channel Width", tooltip="ATR period used to compute channel half-width. Shorter periods react faster to volatility changes.")
atr_mult = input.float(0.3, "ATR Multiplier", minval=0.05, maxval=3.0, step=0.05, group="Channel Width", tooltip="Half-width = ATR × multiplier. Increase on volatile instruments; decrease on smooth ones.")

col1     = input.color(#26a69a, "TF1 Color", group="Visuals")
col2     = input.color(#ff9800, "TF2 Color", group="Visuals")
col3     = input.color(#7c4dff, "TF3 Color", group="Visuals")

// ── Higher-timeframe pivot detection ─────────────────────────────────────────
//    ta.pivothigh/pivotlow run inside request.security in the HTF context.
//    They return a non-na price only on the bar where a pivot is confirmed.
//    lookahead_off prevents future candle data from bleeding into history.
tf1_ph = request.security(syminfo.tickerid, tf1, ta.pivothigh(piv_len, piv_len), lookahead=barmerge.lookahead_off)
tf1_pl = request.security(syminfo.tickerid, tf1, ta.pivotlow( piv_len, piv_len), lookahead=barmerge.lookahead_off)
tf2_ph = request.security(syminfo.tickerid, tf2, ta.pivothigh(piv_len, piv_len), lookahead=barmerge.lookahead_off)
tf2_pl = request.security(syminfo.tickerid, tf2, ta.pivotlow( piv_len, piv_len), lookahead=barmerge.lookahead_off)
tf3_ph = request.security(syminfo.tickerid, tf3, ta.pivothigh(piv_len, piv_len), lookahead=barmerge.lookahead_off)
tf3_pl = request.security(syminfo.tickerid, tf3, ta.pivotlow( piv_len, piv_len), lookahead=barmerge.lookahead_off)

// ── Pivot history ─────────────────────────────────────────────────────────────
//    Accumulate the N most recently confirmed pivots per TF in var arrays.
//    Index 0 is always the most recent. Each array is capped at n_pivots.
var float[] ph1 = array.new_float(0)
var float[] pl1 = array.new_float(0)
var float[] ph2 = array.new_float(0)
var float[] pl2 = array.new_float(0)
var float[] ph3 = array.new_float(0)
var float[] pl3 = array.new_float(0)

f_push(arr, val, max_n) =>
    array.unshift(arr, val)
    if array.size(arr) > max_n
        array.pop(arr)

if not na(tf1_ph)
    f_push(ph1, tf1_ph, n_pivots)
if not na(tf1_pl)
    f_push(pl1, tf1_pl, n_pivots)
if not na(tf2_ph)
    f_push(ph2, tf2_ph, n_pivots)
if not na(tf2_pl)
    f_push(pl2, tf2_pl, n_pivots)
if not na(tf3_ph)
    f_push(ph3, tf3_ph, n_pivots)
if not na(tf3_pl)
    f_push(pl3, tf3_pl, n_pivots)

// ── Drawing object storage ────────────────────────────────────────────────────
var line[]     g_lines  = array.new<line>(0)
var linefill[] g_fills  = array.new<linefill>(0)
var label[]    g_labels = array.new<label>(0)

// ── Channel half-width ────────────────────────────────────────────────────────
half_w = ta.atr(atr_len) * atr_mult

// ── Drawing helpers ───────────────────────────────────────────────────────────
//    f_zone: draw one filled S/R zone centered on lvl, append to storage arrays.
f_zone(lvl, hw, start_b, col, tag, arr_ln, arr_lf, arr_lb) =>
    u  = line.new(start_b, lvl + hw, bar_index, lvl + hw, xloc=xloc.bar_index, extend=extend.right, color=color.new(col, 55), width=1, style=line.style_solid)
    d  = line.new(start_b, lvl - hw, bar_index, lvl - hw, xloc=xloc.bar_index, extend=extend.right, color=color.new(col, 55), width=1, style=line.style_solid)
    lf = linefill.new(u, d, color.new(col, 84))
    lb = label.new(bar_index + 2, lvl, tag + "  " + str.tostring(lvl, format.mintick), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(col, 92), textcolor=col, size=size.small)
    array.push(arr_ln, u)
    array.push(arr_ln, d)
    array.push(arr_lf, lf)
    array.push(arr_lb, lb)

//    f_draw_set: iterate a pivot array, draw each zone that clears the proximity filter.
f_draw_set(pivots, hw, start_b, col, tf_lbl, kind, use_p, prox, cur, arr_ln, arr_lf, arr_lb) =>
    n = array.size(pivots)
    if n > 0
        for i = 0 to n - 1
            lvl  = array.get(pivots, i)
            near = not use_p or math.abs(lvl - cur) / cur <= prox
            if near
                f_zone(lvl, hw, start_b, col, tf_lbl + " " + kind + str.tostring(i + 1), arr_ln, arr_lf, arr_lb)

// ── Redraw on last bar ────────────────────────────────────────────────────────
//    All drawing objects are rebuilt on every tick of the last bar so labels and zone widths stay current with the latest ATR value.
if barstate.islast

    // Clear existing lines
    n_ln = array.size(g_lines)
    if n_ln > 0
        for i = 0 to n_ln - 1
            line.delete(array.get(g_lines, i))
    array.clear(g_lines)

    // Clear existing linefills
    n_lf = array.size(g_fills)
    if n_lf > 0
        for i = 0 to n_lf - 1
            linefill.delete(array.get(g_fills, i))
    array.clear(g_fills)

    // Clear existing labels
    n_lb = array.size(g_labels)
    if n_lb > 0
        for i = 0 to n_lb - 1
            label.delete(array.get(g_labels, i))
    array.clear(g_labels)

    // Geometry for this tick
    sb   = math.max(0, bar_index - 300)
    hw   = half_w
    prox = prox_pct / 100.0
    cur  = close

    // TF1
    if show_tf1 and show_res
        f_draw_set(ph1, hw, sb, col1, tf1, "R", use_prox, prox, cur, g_lines, g_fills, g_labels)
    if show_tf1 and show_sup
        f_draw_set(pl1, hw, sb, col1, tf1, "S", use_prox, prox, cur, g_lines, g_fills, g_labels)

    // TF2
    if show_tf2 and show_res
        f_draw_set(ph2, hw, sb, col2, tf2, "R", use_prox, prox, cur, g_lines, g_fills, g_labels)
    if show_tf2 and show_sup
        f_draw_set(pl2, hw, sb, col2, tf2, "S", use_prox, prox, cur, g_lines, g_fills, g_labels)

    // TF3
    if show_tf3 and show_res
        f_draw_set(ph3, hw, sb, col3, tf3, "R", use_prox, prox, cur, g_lines, g_fills, g_labels)
    if show_tf3 and show_sup
        f_draw_set(pl3, hw, sb, col3, tf3, "S", use_prox, prox, cur, g_lines, g_fills, g_labels)

// ── Alerts ────────────────────────────────────────────────────────────────────
//    Fire when a new pivot is confirmed on each timeframe, signaling that the projection set has been updated with a fresh reference level.
alertcondition(not na(tf1_ph), "New TF1 Resistance Pivot", "{{ticker}} new Timeframe 1 pivot high confirmed — TF1 resistance zones updated on {{interval}}")

alertcondition(not na(tf1_pl),  "New TF1 Support Pivot", "{{ticker}} new Timeframe 1 pivot low confirmed — TF1 support zones updated on {{interval}}")

alertcondition(not na(tf2_ph), "New TF2 Resistance Pivot", "{{ticker}} new Timeframe 2 pivot high confirmed — TF2 resistance zones updated on {{interval}}")

alertcondition(not na(tf2_pl), "New TF2 Support Pivot", "{{ticker}} new Timeframe 2 pivot low confirmed — TF2 support zones updated on {{interval}}")

alertcondition(not na(tf3_ph), "New TF3 Resistance Pivot", "{{ticker}} new Timeframe 3 pivot high confirmed — TF3 resistance zones updated on {{interval}}")

alertcondition(not na(tf3_pl), "New TF3 Support Pivot", "{{ticker}} new Timeframe 3 pivot low confirmed — TF3 support zones updated on {{interval}}")
````
