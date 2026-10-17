# Cambio Tendencia Ema

- url: https://www.tradingview.com/script/AaCGbfMZ/
- type: indicator
- pine_id: PUB;a8ee902f18e04989a346750ba0e23099
- version: 2.0

## Description

Este indicador se basa en una media movil exponencial, cuando la vela cruza el 50% de la ema, da una sela de compra o venta, configurable para filtrar falsas entradas

## Source Code

````pine
//@version=5


indicator("Cambio Tendencia - 50% Body sobre EMA", overlay=true,
     max_labels_count=200)

// ============ INPUTS: EMA ============
grpEMA = "📈 Configuración EMA"
emaLen = input.int(20, "Período EMA", minval=1, group=grpEMA)
emaSrc = input.source(close, "Fuente", group=grpEMA)
emaTF  = input.timeframe("", "Timeframe (vacío = chart actual)", group=grpEMA,
     tooltip="Vacío = usa el timeframe del chart.\nPara EMA de 20 min en chart de 5m, deja vacío con período 4.\nPara EMA(20) calculada sobre velas de 20m, escribe '20' aquí.")

// ============ INPUTS: VISUALIZACIÓN ============
grpVis = "🎨 Visualización"
showEMA = input.bool(true, "Mostrar línea EMA", group=grpVis)
colEMA  = input.color(#2196F3, "Color EMA estática", group=grpVis)
emaWidth = input.int(2, "Grosor EMA", minval=1, maxval=5, group=grpVis)

// EMA dinámica por pendiente
useDynamicEMA = input.bool(false, "EMA dinámica por pendiente", group=grpVis,
     tooltip="Colorea la EMA según su pendiente:\n• Verde = subiendo\n• Roja = bajando\n• Gris = lateral (pendiente menor al umbral)")
colEMAUp   = input.color(color.lime, "EMA subiendo", group=grpVis, inline="ema_dyn")
colEMADown = input.color(#FF1744, "EMA bajando", group=grpVis, inline="ema_dyn")
colEMAFlat = input.color(color.gray, "EMA lateral", group=grpVis, inline="ema_dyn")
slopeLookback = input.int(3, "Barras para medir pendiente", minval=1, maxval=20, group=grpVis,
     tooltip="Cuántas barras atrás comparar el valor de la EMA para determinar la pendiente.")

paintBars = input.bool(true, "Colorear velas señal", group=grpVis)
colBull = input.color(color.lime, "Cambio alcista (▲)", group=grpVis)
colBear = input.color(#FF1744, "Cambio bajista (▼)", group=grpVis)

forceNeutral = input.bool(false, "Forzar color en velas no-señal", group=grpVis,
     tooltip="Si está APAGADO (recomendado): solo las velas señal se pintan, las demás conservan tu gris original.\nSi está ENCENDIDO: todas las velas no-señal se pintan con el color neutral elegido.")
colNeut = input.color(color.gray, "Color neutral (si forzado)", group=grpVis)

showLabels = input.bool(true, "Etiquetas ▲/▼ en señales", group=grpVis)
labelSize  = input.string("small", "Tamaño etiqueta", 
     options=["tiny", "small", "normal", "large"], group=grpVis)
showBg     = input.bool(false, "Fondo coloreado en señal", group=grpVis,
     tooltip="Pinta una franja vertical sutil en la vela señal. Útil para destacar más.")

// Línea de última señal extendida
showLastSignalLine = input.bool(true, "Línea horizontal de última señal", group=grpVis,
     tooltip="Proyecta el precio de cierre de la última señal como línea horizontal hacia la derecha.\nÚtil para ver el nivel de referencia del último cambio.")
lastLineStyle = input.string("dashed", "Estilo de línea", 
     options=["solid", "dashed", "dotted"], group=grpVis)
lastLineWidth = input.int(1, "Grosor línea última señal", minval=1, maxval=4, group=grpVis)

// Contador de barras desde última señal
showCounter = input.bool(true, "Contador de barras desde última señal", group=grpVis,
     tooltip="Muestra una etiqueta flotante en la última vela con el número de barras transcurridas desde el último cambio de tendencia.")
counterPos = input.string("top_right", "Posición contador",
     options=["top_right","top_left","bottom_right","bottom_left","middle_right","middle_left"], group=grpVis)

// ============ INPUTS: FILTROS (opcionales) ============
grpFilt = "🔍 Filtros (reducir ruido)"
useMinBody = input.bool(false, "Filtrar velas con body muy pequeño", group=grpFilt,
     tooltip="Ignora señales cuando el body de la vela es menor a un % del ATR.\nEvita señales en velas doji o de cuerpo mínimo.")
minBodyATR = input.float(0.3, "Body mínimo (× ATR)", minval=0.1, maxval=2.0, step=0.1, group=grpFilt)
atrLen     = input.int(14, "Período ATR", minval=1, group=grpFilt)

useDistance = input.bool(false, "Requerir distancia mínima desde EMA", group=grpFilt,
     tooltip="La vela anterior debe estar a cierta distancia de la EMA, no apenas tocándola.\nEvita señales en chop alrededor de la EMA.")
minDistATR  = input.float(0.2, "Distancia mínima (× ATR)", minval=0.05, maxval=2.0, step=0.05, group=grpFilt)

// ============ CÁLCULO EMA ============
emaCalc() => ta.ema(emaSrc, emaLen)
ema = request.security(syminfo.tickerid, emaTF == "" ? timeframe.period : emaTF, emaCalc())

// ============ DETECCIÓN ============
bodyMid = (open + close) / 2
bodySize = math.abs(close - open)
atr = ta.atr(atrLen)

// Filtros opcionales
bodyOK = not useMinBody or (bodySize >= minBodyATR * atr)
distOK = not useDistance or (math.abs(bodyMid[1] - ema[1]) >= minDistATR * atr)

// Señal: el midpoint del body cruzó la EMA al otro lado
bullSignal = bodyMid > ema and bodyMid[1] <= ema[1] and bodyOK and distOK
bearSignal = bodyMid < ema and bodyMid[1] >= ema[1] and bodyOK and distOK

// ============ DIBUJO ============

// --- 1. EMA con color dinámico opcional ---
emaSlope = ema - ema[slopeLookback]
slopeThreshold = atr * 0.05  // umbral mínimo para considerar lateral
emaColorDyn = emaSlope > slopeThreshold ? colEMAUp :
              emaSlope < -slopeThreshold ? colEMADown :
              colEMAFlat
emaFinalColor = useDynamicEMA ? emaColorDyn : colEMA

plot(showEMA ? ema : na, "EMA", emaFinalColor, emaWidth)

// --- Color de velas: solo señal, o neutral forzado ---
barcolor(paintBars ? 
     (bullSignal ? colBull : 
      bearSignal ? colBear : 
      (forceNeutral ? colNeut : na)) : na)

// --- Fondo opcional ---
bgcolor(showBg ? (bullSignal ? color.new(colBull, 85) : bearSignal ? color.new(colBear, 85) : na) : na)

// --- Etiquetas ▲/▼ ---
sizeMap = labelSize == "tiny" ? size.tiny : 
          labelSize == "small" ? size.small : 
          labelSize == "normal" ? size.normal : size.large

if showLabels and bullSignal
    label.new(bar_index, low, "▲", 
         color=color.new(colBull, 20), textcolor=color.white, 
         style=label.style_label_up, size=sizeMap)

if showLabels and bearSignal
    label.new(bar_index, high, "▼", 
         color=color.new(colBear, 20), textcolor=color.white, 
         style=label.style_label_down, size=sizeMap)

// --- 2. Línea horizontal de última señal ---
var line   lastSignalLine  = na
var label  lastSignalLabel = na
var float  lastSignalPrice = na
var int    lastSignalBar   = na
var bool   lastSignalIsBull = na

lineStyleMap = lastLineStyle == "solid"  ? line.style_solid :
               lastLineStyle == "dashed" ? line.style_dashed :
               line.style_dotted

if bullSignal or bearSignal
    lastSignalPrice  := close
    lastSignalBar    := bar_index
    lastSignalIsBull := bullSignal
    
    if showLastSignalLine
        // Borrar la línea anterior
        if not na(lastSignalLine)
            line.delete(lastSignalLine)
        if not na(lastSignalLabel)
            label.delete(lastSignalLabel)
        
        // Crear nueva línea desde la señal hacia la derecha
        lineColor = bullSignal ? colBull : colBear
        lastSignalLine := line.new(x1=bar_index, y1=close, x2=bar_index + 1, y2=close,
             color=lineColor, style=lineStyleMap, width=lastLineWidth, extend=extend.right)

// Actualizar etiqueta de precio en el extremo derecho de la línea
if showLastSignalLine and not na(lastSignalPrice) and barstate.islast
    if not na(lastSignalLabel)
        label.delete(lastSignalLabel)
    lblColor = lastSignalIsBull ? colBull : colBear
    arrow = lastSignalIsBull ? "▲" : "▼"
    lastSignalLabel := label.new(x=bar_index + 5, y=lastSignalPrice, 
         text=arrow + " " + str.tostring(lastSignalPrice, format.mintick),
         color=color.new(lblColor, 20), textcolor=color.white,
         style=label.style_label_left, size=size.small)

// --- 3. Contador de barras desde última señal ---
var table counterTable = table.new(
     counterPos == "top_right" ? position.top_right :
     counterPos == "top_left" ? position.top_left :
     counterPos == "bottom_right" ? position.bottom_right :
     counterPos == "bottom_left" ? position.bottom_left :
     counterPos == "middle_right" ? position.middle_right :
     position.middle_left,
     1, 3, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.gray)

if showCounter and barstate.islast
    barsSince = na(lastSignalBar) ? na : bar_index - lastSignalBar
    
    table.cell(counterTable, 0, 0, "ÚLTIMA SEÑAL", 
         text_color=color.white, bgcolor=color.new(color.blue, 40), text_size=size.small)
    
    if na(barsSince)
        table.cell(counterTable, 0, 1, "Sin señal aún", 
             text_color=color.gray, text_size=size.small)
        table.cell(counterTable, 0, 2, "—", 
             text_color=color.gray, text_size=size.small)
    else
        signalText = lastSignalIsBull ? "▲ ALCISTA" : "▼ BAJISTA"
        signalColor = lastSignalIsBull ? colBull : colBear
        table.cell(counterTable, 0, 1, signalText, 
             text_color=signalColor, text_size=size.small)
        // Cambiar color del contador según tiempo transcurrido
        countColor = barsSince <= 5 ? color.lime :
                     barsSince <= 15 ? color.yellow :
                     barsSince <= 30 ? color.orange : color.red
        table.cell(counterTable, 0, 2, "Hace " + str.tostring(barsSince) + " velas",
             text_color=countColor, text_size=size.small)


// ============ ALERTAS ============
alertcondition(bullSignal, "Cambio Alcista (50% body sobre EMA)", 
     "Body midpoint cruzó EMA hacia arriba — posible cambio de tendencia alcista")
alertcondition(bearSignal, "Cambio Bajista (50% body bajo EMA)", 
     "Body midpoint cruzó EMA hacia abajo — posible cambio de tendencia bajista")
alertcondition(bullSignal or bearSignal, "Cualquier cambio de tendencia", 
     "Señal de cambio de tendencia detectada")
````
