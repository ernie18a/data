# CE + CLRDMA + EMA System JW

- url: https://www.tradingview.com/script/374Ucgz3-CE-CLRDMA-EMA-System-JW/
- type: indicator
- pine_id: PUB;373b25eb2b1941b7881978ceef049156
- version: 1.0

## Description

Using Josh W safe trade strategy to create movement points and entry with stop and loss indicators.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © dheron85

//@version=5
indicator("CE + CLRDMA + EMA System JW", overlay=true, max_lines_count=50, max_labels_count=50)

emaLen = input.int(200, "EMA Length")
atrPeriod = input.int(10, "ATR Period")
atrMult = input.float(4.0, "ATR Multiplier")
tickBuffer = input.float(2.5, "Tick Buffer (points)")
boxLen = input.int(10, "Box Width (bars)")
riskDollars = input.float(300, "Risk Per Trade ($)")
tp2Dollars = input.float(210, "TP2 Profit Target ($)")
pointValue = input.float(2.0, "Point Value ($) - MNQ=2")

ema200_1m = ta.ema(close, emaLen)
ema200_5m = request.security(syminfo.tickerid, "5", ta.ema(close, emaLen))

plot(ema200_1m, "EMA 200 1m", color=color.purple, linewidth=2)
plot(ema200_5m, "EMA 200 5m", color=color.white, linewidth=2)

atr = ta.atr(atrPeriod)
highestHigh = ta.highest(high, atrPeriod)
lowestLow = ta.lowest(low, atrPeriod)
longStop = highestHigh - atrMult * atr
shortStop = lowestLow + atrMult * atr

var float longStopPrev = na
var float shortStopPrev = na
longStopPrev := nz(longStop[1], longStop)
shortStopPrev := nz(shortStop[1], shortStop)
longStop := close[1] > longStopPrev ? math.max(longStop, longStopPrev) : longStop
shortStop := close[1] < shortStopPrev ? math.min(shortStop, shortStopPrev) : shortStop

var int dir = 1
dir := close > shortStopPrev ? 1 : close < longStopPrev ? -1 : dir

buySignal = dir == 1 and dir[1] == -1
sellSignal = dir == -1 and dir[1] == 1

emaAbove = ema200_1m > ema200_5m
emaBelow = ema200_1m < ema200_5m
emaCrossUp = ta.crossover(ema200_1m, ema200_5m)
emaCrossDown = ta.crossunder(ema200_1m, ema200_5m)
priceCrossAbove = ta.crossover(close, ema200_1m)
priceCrossBelow = ta.crossunder(close, ema200_1m)

filteredBuy = (buySignal and emaAbove and close > ema200_1m) or (emaCrossUp and dir == 1 and close > ema200_1m) or (priceCrossAbove and dir == 1 and emaAbove)
filteredSell = (sellSignal and emaBelow and close < ema200_1m) or (emaCrossDown and dir == -1 and close < ema200_1m) or (priceCrossBelow and dir == -1 and emaBelow)

ceStop = dir == 1 ? longStop : shortStop
plot(ceStop, "CE Stop", color=dir == 1 ? color.green : color.red, linewidth=2)

plotshape(filteredBuy, "Buy", shape.labelup, location.belowbar, color.green, text="BUY", textcolor=color.white, size=size.small)
plotshape(filteredSell, "Sell", shape.labeldown, location.abovebar, color.red, text="SELL", textcolor=color.white, size=size.small)

barcolor(dir == 1 ? color.blue : color.red)
bgcolor(close > ema200_1m ? color.new(color.blue, 75) : color.new(color.red, 75))

var float segmentHigh = na
var float segmentLow = na
var float savedHigh = na
var float savedLow = na

segmentHigh := buySignal or sellSignal ? high : math.max(nz(segmentHigh, high), high)
segmentLow := buySignal or sellSignal ? low : math.min(nz(segmentLow, low), low)
savedHigh := sellSignal ? segmentHigh[1] : nz(savedHigh)
savedLow := buySignal ? segmentLow[1] : nz(savedLow)

var float buyEP = na
var float buySP = na
var float buyTP = na
var float sellEP = na
var float sellSP = na
var float sellTP = na

buyEP := filteredBuy[1] ? open : nz(buyEP)
buySP := filteredBuy[1] ? savedLow[1] - tickBuffer : nz(buySP)
buyTP := filteredBuy[1] ? buyEP + (buyEP - buySP) : nz(buyTP)
sellEP := filteredSell[1] ? open : nz(sellEP)
sellSP := filteredSell[1] ? savedHigh[1] + tickBuffer : nz(sellSP)
sellTP := filteredSell[1] ? sellEP - (sellSP - sellEP) : nz(sellTP)

var line entryLine = na
var line stopLine = na
var line targetLine = na
var line tp2Line = na
var label entryLbl = na
var label stopLbl = na
var label targetLbl = na
var label tp2Lbl = na
var label contractLbl = na

if filteredBuy[1] or filteredSell[1]
    line.delete(entryLine)
    line.delete(stopLine)
    line.delete(targetLine)
    line.delete(tp2Line)
    label.delete(entryLbl)
    label.delete(stopLbl)
    label.delete(targetLbl)
    label.delete(tp2Lbl)
    label.delete(contractLbl)
    ep = filteredBuy[1] ? buyEP : sellEP
    sp = filteredBuy[1] ? buySP : sellSP
    tp = filteredBuy[1] ? buyTP : sellTP
    riskPts = math.abs(ep - sp)
    contracts = math.ceil(riskDollars / (riskPts * pointValue))
    tp2Pts = tp2Dollars / (contracts * pointValue)
    tp2 = filteredBuy[1] ? ep + tp2Pts : ep - tp2Pts
    offset = atr * 0.3
    entryLine := line.new(bar_index, ep, bar_index + boxLen, ep, color=color.white, width=1, style=line.style_dashed)
    stopLine := line.new(bar_index, sp, bar_index + boxLen, sp, color=color.red, width=1)
    targetLine := line.new(bar_index, tp, bar_index + boxLen, tp, color=color.green, width=1)
    tp2Line := line.new(bar_index, tp2, bar_index + boxLen, tp2, color=color.yellow, width=1, style=line.style_dashed)
    entryLbl := label.new(bar_index + boxLen, ep, "ENTRY: " + str.tostring(ep, "#.##"), color=color.gray, textcolor=color.white, style=label.style_label_left, size=size.small)
    stopLbl := label.new(bar_index + boxLen, sp, "STOP: " + str.tostring(sp, "#.##"), color=color.red, textcolor=color.white, style=label.style_label_left, size=size.small)
    targetLbl := label.new(bar_index + boxLen, tp, "TP1: " + str.tostring(tp, "#.##"), color=color.green, textcolor=color.white, style=label.style_label_left, size=size.small)
    tp2Lbl := label.new(bar_index + boxLen, tp2, "TP2 $" + str.tostring(tp2Dollars, "#") + ": " + str.tostring(tp2, "#.##"), color=color.yellow, textcolor=color.black, style=label.style_label_left, size=size.small)
    contractLbl := label.new(bar_index + boxLen, filteredBuy[1] ? sp - offset : sp + offset, "CONTRACTS: " + str.tostring(contracts) + "  |  RISK: $" + str.tostring(riskDollars, "#") + "  |  " + str.tostring(riskPts, "#.##") + "pts", color=color.orange, textcolor=color.white, style=label.style_label_left, size=size.small)
````
