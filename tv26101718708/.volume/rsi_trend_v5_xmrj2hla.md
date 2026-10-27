# RSI Trend v5

- url: https://www.tradingview.com/script/xMrj2hLA-RSI-Trend-v5/
- type: indicator
- pine_id: PUB;8e3ceafbf53b499e956e40811a1eeae5
- version: 1.0

## Description

Put this RSI Indicator set to 1 Minute time frame and a copy of this RSI Indicator set to 5 minute time frame on the same pane. 

Indicator colors the pane a shade of green (input; opacity, color) shading when:
5M RSI is above its Moving Average 
and
1M RSI is above its Moving Average


Indicator colors the pane a shade of red (input; opacity, color) shading when:
5M RSI is below its Moving Average 
and
1M RSI is below its Moving Average

## Source Code

````pine
//@version=6
indicator(title="RSI Trend", shorttitle="RSI Trend", format=format.price, precision=2, timeframe="", timeframe_gaps=true)

// =====================
// RSI Settings
// =====================
rsiLengthInput = input.int(14, minval=1, title="RSI Length", group="RSI Settings")
rsiSourceInput = input.source(close, "Source", group="RSI Settings")
calculateDivergence = input.bool(false, title="Calculate Divergence", group="RSI Settings", display = display.none, tooltip = "Calculating divergences is needed in order for divergence alerts to fire.")

// =====================
// Multi-Timeframe RSI Calculation
// =====================
rsiLengthInput1M = input.int(14, minval=1, title="1M RSI Length", group="Multi-Timeframe RSI")
rsiLengthInput5M = input.int(14, minval=1, title="5M RSI Length", group="Multi-Timeframe RSI")

// Calculate RSI for current timeframe
changeTF = ta.change(rsiSourceInput)
upTF = ta.rma(math.max(changeTF, 0), rsiLengthInput)
downTF = ta.rma(-math.min(changeTF, 0), rsiLengthInput)
rsiTF = downTF == 0 ? 100 : upTF == 0 ? 0 : 100 - (100 / (1 + upTF / downTF))

// Calculate RSI for 1M timeframe
rsi1M = request.security(syminfo.tickerid, "1", rsiTF, lookahead = barmerge.lookahead_off)

// Calculate RSI for 5M timeframe
rsi5M = request.security(syminfo.tickerid, "5", rsiTF, lookahead = barmerge.lookahead_off)

// =====================
// Moving Average Types for Multi-Timeframe
// =====================
maType1M = input.string("SMA", "1M MA Type", options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group = "Multi-Timeframe RSI", display = display.none)
maLength1M = input.int(14, "1M MA Length", group = "Multi-Timeframe RSI", display = display.none)
maType5M = input.string("SMA", "5M MA Type", options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group = "Multi-Timeframe RSI", display = display.none)
maLength5M = input.int(14, "5M MA Length", group = "Multi-Timeframe RSI", display = display.none)

// =====================
// MA Calculation Function
// =====================
ma(source, length, MAtype) =>
	switch MAtype
		"SMA"           => ta.sma(source, length)
		"EMA"           => ta.ema(source, length)
		"SMMA (RMA)"    => ta.rma(source, length)
		"WMA"           => ta.wma(source, length)
		"VWMA"          => ta.vwma(source, length)

// =====================
// Calculate MAs for 1M and 5M RSI
// =====================
ma1M = request.security(syminfo.tickerid, "1", ma(rsi1M, maLength1M, maType1M), lookahead = barmerge.lookahead_off)
ma5M = request.security(syminfo.tickerid, "5", ma(rsi5M, maLength5M, maType5M), lookahead = barmerge.lookahead_off)

// =====================
// Background Fill Colors & Opacity Inputs
// =====================
bullShadeColor = input.color(color.green, "Bullish Shade Color", group = "Background Colors")
bullShadeOpacity = input.int(85, "Bullish Shade Opacity (0-100)", minval=0, maxval=100, group = "Background Colors")
bearShadeColor = input.color(color.red, "Bearish Shade Color", group = "Background Colors")
bearShadeOpacity = input.int(85, "Bearish Shade Opacity (0-100)", minval=0, maxval=100, group = "Background Colors")

// Calculate colors with opacity
bullBgColor = color.new(bullShadeColor, bullShadeOpacity)
bearBgColor = color.new(bearShadeColor, bearShadeOpacity)

// =====================
// Background Fill Logic
// =====================
// Green when both RSI values are above their MAs
bothAbove = not na(ma1M) and not na(ma5M) and rsi1M > ma1M and rsi5M > ma5M
// Red when both RSI values are below their MAs
bothBelow = not na(ma1M) and not na(ma5M) and rsi1M < ma1M and rsi5M < ma5M

// Apply background color
bgcolor(bothAbove ? bullBgColor : bothBelow ? bearBgColor : na, title = "Trend Background Fill")

// =====================
// Original RSI Calculation (for main display)
// =====================
change = ta.change(rsiSourceInput)
up = ta.rma(math.max(change, 0), rsiLengthInput)
down = ta.rma(-math.min(change, 0), rsiLengthInput)
rsi = down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))

// =====================
// RSI Plots and Bands
// =====================
rsiPlot = plot(rsi, "RSI", color=#7E57C2)
rsiUpperBand = hline(70, "RSI Upper Band", color=#787B86)
midline = hline(50, "RSI Middle Band", color=color.new(#787B86, 50))
rsiLowerBand = hline(30, "RSI Lower Band", color=#787B86)
fill(rsiUpperBand, rsiLowerBand, color=color.rgb(126, 87, 194, 90), title="RSI Background Fill")
midLinePlot = plot(50, color = na, editable = false, display = display.none)
fill(rsiPlot, midLinePlot, 100, 70, top_color = color.new(color.green, 0), bottom_color = color.new(color.green, 100),  title = "Overbought Gradient Fill")
fill(rsiPlot, midLinePlot, 30,  0,  top_color = color.new(color.red, 100), bottom_color = color.new(color.red, 0),      title = "Oversold Gradient Fill")

// =====================
// Smoothing MA inputs
// =====================
GRP = "Smoothing"
TT_BB = "Only applies when 'SMA + Bollinger Bands' is selected. Determines the distance between the SMA and the bands."
maTypeInput = input.string("SMA", "Type", options = ["None", "SMA", "SMA + Bollinger Bands", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group = GRP, display = display.none)
var isBB = maTypeInput == "SMA + Bollinger Bands"
maLengthInput = input.int(14, "Length", group = GRP, display = display.none, active = maTypeInput != "None")
bbMultInput = input.float(2.0, "BB StdDev", minval = 0.001, maxval = 50, step = 0.5, tooltip = TT_BB, group = GRP, display = display.none, active = isBB)
var enableMA = maTypeInput != "None"

// =====================
// Smoothing MA Calculation
// =====================
smoothingMA = enableMA ? ma(rsi, maLengthInput, maTypeInput) : na
smoothingStDev = isBB ? ta.stdev(rsi, maLengthInput) * bbMultInput : na
plot(smoothingMA, "RSI-based MA", color=color.yellow, display = enableMA ? display.all : display.none, editable = enableMA)
bbUpperBand = plot(smoothingMA + smoothingStDev, title = "Upper Bollinger Band", color=color.green, display = isBB ? display.all : display.none, editable = isBB)
bbLowerBand = plot(smoothingMA - smoothingStDev, title = "Lower Bollinger Band", color=color.green, display = isBB ? display.all : display.none, editable = isBB)
fill(bbUpperBand, bbLowerBand, color= isBB ? color.new(color.green, 90) : na, title="Bollinger Bands Background Fill", display = isBB ? display.all : display.none, editable = isBB)

// =====================
// Divergence
// =====================
lookbackRight = 5
lookbackLeft = 5
rangeUpper = 60
rangeLower = 5
bearColor = color.red
bullColor = color.green
textColor = color.white
noneColor = color.new(color.white, 100)

_inRange(bool cond) =>
    bars = ta.barssince(cond)
    rangeLower <= bars and bars <= rangeUpper

plFound = false
phFound = false

bullCond = false
bearCond = false

rsiLBR = rsi[lookbackRight]

if calculateDivergence
    //------------------------------------------------------------------------------
    // Regular Bullish
    // rsi: Higher Low
    plFound := not na(ta.pivotlow(rsi, lookbackLeft, lookbackRight))    
    rsiHL = rsiLBR > ta.valuewhen(plFound, rsiLBR, 1) and _inRange(plFound[1])
    // Price: Lower Low
    lowLBR = low[lookbackRight]
    priceLL = lowLBR < ta.valuewhen(plFound, lowLBR, 1)
    bullCond := priceLL and rsiHL and plFound

    //------------------------------------------------------------------------------
    // Regular Bearish
    // rsi: Lower High
    phFound := not na(ta.pivothigh(rsi, lookbackLeft, lookbackRight))
    rsiLH = rsiLBR < ta.valuewhen(phFound, rsiLBR, 1) and _inRange(phFound[1])
    // Price: Higher High
    highLBR = high[lookbackRight]
    priceHH = highLBR > ta.valuewhen(phFound, highLBR, 1)
    bearCond := priceHH and rsiLH and phFound


plot(
     plFound   ? rsiLBR : na,
     offset    = -lookbackRight,
     title     = "Regular Bullish",
     linewidth = 2,
     color     = (bullCond ? bullColor : noneColor),
     display   = display.pane,
     editable  = calculateDivergence)

plotshape(
     bullCond  ? rsiLBR : na,
     offset    = -lookbackRight,
     title     = "Regular Bullish Label",
     text      = " Bull ",
     style     = shape.labelup,
     location  = location.absolute,
     color     = bullColor,
     textcolor = textColor,
     display   = display.pane,
     editable  = calculateDivergence)

plot(
     phFound   ? rsiLBR : na,
     offset    = -lookbackRight,
     title     = "Regular Bearish",
     linewidth = 2,
     color     = (bearCond ? bearColor : noneColor),
     display   = display.pane,
     editable  = calculateDivergence)

plotshape(
     bearCond  ? rsiLBR : na,
     offset    = -lookbackRight,
     title     = "Regular Bearish Label",
     text      = " Bear ",
     style     = shape.labeldown,
     location  = location.absolute,
     color     = bearColor,
     textcolor = textColor,
     display   = display.pane,
     editable  = calculateDivergence)

// =====================
// Alert Conditions
// =====================
alertcondition(bullCond, title='Regular Bullish Divergence', message="Found a new Regular Bullish Divergence, `Pivot Lookback Right` number of bars to the left of the current bar.")
alertcondition(bearCond, title='Regular Bearish Divergence', message='Found a new Regular Bearish Divergence, `Pivot Lookback Right` number of bars to the left of the current bar.')

// Additional alert conditions for multi-timeframe trend
alertcondition(bothAbove, title='Both RSI Above MA (Bullish)', message='Both 1M and 5M RSI are above their moving averages - Bullish trend')
alertcondition(bothBelow, title='Both RSI Below MA (Bearish)', message='Both 1M and 5M RSI are below their moving averages - Bearish trend')
````
