# Precision-Vision (Linea Fantasma)

- url: https://www.tradingview.com/script/7aCcBkB8/
- type: indicator
- pine_id: PUB;6a6e3e8420894b07af4a6e4f01ecf886
- version: 1.0

## Description

indicador de previsión a futuro, que se basa en distintos indicadores madres básicos.

## Source Code

````pine
//@version=5
indicator("GEMINI: Precision-Vision (Línea Fantasma)", overlay=true)

// ==========================================
// 1. AJUSTE DE PRECISIÓN MATEMÁTICA
// ==========================================
group_calc = "Cálculo Matemático"
// Para x20, buscamos movimientos del 0.2% al 0.4% reales. 
// Usamos un ATR rápido (10) para reaccionar a la volatilidad inmediata.
atr_period = input.int(10, "Sensibilidad Volatilidad", group=group_calc) 
// Multiplicador 0.5 es el "Sweet Spot" para scalping rápido. Toca y se devuelve.
target_strength = input.float(0.5, "Distancia de Predicción (0.5 = Scalp Rápido)", step=0.1, group=group_calc)

// ==========================================
// 2. VARIABLES INMÓVILES (MEMORIA)
// ==========================================
var float locked_target = na
var string locked_trend = "NEUTRAL"

// Creamos la línea UNA SOLA VEZ. Usaremos style_dashed para que NO TAPE las velas.
var line ghost_line = line.new(na, na, na, na, width=1, style=line.style_dashed)
var label ghost_label = label.new(na, na, text="", style=label.style_label_left, size=size.normal)

// Detectar segundo exacto de nueva vela
is_new_minute = ta.change(time)

// ==========================================
// 3. ANÁLISIS DEL MINUTO PREVIO (FOTO INSTANTÁNEA)
// ==========================================
// Datos del minuto CERRADO [1]
close_prev = close[1]
open_prev = open[1]
high_prev = high[1]
low_prev = low[1]
atr_prev = ta.atr(atr_period)[1]

// Análisis de Fuerza de Vela Anterior
is_green = close_prev > open_prev
is_red = close_prev < open_prev
body_size = math.abs(close_prev - open_prev)

// Filtro de "Ruido": Si la vela anterior fue un Doji (cuerpo enano), no predecimos, es peligroso.
is_noise = body_size < (atr_prev * 0.1) 

// ==========================================
// 4. LÓGICA DE FIJACIÓN (SEGUNDO 00)
// ==========================================

if is_new_minute
    if is_noise
        // Si hay ruido, borramos línea para no confundir
        locked_target := na
        locked_trend := "NEUTRAL"
        line.set_xy1(ghost_line, na, na)
        line.set_xy2(ghost_line, na, na)
        label.set_text(ghost_label, "")
    else
        // CASO 1: CONTINUACIÓN ALCISTA
        // Si vela anterior fue verde, proyectamos continuación desde el CIERRE anterior
        if is_green
            locked_trend := "BULL"
            // Fórmula: Cierre + (Volatilidad * Fuerza)
            locked_target := close_prev + (atr_prev * target_strength)
            
            // CONFIGURACIÓN VISUAL NO INTRUSIVA (VERDE TRANSPARENTE)
            line.set_xy1(ghost_line, bar_index, locked_target)
            line.set_xy2(ghost_line, bar_index + 10, locked_target)
            line.set_color(ghost_line, color.new(color.lime, 30)) // 30% Transparencia
            
            label.set_xy(ghost_label, bar_index + 10, locked_target)
            label.set_text(ghost_label, "TP: " + str.tostring(locked_target, format.mintick))
            label.set_color(ghost_label, color.new(color.lime, 100)) // Fondo invisible
            label.set_textcolor(ghost_label, color.lime) // Solo texto flotante

        // CASO 2: CONTINUACIÓN BAJISTA
        // Si vela anterior fue roja, proyectamos caída desde el CIERRE anterior
        else if is_red
            locked_trend := "BEAR"
            // Fórmula: Cierre - (Volatilidad * Fuerza)
            locked_target := close_prev - (atr_prev * target_strength)
            
            // CONFIGURACIÓN VISUAL NO INTRUSIVA (ROJA TRANSPARENTE)
            line.set_xy1(ghost_line, bar_index, locked_target)
            line.set_xy2(ghost_line, bar_index + 10, locked_target)
            line.set_color(ghost_line, color.new(color.red, 30)) // 30% Transparencia
            
            label.set_xy(ghost_label, bar_index + 10, locked_target)
            label.set_text(ghost_label, "TP: " + str.tostring(locked_target, format.mintick))
            label.set_color(ghost_label, color.new(color.red, 100)) // Fondo invisible
            label.set_textcolor(ghost_label, color.red) // Solo texto flotante

// ==========================================
// 5. MANTENIMIENTO (DURANTE EL MINUTO)
// ==========================================
// La línea se mantiene fija en el eje Y (Precio), solo extendemos el eje X (Tiempo)
// para que la etiqueta no te tape la vela actual.
if not is_new_minute and not na(locked_target)
    line.set_x2(ghost_line, bar_index + 10)
    label.set_xy(ghost_label, bar_index + 10, locked_target)

    // EFECTO VISUAL "HIT" (GOLPE)
    // Si el precio toca la línea, la línea se vuelve sólida momentáneamente para felicitarte
    if (high >= locked_target and locked_trend == "BULL") or (low <= locked_target and locked_trend == "BEAR")
        line.set_style(ghost_line, line.style_solid)
        line.set_width(ghost_line, 2)
    else
        line.set_style(ghost_line, line.style_dashed)
        line.set_width(ghost_line, 1)

// ==========================================
// 6. ALERTAS
// ==========================================
alertcondition(is_new_minute and not na(locked_target), "NUEVA PREDICCIÓN", "Línea ajustada para el nuevo minuto.")
````
