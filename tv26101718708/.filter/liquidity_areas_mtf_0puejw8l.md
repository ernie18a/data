# Liquidity Areas (MTF)

- url: https://www.tradingview.com/script/0PuejW8l-Liquidity-Areas-MTF/
- type: indicator
- pine_id: PUB;9f578282b71342838946591b55c63c98
- version: 1.0

## Description

[b]Liquidity Areas (MTF)[/b]

Maps the price levels on up to three higher timeframes where stop orders are most likely clustered, plotted as filled zones. Levels above swing highs are buy-side liquidity (BSL) — short sellers' stops sit there. Levels below swing lows are sell-side liquidity (SSL) — long holders' stops sit there. When two adjacent swings line up within a tight tolerance, they're labeled EQH (equal highs) or EQL (equal lows): a denser stop cluster and historically a stronger magnet.
When price closes beyond a level, it's marked as swept and rendered in a dimmed, dashed style — visible for context but visually de-emphasized.

[b]How it works[/b]

For each of the three configured timeframes, the script runs a pivot detector inside request.security (with lookahead_off) and tracks the most recent N swing highs (BSL candidates) and N swing lows (SSL candidates). Each level becomes a filled zone centered on the pivot price, with half-width = ATR × multiplier on the chart's own timeframe.
A level is checked for EQH/EQL status against its immediate neighbor in the array: if two consecutive swing highs (or lows) sit within the configured percentage tolerance, both are flagged as equal and recolored.
A level is marked swept on the first bar where close goes beyond it — above for BSL, below for SSL. Swept status is permanent: once flagged, a level stays swept for the remainder of the chart.
A proximity filter hides levels further than X% from current close. All drawing objects rebuild on the last bar so widths and statuses stay current.

[b]How to read it[/b]

Four color states carry information independently:
[list]
[*]Live BSL (default teal) — buy-side liquidity, unswept
[*]Live SSL (default red) — sell-side liquidity, unswept
[*]EQH / EQL (default amber) — equal highs or lows, denser clusters
[*]Swept (default grey, dashed) — price has already closed through
[/list]
Labels at the right edge mark the timeframe, the type (BSL, SSL, EQH, EQL, or "swept"), and the exact level.
The intuition behind the indicator: large orders are filled where liquidity exists, and liquidity exists where stops are clustered. A cleanly swept level often coincides with a reversal because the stop run has supplied the fills the large order needed. The indicator doesn't predict that reversal — it just makes the magnets visible.

[b]Inputs[/b]
[list]
[*]Timeframes 1/2/3 — defaults: 1H, Daily, Weekly. Choose timeframes higher than your chart timeframe.
[*]Pivot Lookback — bars required on each side to confirm a swing. Default 2. Lower values flag more levels; higher values restrict to more major swings.
[*]Levels per side per TF — number of recent BSL and SSL levels kept per timeframe. Default 3.
[*]Equal High/Low Tolerance — two adjacent swings within this percentage of each other get flagged EQH/EQL. Default 0.1%.
[*]Display toggles — BSL, SSL, swept, plus per-timeframe.
[*]Proximity filter — hide levels more than X% from current close. Default on, 5%.
[*]ATR Length / Multiplier — controls zone half-width. Defaults 14 / 0.25.
[*]Colors — BSL, SSL, EQH/EQL, and swept, customizable independently.
[/list]

[b]Built-in alerts[/b]
[list]
[*]New TF1 / TF2 / TF3 BSL — new pivot high confirmed on the corresponding timeframe
[*]New TF1 / TF2 / TF3 SSL — new pivot low confirmed on the corresponding timeframe
[*]TF1 BSL Swept — first bar where close crosses above the nearest unswept TF1 BSL level
[*]TF1 SSL Swept — first bar where close crosses below the nearest unswept TF1 SSL level
[/list]
Sweep alerts are TF1-only by design. Higher timeframes have enough delay between pivot confirmation and a meaningful sweep that a real-time alert isn't useful — watch the chart for TF2/TF3 sweeps, alert on TF1.

[b]Notes[/b]
The framework here borrows from Smart Money Concepts / ICT trading, where the underlying claim is that price tends to move toward visible liquidity pools before reversing. Whether you accept that as causal or just descriptive, the indicator is purely mechanical: it marks where stops are most likely sitting and lets you see when they're taken.
EQH/EQL detection only compares each level against its adjacent neighbor in the array, not all combinations. This is deliberate — equal highs separated by several swings historically are usually not the same liquidity pool in practice. Tighten the tolerance if you're getting false EQH flags; widen it if levels you visually consider equal aren't being marked.
The proximity filter defaults tighter than the other MTF indicators in this collection (5% vs 10–20%) because liquidity matters most when price is near it. A weekly BSL 25% away is irrelevant tactically; a weekly BSL 3% away might be where the next session is heading.
Higher-timeframe pivots don't confirm until pivot lookback bars after the actual high or low. Same lag caveat as the other MTF tools.
This is a structural tool, not a signal generator. It marks where stops cluster and which clusters have already been swept.

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
//                  Liquidity Areas (MTF)
//                  ──────────────────────
//   Maps the price levels on up to three higher timeframes where stop-loss
//   orders are most likely to be clustered:
//
//   BSL (Buy-Side Liquidity)  — above swing highs, where short sellers park
//                               their buy-stops. Price sweeping above a high
//                               triggers these orders.
//   SSL (Sell-Side Liquidity) — below swing lows, where long holders park
//                               their sell-stops.
//   EQH / EQL                 — Equal Highs / Equal Lows: two or more swings
//                               within a tight tolerance, forming a denser
//                               liquidity cluster that is a stronger magnet.
//
//   When price closes beyond a level it is marked as swept (dimmed, dashed).
//   Swept levels can be hidden or kept visible for context.
//
//   Version: 1.0
// ─────────────────────────────────────────────────────────────────────────────

//@version=6
indicator("Liquidity Areas (MTF)", shorttitle="Liq MTF", overlay=true, max_lines_count=500, max_labels_count=500, max_bars_back=500)

// ── Inputs ───────────────────────────────────────────────────────────────────
tf1      = input.timeframe("60", "Timeframe 1", group="Timeframes", tooltip="First higher timeframe. Default: 1 Hour.")
tf2      = input.timeframe("D",  "Timeframe 2", group="Timeframes", tooltip="Second higher timeframe. Default: Daily.")
tf3      = input.timeframe("W",  "Timeframe 3", group="Timeframes", tooltip="Third higher timeframe. Default: Weekly.")

piv_len  = input.int(2,   "Pivot Lookback (bars each side)", minval=1, maxval=10, group="Detection", tooltip="Bars required on each side of a swing to confirm it on the higher timeframe. Lower values detect more swings and more liquidity levels.")
n_levels = input.int(3,   "Levels Per Side Per TF",          minval=1, maxval=10, group="Detection", tooltip="How many of the most recent swing highs (BSL) and swing lows (SSL) to track per timeframe.")
eq_tol   = input.float(0.1, "Equal High/Low Tolerance (%)",  minval=0.01, maxval=2.0, step=0.01, group="Detection", tooltip="Two swing highs (or lows) within this percentage of each other are labeled EQH / EQL — a denser liquidity cluster. Tighter values flag only near-identical levels.")

show_bsl  = input.bool(true,  "Show BSL (Buy-Side, above highs)", group="Display")
show_ssl  = input.bool(true,  "Show SSL (Sell-Side, below lows)", group="Display")
show_sw   = input.bool(true,  "Show Swept Levels", group="Display", tooltip="Keep swept levels visible in a dimmed, dashed style. Disable to remove them from the chart once price has moved through them.")
show_tf1  = input.bool(true,  "Show TF1", group="Display")
show_tf2  = input.bool(true,  "Show TF2", group="Display")
show_tf3  = input.bool(true,  "Show TF3", group="Display")

use_prox  = input.bool(true,  "Proximity Filter", group="Filter", tooltip="Hide levels further than the specified distance from the current close.")
prox_pct  = input.float(5.0, "Max Distance from Close (%)",  minval=0.5, maxval=30.0, step=0.5, group="Filter")

atr_len   = input.int(14,    "ATR Length", minval=1, group="Zone Width")
atr_mult  = input.float(0.25, "ATR Multiplier", minval=0.05, maxval=3.0, step=0.05, group="Zone Width", tooltip="Half-width of each zone = ATR x multiplier.")

col_bsl   = input.color(#26a69a, "BSL Color", group="Visuals")
col_ssl   = input.color(#ef5350, "SSL Color", group="Visuals")
col_eq    = input.color(#ff9800, "EQH / EQL Color", group="Visuals")
col_sw    = input.color(#78909c, "Swept Color", group="Visuals")

// ── Higher-timeframe pivot detection ─────────────────────────────────────────
tf1_ph = request.security(syminfo.tickerid, tf1, ta.pivothigh(piv_len, piv_len), lookahead=barmerge.lookahead_off)
tf1_pl = request.security(syminfo.tickerid, tf1, ta.pivotlow( piv_len, piv_len), lookahead=barmerge.lookahead_off)
tf2_ph = request.security(syminfo.tickerid, tf2, ta.pivothigh(piv_len, piv_len), lookahead=barmerge.lookahead_off)
tf2_pl = request.security(syminfo.tickerid, tf2, ta.pivotlow( piv_len, piv_len), lookahead=barmerge.lookahead_off)
tf3_ph = request.security(syminfo.tickerid, tf3, ta.pivothigh(piv_len, piv_len), lookahead=barmerge.lookahead_off)
tf3_pl = request.security(syminfo.tickerid, tf3, ta.pivotlow( piv_len, piv_len), lookahead=barmerge.lookahead_off)

// ── Level storage ─────────────────────────────────────────────────────────────
//    For each TF: parallel float array (prices) and bool array (swept status).
//    Index 0 = most recent level. Swept = price has closed beyond the level.
var float[] bsl1 = array.new_float(0)
var bool[]  sw1b = array.new_bool(0)
var float[] ssl1 = array.new_float(0)
var bool[]  sw1s = array.new_bool(0)
var float[] bsl2 = array.new_float(0)
var bool[]  sw2b = array.new_bool(0)
var float[] ssl2 = array.new_float(0)
var bool[]  sw2s = array.new_bool(0)
var float[] bsl3 = array.new_float(0)
var bool[]  sw3b = array.new_bool(0)
var float[] ssl3 = array.new_float(0)
var bool[]  sw3s = array.new_bool(0)

// ── Push helper ───────────────────────────────────────────────────────────────
//    Add a new level (unswept) to the front of both parallel arrays.
//    Pop the oldest pair when the cap is reached.
f_push(price_arr, swept_arr, val, max_n) =>
    array.unshift(price_arr, val)
    array.unshift(swept_arr, false)
    if array.size(price_arr) > max_n
        array.pop(price_arr)
        array.pop(swept_arr)

// ── Per-bar level updates ─────────────────────────────────────────────────────
if not na(tf1_ph)
    f_push(bsl1, sw1b, tf1_ph, n_levels)
if not na(tf1_pl)
    f_push(ssl1, sw1s, tf1_pl, n_levels)
if not na(tf2_ph)
    f_push(bsl2, sw2b, tf2_ph, n_levels)
if not na(tf2_pl)
    f_push(ssl2, sw2s, tf2_pl, n_levels)
if not na(tf3_ph)
    f_push(bsl3, sw3b, tf3_ph, n_levels)
if not na(tf3_pl)
    f_push(ssl3, sw3s, tf3_pl, n_levels)

// ── Swept state update ────────────────────────────────────────────────────────
//    BSL is swept when price closes above the swing high.
//    SSL is swept when price closes below the swing low.
//    Once swept, a level stays swept — swept status is never reversed.
f_upd_bsl_swept(arr, sw_arr) =>
    n = array.size(arr)
    if n > 0
        for i = 0 to n - 1
            if not array.get(sw_arr, i) and close > array.get(arr, i)
                array.set(sw_arr, i, true)

f_upd_ssl_swept(arr, sw_arr) =>
    n = array.size(arr)
    if n > 0
        for i = 0 to n - 1
            if not array.get(sw_arr, i) and close < array.get(arr, i)
                array.set(sw_arr, i, true)

f_upd_bsl_swept(bsl1, sw1b)
f_upd_ssl_swept(ssl1, sw1s)
f_upd_bsl_swept(bsl2, sw2b)
f_upd_ssl_swept(ssl2, sw2s)
f_upd_bsl_swept(bsl3, sw3b)
f_upd_ssl_swept(ssl3, sw3s)

// ── Drawing storage ───────────────────────────────────────────────────────────
var line[]     g_lines  = array.new<line>(0)
var linefill[] g_fills  = array.new<linefill>(0)
var label[]    g_labels = array.new<label>(0)

// ── Zone half-width ───────────────────────────────────────────────────────────
half_w = ta.atr(atr_len) * atr_mult

// ── Drawing helper ────────────────────────────────────────────────────────────
//    Draw one BSL or SSL zone set for a single timeframe.
//    is_bsl=true → BSL (swing highs); is_bsl=false → SSL (swing lows).
f_draw_side(arr, sw_arr, is_bsl, c_live, c_eq, c_sw, s_sw, eq_dec, hw, use_p, prox, cur, tf_lbl, sb, arr_ln, arr_lf, arr_lb) =>
    n = array.size(arr)
    if n > 0
        for i = 0 to n - 1
            lvl = array.get(arr, i)
            sw  = array.get(sw_arr, i)
            // Skip swept levels when show_swept is off
            if not sw or s_sw
                near = not use_p or math.abs(lvl - cur) / cur <= prox
                if near
                    // Equal High/Low check — adjacent levels within tolerance
                    is_eq = false
                    if i > 0
                        if math.abs(lvl - array.get(arr, i - 1)) / lvl <= eq_dec
                            is_eq := true
                    if not is_eq and i < n - 1
                        if math.abs(lvl - array.get(arr, i + 1)) / lvl <= eq_dec
                            is_eq := true

                    zone_col    = sw ? c_sw : is_eq ? c_eq : c_live
                    fill_transp = sw ? 93 : 85
                    line_transp = sw ? 68 : 42
                    line_style  = sw ? line.style_dashed : line.style_solid
                    tag         = sw ? tf_lbl + (is_bsl ? " BSL" : " SSL") + " (swept)" : is_eq ? tf_lbl + (is_bsl ? " EQH" : " EQL") : tf_lbl + (is_bsl ? " BSL" : " SSL")

                    u  = line.new(sb, lvl + hw, bar_index, lvl + hw, xloc=xloc.bar_index, extend=extend.right, color=color.new(zone_col, line_transp), width=1, style=line_style)
                    d  = line.new(sb, lvl - hw, bar_index, lvl - hw, xloc=xloc.bar_index, extend=extend.right, color=color.new(zone_col, line_transp), width=1, style=line_style)
                    lf = linefill.new(u, d, color.new(zone_col, fill_transp))
                    lb = label.new(bar_index + 2, lvl, tag + "  " + str.tostring(lvl, format.mintick), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(zone_col, 90), textcolor=color.new(zone_col, line_transp), size=size.small)

                    array.push(arr_ln, u)
                    array.push(arr_ln, d)
                    array.push(arr_lf, lf)
                    array.push(arr_lb, lb)

// ── Redraw on last bar ────────────────────────────────────────────────────────
if barstate.islast

    n_ln = array.size(g_lines)
    if n_ln > 0
        for i = 0 to n_ln - 1
            line.delete(array.get(g_lines, i))
    array.clear(g_lines)

    n_lf = array.size(g_fills)
    if n_lf > 0
        for i = 0 to n_lf - 1
            linefill.delete(array.get(g_fills, i))
    array.clear(g_fills)

    n_lb = array.size(g_labels)
    if n_lb > 0
        for i = 0 to n_lb - 1
            label.delete(array.get(g_labels, i))
    array.clear(g_labels)

    sb   = math.max(0, bar_index - 300)
    hw   = half_w
    prox = prox_pct / 100.0
    cur  = close
    eq   = eq_tol / 100.0

    if show_tf1
        if show_bsl
            f_draw_side(bsl1, sw1b, true,  col_bsl, col_eq, col_sw, show_sw, eq, hw, use_prox, prox, cur, tf1, sb, g_lines, g_fills, g_labels)
        if show_ssl
            f_draw_side(ssl1, sw1s, false, col_ssl, col_eq, col_sw, show_sw, eq, hw, use_prox, prox, cur, tf1, sb, g_lines, g_fills, g_labels)
    if show_tf2
        if show_bsl
            f_draw_side(bsl2, sw2b, true,  col_bsl, col_eq, col_sw, show_sw, eq, hw, use_prox, prox, cur, tf2, sb, g_lines, g_fills, g_labels)
        if show_ssl
            f_draw_side(ssl2, sw2s, false, col_ssl, col_eq, col_sw, show_sw, eq, hw, use_prox, prox, cur, tf2, sb, g_lines, g_fills, g_labels)
    if show_tf3
        if show_bsl
            f_draw_side(bsl3, sw3b, true,  col_bsl, col_eq, col_sw, show_sw, eq, hw, use_prox, prox, cur, tf3, sb, g_lines, g_fills, g_labels)
        if show_ssl
            f_draw_side(ssl3, sw3s, false, col_ssl, col_eq, col_sw, show_sw, eq, hw, use_prox, prox, cur, tf3, sb, g_lines, g_fills, g_labels)

// ── Alerts ────────────────────────────────────────────────────────────────────
//    New level alerts fire when a fresh swing is confirmed on the HTF.
//    Swept alerts fire on the bar where price first closes through a level.
alertcondition(not na(tf1_ph), "New TF1 BSL",  "{{ticker}} new TF1 buy-side liquidity level above {{interval}}")
alertcondition(not na(tf1_pl), "New TF1 SSL",  "{{ticker}} new TF1 sell-side liquidity level below {{interval}}")
alertcondition(not na(tf2_ph), "New TF2 BSL",  "{{ticker}} new TF2 buy-side liquidity level above {{interval}}")
alertcondition(not na(tf2_pl), "New TF2 SSL",  "{{ticker}} new TF2 sell-side liquidity level below {{interval}}")
alertcondition(not na(tf3_ph), "New TF3 BSL",  "{{ticker}} new TF3 buy-side liquidity level above {{interval}}")
alertcondition(not na(tf3_pl), "New TF3 SSL",  "{{ticker}} new TF3 sell-side liquidity level below {{interval}}")

// Swept alerts — edge-detect the first bar a level is swept
float bsl1_min_unswept = na
float ssl1_max_unswept = na
n_b1 = array.size(bsl1)
if n_b1 > 0
    for i = 0 to n_b1 - 1
        if not array.get(sw1b, i)
            lv = array.get(bsl1, i)
            bsl1_min_unswept := na(bsl1_min_unswept) ? lv : math.min(bsl1_min_unswept, lv)
n_s1 = array.size(ssl1)
if n_s1 > 0
    for i = 0 to n_s1 - 1
        if not array.get(sw1s, i)
            lv = array.get(ssl1, i)
            ssl1_max_unswept := na(ssl1_max_unswept) ? lv : math.max(ssl1_max_unswept, lv)

alertcondition(ta.crossover(close, bsl1_min_unswept),  "TF1 BSL Swept", "{{ticker}} price swept TF1 buy-side liquidity on {{interval}}")
alertcondition(ta.crossunder(close, ssl1_max_unswept), "TF1 SSL Swept", "{{ticker}} price swept TF1 sell-side liquidity on {{interval}}")
````
