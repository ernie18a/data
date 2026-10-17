# Ut bot - Trend+volume

- url: https://www.tradingview.com/script/EhDCu3hn-Ut-bot-Trend-volume/
- type: indicator
- pine_id: PUB;52eafb85496f439782c372774b4b60e4
- version: 1.0

## Description

Works specifically with Market trend and volume before market moves

## Source Code

````pine
//@version=6
indicator("Pure UT Bot - Signals Only", overlay=true)

// --- Settings ---
// These are the "Golden" settings for fast intraday signals
keyValue = input.float(1.0, "Sensitivity (Lower = More Signals)")
atrPeriod = input.int(10, "ATR Period")

// --- UT Bot Core Logic ---
xATR = ta.atr(atrPeriod)
nLoss = keyValue * xATR

var float trailingStop = 0.0
trailingStop := close > nz(trailingStop[1], 0) and close[1] > nz(trailingStop[1], 0) ? math.max(nz(trailingStop[1]), close - nLoss) :
                 close < nz(trailingStop[1], 0) and close[1] < nz(trailingStop[1], 0) ? math.min(nz(trailingStop[1]), close + nLoss) :
                 close > nz(trailingStop[1], 0) ? close - nLoss : close + nLoss

// --- Signal Generation ---
// Buy when price crosses above the invisible trailing stop
buySignal  = ta.crossover(close, trailingStop)
// Sell when price crosses below the invisible trailing stop
sellSignal = ta.crossunder(close, trailingStop)

// --- Visuals (ONLY BUY/SELL LABELS) ---
plotshape(buySignal,  title="BUY",  style=shape.labelup,   location=location.belowbar, color=color.new(#26a69a, 0), text="BUY",  textcolor=color.white, size=size.small)
plotshape(sellSignal, title="SELL", style=shape.labeldown, location=location.abovebar, color=color.new(#ef5350, 0),   text="SELL", textcolor=color.white, size=size.small)

// Alert triggers for your phone/desktop
alertcondition(buySignal,  "UT Buy Signal",  "UT Bot BUY")
alertcondition(sellSignal, "UT Sell Signal", "UT Bot SELL")
````
