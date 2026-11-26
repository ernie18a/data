# Previous High & Low

- url: https://www.tradingview.com/script/uADp1hoc/
- type: indicator
- pine_id: PUB;0a307f1f322744f3b022a2e8d0f59292
- version: 1.0

## Description

Marca as máximas e mínimas do pregão anterior de forma discreta e com linhas no gráfico.

## Source Code

````pine
//@version=5
indicator("Previous High & Low", overlay=true)

// Inputs
mostrar_ph = input.bool(true, "Mostrar Previous High (PH)")
mostrar_pl = input.bool(true, "Mostrar Previous Low (PL)")

// Detecta início de novo pregão
novo_pregao = ta.change(time("D")) != 0

// Captura máxima e mínima do pregão anterior
var float prev_high = na
var float prev_low  = na
var float temp_high = na
var float temp_low  = na

var line  linha_ph  = na
var line  linha_pl  = na
var label label_ph  = na
var label label_pl  = na

if novo_pregao
    prev_high := temp_high
    prev_low  := temp_low
    temp_high := high
    temp_low  := low
else
    temp_high := math.max(nz(temp_high, high), high)
    temp_low  := math.min(nz(temp_low,  low),  low)

// Redesenha linhas e labels apenas no último candle
if barstate.islast
    line.delete(linha_ph)
    line.delete(linha_pl)
    label.delete(label_ph)
    label.delete(label_pl)

    if mostrar_ph and not na(prev_high)
        linha_ph := line.new(
             x1=bar_index, y1=prev_high,
             x2=bar_index + 1, y2=prev_high,
             extend=extend.right,
             color=color.black,
             style=line.style_dashed,
             width=1)
        label_ph := label.new(bar_index, prev_high, "PH",
             style=label.style_none,
             textcolor=color.black,
             size=size.tiny,
             yloc=yloc.price)

    if mostrar_pl and not na(prev_low)
        linha_pl := line.new(
             x1=bar_index, y1=prev_low,
             x2=bar_index + 1, y2=prev_low,
             extend=extend.right,
             color=color.black,
             style=line.style_dashed,
             width=1)
        label_pl := label.new(bar_index, prev_low, "PL",
             style=label.style_none,
             textcolor=color.black,
             size=size.tiny,
             yloc=yloc.price)
````
