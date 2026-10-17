# Trend Lines (HTF)

- url: https://www.tradingview.com/script/bwgDptmi-Trend-Lines-HTF/
- type: indicator
- pine_id: PUB;f3d8a5f71ab840d6875c076c6fe58fc0
- version: 1.0

## Description

[b]Trend Lines (HTF)[/b]

Auto-detected trend lines drawn between recent confirmed pivots across up to three higher timeframes. Resistance lines connect swing highs; support lines connect swing lows. Each line extends to the chart's right edge, and lines that price has closed through are dimmed and dashed — visible for context without dominating the chart.
The point is to put higher-timeframe trend structure on a single chart, without manually redrawing every time a new swing prints.

[b]How it works[/b]

For each of the three configured timeframes, the script runs a pivot detector inside request.security, with bar timestamps stored alongside each pivot so lines stay anchored to absolute chart time and don't drift on zoom or scroll. The most recent swing highs and swing lows are kept per timeframe.
Trend lines are drawn between adjacent pivots — pivot N−1 to pivot N for the most recent line, pivot N−2 to pivot N−1 for the previous one, and so on, up to the configured number per side. Newer lines render at full opacity; older ones progressively fade.
A line is marked broken the moment current close has crossed past its projected price — above for resistance, below for support. Broken lines switch to grey and dashed.
All lines and labels rebuild on every tick of the last bar so the right-edge price label always reflects the line's current projected level.

[b]How to read it[/b]

Each timeframe has its own color (defaults: teal for TF1, amber for TF2, purple for TF3) and its own line width. The most recent line per direction gets a price label at the right edge showing where that line currently projects.
Older lines fade with age. A solid, full-opacity line is the freshest trend; faded ones are historical structure that may still be relevant. Broken lines flip to grey-dashed — useful for spotting role reversal, where a broken resistance becomes new support or vice versa.
The lines connect adjacent pivots — they're not best-fit lines through many touches. This is deliberate: it shows you the slope of the most recent swing, not a line of best fit that may not match what price is actually doing right now.

[b]Inputs[/b]
[list]
[*]Timeframes 1/2/3 — defaults: Daily, Weekly, 3-Month. Choose timeframes higher than your chart timeframe.
[*]Per-TF Pivot Lookback — bars required on each side to confirm a swing, set independently per timeframe. Default 3 each. Higher values capture only major swings.
[*]Resistance / Support lines per TF — how many trend lines to draw per timeframe per direction. Defaults 2 each. Increase to see more historical structure.
[*]Display toggles — per-TF, resistance/support, broken lines, pivot anchor markers, right-edge price labels, and timeframe tag in the label. TF3 is off by default because 3-Month pivots confirm very slowly.
[*]Colors — one per timeframe, plus a separate broken-lines color.
[*]Line widths — independent per timeframe.
[*]Extension — Right (default), Both, or None. Controls whether each line extends past its second pivot.
[*]Line Style — Solid, Dashed, or Dotted (applies to unbroken lines).
[/list]

[b]Built-in alerts[/b]
Six alerts, one per timeframe and direction:
[list]
[*]TF1 / TF2 / TF3 Resistance Break ↑ — close crosses above the most recent unbroken resistance line on that timeframe
[*]TF1 / TF2 / TF3 Support Break ↓ — close crosses below the most recent unbroken support line on that timeframe
[/list]
Breaks fire on the bar they occur, based on the line's current projected price.

[b]Notes[/b]
The lines connect adjacent pivots only. Some auto-trendline indicators try to fit lines through several swings at once; this one doesn't. The design assumption is that the slope between the two most recent swings is what's currently relevant, and older swings shouldn't be forced onto the same line just because they're nearby. If you want longer trend channels, increase pivot lookback so individual swings represent larger structural moves.
Each timeframe has its own pivot lookback by design. A daily chart and a 3-month chart usually need different sensitivities, and forcing them to share one setting tends to make at least one of them wrong.
Higher-timeframe pivots don't confirm until pivot lookback bars after the actual high or low. On a 3-month timeframe with lookback 3, that's nine months of delay — which is why TF3 is off by default and only worth turning on if you're trading multi-year structure.
When a line breaks, it stays dimmed permanently. There's no un-breaking. If price reclaims the level, that's role reversal: the broken resistance is now informing as historical structure while the most recent unbroken support takes over the active role.
This is a structural tool, not a signal generator. It marks where the recent swing slopes sit and which of those slopes price has already broken.

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
//                Trend Lines (HTF)
//                ─────────────────
//   Automatically detects swing highs and lows on up to three higher timeframes
//   and draws the resulting trend lines on the chart. Resistance lines connect
//   recent pivot highs; support lines connect recent pivot lows. Each line
//   extends to the chart edge. Broken lines are dimmed. Pivot anchor markers
//   show where each line is anchored.
//
//   Pivot times are stored as bar timestamps so all drawings are anchored to
//   absolute chart time — stable across zoom and scroll.
//
//   Version: 1.1
// ─────────────────────────────────────────────────────────────────────────────

//@version=6
indicator("Trend Lines (HTF)", shorttitle="TL·HTF", overlay=true, max_lines_count=500, max_labels_count=500)

// ── Inputs ────────────────────────────────────────────────────────────────────
tf1      = input.timeframe("D",  "Timeframe 1", group="Timeframes")
tf2      = input.timeframe("W",  "Timeframe 2", group="Timeframes")
tf3      = input.timeframe("3M", "Timeframe 3", group="Timeframes")

piv_len1 = input.int(3, "TF1 Pivot Lookback", minval=1, maxval=20, group="Detection", tooltip="Bars each side of the swing on the HTF. Increase for fewer, more significant pivots.")
piv_len2 = input.int(3, "TF2 Pivot Lookback", minval=1, maxval=20, group="Detection")
piv_len3 = input.int(3, "TF3 Pivot Lookback", minval=1, maxval=20, group="Detection")
max_res  = input.int(2, "Resistance lines per TF", minval=1, maxval=5, group="Detection", tooltip="How many descending/ascending resistance trend lines to draw per timeframe.")
max_sup  = input.int(2, "Support lines per TF",    minval=1, maxval=5, group="Detection", tooltip="How many ascending/descending support trend lines to draw per timeframe.")

show_tf1    = input.bool(true,  "TF1", group="Show")
show_tf2    = input.bool(true,  "TF2", group="Show")
show_tf3    = input.bool(false, "TF3", group="Show")
show_res    = input.bool(true,  "Resistance (swing highs)", group="Show")
show_sup    = input.bool(true,  "Support (swing lows)",  group="Show")
show_broke  = input.bool(true,  "Broken lines",  group="Show")
show_pivots = input.bool(true,  "Pivot anchor markers", group="Show")
show_label  = input.bool(true,  "Price labels", group="Show")
show_tf_tag = input.bool(true,  "Timeframe tag in label", group="Show")

col1      = input.color(#26a69a, "TF1 Color", group="Colors")
col2      = input.color(#ff9800, "TF2 Color", group="Colors")
col3      = input.color(#7c4dff, "TF3 Color", group="Colors")
broke_col = input.color(#787b86, "Broken lines", group="Colors")

lw1      = input.int(2, "TF1 Width", minval=1, maxval=4, group="Style")
lw2      = input.int(1, "TF2 Width", minval=1, maxval=4, group="Style")
lw3      = input.int(1, "TF3 Width", minval=1, maxval=4, group="Style")
ext_opt  = input.string("Right", "Extension",  options=["Right", "Both", "None"], group="Style", tooltip="Right: extends past the second pivot toward the future. Both: extends in both directions. None: draws only between the two pivots.")
ls_opt   = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group="Style")

ext_val = ext_opt == "Right" ? extend.right : ext_opt == "Both" ? extend.both : extend.none
ls_val  = ls_opt  == "Solid" ? line.style_solid : ls_opt == "Dashed" ? line.style_dashed : line.style_dotted

// ── HTF pivot function ────────────────────────────────────────────────────────
f_piv(len) =>
    ph   = ta.pivothigh(len, len)
    pl   = ta.pivotlow( len, len)
    ph_t = not na(ph) ? time[len] : int(na)
    pl_t = not na(pl) ? time[len] : int(na)
    [ph, ph_t, pl, pl_t]

[tf1_ph, tf1_pht, tf1_pl, tf1_plt] = request.security(syminfo.tickerid, tf1, f_piv(piv_len1))
[tf2_ph, tf2_pht, tf2_pl, tf2_plt] = request.security(syminfo.tickerid, tf2, f_piv(piv_len2))
[tf3_ph, tf3_pht, tf3_pl, tf3_plt] = request.security(syminfo.tickerid, tf3, f_piv(piv_len3))

// ── Pivot storage ─────────────────────────────────────────────────────────────
var int[]   tf1_rht = array.new_int(0)
var float[] tf1_rhp = array.new_float(0)
var int[]   tf1_slt = array.new_int(0)
var float[] tf1_slp = array.new_float(0)

var int[]   tf2_rht = array.new_int(0)
var float[] tf2_rhp = array.new_float(0)
var int[]   tf2_slt = array.new_int(0)
var float[] tf2_slp = array.new_float(0)

var int[]   tf3_rht = array.new_int(0)
var float[] tf3_rhp = array.new_float(0)
var int[]   tf3_slt = array.new_int(0)
var float[] tf3_slp = array.new_float(0)

// ── Drawing storage ───────────────────────────────────────────────────────────
var line[]  g_lines  = array.new<line>(0)
var label[] g_labels = array.new<label>(0)

// ── Push helper ───────────────────────────────────────────────────────────────
f_push(t_arr, p_arr, t, p, cap) =>
    array.push(t_arr, t)
    array.push(p_arr, p)
    if array.size(t_arr) > cap
        array.shift(t_arr)
        array.shift(p_arr)

// ── Per-bar pivot accumulation ────────────────────────────────────────────────
cap_res = max_res + 1
cap_sup = max_sup + 1

if not na(tf1_ph) and na(tf1_ph[1]) and not na(tf1_pht)
    f_push(tf1_rht, tf1_rhp, tf1_pht, tf1_ph, cap_res)
if not na(tf1_pl) and na(tf1_pl[1]) and not na(tf1_plt)
    f_push(tf1_slt, tf1_slp, tf1_plt, tf1_pl, cap_sup)
if not na(tf2_ph) and na(tf2_ph[1]) and not na(tf2_pht)
    f_push(tf2_rht, tf2_rhp, tf2_pht, tf2_ph, cap_res)
if not na(tf2_pl) and na(tf2_pl[1]) and not na(tf2_plt)
    f_push(tf2_slt, tf2_slp, tf2_plt, tf2_pl, cap_sup)
if not na(tf3_ph) and na(tf3_ph[1]) and not na(tf3_pht)
    f_push(tf3_rht, tf3_rhp, tf3_pht, tf3_ph, cap_res)
if not na(tf3_pl) and na(tf3_pl[1]) and not na(tf3_plt)
    f_push(tf3_slt, tf3_slp, tf3_plt, tf3_pl, cap_sup)

// ── Trend line current price ───────────────────────────────────────────────────
f_tl_now(t_arr, p_arr) =>
    n      = array.size(t_arr)
    result = float(na)
    if n >= 2
        t1 = array.get(t_arr, n - 2)
        t2 = array.get(t_arr, n - 1)
        if t1 != t2
            p1    = array.get(p_arr, n - 2)
            p2    = array.get(p_arr, n - 1)
            slope = (p2 - p1) / float(t2 - t1)
            result := p2 + slope * float(time - t2)
    result

tf1_res_val = f_tl_now(tf1_rht, tf1_rhp)
tf1_sup_val = f_tl_now(tf1_slt, tf1_slp)
tf2_res_val = f_tl_now(tf2_rht, tf2_rhp)
tf2_sup_val = f_tl_now(tf2_slt, tf2_slp)
tf3_res_val = f_tl_now(tf3_rht, tf3_rhp)
tf3_sup_val = f_tl_now(tf3_slt, tf3_slp)

// ── Drawing function ───────────────────────────────────────────────────────────
f_draw(t_arr, p_arr, col, lw, is_res, max_segs, tf_tag) =>
    n = array.size(t_arr)
    if n >= 2
        segs = math.min(n - 1, max_segs)
        if segs > 0
            for i = 0 to segs - 1
                idx2 = n - 1 - i
                idx1 = idx2 - 1
                t1   = array.get(t_arr, idx1)
                t2   = array.get(t_arr, idx2)
                if t1 == t2
                    continue
                p1    = array.get(p_arr, idx1)
                p2    = array.get(p_arr, idx2)
                slope = (p2 - p1) / float(t2 - t1)
                p_now = p2 + slope * float(time - t2)
                broke = is_res ? close > p_now : close < p_now
                if broke and not show_broke
                    continue
                lc    = broke ? broke_col : col
                ls    = broke ? line.style_dashed : ls_val
                alpha = i * 30   // most recent = 0 (opaque), older = 30, 60, ...
                ln = line.new(t1, p1, t2, p2,
                              xloc   = xloc.bar_time,
                              extend = ext_val,
                              color  = color.new(lc, alpha),
                              width  = lw,
                              style  = ls)
                array.push(g_lines, ln)

                // Pivot anchor markers at both endpoints
                if show_pivots
                    m1 = label.new(t1, p1, "",
                                   xloc=xloc.bar_time, yloc=yloc.price,
                                   style=label.style_circle,
                                   color=color.new(lc, alpha + 30),
                                   size=size.tiny)
                    m2 = label.new(t2, p2, "",
                                   xloc=xloc.bar_time, yloc=yloc.price,
                                   style=label.style_circle,
                                   color=color.new(lc, alpha + 30),
                                   size=size.tiny)
                    array.push(g_labels, m1)
                    array.push(g_labels, m2)

                // Right-edge label: most recent unbroken line only
                if show_label and i == 0 and not broke
                    lbl_txt = show_tf_tag ? tf_tag + " " + str.tostring(p_now, format.mintick)
                                          : str.tostring(p_now, format.mintick)
                    lb = label.new(time, p_now, lbl_txt,
                                   xloc      = xloc.bar_time,
                                   yloc      = yloc.price,
                                   style     = label.style_label_right,
                                   color     = color.new(lc, 0),
                                   textcolor = color.white,
                                   size      = size.small)
                    array.push(g_labels, lb)

// ── Redraw on last bar ────────────────────────────────────────────────────────
if barstate.islast
    for ln in g_lines
        line.delete(ln)
    array.clear(g_lines)
    for lb in g_labels
        label.delete(lb)
    array.clear(g_labels)

    if show_tf1
        if show_res
            f_draw(tf1_rht, tf1_rhp, col1, lw1, true,  max_res, tf1)
        if show_sup
            f_draw(tf1_slt, tf1_slp, col1, lw1, false, max_sup, tf1)
    if show_tf2
        if show_res
            f_draw(tf2_rht, tf2_rhp, col2, lw2, true,  max_res, tf2)
        if show_sup
            f_draw(tf2_slt, tf2_slp, col2, lw2, false, max_sup, tf2)
    if show_tf3
        if show_res
            f_draw(tf3_rht, tf3_rhp, col3, lw3, true,  max_res, tf3)
        if show_sup
            f_draw(tf3_slt, tf3_slp, col3, lw3, false, max_sup, tf3)

// ── Alerts ────────────────────────────────────────────────────────────────────
alertcondition(ta.crossover( close, tf1_res_val), "TF1 Resistance Break ↑", "{{ticker}} closed above TF1 resistance trend line on {{interval}}")
alertcondition(ta.crossunder(close, tf1_sup_val), "TF1 Support Break ↓",    "{{ticker}} closed below TF1 support trend line on {{interval}}")
alertcondition(ta.crossover( close, tf2_res_val), "TF2 Resistance Break ↑", "{{ticker}} closed above TF2 resistance trend line on {{interval}}")
alertcondition(ta.crossunder(close, tf2_sup_val), "TF2 Support Break ↓",    "{{ticker}} closed below TF2 support trend line on {{interval}}")
alertcondition(ta.crossover( close, tf3_res_val), "TF3 Resistance Break ↑", "{{ticker}} closed above TF3 resistance trend line on {{interval}}")
alertcondition(ta.crossunder(close, tf3_sup_val), "TF3 Support Break ↓",    "{{ticker}} closed below TF3 support trend line on {{interval}}")
````
