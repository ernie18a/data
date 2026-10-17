# Niveles Algo Pro V2 - 4 Grupos

- url: https://www.tradingview.com/script/uqVsG8Pz/
- type: indicator
- pine_id: PUB;75726082930541b69d9c13fc2ff708ca
- version: 1.0

## Description

sirve para graficar niveles en el grafico relevantes, ideal para los que tienen niveles de diferentes plataformas, para server de 2ad

## Source Code

````pine
//@version=5
indicator("Niveles Algo Pro V2 - 4 Grupos", overlay=true, max_lines_count=500)

// ==========================================
// 1. GESTIÓN DE MEMORIA (Limpieza de PC)
// ==========================================
// Creamos listas para que la PC no se sature de líneas viejas
var g1_l = array.new_line()
var g1_b = array.new_label()
var g2_l = array.new_line()
var g2_b = array.new_label()
var g3_l = array.new_line()
var g3_b = array.new_label()
var g4_l = array.new_line()
var g4_b = array.new_label()

// Función para limpiar la pantalla antes de redibujar
limpiar(lineas, etiquetas) =>
    if array.size(lineas) > 0
        for i = 0 to array.size(lineas) - 1
            line.delete(array.get(lineas, i))
        array.clear(lineas)
    if array.size(etiquetas) > 0
        for i = 0 to array.size(etiquetas) - 1
            label.delete(array.get(etiquetas, i))
        array.clear(etiquetas)

// Función para procesar precios
get_nums(txt) =>
    float[] res = array.new_float()
    parts = str.split(txt, ",")
    if array.size(parts) > 0
        for i = 0 to array.size(parts) - 1
            n = str.tonumber(str.replace_all(array.get(parts, i), " ", ""))
            if not na(n)
                array.push(res, n)
    res

// Función Maestra de Dibujo
dibujar(on, data, col, wid, style, t_start, lbl_on, arr_l, arr_b) =>
    if on and barstate.islast
        limpiar(arr_l, arr_b)
        precios = get_nums(data)
        sty = style == "Punteada" ? line.style_dotted : style == "Discontinua" ? line.style_dashed : line.style_solid
        
        if array.size(precios) > 0
            for i = 0 to array.size(precios) - 1
                p = array.get(precios, i)
                // Dibujamos la línea anclada a TIEMPO y PRECIO
                ln = line.new(t_start, p, time, p, xloc=xloc.bar_time, extend=extend.right, color=col, style=sty, width=wid)
                array.push(arr_l, ln)
                if lbl_on
                    lb = label.new(time + (time - time[1]) * 10, p, str.tostring(p), xloc=xloc.bar_time, color=color.new(col, 100), textcolor=col, style=label.style_label_left, size=size.small)
                    array.push(arr_b, lb)

// ==========================================
// 2. CONFIGURACIÓN DE LOS 4 GRUPOS
// ==========================================

// GRUPO 1
g1_on = input.bool(true, "ON", inline="1", group="GRUPO 1")
g1_t  = input.time(timestamp("2024-02-04 00:00"), "Hora", inline="1", group="GRUPO 1")
g1_d  = input.string("17600.5, 17650", "Precios", group="GRUPO 1")
g1_c  = input.color(#00fbff, "", inline="1b", group="GRUPO 1")
g1_w  = input.int(2, "", inline="1b", group="GRUPO 1")
g1_s  = input.string("Sólida", "", options=["Sólida", "Punteada", "Discontinua"], inline="1b", group="GRUPO 1")
g1_lbl = input.bool(true, "Label", inline="1b", group="GRUPO 1")

// GRUPO 2
g2_on = input.bool(false, "ON", inline="2", group="GRUPO 2")
g2_t  = input.time(timestamp("2024-02-04 00:00"), "Hora", inline="2", group="GRUPO 2")
g2_d  = input.string("", "Precios", group="GRUPO 2")
g2_c  = input.color(#ff0000, "", inline="2b", group="GRUPO 2")
g2_w  = input.int(2, "", inline="2b", group="GRUPO 2")
g2_s  = input.string("Sólida", "", options=["Sólida", "Punteada", "Discontinua"], inline="2b", group="GRUPO 2")
g2_lbl = input.bool(true, "Label", inline="2b", group="GRUPO 2")

// GRUPO 3
g3_on = input.bool(false, "ON", inline="3", group="GRUPO 3")
g3_t  = input.time(timestamp("2024-02-04 00:00"), "Hora", inline="3", group="GRUPO 3")
g3_d  = input.string("", "Precios", group="GRUPO 3")
g3_c  = input.color(#00ff00, "", inline="3b", group="GRUPO 3")
g3_w  = input.int(1, "", inline="3b", group="GRUPO 3")
g3_s  = input.string("Punteada", "", options=["Sólida", "Punteada", "Discontinua"], inline="3b", group="GRUPO 3")
g3_lbl = input.bool(true, "Label", inline="3b", group="GRUPO 3")

// GRUPO 4
g4_on = input.bool(false, "ON", inline="4", group="GRUPO 4")
g4_t  = input.time(timestamp("2024-02-04 00:00"), "Hora", inline="4", group="GRUPO 4")
g4_d  = input.string("", "Precios", group="GRUPO 4")
g4_c  = input.color(#ffffff, "", inline="4b", group="GRUPO 4")
g4_w  = input.int(1, "", inline="4b", group="GRUPO 4")
g4_s  = input.string("Discontinua", "", options=["Sólida", "Punteada", "Discontinua"], inline="4b", group="GRUPO 4")
g4_lbl = input.bool(true, "Label", inline="4b", group="GRUPO 4")

// ==========================================
// 3. EJECUCIÓN
// ==========================================
dibujar(g1_on, g1_d, g1_c, g1_w, g1_s, g1_t, g1_lbl, g1_l, g1_b)
dibujar(g2_on, g2_d, g2_c, g2_w, g2_s, g2_t, g2_lbl, g2_l, g2_b)
dibujar(g3_on, g3_d, g3_c, g3_w, g3_s, g3_t, g3_lbl, g3_l, g3_b)
dibujar(g4_on, g4_d, g4_c, g4_w, g4_s, g4_t, g4_lbl, g4_l, g4_b)
````
