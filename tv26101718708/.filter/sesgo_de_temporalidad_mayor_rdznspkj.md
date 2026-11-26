# Sesgo de Temporalidad Mayor 

- url: https://www.tradingview.com/script/rdZnspkJ/
- type: indicator
- pine_id: PUB;0b26d83cb5334b35b2ba1427954bc64d
- version: 2.0

## Description

Indicador de sesgo en Temporalidad Diaria. Para quienes operan en temporalidades menores, tener siempre presente el sesgo diario anterior permite proyectar un eventual movimiento en la misma dirección. Se acopla facilmente a una estrategia de seguimiento de tendencia

## Source Code

````pine
//@version=6
indicator("Sesgo de Temporalidad Mayor (Antigravity) v2", overlay=true, max_boxes_count=10, max_labels_count=200)
// =========================================================================
// 1. PARÁMETROS DE ENTRADA (INPUTS)
// =========================================================================
// Grupo: Configuración del Sesgo
grp_bias      = "1. Configuración del Sesgo"
anchor_tf     = input.timeframe("D", "Temporalidad de Sesgo", group=grp_bias, tooltip="Temporalidad mayor en la que se basará el sesgo (ej. 'D' para Diario, 'W' para Semanal, '240' para 4 Horas).")
// Grupo: Configuración de la Estructura (1H y 15m)
grp_struct    = "2. Configuración de Estructura"
show_struct   = input.bool(true, "Mostrar Filas de Estructura", group=grp_struct, tooltip="Activa o desactiva las filas correspondientes a la estructura de 1H y 15m.")
pivot_len     = input.int(10, "Fuerza de los Pivotes (Velas)", minval=1, group=grp_struct, tooltip="Número de velas a la izquierda y derecha para confirmar un Swing High/Low. Valores más altos muestran la estructura general Macro; valores más bajos muestran estructura Micro.")
// Grupo: Configuración del Panel Informativo (Dashboard)
grp_panel     = "3. Panel Flotante"
show_panel    = input.bool(true, "Mostrar Panel Informativo", group=grp_panel)
table_pos     = input.string("Superior Derecha", "Posición del Panel", options=["Superior Derecha", "Superior Izquierda", "Inferior Derecha", "Inferior Izquierda"], group=grp_panel)
table_bg      = input.color(color.new(color.black, 40), "Color de Fondo del Panel", group=grp_panel)
table_text_c  = input.color(color.white, "Color de Texto del Panel", group=grp_panel)
// =========================================================================
// 2. COMPROBACIÓN DE COMPATIBILIDAD DE TEMPORALIDADES
// =========================================================================
// Obtener duraciones en segundos
chart_sec  = timeframe.in_seconds()
anchor_sec = timeframe.in_seconds(anchor_tf)
is_invalid = chart_sec > anchor_sec
// Validación para 1H (3600 segundos) y 15m (900 segundos)
sec_1h     = 3600
sec_15m    = 900
is_1h_invalid  = chart_sec > sec_1h
is_15m_invalid = chart_sec > sec_15m
// =========================================================================
// 3. PETICIÓN SEGURA DE DATOS (SIN REPINTAR) - SESGO PRINCIPAL
// =========================================================================
// Solicitamos la apertura y cierre de la vela ANTERIOR completada de la temporalidad mayor
anchor_open  = request.security(syminfo.tickerid, anchor_tf, open[1], barmerge.gaps_off, barmerge.lookahead_off)
anchor_close = request.security(syminfo.tickerid, anchor_tf, close[1], barmerge.gaps_off, barmerge.lookahead_off)
// Lógica de determinación del sesgo principal
is_bullish = anchor_close > anchor_open
is_bearish = anchor_close < anchor_open
// =========================================================================
// 4. LÓGICA Y PETICIÓN DE ESTRUCTURA DE MERCADO (1H Y 15M)
// =========================================================================
// Función para calcular la estructura basada en Swing Highs / Swing Lows (Pivotes 3-3)
f_market_structure() =>
    // Pivotes de fuerza según configuración
    ph = ta.pivothigh(high, pivot_len, pivot_len)
    pl = ta.pivotlow(low, pivot_len, pivot_len)
    
    // Variables persistentes para los últimos dos pivotes confirmados
    var float ph1 = na
    var float ph_prev = na
    var float pl1 = na
    var float pl_prev = na
    var int trend = 0 // 1 = Alcista, -1 = Bajista, 0 = Rango
    
    // Actualizar pivotes altos
    if not na(ph)
        ph_prev := ph1
        ph1 := ph
        // Si venía alcista y forma un Máximo Menor (LH), pasa a rango
        if trend == 1 and not na(ph_prev) and ph1 < ph_prev
            trend := 0
            
    // Actualizar pivotes bajos
    if not na(pl)
        pl_prev := pl1
        pl1 := pl
        // Si venía bajista y forma un Mínimo Mayor (HL), pasa a rango
        if trend == -1 and not na(pl_prev) and pl1 > pl_prev
            trend := 0
            
    // Confirmación por Cierre de Vela (BOS)
    if not na(ph1) and close > ph1
        trend := 1
    if not na(pl1) and close < pl1
        trend := -1
        
    trend
// Petición segura de la estructura en 1H y 15m sin repintar (se evalúa la vela anterior completada para la tendencia de estructura)
// Pasamos el cálculo completo a request.security para que se evalúe en el marco temporal objetivo
trend_1h   = request.security(syminfo.tickerid, "60", f_market_structure()[1], barmerge.gaps_off, barmerge.lookahead_off)
trend_15m  = request.security(syminfo.tickerid, "15", f_market_structure()[1], barmerge.gaps_off, barmerge.lookahead_off)
// =========================================================================
// 5. RENDERIZADO DEL PANEL INFORMATIVO (TABLA)
// =========================================================================
// Conversor de posición del panel
get_position(pos_str) =>
    switch pos_str
        "Superior Derecha"   => position.top_right
        "Superior Izquierda"  => position.top_left
        "Inferior Derecha"   => position.bottom_right
        => position.bottom_left
// Creamos la tabla con las filas requeridas de forma dinámica
rows_count = show_struct ? 3 : 1
var table bias_table = table.new(get_position(table_pos), 2, rows_count, border_width=1, border_color=color.new(color.gray, 60))
if barstate.islast
    if show_panel
        // --- FILA 0: SESGO PRINCIPAL ---
        if not is_invalid
            table.cell(bias_table, 0, 0, "Sesgo [" + anchor_tf + "]", 
                       text_color=table_text_c, bgcolor=table_bg, text_size=size.small)
            
            status_text = is_bullish ? "ALCISTA 🟢" : (is_bearish ? "BAJISTA 🔴" : "NEUTRAL 🟡")
            status_bg   = is_bullish ? color.new(color.green, 20) : (is_bearish ? color.new(color.red, 20) : color.new(color.gray, 20))
            status_text_c = color.black
            
            table.cell(bias_table, 1, 0, status_text, 
                       text_color=status_text_c, bgcolor=status_bg, text_size=size.small)
        else
            table.cell(bias_table, 0, 0, "Sesgo [" + anchor_tf + "]", 
                       text_color=table_text_c, bgcolor=table_bg, text_size=size.small)
            table.cell(bias_table, 1, 0, "N/A", 
                       text_color=color.black, bgcolor=color.new(color.gray, 20), text_size=size.small)
        
        // --- FILAS DE ESTRUCTURA (SOLO SI ESTÁ ACTIVO) ---
        if show_struct
            // --- FILA 1: ESTRUCTURA 1H ---
            table.cell(bias_table, 0, 1, "Estructura 1H", 
                       text_color=table_text_c, bgcolor=table_bg, text_size=size.small)
            if not is_1h_invalid
                status_text_1h   = trend_1h == 1 ? "ALCISTA 🟢" : (trend_1h == -1 ? "BAJISTA 🔴" : "RANGO 🟡")
                status_bg_1h     = trend_1h == 1 ? color.new(color.green, 20) : (trend_1h == -1 ? color.new(color.red, 20) : color.new(color.gray, 20))
                status_text_c_1h = color.black
                
                table.cell(bias_table, 1, 1, status_text_1h, 
                           text_color=status_text_c_1h, bgcolor=status_bg_1h, text_size=size.small)
            else
                table.cell(bias_table, 1, 1, "N/A", 
                           text_color=color.black, bgcolor=color.new(color.gray, 20), text_size=size.small)
            // --- FILA 2: ESTRUCTURA 15M ---
            table.cell(bias_table, 0, 2, "Estructura 15m", 
                       text_color=table_text_c, bgcolor=table_bg, text_size=size.small)
            if not is_15m_invalid
                status_text_15m   = trend_15m == 1 ? "ALCISTA 🟢" : (trend_15m == -1 ? "BAJISTA 🔴" : "RANGO 🟡")
                status_bg_15m     = trend_15m == 1 ? color.new(color.green, 20) : (trend_15m == -1 ? color.new(color.red, 20) : color.new(color.gray, 20))
                status_text_c_15m = color.black
                
                table.cell(bias_table, 1, 2, status_text_15m, 
                           text_color=status_text_c_15m, bgcolor=status_bg_15m, text_size=size.small)
            else
                table.cell(bias_table, 1, 2, "N/A", 
                           text_color=color.black, bgcolor=color.new(color.gray, 20), text_size=size.small)
    else
        // Limpiamos celdas si el panel flotante está desactivado
        for r = 0 to (rows_count - 1)
            table.cell(bias_table, 0, r, "", bgcolor=color.new(color.white, 100))
            table.cell(bias_table, 1, r, "", bgcolor=color.new(color.white, 100))
// =========================================================================
// 6. ESTRUCTURA LOCAL Y ETIQUETAS DE SWINGS EN EL GRÁFICO
// =========================================================================
// Colores de contraste premium (estilo Material Design)
color_bullish = color.rgb(129, 199, 132)  // Verde pastel
color_bearish = color.rgb(229, 115, 115)  // Rojo pastel
color_range   = color.rgb(189, 189, 189)  // Gris pastel
// Cálculo de los pivotes en la temporalidad local del gráfico
local_ph = ta.pivothigh(high, pivot_len, pivot_len)
local_pl = ta.pivotlow(low, pivot_len, pivot_len)
var float local_ph1 = na
var float local_ph_prev = na
var float local_pl1 = na
var float local_pl_prev = na
var int local_trend = 0
// Variables persistentes para las referencias de las etiquetas activas (se actualiza su color)
var label lbl_high = na
var label lbl_low = na
// Detección de pivote alto y dibujo de etiqueta Swing High
if not na(local_ph)
    local_ph_prev := local_ph1
    local_ph1 := local_ph
    
    // Si venía alcista y forma un Máximo Menor (LH), pasa a rango
    if local_trend == 1 and not na(local_ph_prev) and local_ph1 < local_ph_prev
        local_trend := 0
        
    // Determinar texto estructural (HH o LH)
    is_hh = na(local_ph_prev) or local_ph1 > local_ph_prev
    label_text = is_hh ? "HH" : "LH"
    
    // NO eliminamos la etiqueta anterior para mantener el registro histórico
    // Crear nueva etiqueta (desplazada pivot_len velas atrás)
    lbl_high := label.new(x=bar_index - pivot_len, y=local_ph1, text=label_text, 
                          color=color_range, textcolor=color.black, 
                          style=label.style_label_down, yloc=yloc.price)
// Detección de pivote bajo y dibujo de etiqueta Swing Low
if not na(local_pl)
    local_pl_prev := local_pl1
    local_pl1 := local_pl
    
    // Si venía bajista y forma un Mínimo Mayor (HL), pasa a rango
    if local_trend == -1 and not na(local_pl_prev) and local_pl1 > local_pl_prev
        local_trend := 0
        
    // Determinar texto estructural (HL o LL)
    is_hl = na(local_pl_prev) or local_pl1 > local_pl_prev
    label_text = is_hl ? "HL" : "LL"
    
    // NO eliminamos la etiqueta anterior para mantener el registro histórico
    // Crear nueva etiqueta (desplazada pivot_len velas atrás)
    lbl_low := label.new(x=bar_index - pivot_len, y=local_pl1, text=label_text, 
                         color=color_range, textcolor=color.black, 
                         style=label.style_label_up, yloc=yloc.price)
// Confirmación por Cierre de Vela (BOS) local
if not na(local_ph1) and close > local_ph1
    local_trend := 1
if not na(local_pl1) and close < local_pl1
    local_trend := -1
// Actualización en tiempo real del color del fondo de las etiquetas según la tendencia actual
lbl_color = local_trend == 1 ? color_bullish : (local_trend == -1 ? color_bearish : color_range)
if barstate.islast
    if not na(lbl_high)
        label.set_color(lbl_high, lbl_color)
    if not na(lbl_low)
        label.set_color(lbl_low, lbl_color)
// =========================================================================
// 7. ADVERTENCIA DE TEMPORALIDAD INCOMPATIBLE (SESGO PRINCIPAL)
// =========================================================================
var label warn_lbl = na
if barstate.islast
    label.delete(warn_lbl)
    
    if is_invalid
        warn_text = "⚠️ ¡Temporalidad Incompatible!\nLa temporalidad del gráfico (" + timeframe.period + ") es mayor o igual que la del sesgo (" + anchor_tf + ").\n\nPor favor, cambia el gráfico a una menor temporalidad o aumenta la temporalidad de sesgo en los ajustes del indicador."
                    
        warn_lbl := label.new(x=bar_index, y=close, text=warn_text, 
                              color=color.red, textcolor=color.white, 
                              style=label.style_label_down)
````
