# Close-Open Gap

- url: https://www.tradingview.com/script/CFG54B81/
- type: indicator
- pine_id: PUB;cb55af0625fb4ba9a4715ae1fbb7dfc1
- version: 1.0

## Description

una herramienta útil, ve mas allá de lo que todos dicen, no mires observa

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © gonFlist - Optimizado para Binance (24/7)

//@version=6
indicator("Close-Open Gap Alert - Binance 500", overlay=true, max_boxes_count=500)

// --- Parámetros ---
minGap = input.float(0.0, "Minimum Gap Size")

// --- Lógica de Apertura Diaria ---
// Detectamos el cambio de día (00:00 UTC) que es cuando abre la vela diaria en Binance
isNewDay = ta.change(time("D")) != 0

// Capturamos el cierre de la vela anterior (ayer) solo cuando cambia el día
var float prevDayClose = na
if isNewDay
    prevDayClose := close[1]

// El Gap real solo ocurre en la primera vela del día (Open de hoy vs Close de ayer)
float gapSize = isNewDay ? (open - prevDayClose) : 0.0

// Señales de Gap
bool finalGapUp   = isNewDay and gapSize > minGap
bool finalGapDown = isNewDay and gapSize < -minGap

// --- Dibujo de Cajas (Limitado a 500 para historial) ---
if finalGapUp
    box.new(left=bar_index-1, top=open, right=bar_index, bottom=prevDayClose,
         bgcolor=color.new(color.green, 80),
         border_color=color.green)

if finalGapDown
    box.new(left=bar_index-1, top=prevDayClose, right=bar_index, bottom=open,
         bgcolor=color.new(color.red, 80),
         border_color=color.red)
````
