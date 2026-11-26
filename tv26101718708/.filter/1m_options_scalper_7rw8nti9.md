# 1m Options Scalper

- url: https://www.tradingview.com/script/7rW8nTI9-1m-Options-Scalper/
- type: indicator
- pine_id: PUB;e4ea9e2a5f7b4f8c89b0e4b554a158e9
- version: 2.0

## Description

Runs on a 1-minute chart and looks for moments where price moved too far too fast. When it spots that, it alerts you to a potential quick options trade, either a call or a put. It filters out bad setups by checking the short-term trend and whether the overall market is in a healthy spot. When it signals, it gives you a limit entry price, a take profit, and a stop loss right on the chart. It's built for quick in-and-out trades during market hours, nothing held for long.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © eli2k_rodgers

//@version=6
indicator("1m Options Scalper (Calls/Puts) - Optimized 10% Options Target", overlay=true, max_labels_count=500)

// ──────────────────────────────────────────────
// 1. Inputs & Configuration
// ──────────────────────────────────────────────
length_sma       = input.int(50,      title="Intraday SMA Length (Z-Score)")
length_rsi       = input.int(14,      title="RSI Length")
z_threshold      = input.float(2.5,   title="Z-Score Trigger Threshold")
rsi_thresh       = input.int(35,      title="RSI Trigger Threshold")
limit_offset_pct = input.float(0.40,  title="Limit Entry Offset (%)") / 100.0
target_pct       = input.float(1.00,  title="Profit Target (%)") / 100.0
stop_pct         = input.float(3.00,  title="Stop Loss (%)") / 100.0
max_hold_bars    = input.int(240,     title="Max Hold Period (Bars)")
lockout_period   = input.int(30,      title="Signal Lockout (Bars)")

// Intraday Trend Filtering (Local 1m chart)
filter_trend = input.bool(true,  title="Enable Intraday Trend Filtering", group="Trend Filter")
length_trend = input.int(200,    title="Trend Baseline SMA Length", group="Trend Filter")

// Daily Macro Regime Filtering (Prevents counter-trend setups)
use_regime   = input.bool(true,  title="Enable Daily Regime Filtering", group="Regime Filter")
regime_sym   = input.symbol("NASDAQ:QQQ", title="Daily Reference Ticker", group="Regime Filter")

// Visual Toggles
show_shapes  = input.bool(true,  title="Show Buy/Sell Arrows", group="Display")
show_labels  = input.bool(false, title="Show Signal Labels", group="Display")

// ──────────────────────────────────────────────
// 2. Calculations
// ──────────────────────────────────────────────
idx_close = close
idx_sma   = ta.sma(idx_close, length_sma)
idx_stdev = ta.stdev(idx_close, length_sma)
idx_rsi   = ta.rsi(idx_close, length_rsi)

z_score   = (idx_close - idx_sma) / idx_stdev

// Local 1m trend filter
trend_sma = ta.sma(idx_close, length_trend)
is_bull   = idx_close > trend_sma

// Daily macro regime filter (fetched from daily timeframe of reference index)
daily_close = request.security(regime_sym, "D", close)
daily_sma   = request.security(regime_sym, "D", ta.sma(close, 200))
daily_bull  = daily_close > daily_sma

// ──────────────────────────────────────────────
// 3. Intraday Scalping Signals (Limit Order Entry)
// ──────────────────────────────────────────────
bool call_cond = (idx_rsi < rsi_thresh) and (z_score <= -z_threshold) and 
                 (not filter_trend or is_bull) and 
                 (not use_regime or daily_bull)

bool put_cond  = (idx_rsi > (100 - rsi_thresh)) and (z_score >= z_threshold) and 
                 (not filter_trend or not is_bull) and 
                 (not use_regime or not daily_bull)

// State management for lockout
var int last_call_bar = 0
var int last_put_bar = 0

bool call_cond_clean = call_cond and (bar_index - last_call_bar) > lockout_period
bool put_cond_clean  = put_cond  and (bar_index - last_put_bar) > lockout_period

var float call_entry = na
var float call_target = na
var float call_stop = na

var float put_entry = na
var float put_target = na
var float put_stop = na

if call_cond_clean
    last_call_bar := bar_index
    call_entry := idx_close * (1 - limit_offset_pct)
    call_target := call_entry * (1 + target_pct)
    call_stop := call_entry * (1 - stop_pct)

var bool call_filled = false
if call_cond_clean
    call_filled := false

if not na(call_entry)
    if not call_filled and low <= call_entry
        call_filled := true
    if (bar_index - last_call_bar > max_hold_bars) or (call_filled and (high >= call_target or low <= call_stop))
        call_entry := na
        call_target := na
        call_stop := na
        call_filled := false

if put_cond_clean
    last_put_bar := bar_index
    put_entry := idx_close * (1 + limit_offset_pct)
    put_target := put_entry * (1 - target_pct)
    put_stop := put_entry * (1 + stop_pct)

var bool put_filled = false
if put_cond_clean
    put_filled := false

if not na(put_entry)
    if not put_filled and high >= put_entry
        put_filled := true
    if (bar_index - last_put_bar > max_hold_bars) or (put_filled and (low <= put_target or high >= put_stop))
        put_entry := na
        put_target := na
        put_stop := na
        put_filled := false

// ──────────────────────────────────────────────
// 4. Visual Layout (Arrows, Entries, Targets & Stops)
// ──────────────────────────────────────────────
plotshape(show_shapes and call_cond_clean, title="CALL Signal", style=shape.triangleup,   location=location.belowbar, color=color.green, size=size.small, text="CALL")
plotshape(show_shapes and put_cond_clean,  title="PUT Signal",  style=shape.triangledown, location=location.abovebar, color=color.red,   size=size.small, text="PUT")

// Plot horizontal levels for the active setups
plot(call_entry,  title="Call Limit Entry", color=color.new(color.green, 20), style=plot.style_linebr, linewidth=2)
plot(call_target, title="Call Take Profit",  color=color.new(color.lime, 40),  style=plot.style_linebr, linewidth=1)
plot(call_stop,   title="Call Stop Loss",    color=color.new(color.red, 40),   style=plot.style_linebr, linewidth=1)

plot(put_entry,  title="Put Limit Entry", color=color.new(color.red, 20),   style=plot.style_linebr, linewidth=2)
plot(put_target, title="Put Take Profit",  color=color.new(color.orange, 40), style=plot.style_linebr, linewidth=1)
plot(put_stop,   title="Put Stop Loss",    color=color.new(color.maroon, 40), style=plot.style_linebr, linewidth=1)

if show_labels and call_cond_clean
    label.new(bar_index, low, "CALL Limit Entry: " + str.tostring(call_entry, "#.##") + "\nTP: " + str.tostring(call_target, "#.##"), style=label.style_label_up, color=color.new(color.green, 30), textcolor=color.white, size=size.small)
if show_labels and put_cond_clean
    label.new(bar_index, high, "PUT Limit Entry: " + str.tostring(put_entry, "#.##") + "\nTP: " + str.tostring(put_target, "#.##"), style=label.style_label_down, color=color.new(color.red, 30), textcolor=color.white, size=size.small)

// ──────────────────────────────────────────────
// 5. Alert Conditions
// ──────────────────────────────────────────────
alertcondition(call_cond_clean, title="BUY CALL Alert", message="🚀 **[Options Scalper] Alert**\n**Stock:** {{ticker}}\n**Current Price:** {{close}}\n**Options Side:** CALL\n**DTE:** Weekly (7 Days or less)")
alertcondition(put_cond_clean,  title="BUY PUT Alert",  message="🚀 **[Options Scalper] Alert**\n**Stock:** {{ticker}}\n**Current Price:** {{close}}\n**Options Side:** PUT\n**DTE:** Weekly (7 Days or less)")
````
