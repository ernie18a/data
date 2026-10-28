# MNQ Scanner Wilber v4

- url: https://www.tradingview.com/script/HxvLZuot/
- type: indicator
- pine_id: PUB;4d1723a65b854e12a67f6c446324c9a5
- version: 1.0

## Description

Escáner de confluencias para trading intradía de MNQ (Micro Nasdaq) basado en una secuencia top-down de tres temporalidades. No es un sistema automático: es una herramienta de lectura que te dice, de un vistazo, si las condiciones de tu plan están alineadas antes de operar. Diseñado para usarse en gráfico de 1 minuto.
Cómo funciona la lógica
El indicador valida tu setup en orden, de mayor a menor temporalidad:

Sesgo (EMA 200 en 1H): define la dirección permitida. Precio por encima = solo largos; por debajo = solo cortos. Nunca opera contra la tendencia mayor.
Estructura y pullback (EMA 21 en 15min): busca un retroceso a la EMA 21 con rechazo — el precio toca o cruza la EMA y vuelve a cerrar a su favor, confirmando continuación.
Momentum (EMA 10 + VWAP en 1min): dispara la señal solo cuando la vela anterior cerró como vela de momentum válida (cuerpo dominante, cierre en el extremo, a favor de EMA 10 y VWAP). La entrada es en la apertura de la vela siguiente — nunca persigue el precio dentro de la vela.

El VWAP actúa como filtro institucional: si contradice el sesgo de la EMA 200, marca "CONFLICTO" y bloquea la señal (no operar).
Lo que ves en pantalla

EMA 10, EMA 21 y EMA 200 (cada una visible según el timeframe configurado).
Línea VWAP del día.
Niveles de máximo y mínimo recientes (rango móvil) dibujados con etiquetas H/L.
Una tabla arriba a la derecha que muestra, fila por fila: sesión activa, sesgo 1H, estado del VWAP, valor del VWAP, rechazo en EMA 21, confirmación de momentum y la señal final (SETUP). Cada fila cambia de color según se cumpla o no, para que sepas exactamente qué condición falta.

Señales

LONG / SHORT (verde/rojo sólido): las cuatro condiciones alineadas — setup completo.
LONG? / SHORT? (naranja): 3 de 4 condiciones — solo aviso, todavía no es entrada.
ESPERA: sin confluencia suficiente.

Sesiones
El escáner solo activa señales dentro de las ventanas horarias definidas (NY, London y Post-NY, en hora del Este), evitando los periodos de baja calidad fuera de ellas.
Alertas incluidas
Setup LONG/SHORT completo, contexto parcial (3+ condiciones), conflicto de VWAP y zona de acumulación cerca de la EMA 21. Configúralas como "Once per bar close" para evitar avisos que luego se invaliden.
@wilberrgarcia

## Source Code

````pine
//@version=6
indicator('MNQ Scanner — Wilber v4', overlay = true, max_bars_back = 500, max_lines_count = 10, max_labels_count = 10)

// ══════════════════════════════════════════════════════════════════════════════
//  INPUTS
// ══════════════════════════════════════════════════════════════════════════════
body_pct      = input.float(0.70, '% cuerpo minimo',        minval = 0.40, maxval = 0.90, step = 0.05, group = 'Filtros')
body_min_pts  = input.float(10.0, 'Cuerpo minimo (puntos)', minval = 1.0,  maxval = 30.0, step = 0.5,  group = 'Filtros')
accum_range   = input.float(8.0,  'Acumulacion rango max',  minval = 3.0,  maxval = 20.0, step = 0.5,  group = 'Filtros')
accum_ema_dist= input.float(15.0, 'Acumulacion dist EMA21', minval = 5.0,  maxval = 40.0, step = 1.0,  group = 'Filtros')
show_vwap     = input.bool(true,  'Mostrar linea VWAP',                                                group = 'Filtros')
hl_lookback   = input.int(80, 'H/L lookback (velas)', minval = 10, maxval = 200, step = 5,            group = 'Estructura')

ema1_len   = input.int(10,  'EMA 1 periodos', group = 'EMA 1')
ema1_desde = input.string('0 min',  'Desde', options = ['0 min','1 min','5 min','15 min','1h','4h','Dia','Semana','Mes'], group = 'EMA 1')
ema1_hasta = input.string('15 min', 'Hasta', options = ['1 min','5 min','15 min','1h','4h','Dia','Semana','Mes','Siempre'], group = 'EMA 1')
ema2_len   = input.int(21,  'EMA 2 periodos', group = 'EMA 2')
ema2_desde = input.string('15 min', 'Desde', options = ['0 min','1 min','5 min','15 min','1h','4h','Dia','Semana','Mes'], group = 'EMA 2')
ema2_hasta = input.string('1h',     'Hasta', options = ['1 min','5 min','15 min','1h','4h','Dia','Semana','Mes','Siempre'], group = 'EMA 2')
ema3_len   = input.int(200, 'EMA 3 periodos', group = 'EMA 3')
ema3_desde = input.string('1h',      'Desde', options = ['0 min','1 min','5 min','15 min','1h','4h','Dia','Semana','Mes'], group = 'EMA 3')
ema3_hasta = input.string('Siempre', 'Hasta', options = ['1 min','5 min','15 min','1h','4h','Dia','Semana','Mes','Siempre'], group = 'EMA 3')

// ══════════════════════════════════════════════════════════════════════════════
//  VWAP
// ══════════════════════════════════════════════════════════════════════════════
vwap_val = ta.vwap

// ══════════════════════════════════════════════════════════════════════════════
//  LOGICA DE TIEMPO
// ══════════════════════════════════════════════════════════════════════════════
actual_mins = timeframe.isseconds ? timeframe.multiplier / 60.0 :
              timeframe.isminutes ? timeframe.multiplier * 1.0 :
              timeframe.isdaily   ? timeframe.multiplier * 1440.0 :
              timeframe.isweekly  ? timeframe.multiplier * 10080.0 :
              timeframe.ismonthly ? timeframe.multiplier * 43200.0 : 0.0

get_desde(c) =>
    switch c
        '0 min'  => 0.0
        '1 min'  => 1.0
        '5 min'  => 5.0
        '15 min' => 15.0
        '1h'     => 60.0
        '4h'     => 240.0
        'Dia'    => 1440.0
        'Semana' => 10080.0
        'Mes'    => 43200.0
        => 0.0

get_hasta(c) =>
    switch c
        '1 min'   => 1.0
        '5 min'   => 5.0
        '15 min'  => 15.0
        '1h'      => 60.0
        '4h'      => 240.0
        'Dia'     => 1440.0
        'Semana'  => 10080.0
        'Mes'     => 43200.0
        'Siempre' => 999999.0
        => 999999.0

// ══════════════════════════════════════════════════════════════════════════════
//  SESIONES ET  (sin cambios)
// ══════════════════════════════════════════════════════════════════════════════
ny_hour   = hour(time,   'America/New_York')
ny_minute = minute(time, 'America/New_York')
ny_time   = ny_hour * 100 + ny_minute

session_post   = ny_time >= 1800 and ny_time < 2000
session_london = ny_time >= 300  and ny_time < 800
session_ny     = ny_time >= 930  and ny_time < 1130
in_window      = session_post or session_london or session_ny

session_name = session_ny ? 'NY' : session_london ? 'LONDON' : session_post ? 'POST-NY' : 'CERRADA'
session_col  = session_ny ? color.green : session_london ? color.aqua : session_post ? color.orange : color.red

// ══════════════════════════════════════════════════════════════════════════════
//  EMAs VISIBLES
// ══════════════════════════════════════════════════════════════════════════════
v1 = ta.ema(close, ema1_len)
v2 = ta.ema(close, ema2_len)
v3 = ta.ema(close, ema3_len)

show1 = actual_mins >= get_desde(ema1_desde) and actual_mins <= get_hasta(ema1_hasta)
show2 = actual_mins >= get_desde(ema2_desde) and actual_mins <= get_hasta(ema2_hasta)
show3 = actual_mins >= get_desde(ema3_desde) and actual_mins <= get_hasta(ema3_hasta)

// ══════════════════════════════════════════════════════════════════════════════
//  INDICADORES
// ══════════════════════════════════════════════════════════════════════════════
ema10     = ta.ema(close, 10)
ema21_15  = request.security(syminfo.tickerid, '15', ta.ema(close, 21),  lookahead = barmerge.lookahead_off)
close_15  = request.security(syminfo.tickerid, '15', close,              lookahead = barmerge.lookahead_off)
ema200_1h = request.security(syminfo.tickerid, '60', ta.ema(close, 200), lookahead = barmerge.lookahead_off)

// ══════════════════════════════════════════════════════════════════════════════
//  HIGH / LOW  (rango movil de hl_lookback velas)
// ══════════════════════════════════════════════════════════════════════════════
session_high = ta.highest(high, hl_lookback)
session_low  = ta.lowest(low,  hl_lookback)

var line  lineH = na
var line  lineL = na
var label lblH  = na
var label lblL  = na

if barstate.islast or barstate.isrealtime
    line.delete(lineH)
    label.delete(lblH)
    line.delete(lineL)
    label.delete(lblL)
    lineH := line.new(bar_index - 3, session_high, bar_index + 4, session_high, color = color.new(color.red,  0), width = 1, style = line.style_dashed)
    lblH  := label.new(bar_index + 4, session_high, 'H ' + str.tostring(math.round(session_high, 0)), color = color.new(color.red,  80), textcolor = color.red,  style = label.style_label_left, size = size.tiny)
    lineL := line.new(bar_index - 3, session_low,  bar_index + 4, session_low,  color = color.new(color.teal, 0), width = 1, style = line.style_dashed)
    lblL  := label.new(bar_index + 4, session_low,  'L ' + str.tostring(math.round(session_low,  0)), color = color.new(color.teal, 80), textcolor = color.teal, style = label.style_label_left, size = size.tiny)

// ══════════════════════════════════════════════════════════════════════════════
//  CONDICIONES
// ══════════════════════════════════════════════════════════════════════════════
bias_long  = close > ema200_1h
bias_short = close < ema200_1h
vwap_bull  = close > vwap_val
vwap_bear  = close < vwap_val
vwap_conflict = (bias_long and vwap_bear) or (bias_short and vwap_bull)

low_15_prev   = request.security(syminfo.tickerid, '15', low[1],               lookahead = barmerge.lookahead_off)
high_15_prev  = request.security(syminfo.tickerid, '15', high[1],              lookahead = barmerge.lookahead_off)
close_15_prev = request.security(syminfo.tickerid, '15', close[1],             lookahead = barmerge.lookahead_off)
ema21_15_prev = request.security(syminfo.tickerid, '15', ta.ema(close, 21)[1], lookahead = barmerge.lookahead_off)

pullback_long_15  = low_15_prev  <= ema21_15_prev and close_15_prev > ema21_15_prev and close_15 > ema21_15 and close_15 > close_15_prev
pullback_short_15 = high_15_prev >= ema21_15_prev and close_15_prev < ema21_15_prev and close_15 < ema21_15 and close_15 < close_15_prev

prev_body       = math.abs(close[1] - open[1])
prev_range      = high[1] - low[1]
prev_body_ratio = prev_range > 0 ? prev_body / prev_range : 0.0
close_top75     = prev_range > 0 ? close[1] >= low[1]  + prev_range * 0.75 : false
close_bot75     = prev_range > 0 ? close[1] <= high[1] - prev_range * 0.75 : false

mom_long  = close[1] > open[1] and prev_body_ratio >= body_pct and prev_body >= body_min_pts and close_top75 and close[1] > ema10[1] and close[1] > vwap_val[1]
mom_short = close[1] < open[1] and prev_body_ratio >= body_pct and prev_body >= body_min_pts and close_bot75 and close[1] < ema10[1] and close[1] < vwap_val[1]

// ══════════════════════════════════════════════════════════════════════════════
//  ACUMULACION  (distancia medida contra la EMA21 de 15min, no la del chart)
// ══════════════════════════════════════════════════════════════════════════════
small_candle = (high - low) < accum_range
near_ema21   = math.abs(close - ema21_15) < accum_ema_dist
accum_zone   = small_candle and small_candle[1] and small_candle[2] and near_ema21 and in_window and not vwap_conflict

// ══════════════════════════════════════════════════════════════════════════════
//  SETUP FINAL
// ══════════════════════════════════════════════════════════════════════════════
long_context  = bias_long  and vwap_bull and pullback_long_15  and not vwap_conflict and in_window
short_context = bias_short and vwap_bear and pullback_short_15 and not vwap_conflict and in_window

long_setup  = long_context  and mom_long
short_setup = short_context and mom_short

score_long  = (bias_long  ? 1 : 0) + (vwap_bull ? 1 : 0) + (pullback_long_15  ? 1 : 0) + (mom_long  ? 1 : 0)
score_short = (bias_short ? 1 : 0) + (vwap_bear ? 1 : 0) + (pullback_short_15 ? 1 : 0) + (mom_short ? 1 : 0)

long_alert  = not long_setup  and score_long  >= 3 and in_window and bias_long  and not vwap_conflict
short_alert = not short_setup and score_short >= 3 and in_window and bias_short and not vwap_conflict

all_long  = long_setup
all_short = short_setup

// ══════════════════════════════════════════════════════════════════════════════
//  PLOTS
// ══════════════════════════════════════════════════════════════════════════════
plot(show1 ? v1 : na, title = 'EMA 10',  color = color.white,  linewidth = 2)
plot(show2 ? v2 : na, title = 'EMA 21',  color = color.aqua,   linewidth = 2)
plot(show3 ? v3 : na, title = 'EMA 200', color = color.yellow, linewidth = 2)

// VWAP visible desde 1min en adelante (solo se oculta en charts de segundos)
vwap_visible = actual_mins >= 1.0
plot(show_vwap and vwap_visible ? vwap_val : na, title = 'VWAP', color = color.purple, linewidth = 2)

// ══════════════════════════════════════════════════════════════════════════════
//  TABLA
// ══════════════════════════════════════════════════════════════════════════════
bg = color.new(color.black, 10)

var table t = table.new(position.top_right, 2, 8, bgcolor = bg, border_color = color.new(color.gray, 40), border_width = 1)

if barstate.islast
    table.cell(t, 0, 0, 'Sesion',    text_color = color.white, bgcolor = bg, text_size = size.tiny)
    table.cell(t, 1, 0, session_name, text_color = session_col, bgcolor = bg, text_size = size.tiny)

    table.cell(t, 0, 1, 'Sesgo 1H',  text_color = color.white, bgcolor = bg, text_size = size.tiny)
    table.cell(t, 1, 1, bias_long ? 'LONG' : 'SHORT', text_color = bias_long ? color.green : color.red, bgcolor = bg, text_size = size.tiny)

    table.cell(t, 0, 2, 'VWAP',      text_color = color.white, bgcolor = bg, text_size = size.tiny)
    table.cell(t, 1, 2, vwap_conflict ? 'CONFLICTO' : vwap_bull ? 'Alcista' : 'Bajista', text_color = vwap_conflict ? color.orange : vwap_bull ? color.green : color.red, bgcolor = bg, text_size = size.tiny)

    table.cell(t, 0, 3, 'VWAP $',    text_color = color.white, bgcolor = bg, text_size = size.tiny)
    table.cell(t, 1, 3, str.tostring(math.round(vwap_val, 2)), text_color = color.white, bgcolor = bg, text_size = size.tiny)

    pb = pullback_long_15 or pullback_short_15
    table.cell(t, 0, 4, 'EMA21',     text_color = color.white, bgcolor = bg, text_size = size.tiny)
    table.cell(t, 1, 4, pb ? 'Rechazo' : 'Espera', text_color = pb ? color.green : color.white, bgcolor = bg, text_size = size.tiny)

    mom = mom_long or mom_short
    table.cell(t, 0, 5, 'Momentum',  text_color = color.white, bgcolor = bg, text_size = size.tiny)
    table.cell(t, 1, 5, mom ? 'Confirmado' : 'Espera', text_color = mom ? color.green : color.white, bgcolor = bg, text_size = size.tiny)

    sig_txt = long_setup ? 'LONG' : short_setup ? 'SHORT' : long_alert ? 'LONG?' : short_alert ? 'SHORT?' : 'ESPERA'
    sig_clr = long_setup ? color.green : short_setup ? color.red : (long_alert or short_alert) ? color.orange : color.white
    sig_bg  = long_setup ? color.new(color.green, 60) : short_setup ? color.new(color.red, 60) : (long_alert or short_alert) ? color.new(color.orange, 65) : bg
    table.cell(t, 0, 6, 'SETUP', text_color = color.white, bgcolor = sig_bg, text_size = size.small)
    table.cell(t, 1, 6, sig_txt, text_color = sig_clr,     bgcolor = sig_bg, text_size = size.small)

    table.cell(t, 0, 7, '💰', text_color = color.orange, bgcolor = bg, text_size = size.tiny)
    table.cell(t, 1, 7, '@wilberrgarcia', text_color = color.white, bgcolor = bg, text_size = size.tiny)

// ══════════════════════════════════════════════════════════════════════════════
//  ALERTAS
// ══════════════════════════════════════════════════════════════════════════════
alertcondition(long_setup,                title = 'MNQ LONG',         message = 'Setup LONG completo')
alertcondition(short_setup,               title = 'MNQ SHORT',        message = 'Setup SHORT completo')
alertcondition(long_alert,                title = 'LONG parcial',     message = 'Contexto LONG 3+ condiciones')
alertcondition(short_alert,               title = 'SHORT parcial',    message = 'Contexto SHORT 3+ condiciones')
alertcondition(long_setup or short_setup, title = 'Setup confirmado', message = 'Setup completo - revisa direccion')
alertcondition(vwap_conflict,             title = 'Conflicto VWAP',   message = 'VWAP contradice sesgo - NO OPERAR')
alertcondition(accum_zone,                title = 'Acumulacion',      message = 'Precio acumulando cerca de EMA21 — prepara entrada')
````
