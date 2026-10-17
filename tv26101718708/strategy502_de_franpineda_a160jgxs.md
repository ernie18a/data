# Strategy_502 de FranPineda

- url: https://www.tradingview.com/script/A160JgXS/
- type: strategy
- pine_id: PUB;1a190953a81c4a3cbfdd5160d737cdcc
- version: 1.0

## Description

**Strategy_502 de FranPineda**

Strategy_502 is a hybrid liquidity-based model that combines two different execution ideas: a 3-hour New York range sweep, an M5 Turtle Soup confirmation, and a structural stop-entry trigger.

The strategy first builds a predefined New York range from **06:00 to 08:59 NY time**. Once the range is completed, it starts tracking the highest high and the lowest low formed by the M5 candles after the range close.

The active entry window is from **09:00 to 12:30 NY time**.

The first requirement is a liquidity sweep of the 3-hour range.

For a **long setup**, price must first take the low of the 3-hour range. After that, the strategy waits for an M5 Turtle Soup confirmation: the current candle must sweep the low of the previous M5 candle, recover back above that level, and close bullish. Once this confirmation appears, the strategy does not enter immediately. Instead, it places a buy stop order at the highest post-range M5 high.

For a **short setup**, price must first take the high of the 3-hour range. After that, the strategy waits for an M5 Turtle Soup confirmation: the current candle must sweep the high of the previous M5 candle, reject back below that level, and close bearish. Once this confirmation appears, the strategy places a sell stop order at the lowest post-range M5 low.

The stop loss is placed beyond the opposite post-range extreme using a configurable buffer.

The take profit is always calculated at a fixed **1:1 risk-to-reward ratio**. It is not limited to the opposite side of the original 3-hour range.

If no pending entry is triggered before **12:30 NY time**, the setup is cancelled and the strategy waits for the next trading day.

If a trade remains open at **16:00 NY time**, the stop loss is moved to break even.

**Core logic:**

* 3-hour New York range: 06:00–08:59 NY.
* Entry window: 09:00–12:30 NY.
* Liquidity sweep of the range high or low.
* M5 Turtle Soup confirmation.
* Pending stop entry at the post-range structural extreme.
* Stop loss beyond the opposite post-range extreme.
* Fixed 1:1 risk-to-reward target.
* Break-even rule at 16:00 NY.
* One trade maximum per day.
* Designed for the M5 timeframe.

The purpose of this strategy is to avoid entering immediately after a liquidity sweep. Instead, it waits for a first reaction through Turtle Soup and then requires price to break the post-range structure before entering. This creates a more selective model focused on liquidity, confirmation, and structural continuation.

## Source Code

````pine
//@version=6
strategy(
     "Strategy_502 de FranPineda",
     overlay = true,
     pyramiding = 0,
     initial_capital = 10000,
     process_orders_on_close = true
)

//====================================================
//==================== INPUTS ========================
//====================================================

// HORARIO RANGO H3
rangeSession = input.session(
     "0600-0859",
     "Rango H3 NY",
     group = "Horario"
)

// HORARIO OPERATIVA
startHour = input.int(
     9,
     "Hora inicio entradas",
     minval = 0,
     maxval = 23,
     group = "Horario"
)

startMinute = input.int(
     0,
     "Minuto inicio entradas",
     minval = 0,
     maxval = 59,
     group = "Horario"
)

endHour = input.int(
     12,
     "Hora fin entradas",
     minval = 0,
     maxval = 23,
     group = "Horario"
)

endMinute = input.int(
     30,
     "Minuto fin entradas",
     minval = 0,
     maxval = 59,
     group = "Horario"
)

// HORA BREAK EVEN
beHour = input.int(
     16,
     "Hora mover a BE",
     minval = 0,
     maxval = 23,
     group = "Gestión"
)

beMinute = input.int(
     0,
     "Minuto mover a BE",
     minval = 0,
     maxval = 59,
     group = "Gestión"
)

// GESTIÓN
slBuffer = input.float(
     2.0,
     "SL Buffer",
     step = 0.25,
     group = "Gestión"
)

// VISUAL
showBox = input.bool(
     true,
     "Mostrar caja rango",
     group = "Visual"
)

showPostRangeLevels = input.bool(
     true,
     "Mostrar extremos post-rango",
     group = "Visual"
)

showTradeLevels = input.bool(
     true,
     "Mostrar niveles trade",
     group = "Visual"
)

showLabels = input.bool(
     true,
     "Mostrar etiquetas",
     group = "Visual"
)

//====================================================
//==================== HORARIO =======================
//====================================================

nyHour = hour(time, "America/New_York")
nyMinute = minute(time, "America/New_York")

afterStart = (
     nyHour > startHour or
     (nyHour == startHour and nyMinute >= startMinute)
)

beforeEnd = (
     nyHour < endHour or
     (nyHour == endHour and nyMinute <= endMinute)
)

allowedTrading = afterStart and beforeEnd

afterEntryWindow = (
     nyHour > endHour or
     (nyHour == endHour and nyMinute > endMinute)
)

beTimeReached = (
     nyHour > beHour or
     (nyHour == beHour and nyMinute >= beMinute)
)

//====================================================
//==================== RESET DIARIO ==================
//====================================================

newDay = dayofmonth(time, "America/New_York") != dayofmonth(time[1], "America/New_York")

var bool tradeTaken = false
var bool pendingOrderPlaced = false
var bool beMoved = false

if newDay
    tradeTaken := false
    pendingOrderPlaced := false
    beMoved := false

    strategy.cancel("LONG")
    strategy.cancel("SHORT")

//====================================================
//==================== RANGO H3 ======================
//====================================================

inRange = not na(
     time(
          timeframe.period,
          rangeSession,
          "America/New_York"
     )
)

var float rangeHigh = na
var float rangeLow = na
var bool rangeReady = false

newRange = inRange and not inRange[1]
endRange = not inRange and inRange[1]

// RESET RANGO
if newDay
    rangeHigh := na
    rangeLow := na
    rangeReady := false

// INICIO RANGO
if newRange
    rangeHigh := high
    rangeLow := low

// CONSTRUCCIÓN RANGO
if inRange
    rangeHigh := math.max(rangeHigh, high)
    rangeLow := math.min(rangeLow, low)

// FIN RANGO
if endRange
    rangeReady := true

//====================================================
//==================== VISUALES RANGO ================
//====================================================

var box rangeBox = na

if showBox

    if newRange

        rangeBox := box.new(
             left = bar_index,
             right = bar_index,
             top = high,
             bottom = low,
             bgcolor = color.new(color.purple, 88),
             border_color = color.new(color.gray, 50)
        )

    if inRange and not na(rangeBox)

        box.set_top(rangeBox, rangeHigh)
        box.set_bottom(rangeBox, rangeLow)
        box.set_right(rangeBox, bar_index)

plot(
     rangeReady ? rangeHigh : na,
     color = color.red,
     linewidth = 3,
     title = "HIGH RANGO H3"
)

plot(
     rangeReady ? rangeLow : na,
     color = color.aqua,
     linewidth = 3,
     title = "LOW RANGO H3"
)

//====================================================
//========== EXTREMOS M5 POST-RANGO H3 ===============
//====================================================

var float postRangeHigh = na
var float postRangeLow = na

if newDay
    postRangeHigh := na
    postRangeLow := na

// Inicializar extremos al terminar el rango
if endRange
    postRangeHigh := high
    postRangeLow := low

// Actualizar extremos post-rango mientras no haya trade abierto
if rangeReady and not inRange and not tradeTaken and strategy.position_size == 0
    postRangeHigh := na(postRangeHigh) ? high : math.max(postRangeHigh, high)
    postRangeLow := na(postRangeLow) ? low : math.min(postRangeLow, low)

plot(
     showPostRangeLevels and rangeReady ? postRangeHigh : na,
     color = color.new(color.orange, 0),
     linewidth = 1,
     title = "POST RANGE HIGH"
)

plot(
     showPostRangeLevels and rangeReady ? postRangeLow : na,
     color = color.new(color.blue, 0),
     linewidth = 1,
     title = "POST RANGE LOW"
)

//====================================================
//============ TURTLE SOUP M5 CONFIRMATION ===========
//====================================================

// LONG:
// Barre el mínimo de la vela anterior,
// recupera cerrando por encima de ese mínimo,
// y cierra verde.
bullishM5TurtleSoup = (
     low < low[1] and
     close > low[1] and
     close > open
)

// SHORT:
// Barre el máximo de la vela anterior,
// recupera cerrando por debajo de ese máximo,
// y cierra roja.
bearishM5TurtleSoup = (
     high > high[1] and
     close < high[1] and
     close < open
)

//====================================================
//==================== SETUPS ========================
//====================================================

var bool rangeLowTaken = false
var bool rangeHighTaken = false

var bool longValidated = false
var bool shortValidated = false

var float longEntryPrice = na
var float longSL = na
var float longTP = na

var float shortEntryPrice = na
var float shortSL = na
var float shortTP = na

if newDay
    rangeLowTaken := false
    rangeHighTaken := false

    longValidated := false
    shortValidated := false

    longEntryPrice := na
    longSL := na
    longTP := na

    shortEntryPrice := na
    shortSL := na
    shortTP := na

//====================================================
//========== PRIMER PASO: TOMA DEL RANGO H3 ==========
//====================================================

// LONG CONTEXT:
// El precio toma el LOW del rango H3.
if (
     rangeReady and
     allowedTrading and
     not tradeTaken and
     strategy.position_size == 0 and
     low < rangeLow
)

    rangeLowTaken := true
    rangeHighTaken := false

    shortValidated := false
    shortEntryPrice := na
    shortSL := na
    shortTP := na

    strategy.cancel("SHORT")

// SHORT CONTEXT:
// El precio toma el HIGH del rango H3.
if (
     rangeReady and
     allowedTrading and
     not tradeTaken and
     strategy.position_size == 0 and
     high > rangeHigh
)

    rangeHighTaken := true
    rangeLowTaken := false

    longValidated := false
    longEntryPrice := na
    longSL := na
    longTP := na

    strategy.cancel("LONG")

//====================================================
//====== SEGUNDO PASO: VALIDACIÓN TURTLE SOUP M5 ======
//====================================================

// VALIDACIÓN LONG
if (
     rangeLowTaken and
     allowedTrading and
     not tradeTaken and
     strategy.position_size == 0 and
     bullishM5TurtleSoup
)

    longValidated := true
    shortValidated := false

    strategy.cancel("SHORT")

    if showLabels
        label.new(
             bar_index,
             low,
             "M5 TS LONG VALIDATED",
             style = label.style_label_up,
             color = color.new(color.lime, 0),
             textcolor = color.black
        )

// VALIDACIÓN SHORT
if (
     rangeHighTaken and
     allowedTrading and
     not tradeTaken and
     strategy.position_size == 0 and
     bearishM5TurtleSoup
)

    shortValidated := true
    longValidated := false

    strategy.cancel("LONG")

    if showLabels
        label.new(
             bar_index,
             high,
             "M5 TS SHORT VALIDATED",
             style = label.style_label_down,
             color = color.new(color.red, 0),
             textcolor = color.white
        )

//====================================================
//============ CÁLCULO ÓRDENES PENDIENTES ============
//====================================================

// LONG:
// Turtle Soup valida.
// Entrada real en ruptura del POST RANGE HIGH.
// SL en POST RANGE LOW - buffer.
// TP siempre 1R.
if (
     longValidated and
     allowedTrading and
     not tradeTaken and
     strategy.position_size == 0 and
     not na(postRangeHigh) and
     not na(postRangeLow)
)

    tempEntry = postRangeHigh
    tempSL = postRangeLow - slBuffer
    tempRisk = tempEntry - tempSL
    tempTP = tempEntry + tempRisk

    if tempRisk > 0
        longEntryPrice := tempEntry
        longSL := tempSL
        longTP := tempTP

// SHORT:
// Turtle Soup valida.
// Entrada real en ruptura del POST RANGE LOW.
// SL en POST RANGE HIGH + buffer.
// TP siempre 1R.
if (
     shortValidated and
     allowedTrading and
     not tradeTaken and
     strategy.position_size == 0 and
     not na(postRangeHigh) and
     not na(postRangeLow)
)

    tempEntry = postRangeLow
    tempSL = postRangeHigh + slBuffer
    tempRisk = tempSL - tempEntry
    tempTP = tempEntry - tempRisk

    if tempRisk > 0
        shortEntryPrice := tempEntry
        shortSL := tempSL
        shortTP := tempTP

//====================================================
//==================== ENTRADAS STOP =================
//====================================================

// LONG STOP
if (
     longValidated and
     allowedTrading and
     not tradeTaken and
     strategy.position_size == 0 and
     not na(longEntryPrice) and
     not na(longSL) and
     not na(longTP)
)

    strategy.entry(
         "LONG",
         strategy.long,
         stop = longEntryPrice
    )

    strategy.exit(
         "LONG EXIT",
         from_entry = "LONG",
         stop = longSL,
         limit = longTP
    )

    pendingOrderPlaced := true

// SHORT STOP
if (
     shortValidated and
     allowedTrading and
     not tradeTaken and
     strategy.position_size == 0 and
     not na(shortEntryPrice) and
     not na(shortSL) and
     not na(shortTP)
)

    strategy.entry(
         "SHORT",
         strategy.short,
         stop = shortEntryPrice
    )

    strategy.exit(
         "SHORT EXIT",
         from_entry = "SHORT",
         stop = shortSL,
         limit = shortTP
    )

    pendingOrderPlaced := true

//====================================================
//========= CANCELAR ÓRDENES FUERA DE HORARIO =========
//====================================================

if (
     afterEntryWindow and
     strategy.position_size == 0 and
     not tradeTaken
)

    strategy.cancel("LONG")
    strategy.cancel("SHORT")

    pendingOrderPlaced := false

    rangeLowTaken := false
    rangeHighTaken := false

    longValidated := false
    shortValidated := false

    longEntryPrice := na
    longSL := na
    longTP := na

    shortEntryPrice := na
    shortSL := na
    shortTP := na

//====================================================
//============== DETECTAR TRADE ACTIVADO =============
//====================================================

if strategy.position_size != 0 and not tradeTaken
    tradeTaken := true

    if showLabels

        if strategy.position_size > 0
            label.new(
                 bar_index,
                 low,
                 "LONG 502",
                 style = label.style_label_up,
                 color = color.lime,
                 textcolor = color.black
            )

        if strategy.position_size < 0
            label.new(
                 bar_index,
                 high,
                 "SHORT 502",
                 style = label.style_label_down,
                 color = color.red,
                 textcolor = color.white
            )

//====================================================
//==================== BREAK EVEN 16H ================
//====================================================

// Si a las 16:00 NY sigue abierta, mover SL a BE.
if (
     beTimeReached and
     strategy.position_size > 0 and
     not beMoved
)

    strategy.exit(
         "LONG EXIT",
         from_entry = "LONG",
         stop = strategy.position_avg_price,
         limit = longTP
    )

    beMoved := true

if (
     beTimeReached and
     strategy.position_size < 0 and
     not beMoved
)

    strategy.exit(
         "SHORT EXIT",
         from_entry = "SHORT",
         stop = strategy.position_avg_price,
         limit = shortTP
    )

    beMoved := true

//====================================================
//==================== LÍNEAS VISUALES ===============
//====================================================

var line entryLine = na
var line slLine = na
var line tpLine = na

// LONG líneas
if (
     showTradeLevels and
     longValidated and
     pendingOrderPlaced and
     strategy.position_size == 0 and
     not na(longEntryPrice) and
     not na(longSL) and
     not na(longTP)
)

    if not na(entryLine)
        line.delete(entryLine)
    if not na(slLine)
        line.delete(slLine)
    if not na(tpLine)
        line.delete(tpLine)

    entryLine := line.new(
         bar_index,
         longEntryPrice,
         bar_index + 20,
         longEntryPrice,
         color = color.yellow,
         width = 2
    )

    slLine := line.new(
         bar_index,
         longSL,
         bar_index + 20,
         longSL,
         color = color.red,
         width = 2
    )

    tpLine := line.new(
         bar_index,
         longTP,
         bar_index + 20,
         longTP,
         color = color.aqua,
         width = 2
    )

// SHORT líneas
if (
     showTradeLevels and
     shortValidated and
     pendingOrderPlaced and
     strategy.position_size == 0 and
     not na(shortEntryPrice) and
     not na(shortSL) and
     not na(shortTP)
)

    if not na(entryLine)
        line.delete(entryLine)
    if not na(slLine)
        line.delete(slLine)
    if not na(tpLine)
        line.delete(tpLine)

    entryLine := line.new(
         bar_index,
         shortEntryPrice,
         bar_index + 20,
         shortEntryPrice,
         color = color.yellow,
         width = 2
    )

    slLine := line.new(
         bar_index,
         shortSL,
         bar_index + 20,
         shortSL,
         color = color.red,
         width = 2
    )

    tpLine := line.new(
         bar_index,
         shortTP,
         bar_index + 20,
         shortTP,
         color = color.aqua,
         width = 2
    )

//====================================================
//==================== ALERTAS =======================
//====================================================

alertcondition(
     rangeLowTaken,
     title = "LOW RANGO TOMADO 502",
     message = "Strategy_502 de FranPineda: LOW del rango H3 tomado"
)

alertcondition(
     rangeHighTaken,
     title = "HIGH RANGO TOMADO 502",
     message = "Strategy_502 de FranPineda: HIGH del rango H3 tomado"
)

alertcondition(
     longValidated,
     title = "LONG VALIDADO 502",
     message = "Strategy_502 de FranPineda: LONG validado por Turtle Soup M5"
)

alertcondition(
     shortValidated,
     title = "SHORT VALIDADO 502",
     message = "Strategy_502 de FranPineda: SHORT validado por Turtle Soup M5"
)

alertcondition(
     longValidated and pendingOrderPlaced,
     title = "LONG STOP PREPARADO 502",
     message = "Strategy_502 de FranPineda: LONG STOP preparado"
)

alertcondition(
     shortValidated and pendingOrderPlaced,
     title = "SHORT STOP PREPARADO 502",
     message = "Strategy_502 de FranPineda: SHORT STOP preparado"
)

alertcondition(
     strategy.position_size > 0 and tradeTaken,
     title = "LONG ACTIVADO 502",
     message = "Strategy_502 de FranPineda: LONG activado"
)

alertcondition(
     strategy.position_size < 0 and tradeTaken,
     title = "SHORT ACTIVADO 502",
     message = "Strategy_502 de FranPineda: SHORT activado"
)
````
