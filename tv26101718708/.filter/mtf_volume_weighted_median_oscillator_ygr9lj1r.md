# MTF Volume Weighted Median Oscillator

- url: https://www.tradingview.com/script/yGR9LJ1r-MTF-Volume-Weighted-Median-Oscillator/
- type: indicator
- pine_id: PUB;702a34d8159c4a38a41e5c94f0860690
- version: 1.0

## Description

Just a multi time frame version of AlphaAlgo's script for my own uses, thought i'd share it

## Source Code

````pine
//@version=6
indicator("MTF Volume Weighted Median Oscillator", "MTF VWMO", overlay=false, explicit_plot_zorder=true)

calcTF = input.timeframe("5", "VWMO Calculation Timeframe")

mainGroup = "Main Settings"
appearanceGroup = "Appearance"

len = input.int(21, "Length", minval=1, group=mainGroup)
extremeLevel = input.float(3.0, "Extreme Level", minval=0.1, step=0.25, group=mainGroup)
smooth = input.bool(true, "Smooth Outputs", group=mainGroup)
ribbon = input.bool(true, "Ribbon", group=mainGroup)
volNormLookback = input.int(21, "Volume Normalization Length", minval=1, group=mainGroup)

green = input.color(#00ffbb, "Bullish Colour", group=appearanceGroup)
red = input.color(#ff1100, "Bearish Colour", group=appearanceGroup)

//==================================================
// VWMO Function
//==================================================
f_vwmoPack(_len, _extremeLevel, _smooth, _ribbon, _volNormLookback) =>
    prices = array.new_float()
    volumes = array.new_float()

    for i = 0 to _len - 1
        array.push(prices, close[i])
        array.push(volumes, volume[i])

    totalVolume = array.sum(volumes)
    midpoint = totalVolume / 2.0
    sortedIndexes = array.sort_indices(prices, order.ascending)

    count = 0.0
    float wMedian = na

    if totalVolume > 0
        for i = 0 to array.size(sortedIndexes) - 1
            idx = array.get(sortedIndexes, i)
            count += array.get(volumes, idx)
            if count >= midpoint
                wMedian := array.get(prices, idx)
                break

    rangeBase = math.max(ta.ema(high - low, 14), syminfo.mintick)

    mom = close - wMedian
    rawHist = mom / rangeBase
    rawMain = (wMedian - ta.ema(wMedian, _len * 3)) / rangeBase

    hist = _smooth ? ta.wma(rawHist, 7) : rawHist
    mainLine = _smooth ? ta.wma(rawMain, 7) : rawMain
    mainSignal = ta.ema(mainLine, _len)

    normalizedVolume = volume / math.max(ta.sma(volume, _volNormLookback), 1.0)

    ribbonState = mainLine >= mainSignal ? 1 : -1
    ribbonStrength = math.min(math.abs(mainLine - mainSignal) / math.max(_extremeLevel, syminfo.mintick), 1.0)

    upperNoOverlap = _ribbon and mainLine > 0 ? math.min(mainLine, mainSignal) : mainLine
    lowerNoOverlap = _ribbon and mainLine < 0 ? math.max(mainLine, mainSignal) : mainLine

    upperFillValue = upperNoOverlap > _extremeLevel ? upperNoOverlap : _extremeLevel
    lowerFillValue = lowerNoOverlap < -_extremeLevel ? lowerNoOverlap : -_extremeLevel

    histMovingTowardZero = math.abs(hist) < nz(math.abs(hist[1]), math.abs(hist))

    histBullCross = ta.crossover(hist, 0)
    histBearCross = ta.crossunder(hist, 0)
    mainBullCross = ta.crossover(mainLine, 0)
    mainBearCross = ta.crossunder(mainLine, 0)
    mainSignalBullCross = ta.crossover(mainLine, mainSignal)
    mainSignalBearCross = ta.crossunder(mainLine, mainSignal)
    overboughtEntry = ta.crossover(mainLine, _extremeLevel)
    overboughtExit = ta.crossunder(mainLine, _extremeLevel)
    oversoldEntry = ta.crossunder(mainLine, -_extremeLevel)
    oversoldExit = ta.crossover(mainLine, -_extremeLevel)
    ribbonBullFlip = ribbonState == 1 and ribbonState[1] == -1
    ribbonBearFlip = ribbonState == -1 and ribbonState[1] == 1

    [hist, mainLine, mainSignal, normalizedVolume, ribbonState, ribbonStrength, upperFillValue, lowerFillValue, histMovingTowardZero, histBullCross, histBearCross, mainBullCross, mainBearCross, mainSignalBullCross, mainSignalBearCross, overboughtEntry, overboughtExit, oversoldEntry, oversoldExit, ribbonBullFlip, ribbonBearFlip]

//==================================================
// True MTF Request
//==================================================
[hist, mainLine, mainSignal, normalizedVolume, ribbonState, ribbonStrength, upperFillValue, lowerFillValue, histMovingTowardZero, histBullCross, histBearCross, mainBullCross, mainBearCross, mainSignalBullCross, mainSignalBearCross, overboughtEntry, overboughtExit, oversoldEntry, oversoldExit, ribbonBullFlip, ribbonBearFlip] = request.security(syminfo.tickerid, calcTF, f_vwmoPack(len, extremeLevel, smooth, ribbon, volNormLookback), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

//==================================================
// Colors
//==================================================
zeroLineColor = color.from_gradient(normalizedVolume, 1.0, 2.0, color.new(chart.fg_color, 90), color.new(chart.fg_color, 0))

ribbonColor = ribbonState == 1 ? color.from_gradient(ribbonStrength, 0.0, 1.0, color.new(green, 0), color.new(green, 80)) : color.from_gradient(ribbonStrength, 0.0, 1.0, color.new(red, 0), color.new(red, 80))

upperTopColor = upperFillValue > extremeLevel ? color.from_gradient(upperFillValue, extremeLevel, extremeLevel * 2.0, color.new(red, 100), color.new(red, 0)) : color.new(red, 100)
lowerBottomColor = lowerFillValue < -extremeLevel ? color.from_gradient(lowerFillValue, -extremeLevel * 2.0, -extremeLevel, color.new(green, 0), color.new(green, 100)) : color.new(green, 100)

histTransparency = histMovingTowardZero ? 75 : 35
histColor = hist >= 0 ? color.new(green, histTransparency) : color.new(red, histTransparency)

//==================================================
// Plots
//==================================================
plot(0, "Zero Line", color=zeroLineColor, linewidth=3)

hline(extremeLevel, "Overbought Line", color=color.new(red, 70), linestyle=hline.style_dashed)
hline(-extremeLevel, "Oversold Line", color=color.new(green, 70), linestyle=hline.style_dashed)

upperBasePlot = plot(extremeLevel, "Overbought Fill Base", display=display.none)
upperSignalPlot = plot(upperFillValue, "Overbought Fill Top", display=display.none)

lowerBasePlot = plot(-extremeLevel, "Oversold Fill Base", display=display.none)
lowerSignalPlot = plot(lowerFillValue, "Oversold Fill Bottom", display=display.none)

fill(upperBasePlot, upperSignalPlot, upperFillValue, extremeLevel, upperTopColor, color.new(red, 100), title="Overbought Gradient Fill")
fill(lowerBasePlot, lowerSignalPlot, -extremeLevel, lowerFillValue, color.new(green, 100), lowerBottomColor, title="Oversold Gradient Fill")

plot(hist, "Momentum Columns", color=histColor, style=plot.style_columns, linewidth=4)

pMain = plot(mainLine, "Median Oscillator", color=color.new(chart.fg_color, 90), linewidth=2)
pMainSignal = plot(ribbon ? mainSignal : na, "Median Oscillator EMA Signal", color=color.new(color.white, 100))

fill(pMain, pMainSignal, color=ribbon ? ribbonColor : na, title="Median Oscillator Ribbon")

//==================================================
// Alerts
//==================================================
alertcondition(histBullCross, title="Histogram Bullish Cross", message="VWMO histogram crossed above zero.")
alertcondition(histBearCross, title="Histogram Bearish Cross", message="VWMO histogram crossed below zero.")
alertcondition(mainBullCross, title="Median Oscillator Bullish Zero Cross", message="VWMO main line crossed above zero.")
alertcondition(mainBearCross, title="Median Oscillator Bearish Zero Cross", message="VWMO main line crossed below zero.")
alertcondition(mainSignalBullCross, title="Median Oscillator Crossed Above EMA Signal", message="VWMO main line crossed above signal.")
alertcondition(mainSignalBearCross, title="Median Oscillator Crossed Below EMA Signal", message="VWMO main line crossed below signal.")
alertcondition(overboughtEntry, title="Median Oscillator Entered Overbought Zone", message="VWMO entered overbought zone.")
alertcondition(overboughtExit, title="Median Oscillator Exited Overbought Zone", message="VWMO exited overbought zone.")
alertcondition(oversoldEntry, title="Median Oscillator Entered Oversold Zone", message="VWMO entered oversold zone.")
alertcondition(oversoldExit, title="Median Oscillator Exited Oversold Zone", message="VWMO exited oversold zone.")
alertcondition(ribbonBullFlip, title="Ribbon Turned Bullish", message="VWMO ribbon turned bullish.")
alertcondition(ribbonBearFlip, title="Ribbon Turned Bearish", message="VWMO ribbon turned bearish.")
````
