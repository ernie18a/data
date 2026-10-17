# Dobos Richard m15 1:3  

- url: https://www.tradingview.com/script/0O1TW0pH-Dobos-Richard-m15-1-3/
- type: indicator
- pine_id: PUB;eba6d657efae45b4bef1c4996f06f16d
- version: 1.0

## Description

M15 alapján ad csak jelet , kiütött demand illetve supply zóna után.

## Source Code

````pine
//@version=6
indicator("Zone to Zone Trader M15", overlay=true, max_lines_count=200, max_labels_count=200)

swingLen = input.int(5, "Swing Length", minval=2)
atr = ta.atr(14)
isM15 = timeframe.period == "15"

swingHigh = ta.pivothigh(high, swingLen, swingLen)
swingLow = ta.pivotlow(low, swingLen, swingLen)

demandTop = ta.valuewhen(not na(swingLow), math.min(open[swingLen], close[swingLen]), 0)
demandBot = ta.valuewhen(not na(swingLow), swingLow, 0)
supplyTop = ta.valuewhen(not na(swingHigh), swingHigh, 0)
supplyBot = ta.valuewhen(not na(swingHigh), math.max(open[swingLen], close[swingLen]), 0)

lowest10 = ta.lowest(low[1], 10)
highest10 = ta.highest(high[1], 10)

breakoutUp = high > highest10
breakoutDown = low < lowest10

buySLLevel = lowest10 - atr * 0.1
sellSLLevel = highest10 + atr * 0.1
demandZoneSize = demandTop - demandBot
supplyZoneSize = supplyTop - supplyBot
validDemandSize = demandZoneSize < atr * 2.0 and demandZoneSize > atr * 0.1
validSupplySize = supplyZoneSize < atr * 2.0 and supplyZoneSize > atr * 0.1

strongDemandCandle = ta.valuewhen(not na(swingLow), math.abs(close[swingLen] - open[swingLen]) / math.max(high[swingLen] - low[swingLen], 0.00001), 0) > 0.5
strongSupplyCandle = ta.valuewhen(not na(swingHigh), math.abs(close[swingLen] - open[swingLen]) / math.max(high[swingLen] - low[swingLen], 0.00001), 0) > 0.5

demandTouchBar = float(low <= demandTop and high >= demandBot ? 1 : 0)
supplyTouchBar = float(high >= supplyBot and low <= supplyTop ? 1 : 0)
demandTouches = math.sum(demandTouchBar, 20)
supplyTouches = math.sum(supplyTouchBar, 20)
freshDemand = demandTouches <= 2
freshSupply = supplyTouches <= 2

rsi = ta.rsi(close, 14)
rsiBuyOk = rsi < 65
rsiSellOk = rsi > 35

ema50 = ta.ema(close, 50)
trendUp = close > ema50
trendDown = close < ema50

strongDemand = validDemandSize and strongDemandCandle and freshDemand and rsiBuyOk
strongSupply = validSupplySize and strongSupplyCandle and freshSupply and rsiSellOk

var string activePos = "none"
var float posEntry = na
var float posSL = na
var float posTP = na

newBuy = isM15 and activePos == "none" and close >= demandBot and close <= demandTop and breakoutUp and strongDemand and trendUp
newSell = isM15 and activePos == "none" and close <= supplyTop and close >= supplyBot and breakoutDown and strongSupply and trendDown

closeBuy = activePos == "buy" and (low <= posSL or high >= posTP)
closeSell = activePos == "sell" and (high >= posSL or low <= posTP)

buyTP = close + (close - buySLLevel) * 3
sellTP = close - (sellSLLevel - close) * 3

activePos := closeBuy or closeSell ? "none" : newBuy ? "buy" : newSell ? "sell" : activePos
posEntry := closeBuy or closeSell ? na : newBuy ? close : newSell ? close : posEntry
posSL := closeBuy or closeSell ? na : newBuy ? buySLLevel : newSell ? sellSLLevel : posSL
posTP := closeBuy or closeSell ? na : newBuy ? buyTP : newSell ? sellTP : posTP

plot(activePos == "buy" ? posEntry : na, "BUY Entry", color=color.white, linewidth=2, style=plot.style_linebr)
plot(activePos == "buy" ? posSL : na, "BUY SL", color=color.red, linewidth=2, style=plot.style_linebr)
plot(activePos == "buy" ? posTP : na, "BUY TP", color=color.lime, linewidth=2, style=plot.style_linebr)
plot(activePos == "sell" ? posEntry : na, "SELL Entry", color=color.yellow, linewidth=2, style=plot.style_linebr)
plot(activePos == "sell" ? posSL : na, "SELL SL", color=color.red, linewidth=2, style=plot.style_linebr)
plot(activePos == "sell" ? posTP : na, "SELL TP", color=color.lime, linewidth=2, style=plot.style_linebr)

buyTxt = "BUY E:" + str.tostring(math.round(close, 5)) + " SL:" + str.tostring(math.round(buySLLevel, 5)) + " TP:" + str.tostring(math.round(buyTP, 5))
sellTxt = "SELL E:" + str.tostring(math.round(close, 5)) + " SL:" + str.tostring(math.round(sellSLLevel, 5)) + " TP:" + str.tostring(math.round(sellTP, 5))

label.new(newBuy ? bar_index : na, newBuy ? close - atr * 0.3 : na, buyTxt, color=color.lime, textcolor=color.black, style=label.style_label_up, size=size.tiny)
label.new(newSell ? bar_index : na, newSell ? close + atr * 0.3 : na, sellTxt, color=color.red, textcolor=color.white, style=label.style_label_down, size=size.tiny)

alertcondition(newBuy, title="BUY", message="BUY pozicio nyitva!")
alertcondition(newSell, title="SELL", message="SELL pozicio nyitva!")
````
