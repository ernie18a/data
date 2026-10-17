# RWA - DD

- url: https://www.tradingview.com/script/IIzSvBuA-RWA-DD/
- type: indicator
- pine_id: PUB;75c95950a345481e930eb8c888a06d3a
- version: 1.0

## Description

WMA RSI [Enhanced]
This is an enhanced version of TradingView's built-in RSI indicator, extended with two additional moving average lines applied directly on the RSI values — a fast EMA and a slow WMA, inspired by the "WMA RSI [Le Soleil]" script.
Features:

Standard RSI with overbought/oversold gradient fills (70/30)
Optional smoothing MA on RSI (SMA, EMA, RMA, WMA, VWMA, or SMA + Bollinger Bands)
EMA line on RSI (default 9) — for short-term momentum signals
WMA line on RSI (default 45) — for trend direction of RSI
Regular Bullish & Bearish Divergence detection (optional)

How to use:

When RSI EMA crosses above RSI WMA → bullish momentum building
When RSI EMA crosses below RSI WMA → bearish momentum building
Use divergence signals alongside the WMA trend for higher-confidence entries

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

rsiPlot = plot(rsi, "RSI", color=#360274)
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
var enableMA = maTypeInput != "None"

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
bbUpperBand = plot(smoothingMA + smoothingStDev, title = "Upper Bollinger Band", color=color.green, display = isBB ? display.all : display.none, editable = isBB)
bbLowerBand = plot(smoothingMA - smoothingStDev, title = "Lower Bollinger Band", color=color.green, display = isBB ? display.all : display.none, editable = isBB)
fill(bbUpperBand, bbLowerBand, color= isBB ? color.new(color.green, 90) : na, title="Bollinger Bands Background Fill", display = isBB ? display.all : display.none, editable = isBB)

// ————— WMA RSI Lines (from Le Soleil) —————
GRP2 = "WMA RSI Lines"
emaLengthInput = input.int(9,  title="EMA Length", group=GRP2)
wmaLengthInput = input.int(45, title="WMA Length", group=GRP2)

rsiEMA = ta.ema(rsi, emaLengthInput)
rsiWMA = ta.wma(rsi, wmaLengthInput)

plot(rsiEMA, title="RSI EMA", color=#1848cc,  linewidth=1)
plot(rsiWMA, title="RSI WMA", color=#f57c00, linewidth=1)

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
    plFound := not na(ta.pivotlow(rsi, lookbackLeft, lookbackRight))    
    rsiHL = rsiLBR > ta.valuewhen(plFound, rsiLBR, 1) and _inRange(plFound[1])
    lowLBR = low[lookbackRight]
    priceLL = lowLBR < ta.valuewhen(plFound, lowLBR, 1)
    bullCond := priceLL and rsiHL and plFound

    phFound := not na(ta.pivothigh(rsi, lookbackLeft, lookbackRight))
    rsiLH = rsiLBR < ta.valuewhen(phFound, rsiLBR, 1) and _inRange(phFound[1])
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
