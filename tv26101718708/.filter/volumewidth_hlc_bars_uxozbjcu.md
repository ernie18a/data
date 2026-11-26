# Volume-Width HLC Bars

- url: https://www.tradingview.com/script/UxOZBjcu-Volume-Width-HLC-Bars/
- type: indicator
- pine_id: PUB;8a881bfd63604b31b06cf4894bd20ee0
- version: 2.0

## Description

[b]***Set your chart type to HLC bars with Thin Bars enabled and set your bar colors to match the indicator's colors.***[/b]

Tradingview has a built-in chart type called Volume Candles which changes the width of the candles according to volume. But I'm a bar guy, so I made this indicator to give us volume normalized bars!

The settings will let you change the lookback period, scaling, bar widths and colors however you like. Just make sure you follow the instructions in bold above.

## Source Code

````pine
//@version=6
indicator("Volume-Width HLC Bars", overlay=true, max_lines_count=500)

// Settings
lookback = input.int(100, "Volume Normalization Lookback", minval=10)
minWidth = input.int(1, "Minimum Bar Width", minval=1, maxval=5)
maxWidth = input.int(10, "Maximum Bar Width", minval=1, maxval=10)
useLogScaling = input.bool(false, "Use Log Scaling")

// Color settings
useBullBearColors = input.bool(true, "Use Bull/Bear Colors")

neutralColor = input.color(color.new(color.gray, 20), "Neutral Bar Color")
bullColor = input.color(color.new(color.green, 20), "Bull Color")
bearColor = input.color(color.new(color.red, 20), "Bear Color")

// Bar color selection
barColor = useBullBearColors ? (close >= open ? bullColor : bearColor) : neutralColor

// Volume source
volForScaling = useLogScaling ? math.log(math.max(volume, 1)) : volume

// Normalize volume
volMin = ta.lowest(volForScaling, lookback)
volMax = ta.highest(volForScaling, lookback)
volNorm = volMax == volMin ? 0.5 : (volForScaling - volMin) / (volMax - volMin)

barWidth = math.round(minWidth + volNorm * (maxWidth - minWidth))

// Draw HL bar
line.new(
     bar_index, low,
     bar_index, high,
     xloc=xloc.bar_index,
     color=barColor,
     width=barWidth
)
````
