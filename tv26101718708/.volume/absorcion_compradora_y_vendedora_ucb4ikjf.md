# Absorcion Compradora y Vendedora

- url: https://www.tradingview.com/script/UCb4IKjf/
- type: indicator
- pine_id: PUB;352ec2c91501498c9cb9d29beab7e1f3
- version: 1.0

## Description

Cómo leer las burbujas:

Burbuja verde 🟢 con % abajo → absorción compradora — vela pequeña pero los compradores están dominando con mucho volumen. Señal de posible subida
Burbuja roja 🔴 con % arriba → absorción vendedora — vela pequeña pero los vendedores dominan. Señal de posible bajada
El porcentaje → cuánto del volumen total fue comprador o vendedor

Los parámetros clave:

Volumen minimo → súbelo si hay demasiadas burbujas
Cuerpo maximo de vela → bájalo para exigir velas más pequeñas
Delta minimo dominante → súbelo a 0.7 para exigir más dominancia

## Source Code

````pine
//@version=5
indicator(title='Absorcion Compradora y Vendedora', shorttitle='Absorcion', precision=2, overlay=true)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
vol_period   = input.int(20,    title='Periodo media volumen')
vol_mult     = input.float(2.0, title='Volumen minimo para absorcion', step=0.1)
body_max     = input.float(0.4, title='Cuerpo maximo de vela (0-1)',   step=0.05)
delta_min    = input.float(0.6, title='Delta minimo dominante (0-1)',  step=0.05)

// ─── CALCULOS ─────────────────────────────────────────────────────────────────
vol_avg      = ta.sma(volume, vol_period)
candle_range = high - low
candle_body  = math.abs(close - open)

// Estimacion de volumen comprador y vendedor
vol_buy  = candle_range > 0 ? volume * (close - low)  / candle_range : 0
vol_sell = candle_range > 0 ? volume * (high - close) / candle_range : 0
delta    = vol_buy - vol_sell

// Ratio de dominancia
buy_ratio  = volume > 0 ? vol_buy  / volume : 0
sell_ratio = volume > 0 ? vol_sell / volume : 0

// ─── CONDICIONES DE ABSORCION ─────────────────────────────────────────────────

// Vela pequeña (poca direccion) pero con mucho volumen
small_candle = candle_range > 0 and (candle_body / candle_range) < body_max
strong_vol   = volume > vol_avg * vol_mult

// Absorcion compradora — vela pequeña, volumen fuerte, compradores dominan
abs_bull = small_candle and strong_vol and buy_ratio  > delta_min

// Absorcion vendedora — vela pequeña, volumen fuerte, vendedores dominan
abs_bear = small_candle and strong_vol and sell_ratio > delta_min

// ─── BURBUJAS ────────────────────────────────────────────────────────────────
// Absorcion compradora — burbuja verde abajo
if abs_bull
    label.new(bar_index, low - ta.atr(14),
         text      = '🟢\n' + str.tostring(math.round(buy_ratio * 100)) + '% C',
         color     = color.new(color.green, 0),
         textcolor = color.white,
         style     = label.style_label_up,
         size      = size.normal)

// Absorcion vendedora — burbuja roja arriba
if abs_bear
    label.new(bar_index, high + ta.atr(14),
         text      = '🔴\n' + str.tostring(math.round(sell_ratio * 100)) + '% V',
         color     = color.new(color.red, 0),
         textcolor = color.white,
         style     = label.style_label_down,
         size      = size.normal)

// ─── COLOR DE VELAS ───────────────────────────────────────────────────────────
barcolor(abs_bull ? color.new(color.green, 0) :
         abs_bear ? color.new(color.red,   0) : na)

// ─── ALERTAS ─────────────────────────────────────────────────────────────────
alertcondition(abs_bull, title='Absorcion Compradora', message='Absorcion compradora detectada — posible subida')
alertcondition(abs_bear, title='Absorcion Vendedora',  message='Absorcion vendedora detectada — posible bajada')
alertcondition(abs_bull or abs_bear, title='Absorcion', message='Absorcion detectada')
````
