# Mauloa Ventures Clean Setup

- url: https://www.tradingview.com/script/MxX6CztU-Mauloa-Ventures-Clean-Setup/
- type: indicator
- pine_id: PUB;aacaac4389e3415eba388b244bdfe2d2
- version: 1.0

## Description

✅ 5m / 1H / Daily 200 EMA
✅ EMA plotted as circles
✅ EMA only shows over the last 50 candles
✅ ORB high + low
✅ Light blue session open line

## Source Code

````pine
//@version=5
indicator("Mauloa Ventures Clean Setup", overlay=true, max_labels_count=500)

//----------------------------------------------------
// INPUTS
//----------------------------------------------------

// MTF 200 EMA
groupEMA = "MTF 200 EMA"
color5m = input.color(color.blue, "5m 200 EMA", group=groupEMA)
color1h = input.color(color.orange, "1H 200 EMA", group=groupEMA)
color1D = input.color(color.green, "Daily 200 EMA", group=groupEMA)
circleSize = input.int(2, "Circle Size", minval=1, maxval=5, group=groupEMA)
barsBack = input.int(50, "Show EMA Last Candles", minval=1, group=groupEMA)

// ORB
groupORB = "Opening Range Breakout"
showORB = input.bool(true, "Show ORB", group=groupORB)
orbSession = input.session("0930-0945", "ORB Session", group=groupORB)
orbMaxTF = input.int(15, "Show ORB On TF <= Minutes", minval=1, group=groupORB)
orbHighColor = input.color(color.green, "ORB High", group=groupORB)
orbLowColor = input.color(color.red, "ORB Low", group=groupORB)
orbWidth = input.int(2, "ORB Width", minval=1, maxval=5, group=groupORB)

// Session Open
groupOpen = "Session Open"
showOpen = input.bool(true, "Show Open Line", group=groupOpen)
openColor = input.color(color.aqua, "Open Line Color", group=groupOpen)
openWidth = input.int(2, "Open Width", minval=1, maxval=5, group=groupOpen)

//----------------------------------------------------
// MTF 200 EMA - LAST 50 CANDLES ONLY
//----------------------------------------------------
ema5m = request.security(syminfo.tickerid, "5", ta.ema(close, 200))
ema1h = request.security(syminfo.tickerid, "60", ta.ema(close, 200))
ema1D = request.security(syminfo.tickerid, "D", ta.ema(close, 200))

var int lastBar = na

if barstate.islast
    lastBar := bar_index

showRecent = not na(lastBar) and bar_index >= lastBar - barsBack

plot(showRecent ? ema5m : na, "5m 200 EMA", color=color5m, style=plot.style_circles, linewidth=circleSize)
plot(showRecent ? ema1h : na, "1H 200 EMA", color=color1h, style=plot.style_circles, linewidth=circleSize)
plot(showRecent ? ema1D : na, "Daily 200 EMA", color=color1D, style=plot.style_circles, linewidth=circleSize)

//----------------------------------------------------
// ORB HIGH / LOW
//----------------------------------------------------
orbTime = time(timeframe.period, orbSession + ":1234567")
inORB = not na(orbTime)
firstORBBar = inORB and not inORB[1]

var float orbHigh = na
var float orbLow = na

if firstORBBar
    orbHigh := high
    orbLow := low
else if inORB
    orbHigh := math.max(orbHigh, high)
    orbLow := math.min(orbLow, low)

showORBFinal = showORB and timeframe.isintraday and timeframe.multiplier <= orbMaxTF

plot(showORBFinal ? orbHigh : na, "ORB High", color=orbHighColor, linewidth=orbWidth)
plot(showORBFinal ? orbLow : na, "ORB Low", color=orbLowColor, linewidth=orbWidth)

//----------------------------------------------------
// SESSION OPEN LINE
//----------------------------------------------------
openTime = time(timeframe.period, "0930-0931:1234567")
newOpen = not na(openTime) and na(openTime[1])

var float sessionOpen = na

if newOpen
    sessionOpen := open

plot(showOpen ? sessionOpen : na, "Session Open", color=openColor, linewidth=openWidth)
````
