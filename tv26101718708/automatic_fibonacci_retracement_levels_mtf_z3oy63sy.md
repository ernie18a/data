# Automatic Fibonacci Retracement Levels (MTF)

- url: https://www.tradingview.com/script/z3oy63SY-Automatic-Fibonacci-Retracement-Levels-MTF/
- type: indicator
- pine_id: PUB;f0e0ffbdfc034ad482bcd21db36bfcba
- version: 1.0

## Description

[b]Automatic Fibonacci Retracement Levels (MTF)[/b]
Auto-anchored Fibonacci retracement levels drawn between the most recent confirmed swing high and swing low, replicated across up to three higher timeframes. As new pivots form on each timeframe, the levels reanchor automatically — no manual redrawing every time the swing range changes.
The point is to see Fibonacci structure across multiple horizons on a single chart, without juggling drawing tools.

[b]How it works[/b]
For each of the three configured timeframes, the script runs a pivot detector inside request.security (with lookahead_off, so no future-data leak). The most recent confirmed swing high and swing low per timeframe are stored as the active anchors. Standard ratios — 0%, 23.6%, 38.2%, 50%, 61.8%, 78.6%, 100% — are computed between low and high, with optional extensions at 127.2%, 161.8%, 200%, and 261.8% beyond the 100% pivot.
A proximity filter compares each individual level to current close and hides anything more than X% away. All drawing objects rebuild on the last bar so levels and labels stay current.

[b]How to read it[/b]
Each timeframe has its own color (defaults: teal for TF1, amber for TF2, purple for TF3). The 50% and 61.8% lines are drawn thicker and more saturated — these are the classical reversal area — and the optional golden zone fill shades the band between them.
The 0% and 100% levels are the swing low and swing high themselves, drawn solid. Intermediate ratios are dashed. Extensions, when enabled, are dotted — visually marking them as projected targets rather than retracements.
When fib levels from different timeframes cluster around the same price, that's confluence — and tends to matter more than any single level on its own.

[b]Inputs[/b]
[list]
[*]Timeframes 1/2/3 — the three higher timeframes to source pivots from. Defaults: Daily, Weekly, Monthly. Choose timeframes higher than your chart timeframe.
[*]Pivot Lookback — bars required on each side to confirm a swing. Higher values detect only major swings and keep the anchors stable for longer. Default 5.
[*]Display toggles — turn each timeframe on or off independently.
[*]Golden Zone Fill — shade the 50%–61.8% band, the highest-probability reversal zone in classical Fibonacci analysis. Default on.
[*]Extensions — draw 127.2%, 161.8%, 200%, and 261.8% beyond the 100% pivot. Useful for projecting price targets once a full swing has been exceeded. Default off.
[*]Proximity filter — hide levels further than X% from current close. Default on, 10%.
[*]Colors — one per timeframe.
[/list]

[b]Built-in alerts[/b]
A swing-confirmation alert is available for each timeframe and direction (six total):
[list]
[*]New TF1 / TF2 / TF3 Swing High — fires when a new pivot high is confirmed and the Fibonacci range reanchors
[*]New TF1 / TF2 / TF3 Swing Low — fires when a new pivot low is confirmed and the Fibonacci range reanchors
[/list]

[b]Notes[/b]
The pivot lookback is the key knob. Small values (2–3) produce fast-moving fib ranges that retag often — useful for short-term retracement plays but visually busy. Larger values (5–10+) lock onto major structural swings that stay anchored for longer, which is closer to how most traders actually use Fibonacci.
Higher-timeframe pivots don't confirm until pivot lookback bars after the actual high or low. On a monthly timeframe with lookback 5, that's five months of delay. The reanchor lag is the price of getting confirmed, non-repainting levels.
When the retracement direction looks wrong — for example, price has clearly made a lower swing low but the indicator is still anchored to an older one — it usually means the new pivot hasn't confirmed yet on that timeframe. Drop down a timeframe or wait it out.
This is a structural tool, not a signal generator. It plots the classical retracement and extension grid across multiple horizons.

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
//                  Automatic Fibonacci Retracement Levels (MTF)
//                  ─────────────────────────────────────────────
//   Detects the most recent swing high and swing low on up to three
//   higher timeframes and draws the full set of Fibonacci retracement
//   levels between them. Levels update automatically as new pivots form.
//
//   Standard levels : 0% · 23.6% · 38.2% · 50% · 61.8% · 78.6% · 100%
//   Optional fill   : golden zone between 50% and 61.8%
//   Optional ext.   : 127.2% · 161.8% · 200% · 261.8%
//
//   Version: 1.0
// ─────────────────────────────────────────────────────────────────────────────

//@version=6
indicator("Automatic Fibonacci Retracement Levels (MTF)", shorttitle="Auto Fib", overlay=true, max_lines_count=500, max_labels_count=500, max_bars_back=500)

// ── Inputs ───────────────────────────────────────────────────────────────────
tf1      = input.timeframe("D", "Timeframe 1", group="Timeframes", tooltip="First higher timeframe. Default: 1 Day.")
tf2      = input.timeframe("W",  "Timeframe 2", group="Timeframes", tooltip="Second higher timeframe. Default: Weekly.")
tf3      = input.timeframe("M",  "Timeframe 3", group="Timeframes", tooltip="Third higher timeframe. Default: Monthly.")

piv_len  = input.int(5,  "Pivot Lookback (bars each side)", minval=1, maxval=20, group="Pivots", tooltip="Bars required on each side of a pivot high or low to confirm it on the higher timeframe. Higher values detect only major structural swings and keep the Fibonacci anchors stable for longer periods.")

show_tf1    = input.bool(true,  "Show TF1 Fibs", group="Display")
show_tf2    = input.bool(true,  "Show TF2 Fibs", group="Display")
show_tf3    = input.bool(true,  "Show TF3 Fibs", group="Display")
show_golden = input.bool(true,  "Golden Zone Fill (50% - 61.8%)", group="Display", tooltip="Shade the area between the 50% and 61.8% retracement levels — the highest-probability reversal zone in classical Fibonacci analysis.")
show_ext    = input.bool(false, "Extension Levels (127.2% - 261.8%)", group="Display", tooltip="Draw Fibonacci extensions beyond the 100% pivot. Useful for projecting price targets after a full swing is exceeded.")

use_prox = input.bool(true,  "Proximity Filter", group="Filter", tooltip="Hide individual Fibonacci levels that fall further than the specified distance from the current close. Keeps the visible levels relevant.")
prox_pct = input.float(10.0, "Max Distance from Close (%)", minval=0.5, maxval=50.0, step=0.5, group="Filter", tooltip="Levels whose price is more than this percentage away from the current close are hidden. Widen on longer timeframes where the swing range may be large.")

col1     = input.color(#26a69a, "TF1 Color", group="Visuals")
col2     = input.color(#ff9800, "TF2 Color", group="Visuals")
col3     = input.color(#7c4dff, "TF3 Color", group="Visuals")

// ── Higher-timeframe pivot detection ─────────────────────────────────────────
//    ta.pivothigh/pivotlow run in the HTF context via request.security.
//    A non-na value is returned only on the bar where the pivot is confirmed.
tf1_ph = request.security(syminfo.tickerid, tf1, ta.pivothigh(piv_len, piv_len), lookahead=barmerge.lookahead_off)
tf1_pl = request.security(syminfo.tickerid, tf1, ta.pivotlow( piv_len, piv_len), lookahead=barmerge.lookahead_off)
tf2_ph = request.security(syminfo.tickerid, tf2, ta.pivothigh(piv_len, piv_len), lookahead=barmerge.lookahead_off)
tf2_pl = request.security(syminfo.tickerid, tf2, ta.pivotlow( piv_len, piv_len), lookahead=barmerge.lookahead_off)
tf3_ph = request.security(syminfo.tickerid, tf3, ta.pivothigh(piv_len, piv_len), lookahead=barmerge.lookahead_off)
tf3_pl = request.security(syminfo.tickerid, tf3, ta.pivotlow( piv_len, piv_len), lookahead=barmerge.lookahead_off)

// ── Pivot tracking ────────────────────────────────────────────────────────────
//    Retain the most recently confirmed swing high and swing low per TF.
//    Both are needed to anchor the Fibonacci range.
var float ref_h1 = na
var float ref_l1 = na
var float ref_h2 = na
var float ref_l2 = na
var float ref_h3 = na
var float ref_l3 = na

if not na(tf1_ph)
    ref_h1 := tf1_ph
if not na(tf1_pl)
    ref_l1 := tf1_pl
if not na(tf2_ph)
    ref_h2 := tf2_ph
if not na(tf2_pl)
    ref_l2 := tf2_pl
if not na(tf3_ph)
    ref_h3 := tf3_ph
if not na(tf3_pl)
    ref_l3 := tf3_pl

// ── Drawing object storage ────────────────────────────────────────────────────
var line[]     g_lines  = array.new<line>(0)
var linefill[] g_fills  = array.new<linefill>(0)
var label[]    g_labels = array.new<label>(0)

// ── Drawing helper ────────────────────────────────────────────────────────────
//    Compute and draw all Fibonacci levels for one timeframe.
f_draw_fibs(ref_h, ref_l, col, show_gz, show_ext_lvls, use_p, prox, cur, start_b, tf_lbl, arr_ln, arr_lf, arr_lb) =>
    if not na(ref_h) and not na(ref_l) and ref_h > ref_l
        rng      = ref_h - ref_l
        ratios   = array.from(0.0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0)
        lbl_strs = array.from("0%", "23.6%", "38.2%", "50%", "61.8%", "78.6%", "100%")

        // References to the 50% and 61.8% lines — needed for the golden zone fill
        line l_50  = na
        line l_618 = na

        n = array.size(ratios)
        if n > 0
            for i = 0 to n - 1
                r    = array.get(ratios, i)
                lvl  = ref_l + r * rng
                near = not use_p or math.abs(lvl - cur) / cur <= prox
                if near
                    is_key = i == 3 or i == 4   // 50% and 61.8%
                    is_end = i == 0 or i == n - 1
                    lc     = is_key ? color.new(col, 20) : color.new(col, 55)
                    st     = is_end ? line.style_solid : line.style_dashed
                    lw     = is_key ? 2 : 1
                    lbl    = array.get(lbl_strs, i)
                    ln     = line.new(start_b, lvl, bar_index, lvl,
                                      xloc=xloc.bar_index, extend=extend.right,
                                      color=lc, width=lw, style=st)
                    lb     = label.new(bar_index + 2, lvl,
                                       tf_lbl + " " + lbl + "  " + str.tostring(lvl, format.mintick),
                                       xloc=xloc.bar_index, yloc=yloc.price,
                                       style=label.style_label_left,
                                       color=color.new(col, 92), textcolor=lc, size=size.small)
                    array.push(arr_ln, ln)
                    array.push(arr_lb, lb)
                    if i == 3
                        l_50 := ln
                    if i == 4
                        l_618 := ln

        // Golden zone fill between 50% and 61.8%
        if show_gz and not na(l_50) and not na(l_618)
            array.push(arr_lf, linefill.new(l_50, l_618, color.new(col, 88)))

        // Fibonacci extensions beyond 100%
        if show_ext_lvls
            ext_r   = array.from(1.272, 1.618, 2.0, 2.618)
            ext_lbl = array.from("127.2%", "161.8%", "200%", "261.8%")
            ne      = array.size(ext_r)
            if ne > 0
                for i = 0 to ne - 1
                    r    = array.get(ext_r, i)
                    lvl  = ref_l + r * rng
                    near = not use_p or math.abs(lvl - cur) / cur <= prox
                    if near
                        lc  = color.new(col, 65)
                        lbl = array.get(ext_lbl, i)
                        ln  = line.new(start_b, lvl, bar_index, lvl,
                                       xloc=xloc.bar_index, extend=extend.right,
                                       color=lc, width=1, style=line.style_dotted)
                        lb  = label.new(bar_index + 2, lvl,
                                        tf_lbl + " " + lbl + "  " + str.tostring(lvl, format.mintick),
                                        xloc=xloc.bar_index, yloc=yloc.price,
                                        style=label.style_label_left,
                                        color=color.new(col, 92), textcolor=lc, size=size.small)
                        array.push(arr_ln, ln)
                        array.push(arr_lb, lb)

// ── Redraw on last bar ────────────────────────────────────────────────────────
if barstate.islast

    // Clear lines
    n_ln = array.size(g_lines)
    if n_ln > 0
        for i = 0 to n_ln - 1
            line.delete(array.get(g_lines, i))
    array.clear(g_lines)

    // Clear linefills
    n_lf = array.size(g_fills)
    if n_lf > 0
        for i = 0 to n_lf - 1
            linefill.delete(array.get(g_fills, i))
    array.clear(g_fills)

    // Clear labels
    n_lb = array.size(g_labels)
    if n_lb > 0
        for i = 0 to n_lb - 1
            label.delete(array.get(g_labels, i))
    array.clear(g_labels)

    sb   = math.max(0, bar_index - 500)
    prox = prox_pct / 100.0
    cur  = close

    if show_tf1
        f_draw_fibs(ref_h1, ref_l1, col1, show_golden, show_ext, use_prox, prox, cur, sb, tf1, g_lines, g_fills, g_labels)
    if show_tf2
        f_draw_fibs(ref_h2, ref_l2, col2, show_golden, show_ext, use_prox, prox, cur, sb, tf2, g_lines, g_fills, g_labels)
    if show_tf3
        f_draw_fibs(ref_h3, ref_l3, col3, show_golden, show_ext, use_prox, prox, cur, sb, tf3, g_lines, g_fills, g_labels)

// ── Alerts ────────────────────────────────────────────────────────────────────
alertcondition(not na(tf1_ph), "New TF1 Swing High", "{{ticker}} new Timeframe 1 swing high confirmed — Fibonacci levels reanchored on {{interval}}")
alertcondition(not na(tf1_pl), "New TF1 Swing Low", "{{ticker}} new Timeframe 1 swing low confirmed — Fibonacci levels reanchored on {{interval}}")
alertcondition(not na(tf2_ph), "New TF2 Swing High", "{{ticker}} new Timeframe 2 swing high confirmed — Fibonacci levels reanchored on {{interval}}")
alertcondition(not na(tf2_pl), "New TF2 Swing Low", "{{ticker}} new Timeframe 2 swing low confirmed — Fibonacci levels reanchored on {{interval}}")
alertcondition(not na(tf3_ph), "New TF3 Swing High", "{{ticker}} new Timeframe 3 swing high confirmed — Fibonacci levels reanchored on {{interval}}")
alertcondition(not na(tf3_pl), "New TF3 Swing Low", "{{ticker}} new Timeframe 3 swing low confirmed — Fibonacci levels reanchored on {{interval}}")
````
