# Niveles Multitemporalidad [1H, 1D, 1W, 1M]

- url: https://www.tradingview.com/script/lBWgvwsb/
- type: indicator
- pine_id: PUB;9cf0715e145644de9e53756f0b622549
- version: 2.0

## Description

marca soportes y resistencias de distintas temporalidades

## Source Code

````pine
//@version=5
indicator("Niveles Multitemporalidad [1H, 1D, 1W, 1M]", overlay=true, max_lines_count=500)

// --- Configuración de Entradas ---
color_1h = input.color(color.blue, "Color 1 Hora")
color_1d = input.color(color.red, "Color 1 Día")
color_1w = input.color(color.purple, "Color 1 Semana")
color_1m = input.color(color.orange, "Color 1 Mes")

show_1h = input.bool(true, "Mostrar 1 Hora")
show_1d = input.bool(true, "Mostrar 1 Día")
show_1w = input.bool(true, "Mostrar 1 Semana")
show_1m = input.bool(true, "Mostrar 1 Mes")

// --- Función robusta para obtener datos MTF (Evita el bug del array ID nulo) ---
f_get_tf_data(tf) =>
    // Pedimos los datos históricos como tuplas en lugar de pedir que el contexto de security genere el arreglo.
    [h0, h1, h2, h3, h4] = request.security(syminfo.tickerid, tf, [high[0], high[1], high[2], high[3], high[4]])
    [l0, l1, l2, l3, l4] = request.security(syminfo.tickerid, tf, [low[0], low[1], low[2], low[3], low[4]])
    [o0, o1, o2, o3, o4] = request.security(syminfo.tickerid, tf, [open[0], open[1], open[2], open[3], open[4]])
    [c0, c1, c2, c3, c4] = request.security(syminfo.tickerid, tf, [close[0], close[1], close[2], close[3], close[4]])
    [t0, t1, t2, t3, t4] = request.security(syminfo.tickerid, tf, [time[0], time[1], time[2], time[3], time[4]])
    
    // Construimos el arreglo de forma segura en el contexto local (Garantiza que el ID del arreglo nunca se corrompa)
    h_arr = array.from(h0, h1, h2, h3, h4)
    l_arr = array.from(l0, l1, l2, l3, l4)
    o_arr = array.from(o0, o1, o2, o3, o4)
    c_arr = array.from(c0, c1, c2, c3, c4)
    t_arr = array.from(t0, t1, t2, t3, t4)
    
    [h_arr, l_arr, o_arr, c_arr, t_arr]

// --- Peticiones de datos Multi-Temporalidad ---
[h_1h, l_1h, o_1h, c_1h, t_1h] = f_get_tf_data("60")
[h_1d, l_1d, o_1d, c_1d, t_1d] = f_get_tf_data("D")
[h_1w, l_1w, o_1w, c_1w, t_1w] = f_get_tf_data("W")
[h_1m, l_1m, o_1m, c_1m, t_1m] = f_get_tf_data("M")

// --- Arreglo para gestionar el dibujado ---
var line[] all_lines = array.new_line()

// --- Función principal de dibujo ---
draw_levels(show, col, h_arr, l_arr, o_arr, c_arr, t_arr) =>
    if show
        for i = 0 to 4 
            float h = array.get(h_arr, i)
            float l = array.get(l_arr, i)
            float o = array.get(o_arr, i)
            float c = array.get(c_arr, i)
            int   t = array.get(t_arr, i)

            // Validación de datos: Evita intentar dibujar cuando un elemento específico no existe (ej: gráficos muy recientes)
            if not na(t) and not na(h) and not na(l) and not na(o) and not na(c)
                int start_idx = bar_index
                int max_lookback = int(math.min(4999, bar_index)) // Lookback seguro
                
                for j = 0 to max_lookback
                    if time[j] <= t
                        start_idx := bar_index - j
                        break

                // 1. Trazar siempre las Mechas (Líneas Sólidas)
                array.push(all_lines, line.new(start_idx, h, start_idx+1, h, color=col, extend=extend.right, style=line.style_solid))
                array.push(all_lines, line.new(start_idx, l, start_idx+1, l, color=col, extend=extend.right, style=line.style_solid))
                
                // 2. Condición para los Cuerpos (Líneas Punteadas)
                if i == 0
                    // VELA ACTUAL: Solo dibujamos la Apertura
                    array.push(all_lines, line.new(start_idx, o, start_idx+1, o, color=col, extend=extend.right, style=line.style_dashed))
                else
                    // VELAS HISTÓRICAS: Dibujamos Apertura y Cierre
                    float body_high = math.max(o, c)
                    float body_low  = math.min(o, c)
                    array.push(all_lines, line.new(start_idx, body_high, start_idx+1, body_high, color=col, extend=extend.right, style=line.style_dashed))
                    array.push(all_lines, line.new(start_idx, body_low,  start_idx+1, body_low,  color=col, extend=extend.right, style=line.style_dashed))

// --- Ejecución ---
if barstate.islast
    // 1. Limpiar las líneas viejas
    if array.size(all_lines) > 0
        for i = 0 to array.size(all_lines) - 1
            line.delete(array.get(all_lines, i))
        array.clear(all_lines)
    
    // 2. Dibujar todo
    draw_levels(show_1h, color_1h, h_1h, l_1h, o_1h, c_1h, t_1h)
    draw_levels(show_1d, color_1d, h_1d, l_1d, o_1d, c_1d, t_1d)
    draw_levels(show_1w, color_1w, h_1w, l_1w, o_1w, c_1w, t_1w)
    draw_levels(show_1m, color_1m, h_1m, l_1m, o_1m, c_1m, t_1m)
````
