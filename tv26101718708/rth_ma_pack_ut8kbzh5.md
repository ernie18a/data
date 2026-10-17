# RTH MA Pack

- url: https://www.tradingview.com/script/Ut8kbzH5/
- type: indicator
- pine_id: PUB;d15975696ff5454999f64854b6e3e3a8
- version: 1.0

## Description

**RTH MA Pack — EMA 9 + WMA 20/40/100/200**

This indicator displays a moving average pack designed specifically for the regular U.S. market session.

It includes:

* EMA 9
* WMA 20
* WMA 40
* WMA 100
* WMA 200

The indicator completely ignores premarket and postmarket data. All moving averages are calculated only during regular trading hours, from 9:30 AM to 4:00 PM New York time.

At the end of the regular session, the indicator saves the final value of each moving average. During premarket and postmarket, those values remain fixed at the previous regular session close. When the market opens again, the moving averages continue calculating from the saved values without restarting and without using extended-hours data.

Main features:

* Calculates only with RTH data.
* Ignores premarket and postmarket.
* Saves the previous session’s closing MA values.
* Continues calculation from the saved values at the next market open.
* Includes EMA 9 and WMA 20/40/100/200.
* Useful for tickers where the chart session cannot be manually adjusted.

This tool is designed for traders who want clean regular-session moving averages without extended-hours price action distorting the calculation.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © danyoptiontrading

//@version=6
indicator("RTH MA Pack", overlay = true, max_bars_back = 5000)

// Horario regular USA
// En Pine:
// 1 = Domingo
// 2 = Lunes
// 3 = Martes
// 4 = Miércoles
// 5 = Jueves
// 6 = Viernes
// 7 = Sábado
//
// Lunes a viernes = 23456
rthSession = input.session("0930-1600:23456", "Horario RTH")
tz         = input.string("America/New_York", "Zona horaria")

// Si está activado, la media se mueve en vivo durante la vela actual.
// Si está apagado, solo actualiza al cierre de cada vela.
showLiveValue = input.bool(true, "Actualizar en vivo durante RTH")

// Detecta horario regular
inRTH = not na(time(timeframe.period, rthSession, tz))

// Solo guardar datos cuando una vela RTH cierra.
// Esto evita duplicar cierres en tiempo real.
updateRTH = inRTH and barstate.isconfirmed

// Array solo con cierres confirmados de RTH
var array<float> rthCloses = array.new_float()

// Valores guardados
var float ema9Saved   = na
var float wma20Saved  = na
var float wma40Saved  = na
var float wma100Saved = na
var float wma200Saved = na

// Función WMA usando solo cierres RTH confirmados
f_wma_from_array(array<float> arr, int len) =>
    float result = na
    int size = array.size(arr)

    if size >= len
        float sum = 0.0
        float weightSum = 0.0

        for i = 0 to len - 1
            float weight = i + 1
            float value = array.get(arr, size - len + i)
            sum += value * weight
            weightSum += weight

        result := sum / weightSum

    result

// Función WMA para mostrar valor en vivo sin guardar la vela actual todavía
f_wma_live(array<float> arr, int len, float currentPrice) =>
    float result = na
    int size = array.size(arr)
    int totalSize = size + 1

    if totalSize >= len
        float sum = 0.0
        float weightSum = 0.0

        for i = 0 to len - 1
            int combinedIndex = totalSize - len + i
            float value = combinedIndex == size ? currentPrice : array.get(arr, combinedIndex)
            float weight = i + 1

            sum += value * weight
            weightSum += weight

        result := sum / weightSum

    result

// EMA manual usando solo cierres RTH
f_ema(float src, float prevEma, int len) =>
    float alpha = 2.0 / (len + 1.0)
    na(prevEma) ? src : alpha * src + (1.0 - alpha) * prevEma

// Actualización real solo dentro de RTH y solo al cierre de vela
if updateRTH
    array.push(rthCloses, close)

    // Mantiene suficiente historial sin hacer pesado el indicador
    if array.size(rthCloses) > 1000
        array.shift(rthCloses)

    // EMA 9 solo con cierres RTH
    ema9Saved := f_ema(close, ema9Saved, 9)

    // WMA solo con cierres RTH
    wma20Saved  := f_wma_from_array(rthCloses, 20)
    wma40Saved  := f_wma_from_array(rthCloses, 40)
    wma100Saved := f_wma_from_array(rthCloses, 100)
    wma200Saved := f_wma_from_array(rthCloses, 200)

// Valores en vivo durante la vela actual.
// No se guardan en el array hasta que la vela cierre.
liveRTH = inRTH and not barstate.isconfirmed and showLiveValue

ema9Plot = liveRTH ? f_ema(close, ema9Saved, 9) : ema9Saved

wma20Plot = liveRTH ? f_wma_live(rthCloses, 20, close) : wma20Saved
wma40Plot = liveRTH ? f_wma_live(rthCloses, 40, close) : wma40Saved
wma100Plot = liveRTH ? f_wma_live(rthCloses, 100, close) : wma100Saved
wma200Plot = liveRTH ? f_wma_live(rthCloses, 200, close) : wma200Saved

// Fuera de RTH no se actualiza nada.
// Se mantiene el último valor guardado del cierre regular anterior.
// Al abrir el mercado, continúa desde ese valor.

plot(ema9Plot,   "EMA 9 RTH",   color = color.new(color.aqua, 0),   linewidth = 2)
plot(wma20Plot,  "WMA 20 RTH",  color = color.new(color.yellow, 0), linewidth = 2)
plot(wma40Plot,  "WMA 40 RTH",  color = color.new(color.red, 0),    linewidth = 2)
plot(wma100Plot, "WMA 100 RTH", color = color.new(color.green, 0),  linewidth = 2)
plot(wma200Plot, "WMA 200 RTH", color = color.new(color.purple, 0), linewidth = 3)
````
