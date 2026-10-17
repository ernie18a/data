# Mark Minervini - Trend Template & VCP Filter

- url: https://www.tradingview.com/script/GZnARecv/
- type: indicator
- pine_id: PUB;50612d8421b64b658fbd1987d2ae1015
- version: 1.0

## Description

Combinacion de Plantilla de tendencia con criterios de patron VCP(Mark Minervini)

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © cris84426-messi

//@version=6
//@version=5
indicator("Mark Minervini - Trend Template & VCP Filter", overlay=true, timeframe="")

// ==========================================
// 1. CONFIGURACIÓN DE MEDIAS MÓVILES (MAs)
// ==========================================
ma50  = ta.sma(close, 50)
ma150 = ta.sma(close, 150)
ma200 = ta.sma(close, 200)

// Validación de la tendencia alcista de la MA200 (mínimo 20 días / 1 mes)
ma200_is_up = ma200 > ma200[20] 

// ==========================================
// 2. CONFIGURACIÓN DE MÁXIMOS Y MÍNIMOS (52 Semanas = 250 días bursátiles)
// ==========================================
high_52w = ta.highest(high, 250)
low_52w  = ta.lowest(low, 250)

// Distancias porcentuales requeridas
pct_above_low = ((close - low_52w) / low_52w) * 100
pct_below_high = ((high_52w - close) / high_52w) * 100

// ==========================================
// 3. FILTRO DE LA PLANTILLA DE TENDENCIA
// ==========================================
criterio1 = close > ma150 and close > ma200
criterio2 = ma150 > ma200
criterio3 = ma200_is_up
criterio4 = ma50 > ma150 and ma50 > ma200
criterio5 = close > ma50
criterio6 = pct_above_low >= 30.0
criterio7 = pct_below_high <= 25.0

// Nota: El criterio 8 (Fuerza Relativa IBD > 70) requiere datos externos. 
// Usamos como alternativa matemática la Fuerza Relativa Mansfield clásica frente al SPY.
spy_close = request.security("AMEX:SPY", timeframe.period, close)
mansfield_rs = (close / ta.sma(close, 52)) / (spy_close / ta.sma(spy_close, 52)) - 1
criterio8 = mansfield_rs > 0 // Fuerza relativa positiva frente al mercado

trend_template_valida = criterio1 and criterio2 and criterio3 and criterio4 and criterio5 and criterio6 and criterio7 and criterio8

// ==========================================
// 4. DETECTOR DEL PATRÓN VCP (Aproximación)
// ==========================================
// Medimos el rango de precio (volatilidad) de las últimas barras
rango_actual   = ta.highest(high, 5) - ta.lowest(low, 5)
rango_previo   = ta.highest(high, 20)[5] - ta.lowest(low, 20)[5]
contraccion_p  = rango_actual < (rango_previo * 0.5) // Volatilidad reducida a la mitad

// Secado de Volumen (Volumen por debajo de su media de 20 periodos)
vol_ma = ta.sma(volume, 20)
volumen_seco = volume < vol_ma * 0.7

vcp_detectado = contraccion_p and volumen_seco

// ==========================================
// 5. SEÑAL FINAL DE COMPRA (PUNTO DE PIVOTE)
// ==========================================
// Resistencia horizontal a romper (máximo de los últimos 5 días)
pivote_resistencia = ta.highest(high, 5)[1]
rompe_pivote = ta.crossover(close, pivote_resistencia) and volume > vol_ma

// La señal se activa solo si cumple la Plantilla de Tendencia Y el VCP está listo o rompiendo
compra_minervini = trend_template_valida and (vcp_detectado or rompe_pivote)

// ==========================================
// 6. VISUALIZACIÓN EN EL GRÁFICO
// ==========================================
// Dibujar Medias Móviles
plot(ma50, color=color.blue, title="MA 50")
plot(ma150, color=color.orange, title="MA 150")
plot(ma200, color=color.red, linewidth=2, title="MA 200")

// Pintar el fondo del gráfico cuando la acción está en "Superrendimiento" (Fase 2)
bgcolor(trend_template_valida ? color.new(color.green, 95) : na)

// Señales visuales de compra
plotshape(series=compra_minervini, title="Compra Minervini", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, text="VCP BUY")
````
