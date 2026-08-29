<!-- tradingview-pine-id: PUB;d51f53a401864ac9a9501d6c812f2549 -->
<!-- tradingviewscripts-format: 1 -->
# RSI + EMA20 + EWO Divergencias + Fibo

Source: https://www.tradingview.com/script/kQBVcFcb/

## Description

RSI + EMA20 + EWO Divergencias + Fibo

Indicador que detecta divergencias entre precio y RSI, filtradas por tendencia (EMA20) y momentum (Elliott Wave Oscillator), y proyecta niveles de Fibonacci automáticos sobre el último swing. Pensado como herramienta de confirmación de entradas long/short, no como sistema de trading automático.

Lógica de las señales

LONG: RSI en zona de sobreventa + precio por encima de la EMA20 + divergencia alcista (el precio marca un mínimo más bajo mientras el RSI marca un mínimo más alto) + EWO positivo (opcional).
SHORT: RSI en zona de sobrecompra + precio por debajo de la EMA20 + divergencia bajista (el precio marca un máximo más alto mientras el RSI marca un máximo más bajo) + EWO negativo (opcional).

Componentes

RSI: detecta las divergencias y filtra sobrecompra/sobreventa. Niveles configurables (por defecto 30/70).
EMA20: filtro de tendencia. Solo habilita long si el precio está arriba, short si está abajo.
EWO (Elliott Wave Oscillator): diferencia entre SMA rápida y lenta expresada en % del precio; funciona como filtro de momentum opcional a favor de la señal.
Fibonacci automático: se redibuja sobre el máximo/mínimo de las últimas N velas (lookback configurable), con los niveles clásicos (0, 23.6, 38.2, 50, 61.8, 78.6, 100).

Dos tipos de señal de divergencia

Confirmada (triángulo grande + etiqueta LONG/SHORT en el gráfico): espera a que el pivot quede validado (configurable, por defecto 5 velas a cada lado). Más lenta pero no repinta ni desaparece una vez formada.
Temprana (círculo/triángulo chico, verde para long y naranja para short): se dispara apenas se forma un nuevo extremo local, sin esperar la confirmación completa del pivot. Da entradas más rápidas pero puede repintarse (desaparecer o corregirse) si en las velas siguientes aparece un extremo más pronunciado. Se puede desactivar desde los inputs.

Inputs configurables

Largo de RSI, niveles de sobrecompra/sobreventa
Largo de EMA
SMAs rápida/lenta del EWO, activar/desactivar filtro de momentum
Barras de confirmación del pivot (izquierda/derecha) y rango máximo entre pivots
Mostrar/ocultar Fibonacci y su lookback
Mostrar/ocultar señal temprana

Alertas disponibles

Cuatro alertas independientes: LONG confirmada, SHORT confirmada, LONG temprana, SHORT temprana.

Temporalidad

No tiene una temporalidad fija: se calcula sobre el timeframe que tengas abierto en el gráfico (1m, 15m, 1h, diario, etc.), como cualquier indicador de Pine Script. Los parámetros por defecto (pivots de 5 velas, EMA20, RSI 14) están pensados para timeframes intradiarios a diarios; en timeframes muy bajos (1m-5m) puede generar más señales de ruido, y en timeframes altos (semanal+) puede convenir alargar el lookback de Fibonacci y los pivots para evitar señales demasiado espaciadas. Se recomienda ajustar y testear los inputs según el activo y la temporalidad que uses.

Advertencia

Es una herramienta de análisis técnico, no una recomendación de inversión. Las señales, especialmente la temprana, pueden dar falsos positivos; se recomienda usarlas en conjunto con gestión de riesgo (stop loss, tamaño de posición) y no de forma aislada.

---

## Source Code

````pine
//@version=6
indicator("RSI + EMA20 + EWO Divergencias + Fibo", overlay=false, max_lines_count=200, max_labels_count=200)

// ===================== INPUTS =====================
grpRSI = "RSI"
rsiLength = input.int(14, "Largo RSI", group=grpRSI)
rsiOS     = input.int(30, "Nivel sobreventa (RSI)", group=grpRSI)
rsiOB     = input.int(70, "Nivel sobrecompra (RSI)", group=grpRSI)

grpEMA = "EMA"
emaLength = input.int(20, "Largo EMA principal", group=grpEMA)

grpEmaExtra = "EMAs adicionales"
showEma10  = input.bool(false, "Mostrar EMA 10", group=grpEmaExtra)
showEma50  = input.bool(false, "Mostrar EMA 50", group=grpEmaExtra)
showEma100 = input.bool(false, "Mostrar EMA 100", group=grpEmaExtra)
showEma200 = input.bool(false, "Mostrar EMA 200", group=grpEmaExtra)

grpEWO = "Elliott Wave Oscillator"
ewoFast = input.int(5, "SMA rápida EWO", group=grpEWO)
ewoSlow = input.int(35, "SMA lenta EWO", group=grpEWO)
useEwoFilter = input.bool(true, "Usar EWO como filtro de momentum", group=grpEWO)

grpDiv = "Divergencias"
pivotLeft  = input.int(5, "Barras a la izquierda (pivot)", group=grpDiv)
pivotRight = input.int(5, "Barras a la derecha (pivot)", group=grpDiv)
maxPivotBars = input.int(60, "Rango máx. entre pivots (barras)", group=grpDiv)

grpFib = "Fibonacci"
showFib     = input.bool(true, "Mostrar Fibonacci automático", group=grpFib)
fibMode     = input.string("Todos los niveles", "Modo de niveles", options=["Todos los niveles", "Solo Golden Pocket"], group=grpFib)
showFibExt  = input.bool(false, "Mostrar extensiones de Fibonacci", group=grpFib)
fibLookback = input.int(100, "Lookback swing high/low", group=grpFib)

grpEarly = "Alerta Temprana (sin confirmar)"
useEarly = input.bool(true, "Mostrar señal temprana (puede repintar)", group=grpEarly)

// ===================== CÁLCULOS BASE =====================
ema20 = ta.ema(close, emaLength)
ema10v  = ta.ema(close, 10)
ema50v  = ta.ema(close, 50)
ema100v = ta.ema(close, 100)
ema200v = ta.ema(close, 200)
rsi   = ta.rsi(close, rsiLength)
ewo   = (ta.sma(close, ewoFast) - ta.sma(close, ewoSlow)) / close * 100

aboveEma = close > ema20
belowEma = close < ema20

// ===================== DETECCIÓN DE DIVERGENCIAS =====================
// Pivots sobre el RSI (confirmados con "pivotRight" barras de rezago)
plFound = not na(ta.pivotlow(rsi, pivotLeft, pivotRight))
phFound = not na(ta.pivothigh(rsi, pivotLeft, pivotRight))

var float lastRsiLow   = na
var float lastPriceLow = na
var int   lastLowBar   = na

var float lastRsiHigh   = na
var float lastPriceHigh = na
var int   lastHighBar   = na

bullishDiv = false
bearishDiv = false

if plFound
    rsiValAtPivot   = rsi[pivotRight]
    priceValAtPivot = low[pivotRight]
    bidx = bar_index - pivotRight
    if not na(lastRsiLow) and (bidx - lastLowBar) <= maxPivotBars
        if priceValAtPivot < lastPriceLow and rsiValAtPivot > lastRsiLow
            bullishDiv := true
            line.new(lastLowBar, lastRsiLow, bidx, rsiValAtPivot, xloc=xloc.bar_index, color=color.green, width=2)
    lastRsiLow   := rsiValAtPivot
    lastPriceLow := priceValAtPivot
    lastLowBar   := bidx

if phFound
    rsiValAtPivot   = rsi[pivotRight]
    priceValAtPivot = high[pivotRight]
    bidx = bar_index - pivotRight
    if not na(lastRsiHigh) and (bidx - lastHighBar) <= maxPivotBars
        if priceValAtPivot > lastPriceHigh and rsiValAtPivot < lastRsiHigh
            bearishDiv := true
            line.new(lastHighBar, lastRsiHigh, bidx, rsiValAtPivot, xloc=xloc.bar_index, color=color.red, width=2)
    lastRsiHigh   := rsiValAtPivot
    lastPriceHigh := priceValAtPivot
    lastHighBar   := bidx

// ===================== DIVERGENCIA TEMPRANA (sin confirmar) =====================
// Usa solo barras hacia atrás (sin lookahead), pero al no esperar "pivotRight" barras
// para confirmar el pivot, la señal puede desaparecer o "repintarse" si aparece un
// mínimo/máximo más extremo en las siguientes velas. Se compara contra el último
// pivot YA CONFIRMADO (lastPriceLow/lastRsiLow, lastPriceHigh/lastRsiHigh).
earlyLowCandidate  = low  <= ta.lowest(low, pivotLeft)
earlyHighCandidate = high >= ta.highest(high, pivotLeft)

earlyBullishDiv = useEarly and earlyLowCandidate and not na(lastPriceLow) and
     low < lastPriceLow and rsi > lastRsiLow and (bar_index - lastLowBar) <= maxPivotBars

earlyBearishDiv = useEarly and earlyHighCandidate and not na(lastPriceHigh) and
     high > lastPriceHigh and rsi < lastRsiHigh and (bar_index - lastHighBar) <= maxPivotBars

earlyLongCondition  = earlyBullishDiv and aboveEma and rsi <= rsiOS and (not useEwoFilter or ewo > 0)
earlyShortCondition = earlyBearishDiv and belowEma and rsi >= rsiOB and (not useEwoFilter or ewo < 0)

// ===================== CONDICIONES LONG / SHORT =====================
emaOkLong  = close[pivotRight] > ema20[pivotRight]
emaOkShort = close[pivotRight] < ema20[pivotRight]

rsiOkLong  = rsi[pivotRight] <= rsiOS
rsiOkShort = rsi[pivotRight] >= rsiOB

ewoOkLong  = not useEwoFilter or ewo[pivotRight] > 0
ewoOkShort = not useEwoFilter or ewo[pivotRight] < 0

longCondition  = bullishDiv and emaOkLong  and rsiOkLong  and ewoOkLong
shortCondition = bearishDiv and emaOkShort and rsiOkShort and ewoOkShort

// ===================== PLOTS: RSI + EWO (panel del indicador) =====================
plot(rsi, "RSI", color=color.new(color.purple, 0), linewidth=2)
hline(rsiOB, "Sobrecompra", color=color.new(color.red, 50))
hline(rsiOS, "Sobreventa", color=color.new(color.green, 50))
hline(50, "50", color=color.new(color.gray, 70))

// EWO normalizado a escala 0-100 para compartir panel visualmente con el RSI
ewoNorm = 50 + ewo * 5
plot(ewoNorm, "EWO (normalizado, referencia 50=cero)", color=color.new(color.orange, 30), style=plot.style_columns)

plotshape(bullishDiv, "Divergencia alcista", style=shape.triangleup, location=location.bottom, offset=-pivotRight, color=color.green, size=size.tiny)
plotshape(bearishDiv, "Divergencia bajista", style=shape.triangledown, location=location.top, offset=-pivotRight, color=color.red, size=size.tiny)

plotshape(earlyBullishDiv, "Divergencia alcista (temprana)", style=shape.circle, location=location.bottom, color=color.new(color.lime, 20), size=size.tiny)
plotshape(earlyBearishDiv, "Divergencia bajista (temprana)", style=shape.circle, location=location.top, color=color.new(color.orange, 20), size=size.tiny)

// ===================== PLOTS SOBRE EL GRÁFICO DE PRECIO =====================
plot(ema20, "EMA20", color=color.blue, linewidth=2, force_overlay=true)
plot(showEma10  ? ema10v  : na, "EMA10",  color=color.aqua,    linewidth=1, force_overlay=true)
plot(showEma50  ? ema50v  : na, "EMA50",  color=color.fuchsia, linewidth=1, force_overlay=true)
plot(showEma100 ? ema100v : na, "EMA100", color=color.orange,  linewidth=1, force_overlay=true)
plot(showEma200 ? ema200v : na, "EMA200", color=color.white,   linewidth=1, force_overlay=true)

// Señales confirmadas: recuadro de texto sobre el gráfico de precio
if longCondition
    label.new(bar_index - pivotRight, low[pivotRight], "LONG", xloc=xloc.bar_index,
         yloc=yloc.belowbar, style=label.style_label_up, color=color.new(color.green, 0),
         textcolor=color.white, size=size.small, force_overlay=true)

if shortCondition
    label.new(bar_index - pivotRight, high[pivotRight], "SHORT", xloc=xloc.bar_index,
         yloc=yloc.abovebar, style=label.style_label_down, color=color.new(color.red, 0),
         textcolor=color.white, size=size.small, force_overlay=true)

plotshape(earlyLongCondition, "Señal LONG (temprana)", style=shape.triangleup, location=location.belowbar,
     color=color.new(color.lime, 20), size=size.tiny, force_overlay=true)
plotshape(earlyShortCondition, "Señal SHORT (temprana)", style=shape.triangledown, location=location.abovebar,
     color=color.new(color.orange, 20), size=size.tiny, force_overlay=true)

// ===================== FIBONACCI AUTOMÁTICO =====================
var line[]  fibLines = array.new_line()
var label[] fibLabels = array.new_label()
var box[]   fibBoxes = array.new_box()

// Estas funciones ta.* deben calcularse en TODAS las velas (no solo adentro de un if)
// para que su estado interno sea consistente; por eso quedan fuera del bloque de dibujo.
hh = ta.highest(high, fibLookback)
ll = ta.lowest(low, fibLookback)
hhBar = bar_index - ta.highestbars(high, fibLookback) * -1
llBar = bar_index - ta.lowestbars(low, fibLookback) * -1

if showFib and barstate.islast
    // limpiar dibujo anterior
    if array.size(fibLines) > 0
        for i = 0 to array.size(fibLines) - 1
            line.delete(array.get(fibLines, i))
            label.delete(array.get(fibLabels, i))
        array.clear(fibLines)
        array.clear(fibLabels)
    if array.size(fibBoxes) > 0
        for i = 0 to array.size(fibBoxes) - 1
            box.delete(array.get(fibBoxes, i))
        array.clear(fibBoxes)

    endBar = bar_index
    trendUp = hhBar > llBar // si el máximo es más reciente que el mínimo, retroceso desde abajo
    swingStart = math.min(hhBar, llBar)

    if fibMode == "Todos los niveles"
        levels = array.from(0.0, 0.236, 0.382, 0.5, 0.618, 0.65, 0.786, 1.0)
        for i = 0 to array.size(levels) - 1
            lvl = array.get(levels, i)
            price = trendUp ? hh - (hh - ll) * lvl : ll + (hh - ll) * lvl
            isGolden = lvl == 0.618 or lvl == 0.65
            ln = line.new(swingStart, price, endBar, price, xloc=xloc.bar_index,
                 color=isGolden ? color.new(color.fuchsia, 20) : color.new(color.white, 40),
                 style=line.style_dashed, force_overlay=true)
            lb = label.new(endBar, price, str.tostring(lvl * 100, "#.#") + "%", xloc=xloc.bar_index,
                 style=label.style_none, color=color.new(color.white, 40),
                 textcolor=color.white, size=size.normal, force_overlay=true)
            array.push(fibLines, ln)
            array.push(fibLabels, lb)
    else
        // Solo Golden Pocket: caja entre 61.8% y 65%
        priceGoldenLow  = trendUp ? hh - (hh - ll) * 0.618 : ll + (hh - ll) * 0.618
        priceGoldenHigh = trendUp ? hh - (hh - ll) * 0.65  : ll + (hh - ll) * 0.65
        bx = box.new(swingStart, math.max(priceGoldenLow, priceGoldenHigh), endBar, math.min(priceGoldenLow, priceGoldenHigh),
             xloc=xloc.bar_index, border_color=color.fuchsia, bgcolor=color.new(color.fuchsia, 80), force_overlay=true)
        lb = label.new(endBar, priceGoldenLow, "Golden Pocket", xloc=xloc.bar_index, style=label.style_label_left,
             color=color.new(color.fuchsia, 80), textcolor=color.white, size=size.tiny, force_overlay=true)
        array.push(fibBoxes, bx)
        array.push(fibLabels, lb)

    // Extensiones: proyectan hacia dónde podría ir el movimiento más allá del swing
    if showFibExt
        extLevels = array.from(1.272, 1.618, 2.0, 2.618)
        for i = 0 to array.size(extLevels) - 1
            lvl = array.get(extLevels, i)
            price = trendUp ? hh + (hh - ll) * (lvl - 1) : ll - (hh - ll) * (lvl - 1)
            ln = line.new(swingStart, price, endBar, price, xloc=xloc.bar_index,
                 color=color.new(color.aqua, 30), style=line.style_dotted, force_overlay=true)
            lb = label.new(endBar, price, "Ext " + str.tostring(lvl * 100, "#.#") + "%", xloc=xloc.bar_index,
                 style=label.style_label_left, color=color.new(#e0e70d, 9), textcolor=color.white,
                 size=size.normal, force_overlay=true)
            array.push(fibLines, ln)
            array.push(fibLabels, lb)

// ===================== ALERTAS =====================
alertcondition(longCondition, "Señal LONG", "Divergencia alcista + precio > EMA20 + RSI sobrevendido")
alertcondition(shortCondition, "Señal SHORT", "Divergencia bajista + precio < EMA20 + RSI sobrecomprado")

alertcondition(earlyLongCondition, "Señal LONG (temprana)", "Divergencia alcista sin confirmar + precio > EMA20 + RSI sobrevendido")
alertcondition(earlyShortCondition, "Señal SHORT (temprana)", "Divergencia bajista sin confirmar + precio < EMA20 + RSI sobrecomprado")
````
