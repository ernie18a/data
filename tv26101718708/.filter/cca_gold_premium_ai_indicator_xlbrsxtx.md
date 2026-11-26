# CCA Gold Premium AI Indicator

- url: https://www.tradingview.com/script/XLbrsxTX-CCA-Gold-Premium-AI-Indicator/
- type: indicator
- pine_id: PUB;76c844cc9fce407081b63bc7d1188dab
- version: 1.0

## Description

Professional Smart Money Concepts indicator for XAUUSD. Detects FVG zones, Order Blocks, BOS/CHoCH, and generates AI confluence signals (4-point scoring system). Features neon green/maroon candles, professional EMA ribbon (9/21/50), VWAP integration, and real-time dashboard showing BIAS, RSI 7, signal status.
Optimized for 5M/15M timeframes. Built and tested on funded accounts up to $300K.
Features:

FVG & Order Block Detection
BOS / CHoCH Labels
4-Confluence AI Scoring
Professional Dashboard
EMA Ribbon + VWAP
Email Support & Updates

Best for: XAUUSD, 5M/15M, London session (8am-4pm GMT)
Trading involves risk. Always use stop losses and proper position sizing.

## Source Code

````pine
//@version=6
indicator("CCA Gold Premium AI Indicator (v6)", overlay=true, max_boxes_count=200, max_lines_count=200, max_labels_count=200)

// ==========================================
// SETTINGS & TOGGLES INPUTS
// ==========================================
gp_toggles = "CCA System - Toggles"
show_candles = input.bool(true, "Show Custom Candles", group=gp_toggles)
show_fvg     = input.bool(true, "Show FVG Zones", group=gp_toggles)
show_ob      = input.bool(true, "Show Order Blocks (OB)", group=gp_toggles)
show_bos     = input.bool(true, "Show BOS Lines", group=gp_toggles)
show_emas    = input.bool(true, "Show EMAs & VWAP", group=gp_toggles)

gp_rsi     = "CCA System - RSI Settings"
rsi_len    = input.int(7, "RSI Length", minval=2, maxval=30, group=gp_rsi)
rsi_ob     = input.int(70, "RSI Overbought Level", minval=50, maxval=90, group=gp_rsi)
rsi_os     = input.int(30, "RSI Oversold Level", minval=10, maxval=50, group=gp_rsi)

gp_smc     = "CCA System - SMC Engine"
pivot_len  = input.int(5, "Swing Pivot Lookback", minval=2, maxval=20, group=gp_smc)
max_zones  = input.int(3, "Max Active Zones (Pruning)", minval=1, maxval=10, group=gp_smc)

// ==========================================
// COLOR PALETTE (CCA AI Terminal Theme)
// ==========================================
color_gold        = #FFD700
color_neon_blue   = #00D4FF // Pure neon blue
color_neon_red    = #FF1744 // Pure neon red
color_neon_green  = #00FF66 // Pure neon green
color_maroon      = #FF1744 // Bright neon red (#FF1744) as requested
color_black       = #000000
color_ultra_dark  = #050505

// Semi-transparent fills and solid borders to match the reference photo style
int fill_trans   = 85 // 15% Opacity (beautifully semi-transparent)
int border_trans = 0  // 100% Solid border (0% transparency)

// ==========================================
// CUSTOM HOLOGRAPHIC CANDLES (Global Scope Plots)
// ==========================================
color body_color = show_candles ? (close >= open ? color_neon_green : color_maroon) : na
color wick_color = show_candles ? (close >= open ? color_neon_green : color_maroon) : na
color border_color = show_candles ? (close >= open ? color_neon_green : color_maroon) : na
plotcandle(show_candles ? open : na, show_candles ? high : na, show_candles ? low : na, show_candles ? close : na, "CCA Cyber Candles", color=body_color, wickcolor=wick_color, bordercolor=border_color)

// ==========================================
// USER DEFINED TYPES (UDTs)
// ==========================================
type ZoneData
    box b
    float top
    float bottom
    int dir // 1 = Bullish, -1 = Bearish
    bool active

// Collections
var array<ZoneData> active_obs  = array.new<ZoneData>()
var array<ZoneData> active_fvgs = array.new<ZoneData>()

// Pruning helper
prune_old_zones(array<ZoneData> zone_arr, int max_allowed) =>
    if array.size(zone_arr) > max_allowed
        for i = 0 to array.size(zone_arr) - max_allowed - 1
            ZoneData old_zone = array.get(zone_arr, 0)
            box.delete(old_zone.b)
            array.shift(zone_arr)

// ==========================================
// SWING PIVOTS & BOS DETECTION
// ==========================================
float ph = ta.pivothigh(high, pivot_len, pivot_len)
float pl = ta.pivotlow(low, pivot_len, pivot_len)

var float last_ph = na
var float last_pl = na
var int last_ph_bar = na
var int last_pl_bar = na

if not na(ph)
    last_ph := ph
    last_ph_bar := bar_index - pivot_len
if not na(pl)
    last_pl := pl
    last_pl_bar := bar_index - pivot_len

var int market_trend = 0 // 1 = Bullish, -1 = Bearish

// Extract crossover checks to global scope to prevent warning CW10002
bool is_ph_crossed = not na(last_ph) and ta.crossover(close, last_ph)
bool is_pl_crossed = not na(last_pl) and ta.crossunder(close, last_pl)

if is_ph_crossed
    market_trend := 1
    if show_bos
        line.new(last_ph_bar, last_ph, bar_index, last_ph, xloc=xloc.bar_index, color=color_neon_green, width=1, style=line.style_dashed)

    // Create Bullish Order Block (OB)
    if show_ob
        int lowest_candle_bar = last_pl_bar
        int offset = bar_index - lowest_candle_bar
        if offset >= 0 and offset < 9900
            float ob_low = nz(low[offset], low)
            float ob_high = nz(high[offset], high)
            for i = 0 to 5
                int idx = bar_index - lowest_candle_bar + i
                int lookup_offset = bar_index - idx
                if lookup_offset >= 0 and lookup_offset < 9900
                    float lookup_open = nz(open[lookup_offset])
                    float lookup_close = nz(close[lookup_offset])
                    float lookup_low = nz(low[lookup_offset])
                    float lookup_high = nz(high[lookup_offset])
                    if lookup_open > lookup_close and lookup_low < ob_low * 1.01
                        ob_low := lookup_low
                        ob_high := lookup_high
                        lowest_candle_bar := idx
                        break

            box ob_box = box.new(lowest_candle_bar, ob_high, bar_index, ob_low,
                                                 bgcolor=color.new(color_neon_blue, fill_trans),
                                                 border_color=color.new(color_neon_blue, border_trans),
                                                 border_style=line.style_solid,
                                                 text="OB", text_size=size.small, text_color=color_neon_blue,
                                                 text_halign=text.align_center, text_valign=text.align_center)
            array.push(active_obs, ZoneData.new(ob_box, ob_high, ob_low, 1, true))
            prune_old_zones(active_obs, max_zones)

    last_ph := na

if is_pl_crossed
    market_trend := -1
    if show_bos
        line.new(last_pl_bar, last_pl, bar_index, last_pl, xloc=xloc.bar_index, color=color_neon_red, width=1, style=line.style_dashed)

    // Create Bearish Order Block (OB)
    if show_ob
        int highest_candle_bar = last_ph_bar
        int offset = bar_index - highest_candle_bar
        if offset >= 0 and offset < 9900
            float ob_low = nz(low[offset], low)
            float ob_high = nz(high[offset], high)
            for i = 0 to 5
                int idx = bar_index - highest_candle_bar + i
                int lookup_offset = bar_index - idx
                if lookup_offset >= 0 and lookup_offset < 9900
                    float lookup_open = nz(open[lookup_offset])
                    float lookup_close = nz(close[lookup_offset])
                    float lookup_low = nz(low[lookup_offset])
                    float lookup_high = nz(high[lookup_offset])
                    if lookup_close > lookup_open and lookup_high > ob_high * 0.99
                        ob_low := lookup_low
                        ob_high := lookup_high
                        highest_candle_bar := idx
                        break

            box ob_box = box.new(highest_candle_bar, ob_high, bar_index, ob_low,
                                                 bgcolor=color.new(color_neon_red, fill_trans),
                                                 border_color=color.new(color_neon_red, border_trans),
                                                 border_style=line.style_solid,
                                                 text="OB", text_size=size.small, text_color=color_neon_red,
                                                 text_halign=text.align_center, text_valign=text.align_center)
            array.push(active_obs, ZoneData.new(ob_box, ob_high, ob_low, -1, true))
            prune_old_zones(active_obs, max_zones)

    last_pl := na

// ==========================================
// FAIR VALUE GAPS (FVG) DETECTION
// ==========================================
if show_fvg
    if (low[0] - high[2]) > 0.0
        box fvg_box = box.new(bar_index - 2, low[0], bar_index, high[2],
                             bgcolor=color.new(color_gold, fill_trans),
                             border_color=color.new(color_gold, border_trans),
                             border_style=line.style_solid)
        array.push(active_fvgs, ZoneData.new(fvg_box, low[0], high[2], 1, true))
        prune_old_zones(active_fvgs, max_zones)

    if (low[2] - high[0]) > 0.0
        box fvg_box = box.new(bar_index - 2, low[2], bar_index, high[0],
                             bgcolor=color.new(color_neon_red, fill_trans),
                             border_color=color.new(color_neon_red, border_trans),
                             border_style=line.style_solid)
        array.push(active_fvgs, ZoneData.new(fvg_box, low[2], high[0], -1, true))
        prune_old_zones(active_fvgs, max_zones)

// ==========================================
// ZONE EXTENSION & MITIGATION
// ==========================================
if array.size(active_obs) > 0
    for i = array.size(active_obs) - 1 to 0
        ZoneData ob = array.get(active_obs, i)
        if ob.active
            box.set_right(ob.b, bar_index)
            if ob.dir == 1 and close < ob.bottom
                ob.active := false
                box.delete(ob.b)
                array.remove(active_obs, i)
            else if ob.dir == -1 and close > ob.top
                ob.active := false
                box.delete(ob.b)
                array.remove(active_obs, i)

if array.size(active_fvgs) > 0
    for i = array.size(active_fvgs) - 1 to 0
        ZoneData fvg = array.get(active_fvgs, i)
        if fvg.active
            box.set_right(fvg.b, bar_index)
            if fvg.dir == 1 and close < fvg.bottom
                fvg.active := false
                box.delete(fvg.b)
                array.remove(active_fvgs, i)
            else if fvg.dir == -1 and close > fvg.top
                fvg.active := false
                box.delete(fvg.b)
                array.remove(active_fvgs, i)

// ==========================================
// EMAs & VWAP ENGINE (Global Scope Plots)
// ==========================================
float ema9  = ta.ema(close, 9)
float ema21 = ta.ema(close, 21)
float ema50 = ta.ema(close, 50)
float vwap_val = ta.vwap

// Ribbon Fill logic
color ribbon_color = show_emas ? (ema9 >= ema21 ? color.new(color_neon_green, 92) : color.new(color_neon_red, 92)) : na

plot_ema9  = plot(show_emas ? ema9 : na, "EMA 9", color=color_gold, linewidth=1)
plot_ema21 = plot(show_emas ? ema21 : na, "EMA 21", color=color_neon_blue, linewidth=1)
plot(show_emas ? ema50 : na, "EMA 50 Circles", color=color_gold, style=plot.style_circles, linewidth=1)
plot(show_emas ? vwap_val : na, "VWAP", color=color_neon_blue, linewidth=1, style=plot.style_line)

fill(plot_ema9, plot_ema21, color=ribbon_color, title="EMA Ribbon Fill")

// ==========================================
// RSI & CONFLUENCE SIGNALS CORE
// ==========================================
float rsi_val = ta.rsi(close, rsi_len)

// Bias System: 4-confluence (candle + EMA + VWAP + EMA50)
bool candle_bullish = close > open
bool ema_bullish    = ema9 > ema21
bool vwap_bullish   = close > vwap_val
bool ema50_bullish  = close > ema50

int bias_score = 0
if candle_bullish
    bias_score += 1
if ema_bullish
    bias_score += 1
if vwap_bullish
    bias_score += 1
if ema50_bullish
    bias_score += 1

string bias_str = bias_score >= 3 ? "BULLISH" : (bias_score <= 1 ? "BEARISH" : "NEUTRAL")
color bias_color = bias_score >= 3 ? color_neon_green : (bias_score <= 1 ? color_neon_red : color.gray)

// Dynamic OB Rejection Signal Engine
bool ob_bullish_rejection = false
bool ob_bearish_rejection = false

if array.size(active_obs) > 0
    for i = 0 to array.size(active_obs) - 1
        ZoneData ob = array.get(active_obs, i)
        if ob.active
            if ob.dir == 1
                // Low touches/dips into Bullish OB, close rejects it upwards
                if low <= ob.top and close >= ob.bottom and close > open
                    ob_bullish_rejection := true
            else if ob.dir == -1
                // High pushes/touches Bearish OB, close rejects it downwards
                if high >= ob.bottom and close <= ob.top and close < open
                    ob_bearish_rejection := true

// Signal Core Logic: Relaxed confluence rules for higher signal frequency
bool rsi_buy_trigger  = ta.crossover(rsi_val, rsi_os)
bool rsi_sell_trigger = ta.crossunder(rsi_val, rsi_ob)

// Signals trigger on:
// 1. RSI crossover + basic trend/bias alignment (ema_bullish or bias_score >= 2)
// 2. OR when a clear OB Rejection happens in the trend direction
bool buy_sig  = (rsi_buy_trigger and (ema_bullish or bias_score >= 2)) or (ob_bullish_rejection and ema_bullish)
bool sell_sig = (rsi_sell_trigger and (not ema_bullish or bias_score <= 2)) or (ob_bearish_rejection and not ema_bullish)

// Prevent signal spam with reduced cooldown (5 bars instead of 10)
var int last_sig_bar = 0
bool is_new_buy  = buy_sig and (bar_index - last_sig_bar > 5)
bool is_new_sell = sell_sig and (bar_index - last_sig_bar > 5)

if is_new_buy
    last_sig_bar := bar_index
    alert("CCA AI System: BUY CONFIRMED", alert.freq_once_per_bar_close)

if is_new_sell
    last_sig_bar := bar_index
    alert("CCA AI System: SELL CONFIRMED", alert.freq_once_per_bar_close)

// Double-Pulse signals: Arrow + double circles (Global Scope Plots)
plotshape(is_new_buy, title="Buy Arrow", style=shape.arrowup, location=location.belowbar, color=color_neon_green, size=size.small)
plotshape(is_new_buy, title="Buy Pulse 1", style=shape.circle, location=location.belowbar, color=color.new(color_neon_green, 40), size=size.tiny)
plotshape(is_new_buy, title="Buy Pulse 2", style=shape.circle, location=location.belowbar, color=color.new(color_neon_green, 70), size=size.small)

plotshape(is_new_sell, title="Sell Arrow", style=shape.arrowdown, location=location.abovebar, color=color_neon_red, size=size.small)
plotshape(is_new_sell, title="Sell Pulse 1", style=shape.circle, location=location.abovebar, color=color.new(color_neon_red, 40), size=size.tiny)
plotshape(is_new_sell, title="Sell Pulse 2", style=shape.circle, location=location.abovebar, color=color.new(color_neon_red, 70), size=size.small)

// BOS Alerts
bool bos_up_alert   = market_trend == 1 and market_trend[1] != 1
bool bos_down_alert = market_trend == -1 and market_trend[1] != -1

if bos_up_alert
    alert("CCA AI System: BOS UP DETECTED", alert.freq_once_per_bar_close)
if bos_down_alert
    alert("CCA AI System: BOS DOWN DETECTED", alert.freq_once_per_bar_close)

// ==========================================
// CCA AI TERMINAL TELEMETRY HUD
// ==========================================
var table hud = table.new(position.top_right, 2, 8,
                          bgcolor=color_ultra_dark,
                          border_color=color_gold,
                          border_width=1,
                          frame_color=color_neon_blue,
                          frame_width=2)

if barstate.islast
    table.cell(hud, 0, 0, "CCA AI SYSTEM", bgcolor=color.new(color_gold, 15), text_color=color_gold, text_size=size.small, width=15)
    table.cell(hud, 1, 0, "PREMIUM v1.0", bgcolor=color.new(color_gold, 15), text_color=color_gold, text_size=size.small, width=15)

    // BIAS Cell
    table.cell(hud, 0, 1, "BIAS SCORE", text_color=color.white, text_size=size.small)
    table.cell(hud, 1, 1, bias_str + " (" + str.tostring(bias_score) + "/4)", text_color=bias_color, text_size=size.small)

    // RSI Cell
    color rsi_color = rsi_val >= rsi_ob ? color_neon_red : (rsi_val <= rsi_os ? color_neon_green : color.white)
    table.cell(hud, 0, 2, "RSI 7 CORE", text_color=color.white, text_size=size.small)
    table.cell(hud, 1, 2, str.tostring(rsi_val, "#.##"), text_color=rsi_color, text_size=size.small)

    // VWAP Cell
    string vwap_arrow = close > vwap_val ? "▲ ABOVE" : "▼ BELOW"
    color vwap_color = close > vwap_val ? color_neon_green : color_neon_red
    table.cell(hud, 0, 3, "VWAP VECTOR", text_color=color.white, text_size=size.small)
    table.cell(hud, 1, 3, vwap_arrow, text_color=vwap_color, text_size=size.small)

    // EMA Trend Cell
    string ema_arrow = ema9 >= ema21 ? "▲ BULLISH" : "▼ BEARISH"
    color ema_trend_color = ema9 >= ema21 ? color_neon_green : color_neon_red
    table.cell(hud, 0, 4, "EMA TREND", text_color=color.white, text_size=size.small)
    table.cell(hud, 1, 4, ema_arrow, text_color=ema_trend_color, text_size=size.small)

    // FVG Toggle Status
    table.cell(hud, 0, 5, "FVG STATUS", text_color=color.white, text_size=size.small)
    table.cell(hud, 1, 5, show_fvg ? "ACTIVE" : "DISABLED", text_color=show_fvg ? color_neon_green : color_neon_red, text_size=size.small)

    // OB Toggle Status
    table.cell(hud, 0, 6, "OB STATUS", text_color=color.white, text_size=size.small)
    table.cell(hud, 1, 6, show_ob ? "ACTIVE" : "DISABLED", text_color=show_ob ? color_neon_green : color_neon_red, text_size=size.small)

    // Signal Status Cell
    string signal_status = is_new_buy ? "BUY CONFIRMED" : (is_new_sell ? "SELL CONFIRMED" : "SCANNING FLOW —")
    color signal_status_color = is_new_buy ? color_neon_green : (is_new_sell ? color_neon_red : color.gray)
    table.cell(hud, 0, 7, "AI SIGNAL STATUS", text_color=color_gold, text_size=size.small)
    table.cell(hud, 1, 7, signal_status, text_color=signal_status_color, text_size=size.small)
````
