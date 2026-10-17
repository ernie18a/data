# SMA200 + MACD Cross Buy/Sell

- url: https://www.tradingview.com/script/lKfc5BKz/
- type: indicator
- pine_id: PUB;ab4d3751321d40ef9dc25076ab2cab28
- version: 1.0

## Description

SMA200 + MACD Cross Buy/Sell
Este indicador genera señales de compra y venta de alta probabilidad combinando dos indicadores clásicos: la Media Móvil Simple de 200 periodos (SMA 200) y el MACD. Funciona en cualquier activo e índice: acciones, forex, criptomonedas, materias primas e índices.
Señal de COMPRA (BUY):
Se activa cuando se cumplen 4 condiciones simultáneamente:

El precio está por encima de la SMA 200 (tendencia alcista)
El MACD cruza la línea de señal hacia arriba
El cruce ocurre en zona negativa (sobreventa real)
La vela actual cierra en verde (confirmación)

Señal de VENTA (SELL):
Se activa cuando se cumplen 4 condiciones simultáneamente:

El precio está por debajo de la SMA 200 (tendencia bajista)
El MACD cruza la línea de señal hacia abajo
El cruce ocurre en zona positiva (sobrecompra real)
La vela actual cierra en rojo (confirmación)

Configuración recomendada:

Activo: cualquier activo (índices, acciones, forex, cripto, materias primas)
Timeframe: desde 15 minutos hasta diario
MACD: 12, 26, 9 (valores por defecto)

Cómo usarlo:

Etiqueta verde grande BUY → buscar entrada larga
Etiqueta roja grande SELL → buscar entrada corta
Usar siempre con gestión de riesgo y stop loss

## Source Code

````pine
//@version=5
indicator(title='SMA200 + MACD Cross Buy/Sell', shorttitle='SMA200 MACD | 1H', precision=2, overlay=true)

// ─── INDICADORES ──────────────────────────────────────────────────────────────
sma200           = ta.sma(close, 200)
[macdL, sigL, _] = ta.macd(close, 12, 26, 9)

// ─── CONDICIONES COMPRA ───────────────────────────────────────────────────────
above_sma200 = close > sma200
macd_cross_up = ta.crossover(macdL, sigL)
macd_neg      = macdL < 0
green_candle  = close > open

BUY = above_sma200 and macd_cross_up and macd_neg and green_candle

// ─── CONDICIONES VENTA ────────────────────────────────────────────────────────
below_sma200   = close < sma200
macd_cross_dn  = ta.crossunder(macdL, sigL)
macd_pos       = macdL > 0
red_candle     = close < open

SELL = below_sma200 and macd_cross_dn and macd_pos and red_candle

// ─── PLOTS ───────────────────────────────────────────────────────────────────
plot(sma200, title='SMA 200', color=color.new(color.white, 20), linewidth=2)

plotshape(BUY,
     title     = 'BUY',
     style     = shape.labelup,
     location  = location.belowbar,
     color     = color.new(color.green, 0),
     text      = 'BUY',
     textcolor = color.white,
     size      = size.large)

plotshape(SELL,
     title     = 'SELL',
     style     = shape.labeldown,
     location  = location.abovebar,
     color     = color.new(color.red, 0),
     text      = 'SELL',
     textcolor = color.white,
     size      = size.large)

barcolor(BUY ? color.new(color.green, 0) : SELL ? color.new(color.red, 0) : na)

// ─── ALERTAS ─────────────────────────────────────────────────────────────────
alertcondition(BUY,  title='BUY Signal',  message='NASDAQ - Compra: SMA200 + MACD cruzando en zona negativa')
alertcondition(SELL, title='SELL Signal', message='NASDAQ - Venta: SMA200 + MACD cruzando en zona positiva')
alertcondition(BUY or SELL, title='Buy & Sell', message='NASDAQ - Senal de entrada')
````
