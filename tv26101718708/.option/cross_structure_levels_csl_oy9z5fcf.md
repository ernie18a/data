# Cross Structure Levels (CSL)

- url: https://www.tradingview.com/script/OY9z5FCf-Cross-Structure-Levels-CSL/
- type: indicator
- pine_id: PUB;2bea5f81ac4048e7a3095dae27e4fc39
- version: 2.0

## Description

[b]Cross Structure Levels (CSL)[/b]

Cross Structure Levels (CSL) is a structural tool designed to help visualize moving average crosses in a more practical way.

In many trading environments, moving average crosses are used as a confirmation of directional bias. However, these events are often missed in real time, and the subsequent price movement develops after the initial cross.

This script transforms those crosses into horizontal levels, allowing traders to track how price interacts with them over time.

[b]Concept[/b]
[list]
[*]A cross between a fast and a slow moving average is treated as a structural event
[*]The closing price of that cross is plotted as a horizontal level
[*]That level extends forward and can act as a reference for price behavior
[/list]

Instead of reacting to the cross itself, CSL helps observe how price behaves around that level afterward.

[b]Important Clarification[/b]
[list]
[*]A moving average cross is not a trading signal by itself
[*]The plotted level is not an entry or exit signal
[*]It is a contextual reference that may help confirm market conditions
[/list]

[b]Key Features[/b]
[list]
[*]Choice between EMA and SMA
[*]Customizable lengths (default 9/21)
[*]Multi-timeframe cross detection (e.g., using 3m or 5m crosses on a 1m chart)
[*]Session filtering (New York session by default)
[*]Option to display only current session/day
[*]Automatic removal of outdated or broken levels
[*]Optional retest labeling
[/list]

[b]How to Use[/b]
[list]
[*]Use levels as contextual references, not as standalone signals
[*]Observe reactions when price returns to a level after a cross
[*]Combine with other tools such as VWAP, opening ranges, or support/resistance
[*]Focus on price behavior rather than the cross itself
[/list]

[b]Notes[/b]
[list]
[*]This script is designed for intraday analysis
[*]Different moving average settings may produce different results
[*]Best used as part of a broader trading framework
[/list]

[b]Release Notes - CSL[/b]
[list]
[*]Initial release of Cross Structure Levels (CSL)
[*]Converts moving average crosses into horizontal levels
[*]Supports EMA and SMA with customizable lengths
[*]Multi-timeframe cross detection
[*]Session filtering and today-only mode
[*]Smart cleaning of outdated levels
[*]Automatic removal of broken levels
[*]Optional retest detection
[*]Visual customization options
[/list]

## Source Code

````pine
//@version=6
indicator("CSL v2.6 - Cross Structure Levels", overlay=true, max_lines_count=500, max_labels_count=500)

// =========================
// INPUTS
// =========================
maType = input.string("EMA", "MA Type", options=["EMA", "SMA"])
fastLen = input.int(9, "Fast MA Length", minval=1)
slowLen = input.int(21, "Slow MA Length", minval=1)
tfInput = input.timeframe("3", "Cross Timeframe")
maSessionMode = input.string("Extended / Chart Session", "MA Data Session", options=["Extended / Chart Session", "Regular Trading Hours"])
crossLevelMode = input.string("Confirmation Close", "Cross Level Price", options=["Confirmation Close", "MA Cross Value"])
sessionInput = input.session("0400-1600", "Active Session NY")
todayOnly = input.bool(true, "Show Today Only")
levelDisplayMode = input.string("Smart Clean", "Level Display Mode", options=["Smart Clean", "Last N Crosses", "All Crosses"])
crossesToKeep = input.int(2, "Crosses to Keep", minval=1, maxval=20)
maxLevels = input.int(5, "Max Levels per Side", minval=1, maxval=20)
showBull = input.bool(true, "Show Bullish Cross Levels")
showBear = input.bool(true, "Show Bearish Cross Levels")
showRetests = input.bool(false, "Show Retest Labels")
deleteInvalidated = input.bool(false, "Delete Invalidated Levels")
cleanBrokenLevels = input.bool(true, "Clean Broken Levels")
invalidationTicks = input.int(10, "Invalidation Buffer Ticks", minval=0)
lineStyleInput = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"])
lineWidth = input.int(2, "Line Width", minval=1, maxval=5)
bullColor = input.color(color.green, "Bull Level Color")
bearColor = input.color(color.red, "Bear Level Color")
labelTextColor = input.color(color.white, "Label Text Color")

// =========================
// SETTINGS
// =========================
invalidationBuffer = invalidationTicks * syminfo.mintick
lineStyle = lineStyleInput == "Solid" ? line.style_solid : lineStyleInput == "Dashed" ? line.style_dashed : line.style_dotted
inSession = not na(time(timeframe.period, sessionInput, "America/New_York"))
isToday = dayofmonth == dayofmonth(timenow) and month == month(timenow) and year == year(timenow)
canCreateLevel = inSession and (not todayOnly or isToday)

// =========================
// SESSION-AWARE TICKERS
// =========================
regularTicker = ticker.new(syminfo.prefix, syminfo.ticker, session.regular)
dataTicker = maSessionMode == "Regular Trading Hours" ? regularTicker : syminfo.tickerid

// =========================
// MA FUNCTION
// =========================
f_ma(src, len) =>
    maType == "EMA" ? ta.ema(src, len) : ta.sma(src, len)

// =========================
// MTF DATA
// =========================
srcClose = request.security(dataTicker, tfInput, close)
fastMA = request.security(dataTicker, tfInput, f_ma(close, fastLen))
slowMA = request.security(dataTicker, tfInput, f_ma(close, slowLen))

// =========================
// CROSS LOGIC
// =========================
bullCross = ta.crossover(fastMA, slowMA)
bearCross = ta.crossunder(fastMA, slowMA)

// =========================
// CROSS LEVEL PRICE
// =========================
maCrossValue = (fastMA + slowMA) / 2.0
crossLevelPrice = crossLevelMode == "Confirmation Close" ? srcClose : maCrossValue

// =========================
// STORAGE
// =========================
var line[] bullLines = array.new_line()
var label[] bullLabels = array.new_label()
var float[] bullPrices = array.new_float()
var bool[] bullArmed = array.new_bool()
var bool[] bullRetested = array.new_bool()

var line[] bearLines = array.new_line()
var label[] bearLabels = array.new_label()
var float[] bearPrices = array.new_float()
var bool[] bearArmed = array.new_bool()
var bool[] bearRetested = array.new_bool()

var line[] allLines = array.new_line()
var label[] allLabels = array.new_label()
var bool[] allIsBull = array.new_bool()

// =========================
// REMOVE SPECIFIC BULL
// =========================
f_removeBull(_index) =>
    targetLine = array.get(bullLines, _index)
    targetLabel = array.get(bullLabels, _index)
    line.delete(targetLine)
    label.delete(targetLabel)
    array.remove(bullLines, _index)
    array.remove(bullLabels, _index)
    array.remove(bullPrices, _index)
    array.remove(bullArmed, _index)
    array.remove(bullRetested, _index)
    allIndex = array.indexof(allLines, targetLine)
    if allIndex >= 0
        array.remove(allLines, allIndex)
        array.remove(allLabels, allIndex)
        array.remove(allIsBull, allIndex)

// =========================
// REMOVE SPECIFIC BEAR
// =========================
f_removeBear(_index) =>
    targetLine = array.get(bearLines, _index)
    targetLabel = array.get(bearLabels, _index)
    line.delete(targetLine)
    label.delete(targetLabel)
    array.remove(bearLines, _index)
    array.remove(bearLabels, _index)
    array.remove(bearPrices, _index)
    array.remove(bearArmed, _index)
    array.remove(bearRetested, _index)
    allIndex = array.indexof(allLines, targetLine)
    if allIndex >= 0
        array.remove(allLines, allIndex)
        array.remove(allLabels, allIndex)
        array.remove(allIsBull, allIndex)

// =========================
// ADD LEVELS
// =========================
f_addBullLevel(_price) =>
    txt = str.tostring(fastLen) + "/" + str.tostring(slowLen) + " Bull"
    l = line.new(bar_index, _price, bar_index + 1, _price, extend=extend.right, color=bullColor, width=lineWidth, style=lineStyle)
    lb = label.new(bar_index, _price, txt, style=label.style_label_left, color=bullColor, textcolor=labelTextColor, size=size.small)
    array.push(bullLines, l)
    array.push(bullLabels, lb)
    array.push(bullPrices, _price)
    array.push(bullArmed, false)
    array.push(bullRetested, false)
    array.push(allLines, l)
    array.push(allLabels, lb)
    array.push(allIsBull, true)

f_addBearLevel(_price) =>
    txt = str.tostring(fastLen) + "/" + str.tostring(slowLen) + " Bear"
    l = line.new(bar_index, _price, bar_index + 1, _price, extend=extend.right, color=bearColor, width=lineWidth, style=lineStyle)
    lb = label.new(bar_index, _price, txt, style=label.style_label_left, color=bearColor, textcolor=labelTextColor, size=size.small)
    array.push(bearLines, l)
    array.push(bearLabels, lb)
    array.push(bearPrices, _price)
    array.push(bearArmed, false)
    array.push(bearRetested, false)
    array.push(allLines, l)
    array.push(allLabels, lb)
    array.push(allIsBull, false)

// =========================
// TRIM PER SIDE
// =========================
f_trimBull() =>
    while array.size(bullLines) > maxLevels
        f_removeBull(0)

f_trimBear() =>
    while array.size(bearLines) > maxLevels
        f_removeBear(0)

// =========================
// KEEP LAST N CROSSES
// =========================
f_trimLastNCrosses() =>
    while array.size(allLines) > crossesToKeep
        oldestLine = array.get(allLines, 0)
        oldestIsBull = array.get(allIsBull, 0)
        if oldestIsBull
            idx = array.indexof(bullLines, oldestLine)
            if idx >= 0
                f_removeBull(idx)
        else
            idx = array.indexof(bearLines, oldestLine)
            if idx >= 0
                f_removeBear(idx)

// =========================
// SMART CLEAN OPPOSITE LEVELS
// =========================
f_cleanOnBullCross(_newPrice) =>
    if array.size(bearPrices) > 0
        for i = array.size(bearPrices) - 1 to 0
            price = array.get(bearPrices, i)
            if price < _newPrice
                f_removeBear(i)

f_cleanOnBearCross(_newPrice) =>
    if array.size(bullPrices) > 0
        for i = array.size(bullPrices) - 1 to 0
            price = array.get(bullPrices, i)
            if price > _newPrice
                f_removeBull(i)

// =========================
// CLEAN BROKEN LEVELS
// =========================
f_cleanBrokenLevels() =>
    if array.size(bullPrices) > 0
        for i = array.size(bullPrices) - 1 to 0
            price = array.get(bullPrices, i)
            if close < price - invalidationBuffer
                f_removeBull(i)
    if array.size(bearPrices) > 0
        for i = array.size(bearPrices) - 1 to 0
            price = array.get(bearPrices, i)
            if close > price + invalidationBuffer
                f_removeBear(i)

// =========================
// RETEST LOGIC
// =========================
f_checkRetests() =>
    if array.size(bullPrices) > 0
        for i = 0 to array.size(bullPrices) - 1
            price = array.get(bullPrices, i)
            armed = array.get(bullArmed, i)
            retested = array.get(bullRetested, i)
            if not armed and close > price + invalidationBuffer
                array.set(bullArmed, i, true)
            if showRetests and armed and not retested and low <= price and close > price
                label.new(bar_index, price, "RT Bull", style=label.style_label_up, color=bullColor, textcolor=labelTextColor, size=size.small)
                array.set(bullRetested, i, true)
    if array.size(bearPrices) > 0
        for i = 0 to array.size(bearPrices) - 1
            price = array.get(bearPrices, i)
            armed = array.get(bearArmed, i)
            retested = array.get(bearRetested, i)
            if not armed and close < price - invalidationBuffer
                array.set(bearArmed, i, true)
            if showRetests and armed and not retested and high >= price and close < price
                label.new(bar_index, price, "RT Bear", style=label.style_label_down, color=bearColor, textcolor=labelTextColor, size=size.small)
                array.set(bearRetested, i, true)

// =========================
// EXECUTION
// =========================
if barstate.isconfirmed and canCreateLevel
    if bullCross and showBull
        if levelDisplayMode == "Smart Clean"
            f_cleanOnBullCross(crossLevelPrice)
        f_addBullLevel(crossLevelPrice)
        if levelDisplayMode == "Smart Clean"
            f_trimBull()
        if levelDisplayMode == "Last N Crosses"
            f_trimLastNCrosses()
    if bearCross and showBear
        if levelDisplayMode == "Smart Clean"
            f_cleanOnBearCross(crossLevelPrice)
        f_addBearLevel(crossLevelPrice)
        if levelDisplayMode == "Smart Clean"
            f_trimBear()
        if levelDisplayMode == "Last N Crosses"
            f_trimLastNCrosses()

if cleanBrokenLevels
    f_cleanBrokenLevels()

if deleteInvalidated
    f_cleanBrokenLevels()

f_checkRetests()
````
