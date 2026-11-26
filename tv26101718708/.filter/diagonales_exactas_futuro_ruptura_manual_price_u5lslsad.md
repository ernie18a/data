# Diagonales Exactas Futuro + Ruptura (Manual Price)

- url: https://www.tradingview.com/script/u5LslSAD/
- type: indicator
- pine_id: PUB;1de6487c6c9b4b339be6f12e64f0a6de
- version: 1.0

## Description

diagonales especificadas por tiempo de 1 hora, media hora, 15 minutos, 5 minutos, 1 dia, 1 semana. Soportes y resistencias.

## Source Code

````pine
 //@version=6
indicator("Diagonales Exactas Futuro + Ruptura (Manual Price)", overlay = true, max_lines_count = 500, dynamic_requests = true)

// --- Configuración de Colores ---
color_1m  = input.color(color.gray, "1 Minuto", group="Colores")
color_5m  = input.color(color.white, "5 Minutos", group="Colores")
color_15m = input.color(color.aqua, "15 Minutos", group="Colores")
color_30m = input.color(color.aqua, "30 Minutos", group="Colores")
color_1h  = input.color(color.blue, "1 Hora", group="Colores")
color_1d  = input.color(color.red, "1 Día", group="Colores")
color_1w  = input.color(color.purple, "1 Semana", group="Colores")
color_1M  = input.color(color.orange, "1 Mes", group="Colores")

grosor = input.int(1, "Grosor de Líneas", minval=1)

// --- Función de Procesamiento ---
dibujarDiagonales(string tf, color col) =>
    // 1. Obtención de datos mediante tuplas
    [h0, h1, h2, h3, h4, h5, h6, h7, h8, h9, h10] = request.security(syminfo.tickerid, tf, [high[0], high[1], high[2], high[3], high[4], high[5], high[6], high[7], high[8], high[9], high[10]])
    [l0, l1, l2, l3, l4, l5, l6, l7, l8, l9, l10] = request.security(syminfo.tickerid, tf, [low[0], low[1], low[2], low[3], low[4], low[5], low[6], low[7], low[8], low[9], low[10]])
    [t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10] = request.security(syminfo.tickerid, tf, [time[0], time[1], time[2], time[3], time[4], time[5], time[6], time[7], time[8], time[9], time[10]])

    h_vals = array.from(h0, h1, h2, h3, h4, h5, h6, h7, h8, h9, h10)
    l_vals = array.from(l0, l1, l2, l3, l4, l5, l6, l7, l8, l9, l10)
    t_vals = array.from(t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10)

    int vela_ms = int(t0 - t1)
    
    var line[] hh = array.new_line(10)
    var line[] ll = array.new_line(10)
    var line[] hl = array.new_line(10)
    var line[] lh = array.new_line(10)

    if barstate.isfirst
        for i = 0 to 9
            array.set(hh, i, line.new(na, na, na, na, xloc=xloc.bar_time, color=col, width=grosor))
            array.set(ll, i, line.new(na, na, na, na, xloc=xloc.bar_time, color=col, width=grosor))
            array.set(hl, i, line.new(na, na, na, na, xloc=xloc.bar_time, color=col, width=grosor))
            array.set(lh, i, line.new(na, na, na, na, xloc=xloc.bar_time, color=col, width=grosor))

    // 2. Loop de dibujo, proyección y cálculo manual de ruptura
    for i = 0 to 9
        int x1 = int(array.get(t_vals, i+1))
        int x2 = int(array.get(t_vals, i))
        int x_futuro = x2 + (vela_ms * 2)

        float ph1 = array.get(h_vals, i+1), ph2 = array.get(h_vals, i)
        float pl1 = array.get(l_vals, i+1), pl2 = array.get(l_vals, i)

        y1_list = array.from(ph1, pl1, ph1, pl1)
        y2_list = array.from(ph2, pl2, pl2, ph2)
        ln_list = array.from(array.get(hh, i), array.get(ll, i), array.get(hl, i), array.get(lh, i))
        es_techo = array.from(true, false, false, true)

        for j = 0 to 3
            line  ln = array.get(ln_list, j)
            float y1 = array.get(y1_list, j)
            float y2 = array.get(y2_list, j)
            bool  techo = array.get(es_techo, j)

            // --- Cálculo Matemático de la Proyección ---
            // Pendiente: m = (y2 - y1) / (x2 - x1)
            float m = (y2 - y1) / (x2 - x1)
            float y_futuro = y2 + (m * (x_futuro - x2))

            line.set_xy1(ln, x1, y1)
            line.set_xy2(ln, x_futuro, y_futuro)

            // --- Cálculo Manual del Precio Actual de la Línea ---
            // Usamos la ecuación de la recta: y = y1 + m * (x_actual - x1)
            // Esto reemplaza a line.get_price() y funciona con xloc.bar_time
            float precio_linea_ahora = y1 + (m * (time - x1))
            
            // Condición de Ruptura (se vuelve transparente si el precio cruza)
            bool rota = (techo and high > precio_linea_ahora) or (not techo and low < precio_linea_ahora)
            
            line.set_color(ln, rota ? color.new(col, 100) : col)

// --- Ejecución ---
dibujarDiagonales("1",   color_1m)
dibujarDiagonales("5",   color_5m)
dibujarDiagonales("15",  color_15m)
dibujarDiagonales("30",  color_30m)
dibujarDiagonales("60",  color_1h)
dibujarDiagonales("D",   color_1d)
dibujarDiagonales("W",   color_1w)
dibujarDiagonales("M",   color_1M)
````
