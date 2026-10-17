# Streak Counter

- url: https://www.tradingview.com/script/Q5QJlUoH-Streak-Counter/
- type: indicator
- pine_id: PUB;03b5d5015f504d40bf988832a214b41b
- version: 2.0

## Description

Streak Counter tracks consecutive bullish or bearish candles and marks the last bar of each completed run with a color-scaled label. Green for bull streaks, red for bear, both ramping from light to deep as length increases. Configurable minimum streak threshold and color range ceiling. Live bar displays the current in-progress count in real time.

## Source Code

````pine
//@version=5
indicator("Streak Counter", overlay=true)

minBars = input.int(2, title="Minimum streak to display", minval=2, maxval=20)
maxBars = input.int(10, title="Max bars for full color range", minval=3, maxval=50)

isBull = close >= open

var int streak = 1

if bar_index > 0
    prevBull = close[1] >= open[1]
    if isBull == prevBull
        streak := streak + 1
    else
        streak := 1

colorChanged = isBull != (close[1] >= open[1])

streakColor(count, maxCount, bull, transp) =>
    t = math.min(math.max((count - 2) / math.max(maxCount - 2, 1), 0.0), 1.0)
    if bull
        color.rgb(math.round(144 - t * 110), math.round(238 - t * 98), math.round(144 - t * 110), transp)
    else
        color.rgb(math.round(255 - t * 55), math.round(160 - t * 155), math.round(160 - t * 155), transp)

// Closed bar labels
if colorChanged and streak[1] >= minBars
    prevBull = close[1] >= open[1]
    label.new(
         x         = bar_index - 1,
         y         = low[1],
         text      = str.tostring(streak[1]),
         style     = label.style_label_up,
         color     = streakColor(streak[1], maxBars, prevBull, 15),
         textcolor = color.white,
         size      = size.small,
         yloc      = yloc.belowbar
         )

// Live bar label
if barstate.islast
    currentBull = close >= open
    prevBull = close[1] >= open[1]
    liveStreak = currentBull == prevBull ? streak : 1
    var label liveLabel = na
    label.delete(liveLabel)
    liveLabel := label.new(
         x         = bar_index,
         y         = low,
         text      = str.tostring(liveStreak) + "?",
         style     = label.style_label_up,
         color     = streakColor(math.max(liveStreak, 2), maxBars, currentBull, 55),
         textcolor = color.white,
         size      = size.small,
         yloc      = yloc.belowbar
         )
````
