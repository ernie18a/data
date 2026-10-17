# 15m Futures Zones + 21 EMA Signals

- url: https://www.tradingview.com/script/7J4LCevh-15m-Futures-Zones-21-EMA-Signals/
- type: indicator
- pine_id: PUB;3276593cb69d4edf8306dd15f215443e
- version: 1.0

## Description

21 EMA for trend direction
Demand zones where buyers may step in
Supply zones where sellers may step in
Support/resistance lines
BUY signs when price reacts from demand/support while above a rising 21 EMA
SELL signs when price reacts from supply/resistance while below a falling 21 EMA

## Source Code

````pine
//@version=6
indicator("15m Futures Zones + 21 EMA Signals", shorttitle="15m Zones EMA", overlay=true, max_boxes_count=60, max_labels_count=500)
// This indicator marks recent supply/demand zones and support/resistance zones,
// then gives buy/sell signs when price reacts with the 21 EMA trend bias.
groupEma = "EMA Trend"
emaLen = input.int(21, "EMA Length", minval=1, group=groupEma)
showEmaSlopeColor = input.bool(true, "Color EMA By Direction", group=groupEma)
groupZones = "Zones"
pivotLen = input.int(5, "Zone Pivot Strength", minval=2, maxval=20, group=groupZones)
zoneAtrLen = input.int(14, "Zone ATR Length", minval=1, group=groupZones)
zoneAtrMult = input.float(0.45, "Zone Thickness ATR Multiple", minval=0.05, step=0.05, group=groupZones)
maxZones = input.int(8, "Zones To Keep", minval=1, maxval=20, group=groupZones)
extendZones = input.bool(true, "Extend Zones Right", group=groupZones)
showSupplyDemand = input.bool(true, "Show Supply/Demand Zones", group=groupZones)
showSupportResistance = input.bool(true, "Show Support/Resistance Lines", group=groupZones)
groupSignals = "Buy/Sell Signals"
useCandleConfirmation = input.bool(true, "Require Strong Candle Close", group=groupSignals)
useEmaRetest = input.bool(true, "Require EMA Bias", group=groupSignals)
signalCooldown = input.int(5, "Minimum Bars Between Signals", minval=0, maxval=50, group=groupSignals)
groupTargets = "Projected Direction"
showTargets = input.bool(true, "Show Typical Next Target", group=groupTargets)
riskAtrMult = input.float(1.0, "Stop Buffer ATR Multiple", minval=0.1, step=0.1, group=groupTargets)
ema21 = ta.ema(close, emaLen)
atr = ta.atr(zoneAtrLen)
zoneSize = atr * zoneAtrMult
emaUp = ema21 > ema21[1]
emaDown = ema21 < ema21[1]
emaColor = showEmaSlopeColor ? emaUp ? color.lime : emaDown ? color.red : color.gray : color.yellow
plot(ema21, "21 EMA", color=emaColor, linewidth=2)
pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivotLow = ta.pivotlow(low, pivotLen, pivotLen)
var array<box> supplyZones = array.new<box>()
var array<box> demandZones = array.new<box>()
var array<line> resistanceLines = array.new<line>()
var array<line> supportLines = array.new<line>()
makeZone(float top, float bottom, color zoneColor) =>
    box.new(
         left=bar_index - pivotLen,
         top=top,
         right=bar_index,
         bottom=bottom,
         bgcolor=showSupplyDemand ? color.new(zoneColor, 84) : color.new(zoneColor, 100),
         border_color=showSupplyDemand ? color.new(zoneColor, 35) : color.new(zoneColor, 100),
         extend=extendZones ? extend.right : extend.none)
makeLevel(float level, color levelColor) =>
    line.new(
         x1=bar_index - pivotLen,
         y1=level,
         x2=bar_index,
         y2=level,
         color=showSupportResistance ? color.new(levelColor, 25) : color.new(levelColor, 100),
         width=1,
         extend=extendZones ? extend.right : extend.none)
if not na(pivotHigh)
    newSupply = makeZone(pivotHigh, pivotHigh - zoneSize[pivotLen], color.red)
    array.push(supplyZones, newSupply)
    newResistance = makeLevel(pivotHigh, color.red)
    array.push(resistanceLines, newResistance)
    if array.size(supplyZones) > maxZones
        box.delete(array.shift(supplyZones))
    if array.size(resistanceLines) > maxZones
        line.delete(array.shift(resistanceLines))
if not na(pivotLow)
    newDemand = makeZone(pivotLow + zoneSize[pivotLen], pivotLow, color.lime)
    array.push(demandZones, newDemand)
    newSupport = makeLevel(pivotLow, color.lime)
    array.push(supportLines, newSupport)
    if array.size(demandZones) > maxZones
        box.delete(array.shift(demandZones))
    if array.size(supportLines) > maxZones
        line.delete(array.shift(supportLines))
inDemandZone() =>
    bool found = false
    if array.size(demandZones) > 0
        for i = 0 to array.size(demandZones) - 1
            dz = array.get(demandZones, i)
            found := found or (low <= box.get_top(dz) and close >= box.get_bottom(dz))
    found
inSupplyZone() =>
    bool found = false
    if array.size(supplyZones) > 0
        for i = 0 to array.size(supplyZones) - 1
            sz = array.get(supplyZones, i)
            found := found or (high >= box.get_bottom(sz) and close <= box.get_top(sz))
    found
````
