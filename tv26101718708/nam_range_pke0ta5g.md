# NAM RANGE

- url: https://www.tradingview.com/script/pKE0Ta5G/
- type: indicator
- pine_id: PUB;9eb53b9b58454abfb957b8af01380bed
- version: 1.0

## Description

chi bao nay minh lam ra de cho cac trader moi su dung mien phi de giup kiem tien on dinh hon ko alli in hay trai nghiem va backtest nhieu hon

## Source Code

````pine
//@version=5
indicator("Range Filter Pro Trend", overlay=true, max_lines_count=500)

// ==== INPUT ====
rfPeriod = input.int(50, "Range Period")
rfMult   = input.float(3.0, "Range Multiplier")
emaLen   = input.int(200, "EMA Length")
adxLen   = input.int(14, "ADX Length")
atrLen   = input.int(14, "ATR Length")
slATR    = input.float(1.5, "SL ATR Multiplier")
tpATR    = input.float(3.0, "TP ATR Multiplier")

// ==== EMA TREND ====
ema200 = ta.ema(close, emaLen)
plot(ema200, color=color.orange, linewidth=2)

// ==== RANGE FILTER ====
src = close

smoothRange = ta.ema(math.abs(src - src[1]), rfPeriod) * rfMult

var float rf = na

rf := na(rf[1]) ? src :
     src > rf[1] ?
     math.max(rf[1], src - smoothRange) :
     math.min(rf[1], src + smoothRange)

plot(rf, color=color.aqua, linewidth=2)

// ==== ADX ====
upMove   = high - high[1]
downMove = low[1] - low

plusDM  = upMove > downMove and upMove > 0 ? upMove : 0
minusDM = downMove > upMove and downMove > 0 ? downMove : 0

trur = ta.rma(ta.tr, adxLen)

plusDI  = 100 * ta.rma(plusDM, adxLen) / trur
minusDI = 100 * ta.rma(minusDM, adxLen) / trur

dx  = 100 * math.abs(plusDI - minusDI) / (plusDI + minusDI)
adx = ta.rma(dx, adxLen)

// ==== ATR ====
atr = ta.atr(atrLen)

// ==== SIGNALS ====
buySignal =
 close > rf and
 close > ema200 and
 adx > 25 and
 close[1] <= rf[1]

sellSignal =
 close < rf and
 close < ema200 and
 adx > 25 and
 close[1] >= rf[1]

// ==== ENTRY - TP - SL ====
longSL = close - atr * slATR
longTP = close + atr * tpATR

shortSL = close + atr * slATR
shortTP = close - atr * tpATR

// ==== PLOTS ====
plotshape(buySignal,
     title="BUY",
     location=location.belowbar,
     style=shape.labelup,
     color=color.lime,
     text="BUY")

plotshape(sellSignal,
     title="SELL",
     location=location.abovebar,
     style=shape.labeldown,
     color=color.red,
     text="SELL")

if buySignal
    line.new(bar_index, longSL, bar_index + 20, longSL,
         color=color.red)
    line.new(bar_index, longTP, bar_index + 20, longTP,
         color=color.green)

if sellSignal
    line.new(bar_index, shortSL, bar_index + 20, shortSL,
         color=color.red)
    line.new(bar_index, shortTP, bar_index + 20, shortTP,
         color=color.green)

// ==== ALERT ====
alertcondition(buySignal, "BUY ALERT", "BUY SIGNAL")
alertcondition(sellSignal, "SELL ALERT", "SELL SIGNAL")

bgcolor(close > ema200 ? color.new(color.green,95)
                       : color.new(color.red,95))
````
