# BTC CYCLES - DEFINITIVE [BETA v1]

- url: https://www.tradingview.com/script/GryLZsp3/
- type: indicator
- pine_id: PUB;7623110c706b41c5b6a78f0bef271fca
- version: 2.0

## Description

This macro analysis indicator is designed to mathematically and visually identify Bitcoin's structural floors throughout its entire history, while also projecting the temporal phases of market cycles (Bull and Bear Markets).

[b]Key Features:[/b]
Custom Floor Curve (21 Historical Points): Utilizes a matrix of fixed time and price coordinates meticulously calibrated from October 2010 ($0.01) up to 2030 projections. This high granularity eliminates logarithmic distortion in the early cycles, perfectly tracking real historical price supports.

Variable Cycle Metrics: Allows users to configure the exact estimated duration in days for both bull markets (Dias de Bull, default: 1064 days) and bear markets (Dias de Bear, default: 364 days).

Shaded Zones & Performance Metrics: Automatically renders historical cycle boxes, calculating the exact percentage ROI (+X%) achieved from the absolute bottom to the peak of each cycle, alongside the actual duration of the move.

Visual Synchronicity Alerts: Features explicit on-chart markers (BUY / SELL) and historical Halving milestones calculated precisely using the Madrid time zone (Europe/Madrid).

Future Projections: Includes a predictive visual module that maps out estimated areas for the upcoming cycle (5th Halving, 5th TOP, and 5th Bottom) based on user inputs.

[b]How to Use:[/b]
For the best visual experience, it is highly recommended to use this indicator on Weekly (1W) or Daily (1D) timeframes and with the Logarithmic Scale ENABLED on your TradingView chart to properly appreciate the curvature of the purple macro support line.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © nahumperez86

//@version=6
indicator("BTC CYCLES — Halvings, BUY/SELL zones & much more [BETA v6]", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// --- INPUTS SIMPLIFICADOS ---
g_mod = "Parametros del Modelo"
diasBull = input.int(1064, "Dias de Bull", group = g_mod)
diasBear = input.int(364,  "Dias de Bear", group = g_mod)

g_vis = "Mostrar / ocultar"
showHalving  = input.bool(true, "Halvings", group = g_vis, inline = "a")
showHalvLbl  = input.bool(true, "Etiqueta halving", group = g_vis, inline = "a")
showTops     = input.bool(true, "TOPs", group = g_vis, inline = "b")
showBottoms  = input.bool(true, "BOTTOMs", group = g_vis, inline = "b")
showZonas    = input.bool(true, "Zonas sombreadas", group = g_vis, inline = "c")
showRend     = input.bool(true, "% rendimiento historico", group = g_vis, inline = "c")
showEtiqueta = input.bool(true, "Etiqueta TOP/BOTTOM", group = g_vis, inline = "d")
showSenal    = input.bool(true, "Senal BUY/SELL historica", group = g_vis, inline = "d")
showProy     = input.bool(true, "Mostrar Estructura Proxima (Sin Datos)", group = g_vis)
showSuelo    = input.bool(true, "Mostrar Linea de Suelo Morada", group = g_vis)

g_col = "Colores base"
colHalv = input.color(color.blue, "Color Halvings", group = g_col)
colTop  = input.color(color.green, "Color TOPs", group = g_col)
colBot  = input.color(color.red, "Color BOTTOMs", group = g_col)
colBull = input.color(color.green, "Zona Bull", group = g_col)
colBear = input.color(color.red, "Zona Bear", group = g_col)
colSenal = input.color(color.yellow, "Circulo Senal", group = g_col)

g_p = "Proyeccion futura (Solo niveles visuales)"
pBottom4 = input.float(57800, "Nivel estimado 4o Bear", group = g_p)
pTop5    = input.float(220000,"Nivel estimado 5o Top", group = g_p)
pBottom5 = input.float(110000,"Nivel estimado 5o Bear", group = g_p)

// --- DATOS HISTÓRICOS ESTRUCTURALES ---
MS_DIA = 86400000
halvT = array.from(timestamp("2012-11-28T00:00"), timestamp("2016-07-09T00:00"), timestamp("2020-05-11T00:00"), timestamp("2024-04-20T00:00"))
topT  = array.from(timestamp("2013-11-25T00:00"), timestamp("2017-12-17T00:00"), timestamp("2021-11-10T00:00"), timestamp("2025-10-06T00:00"))
topP  = array.from(1130.0, 19800.0, 69000.0, 126000.0)
botT  = array.from(timestamp("2015-01-12T00:00"), timestamp("2018-12-15T00:00"), timestamp("2022-11-21T00:00"))
botP  = array.from(170.0, 3200.0, 15500.0)

// --- CÁLCULO DE ALTURA PARA ETIQUETAS (Scope Global) ---
low500 = ta.lowest(low, 500)
high500 = ta.highest(high, 500)
yRend = math.pow(10, math.log10(low500) + 0.55 * (math.log10(high500) - math.log10(low500)))

// =======================================================
// --- MATRIZ DEL SUELO REAL (21 PUNTOS PRECISOS) -------
// =======================================================
sueloFechas = array.from(
   timestamp("2010-10-18T00:00"), timestamp("2011-01-03T00:00"), timestamp("2011-05-02T00:00"),
   timestamp("2011-11-07T00:00"), timestamp("2012-05-28T00:00"), timestamp("2012-12-03T00:00"),
   timestamp("2013-06-03T00:00"), timestamp("2013-11-25T00:00"), timestamp("2014-06-23T00:00"),
   timestamp("2015-01-12T00:00"), timestamp("2016-07-11T00:00"), timestamp("2017-12-18T00:00"),
   timestamp("2018-12-17T00:00"), timestamp("2020-05-11T00:00"), timestamp("2021-11-15T00:00"),
   timestamp("2022-11-21T00:00"), timestamp("2024-04-22T00:00"), timestamp("2025-10-06T00:00"),
   timestamp("2026-10-05T00:00"), timestamp("2028-04-03T00:00"), timestamp("2029-09-03T00:00"),
   timestamp("2030-09-02T00:00")
 )
sueloPrecios = array.from(
   0.01, 0.06, 0.26, 1.03, 3.79, 9.77, 20.82, 39.66, 78.83, 143.74, 579.81, 1619.04, 2990.58, 6243.08, 12531.91, 18804.75, 30981.64, 48639.09, 63362.61, 89689.14, 119933.68, 143333.62
 )

// --- DIBUJO EN LA ÚLTIMA BARRA ---
if barstate.islast
    // Trazado de la Curva del Suelo
    if showSuelo
        for i = 0 to array.size(sueloFechas) - 2
            int x1 = array.get(sueloFechas, i)
            int x2 = array.get(sueloFechas, i + 1)
            float s1 = array.get(sueloPrecios, i)
            float s2 = array.get(sueloPrecios, i + 1)
            line.new(x1=x1, y1=s1, x2=x2, y2=s2, xloc=xloc.bar_time, color=color.rgb(111, 0, 255, 46), width=12, style=line.style_solid)

    // Halvings Históricos
    if showHalving
        for i = 0 to array.size(halvT) - 1
            t = array.get(halvT, i)
            line.new(x1 = t, y1 = 0, x2 = t, y2 = 1000, xloc = xloc.bar_time, extend = extend.both, color = colHalv, style = line.style_solid, width = 2)
            if showHalvLbl
                txt = (i+1 == 1 ? "1er" : i+1 == 2 ? "2do" : i+1 == 3 ? "3er" : "4to") + " Halving\n"
                label.new(t, high500 * 1.08, xloc = xloc.bar_time, yloc = yloc.price, text = txt + str.format_time(t, "dd/MM/yyyy", "Europe/Madrid"), style = label.style_label_down, color = color.new(colHalv, 30), textcolor = color.white, size = size.small)

    if showTops
        for i = 0 to array.size(topT) - 1
            t = array.get(topT, i)
            line.new(x1 = t, y1 = 0, x2 = t, y2 = 1000, xloc = xloc.bar_time, extend = extend.both, color = colTop, style = line.style_dashed, width = 1)
    if showBottoms
        for i = 0 to array.size(botT) - 1
            t = array.get(botT, i)
            line.new(x1 = t, y1 = 0, x2 = t, y2 = 1000, xloc = xloc.bar_time, extend = extend.both, color = colBot, style = line.style_dashed, width = 1)

    if showEtiqueta
        for i = 0 to array.size(topT) - 1
            float precioTop = array.get(topP, i)
            label.new(array.get(topT, i), precioTop * 1.06, xloc = xloc.bar_time, yloc = yloc.price, text = "TOP " + str.tostring(i+1) + "\n$" + str.tostring(precioTop, "#"), style = label.style_label_center, color = color.new(colTop, 20), textcolor = color.white, size = size.normal)
        for i = 0 to array.size(botT) - 1
            float precioBot = array.get(botP, i)
            label.new(array.get(botT, i), precioBot * 0.94, xloc = xloc.bar_time, yloc = yloc.price, text = "BOTTOM " + str.tostring(i+1) + "\n$" + str.tostring(precioBot, "#"), style = label.style_label_center, color = color.new(colBot, 20), textcolor = color.white, size = size.normal)
    
    if showSenal
        for i = 0 to array.size(topT) - 1
            label.new(array.get(topT, i), array.get(topP, i), xloc = xloc.bar_time, yloc = yloc.price, style = label.style_circle, color = colSenal, size = size.normal)
            label.new(array.get(topT, i), array.get(topP, i) * 0.96, xloc = xloc.bar_time, yloc = yloc.price, text = "SELL", style = label.style_none, textcolor = color.red, size = size.normal)
        for i = 0 to array.size(botT) - 1
            label.new(array.get(botT, i), array.get(botP, i), xloc = xloc.bar_time, yloc = yloc.price, style = label.style_circle, color = colSenal, size = size.normal)
            label.new(array.get(botT, i), array.get(botP, i) * 1.04, xloc = xloc.bar_time, yloc = yloc.price, text = "BUY", style = label.style_none, textcolor = color.lime, size = size.normal)

    if showZonas or showRend
        if showZonas
            box.new(timestamp("2009-10-05T00:00"), 1244.0, timestamp("2013-11-25T00:00"), 0.00, xloc = xloc.bar_time, bgcolor = color.new(colBull, 85), border_color = color.new(colBull, 60))
        for i = 0 to array.size(botT) - 1
            if i + 1 <= array.size(topT) - 1
                bt = array.get(botT, i), bp = array.get(botP, i), tt = array.get(topT, i + 1), tp = array.get(topP, i + 1)
                if showZonas
                    box.new(bt, tp, tt, bp, xloc = xloc.bar_time, bgcolor = color.new(colBull, 85), border_color = color.new(colBull, 60))
                if showRend
                    label.new(math.round((bt + tt) / 2), yRend, xloc = xloc.bar_time, yloc = yloc.price, text = "+" + str.tostring((tp - bp) / bp * 100, "#,###.##") + "%\n" + str.tostring(diasBull) + "d", style = label.style_label_center, color = color.new(colBull, 30), textcolor = color.white, size = size.small)
        for i = 0 to array.size(botT) - 1
            tt = array.get(topT, i), tp = array.get(topP, i), bt = array.get(botT, i), bp = array.get(botP, i)
            int diasRealesBear = math.round((bt - tt) / MS_DIA)
            if showZonas
                box.new(tt, tp, bt, bp, xloc = xloc.bar_time, bgcolor = color.new(colBear, 85), border_color = color.new(colBear, 60))
            if showRend
                label.new(math.round((tt + bt) / 2), yRend, xloc = xloc.bar_time, yloc = yloc.price, text = str.tostring((bp - tp) / tp * 100, "#,###.##") + "%\n" + str.tostring(diasRealesBear) + "d", style = label.style_label_center, color = color.new(colBear, 30), textcolor = color.white, size = size.small)

    if showProy
        ultimoTop = array.get(topT, array.size(topT) - 1)
        ultimoTopP = array.get(topP, array.size(topT) - 1)
        proxBottom = ultimoTop + diasBear * MS_DIA
        halv5 = array.get(halvT, array.size(halvT) - 1) + 1441 * MS_DIA
        proxTop = proxBottom + diasBull * MS_DIA
        proxBottom2 = proxTop + diasBear * MS_DIA

        line.new(x1 = proxBottom, y1 = 0, x2 = proxBottom, y2 = 1000, xloc = xloc.bar_time, extend = extend.both, color = colBot, style = line.style_dashed, width = 1)
        line.new(x1 = halv5, y1 = 0, x2 = halv5, y2 = 1000, xloc = xloc.bar_time, extend = extend.both, color = colHalv, style = line.style_solid, width = 2)
        line.new(x1 = proxTop, y1 = 0, x2 = proxTop, y2 = 1000, xloc = xloc.bar_time, extend = extend.both, color = colTop, style = line.style_dashed, width = 1)
        line.new(x1 = proxBottom2, y1 = 0, x2 = proxBottom2, y2 = 1000, xloc = xloc.bar_time, extend = extend.both, color = colBot, style = line.style_dashed, width = 1)
        
        if showHalvLbl
            label.new(halv5, high500 * 1.08, xloc = xloc.bar_time, yloc = yloc.price, text = "5o Halving (Estimado)\n" + str.format_time(halv5, "dd/MM/yyyy", "Europe/Madrid"), style = label.style_label_down, color = color.new(colHalv, 30), textcolor = color.white, size = size.small)
        if showZonas
            box.new(ultimoTop, ultimoTopP, proxBottom, pBottom4, xloc = xloc.bar_time, bgcolor = color.new(colBear, 85), border_color = color.new(colBear, 60))
            box.new(proxBottom, pTop5, proxTop, pBottom4, xloc = xloc.bar_time, bgcolor = color.new(colBull, 85), border_color = color.new(colBull, 60))
            box.new(proxTop, pTop5, proxBottom2, pBottom5, xloc = xloc.bar_time, bgcolor = color.new(colBear, 85), border_color = color.new(colBear, 60))
````
