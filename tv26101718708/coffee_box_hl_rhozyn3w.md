# Coffee Box HL

- url: https://www.tradingview.com/script/rHOzYn3W/
- type: indicator
- pine_id: PUB;807f98488fbf467f8d3d5b0acbe28a08
- version: 1.0

## Description

Coffee Box - Contiene calculador de amplitud - Amplitude indicator

## Source Code

````pine
// @version=5
// ============================================================
//  Coffee Box Indicator  |  by Claude
//  Muestra la caja de sesión London Open (06:00–09:00 UTC)
//  con el % de amplitud (high - low) / low * 100
// ============================================================

indicator(title="Coffee Box", shorttitle="☕ CBox", overlay=true)

// ─── INPUTS ─────────────────────────────────────────────────
var string TZ        = "UTC"
int  boxStartHour    = input.int(6,  "Hora inicio (UTC)", minval=0, maxval=23)
int  boxEndHour      = input.int(9,  "Hora fin   (UTC)", minval=0, maxval=23)
int  boxExtendBars   = input.int(40, "Extender caja (barras)", minval=0, maxval=200)

color colBox    = input.color(color.new(color.orange, 80),  "Color relleno")
color colBorder = input.color(color.new(color.orange, 10),  "Color borde")
color colMid    = input.color(color.new(color.yellow, 20),  "Color línea media")
bool  showMid   = input.bool(true,  "Mostrar línea media (50%)")
bool  showLabel = input.bool(true,  "Mostrar etiqueta % amplitud")
bool  showBreak = input.bool(true,  "Marcar rompimiento de caja")
color colBullBrk= input.color(color.new(color.lime,  10), "Color ruptura alcista")
color colBearBrk= input.color(color.new(color.red,   10), "Color ruptura bajista")

// ─── LÓGICA HORARIA ─────────────────────────────────────────
isInBox()  => hour(time, TZ) >= boxStartHour and hour(time, TZ) < boxEndHour
isBoxEnd() => hour(time, TZ) == boxEndHour   and hour(time, TZ)[1] < boxEndHour

// ─── VARIABLES PERSISTENTES ─────────────────────────────────
var float boxHigh  = na
var float boxLow   = na
var int   boxStart = na
var int   boxEnd   = na
var box   drawnBox = na
var line  midLine  = na
var label ampLabel = na

// ─── CONSTRUCCIÓN DE LA CAJA ─────────────────────────────────
if isInBox()
    // Primera barra de la sesión → inicializar
    if na(boxHigh) or (hour(time, TZ) == boxStartHour and minute(time, TZ) == 0 and not isInBox()[1])
        boxHigh := high
        boxLow  := low
        boxStart := bar_index
    else
        boxHigh := math.max(boxHigh, high)
        boxLow  := math.min(boxLow,  low)

// ─── DIBUJO AL CIERRE DE SESIÓN ──────────────────────────────
if isBoxEnd() and not na(boxHigh)
    boxEnd := bar_index + boxExtendBars

    // Amplitud %
    float amp = (boxHigh - boxLow) / boxLow * 100

    // Caja principal
    if not na(drawnBox)
        box.delete(drawnBox)
    drawnBox := box.new(
      left          = boxStart,
      top           = boxHigh,
      right         = boxEnd,
      bottom        = boxLow,
      bgcolor       = colBox,
      border_color  = colBorder,
      border_width  = 1,
      extend        = extend.none
      )

    // Línea media
    if showMid
        if not na(midLine)
            line.delete(midLine)
        midLine := line.new(
          x1    = boxStart,
          y1    = (boxHigh + boxLow) / 2,
          x2    = boxEnd,
          y2    = (boxHigh + boxLow) / 2,
          color = colMid,
          style = line.style_dashed,
          width = 1
          )

    // Etiqueta con % de amplitud
    if showLabel
        if not na(ampLabel)
            label.delete(ampLabel)
        ampLabel := label.new(
          x         = boxEnd,
          y         = boxHigh,
          text      = "☕ " + str.tostring(amp, "#.##") + "%",
          color     = colBorder,
          textcolor = color.white,
          style     = label.style_label_left,
          size      = size.normal
          )

    // Reset para la siguiente sesión
    boxHigh := na
    boxLow  := na

// ─── SEÑALES DE RUPTURA ──────────────────────────────────────
// Se calculan comparando el cierre actual con la última caja guardada
var float savedHigh = na
var float savedLow  = na

if isBoxEnd() and not na(boxHigh)
    savedHigh := boxHigh
    savedLow  := boxLow

bullBreak = showBreak and not na(savedHigh) and close > savedHigh and close[1] <= savedHigh
bearBreak = showBreak and not na(savedLow)  and close < savedLow  and close[1] >= savedLow

plotshape(bullBreak, title="Ruptura Alcista", style=shape.triangleup,
  location=location.belowbar, color=colBullBrk, size=size.small)
plotshape(bearBreak, title="Ruptura Bajista", style=shape.triangledown,
  location=location.abovebar, color=colBearBrk, size=size.small)

// ─── ALERTAS ─────────────────────────────────────────────────
alertcondition(bullBreak, "Coffee Box — Ruptura ALCISTA", "Precio rompió la Coffee Box al alza")
alertcondition(bearBreak, "Coffee Box — Ruptura BAJISTA", "Precio rompió la Coffee Box a la baja")
````
