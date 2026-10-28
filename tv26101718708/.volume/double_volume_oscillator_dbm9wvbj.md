# Double Volume Oscillator

- url: https://www.tradingview.com/script/DBm9wVBj-Double-Volume-Oscillator/
- type: indicator
- pine_id: PUB;ec29ffd065c5417fa875fcb43c2ea1a9
- version: 1.0

## Description

PERFECT DOUBLE VOLUME OSCILLATOR this volume oscillator provides a clear view of volume, that it can be measured easily for better trading

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © rain_mustfall

//@version=5
indicator("Double Volume Oscillator", overlay=false)

// ===== First Oscillator =====
shortLength1 = input.int(50, title="Short Length 1")
longLength1  = input.int(200, title="Long Length 1")

shortMA1 = ta.ema(volume, shortLength1)
longMA1  = ta.ema(volume, longLength1)

vo1 = shortMA1 - longMA1

// ===== Second Oscillator =====
shortLength2 = input.int(20, title="Short Length 2")
longLength2  = input.int(100, title="Long Length 2")

shortMA2 = ta.ema(volume, shortLength2)
longMA2  = ta.ema(volume, longLength2)

vo2 = shortMA2 - longMA2

// ===== Plot =====
plot(vo1, title="VO 50/200", color=color.blue, linewidth=2)
plot(vo2, title="VO 20/100", color=color.orange, linewidth=2)

// ===== Zero Line =====
hline(0, "Zero Line", color=color.white, linestyle=hline.style_solid, linewidth=2)
````
