# NEFTALI HTF Candles Overlay turtle soup

- url: https://www.tradingview.com/script/xi6hmpMM-NEFTALI-HTF-Candles-Overlay-turtle-soup/
- type: indicator
- pine_id: PUB;a925882264c14b10b765e6c7a500027e
- version: 1.0

## Description

NEFTALI HTF Candles Overlay turtle soup NEFTALI HTF Candles Overlay turtle soup

## Source Code

````pine
//@version=6
indicator("HTF Candles Overlay FIX (Invertido + Distancia)", overlay=true, max_boxes_count=500, max_lines_count=500)

tf = input.timeframe("15", "Temporalidad HTF")

// 🔥 NUEVO: distancia configurable
dist = input.int(30, "Distancia al precio", minval=1)

// separación entre velas
spacing = input.int(3, "Separación entre velas", minval=1)

[o, h, l, c] = request.security(syminfo.tickerid, tf, [open, high, low, close])
[o1, h1, l1, c1] = request.security(syminfo.tickerid, tf, [open[1], high[1], low[1], close[1]])
[o2, h2, l2, c2] = request.security(syminfo.tickerid, tf, [open[2], high[2], low[2], close[2]])
[o3, h3, l3, c3] = request.security(syminfo.tickerid, tf, [open[3], high[3], low[3], close[3]])

var box[] bodies = array.new_box()
var line[] wicks = array.new_line()

if barstate.isfirst
    for i = 0 to 3
        array.push(bodies, box.new(na, na, na, na))
        array.push(wicks, line.new(na, na, na, na))

if barstate.islast

    oo = array.from(o, o1, o2, o3)
    hh = array.from(h, h1, h2, h3)
    ll = array.from(l, l1, l2, l3)
    cc = array.from(c, c1, c2, c3)

    for i = 0 to 3

        idx = 3 - i  // orden invertido

        op = array.get(oo, idx)
        hi = array.get(hh, idx)
        lo = array.get(ll, idx)
        cl = array.get(cc, idx)

        col = cl >= op ? color.lime : color.red

        // 🔥 DISTANCIA CONFIGURABLE
        x = bar_index + dist + i * spacing

        wick = array.get(wicks, i)
        line.set_xy1(wick, x, hi)
        line.set_xy2(wick, x, lo)
        line.set_color(wick, col)

        body = array.get(bodies, i)

        box.set_left(body, x - 1)
        box.set_right(body, x + 1)
        box.set_top(body, math.max(op, cl))
        box.set_bottom(body, math.min(op, cl))

        box.set_bgcolor(body, col)
        box.set_border_color(body, col)
````
