# DUAL Relative Strength Index    (Settings: 14 14 28)

- url: https://www.tradingview.com/script/EDQhXwzi/
- type: indicator
- pine_id: PUB;1c2a97bcf5c44d79acc9d2f47cae5b86
- version: 1.0

## Description

RSI with Dual Smoothing MA

A modified version of TradingView's built-in RSI indicator with a second RSI-based moving average added.

The standard RSI includes a single smoothing MA. This version adds a second, fully independent one — so you can run a fast MA alongside a slow MA and compare the RSI's short-term movement against its longer-term trend in the same pane.

Features

Two separate RSI-based MAs, each with its own type and length (SMA, EMA, SMMA/RMA, WMA, VWMA)
Independent color selection for each line
Either MA can be switched off entirely by setting its type to "None"
Optional Bollinger Bands on the first MA (as in the original)
Regular bullish/bearish divergence detection and alerts (as in the original)

Settings

RSI Settings: RSI length, source, divergence calculation
Smoothing: first MA — defaults to 14 SMA, yellow
Smoothing 2: second MA — defaults to 28 SMA, orange

Ways to use it

The fast MA crossing above the slow MA can be read as strengthening momentum; crossing below, as weakening
Both MAs sitting on the same side of the 50 level can serve as directional confirmation
The distance between the two lines gives a sense of how quickly momentum is shifting

This indicator does not generate standalone buy or sell signals. It is intended as a confirmation tool within your own system, and settings should be tested against the symbol and timeframe you trade.

Based on TradingView's open-source built-in "Relative Strength Index" indicator.


İngilizce:

Ways to use it

The fast MA crossing above the slow MA can be read as strengthening momentum; crossing below, as weakening
Crossovers that occur in the extreme zones (below 30 / above 70) tend to be more meaningful than those in the middle range (roughly 40–60), where the RSI often moves sideways and the MAs cross back and forth, producing noise
Both MAs sitting on the same side of the 50 level can serve as directional confirmation
The distance between the two lines gives a sense of how quickly momentum is shifting

## Source Code

````pine
//@version=6
indicator(title="Relative Strength Index", shorttitle="RSI", format=format.price, precision=2, timeframe="", timeframe_gaps=true)

rsiLengthInput = input.int(14, minval=1, title="RSI Length", group="RSI Settings")
rsiSourceInput = input.source(close, "Source", group="RSI Settings")
calculateDivergence = input.bool(false, title="Calculate Divergence", group="RSI Settings", display = display.none, tooltip = "Calculating divergences is needed in order for divergence alerts to fire.")

change = ta.change(rsiSourceInput)
up = ta.rma(math.max(change, 0), rsiLengthInput)
down = ta.rma(-math.min(change, 0), rsiLengthInput)
rsi = down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))

rsiPlot = plot(rsi, "RSI", color=#7E57C2)
rsiUpperBand = hline(70, "RSI Upper Band", color=#787B86)
midline = hline(50, "RSI Middle Band", color=color.new(#787B86, 50))
rsiLowerBand = hline(30, "RSI Lower Band", color=#787B86)
fill(rsiUpperBand, rsiLowerBand, color=color.rgb(126, 87, 194, 90), title="RSI Background Fill")
midLinePlot = plot(50, color = na, editable = false, display = display.none)
fill(rsiPlot, midLinePlot, 100, 70, top_color = color.new(color.green, 0), bottom_color = color.new(color.green, 100),  title = "Overbought Gradient Fill")
fill(rsiPlot, midLinePlot, 30,  0,  top_color = color.new(color.red, 100), bottom_color = color.new(color.red, 0),      title = "Oversold Gradient Fill")

// Smoothing MA inputs
GRP = "Smoothing"
TT_BB = "Only applies when 'SMA + Bollinger Bands' is selected. Determines the distance between the SMA and the bands."
maTypeInput = input.string("SMA", "Type", options = ["None", "SMA", "SMA + Bollinger Bands", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group = GRP, display = display.none)
var isBB = maTypeInput == "SMA + Bollinger Bands"
maLengthInput = input.int(14, "Length", group = GRP, display = display.none, active = maTypeInput != "None")
bbMultInput = input.float(2.0, "BB StdDev", minval = 0.001, maxval = 50, step = 0.5, tooltip = TT_BB, group = GRP, display = display.none, active = isBB)
maColorInput = input.color(color.yellow, "Color", group = GRP, display = display.none, active = maTypeInput != "None")
var enableMA = maTypeInput != "None"

// ===== 2. Smoothing MA inputs (YENİ) =====
GRP2 = "Smoothing 2"
ma2TypeInput   = input.string("SMA", "Type", options = ["None", "SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group = GRP2, display = display.none)
ma2LengthInput = input.int(50, "Length", minval = 1, group = GRP2, display = display.none, active = ma2TypeInput != "None")
ma2ColorInput  = input.color(color.orange, "Color", group = GRP2, display = display.none, active = ma2TypeInput != "None")
var enableMA2  = ma2TypeInput != "None"

// Smoothing MA Calculation
ma(source, length, MAtype) =>
	switch MAtype
		"SMA"                   => ta.sma(source, length)
		"SMA + Bollinger Bands" => ta.sma(source, length)
		"EMA"                   => ta.ema(source, length)
		"SMMA (RMA)"            => ta.rma(source, length)
		"WMA"                   => ta.wma(source, length)
		"VWMA"                  => ta.vwma(source, length)

// Smoothing MA plots
smoothingMA = enableMA ? ma(rsi, maLengthInput, maTypeInput) : na
smoothingStDev = isBB ? ta.stdev(rsi, maLengthInput) * bbMultInput : na
plot(smoothingMA, "RSI-based MA", color=maColorInput, display = enableMA ? display.all : display.none, editable = enableMA)
bbUpperBand = plot(smoothingMA + smoothingStDev, title = "Upper Bollinger Band", color=color.green, display = isBB ? display.all : display.none, editable = isBB)
bbLowerBand = plot(smoothingMA - smoothingStDev, title = "Lower Bollinger Band", color=color.green, display = isBB ? display.all : display.none, editable = isBB)
fill(bbUpperBand, bbLowerBand, color= isBB ? color.new(color.green, 90) : na, title="Bollinger Bands Background Fill", display = isBB ? display.all : display.none, editable = isBB)

// ===== 2. Smoothing MA plot (YENİ) =====
smoothingMA2 = enableMA2 ? ma(rsi, ma2LengthInput, ma2TypeInput) : na
plot(smoothingMA2, "RSI-based MA 2", color=ma2ColorInput, display = enableMA2 ? display.all : display.none, editable = enableMA2)

// Divergence
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

alertcondition(bullCond, title='Regular Bullish Divergence', message="Found a new Regular Bullish Divergence, `Pivot Lookback Right` number of bars to the left of the current bar.")
alertcondition(bearCond, title='Regular Bearish Divergence', message='Found a new Regular Bearish Divergence, `Pivot Lookback Right` number of bars to the left of the current bar.')
````
