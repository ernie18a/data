<!-- tradingview-pine-id: PUB;a0681cac62b244e39182c0a34c470ee0 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Liquidity Pools

Source: https://www.tradingview.com/script/m6i0HG9x-Liquidity-Pools/

## Description

This indicator uses SMC (ICT) concept for valid liquidity pools' identification.
It maps active liquidity pools using confirmed structural swing highs and swing lows. It is built on the same structural swing comparison logic as the SMC Structure Identifier, but focuses specifically on unswept structural highs and lows.

The swing logic uses configurable lookback and forward confirmation windows. Raw swings are filtered into structural swings by comparing consecutive highs and lows. If multiple swings of the same type occur before an opposite swing confirms structure, only the most extreme swing is kept. These surviving structural swings become potential liquidity pools.

Features:
• Confirmed swing high and swing low detection
• Structural swing filtering with overwritten swing handling
• Active liquidity levels from structural highs and lows
• Automatic invalidation when liquidity is swept
• Optional hiding or graying out of swept pools
• Configurable maximum pool age in bars
• Customizable high-side and low-side liquidity colors
• Customizable pool line width and line style
• Optional display of structural and ignored swing markers

Logic:
A liquidity pool is created from a structural swing high or structural swing low.

High-side liquidity:
• Created from confirmed structural highs
• Remains active while price stays below it
• Becomes invalid when a later candle’s high trades above the level

Low-side liquidity:
• Created from confirmed structural lows
• Remains active while price stays above it
• Becomes invalid when a later candle’s low trades below the level

Older active pools can be automatically removed using the maximum pool age setting, which helps keep the chart focused on recent liquidity instead of historical levels.

This tool is intended for traders who use market structure, swing points, and liquidity concepts in discretionary analysis.

Note:
1. Liquidity inside SMC is subjective and has many representations; this indicator is an attempt to implement on of the simplest variations into the code. Regulate Lookforward and Lookback variables to find the most suitable liquidity pools from swings for you.
2. This indicator does not provide buy or sell signals. It is a visual liquidity-mapping tool and should be used together with your own trading plan, risk management, and additional analysis.

---

## Source Code

````pine
//@version=6
indicator("Liquidity Pools", overlay=true, max_labels_count=500, max_lines_count=500)

lookback = input.int(5, "Lookback", minval=1)
forward = input.int(3, "Forward", minval=1)

showStructuralSwings = input.bool(true, "Show Structural Swings", group="Swings")
showIgnoredSwings = input.bool(true, "Show Ignored/Overwritten Swings", group="Swings")
showLiquidity = input.bool(true, "Show Liquidity Pools", group="Liquidity")
hideSweptPools = input.bool(true, "Hide Swept Pools", group="Liquidity")
maxPoolAge = input.int(200, "Max Pool Age In Bars", minval=1, maxval=5000, group="Liquidity")

structuralColor = input.color(color.new(color.blue, 90), "Structural Swing Color", group="Swings")
ignoredColor = input.color(color.new(color.gray, 90), "Ignored Swing Color", group="Swings")
markerSizeInput = input.string("Tiny", "Swing Marker Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Swings")

highPoolColor = input.color(color.new(color.red, 0), "High Liquidity Color", group="Liquidity")
lowPoolColor = input.color(color.new(color.green, 0), "Low Liquidity Color", group="Liquidity")
sweptPoolColor = input.color(color.new(color.gray, 70), "Swept Pool Color", group="Liquidity")
poolLineWidth = input.int(1, "Pool Line Width", minval=1, maxval=5, group="Liquidity")
poolLineStyleInput = input.string("Dotted", "Pool Line Style", options=["Solid", "Dashed", "Dotted"], group="Liquidity")

markerSize = switch markerSizeInput
    "Tiny" => size.tiny
    "Small" => size.small
    "Normal" => size.normal
    "Large" => size.large
    => size.huge

poolLineStyle = switch poolLineStyleInput
    "Solid" => line.style_solid
    "Dotted" => line.style_dotted
    => line.style_dashed

candidateHigh = high[forward]
candidateLow = low[forward]

isSwingHigh = true
isSwingLow = true

for j = 1 to lookback
    if high[forward + j] > candidateHigh
        isSwingHigh := false

    if low[forward + j] < candidateLow
        isSwingLow := false

for j = 0 to forward - 1
    if high[j] > candidateHigh
        isSwingHigh := false

    if low[j] < candidateLow
        isSwingLow := false

rawHigh = isSwingHigh ? candidateHigh : na
rawLow = isSwingLow ? candidateLow : na
rawHighBar = bar_index - forward
rawLowBar = bar_index - forward

var int activeType = 0
var float activeValue = na
var int activeBar = na
var label activeMarker = na

var array<float> activeHighValues = array.new<float>()
var array<int> activeHighBars = array.new<int>()
var array<line> activeHighLines = array.new<line>()

var array<float> activeLowValues = array.new<float>()
var array<int> activeLowBars = array.new<int>()
var array<line> activeLowLines = array.new<line>()

makeMarker(int x, float y, color markerColor) =>
    label.new(
         x=x,
         y=y,
         text="",
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_circle,
         color=markerColor,
         textcolor=color.white,
         size=markerSize)

markIgnored(label marker) =>
    if not na(marker)
        if showIgnoredSwings
            label.set_color(marker, ignoredColor)
        else
            label.delete(marker)

markStructural(label marker) =>
    if not na(marker)
        if showStructuralSwings
            label.set_color(marker, structuralColor)
        else
            label.delete(marker)

addLiquidityPool(int poolType, float value, int pivotBar) =>
    if showLiquidity
        color poolColor = poolType == 1 ? highPoolColor : lowPoolColor
        line poolLine = line.new(
             x1=pivotBar,
             y1=value,
             x2=bar_index,
             y2=value,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=poolColor,
             style=poolLineStyle,
             width=poolLineWidth)

        if poolType == 1
            array.push(activeHighValues, value)
            array.push(activeHighBars, pivotBar)
            array.push(activeHighLines, poolLine)
        else
            array.push(activeLowValues, value)
            array.push(activeLowBars, pivotBar)
            array.push(activeLowLines, poolLine)

updatePoolLines() =>
    if array.size(activeHighLines) > 0
        for i = array.size(activeHighLines) - 1 to 0
            int pivotBar = array.get(activeHighBars, i)
            line poolLine = array.get(activeHighLines, i)

            if bar_index - pivotBar > maxPoolAge
                line.delete(poolLine)
                array.remove(activeHighValues, i)
                array.remove(activeHighBars, i)
                array.remove(activeHighLines, i)
                true
            else
                line.set_x2(poolLine, bar_index)
                true

    if array.size(activeLowLines) > 0
        for i = array.size(activeLowLines) - 1 to 0
            int pivotBar = array.get(activeLowBars, i)
            line poolLine = array.get(activeLowLines, i)

            if bar_index - pivotBar > maxPoolAge
                line.delete(poolLine)
                array.remove(activeLowValues, i)
                array.remove(activeLowBars, i)
                array.remove(activeLowLines, i)
                true
            else
                line.set_x2(poolLine, bar_index)
                true

validatePools() =>
    if array.size(activeHighValues) > 0
        for i = array.size(activeHighValues) - 1 to 0
            float poolValue = array.get(activeHighValues, i)
            line poolLine = array.get(activeHighLines, i)

            if high > poolValue
                line.set_x2(poolLine, bar_index)
                if hideSweptPools
                    line.delete(poolLine)
                else
                    line.set_color(poolLine, sweptPoolColor)

                array.remove(activeHighValues, i)
                array.remove(activeHighBars, i)
                array.remove(activeHighLines, i)

    if array.size(activeLowValues) > 0
        for i = array.size(activeLowValues) - 1 to 0
            float poolValue = array.get(activeLowValues, i)
            line poolLine = array.get(activeLowLines, i)

            if low < poolValue
                line.set_x2(poolLine, bar_index)
                if hideSweptPools
                    line.delete(poolLine)
                else
                    line.set_color(poolLine, sweptPoolColor)

                array.remove(activeLowValues, i)
                array.remove(activeLowBars, i)
                array.remove(activeLowLines, i)

processSwing(int swingType, float swingValue, int swingBar, int currentType, float currentValue, int currentBar, label currentMarker) =>
    label newMarker = na
    int nextType = currentType
    float nextValue = currentValue
    int nextBar = currentBar
    label nextMarker = currentMarker

    if showIgnoredSwings or showStructuralSwings
        newMarker := makeMarker(swingBar, swingValue, ignoredColor)

    if currentType == 0
        nextType := swingType
        nextValue := swingValue
        nextBar := swingBar
        nextMarker := newMarker
        markStructural(nextMarker)

    else if swingType != currentType
        markStructural(currentMarker)
        addLiquidityPool(currentType, currentValue, currentBar)

        nextType := swingType
        nextValue := swingValue
        nextBar := swingBar
        nextMarker := newMarker
        markStructural(nextMarker)

    else
        bool replacesActive = swingType == 1 ? swingValue > currentValue : swingValue < currentValue

        if replacesActive
            markIgnored(currentMarker)
            nextType := swingType
            nextValue := swingValue
            nextBar := swingBar
            nextMarker := newMarker
            markStructural(nextMarker)
        else
            markIgnored(newMarker)

    [nextType, nextValue, nextBar, nextMarker]

updatePoolLines()
validatePools()

if isSwingHigh
    [highType, highValue, highBar, highMarker] = processSwing(1, rawHigh, rawHighBar, activeType, activeValue, activeBar, activeMarker)
    activeType := highType
    activeValue := highValue
    activeBar := highBar
    activeMarker := highMarker

if isSwingLow
    [lowType, lowValue, lowBar, lowMarker] = processSwing(-1, rawLow, rawLowBar, activeType, activeValue, activeBar, activeMarker)
    activeType := lowType
    activeValue := lowValue
    activeBar := lowBar
    activeMarker := lowMarker
````
