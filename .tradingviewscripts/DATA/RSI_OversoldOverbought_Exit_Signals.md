<!-- tradingview-pine-id: PUB;f2d01ecc22e144aba633d8e49cf2274a -->
<!-- tradingviewscripts-format: 1 -->
# RSI Oversold/Overbought Exit Signals

Source: https://www.tradingview.com/script/TY7nSfbe-RSI-Oversold-Overbought-Exit-Signals/

## Description

🍀Overview

[*]This script is built on top of TradingView’s original Relative Strength Index (RSI) indicator. It preserves the original RSI calculation, visualization, smoothing options, Bollinger Band option, and regular bullish/bearish divergence functionality, while adding customizable overbought/oversold exit signals directly on the main price chart. 

🍀Features

[*]Standard RSI calculation with configurable length and source.
[*]Configurable overbought and oversold levels, used for both the RSI bands and signal logic.
[*]Long-bias markers appear when RSI crosses back above the oversold level.
[*]Short-bias markers appear when RSI crosses back below the overbought level.
[*]Optional bar-close confirmation helps prevent signals from appearing before the current candle has closed.
[*]Signals are displayed on the main chart while RSI remains in its own pane.
[*]Includes the original RSI smoothing choices: SMA, EMA, SMMA/RMA, WMA, VWMA, and SMA with Bollinger Bands.
[*]Includes optional regular bullish and bearish divergence detection and alerts inherited from the original TradingView RSI script. 
[*]Different from the original RSI script, a single configured “Any alert() function call” alert can trigger for both RSI oversold-exit and overbought-exit signals. The alert message identifies whether RSI crossed above the oversold level or below the overbought level.

🍀Inputs

[*]RSI Length: Number of bars used in the RSI calculation. Default: 14.
[*]Source: Price source used to calculate RSI. Default: close.
[*]Calculate Divergence: Enables regular bullish and bearish RSI divergence detection.
[*]Show Overbought/Oversold Exit Signals: Shows or hides the Long bias and Short bias markers on the price chart.
[*]Oversold: RSI level used to define the oversold zone and the oversold-exit signal. Default: 30.
[*]Overbought: RSI level used to define the overbought zone and the overbought-exit signal. Default: 70.
[*]Confirm Signals On Bar Close: When enabled, a signal is confirmed only after the candle closes.
 
🍀Usage

[*]A Long bias marker is generated when RSI crosses above the selected oversold level, indicating that RSI has exited the oversold zone.
[*]A Short bias marker is generated when RSI crosses below the selected overbought level, indicating that RSI has exited the overbought zone.
[*]For example, with the default settings, a Long bias marker appears when RSI crosses above 30, while a Short bias marker appears when RSI crosses below 70.
[*]These signals are intended as momentum and condition-change references, not standalone entry or exit instructions. Consider confirming them with trend direction, market structure, support and resistance, volume, or other analysis tools.

🍀Disclaimer

[*]This script is built on top of TradingView’s original RSI indicator and adds custom signal functionality. It is provided for informational and educational purposes only and does not constitute financial, investment, or trading advice. 
[*]RSI levels, crossovers, and divergences do not guarantee future price direction or performance. Long bias and Short bias markers are not buy or sell recommendations. Always perform independent analysis and use appropriate risk management before making trading decisions.

---

## Source Code

````pine
//@version=6
indicator(title="RSI Oversold/Overbought Exit Signals", shorttitle="RSI Signals", format=format.price, precision=2)//, timeframe="", timeframe_gaps=true)

rsiLengthInput = input.int(14, minval=1, title="RSI Length", group="RSI Settings")
rsiSourceInput = input.source(close, "Source", group="RSI Settings")
calculateDivergence = input.bool(false, title="Calculate Divergence", group="RSI Settings", display = display.none, tooltip = "Calculating divergences is needed in order for divergence alerts to fire.")

// Signal settings
group_signal_settings = "Signal Settings"
showSignals = input.bool(true, "Show Overbought/Oversold Exit Signals", group=group_signal_settings)
overSold = input.int(30, "Oversold", minval=1, maxval=100, group=group_signal_settings)
overBought = input.int(70, "Overbought", minval=1, maxval=100, group=group_signal_settings)
confirmOnClose = input.bool(true, "Confirm Signals On Bar Close", group=group_signal_settings)

change = ta.change(rsiSourceInput)
up = ta.rma(math.max(change, 0), rsiLengthInput)
down = ta.rma(-math.min(change, 0), rsiLengthInput)
rsi = down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))

rsiPlot = plot(rsi, "RSI", color=#7E57C2)
rsiUpperBand = hline(overBought, "RSI Upper Band", color=#787B86)
midline = hline(50, "RSI Middle Band", color=color.new(#787B86, 50))
rsiLowerBand = hline(overSold, "RSI Lower Band", color=#787B86)
fill(rsiUpperBand, rsiLowerBand, color=color.rgb(126, 87, 194, 90), title="RSI Background Fill")
midLinePlot = plot(50, color = na, editable = false, display = display.none)
fill(rsiPlot, midLinePlot, 100, overBought, top_color = color.new(color.green, 0), bottom_color = color.new(color.green, 100),  title = "Overbought Gradient Fill")
fill(rsiPlot, midLinePlot, overSold,  0,  top_color = color.new(color.red, 100), bottom_color = color.new(color.red, 0),      title = "Oversold Gradient Fill")

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
plot(smoothingMA, "RSI-based MA", color=color.yellow, display = enableMA ? display.all : display.none, editable = enableMA)
bbUpperBand = plot(smoothingMA + smoothingStDev, title = "Upper Bollinger Band", color=color.green, display = isBB ? display.all : display.none, editable = isBB)
bbLowerBand = plot(smoothingMA - smoothingStDev, title = "Lower Bollinger Band", color=color.green, display = isBB ? display.all : display.none, editable = isBB)
fill(bbUpperBand, bbLowerBand, color= isBB ? color.new(color.green, 90) : na, title="Bollinger Bands Background Fill", display = isBB ? display.all : display.none, editable = isBB)

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


// RSI cross signals
oversoldExit = ta.crossover(rsi, overSold)
overboughtExit = ta.crossunder(rsi, overBought)

buySignal = showSignals and oversoldExit and (not confirmOnClose or barstate.isconfirmed)
sellSignal = showSignals and overboughtExit and (not confirmOnClose or barstate.isconfirmed)

// Draw signals on main chart while keeping RSI in its own pane
plotshape(buySignal,
     title="RSI Oversold Exit Signal",
     text="Long bias",
     style=shape.triangleup,
     location=location.belowbar,
     color=bullColor,
     textcolor=color.black,
     size=size.tiny,
     force_overlay=true)

plotshape(sellSignal,
     title="RSI Overbought Exit Signal",
     text="Short bias",
     style=shape.triangledown,
     location=location.abovebar,
     color=bearColor,
     textcolor=color.black,
     size=size.tiny,
     force_overlay=true)

//@function     Something like alertcondition() but allows variables in the message
triggerAlert(bool condition, string message) =>
    if condition and barstate.islast
        alert(message, alert.freq_once_per_bar)

// Alerts
triggerAlert(buySignal, "RSI oversold exit signal, crossed over " + str.tostring(overSold, "#.##"))
triggerAlert(sellSignal, "RSI overbought exit signal, crossed under " + str.tostring(overBought, "#.##"))
````
