# take liquidity and expansion_pro

- url: https://www.tradingview.com/script/8agDfSNZ/
- type: indicator
- pine_id: PUB;a45ddac9c5414a41822ebbe41acdf281
- version: 1.0

## Description

🧠 System Logic

The script is based on a "sweep + move" model, where the market first generates liquidity and then moves with directional intent.

1. Range Structure

The previous candlestick is used as a reference to define a micro-range:

Previous High
Previous Low

This range acts as a liquidity zone.

2. Manipulation (Sweep)

The system detects when the price:

Breaks the previous low (searching for buy stops)
Breaks the previous high (searching for sell stops)

This represents the institutional manipulation phase.

3. Directional Confirmation

After manipulation, confirmation is required through:

Moving candles (actual price expansion)
Clear candlestick body direction

The indicator offers two modes:

🔹 Simple Mode
Based on basic directional momentum
Candlestick structure + continuation
🔸 Institutional Mode
Stricter filter:
Dominant candlestick body
Expansion above the average true range (ATR)
Close near extremes
Detects more “intentional” and cleaner movement

4. Multi-Timeframe Confirmation

To validate a signal, alignment with the following is required:

H1 (mandatory) → macro direction based on structural manipulation
M15 (execution) → entry point

## Source Code

````pine
//@version=6
indicator("Rangos Manipulados PRO EURUSD/GBPUSD", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

//====================================================
//==================== CONFIG ========================
//====================================================

modoEntrada = input.string("Simple", "Tipo de Confirmación", options=["Simple", "Institucional"])

mostrarRangos = input.bool(true, "Mostrar Rangos")
mostrarDashboard = input.bool(true, "Mostrar Dashboard")
mostrarTP_SL = input.bool(true, "Mostrar TP y SL")

rr = input.float(2.0, "Risk Reward", step=0.1)
bufferPips = input.float(4.0, "Buffer SL en pips")

//====================================================
//==================== HORARIO =======================
//====================================================

sessionFrankfurt = input.session("0800-1700", "Horario Operativo")

enHorario = not na(time(timeframe.period, sessionFrankfurt, "Europe/Madrid"))

//====================================================
//==================== PIPS ==========================
//====================================================

pip = syminfo.mintick * 10
buffer = bufferPips * pip

//====================================================
//==================== H1 DATA =======================
//====================================================

h1High = request.security(syminfo.tickerid, "60", high)
h1Low = request.security(syminfo.tickerid, "60", low)
h1Close = request.security(syminfo.tickerid, "60", close)

h1PrevHigh = request.security(syminfo.tickerid, "60", high[1])
h1PrevLow = request.security(syminfo.tickerid, "60", low[1])

//====================================================
//=========== MANIPULACION H1 ========================
//====================================================

h1ManipBuy = (
    h1Low < h1PrevLow and
    h1Close > h1PrevLow
)

h1ManipSell = (
    h1High > h1PrevHigh and
    h1Close < h1PrevHigh
)

//====================================================
//============= MANIPULACION M15 =====================
//====================================================

prevHigh = high[1]
prevLow = low[1]

sweepBuy = (
    low < prevLow
)

sweepSell = (
    high > prevHigh
)

//====================================================
//============= DEFINICION SIMPLE ====================
//====================================================

simpleBuy = (
    close > open and
    close > high[1]
)

simpleSell = (
    close < open and
    close < low[1]
)

//====================================================
//======= DEFINICION INSTITUCIONAL ===================
//====================================================

bodySize = math.abs(close - open)
fullRange = high - low
atr = ta.atr(14)

institucionalBuy = (
    close > open and
    bodySize > fullRange * 0.6 and
    fullRange > atr * 0.8 and
    close >= high - (fullRange * 0.2)
)

institucionalSell = (
    close < open and
    bodySize > fullRange * 0.6 and
    fullRange > atr * 0.8 and
    close <= low + (fullRange * 0.2)
)

//====================================================
//=========== SELECCION DE MODO ======================
//====================================================

confirmBuy = (
    modoEntrada == "Simple"
        ? simpleBuy
        : institucionalBuy
)

confirmSell = (
    modoEntrada == "Simple"
        ? simpleSell
        : institucionalSell
)

//====================================================
//================ ENTRADAS ==========================
//====================================================

buySignal = (
    enHorario and
    h1ManipBuy and
    sweepBuy and
    confirmBuy
)

sellSignal = (
    enHorario and
    h1ManipSell and
    sweepSell and
    confirmSell
)

//====================================================
//==================== SL / TP =======================
//====================================================

buySL = low - buffer
buyRisk = close - buySL
buyTP = close + (buyRisk * rr)

sellSL = high + buffer
sellRisk = sellSL - close
sellTP = close - (sellRisk * rr)

//====================================================
//==================== FLECHAS =======================
//====================================================

plotshape(
    series=buySignal,
    title="BUY",
    style=shape.arrowup,
    location=location.belowbar,
    color=color.lime,
    size=size.large,
    text="BUY"
)

plotshape(
    series=sellSignal,
    title="SELL",
    style=shape.arrowdown,
    location=location.abovebar,
    color=color.red,
    size=size.large,
    text="SELL"
)

//====================================================
//==================== RANGOS ========================
//====================================================

if mostrarRangos

    if buySignal

        box.new(
            left=bar_index - 1,
            top=prevHigh,
            right=bar_index + 3,
            bottom=prevLow,
            border_color=color.lime,
            bgcolor=color.new(color.lime, 90),
            xloc=xloc.bar_index
        )

    if sellSignal

        box.new(
            left=bar_index - 1,
            top=prevHigh,
            right=bar_index + 3,
            bottom=prevLow,
            border_color=color.red,
            bgcolor=color.new(color.red, 90),
            xloc=xloc.bar_index
        )

//====================================================
//==================== TP / SL =======================
//====================================================

if mostrarTP_SL

    if buySignal

        line.new(
            x1=bar_index,
            y1=buySL,
            x2=bar_index + 5,
            y2=buySL,
            xloc=xloc.bar_index,
            extend=extend.none,
            color=color.red,
            width=2
        )

        line.new(
            x1=bar_index,
            y1=buyTP,
            x2=bar_index + 5,
            y2=buyTP,
            xloc=xloc.bar_index,
            extend=extend.none,
            color=color.lime,
            width=2
        )

    if sellSignal

        line.new(
            x1=bar_index,
            y1=sellSL,
            x2=bar_index + 5,
            y2=sellSL,
            xloc=xloc.bar_index,
            extend=extend.none,
            color=color.red,
            width=2
        )

        line.new(
            x1=bar_index,
            y1=sellTP,
            x2=bar_index + 5,
            y2=sellTP,
            xloc=xloc.bar_index,
            extend=extend.none,
            color=color.lime,
            width=2
        )

//====================================================
//================ DASHBOARD =========================
//====================================================

var table dashboard = table.new(position.top_right, 2, 4)

if mostrarDashboard

    table.cell(dashboard, 0, 0, "Modo")
    table.cell(dashboard, 1, 0, modoEntrada)

    table.cell(dashboard, 0, 1, "H1 BUY")
    table.cell(dashboard, 1, 1, h1ManipBuy ? "SI" : "NO")

    table.cell(dashboard, 0, 2, "H1 SELL")
    table.cell(dashboard, 1, 2, h1ManipSell ? "SI" : "NO")

    table.cell(dashboard, 0, 3, "Horario")
    table.cell(dashboard, 1, 3, enHorario ? "ACTIVO" : "OFF")

//====================================================
//================ ALERTAS ===========================
//====================================================

alertcondition(
    condition=buySignal,
    title="BUY SIGNAL",
    message="BUY EURUSD/GBPUSD"
)

alertcondition(
    condition=sellSignal,
    title="SELL SIGNAL",
    message="SELL EURUSD/GBPUSD"
)
````
