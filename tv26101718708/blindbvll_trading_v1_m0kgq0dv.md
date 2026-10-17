# BlindBvll Trading v1

- url: https://www.tradingview.com/script/M0KgQ0Dv/
- type: indicator
- pine_id: PUB;c409538c18224f4b919149079b57d547
- version: 3.0

## Description

Indicador all-in-one de Smart Money Concepts (SMC) optimizado para sesiones europeas. Integra sesiones horarias ajustadas automáticamente al cambio de hora de Madrid (Europe/Madrid), proyección del Asian Range H/L con cierre automático al ser tocado, PDH/PDL del día anterior anclados al extremo exacto que los originó, y detección de FVG, IFVG, Order Blocks y Breaker Blocks con mitigación por porcentaje de llenado configurable. Todos los POIs se autolimpian al ser rebalanceados por el precio o al superar la ventana de día actual + día anterior, evitando acumulación visual. Totalmente personalizable: color de fondo, borde, grosor y estilo de línea independientes para cada elemento. Alertas nativas para Asia H/L y PDH/PDL con disparo único por día y reset automático.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BlindBvll

//@version=6
indicator("BlindBvll Trading v1", overlay = true)

// ─── INPUTS ───────────────────────────────────────────────────
ma_len    = input.int   (20,        "Periodo",  minval = 1)
ma_src    = input.source(close,     "Fuente")
ma_type   = input.string("EMA",     "Tipo",     options = ["EMA","SMA","WMA"])
ma_col    = input.color (color.new(#f5c518, 0), "Color")
ma_width  = input.int   (2,         "Grosor",   minval = 1, maxval = 4)

// ─── CÁLCULO ──────────────────────────────────────────────────
ma = switch ma_type
    "EMA" => ta.ema(ma_src, ma_len)
    "SMA" => ta.sma(ma_src, ma_len)
    "WMA" => ta.wma(ma_src, ma_len)

// ─── PLOT ─────────────────────────────────────────────────────
plot(ma, "MA", color = ma_col, linewidth = ma_width)
````
