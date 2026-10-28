# Fibonacci Projection + Volume & Delta Profile

- url: https://www.tradingview.com/script/MGDzAHYf/
- type: indicator
- pine_id: PUB;d5a092b7921e45aa9ff1baeda1249578
- version: 1.0

## Description

Indicador de Proyección Fibonacci con Volume Profile y Delta Profile.

Muestra:
• Niveles de Fibonacci proyectados hacia el futuro
• Swing Highs y Lows detectados automáticamente
• Volume Profile dentro del rango Fibonacci
• Delta Profile (Bullish/Bearish) con cajas de fuerza
• Cajas y etiquetas de porcentaje de proyección

Totalmente personalizable con colores, estilos y tamaños.

Basado en el trabajo de Zeiierman con modificaciones.

Ideal para trading de oro (XAUUSD), forex y futuros.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © Zeiierman — modified levels by user
//@version=6
indicator("Fibonacci Projection with Volume & Delta Profile (Zeiierman)", shorttitle ="Fibonacci Projection (Zeiierman)" ,overlay = true, max_bars_back = 5000)

prd = input.int(100, "Period", group="Fib Settings")
lvl = input.float(0.5, title="Projection Level", group="Fib Settings", options=[0.0, -0.25, -0.5, -1.0, 0.2, 0.25, 0.5, 0.75, 0.8, 1.0, 1.25, 1.5, 2.0])

col_0    = input.color(color.new(color.white, 60), "0",     group="Fib Level Colors")
col_1    = input.color(color.new(color.white, 60), "1",     group="Fib Level Colors")
col_125  = input.color(color.new(color.white, 60), "1.25",  group="Fib Level Colors")
col_150  = input.color(#5cb85c, "1.5", group="Fib Level Colors")
col_2    = input.color(#888888, "2", group="Fib Level Colors")
col_02   = input.color(#888888, "0.2", group="Fib Level Colors")
col_08   = input.color(color.new(color.white, 60), "0.8", group="Fib Level Colors")
col_075  = input.color(#5cb85c, "0.75", group="Fib Level Colors")
col_05   = input.color(#5cb85c, "0.5", group="Fib Level Colors")
col_025  = input.color(#5cb85c, "0.25", group="Fib Level Colors")
col_n025 = input.color(color.new(color.white, 60), "-0.25", group="Fib Level Colors")
col_n05  = input.color(#7a9e7e, "-0.5", group="Fib Level Colors")
col_n1   = input.color(#666666, "-1", group="Fib Level Colors")

fibLineWidth = input.int(2, "Fib Line Width", minval=1, maxval=5, group="Fib Level Colors")

showlab         = input.bool(false, "Fib Labels", group="Fib Levels Style")
fibLabelColor   = input.color(color.white, "", group="Fib Levels Style")
fibLabelSizeStr = input.string("Small", "", options=["Tiny","Small","Normal","Large","Huge"], group="Fib Levels Style")
fibLabelSize = fibLabelSizeStr == "Tiny" ? size.tiny : fibLabelSizeStr == "Small" ? size.small : fibLabelSizeStr == "Large" ? size.large : fibLabelSizeStr == "Huge" ? size.huge : size.normal

loLineColor   = input.color(color.new(color.green, 0), "Low Line", group="Swing High/Low Lines Style")
hiLineColor   = input.color(color.new(color.red, 0), "High Line", group="Swing High/Low Lines Style")
hiloLineWidth = input.int(2, "Width", 1, 5, group="Swing High/Low Lines Style")

showFibProfile = input.bool(true, "Fib Volume Profile", group="Fib Volume Profile")
rows           = input.int(10, "Rows", 2, 100, group="Fib Volume Profile")
flipOrder      = input.bool(false, "Flip Bull/Bear", group="Fib Volume Profile")
bull_color     = input.color(color.new(color.teal, 30), "Bull", group="Fib Volume Profile")
bear_color     = input.color(color.new(color.orange, 30), "Bear", group="Fib Volume Profile")

showFibDelta   = input.bool(false, "Fib Volume Delta", group="Fib Volume Delta Profile")
deltaMaxWidth  = input.int(30, "Max Width", minval=5, maxval=200, group="Fib Volume Delta Profile")
deltaBullColor = input.color(color.new(color.lime, 80), "Bullish Delta", group="Fib Volume Delta Profile")
deltaBearColor = input.color(color.new(color.red, 80), "Bearish Delta", group="Fib Volume Delta Profile")

projLineBullColor = input.color(color.new(color.green, 0), "Bullish", group="Projection Lines Style")
projLineBearColor = input.color(color.new(color.red, 0), "Bearish", group="Projection Lines Style")
projLineWidth     = input.int(2, "Width", 1, 5, group="Projection Lines Style")
projLineStyleStr  = input.string("Arrow Right", "", options=["Solid","Dashed","Dotted","Arrow Left","Arrow Right"], group="Projection Lines Style")
projLineStyle = projLineStyleStr == "Solid" ? line.style_solid : projLineStyleStr == "Dashed" ? line.style_dashed : projLineStyleStr == "Dotted" ? line.style_dotted : projLineStyleStr == "Arrow Left" ? line.style_arrow_left : line.style_arrow_right

projPercBullColor    = input.color(color.new(color.green, 0), "Bullish Bg", group="Projection Labels Style")
projPercBearColor    = input.color(color.new(color.red, 0), "Bearish Bg", group="Projection Labels Style")
projPercTextColor    = input.color(color.white, "Text", group="Projection Labels Style")
projPercLabelSizeStr = input.string("Small", "", options=["Tiny","Small","Normal","Large","Huge"], group="Projection Labels Style")
projPercLabelSize = projPercLabelSizeStr == "Tiny" ? size.tiny : projPercLabelSizeStr == "Small" ? size.small : projPercLabelSizeStr == "Large" ? size.large : projPercLabelSizeStr == "Huge" ? size.huge : size.normal

projBoxBgOn           = input.bool(true, "Background", group="Projection Box Style")
projBoxBgColor        = input.color(color.new(color.blue, 80), "", group="Projection Box Style")
projBoxBorderOn       = input.bool(true, "Border", group="Projection Box Style")
projBoxBorderCol      = input.color(color.new(color.white, 0), "", group="Projection Box Style")
projBoxBorderW        = input.int(1, "", minval=1, maxval=5, group="Projection Box Style")
projBoxBorderStyleStr = input.string("Solid", "", options=["Solid","Dashed","Dotted"], group="Projection Box Style")
projBoxTextHAlignStr  = input.string("Center", "H Align", options=["Left","Center","Right"], group="Projection Box Style")
projBoxTextVAlignStr  = input.string("Center", "V Align", options=["Top","Center","Bottom"], group="Projection Box Style")
projBoxTextColor      = input.color(color.white, "Text", group="Projection Box Style")
projBoxTextSizeStr    = input.string("Normal", "", options=["Tiny","Small","Normal","Large","Huge"], group="Projection Box Style")

projBoxTextSize = projBoxTextSizeStr == "Tiny" ? size.tiny : projBoxTextSizeStr == "Small" ? size.small : projBoxTextSizeStr == "Large" ? size.large : projBoxTextSizeStr == "Huge" ? size.huge : size.normal
projBoxBorderStyle = projBoxBorderStyleStr == "Solid" ? line.style_solid : projBoxBorderStyleStr == "Dashed" ? line.style_dashed : line.style_dotted
projBoxTextHAlign = projBoxTextHAlignStr == "Left" ? "left" : projBoxTextHAlignStr == "Right" ? "right" : "center"
projBoxTextVAlign = projBoxTextVAlignStr == "Top" ? "top" : projBoxTextVAlignStr == "Bottom" ? "bottom" : "center"

levelColor(v) => v == 0.0 ? col_0 : v == 1.0 ? col_1 : v == 1.25 ? col_125 : v == 1.5 ? col_150 : v == 2.0 ? col_2 : v == 0.2 ? col_02 : v == 0.8 ? col_08 : v == 0.75 ? col_075 : v == 0.5 ? col_05 : v == 0.25 ? col_025 : v == -0.25 ? col_n025 : v == -0.5 ? col_n05 : v == -1.0 ? col_n1 : color.white

hi = ta.highest(high, prd)
lo = ta.lowest(low, prd)

isHi = high == hi
isLo = low == lo

HB = ta.barssince(isHi)
LB = ta.barssince(isLo)

hiPrice = ta.valuewhen(isHi, high, 0)
loPrice = ta.valuewhen(isLo, low, 0)
hiBar   = ta.valuewhen(isHi, bar_index, 0)
loBar   = ta.valuewhen(isLo, bar_index, 0)

var line hiLine = na
var line loLine = na

if barstate.isfirst
    hiLine := line.new(na, na, na, na, color=hiLineColor, width=hiloLineWidth)
    loLine := line.new(na, na, na, na, color=loLineColor, width=hiloLineWidth)

var array<line>  fibbLines       = array.new_line()
var array<label> fibbLabels      = array.new_label()
var array<line>  forecastLines   = array.new_line()
var array<box>   areas           = array.new_box()
var array<label> perc            = array.new_label()
var array<box>   fibProfileBoxes = array.new_box()
var array<box>   fibDeltaBoxes   = array.new_box()

var int deltaStartX = na

fibbFunc(v, last, h, l) => last ? h - (h - l) * v : l + (h - l) * v

cleaner(a, idx) =>
    if idx >= 0 and idx < array.size(a)
        el = array.get(a, idx)
        if not na(el)
            el.delete()
        array.remove(a, idx)

if not na(HB) and not na(LB) and not na(hiPrice) and not na(loPrice) and not na(hiBar) and not na(loBar)
    line.set_xy1(hiLine, hiBar, hiPrice)
    line.set_xy2(hiLine, bar_index, hiPrice)
    line.set_color(hiLine, hiLineColor)
    line.set_width(hiLine, hiloLineWidth)

    line.set_xy1(loLine, loBar, loPrice)
    line.set_xy2(loLine, bar_index, loPrice)
    line.set_color(loLine, loLineColor)
    line.set_width(loLine, hiloLineWidth)

    bars = math.abs(HB - LB)

    for i = array.size(fibbLines) - 1 to 0
        cleaner(fibbLines, i)
    for i = array.size(fibbLabels) - 1 to 0
        cleaner(fibbLabels, i)

    lvls = array.from(0.0, 1.25, 1.5, 1.0, 0.2, 0.8, 0.75, 0.5, 0.25, -0.25, -1.0, 2.0, -0.5)

    baseOffset = HB > LB ? LB : HB
    xFibStart  = bar_index - baseOffset

    for [i, e] in lvls
        f = fibbFunc(e, HB < LB, hiPrice, loPrice)
        col = levelColor(e)
        ln = line.new(chart.point.from_index(xFibStart, f), chart.point.from_index(bar_index, f), color=col, width=fibLineWidth)
        array.push(fibbLines, ln)

        if showlab
            lbl = label.new(chart.point.from_index(bar_index + 1, f), str.tostring(e, "#.###"), textcolor=fibLabelColor, style=label.style_label_left, size=fibLabelSize, color=col)
            array.push(fibbLabels, lbl)

    fibb  = fibbFunc(lvl, LB > HB, hiPrice, loPrice)
    fibb2 = LB < HB ? fibbFunc(lvl, true, fibb, loPrice) : fibbFunc(lvl, false, hiPrice, fibb)
    trendfibb = LB > HB ? fibbFunc(1.272, true, hiPrice, loPrice) : fibbFunc(1.272, false, hiPrice, loPrice)

    forecast = array.from(HB < LB ? hiPrice : loPrice, fibb, fibb2, trendfibb)
    segment  = math.min(bars, math.floor(500.0 / 4.0))

    for i = array.size(forecastLines) - 1 to 0
        cleaner(forecastLines, i)
    for i = array.size(areas) - 1 to 0
        cleaner(areas, i)
    for i = array.size(perc) - 1 to 0
        cleaner(perc, i)

    deltaStartX := na
    future = bar_index

    for i = 0 to forecast.size() - 2
        x1 = math.min(future, bar_index + 500)
        x2 = math.min(future + segment, bar_index + 500)
        y1 = forecast.get(i)
        y2 = forecast.get(i + 1)

        lnForecast = line.new(x1, y1, x2, y2, color = y1 < y2 ? projLineBullColor : projLineBearColor, width=projLineWidth, style=projLineStyle)
        array.push(forecastLines, lnForecast)

        midBoxLeft  = x2 - math.round((x1 - x2) / 4.0)
        midBoxRight = x2 + math.round((x1 - x2) / 4.0)
        boxHeight   = math.abs(y1 - y2) / 10.0

        txtLevel = i == forecast.size() - 2 ? "1.272" : str.tostring(lvl, "#.###")
        bx = box.new(midBoxLeft, y2 + boxHeight, midBoxRight, y2 - boxHeight, bgcolor=projBoxBgOn ? projBoxBgColor : color.new(projBoxBgColor,100), border_color=projBoxBorderOn ? projBoxBorderCol : color.new(projBoxBorderCol,100), border_style=projBoxBorderStyle, border_width=projBoxBorderW, text=txtLevel, text_halign=projBoxTextHAlign, text_valign=projBoxTextVAlign, text_color=projBoxTextColor, text_size=projBoxTextSize)
        array.push(areas, bx)

        deltaStartX := na(deltaStartX) ? box.get_right(bx) : math.max(deltaStartX, box.get_right(bx))

        change = (y2 - y1) / y1
        midX = int(math.avg(x1, x2))
        midY = line.get_price(lnForecast, midX)   // ← ESTA LÍNEA ESTABA INCOMPLETA

        lb = label.new(chart.point.from_index(midX, midY), str.tostring(change * 100, format.percent), color=change > 0 ? projPercBullColor : projPercBearColor, style=i == 1 ? label.style_label_lower_right : label.style_label_lower_left, textcolor=projPercTextColor, size=projPercLabelSize)
        array.push(perc, lb)
        future += segment

    // ==================== VOLUME PROFILE ====================
    if showFibProfile and hiBar != loBar and not na(hiPrice) and not na(loPrice)
        for i = array.size(fibProfileBoxes) - 1 to 0
            cleaner(fibProfileBoxes, i)

        top    = math.max(hiPrice, loPrice)
        bottom = math.min(hiPrice, loPrice)

        if top != bottom
            step   = (top - bottom) / rows
            levels = array.new_float()
            for i = 0 to rows
                array.push(levels, bottom + step * i)

            volUp = array.new_float(rows, 0.0)
            volDn = array.new_float(rows, 0.0)

            startBar = math.min(hiBar, loBar)
            endBar   = math.max(hiBar, loBar)

            for bi = startBar to endBar
                offset = bar_index - bi
                price  = hlc3[offset]
                vol    = volume[offset]
                bull   = close[offset] > open[offset]
                for r = 0 to rows - 1
                    dn = array.get(levels, r)
                    up = array.get(levels, r + 1)
                    if price >= dn and price < up
                        if bull
                            array.set(volUp, r, array.get(volUp, r) + vol)
                        else
                            array.set(volDn, r, array.get(volDn, r) + vol)
                        break

            maxTot = 0.0
            for r = 0 to rows - 1
                tot = array.get(volUp, r) + array.get(volDn, r)
                maxTot := math.max(maxTot, tot)

            span = endBar - startBar + 1

            if maxTot > 0
                for r = 0 to rows - 1
                    upVol = array.get(volUp, r)
                    dnVol = array.get(volDn, r)
                    normUp = upVol == 0 ? 0 : int((upVol / maxTot) * span)
                    normDn = dnVol == 0 ? 0 : int((dnVol / maxTot) * span)

                    bullRowCol = color.from_gradient(r, 0, rows-1, color.new(bull_color,80), color.new(bull_color,10))
                    bearRowCol = color.from_gradient(r, 0, rows-1, color.new(bear_color,80), color.new(bear_color,10))

                    yTop    = array.get(levels, r + 1)
                    yBottom = array.get(levels, r)

                    leftBull  = flipOrder ? startBar : startBar + normDn
                    rightBull = flipOrder ? startBar + normUp : startBar + normDn + normUp
                    leftBear  = flipOrder ? startBar + normUp : startBar
                    rightBear = flipOrder ? startBar + normUp + normDn : startBar + normDn

                    if normUp > 0
                        array.push(fibProfileBoxes, box.new(leftBull, yTop, rightBull, yBottom, bgcolor=bullRowCol, border_color=color.new(bullRowCol,0), border_style=line.style_dotted))
                    if normDn > 0
                        array.push(fibProfileBoxes, box.new(leftBear, yTop, rightBear, yBottom, bgcolor=bearRowCol, border_color=color.new(bearRowCol,0), border_style=line.style_dotted))

    // ==================== DELTA PROFILE ====================
    if showFibDelta and hiBar != loBar and not na(hiPrice) and not na(loPrice)
        for i = array.size(fibDeltaBoxes) - 1 to 0
            cleaner(fibDeltaBoxes, i)

        fibPrices  = array.new_float()
        array.push(fibPrices, hiPrice)
        customLvls = array.from(0.0, 1.25, 1.5, 1.0, 0.2, 0.8, 0.75, 0.5, 0.25, -0.25, -1.0, 2.0, -0.5)
        for e in customLvls
            array.push(fibPrices, fibbFunc(e, HB < LB, hiPrice, loPrice))
        array.push(fibPrices, loPrice)

        fibSorted  = array.copy(fibPrices)
        array.sort(fibSorted)

        bandsCount = array.size(fibSorted) - 1
        if bandsCount > 0
            bandBull = array.new_float(bandsCount, 0.0)
            bandBear = array.new_float(bandsCount, 0.0)

            startBar = math.min(hiBar, loBar)
            endBar   = math.max(hiBar, loBar)

            for bi = startBar to endBar
                offset = bar_index - bi
                price  = hlc3[offset]
                vol    = volume[offset]
                bull   = close[offset] > open[offset]
                for b = 0 to bandsCount - 1
                    bandLow  = array.get(fibSorted, b)
                    bandHigh = array.get(fibSorted, b + 1)
                    if price >= bandLow and price < bandHigh
                        if bull
                            array.set(bandBull, b, array.get(bandBull, b) + vol)
                        else
                            array.set(bandBear, b, array.get(bandBear, b) + vol)
                        break

            maxAbsDelta = 0.0
            for b = 0 to bandsCount - 1
                delta = array.get(bandBull, b) - array.get(bandBear, b)
                maxAbsDelta := math.max(maxAbsDelta, math.abs(delta))

            if maxAbsDelta > 0
                for b = 0 to bandsCount - 1
                    bandLow  = array.get(fibSorted, b)
                    bandHigh = array.get(fibSorted, b + 1)
                    delta    = array.get(bandBull, b) - array.get(bandBear, b)
                    if delta == 0
                        continue
                    widthBars = math.max(int((math.abs(delta) / maxAbsDelta) * deltaMaxWidth), 1)
                    col       = delta >= 0 ? deltaBullColor : deltaBearColor
                    array.push(fibDeltaBoxes, box.new(startBar - widthBars, bandHigh, startBar, bandLow, bgcolor=col, border_color=color.new(col,0), border_style=line.style_solid, text="Δ " + str.tostring(delta, format.volume), text_color=color.white, text_halign="center", text_valign="center"))
````
