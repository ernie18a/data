# NTR: NASDAQ M1 - Trend Runner

- url: https://www.tradingview.com/script/O4PX6w2i/
- type: strategy
- pine_id: PUB;016c8e87585b418296ce0a76900f3a36
- version: 1.0

## Description

NASDAQ M1 - MACD Trend Runner is a systematic trend continuation strategy specifically designed and optimized for the NASDAQ index on the 1-minute timeframe.

The strategy was developed around a simple observation:

Strong directional movements in NASDAQ often emerge after temporary pullbacks toward key moving averages while underlying momentum remains intact.

Instead of attempting to predict reversals or market turning points, the objective of this framework is to identify favorable re-entry opportunities within an existing bullish environment and allow winning positions to develop through dynamic trade management.

CORE CONCEPT

The strategy combines momentum, trend structure, market positioning, and risk control into a single execution model.

A valid setup requires:

• MACD bullish crossover.
• Momentum developing from lower MACD values.
• Price trading within a defined proximity to the 200-period moving average.
• Positive higher-order trend structure measured through the slope of the 50-period moving average.
• Time-of-day filtering to focus on periods of meaningful market participation.

This combination seeks to isolate moments where price temporarily retraces into trend support before resuming directional movement.

TRADE MANAGEMENT

Risk management is based on market structure rather than fixed stop distances.

Initial stop placement is determined using recent technical lows, creating a structure-based risk framework that adapts to changing market conditions.

Once a position develops sufficient unrealized profit, the strategy transitions into a trailing stop model designed to protect gains while allowing extended trend participation.

The goal is not to maximize win rate.

The goal is to capture asymmetric reward opportunities where a limited number of successful trades can outweigh multiple small losses.

KEY FEATURES

• MACD Momentum Confirmation
• SMA200 Trend Location Filter
• SMA50 Slope Validation
• Technical Structure-Based Stop Loss
• Dynamic Trailing Stop Management
• Session-Based Time Filter
• Daily Trade Limitation Logic
• Daily Profit Protection Logic
• Visual Diagnostic System
• Re-entry Detection Framework

DESIGN PHILOSOPHY

This strategy is intentionally specialized.

It was developed, tested, and refined specifically for NASDAQ price behavior on the 1-minute timeframe.

While certain concepts may be transferable to other instruments, the framework was not designed as a universal trading system.

The primary objective is to exploit recurring short-term trend continuation behavior observed within NASDAQ intraday market structure.

DISCLAIMER

This strategy is provided for educational and research purposes only.

Past performance does not guarantee future results. All trading involves risk, and users should perform their own analysis and validation before applying any strategy in live market conditions.

Created by @Peter_n_n

## Source Code

````pine
//@version=6
strategy("NTR: NASDAQ M1 - Trend Runner", shorttitle='NTR', overlay=true, initial_capital=10000, default_qty_type=strategy.percent_of_equity, default_qty_value=100, pyramiding=10)

// === CONFIGURACIÓN ===

// ---------------- MACD ----------------
fastLength    = input.int(12, title="MACD Fast Length", group="MACD")
slowLength    = input.int(26, title="MACD Slow Length", group="MACD")
signalLength  = input.int(9, title="MACD Signal Length", group="MACD")

// ---------------- SMA ----------------
smaLength       = input.int(200, title="SMA 200", group="Filtro SMA")
maxPipsDistance = input.float(75.0, title="Distancia Máxima Pips", group="Filtro SMA")

// ---------------- Gestión ----------------
ratioBeneficio  = input.float(5.0, title="TP Ratio 1:X", group="Gestión")
slPeriodos      = input.int(30, title="Periodos Mínimo Técnico", group="Gestión")
slExtraPips     = input.float(2.0, title="SL Extra debajo Mínimo", group="Gestión")

// ---------------- Trailing Stop ----------------
trailingStopPips      = input.float(100.0, title="Distancia Trailing Stop", group="Trailing Stop")
activarTrailingPips   = input.float(100.0, title="Activar Trailing después de profit", group="Trailing Stop")

// ---------------- Horario ----------------
horaSesion = input.session("0730-1500", title="Horario Operativo", group="Horario")

// === INDICADORES ===

// ---------------- MACD ----------------
[macdLine, signalLine, histLine] = ta.macd(close, fastLength, slowLength, signalLength)
macdDebajoCero = macdLine < 10 and signalLine < 10
macdCrossUp = ta.crossover(macdLine, signalLine)
macdBullish = macdLine > signalLine
histReimpulso = histLine > histLine[1] and histLine[1] < histLine[2]

gatilloMACD = macdCrossUp

// ---------------- SMA ----------------
sma200 = ta.sma(close, smaLength)
sma50 = ta.sma(close, 50)

// ---------------- Pips ----------------
pipValue = syminfo.mintick * 10

distanceInPips = math.abs(close - sma200) / pipValue

// === PENDIENTE SMA50 ===
periodosPendiente = input.int(10, title="Velas Pendiente SMA", group="Filtro SMA")

// Pendiente promedio
pendienteSMA50 = (sma50 - sma50[periodosPendiente]) / periodosPendiente

// Filtro flexible
pendienteMinima = input.float(-2.5, title="Pendiente mínima SMA50", group="Filtro SMA")

filtroEntradaMA = pendienteSMA50 >= pendienteMinima

// Solo afecta señal de entrada
cercaDeSMA = distanceInPips <= maxPipsDistance

// === MÍNIMO TÉCNICO ===
minimoTecnico = ta.lowest(low, slPeriodos)[1]

// === FILTRO HORARIO ===
enHorarioPermitido = not na(time(timeframe.period, horaSesion, "America/Mexico_City"))

// === CONTROL REENTRADAS ===
var int barraUltimaSalida = 0

huboCambioPosicion = nz(ta.change(strategy.position_size)) != 0

posicionCerrada = huboCambioPosicion and strategy.position_size == 0

if posicionCerrada
    barraUltimaSalida := bar_index

candadoReentrada = bar_index > barraUltimaSalida

nuevoDia = ta.change(dayofmonth(time("D", "0000-2359", "America/Mexico_City"))) != 0

// === CONTROL DIARIO ===
var int operacionesHoy = 0
var int perdidasHoy = 0
var int gananciasHoy = 0

if nuevoDia
    operacionesHoy := 0
    perdidasHoy := 0
    gananciasHoy := 0

tradeCerrado = strategy.closedtrades > strategy.closedtrades[1]

if tradeCerrado

    operacionesHoy += 1

    ultimoTrade = strategy.closedtrades - 1

    profitUltimo = strategy.closedtrades.profit(ultimoTrade)

    if profitUltimo < 0
        perdidasHoy += 1

    if profitUltimo > 0
        gananciasHoy += 1

// === FILTROS ===
limiteOperaciones = operacionesHoy < 3
limiteGanancias   = gananciasHoy < 2
sinPosicion       = strategy.position_size == 0

// === SEÑAL POTENCIAL ===
senalPotencial =
     gatilloMACD and
     macdDebajoCero and
     cercaDeSMA and
     candadoReentrada and
     enHorarioPermitido and
     filtroEntradaMA

// === ENTRADA REAL ===
senalCompra =
     senalPotencial and
     limiteOperaciones and
     limiteGanancias and
     sinPosicion

// === SEÑAL VISUAL ===
senalVisual = senalPotencial

// === VARIABLES ===
var float precioSL = na
var float trailingSL = na
var float riesgo = na
var float stopActual = na

// === ENTRADA ===
if senalCompra

    precioSL := minimoTecnico - (slExtraPips * pipValue)

    riesgo := close - precioSL

    // Seguridad
    if riesgo <= 0
        riesgo := 20 * pipValue
        precioSL := close - riesgo

    strategy.entry("Compra", strategy.long)
    
    stopActual := precioSL

// === TRAILING STOP ===
if strategy.position_size > 0

    profitActual = close - strategy.position_avg_price

    // Activar trailing después de profit
    if profitActual >= (activarTrailingPips * pipValue)

        nuevoTrailing = close - (trailingStopPips * pipValue)

        // El trailing solo puede subir
        trailingSL := math.max(nuevoTrailing, nz(trailingSL[1]))

        // Reemplazar stop actual por trailing
        stopActual := trailingSL

    // ÚNICA salida de toda la estrategia
    strategy.exit("Salida", "Compra", stop=stopActual)

// === RESET VARIABLES ===
if strategy.position_size == 0

    precioSL := na
    trailingSL := na
    riesgo := na

// === VISUAL ===
plot(sma200, color=color.rgb(33, 149, 243, 100), linewidth=2, title="SMA 200")

plot(strategy.position_size > 0 ? precioSL : na,
     color=color.red,
     linewidth=2,
     style=plot.style_linebr,
     title="SL Inicial")

plotshape(
     senalPotencial and not senalCompra,
     style=shape.circle,
     location=location.belowbar,
     color=color.aqua,
     size=size.tiny)

plotshape(
     senalCompra,
     style=shape.triangleup,
     location=location.belowbar,
     color=color.lime,
     size=size.small)

// === DEBUG ===
mostrarDiagnostico = input.bool(true, title="Mostrar Diagnóstico", group="Debug")

// ===== DEBUG VISUAL =====

// MACD OK
plotshape(
     mostrarDiagnostico and gatilloMACD,
     title="MACD OK",
     style=shape.circle,
     location=location.bottom,
     color=color.lime,
     size=size.tiny)

// Bajo cero OK
plotshape(
     mostrarDiagnostico and macdDebajoCero,
     title="MACD Bajo 0",
     style=shape.circle,
     location=location.bottom,
     color=color.aqua,
     size=size.tiny)

// SMA OK
plotshape(
     mostrarDiagnostico and cercaDeSMA,
     title="Cerca SMA",
     style=shape.circle,
     location=location.bottom,
     color=color.orange,
     size=size.tiny)

// Horario OK
plotshape(
     mostrarDiagnostico and enHorarioPermitido,
     title="Horario OK",
     style=shape.circle,
     location=location.bottom,
     color=color.yellow,
     size=size.tiny)

// SMA50 pendiente OK
plotshape(
     mostrarDiagnostico and filtroEntradaMA,
     title="Pendiente SMA50 OK",
     style=shape.circle,
     location=location.bottom,
     color=color.fuchsia,
     size=size.tiny)

// ===== LABEL SOLO SI FALLA ALGO =====

falloEntrada =
     gatilloMACD and
     (
     not macdDebajoCero or
     not cercaDeSMA or
     not enHorarioPermitido or
     not filtroEntradaMA
     )

if mostrarDiagnostico and falloEntrada

    string motivos = ""

    motivos += macdDebajoCero ? "" : "❌ Bajo 0\n"
    motivos += cercaDeSMA ? "" : "❌ SMA\n"
    motivos += enHorarioPermitido ? "" : "❌ Horario\n"
    motivos += filtroEntradaMA ? "" : "❌ Pendiente SMA50\n"

    label.new(
         bar_index,
         high,
         motivos,
         style=label.style_label_down,
         textcolor=color.white,
         color=color.rgb(40,40,40),
         size=size.tiny)

// === ALERTAS ===
// Señal visual (reentrada potencial)
alertcondition(
     senalVisual,
     title="Posible Reentrada",
     message="Nueva señal visual NASDAQ M1"
)

// Entrada REAL ejecutada
alertcondition(
     senalCompra,
     title="Entrada Ejecutada",
     message="Entrada REAL NASDAQ M1"
)

// Salida
alertcondition(
     posicionCerrada,
     title="Salida",
     message="Posición cerrada NASDAQ M1"
)
````
