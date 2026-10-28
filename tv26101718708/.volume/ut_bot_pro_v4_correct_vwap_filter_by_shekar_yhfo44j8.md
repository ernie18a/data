# UT Bot PRO v4 (Correct VWAP Filter by Shekar)

- url: https://www.tradingview.com/script/YHFo44J8-UT-Bot-PRO-v4-Correct-VWAP-Filter-by-Shekar/
- type: indicator
- pine_id: PUB;b3bfeff016e7416d87787ee9cf264455
- version: 2.0

## Description

It gives signal when big heikanashi candle comes , diff between this and ut bot is ; ut bot gives signal only once but it gives signal everytime when big ha candle comes.

## Source Code

````pine
//@version=6
indicator("UT Bot PRO v4 (Correct VWAP Filter)", overlay=true)

// === INPUTS ===
haBodyMultiplier = input.float(1.2, "Strong Candle Multiplier")
pullbackBars = input.int(3, "Pullback Lookback")

// === VWAP (MATCH CHART) ====
vwapValue = ta.vwap(hlc3)  // IMPORTANT FIX

// === HEIKIN ASHI ===
haClose = (open + high + low + close) / 4
var float haOpen = na
haOpen := na(haOpen[1]) ? (open + close)/2 : (haOpen[1] + haClose[1]) / 2

haBody = math.abs(haClose - haOpen)
haAvgBody = ta.sma(haBody, 10)

// === STRONG CANDLES ===
isStrongBull = haClose > haOpen and haBody > haAvgBody * haBodyMultiplier
isStrongBear = haClose < haOpen and haBody > haAvgBody * haBodyMultiplier

// === PULLBACK ===
isPullbackBull = haClose < haOpen or haBody < haAvgBody
isPullbackBear = haClose > haOpen or haBody < haAvgBody

pullbackHappenedBull = ta.barssince(isPullbackBull) < pullbackBars
pullbackHappenedBear = ta.barssince(isPullbackBear) < pullbackBars

// === STATE ===
var bool sellReady = true
var bool buyReady = true

if pullbackHappenedBear
    sellReady := true

if pullbackHappenedBull
    buyReady := true

// === STRICT VWAP CONDITIONS ===

// 🚫 STRICT: candle must CLOSE above VWAP
aboveVWAP = close > vwapValue and low > vwapValue

// 🚫 STRICT: candle must CLOSE below VWAP
belowVWAP = close < vwapValue and high < vwapValue

// === SIGNALS ===
sellSignal = belowVWAP and isStrongBear and sellReady
buySignal  = aboveVWAP and isStrongBull and buyReady

if sellSignal
    sellReady := false

if buySignal
    buyReady := false

// === PLOTS ===
plot(vwapValue, color=color.yellow, linewidth=2)

plotshape(buySignal, title="BUY", location=location.belowbar,
     color=color.green, style=shape.labelup, text="B")

plotshape(sellSignal, title="SELL", location=location.abovebar,
     color=color.red, style=shape.labeldown, text="S")

// === ALERTS ===
alertcondition(buySignal, title="BUY ALERT", message="BUY Signal")
alertcondition(sellSignal, title="SELL ALERT", message="SELL Signal")
````
