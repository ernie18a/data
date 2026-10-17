# MSS Trend Filter Lite v1.0

- url: https://www.tradingview.com/script/plRW11A8/
- type: indicator
- pine_id: PUB;ca09a422eb1b4ff98cdfd03691e8552f
- version: 1.0

## Description

M5+M15 FULL TP
If the above code still shows errors, please send your complete current code (after editing) or a new image. I will then send you a complete Pine Script v6 version, streamlined for direct insertion into TradingView without further modifications.

## Source Code

````pine
//@version=6
indicator("XAUUSD MSS Trend Filter Lite v1.0", overlay=true)

//====================================================
// INPUTS
//====================================================
pivotLen = input.int(5, "Pivot Length", minval=2)
emaLen = input.int(50, "EMA Length")
adxLen = input.int(14, "ADX Length")
adxThreshold = input.float(20.0, "ADX Threshold")
atrLen = input.int(14, "ATR Length")
atrBuffer = input.float(0.10, "ATR Buffer")
rr = input.float(1.5, "Risk Reward")

//====================================================
// EMA FILTER
//====================================================
ema50 = ta.ema(close, emaLen)

plot(ema50, title="EMA50", color=color.orange, linewidth=2)

emaUp = ema50 > ema50[3]
emaDown = ema50 < ema50[3]

//====================================================
// ADX FILTER
//====================================================
[diPlus, diMinus, adx] = ta.dmi(adxLen, adxLen)

adxPass = adx > adxThreshold

bgcolor(adxPass ? na : color.new(color.gray, 92))

//====================================================
// ATR
//====================================================
atrValue = ta.atr(atrLen)

//====================================================
// PIVOT SWINGS
//====================================================
pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivotLow = ta.pivotlow(low, pivotLen, pivotLen)

var float lastSwingHigh = na
var float lastSwingLow = na

lastSwingHigh := not na(pivotHigh) ? pivotHigh : lastSwingHigh
lastSwingLow := not na(pivotLow) ? pivotLow : lastSwingLow

//====================================================
// MSS
//====================================================
bullMSS = not na(lastSwingHigh) and close > lastSwingHigh and close[1] <= lastSwingHigh

bearMSS = not na(lastSwingLow) and close < lastSwingLow and close[1] >= lastSwingLow

//====================================================
// TREND FILTER
//====================================================
buySignal = bullMSS and adxPass and emaUp and close > ema50
sellSignal = bearMSS and adxPass and emaDown and close < ema50

//====================================================
// MSS MARKERS
//====================================================
plotshape(
bullMSS,
title="Bull MSS",
style=shape.circle,
location=location.abovebar,
color=color.green,
size=size.tiny
)

plotshape(
bearMSS,
title="Bear MSS",
style=shape.circle,
location=location.belowbar,
color=color.red,
size=size.tiny
)

//====================================================
// BUY / SELL SIGNALS
//====================================================
plotshape(
buySignal,
title="BUY",
style=shape.arrowup,
location=location.belowbar,
color=color.lime,
size=size.large,
text="BUY"
)

plotshape(
sellSignal,
title="SELL",
style=shape.arrowdown,
location=location.abovebar,
color=color.red,
size=size.large,
text="SELL"
)

//====================================================
// SL / TP
//====================================================
buySL = buySignal ? low - atrBuffer * atrValue : na
buyTP = buySignal ? close + (close - buySL) * rr : na

sellSL = sellSignal ? high + atrBuffer * atrValue : na
sellTP = sellSignal ? close - (sellSL - close) * rr : na

plot(buySL, title="BUY SL", color=color.red, linewidth=2)
plot(buyTP, title="BUY TP", color=color.green, linewidth=2)

plot(sellSL, title="SELL SL", color=color.red, linewidth=2)
plot(sellTP, title="SELL TP", color=color.green, linewidth=2)

//====================================================
// INFO TABLE
//====================================================
var table info = table.new(position.top_right, 2, 4, border_width=1)

if barstate.islast
    table.cell(info, 0, 0, "ADX")
    table.cell(info, 1, 0, str.tostring(math.round(adx * 10) / 10))

    table.cell(info, 0, 1, "EMA")
    table.cell(info, 1, 1, emaUp ? "UP" : emaDown ? "DOWN" : "FLAT")

    table.cell(info, 0, 2, "FILTER")
    table.cell(info, 1, 2, adxPass ? "PASS" : "FAIL")

    table.cell(info, 0, 3, "SIGNAL")
    table.cell(info, 1, 3, buySignal ? "BUY" : sellSignal ? "SELL" : "NONE")

//====================================================
// ALERTS
//====================================================
alertcondition(buySignal, title="BUY SIGNAL", message="BUY MSS + EMA50 + ADX")
alertcondition(sellSignal, title="SELL SIGNAL", message="SELL MSS + EMA50 + ADX")
````
