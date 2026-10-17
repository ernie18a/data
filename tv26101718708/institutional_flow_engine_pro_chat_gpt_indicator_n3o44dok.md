# Institutional Flow Engine PRO Chat GPT Indicator

- url: https://www.tradingview.com/script/n3o44doK-Institutional-Flow-Engine-PRO-Chat-GPT-Indicator/
- type: indicator
- pine_id: PUB;79a34bda7c2c4809a9874e1921d14248
- version: 1.0

## Description

Chat gpt built indicator for proactive trading asdasdasdasdade3rfsdvsdvsdf

## Source Code

````pine
//@version=6
indicator("Institutional Flow Engine PRO", overlay=true, max_labels_count=500, max_boxes_count=500)

//=====================================================
// INPUTS
//=====================================================

showFVG         = input.bool(true, "Show Fair Value Gaps")
showFBD         = input.bool(true, "Show Failed Breakdowns")
showLiquidity   = input.bool(true, "Show Liquidity Sweeps")
showORB         = input.bool(true, "Show Opening Range (15m)")
showPDHL        = input.bool(true, "Show Previous Day High/Low")

rvolThreshold   = input.float(1.5, "RVOL Threshold", step=0.1)

//=====================================================
// EMA SYSTEM
//=====================================================

ema9   = ta.ema(close, 9)
ema20  = ta.ema(close, 20)
ema50  = ta.ema(close, 50)
ema100 = ta.ema(close, 100)

emaSlope = ema9 - ema9[3]

//=====================================================
// EMA PLOTS
//=====================================================

plot(ema9, "9 EMA", color=color.blue, linewidth=3)
plot(ema20, "20 EMA", color=color.yellow, linewidth=2)
plot(ema50, "50 EMA", color=color.orange, linewidth=2)
plot(ema100, "100 EMA", color=color.red, linewidth=2)

//=====================================================
// RVOL
//=====================================================

avgVol = ta.sma(volume, 20)
rvol = avgVol > 0 ? volume / avgVol : 0.0

highRVOL = rvol > rvolThreshold

//=====================================================
// RSI + MACD
//=====================================================

rsi = ta.rsi(close, 14)

[macdLine, signalLine, histLine] = ta.macd(close, 12, 26, 9)

bullMomentum = rsi > 55 and histLine > histLine[1]
bearMomentum = rsi < 45 and histLine < histLine[1]

//=====================================================
// FLOW CONDITIONS
//=====================================================

bullFlow =
     emaSlope > 0 and
     close > ema9 and
     close > open and
     highRVOL and
     bullMomentum

bearFlow =
     emaSlope < 0 and
     close < ema9 and
     close < open and
     highRVOL and
     bearMomentum

//=====================================================
// LONG / SHORT MARKERS
//=====================================================

plotshape(
     bullFlow,
     title="Long Flow",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     text="LONG",
     textcolor=color.white,
     size=size.small)

plotshape(
     bearFlow,
     title="Short Flow",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="SHORT",
     textcolor=color.white,
     size=size.small)

//=====================================================
// FAIR VALUE GAPS
//=====================================================

bullFVG = low > high[2]
bearFVG = high < low[2]

// FVG BOXES
if showFVG and bullFVG
    box.new(
         left=bar_index-2,
         top=low,
         right=bar_index,
         bottom=high[2],
         bgcolor=color.new(color.green, 85),
         border_color=color.green)

if showFVG and bearFVG
    box.new(
         left=bar_index-2,
         top=low[2],
         right=bar_index,
         bottom=high,
         bgcolor=color.new(color.red, 85),
         border_color=color.red)

// FVG MARKERS
plotshape(
     showFVG and bullFVG,
     title="Bull FVG",
     style=shape.square,
     location=location.belowbar,
     color=color.green,
     text="FVG",
     textcolor=color.white,
     size=size.tiny)

plotshape(
     showFVG and bearFVG,
     title="Bear FVG",
     style=shape.square,
     location=location.abovebar,
     color=color.red,
     text="FVG",
     textcolor=color.white,
     size=size.tiny)

//=====================================================
// FAILED BREAKDOWNS / BREAKOUTS
//=====================================================

supportLevel = ta.lowest(low, 10)[1]
resistanceLevel = ta.highest(high, 10)[1]

failedBreakdown =
     low < supportLevel and
     close > supportLevel and
     close > open and
     highRVOL

failedBreakout =
     high > resistanceLevel and
     close < resistanceLevel and
     close < open and
     highRVOL

plotshape(
     showFBD and failedBreakdown,
     title="Failed Breakdown",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.lime,
     text="FBD",
     textcolor=color.black,
     size=size.small)

plotshape(
     showFBD and failedBreakout,
     title="Failed Breakout",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.maroon,
     text="FBO",
     textcolor=color.white,
     size=size.small)

//=====================================================
// LIQUIDITY SWEEPS
//=====================================================

bullSweep =
     low < ta.lowest(low, 5)[1] and
     close > open

bearSweep =
     high > ta.highest(high, 5)[1] and
     close < open

plotshape(
     showLiquidity and bullSweep,
     title="Bull Sweep",
     style=shape.circle,
     location=location.belowbar,
     color=color.aqua,
     text="SWEEP",
     textcolor=color.black,
     size=size.tiny)

plotshape(
     showLiquidity and bearSweep,
     title="Bear Sweep",
     style=shape.circle,
     location=location.abovebar,
     color=color.purple,
     text="SWEEP",
     textcolor=color.white,
     size=size.tiny)

//=====================================================
// PREVIOUS DAY HIGH / LOW
//=====================================================

pdHigh = request.security(syminfo.tickerid, "D", high[1])
pdLow  = request.security(syminfo.tickerid, "D", low[1])

plot(
     showPDHL ? pdHigh : na,
     title="Previous Day High",
     color=color.green,
     linewidth=2,
     style=plot.style_linebr)

plot(
     showPDHL ? pdLow : na,
     title="Previous Day Low",
     color=color.red,
     linewidth=2,
     style=plot.style_linebr)

//=====================================================
// ORB (OPENING RANGE BREAKOUT)
//=====================================================

newDay = ta.change(time("D")) != 0

var float orbHigh = na
var float orbLow = na
var int orbStartTime = na

if newDay
    orbHigh := na
    orbLow := na
    orbStartTime := time

orbActive =
     not na(orbStartTime) and
     time < orbStartTime + (15 * 60 * 1000)

if orbActive
    orbHigh := na(orbHigh) ? high : math.max(orbHigh, high)
    orbLow := na(orbLow) ? low : math.min(orbLow, low)

plot(
     showORB and not na(orbHigh) ? orbHigh : na,
     title="ORB High",
     color=color.white,
     linewidth=2)

plot(
     showORB and not na(orbLow) ? orbLow : na,
     title="ORB Low",
     color=color.white,
     linewidth=2)

//=====================================================
// BACKGROUND TREND COLOR
//=====================================================

bgcolor(
     bullFlow ? color.new(color.green, 92) :
     bearFlow ? color.new(color.red, 92) :
     na)

//=====================================================
// ALERT CONDITIONS
//=====================================================

alertcondition(
     bullFlow,
     title="Bullish Long Flow",
     message="Bullish Long Flow Detected")

alertcondition(
     bearFlow,
     title="Bearish Short Flow",
     message="Bearish Short Flow Detected")

alertcondition(
     failedBreakdown,
     title="Failed Breakdown",
     message="Failed Breakdown Detected")

alertcondition(
     failedBreakout,
     title="Failed Breakout",
     message="Failed Breakout Detected")

alertcondition(
     bullFVG,
     title="Bullish FVG",
     message="Bullish Fair Value Gap Detected")

alertcondition(
     bearFVG,
     title="Bearish FVG",
     message="Bearish Fair Value Gap Detected")
````
