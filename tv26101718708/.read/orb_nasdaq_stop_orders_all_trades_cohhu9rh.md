# ORB NASDAQ Stop Orders - All Trades

- url: https://www.tradingview.com/script/cohHU9Rh/
- type: indicator
- pine_id: PUB;2e4b618abbca4dbfa6d9ed92ba388604
- version: 1.0

## Description

Este script es un indicador para TradingView que automatiza visualmente una estrategia ORB (Opening Range Breakout) sobre el Nasdaq, utilizando órdenes stop basadas en el rango inicial del mercado.

La lógica funciona así:

Define un rango ORB usando la vela o conjunto de velas entre las 9:30 y 9:45 AM.
Calcula automáticamente el máximo y mínimo de ese rango.
Después de las 9:45 AM, espera un breakout:
Si el precio rompe el máximo → genera una entrada BUY.
Si rompe el mínimo → genera una entrada SELL.
El Stop Loss se coloca al lado opuesto del rango ORB.
El Take Profit se calcula automáticamente usando un Risk Reward configurable (RR).

Además, el script:

Dibuja visualmente el rango ORB en el gráfico.
Muestra cajas de TP y SL estilo estrategia de TradingView.
Coloca etiquetas de BUY, SELL, TP, SL y STOP TIME.
Permite cerrar operaciones automáticamente a una hora específica si no alcanzaron TP o SL.
Lleva estadísticas en tiempo real:
número de trades,
BUY vs SELL,
TP vs SL,
winrate,
trades cerrados por tiempo,
ganancias y pérdidas.

También incluye alertas automáticas para entradas BUY y SELL, por lo que puede conectarse con automatizaciones o bots externos.

## Source Code

````pine
//@version=6
indicator("ORB NASDAQ Stop Orders - All Trades", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

orbSession    = input.session("0930-0945", "Vela ORB")
entrySession  = input.session("0945-1100", "Ventana de entrada")
stopHour      = input.int(16, "STOP TIME Hora", minval=0, maxval=23)
stopMinute    = input.int(0, "STOP TIME Minuto", minval=0, maxval=59)
rr            = input.float(1.0, "RR", step=0.1)

showOrbRange  = input.bool(true, "Mostrar rango ORB")
orbWidthBars  = input.int(10, "Ancho rango ORB (velas)", minval=1)
orbBoxColor   = input.color(color.new(color.gray, 70), "Color rango ORB")
orbMidColor   = input.color(color.yellow, "Color línea media ORB")

showBox       = input.bool(true, "Mostrar posición estilo TV")
showLabel     = input.bool(true, "Mostrar etiqueta BUY/SELL")
showExitLabel = input.bool(true, "Mostrar etiqueta de salida")
showTable     = input.bool(true, "Mostrar tabla de métricas")

inOrbSession   = not na(time(timeframe.period, orbSession))
inEntrySession = not na(time(timeframe.period, entrySession))

var float orbHigh = na
var float orbLow = na
var bool orbReady = false
var bool tradeTaken = false

var box orbBox = na
var line orbMidLine = na
var int orbStartBar = na

var bool tradeActive = false
var int activeDir = 0
var float activeEntry = na
var float activeSL = na
var float activeTP = na
var int activeEntryBar = na
var int activeStopTimestamp = na

var box activeTpBox = na
var box activeSlBox = na

var int totalTrades = 0
var int buyTrades = 0
var int sellTrades = 0
var int tpTrades = 0
var int slTrades = 0
var int stopTimeTrades = 0
var int stopTimeWins = 0
var int stopTimeLosses = 0

newDay = ta.change(time("D")) != 0

if newDay
    orbHigh := na
    orbLow := na
    orbReady := false
    tradeTaken := false
    orbBox := na
    orbMidLine := na
    orbStartBar := na

if inOrbSession
    if na(orbStartBar)
        orbStartBar := bar_index

    orbHigh := na(orbHigh) ? high : math.max(orbHigh, high)
    orbLow  := na(orbLow) ? low : math.min(orbLow, low)

if not inOrbSession and not na(orbHigh) and not na(orbLow)
    orbReady := true

    if showOrbRange
        midPrice = (orbHigh + orbLow) / 2
        rightEdge = orbStartBar + orbWidthBars

        if na(orbBox)
            orbBox := box.new(
                 left=orbStartBar,
                 top=orbHigh,
                 right=rightEdge,
                 bottom=orbLow,
                 bgcolor=orbBoxColor,
                 border_color=color.black
            )
        else
            box.set_left(orbBox, orbStartBar)
            box.set_right(orbBox, rightEdge)
            box.set_top(orbBox, orbHigh)
            box.set_bottom(orbBox, orbLow)

        if na(orbMidLine)
            orbMidLine := line.new(
                 x1=orbStartBar,
                 y1=midPrice,
                 x2=rightEdge,
                 y2=midPrice,
                 color=orbMidColor,
                 width=2
            )
        else
            line.set_x1(orbMidLine, orbStartBar)
            line.set_x2(orbMidLine, rightEdge)
            line.set_y1(orbMidLine, midPrice)
            line.set_y2(orbMidLine, midPrice)

rangeSize = orbHigh - orbLow

buyEntry = orbHigh
buySL    = orbLow
buyTP    = orbHigh + rangeSize * rr

sellEntry = orbLow
sellSL    = orbHigh
sellTP    = orbLow - rangeSize * rr

buySignal  = orbReady and inEntrySession and not tradeTaken and not tradeActive and high >= orbHigh
sellSignal = orbReady and inEntrySession and not tradeTaken and not tradeActive and not buySignal and low <= orbLow

if buySignal
    tradeTaken := true
    tradeActive := true
    activeDir := 1
    activeEntry := buyEntry
    activeSL := buySL
    activeTP := buyTP
    activeEntryBar := bar_index
    activeStopTimestamp := timestamp(syminfo.timezone, year, month, dayofmonth, stopHour, stopMinute)

    totalTrades += 1
    buyTrades += 1

    if showBox
        activeTpBox := box.new(bar_index, buyTP, bar_index, buyEntry, bgcolor=color.new(color.green, 80), border_color=color.new(color.green, 100))
        activeSlBox := box.new(bar_index, buyEntry, bar_index, buySL, bgcolor=color.new(color.red, 80), border_color=color.new(color.red, 100))

    if showLabel
        label.new(
             bar_index,
             buyTP,
             "BUY\nEntrada: " + str.tostring(buyEntry, format.mintick) +
             "\nSL: " + str.tostring(buySL, format.mintick) +
             "\nTP: " + str.tostring(buyTP, format.mintick),
             style=label.style_label_down,
             color=color.green,
             textcolor=color.white
        )

if sellSignal
    tradeTaken := true
    tradeActive := true
    activeDir := -1
    activeEntry := sellEntry
    activeSL := sellSL
    activeTP := sellTP
    activeEntryBar := bar_index
    activeStopTimestamp := timestamp(syminfo.timezone, year, month, dayofmonth, stopHour, stopMinute)

    totalTrades += 1
    sellTrades += 1

    if showBox
        activeTpBox := box.new(bar_index, sellEntry, bar_index, sellTP, bgcolor=color.new(color.green, 80), border_color=color.new(color.green, 100))
        activeSlBox := box.new(bar_index, sellSL, bar_index, sellEntry, bgcolor=color.new(color.red, 80), border_color=color.new(color.red, 100))

    if showLabel
        label.new(
             bar_index,
             sellTP,
             "SELL\nEntrada: " + str.tostring(sellEntry, format.mintick) +
             "\nSL: " + str.tostring(sellSL, format.mintick) +
             "\nTP: " + str.tostring(sellTP, format.mintick),
             style=label.style_label_up,
             color=color.red,
             textcolor=color.white
        )

if tradeActive and showBox
    if not na(activeTpBox)
        box.set_right(activeTpBox, bar_index)
    if not na(activeSlBox)
        box.set_right(activeSlBox, bar_index)

string exitReason = ""
float exitPrice = na
int exitDir = activeDir

if tradeActive and bar_index > activeEntryBar
    if activeDir == 1
        if high >= activeTP
            tpTrades += 1
            exitReason := "TP"
            exitPrice := activeTP
            tradeActive := false
        else if low <= activeSL
            slTrades += 1
            exitReason := "SL"
            exitPrice := activeSL
            tradeActive := false
        else if time_close >= activeStopTimestamp
            stopTimeTrades += 1
            exitReason := "STOP TIME"
            exitPrice := close
            if close > activeEntry
                stopTimeWins += 1
            else
                stopTimeLosses += 1
            tradeActive := false

    if activeDir == -1
        if low <= activeTP
            tpTrades += 1
            exitReason := "TP"
            exitPrice := activeTP
            tradeActive := false
        else if high >= activeSL
            slTrades += 1
            exitReason := "SL"
            exitPrice := activeSL
            tradeActive := false
        else if time_close >= activeStopTimestamp
            stopTimeTrades += 1
            exitReason := "STOP TIME"
            exitPrice := close
            if close < activeEntry
                stopTimeWins += 1
            else
                stopTimeLosses += 1
            tradeActive := false

if exitReason != "" and showBox
    if not na(activeTpBox)
        box.set_right(activeTpBox, bar_index)
    if not na(activeSlBox)
        box.set_right(activeSlBox, bar_index)

if exitReason != "" and showExitLabel
    labelStyle =
         exitReason == "SL"
         ? (exitDir == 1 ? label.style_label_up : label.style_label_down)
         : (exitDir == 1 ? label.style_label_down : label.style_label_up)

    label.new(
         bar_index,
         exitPrice,
         exitReason,
         style=labelStyle,
         color=exitReason == "TP" ? color.green : exitReason == "SL" ? color.red : color.orange,
         textcolor=color.white
    )

wins = tpTrades + stopTimeWins
losses = slTrades + stopTimeLosses
closedTrades = wins + losses
winrate = closedTrades > 0 ? wins / closedTrades * 100 : na

var table statsTable = table.new(position.top_right, 2, 8, border_width=1, frame_width=1)

headerBg = color.rgb(55, 59, 68)
rowBg    = color.rgb(125, 125, 125)
txtColor = color.white

if showTable and barstate.islast
    table.cell(statsTable, 0, 0, "Métrica", text_color=txtColor, bgcolor=headerBg)
    table.cell(statsTable, 1, 0, "Valor", text_color=txtColor, bgcolor=headerBg)

    table.cell(statsTable, 0, 1, "Trades", text_color=txtColor, bgcolor=rowBg)
    table.cell(statsTable, 1, 1, str.tostring(totalTrades), text_color=txtColor, bgcolor=rowBg)

    table.cell(statsTable, 0, 2, "BUY / SELL", text_color=txtColor, bgcolor=rowBg)
    table.cell(statsTable, 1, 2, str.tostring(buyTrades) + " / " + str.tostring(sellTrades), text_color=txtColor, bgcolor=rowBg)

    table.cell(statsTable, 0, 3, "TP / SL", text_color=txtColor, bgcolor=rowBg)
    table.cell(statsTable, 1, 3, str.tostring(tpTrades) + " / " + str.tostring(slTrades), text_color=txtColor, bgcolor=rowBg)

    table.cell(statsTable, 0, 4, "STOP TIME", text_color=txtColor, bgcolor=rowBg)
    table.cell(statsTable, 1, 4, str.tostring(stopTimeTrades) + " (" + str.tostring(stopTimeWins) + "W/" + str.tostring(stopTimeLosses) + "L)", text_color=txtColor, bgcolor=rowBg)

    table.cell(statsTable, 0, 5, "Wins / Losses", text_color=txtColor, bgcolor=rowBg)
    table.cell(statsTable, 1, 5, str.tostring(wins) + " / " + str.tostring(losses), text_color=txtColor, bgcolor=rowBg)

    table.cell(statsTable, 0, 6, "Cerrados", text_color=txtColor, bgcolor=rowBg)
    table.cell(statsTable, 1, 6, str.tostring(closedTrades), text_color=txtColor, bgcolor=rowBg)

    table.cell(statsTable, 0, 7, "Winrate", text_color=txtColor, bgcolor=rowBg)
    table.cell(statsTable, 1, 7, na(winrate) ? "N/A" : str.tostring(winrate, "#.##") + "%", text_color=txtColor, bgcolor=rowBg)

alertcondition(buySignal, "ORB Compra", "ORB NASDAQ: Entrada en COMPRA activada")
alertcondition(sellSignal, "ORB Venta", "ORB NASDAQ: Entrada en VENTA activada")
````
