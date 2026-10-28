# SQZ Pro JS [MTF + ADX + Divergencias + Giros]

- url: https://www.tradingview.com/script/FH0wCI7H/
- type: indicator
- pine_id: PUB;2c5c1025bcfc4f94bf4d8dead8c2747a
- version: 4.0

## Description

El ecosistema definitivo del Squeeze Momentum. Basado en la estrategia clásica del Squeeze, este indicador ha sido reconstruido desde cero para traders exigentes que buscan precisión matemática y gráficos extremadamente limpios. Hemos eliminado el "ruido" y las señales falsas para centrarnos en lo que realmente importa: la fuerza de la tendencia, la alineación de temporalidades y las divergencias estructurales.

🎯 CARACTERÍSTICAS PRINCIPALES:
1. Motor de Divergencias PRO (Lógica de Olas)
Olvídate de las divergencias falsas causadas por pequeños baches en el precio. Este indicador utiliza un rastreador de "Olas" (Wave Tracker) que identifica el pico absoluto de la fuerza compradora/vendedora y lo compara estrictamente con la ola anterior.

Regla de Cero Estricta: Las divergencias alcistas solo se calculan en la zona roja (valles) y las bajistas en la zona verde (picos). Trazado limpio "de palo a palo".

2. Panel Dinámico Multi-Timeframe (MTF)
Un monitor lateral que te permite escanear el mercado desde 5 Minutos hasta Mensual. La tabla es inteligente: su tamaño se adapta dinámicamente según las temporalidades que actives.
Para cada temporalidad, el panel analiza simultáneamente:

La dirección del Squeeze.

La fuerza de la tendencia (Filtro ADX y cruces DI+/DI- integrados matemáticamente).

Eventos en tiempo real (Giros de color y cruces de la línea cero).

3. Señales Verticales de Precisión (Sin ensuciar el gráfico)
El indicador traza líneas verticales directamente en tu gráfico solo en la temporalidad en la que te encuentras, marcando los momentos críticos:

Giro Buy / Sell: Cuando el momentum cambia de dirección perdiendo fuerza.

Cruce 0 UP / DN: Cuando el momentum cruza la línea cero confirmando el cambio de bando.

Totalmente personalizables: Elige el grosor, color y estilo (línea sólida, punteada o discontinua) para adaptar el gráfico a tu estilo visual.

4. Estética "Clean Chart" (Cero distracciones)
Diseñado para no estorbar.

El Momentum se muestra en formato de columnas limpias (Verde oscuro para fuerza creciente, Rojo para fuerza decreciente).

Elementos secundarios como el ADX, las líneas DI o los puntos del Squeeze (dots) vienen ocultos de fábrica para mantener el gráfico puro, aunque su matemática sigue trabajando en segundo plano para la tabla MTF.

Las etiquetas molestas de la escala de precios han sido desactivadas por defecto.

💡 CÓMO UTILIZARLO:
El Panel (El Bosque): Utiliza la tabla MTF para confirmar que las temporalidades mayores (ej. Diario y 4H) están alineadas en la misma dirección (Fuerza + ADX).

El Histograma (El Árbol): Busca entradas en tu temporalidad operativa cuando el histograma confirme un "Giro" a favor de la tendencia mayor, o cuando detecte una Divergencia Pro confirmada.

⚙️ CONFIGURACIÓN DE FÁBRICA:
El indicador viene pre-configurado para operar "Out of the box" con colores intuitivos y sensibilidad profesional, pero ofrece control absoluto en sus ajustes para activar temporalidades menores (5m, 15m, 30m), mostrar las líneas del ADX o ajustar los periodos del canal de Keltner y las Bandas de Bollinger.

(Descargo de responsabilidad: Este indicador es una herramienta de análisis técnico y no constituye asesoramiento financiero. Úsalo en confluencia con tu propia gestión de riesgo).

## Source Code

````pine
//@version=6
indicator("SQZ Pro Limpio [MTF + Gatillo Radar + BBWP]", shorttitle="SQZ JS", overlay=false, max_lines_count=500, max_labels_count=500)

// ============================================================
//  GUÍA RÁPIDA E INFO (TOOLTIPS)
// ============================================================
info_estr = input.string("LEER INFO", "ℹ️ GUÍA DE ESTRATEGIA", group="SOBRE SQZ JS", 
     tooltip="ESTRATEGIA SQZ JS:\n\n" +
     "1. SQUEEZE (Puntos Negros): Acumulación de energía. Gris/Amarillo: Liberación.\n" +
     "2. ADX: Filtro de fuerza. > 23 y subiendo (↑) indica tendencia real.\n" +
     "3. EVT: 0-UP (Cruce alcista), 0-LOW (Cruce bajista).\n" +
     "4. DIVERGENCIAS: Inteligentes. Solo visibles en >= 4H para evitar ruido.\n" +
     "5. LÍNEAS SEÑAL: Solo en >= 1H.")

info_tf = input.string("LEER POTENCIAL", "⏳ INFO TEMPORALIDADES", group="SOBRE SQZ JS", 
     tooltip="POTENCIAL DEL GATILLO:\n\n" +
     "• 1 Hora (1H) / 4 Horas (4H): Ideales para Swing Trading de corto plazo. Si el Squeeze revienta aquí, esperar un movimiento fuerte de 1 a 3 días.\n\n" +
     "• Diario (1D): Aquí está el 'dinero grande'. Squeeze diario con ADX fuerte significa compresión de semanas. Al liberarse, genera tendencias de un mes o más.\n\n" +
     "• Semanal (S): Ocurren poco, pero inician ciclos masivos de meses.")

info_radar = input.string("LEER RADAR", "🎯 INFO RADAR Y BBWP", group="SOBRE SQZ JS", 
     tooltip="CÓMO FUNCIONA LA FILA INFERIOR:\n\n" +
     "RADAR: Rastreador de explosiones. Marca 🔥 BUY o ⚡ SELL si hay: Squeeze OFF + ADX fuerte + Momentum a favor.\n\n" +
     "VOL (BBWP): Es la esquina inferior derecha. Mide la volatilidad extrema.\n" +
     "Fondo Gris = Mercado dormido o normal.\n" +
     "Fondo Naranja/Rojo = Volatilidad extrema (¡Cuidado!).\n" +
     "La flecha indica si la volatilidad aumenta ↑ o disminuye ↓.")

// ============================================================
//  GRUPOS
// ============================================================
var string G_SQZ  = "SQZ - Squeeze Momentum"
var string G_ADX  = "ADX - Direccionalidad"
var string G_VOL  = "BBWP - Volatilidad"
var string G_DIV  = "Divergencias PRO (Filtro TF)"
var string G_MTF  = "Multi-Timeframe"
var string G_SIG  = "Senales Visuales (Filtro TF)"
var string G_TAB  = "Tabla MTF"
var string G_SES  = "Sesiones de Mercado (Auto-Zona)"

// ============================================================
//  SQZ
// ============================================================
sqz_len       = input.int(20, "Longitud BB/KC", group=G_SQZ, minval=1)
sqz_bb_mult   = input.float(2.0, "Multiplicador BB", group=G_SQZ, step=0.1)
sqz_kc_mult   = input.float(1.5, "Multiplicador KC", group=G_SQZ, step=0.1)
sqz_mom_len   = input.int(12, "Longitud Momentum", group=G_SQZ, minval=1)

col_bull_up   = input.color(#089981, "Alcista creciendo", group=G_SQZ)
col_bull_dn   = input.color(#F23645, "Alcista bajando", group=G_SQZ)  
col_bear_dn   = input.color(#F23645, "Bajista bajando", group=G_SQZ)  
col_bear_up   = input.color(#089981, "Bajista subiendo", group=G_SQZ)  

sqz_show_dot  = input.bool(false, "Mostrar Squeeze Dots", group=G_SQZ)
col_sqz_on    = input.color(#212121, "Squeeze ON", group=G_SQZ)
col_sqz_off   = input.color(#FFEB3B, "Squeeze OFF", group=G_SQZ)
col_no_sqz    = input.color(#9E9E9E, "Sin squeeze", group=G_SQZ)

basis_bb = ta.sma(close, sqz_len)
dev_bb   = sqz_bb_mult * ta.stdev(close, sqz_len)
upper_bb = basis_bb + dev_bb
lower_bb = basis_bb - dev_bb

basis_kc = ta.sma(close, sqz_len)
rng_kc   = ta.sma(ta.tr, sqz_len)
upper_kc = basis_kc + sqz_kc_mult * rng_kc
lower_kc = basis_kc - sqz_kc_mult * rng_kc

sqz_on  = (lower_bb > lower_kc) and (upper_bb < upper_kc)
sqz_off = (lower_bb < lower_kc) and (upper_bb > upper_kc)

highest_h = ta.highest(high, sqz_len)
lowest_l  = ta.lowest(low, sqz_len)
mom_val   = ta.linreg(close - math.avg(math.avg(highest_h, lowest_l), ta.sma(close, sqz_len)), sqz_mom_len, 0)

mom_col = mom_val > 0 ? (mom_val > nz(mom_val[1]) ? col_bull_up : col_bull_dn) : (mom_val < nz(mom_val[1]) ? col_bear_dn : col_bear_up)
sqz_dot_col = sqz_on ? col_sqz_on : (sqz_off ? col_sqz_off : col_no_sqz)

curr_mom_color_id = mom_val > 0 ? (mom_val > nz(mom_val[1]) ? 1 : 2) : (mom_val < nz(mom_val[1]) ? 3 : 4)

// ============================================================
//  GIROS Y CRUCES LOCALES
// ============================================================
bear_turn_up    = (mom_val < 0) and (mom_val > nz(mom_val[1])) and (nz(mom_val[1]) <= nz(mom_val[2]))
bull_turn_down  = (mom_val > 0) and (mom_val < nz(mom_val[1])) and (nz(mom_val[1]) >= nz(mom_val[2]))
zero_cross_up   = ta.crossover(mom_val, 0)
zero_cross_down = ta.crossunder(mom_val, 0)

// ============================================================
//  ADX
// ============================================================
adx_show      = input.bool(false, "Mostrar ADX", group=G_ADX)
adx_len       = input.int(14, "Longitud ADX", group=G_ADX, minval=1)
adx_smooth    = input.int(14, "Suavizado ADX", group=G_ADX, minval=1)
adx_thresh_hi = input.int(25, "Umbral FUERZA (verde >)", group=G_ADX, minval=1, maxval=100)
adx_thresh_lo = input.int(20, "Umbral DEBIL (rojo <)", group=G_ADX, minval=1, maxval=100)
adx_show_di   = input.bool(false, "Mostrar DI+ / DI-", group=G_ADX)
adx_show_thr  = input.bool(false, "Mostrar lineas umbral", group=G_ADX)
adx_line_wid  = input.int(2, "Grosor linea ADX", group=G_ADX, minval=1, maxval=4)
di_line_wid   = input.int(1, "Grosor lineas DI", group=G_ADX, minval=1, maxval=4)

col_adx_up     = input.color(#FFD700, "ADX ganando fuerza", group=G_ADX)
col_adx_dn     = input.color(#78909C, "ADX perdiendo fuerza", group=G_ADX)
col_adx_thr    = input.color(color.new(#FFFFFF, 60), "Color umbral", group=G_ADX)
col_di_plus    = input.color(#26C6DA, "Color DI+", group=G_ADX)
col_di_minus   = input.color(#EF5350, "Color DI-", group=G_ADX)
col_adx_strong = input.color(#00C853, "Tabla ADX: fuerza", group=G_ADX)
col_adx_mid    = input.color(#FF6D00, "Tabla ADX: medio", group=G_ADX)
col_adx_weak   = input.color(#D50000, "Tabla ADX: debil", group=G_ADX)

[diplus_raw, diminus_raw, adx_raw] = ta.dmi(adx_len, adx_smooth)
adx_col = adx_raw > nz(adx_raw[1]) ? col_adx_up : col_adx_dn

f_adx_bg(adx_v, activo) =>
    not activo ? color.new(#000000, 0) : (adx_v >= adx_thresh_hi ? col_adx_strong : (adx_v >= adx_thresh_lo ? col_adx_mid : col_adx_weak))

// ============================================================
//  BBWP - VOLATILIDAD INTERNA
// ============================================================
bbwp_len = input.int(252, "Longitud BBWP", group=G_VOL, tooltip="Periodos de retrospectiva para calcular el percentil. 252 es el estándar institucional anual.")

bbw = basis_bb == 0 ? 0 : (upper_bb - lower_bb) / basis_bb
bbwp = ta.percentrank(bbw, bbwp_len)
bbwp_sma = ta.sma(bbwp, 5)

// Flechas de dirección BBWP
bbwp_arr = bbwp > bbwp_sma ? "↑" : (bbwp < bbwp_sma ? "↓" : "→")

// ============================================================
//  DIVERGENCIAS PRO (CON FILTRO TF)
// ============================================================
div_show         = input.bool(true, "Activar Divergencias (Filtro > 4H)", group=G_DIV)
pivot_left       = input.int(5, "Pivote - Barras Izquierda", group=G_DIV, minval=1)
pivot_right      = input.int(2, "Pivote - Barras Derecha", group=G_DIV, minval=1)
div_range_max    = input.int(60, "Rango max (barras)", group=G_DIV, minval=5)

plot_bull         = input.bool(true, "Trazado regular alcista", group=G_DIV)
plot_hidden_bull = input.bool(true, "Trazado oculto alcista", group=G_DIV)
plot_bear         = input.bool(true, "Trazado regular bajista", group=G_DIV)
plot_hidden_bear = input.bool(true, "Trazado oculto bajista", group=G_DIV)

col_reg_bull_0   = input.color(#1bff00, "Alcista regular", group=G_DIV)
col_hid_bull_0   = input.color(#a4ff99, "Alcista oculto", group=G_DIV)
col_reg_bear_0   = input.color(#ff0000, "Bajista regular", group=G_DIV)
col_hid_bear_0   = input.color(#ff9e9e, "Bajista oculto", group=G_DIV)

is_high_tf_div = (timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly or (timeframe.isintraday and timeframe.multiplier >= 240))
can_draw_div = div_show and is_high_tf_div

ph = ta.pivothigh(mom_val, pivot_left, pivot_right)
pl = ta.pivotlow(mom_val, pivot_left, pivot_right)

var float osc_ph_val = na, var float price_ph_val = na, var int ph_bar = na
var float osc_pl_val = na, var float price_pl_val = na, var int pl_bar = na

if not na(ph)
    curr_osc_ph = ph
    curr_prc_ph = high[pivot_right]
    curr_bar_ph = bar_index[pivot_right]
    
    if not na(osc_ph_val) and (curr_bar_ph - ph_bar) <= div_range_max
        if curr_prc_ph > price_ph_val and curr_osc_ph < osc_ph_val and can_draw_div
            if plot_bear
                line.new(ph_bar, osc_ph_val, curr_bar_ph, curr_osc_ph, color=col_reg_bear_0, width=2)
        else if curr_prc_ph < price_ph_val and curr_osc_ph > osc_ph_val and can_draw_div
            if plot_hidden_bear
                line.new(ph_bar, osc_ph_val, curr_bar_ph, curr_osc_ph, color=col_hid_bear_0, width=1, style=line.style_dashed)
                
    osc_ph_val := curr_osc_ph
    price_ph_val := curr_prc_ph
    ph_bar := curr_bar_ph

if not na(pl)
    curr_osc_pl = pl
    curr_prc_pl = low[pivot_right]
    curr_bar_pl = bar_index[pivot_right]
    
    if not na(osc_pl_val) and (curr_bar_pl - pl_bar) <= div_range_max
        if curr_prc_pl < price_pl_val and curr_osc_pl > osc_pl_val and can_draw_div
            if plot_bull
                line.new(pl_bar, osc_pl_val, curr_bar_pl, curr_osc_pl, color=col_reg_bull_0, width=2)
        else if curr_prc_pl > price_pl_val and curr_osc_pl < osc_pl_val and can_draw_div
            if plot_hidden_bull
                line.new(pl_bar, osc_pl_val, curr_bar_pl, curr_osc_pl, color=col_hid_bull_0, width=1, style=line.style_dashed)
                
    osc_pl_val := curr_osc_pl
    price_pl_val := curr_prc_pl
    pl_bar := curr_bar_pl

// ============================================================
//  MULTI-TIMEFRAME Y DETECCIÓN DE TF ACTUAL (HIGHLIGHT)
// ============================================================
mtf_min   = input.int(3, "Minimo TF coincidentes", group=G_MTF, minval=1, maxval=8, tooltip="Alineación necesaria para disparar estado de TENDENCIA (Alineado).")
use_5m    = input.bool(false, "Activar 5m", group=G_MTF)
use_15m   = input.bool(false, "Activar 15m", group=G_MTF)
use_30m   = input.bool(false, "Activar 30m", group=G_MTF)
use_1h    = input.bool(true,  "Activar 1H", group=G_MTF)
use_4h    = input.bool(true,  "Activar 4H", group=G_MTF)
use_1d    = input.bool(true,  "Activar Diario", group=G_MTF)
use_1w    = input.bool(true,  "Activar Semanal (S)", group=G_MTF)
use_1mo   = input.bool(true,  "Activar Mensual (M)", group=G_MTF)

// Variables booleanas para saber en qué gráfico estamos
is_curr_5m  = timeframe.isintraday and timeframe.multiplier == 5
is_curr_15m = timeframe.isintraday and timeframe.multiplier == 15
is_curr_30m = timeframe.isintraday and timeframe.multiplier == 30
is_curr_1h  = timeframe.isintraday and timeframe.multiplier == 60
is_curr_4h  = timeframe.isintraday and timeframe.multiplier == 240
is_curr_1d  = timeframe.isdaily
is_curr_1w  = timeframe.isweekly
is_curr_1mo = timeframe.ismonthly

// Funciones ajustadas para opacar suavemente los resultados (SQZ, ADX, EVT)
f_dim_bg(c, is_curr)  => is_curr ? c : color.new(c, 50) 
f_dim_txt(c, is_curr) => is_curr ? c : color.new(c, 20) 

// Función para el color del texto BUY/SELL (Negro para BUY, Blanco para el resto)
f_sqz_txt_col(bull, bear) => bull ? color.black : color.white

f_sqz_signal(tf) =>
    [m, sq_on_tf, adx_v, adx_p, dip, dim, ev_bt, ev_st, ev_zup, ev_zdn] = request.security(
         syminfo.tickerid, tf,
         [mom_val, sqz_on, adx_raw, adx_raw[1], diplus_raw, diminus_raw, bear_turn_up, bull_turn_down, zero_cross_up, zero_cross_down],
         lookahead=barmerge.lookahead_off)

    bull = (m > 0) and not sq_on_tf and (adx_v > adx_thresh_lo) and (dip > dim)
    bear = (m < 0) and not sq_on_tf and (adx_v > adx_thresh_lo) and (dim > dip)
    adx_arr = adx_v > adx_p ? "↑" : "↓"

    [bull, bear, m, adx_v, adx_arr, ev_bt, ev_st, ev_zup, ev_zdn]

[bull_5m, bear_5m, mom_5m, adx_5m, arr_5m, bt_5m, st_5m, zup_5m, zdn_5m] = f_sqz_signal("5")
[bull_15m, bear_15m, mom_15m, adx_15m, arr_15m, bt_15m, st_15m, zup_15m, zdn_15m] = f_sqz_signal("15")
[bull_30m, bear_30m, mom_30m, adx_30m, arr_30m, bt_30m, st_30m, zup_30m, zdn_30m] = f_sqz_signal("30")
[bull_1h, bear_1h, mom_1h, adx_1h, arr_1h, bt_1h, st_1h, zup_1h, zdn_1h] = f_sqz_signal("60")
[bull_4h, bear_4h, mom_4h, adx_4h, arr_4h, bt_4h, st_4h, zup_4h, zdn_4h] = f_sqz_signal("240")
[bull_1d, bear_1d, mom_1d, adx_1d, arr_1d, bt_1d, st_1d, zup_1d, zdn_1d] = f_sqz_signal("D")
[bull_1w, bear_1w, mom_1w, adx_1w, arr_1w, bt_1w, st_1w, zup_1w, zdn_1w] = f_sqz_signal("W")
[bull_1mo, bear_1mo, mom_1mo, adx_1mo, arr_1mo, bt_1mo, st_1mo, zup_1mo, zdn_1mo] = f_sqz_signal("M")

bull_count = (use_5m and bull_5m ? 1 : 0) + (use_15m and bull_15m ? 1 : 0) + (use_30m and bull_30m ? 1 : 0) + (use_1h and bull_1h ? 1 : 0) + (use_4h and bull_4h ? 1 : 0) + (use_1d and bull_1d ? 1 : 0) + (use_1w and bull_1w ? 1 : 0) + (use_1mo and bull_1mo ? 1 : 0)
bear_count = (use_5m and bear_5m ? 1 : 0) + (use_15m and bear_15m ? 1 : 0) + (use_30m and bear_30m ? 1 : 0) + (use_1h and bear_1h ? 1 : 0) + (use_4h and bear_4h ? 1 : 0) + (use_1d and bear_1d ? 1 : 0) + (use_1w and bear_1w ? 1 : 0) + (use_1mo and bear_1mo ? 1 : 0)

signal_bull = bull_count >= mtf_min
signal_bear = bear_count >= mtf_min

// ============================================================
//  SESIONES DE MERCADO (AUTO-ZONA HORARIA)
// ============================================================
show_ses = input.bool(false, "Mostrar fondos de Sesion", group=G_SES, tooltip="Muestra el fondo de pantalla cuando cada mercado está abierto. Introduce la hora NATIVA de cada país; el indicador la adaptará automáticamente a tu gráfico local.")

show_lon = input.bool(true, "Londres", inline="lon", group=G_SES)
time_lon = input.session("0800-1630", "", inline="lon", group=G_SES)
col_lon  = input.color(color.new(color.blue, 90), "", inline="lon", group=G_SES)

show_ny  = input.bool(true, "Nueva York", inline="ny", group=G_SES)
time_ny  = input.session("0930-1600", "", inline="ny", group=G_SES)
col_ny   = input.color(color.new(color.yellow, 90), "", inline="ny", group=G_SES)

show_tok = input.bool(false, "Tokio", inline="tok", group=G_SES)
time_tok = input.session("0900-1500", "", inline="tok", group=G_SES)
col_tok  = input.color(color.new(color.red, 90), "", inline="tok", group=G_SES)

show_syd = input.bool(false, "Sydney", inline="syd", group=G_SES)
time_syd = input.session("1000-1600", "", inline="syd", group=G_SES)
col_syd  = input.color(color.new(color.purple, 90), "", inline="syd", group=G_SES)

in_lon = show_ses and show_lon and not na(time(timeframe.period, time_lon, "Europe/London"))
in_ny  = show_ses and show_ny  and not na(time(timeframe.period, time_ny, "America/New_York"))
in_tok = show_ses and show_tok and not na(time(timeframe.period, time_tok, "Asia/Tokyo"))
in_syd = show_ses and show_syd and not na(time(timeframe.period, time_syd, "Australia/Sydney"))

bgcolor(in_lon ? col_lon : na, title="Fondo Sesion Londres")
bgcolor(in_ny  ? col_ny  : na, title="Fondo Sesion Nueva York")
bgcolor(in_tok ? col_tok : na, title="Fondo Sesion Tokio")
bgcolor(in_syd ? col_syd : na, title="Fondo Sesion Sydney")

// ============================================================
//  SEÑALES VISUALES Y LÍNEAS (CON FILTRO TF Y OPACIDAD)
// ============================================================
sig_show        = input.bool(false, "Mostrar senales globales MTF", group=G_SIG)
sig_show_turns  = input.bool(true, "Mostrar Líneas de GIRO (Filtro > 1H)", group=G_SIG)
sig_show_zero_x = input.bool(true, "Mostrar Líneas CRUCE 0 (Filtro > 1H)", group=G_SIG)

is_high_tf_sig = (timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly or (timeframe.isintraday and timeframe.multiplier >= 60))
can_draw_sig_turns = sig_show_turns and is_high_tf_sig
can_draw_sig_zero = sig_show_zero_x and is_high_tf_sig

// Colores con 70 de transparencia (opacidad tenue)
col_turn_buy    = input.color(color.new(#089981, 70), "Color Giro Buy", group=G_SIG)
sty_turn_buy    = input.string("Solid", "Estilo Giro Buy", options=["Solid", "Dotted", "Dashed"], group=G_SIG)
wid_turn_buy    = input.int(1, "Grosor Giro Buy", minval=1, maxval=4, group=G_SIG)

col_zero_up     = input.color(color.new(#089981, 70), "Color Cruce 0 UP", group=G_SIG)
sty_zero_up     = input.string("Dotted", "Estilo Cruce 0 UP", options=["Solid", "Dotted", "Dashed"], group=G_SIG)
wid_zero_up     = input.int(2, "Grosor Cruce 0 UP", minval=1, maxval=4, group=G_SIG)

col_turn_sell   = input.color(color.new(#F23645, 70), "Color Giro Sell", group=G_SIG)
sty_turn_sell   = input.string("Solid", "Estilo Giro Sell", options=["Solid", "Dotted", "Dashed"], group=G_SIG)
wid_turn_sell   = input.int(1, "Grosor Giro Sell", minval=1, maxval=4, group=G_SIG)

col_zero_down   = input.color(color.new(#F23645, 70), "Color Cruce 0 DN", group=G_SIG)
sty_zero_down   = input.string("Dotted", "Estilo Cruce 0 DN", options=["Solid", "Dotted", "Dashed"], group=G_SIG)
wid_zero_down   = input.int(2, "Grosor Cruce 0 DN", minval=1, maxval=4, group=G_SIG)

f_get_style(sty) => sty == "Solid" ? line.style_solid : (sty == "Dotted" ? line.style_dotted : line.style_dashed)

mom_range = ta.highest(math.abs(mom_val), 50)

if can_draw_sig_turns and bear_turn_up
    line.new(bar_index, mom_range * 1.5, bar_index, -mom_range * 1.5, color=col_turn_buy, width=wid_turn_buy, style=f_get_style(sty_turn_buy))
if can_draw_sig_zero and zero_cross_up
    line.new(bar_index, mom_range * 1.5, bar_index, -mom_range * 1.5, color=col_zero_up, width=wid_zero_up, style=f_get_style(sty_zero_up))
if can_draw_sig_turns and bull_turn_down
    line.new(bar_index, mom_range * 1.5, bar_index, -mom_range * 1.5, color=col_turn_sell, width=wid_turn_sell, style=f_get_style(sty_turn_sell))
if can_draw_sig_zero and zero_cross_down
    line.new(bar_index, mom_range * 1.5, bar_index, -mom_range * 1.5, color=col_zero_down, width=wid_zero_down, style=f_get_style(sty_zero_down))

// ============================================================
//  PLOTS PRINCIPALES (SQZ, ADX)
// ============================================================
plot(mom_val, style=plot.style_columns, color=mom_col, linewidth=4, title="SQZ Momentum", display=display.pane)
plot(sqz_show_dot ? 0 : na, style=plot.style_circles, color=sqz_dot_col, linewidth=3, title="Squeeze dot", display=display.pane)

// Plots ADX
plot(adx_show ? adx_raw : na, title="Linea ADX", color=adx_col, linewidth=adx_line_wid, display=display.pane)
plot(adx_show and adx_show_di ? diplus_raw : na, title="Linea DI+", color=col_di_plus, linewidth=di_line_wid, display=display.pane)
plot(adx_show and adx_show_di ? diminus_raw : na, title="Linea DI-", color=col_di_minus, linewidth=di_line_wid, display=display.pane)
plot(adx_show and adx_show_thr ? adx_thresh_hi : na, title="Umbral ADX Fuerte", color=col_adx_thr, style=plot.style_line, display=display.pane)
plot(adx_show and adx_show_thr ? adx_thresh_lo : na, title="Umbral ADX Debil", color=col_adx_thr, style=plot.style_line, display=display.pane)


// ============================================================
//  TABLA MTF & RADAR & BBWP
// ============================================================
tab_show     = input.bool(true, "Mostrar tabla MTF", group=G_TAB)
tab_pos      = input.string("bottom_right", "Posicion", options=["top_left","top_right","bottom_left","bottom_right"], group=G_TAB)
tab_txt_sz   = input.string("normal", "Tamano texto", options=["tiny","small","normal","large"], group=G_TAB)

// Fondo general de la tabla y cabecera en NEGRO PURO
col_tab_bg   = input.color(color.new(#000000, 0), "Fondo tabla", group=G_TAB)
col_tab_brd  = input.color(color.new(#3D3D7A, 0), "Borde", group=G_TAB)
col_tab_hdr  = input.color(color.new(#000000, 0), "Fondo cabecera", group=G_TAB)
col_tab_txt  = input.color(color.white, "Texto", group=G_TAB)

tab_sz = switch tab_txt_sz
    "tiny"   => size.tiny
    "small"  => size.small
    "normal" => size.normal
    => size.large

tab_p = switch tab_pos
    "top_left"     => position.top_left
    "top_right"    => position.top_right
    "bottom_left"  => position.bottom_left
    => position.bottom_right

f_tf_txt(bull, bear, activo) => not activo ? "-" : bull ? "BUY" : bear ? "SELL" : "---"
// Las celdas "---" (vacías) usan el color base de la tabla (#546E7A)
f_tf_bg(bull, bear, activo) => not activo ? #546E7A : bull ? #00E676 : bear ? #D50000 : #546E7A 

f_evt_txt(buy_turn, sell_turn, zup, zdn, activo) =>
    not activo ? "-" : zup ? "0-UP" : zdn ? "0-LOW" : buy_turn ? "G-BUY" : sell_turn ? "G-SELL" : "-"
f_evt_bg(buy_turn, sell_turn, zup, zdn, activo) =>
    not activo ? #546E7A : zup ? #00E676 : zdn ? #D50000 : buy_turn ? #089981 : sell_turn ? #D50000 : #546E7A 

// LOGICA RADAR
tb_5m  = bull_5m and (zup_5m or bt_5m)
ts_5m  = bear_5m and (zdn_5m or st_5m)
tb_15m = bull_15m and (zup_15m or bt_15m)
ts_15m = bear_15m and (zdn_15m or st_15m)
tb_30m = bull_30m and (zup_30m or bt_30m)
ts_30m = bear_30m and (zdn_30m or st_30m)
tb_1h  = bull_1h and (zup_1h or bt_1h)
ts_1h  = bear_1h and (zdn_1h or st_1h)
tb_4h  = bull_4h and (zup_4h or bt_4h)
ts_4h  = bear_4h and (zdn_4h or st_4h)
tb_1d  = bull_1d and (zup_1d or bt_1d)
ts_1d  = bear_1d and (zdn_1d or st_1d)
tb_1w  = bull_1w and (zup_1w or bt_1w)
ts_1w  = bear_1w and (zdn_1w or st_1w)
tb_1mo = bull_1mo and (zup_1mo or bt_1mo)
ts_1mo = bear_1mo and (zdn_1mo or st_1mo)

b_str = (use_1h and tb_1h ? "1H " : "") + (use_4h and tb_4h ? "4H " : "") + (use_1d and tb_1d ? "1D " : "") + (use_1w and tb_1w ? "S " : "") + (use_1mo and tb_1mo ? "M " : "")
s_str = (use_1h and ts_1h ? "1H " : "") + (use_4h and ts_4h ? "4H " : "") + (use_1d and ts_1d ? "1D " : "") + (use_1w and ts_1w ? "S " : "") + (use_1mo and ts_1mo ? "M " : "")

// FONDOS DINÁMICOS BBWP: Vuelve a su color base #546E7A si no hay volatilidad
bbwp_bg = bbwp >= 80 ? color.new(#D50000, 0) : (bbwp >= 60 ? color.new(#FF6D00, 0) : (bbwp > 20 ? color.new(#9E9E9E, 0) : color.new(#546E7A, 0)))

// SOLO el nombre de la temporalidad (1H, 1D...) usa NEGRO PURO si no estás ahí, y #546E7A si sí estás.
f_tf_lbl_bg(is_curr)  => is_curr ? color.new(#546E7A, 0) : color.new(#000000, 0)
f_tf_lbl_txt(is_curr) => is_curr ? color.white : color.new(color.white, 40)

var table t = na
if barstate.islast and tab_show
    if not na(t)
        table.delete(t)
    int rows = 2 + (use_5m?1:0)+(use_15m?1:0)+(use_30m?1:0)+(use_1h?1:0)+(use_4h?1:0)+(use_1d?1:0)+(use_1w?1:0)+(use_1mo?1:0)
    t := table.new(tab_p, 4, rows, bgcolor=col_tab_bg, border_color=col_tab_brd, border_width=1, frame_color=col_tab_brd, frame_width=1)
    
    table.cell(t,0,0,"TF",text_color=col_tab_txt,bgcolor=col_tab_hdr,text_size=tab_sz)
    table.cell(t,1,0,"SQZ",text_color=col_tab_txt,bgcolor=col_tab_hdr,text_size=tab_sz)
    table.cell(t,2,0,"ADX",text_color=col_tab_txt,bgcolor=col_tab_hdr,text_size=tab_sz)
    table.cell(t,3,0,"EVT",text_color=col_tab_txt,bgcolor=col_tab_hdr,text_size=tab_sz)
    int r = 1
    
    if use_5m
        table.cell(t,0,r,"5m",text_color=f_tf_lbl_txt(is_curr_5m),bgcolor=f_tf_lbl_bg(is_curr_5m),text_size=tab_sz)
        table.cell(t,1,r,f_tf_txt(bull_5m,bear_5m,true),text_color=f_dim_txt(f_sqz_txt_col(bull_5m,bear_5m), is_curr_5m),bgcolor=f_dim_bg(f_tf_bg(bull_5m,bear_5m,true), is_curr_5m),text_size=tab_sz)
        table.cell(t,2,r,str.tostring(math.round(adx_5m))+" "+arr_5m,text_color=f_dim_txt(color.white, is_curr_5m),bgcolor=f_dim_bg(f_adx_bg(adx_5m,true), is_curr_5m),text_size=tab_sz)
        table.cell(t,3,r,f_evt_txt(bt_5m,st_5m,zup_5m,zdn_5m,true),text_color=f_dim_txt(color.white, is_curr_5m),bgcolor=f_dim_bg(f_evt_bg(bt_5m,st_5m,zup_5m,zdn_5m,true), is_curr_5m),text_size=tab_sz)
        r += 1
    if use_15m
        table.cell(t,0,r,"15m",text_color=f_tf_lbl_txt(is_curr_15m),bgcolor=f_tf_lbl_bg(is_curr_15m),text_size=tab_sz)
        table.cell(t,1,r,f_tf_txt(bull_15m,bear_15m,true),text_color=f_dim_txt(f_sqz_txt_col(bull_15m,bear_15m), is_curr_15m),bgcolor=f_dim_bg(f_tf_bg(bull_15m,bear_15m,true), is_curr_15m),text_size=tab_sz)
        table.cell(t,2,r,str.tostring(math.round(adx_15m))+" "+arr_15m,text_color=f_dim_txt(color.white, is_curr_15m),bgcolor=f_dim_bg(f_adx_bg(adx_15m,true), is_curr_15m),text_size=tab_sz)
        table.cell(t,3,r,f_evt_txt(bt_15m,st_15m,zup_15m,zdn_15m,true),text_color=f_dim_txt(color.white, is_curr_15m),bgcolor=f_dim_bg(f_evt_bg(bt_15m,st_15m,zup_15m,zdn_15m,true), is_curr_15m),text_size=tab_sz)
        r += 1
    if use_30m
        table.cell(t,0,r,"30m",text_color=f_tf_lbl_txt(is_curr_30m),bgcolor=f_tf_lbl_bg(is_curr_30m),text_size=tab_sz)
        table.cell(t,1,r,f_tf_txt(bull_30m,bear_30m,true),text_color=f_dim_txt(f_sqz_txt_col(bull_30m,bear_30m), is_curr_30m),bgcolor=f_dim_bg(f_tf_bg(bull_30m,bear_30m,true), is_curr_30m),text_size=tab_sz)
        table.cell(t,2,r,str.tostring(math.round(adx_30m))+" "+arr_30m,text_color=f_dim_txt(color.white, is_curr_30m),bgcolor=f_dim_bg(f_adx_bg(adx_30m,true), is_curr_30m),text_size=tab_sz)
        table.cell(t,3,r,f_evt_txt(bt_30m,st_30m,zup_30m,zdn_30m,true),text_color=f_dim_txt(color.white, is_curr_30m),bgcolor=f_dim_bg(f_evt_bg(bt_30m,st_30m,zup_30m,zdn_30m,true), is_curr_30m),text_size=tab_sz)
        r += 1
    if use_1h
        table.cell(t,0,r,"1H",text_color=f_tf_lbl_txt(is_curr_1h),bgcolor=f_tf_lbl_bg(is_curr_1h),text_size=tab_sz)
        table.cell(t,1,r,f_tf_txt(bull_1h,bear_1h,true),text_color=f_dim_txt(f_sqz_txt_col(bull_1h,bear_1h), is_curr_1h),bgcolor=f_dim_bg(f_tf_bg(bull_1h,bear_1h,true), is_curr_1h),text_size=tab_sz)
        table.cell(t,2,r,str.tostring(math.round(adx_1h))+" "+arr_1h,text_color=f_dim_txt(color.white, is_curr_1h),bgcolor=f_dim_bg(f_adx_bg(adx_1h,true), is_curr_1h),text_size=tab_sz)
        table.cell(t,3,r,f_evt_txt(bt_1h,st_1h,zup_1h,zdn_1h,true),text_color=f_dim_txt(color.white, is_curr_1h),bgcolor=f_dim_bg(f_evt_bg(bt_1h,st_1h,zup_1h,zdn_1h,true), is_curr_1h),text_size=tab_sz)
        r += 1
    if use_4h
        table.cell(t,0,r,"4H",text_color=f_tf_lbl_txt(is_curr_4h),bgcolor=f_tf_lbl_bg(is_curr_4h),text_size=tab_sz)
        table.cell(t,1,r,f_tf_txt(bull_4h,bear_4h,true),text_color=f_dim_txt(f_sqz_txt_col(bull_4h,bear_4h), is_curr_4h),bgcolor=f_dim_bg(f_tf_bg(bull_4h,bear_4h,true), is_curr_4h),text_size=tab_sz)
        table.cell(t,2,r,str.tostring(math.round(adx_4h))+" "+arr_4h,text_color=f_dim_txt(color.white, is_curr_4h),bgcolor=f_dim_bg(f_adx_bg(adx_4h,true), is_curr_4h),text_size=tab_sz)
        table.cell(t,3,r,f_evt_txt(bt_4h,st_4h,zup_4h,zdn_4h,true),text_color=f_dim_txt(color.white, is_curr_4h),bgcolor=f_dim_bg(f_evt_bg(bt_4h,st_4h,zup_4h,zdn_4h,true), is_curr_4h),text_size=tab_sz)
        r += 1
    if use_1d
        table.cell(t,0,r,"1D",text_color=f_tf_lbl_txt(is_curr_1d),bgcolor=f_tf_lbl_bg(is_curr_1d),text_size=tab_sz)
        table.cell(t,1,r,f_tf_txt(bull_1d,bear_1d,true),text_color=f_dim_txt(f_sqz_txt_col(bull_1d,bear_1d), is_curr_1d),bgcolor=f_dim_bg(f_tf_bg(bull_1d,bear_1d,true), is_curr_1d),text_size=tab_sz)
        table.cell(t,2,r,str.tostring(math.round(adx_1d))+" "+arr_1d,text_color=f_dim_txt(color.white, is_curr_1d),bgcolor=f_dim_bg(f_adx_bg(adx_1d,true), is_curr_1d),text_size=tab_sz)
        table.cell(t,3,r,f_evt_txt(bt_1d,st_1d,zup_1d,zdn_1d,true),text_color=f_dim_txt(color.white, is_curr_1d),bgcolor=f_dim_bg(f_evt_bg(bt_1d,st_1d,zup_1d,zdn_1d,true), is_curr_1d),text_size=tab_sz)
        r += 1
    if use_1w
        table.cell(t,0,r,"S",text_color=f_tf_lbl_txt(is_curr_1w),bgcolor=f_tf_lbl_bg(is_curr_1w),text_size=tab_sz)
        table.cell(t,1,r,f_tf_txt(bull_1w,bear_1w,true),text_color=f_dim_txt(f_sqz_txt_col(bull_1w,bear_1w), is_curr_1w),bgcolor=f_dim_bg(f_tf_bg(bull_1w,bear_1w,true), is_curr_1w),text_size=tab_sz)
        table.cell(t,2,r,str.tostring(math.round(adx_1w))+" "+arr_1w,text_color=f_dim_txt(color.white, is_curr_1w),bgcolor=f_dim_bg(f_adx_bg(adx_1w,true), is_curr_1w),text_size=tab_sz)
        table.cell(t,3,r,f_evt_txt(bt_1w,st_1w,zup_1w,zdn_1w,true),text_color=f_dim_txt(color.white, is_curr_1w),bgcolor=f_dim_bg(f_evt_bg(bt_1w,st_1w,zup_1w,zdn_1w,true), is_curr_1w),text_size=tab_sz)
        r += 1
    if use_1mo
        table.cell(t,0,r,"M",text_color=f_tf_lbl_txt(is_curr_1mo),bgcolor=f_tf_lbl_bg(is_curr_1mo),text_size=tab_sz)
        table.cell(t,1,r,f_tf_txt(bull_1mo,bear_1mo,true),text_color=f_dim_txt(f_sqz_txt_col(bull_1mo,bear_1mo), is_curr_1mo),bgcolor=f_dim_bg(f_tf_bg(bull_1mo,bear_1mo,true), is_curr_1mo),text_size=tab_sz)
        table.cell(t,2,r,str.tostring(math.round(adx_1mo))+" "+arr_1mo,text_color=f_dim_txt(color.white, is_curr_1mo),bgcolor=f_dim_bg(f_adx_bg(adx_1mo,true), is_curr_1mo),text_size=tab_sz)
        table.cell(t,3,r,f_evt_txt(bt_1mo,st_1mo,zup_1mo,zdn_1mo,true),text_color=f_dim_txt(color.white, is_curr_1mo),bgcolor=f_dim_bg(f_evt_bg(bt_1mo,st_1mo,zup_1mo,zdn_1mo,true), is_curr_1mo),text_size=tab_sz)
        r += 1

    // LOGICA VISUAL DEL RADAR Y BBWP PARA LA FILA FINAL
    s_txt = "NEUTRO"
    s_bg = color.new(#546E7A, 0) // El Radar base vuelve a #546E7A
    s_txt_col = color.white 
    
    if str.length(b_str) > 0
        s_txt := "🔥 BUY [" + str.replace_all(str.trim(b_str), " ", ",") + "]"
        s_bg := color.new(#00E676, 0)
        s_txt_col := color.black 
    else if str.length(s_str) > 0
        s_txt := "⚡ SELL [" + str.replace_all(str.trim(s_str), " ", ",") + "]"
        s_bg := color.new(#D50000, 0)
        s_txt_col := color.white
    else if signal_bull
        s_txt := "📈 T. ALCISTA" // Nuevos Iconos de Tendencia 
        s_bg := color.new(#089981, 0)
        s_txt_col := color.white
    else if signal_bear
        s_txt := "📉 T. BAJISTA" // Nuevos Iconos de Tendencia 
        s_bg := color.new(#D50000, 0)
        s_txt_col := color.white
    else if bbwp <= 20 and sqz_on
        s_txt := "⏳ COMPRESIÓN"
        s_bg := color.new(#9E9E9E, 0)
        s_txt_col := color.white

    // Celda Izquierda (Radar, ocupa columnas 0, 1 y 2 = 75% del espacio)
    table.cell(t, 0, r, s_txt, text_color=s_txt_col, bgcolor=s_bg, text_size=tab_sz, text_halign=text.align_center)
    table.merge_cells(t, 0, r, 2, r)

    // Celda Derecha (BBWP Volatilidad minimalista, ocupa solo columna 3)
    txt_vol = str.tostring(math.round(nz(bbwp, 0))) + "%" + bbwp_arr
    table.cell(t, 3, r, txt_vol, text_color=color.white, bgcolor=bbwp_bg, text_size=tab_sz, text_halign=text.align_center)

// ============================================================
//  ALERTAS
// ============================================================
alertcondition(bear_turn_up, title="SQZ GIRO COMPRA", message="SQZ JS: abajo cambia de rojo bajando a rojo subiendo")
alertcondition(zero_cross_up, title="SQZ CRUCE 0 ARRIBA", message="SQZ JS: el momentum cruza 0 hacia arriba")
alertcondition(bull_turn_down, title="SQZ GIRO VENTA", message="SQZ JS: arriba cambia de verde subiendo a verde bajando")
alertcondition(zero_cross_down, title="SQZ CRUCE 0 ABAJO", message="SQZ JS: el momentum cruza 0 hacia abajo")
````
