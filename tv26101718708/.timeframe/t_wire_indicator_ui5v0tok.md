# T Wire Indicator

- url: https://www.tradingview.com/script/uI5V0toK-T-Wire-Indicator/
- type: indicator
- pine_id: PUB;149419e218fb46629aafc30a6773be76
- version: 1.0

## Description

this updated version of the script now has the ability to set alerts for elite and prime signals

## Source Code

````pine
//@version=6
// © T Wire Indicator v1.1
// v1.1 — PRIME/ELITE alert conditions, repainting fix on 4H security calls
indicator("T Wire Indicator", shorttitle="T Wire", overlay=true, max_labels_count=500)

// ─── INPUTS ───────────────────────────────────────────────────────────────────

var string GRP_EMA = "EMA Settings"
ema_fast_len = input.int(50,  "Fast EMA",  minval=1, group=GRP_EMA)
ema_slow_len = input.int(200, "Slow EMA",  minval=1, group=GRP_EMA)
show_emas    = input.bool(true, "Show EMA Lines", group=GRP_EMA)

var string GRP_ST = "Supertrend Settings"
st_period = input.int(10,    "ATR Period",      minval=1,   group=GRP_ST)
st_mult   = input.float(3.0, "ATR Multiplier",  minval=0.1, group=GRP_ST)
show_st   = input.bool(true, "Show Supertrend Line", group=GRP_ST)

var string GRP_RSI = "RSI Settings"
rsi_len = input.int(14, "RSI Length",  minval=1, group=GRP_RSI)
rsi_ob  = input.int(70, "Overbought",  group=GRP_RSI)
rsi_os  = input.int(30, "Oversold",    group=GRP_RSI)

var string GRP_VOL = "Volume Settings"
vol_len  = input.int(20,    "Volume MA Length", minval=1,   group=GRP_VOL)
vol_mult = input.float(1.5, "Surge Multiplier", minval=1.0, group=GRP_VOL)
show_vol = input.bool(true, "Highlight Volume Surges", group=GRP_VOL)

var string GRP_SIG = "Signal Settings"
show_labels = input.bool(true, "Show Signal Labels", group=GRP_SIG)
show_arrows = input.bool(true, "Show Signal Arrows", group=GRP_SIG)

// ─── COLOURS ──────────────────────────────────────────────────────────────────

TEAL   = color.new(#00C9A7, 0)
GREEN  = color.new(#2ECC71, 0)
RED    = color.new(#E74C3C, 0)
BLUE   = color.new(#3B8EEA, 0)
ORANGE = color.new(#FF7A00, 0)
PURPLE = color.new(#8B5CF6, 0)
GREY   = color.new(#888888, 0)
WHITE  = color.new(#FFFFFF, 0)

// ─── EMA ──────────────────────────────────────────────────────────────────────

ema_fast = ta.ema(close, ema_fast_len)
ema_slow = ta.ema(close, ema_slow_len)
ema_bull = ema_fast > ema_slow

p_fast = plot(show_emas ? ema_fast : na, "EMA 50",  color=BLUE,   linewidth=1)
p_slow = plot(show_emas ? ema_slow : na, "EMA 200", color=ORANGE, linewidth=2)
fill(p_fast, p_slow, color=ema_bull ? color.new(#2ECC71, 90) : color.new(#E74C3C, 90), title="EMA Ribbon")

// ─── SUPERTREND ───────────────────────────────────────────────────────────────

[st_val, st_dir] = ta.supertrend(st_mult, st_period)
st_bull = st_dir < 0
plot(show_st ? st_val : na, "Supertrend", color=st_bull ? GREEN : RED, linewidth=2)

// ─── RSI ──────────────────────────────────────────────────────────────────────

rsi_val  = ta.rsi(close, rsi_len)
rsi_bull = rsi_val > 50 and rsi_val < rsi_ob
rsi_bear = rsi_val < 50 and rsi_val > rsi_os

// ─── VOLUME SURGE ─────────────────────────────────────────────────────────────

vol_ma    = ta.sma(volume, vol_len)
vol_surge = volume > vol_ma * vol_mult
barcolor(show_vol and vol_surge ? color.new(TEAL, 60) : na, title="Volume Surge Bar")

// ─── ATR ──────────────────────────────────────────────────────────────────────

atr = ta.atr(14)

// ─── 4H CONFLUENCE (repainting-safe — uses previous confirmed 4H bar) ─────────
// Using [1] offset references the last *fully closed* 4H candle, not the live one.
// This eliminates mid-bar repainting that triggers TradingView's warning.

ema_fast_4h   = request.security(syminfo.tickerid, "240", ta.ema(close, ema_fast_len)[1])
ema_slow_4h   = request.security(syminfo.tickerid, "240", ta.ema(close, ema_slow_len)[1])
st_dir_4h     = request.security(syminfo.tickerid, "240", st_dir[1])

conf_4h_bull = ema_fast_4h > ema_slow_4h and st_dir_4h < 0
conf_4h_bear = ema_fast_4h < ema_slow_4h and st_dir_4h > 0

// ─── SIGNAL CONDITIONS ────────────────────────────────────────────────────────

cur_long  = ema_bull and st_bull
cur_short = not ema_bull and not st_bull

prev_long  = ema_fast[1] > ema_slow[1] and st_dir[1] < 0
prev_short = ema_fast[1] < ema_slow[1] and st_dir[1] > 0

long_signal  = cur_long  and not prev_long
short_signal = cur_short and not prev_short

long_confirmed  = long_signal  and rsi_bull and conf_4h_bull
short_confirmed = short_signal and rsi_bear and conf_4h_bear

// ─── SCORING ──────────────────────────────────────────────────────────────────

score_long = (ema_bull     ? 20 : 0) +
             (st_bull      ? 20 : 0) +
             (rsi_bull     ? 20 : 0) +
             (vol_surge    ? 20 : 0) +
             (conf_4h_bull ? 20 : 0)

score_short = (not ema_bull  ? 20 : 0) +
              (not st_bull   ? 20 : 0) +
              (rsi_bear      ? 20 : 0) +
              (vol_surge     ? 20 : 0) +
              (conf_4h_bear  ? 20 : 0)

// ─── TIER CLASSIFICATION ──────────────────────────────────────────────────────

long_std   = long_signal  and score_long  < 60
long_prime = long_signal  and score_long  >= 60 and score_long  < 80
long_elite = long_signal  and score_long  >= 80

short_std   = short_signal and score_short < 60
short_prime = short_signal and score_short >= 60 and score_short < 80
short_elite = short_signal and score_short >= 80

// ─── SIGNAL ARROWS ───────────────────────────────────────────────────────────

plotshape(show_arrows and long_signal     ? low  : na, "Long Signal",     shape.triangleup,   location.belowbar, GREEN,  size=size.small)
plotshape(show_arrows and short_signal    ? high : na, "Short Signal",    shape.triangledown, location.abovebar, RED,    size=size.small)
plotshape(show_arrows and long_confirmed  ? low  : na, "Long Confirmed",  shape.triangleup,   location.belowbar, TEAL,   size=size.normal)
plotshape(show_arrows and short_confirmed ? high : na, "Short Confirmed", shape.triangledown, location.abovebar, PURPLE, size=size.normal)

// ─── SIGNAL LABELS ───────────────────────────────────────────────────────────

if show_labels and long_signal
    score    = score_long
    tier     = score >= 80 ? "ELITE" : score >= 60 ? "PRIME" : "STD"
    lbl_text = "▲ LONG  " + tier + "  " + str.tostring(score) + "/100"
    label.new(bar_index, low - atr * 1.5, text=lbl_text, color=score >= 80 ? TEAL : GREEN, textcolor=WHITE, style=label.style_label_up, size=size.small)

if show_labels and short_signal
    score    = score_short
    tier     = score >= 80 ? "ELITE" : score >= 60 ? "PRIME" : "STD"
    lbl_text = "▼ SHORT  " + tier + "  " + str.tostring(score) + "/100"
    label.new(bar_index, high + atr * 1.5, text=lbl_text, color=score >= 80 ? PURPLE : RED, textcolor=WHITE, style=label.style_label_down, size=size.small)

// ─── DASHBOARD TABLE ─────────────────────────────────────────────────────────

var table dash = table.new(position.top_right, 2, 7, bgcolor=color.new(#111111, 10), border_color=color.new(#00C9A7, 60), border_width=1, frame_color=TEAL, frame_width=1)

if barstate.islast
    table.cell(dash, 0, 0, "T WIRE",        text_color=TEAL, text_size=size.small, bgcolor=color.new(#111111, 0), text_halign=text.align_left)
    table.cell(dash, 1, 0, "STATUS",        text_color=GREY, text_size=size.small, bgcolor=color.new(#111111, 0), text_halign=text.align_right)
    table.cell(dash, 0, 1, "EMA 50/200",    text_color=GREY, text_size=size.tiny,  text_halign=text.align_left)
    table.cell(dash, 1, 1, ema_bull ? "✔ BULL" : "✖ BEAR", text_color=ema_bull ? GREEN : RED, text_size=size.tiny, text_halign=text.align_right)
    table.cell(dash, 0, 2, "Supertrend",    text_color=GREY, text_size=size.tiny,  text_halign=text.align_left)
    table.cell(dash, 1, 2, st_bull ? "✔ BULL" : "✖ BEAR",  text_color=st_bull  ? GREEN : RED, text_size=size.tiny, text_halign=text.align_right)
    table.cell(dash, 0, 3, "RSI " + str.tostring(math.round(rsi_val)), text_color=GREY, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 3, rsi_bull ? "✔ BULL" : rsi_bear ? "✔ BEAR" : "— NEUT", text_color=rsi_bull ? GREEN : rsi_bear ? RED : GREY, text_size=size.tiny, text_halign=text.align_right)
    table.cell(dash, 0, 4, "Volume",        text_color=GREY, text_size=size.tiny,  text_halign=text.align_left)
    table.cell(dash, 1, 4, vol_surge ? "✔ SURGE" : "— NORM", text_color=vol_surge ? TEAL : GREY, text_size=size.tiny, text_halign=text.align_right)
    table.cell(dash, 0, 5, "4H Confluence", text_color=GREY, text_size=size.tiny,  text_halign=text.align_left)
    table.cell(dash, 1, 5, conf_4h_bull ? "✔ BULL" : conf_4h_bear ? "✔ BEAR" : "— MIXED", text_color=conf_4h_bull ? GREEN : conf_4h_bear ? RED : GREY, text_size=size.tiny, text_halign=text.align_right)
    cur_score = ema_bull ? score_long : score_short
    score_col = cur_score >= 80 ? TEAL : cur_score >= 60 ? GREEN : GREY
    table.cell(dash, 0, 6, "Score",         text_color=WHITE, text_size=size.tiny, text_halign=text.align_left,  bgcolor=color.new(#111111, 0))
    table.cell(dash, 1, 6, str.tostring(cur_score) + " / 100", text_color=score_col, text_size=size.small, text_halign=text.align_right, bgcolor=color.new(#111111, 0))

// ─── CANDLE LEGEND ───────────────────────────────────────────────────────────

var table leg = table.new(position.bottom_left, 2, 2, bgcolor=color.new(#111111, 10), border_color=color.new(#444444, 60), border_width=1, frame_color=GREY, frame_width=1)

if barstate.islast
    table.cell(leg, 0, 0, "CANDLE KEY", text_color=TEAL, text_size=size.tiny, text_halign=text.align_left, bgcolor=color.new(#111111, 0))
    table.cell(leg, 1, 0, "", bgcolor=color.new(#111111, 0))
    table.cell(leg, 0, 1, "  ●  ", text_color=color.new(#00C9A7, 0), text_size=size.small, text_halign=text.align_center, bgcolor=color.new(#111111, 0))
    table.cell(leg, 1, 1, "Vol Surge  ≥" + str.tostring(vol_mult) + "× avg", text_color=GREY, text_size=size.tiny, text_halign=text.align_left, bgcolor=color.new(#111111, 0))

// ─── ALERT CONDITIONS ────────────────────────────────────────────────────────

// Any signal
alertcondition(long_signal,               "T Wire — Long Signal",            "T Wire: LONG signal fired | {{ticker}} {{interval}}")
alertcondition(short_signal,              "T Wire — Short Signal",           "T Wire: SHORT signal fired | {{ticker}} {{interval}}")

// By tier — LONG
alertcondition(long_std,                  "T Wire — Long STD",               "T Wire ▲ LONG STD | {{ticker}} {{interval}}")
alertcondition(long_prime,                "T Wire — Long PRIME ⭐",          "T Wire ▲ LONG PRIME (60-79) | {{ticker}} {{interval}}")
alertcondition(long_elite,                "T Wire — Long ELITE 🔥",          "T Wire ▲ LONG ELITE (80+) | {{ticker}} {{interval}}")

// By tier — SHORT
alertcondition(short_std,                 "T Wire — Short STD",              "T Wire ▼ SHORT STD | {{ticker}} {{interval}}")
alertcondition(short_prime,               "T Wire — Short PRIME ⭐",         "T Wire ▼ SHORT PRIME (60-79) | {{ticker}} {{interval}}")
alertcondition(short_elite,               "T Wire — Short ELITE 🔥",         "T Wire ▼ SHORT ELITE (80+) | {{ticker}} {{interval}}")

// Fully confirmed (all 5 factors aligned)
alertcondition(long_confirmed,            "T Wire — Long Confirmed (All)",   "T Wire: CONFIRMED LONG — all factors aligned | {{ticker}} {{interval}}")
alertcondition(short_confirmed,           "T Wire — Short Confirmed (All)",  "T Wire: CONFIRMED SHORT — all factors aligned | {{ticker}} {{interval}}")

// PRIME or ELITE only (quality filter)
alertcondition(long_prime  or long_elite, "T Wire — Long PRIME or ELITE",   "T Wire ▲ HIGH QUALITY LONG | {{ticker}} {{interval}}")
alertcondition(short_prime or short_elite,"T Wire — Short PRIME or ELITE",  "T Wire ▼ HIGH QUALITY SHORT | {{ticker}} {{interval}}")
````
