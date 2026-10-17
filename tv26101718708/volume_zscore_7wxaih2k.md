# Volume Z-Score

- url: https://www.tradingview.com/script/7WXAIH2K-Volume-Z-Score/
- type: indicator
- pine_id: PUB;a84116f071834e27a7f87176dd39d1c2
- version: 1.0

## Description

Volume Z-Score highlights candles with statistically unusual volume using a rolling z-score calculation.

The script compares each candle’s volume to the average volume over the selected lookback period, then measures how many standard deviations the current volume is above or below that average.

Candles are colored by volume deviation level:
- Z-score > 1, > 2, and > 3 for unusually high volume
- Z-score < -1, < -2, and < -3 for unusually low volume

The default lookback is 60 candles. Candle colors are fully customizable, and alerts are included for each high-volume and low-volume threshold.

## Source Code

````pine
//@version=6
indicator("Volume Z-Score", overlay=true, max_labels_count=500)

length = input.int(60, "Lookback Candles", minval=2)
paintCandles = input.bool(true, "Paint Candles")

z1Color = input.color(color.yellow, "Z-Score > 1 Color")
z2Color = input.color(color.orange, "Z-Score > 2 Color")
z3Color = input.color(color.red, "Z-Score > 3 Color")
n1Color = input.color(color.aqua, "Z-Score < -1 Color")
n2Color = input.color(color.blue, "Z-Score < -2 Color")
n3Color = input.color(color.purple, "Z-Score < -3 Color")

avgVolume = ta.sma(volume, length)
stdVolume = ta.stdev(volume, length)
volumeZScore = na(avgVolume) or na(stdVolume) or stdVolume == 0.0 ? na : (volume - avgVolume) / stdVolume

isZ3 = not na(volumeZScore) and volumeZScore > 3
isZ2 = volumeZScore > 2 and not isZ3
isZ1 = volumeZScore > 1 and not isZ2 and not isZ3
isN3 = not na(volumeZScore) and volumeZScore < -3
isN2 = volumeZScore < -2 and not isN3
isN1 = volumeZScore < -1 and not isN2 and not isN3

candleColor = isZ3 ? z3Color : isZ2 ? z2Color : isZ1 ? z1Color : isN3 ? n3Color : isN2 ? n2Color : isN1 ? n1Color : na
barcolor(paintCandles ? candleColor : na)

alertcondition(isZ1 or isZ2 or isZ3, title="High Volume Level", message="Volume is above the selected high-volume threshold.")
alertcondition(isZ2 or isZ3, title="High Volume Level 2", message="Volume is above the selected level 2 high-volume threshold.")
alertcondition(isZ3, title="High Volume Level 3", message="Volume is above the selected level 3 high-volume threshold.")
alertcondition(isN1 or isN2 or isN3, title="Low Volume Level", message="Volume is below the selected low-volume threshold.")
alertcondition(isN2 or isN3, title="Low Volume Level 2", message="Volume is below the selected level 2 low-volume threshold.")
alertcondition(isN3, title="Low Volume Level 3", message="Volume is below the selected level 3 low-volume threshold.")

plot(volumeZScore, title="Volume Z-Score", display=display.data_window)
````
