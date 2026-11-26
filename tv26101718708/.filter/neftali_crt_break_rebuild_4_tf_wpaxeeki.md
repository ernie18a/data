# NEFTALI CRT Break & Rebuild (4 TF

- url: https://www.tradingview.com/script/wpAxEEKi-NEFTALI-CRT-Break-Rebuild-4-TF/
- type: indicator
- pine_id: PUB;5a0ab67ee428427b8f44f1b866546de8
- version: 1.0

## Description

CRT Break & Rebuild (4 TF, multi time frame CRT indicator, nothing else to say, enjoy it.

## Source Code

````pine
//@version=6
indicator("CRT Break & Rebuild (4 TF + Toggle)", overlay=true, max_lines_count=500)

// ─────────────────────────────
// INPUTS TF + TOGGLE
// ─────────────────────────────
show1 = input.bool(true, "Mostrar TF 1")
show2 = input.bool(true, "Mostrar TF 2")
show3 = input.bool(true, "Mostrar TF 3")
show4 = input.bool(true, "Mostrar TF 4")

tf1 = input.timeframe("1", "TF 1")
tf2 = input.timeframe("5", "TF 2")
tf3 = input.timeframe("15", "TF 3")
tf4 = input.timeframe("60", "TF 4")

dist = input.int(20, "Distancia derecha", minval=1)

// ─────────────────────────────
// HTF DATA
// ─────────────────────────────
[o1, h1, l1, c1] = request.security(syminfo.tickerid, tf1, [open, high, low, close])
[o2, h2, l2, c2] = request.security(syminfo.tickerid, tf2, [open, high, low, close])
[o3, h3, l3, c3] = request.security(syminfo.tickerid, tf3, [open, high, low, close])
[o4, h4, l4, c4] = request.security(syminfo.tickerid, tf4, [open, high, low, close])

// ─────────────────────────────
// RANGOS
// ─────────────────────────────
var float rHigh1 = na
var float rLow1  = na

var float rHigh2 = na
var float rLow2  = na

var float rHigh3 = na
var float rLow3  = na

var float rHigh4 = na
var float rLow4  = na

// ─────────────────────────────
// INIT
// ─────────────────────────────
if na(rHigh1)
    rHigh1 := h1
    rLow1  := l1

if na(rHigh2)
    rHigh2 := h2
    rLow2  := l2

if na(rHigh3)
    rHigh3 := h3
    rLow3  := l3

if na(rHigh4)
    rHigh4 := h4
    rLow4  := l4

// ─────────────────────────────
// BREAK & REBUILD
// ─────────────────────────────
if c1 > rHigh1 or c1 < rLow1
    rHigh1 := h1
    rLow1  := l1

if c2 > rHigh2 or c2 < rLow2
    rHigh2 := h2
    rLow2  := l2

if c3 > rHigh3 or c3 < rLow3
    rHigh3 := h3
    rLow3  := l3

if c4 > rHigh4 or c4 < rLow4
    rHigh4 := h4
    rLow4  := l4

// ─────────────────────────────
// DRAW ARRAYS
// ─────────────────────────────
var line[] highs = array.new_line()
var line[] lows  = array.new_line()

if barstate.isfirst
    for i = 0 to 3
        array.push(highs, line.new(na, na, na, na))
        array.push(lows, line.new(na, na, na, na))

if barstate.islast

    hArr = array.from(rHigh1, rHigh2, rHigh3, rHigh4)
    lArr = array.from(rLow1, rLow2, rLow3, rLow4)
    sArr = array.from(show1, show2, show3, show4)

    for i = 0 to 3

        if array.get(sArr, i)

            hi = array.get(hArr, i)
            lo = array.get(lArr, i)

            col = i == 0 ? color.blue :
                  i == 1 ? color.green :
                  i == 2 ? color.orange :
                           color.red

            x1 = bar_index + dist + i * 10
            x2 = x1 + 8

            lh = array.get(highs, i)
            line.set_xy1(lh, x1, hi)
            line.set_xy2(lh, x2, hi)
            line.set_color(lh, col)
            line.set_width(lh, 2)

            ll = array.get(lows, i)
            line.set_xy1(ll, x1, lo)
            line.set_xy2(ll, x2, lo)
            line.set_color(ll, col)
            line.set_width(ll, 2)
````
