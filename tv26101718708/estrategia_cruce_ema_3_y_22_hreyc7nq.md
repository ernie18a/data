# Estrategia Cruce EMA 3 y 22

- url: https://www.tradingview.com/script/HrEyc7NQ/
- type: indicator
- pine_id: PUB;487629e0171942bf9b63ee71c263b09d
- version: 1.0

## Description

Indicador que pinta las velas rojas, verde, segun el cruce de la ema 3 y 2 Periodos

## Source Code

````pine
//@version=5
indicator("Estrategia Cruce EMA 3 y 22", overlay=true)

// 1. Definimos las longitudes (puedes cambiarlas luego en configuración si quieres)
longitud_rapida = input.int(3, title="Longitud EMA Rápida")
longitud_lenta = input.int(22, title="Longitud EMA Lenta")

// 2. Calculamos las EMAs basándonos en el precio de cierre de la vela
ema_rapida = ta.ema(close, longitud_rapida)
ema_lenta = ta.ema(close, longitud_lenta)

// 3. Definimos la regla de los colores
// Si EMA 3 es mayor que EMA 22 = Verde. Si es menor = Rojo.
color_vela = ema_rapida > ema_lenta ? color.green : ema_rapida < ema_lenta ? color.red : na

// 4. Pintamos las velas
barcolor(color_vela)

// 5. (Opcional) Dibujamos las líneas en el gráfico para guiarte
plot(ema_rapida, color=color.blue, title="EMA Rápida (3)", linewidth=2)
plot(ema_lenta, color=color.orange, title="EMA Lenta (22)", linewidth=2)
````
