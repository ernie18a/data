# DNB - Cajas-Con punto de rotura

- url: https://www.tradingview.com/script/qx8HOP0R/
- type: indicator
- pine_id: PUB;f70edca9accf4bfd8fbb5d9cd12b2a81
- version: 4.0

## Description

Marcación de franjas horarias Asia y Londres para determinar dirección de la operativa.

## Source Code

````pine
//@version=6
indicator("DNB - Cajas", overlay=true, max_boxes_count=100, max_lines_count=300)

// ===== Ajustes =====
buffer = input.float(3.0, "Buffer rotura (precio)", step=0.1)
tz     = input.string("UTC+2", "Zona horaria de las sesiones")

asiaWinEndH = input.int(12, "Fin operativa Asia (hora)", minval=6, maxval=23)
lonWinEndH  = input.int(17, "Fin operativa Londres (hora)", minval=11, maxval=23)

colAsiaBox = input.color(color.new(#4F6BFF, 65), "Sombra Asia")
colLonBox  = input.color(color.new(#FFC400, 65), "Sombra Londres")
colUp      = input.color(color.new(color.green, 0), "Rotura alcista")
colDn      = input.color(color.new(color.red, 0), "Rotura bajista")

// ===== Horarios del dia =====
f_t(h) => timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), h, 0)

asiaStartT  = f_t(2)
asiaEndT    = f_t(5)
asiaWinEndT = f_t(asiaWinEndH)

lonStartT   = f_t(7)
lonEndT     = f_t(10)
lonWinEndT  = f_t(lonWinEndH)

// La caja incluye TODAS las velas hasta la del borde, ambas incluidas.
// La vela que queda en el borde de la caja cuenta entera, mecha incluida,
// para el techo y el suelo.
inAsia = time >= asiaStartT and time <= asiaEndT
inLon  = time >= lonStartT and time <= lonEndT

// Ventana de operativa: desde la vela siguiente al borde hasta la hora limite
asiaWin = time > asiaEndT and time < asiaWinEndT
lonWin  = time > lonEndT and time < lonWinEndT

// Reinicio al empezar cada sesion
newAsia = time >= asiaStartT and nz(time[1]) < asiaStartT
newLon  = time >= lonStartT and nz(time[1]) < lonStartT

// ===== Variables Asia =====
var float asiaHigh   = na
var float asiaLow    = na
var box   asiaBox    = na
var line  asiaUpLine = na
var line  asiaDnLine = na
var bool  asiaUpDone = false
var bool  asiaDnDone = false

// ===== Variables Londres =====
var float lonHigh   = na
var float lonLow    = na
var box   lonBox    = na
var line  lonUpLine = na
var line  lonDnLine = na
var bool  lonUpDone = false
var bool  lonDnDone = false

if newAsia
    asiaHigh   := na
    asiaLow    := na
    asiaBox    := na
    asiaUpLine := na
    asiaDnLine := na
    asiaUpDone := false
    asiaDnDone := false

if newLon
    lonHigh   := na
    lonLow    := na
    lonBox    := na
    lonUpLine := na
    lonDnLine := na
    lonUpDone := false
    lonDnDone := false

// ===== Caja Asia: bordes clavados en 2:00 y 5:00 =====
if inAsia
    asiaHigh := na(asiaHigh) ? high : math.max(asiaHigh, high)
    asiaLow  := na(asiaLow) ? low : math.min(asiaLow, low)
    if na(asiaBox)
        asiaBox := box.new(asiaStartT, asiaHigh, asiaEndT, asiaLow, xloc=xloc.bar_time, border_color=color.new(color.white, 100), border_width=0, bgcolor=colAsiaBox)
    else
        box.set_top(asiaBox, asiaHigh)
        box.set_bottom(asiaBox, asiaLow)

// ===== Caja Londres: bordes clavados en 7:00 y 10:00 =====
if inLon
    lonHigh := na(lonHigh) ? high : math.max(lonHigh, high)
    lonLow  := na(lonLow) ? low : math.min(lonLow, low)
    if na(lonBox)
        lonBox := box.new(lonStartT, lonHigh, lonEndT, lonLow, xloc=xloc.bar_time, border_color=color.new(color.white, 100), border_width=0, bgcolor=colLonBox)
    else
        box.set_top(lonBox, lonHigh)
        box.set_bottom(lonBox, lonLow)

// La caja queda cerrada cuando ya ha pasado la vela del borde
asiaFormed = not na(asiaHigh) and time > asiaEndT
lonFormed  = not na(lonHigh) and time > lonEndT

sigUp = false
sigDn = false

// ===== Asia: lineas de rotura desde el borde de la caja =====
if asiaFormed and asiaWin
    asiaUpLevel = asiaHigh + buffer
    asiaDnLevel = asiaLow - buffer
    if na(asiaUpLine)
        asiaUpLine := line.new(asiaEndT, asiaUpLevel, time, asiaUpLevel, xloc=xloc.bar_time, color=colUp, width=1)
        asiaDnLine := line.new(asiaEndT, asiaDnLevel, time, asiaDnLevel, xloc=xloc.bar_time, color=colDn, width=1)
    if not asiaUpDone
        line.set_x2(asiaUpLine, time)
    if not asiaDnDone
        line.set_x2(asiaDnLine, time)
    if barstate.isconfirmed
        if not asiaUpDone and close > asiaUpLevel
            asiaUpDone := true
            sigUp      := true
        else if not asiaDnDone and close < asiaDnLevel
            asiaDnDone := true
            sigDn      := true

// ===== Londres: lineas de rotura desde el borde de la caja =====
if lonFormed and lonWin
    lonUpLevel = lonHigh + buffer
    lonDnLevel = lonLow - buffer
    if na(lonUpLine)
        lonUpLine := line.new(lonEndT, lonUpLevel, time, lonUpLevel, xloc=xloc.bar_time, color=colUp, width=1)
        lonDnLine := line.new(lonEndT, lonDnLevel, time, lonDnLevel, xloc=xloc.bar_time, color=colDn, width=1)
    if not lonUpDone
        line.set_x2(lonUpLine, time)
    if not lonDnDone
        line.set_x2(lonDnLine, time)
    if barstate.isconfirmed
        if not lonUpDone and close > lonUpLevel
            lonUpDone := true
            sigUp     := true
        else if not lonDnDone and close < lonDnLevel
            lonDnDone := true
            sigDn     := true

// ===== Senales: triangulo verde arriba / rojo abajo =====
plotshape(sigUp, "Rotura alcista", shape.triangleup, location.belowbar, colUp, size=size.tiny)
plotshape(sigDn, "Rotura bajista", shape.triangledown, location.abovebar, colDn, size=size.tiny)
````
