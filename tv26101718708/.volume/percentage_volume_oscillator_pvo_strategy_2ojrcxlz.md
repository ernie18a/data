# Percentage Volume Oscillator (PVO) Strategy

- url: https://www.tradingview.com/script/2ojRCxLZ-Percentage-Volume-Oscillator-PVO-Strategy/
- type: indicator
- pine_id: PUB;yPNuJJQ5HFzlwtmXUUNi7iXZjI9aygFr
- version: 1.0

## Description

The Percentage Volume Oscillator (PVO) is a momentum oscillator for volume. 
 PVO measures the difference between two volume-based moving averages as a 
 percentage of the larger moving average. As with MACD and the Percentage Price 
 Oscillator (PPO), it is shown with a signal line, a histogram and a centerline. 
 PVO is positive when the shorter volume EMA is above the longer volume EMA and 
 negative when the shorter volume EMA is below. This indicator can be used to define 
 the ups and downs for volume, which can then be use to confirm or refute other signals. 
 Typically, a breakout or support break is validated when PVO is rising or positive. 

 WARNING:
  This script to change bars colors.

## Source Code

````pine
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 26/09/2017
// The Percentage Volume Oscillator (PVO) is a momentum oscillator for volume. 
// PVO measures the difference between two volume-based moving averages as a 
// percentage of the larger moving average. As with MACD and the Percentage Price 
// Oscillator (PPO), it is shown with a signal line, a histogram and a centerline. 
// PVO is positive when the shorter volume EMA is above the longer volume EMA and 
// negative when the shorter volume EMA is below. This indicator can be used to define 
// the ups and downs for volume, which can then be use to confirm or refute other signals. 
// Typically, a breakout or support break is validated when PVO is rising or positive. 
//
// WARNING:
//  This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="Percentage Volume Oscillator (PVO)", shorttitle="PVO")
LengthShortEMA = input(12, minval=1)
LengthLongEMA = input(26, minval=1)
LengthSignalEMA = input(9, minval=1)
hline(0, color=gray, linestyle=line)
xShortEMA = ema(volume , LengthShortEMA)
xLongEMA = ema(volume , LengthLongEMA)
xPVO = ((xShortEMA - xLongEMA) / xLongEMA) * 100
xSignalEMA = ema(xPVO , LengthSignalEMA)
xPVOHisto = xPVO - xSignalEMA
pos = iff(xSignalEMA < xPVO, -1,
	   iff(xSignalEMA > xPVO, 1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue)
plot(xPVO, color=blue, title="PVO")
plot(xSignalEMA, color=red, title="Signal")
plot(xPVOHisto, color=gray, title="PVO Histo", style=histogram)
````
