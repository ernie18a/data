# TheBarneyBag

- url: https://www.tradingview.com/script/B4SOgscP-TheBarneyBag/
- type: indicator
- pine_id: PUB;ba743a6f63884065a7403e314b78eec6
- version: 1.0

## Description

Covering al the basic 
9,21,50,200 ema
50,200 sma
Bollinger bands
VWAP

## Source Code

````pine
//@version=6
indicator("TheBarneyBag", overlay=true, max_lines_count=500)

//====================================================
// INPUTS
//====================================================

//====================================================
// VWAP SETTINGS
//====================================================

groupVWAP = "VWAP"

showVWAP = input.bool(true, "Show VWAP", group=groupVWAP)

showVWAPBands = input.bool(true, "Show VWAP Bands", group=groupVWAP)

vwapSource = input.source(hlc3, "VWAP Source", group=groupVWAP)

bandMode = input.string(
     "Standard Deviation",
     "Band Calculation",
     options = ["Standard Deviation", "Percentage"],
     group=groupVWAP
)

showBand1 = input.bool(true, "Show Band 1", group=groupVWAP)
showBand2 = input.bool(true, "Show Band 2", group=groupVWAP)
showBand3 = input.bool(false, "Show Band 3", group=groupVWAP)

band1Mult = input.float(1.0, "Band 1 Multiplier", step=0.1, group=groupVWAP)
band2Mult = input.float(2.0, "Band 2 Multiplier", step=0.1, group=groupVWAP)
band3Mult = input.float(3.0, "Band 3 Multiplier", step=0.1, group=groupVWAP)

//====================================================
// BOLLINGER BAND SETTINGS
//====================================================

groupBB = "Bollinger Bands"

showBB = input.bool(true, "Show Bollinger Bands", group=groupBB)

bbLength = input.int(20, "Length", minval=1, group=groupBB)

bbMult = input.float(2.0, "Std Dev", step=0.1, group=groupBB)

bbSource = input.source(close, "Source", group=groupBB)

//====================================================
// EMA SETTINGS
//====================================================

groupEMA = "EMAs"

showEMA9 = input.bool(true, "EMA 9", group=groupEMA)

showEMA21 = input.bool(true, "EMA 21", group=groupEMA)

showEMA50 = input.bool(true, "EMA 50", group=groupEMA)

showEMA200 = input.bool(true, "EMA 200", group=groupEMA)

//====================================================
// SMA SETTINGS
//====================================================

groupSMA = "SMAs"

showSMA50 = input.bool(true, "SMA 50", group=groupSMA)

showSMA200 = input.bool(true, "SMA 200", group=groupSMA)

//====================================================
// ORB SETTINGS
//====================================================

groupORB = "Opening Range Breakout"

showORB = input.bool(true, "Show ORB", group=groupORB)

orbSession = input.session("0930-1000", "ORB Window", group=groupORB)

showORBFill = input.bool(true, "Fill ORB Range", group=groupORB)

//====================================================
// VWAP SESSION ANCHOR
//====================================================

isNewPeriod = timeframe.change("D")

//====================================================
// VWAP CALCULATIONS
//====================================================

[vwapValue, upperReference, _] = ta.vwap(vwapSource, isNewPeriod, 1)

stdev = upperReference - vwapValue

bandBasis =
     bandMode == "Standard Deviation"
     ? stdev
     : vwapValue * 0.01

upperBand1 = vwapValue + bandBasis * band1Mult
lowerBand1 = vwapValue - bandBasis * band1Mult

upperBand2 = vwapValue + bandBasis * band2Mult
lowerBand2 = vwapValue - bandBasis * band2Mult

upperBand3 = vwapValue + bandBasis * band3Mult
lowerBand3 = vwapValue - bandBasis * band3Mult

//====================================================
// VWAP PLOTS
//====================================================

plot(
     showVWAP ? vwapValue : na,
     title="VWAP",
     color=color.purple,
     linewidth=2
)

u1 = plot(
     showVWAPBands and showBand1 ? upperBand1 : na,
     title="VWAP Upper 1",
     color=color.blue
)

l1 = plot(
     showVWAPBands and showBand1 ? lowerBand1 : na,
     title="VWAP Lower 1",
     color=color.blue
)

u2 = plot(
     showVWAPBands and showBand2 ? upperBand2 : na,
     title="VWAP Upper 2",
     color=color.aqua
)

l2 = plot(
     showVWAPBands and showBand2 ? lowerBand2 : na,
     title="VWAP Lower 2",
     color=color.aqua
)

u3 = plot(
     showVWAPBands and showBand3 ? upperBand3 : na,
     title="VWAP Upper 3",
     color=color.navy
)

l3 = plot(
     showVWAPBands and showBand3 ? lowerBand3 : na,
     title="VWAP Lower 3",
     color=color.navy
)

fill(u1, l1, color=color.new(color.blue, 92))
fill(u2, l2, color=color.new(color.aqua, 94))
fill(u3, l3, color=color.new(color.navy, 96))

//====================================================
// BOLLINGER BANDS
//====================================================

bbBasis = ta.sma(bbSource, bbLength)

bbDev = bbMult * ta.stdev(bbSource, bbLength)

bbUpper = bbBasis + bbDev

bbLower = bbBasis - bbDev

bbBasisPlot = plot(
     showBB ? bbBasis : na,
     title="BB Basis",
     color=color.yellow
)

bbUpperPlot = plot(
     showBB ? bbUpper : na,
     title="BB Upper",
     color=color.orange
)

bbLowerPlot = plot(
     showBB ? bbLower : na,
     title="BB Lower",
     color=color.orange
)

fill(
     bbUpperPlot,
     bbLowerPlot,
     color=color.new(color.orange, 92)
)

//====================================================
// EMA CALCULATIONS
//====================================================

plot(showEMA9 ? ta.ema(close, 9) : na, "EMA 9", color=color.aqua, linewidth=2)

plot(showEMA21 ? ta.ema(close, 21) : na, "EMA 21", color=color.orange, linewidth=2)

plot(showEMA50 ? ta.ema(close, 50) : na, "EMA 50", color=color.green, linewidth=2)

plot(showEMA200 ? ta.ema(close, 200) : na, "EMA 200", color=color.red, linewidth=3)

//====================================================
// SMA CALCULATIONS
//====================================================

plot(showSMA50 ? ta.sma(close, 50) : na, "SMA 50", color=color.teal, linewidth=3)

plot(showSMA200 ? ta.sma(close, 200) : na, "SMA 200", color=color.maroon, linewidth=4)

//====================================================
// ORB LOGIC
//====================================================

inORB = not na(time(timeframe.period, orbSession))

newORBSession = inORB and not inORB[1]

var float orbHigh = na
var float orbLow = na

if newORBSession
    orbHigh := high
    orbLow := low

if inORB
    orbHigh := math.max(orbHigh, high)
    orbLow := math.min(orbLow, low)

//====================================================
// ORB PLOTS
//====================================================

orbHighPlot = plot(
     showORB and not inORB ? orbHigh : na,
     title="ORB High",
     color=color.lime,
     linewidth=2,
     style=plot.style_linebr
)

orbLowPlot = plot(
     showORB and not inORB ? orbLow : na,
     title="ORB Low",
     color=color.red,
     linewidth=2,
     style=plot.style_linebr
)

fill(
     orbHighPlot,
     orbLowPlot,
     color=showORBFill ? color.new(color.gray, 92) : na
)

//====================================================
// TREND BACKGROUND
//====================================================

bullTrend =
     ta.ema(close, 9) >
     ta.ema(close, 21) and
     ta.ema(close, 21) >
     ta.ema(close, 50)

bearTrend =
     ta.ema(close, 9) <
     ta.ema(close, 21) and
     ta.ema(close, 21) <
     ta.ema(close, 50)

bgcolor(bullTrend ? color.new(color.green, 97) : na)

bgcolor(bearTrend ? color.new(color.red, 97) : na)
````
