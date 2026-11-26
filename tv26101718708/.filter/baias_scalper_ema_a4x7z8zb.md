# Baias Scalper EMA

- url: https://www.tradingview.com/script/a4X7z8zB/
- type: indicator
- pine_id: PUB;f7f6fdbd423345f6aaf4c6b7e0e2e922
- version: 1.0

## Description

Este indicador está diseñado para ofrecer una visión rápida, limpia y profesional de la dirección del mercado en múltiples temporalidades (Multi-Timeframe) directamente en tu gráfico. Es una herramienta ideal para traders que necesitan alinear sus operaciones con la tendencia general y evitar operar en momentos de consolidación.

¿Cómo funciona?
A diferencia de los indicadores tradicionales que cambian de estado con un simple cruce (lo que genera mucho "ruido" o señales falsas), este script utiliza un filtro de consistencia. Analiza las últimas 30 velas en relación con la Media Móvil Exponencial (EMA):

ALCISTA: Si el precio cierra por encima de la EMA en al menos el 70% de las últimas 30 velas.

BAJISTA: Si el precio cierra por debajo de la EMA en al menos el 70% de las últimas 30 velas.

NONE (Rango): Si el precio fluctúa alrededor de la EMA sin un dominio claro, filtrando así los mercados laterales.

Características Principales:

Panel Multi-Temporalidad Integrado: Muestra simultáneamente el estado de la tendencia en 1m, 3m, 5m, 15m, 30m y 1h.

Totalmente Configurable: Puedes ajustar la longitud de la EMA (por defecto en 20) según tu estilo de trading.

Filtro de Ruido Matemático: Su lógica de porcentaje (70%) asegura que solo se marquen tendencias sólidas y confirmadas.

Diseño No Intrusivo: Un panel moderno y semitransparente en la esquina superior derecha que no interrumpe tu análisis visual.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MzrinFx

//@version=6
indicator("Dirección Scalper EMA", overlay=true)

// --- [ INPUTS ] ---
emaLen     = input.int(20, "Periodo EMA", minval=1)
lookback   = 30
threshold  = 21 // 70% de dominancia necesaria

// --- [ LÓGICA DE CÁLCULO ] ---
// Función para determinar tendencia en base a dominancia de cierres sobre EMA
checkTrend(len) =>
    emaVal = ta.ema(close, len)
    countAbove = 0
    for i = 0 to lookback - 1
        if close[i] > emaVal[i]
            countAbove += 1
    
    int res = 0 // 0 = NONE
    if countAbove >= threshold
        res := 1 // Alcista
    else if countAbove <= (lookback - threshold)
        res := -1 // Bajista
    res

// --- [ PETICIONES MULTI-TEMPORALIDAD ] ---
s1  = request.security(syminfo.tickerid, "1",  checkTrend(emaLen))
s3  = request.security(syminfo.tickerid, "3",  checkTrend(emaLen))
s5  = request.security(syminfo.tickerid, "5",  checkTrend(emaLen))
s15 = request.security(syminfo.tickerid, "15", checkTrend(emaLen))
s30 = request.security(syminfo.tickerid, "30", checkTrend(emaLen))
s60 = request.security(syminfo.tickerid, "60", checkTrend(emaLen))

// --- [ FUNCIÓN VISUAL ] ---
getLabel(s) =>
    t = "NONE"
    c = color.rgb(148, 163, 184) // Slate 400
    if s == 1
        t := "ALCISTA"
        c := color.rgb(16, 185, 129) // Emerald 500
    else if s == -1
        t := "BAJISTA"
        c := color.rgb(239, 68, 68) // Red 500
    [t, c]

[t1, c1] = getLabel(s1)
[t3, c3] = getLabel(s3)
[t5, c5] = getLabel(s5)
[t15, c15] = getLabel(s15)
[t30, c30] = getLabel(s30)
[t60, c60] = getLabel(s60)

// --- [ RENDERIZADO DE TABLA ] ---
var table board = table.new(position.top_right, 2, 7, border_width=1, border_color=color.new(color.gray, 90), frame_color=color.new(color.gray, 90), bgcolor=color.new(color.black, 20))

// Función interna para rellenar filas (declarada en el entorno global)
fillRow(tbl, row, tf, txt, col) =>
    table.cell(tbl, 0, row, tf, text_color=color.white, text_halign=text.align_left)
    table.cell(tbl, 1, row, txt, text_color=col, text_halign=text.align_center)

if barstate.islast
    // Encabezados con estilo
    table.cell(board, 0, 0, "TIMEFRAME", text_color=color.white, bgcolor=color.new(#1e293b, 0), text_size=size.small)
    table.cell(board, 1, 0, "TENDENCIA", text_color=color.white, bgcolor=color.new(#1e293b, 0), text_size=size.small)
    
    // Llamadas a la función
    fillRow(board, 1, "1 min",  t1,  c1)
    fillRow(board, 2, "3 min",  t3,  c3)
    fillRow(board, 3, "5 min",  t5,  c5)
    fillRow(board, 4, "15 min", t15, c15)
    fillRow(board, 5, "30 min", t30, c30)
    fillRow(board, 6, "1 hora", t60, c60)

// Referencia visual en el gráfico
plot(ta.ema(close, emaLen), "EMA Principal", color=color.new(#10b981, 50), linewidth=2)
````
