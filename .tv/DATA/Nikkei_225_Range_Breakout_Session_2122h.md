<!-- tradingview-pine-id: PUB;7c16cbf7e92146859b69a0f2274acb20 -->
<!-- tradingviewscripts-format: 1 -->
# Nikkei 225 Range Breakout — Session 21-22h

Source: https://www.tradingview.com/script/oteEPIgo/

## Description

═══════════════════════════════════════ ENGLISH ═══════════════════════════════════════

OVERVIEW A time-based intraday tool for the Nikkei 225 (JP225). It builds a reference range between 19:00 and 21:00, and then — only inside a strict 21:00–22:00 execution window — it looks for a breakout of that range confirmed on the 5-minute chart, a retest of the broken level (support/resistance flip), and a 1-minute engulfing candle as the entry trigger. Risk is fixed: stop-loss at the opposite side of the range and take-profit at 1:1. All times are in UTC-3 (Argentina) by default and are fully configurable.

HOW IT WORKS (step by step)

Reference range (19:00–21:00): the indicator captures the high and low of this period and draws it as a box.
Execution window (21:00–22:00): trades are only evaluated inside this window.
Breakout: a 5-minute close above the range high (bullish) or below the range low (bearish) marks the break, with a label and a level line.
Retest (S/R flip): price must return to the broken level before an entry is allowed.
Entry: a 1-minute engulfing candle in the breakout direction triggers the trade. The stop-loss is placed at the opposite end of the range and the take-profit at a 1:1 ratio. Entry, SL and TP zones are drawn.
Management: the position is tracked until price reaches TP or SL, and the outcome is labelled.

HOW TO USE

Apply it to the Nikkei 225 (JP225) on a 1-minute chart. It reads the 5-minute close internally for the breakout and the 1-minute candles for the entry.
Adjust the range/window sessions and the timezone to match your broker.
One setup per day, evaluated inside the 21:00–22:00 window.

USER-INTERFACE TEXT (English translation) The boxes and labels are written in Spanish. English meaning:

"Rango 19-21hs" = reference range 19:00–21:00.
"Ventana 21-22hs" = execution window 21:00–22:00.
"Ruptura 5m Alcista / Bajista" = 5-minute bullish / bearish breakout.
"COMPRA (S/R)" = Buy on the S/R flip · "VENTA (S/R)" = Sell on the S/R flip.
"TP 1:1" = take-profit at 1:1 · "SL Rango" = stop-loss at the range.
"TP ALCANZADO" = take-profit reached · "SL ALCANZADO" = stop-loss reached.
"Nivel Máximo / Mínimo" = range high / low levels.

Note: this indicator visualizes the strategy and its entries/exits on the chart; it does not place real orders. Open-source — feel free to study it and adapt it.

═══════════════════════════════════════ ESPAÑOL ═══════════════════════════════════════

Herramienta intradía por horario para el Nikkei 225 (JP225). Construye un rango de referencia entre las 19:00 y las 21:00, y solo dentro de una ventana estricta de 21:00 a 22:00 busca: una ruptura del rango confirmada en 5 minutos, un retroceso al nivel roto (flip de soporte/resistencia) y una vela envolvente de 1 minuto como gatillo de entrada. Riesgo fijo: stop-loss en el extremo opuesto del rango y take-profit 1:1. Horarios en UTC-3 (Argentina) por defecto y configurables.

CÓMO FUNCIONA

Rango (19:00–21:00): marca el máximo y el mínimo del período.
Ventana operativa (21:00–22:00): solo opera dentro de esta franja.
Ruptura: un cierre de 5m por encima del máximo (alcista) o por debajo del mínimo (bajista).
Retroceso: el precio debe volver al nivel roto antes de habilitar la entrada.
Entrada: vela envolvente de 1m en la dirección de la ruptura. SL en el extremo opuesto del rango, TP 1:1.
Gestión: sigue la posición hasta que toca TP o SL.

CÓMO USARLO Aplicalo en el Nikkei 225 (JP225) en un gráfico de 1 minuto. Ajustá los horarios y la zona horaria a tu broker. Un setup por día, dentro de la ventana de 21:00 a 22:00.

Indicador de código abierto — Trading Sin Fronteras.

---

## Source Code

````pine
//@version=6
indicator("Nikkei 225 Range Breakout — Session 21-22h", overlay=true, max_boxes_count=50, max_labels_count=50)
// --- ENTRADAS DE HORARIOS Y COLORES ---
grupo_horarios = "Configuración de Horarios (UTC-3)"
sessionRange = input.session("1900-2100", title="1. Horario de Rango (19 a 21hs)", group=grupo_horarios)
sessionBreakout = input.session("2100-2200", title="2. Ventana Operativa (21 a 22hs)", group=grupo_horarios)
tz = input.string("UTC-3", title="Zona Horaria", group=grupo_horarios)
grupo_colores = "Estilo Visual de Rangos"
colorRangeBg = input.color(color.rgb(65, 105, 225, 80), title="Fondo Rango 19-21hs", group=grupo_colores)
colorRangeBorder = input.color(color.rgb(65, 105, 225, 30), title="Borde Rango 19-21hs", group=grupo_colores)
colorBreakoutBg = input.color(color.rgb(255, 165, 0, 85), title="Fondo Ventana 21-22hs", group=grupo_colores)
colorBreakoutBorder = input.color(color.rgb(255, 140, 0, 40), title="Borde Ventana 21-22hs", group=grupo_colores)
// --- LÓGICA DE TIEMPO (booleanos explícitos, v6) ---
inRange = not na(time(timeframe.period, sessionRange, tz))
inBreakout = not na(time(timeframe.period, sessionBreakout, tz))
// --- VARIABLES DE ESTADO Y RANGOS VISUALES ---
var float rangeHigh = na
var float rangeLow = na
var box rangeBox = na
var box breakoutBox = na
var bool hasBrokenUp = false
var bool hasBrokenDown = false
var bool hasEntered = false
var bool levelRetested = false
var line srLine = na
// --- VARIABLES DE SEGUIMIENTO DE POSICIÓN ACTIVA ---
var bool inPosition = false
var bool isLong = false
var float entryPrice = na
var float slPrice = na
var float tpPrice = na
var box tpBox = na
var box slBox = na
var line entryLine = na
// --- CONSULTA DE DATOS EN 5m ---
close5m = request.security(syminfo.tickerid, "5", close, lookahead=barmerge.lookahead_off)
// --- PASO 1: MARCAR EL RANGO DE REFERENCIA (19:00 A 21:00) ---
if inRange and not inRange[1]
    rangeHigh := high
    rangeLow := low
    hasBrokenUp := false
    hasBrokenDown := false
    hasEntered := false
    levelRetested := false
    inPosition := false
    isLong := false
    entryPrice := na
    slPrice := na
    tpPrice := na
    srLine := na
    tpBox := na
    slBox := na
    entryLine := na
    breakoutBox := na
    rangeBox := box.new(left=bar_index, top=rangeHigh, right=bar_index, bottom=rangeLow, border_color=colorRangeBorder, bgcolor=colorRangeBg, text="Rango 19-21hs", text_size=size.tiny, text_color=color.rgb(200, 220, 255))
if inRange
    rangeHigh := math.max(rangeHigh, high)
    rangeLow := math.min(rangeLow, low)
    box.set_top(rangeBox, rangeHigh)
    box.set_bottom(rangeBox, rangeLow)
    box.set_right(rangeBox, bar_index)
// --- PASO 2: DIBUJAR Y CONTROLAR VENTANA OPERATIVA (21:00 A 22:00) ---
if inBreakout and not inBreakout[1]
    breakoutBox := box.new(left=bar_index, top=rangeHigh, right=bar_index, bottom=rangeLow, border_color=colorBreakoutBorder, bgcolor=colorBreakoutBg, text="Ventana 21-22hs", text_size=size.tiny, text_color=color.orange)
if inBreakout and not na(breakoutBox)
    box.set_top(breakoutBox, math.max(rangeHigh, high))
    box.set_bottom(breakoutBox, math.min(rangeLow, low))
    box.set_right(breakoutBox, bar_index)
// --- PASO 3: DETECTAR RUPTURA CON CUERPO EN 5m (SOLO DENTRO DE 21-22hs) ---
if inBreakout and not hasBrokenUp and not hasBrokenDown
    if close5m > rangeHigh
        hasBrokenUp := true
        label.new(bar_index, high, "Ruptura 5m Alcista", color=color.blue, textcolor=color.white, style=label.style_label_down, size=size.small)
        srLine := line.new(x1=bar_index, y1=rangeHigh, x2=bar_index + 1, y2=rangeHigh, color=color.blue, width=2, style=line.style_dashed)
    else if close5m < rangeLow
        hasBrokenDown := true
        label.new(bar_index, low, "Ruptura 5m Bajista", color=color.fuchsia, textcolor=color.white, style=label.style_label_up, size=size.small)
        srLine := line.new(x1=bar_index, y1=rangeLow, x2=bar_index + 1, y2=rangeLow, color=color.fuchsia, width=2, style=line.style_dashed)
if inBreakout and (hasBrokenUp or hasBrokenDown) and not na(srLine)
    line.set_x2(srLine, bar_index + 1)
// --- PASO 4: RETROCESO (S/R FLIP) DENTRO DE LA VENTANA ---
if inBreakout and (hasBrokenUp or hasBrokenDown) and not hasEntered
    if hasBrokenUp and low <= rangeHigh
        levelRetested := true
    if hasBrokenDown and high >= rangeLow
        levelRetested := true
// --- PASO 5: GATILLO DE ENTRADA CON ENVOLVENTE EN 1m (ESTRICTAMENTE 21:00 A 22:00) ---
bullEngulfing1m = close > open and close[1] < open[1] and close >= open[1] and open <= close[1]
bearEngulfing1m = close < open and close[1] > open[1] and close <= open[1] and open >= close[1]
isBuyEntry = false
isSellEntry = false
// El filtro inBreakout asegura que la orden solo se ejecute entre las 21:00 y las 22:00 hs
if inBreakout and levelRetested and not hasEntered and not inPosition
    if hasBrokenUp and bullEngulfing1m
        hasEntered := true
        inPosition := true
        isLong := true
        isBuyEntry := true
        entryPrice := close
        slPrice := rangeLow
        float risk = entryPrice - slPrice
        tpPrice := entryPrice + risk
        entryLine := line.new(x1=bar_index, y1=entryPrice, x2=bar_index, y2=entryPrice, color=color.gray, width=1, style=line.style_solid)
        tpBox := box.new(left=bar_index, top=tpPrice, right=bar_index, bottom=entryPrice, border_color=color.green, bgcolor=color.new(color.green, 80), text="TP 1:1 (" + str.tostring(tpPrice, "#.#") + ")", text_color=color.green, text_size=size.tiny)
        slBox := box.new(left=bar_index, top=entryPrice, right=bar_index, bottom=slPrice, border_color=color.red, bgcolor=color.new(color.red, 80), text="SL Rango (" + str.tostring(slPrice, "#.#") + ")", text_color=color.red, text_size=size.tiny)
    if hasBrokenDown and bearEngulfing1m
        hasEntered := true
        inPosition := true
        isLong := false
        isSellEntry := true
        entryPrice := close
        slPrice := rangeHigh
        float risk = slPrice - entryPrice
        tpPrice := entryPrice - risk
        entryLine := line.new(x1=bar_index, y1=entryPrice, x2=bar_index, y2=entryPrice, color=color.gray, width=1, style=line.style_solid)
        tpBox := box.new(left=bar_index, top=entryPrice, right=bar_index, bottom=tpPrice, border_color=color.green, bgcolor=color.new(color.green, 80), text="TP 1:1 (" + str.tostring(tpPrice, "#.#") + ")", text_color=color.green, text_size=size.tiny)
        slBox := box.new(left=bar_index, top=slPrice, right=bar_index, bottom=entryPrice, border_color=color.red, bgcolor=color.new(color.red, 80), text="SL Rango (" + str.tostring(slPrice, "#.#") + ")", text_color=color.red, text_size=size.tiny)
// --- PASO 6: GESTIÓN DE LA POSICIÓN HASTA SU CIERRE POR TP O SL ---
if inPosition
    box.set_right(tpBox, bar_index)
    box.set_right(slBox, bar_index)
    line.set_x2(entryLine, bar_index)
    if isLong
        if high >= tpPrice
            inPosition := false
            label.new(bar_index, high, "TP ALCANZADO (1:1)", color=color.green, textcolor=color.white, style=label.style_label_down, size=size.small)
        else if low <= slPrice
            inPosition := false
            label.new(bar_index, low, "SL ALCANZADO", color=color.red, textcolor=color.white, style=label.style_label_up, size=size.small)
    if not isLong
        if low <= tpPrice
            inPosition := false
            label.new(bar_index, low, "TP ALCANZADO (1:1)", color=color.green, textcolor=color.white, style=label.style_label_up, size=size.small)
        else if high >= slPrice
            inPosition := false
            label.new(bar_index, high, "SL ALCANZADO", color=color.red, textcolor=color.white, style=label.style_label_down, size=size.small)
// --- CARTELES DE ENTRADA ---
plotshape(isBuyEntry, title="Apertura Compra", location=location.belowbar, color=color.green, style=shape.labelup, size=size.small, text="COMPRA (S/R)", textcolor=color.white)
plotshape(isSellEntry, title="Apertura Venta", location=location.abovebar, color=color.red, style=shape.labeldown, size=size.small, text="VENTA (S/R)", textcolor=color.white)
// --- LÍNEAS DE REFERENCIA PARA STOP LOSS DEL RANGO ---
plot(inBreakout or inRange ? rangeHigh : na, color=color.red, style=plot.style_linebr, title="Nivel Máximo (SL Ventas)")
plot(inBreakout or inRange ? rangeLow : na, color=color.green, style=plot.style_linebr, title="Nivel Mínimo (SL Compras)")
````
