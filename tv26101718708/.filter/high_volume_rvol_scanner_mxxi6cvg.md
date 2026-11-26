# High Volume + RVOL Scanner

- url: https://www.tradingview.com/script/MxxI6cvG-High-Volume-RVOL-Scanner/
- type: indicator
- pine_id: PUB;60ea393b6b9e4304b1d41f5a03c91d7e
- version: 1.0

## Description

What this version does
Shows RVOL line under your chart

Marks candles with Spike or RVOL labels

Alerts you when volume is abnormal

Clean and fast for day trading or swing trading

## Source Code

````pine
//@version=5
indicator("High Volume + RVOL Scanner", overlay=true)

// Inputs
len = input.int(20, "Average Volume Length")
rvolThresh = input.float(2.0, "RVOL Threshold")
volSpikeMult = input.float(1.5, "Volume Spike Multiplier")

// Calculations
avgVol = ta.sma(volume, len)
rvol = volume / avgVol
isSpike = volume > avgVol * volSpikeMult
isHighRvol = rvol > rvolThresh

// Plot labels
plotshape(isSpike, title="Volume Spike", style=shape.labelup, 
     color=color.orange, text="Spike", size=size.tiny)

plotshape(isHighRvol, title="High RVOL", style=shape.labelup, 
     color=color.green, text="RVOL", size=size.tiny)

// Alerts
alertcondition(isSpike, "Volume Spike", "Volume spike detected")
alertcondition(isHighRvol, "High RVOL", "High RVOL detected")

// Display RVOL on chart
plot(rvol, "RVOL", color=color.new(color.blue, 0))
hline(rvolThresh, "RVOL Threshold", color=color.red)
````
