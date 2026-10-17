# Eao_Volt

- url: https://www.tradingview.com/script/jbtuocIF-Eao-Volt/
- type: indicator
- pine_id: PUB;9d8027f4d332461e95cf301fb6d2aa8c
- version: 1.0

## Description

Multi-condition trend indicator using smoothed highs/lows and range extremes to filter noise. Line trails as dynamic support/resistance; color flips on confirmed regime change. Arrows signal reversals. Adjustable Amplitude for scalping through swing trading. Best used with higher timeframes alignment and proper risk management always.

[image]https://www.tradingview.com/x/53Qdddlx/[/image][image]https://www.tradingview.com/x/j77t5brf/[/image][image]https://www.tradingview.com/x/lOHb2n48/[/image]

## Source Code

````pine
//@version=6
indicator("Eao_Volt", overlay=true)

// Contact
// Eaofx99@gmail.com

//--- input parameters
amplitude = input.int(5, minval=1, title="Amplitude")

//--- Calculate SMA of High and Low
maHigh = ta.sma(high, amplitude)
maLow = ta.sma(low, amplitude)

//--- Calculate Highest and Lowest over amplitude period
highest = ta.highest(high, amplitude)
lowest = ta.lowest(low, amplitude)

//--- State variables
var float lineValue = na
var float trendColor = 0  // 0 = down (orangered), 1 = up (deepskyblue)

//--- Initialize on first bar
if bar_index == 0
    lineValue := high
    trendColor := 0

//--- Calculate for subsequent bars
if bar_index > 0
    // Downtrend condition
    if maHigh < lineValue[1] and maLow < lineValue[1] and highest < lineValue[1]
        lineValue := highest
        trendColor := trendColor[1]
        if lineValue < lineValue[1]
            trendColor := 0
        if lineValue > lineValue[1]
            trendColor := 1
    // Uptrend condition
    else if maHigh > lineValue[1] and maLow > lineValue[1] and lowest > lineValue[1]
        lineValue := lowest
        trendColor := trendColor[1]
        if lineValue < lineValue[1]
            trendColor := 0
        if lineValue > lineValue[1]
            trendColor := 1
    else
        lineValue := lineValue[1]
        trendColor := trendColor[1]

//--- Detect trend changes for arrows
upArrow = bar_index > 0 and trendColor[1] == 0 and trendColor == 1
downArrow = bar_index > 0 and trendColor[1] == 1 and trendColor == 0

//--- Dynamic color
colLine = trendColor == 1 ? #00BFFF : #FF4500

//--- Plot line
plot(lineValue, title="Line", color=colLine, linewidth=3)

//--- Plot arrows at trend changes
plotshape(upArrow, title="Up", style=shape.triangleup, location=location.belowbar, color=#00BFFF, size=size.small)
plotshape(downArrow, title="Down", style=shape.triangledown, location=location.abovebar, color=#FF4500, size=size.small)
````
