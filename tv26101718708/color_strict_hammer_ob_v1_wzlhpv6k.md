# Color Strict Hammer OB v1

- url: https://www.tradingview.com/script/wZlHpv6K-Color-Strict-Hammer-OB-v1/
- type: indicator
- pine_id: PUB;49c92dd663d342eb8577f7894f08d8d2
- version: 1.0

## Description

This is an open-source TradingView script designed to help traders analyze market conditions with clear and structured signals. The logic is fully transparent and can be modified freely. It is intended for educational use and personal strategy development. Feel free to explore, customize, and improve the code according to your trading style.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © rinsokpaul
//@version=6
indicator("Color Strict Hammer OB v1", overlay=true)

prevRange = high[1] - low[1]
prevBody = math.abs(close[1] - open[1])

prevUpperWick = high[1] - math.max(open[1], close[1])
prevLowerWick = math.min(open[1], close[1]) - low[1]

upperRatio = prevUpperWick / prevRange
lowerRatio = prevLowerWick / prevRange
bodyRatio = prevBody / prevRange

redInvertedHammer = (close[1] < open[1]) and (upperRatio >= 0.50) and (lowerRatio <= 0.25) and (bodyRatio <= 0.45)

greenHangingMan = (close[1] > open[1]) and (lowerRatio >= 0.50) and (upperRatio <= 0.25) and (bodyRatio <= 0.45)

obRange = high - low
obBody = math.abs(close - open)

obRatio = obBody / obRange

strongOB = obRatio >= 0.50

//==============================
// DISPLACEMENT OB CONFIRMATION
//==============================

// Candle 1 reference
hammerHigh = high[1]
hangLow = low[1]

// BUY OB: must break + close above hammer wick
bullishOB =
     close > open and
     high > hammerHigh and
     close > hammerHigh

// SELL OB: must break + close below hanging man wick
bearishOB =
     close < open and
     low < hangLow and
     close < hangLow

// BUY MITIGATION
buyWickLevel = high[1]

buyMitigationNow =
     low <= buyWickLevel

buyMitigationDelayed =
     (low[1] <= buyWickLevel) or
     (low[2] <= buyWickLevel) or
     (low[3] <= buyWickLevel)

buyMitigation =
     buyMitigationNow or buyMitigationDelayed

// SELL MITIGATION
sellWickLevel = low[1]

sellMitigationNow =
     high >= sellWickLevel

sellMitigationDelayed =
     (high[1] >= sellWickLevel) or
     (high[2] >= sellWickLevel) or
     (high[3] >= sellWickLevel)

sellMitigation =
     sellMitigationNow or sellMitigationDelayed

//==============================
// BREAK CONFIRMATION
//==============================

buyBreak  = math.max(open, close) > high[1]
sellBreak = math.min(open, close) < low[1]


buySignal =
     redInvertedHammer and
     bullishOB and
     buyBreak and
     buyMitigation

sellSignal =
     greenHangingMan and
     bearishOB and
     sellBreak and
     sellMitigation

plotshape(buySignal, title="BUY", style=shape.labelup, location=location.belowbar, color=color.green, text="BUY")

plotshape(sellSignal, title="SELL", style=shape.labeldown, location=location.abovebar, color=color.red, text="SELL")

alertcondition(buySignal, title="BUY ALERT", message="BUY: Red Inverted Hammer + Bullish OB")

alertcondition(sellSignal, title="SELL ALERT", message="SELL: Green Hanging Man + Bearish OB")
````
