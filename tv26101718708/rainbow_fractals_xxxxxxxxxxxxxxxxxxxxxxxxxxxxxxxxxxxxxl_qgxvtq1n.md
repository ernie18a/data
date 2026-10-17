# Rainbow Fractals XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXL

- url: https://www.tradingview.com/script/QGXvTq1n-Rainbow-Fractals-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXL/
- type: indicator
- pine_id: PUB;70b41aead66b4e05936211a29e64b618
- version: 1.0

## Description

just a chill fractals indicator, some simple code but pretty straightforward nonetheless! [symbol="NSE:NIFTY1!"]NSE:NIFTY1![/symbol]

## Source Code

````pine
//@version=6
indicator("Rainbow Fractals", overlay=true)

// --- Fractal Logic ---
isHighFractal = high[2] > high[4] and high[2] > high[3] and high[2] > high[1] and high[2] > high[0]
isLowFractal  = low[2] < low[4] and low[2] < low[3] and low[2] < low[1] and low[2] < low[0]

// --- Rainbow Color Cycling ---
var int colorIndex = 0
rainbowColors = array.from(
     color.red, 
     color.orange, 
     color.yellow, 
     color.green, 
     color.blue, 
     color.purple
 )

// We only want to advance the color if a fractal is actually found
bool anyFractal = isHighFractal or isLowFractal

// Get the current color from the array
color currentColor = array.get(rainbowColors, colorIndex)

// Update the index for the NEXT bar only if a fractal was found today
if anyFractal
    colorIndex := (colorIndex + 1) % array.size(rainbowColors)

// --- Plotting ---
// Use 'currentColor' for the shapes
plotshape(isHighFractal, 
     title="High Fractal", 
     style=shape.triangleup, 
     location=location.abovebar, 
     color=currentColor, 
     size=size.small, 
     offset=-2)

plotshape(isLowFractal, 
     title="Low Fractal", 
     style=shape.triangledown, 
     location=location.belowbar, 
     color=currentColor, 
     size=size.small, 
     offset=-2)
````
