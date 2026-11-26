# Order Blocks & Breakers (HTF)

- url: https://www.tradingview.com/script/VwXFh8Lg-Order-Blocks-Breakers-HTF/
- type: indicator
- pine_id: PUB;925baa72081b422cb278710131e3fc0b
- version: 1.0

## Description

[b]Order Blocks & Breakers (HTF)[/b]

Detects order blocks — the last opposite-colored candle before a decisive directional move — across up to three higher timeframes. A bullish OB is the last bearish candle before a bullish breakout; a bearish OB is the last bullish candle before a bearish breakdown. The SMC/ICT interpretation is that these are the candles where institutions accumulated or distributed positions, and price frequently returns to test them.
When an order block's defining edge fails — close below the bottom of a bullish OB, or close above the top of a bearish OB — the zone flips polarity and becomes a breaker. Former support becomes resistance, and vice versa. Breakers render in distinct colors so the flip is immediately visible without having to track which zone was originally which.

[b]How it works[/b]

For each of the three configured timeframes, the script runs OB detection inside request.security:[list]
[*]Bullish OB when close[1] < open[1] and close > high[1] — the previous candle was bearish, the current candle closed above the previous high. The OB is the previous bearish candle.
[*]Bearish OB when close[1] > open[1] and close < low[1] — the previous candle was bullish, the current candle closed below the previous low. The OB is the previous bullish candle.
[/list]
New OBs pass an optional minimum-size filter (height as percentage of ATR). On every chart bar, all stored zones are evaluated for two state transitions:[list=1]
[*]Mitigation — first interaction with the zone. Configurable as Tap (any wick reaches the zone) or Close inside (a bar closes within the zone).
[*]Breaker conversion — close pushes through the zone's defining edge, fully invalidating the original direction. The zone flips polarity and stays active in its new role.
[/list]
A zone is in one of three states at any time:[list]
[*]Active — unmitigated, full color, extends right
[*]Mitigated (but defining edge still holds) — dimmed, dashed, optional
[*]Breaker — fully violated, flipped polarity, distinct breaker color, extends right
[/list]
All boxes and labels are rebuilt on the last bar so styling and right-edge timestamps stay current.

[b]How to read it[/b]

Each timeframe is differentiated by border weight (thin → medium → thick), leaving color free to carry direction and state.
Four directional colors:[list]
[*]Bullish OB (default teal) — last bearish candle before an up-move; treat as support.
[*]Bearish OB (default red) — last bullish candle before a down-move; treat as resistance.
[*]Bull Breaker (default blue) — former bearish OB whose resistance failed. Now acts as support.
[*]Bear Breaker (default orange) — former bullish OB whose support failed. Now acts as resistance.
[/list]
The simple mental model: blue and teal are "expect a bounce up here"; orange and red are "expect rejection down here." Breakers are the role-reversal flavor of the same idea.
Labels on active zones show the timeframe, type (OB or BB), and the zone's height as a percentage of ATR — a quick read on whether the zone is structurally meaningful or barely-there noise.
When zones from different timeframes stack at the same price, that's confluence — and tends to matter more than any zone in isolation.

[b]Inputs[/b]
[list]
[*]Bullish / Bearish OBs — toggle each direction independently.
[*]Show Breakers — render flipped-polarity zones. Default on.
[*]Show mitigated OBs — keep mitigated, unbroken zones on chart. Default off, since these accumulate quickly.
[*]Labels — show or hide right-edge labels with timeframe, type, and ATR%. Default on.
[*]Max OBs (per TF) — cap on unmitigated zones drawn per timeframe per direction. Default 5.
[*]Mitigation — Tap (wick) or Close inside (bar closes within the zone). Default Tap.
[*]Min size (% of ATR) — filter out zones smaller than this percentage of ATR. Default 0 (no filter).
[*]ATR Length — period for the ATR used by the size filter and labels. Default 14.
[*]Timeframes 1/2/3 — defaults: 1H, 4H, Daily. Each independently enabled. TF3 off by default.
[*]Colors — bullish OB, bearish OB, bull breaker, bear breaker, mitigated.
[/list]
[b]Built-in alerts[/b]
[list]
[*]New Bullish OB — fires when a new bullish OB is detected on any enabled timeframe
[*]New Bearish OB — same, for bearish
[*]Price entered Bullish zone — fires the first bar price interacts with any active bullish OB or bull breaker (across all enabled timeframes)
[*]Price entered Bearish zone — same, for bearish
[/list]
The "entered" alerts treat OBs and breakers together — both are bullish (or bearish) zones regardless of how they originated.

[b]Notes[/b]

The breaker mechanic is what makes this indicator more than a labeled support/resistance tool. A bullish OB that holds is a support zone; a bullish OB that fully breaks becomes resistance — and that's structurally informative. Tracking the polarity flip keeps the zone in play instead of discarding it.
Mitigated-but-unbroken zones are off by default because they accumulate quickly and clutter the chart. Turn them on if you want to see which zones have been tested and defended without flipping.
Two mitigation styles, no "Full fill" option: for OBs, "Full fill" and "Breaker" describe the same event — the zone has been completely violated — so the breaker conversion replaces the third mitigation rule the FVG indicator offers.
OBs versus FVGs: an FVG is an unfilled price imbalance (a gap in the candles); an OB is a causally meaningful candle (the supposed source of institutional orders). The detection logic here is purely mechanical, so whether you accept the institutional-flow framing or just treat OBs as well-defined zones at recent inflection points, the indicator works the same way.
The framework here borrows from Smart Money Concepts / ICT trading. Whether you accept the underlying claim or just use OBs as a clean way to mark recent inflection candles, the indicator is purely mechanical: it finds the patterns and tracks how price behaves at them.
This is a structural tool, not a signal generator. It marks order blocks, tracks their state, and flags polarity flips.

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
//                Order Blocks & Breaker Blocks
//                ─────────────────────────────
//   Order blocks are the last opposite-coloured candle before a decisive
//   directional move — the last bearish candle before a bullish surge, or
//   the last bullish candle before a bearish breakdown. These zones mark
//   where institutions accumulated or distributed positions, and price
//   frequently returns to them for re-entry.
//
//   When an order block's support or resistance level fails completely
//   (price closes beyond its far edge), the zone flips polarity and
//   becomes a breaker block — former support becomes resistance, and
//   vice versa. Breakers render in a distinct colour so the flip is
//   immediately visible.
//
//   Choose up to three timeframes; each layer uses a progressively
//   thicker border so higher-timeframe zones always stand out.
//
//   Version: 1.0
// ─────────────────────────────────────────────────────────────────────────────

//@version=6
indicator("Order Blocks & Breakers (HTF)", shorttitle="Order B&B's", overlay=true, max_boxes_count=500, max_labels_count=500)

// ── Inputs ───────────────────────────────────────────────────────────────────
show_bull = input.bool(true,  "Bullish OBs",         group="Display")
show_bear = input.bool(true,  "Bearish OBs",         group="Display")
show_brk  = input.bool(true,  "Show Breakers",       group="Display", tooltip="Breakers are order blocks whose support or resistance has been fully violated. They flip polarity and remain active as zones in the opposite direction.")
show_mit  = input.bool(false, "Show mitigated OBs",  group="Display", tooltip="Keep dimmed, dashed zones for order blocks that price has already tested.")
show_lbl  = input.bool(true,  "Labels",              group="Display")
max_obs   = input.int(5,      "Max OBs (per TF)",    minval=1, maxval=20, group="Display")

mit_style = input.string("Tap", "Mitigation", options=["Tap", "Close inside"], group="Detection", tooltip="Tap: the first wick into the zone marks it as tested. Close inside: a bar must close within the zone boundaries.")
min_size  = input.float(0.0,  "Min size (% of ATR)", minval=0, step=0.1, group="Detection", tooltip="Ignore order blocks whose height is smaller than this percentage of ATR. 0 = no filter.")
atr_len   = input.int(14,     "ATR Length",          minval=1, group="Detection")

tf1_on = input.bool(true,  "TF 1", group="Timeframes", inline="tf1")
tf1    = input.timeframe("60",  "", group="Timeframes", inline="tf1")
tf2_on = input.bool(true,  "TF 2", group="Timeframes", inline="tf2")
tf2    = input.timeframe("240", "", group="Timeframes", inline="tf2")
tf3_on = input.bool(false, "TF 3", group="Timeframes", inline="tf3")
tf3    = input.timeframe("D",   "", group="Timeframes", inline="tf3")

bull_ob_col  = input.color(#26a69a, "Bullish OB",   group="Colors")
bear_ob_col  = input.color(#ef5350, "Bearish OB",   group="Colors")
bull_brk_col = input.color(#1565c0, "Bull Breaker", group="Colors", tooltip="Former bearish OB whose resistance failed — now acts as support.")
bear_brk_col = input.color(#e65100, "Bear Breaker", group="Colors", tooltip="Former bullish OB whose support failed — now acts as resistance.")
mit_col      = input.color(#787b86, "Mitigated",    group="Colors")

// ── TF data ───────────────────────────────────────────────────────────────────
f_raw() =>
    atr_v    = ta.atr(atr_len)
    bull_det = close[1] < open[1] and close > high[1]
    bear_det = close[1] > open[1] and close < low[1]
    [bull_det ? high[1] : float(na), bull_det ? low[1] : float(na), bull_det ? time[1] : int(na), bear_det ? high[1] : float(na), bear_det ? low[1] : float(na), bear_det ? time[1] : int(na), atr_v]

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
var bool[]  tf1_brk_a = array.new_bool(0)

var float[] tf2_top_a = array.new_float(0)
var float[] tf2_bot_a = array.new_float(0)
var int[]   tf2_ts_a  = array.new_int(0)
var bool[]  tf2_bul_a = array.new_bool(0)
var bool[]  tf2_mit_a = array.new_bool(0)
var int[]   tf2_mts_a = array.new_int(0)
var bool[]  tf2_brk_a = array.new_bool(0)

var float[] tf3_top_a = array.new_float(0)
var float[] tf3_bot_a = array.new_float(0)
var int[]   tf3_ts_a  = array.new_int(0)
var bool[]  tf3_bul_a = array.new_bool(0)
var bool[]  tf3_mit_a = array.new_bool(0)
var int[]   tf3_mts_a = array.new_int(0)
var bool[]  tf3_brk_a = array.new_bool(0)

// Drawing objects rebuilt in full at barstate.islast
var box[]   g_bxs = array.new<box>(0)
var label[] g_lbs = array.new<label>(0)

// ── Push helper ───────────────────────────────────────────────────────────────
f_push(tp, bt, ts, is_bull, top_a, bot_a, ts_a, bull_a, mit_a, mts_a, brk_a, cap) =>
    array.push(top_a,  tp)
    array.push(bot_a,  bt)
    array.push(ts_a,   ts)
    array.push(bull_a, is_bull)
    array.push(mit_a,  false)
    array.push(mts_a,  int(na))
    array.push(brk_a,  false)
    if array.size(top_a) > cap
        array.shift(top_a)
        array.shift(bot_a)
        array.shift(ts_a)
        array.shift(bull_a)
        array.shift(mit_a)
        array.shift(mts_a)
        array.shift(brk_a)

// ── State update — mitigation and breaker conversion ─────────────────────────
f_update(top_a, bot_a, bull_a, mit_a, mts_a, brk_a) =>
    n = array.size(brk_a)
    if n > 0
        for i = 0 to n - 1
            if not array.get(brk_a, i)
                tp   = array.get(top_a, i)
                bt   = array.get(bot_a, i)
                is_b = array.get(bull_a, i)
                broke = is_b ? close < bt : close > tp
                if broke
                    array.set(brk_a, i, true)
                    if not array.get(mit_a, i)
                        array.set(mit_a, i, true)
                        array.set(mts_a, i, time)
                else if not array.get(mit_a, i)
                    tapped    = is_b ? low <= tp : high >= bt
                    closed_in = close >= bt and close <= tp
                    hit = mit_style == "Tap" ? tapped : closed_in
                    if hit
                        array.set(mit_a, i, true)
                        array.set(mts_a, i, time)

// ── Zone presence — for alerts ────────────────────────────────────────────────
f_in_zones(top_a, bot_a, bul_a, mit_a, brk_a) =>
    rb = false
    rr = false
    n = array.size(mit_a)
    if n > 0
        for i = 0 to n - 1
            is_m   = array.get(mit_a,  i)
            is_brk = array.get(brk_a,  i)
            if is_m and not is_brk
                continue
            tp     = array.get(top_a, i)
            bt     = array.get(bot_a, i)
            is_bul = array.get(bul_a, i)
            is_bull_zone = (is_bul and not is_brk) or (not is_bul and is_brk)
            if low <= tp and high >= bt
                if is_bull_zone
                    rb := true
                else
                    rr := true
    [rb, rr]

// ── Draw — called once at barstate.islast ─────────────────────────────────────
f_draw(top_a, bot_a, ts_a, bull_a, mit_a, mts_a, brk_a, atr_ref, lw, tag) =>
    n = array.size(top_a)
    if n > 0
        bc = 0
        rc = 0
        for i = n - 1 to 0
            tp     = array.get(top_a,  i)
            bt     = array.get(bot_a,  i)
            ts     = array.get(ts_a,   i)
            is_bul = array.get(bull_a, i)
            is_m   = array.get(mit_a,  i)
            is_brk = array.get(brk_a,  i)
            is_bull_zone = (is_bul and not is_brk) or (not is_bul and is_brk)
            if is_brk
                if not show_brk
                    continue
            else if is_m
                if not show_mit
                    continue
            else
                if is_bul
                    if not show_bull
                        continue
                    bc += 1
                    if bc > max_obs
                        continue
                else
                    if not show_bear
                        continue
                    rc += 1
                    if rc > max_obs
                        continue
            ob_col  = is_bul ? bull_ob_col  : bear_ob_col
            brk_col = is_bul ? bear_brk_col : bull_brk_col
            col     = is_brk ? brk_col : ob_col
            z_col   = is_m and not is_brk ? mit_col : col
            r_ts    = is_m and not is_brk ? array.get(mts_a, i) : time
            ext     = is_m and not is_brk ? extend.none : extend.right
            b_sty   = is_m and not is_brk ? line.style_dashed : line.style_solid
            t_bg    = is_m and not is_brk ? 92 : 85
            t_bd    = is_m and not is_brk ? 55 : 20
            bx      = box.new(left=ts, top=tp, right=r_ts, bottom=bt, border_color=color.new(z_col, t_bd), border_width=lw, border_style=b_sty, extend=ext, xloc=xloc.bar_time, bgcolor=color.new(z_col, t_bg))
            array.push(g_bxs, bx)
            if show_lbl and not (is_m and not is_brk)
                lbl_txt = "[" + tag + "] " + (is_brk ? "BB" : "OB") + (atr_ref > 0 ? "\n" + str.tostring(math.round((tp - bt) / atr_ref * 100, 1)) + "% ATR" : "")
                lb_col  = color.new(col, 15)
                lb      = label.new(time, (tp + bt) / 2.0, lbl_txt, xloc=xloc.bar_time, yloc=yloc.price, style=is_bull_zone ? label.style_label_left : label.style_label_left, color=lb_col, textcolor=color.white, size=size.small)
                array.push(g_lbs, lb)

// ── Detection ─────────────────────────────────────────────────────────────────
cap = max_obs * 3

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
        f_push(tf1_b_top, tf1_b_bot, tf1_b_ts, true,  tf1_top_a, tf1_bot_a, tf1_ts_a, tf1_bul_a, tf1_mit_a, tf1_mts_a, tf1_brk_a, cap)

if tf1_on and show_bear and tf1_new_bear
    gap = tf1_r_top - tf1_r_bot
    if min_size == 0.0 or gap / tf1_atr_safe * 100 >= min_size
        f_push(tf1_r_top, tf1_r_bot, tf1_r_ts, false, tf1_top_a, tf1_bot_a, tf1_ts_a, tf1_bul_a, tf1_mit_a, tf1_mts_a, tf1_brk_a, cap)

if tf2_on and show_bull and tf2_new_bull
    gap = tf2_b_top - tf2_b_bot
    if min_size == 0.0 or gap / tf2_atr_safe * 100 >= min_size
        f_push(tf2_b_top, tf2_b_bot, tf2_b_ts, true,  tf2_top_a, tf2_bot_a, tf2_ts_a, tf2_bul_a, tf2_mit_a, tf2_mts_a, tf2_brk_a, cap)

if tf2_on and show_bear and tf2_new_bear
    gap = tf2_r_top - tf2_r_bot
    if min_size == 0.0 or gap / tf2_atr_safe * 100 >= min_size
        f_push(tf2_r_top, tf2_r_bot, tf2_r_ts, false, tf2_top_a, tf2_bot_a, tf2_ts_a, tf2_bul_a, tf2_mit_a, tf2_mts_a, tf2_brk_a, cap)

if tf3_on and show_bull and tf3_new_bull
    gap = tf3_b_top - tf3_b_bot
    if min_size == 0.0 or gap / tf3_atr_safe * 100 >= min_size
        f_push(tf3_b_top, tf3_b_bot, tf3_b_ts, true,  tf3_top_a, tf3_bot_a, tf3_ts_a, tf3_bul_a, tf3_mit_a, tf3_mts_a, tf3_brk_a, cap)

if tf3_on and show_bear and tf3_new_bear
    gap = tf3_r_top - tf3_r_bot
    if min_size == 0.0 or gap / tf3_atr_safe * 100 >= min_size
        f_push(tf3_r_top, tf3_r_bot, tf3_r_ts, false, tf3_top_a, tf3_bot_a, tf3_ts_a, tf3_bul_a, tf3_mit_a, tf3_mts_a, tf3_brk_a, cap)

// ── State update every bar ────────────────────────────────────────────────────
f_update(tf1_top_a, tf1_bot_a, tf1_bul_a, tf1_mit_a, tf1_mts_a, tf1_brk_a)
f_update(tf2_top_a, tf2_bot_a, tf2_bul_a, tf2_mit_a, tf2_mts_a, tf2_brk_a)
f_update(tf3_top_a, tf3_bot_a, tf3_bul_a, tf3_mit_a, tf3_mts_a, tf3_brk_a)

// ── Alert booleans ────────────────────────────────────────────────────────────
new_bull_ob = (tf1_on and tf1_new_bull) or (tf2_on and tf2_new_bull) or (tf3_on and tf3_new_bull)
new_bear_ob = (tf1_on and tf1_new_bear) or (tf2_on and tf2_new_bear) or (tf3_on and tf3_new_bear)

[b1, r1] = f_in_zones(tf1_top_a, tf1_bot_a, tf1_bul_a, tf1_mit_a, tf1_brk_a)
[b2, r2] = f_in_zones(tf2_top_a, tf2_bot_a, tf2_bul_a, tf2_mit_a, tf2_brk_a)
[b3, r3] = f_in_zones(tf3_top_a, tf3_bot_a, tf3_bul_a, tf3_mit_a, tf3_brk_a)
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
        f_draw(tf1_top_a, tf1_bot_a, tf1_ts_a, tf1_bul_a, tf1_mit_a, tf1_mts_a, tf1_brk_a, tf1_atr_safe, 1, tf1)
    if tf2_on
        f_draw(tf2_top_a, tf2_bot_a, tf2_ts_a, tf2_bul_a, tf2_mit_a, tf2_mts_a, tf2_brk_a, tf2_atr_safe, 2, tf2)
    if tf3_on
        f_draw(tf3_top_a, tf3_bot_a, tf3_ts_a, tf3_bul_a, tf3_mit_a, tf3_mts_a, tf3_brk_a, tf3_atr_safe, 3, tf3)

// ── Alerts ────────────────────────────────────────────────────────────────────
alertcondition(new_bull_ob, "New Bullish OB",  "{{ticker}} bullish order block detected on {{interval}}")
alertcondition(new_bear_ob, "New Bearish OB",  "{{ticker}} bearish order block detected on {{interval}}")
alertcondition(in_bull and not in_bull[1], "Price entered Bullish zone", "{{ticker}} price entered a bullish OB or breaker on {{interval}}")
alertcondition(in_bear and not in_bear[1], "Price entered Bearish zone", "{{ticker}} price entered a bearish OB or breaker on {{interval}}")
````
