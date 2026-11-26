# OBV RSI BB(SMA)

- url: https://www.tradingview.com/script/TAsXQ699-OBV-RSI-BB-SMA/
- type: indicator
- pine_id: PUB;86b2a5046fd94c48a538fce845cc4373
- version: 1.0

## Description

BB analysis based on RSI (simple moving average) from OBV

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © YanisZh


//@version=6
indicator(title="OBV RSI BB(SMA)", shorttitle="OBV RSI BB", overlay=false, timeframe="", timeframe_gaps=true)

// --- Input ---
rsiLength = input.int(14, "RSI Length", minval=1)
smaWindow = input.int(20, "SMA Window", minval=1)
bbWeight  = input.float(2.0, "Bollinger Weight", minval=0.001, step=0.1)

// --- OBV ---
priceChange = ta.change(close)          
var float obv = 0.0
if bar_index == 0
    obv := 0.0
else
    dir = math.sign(priceChange)         
    obv := obv[1] + dir * volume

// ---  OBV  RSI（Wilder）---
changeOBV = ta.change(obv)
up   = ta.rma(math.max(changeOBV, 0), rsiLength)
down = ta.rma(-math.min(changeOBV, 0), rsiLength)
rsi  = down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))

// --- RSI SMA
avgRSI   = ta.sma(rsi, smaWindow)
avgSqRSI = ta.sma(rsi * rsi, smaWindow)
varRSI   = avgSqRSI - avgRSI * avgRSI         
stdevRSI = math.sqrt(math.max(varRSI, 0))      

// --- Boll ---
upperBB = avgRSI + bbWeight * stdevRSI
lowerBB = avgRSI - bbWeight * stdevRSI

// --- Figure ---
plot(rsi,     "RSI",           color=#7E57C2, linewidth=1)
plot(avgRSI,  "RSI SMA",       color=color.yellow, linewidth=1)
plot(upperBB, "Upper Band",    color=color.green, linewidth=1)
plot(lowerBB, "Lower Band",    color=color.red,   linewidth=1)
hline(50, "Midline", color=color.gray, linestyle=hline.style_dashed)
````
