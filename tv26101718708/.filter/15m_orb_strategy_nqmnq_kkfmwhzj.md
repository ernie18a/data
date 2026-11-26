# 15M ORB Strategy [NQ/MNQ]

- url: https://www.tradingview.com/script/KkfmwHZj-15M-ORB-Strategy-NQ-MNQ/
- type: indicator
- pine_id: PUB;3725ce0883934e35ba75365b28e32ca3
- version: 1.0

## Description

Here's a clean description you can save or share:

15M ORB Strategy [NQ/MNQ]
A 15-minute Opening Range Breakout strategy designed for NQ/MNQ futures, running on a 1-minute chart.
How it works:
Every morning at 9:30 AM ET, the strategy marks the high and low of the first 15 minutes of trading as the Opening Range. Once the market closes convincingly outside that range (2 consecutive closes), it waits for price to pull back and retest the OR level before entering. If no retest occurs within 10 bars, a fallback entry fires to catch momentum moves that don't look back.
Two modes based on OR size:

Small OR (under 200 pts) → Fixed TP at 0.75R with SL at the opposite end of the range
Large OR (200+ pts) → Trail mode — no fixed TP, rides the trend with an ATR-based trailing stop after breakeven is secured at +20 points

Risk management:

Stop loss at the opposite end of the opening range
Breakeven moves to entry after +20 points of profit
ATR trailing stop (3.5x multiplier) kicks in after breakeven to ride trending moves
All trades close at 2PM ET / noon MST
One trade per direction per day, no hedging

Signals:

Takes both longs and shorts depending on breakout direction
False breakouts are filtered — if price closes back inside the range, the breakout is reset
Separate alerts for retest entries, fallback entries, and any signal for automation compatibility

MADE WITH CLAUDE AI

## Source Code

````pine
//@version=6
indicator("15M ORB Strategy [NQ/MNQ]", overlay=true, max_labels_count=500, max_lines_count=500)

// ═══════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════
grp1 = "Signal Settings"
retest_buffer  = input.float(3.0,   "Retest Buffer (points)",          minval=0.5, step=0.5,  group=grp1)
or_threshold   = input.float(200.0, "Large OR Threshold (points)",     minval=10.0, step=5.0, group=grp1,
                     tooltip="OR >= this = Trail mode. OR < this = Fixed TP mode.")
rr_ratio       = input.float(0.75,  "Fixed TP Risk:Reward",            minval=0.1, step=0.05, group=grp1)

grp1b = "Breakout Settings"
confirm_bars   = input.int(2,    "Consecutive Closes to Confirm",      minval=1, maxval=5, group=grp1b,
                     tooltip="Consecutive closes outside OR needed to confirm breakout.")
use_fallback   = input.bool(true, "Use Fallback Entry if No Retest",   group=grp1b)
fallback_bars  = input.int(10,   "Bars to Wait Before Fallback",       minval=1, maxval=60, group=grp1b)

grp2 = "Risk Management"
be_trigger_pts = input.float(20.0, "Breakeven Trigger (points)", minval=1.0, step=1.0, group=grp2)
trail_atr_mult = input.float(3.5,  "Trail ATR Multiplier",       minval=0.1, step=0.1,  group=grp2)

grp3 = "Display"
show_or_box  = input.bool(true,  "Show OR Box",           group=grp3)
show_signals = input.bool(true,  "Show Signal Labels",    group=grp3)
show_tp_sl   = input.bool(true,  "Show TP / SL Lines",   group=grp3)
show_be      = input.bool(true,  "Show Breakeven Line",   group=grp3)
show_trail   = input.bool(true,  "Show Trailing SL Line", group=grp3)
bull_col     = input.color(color.new(#00E676, 0),  "Bullish Color", group=grp3)
bear_col     = input.color(color.new(#FF1744, 0),  "Bearish Color", group=grp3)
box_col      = input.color(color.new(#2962FF, 10), "OR Box Color",  group=grp3)

// ═══════════════════════════════════════════════════════════
//  INDICATORS
// ═══════════════════════════════════════════════════════════
atr_1m = ta.atr(14)

// ═══════════════════════════════════════════════════════════
//  TIME
// ═══════════════════════════════════════════════════════════
et_hour  = hour(time,   "America/New_York")
et_min   = minute(time, "America/New_York")
new_day  = ta.change(time("D")) != 0
in_or    = et_hour == 9 and et_min >= 30 and et_min < 45
sess_end = et_hour >= 14

// ═══════════════════════════════════════════════════════════
//  OPENING RANGE
// ═══════════════════════════════════════════════════════════
var float orh   = na
var float orl   = na
var bool  built = false
var int   bleft = na

if new_day
    orh   := na
    orl   := na
    built := false
    bleft := na

if in_or
    orh   := na(orh)   ? high : math.max(orh, high)
    orl   := na(orl)   ? low  : math.min(orl, low)
    bleft := na(bleft) ? bar_index : bleft

just_built = not in_or and not built and not na(orh)
if just_built
    built := true

or_size  = built ? orh - orl : na
large_or = built and or_size >= or_threshold
small_or = built and or_size < or_threshold

long_tp  = built ? orh + (or_size * rr_ratio) : na
long_sl  = built ? orl                         : na
short_tp = built ? orl - (or_size * rr_ratio)  : na
short_sl = built ? orh                          : na

// OR Box
var box orbox = na
if just_built and show_or_box
    orbox := box.new(bleft, orh, bar_index, orl,
                     border_color=color.new(box_col, 30),
                     bgcolor=color.new(box_col, 80))
if built and show_or_box and not na(orbox)
    box.set_right(orbox, bar_index)

// OR mode label
if just_built
    label.new(bleft, orh + nz(or_size, 10) * 0.1,
              (large_or ? "🔥 TRAIL" : "🎯 FIXED TP") + " | OR: " + str.tostring(or_size, "#.0") + " pts",
              color=large_or ? color.new(bull_col, 20) : color.new(color.orange, 20),
              textcolor=color.white, style=label.style_label_right, size=size.small)

// ═══════════════════════════════════════════════════════════
//  BREAKOUT CONFIRMATION
// ═══════════════════════════════════════════════════════════
var bool trade_open = false
if new_day
    trade_open := false

var int  consec_above   = 0
var int  consec_below   = 0
var bool b_above        = false
var bool b_below        = false
var int  breakout_bar_l = na
var int  breakout_bar_s = na

if new_day
    consec_above   := 0
    consec_below   := 0
    b_above        := false
    b_below        := false
    breakout_bar_l := na
    breakout_bar_s := na

if built and not sess_end
    if close > orh
        consec_above += 1
    else
        consec_above := 0
    if close < orl
        consec_below += 1
    else
        consec_below := 0

breakout_up   = built and not b_above and consec_above[1] >= confirm_bars and not sess_end
breakout_down = built and not b_below and consec_below[1] >= confirm_bars and not sess_end

if breakout_up
    b_above        := true
    breakout_bar_l := bar_index

if breakout_down
    b_below        := true
    breakout_bar_s := bar_index

// False breakout reset (use trade_open flag since in_long/in_short declared later)
if built and b_above and close < orh and not sess_end and not trade_open
    b_above        := false
    consec_above   := 0
    breakout_bar_l := na

if built and b_below and close > orl and not sess_end and not trade_open
    b_below        := false
    consec_below   := 0
    breakout_bar_s := na

// ═══════════════════════════════════════════════════════════
//  SIGNAL LOGIC + SIMULATED POSITION TRACKING
// ═══════════════════════════════════════════════════════════
var bool  l_done      = false
var bool  s_done      = false
var bool  in_long     = false
var bool  in_short    = false
var float entry_px    = na
var bool  long_be     = false
var bool  short_be    = false
var float trail_long  = na
var float trail_short = na

if new_day
    l_done      := false
    s_done      := false
    in_long     := false
    in_short    := false
    entry_px    := na
    long_be     := false
    short_be    := false
    trail_long  := na
    trail_short := na
    trade_open  := false

bars_since_long  = not na(breakout_bar_l) ? bar_index - breakout_bar_l : 0
bars_since_short = not na(breakout_bar_s) ? bar_index - breakout_bar_s : 0

// Retest signals
long_retest  = built and b_above and not l_done and not trade_open and not sess_end and low  <= orh + retest_buffer
short_retest = built and b_below and not s_done and not trade_open and not sess_end and high >= orl - retest_buffer

// Fallback signals
long_fallback  = use_fallback and built and b_above and not l_done and not trade_open and not sess_end and not long_retest  and bars_since_long  >= fallback_bars
short_fallback = use_fallback and built and b_below and not s_done and not trade_open and not sess_end and not short_retest and bars_since_short >= fallback_bars

long_sig  = long_retest  or long_fallback
short_sig = short_retest or short_fallback

// Enter simulated position
if long_sig
    in_long    := true
    trade_open := true
    entry_px   := long_fallback ? close : orh
    long_be    := false
    trail_long := na
    l_done     := true

if short_sig
    in_short   := true
    trade_open := true
    entry_px   := short_fallback ? close : orl
    short_be   := false
    trail_short := na
    s_done     := true

// Breakeven tracking
if in_long and not long_be and (close - entry_px) >= be_trigger_pts
    long_be := true
if in_short and not short_be and (entry_px - close) >= be_trigger_pts
    short_be := true

// Trailing stop tracking
if in_long and long_be
    float t    = close - atr_1m * trail_atr_mult
    trail_long := math.max(nz(trail_long, t), t)
if in_short and short_be
    float t     = close + atr_1m * trail_atr_mult
    trail_short := math.min(nz(trail_short, t), t)

// Check exit conditions
long_sl_exit   = in_long  and not long_be  and low  <= long_sl
long_be_exit   = in_long  and long_be      and not na(trail_long)  and low  <= math.max(trail_long, entry_px)
long_tp_exit   = in_long  and small_or     and high >= long_tp
long_time_exit = in_long  and sess_end

short_sl_exit   = in_short and not short_be and high >= short_sl
short_be_exit   = in_short and short_be     and not na(trail_short) and high >= math.min(trail_short, entry_px)
short_tp_exit   = in_short and small_or     and low  <= short_tp
short_time_exit = in_short and sess_end

if long_sl_exit or long_be_exit or long_tp_exit or long_time_exit
    in_long    := false
    trade_open := false
    entry_px   := na
    trail_long := na
    long_be    := false

if short_sl_exit or short_be_exit or short_tp_exit or short_time_exit
    in_short    := false
    trade_open  := false
    entry_px    := na
    trail_short := na
    short_be    := false

// ═══════════════════════════════════════════════════════════
//  SIGNAL LABELS + LINES
// ═══════════════════════════════════════════════════════════
if long_sig and show_signals
    string entry_str = long_fallback ? str.tostring(close, "#.00") : str.tostring(orh, "#.00")
    string lbl = long_fallback ?
          "▲ LONG-FALLBACK\nEntry: " + entry_str + "\nSL: " + str.tostring(long_sl, "#.00") :
          small_or ?
          "▲ LONG-FIXED\nEntry: " + entry_str + "\nTP: " + str.tostring(long_tp, "#.00") + "\nSL: " + str.tostring(long_sl, "#.00") :
          "▲ LONG-TRAIL\nEntry: " + entry_str + "\nSL: " + str.tostring(long_sl, "#.00") + "\nBE @ +" + str.tostring(be_trigger_pts, "#") + " pts"
    label.new(bar_index, low - nz(or_size, 10) * 0.15, lbl,
              color=bull_col, textcolor=color.white, style=label.style_label_up, size=size.small)

if short_sig and show_signals
    string entry_str = short_fallback ? str.tostring(close, "#.00") : str.tostring(orl, "#.00")
    string slbl = short_fallback ?
          "▼ SHORT-FALLBACK\nEntry: " + entry_str + "\nSL: " + str.tostring(short_sl, "#.00") :
          small_or ?
          "▼ SHORT-FIXED\nEntry: " + entry_str + "\nTP: " + str.tostring(short_tp, "#.00") + "\nSL: " + str.tostring(short_sl, "#.00") :
          "▼ SHORT-TRAIL\nEntry: " + entry_str + "\nSL: " + str.tostring(short_sl, "#.00") + "\nBE @ +" + str.tostring(be_trigger_pts, "#") + " pts"
    label.new(bar_index, high + nz(or_size, 10) * 0.15, slbl,
              color=bear_col, textcolor=color.white, style=label.style_label_down, size=size.small)

if long_sig and show_tp_sl
    line.new(bar_index, long_sl, bar_index + 60, long_sl, color=color.new(bear_col, 10), width=2, style=line.style_dashed)
    label.new(bar_index + 62, long_sl, "SL " + str.tostring(long_sl, "#.00"), color=color.new(bear_col, 50), textcolor=bear_col, style=label.style_label_left, size=size.tiny)
    if small_or and not long_fallback
        line.new(bar_index, long_tp, bar_index + 60, long_tp, color=color.new(bull_col, 10), width=2, style=line.style_dashed)
        label.new(bar_index + 62, long_tp, "TP " + str.tostring(long_tp, "#.00"), color=color.new(bull_col, 50), textcolor=bull_col, style=label.style_label_left, size=size.tiny)

if short_sig and show_tp_sl
    line.new(bar_index, short_sl, bar_index + 60, short_sl, color=color.new(bear_col, 10), width=2, style=line.style_dashed)
    label.new(bar_index + 62, short_sl, "SL " + str.tostring(short_sl, "#.00"), color=color.new(bear_col, 50), textcolor=bear_col, style=label.style_label_left, size=size.tiny)
    if small_or and not short_fallback
        line.new(bar_index, short_tp, bar_index + 60, short_tp, color=color.new(bull_col, 10), width=2, style=line.style_dashed)
        label.new(bar_index + 62, short_tp, "TP " + str.tostring(short_tp, "#.00"), color=color.new(bull_col, 50), textcolor=bull_col, style=label.style_label_left, size=size.tiny)

// ═══════════════════════════════════════════════════════════
//  PLOTS
// ═══════════════════════════════════════════════════════════
plot(built ? orh : na, "OR High", color=color.new(box_col, 20), linewidth=1, style=plot.style_linebr)
plot(built ? orl : na, "OR Low",  color=color.new(box_col, 20), linewidth=1, style=plot.style_linebr)

plot(show_be and in_long  and long_be  ? entry_px : na, "BE Long",  color=color.new(color.white, 10), linewidth=1, style=plot.style_linebr)
plot(show_be and in_short and short_be ? entry_px : na, "BE Short", color=color.new(color.white, 10), linewidth=1, style=plot.style_linebr)

plot(show_trail and in_long  and long_be  and not na(trail_long)  ? math.max(trail_long,  entry_px) : na, "Trail Long",  color=color.new(bear_col, 10), linewidth=2, style=plot.style_linebr)
plot(show_trail and in_short and short_be and not na(trail_short) ? math.min(trail_short, entry_px) : na, "Trail Short", color=color.new(bear_col, 10), linewidth=2, style=plot.style_linebr)

bgcolor(in_or ? color.new(box_col, 88) : na, title="OR Window")

// ═══════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════
alertcondition(long_sig  and not long_fallback,  "ORB Long - Retest",    "ORB LONG RETEST - Entry at OR High. Check chart for TP and SL levels.")
alertcondition(short_sig and not short_fallback, "ORB Short - Retest",   "ORB SHORT RETEST - Entry at OR Low. Check chart for TP and SL levels.")
alertcondition(long_fallback,                    "ORB Long - Fallback",  "ORB LONG FALLBACK - No retest, entering on momentum. Market order.")
alertcondition(short_fallback,                   "ORB Short - Fallback", "ORB SHORT FALLBACK - No retest, entering on momentum. Market order.")
alertcondition(long_sig or short_sig,            "ORB Any Signal",       "ORB Signal fired - check chart for direction.")
````
