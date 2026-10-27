# OTE - Optimal Trade Entry

- url: https://www.tradingview.com/script/0DvWAlQj-OTE-Optimal-Trade-Entry/
- type: indicator
- pine_id: PUB;32438d4b7d4f4bd3bdcca5d9ea003d59
- version: 1.0

## Description

[b]OTE - Optimal Trade Entry[/b]

Marks the 61.8%–79% Fibonacci retracement of each confirmed impulse leg as a shaded zone. In ICT methodology this band — anchored at 61.8%, centred on the 70.5% "sweet spot," and bounded at 79% — is where institutional flow is most likely to re-enter after a pullback.
A bullish OTE zone is drawn when a swing high confirms after a swing low (an up-leg has completed), marking the expected pullback area for a long re-entry. A bearish OTE zone is drawn when a swing low confirms after a swing high (a down-leg has completed), marking the expected pullback area for a short. Three timeframes overlay simultaneously, with border weight increasing per TF so higher-timeframe zones always stand out.

[b]How it works[/b]

For each of the three configured timeframes, the script runs pivot detection inside request.security and tracks the most recent confirmed swing high and swing low.[list]
[*]A swing high confirming after the most recent swing low triggers a bullish OTE: the impulse leg is from low to high, and the zone is drawn between the 61.8% and 79% retracements down from the high.
[*]A swing low confirming after the most recent swing high triggers a bearish OTE: the impulse leg is from high to low, and the zone is drawn between the 61.8% and 79% retracements up from the low.[/list]

Each zone records the original swing (the Fibonacci anchor), its 70.5% midline, and its top and bottom bounds. A zone is marked mitigated the first bar price wicks into it. Mitigated zones stop extending right and re-render in grey; they can be hidden entirely if the chart gets busy.
All boxes, lines, and labels are rebuilt on the last bar so styling stays current.

[b]How to read it[/b]

Each timeframe is differentiated by border weight (thin → medium → thick), leaving color free for direction:[list]
[*]Bullish OTE (default teal) — expected pullback area for a long
[*]Bearish OTE (default red) — expected pullback area for a short
[*]Mitigated (default grey) — price has already wicked into the zone[/list]

A few visual elements help anchor each zone:[list]
[*]Origin line — a vertical line from the anchor swing point to the zone edge, showing exactly where the Fibonacci was measured from. Useful when several zones stack and you need to identify the impulse leg each one belongs to.
[*]70.5% midline — a dashed line through the centre of each zone. ICT methodology treats the midline as the precision-entry level within the band.
[*]Label — timeframe and direction (▲ bullish, ▼ bearish).[/list]
When OTE zones from different timeframes stack at the same price, that's confluence — a 1H bullish OTE coinciding with a 4H bullish OTE is structurally more interesting than either zone alone.

[b]Inputs[/b][list]
[*]Show mitigated zones — keep entered zones on chart in dimmed style. Default on.
[*]Labels — show or hide zone labels. Default on.
[*]70.5% midline — draw the precision-entry line through the centre of each zone. Default on.
[*]Origin line — draw the vertical anchor line from swing to zone. Default on.
[*]Max zones (per TF) — cap on stored zones drawn per timeframe. Default 10.
[*]Pivot Length — bars required on each side to confirm a swing. Default 5.
[*]Timeframes 1/2/3 — defaults: 1H, 4H, Daily. Each independently enabled. TF3 off by default.
[*]Colors — bullish, bearish, mitigated.[/list]

[b]Built-in alerts[/b][list]
[*]Bullish OTE Zone — fires when a new bullish OTE zone is formed on any enabled timeframe
[*]Bearish OTE Zone — same, for bearish[/list]
Note: these fire on zone formation, not on price entry into the zone. If you want entry-trigger alerts, set TradingView alerts on price crossing into the published zone levels.

[b]Notes[/b]
OTE is a focused subset of Fibonacci retracement analysis — it isolates the 61.8%–79% band, where ICT methodology argues the highest-probability re-entry sits. The full Fibonacci grid (0%, 23.6%, 38.2%, 50%, 61.8%, 78.6%, 100%) is available in the Automatic Fibonacci Retracement Levels (MTF) indicator if you want to see the whole structure rather than just the OTE band.
The pivot length controls what counts as an impulse leg. A length of 5 catches most meaningful intraday and swing structure. Smaller values produce overlapping zones from minor swings; larger values restrict to major impulse legs but lag substantially. Pick a value that matches what you'd manually call "the recent leg."
Higher-timeframe pivots don't confirm until pivot length bars after the actual swing. On a Daily timeframe with length 5, that's five days of delay between the actual high or low and the OTE zone appearing. Zones are non-repainting once printed, but they appear later than the swing itself.
A mitigated OTE isn't a failed one. Price wicking into the zone is the expected behaviour — the zone is doing its job. The mitigation flag is informational: it tells you the zone has been tested. Whether the test held or failed is a separate question your own system needs to answer.
The framework here borrows from Smart Money Concepts / ICT trading, where OTE is one of the canonical entry techniques. Whether you accept the institutional-flow narrative or just use the 61.8%–79% band as a high-quality retracement zone, the indicator is purely mechanical: it finds the impulse legs and draws the bands.
This is a structural tool, not a signal generator. It marks the highest-quality retracement zone of each completed impulse.

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
//                OTE - Optimal Trade Entry
//                ──────────────────────────
//   Marks the 61.8 %–79 % Fibonacci retracement of each confirmed impulse
//   leg as a shaded zone.  In ICT methodology this band — anchored at 61.8 %,
//   centred on the 70.5 % sweet spot, and bounded at 79 % — is where
//   institutional flow is most likely to re-enter after a pullback.
//
//   A bullish OTE zone is drawn whenever a swing high confirms after a swing
//   low (completed up-leg), marking the expected retrace area for a long entry.
//   A bearish OTE zone is drawn whenever a swing low confirms after a swing
//   high (completed down-leg), marking the expected retrace area for a short.
//   A vertical origin line connects the anchor swing point to the zone edge,
//   making the Fibonacci measurement immediately visible. An optional 70.5 %
//   midline cuts through each zone for precision entries.
//
//   Three independently configurable timeframes overlay simultaneously.
//   Border weight increases per TF so higher-timeframe zones always stand out.
//   Zones dim once price trades into them; mitigated zones can be hidden.
//
//   Version: 1.0
// ─────────────────────────────────────────────────────────────────────────────

//@version=6
indicator("OTE - Optimal Trade Entry", shorttitle="OTE", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ── Inputs ───────────────────────────────────────────────────────────────────
show_mit  = input.bool(true, "Show mitigated zones", group="Display")
show_lbl  = input.bool(true, "Labels",               group="Display")
show_mid  = input.bool(true, "70.5 % midline",       group="Display")
show_orig = input.bool(true, "Origin line",           group="Display", tooltip="Draws a vertical line from the anchor swing point to the zone edge, showing exactly where the Fibonacci was measured from.")
max_zones = input.int(10,    "Max zones (per TF)",   minval=1, maxval=50, group="Display")

struct_len = input.int(5, "Pivot Length", minval=2, maxval=20, group="Detection", tooltip="Bars required on each side to confirm a swing pivot. Higher values filter minor swings and produce fewer, more significant zones.")

tf1_on = input.bool(true,  "TF 1", group="Timeframes", inline="tf1")
tf1    = input.timeframe("60",  "", group="Timeframes", inline="tf1")
tf2_on = input.bool(true,  "TF 2", group="Timeframes", inline="tf2")
tf2    = input.timeframe("240", "", group="Timeframes", inline="tf2")
tf3_on = input.bool(false, "TF 3", group="Timeframes", inline="tf3")
tf3    = input.timeframe("D",   "", group="Timeframes", inline="tf3")

bull_col = input.color(#26a69a, "Bullish",   group="Colors")
bear_col = input.color(#ef5350, "Bearish",   group="Colors")
mit_col  = input.color(#787b86, "Mitigated", group="Colors")

// ── OTE detection (runs inside each request.security context) ─────────────────
f_raw() =>
    ph = ta.pivothigh(high, struct_len, struct_len)
    pl = ta.pivotlow(low,  struct_len, struct_len)

    var float last_ph = na
    var float last_pl = na

    new_bull  = not na(ph) and not na(last_pl)
    b_rng     = new_bull ? ph - last_pl        : float(na)
    bull_top  = new_bull ? ph - b_rng * 0.618  : float(na)
    bull_mid  = new_bull ? ph - b_rng * 0.705  : float(na)
    bull_bot  = new_bull ? ph - b_rng * 0.790  : float(na)
    bull_ts   = new_bull ? time[struct_len]     : int(na)
    bull_swp  = new_bull ? ph                  : float(na)   // swing high — Fib anchor

    new_bear  = not na(pl) and not na(last_ph)
    r_rng     = new_bear ? last_ph - pl        : float(na)
    bear_bot  = new_bear ? pl + r_rng * 0.618  : float(na)
    bear_mid  = new_bear ? pl + r_rng * 0.705  : float(na)
    bear_top  = new_bear ? pl + r_rng * 0.790  : float(na)
    bear_ts   = new_bear ? time[struct_len]     : int(na)
    bear_swp  = new_bear ? pl                  : float(na)   // swing low — Fib anchor

    if not na(ph)
        last_ph := ph
    if not na(pl)
        last_pl := pl

    [bull_top, bull_mid, bull_bot, bull_ts, bull_swp, bear_top, bear_mid, bear_bot, bear_ts, bear_swp]

[tf1_btop, tf1_bmid, tf1_bbot, tf1_bts, tf1_bswp, tf1_rtop, tf1_rmid, tf1_rbot, tf1_rts, tf1_rswp] = request.security(syminfo.tickerid, tf1, f_raw())
[tf2_btop, tf2_bmid, tf2_bbot, tf2_bts, tf2_bswp, tf2_rtop, tf2_rmid, tf2_rbot, tf2_rts, tf2_rswp] = request.security(syminfo.tickerid, tf2, f_raw())
[tf3_btop, tf3_bmid, tf3_bbot, tf3_bts, tf3_bswp, tf3_rtop, tf3_rmid, tf3_rbot, tf3_rts, tf3_rswp] = request.security(syminfo.tickerid, tf3, f_raw())

// ── Storage ───────────────────────────────────────────────────────────────────
var float[] tf1_top_a = array.new_float(0)
var float[] tf1_mid_a = array.new_float(0)
var float[] tf1_bot_a = array.new_float(0)
var int[]   tf1_ts_a  = array.new_int(0)
var float[] tf1_swp_a = array.new_float(0)
var bool[]  tf1_bul_a = array.new_bool(0)
var bool[]  tf1_mit_a = array.new_bool(0)
var int[]   tf1_mts_a = array.new_int(0)

var float[] tf2_top_a = array.new_float(0)
var float[] tf2_mid_a = array.new_float(0)
var float[] tf2_bot_a = array.new_float(0)
var int[]   tf2_ts_a  = array.new_int(0)
var float[] tf2_swp_a = array.new_float(0)
var bool[]  tf2_bul_a = array.new_bool(0)
var bool[]  tf2_mit_a = array.new_bool(0)
var int[]   tf2_mts_a = array.new_int(0)

var float[] tf3_top_a = array.new_float(0)
var float[] tf3_mid_a = array.new_float(0)
var float[] tf3_bot_a = array.new_float(0)
var int[]   tf3_ts_a  = array.new_int(0)
var float[] tf3_swp_a = array.new_float(0)
var bool[]  tf3_bul_a = array.new_bool(0)
var bool[]  tf3_mit_a = array.new_bool(0)
var int[]   tf3_mts_a = array.new_int(0)

var box[]   g_bxs = array.new<box>(0)
var line[]  g_lns = array.new<line>(0)
var label[] g_lbs = array.new<label>(0)

// ── Push helper ───────────────────────────────────────────────────────────────
f_push(top, mid, bot, ts, swp, bul, top_a, mid_a, bot_a, ts_a, swp_a, bul_a, mit_a, mts_a, cap) =>
    array.push(top_a, top)
    array.push(mid_a, mid)
    array.push(bot_a, bot)
    array.push(ts_a,  ts)
    array.push(swp_a, swp)
    array.push(bul_a, bul)
    array.push(mit_a, false)
    array.push(mts_a, 0)
    if array.size(top_a) > cap
        array.shift(top_a)
        array.shift(mid_a)
        array.shift(bot_a)
        array.shift(ts_a)
        array.shift(swp_a)
        array.shift(bul_a)
        array.shift(mit_a)
        array.shift(mts_a)

// ── Mitigation update ─────────────────────────────────────────────────────────
f_update(top_a, bot_a, bul_a, mit_a, mts_a) =>
    n = array.size(mit_a)
    if n > 0
        for i = 0 to n - 1
            if not array.get(mit_a, i)
                tp   = array.get(top_a, i)
                bt   = array.get(bot_a, i)
                is_b = array.get(bul_a, i)
                hit  = is_b ? low <= tp : high >= bt
                if hit
                    array.set(mit_a, i, true)
                    array.set(mts_a, i, time)

// ── Draw — called once at barstate.islast ─────────────────────────────────────
f_draw(top_a, mid_a, bot_a, ts_a, swp_a, bul_a, mit_a, mts_a, lw, tag) =>
    n = array.size(top_a)
    if n > 0
        shown = 0
        for i = n - 1 to 0
            if shown >= max_zones
                break
            is_mit = array.get(mit_a, i)
            if is_mit and not show_mit
                continue
            is_bul = array.get(bul_a, i)
            tp     = array.get(top_a, i)
            md     = array.get(mid_a, i)
            bt     = array.get(bot_a, i)
            ts     = array.get(ts_a,  i)
            swp    = array.get(swp_a, i)
            mts    = array.get(mts_a, i)
            col    = is_mit ? mit_col : (is_bul ? bull_col : bear_col)
            x2_val = is_mit ? mts : time
            ext    = is_mit ? extend.none : extend.right
            bx     = box.new(ts, tp, x2_val, bt, xloc=xloc.bar_time, extend=ext, bgcolor=color.new(col, 85), border_color=color.new(col, 30), border_width=lw)
            array.push(g_bxs, bx)
            if show_orig
                orig_near = is_bul ? tp : bt
                ol = line.new(x1=ts, y1=swp, x2=ts, y2=orig_near, xloc=xloc.bar_time, color=color.new(col, 30), width=lw, style=line.style_solid)
                array.push(g_lns, ol)
            if show_mid
                ml = line.new(x1=ts, y1=md, x2=x2_val, y2=md, xloc=xloc.bar_time, extend=ext, color=color.new(col, 45), width=lw, style=line.style_dashed)
                array.push(g_lns, ml)
            if show_lbl
                lbl_y = is_bul ? tp : bt
                lb    = label.new(ts, lbl_y, "[" + tag + "] OTE" + (is_bul ? " ▲" : " ▼"), xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_left, color=color.new(col, 20), textcolor=color.white, size=size.small)
                array.push(g_lbs, lb)
            shown += 1

// ── Detection ─────────────────────────────────────────────────────────────────
cap = max_zones * 2

tf1_bull_new = not na(tf1_bts) and (na(tf1_bts[1]) or tf1_bts != tf1_bts[1])
tf1_bear_new = not na(tf1_rts) and (na(tf1_rts[1]) or tf1_rts != tf1_rts[1])
tf2_bull_new = not na(tf2_bts) and (na(tf2_bts[1]) or tf2_bts != tf2_bts[1])
tf2_bear_new = not na(tf2_rts) and (na(tf2_rts[1]) or tf2_rts != tf2_rts[1])
tf3_bull_new = not na(tf3_bts) and (na(tf3_bts[1]) or tf3_bts != tf3_bts[1])
tf3_bear_new = not na(tf3_rts) and (na(tf3_rts[1]) or tf3_rts != tf3_rts[1])

if tf1_on and tf1_bull_new
    f_push(tf1_btop, tf1_bmid, tf1_bbot, tf1_bts, tf1_bswp, true,  tf1_top_a, tf1_mid_a, tf1_bot_a, tf1_ts_a, tf1_swp_a, tf1_bul_a, tf1_mit_a, tf1_mts_a, cap)
if tf1_on and tf1_bear_new
    f_push(tf1_rtop, tf1_rmid, tf1_rbot, tf1_rts, tf1_rswp, false, tf1_top_a, tf1_mid_a, tf1_bot_a, tf1_ts_a, tf1_swp_a, tf1_bul_a, tf1_mit_a, tf1_mts_a, cap)
if tf2_on and tf2_bull_new
    f_push(tf2_btop, tf2_bmid, tf2_bbot, tf2_bts, tf2_bswp, true,  tf2_top_a, tf2_mid_a, tf2_bot_a, tf2_ts_a, tf2_swp_a, tf2_bul_a, tf2_mit_a, tf2_mts_a, cap)
if tf2_on and tf2_bear_new
    f_push(tf2_rtop, tf2_rmid, tf2_rbot, tf2_rts, tf2_rswp, false, tf2_top_a, tf2_mid_a, tf2_bot_a, tf2_ts_a, tf2_swp_a, tf2_bul_a, tf2_mit_a, tf2_mts_a, cap)
if tf3_on and tf3_bull_new
    f_push(tf3_btop, tf3_bmid, tf3_bbot, tf3_bts, tf3_bswp, true,  tf3_top_a, tf3_mid_a, tf3_bot_a, tf3_ts_a, tf3_swp_a, tf3_bul_a, tf3_mit_a, tf3_mts_a, cap)
if tf3_on and tf3_bear_new
    f_push(tf3_rtop, tf3_rmid, tf3_rbot, tf3_rts, tf3_rswp, false, tf3_top_a, tf3_mid_a, tf3_bot_a, tf3_ts_a, tf3_swp_a, tf3_bul_a, tf3_mit_a, tf3_mts_a, cap)

// ── Mitigation checks ─────────────────────────────────────────────────────────
if tf1_on
    f_update(tf1_top_a, tf1_bot_a, tf1_bul_a, tf1_mit_a, tf1_mts_a)
if tf2_on
    f_update(tf2_top_a, tf2_bot_a, tf2_bul_a, tf2_mit_a, tf2_mts_a)
if tf3_on
    f_update(tf3_top_a, tf3_bot_a, tf3_bul_a, tf3_mit_a, tf3_mts_a)

// ── Rebuild all drawings at barstate.islast ───────────────────────────────────
if barstate.islast
    n_bx = array.size(g_bxs)
    if n_bx > 0
        for i = 0 to n_bx - 1
            box.delete(array.get(g_bxs, i))
    array.clear(g_bxs)

    n_ln = array.size(g_lns)
    if n_ln > 0
        for i = 0 to n_ln - 1
            line.delete(array.get(g_lns, i))
    array.clear(g_lns)

    n_lb = array.size(g_lbs)
    if n_lb > 0
        for i = 0 to n_lb - 1
            label.delete(array.get(g_lbs, i))
    array.clear(g_lbs)

    if tf1_on
        f_draw(tf1_top_a, tf1_mid_a, tf1_bot_a, tf1_ts_a, tf1_swp_a, tf1_bul_a, tf1_mit_a, tf1_mts_a, 1, tf1)
    if tf2_on
        f_draw(tf2_top_a, tf2_mid_a, tf2_bot_a, tf2_ts_a, tf2_swp_a, tf2_bul_a, tf2_mit_a, tf2_mts_a, 2, tf2)
    if tf3_on
        f_draw(tf3_top_a, tf3_mid_a, tf3_bot_a, tf3_ts_a, tf3_swp_a, tf3_bul_a, tf3_mit_a, tf3_mts_a, 3, tf3)

// ── Alerts ────────────────────────────────────────────────────────────────────
new_bull_ote = (tf1_on and tf1_bull_new) or (tf2_on and tf2_bull_new) or (tf3_on and tf3_bull_new)
new_bear_ote = (tf1_on and tf1_bear_new) or (tf2_on and tf2_bear_new) or (tf3_on and tf3_bear_new)

alertcondition(new_bull_ote, "Bullish OTE Zone", "{{ticker}} bullish OTE zone formed on {{interval}}")
alertcondition(new_bear_ote, "Bearish OTE Zone", "{{ticker}} bearish OTE zone formed on {{interval}}")
````
