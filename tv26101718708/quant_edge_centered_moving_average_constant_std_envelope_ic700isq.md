# Quant Edge - Centered Moving Average - Constant STD Envelope

- url: https://www.tradingview.com/script/Ic700isq-Quant-Edge-Centered-Moving-Average-Constant-STD-Envelope/
- type: indicator
- pine_id: PUB;6171c42e68014c178110397911819dde
- version: 1.0

## Description

Centered Moving Average. Provides an optional additional smoothing period.
Uniform Envelop of with constant distance equal to 1 standard deviation of price to CMA.

## Source Code

````pine
//@version=6
indicator("Centered Moving Average - Constant STD Envelope", overlay=true)

//--------------------------------------------------
// Inputs
//--------------------------------------------------
cmaLen = input.int(40, "CMA Period", minval=2)

srcType = input.string(
     "Close",
     "Price Source",
     options=[
         "Close",
         "Open",
         "High",
         "Low",
         "HL2",
         "HLC3",
         "OHLC4",
         "OC2"
     ])

useExtraSmooth = input.bool(false, "Enable Additional Smoothing")
smoothLen      = input.int(5, "Additional Smoothing Period", minval=1)

// Envelope multiplier
stdMultiplier = input.float(1.0, "STD Multiplier", minval=0.1, step=0.1)

// Colors
cmaColor   = input.color(color.yellow, "Center Line Color")
upperColor = input.color(color.lime, "Upper Band Color")
lowerColor = input.color(color.red, "Lower Band Color")

// Widths
cmaWidth   = input.int(2, "Center Line Width", minval=1, maxval=5)
bandWidth  = input.int(1, "Band Width", minval=1, maxval=5)

//--------------------------------------------------
// Source selection
//--------------------------------------------------
src =
     srcType == "Close" ? close :
     srcType == "Open"  ? open :
     srcType == "High"  ? high :
     srcType == "Low"   ? low :
     srcType == "HL2"   ? hl2 :
     srcType == "HLC3"  ? hlc3 :
     srcType == "OHLC4" ? ohlc4 :
     (open + close) / 2.0

//--------------------------------------------------
// Optional smoothing
//--------------------------------------------------
filteredSrc =
     useExtraSmooth
     ? ta.sma(src, smoothLen)
     : src

//--------------------------------------------------
// Centered Moving Average
//--------------------------------------------------
cma = ta.sma(filteredSrc, cmaLen)

offsetBars = math.floor(cmaLen / 2)

//--------------------------------------------------
// Detrended series
//--------------------------------------------------
residual = filteredSrc - cma

//--------------------------------------------------
// Global standard deviation
//--------------------------------------------------
var float sum = 0.0
var float sumSq = 0.0
var int count = 0

if not na(residual)
    sum += residual
    sumSq += residual * residual
    count += 1

mean = count > 0 ? sum / count : na

variance =
     count > 0
     ? sumSq / count - mean * mean
     : na

globalStd = math.sqrt(math.max(variance, 0))

bandDistance = globalStd * stdMultiplier

//--------------------------------------------------
// Constant-width envelope
//--------------------------------------------------
upperBand = cma + bandDistance
lowerBand = cma - bandDistance

//--------------------------------------------------
// Plot
//--------------------------------------------------
plot(
     cma,
     title="Centered Moving Average",
     color=cmaColor,
     linewidth=cmaWidth,
     offset=-offsetBars)

plot(
     upperBand,
     title="Upper Band",
     color=upperColor,
     linewidth=bandWidth,
     offset=-offsetBars)

plot(
     lowerBand,
     title="Lower Band",
     color=lowerColor,
     linewidth=bandWidth,
     offset=-offsetBars)
````
