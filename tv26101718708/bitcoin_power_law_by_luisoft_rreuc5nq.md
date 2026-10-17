# Bitcoin Power Law by Luisoft

- url: https://www.tradingview.com/script/RreUc5nQ/
- type: indicator
- pine_id: PUB;b2c1ef814e53491a97ec8fcc62f8d1c6
- version: 1.0

## Description

📈 This indicator implements the quantitative [b]Power Law[/b] model for Bitcoin, specifically designed to analyze its long-term growth structure. Unlike traditional models, this perspective demonstrates that Bitcoin's growth is fundamentally exponential.

By projecting this behavior onto a logarithmic scale, the curve adopts a linear trajectory (a constant and predictable slope). This shows that the asset's expansion is not decelerating; instead, it maintains a continuous structural growth rate from its genesis block, making it possible to establish clear mathematical zones of accumulation and distribution.

The script has been optimized at both the mathematical and design levels to offer a clean interface, an ultra-smooth future projection, and an interactive data dashboard for macroeconomic decision-making.

## Source Code

````pine
//@version=6
indicator("BTC Power Law - Luisoft", overlay=true, max_lines_count=500)

// --- 1. Parámetros Exactos (Configuración por Defecto) ---
startYear  = input.int(2009, title="Año de Inicio (Génesis)", group="Configuración de Tiempo")
startMonth = input.int(-15, title="Mes de Inicio", group="Configuración de Tiempo")
startDay   = input.int(5, title="Día de Inicio", group="Configuración de Tiempo")

intercept = input.float(-21.539, title="Intercepto (A)", step=0.1, group="Parámetros de la Ley de Potencias")
slope     = input.float(7, title="Pendiente (B)", step=0.1, group="Parámetros de la Ley de Potencias")
sigma     = input.float(0.24, title="1σ Ancho (log10)", step=0.01, group="Parámetros de la Ley de Potencias")

// Controles de Proyección y Opacidad
extendYears = input.int(5, title="Extender en el Futuro (Años)", minval=0, group="Proyección Futura")
futLineOp   = input.int(40, title="Opacidad Líneas Futuras (%)", minval=0, maxval=100, step=5, group="Proyección Futura")
futFillOp   = input.int(15, title="Opacidad Rellenos Futuros (%)", minval=0, maxval=100, step=5, group="Proyección Futura")

futLineTransp = 100 - futLineOp
futFillTransp = 100 - futFillOp

showPanel = input.bool(true, title="Mostrar Panel de Datos", group="Interfaz")

// --- 2. Cálculos de Tiempo y Ecuación ---
startTime = timestamp(startYear, startMonth, startDay, 0, 0, 0)
daysSince = (time - startTime) / 86400000.0

var float p0 = na
var float p1_up = na, var float p2_up = na
var float p1_dn = na, var float p2_dn = na
var float zScore = na

if daysSince > 0
    logFair = intercept + slope * math.log10(daysSince)
    
    p0 := math.pow(10, logFair)
    p1_up := math.pow(10, logFair + sigma)
    p2_up := math.pow(10, logFair + (2 * sigma))
    p1_dn := math.pow(10, logFair - sigma)
    p2_dn := math.pow(10, logFair - (2 * sigma))
    zScore := (math.log10(close) - logFair) / sigma

// --- 3. Paleta de Colores ---
col_2u = color.new(#ffeb3b, 0)   // Amarillo (+2σ)
col_1u = color.new(#ffeb3b, 0)   // Amarillo (+1σ)
col_0  = color.new(#ff9800, 0)   // Naranja (Fair Value)
col_1d = color.new(#26c6da, 0)   // Cyan (-1σ)
col_2d = color.new(#26c6da, 0)   // Cyan (-2σ)

c2u_fut = color.new(#ffeb3b, futLineTransp)
c1u_fut = color.new(#ffeb3b, futLineTransp)
c0_fut  = color.new(#ff9800, futLineTransp)
c1d_fut = color.new(#26c6da, futLineTransp)
c2d_fut = color.new(#26c6da, futLineTransp)
fill_up_color = color.new(#f23645, futFillTransp)
fill_dn_color = color.new(#0097a7, futFillTransp)

// --- 4. Renderizado Histórico ---
plot_2u = plot(daysSince > 0 ? p2_up : na, color=col_2u, linewidth=1, title="+2σ")
plot_1u = plot(daysSince > 0 ? p1_up : na, color=col_1u, linewidth=1, title="+1σ")
plot_0  = plot(daysSince > 0 ? p0 : na, color=col_0, linewidth=1, title="Fair Value")
plot_1d = plot(daysSince > 0 ? p1_dn : na, color=col_1d, linewidth=1, title="-1σ")
plot_2d = plot(daysSince > 0 ? p2_dn : na, color=col_2d, linewidth=1, title="-2σ")

fill(plot_1u, plot_2u, color=color.new(#f23645, 85), title="Fill +1 a +2")
fill(plot_0, plot_1u, color=color.new(#f23645, 85), title="Fill 0 a +1", display=display.none)
fill(plot_0, plot_1d, color=color.new(#0097a7, 85), title="Fill 0 a -1", display=display.none)
fill(plot_1d, plot_2d, color=color.new(#0097a7, 85), title="Fill -1 a -2")

// --- 5. Motor de Proyección Futura (Anclaje Perfecto por Índices Visuales) ---
var int lblIndex = bar_index
var float lbl_2u = p2_up, var float lbl_1u = p1_up, var float lbl_0 = p0
var float lbl_1d = p1_dn, var float lbl_2d = p2_dn

var futureLines = array.new<line>()
var futureFills = array.new<linefill>()

if barstate.islast and extendYears > 0
    if array.size(futureLines) > 0
        for l in futureLines
            line.delete(l)
        array.clear(futureLines)
    if array.size(futureFills) > 0
        for lf in futureFills
            linefill.delete(lf)
        array.clear(futureFills)

    // Calculamos el espacio exacto del timeframe para evitar los cortes de escalera
    float step_ms = time - nz(time[1], time)
    if step_ms == 0
        step_ms := 86400000.0 // Fallback diario por seguridad

    int totalFutureBars = int((extendYears * 365.25 * 86400000) / step_ms)
    
    // Limitamos a 90 segmentos para garantizar la máxima suavidad sin superar la memoria
    int segments = totalFutureBars > 0 ? math.min(totalFutureBars, 90) : 90
    float barStep = totalFutureBars / segments
    float timeStep = (extendYears * 365.25 * 86400000) / segments
    
    float last_p2_up = p2_up, float last_p1_up = p1_up, float last_p0 = p0
    float last_p1_dn = p1_dn, float last_p2_dn = p2_dn
    int last_index = bar_index
    
    for i = 1 to segments
        int fIndex = int(bar_index + (i * barStep))
        float fTime = time + (i * timeStep)
        float fDaysSince = (fTime - startTime) / 86400000.0
        
        if fDaysSince > 0
            float fLogFair = intercept + slope * math.log10(fDaysSince)
            float next_p0    = math.pow(10, fLogFair)
            float next_p1_up = math.pow(10, fLogFair + sigma)
            float next_p2_up = math.pow(10, fLogFair + (2 * sigma))
            float next_p1_dn = math.pow(10, fLogFair - sigma)
            float next_p2_dn = math.pow(10, fLogFair - (2 * sigma))
            
            // Usamos xloc.bar_index para forzar la suavidad perfecta en cualquier escala logarítmica
            line l2u = line.new(last_index, last_p2_up, fIndex, next_p2_up, xloc=xloc.bar_index, color=c2u_fut, width=1, style=line.style_solid)
            line l1u = line.new(last_index, last_p1_up, fIndex, next_p1_up, xloc=xloc.bar_index, color=c1u_fut, width=1, style=line.style_solid)
            line l0  = line.new(last_index, last_p0,    fIndex, next_p0,    xloc=xloc.bar_index, color=c0_fut,  width=1, style=line.style_solid)
            line l1d = line.new(last_index, last_p1_dn, fIndex, next_p1_dn, xloc=xloc.bar_index, color=c1d_fut, width=1, style=line.style_solid)
            line l2d = line.new(last_index, last_p2_dn, fIndex, next_p2_dn, xloc=xloc.bar_index, color=c2d_fut, width=1, style=line.style_solid)
            
            array.push(futureLines, l2u), array.push(futureLines, l1u), array.push(futureLines, l0)
            array.push(futureLines, l1d), array.push(futureLines, l2d)
            
            linefill fill_up = linefill.new(l1u, l2u, fill_up_color)
            linefill fill_dn = linefill.new(l2d, l1d, fill_dn_color)
            
            array.push(futureFills, fill_up), array.push(futureFills, fill_dn)
            
            last_index := fIndex
            last_p2_up := next_p2_up, last_p1_up := next_p1_up, last_p0 := next_p0
            last_p1_dn := next_p1_dn, last_p2_dn := next_p2_dn
            
            if i == segments
                lblIndex := fIndex
                lbl_2u := next_p2_up, lbl_1u := next_p1_up, lbl_0 := next_p0
                lbl_1d := next_p1_dn, lbl_2d := next_p2_dn

else if barstate.islast and extendYears == 0
    lblIndex := bar_index
    lbl_2u := p2_up, lbl_1u := p1_up, lbl_0 := p0
    lbl_1d := p1_dn, lbl_2d := p2_dn

// --- 6. Etiquetas Dinámicas ---
var label l2u = na, var label l1u = na, var label l0 = na, var label l1d = na, var label l2d = na

if barstate.islast
    label.delete(l2u), label.delete(l1u), label.delete(l0), label.delete(l1d), label.delete(l2d)
    l2u := label.new(lblIndex, lbl_2u, "+2σ  $" + str.tostring(lbl_2u, "#,###"), color=color.new(color.black, 100), style=label.style_label_left, textcolor=c2u_fut, size=size.small, xloc=xloc.bar_index)
    l1u := label.new(lblIndex, lbl_1u, "+1σ  $" + str.tostring(lbl_1u, "#,###"), color=color.new(color.black, 100), style=label.style_label_left, textcolor=c1u_fut, size=size.small, xloc=xloc.bar_index)
    l0  := label.new(lblIndex, lbl_0, "Fair Value: $" + str.tostring(lbl_0, "#,###"), color=color.new(color.black, 100), style=label.style_label_left, textcolor=c0_fut, size=size.small, xloc=xloc.bar_index)
    l1d := label.new(lblIndex, lbl_1d, "-1σ  $" + str.tostring(lbl_1d, "#,###"), color=color.new(color.black, 100), style=label.style_label_left, textcolor=c1d_fut, size=size.small, xloc=xloc.bar_index)
    l2d := label.new(lblIndex, lbl_2d, "-2σ  $" + str.tostring(lbl_2d, "#,###"), color=color.new(color.black, 100), style=label.style_label_left, textcolor=c2d_fut, size=size.small, xloc=xloc.bar_index)

// --- 7. Tabla de Datos (Dashboard) ---
var table tb = table.new(position.bottom_right, 2, 7, bgcolor=color.new(#131722, 10), border_width=1, border_color=color.new(color.gray, 70))

if barstate.islast
    if showPanel
        table.cell(tb, 0, 0, "BTC Power Law - Luisoft", text_color=color.white, bgcolor=color.new(color.gray, 60), text_size=size.small)
        table.cell(tb, 1, 0, "Price (USD)", text_color=color.white, bgcolor=color.new(color.gray, 60), text_size=size.small)
        table.cell(tb, 0, 1, "Current Price", text_color=color.gray, text_size=size.small)
        table.cell(tb, 1, 1, "$" + str.tostring(close, "#,###"), text_color=color.new(#F59223, 0), text_size=size.small)
        table.cell(tb, 0, 2, "Fair Value (0σ)", text_color=color.gray, text_size=size.small)
        table.cell(tb, 1, 2, "$" + str.tostring(p0, "#,###"), text_color=color.white, text_size=size.small)
        zColor = zScore > 0 ? color.red : color.green
        table.cell(tb, 0, 3, "Z-Score (σ)", text_color=color.gray, text_size=size.small)
        table.cell(tb, 1, 3, str.tostring(zScore, "#.##") + "σ", text_color=zColor, text_size=size.small)
        table.cell(tb, 0, 4, "Days Since Genesis", text_color=color.gray, text_size=size.small)
        table.cell(tb, 1, 4, str.tostring(daysSince, "#,###"), text_color=color.white, text_size=size.small)
        table.cell(tb, 0, 5, "Slope / Intercept", text_color=color.gray, text_size=size.small)
        table.cell(tb, 1, 5, str.tostring(slope) + " / " + str.tostring(intercept), text_color=color.white, text_size=size.small)
        table.cell(tb, 0, 6, "1σ Width (log10)", text_color=color.gray, text_size=size.small)
        table.cell(tb, 1, 6, str.tostring(sigma), text_color=color.white, text_size=size.small)
    else
        table.clear(tb, 0, 0, 1, 6) // Esto borra la tabla de la pantalla si desmarcas la casilla
````
