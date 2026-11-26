# Pigo 848 Trend NQGC

- url: https://www.tradingview.com/script/f8lJ6xr0/
- type: indicator
- pine_id: PUB;95a680b8caab4ee3a473f65082612684
- version: 1.0

## Description

only to spot trends on MQ and GC  with strong med and weak signals

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AlexFuch (modified with Kalman Trend Meter + NQ/GC presets + Enhanced Strength)

//@version=6

indicator("Pigo 848 Trend", shorttitle = "Pigo848", overlay = true, scale = scale.none, dynamic_requests = true)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//* PRESET SELECTOR *//

preset = input.string("NQ Scalping", title = "⚡ Preset", options = ["NQ Scalping", "GC Scalping", "Custom"], tooltip = "Select a preset to auto-configure all parameters. Choose Custom to use manual values below.", group = '🎯 PRESET SELECTOR')

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//* BAR SETTINGS *//

paint_bars = input(false, title = "Paint bars? (works in ALL presets)", tooltip = "This overrides presets. Turn ON only if you want colored bars.", group = 'Bars Settings')
catch_flat_custom = input(false, title = "Try to catch flat? (Custom only)", group = 'Bars Settings')
uptrend_colour = input.color(defval = color.green, title = "Uptrend colour", group = 'Bars Settings')
downtrend_colour = input.color(defval = color.red, title = "Downtrend colour", group = 'Bars Settings')
neutraltrend_colour = input.color(defval = color.gray, title = "Neutraltrend colour", group = 'Bars Settings')

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//* TABLE SETTINGS *//

show_header = input(false, title = "Show header?", group = 'Table Settings')
show_ema_value = input(false, title = "Show EMA value?", group = 'Table Settings')
show_strength = input(true, title = "Show trend strength?", group = 'Table Settings')
show_preset_label = input(true, title = "Show active preset label?", group = 'Table Settings')
dashboard_position  = input.session("Middle right", "Position", ["Top right", "Bottom right", "Top left", "Bottom left", "Top center", "Bottom center", "Middle right"], group = 'Table Settings')
text_size = input.session('Small', "Size", options = ["Tiny", "Small", "Normal", "Large"], group = 'Table Settings')
text_color = input.color(defval = color.white, title = "Text colour", group = 'Table Settings')
table_color = input.color(defval = color.gray, title = "Border colour", group = 'Table Settings')

uptrend_indicator = input("🟢", title = "Uptrend indicator", group = 'Table Settings')
downtrend_indicator = input("🔴", title = "Downtrend indicator", group = 'Table Settings')
neutraltrend_indicator = input("⚫️", title = "Neutraltrend indicator", group = 'Table Settings')

strong_trend_indicator = input("💪", title = "Strong trend indicator", group = 'Table Settings')
medium_trend_indicator = input("👊", title = "Medium trend indicator", group = 'Table Settings')
weak_trend_indicator = input("🤏", title = "Weak trend indicator", group = 'Table Settings')

header_bg_color = input.color(color.rgb(128, 128, 128, 75), title = "Header background colour", group = 'Table Settings')
uptrend_bg_color = input.color(color.rgb(76, 175, 80, 75), title = "Uptrend background colour", group = 'Table Settings')
downtrend_bg_color = input(color.rgb(255, 82, 82, 75), title = "Downtrend background colour", group = 'Table Settings')
neutraltrend_bg_color = input(color.rgb(120, 123, 134, 75), title = "Neutraltrend background colour", group = 'Table Settings')

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//* CUSTOM EMA SETTINGS *//

trend_identification_approach  = input.session("Direction of a single EMA", "Trend identification approach (Custom only)", ["Direction of a single EMA", "Comparison of the two EMAs"], group = '📈 Custom EMA Settings')
ema1_length_custom = input.int(title = "EMA length (Custom only)", defval = 50, minval = 1, maxval = 800, group = '📈 Custom EMA Settings')
ema2_length_custom = input.int(title = "Additional EMA length (Custom only)", defval = 200, minval = 1, maxval = 800, group = '📈 Custom EMA Settings')

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//* CUSTOM STRENGTH SETTINGS *//

kalman_process_noise_custom = input.float(title = "Process noise (Custom only)", defval = 0.05, minval = 0.001, maxval = 1.0, step = 0.01, group = '⚡ Custom Strength Settings')
kalman_measurement_noise_custom = input.float(title = "Measurement noise (Custom only)", defval = 3.0, minval = 0.1, maxval = 50.0, step = 0.1, group = '⚡ Custom Strength Settings')
kalman_slope_period_custom = input.int(title = "Slope period (Custom only)", defval = 5, minval = 1, maxval = 50, group = '⚡ Custom Strength Settings')
momentum_period_custom = input.int(title = "Momentum period (Custom only)", defval = 5, minval = 1, maxval = 50, tooltip = "How many bars back to measure raw price momentum. Catches fast drops.", group = '⚡ Custom Strength Settings')
atr_length_custom = input.int(title = "ATR length (Custom only)", defval = 20, minval = 1, maxval = 100, tooltip = "Use 20+ to avoid ATR inflation during strong moves.", group = '⚡ Custom Strength Settings')
strength_weak_threshold_custom = input.float(title = "Weak threshold % (Custom only)", defval = 15.0, minval = 0.1, maxval = 500.0, step = 0.5, group = '⚡ Custom Strength Settings')
strength_strong_threshold_custom = input.float(title = "Strong threshold % (Custom only)", defval = 40.0, minval = 0.1, maxval = 500.0, step = 0.5, group = '⚡ Custom Strength Settings')

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//* PRESET RESOLUTION *//

// NQ Scalping preset values
nq_catch_flat = false
nq_ema1 = 21
nq_ema2 = 50
nq_approach = "Direction of a single EMA"
nq_process_noise = 0.12
nq_measurement_noise = 2.0
nq_slope_period = 3
nq_momentum_period = 5
nq_atr_length = 20
nq_weak_threshold = 25.0
nq_strong_threshold = 65.0

// GC Scalping preset values
gc_catch_flat = true
gc_ema1 = 34
gc_ema2 = 50
gc_approach = "Direction of a single EMA"
gc_process_noise = 0.06
gc_measurement_noise = 4.0
gc_slope_period = 5
gc_momentum_period = 7
gc_atr_length = 20
gc_weak_threshold = 15.0
gc_strong_threshold = 45.0

// Resolve active parameters
catch_flat = preset == "NQ Scalping" ? nq_catch_flat : preset == "GC Scalping" ? gc_catch_flat : catch_flat_custom
ema1_length = preset == "NQ Scalping" ? nq_ema1 : preset == "GC Scalping" ? gc_ema1 : ema1_length_custom
ema2_length = preset == "NQ Scalping" ? nq_ema2 : preset == "GC Scalping" ? gc_ema2 : ema2_length_custom
active_approach = preset == "NQ Scalping" ? nq_approach : preset == "GC Scalping" ? gc_approach : trend_identification_approach
kalman_process_noise = preset == "NQ Scalping" ? nq_process_noise : preset == "GC Scalping" ? gc_process_noise : kalman_process_noise_custom
kalman_measurement_noise = preset == "NQ Scalping" ? nq_measurement_noise : preset == "GC Scalping" ? gc_measurement_noise : kalman_measurement_noise_custom
kalman_slope_period = preset == "NQ Scalping" ? nq_slope_period : preset == "GC Scalping" ? gc_slope_period : kalman_slope_period_custom
momentum_period = preset == "NQ Scalping" ? nq_momentum_period : preset == "GC Scalping" ? gc_momentum_period : momentum_period_custom
atr_length = preset == "NQ Scalping" ? nq_atr_length : preset == "GC Scalping" ? gc_atr_length : atr_length_custom
strength_weak_threshold = preset == "NQ Scalping" ? nq_weak_threshold : preset == "GC Scalping" ? gc_weak_threshold : strength_weak_threshold_custom
strength_strong_threshold = preset == "NQ Scalping" ? nq_strong_threshold : preset == "GC Scalping" ? gc_strong_threshold : strength_strong_threshold_custom

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//* TIMEFRAME SETTINGS *//

show_1m = input(true, title = 'Show 1m', group = 'Timeframe Settings')
show_2m = input(false, title = 'Show 2m ', group = 'Timeframe Settings')
show_3m = input(false, title = 'Show 3m ', group = 'Timeframe Settings')
show_5m = input(true, title = 'Show 5m', group = 'Timeframe Settings')
show_10m = input(false, title = 'Show 10m', group = 'Timeframe Settings')
show_15m = input(true, title = 'Show 15m', group = 'Timeframe Settings')
show_30m = input(false, title = 'Show 30m', group = 'Timeframe Settings')
show_45m = input(false, title = 'Show 45m', group = 'Timeframe Settings')
show_1h = input(true, title = 'Show 1h', group = 'Timeframe Settings')
show_2h = input(false, title = 'Show 2h', group = 'Timeframe Settings')
show_3h = input(false, title = 'Show 3h', group = 'Timeframe Settings')
show_4h = input(true, title = 'Show 4h', group = 'Timeframe Settings')
show_6h = input(false, title = 'Show 6h', group = 'Timeframe Settings')
show_8h = input(false, title = 'Show 8h', group = 'Timeframe Settings')
show_12h = input(false, title = 'Show 12h', group = 'Timeframe Settings')
show_D = input(true, title = 'Show D', group = 'Timeframe Settings')
show_3D = input(false, title = 'Show 3D', group = 'Timeframe Settings')
show_W = input(false, title = 'Show W', group = 'Timeframe Settings')
show_M = input(false, title = 'Show M', group = 'Timeframe Settings')

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//* CALCULATION *//

var table_position = dashboard_position == 'Top right' ? position.top_right :
  dashboard_position == 'Top left' ? position.top_left :
  dashboard_position == 'Top center' ? position.top_center :
  dashboard_position == 'Bottom right' ? position.bottom_right :
  dashboard_position == 'Bottom left' ? position.bottom_left :
  dashboard_position == 'Bottom center' ? position.bottom_center :
  dashboard_position == 'Middle right' ? position.middle_right :
  dashboard_position == 'Middle left' ? position.middle_left : position.middle_right
  
var table_text_size = text_size == 'Normal' ? size.normal :
  text_size == 'Large' ? size.large :
  text_size == 'Tiny' ? size.tiny :
  text_size == 'Small' ? size.small : size.normal

var t = table.new(position = table_position,
                  columns = 4,
                  rows = 21,
                  frame_color = table_color,
                  frame_width = 2,
                  border_color = table_color,
                  border_width = 2)

calc_smma(src, len) =>
    var float smma = na
    sma_val = ta.sma(src, len)
    smma := na(smma) ? sma_val : (smma[1] * (len - 1) + src) / len
    smma

calc_zlema(src, len) =>
    ema1 = ta.ema(src, len)
    ema2 = ta.ema(ema1, len)
    d = ema1 - ema2
    ema1 + d

check_impulse() =>
    impulse_length = 34
    impulse_strength = 9
    hi = calc_smma(high, impulse_length)
    lo = calc_smma(low, impulse_length)
    mi = calc_zlema(hlc3, impulse_length)
    md = (mi > hi) ? (mi - hi) : (mi < lo) ? (mi - lo) : 0
    md_prev = (mi[1] > hi[1]) ? (mi[1] - hi[1]) : (mi[1] < lo[1]) ? (mi[1] - lo[1]) : 0
    sb = ta.sma(md, impulse_strength)
    sb_prev = ta.sma(md_prev, impulse_strength)
    sh = md - sb
    sh_prev = md_prev - sb_prev
    is_impulse = sh != 0 and sh_prev != 0
    is_impulse

// KALMAN FILTER
calc_kalman(src, process_noise, measurement_noise) =>
    var float x_est = na
    var float p_est = 1.0
    if na(x_est)
        x_est := src
    x_pred = x_est
    p_pred = p_est + process_noise
    k_gain = p_pred / (p_pred + measurement_noise)
    x_est := x_pred + k_gain * (src - x_pred)
    p_est := (1 - k_gain) * p_pred
    x_est

// ENHANCED STRENGTH METER
// Combines: Kalman slope (40%) + Price momentum (40%) + Acceleration (20%)
// Uses stable ATR (offset by 1) to avoid inflation during strong moves
calc_enhanced_strength(slope_period, mom_period, atr_len, proc_noise, meas_noise) =>
    // 1. Kalman slope (velocidad del filtro)
    kalman_value = calc_kalman(close, proc_noise, meas_noise)
    kalman_slope = (kalman_value - kalman_value[slope_period]) / slope_period
    
    // 2. Price momentum (captura movimientos rápidos que el Kalman suaviza)
    price_momentum = (close - close[mom_period]) / mom_period
    
    // 3. Acceleration (detecta si el movimiento se está intensificando)
    kalman_slope_prev = (kalman_value[slope_period] - kalman_value[slope_period * 2]) / slope_period
    acceleration = kalman_slope - kalman_slope_prev
    
    // ATR estable: desfasado 1 vela para no contaminarse con la vela explosiva actual
    atr_stable = ta.atr(atr_len)[1]
    atr_value = na(atr_stable) ? ta.atr(atr_len) : atr_stable
    
    // Ratios individuales normalizados
    slope_ratio = atr_value != 0 ? (math.abs(kalman_slope) / atr_value) * 100 : 0
    momentum_ratio = atr_value != 0 ? (math.abs(price_momentum) / atr_value) * 100 : 0
    acceleration_ratio = atr_value != 0 ? (math.abs(acceleration) / atr_value) * 100 : 0
    
    // Fuerza combinada con pesos
    combined_strength = (slope_ratio * 0.4) + (momentum_ratio * 0.4) + (acceleration_ratio * 0.2)
    
    combined_strength

get_strength_indicator(strength_value) =>
    strength_value < strength_weak_threshold ? weak_trend_indicator :
      strength_value > strength_strong_threshold ? strong_trend_indicator :
      medium_trend_indicator

get_trend_status() =>
    impulse = catch_flat ? check_impulse() : true
    ema1_current_candle = ta.ema(close, ema1_length)
    ema1_previous_candle = ema1_current_candle[1]
    round = ema1_current_candle > 1000 ? 0 : ema1_current_candle > 10 ? 1 : ema1_current_candle > 0 ? 2 : ema1_current_candle > 0.1 ? 3 : 10
    ema1_str = str.tostring(math.round(ema1_current_candle, round))
    
    enhanced_strength = calc_enhanced_strength(kalman_slope_period, momentum_period, atr_length, kalman_process_noise, kalman_measurement_noise)
    strength = get_strength_indicator(enhanced_strength)
    
    if (active_approach == "Direction of a single EMA")
        ema1_previous_previous_candle = ema1_current_candle[2]
        trend_bg_color = not impulse ? neutraltrend_bg_color : ema1_current_candle > ema1_previous_candle ? uptrend_bg_color : ema1_current_candle < ema1_previous_candle ? downtrend_bg_color : neutraltrend_bg_color
        trend_current_candle = not impulse ? neutraltrend_indicator : ema1_current_candle > ema1_previous_candle ? uptrend_indicator : ema1_current_candle < ema1_previous_candle ? downtrend_indicator : neutraltrend_indicator
        trend_previous_candle = not impulse ? neutraltrend_indicator : ema1_previous_candle > ema1_previous_previous_candle ? uptrend_indicator : ema1_previous_candle < ema1_previous_previous_candle ? downtrend_indicator : neutraltrend_indicator
        [ema1_str, trend_bg_color, trend_current_candle, trend_previous_candle, strength]
    else
        ema2_current_candle = ta.ema(close, ema2_length)
        ema2_previous_candle = ema2_current_candle[1]
        trend_bg_color = not impulse ? neutraltrend_bg_color : ema1_current_candle > ema2_current_candle ? uptrend_bg_color : ema1_current_candle < ema2_current_candle ? downtrend_bg_color : neutraltrend_bg_color
        trend_current_candle = not impulse ? neutraltrend_indicator : ema1_current_candle > ema2_current_candle ? uptrend_indicator : ema1_current_candle < ema2_current_candle ? downtrend_indicator : neutraltrend_indicator
        trend_previous_candle = not impulse ? neutraltrend_indicator : ema1_previous_candle > ema2_previous_candle ? uptrend_indicator : ema1_previous_candle < ema2_previous_candle ? downtrend_indicator : neutraltrend_indicator
        [ema1_str, trend_bg_color, trend_current_candle, trend_previous_candle, strength]

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//* MTF DATA REQUESTS *//

[ema_1m, trend_bg_color_1m, trend_indicator_1m, _, strength_1m] = if (show_1m)
    request.security(syminfo.tickerid, "1", get_trend_status())
else
    [na, na, na, na, na]

[ema_2m, trend_bg_color_2m, trend_indicator_2m, _, strength_2m] = if (show_2m)
    request.security(syminfo.tickerid, "2", get_trend_status())
else
    [na, na, na, na, na]

[ema_3m, trend_bg_color_3m, trend_indicator_3m, _, strength_3m] = if (show_3m)
    request.security(syminfo.tickerid, "3", get_trend_status())
else
    [na, na, na, na, na]

[ema_5m, trend_bg_color_5m, trend_indicator_5m, _, strength_5m] = if (show_5m)
    request.security(syminfo.tickerid, "5", get_trend_status())
else
    [na, na, na, na, na]

[ema_10m, trend_bg_color_10m, trend_indicator_10m, _, strength_10m] = if (show_10m)
    request.security(syminfo.tickerid, "10", get_trend_status())
else
    [na, na, na, na, na]

[ema_15m, trend_bg_color_15m, trend_indicator_15m, _, strength_15m] = if (show_15m)
    request.security(syminfo.tickerid, "15", get_trend_status())
else
    [na, na, na, na, na]

[ema_30m, trend_bg_color_30m, trend_indicator_30m, _, strength_30m] = if (show_30m)
    request.security(syminfo.tickerid, "30", get_trend_status())
else
    [na, na, na, na, na]

[ema_45m, trend_bg_color_45m, trend_indicator_45m, _, strength_45m] = if (show_45m)
    request.security(syminfo.tickerid, "45", get_trend_status())
else
    [na, na, na, na, na]

[ema_1h, trend_bg_color_1h, trend_indicator_1h, _, strength_1h] = if (show_1h)
    request.security(syminfo.tickerid, "60", get_trend_status())
else
    [na, na, na, na, na]

[ema_2h, trend_bg_color_2h, trend_indicator_2h, _, strength_2h] = if (show_2h)
    request.security(syminfo.tickerid, "120", get_trend_status())
else
    [na, na, na, na, na]

[ema_3h, trend_bg_color_3h, trend_indicator_3h, _, strength_3h] = if (show_3h)
    request.security(syminfo.tickerid, "180", get_trend_status())
else
    [na, na, na, na, na]

[ema_4h, trend_bg_color_4h, trend_indicator_4h, _, strength_4h] = if (show_4h)
    request.security(syminfo.tickerid, "240", get_trend_status())
else
    [na, na, na, na, na]

[ema_6h, trend_bg_color_6h, trend_indicator_6h, _, strength_6h] = if (show_6h)
    request.security(syminfo.tickerid, "360", get_trend_status())
else
    [na, na, na, na, na]

[ema_8h, trend_bg_color_8h, trend_indicator_8h, _, strength_8h] = if (show_8h)
    request.security(syminfo.tickerid, "480", get_trend_status())
else
    [na, na, na, na, na]

[ema_12h, trend_bg_color_12h, trend_indicator_12h, _, strength_12h] = if (show_12h)
    request.security(syminfo.tickerid, "720", get_trend_status())
else
    [na, na, na, na, na]

[ema_D, trend_bg_color_D, trend_indicator_D, _, strength_D] = if (show_D)
    request.security(syminfo.tickerid, "D", get_trend_status())
else
    [na, na, na, na, na]

[ema_3D, trend_bg_color_3D, trend_indicator_3D, _, strength_3D] = if (show_3D)
    request.security(syminfo.tickerid, "3D", get_trend_status())
else
    [na, na, na, na, na]

[ema_W, trend_bg_color_W, trend_indicator_W, _, strength_W] = if (show_W)
    request.security(syminfo.tickerid, "W", get_trend_status())
else
    [na, na, na, na, na]

[ema_M, trend_bg_color_M, trend_indicator_M, _, strength_M] = if (show_M)
    request.security(syminfo.tickerid, "M", get_trend_status())
else
    [na, na, na, na, na]

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//* TABLE DRAWING *//

f_draw_row(row, tf_label, trend_ind, strength_ind, ema_val, bg) =>
    table.cell(t, 0, row, tf_label, text_color = text_color, text_size = table_text_size, bgcolor = bg)
    table.cell(t, 1, row, trend_ind, text_color = text_color, text_size = table_text_size, bgcolor = bg)
    col = 2
    if (show_strength)
        table.cell(t, col, row, strength_ind, text_color = text_color, text_size = table_text_size, bgcolor = bg)
        col += 1
    if (show_ema_value)
        table.cell(t, col, row, ema_val, text_color = text_color, text_size = table_text_size, bgcolor = bg)

preset_icon = preset == "NQ Scalping" ? "🟦 NQ" : preset == "GC Scalping" ? "🟨 GC" : "⚙️ Custom"
preset_bg = preset == "NQ Scalping" ? color.rgb(33, 150, 243, 60) : preset == "GC Scalping" ? color.rgb(255, 193, 7, 60) : color.rgb(158, 158, 158, 60)

if (barstate.islast)
    row_idx = 0
    
    if (show_preset_label)
        table.cell(t, 0, row_idx, preset_icon, text_color = text_color, text_size = table_text_size, bgcolor = preset_bg)
        table.cell(t, 1, row_idx, "", bgcolor = preset_bg)
        if (show_strength)
            table.cell(t, 2, row_idx, "", bgcolor = preset_bg)
        if (show_ema_value)
            last_col = show_strength ? 3 : 2
            table.cell(t, last_col, row_idx, "", bgcolor = preset_bg)
        row_idx += 1
    
    if (show_header)
        table.cell(t, 0, row_idx, "TF", text_color = text_color, text_size = table_text_size, bgcolor = header_bg_color)
        table.cell(t, 1, row_idx, "Trend", text_color = text_color, text_size = table_text_size, bgcolor = header_bg_color)
        col = 2
        if (show_strength)
            table.cell(t, col, row_idx, "Force", text_color = text_color, text_size = table_text_size, bgcolor = header_bg_color)
            col += 1
        if (show_ema_value)
            table.cell(t, col, row_idx, str.tostring(ema1_length) + " EMA", text_color = text_color, text_size = table_text_size, bgcolor = header_bg_color)
        row_idx += 1

    if (show_1m)
        f_draw_row(row_idx, "1m", trend_indicator_1m, strength_1m, ema_1m, trend_bg_color_1m)
        row_idx += 1
    if (show_2m)
        f_draw_row(row_idx, "2m", trend_indicator_2m, strength_2m, ema_2m, trend_bg_color_2m)
        row_idx += 1
    if (show_3m)
        f_draw_row(row_idx, "3m", trend_indicator_3m, strength_3m, ema_3m, trend_bg_color_3m)
        row_idx += 1
    if (show_5m)
        f_draw_row(row_idx, "5m", trend_indicator_5m, strength_5m, ema_5m, trend_bg_color_5m)
        row_idx += 1
    if (show_10m)
        f_draw_row(row_idx, "10m", trend_indicator_10m, strength_10m, ema_10m, trend_bg_color_10m)
        row_idx += 1
    if (show_15m)
        f_draw_row(row_idx, "15m", trend_indicator_15m, strength_15m, ema_15m, trend_bg_color_15m)
        row_idx += 1
    if (show_30m)
        f_draw_row(row_idx, "30m", trend_indicator_30m, strength_30m, ema_30m, trend_bg_color_30m)
        row_idx += 1
    if (show_45m)
        f_draw_row(row_idx, "45m", trend_indicator_45m, strength_45m, ema_45m, trend_bg_color_45m)
        row_idx += 1
    if (show_1h)
        f_draw_row(row_idx, "1h", trend_indicator_1h, strength_1h, ema_1h, trend_bg_color_1h)
        row_idx += 1
    if (show_2h)
        f_draw_row(row_idx, "2h", trend_indicator_2h, strength_2h, ema_2h, trend_bg_color_2h)
        row_idx += 1
    if (show_3h)
        f_draw_row(row_idx, "3h", trend_indicator_3h, strength_3h, ema_3h, trend_bg_color_3h)
        row_idx += 1
    if (show_4h)
        f_draw_row(row_idx, "4h", trend_indicator_4h, strength_4h, ema_4h, trend_bg_color_4h)
        row_idx += 1
    if (show_6h)
        f_draw_row(row_idx, "6h", trend_indicator_6h, strength_6h, ema_6h, trend_bg_color_6h)
        row_idx += 1
    if (show_8h)
        f_draw_row(row_idx, "8h", trend_indicator_8h, strength_8h, ema_8h, trend_bg_color_8h)
        row_idx += 1
    if (show_12h)
        f_draw_row(row_idx, "12h", trend_indicator_12h, strength_12h, ema_12h, trend_bg_color_12h)
        row_idx += 1
    if (show_D)
        f_draw_row(row_idx, "D", trend_indicator_D, strength_D, ema_D, trend_bg_color_D)
        row_idx += 1
    if (show_3D)
        f_draw_row(row_idx, "3D", trend_indicator_3D, strength_3D, ema_3D, trend_bg_color_3D)
        row_idx += 1
    if (show_W)
        f_draw_row(row_idx, "W", trend_indicator_W, strength_W, ema_W, trend_bg_color_W)
        row_idx += 1
    if (show_M)
        f_draw_row(row_idx, "M", trend_indicator_M, strength_M, ema_M, trend_bg_color_M)
        row_idx += 1

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//* BARS *//

[_, _, current_trend_indicator_current_timeframe, previous_trend_indicator_current_timeframe, _] = get_trend_status()
barcolor = current_trend_indicator_current_timeframe == uptrend_indicator ? uptrend_colour : current_trend_indicator_current_timeframe == downtrend_indicator ? downtrend_colour : neutraltrend_colour
barcolor(color = barcolor, editable = false, display = paint_bars ? display.all : display.none)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//* ALERTS *//

alertcondition(current_trend_indicator_current_timeframe != previous_trend_indicator_current_timeframe, '0. Trend changed', '⏰ Pigo848 - Trend changed on {{ticker}}:{{interval}}min')
alertcondition(current_trend_indicator_current_timeframe != previous_trend_indicator_current_timeframe and current_trend_indicator_current_timeframe == uptrend_indicator, '1. Uptrend started', '🟢 Pigo848 - Uptrend started on {{ticker}}:{{interval}}min')
alertcondition(current_trend_indicator_current_timeframe != previous_trend_indicator_current_timeframe and current_trend_indicator_current_timeframe == downtrend_indicator, '2. Downtrend started', '🔴 Pigo848 - Downtrend started on {{ticker}}:{{interval}}min')
alertcondition(current_trend_indicator_current_timeframe != previous_trend_indicator_current_timeframe and current_trend_indicator_current_timeframe == neutraltrend_indicator, '3. Neutral trend started', '⚫️ Pigo848 - Neutral trend started on {{ticker}}:{{interval}}min')
alertcondition(trend_indicator_3D == trend_indicator_D and trend_indicator_D == trend_indicator_4h, '4. 3D, D, 4h aligned', 'Pigo848 - 3D, D, 4h {{ticker}} trend alignment')
alertcondition(trend_indicator_D == trend_indicator_4h and trend_indicator_4h == trend_indicator_1h, '5. D, 4h, 1h aligned', 'Pigo848 - D, 4h, 1h {{ticker}} trend alignment')
alertcondition(trend_indicator_4h == trend_indicator_1h and trend_indicator_1h == trend_indicator_15m, '6. 4h, 1h, 15m aligned', 'Pigo848 - 4h, 1h, 15m {{ticker}} trend alignment')
alertcondition(trend_indicator_1h == trend_indicator_15m and trend_indicator_15m == trend_indicator_5m, '7. 1h, 15m, 5m aligned', 'Pigo848 - 1h, 15m, 5m {{ticker}} trend alignment')
alertcondition(trend_indicator_15m == trend_indicator_5m and trend_indicator_5m == trend_indicator_3m, '8. 15m, 5m, 3m aligned', 'Pigo848 - 15m, 5m, 3m {{ticker}} trend alignment')
alertcondition(trend_indicator_5m == trend_indicator_3m and trend_indicator_3m == trend_indicator_1m, '9. 5m, 3m, 1m aligned', 'Pigo848 - 5m, 3m, 1m {{ticker}} trend alignment')
````
