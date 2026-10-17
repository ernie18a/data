# Strategy_501 de FranPineda

- url: https://www.tradingview.com/script/V9WyS98w/
- type: strategy
- pine_id: PUB;fadf35ffc1dd4a9dbffcbb9f164ba891
- version: 1.0

## Description

**Strategy_501 de FranPineda**

Strategy_501 is a New York session liquidity-based strategy built around a predefined 3-hour range.

The model first creates a range from **06:00 to 08:59 New York time**. Once that range is completed, the strategy starts tracking the highest high and the lowest low formed by the M5 candles after the range closes.

The active entry window runs from **09:00 to 12:30 New York time**.

The strategy does not enter immediately after a liquidity sweep. Instead, it waits for price to take one side of the 3-hour range and then places a pending stop order at the opposite post-range extreme.

For a **long setup**, price must first take the low of the 3-hour range. After that, the strategy places a buy stop order at the highest M5 high formed after the range close. The stop loss is placed below the lowest M5 low formed after the range close, with a configurable buffer.

For a **short setup**, price must first take the high of the 3-hour range. After that, the strategy places a sell stop order at the lowest M5 low formed after the range close. The stop loss is placed above the highest M5 high formed after the range close, with a configurable buffer.

The take profit is always calculated using a fixed **1:1 risk-to-reward ratio**. It is not limited to the opposite side of the 3-hour range. If the opposite range level is not far enough to provide a full 1R target, the take profit is extended until the 1:1 RR level is reached.

If no entry is triggered before **12:30 New York time**, the pending setup is cancelled and the strategy waits for the next trading day.

If a trade is still open at **16:00 New York time**, the stop loss is moved to break even.

**Core logic:**

* 3-hour New York range: 06:00–08:59 NY.
* Entry window: 09:00–12:30 NY.
* Liquidity sweep of the range high or low.
* Pending stop entry at the opposite post-range M5 extreme.
* Stop loss beyond the post-range extreme with buffer.
* Take profit always at 1:1 RR.
* Break even rule at 16:00 NY.
* One trade maximum per day.
* Designed for the M5 timeframe.

The purpose of this strategy is to study how price behaves after taking liquidity from a key intraday range and whether a later breakout of the post-range structure can offer a cleaner continuation toward a fixed 1R target.

## Source Code

````pine
//@version=6
strategy(
     "Strategy_501 de FranPineda",
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
     "Mostrar caja",
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

// Reset de extremos post-rango
if newDay
    postRangeHigh := na
    postRangeLow := na

// Inicializar al cierre del rango
if endRange
    postRangeHigh := high
    postRangeLow := low

// Actualizar extremos después del cierre del rango
if rangeReady and not inRange and not tradeTaken and strategy.position_size == 0
    postRangeHigh := na(postRangeHigh) ? high : math.max(postRangeHigh, high)
    postRangeLow := na(postRangeLow) ? low : math.min(postRangeLow, low)

// Dibujar extremos post-rango
plot(
     rangeReady ? postRangeHigh : na,
     color = color.new(color.orange, 0),
     linewidth = 1,
     title = "POST RANGE HIGH"
)

plot(
     rangeReady ? postRangeLow : na,
     color = color.new(color.blue, 0),
     linewidth = 1,
     title = "POST RANGE LOW"
)

//====================================================
//==================== SETUPS ========================
//====================================================

var bool longSetup = false
var bool shortSetup = false

var float longEntryPrice = na
var float longSL = na
var float longTP = na

var float shortEntryPrice = na
var float shortSL = na
var float shortTP = na

if newDay
    longSetup := false
    shortSetup := false

    longEntryPrice := na
    longSL := na
    longTP := na

    shortEntryPrice := na
    shortSL := na
    shortTP := na

//====================================================
//============ DETECCIÓN TOMA LIQUIDEZ ===============
//====================================================

// LONG SETUP:
// El precio toma el LOW del rango H3.
if (
     rangeReady and
     allowedTrading and
     not tradeTaken and
     strategy.position_size == 0 and
     low < rangeLow
)

    longSetup := true
    shortSetup := false

    shortEntryPrice := na
    shortSL := na
    shortTP := na

    strategy.cancel("SHORT")

// SHORT SETUP:
// El precio toma el HIGH del rango H3.
if (
     rangeReady and
     allowedTrading and
     not tradeTaken and
     strategy.position_size == 0 and
     high > rangeHigh
)

    shortSetup := true
    longSetup := false

    longEntryPrice := na
    longSL := na
    longTP := na

    strategy.cancel("LONG")

//====================================================
//============ CÁLCULO ÓRDENES PENDIENTES ============
//====================================================

// LONG:
// Entrada en el alto más alto post-rango.
// SL en el bajo más bajo post-rango - buffer.
// TP siempre RR 1:1.
if (
     longSetup and
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
// Entrada en el bajo más bajo post-rango.
// SL en el alto más alto post-rango + buffer.
// TP siempre RR 1:1.
if (
     shortSetup and
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
     longSetup and
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
     shortSetup and
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

    longSetup := false
    shortSetup := false

    pendingOrderPlaced := false

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
                 "LONG 501",
                 style = label.style_label_up,
                 color = color.lime,
                 textcolor = color.black
            )

        if strategy.position_size < 0
            label.new(
                 bar_index,
                 high,
                 "SHORT 501",
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
if longSetup and pendingOrderPlaced and strategy.position_size == 0 and not na(longEntryPrice)

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
if shortSetup and pendingOrderPlaced and strategy.position_size == 0 and not na(shortEntryPrice)

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
     longSetup and pendingOrderPlaced,
     title = "LONG STOP 501",
     message = "Strategy_501 de FranPineda: LONG STOP preparado"
)

alertcondition(
     shortSetup and pendingOrderPlaced,
     title = "SHORT STOP 501",
     message = "Strategy_501 de FranPineda: SHORT STOP preparado"
)

alertcondition(
     strategy.position_size > 0 and tradeTaken,
     title = "LONG ACTIVADO 501",
     message = "Strategy_501 de FranPineda: LONG activado"
)

alertcondition(
     strategy.position_size < 0 and tradeTaken,
     title = "SHORT ACTIVADO 501",
     message = "Strategy_501 de FranPineda: SHORT activado"
)
````
