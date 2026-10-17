# appaz utbot con Filtro EMA y Agotamiento

- url: https://www.tradingview.com/script/XrryUPz1/
- type: indicator
- pine_id: PUB;1d798851c5214861a22c9b6c13f3ed95
- version: 2.0

## Description

entradas precisas y puedes ver las fases de agotamientos de los fractales

## Source Code

````pine
//@version=6
indicator(title="appaz utbot con Filtro EMA y Zonas de Bloques", shorttitle="Appaz UTBot + S&D", overlay=true, max_boxes_count=50)

// ==========================================
// CONFIGURACIÓN DE LA EMA FILTRO (200)
// ==========================================
emaLen   = input.int(200, title="Período de la EMA Filtro", group="Filtro de Tendencia")
emaColor = input.color(color.yellow, title="Color de la EMA Filtro", group="Filtro de Tendencia")
emaVal   = ta.ema(close, emaLen)

// Dibujar la EMA Filtro en el gráfico
plot(emaVal, title="EMA Filtro 200", color=emaColor, linewidth=2)


// ==========================================
// CONFIGURACIÓN DE EMAS ADICIONALES (VISUALES)
// ==========================================
emaRapidaLen   = input.int(5, title="Período EMA Rápida", group="EMAs Visuales")
emaRapidaColor = input.color(color.green, title="Color EMA Rápida", group="EMAs Visuales")
emaRapidaVal   = ta.ema(close, emaRapidaLen)

emaLentaLen    = input.int(10, title="Período EMA Lenta", group="EMAs Visuales")
emaLentaColor  = input.color(color.red, title="Color EMA Lenta", group="EMAs Visuales")
emaLentaVal    = ta.ema(close, emaLentaLen)

// Dibujar las EMAs adicionales en el gráfico
plot(emaRapidaVal, title="EMA 5 (Verde)", color=emaRapidaColor, linewidth=1)
plot(emaLentaVal, title="EMA 10 (Rojo)", color=emaLentaColor, linewidth=1)


// ==========================================
// CONFIGURACIÓN - UT BOT 1
// ==========================================
a1 = input.float(2.0, title="Bot 1: Key Value (Sensibilidad)", group="UT Bot 1")
c1 = input.int(1, title="Bot 1: ATR Period", group="UT Bot 1")
h1 = input.bool(false, title="Bot 1: Señales desde Heikin Ashi", group="UT Bot 1")

xATR1 = ta.atr(c1)
nLoss1 = a1 * xATR1

src1 = h1 ? request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, close, lookahead=barmerge.lookahead_off) : close

var float xATRTrailingStop1 = 0.0
xATRTrailingStop1 := src1 > nz(xATRTrailingStop1, 0) and src1 > nz(xATRTrailingStop1, 0) ? math.max(nz(xATRTrailingStop1), src1 - nLoss1) :
   src1 < nz(xATRTrailingStop1, 0) and src1 < nz(xATRTrailingStop1, 0) ? math.min(nz(xATRTrailingStop1), src1 + nLoss1) :
   src1 > nz(xATRTrailingStop1, 0) ? src1 - nLoss1 : src1 + nLoss1
 
var int pos1 = 0   
pos1 := src1 < nz(xATRTrailingStop1, 0) and src1 > nz(xATRTrailingStop1, 0) ? 1 :
   src1 > nz(xATRTrailingStop1, 0) and src1 < nz(xATRTrailingStop1, 0) ? -1 : nz(pos1, 0)

ema1 = ta.ema(src1, 1)
above1 = ta.crossover(ema1, xATRTrailingStop1)
below1 = ta.crossover(xATRTrailingStop1, ema1)

// Señal filtrada únicamente por la EMA Filtro (200)
sell1_orig = src1 < xATRTrailingStop1 and below1
sell1      = sell1_orig and close < emaVal

// Renderizado Bot 1: Muestra únicamente "Sell"
plotshape(sell1, title="Bot 1: Sell (Filtrado)", text='Sell', style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.tiny)


// ==========================================
// CONFIGURACIÓN - UT BOT 2
// ==========================================
a2 = input.float(2.0, title="Bot 2: Key Value (Sensibilidad)", group="UT Bot 2")
c2 = input.int(300, title="Bot 2: ATR Period", group="UT Bot 2")
h2 = input.bool(false, title="Bot 2: Señales desde Heikin Ashi", group="UT Bot 2")

xATR2 = ta.atr(c2)
nLoss2 = a2 * xATR2

src2 = h2 ? request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, close, lookahead=barmerge.lookahead_off) : close

var float xATRTrailingStop2 = 0.0
xATRTrailingStop2 := src2 > nz(xATRTrailingStop2, 0) and src2 > nz(xATRTrailingStop2, 0) ? math.max(nz(xATRTrailingStop2), src2 - nLoss2) :
   src2 < nz(xATRTrailingStop2, 0) and src2 < nz(xATRTrailingStop2, 0) ? math.min(nz(xATRTrailingStop2), src2 + nLoss2) :
   src2 > nz(xATRTrailingStop2, 0) ? src2 - nLoss2 : src2 + nLoss2
 
var int pos2 = 0   
pos2 := src2 < nz(xATRTrailingStop2, 0) and src2 > nz(xATRTrailingStop2, 0) ? 1 :
   src2 > nz(xATRTrailingStop2, 0) and src2 < nz(xATRTrailingStop2, 0) ? -1 : nz(pos2, 0)

ema2 = ta.ema(src2, 1)
above2 = ta.crossover(ema2, xATRTrailingStop2)
below2 = ta.crossover(xATRTrailingStop2, ema2)

// Señal filtrada únicamente por la EMA Filtro (200)
buy2_orig = src2 > xATRTrailingStop2 and above2 
buy2      = buy2_orig and close > emaVal

// Renderizado Bot 2: Muestra únicamente "Buy"
plotshape(buy2, title="Bot 2: Buy (Filtrado)", text='Buy', style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white, size=size.tiny)


// ==========================================
// LÓGICA DE AGOTAMIENTO ORIGINAL RESTAURADA
// ==========================================
var int conteoExhaustionAlcista = 0
var int conteoExhaustionBajista = 0

// Comparación estricta de barras previas (LuxAlgo Setup)
if close < close[4]
    conteoExhaustionAlcista := conteoExhaustionAlcista + 1
    conteoExhaustionBajista := 0
else
    if close > close[4]
        conteoExhaustionBajista := conteoExhaustionBajista + 1
        conteoExhaustionAlcista := 0

// Las marcas "E" originales aparecen exactamente en la barra 9 de la secuencia
agotamientoVentaOriginal  = (conteoExhaustionAlcista == 9)
agotamientoCompraOriginal = (conteoExhaustionBajista == 9)

// Renderizado de Viñetas de Agotamiento de Alta Probabilidad
plotshape(agotamientoVentaOriginal,  title="Agotamiento de Venta (E)", text='E', style=shape.circle, location=location.belowbar, color=color.teal, textcolor=color.white, size=size.small)
plotshape(agotamientoCompraOriginal, title="Agotamiento de Compra (E)", text='E', style=shape.circle, location=location.abovebar, color=color.maroon, textcolor=color.white, size=size.small)


// ==========================================
// ZONAS DE OFERTA Y DEMANDA AUTOMÁTICAS
// ==========================================
pdPeriod = input.int(15, title="Fuerza del Pivote Estructural", group="Zonas Oferta / Demanda")
colSup   = input.color(color.new(color.red, 85), title="Color Zona de Oferta", group="Zonas Oferta / Demanda")
colDem   = input.color(color.new(color.teal, 85), title="Color Zona de Demanda", group="Zonas Oferta / Demanda")

pivHigh = ta.pivothigh(high, pdPeriod, pdPeriod)
pivLow  = ta.pivotlow(low, pdPeriod, pdPeriod)

// Gestión dinámica de cajas (boxes) mediante arrays nativos
var box[] supBoxes = array.new_box()
var box[] demBoxes = array.new_box()

if not na(pivHigh)
    boxNew = box.new(left=bar_index - pdPeriod, top=high[pdPeriod], right=bar_index, bottom=math.max(open[pdPeriod], close[pdPeriod]), bgcolor=colSup, border_color=color.new(color.red, 40), border_style=line.style_dashed)
    array.push(supBoxes, boxNew)
    if array.size(supBoxes) > 3
        box.delete(array.shift(supBoxes))

if not na(pivLow)
    boxNew = box.new(left=bar_index - pdPeriod, top=math.min(open[pdPeriod], close[pdPeriod]), right=bar_index, bottom=low[pdPeriod], bgcolor=colDem, border_color=color.new(color.teal, 40), border_style=line.style_dashed)
    array.push(demBoxes, boxNew)
    if array.size(demBoxes) > 3
        box.delete(array.shift(demBoxes))

// Extender extremo derecho
if array.size(supBoxes) > 0
    for i = 0 to array.size(supBoxes) - 1
        box.set_right(array.get(supBoxes, i), bar_index)

if array.size(demBoxes) > 0
    for i = 0 to array.size(demBoxes) - 1
        box.set_right(array.get(demBoxes, i), bar_index)


// ==========================================
// SECCIÓN DE ALERTAS FILTRADAS
// ==========================================
alertcondition(sell1, "Bot 1 Short Filtro", "¡Bot 1 dio señal de Venta (Confirmada por EMA 200)!")
alertcondition(buy2,  "Bot 2 Long Filtro",  "¡Bot 2 dio señal de Compra (Confirmada por EMA 200)!")
alertcondition(agotamientoVentaOriginal, "Agotamiento Venta", "¡Agotamiento de Fuerza Vendedora Detectado (E)!")
alertcondition(agotamientoCompraOriginal, "Agotamiento Compra", "¡Agotamiento de Fuerza Compradora Detectado (E)!")
````
