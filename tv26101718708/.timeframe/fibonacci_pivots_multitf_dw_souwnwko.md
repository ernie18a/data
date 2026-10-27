# Fibonacci Pivots Multi-TF (D/W)

- url: https://www.tradingview.com/script/sOuwNWkO-Fibonacci-Pivots-Multi-TF-D-W/
- type: indicator
- pine_id: PUB;8d9f578aaa5044e0ab81d9a6a2150924
- version: 1.0

## Description

Pivot-Diario
Pivot-Semanal

Niveles de Pivots fibonacci en un mismo indicador

## Source Code

````pine
//@version=6
indicator('Fibonacci Pivots Multi-TF (D/W)', overlay = true, max_lines_count = 500, max_labels_count = 500)

// === INPUTS ===
showD = input.bool(false, 'Mostrar Daily', group = 'Daily')
showW = input.bool(true, 'Mostrar Weekly', group = 'Weekly')
numPrev = input.int(1, 'Número de pivots a mostrar (1=actual, 5=últimos 5)', minval = 1, maxval = 5, group = 'Display')
labelSide = input.string('Derecha', 'Posición etiqueta', options = ['Izquierda', 'Derecha'], group = 'Display')

// === COLORES ===
PIVOT_W = color.yellow
PIVOT_D = color.aqua
COL_38 = #00FF00
COL_61 = #FF3333
COL_78 = #FFFF00
COL_100 = #FFA500
COL_138 = #FF8C00
COL_161 = #ADFF2F
COL_200 = #C71585

// === DURACIONES en milisegundos ===
DAY_MS = 86400000 // 24h
WEEK_MS = 604800000 // 7 días

// === REQUEST.SECURITY ===
// Para cada offset i, traer HLC[i] (source) + time[i-1] (donde dibujar)
// i=1 → HLC de la semana/día PREVIO + time de la semana/día ACTUAL
// i=2 → HLC de 2 atrás + time de la PREVIA
// etc.
[hW1, lW1, cW1, tW1] = request.security(syminfo.tickerid, 'W', [high[1], low[1], close[1], time])
[hW2, lW2, cW2, tW2] = request.security(syminfo.tickerid, 'W', [high[2], low[2], close[2], time[1]])
[hW3, lW3, cW3, tW3] = request.security(syminfo.tickerid, 'W', [high[3], low[3], close[3], time[2]])
[hW4, lW4, cW4, tW4] = request.security(syminfo.tickerid, 'W', [high[4], low[4], close[4], time[3]])
[hW5, lW5, cW5, tW5] = request.security(syminfo.tickerid, 'W', [high[5], low[5], close[5], time[4]])

[hD1, lD1, cD1, tD1] = request.security(syminfo.tickerid, 'D', [high[1], low[1], close[1], time])
[hD2, lD2, cD2, tD2] = request.security(syminfo.tickerid, 'D', [high[2], low[2], close[2], time[1]])
[hD3, lD3, cD3, tD3] = request.security(syminfo.tickerid, 'D', [high[3], low[3], close[3], time[2]])
[hD4, lD4, cD4, tD4] = request.security(syminfo.tickerid, 'D', [high[4], low[4], close[4], time[3]])
[hD5, lD5, cD5, tD5] = request.security(syminfo.tickerid, 'D', [high[5], low[5], close[5], time[4]])

// === ARRAYS ===
var array<line> allLines = array.new<line>()
var array<label> allLabels = array.new<label>()

// === FUNCION DRAW (usa xloc.bar_time) ===
drawSet(_h, _l, _c, _tStart, _tEnd, _tLbl, _pivCol, _prefix) =>
    p = (_h + _l + _c) / 3.0
    d = _h - _l
    r38 = p + d * 0.382
    r61 = p + d * 0.618
    r78 = p + d * 0.786
    r100 = p + d * 1.000
    r138 = p + d * 1.382
    r161 = p + d * 1.618
    r200 = p + d * 2.000
    s38 = p - d * 0.382
    s61 = p - d * 0.618
    s78 = p - d * 0.786
    s100 = p - d * 1.000
    s138 = p - d * 1.382
    s161 = p - d * 1.618
    s200 = p - d * 2.000

    array.push(allLines, line.new(_tStart, p, _tEnd, p, xloc = xloc.bar_time, color = _pivCol, width = 2))
    array.push(allLines, line.new(_tStart, r38, _tEnd, r38, xloc = xloc.bar_time, color = COL_38, width = 1))
    array.push(allLines, line.new(_tStart, r61, _tEnd, r61, xloc = xloc.bar_time, color = COL_61, width = 1))
    array.push(allLines, line.new(_tStart, r78, _tEnd, r78, xloc = xloc.bar_time, color = COL_78, width = 1))
    array.push(allLines, line.new(_tStart, r100, _tEnd, r100, xloc = xloc.bar_time, color = COL_100, width = 2))
    array.push(allLines, line.new(_tStart, r138, _tEnd, r138, xloc = xloc.bar_time, color = COL_138, width = 1))
    array.push(allLines, line.new(_tStart, r161, _tEnd, r161, xloc = xloc.bar_time, color = COL_161, width = 1))
    array.push(allLines, line.new(_tStart, r200, _tEnd, r200, xloc = xloc.bar_time, color = COL_200, width = 2))
    array.push(allLines, line.new(_tStart, s38, _tEnd, s38, xloc = xloc.bar_time, color = COL_38, width = 1))
    array.push(allLines, line.new(_tStart, s61, _tEnd, s61, xloc = xloc.bar_time, color = COL_61, width = 1))
    array.push(allLines, line.new(_tStart, s78, _tEnd, s78, xloc = xloc.bar_time, color = COL_78, width = 1))
    array.push(allLines, line.new(_tStart, s100, _tEnd, s100, xloc = xloc.bar_time, color = COL_100, width = 2))
    array.push(allLines, line.new(_tStart, s138, _tEnd, s138, xloc = xloc.bar_time, color = COL_138, width = 1))
    array.push(allLines, line.new(_tStart, s161, _tEnd, s161, xloc = xloc.bar_time, color = COL_161, width = 1))
    array.push(allLines, line.new(_tStart, s200, _tEnd, s200, xloc = xloc.bar_time, color = COL_200, width = 2))

    array.push(allLabels, label.new(_tLbl, p, _prefix + ' P', xloc = xloc.bar_time, color = color.new(color.black, 100), textcolor = _pivCol, style = label.style_none, size = size.small))
    array.push(allLabels, label.new(_tLbl, r38, _prefix + ' R38', xloc = xloc.bar_time, color = color.new(color.black, 100), textcolor = COL_38, style = label.style_none, size = size.small))
    array.push(allLabels, label.new(_tLbl, r61, _prefix + ' R61', xloc = xloc.bar_time, color = color.new(color.black, 100), textcolor = COL_61, style = label.style_none, size = size.small))
    array.push(allLabels, label.new(_tLbl, r78, _prefix + ' R78', xloc = xloc.bar_time, color = color.new(color.black, 100), textcolor = COL_78, style = label.style_none, size = size.small))
    array.push(allLabels, label.new(_tLbl, r100, _prefix + ' R100', xloc = xloc.bar_time, color = color.new(color.black, 100), textcolor = COL_100, style = label.style_none, size = size.small))
    array.push(allLabels, label.new(_tLbl, r138, _prefix + ' R138', xloc = xloc.bar_time, color = color.new(color.black, 100), textcolor = COL_138, style = label.style_none, size = size.small))
    array.push(allLabels, label.new(_tLbl, r161, _prefix + ' R161', xloc = xloc.bar_time, color = color.new(color.black, 100), textcolor = COL_161, style = label.style_none, size = size.small))
    array.push(allLabels, label.new(_tLbl, r200, _prefix + ' R200', xloc = xloc.bar_time, color = color.new(color.black, 100), textcolor = COL_200, style = label.style_none, size = size.small))
    array.push(allLabels, label.new(_tLbl, s38, _prefix + ' S38', xloc = xloc.bar_time, color = color.new(color.black, 100), textcolor = COL_38, style = label.style_none, size = size.small))
    array.push(allLabels, label.new(_tLbl, s61, _prefix + ' S61', xloc = xloc.bar_time, color = color.new(color.black, 100), textcolor = COL_61, style = label.style_none, size = size.small))
    array.push(allLabels, label.new(_tLbl, s78, _prefix + ' S78', xloc = xloc.bar_time, color = color.new(color.black, 100), textcolor = COL_78, style = label.style_none, size = size.small))
    array.push(allLabels, label.new(_tLbl, s100, _prefix + ' S100', xloc = xloc.bar_time, color = color.new(color.black, 100), textcolor = COL_100, style = label.style_none, size = size.small))
    array.push(allLabels, label.new(_tLbl, s138, _prefix + ' S138', xloc = xloc.bar_time, color = color.new(color.black, 100), textcolor = COL_138, style = label.style_none, size = size.small))
    array.push(allLabels, label.new(_tLbl, s161, _prefix + ' S161', xloc = xloc.bar_time, color = color.new(color.black, 100), textcolor = COL_161, style = label.style_none, size = size.small))
    array.push(allLabels, label.new(_tLbl, s200, _prefix + ' S200', xloc = xloc.bar_time, color = color.new(color.black, 100), textcolor = COL_200, style = label.style_none, size = size.small))

// === HELPERS ===
getHW(i) =>
    i == 1 ? hW1 : i == 2 ? hW2 : i == 3 ? hW3 : i == 4 ? hW4 : hW5
getLW(i) =>
    i == 1 ? lW1 : i == 2 ? lW2 : i == 3 ? lW3 : i == 4 ? lW4 : lW5
getCW(i) =>
    i == 1 ? cW1 : i == 2 ? cW2 : i == 3 ? cW3 : i == 4 ? cW4 : cW5
getTW(i) =>
    i == 1 ? tW1 : i == 2 ? tW2 : i == 3 ? tW3 : i == 4 ? tW4 : tW5
getHD(i) =>
    i == 1 ? hD1 : i == 2 ? hD2 : i == 3 ? hD3 : i == 4 ? hD4 : hD5
getLD(i) =>
    i == 1 ? lD1 : i == 2 ? lD2 : i == 3 ? lD3 : i == 4 ? lD4 : lD5
getCD(i) =>
    i == 1 ? cD1 : i == 2 ? cD2 : i == 3 ? cD3 : i == 4 ? cD4 : cD5
getTD(i) =>
    i == 1 ? tD1 : i == 2 ? tD2 : i == 3 ? tD3 : i == 4 ? tD4 : tD5

if barstate.islast
    while array.size(allLines) > 0
        line.delete(array.shift(allLines))
    while array.size(allLabels) > 0
        label.delete(array.shift(allLabels))

    for i = 1 to numPrev by 1
        // WEEKLY
        if showW
            hWi = getHW(i)
            lWi = getLW(i)
            cWi = getCW(i)
            tWi = getTW(i)
            if not na(hWi) and not na(lWi) and not na(cWi) and not na(tWi)
                int tStart = tWi
                int tEnd = tWi + WEEK_MS
                int tLbl = labelSide == 'Izquierda' ? tStart - int(WEEK_MS / 20) : tEnd + int(WEEK_MS / 20)
                drawSet(hWi, lWi, cWi, tStart, tEnd, tLbl, PIVOT_W, 'W')

        // DAILY
        if showD
            hDi = getHD(i)
            lDi = getLD(i)
            cDi = getCD(i)
            tDi = getTD(i)
            if not na(hDi) and not na(lDi) and not na(cDi) and not na(tDi)
                int tStart = tDi
                int tEnd = tDi + DAY_MS
                int tLbl = labelSide == 'Izquierda' ? tStart - int(DAY_MS / 20) : tEnd + int(DAY_MS / 20)
                drawSet(hDi, lDi, cDi, tStart, tEnd, tLbl, PIVOT_D, 'D')
````
