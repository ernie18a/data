# BRN - FVG MTF  

- url: https://www.tradingview.com/script/Dyma8qI8/
- type: indicator
- pine_id: PUB;52366e0940c9411eaebce4d92ec4a74d
- version: 1.0

## Description

This indicator displays a live mini-chart of a selected higher timeframe on the right side of the main chart. It identifies confirmed Fair Value Gaps, highlights the impulse candle, and plots a step-style line at the midpoint of the latest FVG. The line updates only when a new FVG is confirmed, while the mini-chart continues updating in real time.

## Source Code

````pine
//@version=6
indicator("BRN - FVG MTF Live", shorttitle="BRN FVG MTF", overlay=true, max_boxes_count=100, max_lines_count=100, max_labels_count=30)

//=============================================================================
// 1. CONFIGURAÇÕES
//=============================================================================

string GRP_MTF = "1. FVG MTF"
string GRP_MINI = "2. GRÁFICO À DIREITA"
string GRP_VISUAL = "3. VISUAL"

string fvgTimeframe = input.timeframe("60", "Timeframe de origem", group=GRP_MTF, tooltip="Utilize um timeframe igual ou superior ao timeframe do gráfico.")

float minFvgTicks = input.float(0.0, "Tamanho mínimo do FVG em ticks", minval=0.0, step=1.0, group=GRP_MTF)

bool showMiniChart = input.bool(true, "Mostrar gráfico MTF à direita", group=GRP_MINI)

int rightOffset = input.int(25, "Distância à direita", minval=5, maxval=300, group=GRP_MINI)

int candleWidth = input.int(4, "Largura das velas", minval=2, maxval=10, group=GRP_MINI)

int candleGap = input.int(2, "Espaço entre velas", minval=1, maxval=10, group=GRP_MINI)

color normalBullColor = input.color(color.rgb(210, 210, 210), "Vela normal de alta", group=GRP_VISUAL)

color normalBearColor = input.color(color.rgb(105, 105, 105), "Vela normal de baixa", group=GRP_VISUAL)

color bullFvgColor = input.color(color.rgb(0, 210, 150), "FVG de alta", group=GRP_VISUAL)

color bearFvgColor = input.color(color.rgb(240, 70, 80), "FVG de baixa", group=GRP_VISUAL)

int stepWidth = input.int(2, "Espessura da linha FVG", minval=1, maxval=5, group=GRP_VISUAL)

//=============================================================================
// 2. VALIDAÇÃO DO TIMEFRAME
//=============================================================================

bool validTimeframe = timeframe.in_seconds(fvgTimeframe) >= timeframe.in_seconds()

float minimumFvgSize = minFvgTicks * syminfo.mintick

//=============================================================================
// 3. DETECÇÃO CONFIRMADA DO FVG NO TIMEFRAME ESCOLHIDO
//=============================================================================

// No contexto do timeframe escolhido:
//
// [3] = primeira vela
// [2] = vela central de impulso
// [1] = vela que fechou e confirmou o FVG
//
// Alta:  low[1] > high[3]
// Baixa: high[1] < low[3]

bool rawBullFvg = request.security(syminfo.tickerid, fvgTimeframe, low[1] > high[3], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

bool rawBearFvg = request.security(syminfo.tickerid, fvgTimeframe, high[1] < low[3], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

float bullFvgMid = request.security(syminfo.tickerid, fvgTimeframe, math.avg(low[1], high[3]), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

float bearFvgMid = request.security(syminfo.tickerid, fvgTimeframe, math.avg(high[1], low[3]), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

float bullFvgSize = request.security(syminfo.tickerid, fvgTimeframe, low[1] - high[3], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

float bearFvgSize = request.security(syminfo.tickerid, fvgTimeframe, low[3] - high[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

int confirmedHtfTime = request.security(syminfo.tickerid, fvgTimeframe, time[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

// A alteração de time[1] indica que uma nova vela MTF fechou.

bool newClosedHtfCandle = validTimeframe and not na(confirmedHtfTime) and ta.change(confirmedHtfTime) != 0

bool newBullFvg = newClosedHtfCandle and rawBullFvg and bullFvgSize >= minimumFvgSize

bool newBearFvg = newClosedHtfCandle and rawBearFvg and bearFvgSize >= minimumFvgSize

//=============================================================================
// 4. MEMÓRIA DO ÚLTIMO FVG
//=============================================================================

var float currentFvgMid = na
var int currentFvgDirection = 0

if newBullFvg
    currentFvgMid := bullFvgMid
    currentFvgDirection := 1
else if newBearFvg
    currentFvgMid := bearFvgMid
    currentFvgDirection := -1

color currentFvgColor = currentFvgDirection == 1 ? bullFvgColor : currentFvgDirection == -1 ? bearFvgColor : color.gray

//=============================================================================
// 5. LINHA EM ESCADA NO GRÁFICO PRINCIPAL
//=============================================================================

plot(currentFvgMid, title="Centro do último FVG MTF", color=currentFvgColor, linewidth=stepWidth, style=plot.style_stepline)

//=============================================================================
// 6. OHLC DO GRÁFICO MTF À DIREITA
//=============================================================================

// Vela atual, ainda em formação.

float o0 = request.security(syminfo.tickerid, fvgTimeframe, open, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
float h0 = request.security(syminfo.tickerid, fvgTimeframe, high, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
float l0 = request.security(syminfo.tickerid, fvgTimeframe, low, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
float c0 = request.security(syminfo.tickerid, fvgTimeframe, close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// Última vela fechada.

float o1 = request.security(syminfo.tickerid, fvgTimeframe, open[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float h1 = request.security(syminfo.tickerid, fvgTimeframe, high[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float l1 = request.security(syminfo.tickerid, fvgTimeframe, low[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float c1 = request.security(syminfo.tickerid, fvgTimeframe, close[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

// Segunda vela fechada.

float o2 = request.security(syminfo.tickerid, fvgTimeframe, open[2], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float h2 = request.security(syminfo.tickerid, fvgTimeframe, high[2], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float l2 = request.security(syminfo.tickerid, fvgTimeframe, low[2], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float c2 = request.security(syminfo.tickerid, fvgTimeframe, close[2], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

// Terceira vela fechada.

float o3 = request.security(syminfo.tickerid, fvgTimeframe, open[3], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float h3 = request.security(syminfo.tickerid, fvgTimeframe, high[3], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float l3 = request.security(syminfo.tickerid, fvgTimeframe, low[3], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float c3 = request.security(syminfo.tickerid, fvgTimeframe, close[3], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

// Quarta vela fechada.

float o4 = request.security(syminfo.tickerid, fvgTimeframe, open[4], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float h4 = request.security(syminfo.tickerid, fvgTimeframe, high[4], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float l4 = request.security(syminfo.tickerid, fvgTimeframe, low[4], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float c4 = request.security(syminfo.tickerid, fvgTimeframe, close[4], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

// Quinta vela fechada.

float o5 = request.security(syminfo.tickerid, fvgTimeframe, open[5], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float h5 = request.security(syminfo.tickerid, fvgTimeframe, high[5], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float l5 = request.security(syminfo.tickerid, fvgTimeframe, low[5], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float c5 = request.security(syminfo.tickerid, fvgTimeframe, close[5], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

//=============================================================================
// 7. FVGs VISÍVEIS NAS ÚLTIMAS VELAS MTF
//=============================================================================

// Confirmação na vela [3].
// A vela [4] é o impulso.
// A vela [5] é a primeira vela.

int direction3 = request.security(syminfo.tickerid, fvgTimeframe, low[3] > high[5] ? 1 : high[3] < low[5] ? -1 : 0, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

// Confirmação na vela [2].
// A vela [3] é o impulso.
// A vela [4] é a primeira vela.

int direction2 = request.security(syminfo.tickerid, fvgTimeframe, low[2] > high[4] ? 1 : high[2] < low[4] ? -1 : 0, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

// Confirmação na vela [1].
// A vela [2] é o impulso.
// A vela [3] é a primeira vela.

int direction1 = request.security(syminfo.tickerid, fvgTimeframe, low[1] > high[3] ? 1 : high[1] < low[3] ? -1 : 0, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

float size3 = direction3 == 1 ? l3 - h5 : direction3 == -1 ? l5 - h3 : na
float size2 = direction2 == 1 ? l2 - h4 : direction2 == -1 ? l4 - h2 : na
float size1 = direction1 == 1 ? l1 - h3 : direction1 == -1 ? l3 - h1 : na

int validDirection3 = direction3 != 0 and size3 >= minimumFvgSize ? direction3 : 0
int validDirection2 = direction2 != 0 and size2 >= minimumFvgSize ? direction2 : 0
int validDirection1 = direction1 != 0 and size1 >= minimumFvgSize ? direction1 : 0

//=============================================================================
// 8. OBJETOS VISUAIS
//=============================================================================

var box[] miniBoxes = array.new_box()
var line[] miniLines = array.new_line()
var label[] miniLabels = array.new_label()

//=============================================================================
// 9. GRÁFICO MTF À DIREITA
//=============================================================================

if barstate.islast
    while array.size(miniBoxes) > 0
        box oldBox = array.pop(miniBoxes)
        box.delete(oldBox)

    while array.size(miniLines) > 0
        line oldLine = array.pop(miniLines)
        line.delete(oldLine)

    while array.size(miniLabels) > 0
        label oldLabel = array.pop(miniLabels)
        label.delete(oldLabel)

    if not validTimeframe
        label warning = label.new(x=bar_index + 5, y=high, text="O timeframe escolhido deve ser\nigual ou maior que o gráfico.", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(color.red, 10), textcolor=color.white, size=size.small)
        array.push(miniLabels, warning)

    if showMiniChart and validTimeframe and not na(o5)
        int candleStep = candleWidth + candleGap
        int baseX = bar_index + rightOffset

        float[] opens = array.from(o5, o4, o3, o2, o1, o0)
        float[] highs = array.from(h5, h4, h3, h2, h1, h0)
        float[] lows = array.from(l5, l4, l3, l2, l1, l0)
        float[] closes = array.from(c5, c4, c3, c2, c1, c0)

        int[] impulseDirections = array.from(0, validDirection3, validDirection2, validDirection1, 0, 0)

        int[] zoneDirections = array.from(validDirection3, validDirection2, validDirection1)
        int[] confirmationIndexes = array.from(2, 3, 4)
        int[] firstIndexes = array.from(0, 1, 2)

        //=====================================================================
        // ÁREAS DOS FVGs VISÍVEIS
        //=====================================================================

        for zoneIndex = 0 to 2
            int zoneDirection = array.get(zoneDirections, zoneIndex)
            int confirmationIndex = array.get(confirmationIndexes, zoneIndex)
            int firstIndex = array.get(firstIndexes, zoneIndex)

            if zoneDirection != 0
                float zoneTop = zoneDirection == 1 ? array.get(lows, confirmationIndex) : array.get(lows, firstIndex)
                float zoneBottom = zoneDirection == 1 ? array.get(highs, firstIndex) : array.get(highs, confirmationIndex)

                int zoneLeft = baseX + firstIndex * candleStep + candleWidth
                int zoneRight = baseX + confirmationIndex * candleStep

                color zoneColor = zoneDirection == 1 ? bullFvgColor : bearFvgColor

                box zoneBox = box.new(left=zoneLeft, top=zoneTop, right=zoneRight, bottom=zoneBottom, xloc=xloc.bar_index, border_color=color.new(zoneColor, 15), border_width=1, bgcolor=color.new(zoneColor, 82))
                array.push(miniBoxes, zoneBox)

        //=====================================================================
        // DESENHO DAS 6 VELAS MTF
        //=====================================================================

        for candleIndex = 0 to 5
            float candleOpen = array.get(opens, candleIndex)
            float candleHigh = array.get(highs, candleIndex)
            float candleLow = array.get(lows, candleIndex)
            float candleClose = array.get(closes, candleIndex)

            int impulseDirection = array.get(impulseDirections, candleIndex)

            color candleColor = candleClose >= candleOpen ? normalBullColor : normalBearColor

            if impulseDirection == 1
                candleColor := bullFvgColor
            else if impulseDirection == -1
                candleColor := bearFvgColor

            int candleX = baseX + candleIndex * candleStep
            int candleCenterX = candleX + int(math.floor(candleWidth / 2.0))

            float bodyTop = math.max(candleOpen, candleClose)
            float bodyBottom = math.min(candleOpen, candleClose)

            if bodyTop == bodyBottom
                bodyTop += syminfo.mintick * 0.5
                bodyBottom -= syminfo.mintick * 0.5

            line candleWick = line.new(x1=candleCenterX, y1=candleHigh, x2=candleCenterX, y2=candleLow, xloc=xloc.bar_index, color=candleColor, width=1)
            array.push(miniLines, candleWick)

            box candleBody = box.new(left=candleX, top=bodyTop, right=candleX + candleWidth, bottom=bodyBottom, xloc=xloc.bar_index, border_color=candleColor, border_width=1, bgcolor=color.new(candleColor, 10))
            array.push(miniBoxes, candleBody)

        //=====================================================================
        // LINHA ATUAL DO FVG ATÉ O GRÁFICO MTF
        //=====================================================================

        if not na(currentFvgMid)
            int miniChartRight = baseX + 5 * candleStep + candleWidth

            line fvgConnector = line.new(x1=bar_index, y1=currentFvgMid, x2=miniChartRight, y2=currentFvgMid, xloc=xloc.bar_index, color=currentFvgColor, width=stepWidth)
            array.push(miniLines, fvgConnector)

            label fvgLabel = label.new(x=miniChartRight, y=currentFvgMid, text="FVG " + fvgTimeframe, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(currentFvgColor, 10), textcolor=color.white, size=size.tiny)
            array.push(miniLabels, fvgLabel)

        //=====================================================================
        // IDENTIFICAÇÃO DO TIMEFRAME
        //=====================================================================

        float miniTop = array.max(highs)

        label timeframeLabel = label.new(x=baseX + 2 * candleStep, y=miniTop, text=fvgTimeframe + "  LIVE", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=color.new(color.black, 100), textcolor=chart.fg_color, size=size.small)
        array.push(miniLabels, timeframeLabel)
````
