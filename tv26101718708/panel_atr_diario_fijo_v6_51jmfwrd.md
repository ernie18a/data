# Panel ATR Diario Fijo v6

- url: https://www.tradingview.com/script/51jMfwrD/
- type: indicator
- pine_id: PUB;5bc193456cf5424288fbaea818922116
- version: 1.0

## Description

Panel DAILY ATR para una rápida y mejor visualización de la volatilidad diaria

## Source Code

````pine
//@version=6
indicator("Panel ATR Diario Fijo v6", overlay=true)

// --- CONFIGURACIÓN DE PARÁMETROS ---
int atrPeriod = input.int(14, title="Período del ATR Diario")
string panelCorner = input.string("Derecha Superior", title="Posición del Panel", options=["Derecha Superior", "Izquierda Superior", "Derecha Inferior", "Izquierda Inferior"])

// --- MAPEO DIRECTO (SIN CONDICIONALES CON ESPACIOS) ---
string posicion = panelCorner == "Izquierda Superior" ? position.top_left : panelCorner == "Derecha Inferior" ? position.bottom_right : panelCorner == "Izquierda Inferior" ? position.bottom_left : position.top_right

// --- CÁLCULO DEL ATR EN TEMPORALIDAD DIARIA ---
float atrDiarioRaw = request.security(syminfo.tickerid, "D", ta.atr(atrPeriod))

// Convertimos el valor del ATR a Pips (Ajustado para Forex/Índices)
float atrEnPips = atrDiarioRaw / syminfo.mintick / 10

// --- CREACIÓN DEL PANEL VISUAL ---
var table panel = table.new(position=posicion, columns=1, rows=2, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.gray)

if barstate.islast
    table.cell(panel, 0, 0, "ATR DIARIO", text_color=color.white, text_size=size.small, bgcolor=color.gray)
    table.cell(panel, 0, 1, str.tostring(atrEnPips, "#.#") + " Pips", text_color=color.green, text_size=size.large)
````
