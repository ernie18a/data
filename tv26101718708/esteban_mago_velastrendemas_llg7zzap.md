# Esteban Mago VelasTrendEmas

- url: https://www.tradingview.com/script/llG7zzaP/
- type: indicator
- pine_id: PUB;95fa2c9ab055455cbbaeb7ecc2d8f3ab
- version: 1.0

## Description

// DESCRIPCIÓN — Esteban Mago VelasTrendEmas
// ═══════════════════════════════════════════════════════
// Indicador de coloración de velas basado en la relación
// entre EMA 9 y EMA 20, con detección de tendencia por
// inclinación normalizada de ambas medias.
//
// LÓGICA DE COLORACIÓN:
// → Verde  : EMA9 > EMA20, precio por encima de ambas
//            y pendiente tendencial alcista confirmada
// → Rojo   : EMA9 < EMA20, precio por debajo de ambas
//            y pendiente tendencial bajista confirmada
// → Gris   : cualquier otro contexto — rango, transición
//            o ambigüedad entre las dos EMAs
//
// SEÑALES ADICIONALES:
// → Triángulo verde abajo : cruce alcista EMA9 sobre EMA20
// → Triángulo rojo arriba : cruce bajista EMA9 bajo EMA20
//
// PARÁMETROS CLAVE:
// → slope_thresh : umbral de inclinación para considerar
//   una tendencia válida vs un movimiento lateral
//   Valores bajos = más sensible / Valores altos = más estricto
//
// USO RECOMENDADO:
// Usar como filtro de contexto. Operar en dirección del
// color dominante. Evitar entradas en velas grises.
// Combinar con SwingRevEnvolvente para confirmación de entrada.
//

## Source Code

````pine
//@version=5
indicator("Esteban Mago VelasTrendEmas", overlay=true)

// ═══════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════
ema9_len     = input.int(9,    "EMA Rápida",         group="EMAs")
ema20_len    = input.int(20,   "EMA Lenta",           group="EMAs")
slope_len    = input.int(5,    "Lookback inclinación",group="EMAs")
slope_thresh = input.float(0.0002, "Umbral inclinación tendencial", step=0.0001, group="EMAs")

col_up    = input.color(color.new(color.green, 0),  "Color Alcista", group="Colores")
col_down  = input.color(color.new(color.red, 0),    "Color Bajista", group="Colores")
col_range = input.color(color.new(color.gray, 30),  "Color Rango",   group="Colores")

// ═══════════════════════════════════════════════════════
// EMAs
// ═══════════════════════════════════════════════════════
ema9  = ta.ema(close, ema9_len)
ema20 = ta.ema(close, ema20_len)

// ═══════════════════════════════════════════════════════
// INCLINACIÓN NORMALIZADA
// ═══════════════════════════════════════════════════════
slope9    = (ema9  - ema9[slope_len])  / ema9[slope_len]
slope20   = (ema20 - ema20[slope_len]) / ema20[slope_len]
slope_avg = (slope9 + slope20) / 2

// ═══════════════════════════════════════════════════════
// CONDICIONES DE TENDENCIA
// ═══════════════════════════════════════════════════════
trend_up   = ema9 > ema20 and close > ema9 and close > ema20 and slope_avg >  slope_thresh
trend_down = ema9 < ema20 and close < ema9 and close < ema20 and slope_avg < -slope_thresh

// ═══════════════════════════════════════════════════════
// COLORACIÓN DE VELAS
// ═══════════════════════════════════════════════════════
bar_color = trend_up ? col_up : trend_down ? col_down : col_range
barcolor(bar_color)

// ═══════════════════════════════════════════════════════
// PLOTS DE EMAs
// ═══════════════════════════════════════════════════════
plot(ema9,  "EMA 9",  color=color.new(color.yellow, 0), linewidth=1)
plot(ema20, "EMA 20", color=color.new(color.white,  20), linewidth=2)

// ═══════════════════════════════════════════════════════
// CRUCES — SEÑALES VISUALES
// ═══════════════════════════════════════════════════════
cruce_alcista = ta.crossover(ema9,  ema20)
cruce_bajista = ta.crossunder(ema9, ema20)

plotshape(cruce_alcista, "Cruce Alcista", shape.triangleup,
     location.belowbar, color.lime, size=size.small)
plotshape(cruce_bajista, "Cruce Bajista", shape.triangledown,
     location.abovebar, color.red,  size=size.small)

// ═══════════════════════════════════════════════════════
// ALERTAS
// ═══════════════════════════════════════════════════════
alertcondition(cruce_alcista,                    "Cruce Alcista EMA 9/20", "EMA9 cruzó arriba EMA20")
alertcondition(cruce_bajista,                    "Cruce Bajista EMA 9/20", "EMA9 cruzó abajo EMA20")
alertcondition(not trend_up and not trend_down,  "Mercado en Rango",       "EMAs sin tendencia clara")
````
