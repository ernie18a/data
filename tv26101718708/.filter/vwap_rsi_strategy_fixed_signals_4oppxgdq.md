# VWAP RSI Strategy (Fixed Signals)

- url: https://www.tradingview.com/script/4opPxGDQ-VWAP-RSI-Strategy-Fixed-Signals/
- type: indicator
- pine_id: PUB;5975e3c624f744fb8554337761deee84
- version: 1.0

## Description

hi
this can be used for intraday trades... gives buy and sell signal using vwap and rsi... simple yet powerful for intraday trading.... enter trade only on entry point in next candle.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ntmanish

//@version=6
//@version=5
indicator("VWAP RSI Strategy (Fixed Signals)", overlay=true)

// === INPUTS ===
rsiLen = input.int(14, "RSI Length")
rsiLevel = input.int(55, "RSI Threshold")
maxRisk = input.int(200, "Max SL Points")

// === INDICATORS ===
vwapValue = ta.vwap(close)
rsi = ta.rsi(close, rsiLen)

// === CONDITIONS ===

// Proper VWAP CROSS conditions
buyCondition = ta.crossover(close, vwapValue) and rsi > rsiLevel
sellCondition = ta.crossunder(close, vwapValue) and rsi < 45

// === RISK CALCULATION ===
entryPrice = close
risk = entryPrice - vwapValue
riskSell = vwapValue - entryPrice

// === RISK FILTER ===
validBuy = risk > 0 and risk <= maxRisk
validSell = riskSell > 0 and riskSell <= maxRisk

// === TARGETS ===
target1_buy = entryPrice + (risk * 2)
target2_buy = entryPrice + (risk * 3)
sl_buy = vwapValue

target1_sell = entryPrice - (riskSell * 2)
target2_sell = entryPrice - (riskSell * 3)
sl_sell = vwapValue

// === FINAL CONDITIONS ===
finalBuy = buyCondition and validBuy
finalSell = sellCondition and validSell

// === PLOT VWAP ===
plot(vwapValue, color=color.orange, linewidth=2)

// === SIGNAL MARKERS ===
plotshape(finalBuy, location=location.belowbar, color=color.green, style=shape.triangleup, size=size.small)
plotshape(finalSell, location=location.abovebar, color=color.red, style=shape.triangledown, size=size.small)

// === LABELS ===
if finalBuy
    label.new(bar_index, low,
     "BUY\nEntry: " + str.tostring(math.round(entryPrice)) +
     "\nSL: " + str.tostring(math.round(sl_buy)) +
     "\nT1: " + str.tostring(math.round(target1_buy)) +
     "\nT2: " + str.tostring(math.round(target2_buy)),
     style=label.style_label_up, color=color.green, textcolor=color.white)

if finalSell
    label.new(bar_index, high,
     "SELL\nEntry: " + str.tostring(math.round(entryPrice)) +
     "\nSL: " + str.tostring(math.round(sl_sell)) +
     "\nT1: " + str.tostring(math.round(target1_sell)) +
     "\nT2: " + str.tostring(math.round(target2_sell)),
     style=label.style_label_down, color=color.red, textcolor=color.white)

// === ALERTS ===
alertcondition(finalBuy, title="Buy Signal", message="VWAP RSI Buy Signal")
alertcondition(finalSell, title="Sell Signal", message="VWAP RSI Sell Signal")
````
