# Pigo GC NQ FX

- url: https://www.tradingview.com/script/4o8xaHee/
- type: indicator
- pine_id: PUB;a302fcd400984abdb537adaeb2b2210e
- version: 1.0

## Description

trend strenght for scalping nq and gc and to swing FX

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AlexFuch (modified - Pigo GC NQ FX with ADX Strength + Dual Preset)

//@version=6

indicator("Pigo GC NQ FX", shorttitle = "PigoFX", overlay = true, scale = scale.none, dynamic_requests = true)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//* PRESET SELECTOR *//

preset = input.string("Scalping GC & NQ", title = "⚡ Preset", options = ["Scalping GC & NQ", "4H Swing", "Custom"], tooltip = "Scalping GC & NQ: optimizado para leer tendencias en 15m-1h con 4H como main trend. 4H Swing: optimizado para 4H/D/W. Custom: valores manuales.", group = '🎯 PRESET SELECTOR')

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
dashboard_position = input.session("Middle right", "Position", ["Top right", "Bottom right", "Top left", "Bottom left", "Top center", "Bottom center", "Middle right"], group = 'Table Settings')
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

trend_identification_approach = input.session("Direction of a single EMA", "Trend identification approach (Custom only)", ["Direction of a single EMA", "Comparison of the two EMAs"], group = '📈 Custom EMA Settings')
ema1_length_custom = input.int(title = "EMA length (Custom only)", defval = 50, minval = 1, maxval = 800, group = '📈 Custom EMA Settings')
ema2_length_custom = input.int(title = "Additional EMA length (Custom only)", defval = 200, minval = 1, maxval = 800, group = '📈 Custom EMA Settings')

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//* CUSTOM ADX SETTINGS *//

adx_length_custom = input.int(title = "ADX length (Custom only)", defval = 14, minval = 1, maxval = 100, group = '💪 Custom ADX Settings')
adx_weak_threshold_custom = input.int(title = "ADX weak threshold (Custom only)", defval = 20, minval = 1, maxval = 100, tooltip = 'ADX below this value = weak trend', group = '💪 Custom ADX Settings')
adx_strong_threshold_custom = input.int(title = "ADX strong threshold (Custom only)", defval = 40, minval = 1, maxval = 100, tooltip = 'ADX above this value = strong trend', group = '💪 Custom ADX Settings')

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//* PRESET RESOLUTION *//

// 🔵 Scalping GC & NQ preset (balanceado para ambos activos)
sc_catch_flat = false
sc_ema1 = 21
sc_ema2 = 50
sc_approach = "Direction of a single EMA"
sc_adx_length = 9
sc_adx_weak = 17
sc_adx_strong = 32

// 🟢 4H Swing preset (macro trend reading)
sw_catch_flat = true
sw_ema1 = 50
sw_ema2 = 200
sw_approach = "Comparison of the two EMAs"
sw_adx_length = 14
sw_adx_weak = 20
sw_adx_strong = 40

// Resolve active parameters based on selected preset
is_scalp = preset == "Scalping GC & NQ"
is_swing = preset == "4H Swing"

catch_flat = is_scalp ? sc_catch_flat : is_swing ? sw_catch_flat : catch_flat_custom
ema1_length = is_scalp ? sc_ema1 : is_swing ? sw_ema1 : ema1_length_custom
ema2_length = is_scalp ? sc_ema2 : is_swing ? sw_ema2 : ema2_length_custom
active_approach = is_scalp ? sc_approach : is_swing ? sw_approach : trend_identification_approach
adx_length = is_scalp ? sc_adx_length : is_swing ? sw_adx_length : adx_length_custom
adx_weak_threshold = is_scalp ? sc_adx_weak : is_swing ? sw_adx_weak : adx_weak_threshold_custom
adx_strong_threshold = is_scalp ? sc_adx_strong : is_swing ? sw_adx_strong : adx_strong_threshold_custom

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

//* TABLE POSITION & SIZE *//

var table_position = dashboard_position == 'Top right' ? position.top_right : dashboard_position == 'Top left' ? position.top_left : dashboard_position == 'Top center' ? position.top_center : dashboard_position == 'Bottom right' ? position.bottom_right : dashboard_position == 'Bottom left' ? position.bottom_left : dashboard_position == 'Bottom center' ? position.bottom_center : dashboard_position == 'Middle right' ? position.middle_right : position.middle_right

var table_text_size = text_size == 'Normal' ? size.normal : text_size == 'Large' ? size.large : text_size == 'Tiny' ? size.tiny : text_size == 'Small' ? size.small : size.normal

var t = table.new(position = table_position, columns = 4, rows = 21, frame_color = table_color, frame_width = 2, border_color = table_color, border_width = 2)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//* CALCULATION FUNCTIONS *//

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

// ADX classic (Welles Wilder 1978)
calc_adx(len) =>
    up = ta.change(high)
    down = -ta.change(low)
    plusDM = na(up) ? na : (up > down and up > 0 ? up : 0)
    minusDM = na(down) ? na : (down > up and down > 0 ? down : 0)
    trur = ta.rma(ta.tr, len)
    plus = fixnan(100 * ta.rma(plusDM, len) / trur)
    minus = fixnan(100 * ta.rma(minusDM, len) / trur)
    sum = plus + minus
    adx = 100 * ta.rma(math.abs(plus - minus) / (sum == 0 ? 1 : sum), len)
    adx

get_strength_indicator(adx_value) =>
    adx_value < adx_weak_threshold ? weak_trend_indicator : adx_value > adx_strong_threshold ? strong_trend_indicator : medium_trend_indicator

get_trend_status() =>
    impulse = catch_flat ? check_impulse() : true
    ema1_current_candle = ta.ema(close, ema1_length)
    ema1_previous_candle = ema1_current_candle[1]
    round_dec = ema1_current_candle > 1000 ? 0 : ema1_current_candle > 10 ? 1 : ema1_current_candle > 0 ? 2 : ema1_current_candle > 0.1 ? 3 : 10
    ema1_str = str.tostring(math.round(ema1_current_candle, round_dec))
    adx_value = calc_adx(adx_length)
    strength = get_strength_indicator(adx_value)
    
    var string trend_current_candle = na
    var string trend_previous_candle = na
    var color trend_bg_color = na
    
    if (active_approach == "Direction of a single EMA")
        ema1_previous_previous_candle = ema1_current_candle[2]
        trend_bg_color := not impulse ? neutraltrend_bg_color : ema1_current_candle > ema1_previous_candle ? uptrend_bg_color : ema1_current_candle < ema1_previous_candle ? downtrend_bg_color : neutraltrend_bg_color
        trend_current_candle := not impulse ? neutraltrend_indicator : ema1_current_candle > ema1_previous_candle ? uptrend_indicator : ema1_current_candle < ema1_previous_candle ? downtrend_indicator : neutraltrend_indicator
        trend_previous_candle := not impulse ? neutraltrend_indicator : ema1_previous_candle > ema1_previous_previous_candle ? uptrend_indicator : ema1_previous_candle < ema1_previous_previous_candle ? downtrend_indicator : neutraltrend_indicator
    else
        ema2_current_candle = ta.ema(close, ema2_length)
        ema2_previous_candle = ema2_current_candle[1]
        trend_bg_color := not impulse ? neutraltrend_bg_color : ema1_current_candle > ema2_current_candle ? uptrend_bg_color : ema1_current_candle < ema2_current_candle ? downtrend_bg_color : neutraltrend_bg_color
        trend_current_candle := not impulse ? neutraltrend_indicator : ema1_current_candle > ema2_current_candle ? uptrend_indicator : ema1_current_candle < ema2_current_candle ? downtrend_indicator : neutraltrend_indicator
        trend_previous_candle := not impulse ? neutraltrend_indicator : ema1_previous_candle > ema2_previous_candle ? uptrend_indicator : ema1_previous_candle < ema2_previous_candle ? downtrend_indicator : neutraltrend_indicator
    
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

// Preset label styling
preset_icon = is_scalp ? "🔵 Scalp GC/NQ" : is_swing ? "🟢 4H Swing" : "⚙️ Custom"
preset_bg = is_scalp ? color.rgb(33, 150, 243, 60) : is_swing ? color.rgb(76, 175, 80, 60) : color.rgb(158, 158, 158, 60)

if (barstate.islast)
    row_idx = 0
    
    // Preset label
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
barcolor_value = current_trend_indicator_current_timeframe == uptrend_indicator ? uptrend_colour : current_trend_indicator_current_timeframe == downtrend_indicator ? downtrend_colour : neutraltrend_colour
barcolor(color = barcolor_value, editable = false, display = paint_bars ? display.all : display.none)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//* ALERTS *//

alertcondition(current_trend_indicator_current_timeframe != previous_trend_indicator_current_timeframe, '0. Trend changed', '⏰ PigoFX - Trend changed on {{ticker}}:{{interval}}min')
alertcondition(current_trend_indicator_current_timeframe != previous_trend_indicator_current_timeframe and current_trend_indicator_current_timeframe == uptrend_indicator, '1. Uptrend started', '🟢 PigoFX - Uptrend started on {{ticker}}:{{interval}}min')
alertcondition(current_trend_indicator_current_timeframe != previous_trend_indicator_current_timeframe and current_trend_indicator_current_timeframe == downtrend_indicator, '2. Downtrend started', '🔴 PigoFX - Downtrend started on {{ticker}}:{{interval}}min')
alertcondition(current_trend_indicator_current_timeframe != previous_trend_indicator_current_timeframe and current_trend_indicator_current_timeframe == neutraltrend_indicator, '3. Neutral trend started', '⚫️ PigoFX - Neutral trend started on {{ticker}}:{{interval}}min')
alertcondition(trend_indicator_3D == trend_indicator_D and trend_indicator_D == trend_indicator_4h, '4. 3D, D, 4h aligned', 'PigoFX - 3D, D, 4h {{ticker}} trend alignment')
alertcondition(trend_indicator_D == trend_indicator_4h and trend_indicator_4h == trend_indicator_1h, '5. D, 4h, 1h aligned', 'PigoFX - D, 4h, 1h {{ticker}} trend alignment')
alertcondition(trend_indicator_4h == trend_indicator_1h and trend_indicator_1h == trend_indicator_15m, '6. 4h, 1h, 15m aligned', 'PigoFX - 4h, 1h, 15m {{ticker}} trend alignment')
alertcondition(trend_indicator_1h == trend_indicator_15m and trend_indicator_15m == trend_indicator_5m, '7. 1h, 15m, 5m aligned', 'PigoFX - 1h, 15m, 5m {{ticker}} trend alignment')
alertcondition(trend_indicator_15m == trend_indicator_5m and trend_indicator_5m == trend_indicator_3m, '8. 15m, 5m, 3m aligned', 'PigoFX - 15m, 5m, 3m {{ticker}} trend alignment')
alertcondition(trend_indicator_5m == trend_indicator_3m and trend_indicator_3m == trend_indicator_1m, '9. 5m, 3m, 1m aligned', 'PigoFX - 5m, 3m, 1m {{ticker}} trend alignment')
````
