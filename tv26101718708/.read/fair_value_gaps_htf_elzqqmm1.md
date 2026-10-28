# Fair Value Gaps (HTF)

- url: https://www.tradingview.com/script/ELzQQMm1-Fair-Value-Gaps-HTF/
- type: indicator
- pine_id: PUB;0c833622f34a4f3684fa555a23b994c7
- version: 1.0

## Description

[b]Fair Value Gaps (HTF)[/b]

Detects three-candle imbalance patterns — fair value gaps — across up to three higher timeframes, plotted as filled zones on the chart. A bullish FVG forms when a strong up-displacement leaves an unfilled gap between the previous candle's high and the next candle's low. A bearish FVG is the mirror: a down-displacement leaves a gap between the previous low and the next high.
Each timeframe renders with a distinct border weight (thin → medium → thick), so higher-timeframe FVGs stand out at a glance without colliding with the bullish/bearish colors. Active zones extend to the right until price mitigates them; mitigated zones are dimmed and optionally kept on chart for context.

[b]How it works[/b]
For each of the three configured timeframes, the script runs FVG detection inside request.security:[list]
[*]Bullish FVG when low > high[2] — the current bar's low sits above the high two bars ago, leaving an unfilled gap on the middle candle.
[*]Bearish FVG when high < low[2] — the current bar's high sits below the low two bars ago.
[/list]
New FVGs are added to the timeframe's history if they pass the optional minimum-size filter (gap height as a percentage of ATR). On every chart bar, all unmitigated FVGs are checked against current price using the configured mitigation rule:[list]
[*]Tap — first wick touches the zone
[*]Close inside — bar closes inside the zone
[*]Full fill — close moves beyond the far boundary
[/list]
Once a zone is mitigated, the mitigation timestamp is stored, the zone stops extending right, and it re-renders dimmed and dashed. All boxes and labels are rebuilt on the last bar so styling stays current.

[b]How to read it[/b]

Each timeframe is differentiated by border weight: thin for TF1, medium for TF2, thick for TF3. This lets the colors carry direction (bullish vs bearish) while the borders carry timeframe — useful when zones from multiple horizons stack up in the same area, since the relative weight tells you which is the more structural anchor.
Active zones extend to the right edge. Their labels show timeframe, type (BFVG / SFVG), and the gap size as a percentage of ATR — a quick read on whether the zone is structurally meaningful or barely-there noise.
Mitigated zones stop at their mitigation point, switch to a dashed border, and fade. They're optional context — turn them off if the chart gets busy, leave them on to track historical zones that have already been worked.
When zones from different timeframes stack at the same price, that's confluence. A small intraday FVG sitting inside an unmitigated daily FVG is structurally more interesting than either zone in isolation.

[b]Inputs[/b]
[list]
[*]Bullish / Bearish FVGs — toggle each direction independently.
[*]Show mitigated — keep mitigated zones on chart as historical context. Default on.
[*]Labels — show or hide the right-edge label with timeframe, type, and ATR%. Default on.
[*]Max FVGs (per TF) — cap on the number of unmitigated zones drawn per timeframe. Default 10.
[*]Mitigation trigger — Tap, Close inside, or Full fill. Default Tap.
[*]Min size (% of ATR) — filter out FVGs smaller than this percentage of ATR. Default 0 (no filter).
[*]ATR Length — period for the ATR used by the size filter and the labels. Default 14.
[*]Timeframes 1/2/3 — defaults: 15min, 1H, Daily. Each independently enabled. TF3 off by default.
[*]Colors — bullish, bearish, mitigated.
[/list]
[b]Built-in alerts[/b]
[list]
[*]New Bullish FVG — fires when a new bullish FVG is detected on any enabled timeframe
[*]New Bearish FVG — same, for bearish
[*]Price entered Bullish FVG — fires the first bar price interacts with any unmitigated bullish FVG (across all enabled timeframes)
[*]Price entered Bearish FVG — same, for bearish
[/list]
The "entered" alerts use the active mitigation rule, so changing the mitigation trigger changes when these fire.

[b]Notes[/b]

The three mitigation rules answer different questions. Tap flags the moment any wick reaches the zone — useful for traders who fade the first touch. Close inside waits for confirmation that price is actually trading inside the gap rather than just probing it. Full fill is the strictest — the gap is only "mitigated" once price has cleared the far side. Most SMC/ICT material assumes Tap; classical price-action work tends toward Close inside or Full fill. The right choice depends on how you intend to act on the zone, not on which is "correct."
The min-size filter expressed as a percentage of ATR is more useful than an absolute size threshold. It scales naturally across instruments and timeframes — setting it to 25%, for example, ignores any FVG smaller than a quarter of recent average true range without forcing you to retune per ticker.
The default timeframes (15min, 1H, Daily) are tuned for intraday and short-swing work, where FVGs are most actively used. For higher-timeframe structural FVGs, push them up — Daily, Weekly, Monthly is a reasonable swing/position setup.
The framework here borrows from Smart Money Concepts / ICT trading, where the underlying claim is that price tends to return to fill imbalances before continuing. Whether you accept that as causal or just descriptive, the indicator is purely mechanical: it finds the patterns and tracks whether they've been touched.
This is a structural tool, not a signal generator. It marks where displacement left an imbalance and tracks whether price has revisited it.

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
//                Fair Value Gaps (FVG)
//                ─────────────────────
//   Detects bullish and bearish fair value gaps — three-candle imbalance
//   patterns where the middle candle's displacement leaves a gap between
//   the first candle's wick and the third candle's wick. Choose up to
//   three timeframes independently; each set of zones renders with a
//   distinct border weight (thin → thick) so higher-timeframe gaps stand
//   out at a glance. Active zones extend to the right until price mitigates
//   them. Mitigated zones are dimmed and optionally kept as historical
//   context.
//
//   Version: 1.0
// ─────────────────────────────────────────────────────────────────────────────

//@version=6
indicator("Fair Value Gaps (HTF)", shorttitle="Fair Value Gaps (HTF)", overlay=true, max_boxes_count=500, max_labels_count=500)

// ── Inputs ───────────────────────────────────────────────────────────────────
show_bull = input.bool(true,  "Bullish FVGs",       group="Display")
show_bear = input.bool(true,  "Bearish FVGs",       group="Display")
show_mit  = input.bool(true,  "Show mitigated",     group="Display", tooltip="Keep mitigated zones on chart as historical context.")
show_lbl  = input.bool(true,  "Labels",             group="Display")
max_fvgs  = input.int(10,     "Max FVGs (per TF)",  minval=1, maxval=50, group="Display")

mit_style = input.string("Tap", "Mitigation trigger", options=["Tap", "Close inside", "Full fill"], group="Detection", tooltip="Tap: first wick into the zone. Close inside: bar closes inside the zone. Full fill: close beyond the far boundary.")
min_size  = input.float(0.0,  "Min size (% of ATR)", minval=0, step=0.1, group="Detection")
atr_len   = input.int(14,     "ATR Length",          minval=1, group="Detection")

tf1_on = input.bool(true,  "TF 1", group="Timeframes", inline="tf1")
tf1    = input.timeframe("15", "",  group="Timeframes", inline="tf1")
tf2_on = input.bool(true,  "TF 2", group="Timeframes", inline="tf2")
tf2    = input.timeframe("60", "",  group="Timeframes", inline="tf2")
tf3_on = input.bool(false, "TF 3", group="Timeframes", inline="tf3")
tf3    = input.timeframe("D",  "",  group="Timeframes", inline="tf3")

bull_col = input.color(#26a69a, "Bullish",   group="Colors")
bear_col = input.color(#ef5350, "Bearish",   group="Colors")
mit_col  = input.color(#787b86, "Mitigated", group="Colors")

// ── TF data ───────────────────────────────────────────────────────────────────
f_raw() =>
    bull_det = low > high[2]
    bear_det = high < low[2]
    [bull_det ? low : float(na), bull_det ? high[2] : float(na), bull_det ? time[2] : int(na), bear_det ? low[2] : float(na), bear_det ? high : float(na), bear_det ? time[2] : int(na), ta.atr(atr_len)]

[tf1_b_top, tf1_b_bot, tf1_b_ts, tf1_r_top, tf1_r_bot, tf1_r_ts, tf1_atr_raw] = request.security(syminfo.tickerid, tf1, f_raw())
[tf2_b_top, tf2_b_bot, tf2_b_ts, tf2_r_top, tf2_r_bot, tf2_r_ts, tf2_atr_raw] = request.security(syminfo.tickerid, tf2, f_raw())
[tf3_b_top, tf3_b_bot, tf3_b_ts, tf3_r_top, tf3_r_bot, tf3_r_ts, tf3_atr_raw] = request.security(syminfo.tickerid, tf3, f_raw())

// ── Storage ───────────────────────────────────────────────────────────────────
var float[] tf1_top_a = array.new_float(0)
var float[] tf1_bot_a = array.new_float(0)
var int[]   tf1_ts_a  = array.new_int(0)
var bool[]  tf1_bul_a = array.new_bool(0)
var bool[]  tf1_mit_a = array.new_bool(0)
var int[]   tf1_mts_a = array.new_int(0)

var float[] tf2_top_a = array.new_float(0)
var float[] tf2_bot_a = array.new_float(0)
var int[]   tf2_ts_a  = array.new_int(0)
var bool[]  tf2_bul_a = array.new_bool(0)
var bool[]  tf2_mit_a = array.new_bool(0)
var int[]   tf2_mts_a = array.new_int(0)

var float[] tf3_top_a = array.new_float(0)
var float[] tf3_bot_a = array.new_float(0)
var int[]   tf3_ts_a  = array.new_int(0)
var bool[]  tf3_bul_a = array.new_bool(0)
var bool[]  tf3_mit_a = array.new_bool(0)
var int[]   tf3_mts_a = array.new_int(0)

// Drawing objects rebuilt in full at barstate.islast
var box[]   g_bxs = array.new<box>(0)
var label[] g_lbs = array.new<label>(0)

// ── Push helper ───────────────────────────────────────────────────────────────
f_push(tp, bt, ts, is_bull, top_a, bot_a, ts_a, bull_a, mit_a, mts_a, cap) =>
    array.push(top_a,  tp)
    array.push(bot_a,  bt)
    array.push(ts_a,   ts)
    array.push(bull_a, is_bull)
    array.push(mit_a,  false)
    array.push(mts_a,  int(na))
    if array.size(top_a) > cap
        array.shift(top_a)
        array.shift(bot_a)
        array.shift(ts_a)
        array.shift(bull_a)
        array.shift(mit_a)
        array.shift(mts_a)

// ── Mitigation ──────────────────
f_mit(top_a, bot_a, bull_a, mit_a, mts_a) =>
    n = array.size(mit_a)
    if n > 0
        for i = 0 to n - 1
            if not array.get(mit_a, i)
                tp   = array.get(top_a, i)
                bt   = array.get(bot_a, i)
                is_b = array.get(bull_a, i)
                tapped    = is_b ? low <= tp : high >= bt
                closed_in = close >= bt and close <= tp
                full_fill = is_b ? close < bt : close > tp
                hit = mit_style == "Tap" ? tapped : mit_style == "Close inside" ? closed_in : full_fill
                if hit
                    array.set(mit_a, i, true)
                    array.set(mts_a, i, time)

// ── Zone presence check ───────────────────────────────────────────────────────
f_in_zones(top_a, bot_a, bul_a, mit_a) =>
    rb = false
    rr = false
    n = array.size(mit_a)
    if n > 0
        for i = 0 to n - 1
            if not array.get(mit_a, i)
                tp = array.get(top_a, i)
                bt = array.get(bot_a, i)
                if array.get(bul_a, i) and low <= tp and high >= bt
                    rb := true
                if not array.get(bul_a, i) and high >= bt and low <= tp
                    rr := true
    [rb, rr]

// ── Draw — called once at barstate.islast ─────────────────────────────────────
f_draw(top_a, bot_a, ts_a, bull_a, mit_a, mts_a, atr_ref, lw, tag) =>
    n = array.size(top_a)
    if n > 0
        bc = 0
        rc = 0
        for i = n - 1 to 0
            tp   = array.get(top_a,  i)
            bt   = array.get(bot_a,  i)
            ts   = array.get(ts_a,   i)
            bull = array.get(bull_a, i)
            is_m = array.get(mit_a,  i)
            if not is_m
                if bull
                    bc += 1
                    if bc > max_fvgs
                        continue
                else
                    rc += 1
                    if rc > max_fvgs
                        continue
            else
                if not show_mit
                    continue
            col   = bull ? bull_col : bear_col
            z_col = is_m ? mit_col : col
            r_ts  = is_m ? array.get(mts_a, i) : time
            ext   = is_m ? extend.none : extend.right
            b_sty = is_m ? line.style_dashed : line.style_solid
            bx    = box.new(left=ts, top=tp, right=r_ts, bottom=bt, border_color=color.new(z_col, is_m ? 55 : 20), border_width=lw, border_style=b_sty, extend=ext, xloc=xloc.bar_time, bgcolor=color.new(z_col, is_m ? 92 : 85))
            array.push(g_bxs, bx)
            if show_lbl and not is_m
                lbl_txt = "[" + tag + "] " + (bull ? "BFVG" : "SFVG") + (atr_ref > 0 ? "\n" + str.tostring(math.round((tp - bt) / atr_ref * 100, 1)) + "% ATR" : "")
                lb = label.new(time, (tp + bt) / 2.0, lbl_txt, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_left, color=color.new(col, 15), textcolor=color.white, size=size.small)
                array.push(g_lbs, lb)

// ── Detection ─────────────────────────────────────────────────────────────────
cap = max_fvgs * 3

tf1_atr_safe = na(tf1_atr_raw) or tf1_atr_raw <= 0 ? 1.0 : tf1_atr_raw
tf2_atr_safe = na(tf2_atr_raw) or tf2_atr_raw <= 0 ? 1.0 : tf2_atr_raw
tf3_atr_safe = na(tf3_atr_raw) or tf3_atr_raw <= 0 ? 1.0 : tf3_atr_raw

tf1_new_bull = not na(tf1_b_ts) and (na(tf1_b_ts[1]) or tf1_b_ts != tf1_b_ts[1])
tf1_new_bear = not na(tf1_r_ts) and (na(tf1_r_ts[1]) or tf1_r_ts != tf1_r_ts[1])
tf2_new_bull = not na(tf2_b_ts) and (na(tf2_b_ts[1]) or tf2_b_ts != tf2_b_ts[1])
tf2_new_bear = not na(tf2_r_ts) and (na(tf2_r_ts[1]) or tf2_r_ts != tf2_r_ts[1])
tf3_new_bull = not na(tf3_b_ts) and (na(tf3_b_ts[1]) or tf3_b_ts != tf3_b_ts[1])
tf3_new_bear = not na(tf3_r_ts) and (na(tf3_r_ts[1]) or tf3_r_ts != tf3_r_ts[1])

if tf1_on and show_bull and tf1_new_bull
    gap = tf1_b_top - tf1_b_bot
    if min_size == 0.0 or gap / tf1_atr_safe * 100 >= min_size
        f_push(tf1_b_top, tf1_b_bot, tf1_b_ts, true,  tf1_top_a, tf1_bot_a, tf1_ts_a, tf1_bul_a, tf1_mit_a, tf1_mts_a, cap)

if tf1_on and show_bear and tf1_new_bear
    gap = tf1_r_top - tf1_r_bot
    if min_size == 0.0 or gap / tf1_atr_safe * 100 >= min_size
        f_push(tf1_r_top, tf1_r_bot, tf1_r_ts, false, tf1_top_a, tf1_bot_a, tf1_ts_a, tf1_bul_a, tf1_mit_a, tf1_mts_a, cap)

if tf2_on and show_bull and tf2_new_bull
    gap = tf2_b_top - tf2_b_bot
    if min_size == 0.0 or gap / tf2_atr_safe * 100 >= min_size
        f_push(tf2_b_top, tf2_b_bot, tf2_b_ts, true,  tf2_top_a, tf2_bot_a, tf2_ts_a, tf2_bul_a, tf2_mit_a, tf2_mts_a, cap)

if tf2_on and show_bear and tf2_new_bear
    gap = tf2_r_top - tf2_r_bot
    if min_size == 0.0 or gap / tf2_atr_safe * 100 >= min_size
        f_push(tf2_r_top, tf2_r_bot, tf2_r_ts, false, tf2_top_a, tf2_bot_a, tf2_ts_a, tf2_bul_a, tf2_mit_a, tf2_mts_a, cap)

if tf3_on and show_bull and tf3_new_bull
    gap = tf3_b_top - tf3_b_bot
    if min_size == 0.0 or gap / tf3_atr_safe * 100 >= min_size
        f_push(tf3_b_top, tf3_b_bot, tf3_b_ts, true,  tf3_top_a, tf3_bot_a, tf3_ts_a, tf3_bul_a, tf3_mit_a, tf3_mts_a, cap)

if tf3_on and show_bear and tf3_new_bear
    gap = tf3_r_top - tf3_r_bot
    if min_size == 0.0 or gap / tf3_atr_safe * 100 >= min_size
        f_push(tf3_r_top, tf3_r_bot, tf3_r_ts, false, tf3_top_a, tf3_bot_a, tf3_ts_a, tf3_bul_a, tf3_mit_a, tf3_mts_a, cap)

// ── Mitigation check every bar ────────────────────────────────────────────────
f_mit(tf1_top_a, tf1_bot_a, tf1_bul_a, tf1_mit_a, tf1_mts_a)
f_mit(tf2_top_a, tf2_bot_a, tf2_bul_a, tf2_mit_a, tf2_mts_a)
f_mit(tf3_top_a, tf3_bot_a, tf3_bul_a, tf3_mit_a, tf3_mts_a)

// ── Alert booleans ────────────────────────────────────────────────────────────
new_bull_fvg = (tf1_on and tf1_new_bull) or (tf2_on and tf2_new_bull) or (tf3_on and tf3_new_bull)
new_bear_fvg = (tf1_on and tf1_new_bear) or (tf2_on and tf2_new_bear) or (tf3_on and tf3_new_bear)

[b1, r1] = f_in_zones(tf1_top_a, tf1_bot_a, tf1_bul_a, tf1_mit_a)
[b2, r2] = f_in_zones(tf2_top_a, tf2_bot_a, tf2_bul_a, tf2_mit_a)
[b3, r3] = f_in_zones(tf3_top_a, tf3_bot_a, tf3_bul_a, tf3_mit_a)
in_bull = b1 or b2 or b3
in_bear = r1 or r2 or r3

// ── Rebuild all drawings at barstate.islast ───────────────────────────────────
if barstate.islast
    n_bx = array.size(g_bxs)
    if n_bx > 0
        for i = 0 to n_bx - 1
            box.delete(array.get(g_bxs, i))
    array.clear(g_bxs)

    n_lb = array.size(g_lbs)
    if n_lb > 0
        for i = 0 to n_lb - 1
            label.delete(array.get(g_lbs, i))
    array.clear(g_lbs)

    if tf1_on
        f_draw(tf1_top_a, tf1_bot_a, tf1_ts_a, tf1_bul_a, tf1_mit_a, tf1_mts_a, tf1_atr_safe, 1, tf1)
    if tf2_on
        f_draw(tf2_top_a, tf2_bot_a, tf2_ts_a, tf2_bul_a, tf2_mit_a, tf2_mts_a, tf2_atr_safe, 2, tf2)
    if tf3_on
        f_draw(tf3_top_a, tf3_bot_a, tf3_ts_a, tf3_bul_a, tf3_mit_a, tf3_mts_a, tf3_atr_safe, 3, tf3)

// ── Alerts ────────────────────────────────────────────────────────────────────
alertcondition(new_bull_fvg, "New Bullish FVG", "{{ticker}} bullish FVG detected on {{interval}}")
alertcondition(new_bear_fvg, "New Bearish FVG", "{{ticker}} bearish FVG detected on {{interval}}")
alertcondition(in_bull and not in_bull[1], "Price entered Bullish FVG", "{{ticker}} price entered a bullish FVG on {{interval}}")
alertcondition(in_bear and not in_bear[1], "Price entered Bearish FVG", "{{ticker}} price entered a bearish FVG on {{interval}}")
````
