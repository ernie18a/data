# FLUX MATRIX  Market Structure Engine

- url: https://www.tradingview.com/script/TOpkW34J/
- type: indicator
- pine_id: PUB;9aded54f73a644ee80e22b3ecf2cb900
- version: 1.0

## Description

🧩 FLUX MATRIX • Market Structure Engine

FLUX MATRIX is a multi-layer market structure engine designed to visualize hidden market pressure, energy flow, and trend alignment in real time.

Unlike traditional indicators that rely on single signals, FLUX MATRIX combines multiple dimensions of price behavior into a unified “tetris-style” grid system:

ATR (market energy)
Delta (price pressure)
OBV (volume flow)
Momentum (speed of movement)
Volatility (expansion / compression state)
Trend structure (directional bias)

Each component is normalized and transformed into a dynamic block system, creating a live visual representation of market conditions.

🧠 Core Logic

The system does not predict the market directly.
Instead, it evaluates market alignment:

When multiple blocks align → probability of continuation increases
When blocks diverge → market becomes unstable or range-bound
When energy spikes → expansion phase begins
When energy compresses → accumulation phase forms
📊 Market Phases
🟢 Compression

Low energy environment.
Market is building pressure before a move.

🔵 Expansion

Momentum + volatility alignment.
High probability directional movement phase.

🔴 Exhaustion / Stress

Overheated conditions.
Trend weakening or reversal risk increases.

🎮 Visual Concept

FLUX MATRIX is designed like a tetris-like market grid where each column represents a different market force.
The height and color of blocks represent intensity and strength.

This creates a real-time “market heat structure” instead of a traditional line-based indicator.

⚠️ Important Note

This tool is not a direct buy/sell signal system.
It is a market structure visualization engine intended to support decision-making, not replace it.

🚀 Summary

FLUX MATRIX helps traders understand:

Where energy is building
When the market is aligning
When momentum is fading
When volatility is preparing expansion

It turns raw market data into a structured visual “flow map”.

## Source Code

````pine
//@version=5
indicator("🧩 FLUX MATRIX • Tetris Engine", overlay=true)

//━━━━━━━━━━━━━━━━━━ INPUTS
len      = input.int(14, "Main Length")
rows     = input.int(10, "Grid Height")

showBg   = input.bool(true, "Stress Background")
showProb = input.bool(true, "Probability Engine")

//━━━━━━━━━━━━━━━━━━ CORE DATA

atr = ta.atr(len)

delta = close - close[1]

// MANUAL OBV
var float obv = 0.0

obv := nz(obv[1]) +
     (close > close[1] ? volume :
     close < close[1] ? -volume : 0)

momentum = ta.roc(close, len)

volatility =
     atr / math.max(ta.sma(atr, len), 1)

trend =
     ta.ema(close, 9) -
     ta.ema(close, 21)

//━━━━━━━━━━━━━━━━━━ NORMALIZER

norm(x) =>
    base = ta.sma(math.abs(x), len)
    base == 0 ? 0 : x / base

//━━━━━━━━━━━━━━━━━━ NORMALIZED VALUES

atrV = norm(atr)

delV = norm(delta)

obvSmooth = ta.ema(obv, len)

obvV = norm(obv - obvSmooth)

momV = norm(momentum)

volV = norm(volatility)

trdV = norm(trend)

//━━━━━━━━━━━━━━━━━━ BLOCK ENGINE

getBlocks(x) =>

    ax = math.abs(x)

    int b = 1

    if ax > 2.2
        b := 6
    else if ax > 1.6
        b := 5
    else if ax > 1.2
        b := 4
    else if ax > 0.8
        b := 3
    else if ax > 0.4
        b := 2
    else
        b := 1

    math.min(b, rows)

//━━━━━━━━━━━━━━━━━━ BLOCK VALUES

b1 = getBlocks(atrV)
b2 = getBlocks(delV)
b3 = getBlocks(obvV)
b4 = getBlocks(momV)
b5 = getBlocks(volV)
b6 = getBlocks(trdV)

//━━━━━━━━━━━━━━━━━━ PHASE ENGINE

totalEnergy =
     b1 + b2 + b3 +
     b4 + b5 + b6

compression = totalEnergy <= 10
expansion   = totalEnergy >= 22
extreme     = totalEnergy >= 30

//━━━━━━━━━━━━━━━━━━ COLOR ENGINE

getColor(x) =>

    color out = color.gray

    if x > 1.5
        out := color.lime
    else if x > 0.7
        out := color.aqua
    else if x > 0
        out := color.yellow
    else if x > -0.7
        out := color.orange
    else
        out := color.red

    out

//━━━━━━━━━━━━━━━━━━ TABLES

var table t =
     table.new(
     position.middle_right,
     6,
     rows,
     border_width = 1)

var table legend =
     table.new(
     position.top_right,
     1,
     8)

//━━━━━━━━━━━━━━━━━━ DRAW FUNCTION

drawColumn(col, blocks, val, txt) =>

    for r = 0 to blocks - 1

        table.cell(
             t,
             col,
             rows - 1 - r,
             txt,
             bgcolor = getColor(val),
             text_color = color.white)

//━━━━━━━━━━━━━━━━━━ DRAW GRID

if barstate.islast

    // CLEAR GRID
    for r = 0 to rows - 1
        for c = 0 to 5

            table.cell(
                 t,
                 c,
                 r,
                 "",
                 bgcolor = color.rgb(10,10,10))

    // DRAW COLUMNS
    drawColumn(0, b1, atrV, "ATR")
    drawColumn(1, b2, delV, "DEL")
    drawColumn(2, b3, obvV, "OBV")
    drawColumn(3, b4, momV, "MOM")
    drawColumn(4, b5, volV, "VOL")
    drawColumn(5, b6, trdV, "TRD")

//━━━━━━━━━━━━━━━━━━ LEGEND

if barstate.islast

    phaseText =
         compression ? "COMPRESSION" :
         expansion ? "EXPANSION" :
         "BALANCED"

    phaseColor =
         compression ? color.gray :
         expansion ? color.lime :
         color.orange

    table.cell(
         legend,
         0,
         0,
         "🧩 FLUX MATRIX",
         text_color = color.white,
         bgcolor = color.black)

    table.cell(
         legend,
         0,
         1,
         "PHASE : " + phaseText,
         text_color = phaseColor,
         bgcolor = color.black)

    table.cell(
         legend,
         0,
         2,
         "🟢 Strong Momentum",
         text_color = color.lime,
         bgcolor = color.black)

    table.cell(
         legend,
         0,
         3,
         "🔵 Healthy Flow",
         text_color = color.aqua,
         bgcolor = color.black)

    table.cell(
         legend,
         0,
         4,
         "🟡 Weak Zone",
         text_color = color.yellow,
         bgcolor = color.black)

    table.cell(
         legend,
         0,
         5,
         "🔴 Pressure Zone",
         text_color = color.red,
         bgcolor = color.black)

//━━━━━━━━━━━━━━━━━━ PROBABILITY ENGINE

score =
     atrV +
     delV +
     obvV +
     momV +
     volV +
     trdV

bullProb =
     math.max(
     math.min(
     50 + score * 8,
     100),
     0)

bearProb = 100 - bullProb

if barstate.islast and showProb

    table.cell(
         legend,
         0,
         6,
         "🟢 Bull : " +
         str.tostring(bullProb, "#.0") +
         "% | 🔴 Bear : " +
         str.tostring(bearProb, "#.0") + "%",
         text_color = color.white,
         bgcolor = color.black)
````
