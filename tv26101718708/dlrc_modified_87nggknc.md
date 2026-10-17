# DLRC Modified

- url: https://www.tradingview.com/script/87nGGknC-DLRC-Modified/
- type: indicator
- pine_id: PUB;c50197147ad544ef9d5be130ed0fd71a
- version: 1.0

## Description

This is a modification of Iravan's Dynamic Linear Regression Channels indicator, modified by Claude 4.6 to limit the lookback period, resulting in the indicator not appearing on some charts

## Source Code

````pine
//Credit to Iravan whose base code was modified by Claude 4.6 AI to limit the lookback period 
//which caused the DLRC indicator to not load on some charts

//@version=6
indicator('DLRC', overlay = true, max_lines_count = 500, max_boxes_count = 500)

upperMultInput = input.float(2.0, title = 'Upper Deviation', inline = 'Upper Deviation')
colorUpper = input.color(color.new(color.blue, 85), '', inline = 'Upper Deviation')
lowerMultInput = input.float(2.0, title = 'Lower Deviation', inline = 'Lower Deviation')
colorLower = input.color(color.new(color.red, 85), '', inline = 'Lower Deviation')
userLength = input.int(200, title = 'Max Lookback Length', minval = 10, maxval = 5000)
confirmBars = input.int(1, title = 'Breakout Confirmation Bars', minval = 1, maxval = 20)

calcSlope(source, length) =>
    max_bars_back(source, 5000)
    if barstate.isfirst or length <= 1
        [float(na), float(na), float(na)]
    else
        sumX = 0.0
        sumY = 0.0
        sumXSqr = 0.0
        sumXY = 0.0
        for i = 0 to length - 1 by 1
            val = source[i]
            per = i + 1.0
            sumX := sumX + per
            sumY := sumY + val
            sumXSqr := sumXSqr + per * per
            sumXY := sumXY + val * per
            sumXY
        slope = (length * sumXY - sumX * sumY) / (length * sumXSqr - sumX * sumX)
        average = sumY / length
        intercept = average - slope * sumX / length + slope
        [slope, average, intercept]

var start_index = 0
lengthInput = math.min(bar_index - start_index + 1, userLength)
[s, a, i] = calcSlope(close, lengthInput)
startPrice = i + s * (lengthInput - 1)
endPrice = i

calcDev(source, length, slope, average, intercept) =>
    max_bars_back(source, 5000)
    max_bars_back(high, 5000)
    max_bars_back(low, 5000)
    if barstate.isfirst or length <= 1
        [float(na), float(na), float(na), float(na)]
    else
        upDev = 0.0
        dnDev = 0.0
        stdDevAcc = 0.0
        dsxx = 0.0
        dsyy = 0.0
        dsxy = 0.0
        periods = length - 1
        daY = intercept + slope * periods / 2
        val = intercept
        for j = 0 to periods by 1
            price = high[j] - val
            if price > upDev
                upDev := price
                upDev
            price := val - low[j]
            if price > dnDev
                dnDev := price
                dnDev
            price := source[j]
            dxt = price - average
            dyt = val - daY
            price := price - val
            stdDevAcc := stdDevAcc + price * price
            dsxx := dsxx + dxt * dxt
            dsyy := dsyy + dyt * dyt
            dsxy := dsxy + dxt * dyt
            val := val + slope
            val
        stdDev = math.sqrt(stdDevAcc / (periods == 0 ? 1 : periods))
        pearsonR = dsxx == 0 or dsyy == 0 ? 0 : dsxy / math.sqrt(dsxx * dsyy)
        [stdDev, pearsonR, upDev, dnDev]

[stdDev, pearsonR, upDev, dnDev] = calcDev(close, lengthInput, s, a, i)
upperStartPrice = startPrice + upperMultInput * stdDev
upperEndPrice = endPrice + upperMultInput * stdDev
lowerStartPrice = startPrice - lowerMultInput * stdDev
lowerEndPrice = endPrice - lowerMultInput * stdDev

var array<line> archivedLines = array.new_line()
var array<linefill> archivedFills = array.new_linefill()

pruneOldSegments() =>
    cutoffBar = bar_index - userLength
    while array.size(archivedLines) > 0
        oldLine = array.get(archivedLines, 0)
        if line.get_x2(oldLine) < cutoffBar
            line.delete(array.shift(archivedLines))
        else
            break
    while array.size(archivedFills) > 0 and array.size(archivedLines) < array.size(archivedFills) * 2
        oldFill = array.shift(archivedFills)
        linefill.delete(oldFill)

var baseLine = line.new(na, na, na, na, width = 1, color = color.new(colorLower, 0))
var upper = line.new(na, na, na, na, width = 1, color = color.new(colorUpper, 0))
var lower = line.new(na, na, na, na, width = 1, color = color.new(colorUpper, 0))
linefill.new(upper, baseLine, color = colorUpper)
linefill.new(baseLine, lower, color = colorLower)

var int outsideCount = 0
isOutside = close > upperEndPrice or close < lowerEndPrice

if isOutside
    outsideCount := outsideCount + 1
    outsideCount
else
    outsideCount := 0
    outsideCount

if outsideCount >= confirmBars and (not barstate.islast or barstate.isconfirmed)
    _baseLine = line.new(bar_index - lengthInput + 1, startPrice[1], bar_index - 1, endPrice[1], width = 1, color = color.new(colorLower, 0))
    _upper = line.new(bar_index - lengthInput + 1, upperStartPrice[1], bar_index - 1, upperEndPrice[1], width = 1, color = color.new(colorUpper, 0))
    _lower = line.new(bar_index - lengthInput + 1, lowerStartPrice[1], bar_index - 1, lowerEndPrice[1], width = 1, color = color.new(colorUpper, 0))
    _fill1 = linefill.new(_upper, _baseLine, color = colorUpper)
    _fill2 = linefill.new(_baseLine, _lower, color = colorLower)
    array.push(archivedLines, _baseLine)
    array.push(archivedLines, _upper)
    array.push(archivedLines, _lower)
    array.push(archivedFills, _fill1)
    array.push(archivedFills, _fill2)
    pruneOldSegments()
    outsideCount := 0
    start_index := bar_index
    start_index

if barstate.islast
    j = isOutside ? 1 : 0
    line.set_xy1(baseLine, bar_index - lengthInput + 1, startPrice[j])
    line.set_xy2(baseLine, bar_index - j, endPrice[j])
    line.set_xy1(upper, bar_index - lengthInput + 1, upperStartPrice[j])
    line.set_xy2(upper, bar_index - j, upperEndPrice[j])
    line.set_xy1(lower, bar_index - lengthInput + 1, lowerStartPrice[j])
    line.set_xy2(lower, bar_index - j, lowerEndPrice[j])
````
