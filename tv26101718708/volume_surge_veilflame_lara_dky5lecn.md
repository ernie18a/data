# Volume Surge [Veilflame Lara]

- url: https://www.tradingview.com/script/dkY5lECn/
- type: indicator
- pine_id: PUB;e399c4c1bdf04024972d36a86143b0a6
- version: 5.0

## Description

**Volume Surge [幻焰]** is designed to identify candlesticks with volume that is significantly above the recent average.

The surge threshold is inspired by the standard normal distribution: **z = 1.2816** represents the **90th percentile**, meaning the candle’s volume is higher than roughly 90% of the sample, or close to the top 10% highest-volume events.

Because volume surge candles often suggest institutional participation, the open price of a surge candle can become an important level. This indicator marks that open price with a dotted line, representing a potential area institutions may defend.

When price later tested that level, the line changes to a faded gray, indicating that the liquidity has been taken.

## Source Code

````pine
//@version=6
indicator("Volume Surge [Veilflame Lara]", shorttitle="Volume Surge [Veilflame Lara ]", overlay=true, max_lines_count=500)


period = input.int(20, "Volume EMA Period", minval=1)
multiplier = input.float(1.2816, "Surge multiplier", minval=0.0, step=0.05)
lineLength = input.int(12, "Open line length", minval=1)
showOpenLines = input.bool(true, "Show open price lines")
maxVisibleOpenLines = input.int(150, "Max visible open lines", minval=10, maxval=500)

surgeVolume = volume > ta.ema(volume, period) * multiplier
upCandle = close > open
downCandle = open > close

surgeUpColor = color.new(color.rgb(99, 187, 140), 10)
surgeDownColor = color.new(color.rgb(255, 82, 82), 10)
normalUpColor = color.white
normalDownColor = color.rgb(104, 114, 149)
touchedLineColor = color.new(color.gray, 60)

barcolor(
     surgeVolume and upCandle ? surgeUpColor :
     surgeVolume and downCandle ? surgeDownColor :
     upCandle ? normalUpColor :
     normalDownColor
 )

var line[] allLines = array.new_line()

var line[] activeLines = array.new_line()
var float[] activeLevels = array.new_float()
var int[] activeSourceBars = array.new_int()

// Check only lines that have not been touched yet.
if array.size(activeLines) > 0
    for i = array.size(activeLines) - 1 to 0
        activeLine = array.get(activeLines, i)
        level = array.get(activeLevels, i)
        sourceBar = array.get(activeSourceBars, i)

        touchedByLaterCandle = bar_index > sourceBar and low <= level and high >= level

        if touchedByLaterCandle
            line.set_color(activeLine, touchedLineColor)

            array.remove(activeLines, i)
            array.remove(activeLevels, i)
            array.remove(activeSourceBars, i)

if surgeVolume and showOpenLines
    newLine = line.new(
         bar_index,
         open,
         bar_index + lineLength,
         open,
         xloc=xloc.bar_index,
         extend=extend.none,
         color=upCandle ? surgeUpColor : surgeDownColor,
         width=2,
         style=line.style_dotted
     )

    array.push(allLines, newLine)

    array.push(activeLines, newLine)
    array.push(activeLevels, open)
    array.push(activeSourceBars, bar_index)

    while array.size(allLines) > maxVisibleOpenLines
        oldLine = array.shift(allLines)
        activeIndex = array.indexof(activeLines, oldLine)

        if activeIndex != -1
            array.remove(activeLines, activeIndex)
            array.remove(activeLevels, activeIndex)
            array.remove(activeSourceBars, activeIndex)

        line.delete(oldLine)
````
