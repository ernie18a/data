# Quantitative Options Momentum Scalper [v5 - Fixed]

- url: https://www.tradingview.com/script/6R8XyhZi-Quantitative-Options-Momentum-Scalper-v5-Fixed/
- type: indicator
- pine_id: PUB;71e463137a674650a318001cf1488f3e
- version: 1.0

## Description

The is designed to help traders identify [e.g., trend direction, overbought/oversold levels, hidden divergences, dynamic support/resistance] across varying market conditions. By combining [e.g., smoothed moving averages, volume confirmation, ATR-based volatility filters], this tool filters out market noise and provides clear, actionable visual cues.
How It Works

Unlike standard [e.g., RSI / MACD / Bollinger Bands], this script enhances signal reliability through:

    [Core Algorithm/Logic]: Uses [e.g., an exponential calculation / multi-factor weighting] to track momentum shifts without excessive lag.

    [Smoothing/Filter]: Incorporates a [e.g., Gaussian filter / Volume-weighted multiplier] to reduce false signals during consolidation phases.

    [Dynamic Thresholds]: Adjusts bands/trigger lines dynamically based on [e.g., average true range (ATR) / standard deviation].

Key Features & Visual Signals

    Bullish Signal (Green [Dots/Arrows/Line]): Indicates [e.g., momentum turning positive above baseline / bullish breakout confirmed by volume].

    Bearish Signal (Red [Dots/Arrows/Line]): Indicates [e.g., momentum breaking below key baseline / distribution phase].

    Neutral / Squeeze Zone (Gray/Orange): Signals low volatility or chop; suggests waiting for confirmation before entering trades.

    Built-in Alerts: Fully configurable alerts for [e.g., buy triggers, sell triggers, overextended zones].

## Source Code

````pine
//@version=6
indicator('Quantitative Options Momentum Scalper [v5 - Fixed]', shorttitle = 'OptScalp Pro', overlay = true, max_labels_count = 500, max_lines_count = 500)

// =============================================================================
// INPUT CONFIGURATION
// =============================================================================

// Trend & Ribbon Inputs
grp_trend = 'Trend & Ribbon (EMAs & VWAP)'
show_ema = input.bool(true, 'Show EMAs', group = grp_trend)
fast_ema_len = input.int(9, 'Fast EMA Length', minval = 1, group = grp_trend)
slow_ema_len = input.int(21, 'Slow EMA Length', minval = 1, group = grp_trend)
show_vwap = input.bool(true, 'Show Session VWAP', group = grp_trend)
show_vwap_dev = input.bool(true, 'Show VWAP StDev Bands', group = grp_trend)
vwap_stdev_mult = input.float(1.25, 'VWAP Band Multiplier (σ)', minval = 0.1, step = 0.25, group = grp_trend)

// Momentum Inputs (Stochastic RSI)
grp_mom = 'Momentum Engine (Stochastic RSI)'
use_mom_filter = input.bool(true, 'Enable Stoch RSI Momentum Filter', group = grp_mom)
rsi_len = input.int(14, 'RSI Length', minval = 1, group = grp_mom)
stoch_len = input.int(14, 'Stochastic Length', minval = 1, group = grp_mom)
smooth_k = input.int(3, 'Smooth %K', minval = 1, group = grp_mom)
smooth_d = input.int(3, 'Smooth %D', minval = 1, group = grp_mom)
stoch_mode = input.string('Crossover Trigger', 'Trigger Mode', options = ['Crossover Trigger', 'Directional State'], group = grp_mom)
stoch_ob = input.int(80, 'Overbought Ceiling (Calls)', minval = 50, maxval = 95, group = grp_mom)
stoch_os = input.int(20, 'Oversold Floor (Puts)', minval = 5, maxval = 50, group = grp_mom)

// Volatility & Noise Filter
grp_volat = 'Volatility & Squeeze Filter'
use_volat_filter = input.bool(true, 'Filter Consolidation (Squeeze Detection)', group = grp_volat)
bb_len = input.int(20, 'Bollinger Length', minval = 1, group = grp_volat)
bb_mult = input.float(2.0, 'Bollinger StdDev', minval = 0.5, step = 0.1, group = grp_volat)
kc_len = input.int(20, 'Keltner Length', minval = 1, group = grp_volat)
kc_mult = input.float(1.5, 'Keltner ATR Multiplier', minval = 0.5, step = 0.1, group = grp_volat)

// Volume Confirmation (RVOL)
grp_vol = 'Volume Confirmation (RVOL)'
use_rvol_filter = input.bool(true, 'Enable RVOL Filter', group = grp_vol)
rvol_len = input.int(20, 'RVOL Lookback (SMA)', minval = 1, group = grp_vol)
min_rvol = input.float(1.10, 'Minimum Relative Volume Multiplier', minval = 0.5, step = 0.05, group = grp_vol)

// Invalidation & Trailing Stop Engine
grp_risk = 'Risk & Dynamic Invalidation'
show_trail_stop = input.bool(true, 'Show Dynamic Trailing Stop Line', group = grp_risk)
atr_len = input.int(14, 'ATR Length', minval = 1, group = grp_risk)
atr_stop_mult = input.float(1.5, 'ATR Stop Multiplier', minval = 0.5, step = 0.25, group = grp_risk)
use_wick_stop = input.bool(true, 'Include Prior Candle Wick in Stop Anchor', group = grp_risk)

// UI / Visuals
grp_ui = 'User Interface & Dashboard'
show_dashboard = input.bool(true, 'Display Real-Time Metric HUD', group = grp_ui)

// =============================================================================
// CORE CALCULATIONS
// =============================================================================

// 1. Exponential Moving Averages
ema_fast = ta.ema(close, fast_ema_len)
ema_slow = ta.ema(close, slow_ema_len)
ema_bull = ema_fast > ema_slow
ema_bear = ema_fast < ema_slow

// 2. Session Anchored VWAP + Standard Deviation Bands
var float cum_vol = 0.0
var float cum_price_vol = 0.0
var float cum_sq_vol = 0.0

is_new_session = ta.change(time('D')) != 0

if is_new_session
    cum_vol := 0.0
    cum_price_vol := 0.0
    cum_sq_vol := 0.0
    cum_sq_vol

current_vol = nz(volume, 0.0)
cum_vol := cum_vol + current_vol
cum_price_vol := cum_price_vol + hlc3 * current_vol
cum_sq_vol := cum_sq_vol + math.pow(hlc3, 2) * current_vol

vwap_val = cum_vol > 0 ? cum_price_vol / cum_vol : hlc3
vwap_var = cum_vol > 0 ? math.max(0.0, cum_sq_vol / cum_vol - math.pow(vwap_val, 2)) : 0.0
vwap_sd = math.sqrt(vwap_var)

vwap_upper = vwap_val + vwap_stdev_mult * vwap_sd
vwap_lower = vwap_val - vwap_stdev_mult * vwap_sd

// 3. Fast Stochastic RSI
rsi_raw = ta.rsi(close, rsi_len)
stoch_raw = ta.stoch(rsi_raw, rsi_raw, rsi_raw, stoch_len)
stoch_k = ta.sma(stoch_raw, smooth_k)
stoch_d = ta.sma(stoch_k, smooth_d)

mom_bull = stoch_mode == 'Crossover Trigger' ? ta.crossover(stoch_k, stoch_d) and stoch_k < stoch_ob : stoch_k > stoch_d and stoch_k < stoch_ob
mom_bear = stoch_mode == 'Crossover Trigger' ? ta.crossunder(stoch_k, stoch_d) and stoch_k > stoch_os : stoch_k < stoch_d and stoch_k > stoch_os

// 4. Volatility Expansion / Squeeze Filter (Bug Fixed)
bb_basis = ta.sma(close, bb_len)
bb_dev = bb_mult * ta.stdev(close, bb_len)
bb_upper = bb_basis + bb_dev
bb_lower = bb_basis - bb_dev

atr_val = ta.atr(atr_len)
kc_basis = ta.sma(close, kc_len)
kc_range = atr_val * kc_mult
kc_upper = kc_basis + kc_range
kc_lower = kc_basis - kc_range

// Standard Squeeze: Bollinger Bands contracting inside Keltner Channel
in_squeeze = bb_lower > kc_lower and bb_upper < kc_upper
volatility_expansion = not in_squeeze

// 5. Volume Confirmation (RVOL) with Spot-Index Zero Volume Bypass
has_volume = current_vol > 0
vol_ma = ta.sma(current_vol, rvol_len)
rvol = has_volume and vol_ma > 0 ? current_vol / vol_ma : 1.0
rvol_pass = not use_rvol_filter or not has_volume or rvol >= min_rvol

// =============================================================================
// CONFLUENCE SIGNAL ENGINE & STATE TRACKING (Bug Fixed)
// =============================================================================

bull_confluence = close > vwap_val and ema_bull and (not use_mom_filter or mom_bull) and (not use_volat_filter or volatility_expansion) and rvol_pass
bear_confluence = close < vwap_val and ema_bear and (not use_mom_filter or mom_bear) and (not use_volat_filter or volatility_expansion) and rvol_pass

var int trade_state = 0 // 0: Flat, 1: Long (Call), -1: Short (Put)
var float dynamic_stop = na

call_entry = bull_confluence and trade_state <= 0
put_entry = bear_confluence and trade_state >= 0

// State Transitions & Stop Anchoring
if call_entry
    trade_state := 1
    base_low = use_wick_stop ? math.min(low, nz(low[1], low)) : low
    dynamic_stop := base_low - atr_val * atr_stop_mult
    dynamic_stop
else if put_entry
    trade_state := -1
    base_high = use_wick_stop ? math.max(high, nz(high[1], high)) : high
    dynamic_stop := base_high + atr_val * atr_stop_mult
    dynamic_stop
else if trade_state == 1
    // Trail Stop upward only on holding bars
    current_floor = (use_wick_stop ? nz(low[1], low) : close) - atr_val * atr_stop_mult
    dynamic_stop := math.max(nz(dynamic_stop, current_floor), current_floor)
    if close < dynamic_stop
        trade_state := 0
        trade_state
else if trade_state == -1
    // Trail Stop downward only on holding bars
    current_ceiling = (use_wick_stop ? nz(high[1], high) : close) + atr_val * atr_stop_mult
    dynamic_stop := math.min(nz(dynamic_stop, current_ceiling), current_ceiling)
    if close > dynamic_stop
        trade_state := 0
        trade_state

call_exit = trade_state[1] == 1 and trade_state == 0
put_exit = trade_state[1] == -1 and trade_state == 0

// =============================================================================
// PLOTTING & VISUALIZATION
// =============================================================================

// EMAs
plot(show_ema ? ema_fast : na, 'Fast EMA (9)', color = color.new(#00E676, 0), linewidth = 2)
plot(show_ema ? ema_slow : na, 'Slow EMA (21)', color = color.new(#FF5252, 0), linewidth = 2)

// VWAP & Bands
plot(show_vwap ? vwap_val : na, 'Session VWAP', color = color.new(#FFD700, 0), linewidth = 2)
p_vwap_u = plot(show_vwap and show_vwap_dev ? vwap_upper : na, 'VWAP Upper (+1.25σ)', color = color.new(#4FC3F7, 50), style = plot.style_circles)
p_vwap_l = plot(show_vwap and show_vwap_dev ? vwap_lower : na, 'VWAP Lower (-1.25σ)', color = color.new(#4FC3F7, 50), style = plot.style_circles)
fill(p_vwap_u, p_vwap_l, color = color.new(#4FC3F7, 95), title = 'VWAP Envelope Fill')

// Trailing Stop Line (Only shown during active positions)
plot(show_trail_stop and trade_state != 0 ? dynamic_stop : na, 'Trailing Stop', color = trade_state == 1 ? color.new(#FF1744, 0) : color.new(#00E676, 0), linewidth = 2, style = plot.style_linebr)

// Call & Put Labels
plotshape(call_entry, title = 'CALL Scalp Label', style = shape.labelup, location = location.belowbar, color = color.new(#00C853, 0), text = 'CALL', textcolor = color.white, size = size.small)
plotshape(put_entry, title = 'PUT Scalp Label', style = shape.labeldown, location = location.abovebar, color = color.new(#D50000, 0), text = 'PUT', textcolor = color.white, size = size.small)

// Exit Markers (Fixed location bug: prevents Y-axis compression to 0.0)
plotshape(call_exit, title = 'Call Exit Stop', style = shape.xcross, location = location.abovebar, color = color.new(#FF8A80, 0), size = size.tiny)
plotshape(put_exit, title = 'Put Exit Stop', style = shape.xcross, location = location.belowbar, color = color.new(#A7FFEB, 0), size = size.tiny)

// Dynamic Candle Tinting
barcolor(trade_state == 1 ? color.new(#00E676, 80) : trade_state == -1 ? color.new(#FF5252, 80) : na, title = 'Active Trade Barcolor')

// =============================================================================
// METRIC HUD (DASHBOARD)
// =============================================================================

var table hud = table.new(position.top_right, 2, 6, bgcolor = color.new(#1E222D, 15), border_color = color.new(#374151, 30), border_width = 1)

if barstate.islast and show_dashboard
    table.cell(hud, 0, 0, 'Metric', bgcolor = color.new(#2A2E39, 0), text_color = color.white, text_size = size.tiny)
    table.cell(hud, 1, 0, 'Confluence State', bgcolor = color.new(#2A2E39, 0), text_color = color.white, text_size = size.tiny)

    vwap_txt = close > vwap_val ? 'Bullish (Above)' : 'Bearish (Below)'
    table.cell(hud, 0, 1, 'VWAP Bias', text_color = color.silver, text_size = size.tiny)
    table.cell(hud, 1, 1, vwap_txt, text_color = close > vwap_val ? color.green : color.red, text_size = size.tiny)

    ema_txt = ema_bull ? '9 EMA > 21 EMA' : '9 EMA < 21 EMA'
    table.cell(hud, 0, 2, 'EMA Ribbon', text_color = color.silver, text_size = size.tiny)
    table.cell(hud, 1, 2, ema_txt, text_color = ema_bull ? color.green : color.red, text_size = size.tiny)

    mom_txt = stoch_k > stoch_d ? 'Bullish (' + str.tostring(math.round(stoch_k, 1)) + ')' : 'Bearish (' + str.tostring(math.round(stoch_k, 1)) + ')'
    table.cell(hud, 0, 3, 'Stoch RSI', text_color = color.silver, text_size = size.tiny)
    table.cell(hud, 1, 3, mom_txt, text_color = stoch_k > stoch_d ? color.green : color.red, text_size = size.tiny)

    volat_txt = in_squeeze ? 'SQUEEZE (Chop)' : 'EXPANSION (Valid)'
    table.cell(hud, 0, 4, 'Volatility', text_color = color.silver, text_size = size.tiny)
    table.cell(hud, 1, 4, volat_txt, text_color = in_squeeze ? color.orange : color.green, text_size = size.tiny)

    rvol_txt = has_volume ? str.tostring(math.round(rvol, 2)) + 'x' : 'N/A (Spot)'
    table.cell(hud, 0, 5, 'RVOL', text_color = color.silver, text_size = size.tiny)
    table.cell(hud, 1, 5, rvol_txt, text_color = rvol_pass ? color.green : color.silver, text_size = size.tiny)

// =============================================================================
// ALERT TRIGGERS
// =============================================================================

alertcondition(call_entry, title = 'CALL Scalp Entry', message = 'CALL Scalp Signal on {{ticker}} at {{close}} | 9>21 EMA, Price>VWAP, Volume Confirmed')
alertcondition(put_entry, title = 'PUT Scalp Entry', message = 'PUT Scalp Signal on {{ticker}} at {{close}} | 9<21 EMA, Price<VWAP, Volume Confirmed')
alertcondition(call_exit or put_exit, title = 'Scalp Invalidation / Exit', message = 'Scalp Stop Triggered on {{ticker}} at {{close}}')
````
