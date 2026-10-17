# ZigZag de fractales (Williams)

- url: https://www.tradingview.com/script/rBM72q8i/
- type: indicator
- pine_id: PUB;83b4a8cf29f84f49a8f54fc9ce21677f
- version: 1.0

## Description

zigazagg fractal, muchas cosas para tradear yuju q divertido es todo este texto

## Source Code

````pine
//@version=6
indicator("ZigZag de fractales (Williams)", overlay = true, max_lines_count = 500)

// ── Ajustes ────────────────────────────────────────────────
showFractals = input.bool(true,  "Mostrar triángulos de fractales")
zzColor      = input.color(color.white, "Color del zigzag")
zzWidth      = input.int(2, "Grosor del zigzag", minval = 1, maxval = 5)
upColor      = input.color(color.red,  "Color fractal arriba (máximo)")
dnColor      = input.color(color.teal, "Color fractal abajo (mínimo)")

// ── Fractales de Williams (patrón de 5 velas) ──────────────
// La vela central (offset 2) debe superar a las 2 de cada lado.
upFractal   = high[2] > high[3] and high[2] > high[4] and high[2] > high[1] and high[2] > high[0]
downFractal = low[2]  < low[3]  and low[2]  < low[4]  and low[2]  < low[1]  and low[2]  < low[0]

// ── Estado del zigzag ──────────────────────────────────────
var float pPrice = na    // precio del último pivote confirmado
var int   pBar   = na    // bar_index del último pivote
var int   pDir   = 0     //  1 = máximo,  -1 = mínimo
var line  zz     = na    // último segmento dibujado

// ── Máximo (fractal arriba) ────────────────────────────────
if upFractal
    float px = high[2]
    int   bx = bar_index - 2
    if pDir != 1
        // lado contrario (o primer pivote): nuevo giro → trazamos segmento
        if not na(pPrice)
            zz := line.new(pBar, pPrice, bx, px, xloc = xloc.bar_index, color = zzColor, width = zzWidth)
        pPrice := px
        pBar   := bx
        pDir   := 1
    else if px > pPrice
        // mismo lado: nos quedamos con el máximo MÁS ALTO y estiramos la pata
        pPrice := px
        pBar   := bx
        if not na(zz)
            line.set_xy2(zz, bx, px)

// ── Mínimo (fractal abajo) ─────────────────────────────────
if downFractal
    float px = low[2]
    int   bx = bar_index - 2
    if pDir != -1
        if not na(pPrice)
            zz := line.new(pBar, pPrice, bx, px, xloc = xloc.bar_index, color = zzColor, width = zzWidth)
        pPrice := px
        pBar   := bx
        pDir   := -1
    else if px < pPrice
        // mismo lado: nos quedamos con el mínimo MÁS BAJO
        pPrice := px
        pBar   := bx
        if not na(zz)
            line.set_xy2(zz, bx, px)

// ── Triángulos (alineados con la vela del fractal, offset -2) ─
plotshape(showFractals and upFractal,   title = "Fractal arriba", style = shape.triangledown, location = location.abovebar, color = upColor, offset = -2, size = size.tiny)
plotshape(showFractals and downFractal, title = "Fractal abajo",  style = shape.triangleup,   location = location.belowbar, color = dnColor, offset = -2, size = size.tiny)
````
