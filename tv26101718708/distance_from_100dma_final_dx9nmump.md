# Distance from 100DMA (Final)

- url: https://www.tradingview.com/script/DX9nMuMp-Distance-from-100DMA-Final/
- type: indicator
- pine_id: PUB;ad329cce12e4453f860c59732f0e5864
- version: 1.0

## Description

Distance from 100DMA (Final)  tracks the distance of 100DMA. Used as one of the fillters in my system to tellls me how much I should allocate in a bull market in right conditions

## Source Code

````pine
//@version=6
indicator("Distance from 100DMA (Final)", overlay=true)

// === 100DMA ===
ma100 = ta.sma(close, 100)

// === Distance calculation ===
distance = (close - ma100) / ma100

// === Regimes (FINAL TWEAKED) ===
weak = distance < 0.04
neutral = distance >= 0.04 and distance <= 0.18
strong = distance > 0.18

// === Background colors ===
bgcolor(
     strong ? color.new(color.green, 85) :
     neutral ? color.new(color.yellow, 85) :
     weak ? color.new(color.red, 85) :
     na
)

// === Plot 100DMA line ===
plot(ma100, color=color.orange, linewidth=2)

// === OPTIONAL: show distance value ===
plotchar(distance, title="Distance", location=location.top)
````
