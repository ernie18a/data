# PIGO TREND ATR 

- url: https://www.tradingview.com/script/URCX1tfg/
- type: indicator
- pine_id: PUB;c13529e2f5a542b7ac588b60431c9554
- version: 1.0

## Description

Cómo usar PIGO TREND ATR
La tabla te muestra 3 cosas por cada timeframe: tendencia (🟢/🔴/⚫️), fuerza (💪/👊/🤏) y ATR (el rango promedio de esa vela en puntos).

La lógica de entrada
Para comprar necesitas ver esto en tu tabla:

4H 🟢 + 1H 🟢 + 15M 🟢 → entrada válida en el 5M cuando gire verde

Para vender igual pero todo rojo hacia abajo.
Regla de oro: si 4H y 1H no coinciden, no hay trade.

Para qué sirve el ATR
El ATR de cada timeframe te dice cuánto mueve normalmente esa vela. Úsalo así:
Stop Loss → coloca el stop a 0.5x el ATR del timeframe de entrada. Si el ATR del 15M es 80 puntos, tu stop mínimo es 40 puntos.
Target → busca al menos 1x el ATR del 15M como objetivo mínimo. Si el ATR es 80, tu target mínimo son 80 puntos.
¿Vale la pena entrar? → Si el precio ya movió más del 80% del ATR del 5M, la vela está agotada. Espera la siguiente.

Los presets

🔵 Scalp GC/NQ → para tu operativa diaria en NQ y Gold, timeframes 5M-1H
🟢 4H Swing → para trades más largos con EMA 50/200
⚙️ Custom → tus propios valores de EMA y ADX

## Source Code

````pine
//@version=6
indicator("PIGO TREND ATR", shorttitle = "PigoTRATR", overlay = true, scale = scale.none, dynamic_requests = true)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* PRESET SELECTOR *//

preset = input.string("Scalping GC & NQ", title = "⚡ Preset", options = ["Scalping GC & NQ", "4H Swing", "Custom"], group = '🎯 PRESET SELECTOR')

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* BAR SETTINGS *//

paint_bars             = input(false, title = "Paint bars?", group = 'Bars Settings')
catch_flat_custom      = input(false, title = "Try to catch flat? (Custom only)", group = 'Bars Settings')
uptrend_colour         = input.color(color.green, title = "Uptrend colour",    group = 'Bars Settings')
downtrend_colour       = input.color(color.red,   title = "Downtrend colour",  group = 'Bars Settings')
neutraltrend_colour    = input.color(color.gray,  title = "Neutraltrend colour", group = 'Bars Settings')

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* TABLE SETTINGS *//

show_header            = input(false, title = "Show header?",              group = 'Table Settings')
show_ema_value         = input(false, title = "Show EMA value?",           group = 'Table Settings')
show_strength          = input(true,  title = "Show trend strength?",      group = 'Table Settings')
show_atr               = input(true,  title = "Show ATR?",                 group = 'Table Settings')
show_preset_label      = input(true,  title = "Show active preset label?", group = 'Table Settings')
dashboard_position     = input.session("Middle right", "Position", ["Top right", "Bottom right", "Top left", "Bottom left", "Top center", "Bottom center", "Middle right"], group = 'Table Settings')
text_size              = input.session('Small', "Size", options = ["Tiny", "Small", "Normal", "Large"], group = 'Table Settings')
text_color             = input.color(color.white, title = "Text colour",   group = 'Table Settings')
table_color            = input.color(color.gray,  title = "Border colour", group = 'Table Settings')

uptrend_indicator      = input("🟢",  title = "Uptrend indicator",      group = 'Table Settings')
downtrend_indicator    = input("🔴",  title = "Downtrend indicator",    group = 'Table Settings')
neutraltrend_indicator = input("⚫️", title = "Neutraltrend indicator", group = 'Table Settings')

strong_trend_indicator = input("💪", title = "Strong trend indicator", group = 'Table Settings')
medium_trend_indicator = input("👊", title = "Medium trend indicator", group = 'Table Settings')
weak_trend_indicator   = input("🤏", title = "Weak trend indicator",   group = 'Table Settings')

header_bg_color        = input.color(color.rgb(128, 128, 128, 75), title = "Header background colour",       group = 'Table Settings')
uptrend_bg_color       = input.color(color.rgb(76,  175, 80,  75), title = "Uptrend background colour",      group = 'Table Settings')
downtrend_bg_color     = input(color.rgb(255, 82,  82,  75),       title = "Downtrend background colour",    group = 'Table Settings')
neutraltrend_bg_color  = input(color.rgb(120, 123, 134, 75),       title = "Neutraltrend background colour", group = 'Table Settings')

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* ATR SETTINGS *//

atr_length = input.int(14, "ATR Length", minval = 1, group = 'ATR Settings')
atr_color  = input.color(color.yellow,  title = "ATR text colour", group = 'ATR Settings')

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* CUSTOM EMA SETTINGS *//

trend_identification_approach = input.session("Direction of a single EMA", "Trend identification approach (Custom only)", ["Direction of a single EMA", "Comparison of the two EMAs"], group = '📈 Custom EMA Settings')
ema1_length_custom = input.int(50,  title = "EMA length (Custom only)",            minval = 1, maxval = 800, group = '📈 Custom EMA Settings')
ema2_length_custom = input.int(200, title = "Additional EMA length (Custom only)", minval = 1, maxval = 800, group = '📈 Custom EMA Settings')

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* CUSTOM ADX SETTINGS *//

adx_length_custom           = input.int(14, title = "ADX length (Custom only)",           minval = 1, maxval = 100, group = '💪 Custom ADX Settings')
adx_weak_threshold_custom   = input.int(20, title = "ADX weak threshold (Custom only)",   minval = 1, maxval = 100, group = '💪 Custom ADX Settings')
adx_strong_threshold_custom = input.int(40, title = "ADX strong threshold (Custom only)", minval = 1, maxval = 100, group = '💪 Custom ADX Settings')

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* PRESET RESOLUTION *//

is_scalp = preset == "Scalping GC & NQ"
is_swing = preset == "4H Swing"

catch_flat           = is_scalp ? false                        : is_swing ? true                         : catch_flat_custom
ema1_length          = is_scalp ? 21                           : is_swing ? 50                           : ema1_length_custom
ema2_length          = is_scalp ? 50                           : is_swing ? 200                          : ema2_length_custom
active_approach      = is_scalp ? "Direction of a single EMA" : is_swing ? "Comparison of the two EMAs" : trend_identification_approach
adx_length           = is_scalp ? 9                            : is_swing ? 14                           : adx_length_custom
adx_weak_threshold   = is_scalp ? 17                           : is_swing ? 20                           : adx_weak_threshold_custom
adx_strong_threshold = is_scalp ? 32                           : is_swing ? 40                           : adx_strong_threshold_custom

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* TIMEFRAME SETTINGS *//

show_1m  = input(true,  title = 'Show 1m',  group = 'Timeframe Settings')
show_2m  = input(false, title = 'Show 2m',  group = 'Timeframe Settings')
show_3m  = input(false, title = 'Show 3m',  group = 'Timeframe Settings')
show_5m  = input(true,  title = 'Show 5m',  group = 'Timeframe Settings')
show_10m = input(false, title = 'Show 10m', group = 'Timeframe Settings')
show_15m = input(true,  title = 'Show 15m', group = 'Timeframe Settings')
show_30m = input(false, title = 'Show 30m', group = 'Timeframe Settings')
show_45m = input(false, title = 'Show 45m', group = 'Timeframe Settings')
show_1h  = input(true,  title = 'Show 1h',  group = 'Timeframe Settings')
show_2h  = input(false, title = 'Show 2h',  group = 'Timeframe Settings')
show_3h  = input(false, title = 'Show 3h',  group = 'Timeframe Settings')
show_4h  = input(true,  title = 'Show 4h',  group = 'Timeframe Settings')
show_6h  = input(false, title = 'Show 6h',  group = 'Timeframe Settings')
show_8h  = input(false, title = 'Show 8h',  group = 'Timeframe Settings')
show_12h = input(false, title = 'Show 12h', group = 'Timeframe Settings')
show_D   = input(true,  title = 'Show D',   group = 'Timeframe Settings')
show_3D  = input(false, title = 'Show 3D',  group = 'Timeframe Settings')
show_W   = input(false, title = 'Show W',   group = 'Timeframe Settings')
show_M   = input(false, title = 'Show M',   group = 'Timeframe Settings')

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* TABLE POSITION & SIZE *//

var table_position =
     dashboard_position == 'Top right'      ? position.top_right     :
     dashboard_position == 'Top left'       ? position.top_left      :
     dashboard_position == 'Top center'     ? position.top_center    :
     dashboard_position == 'Bottom right'   ? position.bottom_right  :
     dashboard_position == 'Bottom left'    ? position.bottom_left   :
     dashboard_position == 'Bottom center'  ? position.bottom_center :
     position.middle_right

var table_text_size =
     text_size == 'Normal' ? size.normal :
     text_size == 'Large'  ? size.large  :
     text_size == 'Tiny'   ? size.tiny   :
     size.small

var t = table.new(position = table_position, columns = 5, rows = 21, frame_color = table_color, frame_width = 2, border_color = table_color, border_width = 2)

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
    ema1 + (ema1 - ema2)

check_impulse() =>
    impulse_length   = 34
    impulse_strength = 9
    hi      = calc_smma(high,  impulse_length)
    lo      = calc_smma(low,   impulse_length)
    mi      = calc_zlema(hlc3, impulse_length)
    md      = mi > hi ? mi - hi : mi < lo ? mi - lo : 0.0
    md_prev = mi[1] > hi[1] ? mi[1] - hi[1] : mi[1] < lo[1] ? mi[1] - lo[1] : 0.0
    sb      = ta.sma(md,      impulse_strength)
    sb_prev = ta.sma(md_prev, impulse_strength)
    (md - sb) != 0 and (md_prev - sb_prev) != 0

calc_adx(len) =>
    up      = ta.change(high)
    down    = -ta.change(low)
    plusDM  = na(up)   ? na : up   > down and up   > 0 ? up   : 0.0
    minusDM = na(down) ? na : down > up   and down > 0 ? down : 0.0
    trur    = ta.rma(ta.tr, len)
    plus    = fixnan(100 * ta.rma(plusDM,  len) / trur)
    minus   = fixnan(100 * ta.rma(minusDM, len) / trur)
    sum     = plus + minus
    100 * ta.rma(math.abs(plus - minus) / (sum == 0 ? 1 : sum), len)

get_strength_indicator(adx_value) =>
    adx_value < adx_weak_threshold ? weak_trend_indicator : adx_value > adx_strong_threshold ? strong_trend_indicator : medium_trend_indicator

get_trend_status() =>
    impulse              = catch_flat ? check_impulse() : true
    ema1_cur             = ta.ema(close, ema1_length)
    ema1_prev            = ema1_cur[1]
    ema1_prev2           = ema1_cur[2]
    round_dec            = ema1_cur > 1000 ? 0 : ema1_cur > 10 ? 1 : ema1_cur > 0 ? 2 : ema1_cur > 0.1 ? 3 : 10
    ema1_str             = str.tostring(math.round(ema1_cur, round_dec))
    strength             = get_strength_indicator(calc_adx(adx_length))

    var string trend_cur  = na
    var string trend_prev = na
    var color  trend_bg   = na

    if active_approach == "Direction of a single EMA"
        trend_bg   := not impulse ? neutraltrend_bg_color : ema1_cur  > ema1_prev  ? uptrend_bg_color  : ema1_cur  < ema1_prev  ? downtrend_bg_color  : neutraltrend_bg_color
        trend_cur  := not impulse ? neutraltrend_indicator : ema1_cur  > ema1_prev  ? uptrend_indicator  : ema1_cur  < ema1_prev  ? downtrend_indicator  : neutraltrend_indicator
        trend_prev := not impulse ? neutraltrend_indicator : ema1_prev > ema1_prev2 ? uptrend_indicator  : ema1_prev < ema1_prev2 ? downtrend_indicator  : neutraltrend_indicator
    else
        ema2_cur  = ta.ema(close, ema2_length)
        ema2_prev = ema2_cur[1]
        trend_bg   := not impulse ? neutraltrend_bg_color : ema1_cur  > ema2_cur  ? uptrend_bg_color  : ema1_cur  < ema2_cur  ? downtrend_bg_color  : neutraltrend_bg_color
        trend_cur  := not impulse ? neutraltrend_indicator : ema1_cur  > ema2_cur  ? uptrend_indicator  : ema1_cur  < ema2_cur  ? downtrend_indicator  : neutraltrend_indicator
        trend_prev := not impulse ? neutraltrend_indicator : ema1_prev > ema2_prev ? uptrend_indicator  : ema1_prev < ema2_prev ? downtrend_indicator  : neutraltrend_indicator

    [ema1_str, trend_bg, trend_cur, trend_prev, strength]

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* ATR FUNCTIONS *//

get_atr(tf) =>
    request.security(syminfo.tickerid, tf, ta.atr(atr_length))

format_atr(val) =>
    if na(val)
        "—"
    else
        decimals = syminfo.mintick >= 1 ? 0 : syminfo.mintick >= 0.1 ? 1 : syminfo.mintick >= 0.01 ? 2 : 3
        str.tostring(math.round(val, decimals))

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* MTF DATA REQUESTS — if/else para evitar error CE10163 *//

[ema_1m,  bg_1m,  ind_1m,  _, str_1m] = if show_1m
    request.security(syminfo.tickerid, "1", get_trend_status())
else
    [na, na, na, na, na]

[ema_2m,  bg_2m,  ind_2m,  _, str_2m] = if show_2m
    request.security(syminfo.tickerid, "2", get_trend_status())
else
    [na, na, na, na, na]

[ema_3m,  bg_3m,  ind_3m,  _, str_3m] = if show_3m
    request.security(syminfo.tickerid, "3", get_trend_status())
else
    [na, na, na, na, na]

[ema_5m,  bg_5m,  ind_5m,  _, str_5m] = if show_5m
    request.security(syminfo.tickerid, "5", get_trend_status())
else
    [na, na, na, na, na]

[ema_10m, bg_10m, ind_10m, _, str_10m] = if show_10m
    request.security(syminfo.tickerid, "10", get_trend_status())
else
    [na, na, na, na, na]

[ema_15m, bg_15m, ind_15m, _, str_15m] = if show_15m
    request.security(syminfo.tickerid, "15", get_trend_status())
else
    [na, na, na, na, na]

[ema_30m, bg_30m, ind_30m, _, str_30m] = if show_30m
    request.security(syminfo.tickerid, "30", get_trend_status())
else
    [na, na, na, na, na]

[ema_45m, bg_45m, ind_45m, _, str_45m] = if show_45m
    request.security(syminfo.tickerid, "45", get_trend_status())
else
    [na, na, na, na, na]

[ema_1h,  bg_1h,  ind_1h,  _, str_1h] = if show_1h
    request.security(syminfo.tickerid, "60", get_trend_status())
else
    [na, na, na, na, na]

[ema_2h,  bg_2h,  ind_2h,  _, str_2h] = if show_2h
    request.security(syminfo.tickerid, "120", get_trend_status())
else
    [na, na, na, na, na]

[ema_3h,  bg_3h,  ind_3h,  _, str_3h] = if show_3h
    request.security(syminfo.tickerid, "180", get_trend_status())
else
    [na, na, na, na, na]

[ema_4h,  bg_4h,  ind_4h,  _, str_4h] = if show_4h
    request.security(syminfo.tickerid, "240", get_trend_status())
else
    [na, na, na, na, na]

[ema_6h,  bg_6h,  ind_6h,  _, str_6h] = if show_6h
    request.security(syminfo.tickerid, "360", get_trend_status())
else
    [na, na, na, na, na]

[ema_8h,  bg_8h,  ind_8h,  _, str_8h] = if show_8h
    request.security(syminfo.tickerid, "480", get_trend_status())
else
    [na, na, na, na, na]

[ema_12h, bg_12h, ind_12h, _, str_12h] = if show_12h
    request.security(syminfo.tickerid, "720", get_trend_status())
else
    [na, na, na, na, na]

[ema_D,   bg_D,   ind_D,   _, str_D] = if show_D
    request.security(syminfo.tickerid, "D", get_trend_status())
else
    [na, na, na, na, na]

[ema_3D,  bg_3D,  ind_3D,  _, str_3D] = if show_3D
    request.security(syminfo.tickerid, "3D", get_trend_status())
else
    [na, na, na, na, na]

[ema_W,   bg_W,   ind_W,   _, str_W] = if show_W
    request.security(syminfo.tickerid, "W", get_trend_status())
else
    [na, na, na, na, na]

[ema_M,   bg_M,   ind_M,   _, str_M] = if show_M
    request.security(syminfo.tickerid, "M", get_trend_status())
else
    [na, na, na, na, na]

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* ATR REQUESTS *//

atr_1m  = show_1m  ? get_atr("1")   : na
atr_2m  = show_2m  ? get_atr("2")   : na
atr_3m  = show_3m  ? get_atr("3")   : na
atr_5m  = show_5m  ? get_atr("5")   : na
atr_10m = show_10m ? get_atr("10")  : na
atr_15m = show_15m ? get_atr("15")  : na
atr_30m = show_30m ? get_atr("30")  : na
atr_45m = show_45m ? get_atr("45")  : na
atr_1h  = show_1h  ? get_atr("60")  : na
atr_2h  = show_2h  ? get_atr("120") : na
atr_3h  = show_3h  ? get_atr("180") : na
atr_4h  = show_4h  ? get_atr("240") : na
atr_6h  = show_6h  ? get_atr("360") : na
atr_8h  = show_8h  ? get_atr("480") : na
atr_12h = show_12h ? get_atr("720") : na
atr_D   = show_D   ? get_atr("D")   : na
atr_3D  = show_3D  ? get_atr("3D")  : na
atr_W   = show_W   ? get_atr("W")   : na
atr_M   = show_M   ? get_atr("M")   : na

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* TABLE DRAWING *//

f_draw_row(row, tf_label, trend_ind, strength_ind, ema_val, atr_val, bg) =>
    col = 0
    table.cell(t, col, row, tf_label,  text_color = text_color, text_size = table_text_size, bgcolor = bg)
    col += 1
    table.cell(t, col, row, trend_ind, text_color = text_color, text_size = table_text_size, bgcolor = bg)
    col += 1
    if show_strength
        table.cell(t, col, row, strength_ind, text_color = text_color, text_size = table_text_size, bgcolor = bg)
        col += 1
    if show_atr
        table.cell(t, col, row, atr_val, text_color = atr_color, text_size = table_text_size, bgcolor = bg)
        col += 1
    if show_ema_value
        table.cell(t, col, row, ema_val, text_color = text_color, text_size = table_text_size, bgcolor = bg)

preset_icon = is_scalp ? "🔵 Scalp GC/NQ" : is_swing ? "🟢 4H Swing" : "⚙️ Custom"
preset_bg   = is_scalp ? color.rgb(33, 150, 243, 60) : is_swing ? color.rgb(76, 175, 80, 60) : color.rgb(158, 158, 158, 60)

if barstate.islast
    row_idx = 0

    if show_preset_label
        table.cell(t, 0, row_idx, preset_icon, text_color = text_color, text_size = table_text_size, bgcolor = preset_bg)
        table.cell(t, 1, row_idx, "", bgcolor = preset_bg)
        col = 2
        if show_strength
            table.cell(t, col, row_idx, "", bgcolor = preset_bg)
            col += 1
        if show_atr
            table.cell(t, col, row_idx, "", bgcolor = preset_bg)
            col += 1
        if show_ema_value
            table.cell(t, col, row_idx, "", bgcolor = preset_bg)
        row_idx += 1

    if show_header
        table.cell(t, 0, row_idx, "TF",    text_color = text_color, text_size = table_text_size, bgcolor = header_bg_color)
        table.cell(t, 1, row_idx, "Trend", text_color = text_color, text_size = table_text_size, bgcolor = header_bg_color)
        col = 2
        if show_strength
            table.cell(t, col, row_idx, "Force", text_color = text_color, text_size = table_text_size, bgcolor = header_bg_color)
            col += 1
        if show_atr
            table.cell(t, col, row_idx, "ATR", text_color = atr_color, text_size = table_text_size, bgcolor = header_bg_color)
            col += 1
        if show_ema_value
            table.cell(t, col, row_idx, str.tostring(ema1_length) + " EMA", text_color = text_color, text_size = table_text_size, bgcolor = header_bg_color)
        row_idx += 1

    if show_1m
        f_draw_row(row_idx, "1m",  ind_1m,  str_1m,  ema_1m,  format_atr(atr_1m),  bg_1m)
        row_idx += 1
    if show_2m
        f_draw_row(row_idx, "2m",  ind_2m,  str_2m,  ema_2m,  format_atr(atr_2m),  bg_2m)
        row_idx += 1
    if show_3m
        f_draw_row(row_idx, "3m",  ind_3m,  str_3m,  ema_3m,  format_atr(atr_3m),  bg_3m)
        row_idx += 1
    if show_5m
        f_draw_row(row_idx, "5m",  ind_5m,  str_5m,  ema_5m,  format_atr(atr_5m),  bg_5m)
        row_idx += 1
    if show_10m
        f_draw_row(row_idx, "10m", ind_10m, str_10m, ema_10m, format_atr(atr_10m), bg_10m)
        row_idx += 1
    if show_15m
        f_draw_row(row_idx, "15m", ind_15m, str_15m, ema_15m, format_atr(atr_15m), bg_15m)
        row_idx += 1
    if show_30m
        f_draw_row(row_idx, "30m", ind_30m, str_30m, ema_30m, format_atr(atr_30m), bg_30m)
        row_idx += 1
    if show_45m
        f_draw_row(row_idx, "45m", ind_45m, str_45m, ema_45m, format_atr(atr_45m), bg_45m)
        row_idx += 1
    if show_1h
        f_draw_row(row_idx, "1h",  ind_1h,  str_1h,  ema_1h,  format_atr(atr_1h),  bg_1h)
        row_idx += 1
    if show_2h
        f_draw_row(row_idx, "2h",  ind_2h,  str_2h,  ema_2h,  format_atr(atr_2h),  bg_2h)
        row_idx += 1
    if show_3h
        f_draw_row(row_idx, "3h",  ind_3h,  str_3h,  ema_3h,  format_atr(atr_3h),  bg_3h)
        row_idx += 1
    if show_4h
        f_draw_row(row_idx, "4h",  ind_4h,  str_4h,  ema_4h,  format_atr(atr_4h),  bg_4h)
        row_idx += 1
    if show_6h
        f_draw_row(row_idx, "6h",  ind_6h,  str_6h,  ema_6h,  format_atr(atr_6h),  bg_6h)
        row_idx += 1
    if show_8h
        f_draw_row(row_idx, "8h",  ind_8h,  str_8h,  ema_8h,  format_atr(atr_8h),  bg_8h)
        row_idx += 1
    if show_12h
        f_draw_row(row_idx, "12h", ind_12h, str_12h, ema_12h, format_atr(atr_12h), bg_12h)
        row_idx += 1
    if show_D
        f_draw_row(row_idx, "D",   ind_D,   str_D,   ema_D,   format_atr(atr_D),   bg_D)
        row_idx += 1
    if show_3D
        f_draw_row(row_idx, "3D",  ind_3D,  str_3D,  ema_3D,  format_atr(atr_3D),  bg_3D)
        row_idx += 1
    if show_W
        f_draw_row(row_idx, "W",   ind_W,   str_W,   ema_W,   format_atr(atr_W),   bg_W)
        row_idx += 1
    if show_M
        f_draw_row(row_idx, "M",   ind_M,   str_M,   ema_M,   format_atr(atr_M),   bg_M)
        row_idx += 1

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* BARS *//

[_, _, cur_trend, prev_trend, _] = get_trend_status()
barcolor_value = cur_trend == uptrend_indicator ? uptrend_colour : cur_trend == downtrend_indicator ? downtrend_colour : neutraltrend_colour
barcolor(color = barcolor_value, editable = false, display = paint_bars ? display.all : display.none)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* ALERTS *//

alertcondition(cur_trend != prev_trend, '0. Trend changed', '⏰ PigoFX - Trend changed on {{ticker}}:{{interval}}min')
alertcondition(cur_trend != prev_trend and cur_trend == uptrend_indicator,      '1. Uptrend started',   '🟢 PigoFX - Uptrend started on {{ticker}}:{{interval}}min')
alertcondition(cur_trend != prev_trend and cur_trend == downtrend_indicator,    '2. Downtrend started', '🔴 PigoFX - Downtrend started on {{ticker}}:{{interval}}min')
alertcondition(cur_trend != prev_trend and cur_trend == neutraltrend_indicator, '3. Neutral started',   '⚫️ PigoFX - Neutral trend started on {{ticker}}:{{interval}}min')
alertcondition(ind_3D == ind_D   and ind_D  == ind_4h,  '4. 3D, D, 4h aligned',   'PigoFX - 3D, D, 4h {{ticker}} trend alignment')
alertcondition(ind_D  == ind_4h  and ind_4h == ind_1h,  '5. D, 4h, 1h aligned',   'PigoFX - D, 4h, 1h {{ticker}} trend alignment')
alertcondition(ind_4h == ind_1h  and ind_1h == ind_15m, '6. 4h, 1h, 15m aligned', 'PigoFX - 4h, 1h, 15m {{ticker}} trend alignment')
alertcondition(ind_1h == ind_15m and ind_15m == ind_5m, '7. 1h, 15m, 5m aligned', 'PigoFX - 1h, 15m, 5m {{ticker}} trend alignment')
alertcondition(ind_15m == ind_5m and ind_5m == ind_3m,  '8. 15m, 5m, 3m aligned', 'PigoFX - 15m, 5m, 3m {{ticker}} trend alignment')
alertcondition(ind_5m == ind_3m  and ind_3m == ind_1m,  '9. 5m, 3m, 1m aligned',  'PigoFX - 5m, 3m, 1m {{ticker}} trend alignment')
````
