# Average Price / Time

- url: https://www.tradingview.com/script/4XEXD1mQ-Average-Price-Time/
- type: indicator
- pine_id: PUB;c162317800d34575aa204a6836d59fd8
- version: 2.0

## Description

Average Price / Time calculates an anchored time-at-price average from a selected starting candle.

The script uses 1-hour candle ranges by default and treats time as evenly distributed across each candle’s high-low range. From the selected anchor point, it calculates the average price and plots standard deviation bands around it.

Features:
- Mouse-selected start candle
- Time-at-price average
- STD1, STD2, and STD3 bands
- Current z-score shown in the data window

Note:
This is a time-at-price approximation, not a volume-weighted calculation. It measures where price spent time, not where the most volume traded.

## Source Code

````pine
//@version=6
indicator("Average Price / Time", overlay=true, max_labels_count=100, max_lines_count=100)

startTime = input.time(timestamp("2024-01-01T00:00:00"), "Start candle", confirm=true)
binTimeframe = input.timeframe("60", "Bin candle timeframe", tooltip="Uses 1H candles by default. Projection slope is calculated from these bins, not chart bars.")
showStd1 = input.bool(true, "Show STD1")
showStd2 = input.bool(true, "Show STD2")
showStd3 = input.bool(true, "Show STD3")
showLabels = input.bool(true, "Show labels")
showProjection = input.bool(true, "Show linear-regression projection", group="Projection")
forwardProjectionDays = input.int(365, "Forward projection days", minval=1, maxval=5000, group="Projection")

avgColor = input.color(color.yellow, "Avg color")
std1Color = input.color(color.aqua, "STD1 color")
std2Color = input.color(color.orange, "STD2 color")
std3Color = input.color(color.red, "STD3 color")

binHigh = request.security(syminfo.tickerid, binTimeframe, high, barmerge.gaps_off, barmerge.lookahead_off)
binLow = request.security(syminfo.tickerid, binTimeframe, low, barmerge.gaps_off, barmerge.lookahead_off)
binTime = request.security(syminfo.tickerid, binTimeframe, time, barmerge.gaps_off, barmerge.lookahead_off)

newBin = ta.change(binTime) != 0
binInRange = binTime >= startTime
firstBinInRange = binInRange and not binInRange[1]
useBin = binInRange and (newBin or firstBinInRange)

var int count = 0
var float sumMean = 0.0
var float sumSecondMoment = 0.0

var float avgN = 0.0
var float avgX = 0.0
var float avgX2 = 0.0
var float avgY = 0.0
var float avgXY = 0.0

var float p1N = 0.0
var float p1X = 0.0
var float p1X2 = 0.0
var float p1Y = 0.0
var float p1XY = 0.0

var float m1N = 0.0
var float m1X = 0.0
var float m1X2 = 0.0
var float m1Y = 0.0
var float m1XY = 0.0

var float p2N = 0.0
var float p2X = 0.0
var float p2X2 = 0.0
var float p2Y = 0.0
var float p2XY = 0.0

var float m2N = 0.0
var float m2X = 0.0
var float m2X2 = 0.0
var float m2Y = 0.0
var float m2XY = 0.0

var float p3N = 0.0
var float p3X = 0.0
var float p3X2 = 0.0
var float p3Y = 0.0
var float p3XY = 0.0

var float m3N = 0.0
var float m3X = 0.0
var float m3X2 = 0.0
var float m3Y = 0.0
var float m3XY = 0.0

var label avgLabel = na
var label plusOneLabel = na
var label minusOneLabel = na
var label plusTwoLabel = na
var label minusTwoLabel = na
var label plusThreeLabel = na
var label minusThreeLabel = na
var label warningLabel = na

var line avgProjectionLine = na
var line plusOneProjectionLine = na
var line minusOneProjectionLine = na
var line plusTwoProjectionLine = na
var line minusTwoProjectionLine = na
var line plusThreeProjectionLine = na
var line minusThreeProjectionLine = na

if firstBinInRange
    count := 0
    sumMean := 0.0
    sumSecondMoment := 0.0
    avgN := 0.0
    avgX := 0.0
    avgX2 := 0.0
    avgY := 0.0
    avgXY := 0.0
    p1N := 0.0
    p1X := 0.0
    p1X2 := 0.0
    p1Y := 0.0
    p1XY := 0.0
    m1N := 0.0
    m1X := 0.0
    m1X2 := 0.0
    m1Y := 0.0
    m1XY := 0.0
    p2N := 0.0
    p2X := 0.0
    p2X2 := 0.0
    p2Y := 0.0
    p2XY := 0.0
    m2N := 0.0
    m2X := 0.0
    m2X2 := 0.0
    m2Y := 0.0
    m2XY := 0.0
    p3N := 0.0
    p3X := 0.0
    p3X2 := 0.0
    p3Y := 0.0
    p3XY := 0.0
    m3N := 0.0
    m3X := 0.0
    m3X2 := 0.0
    m3Y := 0.0
    m3XY := 0.0

if useBin
    candleMean = (binHigh + binLow) * 0.5
    candleRange = binHigh - binLow
    candleSecondMoment = candleMean * candleMean + candleRange * candleRange / 12.0

    count += 1
    sumMean += candleMean
    sumSecondMoment += candleSecondMoment

mean = count > 0 ? sumMean / count : na
secondMoment = count > 0 ? sumSecondMoment / count : na
variance = count > 1 ? math.max(secondMoment - mean * mean, 0.0) : na
stdev = not na(variance) ? math.sqrt(variance) : na

plusOne = not na(stdev) ? mean + stdev : na
minusOne = not na(stdev) ? mean - stdev : na
plusTwo = not na(stdev) ? mean + stdev * 2.0 : na
minusTwo = not na(stdev) ? mean - stdev * 2.0 : na
plusThree = not na(stdev) ? mean + stdev * 3.0 : na
minusThree = not na(stdev) ? mean - stdev * 3.0 : na

if useBin
    x = (binTime - startTime) / 86400000.0

    if not na(mean)
        avgN += 1.0
        avgX += x
        avgX2 += x * x
        avgY += mean
        avgXY += x * mean

    if not na(plusOne)
        p1N += 1.0
        p1X += x
        p1X2 += x * x
        p1Y += plusOne
        p1XY += x * plusOne

    if not na(minusOne)
        m1N += 1.0
        m1X += x
        m1X2 += x * x
        m1Y += minusOne
        m1XY += x * minusOne

    if not na(plusTwo)
        p2N += 1.0
        p2X += x
        p2X2 += x * x
        p2Y += plusTwo
        p2XY += x * plusTwo

    if not na(minusTwo)
        m2N += 1.0
        m2X += x
        m2X2 += x * x
        m2Y += minusTwo
        m2XY += x * minusTwo

    if not na(plusThree)
        p3N += 1.0
        p3X += x
        p3X2 += x * x
        p3Y += plusThree
        p3XY += x * plusThree

    if not na(minusThree)
        m3N += 1.0
        m3X += x
        m3X2 += x * x
        m3Y += minusThree
        m3XY += x * minusThree

zScore = not na(stdev) and stdev != 0.0 ? (close - mean) / stdev : na

f_slope(n, sx, sx2, sy, sxy) =>
    denominator = n * sx2 - sx * sx
    n > 1 and denominator != 0.0 ? (n * sxy - sx * sy) / denominator : na

f_intercept(n, sx, sy, slope) =>
    not na(slope) and n > 0 ? (sy - slope * sx) / n : na

f_regValue(intercept, slope, x) =>
    not na(intercept) and not na(slope) ? intercept + slope * x : na

avgSlope = f_slope(avgN, avgX, avgX2, avgY, avgXY)
plusOneSlope = f_slope(p1N, p1X, p1X2, p1Y, p1XY)
minusOneSlope = f_slope(m1N, m1X, m1X2, m1Y, m1XY)
plusTwoSlope = f_slope(p2N, p2X, p2X2, p2Y, p2XY)
minusTwoSlope = f_slope(m2N, m2X, m2X2, m2Y, m2XY)
plusThreeSlope = f_slope(p3N, p3X, p3X2, p3Y, p3XY)
minusThreeSlope = f_slope(m3N, m3X, m3X2, m3Y, m3XY)

avgIntercept = f_intercept(avgN, avgX, avgY, avgSlope)
plusOneIntercept = f_intercept(p1N, p1X, p1Y, plusOneSlope)
minusOneIntercept = f_intercept(m1N, m1X, m1Y, minusOneSlope)
plusTwoIntercept = f_intercept(p2N, p2X, p2Y, plusTwoSlope)
minusTwoIntercept = f_intercept(m2N, m2X, m2Y, minusTwoSlope)
plusThreeIntercept = f_intercept(p3N, p3X, p3Y, plusThreeSlope)
minusThreeIntercept = f_intercept(m3N, m3X, m3Y, minusThreeSlope)

futureTime = time + int(forwardProjectionDays * 86400000)
futureX = (futureTime - startTime) / 86400000.0

plot(mean, "Avg", color=avgColor, linewidth=2)
plot(showStd1 ? plusOne : na, "STD1+", color=std1Color, linewidth=1)
plot(showStd1 ? minusOne : na, "STD1-", color=std1Color, linewidth=1)
plot(showStd2 ? plusTwo : na, "STD2+", color=std2Color, linewidth=1)
plot(showStd2 ? minusTwo : na, "STD2-", color=std2Color, linewidth=1)
plot(showStd3 ? plusThree : na, "STD3+", color=std3Color, linewidth=1)
plot(showStd3 ? minusThree : na, "STD3-", color=std3Color, linewidth=1)

plot(zScore, "Z-Score", display=display.data_window)
plot(count, "Bins", display=display.data_window)
plot(avgSlope, "Avg regression slope/day", display=display.data_window)
plot(plusOneSlope, "STD1+ regression slope/day", display=display.data_window)
plot(minusOneSlope, "STD1- regression slope/day", display=display.data_window)
plot(plusTwoSlope, "STD2+ regression slope/day", display=display.data_window)
plot(minusTwoSlope, "STD2- regression slope/day", display=display.data_window)
plot(plusThreeSlope, "STD3+ regression slope/day", display=display.data_window)
plot(minusThreeSlope, "STD3- regression slope/day", display=display.data_window)

if barstate.islast
    label.delete(warningLabel)
    label.delete(avgLabel)
    label.delete(plusOneLabel)
    label.delete(minusOneLabel)
    label.delete(plusTwoLabel)
    label.delete(minusTwoLabel)
    label.delete(plusThreeLabel)
    label.delete(minusThreeLabel)

    line.delete(avgProjectionLine)
    line.delete(plusOneProjectionLine)
    line.delete(minusOneProjectionLine)
    line.delete(plusTwoProjectionLine)
    line.delete(minusTwoProjectionLine)
    line.delete(plusThreeProjectionLine)
    line.delete(minusThreeProjectionLine)

    if count == 0
        warningLabel := label.new(bar_index, high, "No bins after selected start candle.", style=label.style_label_down, textcolor=color.white, color=color.red, size=size.small)

    if showLabels and count > 0
        avgLabel := label.new(bar_index, mean, "Avg", style=label.style_label_left, textcolor=color.black, color=avgColor, size=size.small)

        if showStd1 and not na(stdev)
            plusOneLabel := label.new(bar_index, plusOne, "STD1", style=label.style_label_left, textcolor=color.black, color=std1Color, size=size.small)
            minusOneLabel := label.new(bar_index, minusOne, "STD1", style=label.style_label_left, textcolor=color.black, color=std1Color, size=size.small)

        if showStd2 and not na(stdev)
            plusTwoLabel := label.new(bar_index, plusTwo, "STD2", style=label.style_label_left, textcolor=color.black, color=std2Color, size=size.small)
            minusTwoLabel := label.new(bar_index, minusTwo, "STD2", style=label.style_label_left, textcolor=color.black, color=std2Color, size=size.small)

        if showStd3 and not na(stdev)
            plusThreeLabel := label.new(bar_index, plusThree, "STD3", style=label.style_label_left, textcolor=color.white, color=std3Color, size=size.small)
            minusThreeLabel := label.new(bar_index, minusThree, "STD3", style=label.style_label_left, textcolor=color.white, color=std3Color, size=size.small)

    if showProjection and count > 1
        if not na(avgIntercept) and not na(avgSlope)
            avgProjectionLine := line.new(startTime, f_regValue(avgIntercept, avgSlope, 0.0), futureTime, f_regValue(avgIntercept, avgSlope, futureX), xloc=xloc.bar_time, extend=extend.none, color=color.new(avgColor, 0), style=line.style_dashed)

        if showStd1
            if not na(plusOneIntercept) and not na(plusOneSlope)
                plusOneProjectionLine := line.new(startTime, f_regValue(plusOneIntercept, plusOneSlope, 0.0), futureTime, f_regValue(plusOneIntercept, plusOneSlope, futureX), xloc=xloc.bar_time, extend=extend.none, color=color.new(std1Color, 0), style=line.style_dashed)
            if not na(minusOneIntercept) and not na(minusOneSlope)
                minusOneProjectionLine := line.new(startTime, f_regValue(minusOneIntercept, minusOneSlope, 0.0), futureTime, f_regValue(minusOneIntercept, minusOneSlope, futureX), xloc=xloc.bar_time, extend=extend.none, color=color.new(std1Color, 0), style=line.style_dashed)

        if showStd2
            if not na(plusTwoIntercept) and not na(plusTwoSlope)
                plusTwoProjectionLine := line.new(startTime, f_regValue(plusTwoIntercept, plusTwoSlope, 0.0), futureTime, f_regValue(plusTwoIntercept, plusTwoSlope, futureX), xloc=xloc.bar_time, extend=extend.none, color=color.new(std2Color, 0), style=line.style_dashed)
            if not na(minusTwoIntercept) and not na(minusTwoSlope)
                minusTwoProjectionLine := line.new(startTime, f_regValue(minusTwoIntercept, minusTwoSlope, 0.0), futureTime, f_regValue(minusTwoIntercept, minusTwoSlope, futureX), xloc=xloc.bar_time, extend=extend.none, color=color.new(std2Color, 0), style=line.style_dashed)

        if showStd3
            if not na(plusThreeIntercept) and not na(plusThreeSlope)
                plusThreeProjectionLine := line.new(startTime, f_regValue(plusThreeIntercept, plusThreeSlope, 0.0), futureTime, f_regValue(plusThreeIntercept, plusThreeSlope, futureX), xloc=xloc.bar_time, extend=extend.none, color=color.new(std3Color, 0), style=line.style_dashed)
            if not na(minusThreeIntercept) and not na(minusThreeSlope)
                minusThreeProjectionLine := line.new(startTime, f_regValue(minusThreeIntercept, minusThreeSlope, 0.0), futureTime, f_regValue(minusThreeIntercept, minusThreeSlope, futureX), xloc=xloc.bar_time, extend=extend.none, color=color.new(std3Color, 0), style=line.style_dashed)
````
