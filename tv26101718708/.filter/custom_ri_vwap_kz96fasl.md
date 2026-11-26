# Custom RI VWAP

- url: https://www.tradingview.com/script/kz96fasL-Custom-RI-VWAP/
- type: indicator
- pine_id: PUB;01be3b6899544d8787a0d5cd20471d2e
- version: 1.0

## Description

HLC3-based VWAP anchored to the 6:00 PM Globex open with user-defined mirrored “risk interval” bands.

These bands represent fixed point deviations from VWAP, helping identify when price is extended from fair value. In a non-volatile market, inner bands tend to highlight areas wher price is overextended from vwap for mean reversion setups. Outer bands highlight areas where price is more likely to mean revert or require strong momentum to continue. 

Use for:

mean reversion at extremes
continuation on acceptance beyond bands
avoiding chasing entries in overextended conditions

Best used alongside key levels, session structure, and orderflow.

## Source Code

````pine
//@version=6
indicator("Custom RI VWAP", overlay=true)

// ===== Visibility Inputs =====
showVWAP    = input.bool(true, "Show VWAP")

showUpper1  = input.bool(true, "Show Upper Band 1")
showLower1  = input.bool(true, "Show Lower Band 1")
showUpper2  = input.bool(true, "Show Upper Band 2")
showLower2  = input.bool(true, "Show Lower Band 2")

// ===== Distance Inputs =====
band1Points = input.float(10.0, "Band 1 Distance From VWAP (Points)", step=0.25, minval=1.0)
band2Points = input.float(20.0, "Band 2 Distance From VWAP (Points)", step=0.25, minval=0.0)

// ===== VWAP Style =====
vwapColor   = input.color(color.rgb(255, 0, 0, 10), "VWAP Line Color")
vwapWidth   = input.int(1, "VWAP Line Width", minval=1, maxval=5)

// ===== Band 1 Style =====
upper1Color = input.color(color.rgb(0, 0, 0, 95), "Upper Band 1 Color")
upper1Width = input.int(1, "Upper Band 1 Width", minval=1, maxval=5)

lower1Color = input.color(color.rgb(0, 0, 0, 95), "Lower Band 1 Color")
lower1Width = input.int(1, "Lower Band 1 Width", minval=1, maxval=5)

// ===== Band 2 Style =====
upper2Color = input.color(color.rgb(0, 0, 0, 100), "Upper Band 2 Color")
upper2Width = input.int(1, "Upper Band 2 Width", minval=1, maxval=5)

lower2Color = input.color(color.rgb(0, 0, 0, 100), "Lower Band 2 Color")
lower2Width = input.int(1, "Lower Band 2 Width", minval=1, maxval=5)

// ===== Fill Inputs =====
showFill1       = input.bool(true, "Show Fill Band 1")
fill1Color      = input.color(color.rgb(255, 255, 255), "Band 1 Fill Color")
fill1Trans      = input.int(90, "Band 1 Fill Transparency", minval=0, maxval=100)

showFill2       = input.bool(true, "Show Fill Band 2")
fill2Color      = input.color(color.rgb(0, 0, 0), "Band 2 Fill Color")
fill2Trans      = input.int(96, "Band 2 Fill Transparency", minval=0, maxval=100)

// ===== Custom VWAP (HLC3, 6PM Reset) =====
tp = (high + low + close) / 3
isNewSession = (hour == 17 and minute == 0)

var float cumTPV = 0.0
var float cumVol = 0.0

if isNewSession
    cumTPV := tp * volume
    cumVol := volume
else
    cumTPV += tp * volume
    cumVol += volume

vwapValue = cumVol != 0 ? cumTPV / cumVol : na

// ===== Bands =====
upperBand1 = vwapValue + band1Points
lowerBand1 = vwapValue - band1Points

upperBand2 = vwapValue + band2Points
lowerBand2 = vwapValue - band2Points

// ===== Plots =====
vwapPlot   = plot(showVWAP   ? vwapValue   : na, title="VWAP",         color=vwapColor,   linewidth=vwapWidth)

upper1Plot = plot(showUpper1 ? upperBand1  : na, title="Upper Band 1", color=upper1Color, linewidth=upper1Width)
lower1Plot = plot(showLower1 ? lowerBand1  : na, title="Lower Band 1", color=lower1Color, linewidth=lower1Width)

upper2Plot = plot(showUpper2 ? upperBand2  : na, title="Upper Band 2", color=upper2Color, linewidth=upper2Width)
lower2Plot = plot(showLower2 ? lowerBand2  : na, title="Lower Band 2", color=lower2Color, linewidth=lower2Width)

// ===== Fills =====
fill(vwapPlot, upper1Plot, color=showFill1 and showUpper1 ? color.new(fill1Color, fill1Trans) : na, title="Upper Fill 1")
fill(vwapPlot, lower1Plot, color=showFill1 and showLower1 ? color.new(fill1Color, fill1Trans) : na, title="Lower Fill 1")

fill(vwapPlot, upper2Plot, color=showFill2 and showUpper2 ? color.new(fill2Color, fill2Trans) : na, title="Upper Fill 2")
fill(vwapPlot, lower2Plot, color=showFill2 and showLower2 ? color.new(fill2Color, fill2Trans) : na, title="Lower Fill 2")
````
