# Market Structure (HTF)

- url: https://www.tradingview.com/script/25ImnUkS-Market-Structure-HTF/
- type: indicator
- pine_id: PUB;e5b02dd298b049c282a920e1accd861f
- version: 1.0

## Description

[b]Market Structure (HTF)[/b]

Tracks the two most-watched events in market-structure analysis — Break of Structure (BOS) and Change of Character (ChoCH) — across up to three independently configurable timeframes.
A BOS is when price closes through a swing level in the same direction as the prevailing trend. It confirms continuation: an uptrend taking out a recent swing high, a downtrend taking out a recent swing low.
A ChoCH is when price closes through a swing level against the prevailing trend. It's the first mechanical sign that the structure may be flipping — an uptrend that takes out a swing low, a downtrend that takes out a swing high.
Each event is drawn as a horizontal line from the swing to the break bar, plus a label on the break bar itself.

[b]How it works[/b]

For each of the three configured timeframes, the script runs pivot detection inside request.security and tracks three things:[list]
[*]The most recent unbroken swing high — the upside structure to defend or break
[*]The most recent unbroken swing low — the downside structure to defend or break
[*]The current trend state — bullish or bearish, updated by every confirmed break
[/list]
When close goes beyond either watched swing, an event fires:[list]
[*]Same direction as current trend → BOS (continuation)
[*]Opposite direction → ChoCH (potential reversal). The trend state then flips.[/list]
After a break, that swing is cleared and the next confirmed pivot in the same direction becomes the new watched swing.

[b]How to read it[/b]

Each event is drawn as a horizontal line from the swing point to the bar where the break was confirmed. Color carries direction: bullish events teal, bearish red. Style carries the type:[list]
[*]BOS lines — solid
[*]ChoCH lines — dashed[/list]
Each timeframe gets a progressively thicker line weight (thin → medium → thick), so higher-timeframe events naturally stand out.
A BOS or ChoCH label appears on the break bar — below the candle for bullish, above for bearish. Labels are placed off the wick to avoid overlap with the candle itself.
The structural read across timeframes: a low-timeframe ChoCH inside an unbroken higher-timeframe BOS direction is usually a pullback, not a reversal. A low-timeframe ChoCH that aligns with a higher-timeframe ChoCH is a stronger reversal signal. The indicator plots the events; reading them in concert is the user's job.

[b]Inputs[/b][list]
[*]Show BOS / ChoCH — toggle either event type independently. Default both on.
[*]Labels — show or hide the BOS/ChoCH text labels on break bars. Default on.
[*]Max events (per TF) — cap on stored events drawn per timeframe. Default 15.
[*]Pivot Length — bars required on each side to confirm a swing. Default 5. Higher values filter out minor swings and produce fewer, more significant events.
[*]Timeframes 1/2/3 — defaults: 1H, 4H, Daily. Each independently enabled. TF3 off by default.
[*]Colors — bullish and bearish.[/list]

[b]Built-in alerts[/b][list]
[*]Bullish BOS — fires when a bullish BOS is confirmed on any enabled timeframe
[*]Bearish BOS — same, for bearish
[*]Bullish ChoCH — fires when a bullish ChoCH is confirmed on any enabled timeframe
[*]Bearish ChoCH — same, for bearish[/list]

[b]Notes[/b]

The trend-state machine starts assuming bullish at chart open. If the actual structure at the start of available data is bearish, the very first event may be classified incorrectly — e.g. a bearish break flagged as ChoCH when it's really BOS. The state self-corrects after one full cycle, so this only affects the leftmost edge of the chart and is usually invisible by the time you're looking at recent price action.
The pivot length is the most consequential setting. A length of 5 catches most meaningful intraday and swing structure. Smaller values (2–3) produce many minor BOS/ChoCH events that mostly reflect noise; larger values (8+) restrict to major structural breaks but can lag substantially. Pick a value that matches how you define "the" trend on the timeframe you're watching.
Higher-timeframe pivots don't confirm until pivot length bars after the actual swing. On a Daily timeframe with length 5, that's five days of delay. Events are non-repainting once printed, but they appear later than the actual high or low.
The framework here borrows from Smart Money Concepts / ICT trading, where market structure is the foundation for multi-timeframe bias. The detection is purely mechanical — close-through-swing — so it captures the spirit of the framework without trying to encode any subjective judgment about which break "really counts."
This is a structural tool, not a signal generator. It marks where structure has continued or shifted on each timeframe.

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
//                Market Structure (BOS / ChoCH)
//                ────────────────────────────────
//   Tracks pivot-based market structure across three independently
//   configurable timeframes. Each confirmed swing high and swing low is
//   classified as a Higher High, Higher Low, Lower High, or Lower Low.
//
//   Break of Structure (BOS): price closes through a swing level in the
//   same direction as the prevailing trend — a continuation signal.
//
//   Change of Character (ChoCH): price closes through a swing level
//   against the current structure — the first sign of a potential reversal.
//
//   Each event is drawn as a horizontal line from the swing point to the
//   bar where the break was confirmed. A plotshape label appears at the
//   break bar, anchored outside the candle range so it never overlaps wicks.
//   BOS lines are solid; ChoCH lines are dashed. Line weight increases with
//   timeframe so higher-timeframe events are always the most prominent.
//
//   Version: 1.1
// ─────────────────────────────────────────────────────────────────────────────

//@version=6
indicator("Market Structure (HTF)", shorttitle="MS", overlay=true, max_lines_count=500)

// ── Inputs ───────────────────────────────────────────────────────────────────
show_bos   = input.bool(true, "Show BOS",   group="Display", tooltip="Break of Structure — confirms trend continuation when price closes through a swing in the prevailing direction.")
show_choch = input.bool(true, "Show ChoCH", group="Display", tooltip="Change of Character — price closes through a swing against the trend, signalling a potential reversal.")
show_lbl   = input.bool(true, "Labels",     group="Display")
max_lines  = input.int(15,   "Max events (per TF)", minval=1, maxval=50, group="Display")

struct_len = input.int(5, "Pivot Length", minval=2, maxval=20, group="Detection", tooltip="Bars required on each side of a swing high or low to confirm the pivot. Higher values filter out minor swings and generate fewer, more significant events.")

tf1_on = input.bool(true,  "TF 1", group="Timeframes", inline="tf1")
tf1    = input.timeframe("60",  "", group="Timeframes", inline="tf1")
tf2_on = input.bool(true,  "TF 2", group="Timeframes", inline="tf2")
tf2    = input.timeframe("240", "", group="Timeframes", inline="tf2")
tf3_on = input.bool(false, "TF 3", group="Timeframes", inline="tf3")
tf3    = input.timeframe("D",   "", group="Timeframes", inline="tf3")

bull_col = input.color(#26a69a, "Bullish", group="Colors")
bear_col = input.color(#ef5350, "Bearish", group="Colors")

// ── Structure detection (runs inside each request.security context) ───────────
f_raw() =>
    ph = ta.pivothigh(high, struct_len, struct_len)
    pl = ta.pivotlow(low,  struct_len, struct_len)

    var float watch_sh    = na
    var int   watch_sh_ts = na
    var float watch_sl    = na
    var int   watch_sl_ts = na
    var bool  is_bull     = true

    if not na(ph)
        watch_sh    := ph
        watch_sh_ts := time[struct_len]
    if not na(pl)
        watch_sl    := pl
        watch_sl_ts := time[struct_len]

    bull_brk = not na(watch_sh) and close > watch_sh
    bear_brk = not na(watch_sl) and close < watch_sl

    e_price  = bull_brk ? watch_sh : (bear_brk ? watch_sl  : float(na))
    e_sw_ts  = bull_brk ? watch_sh_ts : (bear_brk ? watch_sl_ts : int(na))
    e_brk_ts = bull_brk or bear_brk ? time : int(na)
    e_is_bos = bull_brk ? is_bull : (bear_brk ? not is_bull : false)
    e_is_bul = bull_brk

    if bull_brk
        is_bull     := true
        watch_sh    := na
        watch_sh_ts := na
    else if bear_brk
        is_bull     := false
        watch_sl    := na
        watch_sl_ts := na

    [e_price, e_sw_ts, e_brk_ts, e_is_bos, e_is_bul]

[tf1_ep, tf1_esw, tf1_ebrk, tf1_ebos, tf1_ebul] = request.security(syminfo.tickerid, tf1, f_raw())
[tf2_ep, tf2_esw, tf2_ebrk, tf2_ebos, tf2_ebul] = request.security(syminfo.tickerid, tf2, f_raw())
[tf3_ep, tf3_esw, tf3_ebrk, tf3_ebos, tf3_ebul] = request.security(syminfo.tickerid, tf3, f_raw())

// ── Storage ───────────────────────────────────────────────────────────────────
var float[] tf1_p   = array.new_float(0)
var int[]   tf1_sw  = array.new_int(0)
var int[]   tf1_brk = array.new_int(0)
var bool[]  tf1_bos = array.new_bool(0)
var bool[]  tf1_bul = array.new_bool(0)

var float[] tf2_p   = array.new_float(0)
var int[]   tf2_sw  = array.new_int(0)
var int[]   tf2_brk = array.new_int(0)
var bool[]  tf2_bos = array.new_bool(0)
var bool[]  tf2_bul = array.new_bool(0)

var float[] tf3_p   = array.new_float(0)
var int[]   tf3_sw  = array.new_int(0)
var int[]   tf3_brk = array.new_int(0)
var bool[]  tf3_bos = array.new_bool(0)
var bool[]  tf3_bul = array.new_bool(0)

var line[] g_lns = array.new<line>(0)

// ── Push helper ───────────────────────────────────────────────────────────────
f_push(ep, esw, ebrk, ebos, ebul, p_a, sw_a, brk_a, bos_a, bul_a, cap) =>
    array.push(p_a,   ep)
    array.push(sw_a,  esw)
    array.push(brk_a, ebrk)
    array.push(bos_a, ebos)
    array.push(bul_a, ebul)
    if array.size(p_a) > cap
        array.shift(p_a)
        array.shift(sw_a)
        array.shift(brk_a)
        array.shift(bos_a)
        array.shift(bul_a)

// ── Draw lines — rebuilt at barstate.islast ───────────────────────────────────
f_draw(p_a, sw_a, brk_a, bos_a, bul_a, lw) =>
    n = array.size(p_a)
    if n > 0
        shown = 0
        for i = n - 1 to 0
            if shown >= max_lines
                break
            is_bos = array.get(bos_a, i)
            is_bul = array.get(bul_a, i)
            if is_bos and not show_bos
                continue
            if not is_bos and not show_choch
                continue
            price  = array.get(p_a,   i)
            sw_ts  = array.get(sw_a,  i)
            brk_ts = array.get(brk_a, i)
            col    = is_bul ? bull_col : bear_col
            l_sty  = is_bos ? line.style_solid : line.style_dashed
            ln     = line.new(x1=sw_ts, y1=price, x2=brk_ts, y2=price, xloc=xloc.bar_time, color=color.new(col, 20), width=lw, style=l_sty)
            array.push(g_lns, ln)
            shown += 1

// ── Detection ─────────────────────────────────────────────────────────────────
cap = max_lines * 3

tf1_new = not na(tf1_ep) and (na(tf1_ebrk[1]) or tf1_ebrk != tf1_ebrk[1])
tf2_new = not na(tf2_ep) and (na(tf2_ebrk[1]) or tf2_ebrk != tf2_ebrk[1])
tf3_new = not na(tf3_ep) and (na(tf3_ebrk[1]) or tf3_ebrk != tf3_ebrk[1])

if tf1_on and tf1_new
    f_push(tf1_ep, tf1_esw, tf1_ebrk, tf1_ebos, tf1_ebul, tf1_p, tf1_sw, tf1_brk, tf1_bos, tf1_bul, cap)

if tf2_on and tf2_new
    f_push(tf2_ep, tf2_esw, tf2_ebrk, tf2_ebos, tf2_ebul, tf2_p, tf2_sw, tf2_brk, tf2_bos, tf2_bul, cap)

if tf3_on and tf3_new
    f_push(tf3_ep, tf3_esw, tf3_ebrk, tf3_ebos, tf3_ebul, tf3_p, tf3_sw, tf3_brk, tf3_bos, tf3_bul, cap)

// ── Rebuild lines at barstate.islast ─────────────────────────────────────────
if barstate.islast
    n_ln = array.size(g_lns)
    if n_ln > 0
        for i = 0 to n_ln - 1
            line.delete(array.get(g_lns, i))
    array.clear(g_lns)

    if tf1_on
        f_draw(tf1_p, tf1_sw, tf1_brk, tf1_bos, tf1_bul, 1)
    if tf2_on
        f_draw(tf2_p, tf2_sw, tf2_brk, tf2_bos, tf2_bul, 2)
    if tf3_on
        f_draw(tf3_p, tf3_sw, tf3_brk, tf3_bos, tf3_bul, 3)

// ── Labels (plotshape) ────────────────────────────────────────────────────────
plotshape(show_lbl and tf1_on and show_bos   and tf1_new and tf1_ebos       and tf1_ebul,     "TF1 Bull BOS",   shape.labelup,   location.belowbar, bull_col, text="BOS",   textcolor=color.white, size=size.small)
plotshape(show_lbl and tf1_on and show_bos   and tf1_new and tf1_ebos       and not tf1_ebul, "TF1 Bear BOS",   shape.labeldown, location.abovebar, bear_col, text="BOS",   textcolor=color.white, size=size.small)
plotshape(show_lbl and tf1_on and show_choch and tf1_new and not tf1_ebos   and tf1_ebul,     "TF1 Bull ChoCH", shape.labelup,   location.belowbar, bull_col, text="ChoCH", textcolor=color.white, size=size.small)
plotshape(show_lbl and tf1_on and show_choch and tf1_new and not tf1_ebos   and not tf1_ebul, "TF1 Bear ChoCH", shape.labeldown, location.abovebar, bear_col, text="ChoCH", textcolor=color.white, size=size.small)

plotshape(show_lbl and tf2_on and show_bos   and tf2_new and tf2_ebos       and tf2_ebul,     "TF2 Bull BOS",   shape.labelup,   location.belowbar, bull_col, text="BOS",   textcolor=color.white, size=size.small)
plotshape(show_lbl and tf2_on and show_bos   and tf2_new and tf2_ebos       and not tf2_ebul, "TF2 Bear BOS",   shape.labeldown, location.abovebar, bear_col, text="BOS",   textcolor=color.white, size=size.small)
plotshape(show_lbl and tf2_on and show_choch and tf2_new and not tf2_ebos   and tf2_ebul,     "TF2 Bull ChoCH", shape.labelup,   location.belowbar, bull_col, text="ChoCH", textcolor=color.white, size=size.small)
plotshape(show_lbl and tf2_on and show_choch and tf2_new and not tf2_ebos   and not tf2_ebul, "TF2 Bear ChoCH", shape.labeldown, location.abovebar, bear_col, text="ChoCH", textcolor=color.white, size=size.small)

plotshape(show_lbl and tf3_on and show_bos   and tf3_new and tf3_ebos       and tf3_ebul,     "TF3 Bull BOS",   shape.labelup,   location.belowbar, bull_col, text="BOS",   textcolor=color.white, size=size.small)
plotshape(show_lbl and tf3_on and show_bos   and tf3_new and tf3_ebos       and not tf3_ebul, "TF3 Bear BOS",   shape.labeldown, location.abovebar, bear_col, text="BOS",   textcolor=color.white, size=size.small)
plotshape(show_lbl and tf3_on and show_choch and tf3_new and not tf3_ebos   and tf3_ebul,     "TF3 Bull ChoCH", shape.labelup,   location.belowbar, bull_col, text="ChoCH", textcolor=color.white, size=size.small)
plotshape(show_lbl and tf3_on and show_choch and tf3_new and not tf3_ebos   and not tf3_ebul, "TF3 Bear ChoCH", shape.labeldown, location.abovebar, bear_col, text="ChoCH", textcolor=color.white, size=size.small)

// ── Alerts ────────────────────────────────────────────────────────────────────
new_bull_bos   = (tf1_on and tf1_new and tf1_ebos and tf1_ebul)         or (tf2_on and tf2_new and tf2_ebos and tf2_ebul)         or (tf3_on and tf3_new and tf3_ebos and tf3_ebul)
new_bear_bos   = (tf1_on and tf1_new and tf1_ebos and not tf1_ebul)     or (tf2_on and tf2_new and tf2_ebos and not tf2_ebul)     or (tf3_on and tf3_new and tf3_ebos and not tf3_ebul)
new_bull_choch = (tf1_on and tf1_new and not tf1_ebos and tf1_ebul)     or (tf2_on and tf2_new and not tf2_ebos and tf2_ebul)     or (tf3_on and tf3_new and not tf3_ebos and tf3_ebul)
new_bear_choch = (tf1_on and tf1_new and not tf1_ebos and not tf1_ebul) or (tf2_on and tf2_new and not tf2_ebos and not tf2_ebul) or (tf3_on and tf3_new and not tf3_ebos and not tf3_ebul)

alertcondition(new_bull_bos,   "Bullish BOS",   "{{ticker}} bullish Break of Structure on {{interval}}")
alertcondition(new_bear_bos,   "Bearish BOS",   "{{ticker}} bearish Break of Structure on {{interval}}")
alertcondition(new_bull_choch, "Bullish ChoCH", "{{ticker}} bullish Change of Character on {{interval}}")
alertcondition(new_bear_choch, "Bearish ChoCH", "{{ticker}} bearish Change of Character on {{interval}}")
````
