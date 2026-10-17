# BILORIE 4.00

- url: https://www.tradingview.com/script/CvkOzB9s-BILORIE-4-00/
- type: indicator
- pine_id: PUB;0909c950071d4dff85a3ac71be8ef91e
- version: 2.0

## Description

Automate trading based on industry best rpactices while using sell signal dca zone and stoploesses

## Source Code

````pine
//@version=6
indicator("ALADDIN-BRAVO", overlay=true)

//--------------------------------------------------
// BODY SIZE SETTINGS (PERCENTAGE)
//--------------------------------------------------
minBodyPct = input.float(0.30, "Minimum %", step=0.01)
maxBodyPct = input.float(1.50, "Maximum %", step=0.01)

//--------------------------------------------------
// RSI SETTINGS
//--------------------------------------------------
rsiLen = input.int(14, "RSI Length")
smaLen = input.int(3, "RSI SMA Length")

sellRsiMin = input.int(50, "SELL RSI Min")
sellRsiMax = input.int(80, "SELL RSI Max")

buyRsiMin  = input.int(20, "BUY RSI Min")
buyRsiMax  = input.int(50, "BUY RSI Max")

//--------------------------------------------------
// BODY SIZE (PERCENT, NO WICKS)
//--------------------------------------------------
bodyPercent = math.abs(close - open) / close * 100
validBody = bodyPercent >= minBodyPct and bodyPercent <= maxBodyPct

//--------------------------------------------------
// CANDLE DIRECTION
//--------------------------------------------------
bullish = close > open
bearish = close < open

//--------------------------------------------------
// RSI + SMA
//--------------------------------------------------
rsiVal = ta.rsi(close, rsiLen)
rsiSma = ta.sma(rsiVal, smaLen)

//--------------------------------------------------
// STATE VARIABLES
//--------------------------------------------------
var bool armedSell = false
var bool armedBuy  = false

//--------------------------------------------------
// ARM SYSTEM ON BLUE CANDLE
//--------------------------------------------------
if validBody
    armedSell := bullish
    armedBuy  := bearish

//--------------------------------------------------
// RSI CROSS CONDITIONS
//--------------------------------------------------
sellCross = ta.crossover(rsiSma, rsiVal)
buyCross  = ta.crossover(rsiVal, rsiSma)

//--------------------------------------------------
// FINAL SIGNALS (FIRST CROSS ONLY)
//--------------------------------------------------
sellSignal = armedSell and sellCross and rsiVal >= sellRsiMin and rsiVal <= sellRsiMax
buySignal  = armedBuy  and buyCross  and rsiVal >= buyRsiMin  and rsiVal <= buyRsiMax

//--------------------------------------------------
// RESET AFTER SIGNAL
//--------------------------------------------------
if sellSignal or buySignal
    armedSell := false
    armedBuy  := false

//--------------------------------------------------
// VISUALS
//--------------------------------------------------
barcolor(validBody ? color.new(color.blue, 0) : na)

plotshape(
    sellSignal,
    title="SELL",
    style=shape.triangledown,
    location=location.abovebar,
    color=color.red,
    size=size.small,
    text="SELL"
)

plotshape(
    buySignal,
    title="BUY",
    style=shape.triangleup,
    location=location.belowbar,
    color=color.lime,
    size=size.small,
    text="BUY"
)
````
