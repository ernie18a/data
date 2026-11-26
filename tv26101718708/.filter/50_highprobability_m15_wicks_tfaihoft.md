# 50% High-Probability M15 Wicks

- url: https://www.tradingview.com/script/TFAIhoFt/
- type: indicator
- pine_id: PUB;53381d634c604d30903b4d1496f4dbc9
- version: 1.0

## Description

[b]Description[/b]
This indicator isolates high-probability liquidity grabs and institutional reference points by tracking M15 (15-minute) candle wicks that exhibit unusual size and volume. It automatically calculates and projects the 50% equilibrium level of these specific wicks as key horizontal support/resistance areas.

Engineered for multi-temporal flexibility, it allows you to scale down to lower execution timeframes (M1, M5) or up to macro views (H1, H4) while maintaining the precise M15 levels fixed on your chart.

[b]What it tracks & Why:
[/b]High-Probability Wick Filter: It calculates the average wick size over a specific period and only triggers when a 15-minute wick exceeds this average by a custom multiplier, ensuring it only flags significant market expansions.

[b]Liquidity Sweeps:[/b] It validates the setup by confirming that the wick successfully swept the previous candle's high or low, signaling a true hunt for stops before a reversal.

[b]Smart Proximity Mitigation:[/b] To maintain a clean workspace and avoid false signals, the indicator automatically deletes active levels in real-time if the price mitigates the 50% level or approaches it within a custom % ATR threshold (pre-mitigation zone).

[b]Key Features:
[/b]True MTF Precision: Swap between any timeframe without lines shifting, breaking, or disappearing.

[b]Real-time Price Labels:[/b] Displays floating current prices next to active levels for quick execution.

[b]Fully Customizable Visuals:[/b] Easily toggle line styles (dotted, dashed, solid), thickness, transparency, and text sizes directly from the settings menu.

## Source Code

````pine
//@version=6
indicator("50% Mechas Alta Probabilidad M15 - Full Configurable", overlay=true, max_boxes_count=500)

// ==========================================
// 1. CONFIGURACIÓN DE PARÁMETROS Y ESTILOS
// ==========================================
var string G_ESTRATEGIA = "Configuración de Estrategia"
multiplicador  = input.float(1.2, title="Multiplicador de Tamaño de Mecha", step=0.1, group=G_ESTRATEGIA)
periodoProm    = input.int(20, title="Periodo Promedio de Mechas", group=G_ESTRATEGIA)
porcentajeATR  = input.float(15.0, title="Distancia de Descarte (% ATR M15)", minval=0.0, maxval=100.0, step=5.0, group=G_ESTRATEGIA) / 100

var string G_ZONA_SUP = "Zonas Superiores (Ventas)"
colorMechaSup  = input.color(color.new(color.red, 10), title="Color Mecha Superior", group=G_ZONA_SUP)

var string G_ZONA_INF = "Zonas Inferiores (Compras)"
colorMechaInf  = input.color(color.new(color.green, 10), title="Color Mecha Inferior", group=G_ZONA_INF)

var string G_VISUAL = "Personalización Visual de Líneas"
estiloLinea    = input.string("Dotted (Puntos)", title="Estilo de Línea", options=["Dotted (Puntos)", "Dashed (Discontinua)", "Solid (Sólida)"], group=G_VISUAL)
grosorLinea    = input.int(1, title="Grosor de Línea (px)", minval=1, maxval=4, group=G_VISUAL)
opacidadFondo  = input.int(100, title="Transparencia del Fondo (100 = Invisible)", minval=0, maxval=100, group=G_VISUAL)

var string G_TEXTO = "Configuración de Precios (Etiquetas)"
mostrarPrecio  = input.bool(true, title="Mostrar Etiqueta de Precio", group=G_TEXTO)
tamanioTexto   = input.string("Normal", title="Tamaño del Texto", options=["Chico", "Normal", "Grande"], group=G_TEXTO)

// Convertir las opciones de texto de los inputs a variables nativas de Pine Script
funcionEstilo() =>
    switch estiloLinea
        "Dotted (Puntos)"       => line.style_dotted
        "Dashed (Discontinua)"   => line.style_dashed
        => line.style_solid

funcionTamanio() =>
    switch tamanioTexto
        "Chico"  => size.small
        "Grande" => size.large
        => size.normal

estiloLineaPine  = funcionEstilo()
tamanioTextoPine = funcionTamanio()

// ==========================================
// 2. ARRAYS PERSISTENTES
// ==========================================
var box[] lineasSuperiores = array.new<box>()
var label[] labelsSuperiores = array.new<label>()

var box[] lineasInferiores = array.new<box>()
var label[] labelsInferiores = array.new<label>()

// ==========================================
// 3. CÁLCULOS FILTRADO M15
// ==========================================
filtrarMechasM15() =>
    cuerpoSuperior = math.max(open, close)
    cuerpoInferior = math.min(open, close)
    
    tamanioMechaSup = high - cuerpoSuperior
    tamanioMechaInf = cuerpoInferior - low
    
    promMechaSup = ta.sma(tamanioMechaSup, periodoProm)
    promMechaInf = ta.sma(tamanioMechaInf, periodoProm)
    
    esMechaSupAltaProb = (tamanioMechaSup > promMechaSup * multiplicador) and (high > high[1])
    esMechaInfAltaProb = (tamanioMechaInf > promMechaInf * multiplicador) and (low < low[1])
    
    mitadMechaSup = esMechaSupAltaProb ? cuerpoSuperior + (tamanioMechaSup / 2) : na
    mitadMechaInf = esMechaInfAltaProb ? cuerpoInferior - (tamanioMechaInf / 2) : na
    
    atrM15 = ta.atr(14)
    [mitadMechaSup, mitadMechaInf, time, atrM15]

// Solicitar datos filtrados de M15
[m15_superior, m15_inferior, m15_tiempo, m15_atr] = request.security(syminfo.tickerid, "15", filtrarMechasM15(), barmerge.gaps_off, barmerge.lookahead_off)
umbralDescarte = m15_atr * porcentajeATR

// ==========================================
// 4. DIBUJO EN GRÁFICO (COORDENADAS DE TIEMPO)
// ==========================================
cambioBarraM15 = ta.change(m15_tiempo) != 0

if cambioBarraM15
    if not na(m15_superior[1])
        bx_sup = box.new(left=m15_tiempo[1], top=m15_superior[1], right=time + 86400000, bottom=m15_superior[1],
                         border_color=colorMechaSup, border_style=estiloLineaPine, border_width=grosorLinea,
                         bgcolor=color.new(colorMechaSup, opacidadFondo), extend=extend.right, xloc=xloc.bar_time)
        array.push(lineasSuperiores, bx_sup)
        
        if mostrarPrecio
            lbl_sup = label.new(x=time, y=m15_superior[1], text=str.tostring(m15_superior[1], "#.##"),
                                color=color.new(color.white, 100), textcolor=colorMechaSup,
                                style=label.style_label_left, xloc=xloc.bar_time, size=tamanioTextoPine)
            array.push(labelsSuperiores, lbl_sup)
            
    if not na(m15_inferior[1])
        bx_inf = box.new(left=m15_tiempo[1], top=m15_inferior[1], right=time + 86400000, bottom=m15_inferior[1],
                         border_color=colorMechaInf, border_style=estiloLineaPine, border_width=grosorLinea,
                         bgcolor=color.new(colorMechaInf, opacidadFondo), extend=extend.right, xloc=xloc.bar_time)
        array.push(lineasInferiores, bx_inf)
        
        if mostrarPrecio
            lbl_inf = label.new(x=time, y=m15_inferior[1], text=str.tostring(m15_inferior[1], "#.##"),
                                color=color.new(color.white, 100), textcolor=colorMechaInf,
                                style=label.style_label_left, xloc=xloc.bar_time, size=tamanioTextoPine)
            array.push(labelsInferiores, lbl_inf)

// Desplazar etiquetas vivas a la derecha
if mostrarPrecio
    if array.size(labelsSuperiores) > 0
        for i = 0 to array.size(labelsSuperiores) - 1
            label.set_x(array.get(labelsSuperiores, i), time)

    if array.size(labelsInferiores) > 0
        for i = 0 to array.size(labelsInferiores) - 1
            label.set_x(array.get(labelsInferiores, i), time)

// ==========================================
// 5. MITIGACIÓN TOTAL Y DESCARTE PROXIMIDAD
// ==========================================
puedeMitigar = timeframe.isminutes and timeframe.multiplier <= 15

if puedeMitigar
    if array.size(lineasSuperiores) > 0
        for i = array.size(lineasSuperiores) - 1 to 0
            box_actual = array.get(lineasSuperiores, i)
            nivel_precio = box.get_top(box_actual)
            
            if high >= (nivel_precio - umbralDescarte)
                box.delete(box_actual)
                array.remove(lineasSuperiores, i)
                
                if mostrarPrecio and array.size(labelsSuperiores) > i
                    lbl_actual = array.get(labelsSuperiores, i)
                    label.delete(lbl_actual)
                    array.remove(labelsSuperiores, i)

    if array.size(lineasInferiores) > 0
        for i = array.size(lineasInferiores) - 1 to 0
            box_actual = array.get(lineasInferiores, i)
            nivel_precio = box.get_top(box_actual)
            
            if low <= (nivel_precio + umbralDescarte)
                box.delete(box_actual)
                array.remove(lineasInferiores, i)
                
                if mostrarPrecio and array.size(labelsInferiores) > i
                    lbl_actual = array.get(labelsInferiores, i)
                    label.delete(lbl_actual)
                    array.remove(labelsInferiores, i)
````
