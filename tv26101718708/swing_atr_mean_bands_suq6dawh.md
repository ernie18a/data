# Swing ATR Mean Bands

- url: https://www.tradingview.com/script/SuQ6dAWH-Swing-ATR-Mean-Bands/
- type: indicator
- pine_id: PUB;461de00901f24c8f89fc5715af22d2d0
- version: 1.0

## Description

Swing ATR Mean Bands
Swing ATR Mean Bands
Swing ATR Mean Bands
Swing ATR Mean Bands
Swing ATR Mean Bands
Swing ATR Mean Bands

## Source Code

````pine
//@version=6
indicator("Swing ATR Mean Bands", overlay=true, max_labels_count=500)

// -------------------------
// Inputs
// -------------------------
leftBars  = input.int(1, "Swing Left Bars", minval=1)
rightBars = input.int(1, "Swing Right Bars", minval=1)

swingAtrLen = input.int(20, "Swing ATR Length", minval=1)
minSwingTicks = input.int(4, "Ignore Swings Smaller Than X Ticks", minval=0)

maType = input.string("EMA", "Mean Type", options=["EMA", "SMA", "RMA"])
maLen = input.int(50, "Mean Length", minval=1)

band1Mult = input.float(1.0, "Band 1 Multiplier", step=0.25)
band2Mult = input.float(2.0, "Band 2 Multiplier", step=0.25)

showBands = input.bool(true, "Show Bands")
showFill = input.bool(true, "Fill Bands")

// -------------------------
// Swing pivot detection
// -------------------------
ph = ta.pivothigh(high, leftBars, rightBars)
pl = ta.pivotlow(low, leftBars, rightBars)

var float lastSwingPrice = na
var int   lastSwingType  = 0        // 1 = high, -1 = low, 0 = none
var array<float> swingRanges = array.new<float>()

minSwingSize = minSwingTicks * syminfo.mintick

// -------------------------
// Process pivot high
// -------------------------
if not na(ph)
    pivotPrice = ph
    pivotType = 1

    if lastSwingType == 0
        lastSwingPrice := pivotPrice
        lastSwingType := pivotType

    else if pivotType == lastSwingType
        if pivotPrice > lastSwingPrice
            lastSwingPrice := pivotPrice

    else
        swingSize = math.abs(pivotPrice - lastSwingPrice)

        if swingSize >= minSwingSize
            array.unshift(swingRanges, swingSize)

            if array.size(swingRanges) > swingAtrLen
                array.pop(swingRanges)

            lastSwingPrice := pivotPrice
            lastSwingType := pivotType

// -------------------------
// Process pivot low
// -------------------------
if not na(pl)
    pivotPrice = pl
    pivotType = -1

    if lastSwingType == 0
        lastSwingPrice := pivotPrice
        lastSwingType := pivotType

    else if pivotType == lastSwingType
        if pivotPrice < lastSwingPrice
            lastSwingPrice := pivotPrice

    else
        swingSize = math.abs(pivotPrice - lastSwingPrice)

        if swingSize >= minSwingSize
            array.unshift(swingRanges, swingSize)

            if array.size(swingRanges) > swingAtrLen
                array.pop(swingRanges)

            lastSwingPrice := pivotPrice
            lastSwingType := pivotType

// -------------------------
// Swing Average True Rotation
// -------------------------
swingATR = array.size(swingRanges) > 0 ? array.avg(swingRanges) : na

// -------------------------
// Mean line
// -------------------------
mean = switch maType
    "EMA" => ta.ema(close, maLen)
    "SMA" => ta.sma(close, maLen)
    "RMA" => ta.rma(close, maLen)

// -------------------------
// Rotation bands
// -------------------------
upper1 = mean + swingATR * band1Mult
lower1 = mean - swingATR * band1Mult

upper2 = mean + swingATR * band2Mult
lower2 = mean - swingATR * band2Mult

// -------------------------
// Plots
// -------------------------
plot(mean, "Rotation Mean", linewidth=2)

pU1 = plot(showBands ? upper1 : na, "Upper 1x Swing ATR", linewidth=1)
pL1 = plot(showBands ? lower1 : na, "Lower 1x Swing ATR", linewidth=1)

pU2 = plot(showBands ? upper2 : na, "Upper 2x Swing ATR", linewidth=1)
pL2 = plot(showBands ? lower2 : na, "Lower 2x Swing ATR", linewidth=1)

fill(pU1, pL1, showFill ? color.new(color.gray, 90) : na, title="1x Band Fill")
fill(pU2, pL2, showFill ? color.new(color.gray, 95) : na, title="2x Band Fill")
````
