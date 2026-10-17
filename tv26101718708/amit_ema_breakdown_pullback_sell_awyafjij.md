# amit EMA Breakdown Pullback SELL

- url: https://www.tradingview.com/script/AWyaFjIj-amit-EMA-Breakdown-Pullback-SELL/
- type: indicator
- pine_id: PUB;a43435abb9754bc5943f8f8351951b61
- version: 1.0

## Description

price is coming from above 9 ema and its close below 9 ema and now next candle is green and next candle is red break the lower level of green candle then give sell signal

## Source Code

````pine
//@version=6
indicator("EMA Breakdown Pullback SELL", overlay=true)

// === EMA ===
ema9 = ta.ema(close, 9)

// === STEP 1: BREAK BELOW EMA ===
wasAbove = close[2] > ema9[2]
breakBelow = close[1] < ema9[1]

// === STEP 2: GREEN PULLBACK ===
greenCandle = close[1] > open[1]

// === STEP 3: RED BREAKDOWN ===
redCandle = close < open
breakLow = close < low[1]

// === FINAL CONDITION ===
sellSignal = wasAbove and breakBelow and greenCandle and redCandle and breakLow

// === PLOT ===
plot(ema9, color=color.blue)

plotshape(sellSignal,
     location=location.abovebar,
     color=color.red,
     style=shape.labeldown,
     text="SELL")

// ALERT
alertcondition(sellSignal, title="SELL ALERT", message="EMA Breakdown SELL")
````
