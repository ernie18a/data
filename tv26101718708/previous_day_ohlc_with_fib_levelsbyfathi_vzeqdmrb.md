# Previous Day OHLC with Fib Levels-By-FATHI_

- url: https://www.tradingview.com/script/vzEqdMrb/
- type: indicator
- pine_id: PUB;a5eb033e30834025a311b00c641e7980
- version: 1.0

## Description

OHLC-avec niveau fibo50% et 38% par rapport à la journée précédente.

## Source Code

````pine
//@version=6
indicator("Previous Day OHLC with Fib Levels", "PrevDay OHLC", overlay = true)

// ─────────────────────────────────────────────
// 1. INPUTS
// ─────────────────────────────────────────────

// Affichage des lignes
showOpen  = input.bool(true,  "Daily Open")
showHigh  = input.bool(true,  "Daily High")
showLow   = input.bool(true,  "Daily Low")
showClose = input.bool(true,  "Daily Close")
showToday = input.bool(true,  "Today Open")
showFib50 = input.bool(true,  "Fib 50%")
showFib38 = input.bool(true,  "Fib 38.2%")

// Affichage des descriptifs
showLabels = input.bool(true, "Afficher les descriptifs")

// Position des labels
labelPos = input.string("Droite", "Position des labels", 
     options = ["Droite", "Gauche", "Au-dessus", "En-dessous"])

// Taille des labels
labelSize = input.string("Normal", "Taille des labels",
     options = ["Tiny", "Small", "Normal"])

// ─────────────────────────────────────────────
// 2. Récupération des données Daily (J-1)
// ─────────────────────────────────────────────
[dOpen, dHigh, dLow, dClose] = request.security(
     syminfo.tickerid, "D",
     [open[1], high[1], low[1], close[1]],
     lookahead = barmerge.lookahead_on)

todayOpen = request.security(
     syminfo.tickerid, "D",
     open,
     lookahead = barmerge.lookahead_on)

// ─────────────────────────────────────────────
// 3. Calculs Fib
// ─────────────────────────────────────────────
fib50 = (dHigh + dLow) / 2
fib382 = (dHigh - dLow) * 0.382
fibLevel = dOpen < dClose ? dHigh - fib382 : dLow + fib382

// ─────────────────────────────────────────────
// 4. Fonction utilitaire pour labels
// ─────────────────────────────────────────────
f_label(_y, _txt, _color) =>
    _style = label.style_label_left
    if labelPos == "Gauche"
        _style := label.style_label_right
    if labelPos == "Au-dessus"
        _style := label.style_label_down
    if labelPos == "En-dessous"
        _style := label.style_label_up

    _size = size.normal
    if labelSize == "Tiny"
        _size := size.tiny
    if labelSize == "Small"
        _size := size.small

    label.new(
        bar_index, _y,
        _txt,
        color = color.new(_color, 0),
        textcolor = color.white,
        style = _style,
        size = _size
    )

// ─────────────────────────────────────────────
// 5. PLOTS
// ─────────────────────────────────────────────
plot(dOpen,  "Daily Open",  color.blue,   style = plot.style_circles,     display = showOpen  ? display.all : display.none)
plot(dHigh,  "Daily High",  color.red,    style = plot.style_circles,     display = showHigh  ? display.all : display.none)
plot(dLow,   "Daily Low",   color.green,  style = plot.style_circles,     display = showLow   ? display.all : display.none)
plot(dClose, "Daily Close", color.purple, style = plot.style_circles,     display = showClose ? display.all : display.none)
plot(todayOpen, "Today Open", color.black, style = plot.style_cross,      display = showToday ? display.all : display.none)

plot(fib50,   "Fib 50%",   color.black,  style = plot.style_steplinebr,   display = showFib50 ? display.all : display.none)
plot(fibLevel,"Fib 38.2%", color.orange, style = plot.style_steplinebr,   display = showFib38 ? display.all : display.none)

// ─────────────────────────────────────────────
// 6. LABELS
// ─────────────────────────────────────────────
if showLabels and barstate.islast
    if showOpen
        f_label(dOpen,  "Daily Open",  color.blue)
    if showHigh
        f_label(dHigh,  "Daily High",  color.red)
    if showLow
        f_label(dLow,   "Daily Low",   color.green)
    if showClose
        f_label(dClose, "Daily Close", color.purple)
    if showToday
        f_label(todayOpen, "Today Open", color.black)
    if showFib50
        f_label(fib50, "Fib 50%", color.gray)
    if showFib38
        f_label(fibLevel, "Fib 38.2%", color.orange)
````
