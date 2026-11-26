# Absorcion + Envolvente + Tendencia

- url: https://www.tradingview.com/script/YpiZN5I8/
- type: indicator
- pine_id: PUB;0fde850b5ce94f0aa3dea7584c7e5421
- version: 1.0

## Description

Absorcion + Vela Envolvente + Tendencia
Este indicador combina tres conceptos poderosos del análisis técnico: absorción de volumen, velas envolventes y filtro de tendencia con EMA 200, generando señales de alta probabilidad en cualquier activo y temporalidad.
Como funciona:
El indicador detecta primero una vela de absorción — una vela pequeña con volumen muy superior a la media donde los compradores o vendedores están absorbiendo el lado contrario sin dejar que el precio se mueva. Cuando en la siguiente vela aparece una vela envolvente que confirma la dirección, y además el precio está del lado correcto de la EMA 200, se genera la señal final.
Señal de COMPRA (BUY):
Se activa cuando se cumplen estas condiciones:

El precio está por encima de la EMA 200 (tendencia alcista confirmada)
Aparece una vela de absorción compradora con volumen mínimo 2x la media
La siguiente vela es una vela envolvente alcista que confirma el movimiento

Señal de VENTA (SELL):
Se activa cuando se cumplen estas condiciones:

El precio está por debajo de la EMA 200 (tendencia bajista confirmada)
Aparece una vela de absorción vendedora con volumen mínimo 2x la media
La siguiente vela es una vela envolvente bajista que confirma el movimiento

Colores en el grafico:

Burbuja azul con porcentaje → absorcion compradora detectada, espera confirmacion
Burbuja naranja con porcentaje → absorcion vendedora detectada, espera confirmacion
Etiqueta verde grande BUY → señal de compra confirmada
Etiqueta roja grande SELL → señal de venta confirmada
El porcentaje indica cuanto del volumen total fue comprador o vendedor

Configuracion recomendada:

Activo: cualquier activo (indices, acciones, forex, cripto, materias primas)
Timeframe: desde 15 minutos hasta diario
Volumen minimo: 2x la media (ajustable)
EMA tendencia: 200 periodos (ajustable)

Como usarlo:

Espera la burbuja azul o naranja como aviso
Confirma con la señal BUY o SELL en la siguiente vela
Opera siempre a favor de la EMA 200
Usar siempre con gestion de riesgo y stop loss

## Source Code

````pine
//@version=5
indicator(title='Absorcion + Envolvente + Tendencia', shorttitle='Abs+Env+EMA', precision=2, overlay=true)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
vol_period = input.int(20,    title='Periodo media volumen')
vol_mult   = input.float(2.0, title='Volumen minimo para absorcion', step=0.1)
body_max   = input.float(0.4, title='Cuerpo maximo vela absorcion',  step=0.05)
delta_min  = input.float(0.6, title='Delta minimo dominante (0-1)',  step=0.05)
ema_len    = input.int(200,   title='EMA tendencia')

// ─── INDICADORES ──────────────────────────────────────────────────────────────
ema200 = ta.ema(close, ema_len)

// ─── CALCULOS VOLUMEN ─────────────────────────────────────────────────────────
vol_avg      = ta.sma(volume, vol_period)
candle_range = high - low
candle_body  = math.abs(close - open)

vol_buy  = candle_range > 0 ? volume * (close - low)  / candle_range : 0
vol_sell = candle_range > 0 ? volume * (high - close) / candle_range : 0

buy_ratio  = volume > 0 ? vol_buy  / volume : 0
sell_ratio = volume > 0 ? vol_sell / volume : 0

strong_vol   = volume > vol_avg * vol_mult
small_candle = candle_range > 0 and (candle_body / candle_range) < body_max

// ─── TENDENCIA ────────────────────────────────────────────────────────────────
trend_up   = close > ema200
trend_down = close < ema200

// ─── ABSORCION ────────────────────────────────────────────────────────────────
abs_bull = small_candle and strong_vol and buy_ratio  > delta_min and trend_up
abs_bear = small_candle and strong_vol and sell_ratio > delta_min and trend_down

var bool prev_abs_bull = false
var bool prev_abs_bear = false
prev_abs_bull := abs_bull[1]
prev_abs_bear := abs_bear[1]

// ─── VELA ENVOLVENTE ──────────────────────────────────────────────────────────
engulf_bull = close > open and
              open  < close[1] and
              close > open[1]  and
              candle_body > math.abs(close[1] - open[1])

engulf_bear = close < open and
              open  > close[1] and
              close < open[1]  and
              candle_body > math.abs(close[1] - open[1])

// ─── SEÑALES COMBINADAS ───────────────────────────────────────────────────────
BUY  = prev_abs_bull and engulf_bull and trend_up
SELL = prev_abs_bear and engulf_bear and trend_down

// ─── BURBUJAS DE ABSORCION ───────────────────────────────────────────────────
if abs_bull
    label.new(bar_index, low - ta.atr(14),
         text      = str.tostring(math.round(buy_ratio * 100)) + '% C',
         color     = color.new(color.blue, 20),
         textcolor = color.white,
         style     = label.style_label_up,
         size      = size.small)

if abs_bear
    label.new(bar_index, high + ta.atr(14),
         text      = str.tostring(math.round(sell_ratio * 100)) + '% V',
         color     = color.new(color.orange, 20),
         textcolor = color.white,
         style     = label.style_label_down,
         size      = size.small)

// ─── SEÑALES EN GRAFICO ───────────────────────────────────────────────────────
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

// ─── EMA ─────────────────────────────────────────────────────────────────────
plot(ema200, title='EMA 200', color=color.new(color.white, 20), linewidth=2)

// ─── COLOR DE VELAS ───────────────────────────────────────────────────────────
barcolor(BUY  ? color.new(color.green,  0) :
         SELL ? color.new(color.red,    0) :
         abs_bull ? color.new(color.blue,   40) :
         abs_bear ? color.new(color.orange, 40) : na)

// ─── ALERTAS ─────────────────────────────────────────────────────────────────
alertcondition(BUY,         title='BUY',  message='Absorcion compradora + Envolvente + Tendencia alcista')
alertcondition(SELL,        title='SELL', message='Absorcion vendedora + Envolvente + Tendencia bajista')
alertcondition(BUY or SELL, title='Senal', message='Senal de entrada detectada')
````
