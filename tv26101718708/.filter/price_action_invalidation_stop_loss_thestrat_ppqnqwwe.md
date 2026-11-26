# Price Action Invalidation Stop Loss (TheStrat)

- url: https://www.tradingview.com/script/PpQnqwWE-Price-Action-Invalidation-Stop-Loss-TheStrat/
- type: indicator
- pine_id: PUB;0608da15c2fd414cb4a3d62c39d76637
- version: 1.0

## Description

A stop-loss visualizer that places the stop where price action says your directional read is wrong, defined by higher-timeframe bar structure. Based on TheStrat methodology by Rob Smith.

[b]ABOUT THESTRAT[/b]
TheStrat, developed by Rob Smith, is a price-action framework that classifies every bar by how it relates to the prior bar's range, then reads that structure across multiple timeframes. Every bar is objectively one of a few types, and the way those types stack across timeframes defines whether a move is continuing or reversing.

[b]BAR TYPES[/b]
[list]
[*]1 (Inside bar): trades entirely within the prior bar's range. High is below the prior high and low is above the prior low. Consolidation by definition.
[*]2u (Directional up): takes the prior bar's high but not its low.
[*]2d (Directional down): takes the prior bar's low but not its high.
[*]3 (Outside bar): takes both the prior bar's high and its low. Range expansion on both sides.
[*]Failing 2 (F2): a bar that was a directional 2 but current price retraces back into the range of the prior candle. A failed 2u breaks the prior high but falls back below the highest high of the prior candle; a failed 2d breaks the prior low then turns back up above the lowest low of the prior candle. A failed 2 marks rejection of the attempted move and often a reversal.
[/list]

[b]WHAT IT DOES[/b]
The stop sits at the level where the directional thesis would be invalidated: the prior higher-timeframe bar's high or low, the point where that timeframe prints a directional 2 or 3 against the position.

It assumes entry on the 15-minute timeframe or lower, using the 30-minute and 60-minute as the structural higher timeframes. The indicator behaves identically on any chart resolution at or below 15m. Whether you load it on a 5m or 15m chart, it references the same 15m / 30m / 60m structure.

[b]THREE STATES[/b]
Long (blue): stop below price at the relevant higher-timeframe invalidation level.
Short (orange): stop above price.
Neutral (gray): no side is structurally supported, so the indicator stays flat.
Invalidation exits the current side. A reversal happens only if the opposite side is also valid. Otherwise the indicator goes neutral rather than flipping, which avoids the whipsaw of a pure stop-and-reverse model in choppy conditions.

[b]HOW THE STOP IS DERIVED[/b]
[list]
[*]Base level: the tighter of the prior 30m / 60m extremes (the higher of the two lows for a long, the lower of the two highs for a short).
[*]Tightening: when a higher timeframe closes a directional 2 in your favor, the stop pulls up to that bar's low (long) or down to its high (short).
[*]Failed-2 handling: if a higher timeframe breaks its prior high or low then fails back through it, the stop tightens to the most recent completed 15m level.
[*]3-override (optional): while a bar is a live outside bar (3), the stop holds at that bar's extreme so the expansion can resolve instead of tripping mid-bar.
[*]A direction is only active when the 30m and/or 60m is in a clean 2 or 3 in that direction, not a failed 2, failed 3, or inside bar.
[/list]

[b]SETTINGS[/b]
Behavior: tighten on 2-in-direction, 3-override, neutral state.
Visual markers (off by default): state transitions, tighten events, state background tint, higher-timeframe reference levels.
Debug: structured Pine Logs of every state change, tighten, and near-miss for bar-by-bar auditing.

[b]HOW TO USE[/b]
Add it to any chart at 15-minute resolution or lower. The single stepped line is the live invalidation stop for the currently supported direction. When the line is absent (neutral), structure is mixed and there is no clean side.

[i]This is a visualization and study tool. It is not a strategy, does not place orders, and does not generate buy/sell signals. Past structure does not guarantee future behavior. Always manage your own risk.[/i]

## Source Code

````pine
// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/
// ¬© SpinTrades
// Based on TheStrat trading methodology by Rob Smith

//@version=6
indicator("Price Action Invalidation Stop Loss", "PA Invalidation Stop", overlay=true)

// === Inputs ===
// --- Behavior ---
G_BEHAVIOR = "Behavior"
tighten_on_2     = input.bool(true,  "Tighten on 2-in-direction (at HTF close)", group=G_BEHAVIOR)
respect_3        = input.bool(false, "3-override: hold stop at 3's H/L during live 3", group=G_BEHAVIOR)
use_neutral      = input.bool(true,  "Use neutral state when direction not supported", group=G_BEHAVIOR)

// --- Visual markers (default OFF ‚Äî clean stop line only) ---
G_VISUAL = "Visual markers"
show_transitions = input.bool(false, "State transition markers (X, N, L, S)", group=G_VISUAL)
show_tightens    = input.bool(false, "Tighten event markers (2u/2d, F2, 3)", group=G_VISUAL)
show_state_bg    = input.bool(false, "State background tint", group=G_VISUAL)
show_htf_levels  = input.bool(false, "HTF reference levels (p30l/p30h/p60l/p60h)", group=G_VISUAL)

// --- Debug ---
G_DEBUG = "Debug"
log_flips        = input.bool(false, "Emit diagnostic Pine Logs", group=G_DEBUG)

// === Prior completed HTF bar H/L (anti-repaint: lookahead_on + [1]) ===
p30h = request.security(syminfo.tickerid, "30", high[1], lookahead=barmerge.lookahead_on)
p30l = request.security(syminfo.tickerid, "30", low[1],  lookahead=barmerge.lookahead_on)
p60h = request.security(syminfo.tickerid, "60", high[1], lookahead=barmerge.lookahead_on)
p60l = request.security(syminfo.tickerid, "60", low[1],  lookahead=barmerge.lookahead_on)

// === Just-closed HTF close + two-back H/L (for 2u/2d at HTF close, used by tightening) ===
p30c1 = request.security(syminfo.tickerid, "30", close[1], lookahead=barmerge.lookahead_on)
p30h2 = request.security(syminfo.tickerid, "30", high[2],  lookahead=barmerge.lookahead_on)
p30l2 = request.security(syminfo.tickerid, "30", low[2],   lookahead=barmerge.lookahead_on)
p60c1 = request.security(syminfo.tickerid, "60", close[1], lookahead=barmerge.lookahead_on)
p60h2 = request.security(syminfo.tickerid, "60", high[2],  lookahead=barmerge.lookahead_on)
p60l2 = request.security(syminfo.tickerid, "60", low[2],   lookahead=barmerge.lookahead_on)

// === 15m LTF reference ===
ltf15_close_prev = request.security(syminfo.tickerid, "15", close[1], lookahead=barmerge.lookahead_on)
ltf15_high_prev  = request.security(syminfo.tickerid, "15", high[1],  lookahead=barmerge.lookahead_on)
ltf15_low_prev   = request.security(syminfo.tickerid, "15", low[1],   lookahead=barmerge.lookahead_on)
ltf15_high_prior = request.security(syminfo.tickerid, "15", high[2],  lookahead=barmerge.lookahead_on)
ltf15_low_prior  = request.security(syminfo.tickerid, "15", low[2],   lookahead=barmerge.lookahead_on)
ltf15_new = ta.change(time("15")) != 0

ltf_against_long  = ltf15_new and ltf15_low_prev  < ltf15_low_prior
ltf_against_short = ltf15_new and ltf15_high_prev > ltf15_high_prior

// === Direction support (long/short active when HTF is in clean 2/3 direction) ===
htf_30_supports_long  = not na(ltf15_close_prev) and not na(p30h) and ltf15_close_prev > p30h
htf_60_supports_long  = not na(ltf15_close_prev) and not na(p60h) and ltf15_close_prev > p60h
htf_30_supports_short = not na(ltf15_close_prev) and not na(p30l) and ltf15_close_prev < p30l
htf_60_supports_short = not na(ltf15_close_prev) and not na(p60l) and ltf15_close_prev < p60l
dir_long_active  = htf_30_supports_long  or htf_60_supports_long
dir_short_active = htf_30_supports_short or htf_60_supports_short

// === Running H/L for in-progress HTF/LTF bars, accumulated from chart bars ===
new15 = ta.change(time("15")) != 0
new30 = ta.change(time("30")) != 0
new60 = ta.change(time("60")) != 0

var float c15h = na
var float c15l = na
var float c30h = na
var float c30l = na
var float c60h = na
var float c60l = na
c15h := new15 ? high : math.max(nz(c15h, high), high)
c15l := new15 ? low  : math.min(nz(c15l, low),  low)
c30h := new30 ? high : math.max(nz(c30h, high), high)
c30l := new30 ? low  : math.min(nz(c30l, low),  low)
c60h := new60 ? high : math.max(nz(c60h, high), high)
c60l := new60 ? low  : math.min(nz(c60l, low),  low)

curr_30_2u = c30h > p30h
curr_30_2d = c30l < p30l
curr_60_2u = c60h > p60h
curr_60_2d = c60l < p60l

just_30_closed_2u = new30 and p30c1 > p30h2
just_30_closed_2d = new30 and p30c1 < p30l2
just_60_closed_2u = new60 and p60c1 > p60h2
just_60_closed_2d = new60 and p60c1 < p60l2

htf_f2u_active = (curr_30_2u and ltf15_close_prev < p30h) or (curr_60_2u and ltf15_close_prev < p60h)
htf_f2d_active = (curr_30_2d and ltf15_close_prev > p30l) or (curr_60_2d and ltf15_close_prev > p60l)

// === 3-in-progress detection (intrabar): bar took prior bar's high AND prior bar's low ===
curr_15_3 = not na(ltf15_high_prev) and not na(ltf15_low_prev) and c15h > ltf15_high_prev and c15l < ltf15_low_prev
curr_30_3 = curr_30_2u and curr_30_2d
curr_60_3 = curr_60_2u and curr_60_2d

// Tightest 3 (smallest TF) ‚Äî 15m wins over 30m wins over 60m
three_low_long   = curr_15_3 ? c15l : curr_30_3 ? c30l : curr_60_3 ? c60l : na
three_high_short = curr_15_3 ? c15h : curr_30_3 ? c30h : curr_60_3 ? c60h : na
any_3_active     = curr_15_3 or curr_30_3 or curr_60_3

long_stop  = math.max(p30l, p60l)
short_stop = math.min(p30h, p60h)

// === State machine: 1=long, 0=neutral, -1=short ===
var int   state             = 0
var float stop              = na
var bool  last_flip_with_f2 = false

if state == 1
    stop := na(stop) ? long_stop : math.max(stop, long_stop)
    if tighten_on_2
        if just_30_closed_2u
            stop := math.max(stop, p30l)
        if just_60_closed_2u
            stop := math.max(stop, p60l)
    if htf_f2u_active and not na(ltf15_low_prev)
        stop := math.max(stop, ltf15_low_prev)
    // 3-override (after ratchet/tightenings): if any TF is currently a 3, hold stop at the 3's low
    if respect_3 and not na(three_low_long)
        stop := three_low_long
    // Rule A uses c15l (running 15m low) so 5m and 15m charts behave identically
    if not na(stop) and c15l < stop
        last_flip_with_f2 := htf_f2u_active
        if use_neutral and not dir_short_active
            state := 0
            stop := na
        else
            state := -1
            stop := short_stop
else if state == -1
    stop := na(stop) ? short_stop : math.min(stop, short_stop)
    if tighten_on_2
        if just_30_closed_2d
            stop := math.min(stop, p30h)
        if just_60_closed_2d
            stop := math.min(stop, p60h)
    if htf_f2d_active and not na(ltf15_high_prev)
        stop := math.min(stop, ltf15_high_prev)
    if respect_3 and not na(three_high_short)
        stop := three_high_short
    if not na(stop) and c15h > stop
        last_flip_with_f2 := htf_f2d_active
        if use_neutral and not dir_long_active
            state := 0
            stop := na
        else
            state := 1
            stop := long_stop
else
    if dir_long_active
        state := 1
        stop := long_stop
        if tighten_on_2
            if just_30_closed_2u
                stop := math.max(stop, p30l)
            if just_60_closed_2u
                stop := math.max(stop, p60l)
        if htf_f2u_active and not na(ltf15_low_prev)
            stop := math.max(stop, ltf15_low_prev)
        if respect_3 and not na(three_low_long)
            stop := three_low_long
        last_flip_with_f2 := false
    else if dir_short_active
        state := -1
        stop := short_stop
        if tighten_on_2
            if just_30_closed_2d
                stop := math.min(stop, p30h)
            if just_60_closed_2d
                stop := math.min(stop, p60h)
        if htf_f2d_active and not na(ltf15_high_prev)
            stop := math.min(stop, ltf15_high_prev)
        if respect_3 and not na(three_high_short)
            stop := three_high_short
        last_flip_with_f2 := false

// === Plots ===
stop_color = state == 1 ? color.new(color.blue, 0) : state == -1 ? color.new(color.orange, 0) : color.new(color.gray, 0)
plot(state == 0 ? na : stop, "Stop", color=stop_color, linewidth=2, style=plot.style_steplinebr)

plot(show_htf_levels ? p30l : na, "p30l", color=color.new(color.aqua,    70), linewidth=1, style=plot.style_stepline)
plot(show_htf_levels ? p60l : na, "p60l", color=color.new(color.teal,    50), linewidth=1, style=plot.style_stepline)
plot(show_htf_levels ? p30h : na, "p30h", color=color.new(color.fuchsia, 70), linewidth=1, style=plot.style_stepline)
plot(show_htf_levels ? p60h : na, "p60h", color=color.new(color.purple,  50), linewidth=1, style=plot.style_stepline)

bg_color = state == 1 ? color.new(color.blue, 95) : state == -1 ? color.new(color.orange, 95) : color.new(color.gray, 90)
bgcolor(show_state_bg ? bg_color : na)

prev_state = nz(state[1], state)
flip_LS              = (prev_state == 1  and state == -1) or (prev_state == -1 and state == 1)
exit_to_neutral      = prev_state != 0   and state == 0
entry_from_neutral_L = prev_state == 0 and state == 1
entry_from_neutral_S = prev_state == 0 and state == -1

plotshape(show_transitions and flip_LS              ? close : na, "L<->S Flip", style=shape.circle,       location=location.absolute, color=color.yellow,  size=size.small, text="X", textcolor=color.black)
plotshape(show_transitions and exit_to_neutral      ? close : na, "Exit to N",  style=shape.diamond,      location=location.absolute, color=color.fuchsia, size=size.small, text="N", textcolor=color.white)
plotshape(show_transitions and entry_from_neutral_L ? close : na, "N -> L",     style=shape.triangleup,   location=location.absolute, color=color.new(color.blue,   0), size=size.small, text="L", textcolor=color.white)
plotshape(show_transitions and entry_from_neutral_S ? close : na, "N -> S",     style=shape.triangledown, location=location.absolute, color=color.new(color.orange, 0), size=size.small, text="S", textcolor=color.white)

tighten_long_mark  = state == 1  and tighten_on_2 and (just_30_closed_2u or just_60_closed_2u)
tighten_short_mark = state == -1 and tighten_on_2 and (just_30_closed_2d or just_60_closed_2d)
plotshape(show_tightens and tighten_long_mark  ? stop : na, "2u Tighten", style=shape.triangleup,   location=location.absolute, color=color.new(color.blue,   0), size=size.tiny)
plotshape(show_tightens and tighten_short_mark ? stop : na, "2d Tighten", style=shape.triangledown, location=location.absolute, color=color.new(color.orange, 0), size=size.tiny)

var bool prev_f2u = false
var bool prev_f2d = false
f2_tighten_long  = state == 1  and htf_f2u_active and not prev_f2u
f2_tighten_short = state == -1 and htf_f2d_active and not prev_f2d
prev_f2u := htf_f2u_active
prev_f2d := htf_f2d_active
plotshape(show_tightens and f2_tighten_long  ? stop : na, "F2u Tighten", style=shape.diamond, location=location.absolute, color=color.new(color.aqua,    0), size=size.tiny)
plotshape(show_tightens and f2_tighten_short ? stop : na, "F2d Tighten", style=shape.diamond, location=location.absolute, color=color.new(color.fuchsia, 0), size=size.tiny)

// 3-in-progress marker (rising edge of any 3)
var bool prev_any_3 = false
three_now = state != 0 and respect_3 and any_3_active and not prev_any_3
prev_any_3 := any_3_active
plotshape(show_tightens and three_now ? stop : na, "3 Override", style=shape.xcross, location=location.absolute, color=color.new(color.white, 0), size=size.tiny)

// =============================================================================
// === DIAGNOSTIC LOGGING ======================================================
// =============================================================================
var int   last_state_change_bar = -1
var bool  prev_log_f2u          = false
var bool  prev_log_f2d          = false
var float prev_log_stop         = na
var bool  prev_near_miss_l      = false
var bool  prev_near_miss_s      = false

state_changed = state != prev_state

if log_flips
    time_str = str.format("{0,date,yyyy-MM-dd HH:mm:ss}", time)
    st30_str = curr_30_3 ? "3" : curr_30_2u ? "2u" : curr_30_2d ? "2d" : "1"
    st60_str = curr_60_3 ? "3" : curr_60_2u ? "2u" : curr_60_2d ? "2d" : "1"
    st15_str = curr_15_3 ? "3" : (c15h > ltf15_high_prev ? "2u" : (c15l < ltf15_low_prev ? "2d" : "1"))
    from_str = prev_state == 1 ? "L" : prev_state == -1 ? "S" : "N"
    to_str   = state      == 1 ? "L" : state      == -1 ? "S" : "N"

    if state_changed
        bars_since = last_state_change_bar < 0 ? -1 : bar_index - last_state_change_bar
        since_min = bars_since < 0 ? -1 : bars_since * timeframe.in_seconds() / 60
        is_whippy = bars_since >= 0 and bars_since < 10
        chg_msg = (is_whippy ? "WHIPPY_STATE_CHG" : "STATE_CHG") +
                  " t=" + time_str +
                  " chart_tf=" + timeframe.period +
                  " from=" + from_str +
                  " to=" + to_str +
                  " with_f2=" + (last_flip_with_f2 ? "T" : "F") +
                  " since_bars=" + (bars_since < 0 ? "-" : str.tostring(bars_since)) +
                  " since_min=" + (since_min < 0 ? "-" : str.tostring(since_min, "#")) +
                  " close=" + str.tostring(close, "#.##") +
                  " c15l=" + str.tostring(c15l, "#.##") +
                  " c15h=" + str.tostring(c15h, "#.##") +
                  " stop=" + str.tostring(stop, "#.##") +
                  " p30l=" + str.tostring(p30l, "#.##") +
                  " p30h=" + str.tostring(p30h, "#.##") +
                  " p60l=" + str.tostring(p60l, "#.##") +
                  " p60h=" + str.tostring(p60h, "#.##") +
                  " st15=" + st15_str +
                  " st30=" + st30_str +
                  " st60=" + st60_str +
                  " 3_15=" + (curr_15_3 ? "T" : "F") +
                  " 3_30=" + (curr_30_3 ? "T" : "F") +
                  " 3_60=" + (curr_60_3 ? "T" : "F") +
                  " dirL=" + (dir_long_active  ? "T" : "F") +
                  " dirS=" + (dir_short_active ? "T" : "F") +
                  " f2u=" + (htf_f2u_active ? "T" : "F") +
                  " f2d=" + (htf_f2d_active ? "T" : "F")
        if is_whippy
            log.warning(chg_msg)
        else
            log.info(chg_msg)
        last_state_change_bar := bar_index

    if htf_f2u_active and not prev_log_f2u
        log.info("F2u_ON t=" + time_str + " state=" + to_str + " stop=" + str.tostring(stop, "#.##") + " dirL=" + (dir_long_active ? "T" : "F"))
    if not htf_f2u_active and prev_log_f2u
        log.info("F2u_OFF t=" + time_str + " state=" + to_str + " stop=" + str.tostring(stop, "#.##"))
    prev_log_f2u := htf_f2u_active

    if htf_f2d_active and not prev_log_f2d
        log.info("F2d_ON t=" + time_str + " state=" + to_str + " stop=" + str.tostring(stop, "#.##") + " dirS=" + (dir_short_active ? "T" : "F"))
    if not htf_f2d_active and prev_log_f2d
        log.info("F2d_OFF t=" + time_str + " state=" + to_str + " stop=" + str.tostring(stop, "#.##"))
    prev_log_f2d := htf_f2d_active

    if any_3_active and not prev_any_3[1]
        which_3 = curr_15_3 ? "15" : curr_30_3 ? "30" : "60"
        log.info("THREE_ON t=" + time_str + " which=" + which_3 + " state=" + to_str + " stop=" + str.tostring(stop, "#.##") + " three_low=" + str.tostring(three_low_long, "#.##") + " three_high=" + str.tostring(three_high_short, "#.##"))

    if not na(stop) and (na(prev_log_stop) or stop != prev_log_stop)
        delta = na(prev_log_stop) ? na : stop - prev_log_stop
        log.info("STOP_CHG t=" + time_str +
                 " state=" + to_str +
                 " from=" + (na(prev_log_stop) ? "-" : str.tostring(prev_log_stop, "#.##")) +
                 " to=" + str.tostring(stop, "#.##") +
                 " delta=" + (na(delta) ? "-" : str.tostring(delta, "#.##")) +
                 " close=" + str.tostring(close, "#.##"))
        prev_log_stop := stop

    nm_l_now = state == 1  and not na(stop) and c15l >= stop and c15l < stop + (stop * 0.001)
    nm_s_now = state == -1 and not na(stop) and c15h <= stop and c15h > stop - (stop * 0.001)
    if nm_l_now and not prev_near_miss_l
        log.info("NEAR_MISS_L t=" + time_str + " c15l=" + str.tostring(c15l, "#.##") + " stop=" + str.tostring(stop, "#.##") + " diff=" + str.tostring(c15l - stop, "#.##"))
    if nm_s_now and not prev_near_miss_s
        log.info("NEAR_MISS_S t=" + time_str + " c15h=" + str.tostring(c15h, "#.##") + " stop=" + str.tostring(stop, "#.##") + " diff=" + str.tostring(c15h - stop, "#.##"))
    prev_near_miss_l := nm_l_now
    prev_near_miss_s := nm_s_now
````
