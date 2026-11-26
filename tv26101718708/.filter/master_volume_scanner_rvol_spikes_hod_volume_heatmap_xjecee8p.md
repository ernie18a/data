# Master Volume Scanner (RVOL + Spikes + HOD Volume + Heatmap)

- url: https://www.tradingview.com/script/XJeceE8p-Master-Volume-Scanner-RVOL-Spikes-HOD-Volume-Heatmap/
- type: indicator
- pine_id: PUB;4256ddd7174947f7bf10a515c36902bb
- version: 1.0

## Description

RVOL scanner

Volume spike detector

Highest volume of the day tracker

Heatmap bar coloring

Labels + alerts for everythin

## Source Code

````pine
//@version=5
indicator("Master Volume Scanner (RVOL + Spikes + HOD Volume + Heatmap)", overlay=true, max_labels_count=500)

//========================
// Inputs
//========================
len = input.int(20, "Average Volume Length")
rvolThresh = input.float(2.0, "RVOL Threshold", step=0.1)
volSpikeMult = input.float(1.5, "Volume Spike Multiplier", step=0.1)
heatmapMult = input.float(2.0, "Heatmap Spike Multiplier", step=0.1)
showHeatmap = input.bool(true, "Show Heatmap Bar Colors")
showLabels = input.bool(true, "Show Labels")

//========================
// Core Calculations
//========================
avgVol = ta.sma(volume, len)
rvol = volume / avgVol

isSpike = volume > avgVol * volSpikeMult
isHighRvol = rvol > rvolThresh

//========================
// Highest Volume of the Day
//========================
isNewDay = ta.change(time("D"))
dayHighVol = 0.0
dayHighVol := isNewDay ? volume : math.max(dayHighVol[1], volume)
isHighest = volume == dayHighVol

//========================
// Heatmap Coloring
//========================
heatSpike = volume > avgVol * heatmapMult
barcolor(showHeatmap and heatSpike ? color.new(color.red, 0) : na)

//========================
// Labels
//========================
if showLabels and isSpike
    label.new(bar_index, high, "Spike", style=label.style_label_up, color=color.orange, textcolor=color.black, size=size.tiny)

if showLabels and isHighRvol
    label.new(bar_index, high, "RVOL", style=label.style_label_up, color=color.green, textcolor=color.black, size=size.tiny)

if showLabels and isHighest
    label.new(bar_index, high, "HOD Vol", style=label.style_label_up, color=color.yellow, textcolor=color.black, size=size.small)

//========================
// Alerts
//========================
alertcondition(isSpike, "Volume Spike", "Volume spike detected")
alertcondition(isHighRvol, "High RVOL", "High RVOL detected")
alertcondition(isHighest, "Highest Volume of Day", "New highest volume candle today")

//========================
// RVOL Plot (lower panel style)
//========================
plot(rvol, "RVOL", color=color.new(color.blue, 0))
hline(rvolThresh, "RVOL Threshold", color=color.red)
````
