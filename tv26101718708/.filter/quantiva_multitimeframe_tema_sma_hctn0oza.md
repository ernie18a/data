# Quantiva Multi-Timeframe TEMA SMA

- url: https://www.tradingview.com/script/Hctn0OzA-Quantiva-Multi-Timeframe-TEMA-SMA/
- type: indicator
- pine_id: PUB;67cba1f20e2a4afb8d8393931d2b2ece
- version: 1.0

## Description

Quantiva TEMA SMA Multitimeframe is a multi-timeframe trend indicator that combines the power of TEMA (Triple Exponential Moving Average) and SMA across multiple timeframes to deliver a smoother and more reliable market direction signal.

Instead of relying on a single timeframe, this indicator aggregates data from several intervals to create a unified trend line, reducing noise and improving consistency.

Key Features:
Multi-timeframe analysis (5m, 10m, 15m, 30m, 1H)
Advanced smoothing using TEMA
Baseline comparison with SMA
Aggregated average for stronger trend confirmation
Dynamic color change:
Blue → Bullish trend (TEMA > SMA)
Red → Bearish trend (TEMA < SMA)
How it works:

The indicator calculates TEMA and SMA on multiple timeframes and then averages them into a single “Super Trend Line” (Super Quantiva).

This approach:

Filters out market noise
Provides clearer trend direction
Helps avoid false signals from lower timeframes
Ideal for:
Trend-following strategies
Intraday and swing trading
Traders looking for higher timeframe confirmation without switching charts

## Source Code

````pine
//@version=5
indicator("🔵 Quantiva TEMA SMA Multitimeframe", overlay=true)

// === INPUTS CONFIGURABLES ===
temaLength = input.int(75, title="Periodo TEMA")
smaLength  = input.int(50, title="Periodo SMA")

// === FUNCIÓN PARA CALCULAR TEMA ===
temaFunc(src, len) =>
    ema1 = ta.ema(src, len)
    ema2 = ta.ema(ema1, len)
    ema3 = ta.ema(ema2, len)
    3 * (ema1 - ema2) + ema3

// === FUNCIÓN PARA CALCULAR PROMEDIO MTF DE TEMA Y SMA ===
temaMTF(tf) => request.security(syminfo.tickerid, tf, temaFunc(close, temaLength))
smaMTF(tf)  => request.security(syminfo.tickerid, tf, ta.sma(close, smaLength))

tema5  = temaMTF("5")
tema10 = temaMTF("10")
tema15 = temaMTF("15")
tema30 = temaMTF("30")
tema1h = temaMTF("60")

sma5  = smaMTF("5")
sma10 = smaMTF("10")
sma15 = smaMTF("15")
sma30 = smaMTF("30")
sma1h = smaMTF("60")

// === PROMEDIOS FINALES ===
superTILONG = (tema5 + tema10 + tema15 + tema30 + tema1h) / 5
superSMA    = (sma5 + sma10 + sma15 + sma30 + sma1h) / 5

// === COLOR SEGÚN CRUCE
colorLinea = superTILONG > superSMA ? color.blue : color.red

// === PLOT DE LA LÍNEA FINAL
plot(superTILONG, title="Super Quantiva", color=colorLinea, linewidth=2)
````
