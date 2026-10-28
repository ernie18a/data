# SXA: Super Xtation Amplitude | MTF Framework

- url: https://www.tradingview.com/script/5WOO7u3j/
- type: indicator
- pine_id: PUB;5d5440bedd0c4df6a50633a913a6e9a1
- version: 15.0

## Description

SXA (Super Xtation Amplitude) is a multi-timeframe market positioning framework designed to provide a complete visual overview of price location within the broader market structure.

Rather than focusing on entry signals, SXA combines trend context, volatility, session activity, anchored VWAPs, prior-day reference levels, Fibonacci projections, and higher-timeframe moving averages into a single environment. The objective is to help traders understand where price is currently trading relative to statistically and structurally significant areas.

The indicator was built around a simple principle:

"Price behaves differently depending on where it is located within the market."

By integrating multiple forms of context into one view, SXA allows traders to quickly identify premium and discount zones, trend alignment, session-driven liquidity areas, and potential reaction levels without switching between multiple indicators.

FEATURES

• Smart Trend Engine
Multi-timeframe moving average framework designed to visualize short, intermediate, and macro directional bias.

• Dynamic Trend Clouds
Visual cloud structures help identify trend alignment and potential transition zones between bullish and bearish conditions.

• Higher Timeframe Context
Daily 50 SMA and 200 SMA provide broader market structure and long-term directional references.

• Prior Day Reference Levels
Automatic plotting of previous day's Open, High, Low, and Close.

• Fibonacci Expansion Grid
Extended Fibonacci projections derived from the previous day's range to identify potential reaction zones and liquidity targets.

• Anchored Session VWAPs
Includes:

* Daily VWAP
* European Session VWAP
* Pre-New York VWAP
* New York Session VWAP
* Post-European Session VWAP

These levels provide institutional-style references for price acceptance and value.

• Weekly Structure Levels
Dynamic weekly Open, High, and Low levels update in real time throughout the trading week.

• Session Mapping
Visual session boxes highlight important market periods, including the Asian session and Pre-New York range.

INTENDED USE

SXA is designed as a contextual decision-support tool rather than a standalone trading system.

The indicator can be used to:

* Assess overall market positioning.
* Identify trend alignment across multiple timeframes.
* Locate potential support and resistance zones.
* Track session-driven liquidity.
* Monitor volatility expansion and contraction.
* Build discretionary trade narratives.
* Enhance existing trading systems.

SXA does not generate buy or sell recommendations. Instead, it seeks to answer a more fundamental question:

"Where is price currently located within the broader market landscape?"

By providing that context at a glance, traders can make more informed decisions while reducing chart clutter and indicator overload.

Created by @Peter_n_n

## Source Code

````pine
//@version=6
indicator(title='SXA: Super Xtation Amplitude - MAs, VWAPs, Sessions & Fibonacci Framework', shorttitle='SXA', overlay=true, max_boxes_count=500, max_lines_count=500, max_bars_back=1500)
//Creted by @Peter_n_n

// --- SECCIÓN: ORDER BLOCKS CON FILTRO ATR (implementación propia) ---
group_ob = "Order Blocks"
show_order_blocks  = input.bool(true, "Activar Order Blocks", group=group_ob)
ob_pivot_len       = input.int(5, "Sensibilidad Pivote", minval=1, group=group_ob, tooltip="Barras a cada lado para confirmar el swing")
ob_max_boxes       = input.int(50, "Máximo de OBs visibles", minval=1, maxval=50, group=group_ob)
ob_filter_type     = input.string("ATR", "Filtro de Volatilidad", options=["ATR", "Rango Acumulado"], group=group_ob, tooltip="Método para descartar velas anómalas al ubicar el OB")
ob_atr_len         = input.int(200, "Periodo ATR", minval=1, group=group_ob)
ob_invalidate_bars = input.int(10, "Velas para invalidar por persistencia", minval=1, group=group_ob, tooltip="Si el precio cierra más allá del OB durante N velas seguidas sin regresar, se invalida")
ob_bull_color      = input.color(color.new(#1848cc, 80), "Bullish OB", group=group_ob)
ob_bear_color      = input.color(color.new(#b22833, 80), "Bearish OB", group=group_ob)
group_ob_alerts        = "Alertas: Order Blocks"
alert_ob_enabled       = input.bool(true, "Alertar cuando el precio esté en zona OB", group=group_ob_alerts)
ob_alert_cooldown_m1   = input.int(15, "Velas de espera entre alertas - M1", minval=1, group=group_ob_alerts)
ob_alert_cooldown_m5   = input.int(5,  "Velas de espera entre alertas - M5", minval=1, group=group_ob_alerts)
ob_alert_cooldown_bars = timeframe.period == "1" ? ob_alert_cooldown_m1 : ob_alert_cooldown_m5
ob_alert_timezone      = "America/Mexico_City"
ob_alert_mode_m1 = input.string("On Touch", "OB Alert Trigger - M1", options=["On Touch", "On Close"], group=group_ob_alerts)
ob_alert_mode_m5 = input.string("On Touch", "OB Alert Trigger - M5", options=["On Touch", "On Close"], group=group_ob_alerts)
ob_alert_mode = timeframe.period == "1" ? ob_alert_mode_m1 : ob_alert_mode_m5

// Ventana 1 - la que ya tenías (sesión de la mañana)
ob_alert_win1_on   = input.bool(true,  "Activar Ventana 1", group=group_ob_alerts, inline="ob_win1")
ob_alert_win1      = input.session("0600-1130", "", group=group_ob_alerts, inline="ob_win1")

// Ventana 2 - nueva, independiente (por ejemplo, sesión de Asia)
ob_alert_win2_on   = input.bool(false, "Activar Ventana 2", group=group_ob_alerts, inline="ob_win2")
ob_alert_win2      = input.session("1700-1900", "", group=group_ob_alerts, inline="ob_win2")

ob_in_win1 = ob_alert_win1_on and not na(time(timeframe.period, ob_alert_win1, ob_alert_timezone))
ob_in_win2 = ob_alert_win2_on and not na(time(timeframe.period, ob_alert_win2, ob_alert_timezone))

ob_alert_in_session = ob_in_win1 or ob_in_win2

// ---------- MEDIDA DE VOLATILIDAD ----------
ob_atrMeasure        = ta.atr(ob_atr_len)
ob_volatilityMeasure = ob_filter_type == "ATR" ? ob_atrMeasure : ta.cum(ta.tr) / bar_index
ob_highVolBar        = (high - low) >= (2 * ob_volatilityMeasure)

ob_parsedHigh = ob_highVolBar ? low  : high
ob_parsedLow  = ob_highVolBar ? high : low

var array<float> ob_parsedHighs = array.new<float>()
var array<float> ob_parsedLows  = array.new<float>()
ob_parsedHighs.push(ob_parsedHigh)
ob_parsedLows.push(ob_parsedLow)

// ---------- ESTRUCTURAS ----------
var array<box>   ob_boxes      = array.new<box>()
var array<int>   ob_bias       = array.new<int>()   // 1 = bullish, -1 = bearish
var array<float> ob_high       = array.new<float>()
var array<float> ob_low        = array.new<float>()
var array<int>   ob_breakCount = array.new<int>()   // velas consecutivas cerrando más allá del OB
var array<int>   ob_lastAlertBar = array.new<int>() // última barra en que se alertó este OB

pivotHighVal = ta.pivothigh(high, ob_pivot_len, ob_pivot_len)
pivotLowVal  = ta.pivotlow(low, ob_pivot_len, ob_pivot_len)

var float lastPivotHigh    = na
var float lastPivotLow     = na
var int   lastPivotHighBar = na   // [Parche 2] bar_index real del pivote, para acotar la búsqueda del ancla
var int   lastPivotLowBar  = na

if not na(pivotHighVal)
    lastPivotHigh    := pivotHighVal
    lastPivotHighBar := bar_index - ob_pivot_len   // ta.pivothigh confirma con "ob_pivot_len" barras de retraso
if not na(pivotLowVal)
    lastPivotLow    := pivotLowVal
    lastPivotLowBar := bar_index - ob_pivot_len

// [Parche 1] cruces guardados en variables propias, fuera de la expresión condicional (evita warning CW10002)
ob_crossover  = ta.crossover(close, lastPivotHigh)
ob_crossunder = ta.crossunder(close, lastPivotLow)

// [Parche 3] confluencia cuerpo/mecha: exige que el cuerpo real de la vela de ruptura
// sea al menos X% de su rango total, para descartar rupturas sostenidas solo por una mecha
ob_confluence_min_ratio = input.float(0.5, "Confluencia mínima cuerpo/rango", minval=0, maxval=1, step=0.05, group=group_ob, tooltip="0 = filtro desactivado. 0.5 = el cuerpo debe ser al menos la mitad del rango de la vela")
ob_bodyRatio    = (high - low) > 0 ? math.abs(close - open) / (high - low) : 0
ob_confluenceOK = ob_bodyRatio >= ob_confluence_min_ratio

bullishBreak = show_order_blocks and not na(lastPivotHigh) and ob_crossover  and ob_confluenceOK
bearishBreak = show_order_blocks and not na(lastPivotLow)  and ob_crossunder and ob_confluenceOK

// [Parche 2] ancla = punto MÁS EXTREMO (ya filtrado por ATR) en todo el tramo entre el pivote roto
// y la vela de ruptura, en vez de "la última vela de color opuesto"
findExtremeInRange(bool bullish, int fromBar) =>
    float extremeHigh = na
    float extremeLow  = na
    int   anchorBar   = na
    if not na(fromBar) and fromBar < bar_index   // guardián: evita repetir el error RE10045 de antes
        for idx = fromBar to bar_index - 1
            val = bullish ? ob_parsedLows.get(idx) : ob_parsedHighs.get(idx)
            isNewExtreme = bullish ? (na(extremeLow) or val < extremeLow) : (na(extremeHigh) or val > extremeHigh)
            if isNewExtreme
                extremeHigh := ob_parsedHighs.get(idx)
                extremeLow  := ob_parsedLows.get(idx)
                anchorBar   := idx
    [extremeHigh, extremeLow, anchorBar]

if bullishBreak
    [obH, obL, anchorBar] = findExtremeInRange(true, lastPivotHighBar)
    if not na(obH)
        obT = time[bar_index - anchorBar]   // [Parche 1] tiempo real del ancla, no bar_index
        newBox = box.new(obT, obH, time + 20 * (time - time[1]), obL, border_color=na, bgcolor=ob_bull_color, xloc=xloc.bar_time)
        ob_boxes.unshift(newBox)
        ob_bias.unshift(1)
        ob_high.unshift(obH)
        ob_low.unshift(obL)
        ob_breakCount.unshift(0)
        ob_lastAlertBar.unshift(na)

if bearishBreak
    [obH, obL, anchorBar] = findExtremeInRange(false, lastPivotLowBar)
    if not na(obH)
        obT = time[bar_index - anchorBar]
        newBox = box.new(obT, obH, time + 20 * (time - time[1]), obL, border_color=na, bgcolor=ob_bear_color, xloc=xloc.bar_time)
        ob_boxes.unshift(newBox)
        ob_bias.unshift(-1)
        ob_high.unshift(obH)
        ob_low.unshift(obL)
        ob_breakCount.unshift(0)
        ob_lastAlertBar.unshift(na)

// ---------- MITIGACIÓN: solo por CIERRE, con regla de persistencia ----------
if show_order_blocks and ob_boxes.size() > 0
    for i = ob_boxes.size() - 1 to 0
        bool closedBeyond = ob_bias.get(i) == 1 ? close < ob_low.get(i) : close > ob_high.get(i)

        if closedBeyond
            // suma una vela más cerrando fuera de la zona
            ob_breakCount.set(i, ob_breakCount.get(i) + 1)
        else
            // el precio volvió a cerrar dentro del rango -> se reinicia el contador (el OB se refuerza)
            ob_breakCount.set(i, 0)

        if ob_breakCount.get(i) >= ob_invalidate_bars
            // invalidado: 5 (o las que definas) velas seguidas cerrando más allá sin regresar
            ob_boxes.get(i).delete()
            ob_boxes.remove(i)
            ob_bias.remove(i)
            ob_high.remove(i)
            ob_low.remove(i)
            ob_breakCount.remove(i)
            ob_lastAlertBar.remove(i)
        else
            ob_boxes.get(i).set_right(time + 20 * (time - time[1]))

// ---------- LÍMITE: mostrar solo los últimos N OBs ----------
if show_order_blocks and ob_boxes.size() > ob_max_boxes
    lastBox = ob_boxes.pop()
    lastBox.delete()
    ob_bias.pop()
    ob_high.pop()
    ob_low.pop()
    ob_breakCount.pop()
    ob_lastAlertBar.pop()

// ---------- ALERTA: PRECIO EN ZONA OB (al cierre de vela, con cooldown) ----------
bool ob_zoneAlertThisBar = false

if alert_ob_enabled and ob_boxes.size() > 0
    for i = 0 to ob_boxes.size() - 1
        float obTop    = ob_high.get(i)
        float obBottom = ob_low.get(i)
        bool  inZone   = high >= obBottom and low <= obTop
        int   lastBar  = ob_lastAlertBar.get(i)
        bool  cooldownOver = na(lastBar) or (bar_index - lastBar) >= ob_alert_cooldown_bars

        if inZone and cooldownOver and ob_alert_in_session
            ob_lastAlertBar.set(i, bar_index)
            ob_zoneAlertThisBar := true
            string obType = ob_bias.get(i) == 1 ? "Bullish" : "Bearish"
            string obMsg  = "🟧 " + syminfo.ticker + " (" + timeframe.period + "): precio en zona OB " + obType + " [" + str.tostring(obBottom, format.mintick) + " - " + str.tostring(obTop, format.mintick) + "]"

            if ob_alert_mode == "On Close"
                alert(obMsg, alert.freq_once_per_bar_close)
            else
                alert(obMsg, alert.freq_once_per_bar)

alertcondition(ob_zoneAlertThisBar, "Zona OB (touch)", "Precio dentro de una zona Order Block")

// --- SECCIÓN 1: SMART TREND ENGINE ---
// ---------- FUNCIONES ----------
ma(source, length, MAtype) =>
    switch MAtype
        "SMA"        => ta.sma(source,  length) 
        "EMA"        => ta.ema(source,  length) 
        "SMMA (RMA)" => ta.rma(source,  length) 
        "WMA"        => ta.wma(source,  length) 
        "VWMA"       => ta.vwma(source, length) 
        => na

get_ma(type, src, len) =>
    type == 'SMA' ? ta.sma(src, len) :
     type == 'EMA' ? ta.ema(src, len) :
     type == 'WMA' ? ta.wma(src, len) :
     type == 'RMA' ? ta.rma(src, len) :
     type == 'HMA' ? ta.hma(src, len) :
     type == 'VWMA' ? ta.vwma(src, len) : na

res_call(res, type, val) =>
    tf = res == '1 Minute' ? '1' :
     res == '3 Minutes' ? '3' :
     res == '5 Minutes' ? '5' :
     res == '15 Minutes' ? '15' :
     res == '1 Hour' ? '60' :
     res == 'Day' ? 'D' :
     res == 'Week' ? 'W' :
     timeframe.period

    m = get_ma(type, close, val)

    res == "Normal MA" ? m :
     request.security(syminfo.tickerid, tf, m)

// ---------- SETTINGS ----------
group_ma = "Smart Trend Engine"
show_engine = input.bool(true, "Activate Smart Engine", group=group_ma)
show_cloud_trend = input.bool(true, "Trend Cloud", group=group_ma)
show_cloud_macro = input.bool(true, "Macro Cloud", group=group_ma)
show_bg_state    = input.bool(true, "Market State Background", group=group_ma)

htf_tf = input.timeframe(
     "D",
     "HTF Structure Timeframe",
     group = group_ma)

// ---------- MEDIAS PRINCIPALES ----------
// MARKET STAGE FRAMEWORK

show_ma1   = input(true,         "MA #1", inline = "MA #1", display = display.none)
ma1_type   = input.string("SMA", "",      inline = "MA #1", active = show_ma1, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma1_source = input(close,        "",      inline = "MA #1", active = show_ma1, display = display.none)
ma1_length = input.int(50,       "",      inline = "MA #1", active = show_ma1, minval  = 1)
ma1_color  = input(#faa1a4,    "",      inline = "MA #1", active = show_ma1, display = display.none)

show_ma2   = input(true,         "MA #2", inline = "MA #2", display = display.none)
ma2_type   = input.string("SMA", "",      inline = "MA #2", active = show_ma2, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma2_source = input(close,        "",      inline = "MA #2", active = show_ma2, display = display.none)
ma2_length = input.int(100,       "",      inline = "MA #2", active = show_ma2, minval  = 1)
ma2_color  = input(#c8e6c9,    "",      inline = "MA #2", active = show_ma2, display = display.none)

show_ma3   = input(true,         "MA #3", inline = "MA #3", display = display.none)
ma3_type   = input.string("SMA", "",      inline = "MA #3", active = show_ma3, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma3_source = input(close,        "",      inline = "MA #3", active = show_ma3, display = display.none)
ma3_length = input.int(150,      "",      inline = "MA #3", active = show_ma3, minval  = 1)
ma3_color  = input(#e1bee7,    "",      inline = "MA #3", active = show_ma3, display = display.none)

show_ma4   = input(true,         "MA #4", inline = "MA #4", display = display.none)
ma4_type   = input.string("SMA", "",      inline = "MA #4", active = show_ma4, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma4_source = input(close,        "",      inline = "MA #4", active = show_ma4, display = display.none)
ma4_length = input.int(200,      "",      inline = "MA #4", active = show_ma4, minval  = 1)
ma4_color  = input(#ffffff,    "",      inline = "MA #4", active = show_ma4, display = display.none)

ma1 = show_ma1 ?
 request.security(
     syminfo.tickerid,
     htf_tf,
     ma(close, ma1_length, ma1_type)
 ) : na

ma2 = show_ma2 ?
 request.security(
     syminfo.tickerid,
     htf_tf,
     ma(close, ma2_length, ma2_type)
 ) : na

ma3 = show_ma3 ?
 request.security(
     syminfo.tickerid,
     htf_tf,
     ma(close, ma3_length, ma3_type)
 ) : na

ma4 = show_ma4 ?
 request.security(
     syminfo.tickerid,
     htf_tf,
     ma(close, ma4_length, ma4_type)
 ) : na

// TREND ENGINE
ma_450_1m = res_call("1 Minute", "SMA", 450)
ma_825_1m = res_call("1 Minute", "SMA", 825)
ma_330_5m = res_call("5 Minutes", "SMA", 330)
ma_650_5m = res_call("5 Minutes", "SMA", 650)
ma_1275_5m = res_call("5 Minutes", "SMA", 1275)
ma_750_15m = res_call("15 Minutes", "SMA", 750)
ma_2000_15m = res_call("15 Minutes", "SMA", 1600)

// ---------- SLOPE COLORING ----------
getSlopeColor(ma) =>
    slope = ma - ma[5]

    slope > 0 ?
     slope > slope[1] ?
      color.lime :
      color.aqua :
     slope < slope[1] ?
      color.red :
      color.orange


// ---------- COLORES DINÁMICOS ----------
c_450_1m = getSlopeColor(ma_450_1m)
c_825_1m = getSlopeColor(ma_825_1m)

c_330_5m = getSlopeColor(ma_330_5m)
c_650_5m = getSlopeColor(ma_650_5m)

c_1275_5m = getSlopeColor(ma_1275_5m)
c_750_15m = getSlopeColor(ma_750_15m)

c_2000_15m = getSlopeColor(ma_2000_15m)

// ---------- PLOTS ----------

// MACRO BIAS
p_macro_fast =
 plot(
  show_engine ? ma_330_5m : na,
  title="330 SMA 5m",
  color=color.new(c_330_5m,0),
  linewidth=3)

p_macro_slow =
 plot(
  show_engine ? ma_650_5m : na,
  title="650 SMA 5m",
  color=color.new(c_650_5m,0),
  linewidth=3)

// TREND ENGINE
p_trend_fast =
 plot(
  show_engine ? ma_450_1m : na,
  title="450 SMA 1m",
  color=color.new(c_450_1m,0),
  linewidth=2)

p_trend_slow =
 plot(
  show_engine ? ma_825_1m : na,
  title="825 SMA 1m",
  color=color.new(c_825_1m,0),
  linewidth=3)

p_bias_fast =
 plot(
  show_engine ? ma_1275_5m : na,
  title="1275 SMA 5m",
  color=color.new(c_1275_5m,0),
  linewidth=4)

p_bias_slow =
 plot(
  show_engine ? ma_750_15m : na,
  title="750 SMA 15m",
  color=color.new(c_750_15m,0),
  linewidth=4)

fill(
 p_bias_fast,
 p_bias_slow,
 color =
  ma_1275_5m > ma_750_15m ?
   color.new(color.teal,85) :
   color.new(color.red,88)
 )

// LONG TERM BIAS
plot(
 show_engine ? ma_2000_15m : na,
 title="2000 SMA 15m",
 color=color.new(c_2000_15m, 0),
 linewidth=5
 )


// HTF STRUCTURE
plot(ma1, "MA 50D", ma1_color, display = show_ma1 ? display.all : display.none)
plot(ma2, "MA 100D", ma2_color, display = show_ma2 ? display.all : display.none)
plot(ma3, "MA 150D", ma3_color, display = show_ma3 ? display.all : display.none)
plot(ma4, "MA 200D", ma4_color, display = show_ma4 ? display.all : display.none)

// ---------- CLOUDS ----------
// TREND CLOUD
fill(
 p_trend_fast,
 p_trend_slow,
 color =
  show_cloud_trend ?
   ma_450_1m > ma_825_1m ?
    color.new(color.teal, 85) :
    color.new(color.red, 88)
   : na
 )

// MACRO CLOUD
fill(
 p_macro_fast,
 p_macro_slow,
 color =
  show_cloud_macro ?
   ma_330_5m > ma_650_5m ?
    color.new(color.teal, 85) :
    color.new(color.red, 88)
   : na
 )
 
// --- SECCIÓN 2: EMAs POR TEMPORALIDAD (M1 / M5) ---
group_tf_emas = "EMAs M1 / M5"

is_chart_m1 = timeframe.period == "1"
is_chart_m5 = timeframe.period == "5"

show_m5_emas = is_chart_m1 or is_chart_m5
show_m1_emas = is_chart_m1

ema30_5m = request.security(syminfo.tickerid, "5", ta.ema(close, 30))
ema50_5m = request.security(syminfo.tickerid, "5", ta.ema(close, 50))

ema30_1m = ta.ema(close, 30)
ema50_1m = ta.ema(close, 50)

plot(show_m5_emas ? ema30_5m : na, title="EMA 30 (M5)", color=color.new(#f6c309, 0), linewidth=1)
plot(show_m5_emas ? ema50_5m : na, title="EMA 50 (M5)", color=color.new(#fb9800, 0), linewidth=1)

plot(show_m1_emas ? ema30_1m : na, title="EMA 30 (M1)", color=color.new(#00e5ff, 0), linewidth=1)
plot(show_m1_emas ? ema50_1m : na, title="EMA 50 (M1)", color=color.new(#2979ff, 0), linewidth=1)

// --- PRIOR DAY OHLC (AYER) ---
g_fibo = "Prior Day Levels & Fibs"
show_pd = input.bool(true, "Mostrar Prior OHLC", group=g_fibo)
col_pd  = input.color(color.new(color.gray, 50), "Color Prior Lines", group=g_fibo)
col_fib_sell = input.color(color.new(color.orange,   30), "Fib 0.786 (zona de venta)",  group=g_fibo)
col_fib_buy  = input.color(color.new(#15d4ff, 30), "Fib 0.236 (zona de compra)", group=g_fibo)

// ESTA ES LA LÍNEA QUE CREA LA OPCIÓN EN EL MENÚ:
distancia_etiquetas = input.int(1, "Label space (candles)", minval=0, maxval=50, group=g_fibo)
pd_ob_clearance_m1 = input.int(24, "Despeje extra OB - M1 (velas)", minval=0, maxval=100, group=g_fibo, tooltip="Empuja los textos más allá del alcance visual de los OB cuando el gráfico está en M1.")
pd_ob_clearance_m5 = input.int(24,  "Despeje extra OB - M5 (velas)", minval=0, maxval=100, group=g_fibo, tooltip="Empuja los textos más allá del alcance visual de los OB cuando el gráfico está en M5.")

pd_ob_clearance = timeframe.period == "1" ? pd_ob_clearance_m1 : timeframe.period == "5" ? pd_ob_clearance_m5 : pd_ob_clearance_m1

pd_label_offset = distancia_etiquetas + pd_ob_clearance

is_new_day = ta.change(time("D")) != 0

// Precios de ayer
p_o = request.security(syminfo.tickerid, "D", open[1], lookahead=barmerge.lookahead_on)
p_h = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
p_l = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)
p_c = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)
p_rng = p_h - p_l

// Open de antier (2 días atrás)
p_o2 = request.security(syminfo.tickerid, "D", open[2], lookahead=barmerge.lookahead_on)
// Low de antier (2 días atrás) - solo se usa internamente para invalidar, no se dibuja
p_l2 = request.security(syminfo.tickerid, "D", low[2], lookahead=barmerge.lookahead_on)
// High de antier (2 días atrás) - solo se usa internamente para invalidar el camino bajista, no se dibuja
p_h2 = request.security(syminfo.tickerid, "D", high[2], lookahead=barmerge.lookahead_on)

var line[] pd_lines = array.new_line()
var label[] pd_labels = array.new_label()

if is_new_day and show_pd
    if array.size(pd_lines) > 0
        for i = 0 to array.size(pd_lines) - 1
            line.delete(array.get(pd_lines, i)), label.delete(array.get(pd_labels, i))
        array.clear(pd_lines), array.clear(pd_labels)
    
    lvls = array.from(
       p_o,
       // Por encima de High (Extensiones superiores basadas en Low)
       p_l + p_rng*3.0, p_l + p_rng*2.786, p_l + p_rng*2.27, p_l + p_rng*2.0, p_l + p_rng*1.618, p_l + p_rng*1.5, p_l + p_rng*1.382,
       // Internos (Entre High y Low)
       p_h - p_rng*0.214, p_h - p_rng*0.382, p_h - p_rng*0.5, p_h - p_rng*0.618, p_h - p_rng*0.764,
       // Por debajo de Low (Extensiones inferiores basadas en High)
       p_h - p_rng*1.382, p_h - p_rng*1.5, p_h - p_rng*1.618, p_h - p_rng*2.0, p_h - p_rng*2.27, p_h - p_rng*2.786, p_h - p_rng*3.0
       )
    nms  = array.from(
       "Prior Open",
       "Fib 3.0", "Fib 2.786", "Fib 2.27", "Fib 2.0", "Fib 1.618", "Fib 1.5", "Fib 1.382",
       "Fib 0.786", "Fib 0.618", "Fib 0.5", "Fib 0.382", "Fib 0.236",
       "Fib -0.382", "Fib -0.5", "Fib -0.618", "Fib -1.0", "Fib -1.27", "Fib -1.786", "Fib -2.0"
       )
    
    for i = 0 to array.size(lvls) - 1
        string levelName = array.get(nms, i)
        color   lvlColor  = levelName == "Fib 0.786" ? col_fib_sell : levelName == "Fib 0.236" ? col_fib_buy : col_pd
        l = line.new(bar_index, array.get(lvls, i), bar_index, array.get(lvls, i), color=lvlColor, style=line.style_dotted)
        // Se aplica la distancia aquí al crear
        lbl = label.new(bar_index + pd_label_offset, array.get(lvls, i), array.get(nms, i), textcolor=lvlColor, style=label.style_none, size=size.small)
        array.push(pd_lines, l), array.push(pd_labels, lbl)

if array.size(pd_lines) > 0
    for i = 0 to array.size(pd_lines) - 1
        line.set_x2(array.get(pd_lines, i), bar_index + pd_label_offset)
        label.set_x(array.get(pd_labels, i), bar_index + pd_label_offset)

// --- PRIOR CLOSE: color dinámico por sesgo direccional ---
g_pd_close    = "Prior Close - Sesgo Direccional"
col_bias_bull = input.color(color.new(color.blue,   30), "Sesgo Alcista (precio > Prior Close)", group=g_pd_close)
col_bias_bear = input.color(color.new(color.orange, 30), "Sesgo Bajista (precio < Prior Close)", group=g_pd_close)

var line  pc_line  = na
var label pc_label = na

if is_new_day and show_pd
    if not na(pc_line)
        line.delete(pc_line)
        label.delete(pc_label)

    pc_line  := line.new(bar_index, p_c, bar_index, p_c, color=col_bias_bull, style=line.style_dotted)
    pc_label := label.new(bar_index + pd_label_offset, p_c, "Prior Close", textcolor=col_bias_bull, style=label.style_none, size=size.small)

if show_pd and not na(pc_line)
    bool  bullishBias = close > p_c
    color pc_color    = bullishBias ? col_bias_bull : col_bias_bear

    line.set_x2(pc_line, bar_index + pd_label_offset)
    line.set_color(pc_line, pc_color)
    label.set_x(pc_label, bar_index + pd_label_offset)
    label.set_textcolor(pc_label, pc_color)
 //   label.set_text(pc_label, "Prior Close (" + (bullishBias ? "buy" : "sell") + ")")
    label.set_text(pc_label, "Prior Close")

//PRIOR HIGH / PRIOR LOW: color dinámico por mitigación de liquidez ---
g_pd_hl = "Prior High/Low - Liquidez"
ph_mitigation_mode = input.string("Mecha", "Mitigar por", options=["Mecha", "Cierre"], group=g_pd_hl, tooltip="Mecha: se mitiga apenas el precio toca/supera el nivel. Cierre: solo se mitiga si el precio CIERRA más allá.")
col_ph_active    = input.color(color.new(color.green, 20), "Prior High (sin mitigar)", group=g_pd_hl)
col_ph_mitigated = input.color(color.new(color.green,   40), "Prior High (mitigado)",    group=g_pd_hl)
col_pl_active    = input.color(color.new(color.red,   20), "Prior Low (sin mitigar)",  group=g_pd_hl)
col_pl_mitigated = input.color(color.new(color.red, 40), "Prior Low (mitigado)",     group=g_pd_hl)

var line  ph_line  = na
var line  pl_line  = na
var label ph_label = na
var label pl_label = na
var bool  ph_mitigated = false
var bool  pl_mitigated = false

if is_new_day and show_pd
    if not na(ph_line)
        line.delete(ph_line)
        label.delete(ph_label)
    if not na(pl_line)
        line.delete(pl_line)
        label.delete(pl_label)

    ph_mitigated := false
    pl_mitigated := false

    ph_line  := line.new(bar_index, p_h, bar_index, p_h, color=col_ph_active, style=line.style_dotted)
    ph_label := label.new(bar_index + pd_label_offset, p_h, "Prior High", textcolor=col_ph_active, style=label.style_none, size=size.small)

    pl_line  := line.new(bar_index, p_l, bar_index, p_l, color=col_pl_active, style=line.style_dotted)
    pl_label := label.new(bar_index + pd_label_offset, p_l, "Prior Low", textcolor=col_pl_active, style=label.style_none, size=size.small)

if show_pd and not na(ph_line)
    bool ph_hit = ph_mitigation_mode == "Mecha" ? high > p_h : close > p_h
    if not ph_mitigated and ph_hit
        ph_mitigated := true

    bool pl_hit = ph_mitigation_mode == "Mecha" ? low < p_l : close < p_l
    if not pl_mitigated and pl_hit
        pl_mitigated := true

    ph_color = ph_mitigated ? col_ph_mitigated : col_ph_active
    pl_color = pl_mitigated ? col_pl_mitigated : col_pl_active

    line.set_x2(ph_line, bar_index + pd_label_offset)
    line.set_color(ph_line, ph_color)
    label.set_x(ph_label, bar_index + pd_label_offset)
    label.set_textcolor(ph_label, ph_color)

    line.set_x2(pl_line, bar_index + pd_label_offset)
    line.set_color(pl_line, pl_color)
    label.set_x(pl_label, bar_index + pd_label_offset)
    label.set_textcolor(pl_label, pl_color)

// --- PRIOR OPEN PREV: discount zone with automatic invalidation (bull & bear paths) ---
g_pd_antier          = "Prior Open Prev - Discount Zone"
show_prior_open_prev = input.bool(true, "Show Prior Open Prev", group=g_pd_antier)

col_pop_bull        = input.color(color.new(color.blue,   30), "Bull path: start (above)",           group=g_pd_antier)
col_pop_discount    = input.color(color.new(color.green,  20), "Bull path: discount (drops below)",  group=g_pd_antier)
col_pop_invalid     = input.color(color.new(color.red,    20), "Bull path: invalidated (breaks Low)",group=g_pd_antier)
col_pop_bear        = input.color(color.new(color.orange, 30), "Bear path: start (below)",           group=g_pd_antier)
col_pop_reclaim     = input.color(color.new(color.red,    20), "Bear path: reclaim (retakes level)", group=g_pd_antier)
col_pop_bearInvalid = input.color(color.new(color.green,  20), "Bear path: invalidated (breaks High)",group=g_pd_antier)

var line  pop_line       = na
var label pop_label      = na
var label pop_breakLabel = na
var bool  pop_pathIsBull = true
var bool  pop_stage2     = false
var bool  pop_stage3     = false

if is_new_day and show_pd and show_prior_open_prev
    if not na(pop_line)
        line.delete(pop_line)
        label.delete(pop_label)
    if not na(pop_breakLabel)
        label.delete(pop_breakLabel)

    pop_stage2     := false
    pop_stage3     := false
    pop_pathIsBull := p_c >= p_o2   // el cierre de AYER (no el de hoy) define el camino, ya conocido desde antes de que empiece el día
    pop_breakLabel := na

    pop_line  := line.new(bar_index, p_o2, bar_index, p_o2, color=col_pop_bull, style=line.style_dotted)
    pop_label := label.new(bar_index + pd_label_offset, p_o2, "Prior Open Prev", style=label.style_none, size=size.small)

if show_pd and show_prior_open_prev and not na(pop_line)
    bool belowOpen  = ph_mitigation_mode == "Mecha" ? low  < p_o2 : close < p_o2
    bool aboveOpen  = ph_mitigation_mode == "Mecha" ? high > p_o2 : close > p_o2
    bool belowLow2  = ph_mitigation_mode == "Mecha" ? low  < p_l2 : close < p_l2
    bool aboveHigh2 = ph_mitigation_mode == "Mecha" ? high > p_h2 : close > p_h2

    bool prevStage3 = pop_stage3   // estado ANTES de evaluar esta vela

    if pop_pathIsBull
        if not pop_stage2 and belowOpen
            pop_stage2 := true
        if not pop_stage3 and belowLow2
            pop_stage3 := true
    else
        if not pop_stage2 and aboveOpen
            pop_stage2 := true
        if not pop_stage3 and aboveHigh2
            pop_stage3 := true

    bool justInvalidated = not prevStage3 and pop_stage3   // true SOLO en la vela exacta de la ruptura

    color pop_color = pop_pathIsBull ?
         (pop_stage3 ? col_pop_invalid : pop_stage2 ? col_pop_discount : col_pop_bull) :
         (pop_stage3 ? col_pop_bearInvalid : pop_stage2 ? col_pop_reclaim : col_pop_bear)

    line.set_x2(pop_line, bar_index + pd_label_offset)
    line.set_color(pop_line, pop_color)
    label.set_x(pop_label, bar_index + pd_label_offset)
    label.set_textcolor(pop_label, pop_color)

    if justInvalidated
        float  breakLevel = pop_pathIsBull ? p_l2 : p_h2
        string breakStyle = pop_pathIsBull ? label.style_label_up : label.style_label_down
        pop_breakLabel := label.new(bar_index, breakLevel, "Break", style=breakStyle, textcolor=pop_color, color=color(na), size=size.small)

// --- SECCIÓN 4: SESIONES Y VWAPS ---
// ==========================================
g_ses = "Sessions & VWAP Settings"
tz_in = input.int(0, "UTC Offset (+/-)", group=g_ses, tooltip="Solo para VWAPs y cajas de sesión (Pre-NY, Asia), cuyos horarios están definidos en UTC. El valor normal es 0. El Volume Profile tiene su propio offset aparte.")
tz_str = "UTC" + (tz_in >= 0 ? "+" : "") + str.tostring(tz_in)
show_v_day = input.bool(true, "VWAP Diario", inline="vd", group=g_ses)
col_v_day  = input.color(#a9dcc3, "", inline="vd", group=g_ses)
show_v_ldn = input.bool(true, "VWAP Londres (Euro)", inline="vl", group=g_ses)
col_v_ldn  = input.color(#00ffff, "", inline="vl", group=g_ses)
show_v_pny = input.bool(true, "VWAP Pre-NY (11:30)", inline="vp", group=g_ses)
col_v_pny  = input.color(color.yellow, "", inline="vp", group=g_ses)
show_v_ny  = input.bool(true, "VWAP NY", inline="vn", group=g_ses)
col_v_ny   = input.color(color.orange, "", inline="vn", group=g_ses)
show_v_peuro = input.bool(true, "VWAP Post-Euro", inline="vn", group=g_ses)
col_v_peuro = input.color(color.rgb(218, 165, 32), "", inline="vn", group=g_ses)

// Lógica de VWAPs Anclados
get_session_vwap(session_str) =>
    var float sum_n = 0.0
    var float sum_d = 0.0
    is_active = not na(time(timeframe.period, session_str, tz_str))
    if not is_active[1] and is_active
        sum_n := close * volume
        sum_d := volume
    else if is_active
        sum_n += close * volume
        sum_d += volume
    sum_d > 0 ? sum_n / sum_d : na
 
show_session_vwap =
 timeframe.isminutes and timeframe.multiplier <= 60

plot(
 show_session_vwap and show_v_day ?
 ta.vwap(close) : na,
 "VWAP Diario",
 color=col_v_day,
 linewidth=1)

plot(
 show_session_vwap and show_v_ldn ?
 get_session_vwap("0700-2200") : na,
 "VWAP Euro",
 color=color.new(col_v_ldn, 50),
 style=plot.style_linebr)

plot(
 show_session_vwap and show_v_pny ?
 get_session_vwap("1100-2200") : na,
 "VWAP Pre-NY",
 color=color.new(col_v_pny, 50),
 style=plot.style_linebr)

plot(
 show_session_vwap and show_v_ny ?
 get_session_vwap("1330-2200") : na,
 "VWAP NY",
 color=color.new(col_v_ny, 50),
 style=plot.style_linebr)

plot(
 show_session_vwap and show_v_peuro ?
 get_session_vwap("1630-2200") : na,
 "VWAP Post-Euro",
 color=color.new(col_v_peuro, 50),
 style=plot.style_linebr)

// === NIVELES SEMANALES (MÁXIMOS, MÍNIMOS Y APERTURA) ===
g_week = "Weekly Levels"

show_week_levels = input.bool(
 true,
 "Show Weekly Levels",
 group=g_week)

col_week_open = input.color(
 color.rgb(255, 255, 255, 44),
 "Weekly Open",
 group=g_week)

col_week_hl = input.color(
 #ffffff82,
 "Weekly High/Low",
 group=g_week)

// Detectar nueva semana
bool is_new_week = ta.change(time("W")) != 0

// Variables globales para almacenar los datos semanales
var float week_open = na
var float week_high = na
var float week_low  = na

// Líneas para dibujar los niveles en el gráfico
var line line_open = na
var line line_high = na
var line line_low  = na

// Actualizar valores al iniciar o transcurrir la semana
if show_week_levels and is_new_week
    week_open := open
    week_high := high
    week_low  := low
    
    // Crear nuevas líneas al inicio de la semana
    line_open := line.new(
         bar_index, week_open,
         bar_index, week_open,
         color=color.rgb(255, 255, 255, 44),
         style=line.style_dashed,
         width=1)

    line_high := line.new(
         bar_index, week_high,
         bar_index, week_high,
         color=#ffffff82,
         style=line.style_solid,
         width=1)

    line_low := line.new(
         bar_index, week_low,
         bar_index, week_low,
         color=#ffffff82,
         style=line.style_solid,
         width=1)

else if show_week_levels
    // Actualizar máximos y mínimos durante la semana
    week_high := math.max(high, week_high)
    week_low  := math.min(low, week_low)

    // Línea de apertura semanal
    if not na(line_open)
        line.set_x2(line_open, bar_index)

    // Línea de máximo semanal
    if not na(line_high)
        line.set_x2(line_high, bar_index)
        line.set_y1(line_high, week_high)
        line.set_y2(line_high, week_high)

    // Línea de mínimo semanal
    if not na(line_low)
        line.set_x2(line_low, bar_index)
        line.set_y1(line_low, week_low)
        line.set_y2(line_low, week_low)

// --- RECUADROS DE SESIÓN ---
// Pre-NY
var box box_pny = na
show_pny_box = timeframe.isminutes and timeframe.multiplier <= 60
in_pny =
 show_pny_box and
 not na(time(timeframe.period, "1100-1330", tz_str))
if in_pny
    if not in_pny[1]
        box_pny := box.new(bar_index, high, bar_index, low, bgcolor=color.new(color.yellow, 90), border_color=na)
    else
        box.set_right(box_pny, bar_index)
        box.set_top(box_pny, math.max(high, box.get_top(box_pny)))
        box.set_bottom(box_pny, math.min(low, box.get_bottom(box_pny)))

// ASIA
show_asia = timeframe.isminutes and timeframe.multiplier <= 60
var float asiaHigh = na
var float asiaLow  = na
var box box_as = na
in_as = show_asia and not na(time(timeframe.period, "2100-0700", tz_str))
if in_as
    asiaHigh := math.max(asiaHigh, high)
    asiaLow  := math.min(asiaLow, low)
    if not in_as[1]
        box_as := box.new(bar_index, high, bar_index, low, bgcolor=color.rgb(152, 0, 255, 90), border_color=na)
    else
        box.set_right(box_as, bar_index)
        box.set_top(box_as, math.max(high, box.get_top(box_as)))
        box.set_bottom(box_as, math.min(low, box.get_bottom(box_as)))
if in_as and not in_as[1]
    asiaHigh := high
    asiaLow  := low
plot(show_asia ? asiaHigh : na, "Asia High", color=color.rgb(152, 0, 255, 70))
plot(show_asia ? asiaLow : na, "Asia Low", color=color.rgb(152, 0, 255, 70))
plot(show_asia ? (asiaHigh + asiaLow) / 2 : na, "Asia Mid", color=color.rgb(152, 0, 255, 70))

// --- SECCIÓN: ALERTAS - PRECIO DENTRO DEL CANAL EMA 30/50 (M1 y M5) ---
group_alerts      = "Alertas: Canal EMA 30/50"
alert_m1_enabled  = input.bool(true, "Alertar entrada al canal M1 (EMA30/EMA50)", group=group_alerts)
alert_m5_enabled  = input.bool(true, "Alertar entrada al canal M5 (EMA30/EMA50)", group=group_alerts)

group_alert_time  = "Horario de Alertas (hora Querétaro, UTC-6)"
alert_timezone    = "America/Mexico_City"
m1_alert_session  = input.session("0730-0900",  "Horario alertas M1", group=group_alert_time)
m5_alert_session  = input.session("0730-1130",  "Horario alertas M5", group=group_alert_time)

m1_in_session = not na(time(timeframe.period, m1_alert_session, alert_timezone))
m5_in_session = not na(time(timeframe.period, m5_alert_session, alert_timezone))

// ---------- CANAL M1 (requiere que el chart esté literalmente en M1) ----------
emaCh1Top    = math.max(ema30_1m, ema50_1m)
emaCh1Bottom = math.min(ema30_1m, ema50_1m)
touchingNow1 = is_chart_m1 and low <= emaCh1Top and high >= emaCh1Bottom

var bool wasInChannel1 = false
var bool alertSent1    = false
bool alertCondition1   = false

if is_chart_m1
    newBar1 = ta.change(time) != 0
    if newBar1
        wasInChannel1 := touchingNow1[1]
        alertSent1    := false

    alertCondition1 := alert_m1_enabled and m1_in_session and touchingNow1 and not wasInChannel1 and not alertSent1
    if alertCondition1
        alertSent1 := true

// ---------- CANAL M5 (requiere que el chart esté literalmente en M5) ----------

emaCh5Top    = math.max(ema30_5m, ema50_5m)
emaCh5Bottom = math.min(ema30_5m, ema50_5m)
touchingNow5 = is_chart_m5 and low <= emaCh5Top and high >= emaCh5Bottom

var bool wasInChannel5 = false
var bool alertSent5    = false
bool alertCondition5   = false

if is_chart_m5
    newBar5 = ta.change(time) != 0
    if newBar5
        wasInChannel5 := touchingNow5[1]
        alertSent5    := false

    alertCondition5 := alert_m5_enabled and m5_in_session and touchingNow5 and not wasInChannel5 and not alertSent5
    if alertCondition5
        alertSent5 := true

// ---------- Condiciones clásicas opcionales ----------
alertcondition(alertCondition1, "Canal M1 (entrada)", "🔵 " + "Precio entró al canal EMA30/EMA50 M1")
alertcondition(alertCondition5, "Canal M5 (entrada)", "🟡 " + "Precio entró al canal EMA30/EMA50 M5")

// --- SECCIÓN: VOLUME PROFILE (SESIÓN) - basado en "Volume Profile / Fixed Range" de LonesomeTheBlue (MPL 2.0) ---
group_vp    = "Volume Profile (Sesión)"
show_vp     = input.bool(true, "Mostrar Volume Profile", group=group_vp)
vp_cnum     = input.int(50, "Filas (Row Size)", minval=5, maxval=100, group=group_vp)
vp_percent  = input.float(70., "Value Area Volume %", minval=0, maxval=100, group=group_vp)
vp_session  = input.session("1600-1600", "Horario de sesión", group=group_vp)
vp_utc_offset = input.int(-6, "UTC Offset - Volume Profile (diario y sesiones)", minval=-12, maxval=14, group=group_vp, tooltip="Hora de referencia para el perfil diario y los de Asia/Europa/NY. Querétaro es UTC-6 fijo todo el año.")
vp_timezone  = ("UTC" + (vp_utc_offset >= 0 ? "+" : "") + str.tostring(vp_utc_offset))
vp_hasVolume = ta.cum(nz(volume)) > 0   // si el símbolo nunca ha reportado volumen real, el perfil se apaga solo

vp_up_color    = input.color(color.new(#1592e6, 50), "Volumen alcista (fuera del área de valor)", group=group_vp)
vp_down_color  = input.color(color.new(#1592e6, 50), "Volumen bajista (fuera del área de valor)", group=group_vp)
vp_vup_color   = input.color(color.new(#ffc600, 30), "Volumen alcista (dentro del área de valor)", group=group_vp)
vp_vdown_color = input.color(color.new(#ffc600, 30), "Volumen bajista (dentro del área de valor)", group=group_vp)

vp_poc_color      = input.color(color.new(#ffeb3b, 0), "POC", group=group_vp, inline="vp_poc")
vp_poc_width      = input.int(2, "", minval=1, maxval=5, group=group_vp, inline="vp_poc")
vp_show_poc_label = input.bool(false, "Mostrar etiqueta POC", group=group_vp)

vp_va_color = input.color(color.new(#2962ff, 0), "VAH / VAL", group=group_vp, inline="vp_va")
vp_va_width = input.int(1, "", minval=1, maxval=5, group=group_vp, inline="vp_va")
vp_daily_offset = input.int(30, "Desplazamiento a la derecha (velas)", minval=0, maxval=300, group=group_vp, tooltip="Separa el perfil diario de las velas, dibujándolo como panel flotante a la derecha en vez de sobre el precio histórico.")
vp_daily_flip = input.bool(true, "Invertir orientación (espejo)", group=group_vp, tooltip="El panel siempre crece hacia la derecha; nunca tapa las velas. Este botón invierte cuál lado del volumen (compra o venta) queda pegado a la pared — un espejo del orden interno, no de la dirección de crecimiento.")

// ---------- DETECCIÓN DE SESIÓN (15:00 a 15:00) ----------
vp_sessionTime = time("D", vp_session, vp_timezone)
vp_newSession  = ta.change(vp_sessionTime) != 0

var int vp_sessionStartBar = na
if vp_newSession
    vp_sessionStartBar := bar_index

vp_sessionBars = na(vp_sessionStartBar) ? na : bar_index - vp_sessionStartBar + 1

// ---------- FUNCIÓN AUXILIAR (nivel global, no dentro de un if) ----------
vp_get_vol(y11, y12, y21, y22, height, vol) =>
    nz(math.max(math.min(math.max(y11, y12), math.max(y21, y22)) - math.max(math.min(y11, y12), math.min(y21, y22)), 0) * vol / height)

max_bars_back(high, 1500)
max_bars_back(low, 1500)
max_bars_back(close, 1500)
max_bars_back(open, 1500)
max_bars_back(volume, 1500)

// ---------- CÁLCULO Y DIBUJO (solo en la última vela) ----------
if show_vp and barstate.islast and not na(vp_sessionStartBar)
    float vp_top = na
    float vp_bot = na
    for i = 0 to vp_sessionBars - 1
        vp_top := na(vp_top) ? high[i] : math.max(vp_top, high[i])
        vp_bot := na(vp_bot) ? low[i]  : math.min(vp_bot, low[i])



    vp_dist = (vp_top - vp_bot) / 500
    vp_step = (vp_top - vp_bot) / vp_cnum

    vp_levels = array.new_float(vp_cnum + 1)
    for x = 0 to vp_cnum by 1
        array.set(vp_levels, x, vp_bot + vp_step * x)

    vp_volumes = array.new_float(vp_cnum * 2, 0.)
    for bars = 0 to vp_sessionBars - 1 by 1
        body_top = math.max(close[bars], open[bars])
        body_bot = math.min(close[bars], open[bars])
        itsgreen = close[bars] >= open[bars]
        topwick = high[bars] - body_top
        bottomwick = body_bot - low[bars]
        body = body_top - body_bot
        bodyvol = body * volume[bars] / (2 * topwick + 2 * bottomwick + body)
        topwickvol = 2 * topwick * volume[bars] / (2 * topwick + 2 * bottomwick + body)
        bottomwickvol = 2 * bottomwick * volume[bars] / (2 * topwick + 2 * bottomwick + body)
        for x = 0 to vp_cnum - 1 by 1
            array.set(vp_volumes, x, array.get(vp_volumes, x) + (itsgreen ? vp_get_vol(array.get(vp_levels, x), array.get(vp_levels, x + 1), body_bot, body_top, body, bodyvol) : 0) + vp_get_vol(array.get(vp_levels, x), array.get(vp_levels, x + 1), body_top, high[bars], topwick, topwickvol) / 2 + vp_get_vol(array.get(vp_levels, x), array.get(vp_levels, x + 1), body_bot, low[bars], bottomwick, bottomwickvol) / 2)
            array.set(vp_volumes, x + vp_cnum, array.get(vp_volumes, x + vp_cnum) + (itsgreen ? 0 : vp_get_vol(array.get(vp_levels, x), array.get(vp_levels, x + 1), body_bot, body_top, body, bodyvol)) + vp_get_vol(array.get(vp_levels, x), array.get(vp_levels, x + 1), body_top, high[bars], topwick, topwickvol) / 2 + vp_get_vol(array.get(vp_levels, x), array.get(vp_levels, x + 1), body_bot, low[bars], bottomwick, bottomwickvol) / 2)

    vp_totalvols = array.new_float(vp_cnum, 0.)
    for x = 0 to vp_cnum - 1 by 1
        array.set(vp_totalvols, x, array.get(vp_volumes, x) + array.get(vp_volumes, x + vp_cnum))

    int vp_poc = array.indexof(vp_totalvols, array.max(vp_totalvols))

    vp_totalmax = array.sum(vp_totalvols) * vp_percent / 100.
    vp_va_total = array.get(vp_totalvols, vp_poc)
    int vp_up = vp_poc
    int vp_down = vp_poc
    for x = 0 to vp_cnum - 1 by 1
        if vp_va_total >= vp_totalmax
            break
        vp_uppervol = vp_up < vp_cnum - 1 ? array.get(vp_totalvols, vp_up + 1) : 0.
        vp_lowervol = vp_down > 0 ? array.get(vp_totalvols, vp_down - 1) : 0.
        if vp_uppervol == 0 and vp_lowervol == 0
            break
        if vp_uppervol > vp_lowervol
            vp_va_total += vp_uppervol
            vp_up += 1
        else
            vp_va_total += vp_lowervol
            vp_down -= 1

    vp_maxvol = array.max(vp_totalvols)

    var vp_box_arr     = array.new_box(vp_cnum * 2, na)
    var line vp_poc_line  = na
    var line vp_vah_line  = na
    var line vp_val_line  = na
    var label vp_poc_label   = na
    var label vp_novol_label = na

    if vp_maxvol > 0
        label.delete(vp_novol_label)

        for x = 0 to vp_cnum * 2 - 1 by 1
            array.set(vp_volumes, x, array.get(vp_volumes, x) * vp_sessionBars / (3 * vp_maxvol))

        int vp_anchorBar = bar_index + vp_daily_offset   // la pared: nunca se cruza, en ninguno de los dos modos

        float vp_panelWidth = 0.0
        for x = 0 to vp_cnum - 1 by 1
            float vp_rowWidth = array.get(vp_volumes, x) + array.get(vp_volumes, x + vp_cnum)
            vp_panelWidth := math.max(vp_panelWidth, vp_rowWidth)

        for x = 0 to vp_cnum - 1 by 1
            box.delete(array.get(vp_box_arr, x))
            box.delete(array.get(vp_box_arr, x + vp_cnum))
            bool insideVA = x >= vp_down and x <= vp_up

            float volNearWall = vp_daily_flip ? array.get(vp_volumes, x + vp_cnum) : array.get(vp_volumes, x)
            float volFarWall  = vp_daily_flip ? array.get(vp_volumes, x)           : array.get(vp_volumes, x + vp_cnum)
            color colNearWall = vp_daily_flip ? (insideVA ? vp_vdown_color : vp_down_color) : (insideVA ? vp_vup_color   : vp_up_color)
            color colFarWall  = vp_daily_flip ? (insideVA ? vp_vup_color   : vp_up_color)    : (insideVA ? vp_vdown_color : vp_down_color)

            float vp_rowWidth = volNearWall + volFarWall
            // Normal: la fila arranca pegada a la pared. Espejo: la fila termina pegada a un borde lejano común,
            // y el lado cercano a la pared es el que varía — nunca cruza vp_anchorBar porque vp_rowWidth <= vp_panelWidth.
            int vp_rowStart = vp_daily_flip ? vp_anchorBar + math.round(vp_panelWidth - vp_rowWidth) : vp_anchorBar
            int vp_edge1    = vp_rowStart + math.round(volNearWall)
            int vp_edge2    = vp_edge1 + math.round(volFarWall)

            array.set(vp_box_arr, x, box.new(vp_rowStart, array.get(vp_levels, x + 1) - vp_dist, vp_edge1, array.get(vp_levels, x) + vp_dist, border_width=0, bgcolor = colNearWall))
            array.set(vp_box_arr, x + vp_cnum, box.new(vp_edge1, array.get(vp_levels, x + 1) - vp_dist, vp_edge2, array.get(vp_levels, x) + vp_dist, border_width=0, bgcolor = colFarWall))

        vp_poc_level = (array.get(vp_levels, vp_poc) + array.get(vp_levels, vp_poc + 1)) / 2
        line.delete(vp_poc_line)
        vp_poc_line := line.new(vp_anchorBar, vp_poc_level, vp_anchorBar + 15, vp_poc_level, color=vp_poc_color, width=vp_poc_width)
        
        if vp_show_poc_label
            label.delete(vp_poc_label)
            vp_poc_label := label.new(vp_anchorBar + 20, vp_poc_level, text="POC: " + str.tostring(math.round_to_mintick(vp_poc_level)), style = close >= vp_poc_level ? label.style_label_up : label.style_label_down, textcolor=vp_poc_color, color=color(na))

        vp_vah_level = array.get(vp_levels, vp_up + 1)
        vp_val_level = array.get(vp_levels, vp_down)

        line.delete(vp_vah_line)
        line.delete(vp_val_line)
        vp_vah_line := line.new(vp_anchorBar, vp_vah_level, vp_anchorBar + 15, vp_vah_level, color=vp_va_color, width=vp_va_width, style=line.style_solid)
        vp_val_line := line.new(vp_anchorBar, vp_val_level, vp_anchorBar + 15, vp_val_level, color=vp_va_color, width=vp_va_width, style=line.style_solid)
    else
        for x = 0 to vp_cnum - 1 by 1
            box.delete(array.get(vp_box_arr, x))
            box.delete(array.get(vp_box_arr, x + vp_cnum))
        line.delete(vp_poc_line)
        line.delete(vp_vah_line)
        line.delete(vp_val_line)
        label.delete(vp_poc_label)

        label.delete(vp_novol_label)
        vp_novol_label := label.new(bar_index, close, "Volume Profile: sin datos de volumen válidos en este símbolo", style=label.style_label_down, textcolor=color.gray, color=color(na), size=size.small)

// ---------- POC DESARROLLADO (a nivel raíz, SIN sangría, para que corra en TODAS las velas) ----------
vp_show_dpoc     = input.bool(false, "Mostrar POC Desarrollado", group=group_vp)
vp_dpoc_color    = input.color(color.new(#ffeb3b, 60), "Color POC Desarrollado", group=group_vp)
vp_dpoc_width    = input.int(1, "Ancho línea POC Desarrollado", minval=1, maxval=5, group=group_vp)
vp_dpoc_atr_mult = input.float(4.0, "Rango estimado de sesión (x ATR 200)", minval=0.5, step=0.5, group=group_vp)

var float vp_dpoc_bucketWidth = na
var map<int, float> vp_dpoc_map = na

vp_dpoc_atr = ta.atr(200)   // se calcula cada vela, sin condición

if vp_newSession
    vp_dpoc_bucketWidth := vp_dpoc_atr * vp_dpoc_atr_mult / vp_cnum
    vp_dpoc_map := map.new<int, float>()
    
if show_vp and vp_show_dpoc and vp_hasVolume and not na(vp_dpoc_bucketWidth) and vp_dpoc_bucketWidth > 0
    int bucketLow  = math.floor(low  / vp_dpoc_bucketWidth)
    int bucketHigh = math.floor(high / vp_dpoc_bucketWidth)
    for b = bucketLow to bucketHigh
        float levelBot = b * vp_dpoc_bucketWidth
        float levelTop = (b + 1) * vp_dpoc_bucketWidth
        float volHere  = vp_get_vol(levelBot, levelTop, low, high, high - low, volume)
        float current  = map.contains(vp_dpoc_map, b) ? map.get(vp_dpoc_map, b) : 0.0
        map.put(vp_dpoc_map, b, current + volHere)

var float vp_dpoc_level = na
if show_vp and vp_show_dpoc and not na(vp_dpoc_map)
    if vp_newSession
        vp_dpoc_level := na
    else
        int   bestBucket = na
        float bestVol    = na
        for [k, v] in vp_dpoc_map
            if na(bestVol) or v > bestVol
                bestVol    := v
                bestBucket := k
        vp_dpoc_level := na(bestBucket) ? na : (bestBucket + 0.5) * vp_dpoc_bucketWidth

plot(show_vp and vp_show_dpoc ? vp_dpoc_level : na, title="POC Desarrollado", color=vp_dpoc_color, style=plot.style_stepline, linewidth=vp_dpoc_width)


// --- SECCIÓN: VOLUME PROFILE POR SESIÓN (Asia / Europa / NY) - módulo reutilizable ---
group_vp_sessions = "Volume Profile - Sesiones (Asia/Europa/NY)"

vp_asia_on      = input.bool(true, "Activar sesión Asia",   group=group_vp_sessions, inline="vpa")
vp_asia_session = input.session("1600-0100", "", group=group_vp_sessions, inline="vpa")
vp_asia_color   = input.color(#ab47bc, "Color base Asia", group=group_vp_sessions)

vp_europe_on      = input.bool(true, "Activar sesión Europa", group=group_vp_sessions, inline="vpe")
vp_europe_session = input.session("0100-0730", "", group=group_vp_sessions, inline="vpe")
vp_europe_color   = input.color(#26a69a, "Color base Europa", group=group_vp_sessions)

vp_ny_on      = input.bool(true, "Activar sesión NY", group=group_vp_sessions, inline="vpn")
vp_ny_session = input.session("0730-1600", "", group=group_vp_sessions, inline="vpn")
vp_ny_color   = input.color(#ffa726, "Color base NY", group=group_vp_sessions)

vp_sessions_timezone = vp_timezone

// ---------- EL "MOLDE": estado que necesita cada perfil de sesión ----------
type VPState
    array<box> boxes
    line  pocLine
    line  vahLine
    line  valLine
    label novolLabel
    int   sessionStartBar
    float lastMaxVol

var VPState vp_asiaState   = VPState.new()
var VPState vp_europeState = VPState.new()
var VPState vp_nyState     = VPState.new()

// ---------- LA FUNCIÓN REUTILIZABLE: calcula y dibuja UNA instancia ----------
calcSessionVP(VPState state, string sessionStr, string tz, int cnum, float percent, color baseColor) =>
    sessionTime = time("D", sessionStr, tz)
    inSession   = not na(sessionTime)
    newSession  = inSession and not inSession[1]
    sessionJustEnded = not inSession and inSession[1]

    if newSession
        state.sessionStartBar := bar_index

    if na(state.boxes)
        state.boxes := array.new_box(cnum * 2, na)

    bool shouldCompute = (barstate.islast and inSession) or sessionJustEnded

    if shouldCompute and not na(state.sessionStartBar)
        int refShift = sessionJustEnded ? 1 : 0
        int refBar   = bar_index - refShift
        int sessionBars = refBar - state.sessionStartBar + 1

        float top = na
        float bot = na
        for i = 0 to sessionBars - 1
            top := na(top) ? high[i + refShift] : math.max(top, high[i + refShift])
            bot := na(bot) ? low[i + refShift]  : math.min(bot, low[i + refShift])

        dist = (top - bot) / 500
        step = (top - bot) / cnum

        levels = array.new_float(cnum + 1)
        for x = 0 to cnum by 1
            array.set(levels, x, bot + step * x)

        volumes = array.new_float(cnum * 2, 0.)
        for bars = 0 to sessionBars - 1 by 1
            body_top = math.max(close[bars + refShift], open[bars + refShift])
            body_bot = math.min(close[bars + refShift], open[bars + refShift])
            itsgreen = close[bars + refShift] >= open[bars + refShift]
            topwick = high[bars + refShift] - body_top
            bottomwick = body_bot - low[bars + refShift]
            body = body_top - body_bot
            bodyvol = body * volume[bars + refShift] / (2 * topwick + 2 * bottomwick + body)
            topwickvol = 2 * topwick * volume[bars + refShift] / (2 * topwick + 2 * bottomwick + body)
            bottomwickvol = 2 * bottomwick * volume[bars + refShift] / (2 * topwick + 2 * bottomwick + body)
            for x = 0 to cnum - 1 by 1
                array.set(volumes, x, array.get(volumes, x) + (itsgreen ? vp_get_vol(array.get(levels, x), array.get(levels, x + 1), body_bot, body_top, body, bodyvol) : 0) + vp_get_vol(array.get(levels, x), array.get(levels, x + 1), body_top, high[bars + refShift], topwick, topwickvol) / 2 + vp_get_vol(array.get(levels, x), array.get(levels, x + 1), body_bot, low[bars + refShift], bottomwick, bottomwickvol) / 2)
                array.set(volumes, x + cnum, array.get(volumes, x + cnum) + (itsgreen ? 0 : vp_get_vol(array.get(levels, x), array.get(levels, x + 1), body_bot, body_top, body, bodyvol)) + vp_get_vol(array.get(levels, x), array.get(levels, x + 1), body_top, high[bars + refShift], topwick, topwickvol) / 2 + vp_get_vol(array.get(levels, x), array.get(levels, x + 1), body_bot, low[bars + refShift], bottomwick, bottomwickvol) / 2)

        totalvols = array.new_float(cnum, 0.)
        for x = 0 to cnum - 1 by 1
            array.set(totalvols, x, array.get(volumes, x) + array.get(volumes, x + cnum))

        int poc = array.indexof(totalvols, array.max(totalvols))

        totalmax = array.sum(totalvols) * percent / 100.
        va_total = array.get(totalvols, poc)
        int up = poc
        int down = poc
        for x = 0 to cnum - 1 by 1
            if va_total >= totalmax
                break
            uppervol = up < cnum - 1 ? array.get(totalvols, up + 1) : 0.
            lowervol = down > 0 ? array.get(totalvols, down - 1) : 0.
            if uppervol == 0 and lowervol == 0
                break
            if uppervol > lowervol
                va_total += uppervol
                up += 1
            else
                va_total += lowervol
                down -= 1

        maxvol = array.max(totalvols)
        state.lastMaxVol := maxvol

        if maxvol > 0
            label.delete(state.novolLabel)

            for x = 0 to cnum * 2 - 1 by 1
                array.set(volumes, x, array.get(volumes, x) * sessionBars / (3 * maxvol))

            colorOutside = color.new(baseColor, 50)
            colorInside  = color.new(baseColor, 30)

            for x = 0 to cnum - 1 by 1
                box.delete(array.get(state.boxes, x))
                box.delete(array.get(state.boxes, x + cnum))
                bool insideVA = x >= down and x <= up
                array.set(state.boxes, x, box.new(state.sessionStartBar, array.get(levels, x + 1) - dist, state.sessionStartBar + math.round(array.get(volumes, x)), array.get(levels, x) + dist, border_width=0, bgcolor = insideVA ? colorInside : colorOutside))
                array.set(state.boxes, x + cnum, box.new(state.sessionStartBar + math.round(array.get(volumes, x)), array.get(levels, x + 1) - dist, state.sessionStartBar + math.round(array.get(volumes, x)) + math.round(array.get(volumes, x + cnum)), array.get(levels, x) + dist, border_width=0, bgcolor = insideVA ? colorInside : colorOutside))

            pocLevel = (array.get(levels, poc) + array.get(levels, poc + 1)) / 2
            line.delete(state.pocLine)
            state.pocLine := line.new(state.sessionStartBar, pocLevel, refBar, pocLevel, color=color.new(baseColor, 0), width=2)

            vahLevel = array.get(levels, up + 1)
            valLevel = array.get(levels, down)
            line.delete(state.vahLine)
            line.delete(state.valLine)
            state.vahLine := line.new(state.sessionStartBar, vahLevel, refBar, vahLevel, color=color.new(baseColor, 0), width=1, style=line.style_solid)
            state.valLine := line.new(state.sessionStartBar, valLevel, refBar, valLevel, color=color.new(baseColor, 0), width=1, style=line.style_solid)
            true
        else
            true

    true

// ---------- LLAMADAS: una por sesión ----------
if vp_asia_on
    calcSessionVP(vp_asiaState, vp_asia_session, vp_sessions_timezone, vp_cnum, vp_percent, vp_asia_color)
if vp_europe_on
    calcSessionVP(vp_europeState, vp_europe_session, vp_sessions_timezone, vp_cnum, vp_percent, vp_europe_color)
if vp_ny_on
    calcSessionVP(vp_nyState, vp_ny_session, vp_sessions_timezone, vp_cnum, vp_percent, vp_ny_color)
````
