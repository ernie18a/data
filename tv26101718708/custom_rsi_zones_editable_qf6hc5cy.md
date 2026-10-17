# Custom RSI Zones (Editable)

- url: https://www.tradingview.com/script/Qf6hC5cy-Custom-RSI-Zones-Editable/
- type: indicator
- pine_id: PUB;947244a0855744a3882402a1324429ab
- version: 1.0

## Description

RSI Zone are helpful to find out the trend reversal.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © vividhcapital

//@version=6
indicator("Custom RSI Zones (Editable)", overlay=false)

// ===== INPUTS =====

// RSI Settings
groupRSI = "RSI Settings"
rsiLength = input.int(14, minval=1, title="RSI Period", group=groupRSI)
rsiSource = input.source(close, title="RSI Source", group=groupRSI)
rsiColor  = input.color(color.blue, title="RSI Line Color", group=groupRSI)

// Upper Zone Settings
groupUpper = "Upper Zone"
upperLow   = input.int(60, minval=0, maxval=100, title="Upper Zone Low", group=groupUpper)
upperHigh  = input.int(70, minval=0, maxval=100, title="Upper Zone High", group=groupUpper)
upperColor = input.color(color.red, title="Upper Zone Color", group=groupUpper)

// Lower Zone Settings
groupLower = "Lower Zone"
lowerLow   = input.int(30, minval=0, maxval=100, title="Lower Zone Low", group=groupLower)
lowerHigh  = input.int(40, minval=0, maxval=100, title="Lower Zone High", group=groupLower)
lowerColor = input.color(color.green, title="Lower Zone Color", group=groupLower)

// Background Highlight
groupVisual = "Visual Settings"
showBg = input.bool(true, title="Highlight Background in Zones", group=groupVisual)

// ===== CALCULATION =====
rsiValue = ta.rsi(rsiSource, rsiLength)

// ===== PLOT RSI =====
plot(rsiValue, title="RSI", color=rsiColor, linewidth=2)

// ===== LEVEL LINES =====
hUpperLow  = hline(upperLow,  "Upper Low")
hUpperHigh = hline(upperHigh, "Upper High")

hLowerLow  = hline(lowerLow,  "Lower Low")
hLowerHigh = hline(lowerHigh, "Lower High")

hline(50, "Midline (50)", color=color.gray)

// ===== ZONE FILLS =====
fill(hUpperLow, hUpperHigh, color=color.new(upperColor, 85))
fill(hLowerLow, hLowerHigh, color=color.new(lowerColor, 85))

// ===== BACKGROUND =====
bgcolor(showBg and (rsiValue >= upperLow and rsiValue <= upperHigh) ? color.new(upperColor, 90) : na)
bgcolor(showBg and (rsiValue >= lowerLow and rsiValue <= lowerHigh) ? color.new(lowerColor, 90) : na)
````
