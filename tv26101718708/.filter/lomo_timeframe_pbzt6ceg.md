# Lomo timeframe

- url: https://www.tradingview.com/script/pBZt6CeG/
- type: indicator
- pine_id: PUB;b22d4ee39e174e9cb042af3688355aa1
- version: 1.0

## Description

Solo muestra la tabla a diferentes temporalidades, para confirmación de tendencia fuerte es muy útil.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BERSANCH

//@version=6
indicator("Lomo timeframe", overlay=true)

t1 = input.timeframe("5", "Time frame 1")
t2 = input.timeframe("15", "Time frame 2")
t3 = input.timeframe("60", "Time frame 3")
t4 = input.timeframe("240", "Time frame 4")
t5 = input.timeframe("1D", "Time frame 5")
green = input.color(#00ffbb, "Bullish Color")
red = input.color(#ff1100, "Bearish Color")

// Lógica mínima para calcular trend (necesaria para la tabla)
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

// MTF requests
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

// Solo la tabla (sin plots)
if barstate.islast
    var table tfTable = table.new(position.top_right, 2, 6, bgcolor=na, border_width=1, border_color=chart.fg_color)
    // Cabecera (column, row)
    table.cell(tfTable, 0, 0, "Time Frame", text_color=chart.fg_color, text_halign=text.align_center)
    table.cell(tfTable, 1, 0, "Signal", text_color=chart.fg_color, text_halign=text.align_center)

    // Filas (column, row)
    table.cell(tfTable, 0, 1, t1, text_halign=text.align_center)
    table.cell(tfTable, 1, 1, s1a, text_halign=text.align_center, bgcolor=s1a == "Bullish" ? color.new(green, 70) : color.new(red, 70))

    table.cell(tfTable, 0, 2, t2, text_halign=text.align_center)
    table.cell(tfTable, 1, 2, s2a, text_halign=text.align_center, bgcolor=s2a == "Bullish" ? color.new(green, 70) : color.new(red, 70))

    table.cell(tfTable, 0, 3, t3, text_halign=text.align_center)
    table.cell(tfTable, 1, 3, s3a, text_halign=text.align_center, bgcolor=s3a == "Bullish" ? color.new(green, 70) : color.new(red, 70))

    table.cell(tfTable, 0, 4, t4, text_halign=text.align_center)
    table.cell(tfTable, 1, 4, s4a, text_halign=text.align_center, bgcolor=s4a == "Bullish" ? color.new(green, 70) : color.new(red, 70))

    table.cell(tfTable, 0, 5, t5, text_halign=text.align_center)
    table.cell(tfTable, 1, 5, s5a, text_halign=text.align_center, bgcolor=s5a == "Bullish" ? color.new(green, 70) : color.new(red, 70))
````
