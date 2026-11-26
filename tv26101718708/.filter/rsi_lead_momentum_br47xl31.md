# RSI Lead Momentum

- url: https://www.tradingview.com/script/br47Xl31/
- type: indicator
- pine_id: PUB;b59a34c0386c421191e68d428a7690bb
- version: 1.0

## Description

RSI Lead Momentum Engine is an advanced evolution of the classic RSI specifically designed for scalping and day trading on fast-moving markets such as Nasdaq (NQ), US100, CFD indices, and futures.

Unlike traditional RSI indicators that mainly react after price movement occurs, this indicator is designed to detect situations where RSI momentum leads the actual price structure.

Its primary objective is to identify pre-impulsive market phases in order to provide early entries before major directional expansions.

## Core Concept

The indicator analyzes the structural disconnection between:

* RSI structure,
* RSI slope,
* momentum acceleration,
* and real price structure.

The “RSI Lead” engine specifically detects situations where:

* RSI breaks a previous swing low or swing high,
* RSI momentum accelerates aggressively,
* while price has not yet confirmed the breakout or breakdown.

This behavior frequently appears on fast algorithmic markets and can signal:

* upcoming bullish or bearish continuation,
* volatility expansion phases,
* institutional momentum building before visible price displacement.

## Features

### RSI Lead Momentum Engine

Early signal detection:

* Early SELL
* Early BUY

Based on:

* RSI structural breaks,
* momentum acceleration,
* price compression,
* price lag versus RSI.

### RSI Divergences

Built-in detection:

* Regular Bullish
* Regular Bearish

### Compression & Momentum Explosion

Detection of:

* volatility compression,
* explosive momentum expansion.

### Dynamic RSI Coloring

Automatic RSI coloring based on:

* bullish momentum,
* bearish momentum,
* acceleration,
* breakout conditions.

### Detection Modes

* FAST → ultra-reactive mode for aggressive scalping.
* CONFIRMED → cleaner signals with additional price confirmation.

## Optimized For

* Nasdaq / NQ
* US100
* 1m / 2m / 5m scalping
* Momentum day trading
* Continuation setups
* Early entries
* Fast breakdowns and breakouts

## Indicator Philosophy

This indicator does not treat RSI as a simple overbought/oversold oscillator.

Instead, RSI is treated as:
an advanced directional pressure engine capable of anticipating certain price displacements before they become visually obvious on the chart.

The core of the algorithm is therefore based on:
detecting momentum displacement before price displacement.

## Source Code

````pine
//@version=6
indicator(title="RSI Lead Momentum Engine", shorttitle="RSI LEAD", format=format.price, precision=2, timeframe="", timeframe_gaps=true)

//====================================================================
// RSI SETTINGS
//====================================================================

rsiLengthInput = input.int(13, minval=1, title="RSI Length", group="RSI Settings")
rsiSourceInput = input.source(close, "Source", group="RSI Settings")

calculateDivergence = input.bool(
     true,
     title="Calculate Divergence",
     group="RSI Settings")

//====================================================================
// RSI CALCULATION
//====================================================================

change = ta.change(rsiSourceInput)

up = ta.rma(math.max(change, 0), rsiLengthInput)
down = ta.rma(-math.min(change, 0), rsiLengthInput)

rsi = down == 0 ? 100 :
      up == 0 ? 0 :
      100 - (100 / (1 + up / down))

//====================================================================
// RSI LEAD MOMENTUM ENGINE
//====================================================================

grpLead = "RSI Lead Momentum Engine"

enableLeadEngine = input.bool(
     true,
     "Enable RSI Lead Engine",
     group = grpLead)

leadMode = input.string(
     "FAST",
     "Lead Detection Mode",
     options = ["FAST", "CONFIRMED"],
     group = grpLead)

leadLookback = input.int(
     5,
     "RSI Structure Lookback",
     minval = 2,
     maxval = 20,
     group = grpLead)

showLeadLabels = input.bool(
     true,
     "Show Lead Labels",
     group = grpLead)

showLeadBackground = input.bool(
     true,
     "Show Compression Background",
     group = grpLead)

enableCompressionFilter = input.bool(
     true,
     "Enable Compression Filter",
     group = grpLead)

compressionThreshold = input.float(
     0.8,
     "Compression Threshold",
     step = 0.1,
     group = grpLead)

enableSlopeFilter = input.bool(
     true,
     "Enable RSI Slope Filter",
     group = grpLead)

slopeThreshold = input.float(
     1.5,
     "RSI Slope Threshold",
     step = 0.1,
     group = grpLead)

enablePriceDelay = input.bool(
     true,
     "Enable Price Delay Logic",
     group = grpLead)

//====================================================================
// RSI MOMENTUM
//====================================================================

rsiSlope = rsi - rsi[1]
rsiAcceleration = rsiSlope - rsiSlope[1]

//====================================================================
// PRICE STRUCTURE
//====================================================================

priceRecentLow = ta.lowest(low, leadLookback)
priceRecentHigh = ta.highest(high, leadLookback)

rsiRecentLow = ta.lowest(rsi, leadLookback)
rsiRecentHigh = ta.highest(rsi, leadLookback)

//====================================================================
// RSI STRUCTURE BREAK
//====================================================================

// CORE IDEA:
// RSI breaks structure BEFORE price breaks structure.

rsiBreakDown =
     rsi < rsiRecentLow[1]

rsiBreakUp =
     rsi > rsiRecentHigh[1]

//====================================================================
// PRICE DELAY
//====================================================================

priceStillHolding =
     low >= priceRecentLow[1]

priceStillWeak =
     high <= priceRecentHigh[1]

//====================================================================
// MOMENTUM CONDITIONS
//====================================================================

bearMomentum =
     rsiSlope < -slopeThreshold and
     rsiAcceleration <= 0

bullMomentum =
     rsiSlope > slopeThreshold and
     rsiAcceleration >= 0

//====================================================================
// COMPRESSION ENGINE
//====================================================================

priceRange = high - low

rangeMA = ta.sma(priceRange, 10)

compressionDetected =
     priceRange < (rangeMA * compressionThreshold)

//====================================================================
// FINAL LEAD SIGNALS
//====================================================================

earlySellSignal =
     enableLeadEngine and
     rsiBreakDown and
     (not enablePriceDelay or priceStillHolding) and
     (not enableSlopeFilter or bearMomentum) and
     (not enableCompressionFilter or compressionDetected)

earlyBuySignal =
     enableLeadEngine and
     rsiBreakUp and
     (not enablePriceDelay or priceStillWeak) and
     (not enableSlopeFilter or bullMomentum) and
     (not enableCompressionFilter or compressionDetected)

//====================================================================
// CONFIRMED MODE
//====================================================================

confirmedSell =
     earlySellSignal and
     close < low[1]

confirmedBuy =
     earlyBuySignal and
     close > high[1]

sellSignal =
     leadMode == "FAST" ?
     earlySellSignal :
     confirmedSell

buySignal =
     leadMode == "FAST" ?
     earlyBuySignal :
     confirmedBuy

//====================================================================
// RSI COLOR ENGINE
//====================================================================

leadRSIColor =
     sellSignal ? color.red :
     buySignal ? color.lime :
     color(#7E57C2)

//====================================================================
// RSI PLOTS
//====================================================================

rsiPlot = plot(
     rsi,
     "RSI",
     color = leadRSIColor,
     linewidth = 2)

rsiUpperBand = hline(
     70,
     "RSI Upper Band",
     color=#787B86)

midline = hline(
     50,
     "RSI Middle Band",
     color=color.new(#787B86, 50))

rsiLowerBand = hline(
     30,
     "RSI Lower Band",
     color=#787B86)

fill(
     rsiUpperBand,
     rsiLowerBand,
     color=color.rgb(126, 87, 194, 90),
     title="RSI Background Fill")

midLinePlot = plot(
     50,
     color = na,
     editable = false,
     display = display.none)

fill(
     rsiPlot,
     midLinePlot,
     100,
     70,
     top_color = color.new(color.green, 0),
     bottom_color = color.new(color.green, 100),
     title = "Overbought Gradient Fill")

fill(
     rsiPlot,
     midLinePlot,
     30,
     0,
     top_color = color.new(color.red, 100),
     bottom_color = color.new(color.red, 0),
     title = "Oversold Gradient Fill")

//====================================================================
// BACKGROUND
//====================================================================

bgcolor(
     showLeadBackground and compressionDetected ?
     color.new(color.orange, 92) :
     na)

//====================================================================
// LABELS
//====================================================================

plotshape(
     showLeadLabels and sellSignal ? rsi : na,
     title = "Early Sell",
     text = "SELL",
     style = shape.labeldown,
     location = location.absolute,
     color = color.red,
     textcolor = color.white,
     size = size.small)

plotshape(
     showLeadLabels and buySignal ? rsi : na,
     title = "Early Buy",
     text = "BUY",
     style = shape.labelup,
     location = location.absolute,
     color = color.lime,
     textcolor = color.black,
     size = size.small)

//====================================================================
// MOMENTUM EXPLOSION
//====================================================================

bearExplosion =
     compressionDetected[1] and
     rsiSlope < -slopeThreshold * 1.5

bullExplosion =
     compressionDetected[1] and
     rsiSlope > slopeThreshold * 1.5

plotshape(
     bearExplosion ? rsi : na,
     title = "Bear Explosion",
     text = "EXP DN",
     style = shape.triangledown,
     location = location.absolute,
     color = color.maroon,
     size = size.tiny)

plotshape(
     bullExplosion ? rsi : na,
     title = "Bull Explosion",
     text = "EXP UP",
     style = shape.triangleup,
     location = location.absolute,
     color = color.aqua,
     size = size.tiny)

//====================================================================
// SMOOTHING MA INPUTS
//====================================================================

GRP = "Smoothing"

TT_BB = "Only applies when 'SMA + Bollinger Bands' is selected."

maTypeInput = input.string(
     "SMA",
     "Type",
     options = ["None", "SMA", "SMA + Bollinger Bands", "EMA", "SMMA (RMA)", "WMA", "VWMA"],
     group = GRP)

isBB = maTypeInput == "SMA + Bollinger Bands"

maLengthInput = input.int(
     14,
     "Length",
     group = GRP)

bbMultInput = input.float(
     2.0,
     "BB StdDev",
     minval = 0.001,
     maxval = 50,
     step = 0.5,
     tooltip = TT_BB,
     group = GRP)

enableMA = maTypeInput != "None"

//====================================================================
// MA FUNCTION
//====================================================================

ma(source, length, MAtype) =>
	switch MAtype
		"SMA"                   => ta.sma(source, length)
		"SMA + Bollinger Bands" => ta.sma(source, length)
		"EMA"                   => ta.ema(source, length)
		"SMMA (RMA)"            => ta.rma(source, length)
		"WMA"                   => ta.wma(source, length)
		"VWMA"                  => ta.vwma(source, length)

//====================================================================
// MA PLOTS
//====================================================================

smoothingMA =
     enableMA ?
     ma(rsi, maLengthInput, maTypeInput) :
     na

smoothingStDev =
     isBB ?
     ta.stdev(rsi, maLengthInput) * bbMultInput :
     na

plot(
     smoothingMA,
     "RSI-based MA",
     color=color.yellow,
     display = enableMA ? display.all : display.none)

bbUpperBand = plot(
     smoothingMA + smoothingStDev,
     title = "Upper Bollinger Band",
     color=color.green,
     display = isBB ? display.all : display.none)

bbLowerBand = plot(
     smoothingMA - smoothingStDev,
     title = "Lower Bollinger Band",
     color=color.green,
     display = isBB ? display.all : display.none)

fill(
     bbUpperBand,
     bbLowerBand,
     color= isBB ? color.new(color.green, 90) : na,
     title="Bollinger Bands Background Fill")

//====================================================================
// DIVERGENCE
//====================================================================

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

    //==============================================================
    // REGULAR BULLISH
    //==============================================================

    plFound := not na(ta.pivotlow(rsi, lookbackLeft, lookbackRight))

    rsiHL =
         rsiLBR > ta.valuewhen(plFound, rsiLBR, 1) and
         _inRange(plFound[1])

    lowLBR = low[lookbackRight]

    priceLL =
         lowLBR < ta.valuewhen(plFound, lowLBR, 1)

    bullCond :=
         priceLL and
         rsiHL and
         plFound

    //==============================================================
    // REGULAR BEARISH
    //==============================================================

    phFound := not na(ta.pivothigh(rsi, lookbackLeft, lookbackRight))

    rsiLH =
         rsiLBR < ta.valuewhen(phFound, rsiLBR, 1) and
         _inRange(phFound[1])

    highLBR = high[lookbackRight]

    priceHH =
         highLBR > ta.valuewhen(phFound, highLBR, 1)

    bearCond :=
         priceHH and
         rsiLH and
         phFound

//====================================================================
// DIVERGENCE PLOTS
//====================================================================

plot(
     plFound ? rsiLBR : na,
     offset = -lookbackRight,
     title = "Regular Bullish",
     linewidth = 2,
     color = (bullCond ? bullColor : noneColor),
     display = display.pane)

plotshape(
     bullCond ? rsiLBR : na,
     offset = -lookbackRight,
     title = "Regular Bullish Label",
     text = "Bull",
     style = shape.labelup,
     location = location.absolute,
     color = bullColor,
     textcolor = textColor,
     display = display.pane)

plot(
     phFound ? rsiLBR : na,
     offset = -lookbackRight,
     title = "Regular Bearish",
     linewidth = 2,
     color = (bearCond ? bearColor : noneColor),
     display = display.pane)

plotshape(
     bearCond ? rsiLBR : na,
     offset = -lookbackRight,
     title = "Regular Bearish Label",
     text = "Bear",
     style = shape.labeldown,
     location = location.absolute,
     color = bearColor,
     textcolor = textColor,
     display = display.pane)

//====================================================================
// ALERTS
//====================================================================

alertcondition(
     bullCond,
     title='Regular Bullish Divergence',
     message="Found a new Regular Bullish Divergence.")

alertcondition(
     bearCond,
     title='Regular Bearish Divergence',
     message='Found a new Regular Bearish Divergence.')
````
