# EMA-RSI-ATR Strategy (AXSUSDT - D)

- url: https://www.tradingview.com/script/vpopCZIt/
- type: strategy
- pine_id: PUB;b7417b5e195f4a10a6e08f08b4bd6382
- version: 1.0

## Description

Estrategia EMA-RSI-ATR  (AXSUSDT - Diario)

Esta es una estrategia cuantitativa de seguimiento de tendencia (Trend Following) diseñada para operar en los mercados de criptomonedas de alta y media capitalización. El sistema utiliza una combinación de filtros de tendencia, fuerza relativa y volatilidad para identificar entradas de alta probabilidad en activos volátiles.

🎯 Filosofía del Sistema

El objetivo es capturar el "cuerpo" de los movimientos direccionales fuertes. La estrategia está programada para ignorar mercados en consolidación (laterales) y solo ejecutar órdenes cuando el momentum y la volatilidad confirman que un movimiento tiene altas probabilidades de continuación.

🛠️ Configuración de Indicadores (El "Core")

Estructura de Tendencia (Doble EMA):

Utilizamos la EMA 21 (rápida) y la EMA 89 (lenta).

Solo se permiten compras si la EMA 21 está por encima de la EMA 89 y el precio cierra por encima de la media rápida. Esto garantiza que operamos a favor del flujo institucional.

Filtro de Momentum (RSI de 14 periodos):

Rango Operativo: 55 - 75.

Este filtro es crítico: el valor de 55 asegura que hay fuerza compradora real, mientras que el límite de 75 nos protege de entrar en "clímax" de compras donde el riesgo de retroceso es máximo.

Filtro de Volatilidad (ATR):

Comparamos el ATR actual contra su media móvil de 20 periodos.

Si el mercado no tiene volatilidad (está plano), la estrategia no opera. Esto evita el "desgaste" de la cuenta por señales falsas en rangos estrechos.

🛡️ Gestión de Riesgo y Salidas

La estrategia prioriza la supervivencia del capital mediante niveles dinámicos basados en la volatilidad del activo:

Stop Loss Técnico: Situado a 2.5x ATR del precio de entrada. Esto permite que cada criptomoneda "respire" según su propia volatilidad.

Take Profit: Situado a 4.0x ATR. Buscamos un ratio riesgo/beneficio positivo superior a 1:1.5.

Costes de Operación: El script ya descuenta automáticamente un 0.075% de comisión y aplica 2 ticks de slippage para reflejar resultados de trading real en exchanges como Binance, Bybit o OKX.

📈 Recomendaciones de Uso

Activos: Ideal para BTC, ETH, SOL y otras Altcoins con volumen.

Temporalidad: Optimizado para 4H y 1D.

Gestión: El tamaño de posición por defecto es el 40% del equity, lo que permite una gestión de riesgo profesional (aprox. 1.5% - 2% de riesgo real sobre la cuenta por trade).

📝 Instrucciones de Instalación

Copie el código en su Pine Editor.

Añádalo al gráfico.

En la pestaña de "Configuración", puede ajustar los multiplicadores de ATR y los niveles de RSI para adaptarlos a la volatilidad específica del par que esté analizando.

Descargo de responsabilidad: Los resultados pasados no garantizan beneficios futuros. Realice su propio backtesting antes de operar con capital real.

💡 Un último consejo para tu publicación:

Cuando estés publicando, en la sección de "Categoría", asegúrate de marcar:

Trend Analysis (Análisis de tendencia)

Momentum

Volatilidad

## Source Code

````pine
//@version=6
strategy(
     title         = "EMA-RSI-ATR Strategy (AXSUSDT - D)",
     overlay       = true,
     initial_capital = 10000,
     default_qty_type  = strategy.percent_of_equity,
     default_qty_value = 40,
     commission_type   = strategy.commission.percent,
     commission_value  = 0.075,
     slippage          = 2
 )

// ─── Parámetros ───────────────────────────────────────────────
emaFastLen  = input.int(21,  "EMA Rápida",          group="EMAs")
emaSlowLen  = input.int(89,  "EMA Lenta",           group="EMAs")
rsiLen      = input.int(14,  "RSI Período",         group="RSI")
rsiLow      = input.int(55,  "RSI Mínimo",          group="RSI")
rsiHigh     = input.int(75,  "RSI Máximo",          group="RSI")
atrLen      = input.int(14,  "ATR Período",         group="ATR")
atrMaLen    = input.int(20,  "ATR Media Período",   group="ATR")
slMult      = input.float(2.5, "Stop Loss ATR x",   group="Gestión de riesgo")
tpMult      = input.float(4.0, "Take Profit ATR x", group="Gestión de riesgo")

// ─── Indicadores ──────────────────────────────────────────────
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
rsi     = ta.rsi(close, rsiLen)
atr     = ta.atr(atrLen)
atrMa   = ta.sma(atr, atrMaLen)

// ─── Condiciones de entrada ───────────────────────────────────
trendOk   = emaFast > emaSlow and close > emaFast
momentumOk = rsi > rsiLow and rsi < rsiHigh
volatOk   = atr > atrMa

longSignal = trendOk and momentumOk and volatOk

// ─── Entrada (al cierre de la vela, ejecuta en apertura siguiente)
if longSignal and strategy.position_size == 0
    strategy.entry("Long", strategy.long)

// ─── Stop Loss y Take Profit (ATR en el momento de entrada) ───
var float entryAtr = na

if strategy.position_size > 0 and na(entryAtr)
    entryAtr := atr

if strategy.position_size == 0
    entryAtr := na

stopPrice = strategy.position_avg_price - slMult * entryAtr
tpPrice   = strategy.position_avg_price + tpMult * entryAtr

if strategy.position_size > 0
    strategy.exit("Exit", "Long", stop=stopPrice, limit=tpPrice)

// ─── Plots ────────────────────────────────────────────────────
plot(emaFast, "EMA 21", color=color.new(color.orange, 0),  linewidth=1)
plot(emaSlow, "EMA 89", color=color.new(color.blue, 0),    linewidth=2)

bgcolor(longSignal ? color.new(color.green, 92) : na, title="Señal de entrada")
````
