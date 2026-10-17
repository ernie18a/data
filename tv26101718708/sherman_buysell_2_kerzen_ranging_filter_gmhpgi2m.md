# sherman Buy/Sell 2 Kerzen + Ranging Filter

- url: https://www.tradingview.com/script/GMHpGi2M/
- type: indicator
- pine_id: PUB;521b2d9d62e24694ba9a0b3b0ef1c12c
- version: 1.0

## Description

Ranging Filter für buy und sell sistem das ist am besten gemacht für silver

## Source Code

````pine
//@version=5
indicator("Buy/Sell 2 Kerzen + Ranging Filter", overlay=true)

// === INPUTS ===
minBodyPerc = input.float(0.3, "Min Body % für Signale", step=0.05)
atrLen = input.int(14, "ATR Länge")
atrMultiplier = input.float(0.5, "Min ATR für Signal")

// === KERZENFARBE ===
greenCandle = close > open
redCandle = close < open

// === VOLATILITÄTSFILTER ===
bodySize = math.abs(close - open)
atr = ta.atr(atrLen)
validMove = bodySize > atr * atrMultiplier  // nur Signale wenn Kerze groß genug

// === LETZTES SIGNAL SPEICHERN ===
var int lastSignal = 0  // 0 = kein, 1 = buy, -1 = sell

// === SIGNALBEDINGUNG ===
buySignal = greenCandle and greenCandle[1] and lastSignal != 1 and validMove
sellSignal = redCandle and redCandle[1] and lastSignal != -1 and validMove

// === UPDATE LETZTES SIGNAL ===
if buySignal
    lastSignal := 1
if sellSignal
    lastSignal := -1

// === PLOT SIGNALS ===
plotshape(buySignal, location=location.belowbar,
     color=color.green, style=shape.labelup, text="BUY")
plotshape(sellSignal, location=location.abovebar,
     color=color.red, style=shape.labeldown, text="SELL")

// === ALERTS ===
alertcondition(buySignal, title="Buy Alert", message="2 grüne Kerzen + Volatilität → BUY")
alertcondition(sellSignal, title="Sell Alert", message="2 rote Kerzen + Volatilität → SELL")
````
