# MULTIFRAME BULLISH/BEARISH (1D-4H-1H-5M)

- url: https://www.tradingview.com/script/R5kNXVx2/
- type: indicator
- pine_id: PUB;fceac67914324fc8856ea9c56a84da7a
- version: 1.0

## Description

Tendencia alcista y bajista: 
1 dia
4 horas
1 hora
5 minutos

## Source Code

````pine
//@version=5
indicator("MTF Trend Dashboard - SMC", overlay=true)

// === Inputs ===
emaLen = input.int(50, "EMA", minval=1, group="Configuración")
posIn  = input.string("top_right", "Posición tabla",
     options=["top_left","top_right","middle_right","bottom_left","bottom_right"],
     group="Visual")

f_pos(s) =>
    s == "top_left"     ? position.top_left     :
     s == "top_right"    ? position.top_right    :
     s == "middle_right" ? position.middle_right :
     s == "bottom_left"  ? position.bottom_left  :
                           position.bottom_right

// === Trend binario por timeframe ===
trendState(tf) =>
    c  = request.security(syminfo.tickerid, tf, close,                 lookahead=barmerge.lookahead_off)
    e  = request.security(syminfo.tickerid, tf, ta.ema(close, emaLen), lookahead=barmerge.lookahead_off)
    c > e ? 1 : -1

t1D = trendState("D")
t4H = trendState("240")
t1H = trendState("60")
t5m = trendState("5")

f_lbl(s) => s == 1 ? "ALCISTA" : "BAJISTA"
f_bg(s)  => s == 1 ? color.new(color.green, 30) : color.new(color.red, 30)

// === Tabla ===
var table panel = table.new(f_pos(posIn), 2, 5, border_width=1)

if barstate.islast
    table.cell(panel, 0, 0, "Timeframe", text_color=color.white, bgcolor=color.new(color.black, 35), text_size=size.small)
    table.cell(panel, 1, 0, "Tendencia", text_color=color.white, bgcolor=color.new(color.black, 35), text_size=size.small)

    table.cell(panel, 0, 1, "1D", text_color=color.black, bgcolor=na, text_size=size.small)
    table.cell(panel, 1, 1, f_lbl(t1D), text_color=color.white, bgcolor=f_bg(t1D), text_size=size.small)

    table.cell(panel, 0, 2, "4H", text_color=color.black, bgcolor=na, text_size=size.small)
    table.cell(panel, 1, 2, f_lbl(t4H), text_color=color.white, bgcolor=f_bg(t4H), text_size=size.small)

    table.cell(panel, 0, 3, "1H", text_color=color.black, bgcolor=na, text_size=size.small)
    table.cell(panel, 1, 3, f_lbl(t1H), text_color=color.white, bgcolor=f_bg(t1H), text_size=size.small)

    table.cell(panel, 0, 4, "5m", text_color=color.black, bgcolor=na, text_size=size.small)
    table.cell(panel, 1, 4, f_lbl(t5m), text_color=color.white, bgcolor=f_bg(t5m), text_size=size.small)
````
