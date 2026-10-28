# Acrofins - Momentum Scanner

- url: https://www.tradingview.com/script/vOJZHX9M-Acrofins-Momentum-Scanner/
- type: indicator
- pine_id: PUB;86da37e30c024f828e992ec9906da6b0
- version: 1.0

## Description

Acrofins - Momentum Scanner for Nifty and Index Traders
This is a multi-factor momentum scanner built specifically for index trading on Nifty 50, Bank Nifty, and similar instruments. It combines 10 independent technical conditions into a single composite score, and only generates a Buy or Sell signal when enough of those conditions align at the same time. The goal is simple: fewer signals, but each one backed by strong confluence across price, volume, trend, and market structure.

1. How the scoring works
Every bar on the chart is evaluated against 10 conditions. Each condition contributes 1 point to either the bull score or the bear score, except for a price breakout which contributes 2 points because it is historically the strongest signal. The maximum possible score is 11. You can set a minimum threshold in the settings (default is 5), and a signal is only generated when the score crosses that threshold. This means the indicator waits for multiple conditions to agree before calling a trade.

The 10 conditions are:

i. Price Breakout (2 points): Price closes above the highest high of the last 20 bars for a buy, or below the lowest low for a sell. This is the foundation of the signal.

ii. Directional Volume Spike: Volume is above 1.5x its 20-bar average AND the candle closes in the direction of the trade. This filters out volume spikes that occur on opposing candles, which most volume indicators ignore.

iii. RSI Zone (current timeframe): RSI is above 55 for bulls or below 45 for bears. Unlike a crossover, this is a persistent zone check so it does not fire and disappear in a single bar.

iv.RSI 1-Hour Confluence: The 1-hour RSI is checked simultaneously. If the higher timeframe RSI agrees with the signal direction, it adds a point. This is a simple multi-timeframe filter that prevents entering a short-term trade that is running against the larger trend.

v.Engulfing Candle Pattern: A classic bullish or bearish engulfing pattern on the signal bar adds a point for pattern confirmation.

vi. Candle Body Strength: The candle body must be at least 60% of the 10-bar average body size. This filters out doji and indecision candles so the entry bar itself shows conviction.

vii.DMI Direction (DI+ vs DI-): If the positive directional index is stronger than the negative, it adds a bull point and vice versa. This checks who is winning the tug of war between buyers and sellers.

viii. ADX Strength Bonus: If the ADX reading is above 25, an extra point is added. This rewards signals that appear during strong trending conditions.

ix. VWAP Bias: Price above the session VWAP adds a bull point, below adds a bear point. VWAP is the benchmark that institutional desks use as a reference during the day, so being on the right side of it matters.

x. Camarilla Proximity: If price is near a Camarilla support level (L3 or L4) it adds a bull point. Near resistance (H3 or H4) adds a bear point. These levels are calculated from the previous day's high, low, and close, and they act as natural reaction zones that many professional traders watch.

2. Regime gates (hard filters)
Two conditions must both be true before any signal can fire, regardless of the score. First, ADX must be above 20, which blocks all signals in flat and ranging markets. Second, the Bollinger Band width must not be in a squeeze, meaning the bands are not contracting relative to their 50-bar average. These gates exist because most false signals in momentum trading occur during consolidation phases.

3. EMA direction filter
There is an optional EMA-50 direction filter that can be toggled on or off. When active, buy signals can only fire when price is above the EMA-50, and sell signals can only fire when price is below it. This prevents counter-trend entries. On the chart you will see two EMA lines: the yellow EMA-20 which moves close to price and shows short-term direction, and the colored EMA-50 which turns green above and red below to show the overall trend.

4. Trade management
Once a signal fires, the indicator automatically calculates three levels based on the current ATR (Average True Range), which makes the levels adapt to the actual volatility of the instrument at that moment rather than using fixed percentages. The Stop Loss is set at 1.5x ATR below the entry for longs, above for shorts. The Take Profit is set at 3x ATR, giving a natural 1:2 risk-reward ratio. The Trailing Stop starts at 2x ATR but does not activate immediately. It only switches on after the trade has moved at least 1 ATR in your favour, which gives the trade room to breathe before the trail kicks in. Once active, it ratchets in your direction and never moves against you. After any exit, whether by stop loss, take profit, or trailing stop, the indicator enforces a cooldown of 5 bars before a new signal can be generated. This is the core fix that prevents the rapid signal repetition that many momentum indicators suffer from.

5. What you see on the chart
A large green BUY label below the bar and a large red SELL label above the bar are the primary action signals. An orange X mark appears when a trade is closed.
The blue dashed horizontal line is the entry price. The red solid line is the stop loss. The green solid line is the take profit. The orange dotted line is the trailing stop, which moves upward for longs as the trade progresses. The aqua VWAP line with faded bands shows where price stands relative to the session's volume-weighted average. The green and red dotted Camarilla levels (L3, L4, H3, H4) are the previous day's key support and resistance zones and remain fixed throughout the trading day. The background shading gives a quick read on market state. A faint green tint means price is above the EMA-50 and only buy signals are allowed. A faint red tint means price is below and only sell signals are allowed. When you are actively in a trade, the tint becomes brighter to confirm the open position.

6. The information table (top right)
The table shows the live status of every component in one place. Position, entry price, stop loss, take profit, and trailing stop are shown when a trade is open. Below that you can read the EMA trend direction, ADX value and strength rating, Bollinger Band regime status, India VIX with its 52-week IV rank percentile, RSI on both the current timeframe and the 1-hour, VWAP bias, Camarilla proximity, current bull and bear scores, and the indicator status which shows whether it is ready to trade, waiting out a cooldown, or paused due to a ranging market.

7. Settings you can adjust
All major parameters are grouped in the settings panel. You can change the EMA periods, the minimum score required to trade, the cooldown length, the ATR multipliers for stop loss, take profit and trailing stop, the ADX thresholds, the RSI zones, the volume spike multiplier, and the Bollinger Band period. Each group is labelled clearly so you can find what you need quickly. The indicator also comes with five built-in alerts covering buy entry, sell entry, long exit, short exit, and squeeze detection.

8. A note on India VIX
The India VIX data feed requires an NSE data subscription on TradingView. If it shows N/A in the table, this is a data access issue at the platform level and does not affect any of the signals.

## Source Code

````pine
//@version=5
indicator("Acrofins", shorttitle="ACR", overlay=true, max_bars_back=500)

//══════════════════════════════════════════════════════════════════════
// INPUTS
//══════════════════════════════════════════════════════════════════════

g_ema = "EMA"
ema_fast_len   = input.int(20,    "Fast",       group=g_ema)
ema_slow_len   = input.int(50,    "Slow",       group=g_ema)
use_ema_filter = input.bool(true, "Filter dir", group=g_ema)

g_sig = "Signal"
breakout_len = input.int(20, "Breakout bars", group=g_sig)
min_score    = input.int(5,  "Min score",     minval=1, maxval=11, group=g_sig)
cooldown_len = input.int(5,  "Cooldown bars", minval=1, maxval=15, group=g_sig)

g_vol = "Volume"
vol_period = input.int(20,    "MA period",  group=g_vol)
vol_mult   = input.float(1.5, "Spike mult", step=0.1, group=g_vol)

g_rsi = "RSI"
rsi_len     = input.int(14, "Period",    group=g_rsi)
rsi_bull_th = input.int(55, "Bull zone", group=g_rsi)
rsi_bear_th = input.int(45, "Bear zone", group=g_rsi)

g_adx = "ADX"
adx_len       = input.int(14, "Period",       group=g_adx)
adx_min_th    = input.int(20, "Min (no trade)", group=g_adx)
adx_strong_th = input.int(25, "Strong bonus", group=g_adx)

g_bb = "BB Regime"
bb_len     = input.int(20,     "Period",  group=g_bb)
bb_mult_in = input.float(2.0,  "Std dev", step=0.1, group=g_bb)
show_bb    = input.bool(false, "Show BB", group=g_bb)

g_vwap = "VWAP"
show_vwap      = input.bool(true, "Show VWAP",  group=g_vwap)
show_vwap_band = input.bool(true, "Show bands", group=g_vwap)

g_pvt = "Pivots"
show_pivots = input.bool(true, "Show Camarilla", group=g_pvt)

g_trd = "Trade Mgmt"
atr_len        = input.int(14,    "ATR period",        group=g_trd)
atr_sl_mult    = input.float(1.5, "SL = ATR x",        step=0.1, group=g_trd)
atr_tp_mult    = input.float(3.0, "TP = ATR x",        step=0.1, group=g_trd)
trail_atr_mult = input.float(2.0, "Trail = ATR x",     step=0.1, group=g_trd)
trail_act_mult = input.float(1.0, "Trail after x ATR", group=g_trd)

//══════════════════════════════════════════════════════════════════════
// CORE CALCULATIONS
//══════════════════════════════════════════════════════════════════════

atr = ta.atr(atr_len)

// EMAs
ema_fast  = ta.ema(close, ema_fast_len)
ema_slow  = ta.ema(close, ema_slow_len)
above_ema = close > ema_slow
below_ema = close < ema_slow

// Bollinger Bands
[bb_mid, bb_upper, bb_lower] = ta.bb(close, bb_len, bb_mult_in)
bb_width     = bb_upper - bb_lower
bb_width_sma = ta.sma(bb_width, 50)
in_squeeze   = not na(bb_width_sma) and bb_width < bb_width_sma * 0.75

// ADX / DMI
[dmi_plus, dmi_minus, adx_val] = ta.dmi(adx_len, adx_len)
is_trending = adx_val >= adx_min_th
is_strong   = adx_val >= adx_strong_th
bull_dmi    = dmi_plus > dmi_minus
bear_dmi    = dmi_minus > dmi_plus

// RSI current TF
rsi        = ta.rsi(close, rsi_len)
rsi_bull_z = rsi > rsi_bull_th
rsi_bear_z = rsi < rsi_bear_th

// RSI 1H MTF
rsi_1h      = request.security(syminfo.tickerid, "60", ta.rsi(close, 14), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
rsi_1h_bull = rsi_1h > 50
rsi_1h_bear = rsi_1h < 50

// India VIX
india_vix  = request.security("NSE:INDIAVIX", "D", close,                  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
vix_52h    = request.security("NSE:INDIAVIX", "D", ta.highest(close, 252), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
vix_52l    = request.security("NSE:INDIAVIX", "D", ta.lowest(close, 252),  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
iv_rank    = na(india_vix) or na(vix_52h) or na(vix_52l) or vix_52h == vix_52l ? na : (india_vix - vix_52l) / (vix_52h - vix_52l) * 100
vix_ok     = not na(india_vix) and india_vix < 22
vix_danger = not na(india_vix) and india_vix > 25

// VWAP
vwap_val   = ta.vwap(hlc3)
vwap_dev   = ta.stdev(hlc3, 20)
vwap_upper = vwap_val + vwap_dev
vwap_lower = vwap_val - vwap_dev
above_vwap = close > vwap_val
below_vwap = close < vwap_val

// Camarilla Pivots
pHigh  = request.security(syminfo.tickerid, "D", high[1],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
pLow   = request.security(syminfo.tickerid, "D", low[1],   gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
pClose = request.security(syminfo.tickerid, "D", close[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
cam_range    = pHigh - pLow
cam_h4       = pClose + cam_range * 0.550
cam_h3       = pClose + cam_range * 0.275
cam_l3       = pClose - cam_range * 0.275
cam_l4       = pClose - cam_range * 0.550
near_support = math.abs(close - cam_l3) <= atr or math.abs(close - cam_l4) <= atr
near_resist  = math.abs(close - cam_h3) <= atr or math.abs(close - cam_h4) <= atr

// Breakout
prev_hh       = ta.highest(high, breakout_len)[1]
prev_ll       = ta.lowest(low,  breakout_len)[1]
bull_breakout = close > prev_hh
bear_breakout = close < prev_ll

// Volume
avg_vol        = ta.sma(volume, vol_period)
vol_spike_raw  = volume > avg_vol * vol_mult
bull_vol_spike = vol_spike_raw and close > open
bear_vol_spike = vol_spike_raw and close < open

// Candle patterns
bull_engulf = close[1] < open[1] and close > open and open <= close[1] and close >= open[1]
bear_engulf = close[1] > open[1] and close < open and open >= close[1] and close <= open[1]
body        = math.abs(close - open)
avg_body    = ta.sma(body, 10)
bull_body   = close > open and body > avg_body * 0.6
bear_body   = close < open and body > avg_body * 0.6

//══════════════════════════════════════════════════════════════════════
// COMPOSITE SCORE (max 11)
//══════════════════════════════════════════════════════════════════════

bull_score = (bull_breakout ? 2 : 0) + (bull_vol_spike ? 1 : 0) + (rsi_bull_z ? 1 : 0) + (rsi_1h_bull ? 1 : 0) + (bull_engulf ? 1 : 0) + (bull_body ? 1 : 0) + (bull_dmi ? 1 : 0) + (is_strong ? 1 : 0) + (above_vwap ? 1 : 0) + (near_support ? 1 : 0)
bear_score = (bear_breakout ? 2 : 0) + (bear_vol_spike ? 1 : 0) + (rsi_bear_z ? 1 : 0) + (rsi_1h_bear ? 1 : 0) + (bear_engulf ? 1 : 0) + (bear_body ? 1 : 0) + (bear_dmi ? 1 : 0) + (is_strong ? 1 : 0) + (below_vwap ? 1 : 0) + (near_resist ? 1 : 0)

regime_ok = is_trending and not in_squeeze
raw_bull   = bull_score >= min_score and regime_ok and (not use_ema_filter or above_ema)
raw_bear   = bear_score >= min_score and regime_ok and (not use_ema_filter or below_ema)

//══════════════════════════════════════════════════════════════════════
// STATE MACHINE
//══════════════════════════════════════════════════════════════════════

var int   trade_state = 0
var float entry_price = na
var float sl_level    = na
var float tp_level    = na
var float trail_level = na
var float best_price  = na
var int   cooldown    = 0

cooldown := math.max(0, cooldown - 1)

sl_dist    = atr * atr_sl_mult
tp_dist    = atr * atr_tp_mult
trail_dist = atr * trail_atr_mult
trail_act  = atr * trail_act_mult

if trade_state == 1
    best_price := math.max(best_price, high)
    if best_price >= entry_price + trail_act
        trail_level := math.max(nz(trail_level, sl_level), best_price - trail_dist)

if trade_state == -1
    best_price := math.min(best_price, low)
    if best_price <= entry_price - trail_act
        trail_level := math.min(nz(trail_level, sl_level), best_price + trail_dist)

long_sl_hit    = trade_state == 1  and not na(sl_level)    and close <= sl_level
long_tp_hit    = trade_state == 1  and not na(tp_level)    and close >= tp_level
long_trail_hit = trade_state == 1  and not na(trail_level) and close <= trail_level

short_sl_hit    = trade_state == -1 and not na(sl_level)    and close >= sl_level
short_tp_hit    = trade_state == -1 and not na(tp_level)    and close <= tp_level
short_trail_hit = trade_state == -1 and not na(trail_level) and close >= trail_level

long_exit  = long_sl_hit  or long_tp_hit  or long_trail_hit
short_exit = short_sl_hit or short_tp_hit or short_trail_hit

if long_exit or short_exit
    trade_state := 0
    entry_price := na
    sl_level    := na
    tp_level    := na
    trail_level := na
    best_price  := na
    cooldown    := cooldown_len

bull_entry = raw_bull and trade_state == 0 and cooldown == 0
bear_entry = raw_bear and trade_state == 0 and cooldown == 0

if bull_entry
    trade_state := 1
    entry_price := close
    sl_level    := close - sl_dist
    tp_level    := close + tp_dist
    trail_level := na
    best_price  := close

if bear_entry
    trade_state := -1
    entry_price := close
    sl_level    := close + sl_dist
    tp_level    := close - tp_dist
    trail_level := na
    best_price  := close

//══════════════════════════════════════════════════════════════════════
// VISUALS
//══════════════════════════════════════════════════════════════════════

// EMAs
plot(ema_fast, "EMA 20 (Fast)", color=color.new(color.yellow, 30), linewidth=1)
plot(ema_slow, "EMA 50 (Slow)", color=above_ema ? color.new(color.lime, 15) : color.new(color.red, 15), linewidth=2)

// VWAP
plot(show_vwap ? vwap_val : na, "VWAP", color=color.new(color.aqua, 0), linewidth=2)
plot(show_vwap and show_vwap_band ? vwap_upper : na, "VWAP +1s", color=color.new(color.aqua, 65), linewidth=1, style=plot.style_linebr)
plot(show_vwap and show_vwap_band ? vwap_lower : na, "VWAP -1s", color=color.new(color.aqua, 65), linewidth=1, style=plot.style_linebr)

// BB (off by default)
plot(show_bb ? bb_upper : na, "BB Upper", color=color.new(color.purple, 55), linewidth=1)
plot(show_bb ? bb_lower : na, "BB Lower", color=color.new(color.purple, 55), linewidth=1)

// Camarilla
plot(show_pivots ? cam_h4 : na, "H4 Resist (Strong)", color=color.new(#FF5252, 15), linewidth=1, style=plot.style_circles)
plot(show_pivots ? cam_h3 : na, "H3 Resist",          color=color.new(#FF8A80, 40), linewidth=1, style=plot.style_circles)
plot(show_pivots ? cam_l3 : na, "L3 Support",         color=color.new(#69F0AE, 40), linewidth=1, style=plot.style_circles)
plot(show_pivots ? cam_l4 : na, "L4 Support (Strong)",color=color.new(#00C853, 15), linewidth=1, style=plot.style_circles)

// Entry labels
plotshape(bull_entry, "BUY",  style=shape.labelup,   location=location.belowbar, color=color.new(#00C853, 0), text="BUY",  textcolor=color.black, size=size.large)
plotshape(bear_entry, "SELL", style=shape.labeldown, location=location.abovebar, color=color.new(#D50000, 0), text="SELL", textcolor=color.white, size=size.large)

// Exit markers — orange X = trade closed (SL / TP / trail hit)
plotshape(long_exit,  "Exit Long",  style=shape.xcross, location=location.abovebar, color=color.new(color.orange, 0), size=size.normal)
plotshape(short_exit, "Exit Short", style=shape.xcross, location=location.belowbar, color=color.new(color.orange, 0), size=size.normal)

// SL / TP / Trail lines (line.new = excluded from Y-axis auto-scale)
var line ln_entry = na
var line ln_sl    = na
var line ln_tp    = na
var line ln_trail = na

if bull_entry or bear_entry
    if not na(ln_entry)
        line.delete(ln_entry)
    if not na(ln_sl)
        line.delete(ln_sl)
    if not na(ln_tp)
        line.delete(ln_tp)
    if not na(ln_trail)
        line.delete(ln_trail)
    ln_entry := line.new(bar_index, entry_price, bar_index + 1, entry_price, color=color.new(color.blue, 0),   width=1, style=line.style_dashed, extend=extend.right)
    ln_sl    := line.new(bar_index, sl_level,    bar_index + 1, sl_level,    color=color.new(#FF5252, 0),      width=2, extend=extend.right)
    ln_tp    := line.new(bar_index, tp_level,    bar_index + 1, tp_level,    color=color.new(#00C853, 0),      width=2, extend=extend.right)
    ln_trail := line.new(bar_index, sl_level,    bar_index + 1, sl_level,    color=color.new(color.orange, 0), width=1, style=line.style_dotted, extend=extend.right)

if long_exit or short_exit
    if not na(ln_entry)
        line.delete(ln_entry)
    if not na(ln_sl)
        line.delete(ln_sl)
    if not na(ln_tp)
        line.delete(ln_tp)
    if not na(ln_trail)
        line.delete(ln_trail)
    ln_entry := na
    ln_sl    := na
    ln_tp    := na
    ln_trail := na

if trade_state != 0 and not na(trail_level) and not na(ln_trail)
    line.set_y1(ln_trail, trail_level)
    line.set_y2(ln_trail, trail_level)

// Background
bg_col = trade_state == 1 ? color.new(color.green, 80) : trade_state == -1 ? color.new(color.red, 80) : above_ema ? color.new(color.green, 93) : color.new(color.red, 93)
bgcolor(bg_col, title="Background")

//══════════════════════════════════════════════════════════════════════
// INFO TABLE
//══════════════════════════════════════════════════════════════════════

var table t = table.new(position.top_right, 2, 15, bgcolor=color.new(#0D1117, 5), border_color=color.new(#30363D, 0), border_width=1, frame_color=color.new(#30363D, 0), frame_width=1)

if barstate.islast
    bg_hdr = color.new(#161B22, 0)
    bg_lbl = color.new(#0D1117, 0)
    bg_val = color.new(#161B22, 0)
    c_wht  = color.new(#E6EDF3, 0)
    c_sil  = color.new(#8B949E, 0)
    c_grn  = color.new(#3FB950, 0)
    c_red  = color.new(#F85149, 0)
    c_amb  = color.new(#D29922, 0)
    c_aqu  = color.new(#79C0FF, 0)

    table.cell(t, 0, 0, "ACROFINS v3", text_color=c_aqu, bgcolor=bg_hdr, text_size=size.small)
    table.cell(t, 1, 0, "STATUS",      text_color=c_wht, bgcolor=bg_hdr, text_size=size.small)

    pos_s = trade_state == 1 ? "LONG  ▲" : trade_state == -1 ? "SHORT  ▼" : "FLAT  ─"
    pos_c = trade_state == 1 ? c_grn : trade_state == -1 ? c_red : c_sil
    table.cell(t, 0, 1, "Position", text_color=c_sil, bgcolor=bg_lbl, text_size=size.small)
    table.cell(t, 1, 1, pos_s,      text_color=pos_c, bgcolor=bg_val, text_size=size.small)

    en_s = trade_state != 0 ? str.tostring(math.round(entry_price, 2)) : "─"
    table.cell(t, 0, 2, "Entry", text_color=c_sil, bgcolor=bg_lbl, text_size=size.small)
    table.cell(t, 1, 2, en_s,    text_color=c_wht, bgcolor=bg_val, text_size=size.small)

    sl_s = trade_state != 0 ? str.tostring(math.round(sl_level, 2)) : "─"
    table.cell(t, 0, 3, "Stop Loss", text_color=c_sil, bgcolor=bg_lbl, text_size=size.small)
    table.cell(t, 1, 3, sl_s,        text_color=c_red, bgcolor=bg_val, text_size=size.small)

    tp_s = trade_state != 0 ? str.tostring(math.round(tp_level, 2)) : "─"
    table.cell(t, 0, 4, "Take Profit", text_color=c_sil, bgcolor=bg_lbl, text_size=size.small)
    table.cell(t, 1, 4, tp_s,          text_color=c_grn, bgcolor=bg_val, text_size=size.small)

    tr_s = trade_state != 0 ? not na(trail_level) ? str.tostring(math.round(trail_level, 2)) : "< 1 ATR away" : "─"
    table.cell(t, 0, 5, "Trail Stop", text_color=c_sil, bgcolor=bg_lbl, text_size=size.small)
    table.cell(t, 1, 5, tr_s,         text_color=c_amb, bgcolor=bg_val, text_size=size.small)

    ema_s = above_ema ? "Bullish ▲" : "Bearish ▼"
    ema_c = above_ema ? c_grn : c_red
    table.cell(t, 0, 6, "EMA Trend", text_color=c_sil, bgcolor=bg_lbl, text_size=size.small)
    table.cell(t, 1, 6, ema_s,       text_color=ema_c, bgcolor=bg_val, text_size=size.small)

    adx_tag = is_strong ? " Strong" : is_trending ? " OK" : " Flat"
    adx_s   = str.tostring(math.round(adx_val, 1)) + adx_tag
    adx_c   = is_strong ? c_grn : is_trending ? c_amb : c_red
    table.cell(t, 0, 7, "ADX", text_color=c_sil, bgcolor=bg_lbl, text_size=size.small)
    table.cell(t, 1, 7, adx_s, text_color=adx_c, bgcolor=bg_val, text_size=size.small)

    bb_s = in_squeeze ? "SQUEEZE ⚠" : "TRENDING ✓"
    bb_c = in_squeeze ? c_red : c_grn
    table.cell(t, 0, 8, "BB Regime", text_color=c_sil, bgcolor=bg_lbl, text_size=size.small)
    table.cell(t, 1, 8, bb_s,        text_color=bb_c,  bgcolor=bg_val, text_size=size.small)

    vix_num  = na(india_vix) ? "N/A" : str.tostring(math.round(india_vix, 1))
    vix_rank = na(iv_rank) ? "" : " R:" + str.tostring(math.round(iv_rank, 0)) + "%"
    vix_disp = na(india_vix) ? "N/A - check data sub" : vix_num + vix_rank
    vix_c    = vix_danger ? c_red : vix_ok ? c_grn : c_amb
    table.cell(t, 0, 9, "India VIX", text_color=c_sil, bgcolor=bg_lbl, text_size=size.small)
    table.cell(t, 1, 9, vix_disp,    text_color=vix_c, bgcolor=bg_val, text_size=size.small)

    rsi_s = str.tostring(math.round(rsi, 1)) + " / " + str.tostring(math.round(rsi_1h, 1)) + " (1H)"
    rsi_c = rsi_bull_z ? c_grn : rsi_bear_z ? c_red : c_sil
    table.cell(t, 0, 10, "RSI / 1H", text_color=c_sil, bgcolor=bg_lbl, text_size=size.small)
    table.cell(t, 1, 10, rsi_s,       text_color=rsi_c, bgcolor=bg_val, text_size=size.small)

    vwap_s = above_vwap ? "Above ▲" : "Below ▼"
    vwap_c = above_vwap ? c_grn : c_red
    table.cell(t, 0, 11, "VWAP",  text_color=c_sil,  bgcolor=bg_lbl, text_size=size.small)
    table.cell(t, 1, 11, vwap_s,  text_color=vwap_c, bgcolor=bg_val, text_size=size.small)

    cam_s = near_support ? "Near Support" : near_resist ? "Near Resist" : "Mid-Range"
    cam_c = near_support ? c_grn : near_resist ? c_red : c_sil
    table.cell(t, 0, 12, "Camarilla", text_color=c_sil,  bgcolor=bg_lbl, text_size=size.small)
    table.cell(t, 1, 12, cam_s,       text_color=cam_c,  bgcolor=bg_val, text_size=size.small)

    score_s = "B:" + str.tostring(bull_score) + " S:" + str.tostring(bear_score) + "/11"
    score_c = bull_score >= min_score ? c_grn : bear_score >= min_score ? c_red : c_sil
    table.cell(t, 0, 13, "Score (>=" + str.tostring(min_score) + ")", text_color=c_sil,   bgcolor=bg_lbl, text_size=size.small)
    table.cell(t, 1, 13, score_s,                                      text_color=score_c, bgcolor=bg_val, text_size=size.small)

    cd_s = cooldown > 0 ? "Cooldown: " + str.tostring(cooldown) + "b" : regime_ok ? "READY ✓" : "RANGING ─"
    cd_c = cooldown > 0 ? c_amb : regime_ok ? c_grn : c_red
    table.cell(t, 0, 14, "Status", text_color=c_sil, bgcolor=bg_lbl, text_size=size.small)
    table.cell(t, 1, 14, cd_s,     text_color=cd_c,  bgcolor=bg_val, text_size=size.small)

//══════════════════════════════════════════════════════════════════════
// ALERTS
//══════════════════════════════════════════════════════════════════════

alertcondition(bull_entry,  "BUY Entry",  "ACROFINS v3 - BUY Signal Triggered")
alertcondition(bear_entry,  "SELL Entry", "ACROFINS v3 - SELL Signal Triggered")
alertcondition(long_exit,   "Long Exit",  "ACROFINS v3 - Long Position Closed")
alertcondition(short_exit,  "Short Exit", "ACROFINS v3 - Short Position Closed")
alertcondition(in_squeeze,  "BB Squeeze", "ACROFINS v3 - Squeeze detected, signals paused")
````
