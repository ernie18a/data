# CWB ICT 9:30 FP FVG

- url: https://www.tradingview.com/script/s07oGC8R-CWB-ICT-9-30-FP-FVG/
- type: indicator
- pine_id: PUB;cf1e7f905a8b46b992e99f4da2d37527
- version: 1.0

## Description

CWB × ICT 9:30 FP FVG automatically identifies and marks the first valid Fair Value Gap formed after the 9:30 AM New York open.

The indicator displays only one zone per session, using confirmed candles only to avoid repainting.

Designed for intraday timeframes of 15 minutes or lower.

This is a visual and educational tool. It does not generate entries, stop losses, take profits, or automated signals.

## Source Code

````pine
//@version=6
indicator(
    "CWB × ICT 9:30 FP FVG",
    shorttitle="CWB ICT 9:30 FP",
    overlay=true,
    max_boxes_count=500,
    max_labels_count=500
)

//━━━━━━━━━━━━━━━━━━━
// CONSTANTES
//━━━━━━━━━━━━━━━━━━━
const string NY_TZ = "America/New_York"
const string RTH_SESSION = "0930-1600:23456"

const string EXTEND_TO_SESSION_END = "Hasta final de sesión"
const string EXTEND_TO_CURRENT_BAR = "Hasta vela actual"
const string EXTEND_FIXED_BARS = "Velas configurables"

//━━━━━━━━━━━━━━━━━━━
// INPUTS VISUALES
//━━━━━━━━━━━━━━━━━━━
showBox = input.bool(
     true,
     "Mostrar caja",
     group="Visualización"
)

bullishFvgColor = input.color(
     color.green,
     "Color FVG alcista",
     group="Visualización"
)

bearishFvgColor = input.color(
     color.red,
     "Color FVG bajista",
     group="Visualización"
)

boxTransparency = input.int(
     85,
     "Transparencia de la caja",
     minval=0,
     maxval=100,
     group="Visualización"
)

borderColor = input.color(
     color.gray,
     "Color del borde",
     group="Visualización"
)

borderWidth = input.int(
     1,
     "Grosor del borde",
     minval=1,
     maxval=5,
     group="Visualización"
)

textColor = input.color(
     color.white,
     "Color del texto",
     group="Visualización"
)

showFirstFvgText = input.bool(
     true,
     "Mostrar texto 1st FVG",
     group="Visualización"
)

showReviewText = input.bool(
     true,
     "Mostrar texto 100 Review",
     group="Visualización"
)

//━━━━━━━━━━━━━━━━━━━
// INPUTS DE EXTENSIÓN
//━━━━━━━━━━━━━━━━━━━
extensionMode = input.string(
     EXTEND_TO_SESSION_END,
     "Extensión de la caja",
     options=[
          EXTEND_TO_SESSION_END,
          EXTEND_TO_CURRENT_BAR,
          EXTEND_FIXED_BARS
     ],
     group="Extensión"
)

extensionBars = input.int(
     20,
     "Velas hacia la derecha",
     minval=1,
     maxval=500,
     group="Extensión"
)

//━━━━━━━━━━━━━━━━━━━
// INPUTS DEL HISTORIAL
//━━━━━━━━━━━━━━━━━━━
showOnlyCurrentSession = input.bool(
     false,
     "Mostrar solo la sesión actual",
     group="Historial"
)

sessionsToKeep = input.int(
     20,
     "Sesiones visibles",
     minval=1,
     maxval=250,
     group="Historial"
)

//━━━━━━━━━━━━━━━━━━━
// FUNCIONES
//━━━━━━━━━━━━━━━━━━━
getSessionEndTime(int sourceTime) =>
    timestamp(
         NY_TZ,
         year(sourceTime, NY_TZ),
         month(sourceTime, NY_TZ),
         dayofmonth(sourceTime, NY_TZ),
         16,
         0
    )

getInitialRightTime(
     int barOpenTime,
     int barCloseTime
) =>
    extensionMode == EXTEND_TO_SESSION_END ?
     getSessionEndTime(barOpenTime) :
     extensionMode == EXTEND_TO_CURRENT_BAR ?
     barCloseTime :
     int(
          barCloseTime +
          extensionBars *
          timeframe.in_seconds() *
          1000
     )

//━━━━━━━━━━━━━━━━━━━
// VALIDACIÓN DE TEMPORALIDAD
//━━━━━━━━━━━━━━━━━━━
tfAllowed = (
     timeframe.isintraday and
     timeframe.in_seconds() <=
     15 *
     60
)

//━━━━━━━━━━━━━━━━━━━
// SESIÓN REGULAR DE NUEVA YORK
// Se valida tanto la apertura como el cierre de cada vela.
//━━━━━━━━━━━━━━━━━━━
barOpenInsideRth = not na(
     time(
          timeframe.period,
          RTH_SESSION,
          NY_TZ
     )
)

barCloseInsideRth = not na(
     time_close(
          timeframe.period,
          RTH_SESSION,
          NY_TZ
     )
)

barFullyInsideRth = (
     barOpenInsideRth and
     barCloseInsideRth
)

newRthSession = (
     barFullyInsideRth and
     (
          bar_index == 0 or
          not barFullyInsideRth[1]
     )
)

//━━━━━━━━━━━━━━━━━━━
// HISTORIAL DE OBJETOS
// Cada índice representa una sesión con un primer FVG.
//━━━━━━━━━━━━━━━━━━━
var box[] historicalBoxes = array.new_box()
var label[] historicalReviewLabels = array.new_label()

deleteBoxSafe(box objectId) =>
    if not na(objectId)
        box.delete(objectId)

deleteLabelSafe(label objectId) =>
    if not na(objectId)
        label.delete(objectId)

deleteOldestVisual() =>
    if array.size(historicalBoxes) > 0
        oldBox = array.shift(historicalBoxes)
        oldReviewLabel = array.shift(historicalReviewLabels)

        deleteBoxSafe(oldBox)
        deleteLabelSafe(oldReviewLabel)

clearAllVisuals() =>
    while array.size(historicalBoxes) > 0
        deleteOldestVisual()

trimHistoricalVisuals() =>
    visibleLimit = (
         showOnlyCurrentSession ?
         1 :
         sessionsToKeep
    )

    while array.size(historicalBoxes) > visibleLimit
        deleteOldestVisual()

//━━━━━━━━━━━━━━━━━━━
// ESTADO DE LA SESIÓN ACTUAL
//━━━━━━━━━━━━━━━━━━━
var bool firstFvgMarked = false
var box currentSessionBox = na

if newRthSession
    firstFvgMarked := false
    currentSessionBox := na

    if showOnlyCurrentSession
        clearAllVisuals()

//━━━━━━━━━━━━━━━━━━━
// EXTENSIÓN DINÁMICA HASTA LA VELA ACTUAL
// Solo modifica la caja de la sesión activa.
//━━━━━━━━━━━━━━━━━━━
if (
     extensionMode == EXTEND_TO_CURRENT_BAR and
     barFullyInsideRth and
     not na(currentSessionBox)
)
    box.set_right(
         currentSessionBox,
         time_close
    )

//━━━━━━━━━━━━━━━━━━━
// DEFINICIÓN DEL FVG
// Las tres velas deben pertenecer completamente a RTH.
//━━━━━━━━━━━━━━━━━━━
threeConfirmedRthBars = (
     bar_index >= 2 and
     barFullyInsideRth and
     barFullyInsideRth[1] and
     barFullyInsideRth[2]
)

bullishFvg = (
     high[1] >
     high[2] and
     low >
     high[2]
)

bearishFvg = (
     low[1] <
     low[2] and
     high <
     low[2]
)

validFirstFvg = (
     tfAllowed and
     barstate.isconfirmed and
     threeConfirmedRthBars and
     not firstFvgMarked and
     (
          bullishFvg or
          bearishFvg
     )
)

//━━━━━━━━━━━━━━━━━━━
// DIBUJAR ÚNICAMENTE EL PRIMER FVG DE LA SESIÓN
//━━━━━━━━━━━━━━━━━━━
if validFirstFvg
    firstFvgMarked := true

    gapTop = (
         bullishFvg ?
         low :
         low[2]
    )

    gapBottom = (
         bullishFvg ?
         high[2] :
         high
    )

    gapMidpoint = (
         gapTop +
         gapBottom
    ) /
     2.0

    gapColor = (
         bullishFvg ?
         bullishFvgColor :
         bearishFvgColor
    )

    rightTime = getInitialRightTime(
         time,
         time_close
    )

    boxText = (
         showFirstFvgText ?
         "1st FVG" :
         ""
    )

    box createdBox = na
    label createdReviewLabel = na

    if showBox
        createdBox := box.new(
             left=time,
             top=gapTop,
             right=rightTime,
             bottom=gapBottom,
             xloc=xloc.bar_time,
             border_color=borderColor,
             border_width=borderWidth,
             bgcolor=color.new(
                  gapColor,
                  boxTransparency
             ),
             text=boxText,
             text_color=textColor,
             text_size=size.small,
             text_halign=text.align_center,
             text_valign=text.align_center
        )

    if showReviewText
        createdReviewLabel := label.new(
             x=time,
             y=gapMidpoint,
             text="100 Review",
             xloc=xloc.bar_time,
             style=label.style_label_left,
             color=color.new(
                  borderColor,
                  65
             ),
             textcolor=textColor,
             size=size.tiny
        )

    array.push(
         historicalBoxes,
         createdBox
    )

    array.push(
         historicalReviewLabels,
         createdReviewLabel
    )

    trimHistoricalVisuals()

    currentSessionBox := createdBox

//━━━━━━━━━━━━━━━━━━━
// AVISO PARA TEMPORALIDADES NO PERMITIDAS
//━━━━━━━━━━━━━━━━━━━
var table warningTable = table.new(
     position.top_right,
     1,
     1
)

if barstate.islast
    if tfAllowed
        table.cell(
             warningTable,
             0,
             0,
             "",
             bgcolor=color.new(
                  color.black,
                  100
             )
        )

    else
        table.cell(
             warningTable,
             0,
             0,
             "[CWB × ICT 9:30 FP FVG] Use a timeframe of 15m or lower",
             bgcolor=color.new(
                  color.black,
                  15
             ),
             text_color=color.orange,
             text_size=size.small
        )
````
