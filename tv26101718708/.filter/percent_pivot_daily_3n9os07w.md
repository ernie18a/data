# Percent Pivot Daily

- url: https://www.tradingview.com/script/3N9OS07W/
- type: indicator
- pine_id: PUB;0ff0efbd33c44dc5afe537aec6eeed78
- version: 1.0

## Description

Indicatore che aiuta a individuare punti percentuali sul grafico. Nella fatti specie i quarti di punto percentuale

## Source Code

````pine
//@version=6
indicator("Percent Pivot Daily", overlay=true)

// === INPUT ===
stepPerc = input.float(0.25, "Step %", step=0.05)
maxPerc  = input.float(5.0, "Range % (+/-)")

colUp      = input.color(color.green, "Colore livelli sopra")
colDown    = input.color(color.red, "Colore livelli sotto")
colMajorUp = input.color(color.lime, "Colore livelli interi sopra (1%, 2%)")
colMajorDn = input.color(color.maroon, "Colore livelli interi sotto (1%, 2%)")
colOpen    = input.color(color.yellow, "Colore linea 0%")

showLabels = input.bool(true, "Mostra livelli (%)")

// === OPEN GIORNALIERO ===
isNewDay = ta.change(time("D")) != 0
var float dailyOpen = na

if isNewDay
    dailyOpen := open

if na(dailyOpen)
    dailyOpen := open

// === ARRAY ===
var line[] lines = array.new_line()
var label[] labels = array.new_label()

// === RESET ===
if isNewDay
    // delete linee
    if array.size(lines) > 0
        for i = 0 to array.size(lines) - 1
            line.delete(array.get(lines, i))
    array.clear(lines)

    // delete labels
    if array.size(labels) > 0
        for i = 0 to array.size(labels) - 1
            label.delete(array.get(labels, i))
    array.clear(labels)

    steps = math.floor(maxPerc / stepPerc)

    // === LINEA 0% ===
    l0 = line.new(bar_index, dailyOpen, bar_index + 1, dailyOpen,
        extend=extend.right, color=colOpen, width=2)
    array.push(lines, l0)

    if showLabels
        lb0 = label.new(bar_index, dailyOpen, "0%",
            style=label.style_none,
            textcolor=colOpen)
        array.push(labels, lb0)

    // === LIVELLI ===
    for i = 1 to steps
        perc = stepPerc * i

        upper = dailyOpen * (1 + perc / 100)
        lower = dailyOpen * (1 - perc / 100)

        isMajor = perc % 1 == 0

        colU = isMajor ? colMajorUp : colUp
        colD = isMajor ? colMajorDn : colDown

        // sopra
        l1 = line.new(bar_index, upper, bar_index + 1, upper,
            extend=extend.right, color=colU, width=isMajor ? 2 : 1)
        array.push(lines, l1)

        if showLabels
            lb1 = label.new(bar_index, upper,
                "+" + str.tostring(perc) + "%",
                style=label.style_none,
                textcolor=colU)
            array.push(labels, lb1)

        // sotto
        l2 = line.new(bar_index, lower, bar_index + 1, lower,
            extend=extend.right, color=colD, width=isMajor ? 2 : 1)
        array.push(lines, l2)

        if showLabels
            lb2 = label.new(bar_index, lower,
                "-" + str.tostring(perc) + "%",
                style=label.style_none,
                textcolor=colD)
            array.push(labels, lb2)
````
