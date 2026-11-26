# 2. Liquidez Institucional (Auto-Corte) Andreas

- url: https://www.tradingview.com/script/1xPddJqV/
- type: indicator
- pine_id: PUB;379df9a73d4b4b8796402187ec1f4864
- version: 1.0

## Description

Aparición: En cuanto hay confluencia (Bancos + RSI + Volumen), sale la línea hacia la derecha al infinito.

Desaparición: En el momento en que una mecha o cuerpo de vela toca el precio de la línea, el indicador le dice: "Ya has llegado, para aquí". La línea se queda "anclada" en esa vela y deja de seguir hacia el futuro.

Interpretación: Las líneas que veas que siguen extendiéndose hacia la derecha son niveles de liquidez virgen. Esos son tus objetivos de entrada más potentes porque el precio aún tiene que ir a buscarlos.

## Source Code

````pine
//@version=5
indicator("2. Liquidez Institucional (Auto-Corte)", overlay=true, max_lines_count=500)

// --- CONFIGURACIÓN ---
volMult = input.float(1.6, "Filtro Volumen Bancos", step=0.1)
rsiLen = input.int(14, "Periodo RSI")

// --- 1. DETECCIÓN DE HUELLA ---
avgVol = ta.sma(volume, 20)
esBancos = volume > (avgVol * volMult)
rsi = ta.rsi(close, rsiLen)

c_compra = (close > high[1] and esBancos and rsi < 40)
c_venta = (close < low[1] and esBancos and rsi > 60)

// --- 2. GESTIÓN DE LÍNEAS CON CORTE (MITIGACIÓN) ---
// Usamos una caja (box) pequeña o línea que se actualiza
var line[] lineas_activas = array.new_line()

if c_compra
    array.push(lineas_activas, line.new(bar_index, low[1], bar_index + 1, low[1], color=color.new(color.lime, 20), width=2, extend=extend.right))

if c_venta
    array.push(lineas_activas, line.new(bar_index, high[1], bar_index + 1, high[1], color=color.new(color.red, 20), width=2, extend=extend.right))

// Lógica de corte: Si el precio toca la línea, dejamos de extenderla
if array.size(lineas_activas) > 0
    for i = array.size(lineas_activas) - 1 to 0
        l = array.get(lineas_activas, i)
        precio_linea = line.get_y1(l)
        
        // Si el precio actual cruza el nivel de la línea, cortamos la extensión
        if (low < precio_linea and high > precio_linea)
            line.set_extend(l, extend.none)
            line.set_x2(l, bar_index)
            array.remove(lineas_activas, i)
````
