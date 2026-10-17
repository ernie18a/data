# Strategy_500 - Turtle Soup NY V5 M5 Sweep

- url: https://www.tradingview.com/script/XC77YPtV/
- type: strategy
- pine_id: PUB;e0a3d29dc86f4b36af4c37aad79789a7
- version: 1.0

## Description

**Strategy_500 – Turtle Soup NY M5 Sweep**

This strategy is based on a New York session liquidity model using a predefined 3-hour range.

The first step is to build the range between **06:00 and 08:59 New York time**. Once that range is completed, the strategy waits for price to take liquidity above or below the range during the active trading window, from **09:00 to 12:00 New York time**.

The logic is simple:

Price must first sweep one side of the 3-hour range.

For a **long setup**, price must take the low of the range. After that, the strategy waits for a 5-minute Turtle Soup confirmation: the current M5 candle must sweep the low of the previous candle, recover back above that previous low, and close bullish. The entry is taken at the close of that confirmation candle.

For a **short setup**, price must take the high of the range. After that, the strategy waits for a 5-minute Turtle Soup confirmation: the current M5 candle must sweep the high of the previous candle, reject back below that previous high, and close bearish. The entry is taken at the close of that confirmation candle.

The stop loss is placed beyond the manipulation extreme, using a configurable buffer. The take profit is placed at the opposite side of the 3-hour range.

To avoid poor-quality trades, the strategy only enters when the potential setup offers at least a **1:1 risk-to-reward ratio**. If the trade does not reach the minimum RR requirement, no position is opened.

The idea behind this model is to avoid entering immediately after a range sweep. Instead, it waits for a second layer of confirmation on M5, trying to capture a cleaner liquidity reversal after the market has trapped breakout traders.

**Main concepts:**

* 3-hour New York range.
* Liquidity sweep of the range high or low.
* M5 Turtle Soup confirmation.
* Entry at the close of the confirmation candle.
* Stop loss beyond the sweep extreme.
* Take profit at the opposite side of the range.
* Minimum RR filter of 1:1.
* One trade per day.

This is a liquidity-based reversal strategy designed to study how price reacts after sweeping a key intraday range during the New York session.

## Source Code

````pine
//@version=6
strategy(
     "Strategy_500 - Turtle Soup NY V5 M5 Sweep",
     overlay = true,
     pyramiding = 0,
     initial_capital = 10000,
     process_orders_on_close = true
)

//====================================================
//==================== INPUTS ========================
//====================================================

// HORARIO RANGO
rangeSession = input.session(
     "0600-0859",
     "Rango NY",
     group = "Horario"
)

// HORARIO OPERATIVA
startHour = input.int(
     9,
     "Hora inicio",
     minval = 0,
     maxval = 23,
     group = "Horario"
)

startMinute = input.int(
     0,
     "Minuto inicio",
     minval = 0,
     maxval = 59,
     group = "Horario"
)

endHour = input.int(
     12,
     "Hora fin",
     minval = 0,
     maxval = 23,
     group = "Horario"
)

endMinute = input.int(
     0,
     "Minuto fin",
     minval = 0,
     maxval = 59,
     group = "Horario"
)

// GESTIÓN
slBuffer = input.float(
     2.0,
     "SL Buffer",
     step = 0.25,
     group = "Gestión"
)

minimumRR = input.float(
     1.0,
     "RR mínimo",
     step = 0.1,
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

//====================================================
//==================== RESET =========================
//====================================================

newDay = dayofmonth(time, "America/New_York") != dayofmonth(time[1], "America/New_York")

var bool tradeTaken = false

if newDay
    tradeTaken := false

//====================================================
//==================== RANGO 3H ======================
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

// RESET
if newDay
    rangeHigh := na
    rangeLow := na
    rangeReady := false

// INICIO
if newRange
    rangeHigh := high
    rangeLow := low

// CONSTRUCCIÓN
if inRange
    rangeHigh := math.max(rangeHigh, high)
    rangeLow := math.min(rangeLow, low)

// FINAL
if endRange
    rangeReady := true

//====================================================
//==================== VISUALES ======================
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

// HIGH
plot(
     rangeReady ? rangeHigh : na,
     color = color.red,
     linewidth = 3,
     title = "HIGH RANGO"
)

// LOW
plot(
     rangeReady ? rangeLow : na,
     color = color.aqua,
     linewidth = 3,
     title = "LOW RANGO"
)

//====================================================
//=========== TOMA LIQUIDEZ RANGO 3H =================
//====================================================

// BARRIDA LOW DEL RANGO 3H
sweepRangeLow = (
     rangeReady and
     low < rangeLow
)

// BARRIDA HIGH DEL RANGO 3H
sweepRangeHigh = (
     rangeReady and
     high > rangeHigh
)

//====================================================
//============ TURTLE SOUP / SWEEP M5 ================
//====================================================

// LONG:
// La vela actual barre el mínimo de la vela anterior,
// recupera cerrando por encima del mínimo anterior,
// y además cierra verde.
bullishM5TurtleSoup = (
     low < low[1] and
     close > low[1] and
     close > open
)

// SHORT:
// La vela actual barre el máximo de la vela anterior,
// recupera cerrando por debajo del máximo anterior,
// y además cierra roja.
bearishM5TurtleSoup = (
     high > high[1] and
     close < high[1] and
     close < open
)

//====================================================
//==================== VARIABLES =====================
//====================================================

var bool longSetup = false
var bool shortSetup = false

var int longSetupBar = na
var int shortSetupBar = na

var float longManipulationLow = na
var float shortManipulationHigh = na

//====================================================
//==================== DETECCIÓN =====================
//====================================================

// LONG SETUP:
// Primero se toma la liquidez del LOW del rango 3H.
if rangeReady and allowedTrading and not tradeTaken

    if sweepRangeLow

        if not longSetup
            longSetupBar := bar_index

        longSetup := true
        shortSetup := false

        longManipulationLow := na(longManipulationLow) ? low : math.min(longManipulationLow, low)

        shortManipulationHigh := na
        shortSetupBar := na

// SHORT SETUP:
// Primero se toma la liquidez del HIGH del rango 3H.
if rangeReady and allowedTrading and not tradeTaken

    if sweepRangeHigh

        if not shortSetup
            shortSetupBar := bar_index

        shortSetup := true
        longSetup := false

        shortManipulationHigh := na(shortManipulationHigh) ? high : math.max(shortManipulationHigh, high)

        longManipulationLow := na
        longSetupBar := na

//====================================================
//==================== LONG ==========================
//====================================================

bool longSignal = false

float longSL = na
float longTP = na
float longEntry = na

if (
     longSetup and
     allowedTrading and
     not tradeTaken and
     strategy.position_size == 0 and
     bar_index > longSetupBar and
     bullishM5TurtleSoup
)

    tempSL = math.min(longManipulationLow, low) - slBuffer
    tempEntry = close
    tempTP = rangeHigh

    risk = tempEntry - tempSL
    reward = tempTP - tempEntry

    rr = reward / risk

    if risk > 0 and reward > 0 and rr >= minimumRR

        longSignal := true

        longSL := tempSL
        longEntry := tempEntry
        longTP := tempTP

//====================================================
//==================== SHORT =========================
//====================================================

bool shortSignal = false

float shortSL = na
float shortTP = na
float shortEntry = na

if (
     shortSetup and
     allowedTrading and
     not tradeTaken and
     strategy.position_size == 0 and
     bar_index > shortSetupBar and
     bearishM5TurtleSoup
)

    tempSL = math.max(shortManipulationHigh, high) + slBuffer
    tempEntry = close
    tempTP = rangeLow

    risk = tempSL - tempEntry
    reward = tempEntry - tempTP

    rr = reward / risk

    if risk > 0 and reward > 0 and rr >= minimumRR

        shortSignal := true

        shortSL := tempSL
        shortEntry := tempEntry
        shortTP := tempTP

//====================================================
//==================== ENTRADAS ======================
//====================================================

// LONG
if longSignal and strategy.position_size == 0 and not tradeTaken

    strategy.entry(
         "LONG",
         strategy.long
    )

    strategy.exit(
         "LONG EXIT",
         from_entry = "LONG",
         stop = longSL,
         limit = longTP
    )

    tradeTaken := true

    longSetup := false
    longSetupBar := na
    longManipulationLow := na

    // ENTRY
    line.new(
         bar_index,
         longEntry,
         bar_index + 20,
         longEntry,
         color = color.yellow,
         width = 2
    )

    // SL
    line.new(
         bar_index,
         longSL,
         bar_index + 20,
         longSL,
         color = color.red,
         width = 2
    )

    // TP
    line.new(
         bar_index,
         longTP,
         bar_index + 20,
         longTP,
         color = color.aqua,
         width = 2
    )

    if showLabels

        label.new(
             bar_index,
             low,
             "LONG M5 TS",
             style = label.style_label_up,
             color = color.lime,
             textcolor = color.black
        )

// SHORT
if shortSignal and strategy.position_size == 0 and not tradeTaken

    strategy.entry(
         "SHORT",
         strategy.short
    )

    strategy.exit(
         "SHORT EXIT",
         from_entry = "SHORT",
         stop = shortSL,
         limit = shortTP
    )

    tradeTaken := true

    shortSetup := false
    shortSetupBar := na
    shortManipulationHigh := na

    // ENTRY
    line.new(
         bar_index,
         shortEntry,
         bar_index + 20,
         shortEntry,
         color = color.yellow,
         width = 2
    )

    // SL
    line.new(
         bar_index,
         shortSL,
         bar_index + 20,
         shortSL,
         color = color.red,
         width = 2
    )

    // TP
    line.new(
         bar_index,
         shortTP,
         bar_index + 20,
         shortTP,
         color = color.aqua,
         width = 2
    )

    if showLabels

        label.new(
             bar_index,
             high,
             "SHORT M5 TS",
             style = label.style_label_down,
             color = color.red,
             textcolor = color.white
        )

//====================================================
//==================== ALERTAS =======================
//====================================================

alertcondition(
     longSignal,
     title = "LONG",
     message = "LONG M5 Turtle Soup después de barrida del rango 3H"
)

alertcondition(
     shortSignal,
     title = "SHORT",
     message = "SHORT M5 Turtle Soup después de barrida del rango 3H"
)
````
