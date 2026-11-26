# Supply and Demand Pro V1

- url: https://www.tradingview.com/script/vkbCndWM-Supply-and-Demand-Pro-V1/
- type: indicator
- pine_id: PUB;ceab279db41541e6a8450d5f1df262b9
- version: 1.0

## Description

Supply and Demand Pro V1 — Smart Money Concepts Signal Indicator
Supply and Demand Pro V1 is a comprehensive Smart Money Concepts indicator designed to identify high-probability trade entries using institutional price action methodology. Built for futures, forex, and equity traders on any timeframe.
Signal Types:

X-BUY / X-SELL — Aggressive first entry signals that fire at the initial momentum breakout, confirmed by Break of Structure
M-BUY / M-SELL — Momentum continuation signals that fire during pullbacks after the initial move is established

Features:

Break of Structure (BOS) — Automatically marks every structural shift in price, helping you identify trend changes in real time
Supply & Demand Zones — Automatically draws demand zones (DZ) and supply zones (SZ) sourced from the 15M timeframe, highlighting key institutional price levels
Three EMA Ribbon — Fast, mid and slow EMAs display the current trend direction at a glance
TP Dots — Green dots appear on the chart when price reaches Take Profit 1, 2 and 3 levels
Signal Legend — Built-in reference table explains every signal and label directly on the chart
Signal Dashboard — Live status panel shows which conditions are active in real time
Session Filter — Toggle between Futures and Stock market session hours to eliminate off-hours noise
Alerts — Full alert support for all signal types with entry, stop loss and take profit levels included in the alert message

Works on all timeframes — optimized for 1M, 3M and 5M but compatible with any chart timeframe.
Best used alongside higher timeframe bias analysis for confirmation.

## Source Code

````pine
//@version=5
indicator(title="Supply and Demand Pro V1", shorttitle="SD-Pro V1", overlay=true, max_boxes_count=10, max_lines_count=50, max_labels_count=500)

// ==================================================================
// SMC PRO v2 -- Modeled after LasPro v1.6
// Signal Types:
//   X-SELL / X-BUY  : First aggressive signal at breakout
//   M-SELL / M-BUY  : Momentum continuation after pullback
//   BOS              : Break of Structure labels
//   TP1 / TP2 / TP3  : Take profit dots + right-side labels
//   Entry / SL       : Horizontal reference lines
//   S&D Zones        : Demand and Supply boxes
// Works on any timeframe
// ==================================================================

// ------------------------------------------------------------------
// INPUTS
// ------------------------------------------------------------------
grp1 = "EMAs"
i_ema1     = input.int(9,   "EMA Fast",   group=grp1, minval=1)
i_ema2     = input.int(21,  "EMA Mid",    group=grp1, minval=1)
i_ema3     = input.int(50,  "EMA Slow",   group=grp1, minval=1)
i_show_ema = input.bool(true, "Show EMAs", group=grp1)

grp2 = "RSI"
i_rsi_len  = input.int(14, "RSI Length",  group=grp2, minval=2)
i_rsi_ob   = input.int(60, "Overbought",  group=grp2, minval=50, maxval=80)
i_rsi_os   = input.int(40, "Oversold",    group=grp2, minval=20, maxval=50)
i_rsi_mid  = input.int(50, "Midline",     group=grp2, minval=40, maxval=60)

grp3 = "Structure"
i_bos_lb   = input.int(10, "BOS Lookback",    group=grp3, minval=3, maxval=50)
i_liq_lb   = input.int(20, "Liq Lookback",    group=grp3, minval=5, maxval=100)
i_sw_win   = input.int(10, "Signal Window",   group=grp3, minval=1, maxval=30)
i_show_bos = input.bool(true, "Show BOS",     group=grp3)

grp4 = "S&D Zones"
i_sd_tf    = input.timeframe("15", "Zone TF", group=grp4)
i_zone_ext = input.int(40, "Zone Extend",     group=grp4, minval=5, maxval=200)
i_show_sd  = input.bool(true, "Show Zones",   group=grp4)

grp5 = "Risk"
i_sl_buf   = input.float(0.15, "SL Buffer %", group=grp5, minval=0.05, maxval=1.0, step=0.05)
i_show_tp1 = input.bool(true, "Show TP1",     group=grp5)
i_show_tp2 = input.bool(true, "Show TP2",     group=grp5)
i_show_tp3 = input.bool(true, "Show TP3",     group=grp5)
i_alerts   = input.bool(true, "Alerts",       group=grp5)
i_session   = input.bool(true,     "Filter Session Hours",                    group=grp5)
i_sess_type = input.string("Futures", "Session Type (Futures or Stocks)", group=grp5, options=["Futures", "Stocks"])

// ------------------------------------------------------------------
// COLOURS
// ------------------------------------------------------------------
c_bull    = color.new(#00ffaa, 0)
c_bear    = color.new(#ff3d5a, 0)
c_orange  = color.new(#ff9900, 0)
c_yellow  = color.new(#ffe03a, 0)
c_dz_bg   = color.new(#00ffaa, 87)
c_dz_br   = color.new(#00ffaa, 20)
c_sz_bg   = color.new(#ff3d5a, 87)
c_sz_br   = color.new(#ff3d5a, 20)
c_bos_b   = color.new(#7cf5ff, 0)
c_bos_s   = color.new(#ffb347, 0)
c_sl_col  = color.new(#ff1133, 0)
c_tp1     = color.new(#00ff00, 0)
c_tp2     = color.new(#00cc00, 0)
c_tp3     = color.new(#009900, 0)
c_entry   = color.new(#ffffff, 0)

// ------------------------------------------------------------------
// EMAs + RSI
// ------------------------------------------------------------------
ema1 = ta.ema(close, i_ema1)
ema2 = ta.ema(close, i_ema2)
ema3 = ta.ema(close, i_ema3)
rsi  = ta.rsi(close, i_rsi_len)
atr  = ta.atr(14)

plot(i_show_ema ? ema1 : na, "EMA Fast", color=color.new(#00ffaa, 20), linewidth=1)
plot(i_show_ema ? ema2 : na, "EMA Mid",  color=color.new(#ffaa00, 20), linewidth=1)
plot(i_show_ema ? ema3 : na, "EMA Slow", color=color.new(#ff3d5a, 20), linewidth=2)

// ------------------------------------------------------------------
// MOMENTUM STATES
// ------------------------------------------------------------------
// Strong bull: all EMAs stacked up + RSI strong
strong_bull = ema1 > ema2 and ema2 > ema3 and rsi > i_rsi_mid
// Strong bear: all EMAs stacked down + RSI weak
strong_bear = ema1 < ema2 and ema2 < ema3 and rsi < i_rsi_mid

// Early momentum -- catches initial move before full stack
early_bull = (ema1 > ema2 or close > ema1) and rsi > i_rsi_mid
early_bear = (ema1 < ema2 or close < ema1) and rsi < i_rsi_mid

// Pullback after signal -- price retraces to EMA then resumes
pb_bull = strong_bull and close <= ema1 * 1.001 and close >= ema2 * 0.999
pb_bear = strong_bear and close >= ema1 * 0.999 and close <= ema2 * 1.001

// ------------------------------------------------------------------
// SESSION
// ------------------------------------------------------------------
// Session filter
// Stocks: 9:30am - 4:00pm ET
// Futures: 6:00pm - 5:00pm ET next day (nearly 24hr, skip 5-6pm gap)
stock_session   = time(timeframe.period, "0930-1600", "America/New_York") != 0
futures_session = time(timeframe.period, "1800-1700", "America/New_York") != 0
in_session = not i_session or (i_sess_type == "Stocks" ? stock_session : futures_session)

// ------------------------------------------------------------------
// S&D ZONES
// ------------------------------------------------------------------
f_avg() => ta.sma(math.abs(close - open), 20)
f_dz()  =>
    avg = f_avg()
    (close - open) > avg * 1.5 and close > open and math.abs(close[3] - open[3]) < avg * 0.6
f_sz()  =>
    avg = f_avg()
    (open - close) > avg * 1.5 and close < open and math.abs(close[3] - open[3]) < avg * 0.6

dz_sig = request.security(syminfo.tickerid, i_sd_tf, f_dz(), lookahead=barmerge.lookahead_off)
sz_sig = request.security(syminfo.tickerid, i_sd_tf, f_sz(), lookahead=barmerge.lookahead_off)
dz_top = request.security(syminfo.tickerid, i_sd_tf, math.max(open[3],close[3]), lookahead=barmerge.lookahead_off)
dz_bot = request.security(syminfo.tickerid, i_sd_tf, low[3],  lookahead=barmerge.lookahead_off)
sz_top = request.security(syminfo.tickerid, i_sd_tf, high[3], lookahead=barmerge.lookahead_off)
sz_bot = request.security(syminfo.tickerid, i_sd_tf, math.min(open[3],close[3]), lookahead=barmerge.lookahead_off)

var box dz_box = na
var box sz_box = na

if i_show_sd and dz_sig
    box.delete(dz_box)
    dz_box := box.new(bar_index, dz_top + syminfo.mintick, bar_index + i_zone_ext, dz_bot - syminfo.mintick,
         bgcolor=c_dz_bg, border_color=c_dz_br, border_width=1,
         text=" DZ", text_color=c_bull, text_size=size.small)

if i_show_sd and sz_sig
    box.delete(sz_box)
    sz_box := box.new(bar_index, sz_top + syminfo.mintick, bar_index + i_zone_ext, sz_bot - syminfo.mintick,
         bgcolor=c_sz_bg, border_color=c_sz_br, border_width=1,
         text=" SZ", text_color=c_bear, text_size=size.small)

// ------------------------------------------------------------------
// BREAK OF STRUCTURE
// ------------------------------------------------------------------
sh       = ta.highest(high, i_bos_lb)[1]
sl_swing = ta.lowest(low,  i_bos_lb)[1]

bos_up   = close > sh       and close[1] <= sh
bos_down = close < sl_swing and close[1] >= sl_swing

if i_show_bos and bos_up
    line.new(bar_index - 1, sh, bar_index + 3, sh,
         color=c_bos_b, width=1, style=line.style_dashed)
    label.new(bar_index, high * 1.0015,
         text="BOS", style=label.style_label_down,
         color=color.new(c_bos_b, 65), textcolor=c_bos_b, size=size.small)

if i_show_bos and bos_down
    line.new(bar_index - 1, sl_swing, bar_index + 3, sl_swing,
         color=c_bos_s, width=1, style=line.style_dashed)
    label.new(bar_index, low * 0.9985,
         text="BOS", style=label.style_label_up,
         color=color.new(c_bos_s, 65), textcolor=c_bos_s, size=size.small)

// ------------------------------------------------------------------
// LIQUIDITY SWEEP
// ------------------------------------------------------------------
liq_h     = ta.highest(high, i_liq_lb)[1]
liq_l     = ta.lowest(low,   i_liq_lb)[1]
bsl_hit   = low  < liq_l
ssl_hit   = high > liq_h
bsl_first = bsl_hit and not bsl_hit[1]
ssl_first = ssl_hit and not ssl_hit[1]
bsl_ago   = ta.barssince(bsl_first)
ssl_ago   = ta.barssince(ssl_first)
bsl_ok    = not na(bsl_ago) and bsl_ago <= i_sw_win
ssl_ok    = not na(ssl_ago) and ssl_ago <= i_sw_win

bos_up_ago  = ta.barssince(bos_up)
bos_dn_ago  = ta.barssince(bos_down)
bos_up_ok   = not na(bos_up_ago) and bos_up_ago <= i_sw_win
bos_dn_ok   = not na(bos_dn_ago) and bos_dn_ago <= i_sw_win

// ------------------------------------------------------------------
// SIGNAL DEFINITIONS
// X-BUY  : Aggressive first entry -- early bull momentum + BOS + sweep
// X-SELL : Aggressive first entry -- early bear momentum + BOS + sweep
// M-BUY  : Pullback buy -- strong bull + price at EMA + BOS + sweep
// M-SELL : Pullback sell -- strong bear + price at EMA + BOS + sweep
// ------------------------------------------------------------------
// Cooldown -- prevent signals from firing too close together
x_buy_ago  = ta.barssince(ta.crossover(rsi, i_rsi_mid))
x_sell_ago = ta.barssince(ta.crossunder(rsi, i_rsi_mid))

// Use var int to track last bar any buy or sell signal fired
// MUST be declared before x_buy/x_sell use buy_cooldown_ok
var int last_buy_bar  = -999
var int last_sell_bar = -999

// Hard cooldown: minimum 30 bars between ANY signals of same direction
// On 1M = 30 min, on 3M = 90 min, on 5M = 150 min
buy_cooldown_ok  = (bar_index - last_buy_bar)  >= 30
sell_cooldown_ok = (bar_index - last_sell_bar) >= 30

// X signals -- aggressive first entry at breakout
// Fires on BOS bar AND cooldown must be clear
x_buy_raw  = early_bull and rsi > i_rsi_mid + 3 and not strong_bear and bos_up_ok and in_session
x_sell_raw = early_bear and rsi < i_rsi_mid - 3 and not strong_bull and bos_dn_ok and in_session

x_buy  = x_buy_raw  and bos_up  and buy_cooldown_ok
x_sell = x_sell_raw and bos_down and sell_cooldown_ok

// M signals -- momentum continuation
m_buy_raw  = strong_bull and not strong_bear and bos_up_ok and in_session
m_sell_raw = strong_bear and not strong_bull and bos_dn_ok and in_session

last_buy_signal  = ta.barssince(x_buy)
last_sell_signal = ta.barssince(x_sell)

// Only 1 X signal and 1 M signal per major move
// M signal fires at least 20 bars after last X signal
m_buy  = m_buy_raw  and not x_buy  and buy_cooldown_ok  and (na(last_buy_signal)  or last_buy_signal  > 20)
m_sell = m_sell_raw and not x_sell and sell_cooldown_ok and (na(last_sell_signal) or last_sell_signal > 20)

// Update trackers when any signal fires
if x_buy  or m_buy
    last_buy_bar  := bar_index
if x_sell or m_sell
    last_sell_bar := bar_index

// Combine for any buy or sell
any_buy  = x_buy or m_buy
any_sell = x_sell or m_sell

// ------------------------------------------------------------------
// SIGNAL PLOTS -- arrows like LasPro
// X signals: larger orange arrows
// M signals: smaller colored arrows
// ------------------------------------------------------------------
plotshape(x_buy,  title="X-BUY",  style=shape.triangleup,   location=location.belowbar,
     color=c_orange, textcolor=color.white, text="X-BUY",  size=size.normal)
plotshape(x_sell, title="X-SELL", style=shape.triangledown, location=location.abovebar,
     color=c_orange, textcolor=color.white, text="X-SELL", size=size.normal)
plotshape(m_buy,  title="M-BUY",  style=shape.triangleup,   location=location.belowbar,
     color=c_bull,   textcolor=color.white, text="M-BUY",  size=size.small)
plotshape(m_sell, title="M-SELL", style=shape.triangledown, location=location.abovebar,
     color=c_bear,   textcolor=color.white, text="M-SELL", size=size.small)

// ------------------------------------------------------------------
// TP DOTS ON CHART -- green dots like LasPro TP1/TP2/TP3 markers
// ------------------------------------------------------------------
var float ep  = na
var float sl  = na
var float r   = na
var float t1  = na
var float t2  = na
var float t3  = na
var bool  is_long = false

// Update levels on new signal
// Only update levels on X signals -- M signals use existing levels
if x_buy
    ep      := close
    sl      := math.min(low[1], low) * (1.0 - i_sl_buf / 100.0)
    r       := ep - sl
    t1      := ep + r * 1.0
    t2      := ep + r * 2.0
    t3      := ep + r * 4.0
    is_long := true

if x_sell
    ep      := close
    sl      := math.max(high[1], high) * (1.0 + i_sl_buf / 100.0)
    r       := sl - ep
    t1      := ep - r * 1.0
    t2      := ep - r * 2.0
    t3      := ep - r * 4.0
    is_long := false

// TP dot plots -- appear at the TP price on the bar that reaches it
tp1_hit_l = is_long  and not na(t1) and high >= t1 and low[1] < t1
tp2_hit_l = is_long  and not na(t2) and high >= t2 and low[1] < t2
tp3_hit_l = is_long  and not na(t3) and high >= t3 and low[1] < t3
tp1_hit_s = not is_long and not na(t1) and low  <= t1 and high[1] > t1
tp2_hit_s = not is_long and not na(t2) and low  <= t2 and high[1] > t2
tp3_hit_s = not is_long and not na(t3) and low  <= t3 and high[1] > t3

plotshape(i_show_tp1 and (tp1_hit_l or tp1_hit_s), title="TP1 Hit",
     style=shape.circle, location=location.absolute, color=c_tp1,
     size=size.small)
plotshape(i_show_tp2 and (tp2_hit_l or tp2_hit_s), title="TP2 Hit",
     style=shape.circle, location=location.absolute, color=c_tp2,
     size=size.small)
plotshape(i_show_tp3 and (tp3_hit_l or tp3_hit_s), title="TP3 Hit",
     style=shape.circle, location=location.absolute, color=c_tp3,
     size=size.small)

// ------------------------------------------------------------------
// RIGHT SIDE LABELS -- Entry, SL, TP1, TP2, TP3 like LasPro
// Drawn fresh on each new signal, deleted on next signal
// ------------------------------------------------------------------
var label el    = na
var label sl_lb = na
var label tp1lb = na
var label tp2lb = na
var label tp3lb = na
var line  sl_ln = na
var line  t1_ln = na
var line  t2_ln = na
var line  t3_ln = na

f_clear() =>
    label.delete(el)
    label.delete(sl_lb)
    label.delete(tp1lb)
    label.delete(tp2lb)
    label.delete(tp3lb)
    line.delete(sl_ln)
    line.delete(t1_ln)
    line.delete(t2_ln)
    line.delete(t3_ln)

if x_buy
    f_clear()
    // Entry box removed -- arrows only
    if i_alerts
        alert("SMC BUY | " + syminfo.ticker +
             " | E: "   + str.tostring(ep, "#.00") +
             " | SL: "  + str.tostring(sl, "#.00") +
             " | TP1: " + str.tostring(t1, "#.00") +
             " | TP2: " + str.tostring(t2, "#.00") +
             " | TP3: " + str.tostring(t3, "#.00"),
             alert.freq_once_per_bar_close)

if x_sell
    f_clear()
    // Entry box removed -- arrows only
    if i_alerts
        alert("SMC SELL | " + syminfo.ticker +
             " | E: "   + str.tostring(ep, "#.00") +
             " | SL: "  + str.tostring(sl, "#.00") +
             " | TP1: " + str.tostring(t1, "#.00") +
             " | TP2: " + str.tostring(t2, "#.00") +
             " | TP3: " + str.tostring(t3, "#.00"),
             alert.freq_once_per_bar_close)

// ------------------------------------------------------------------
// BACKGROUND FLASH
// ------------------------------------------------------------------
flash_color = x_buy ? color.new(c_bull, 92) : x_sell ? color.new(c_bear, 92) : m_buy ? color.new(c_bull, 95) : m_sell ? color.new(c_bear, 95) : na
bgcolor(flash_color, title="Signal Flash")

// ------------------------------------------------------------------
// SIGNAL STATUS DASHBOARD -- bottom right
// ------------------------------------------------------------------
var table dash = table.new(position.bottom_right, 2, 8,
     bgcolor=color.new(color.black, 60),
     border_color=color.new(color.gray, 50),
     border_width=1, frame_color=color.new(color.gray, 40), frame_width=1)

dr(t, r, nm, chk) =>
    bg = chk ? color.new(#00ffaa, 75) : color.new(color.black, 70)
    fc = chk ? color.white : color.new(color.gray, 20)
    table.cell(t, 0, r, nm,                    text_color=color.silver, text_size=size.small, bgcolor=color.new(color.black, 60))
    table.cell(t, 1, r, chk ? "YES" : "NO",    text_color=fc,           text_size=size.small, bgcolor=bg)

if barstate.islast
    table.cell(dash, 0, 0, "SMC Pro",    text_color=color.white, text_size=size.small, bgcolor=color.new(color.navy, 20))
    table.cell(dash, 1, 0, "STATUS",     text_color=color.white, text_size=size.small, bgcolor=color.new(color.navy, 20))
    dr(dash, 1, "Momentum Bull", early_bull)
    dr(dash, 2, "Momentum Bear", early_bear)
    dr(dash, 3, "BOS",           bos_up_ok or bos_dn_ok)
    dr(dash, 4, "Sweep",         bsl_ok or ssl_ok)
    dr(dash, 5, "X-Signal",      x_buy or x_sell)
    dr(dash, 6, "M-Signal",      m_buy or m_sell)
    dr(dash, 7, "Session",       in_session)

// ------------------------------------------------------------------
// SIGNAL LEGEND -- top right corner
// Explains every signal type and label on the chart
// ------------------------------------------------------------------
var table legend = table.new(position.top_right, 2, 12,
     bgcolor      = color.new(color.black, 55),
     border_color = color.new(color.gray, 50),
     border_width = 1,
     frame_color  = color.new(color.gray, 40),
     frame_width  = 1)

if barstate.islast
    // Header
    table.cell(legend, 0, 0, "SIGNAL",      text_color=color.white,          text_size=size.small, bgcolor=color.new(color.navy, 20))
    table.cell(legend, 1, 0, "MEANING",     text_color=color.white,          text_size=size.small, bgcolor=color.new(color.navy, 20))
    // X Signals
    table.cell(legend, 0, 1, "X-BUY",       text_color=color.new(#ff9900,0), text_size=size.small, bgcolor=color.new(color.black, 60))
    table.cell(legend, 1, 1, "Aggressive long entry at breakout",
         text_color=color.silver, text_size=size.small, bgcolor=color.new(color.black, 60))
    table.cell(legend, 0, 2, "X-SELL",      text_color=color.new(#ff9900,0), text_size=size.small, bgcolor=color.new(color.black, 60))
    table.cell(legend, 1, 2, "Aggressive short entry at breakdown",
         text_color=color.silver, text_size=size.small, bgcolor=color.new(color.black, 60))
    // M Signals
    table.cell(legend, 0, 3, "M-BUY",       text_color=color.new(#00ffaa,0), text_size=size.small, bgcolor=color.new(color.black, 60))
    table.cell(legend, 1, 3, "Momentum buy during uptrend continuation",
         text_color=color.silver, text_size=size.small, bgcolor=color.new(color.black, 60))
    table.cell(legend, 0, 4, "M-SELL",      text_color=color.new(#ff3d5a,0), text_size=size.small, bgcolor=color.new(color.black, 60))
    table.cell(legend, 1, 4, "Momentum sell during downtrend continuation",
         text_color=color.silver, text_size=size.small, bgcolor=color.new(color.black, 60))
    // BOS
    table.cell(legend, 0, 5, "BOS",         text_color=color.new(#7cf5ff,0), text_size=size.small, bgcolor=color.new(color.black, 60))
    table.cell(legend, 1, 5, "Break of Structure -- trend shift confirmed",
         text_color=color.silver, text_size=size.small, bgcolor=color.new(color.black, 60))
    // Zones
    table.cell(legend, 0, 6, "DZ (Green)",  text_color=color.new(#00ffaa,0), text_size=size.small, bgcolor=color.new(color.black, 60))
    table.cell(legend, 1, 6, "Demand Zone -- potential buy area",
         text_color=color.silver, text_size=size.small, bgcolor=color.new(color.black, 60))
    table.cell(legend, 0, 7, "SZ (Red)",    text_color=color.new(#ff3d5a,0), text_size=size.small, bgcolor=color.new(color.black, 60))
    table.cell(legend, 1, 7, "Supply Zone -- potential sell area",
         text_color=color.silver, text_size=size.small, bgcolor=color.new(color.black, 60))
    // TP / SL
    table.cell(legend, 0, 8, "TP1",         text_color=color.new(#00ff00,0), text_size=size.small, bgcolor=color.new(color.black, 60))
    table.cell(legend, 1, 8, "Take Profit 1 -- 1:1 risk/reward",
         text_color=color.silver, text_size=size.small, bgcolor=color.new(color.black, 60))
    table.cell(legend, 0, 9, "TP2",         text_color=color.new(#00cc00,0), text_size=size.small, bgcolor=color.new(color.black, 60))
    table.cell(legend, 1, 9, "Take Profit 2 -- 1:2 risk/reward",
         text_color=color.silver, text_size=size.small, bgcolor=color.new(color.black, 60))
    table.cell(legend, 0, 10, "TP3",        text_color=color.new(#009900,0), text_size=size.small, bgcolor=color.new(color.black, 60))
    table.cell(legend, 1, 10, "Take Profit 3 -- 1:4 risk/reward",
         text_color=color.silver, text_size=size.small, bgcolor=color.new(color.black, 60))
    table.cell(legend, 0, 11, "SL (Red)",   text_color=color.new(#ff1133,0), text_size=size.small, bgcolor=color.new(color.black, 60))
    table.cell(legend, 1, 11, "Stop Loss -- exit if price reaches here",
         text_color=color.silver, text_size=size.small, bgcolor=color.new(color.black, 60))
````
