# Zona Horaria

- url: https://www.tradingview.com/script/H85p6O7z/
- type: indicator
- pine_id: PUB;cb85d4858a3f4fa1b323200b3244449b
- version: 1.0

## Description

¡Hola a toda la comunidad! Les comparto este indicador llamado "Zona Horaria", diseñado para facilitar el análisis de sesiones de trading y potenciar las estrategias de rupturas (breakouts) y toma de liquidez.

Este script te permite visualizar de forma limpia y personalizable hasta 3 franjas horarias clave en tu gráfico (ideal para marcar las sesiones de Asia, Londres y Nueva York o "Killzones"), y ofrece una herramienta dinámica para proyectar soportes y resistencias basados en los extremos de cada sesión.

🔥 Características Principales:

- ⏱️ 3 Zonas Horarias Personalizables: Configura el horario de inicio y fin, activa o desactiva cada sesión de forma individual y asígnales colores específicos con opacidad ajustable.

- 🎨 Estilos de Visualización Flexibles: Adapta el indicador a la estética de tu gráfico eligiendo entre:
          Franja: Colorea el fondo vertical completo del gráfico durante el horario de la sesión.
          Rectángulo: Dibuja una caja limpia que envuelve exclusivamente la acción del precio (desde el máximo hasta el mínimo) generada durante la sesión.
          Ninguno: Oculta los fondos si prefieres un gráfico más limpio y solo quieres ver las líneas.

- 📈 Niveles Dinámicos de Ruptura (Líneas Max/Min): La función más potente del indicador. Al activar "Marcar Max/Min", el script rastrea el precio más alto y más bajo alcanzado en la sesión. Al finalizar el horario, proyecta líneas horizontales desde estos extremos hacia el futuro. ¡Estas líneas actúan como niveles clave y se eliminan automáticamente del gráfico en el momento en que el precio las rompe!

💡 ¿Cómo utilizarlo en tu operativa?

1. Ve a la configuración del indicador y define los horarios de tus sesiones operativas según tu zona horaria.
2. Selecciona tu estilo visual preferido (Franja o Rectángulo) para identificar rápidamente en qué momento del día te encuentras.
3. Activa "Marcar Max/Min" si tu estrategia busca operar la manipulación de los rangos (ej. el famoso "Asian Range Breakout"). Las líneas proyectadas te servirán como objetivos visuales (Take Profit) o puntos de entrada al confirmar una ruptura.

Es un código optimizado para no sobrecargar el gráfico, eliminando datos históricos innecesarios gracias al uso eficiente de arrays.

¡Espero que esta herramienta les sea de gran utilidad para mantener sus gráficos organizados y encontrar entradas precisas! Si les gusta o tienen alguna sugerencia para futuras actualizaciones, no duden en dejar un comentario o un "Me gusta" 👍.

## Source Code

````pine
//@version=6
indicator("Zona Horaria", overlay=true, max_lines_count=500, max_boxes_count=500)

// =======================
// Configuración General
// =======================
bg_style = input.string("Franja", options=["Franja", "Rectángulo", "Ninguno"], title="Estilo de Fondo", group="CONFIGURACIÓN GENERAL")

// =======================
// Zona Horaria 1
// =======================
show_tz1    = input.bool(true, title="Zona horaria 1", group="ZONA HORARIA 1")
session1    = input.session("1900-2300", title="Sesión 1", group="ZONA HORARIA 1")
color1      = input.color(color.new(#0000FF, 85), title="Color 1", group="ZONA HORARIA 1")
show_lines1 = input.bool(false, title="Marcar Max/Min", group="ZONA HORARIA 1")

// =======================
// Zona Horaria 2
// =======================
show_tz2    = input.bool(false, title="Zona horaria 2", group="ZONA HORARIA 2")
session2    = input.session("0300-0500", title="Sesión 2", group="ZONA HORARIA 2")
color2      = input.color(color.new(#FF0000, 85), title="Color 2", group="ZONA HORARIA 2")
show_lines2 = input.bool(false, title="Marcar Max/Min", group="ZONA HORARIA 2")

// =======================
// Zona Horaria 3
// =======================
show_tz3    = input.bool(false, title="Zona horaria 3", group="ZONA HORARIA 3")
session3    = input.session("0700-1300", title="Sesión 3", group="ZONA HORARIA 3")
color3      = input.color(color.new(#00FF00, 85), title="Color 3", group="ZONA HORARIA 3")
show_lines3 = input.bool(false, title="Marcar Max/Min", group="ZONA HORARIA 3")

// =======================
// Lógica de Tiempos
// =======================
in_sess1_bool = not na(time(timeframe.period, session1))
in_sess2_bool = not na(time(timeframe.period, session2))
in_sess3_bool = not na(time(timeframe.period, session3))

// =======================
// Fondos Estilo "Franja"
// =======================
bgcolor(show_tz1 and bg_style == "Franja" and in_sess1_bool ? color1 : na, title="Fondo Franja ZH1")
bgcolor(show_tz2 and bg_style == "Franja" and in_sess2_bool ? color2 : na, title="Fondo Franja ZH2")
bgcolor(show_tz3 and bg_style == "Franja" and in_sess3_bool ? color3 : na, title="Fondo Franja ZH3")

// =======================
// Lógica de Líneas y Rectángulos
// =======================

// ====== Zona 1 ======
var line[] active_max_lines1 = array.new_line()
var float[] active_max_vals1 = array.new_float()
var line[] active_min_lines1 = array.new_line()
var float[] active_min_vals1 = array.new_float()

var float current_max1 = na
var float current_min1 = na
var line current_max_line1 = na
var line current_min_line1 = na
var box current_box1 = na

is_new1 = in_sess1_bool and not in_sess1_bool[1]
is_end1 = not in_sess1_bool and in_sess1_bool[1]

if show_tz1
    if is_new1
        current_max1 := high
        current_min1 := low
        
        if show_lines1
            current_max_line1 := line.new(bar_index, high, bar_index, high, color=color.new(color1, 0), width=2)
            current_min_line1 := line.new(bar_index, low, bar_index, low, color=color.new(color1, 0), width=2)
            
        if bg_style == "Rectángulo"
            current_box1 := box.new(bar_index, high, bar_index, low, bgcolor=color1, border_color=na)
            
    else if in_sess1_bool
        if high > current_max1
            current_max1 := high
            if show_lines1
                line.set_xy1(current_max_line1, bar_index, current_max1)
                line.set_y2(current_max_line1, current_max1)
        if low < current_min1
            current_min1 := low
            if show_lines1
                line.set_xy1(current_min_line1, bar_index, current_min1)
                line.set_y2(current_min_line1, current_min1)
        
        if show_lines1
            line.set_x2(current_max_line1, bar_index)
            line.set_x2(current_min_line1, bar_index)
            
        if bg_style == "Rectángulo"
            box.set_top(current_box1, current_max1)
            box.set_bottom(current_box1, current_min1)
            box.set_right(current_box1, bar_index)
        
    if is_end1
        if show_lines1
            array.push(active_max_lines1, current_max_line1)
            array.push(active_max_vals1, current_max1)
            array.push(active_min_lines1, current_min_line1)
            array.push(active_min_vals1, current_min1)

    if show_lines1
        if array.size(active_max_lines1) > 0
            for i = array.size(active_max_lines1) - 1 to 0
                l = array.get(active_max_lines1, i)
                val = array.get(active_max_vals1, i)
                line.set_x2(l, bar_index)
                if high >= val
                    array.remove(active_max_lines1, i)
                    array.remove(active_max_vals1, i)

        if array.size(active_min_lines1) > 0
            for i = array.size(active_min_lines1) - 1 to 0
                l = array.get(active_min_lines1, i)
                val = array.get(active_min_vals1, i)
                line.set_x2(l, bar_index)
                if low <= val
                    array.remove(active_min_lines1, i)
                    array.remove(active_min_vals1, i)

// ====== Zona 2 ======
var line[] active_max_lines2 = array.new_line()
var float[] active_max_vals2 = array.new_float()
var line[] active_min_lines2 = array.new_line()
var float[] active_min_vals2 = array.new_float()

var float current_max2 = na
var float current_min2 = na
var line current_max_line2 = na
var line current_min_line2 = na
var box current_box2 = na

is_new2 = in_sess2_bool and not in_sess2_bool[1]
is_end2 = not in_sess2_bool and in_sess2_bool[1]

if show_tz2
    if is_new2
        current_max2 := high
        current_min2 := low
        
        if show_lines2
            current_max_line2 := line.new(bar_index, high, bar_index, high, color=color.new(color2, 0), width=2)
            current_min_line2 := line.new(bar_index, low, bar_index, low, color=color.new(color2, 0), width=2)
            
        if bg_style == "Rectángulo"
            current_box2 := box.new(bar_index, high, bar_index, low, bgcolor=color2, border_color=na)
            
    else if in_sess2_bool
        if high > current_max2
            current_max2 := high
            if show_lines2
                line.set_xy1(current_max_line2, bar_index, current_max2)
                line.set_y2(current_max_line2, current_max2)
        if low < current_min2
            current_min2 := low
            if show_lines2
                line.set_xy1(current_min_line2, bar_index, current_min2)
                line.set_y2(current_min_line2, current_min2)
        
        if show_lines2
            line.set_x2(current_max_line2, bar_index)
            line.set_x2(current_min_line2, bar_index)
            
        if bg_style == "Rectángulo"
            box.set_top(current_box2, current_max2)
            box.set_bottom(current_box2, current_min2)
            box.set_right(current_box2, bar_index)
        
    if is_end2
        if show_lines2
            array.push(active_max_lines2, current_max_line2)
            array.push(active_max_vals2, current_max2)
            array.push(active_min_lines2, current_min_line2)
            array.push(active_min_vals2, current_min2)

    if show_lines2
        if array.size(active_max_lines2) > 0
            for i = array.size(active_max_lines2) - 1 to 0
                l = array.get(active_max_lines2, i)
                val = array.get(active_max_vals2, i)
                line.set_x2(l, bar_index)
                if high >= val
                    array.remove(active_max_lines2, i)
                    array.remove(active_max_vals2, i)

        if array.size(active_min_lines2) > 0
            for i = array.size(active_min_lines2) - 1 to 0
                l = array.get(active_min_lines2, i)
                val = array.get(active_min_vals2, i)
                line.set_x2(l, bar_index)
                if low <= val
                    array.remove(active_min_lines2, i)
                    array.remove(active_min_vals2, i)

// ====== Zona 3 ======
var line[] active_max_lines3 = array.new_line()
var float[] active_max_vals3 = array.new_float()
var line[] active_min_lines3 = array.new_line()
var float[] active_min_vals3 = array.new_float()

var float current_max3 = na
var float current_min3 = na
var line current_max_line3 = na
var line current_min_line3 = na
var box current_box3 = na

is_new3 = in_sess3_bool and not in_sess3_bool[1]
is_end3 = not in_sess3_bool and in_sess3_bool[1]

if show_tz3
    if is_new3
        current_max3 := high
        current_min3 := low
        
        if show_lines3
            current_max_line3 := line.new(bar_index, high, bar_index, high, color=color.new(color3, 0), width=2)
            current_min_line3 := line.new(bar_index, low, bar_index, low, color=color.new(color3, 0), width=2)
            
        if bg_style == "Rectángulo"
            current_box3 := box.new(bar_index, high, bar_index, low, bgcolor=color3, border_color=na)
            
    else if in_sess3_bool
        if high > current_max3
            current_max3 := high
            if show_lines3
                line.set_xy1(current_max_line3, bar_index, current_max3)
                line.set_y2(current_max_line3, current_max3)
        if low < current_min3
            current_min3 := low
            if show_lines3
                line.set_xy1(current_min_line3, bar_index, current_min3)
                line.set_y2(current_min_line3, current_min3)
        
        if show_lines3
            line.set_x2(current_max_line3, bar_index)
            line.set_x2(current_min_line3, bar_index)
            
        if bg_style == "Rectángulo"
            box.set_top(current_box3, current_max3)
            box.set_bottom(current_box3, current_min3)
            box.set_right(current_box3, bar_index)
        
    if is_end3
        if show_lines3
            array.push(active_max_lines3, current_max_line3)
            array.push(active_max_vals3, current_max3)
            array.push(active_min_lines3, current_min_line3)
            array.push(active_min_vals3, current_min3)

    if show_lines3
        if array.size(active_max_lines3) > 0
            for i = array.size(active_max_lines3) - 1 to 0
                l = array.get(active_max_lines3, i)
                val = array.get(active_max_vals3, i)
                line.set_x2(l, bar_index)
                if high >= val
                    array.remove(active_max_lines3, i)
                    array.remove(active_max_vals3, i)

        if array.size(active_min_lines3) > 0
            for i = array.size(active_min_lines3) - 1 to 0
                l = array.get(active_min_lines3, i)
                val = array.get(active_min_vals3, i)
                line.set_x2(l, bar_index)
                if low <= val
                    array.remove(active_min_lines3, i)
                    array.remove(active_min_vals3, i)
````
