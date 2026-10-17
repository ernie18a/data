# CRT Candle Range Theory

- url: https://www.tradingview.com/script/QT3GQs7W/
- type: indicator
- pine_id: PUB;c2fc70853e054cb6a4d9cd93f52fbe67
- version: 1.0

## Description

CRT — Candle Range Theory

Detecta automáticamente patrones CRT (Candle Range Theory) en el timeframe actual y visualiza el rango, el target y la etiqueta de señal.

¿Qué es un CRT?
Una vela de señal que toma con su wick el high o el low de la vela anterior, pero cierra de regreso dentro de ese rango. El objetivo es el extremo opuesto:

CRT Alcista: wick rompe el low anterior → target en el high del rango
CRT Bajista: wick rompe el high anterior → target en el low del rango
Características

Detecta CRT alcistas y bajistas en cualquier timeframe
Detecta CRT anidados: un CRT que se forma dentro de un rango activo previo (se muestra en naranja)
Los rangos se invalidan automáticamente si el precio rompe el lado contrario al target
Los rangos se eliminan al alcanzar su target
Opción para mostrar solo el último rango activo (ideal para operar en tiempo real)
Opción para ocultar o mantener los rangos ya completados
Alertas de TradingView para las 4 condiciones: Bull, Bear, Nested Bull, Nested Bear
Visuales

Recuadro transparente del high al low de la vela de rango
Línea discontinua en el nivel del target
Etiqueta de señal en la vela de entrada
Inputs configurables: colores por tipo de señal, máximo de rangos activos simultáneos, extensión de las cajas en velas.

## Source Code

````pine
//@version=6
indicator("CRT — Candle Range Theory", overlay=true,
          max_boxes_count=100, max_lines_count=200, max_labels_count=100)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
grpVis   = "Visibilidad"
grpColor = "Colores"
grpAdj   = "Ajustes"

showBull      = input.bool(true,  "Mostrar CRT Alcista",          group=grpVis)
showBear      = input.bool(true,  "Mostrar CRT Bajista",          group=grpVis)
showNested    = input.bool(true,  "Mostrar CRT Anidados",         group=grpVis)
showLastOnly  = input.bool(false, "Solo último rango activo",     group=grpVis)
hideCompleted = input.bool(true,  "Ocultar rangos completados",   group=grpVis)

maxCRT     = input.int(5,  "Máx. rangos activos simultáneos", minval=1, maxval=20, group=grpAdj)
targetBars = input.int(50, "Extensión caja (velas)",           minval=5, maxval=500, group=grpAdj)

bullLineClr = input.color(color.teal,   "Target Alcista", group=grpColor)
bearLineClr = input.color(color.red,    "Target Bajista", group=grpColor)
nestLineClr = input.color(color.orange, "Target Anidado", group=grpColor)

// ─── ESTADO: rangos CRT activos (no resueltos) ────────────────────────────────
var float[] rngHigh  = array.new_float()
var float[] rngLow   = array.new_float()
var int[]   rngDir   = array.new_int()
var box[]   rngBox   = array.new_box()
var line[]  rngLine  = array.new_line()
var label[] rngLabel = array.new_label()

// ─── RESOLUCIÓN: quitar rangos cuyo target fue alcanzado ──────────────────────
sz = array.size(rngHigh)
int iR = sz - 1
while iR >= 0
    rH = array.get(rngHigh, iR)
    rL = array.get(rngLow,  iR)
    rD = array.get(rngDir,  iR)
    bool resolved = (rD == 1 and high >= rH) or (rD == -1 and low <= rL)
    if resolved
        if hideCompleted
            box.delete(array.get(rngBox,   iR))
            line.delete(array.get(rngLine,  iR))
            label.delete(array.get(rngLabel, iR))
        array.remove(rngHigh,  iR)
        array.remove(rngLow,   iR)
        array.remove(rngDir,   iR)
        array.remove(rngBox,   iR)
        array.remove(rngLine,  iR)
        array.remove(rngLabel, iR)
    iR -= 1

// ─── DETECCIÓN CRT ────────────────────────────────────────────────────────────
isBullCRT = low  < low[1]  and close > low[1]  and close < high[1]
isBearCRT = high > high[1] and close < high[1] and close > low[1]

// ─── CHECK ANIDADO ────────────────────────────────────────────────────────────
isNested = false
szA = array.size(rngHigh)
if (isBullCRT or isBearCRT) and szA > 0
    for iA = 0 to szA - 1
        if high[1] <= array.get(rngHigh, iA) and low[1] >= array.get(rngLow, iA)
            isNested := true
            break

// ─── LIMPIAR TODOS LOS RANGOS (inline para evitar problemas de scope) ─────────
if showLastOnly and (isBullCRT or isBearCRT)
    int nc = array.size(rngHigh)
    if nc > 0
        for iC = 0 to nc - 1
            box.delete(array.get(rngBox,   iC))
            line.delete(array.get(rngLine,  iC))
            label.delete(array.get(rngLabel, iC))
    array.clear(rngHigh)
    array.clear(rngLow)
    array.clear(rngDir)
    array.clear(rngBox)
    array.clear(rngLine)
    array.clear(rngLabel)

// ─── TRIM (modo normal: respetar máximo de rangos activos) ────────────────────
trimActive() =>
    while array.size(rngHigh) >= maxCRT
        box.delete(array.shift(rngBox))
        line.delete(array.shift(rngLine))
        label.delete(array.shift(rngLabel))
        array.shift(rngHigh)
        array.shift(rngLow)
        array.shift(rngDir)

atr14 = ta.atr(14)

// ─── CRT ALCISTA ──────────────────────────────────────────────────────────────
if isBullCRT
    lnClr = isNested ? nestLineClr : bullLineClr
    txt   = isNested ? "CRT Nested ▲" : "CRT Bull ▲"
    show  = isNested ? showNested   : showBull
    if show
        if not showLastOnly
            trimActive()
        bx  = box.new(bar_index - 1, high[1], bar_index + targetBars, low[1],
                      bgcolor=color.new(color.white, 100), border_color=lnClr, border_width=1)
        ln  = line.new(bar_index - 1, high[1], bar_index + targetBars, high[1],
                       color=lnClr, width=2, style=line.style_dashed)
        lbl = label.new(bar_index, low - atr14 * 0.3, txt,
                        style=label.style_label_up, color=lnClr,
                        textcolor=color.white, size=size.small)
        array.push(rngHigh,  high[1])
        array.push(rngLow,   low[1])
        array.push(rngDir,   1)
        array.push(rngBox,   bx)
        array.push(rngLine,  ln)
        array.push(rngLabel, lbl)

// ─── CRT BAJISTA ──────────────────────────────────────────────────────────────
if isBearCRT
    lnClr = isNested ? nestLineClr : bearLineClr
    txt   = isNested ? "CRT Nested ▼" : "CRT Bear ▼"
    show  = isNested ? showNested   : showBear
    if show
        if not showLastOnly
            trimActive()
        bx  = box.new(bar_index - 1, high[1], bar_index + targetBars, low[1],
                      bgcolor=color.new(color.white, 100), border_color=lnClr, border_width=1)
        ln  = line.new(bar_index - 1, low[1], bar_index + targetBars, low[1],
                       color=lnClr, width=2, style=line.style_dashed)
        lbl = label.new(bar_index, high + atr14 * 0.3, txt,
                        style=label.style_label_down, color=lnClr,
                        textcolor=color.white, size=size.small)
        array.push(rngHigh,  high[1])
        array.push(rngLow,   low[1])
        array.push(rngDir,   -1)
        array.push(rngBox,   bx)
        array.push(rngLine,  ln)
        array.push(rngLabel, lbl)

// ─── ALERTAS ──────────────────────────────────────────────────────────────────
alertcondition(isBullCRT and not isNested, "CRT Alcista",
               "CRT Bull detectado en {{ticker}} [{{interval}}]")
alertcondition(isBearCRT and not isNested, "CRT Bajista",
               "CRT Bear detectado en {{ticker}} [{{interval}}]")
alertcondition(isBullCRT and isNested, "CRT Anidado Alcista",
               "CRT Nested Bull en {{ticker}} [{{interval}}]")
alertcondition(isBearCRT and isNested, "CRT Anidado Bajista",
               "CRT Nested Bear en {{ticker}} [{{interval}}]")
````
