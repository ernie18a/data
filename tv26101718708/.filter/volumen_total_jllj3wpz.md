# Volumen total

- url: https://www.tradingview.com/script/jlLJ3wPZ/
- type: indicator
- pine_id: PUB;049d556a9d7949119021e71dc1861f02
- version: 1.0

## Description

mide el volumen delta total y porcentaje de volumen en compra o venta en vivo

## Source Code

````pine
//@version=5
indicator("Estadísticas de Volumen Editables", overlay=true)

// --- CONFIGURACIÓN DE INTERFAZ (INPUTS) ---
grp_table = "Configuración de la Tabla"
pos_table = input.string("top_right", "Posición", options=["top_right", "bottom_right", "top_left", "bottom_left", "middle_right"], group=grp_table)
txt_size  = input.string("normal", "Tamaño del Texto", options=["tiny", "small", "normal", "large", "huge"], group=grp_table)

grp_colors = "Colores y Estética"
header_bg = input.color(color.gray, "Fondo Encabezado", group=grp_colors)
header_tx = input.color(color.white, "Texto Encabezado", group=grp_colors)
cell_bg   = input.color(color.new(color.black, 70), "Fondo de Celdas", group=grp_colors)
text_col  = input.color(color.white, "Color de Texto Datos", group=grp_colors)

// --- CÁLCULOS ---
totVol  = volume
buyVol  = (high == low) ? 0 : volume * (close - low) / (high - low)
sellVol = volume - buyVol

buyPct  = (buyVol / totVol) * 100
sellPct = (sellVol / totVol) * 100

// --- LÓGICA DE LA TABLA ---
var table statsTable = table.new(pos_table, 2, 4, border_width = 1, border_color = color.gray)

if barstate.islast
    // Encabezados
    table.cell(statsTable, 0, 0, "Métrica", bgcolor = header_bg, text_color = header_tx, text_size = txt_size)
    table.cell(statsTable, 1, 0, "Valor", bgcolor = header_bg, text_color = header_tx, text_size = txt_size)
    
    // Fila Volumen Total
    table.cell(statsTable, 0, 1, "Vol. Total", bgcolor = cell_bg, text_color = text_col, text_size = txt_size)
    table.cell(statsTable, 1, 1, str.tostring(totVol, format.volume), bgcolor = cell_bg, text_color = text_col, text_size = txt_size)
    
    // Fila Compras
    table.cell(statsTable, 0, 2, "% Compra", bgcolor = cell_bg, text_color = color.green, text_size = txt_size)
    table.cell(statsTable, 1, 2, str.tostring(buyPct, "#.##") + "%", bgcolor = cell_bg, text_color = color.green, text_size = txt_size)
    
    // Fila Ventas
    table.cell(statsTable, 0, 3, "% Venta", bgcolor = cell_bg, text_color = color.red, text_size = txt_size)
    table.cell(statsTable, 1, 3, str.tostring(sellPct, "#.##") + "%", bgcolor = cell_bg, text_color = color.red, text_size = txt_size)
````
