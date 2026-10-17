# MACD Buy Signal NAS100

- url: https://www.tradingview.com/script/KLuh1IGF/
- type: indicator
- pine_id: PUB;96c5341219534ceaa4156a65ad05a4a0
- version: 1.0

## Description

Aqui tienes la descripcion lista para pegar en TradingView:

MACD Buy Signal NAS100
Indicador de senales de compra basado en el MACD, disenado especificamente para operar en el Nasdaq en temporalidad de 1 hora. Genera senales de compra de alta probabilidad cuando el MACD se encuentra en zona de sobreventa extrema y comienza a girar al alza.
Como funciona:
El indicador monitoriza el MACD continuamente. Cuando el MACD esta por debajo de -100 puntos, indicando sobreventa extrema en el Nasdaq, y en ese momento el MACD cruza al alza la linea de senal, se genera una senal de compra representada por un circulo verde en la parte inferior del panel.
Senal de compra:
Se activa cuando se cumplen dos condiciones simultaneamente. El MACD esta por debajo de -100 puntos, confirmando agotamiento vendedor real. El MACD cruza al alza la linea de senal, confirmando que el momentum esta girando a favor de los compradores.
Importante:
Este indicador genera exclusivamente senales de compra. No genera senales de venta. Disenado para capturar rebotes en zonas de agotamiento vendedor extremo en el Nasdaq. Funciona en cualquier activo ajustando el nivel del MACD desde los inputs.
Configuracion recomendada:

Activo: Nasdaq NAS100 o US100.
Timeframe: 1 hora.
MACD Fast Length: 12 por defecto.
MACD Slow Length: 26 por defecto.
MACD Signal: 9 por defecto.
Nivel MACD para senal: -100 por defecto, ajustar segun el activo.

Como usarlo:
Espera el circulo verde en la parte inferior del panel. Activa la alerta para recibir notificacion automatica. Usar siempre con gestion de riesgo y stop loss.

## Source Code

````pine
//@version=5
indicator(title="MACD Buy Signal NAS100", shorttitle="MACD Buy | 1H", overlay=false)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
fast_length   = input.int(12,     "MACD Fast Length")
slow_length   = input.int(26,     "MACD Slow Length")
signal_length = input.int(9,      "MACD Signal",     minval=1, maxval=50)
macd_level    = input.float(-100, "MACD nivel maximo para senal (negativo)")

// ─── MACD ─────────────────────────────────────────────────────────────────────
fast_ma = ta.ema(close, fast_length)
slow_ma = ta.ema(close, slow_length)
macd    = fast_ma - slow_ma
signal  = ta.ema(macd, signal_length)
hist    = macd - signal

// ─── COLORES HISTOGRAMA ───────────────────────────────────────────────────────
col_grow_above = #26A69A
col_grow_below = #FFCDD2
col_fall_above = #B2DFDB
col_fall_below = #EF5350

plot(hist, title="Histograma", style=plot.style_columns,
     color=hist >= 0 ? (hist[1] < hist ? col_grow_above : col_fall_above) :
                       (hist[1] < hist ? col_grow_below : col_fall_below))

plot(macd,   title="MACD",   color=#0094ff, linewidth=2)
plot(signal, title="Signal", color=#ff6a00, linewidth=1)

hline(0,          "Cero",        color=#787B86, linestyle=hline.style_dotted)
hline(macd_level, "Nivel senal", color=color.new(color.green, 60), linestyle=hline.style_dashed)

// ─── SEÑAL ────────────────────────────────────────────────────────────────────
macd_cross_up = ta.crossover(macd, signal)
macd_low      = macd <= macd_level
buy_signal    = macd_cross_up and macd_low

// ─── CIRCULO VERDE PEQUENO ────────────────────────────────────────────────────
plotshape(buy_signal,
     title     = "BUY",
     style     = shape.circle,
     location  = location.bottom,
     color     = color.new(color.green, 0),
     size      = size.small)

barcolor(buy_signal ? color.new(color.green, 0) : na)

// ─── ALERTAS ─────────────────────────────────────────────────────────────────
alertcondition(buy_signal, title="BUY MACD NAS100", message="MACD cruzando al alza por debajo de -100 puntos - Senal de compra NAS100")
````
