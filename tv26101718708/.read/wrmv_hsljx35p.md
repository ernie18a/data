# WRMV

- url: https://www.tradingview.com/script/HSLjX35p-WRMV/
- type: indicator
- pine_id: PUB;33b67d3e391a49ca9a66896033791357
- version: 1.0

## Description

Find short term tight setups

Inspired by Deepvue & Richard Moglen's RMV

## Source Code

````pine
//@version=6
indicator("WRMV", "WRMV", overlay=false, format=format.percent, precision=2, max_bars_back=1000)

priceSrc  = close
basisType = "EMA"
lwlen     = 4
lookback  = 20

belowLevelColor = color.lime
aboveMaColor    = color.rgb(70, 130, 180)
belowMaColor    = color.rgb(70, 130, 180)
neutralColor    = color.rgb(70, 130, 180)

lowLevel         = 20.0
useBelowColor    = true
useMaColors      = true

useExpansionColor      = true
requireExpansionRising = true
expansionUpColor       = color.rgb(0, 102, 255)
expansionDownColor     = color.rgb(255, 102, 102)

showMA1 = false
ma1Type = "SMA"
ma1Len  = 5
ma1Color = color.white
maWidth = 1

showHighLine = true
highLevel    = 80.0
highColor    = color.white
highWidth    = 1

showLowLine = true
lowColor    = color.white
lowWidth    = 1

showCrossSignal = true
crossColor      = color.lime

f_maType(_price, _len, _type) =>
    switch _type
        "SMA"  => ta.sma(_price, _len)
        "EMA"  => ta.ema(_price, _len)
        "WMA"  => ta.wma(_price, _len)
        "RMA"  => ta.rma(_price, _len)
        "HMA"  => ta.hma(_price, _len)
        "VWMA" => ta.vwma(_price, _len)
        => ta.sma(_price, _len)

f_wrmv(_price, _RMVLen, _wrmvLen, _type) =>
    float basis = f_maType(_price, _RMVLen, _type)
    float dev   = ta.stdev(_price, _RMVLen)
    float RMV   = ((basis + dev) - (basis - dev)) / basis

    float RMVSum = 0.0
    int len = bar_index < _wrmvLen ? bar_index : _wrmvLen

    for i = 1 to len
        RMVSum += RMV[i] > RMV ? 0 : 1

    bar_index >= _RMVLen and len > 0 ? (RMVSum / len) * 100 : na

wrmv = f_wrmv(priceSrc, lwlen, lookback, basisType)

wrmvMA1 = showMA1 ? f_maType(wrmv, ma1Len, ma1Type) : na

isBelowLowLevel = not na(wrmv) and wrmv < lowLevel

wasBelowLowLevel   = not na(wrmv[1]) and wrmv[1] < lowLevel
isNowAboveLowLevel = not na(wrmv) and wrmv >= lowLevel
isExpansionRising  = not na(wrmv[1]) and wrmv > wrmv[1]

isExpansionBarAfterLow =
     useExpansionColor and
     wasBelowLowLevel and
     isNowAboveLowLevel and
     (not requireExpansionRising or isExpansionRising)

isExpansionUp = close >= open

expansionBarColor = isExpansionUp ? expansionUpColor : expansionDownColor

maBasedColor = wrmv > wrmvMA1 ? aboveMaColor : belowMaColor

baseColor = neutralColor

if useMaColors and showMA1 and not na(wrmvMA1)
    baseColor := maBasedColor

if useBelowColor and isBelowLowLevel
    baseColor := belowLevelColor

wrmvColor = isExpansionBarAfterLow ? expansionBarColor : baseColor

crossUp = showMA1 and not na(wrmvMA1) and ta.crossover(wrmv, wrmvMA1)

plot(wrmv, "wrmv", color=wrmvColor, linewidth=2, style=plot.style_columns)

plot(showMA1 ? wrmvMA1 : na,
     "MA 1",
     color=ma1Color,
     linewidth=maWidth)

plot(showHighLine ? highLevel : na,
     "High Line",
     color=highColor,
     linewidth=highWidth)

plot(showLowLine ? lowLevel : na,
     "Low Line",
     color=lowColor,
     linewidth=lowWidth)

plotshape(showCrossSignal and crossUp,
     title="wrmv Cross Up Above MA",
     style=shape.triangleup,
     location=location.bottom,
     size=size.tiny,
     color=crossColor)
````
