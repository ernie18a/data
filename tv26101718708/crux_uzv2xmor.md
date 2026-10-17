# CRUX

- url: https://www.tradingview.com/script/Uzv2XmOr/
- type: indicator
- pine_id: PUB;01db8a8c7efe47f8a3a7f37ad515c2e3
- version: 1.0

## Description

RSI + MACD Buy Signal
Indicador de senales de compra que combina el RSI y el MACD para detectar momentos de alta probabilidad de reversion alcista.
Como funciona:
El indicador monitoriza continuamente el RSI y el MACD. Cuando el RSI baja a zona de sobreventa extrema por debajo de 20 y luego se da la vuelta cruzando al alza ese nivel, y al mismo tiempo el MACD se encuentra en zona negativa, se genera una senal de compra representada por una cruz verde en la parte inferior del panel.
Senal de compra:
Se activa cuando se cumplen dos condiciones simultaneamente. El RSI cruza al alza el nivel 20, confirmando que el precio toco fondo y esta girando. El MACD esta por debajo de -25, confirmando que hay agotamiento vendedor real.
Importante:
Este indicador genera exclusivamente senales de compra. No genera senales de venta. Disenado para buscar rebotes en zonas de sobreventa extrema. Funciona en cualquier activo y temporalidad.
Configuracion recomendada:

Activo: cualquier activo, indices, acciones, forex, cripto, materias primas.
Timeframe: desde 15 minutos hasta diario.
RSI nivel sobreventa: 20 por defecto.
MACD nivel negativo: -25 por defecto, ajustar segun el activo.

Como usarlo:
Espera la cruz verde en la parte inferior. Activa la alerta para recibir notificacion automatica. Usar siempre con gestion de riesgo y stop loss.

## Source Code

````pine
//@version=5
indicator(title="RSI + MACD Señales", shorttitle="RSI+MACD Signals", format=format.price, timeframe="", timeframe_gaps=true)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
src            = input(close,     "Fuente")
rsi_len        = input.int(14,    "RSI Periodo",       minval=1)
fast_length    = input.int(12,    "MACD Fast Length")
slow_length    = input.int(26,    "MACD Slow Length")
signal_length  = input.int(9,     "MACD Signal",       minval=1, maxval=50)
rsi_buy_level  = input.int(20,    "RSI nivel sobreventa")
macd_buy_level = input.float(-25, "MACD nivel negativo maximo")

// ─── MACD ─────────────────────────────────────────────────────────────────────
fast_ma = ta.ema(src, fast_length)
slow_ma = ta.ema(src, slow_length)
macd    = fast_ma - slow_ma
signal  = ta.ema(macd, signal_length)
hist    = macd - signal

col_grow_above = #26A69A
col_grow_below = #FFCDD2
col_fall_above = #B2DFDB
col_fall_below = #EF5350

plot(hist, title="Histograma", style=plot.style_columns,
     color=hist >= 0 ? (hist[1] < hist ? col_grow_above : col_fall_above) :
                       (hist[1] < hist ? col_grow_below : col_fall_below))
plot(macd,   title="MACD",   color=#0094ff, linewidth=2)
plot(signal, title="Signal", color=#ff6a00, linewidth=1)

// ─── RSI ──────────────────────────────────────────────────────────────────────
osc = ta.rsi(src, rsi_len)

scale = input.float(0.005, "RSI escala visual", step=0.001)
move  = input.float(0.05,  "RSI offset visual", step=0.01)

rsi_plot = (osc - 50) * scale - move
plot(rsi_plot, title="RSI", color=color.purple, linewidth=1)

band1 = hline(( 20 * scale) - move, color=color.new(color.purple, 60), linestyle=hline.style_dotted)
band0 = hline((-20 * scale) - move, color=color.new(color.purple, 60), linestyle=hline.style_dotted)
fill(band1, band0, color=color.new(color.purple, 95))

hline(0, "Cero MACD", color=#787B86, linestyle=hline.style_dotted)
hline(macd_buy_level, "MACD nivel", color=color.new(color.green, 60), linestyle=hline.style_dashed)

// ─── SEÑAL PRINCIPAL ──────────────────────────────────────────────────────────
// RSI cruzando al alza el nivel 20 (venia de abajo y sube)
// Y MACD por debajo del nivel negativo configurado
rsi_cross_up = ta.crossover(osc, rsi_buy_level)
macd_negative = macd <= macd_buy_level

buy_signal = rsi_cross_up and macd_negative

plotshape(buy_signal,
     title     = "BUY Signal",
     style     = shape.xcross,
     location  = location.bottom,
     color     = color.new(color.green, 0),
     size      = size.large)

// Colorear la barra cuando hay señal
barcolor(buy_signal ? color.new(color.green, 0) : na)

// ─── ALERTAS ─────────────────────────────────────────────────────────────────
alertcondition(buy_signal, title="BUY RSI+MACD", message="RSI cruzando al alza nivel 20 con MACD negativo — Señal de compra")
````
