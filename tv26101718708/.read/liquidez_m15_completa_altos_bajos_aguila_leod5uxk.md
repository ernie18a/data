# Liquidez M15 Completa (Altos + Bajos) - AGUILA

- url: https://www.tradingview.com/script/leOd5uxK/
- type: indicator
- pine_id: PUB;c0bea8d6cc044b268b3d5f261813ce66
- version: 1.0

## Description

El script hará esto:

Detecta el máximo previo (swing high) en M15
Espera que el precio:
Rompa ese nivel (tome liquidez)
Cierre por debajo (rechazo)
Marca una señal de venta (liquidity grab)

## Source Code

````pine
//@version=5
indicator("Liquidez M15 Completa (Altos + Bajos)", overlay=true)

// ===== INPUT =====
tf = input.timeframe("15", "Temporalidad")
lookback = input.int(10, "Velas para niveles")

// ===== DATOS MTF =====
mtf_high  = request.security(syminfo.tickerid, tf, high)
mtf_low   = request.security(syminfo.tickerid, tf, low)
mtf_close = request.security(syminfo.tickerid, tf, close)

// ===== NIVELES =====
prev_high = ta.highest(mtf_high[1], lookback)
prev_low  = ta.lowest(mtf_low[1], lookback)

// ===== LIQUIDEZ =====
// SELL (toma de altos)
liq_sell = mtf_high > prev_high and mtf_close < prev_high

// BUY (toma de bajos)
liq_buy = mtf_low < prev_low and mtf_close > prev_low

// ===== VISUAL =====
plot(prev_high, color=color.red, linewidth=1, title="High Liquidez")
plot(prev_low, color=color.green, linewidth=1, title="Low Liquidez")

plotshape(liq_sell,
     title="LIQ SELL",
     location=location.abovebar,
     color=color.red,
     style=shape.labeldown,
     text="SELL")

plotshape(liq_buy,
     title="LIQ BUY",
     location=location.belowbar,
     color=color.green,
     style=shape.labelup,
     text="BUY")

// ===== ALERTAS =====
alertcondition(liq_sell,
     title="Liquidez SELL",
     message="Tomaron liquidez arriba → posible caída")

alertcondition(liq_buy,
     title="Liquidez BUY",
     message="Tomaron liquidez abajo → posible subida")
````
