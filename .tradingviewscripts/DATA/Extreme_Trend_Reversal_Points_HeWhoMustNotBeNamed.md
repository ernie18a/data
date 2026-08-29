<!-- tradingview-pine-id: PUB;3ace55eba2e34d089aaae3be62fb9313 -->
<!-- tradingviewscripts-format: 1 -->
# Extreme Trend Reversal Points [HeWhoMustNotBeNamed]

Source: https://www.tradingview.com/script/eBB5mW6b-Extreme-Trend-Reversal-Points-HeWhoMustNotBeNamed/

## Description

Using moving average crossover for identifying the change in trend is very common. However, this method can give lots of false signals during the ranging markets. In this algorithm, we try to find the extreme trend by looking at fully aligned multi-level moving averages and only look at moving average crossover when market is in the extreme trend - either bullish or bearish. These points can mean long term downtrend or can also cause a small pullback before trend continuation. In this discussion, we will also check how to handle different scenarios.

🎲 Components
🎯 Recursive Multi Level Moving Averages
Multi level moving average here refers to applying moving average on top of base moving average on multiple levels. For example,

Level 1 SMA = SMA(source, length)
Level 2 SMA = SMA(Level 1 SMA, length)
Level 3 SMA = SMA(Level 2 SMA, length)
..
..
..
Level n SMA = SMA(Level (n-1) SMA, length)

In this script, user can select how many levels of moving averages need to be calculated. This is achieved through "recursive moving average" algorithm. Requirement for building such algorithm was initially raised by @loxx
While I was able to develop them in minimal code with the help of some of the existing libraries built on [arrays](https://www.tradingview.com/script/9IzpUieD-arrayutils/) and [matrix](https://www.tradingview.com/script/hXS05TdU-matrix/), I also thought why not extend this to find something interesting.

Note that since we are using variable levels - we will not be able to plot all the levels of moving average. (This is because plotting cannot be done in the loop). Hence, we are using lines to display the latest moving average levels in front of the last candle. Lines are color coded in such a way that least numbered levels are greener and higher levels are redder.

https://www.tradingview.com/x/SxC7Cu3o/

🎯 Finding the trend and range
Strength of fully aligned moving average is calculated based on position of each level with respect to other levels.

For example, in a complete uptrend, we can find

source > L(1)MA > L(2)MA > L(3)MA ...... > L(n-1)MA > L(n)MA

Similarly in a complete downtrend, we can find

source < L(1)MA < L(2)MA < L(3)MA ...... < L(n-1)MA < L(n)MA

Hence, the strength of trend here is calculated based on relative positions of each levels. Due to this, value of strength can range from 0 to Level*(Level-1)/2

0 represents the complete downtrend
Level*(Level-1)/2 represents the complete uptrend.

Range and Extreme Range are calculated based on the percentile from median. The brackets are defined as per input parameters - Range Percentile and Extreme Range Percentile by using Percentile History as reference length.

Moving average plot is color coded to display the trend strength.

Green - Extreme Bullish
Lime - Bullish
Silver - range
Orange - Bearish
Red - Extreme Bearish

[https://www.tradingview.com/x/GPocC07Q/](https://www.tradingview.com/x/GPocC07Q/)

🎯 Finding the trend reversal
Possible trend reversals are when price crosses the moving average while in complete trend with all the moving averages fully aligned. Triangle marks are placed in such locations which can help observe the probable trend reversal points. But, there are possibilities of trend overriding these levels. An example of such thing, we can see here:

https://www.tradingview.com/x/LjU5I4YC/

In order to overcome this problem, we can employ few techniques.

1. After the signal, wait for trend reversal (moving average plot color to turn silver) before placing your order.
2. Place stop orders on immediate pivot levels or support resistance points instead of opening market order. This way, we can also place an order in the direction of trend. Whichever side the price breaks out, will be the direction to trade.
3. Look for other confirmations such as extremely bullish and bearish candles before placing the orders.

🎯 An example of using stop orders

Let us take this scenario where there is a signal on possible reversal from complete uptrend.
https://www.tradingview.com/x/N9g1EKRc/

Create a box joining high and low pivots at reasonable distance. You can also chose to add 1 ATR additional distance from pivots.
https://www.tradingview.com/x/ZkAkv2Co/

Use the top of the box as stop-entry for long and bottom as stop-entry for short. The other ends of the box can become stop-losses for each side.

After few bars, we can see that few more signals are plotted but, the price is still within the box. There are some candles which touched the top of the box. But, the candlestick patterns did not represent bullishness on those instances. If you have placed stop orders, these orders would have already filled in. In that case, just wait for position to hit either stop or target.

https://www.tradingview.com/x/ujAIr8dO/

For bullish side, targets can be placed at certain risk reward levels. In this case, we just use 1:1 for bullish (trend side) and 1:1.5 for bearish side (reversal side)

https://www.tradingview.com/x/ZKxbStfD/

In this case, price hit the target without any issue: https://www.tradingview.com/x/D9bLoVdV/

Wait for next reversal signal to appear before placing another order :)

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © HeWhoMustNotBeNamed

//   __    __            __       __  __                  __       __                        __      __    __              __      _______             __    __                                          __ 
//  /  |  /  |          /  |  _  /  |/  |                /  \     /  |                      /  |    /  \  /  |            /  |    /       \           /  \  /  |                                        /  |
//  $$ |  $$ |  ______  $$ | / \ $$ |$$ |____    ______  $$  \   /$$ | __    __   _______  _$$ |_   $$  \ $$ |  ______   _$$ |_   $$$$$$$  |  ______  $$  \ $$ |  ______   _____  ____    ______    ____$$ |
//  $$ |__$$ | /      \ $$ |/$  \$$ |$$      \  /      \ $$$  \ /$$$ |/  |  /  | /       |/ $$   |  $$$  \$$ | /      \ / $$   |  $$ |__$$ | /      \ $$$  \$$ | /      \ /     \/    \  /      \  /    $$ |
//  $$    $$ |/$$$$$$  |$$ /$$$  $$ |$$$$$$$  |/$$$$$$  |$$$$  /$$$$ |$$ |  $$ |/$$$$$$$/ $$$$$$/   $$$$  $$ |/$$$$$$  |$$$$$$/   $$    $$< /$$$$$$  |$$$$  $$ | $$$$$$  |$$$$$$ $$$$  |/$$$$$$  |/$$$$$$$ |
//  $$$$$$$$ |$$    $$ |$$ $$/$$ $$ |$$ |  $$ |$$ |  $$ |$$ $$ $$/$$ |$$ |  $$ |$$      \   $$ | __ $$ $$ $$ |$$ |  $$ |  $$ | __ $$$$$$$  |$$    $$ |$$ $$ $$ | /    $$ |$$ | $$ | $$ |$$    $$ |$$ |  $$ |
//  $$ |  $$ |$$$$$$$$/ $$$$/  $$$$ |$$ |  $$ |$$ \__$$ |$$ |$$$/ $$ |$$ \__$$ | $$$$$$  |  $$ |/  |$$ |$$$$ |$$ \__$$ |  $$ |/  |$$ |__$$ |$$$$$$$$/ $$ |$$$$ |/$$$$$$$ |$$ | $$ | $$ |$$$$$$$$/ $$ \__$$ |
//  $$ |  $$ |$$       |$$$/    $$$ |$$ |  $$ |$$    $$/ $$ | $/  $$ |$$    $$/ /     $$/   $$  $$/ $$ | $$$ |$$    $$/   $$  $$/ $$    $$/ $$       |$$ | $$$ |$$    $$ |$$ | $$ | $$ |$$       |$$    $$ |
//  $$/   $$/  $$$$$$$/ $$/      $$/ $$/   $$/  $$$$$$/  $$/      $$/  $$$$$$/  $$$$$$$/     $$$$/  $$/   $$/  $$$$$$/     $$$$/  $$$$$$$/   $$$$$$$/ $$/   $$/  $$$$$$$/ $$/  $$/  $$/  $$$$$$$/  $$$$$$$/ 
//                                                                                                                                                                                                          
//                                                                                                                                                                                                          
//
//@version=5
indicator("Extreme Trend Reversal Points [HeWhoMustNotBeNamed]", shorttitle = "ETRP[HWMNBN]", overlay=true)
import HeWhoMustNotBeNamed/_matrix/5 as ma
import HeWhoMustNotBeNamed/arrayutils/21 as ar
import HeWhoMustNotBeNamed/enhanced_ta/14 as eta
import HeWhoMustNotBeNamed/drawingutils/8 as dr
import HeWhoMustNotBeNamed/arrays/1 as pa

source = input.source(close, "Source", group="Moving Average")
type = input.string("sma", "Type", options = ["sma", "ema", "rma", "wma"], group="Moving Average")
length = input.int(20, "Length", step=5, group="Moving Average")
level = input.int(10, "Level", minval = 5, step=5, group="Moving Average")
minMaxRangePercentile = input.int(20, 'Range Percentile', minval=5, maxval=45, step=5)
extremeMinMaxRangePercentile = input.int(45, 'Extreme Range Percentile', minval=40, maxval=48, step=2)
history = input.int(1000, 'Percentile History', minval=1000, maxval=5000, step=500)
realTimeAlerts = input.bool(false, 'Real Time Alerts', 'If set to true, alerts are fired on latest candle - which may repaint. For safer option set this to false')
maxHistory = length-1

ema(float currentEma, float source, simple int length) =>
    k = 2 / (length + 1)
    ema = source * k + (1 - k) * currentEma
    ema

rma(float currentRma, float source, simple int length) =>
    k = 2 / (length + 1)
    rma = (currentRma * (length-1) + source)/length
    rma

var maMatrix = matrix.new<float>(1, level+1, source)

if(type == "ema")
    emaArray = array.new<float>(1, source)
    for i=1 to matrix.columns(maMatrix)-1
        ema = ema(matrix.get(maMatrix, 0, i), array.get(emaArray, array.size(emaArray)-1), length)
        array.push(emaArray, ema)
    ma.unshift(maMatrix, emaArray, maxHistory)

if(type == "rma")
    rmaArray = array.new<float>(1, source)
    for i=1 to matrix.columns(maMatrix)-1
        rma = rma(matrix.get(maMatrix, 0, i), array.get(rmaArray, array.size(rmaArray)-1), length)
        array.push(rmaArray, rma)
    ma.unshift(maMatrix, rmaArray, maxHistory)

if(type == "sma" or type == "wma")
    maArray = array.new<float>(1, source)
    for i=1 to matrix.columns(maMatrix)-1
        values = matrix.col(maMatrix, i-1)
        tmpArray = array.new<float>(1, array.get(maArray, i-1))
        tmpArray := array.concat(tmpArray, values)
        array.push(maArray, ar.ma(tmpArray, type, length))

    ma.unshift(maMatrix, maArray, maxHistory)

strength = 0
bearishStrength = 0
diffMatrix = matrix.new<float>(level+1, level+1, 0)

var linesArray = array.new<line>()
var labelsArray = array.new<label>()

ar.clear(linesArray)
ar.clear(labelsArray)

for i = 0 to level
    for j = 0 to level
        pma = matrix.get(maMatrix, 0, i)
        nma = matrix.get(maMatrix, 0, j)
        
        //strength := pma > nma ? strength+1 : strength
        if(j > i)
            strength := pma > nma ? strength+1 : strength
        matrix.set(diffMatrix, i, j, math.sign(pma-nma))
       
lastRow = matrix.row(maMatrix, 0)
lastRowIndex = array.sort_indices(array.slice(lastRow, 1, array.size(lastRow)), order.descending)

if(barstate.islast)
    for i=1 to level
        levelColor = color.from_gradient(i, 1, level, color.green, color.red)
        dr.draw_labelled_line(array.get(lastRow, i), type+'('+str.tostring(i)+')',levelColor, levelColor, 0, true, linesArray, labelsArray)

minRange = ta.percentile_nearest_rank(strength, history, 50-minMaxRangePercentile)
maxRange = ta.percentile_nearest_rank(strength, history, 50+minMaxRangePercentile)

extremeMinRange = ta.percentile_nearest_rank(strength, history, 50-extremeMinMaxRangePercentile)
extremeMaxRange = ta.percentile_nearest_rank(strength, history, 50+extremeMinMaxRangePercentile)
plotColor = strength > extremeMaxRange? color.green :
                 strength > maxRange? color.lime :
                 strength < extremeMinRange ? color.red : 
                 strength < minRange? color.orange : color.silver

strengthRange = strength > extremeMaxRange? 2 :
                 strength > maxRange? 1 :
                 strength > minRange ? 0 : 
                 strength < extremeMinRange? -1 : -2
maxStrength = level * (level+1)/2

ma = eta.ma(source, type, length)

bullishTrendReversalPoint = strength[1]== maxStrength and ta.crossunder(source, ma)
bearishTrendReversalPoint = strength[1]==0 and ta.crossover(source, ma)

plotshape(bullishTrendReversalPoint, 'Bullish Trend Reversal Point',
                     style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)
plotshape(bearishTrendReversalPoint, 'Bearish Trend Reversal Point',
                     style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small)

plot(strength, "Strength", color=color.silver, display = display.data_window)
plot(minRange, "Min Range", color=color.orange, display = display.data_window)
plot(maxRange, "Max Range", color=color.lime, display = display.data_window)
plot(extremeMinRange, "Extreme Min Range", color=color.red, display = display.data_window)
plot(extremeMaxRange, "Extreme Max Range", color=color.green, display = display.data_window)
plot(strengthRange, "Strength Range", color=color.blue, display = display.data_window)
plot(ma, "Moving Average", plotColor)

alertcondition(bullishTrendReversalPoint[realTimeAlerts?0:1], "Bullish Trend Reversal", "Possible reversal of bullish trend")
alertcondition(bearishTrendReversalPoint[realTimeAlerts?0:1], "Bearish Trend Reversal", "Possible reversal of bearish trend")
````
