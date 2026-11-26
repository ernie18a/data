# V2. SDEX-Trend (90)

- url: https://www.tradingview.com/script/yFT9yLM2-V2-SDEX-Trend-90/
- type: indicator
- pine_id: PUB;ea52df7629a14784a020dfdfb46aa0b9
- version: 1.0

## Description

SDEX 90 V2  —  SDEX-Trend (90)

A trend-based view of the SDEX (Skew Dispersion Index) using a long-window
Bollinger envelope. The script plots the SDEX value together with its 90-period
moving average and ±2 standard-deviation bands, providing a regime-classification
overlay rather than a short-term timing signal.

Inputs:
- Length: 90 (default)
- Std. dev. multiplier: 2

How to read:
- SDEX above the upper band  →  favorable skew regime
- SDEX between the bands     →  neutral regime
- SDEX below the lower band  →  adverse skew regime

Designed as a slow-moving context indicator for option-strategy filters, not
as a standalone entry/exit signal. Best used on the daily timeframe.

## Source Code

````pine
// SDEX Trend (Skew) - Corregido
//@version=5
indicator("V2. SDEX-Trend (90)", precision=2, overlay=false)

// Obtención de datos de SDEX con alineación en tiempo real
sdex = request.security("SDEX", "D", close, lookahead=barmerge.lookahead_on)

// Parámetros del indicador
period = input(90, "Period")
ma = ta.sma(sdex, period)
std_dev = ta.stdev(sdex, period)

// Cálculo de las bandas de Bollinger
upper_1BB = ma + std_dev
lower_1BB = ma - std_dev
upper_2BB = ma + (2 * std_dev)
lower_2BB = ma - (2 * std_dev)

// Asignación de colores según las condiciones
dotcolor = sdex > upper_2BB ? color.green :
           sdex > upper_1BB ? color.aqua :
           sdex < lower_2BB ? color.red :
           sdex < lower_1BB ? color.fuchsia :
           color.rgb(204, 199, 199)

// Graficado de los datos
p1 = plot(sdex, title="SDEX", color=dotcolor, linewidth=3, style=plot.style_circles)
p2 = plot(ma, title="SMA", color=color.gray, linewidth=1)
p3 = plot(upper_1BB, title="Upper_1BB", color=#8b8989, linewidth=1)
p4 = plot(lower_1BB, title="Lower_1BB", color=#8b8989, linewidth=1)
p5 = plot(upper_2BB, title="Upper_2BB", color=#8b8989, linewidth=1)
p6 = plot(lower_2BB, title="Lower_2BB", color=#8b8989, linewidth=1)
````
