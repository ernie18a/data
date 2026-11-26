# Lomo Timeframes & Delta Volume

- url: https://www.tradingview.com/script/rUZbvZEr/
- type: indicator
- pine_id: PUB;a73c6a44bd7747c599da9f73b268fd8d
- version: 2.0

## Description

Podrás visualizar el sesgo del activo en diferentes temporalidades y el delta volume en tiempo real. Muy funcional y visual para saber dirección del activo.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BERSANCH

//@version=6
indicator("Lomo timeframes delta volume", overlay=true)

t1 = input.timeframe("5", "Time frame 1")
t2 = input.timeframe("15", "Time frame 2")
t3 = input.timeframe("60", "Time frame 3")
t4 = input.timeframe("240", "Time frame 4")
t5 = input.timeframe("1D", "Time frame 5")
green = input.color(#00ffbb, "Bullish Color")
red = input.color(#ff1100, "Bearish Color")

// Trend logic
length = 70
src = close
lag = math.floor((length - 1) / 2)
zlema = ta.ema(src + (src - src[lag]), length)
volatility = ta.highest(ta.atr(length), length * 3) * 1.2

var int trend = 0
if ta.crossover(close, zlema + volatility)
    trend := 1
if ta.crossunder(close, zlema - volatility)
    trend := -1

// MTF
s1 = request.security(syminfo.tickerid, t1, trend)
s2 = request.security(syminfo.tickerid, t2, trend)
s3 = request.security(syminfo.tickerid, t3, trend)
s4 = request.security(syminfo.tickerid, t4, trend)
s5 = request.security(syminfo.tickerid, t5, trend)

s1a = s1 == 1 ? "Bullish" : "Bearish"
s2a = s2 == 1 ? "Bullish" : "Bearish"
s3a = s3 == 1 ? "Bullish" : "Bearish"
s4a = s4 == 1 ? "Bullish" : "Bearish"
s5a = s5 == 1 ? "Bullish" : "Bearish"

// Delta Volume
delta = volume - volume[1]
deltaPct = volume[1] != 0 ? (delta / volume[1]) * 100 : 0
deltaColor = deltaPct > 30 ? color.new(green, 70) : deltaPct < -30 ? color.new(red, 70) : color.new(color.gray, 70)

if barstate.islast
    // Cambia position.top_center por position.top_right si quieres más a la derecha
    var table tfTable = table.new(position.top_center, 2, 6, bgcolor = na, border_width = 1, border_color = chart.fg_color)

    table.cell(tfTable, 0, 0, "Time Frame", text_color = chart.fg_color, text_halign = text.align_center)
    table.cell(tfTable, 1, 0, "Signal", text_color = chart.fg_color, text_halign = text.align_center)

    table.cell(tfTable, 0, 1, t1, text_halign = text.align_center)
    table.cell(tfTable, 1, 1, s1a, text_halign = text.align_center, bgcolor = s1a == "Bullish" ? color.new(green, 70) : color.new(red, 70))

    table.cell(tfTable, 0, 2, t2, text_halign = text.align_center)
    table.cell(tfTable, 1, 2, s2a, text_halign = text.align_center, bgcolor = s2a == "Bullish" ? color.new(green, 70) : color.new(red, 70))

    table.cell(tfTable, 0, 3, t3, text_halign = text.align_center)
    table.cell(tfTable, 1, 3, s3a, text_halign = text.align_center, bgcolor = s3a == "Bullish" ? color.new(green, 70) : color.new(red, 70))

    table.cell(tfTable, 0, 4, t4, text_halign = text.align_center)
    table.cell(tfTable, 1, 4, s4a, text_halign = text.align_center, bgcolor = s4a == "Bullish" ? color.new(green, 70) : color.new(red, 70))

    table.cell(tfTable, 0, 5, t5, text_halign = text.align_center)
    table.cell(tfTable, 1, 5, s5a, text_halign = text.align_center, bgcolor = s5a == "Bullish" ? color.new(green, 70) : color.new(red, 70))

    // Tabla Delta Volume justo debajo; TradingView apila tablas en la misma posición
    var table deltaTable = table.new(position.top_center, 2, 2, bgcolor = na, border_width = 1, border_color = chart.fg_color)

    table.cell(deltaTable, 0, 0, "Delta Volume %", text_color = chart.fg_color, text_halign = text.align_center)
    table.cell(deltaTable, 1, 0, "", text_halign = text.align_center)

    table.cell(deltaTable, 0, 1, str.tostring(deltaPct, format.mintick), text_halign = text.align_center, bgcolor = deltaColor)
    table.cell(deltaTable, 1, 1, "", text_halign = text.align_center)
````
