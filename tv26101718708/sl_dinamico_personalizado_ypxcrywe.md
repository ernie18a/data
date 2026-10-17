# SL dinamico personalizado

- url: https://www.tradingview.com/script/ypxcryWe/
- type: indicator
- pine_id: PUB;c51d18a815b64cf2bccc3da9ab693a23
- version: 1.0

## Description

mide la distancia en ticks desde el precio actual en tiempo real
personalizable 
- cambia el color
- cambia el estilo de linea 
- configura la distancia en ticks de tu preferencia

disponible para cualquier activo

## Source Code

````pine
//@version=5
indicator("SL dinámico personalizado", overlay=true)

// =====================
// CONFIGURACIÓN
// =====================
ticks = input.int(500, "Distancia en ticks")
longitud = input.int(6, "Longitud hacia la derecha (velas)")

// Colores
color_arriba = input.color(color.red, "Color línea superior")
color_abajo  = input.color(color.red, "Color línea inferior")

// Grosor
grosor_linea = input.int(2, "Grosor de línea", minval=1, maxval=5)

// Estilo
estilo_input = input.string(
     "Sólida",
     "Estilo de línea",
     options = ["Sólida", "Punteada", "Discontinua"])

// Conversión de estilos
estilo_linea = estilo_input == "Sólida" ? line.style_solid :
               estilo_input == "Punteada" ? line.style_dotted :
               line.style_dashed

// =====================
// CÁLCULOS
// =====================
tick_size = syminfo.mintick
distancia = ticks * tick_size

nivel_arriba = close + distancia
nivel_abajo  = close - distancia

// =====================
// VARIABLES DE LÍNEAS
// =====================
var line linea_arriba = na
var line linea_abajo  = na

// =====================
// ACTUALIZAR LÍNEAS
// =====================
if barstate.islast

    // borrar líneas anteriores
    line.delete(linea_arriba)
    line.delete(linea_abajo)

    // crear nuevas líneas
    linea_arriba := line.new(
         x1 = bar_index,
         y1 = nivel_arriba,
         x2 = bar_index + longitud,
         y2 = nivel_arriba,
         color = color_arriba,
         width = grosor_linea,
         style = estilo_linea)

    linea_abajo := line.new(
         x1 = bar_index,
         y1 = nivel_abajo,
         x2 = bar_index + longitud,
         y2 = nivel_abajo,
         color = color_abajo,
         width = grosor_linea,
         style = estilo_linea)
````
