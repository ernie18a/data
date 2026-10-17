# Simple Swing High/Low Dots

- url: https://www.tradingview.com/script/jVoiMSBZ-Simple-Swing-High-Low-Dots/
- type: indicator
- pine_id: PUB;5be63370d40742579121b455ce62df15
- version: 1.0

## Description

Simple Swing High/Low Dots to help keep track of structure

## Source Code

````pine
//@version=6
indicator("Simple Swing High/Low Dots", overlay=true, max_labels_count=500)

// === Inputs ===
leftBars  = input.int(5, "Left Bars",  minval=1)
rightBars = input.int(5, "Right Bars", minval=1)

// === Detect Swings ===
swingHigh = ta.pivothigh(high, leftBars, rightBars)
swingLow  = ta.pivotlow(low, leftBars, rightBars)

// === Plot Dots Exactly on Swing High/Low ===
plotshape(series = swingHigh, title="Swing High", 
          location=location.absolute, color=color.red, 
          style=shape.circle, size=size.tiny, offset = -rightBars)

plotshape(series = swingLow, title="Swing Low", 
          location=location.absolute, color=color.green, 
          style=shape.circle, size=size.tiny, offset = -rightBars)
````
