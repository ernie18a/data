# T Wire Live V2

- url: https://www.tradingview.com/script/jo3LHikq-T-Wire-Live-V2/
- type: indicator
- pine_id: PUB;a0c807b64d1e447ba66ab08ee3dbe11e
- version: 1.0

## Description

Used for Twire trading primarily on XRP on leverage

## Source Code

````pine
//@version=5
indicator("T Wire Indicator", shorttitle="T Wire", overlay=true, max_labels_count=500)

// ─── INPUTS ───────────────────────────────────────────────────────────────────

var string GRP_EMA = "EMA Settings"
ema_fast_len = input.int(50,  "Fast EMA",  minval=1, group=GRP_EMA)
ema_slow_len = input.int(200, "Slow EMA",  minval=1, group=GRP_EMA)
show_emas    = input.bool(true, "Show EMA Lines", group=GRP_EMA)

var string GRP_ST = "Supertrend Settings"
st_period = input.int(10,  "ATR Period",     minval=1,   group=GRP_ST)
st_mult   = input.float(3.0, "ATR Multiplier", minval=0.1, group=GRP_ST)
show_st   = input.bool(true, "Show Supertrend Line", group=GRP_ST)

var string GRP_RSI = "RSI Settings"
rsi_len      = input.int(14, "RSI Length", minval=1, group=GRP_RSI)
rsi_ob       = input.int(70, "Overbought", group=GRP_RSI)
rsi_os       = input.int(30, "Oversold",   group=GRP_RSI)
show_rsi_tbl = input.bool(true, "Show RSI Badge", group=GRP_RSI)

var string GRP_VOL = "Volume Settings"
vol_len    = input.int(20, "Volume MA Length", minval=1, group=GRP_VOL)
vol_mult   = input.float(1.5, "Surge Multiplier", minval=1.0, group=GRP_VOL)
show_vol   = input.bool(true, "Highlight Volume Surges", group=GRP_VOL)

var string GRP_SIG = "Signal Settings"
show_labels  = input.bool(true, "Show Signal Labels",  group=GRP_SIG)
show_arrows  = input.bool(true, "Show Signal Arrows",  group=GRP_SIG)

// ─── COLOURS ──────────────────────────────────────────────────────────────────

TEAL    = color.new(#00C9A7, 0)
TEAL_T  = color.new(#00C9A7, 80)
GREEN   = color.new(#2ECC71, 0)
GREEN_T = color.new(#2ECC71, 80)
RED     = color.new(#E74C3C, 0)
RED_T   = color.new(#E74C3C, 80)
BLUE    = color.new(#3B8EEA, 0)
ORANGE  = color.new(#FF7A00, 0)
GREY    = color.new(#888888, 0)
WHITE   = color.new(#FFFFFF, 0)
DARK    = color.new(#111111, 0)

// ─── EMA ──────────────────────────────────────────────────────────────────────

ema_fast = ta.ema(close, ema_fast_len)
ema_slow = ta.ema(close, ema_slow_len)

ema_bull = ema_fast > ema_slow

p_fast = plot(show_emas ? ema_fast : na, "EMA 50",  color=BLUE,   linewidth=1)
p_slow = plot(show_emas ? ema_slow : na, "EMA 200", color=ORANGE, linewidth=2)

// EMA ribbon fill
fill(p_fast, p_slow, color = ema_bull ? color.new(#2ECC71, 90) : color.new(#E74C3C, 90), title="EMA Ribbon")

// ─── SUPERTREND ───────────────────────────────────────────────────────────────

[st_val, st_dir] = ta.supertrend(st_mult, st_period)

st_bull = st_dir < 0   // Pine Script supertrend: dir < 0 = bullish
st_line_color = st_bull ? GREEN : RED

plot(show_st ? st_val : na, "Supertrend",
     color=st_line_color, linewidth=2, style=plot.style_line)

// ─── RSI ──────────────────────────────────────────────────────────────────────

rsi_val  = ta.rsi(close, rsi_len)
rsi_bull = rsi_val > 50 and rsi_val < rsi_ob   // bullish zone — above 50, not overbought
rsi_bear = rsi_val < 50 and rsi_val > rsi_os   // bearish zone — below 50, not oversold

// ─── VOLUME SURGE ─────────────────────────────────────────────────────────────

vol_ma    = ta.sma(volume, vol_len)
vol_surge = volume > vol_ma * vol_mult

barcolor(show_vol and vol_surge ? color.new(TEAL, 60) : na, title="Volume Surge Bar")

// ─── ATR (used for label offset — scales with volatility) ─────────────────────

atr = ta.atr(14)

// ─── 4H CONFLUENCE ───────────────────────────────────────────────────────────

ema_fast_4h = request.security(syminfo.tickerid, "240", ta.ema(close, ema_fast_len), lookahead=barmerge.lookahead_off)
ema_slow_4h = request.security(syminfo.tickerid, "240", ta.ema(close, ema_slow_len), lookahead=barmerge.lookahead_off)
[_, st_dir_4h] = request.security(syminfo.tickerid, "240", ta.supertrend(st_mult, st_period), lookahead=barmerge.lookahead_off)

conf_4h_bull = ema_fast_4h > ema_slow_4h and st_dir_4h < 0
conf_4h_bear = ema_fast_4h < ema_slow_4h and st_dir_4h > 0

// ─── SIGNAL CONDITIONS ────────────────────────────────────────────────────────
// Matches the T Wire Bot logic exactly:
// LONG  : EMA 50 > EMA 200  AND  Supertrend bullish  — fires on FIRST candle where both align
// SHORT : EMA 50 < EMA 200  AND  Supertrend bearish  — fires on FIRST candle where both align

cur_long  = ema_bull and st_bull
cur_short = not ema_bull and not st_bull

prev_long  = ema_fast[1] > ema_slow[1] and st_dir[1] < 0
prev_short = ema_fast[1] < ema_slow[1] and st_dir[1] > 0

// Primary signal — matches bot exactly
long_signal  = cur_long  and not prev_long
short_signal = cur_short and not prev_short

// Enhanced signal — additional RSI + 4H confluence confirmation
long_confirmed  = long_signal  and rsi_bull and conf_4h_bull
short_confirmed = short_signal and rsi_bear and conf_4h_bear

// ─── SCORING (visual only) ────────────────────────────────────────────────────
// Each factor worth 20 pts — max 100

score_long = (ema_bull ? 20 : 0) +
             (st_bull   ? 20 : 0) +
             (rsi_bull  ? 20 : 0) +
             (vol_surge ? 20 : 0) +
             (conf_4h_bull ? 20 : 0)

score_short = (not ema_bull   ? 20 : 0) +
              (not st_bull    ? 20 : 0) +
              (rsi_bear       ? 20 : 0) +
              (vol_surge      ? 20 : 0) +
              (conf_4h_bear   ? 20 : 0)

// ─── SIGNAL ARROWS ───────────────────────────────────────────────────────────

plotshape(show_arrows and long_signal ? low : na, title="Long Signal", style=shape.triangleup, location=location.belowbar, color=GREEN, size=size.small)
plotshape(show_arrows and short_signal ? high : na, title="Short Signal", style=shape.triangledown, location=location.abovebar, color=RED, size=size.small)
plotshape(show_arrows and long_confirmed ? low : na, title="Long Confirmed", style=shape.triangleup, location=location.belowbar, color=TEAL, size=size.normal)
plotshape(show_arrows and short_confirmed ? high : na, title="Short Confirmed", style=shape.triangledown, location=location.abovebar, color=color.new(#8B5CF6, 0), size=size.normal)

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
    label.new(bar_index, high + atr * 1.5, text=lbl_text, color=score >= 80 ? color.new(#8B5CF6, 0) : RED, textcolor=WHITE, style=label.style_label_down, size=size.small)

// ─── DASHBOARD TABLE ─────────────────────────────────────────────────────────

var table dash = table.new(position.top_right, 2, 7, bgcolor=color.new(#111111, 10), border_color=color.new(#00C9A7, 60), border_width=1, frame_color=TEAL, frame_width=1)

if barstate.islast
    table.cell(dash, 0, 0, "T WIRE", text_color=TEAL, text_size=size.small, bgcolor=color.new(#111111, 0), text_halign=text.align_left)
    table.cell(dash, 1, 0, "STATUS", text_color=GREY, text_size=size.small, bgcolor=color.new(#111111, 0), text_halign=text.align_right)
    table.cell(dash, 0, 1, "EMA 50/200", text_color=GREY, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 1, ema_bull ? "✔ BULL" : "✖ BEAR", text_color=ema_bull ? GREEN : RED, text_size=size.tiny, text_halign=text.align_right)
    table.cell(dash, 0, 2, "Supertrend", text_color=GREY, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 2, st_bull ? "✔ BULL" : "✖ BEAR", text_color=st_bull ? GREEN : RED, text_size=size.tiny, text_halign=text.align_right)
    table.cell(dash, 0, 3, "RSI " + str.tostring(math.round(rsi_val)), text_color=GREY, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 3, rsi_bull ? "✔ BULL" : rsi_bear ? "✔ BEAR" : "— NEUT", text_color=rsi_bull ? GREEN : rsi_bear ? RED : GREY, text_size=size.tiny, text_halign=text.align_right)
    table.cell(dash, 0, 4, "Volume", text_color=GREY, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 4, vol_surge ? "✔ SURGE" : "— NORM", text_color=vol_surge ? TEAL : GREY, text_size=size.tiny, text_halign=text.align_right)
    table.cell(dash, 0, 5, "4H Confluence", text_color=GREY, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 5, conf_4h_bull ? "✔ BULL" : conf_4h_bear ? "✔ BEAR" : "— MIXED", text_color=conf_4h_bull ? GREEN : conf_4h_bear ? RED : GREY, text_size=size.tiny, text_halign=text.align_right)
    cur_score = ema_bull ? score_long : score_short
    score_col = cur_score >= 80 ? TEAL : cur_score >= 60 ? GREEN : GREY
    table.cell(dash, 0, 6, "Score", text_color=WHITE, text_size=size.tiny, text_halign=text.align_left, bgcolor=color.new(#111111, 0))
    table.cell(dash, 1, 6, str.tostring(cur_score) + " / 100", text_color=score_col, text_size=size.small, text_halign=text.align_right, bgcolor=color.new(#111111, 0))

// ─── CANDLE COLOUR LEGEND ────────────────────────────────────────────────────

var table leg = table.new(position.bottom_left, 2, 2,
     bgcolor=color.new(#111111, 10),
     border_color=color.new(#444444, 60), border_width=1,
     frame_color=GREY, frame_width=1)

if barstate.islast
    table.cell(leg, 0, 0, "CANDLE KEY", text_color=TEAL, text_size=size.tiny,
         text_halign=text.align_left, bgcolor=color.new(#111111, 0))
    table.cell(leg, 1, 0, "", bgcolor=color.new(#111111, 0))
    table.cell(leg, 0, 1, "  ●  ", text_color=color.new(#00C9A7, 0), text_size=size.small,
         text_halign=text.align_center, bgcolor=color.new(#111111, 0))
    table.cell(leg, 1, 1, "Vol Surge  ≥" + str.tostring(vol_mult) + "× avg",
         text_color=GREY, text_size=size.tiny,
         text_halign=text.align_left, bgcolor=color.new(#111111, 0))

// ─── ALERTS ───────────────────────────────────────────────────────────────────

alertcondition(long_signal,     "T Wire — Long Signal",           "T Wire: LONG signal fired")
alertcondition(short_signal,    "T Wire — Short Signal",          "T Wire: SHORT signal fired")
alertcondition(long_confirmed,  "T Wire — Long Confirmed (All)",  "T Wire: CONFIRMED LONG — all factors aligned")
alertcondition(short_confirmed, "T Wire — Short Confirmed (All)", "T Wire: CONFIRMED SHORT — all factors aligned")
````
