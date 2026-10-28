# Volume with EMA

- url: https://www.tradingview.com/script/nz7SRvlt/
- type: indicator
- pine_id: PUB;176556f683fb4d7791a9496676bb9732
- version: 2.0

## Description

This is the Basic Volume Indicator from TradingView just with an EMA instead of an SMA. Additonally there are little arrows indicating when the Volume is above the EMA.

## Source Code

````pine
//@version=6
indicator("Volume with EMA", overlay=false, format=format.volume)

// === INPUTS ===
length        = input.int(20,          title="EMA Length",                  minval=1)
showEMA       = input.bool(true,       title="Show EMA")
colorUp       = input.color(color.green, title="Up Volume Color")
colorDown     = input.color(color.red,   title="Down Volume Color")
highVolMultiplier = input.float(1.5,   title="High Volume Threshold (x EMA)")

// === DATA ===
vol    = volume
emaVol = ta.ema(vol, length)

// === COLOR LOGIC ===
// Neutral fällt weg – Up/Down basierend auf Kerzenrichtung
volColor = close >= close[1] ? colorUp : colorDown

// === PLOTS ===
plot(vol,                        style=plot.style_columns, color=volColor,      title="Volume")
plot(showEMA ? emaVol : na,      color=color.yellow,       linewidth=2,         title="Volume EMA")

// === HIGHLIGHT HIGH VOLUME ===
isHighVol = vol > emaVol * highVolMultiplier

plotshape(isHighVol,
     title="High Volume Marker",
     location=location.top,
     style=shape.triangleup,
     size=size.tiny,
     color=color.yellow)
````
