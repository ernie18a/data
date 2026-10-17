# Master Supertrend Strategy [Trendoscope]

- url: https://www.tradingview.com/script/YexkkFy8-Master-Supertrend-Strategy-Trendoscope/
- type: strategy
- pine_id: PUB;e72616bf8cd74bb1b38d30841c83cd62
- version: 1.0

## Description

Here is the strategy version of the indicator - [url=https://www.tradingview.com/script/vHpsE0Ft-Master-Supertrend-Trendoscope/]Master Supertrend[/url]

Options and variations are same throughout.

[b]🎲 Variations[/b]
Following variations are provided in the form of settings.

[b]🎯 Range Type[/b]
Instead of ATR, different types of ranges can be used for stop calculation. Here is the complete list used in the script.

[b]Plus/Minus Range*[/b] - Calculates plus range and minus range for each candle and uses them for different sides of stop calculation
[b]Ladder ATR[/b] - Based on the existing concept of Ladder ATR defined in [url=https://www.tradingview.com/script/8EZaD3CW-Supertrend-Ladder-ATR/]Supertrend-Ladder-ATR[/url]
[b]True Range[/b] - True range derived from standard function ta.tr
[b]Standard Deviation[/b] - Standard deviation of close prices

[b]🎯 Applied Calculation[/b]
In standard ATR, rma of TR is used for calculations. But, the application calculation provides option to users to use different mechanisms. It can be a type of moving average or few other types of calculations.

Available values are

[list]
[*]sma
[*]ema
[*]hma
[*]rma
[*]wma
[*]high
[*]median
[/list]

[b]🎯 Other options[/b]
Few other options provided are
Use Close Price - If selected stops are calculated based on the close price instead of high/low prices
Wait for Close If selected, change of supertrend direction is calculated based on close price instead of high/low prices
Diminishing Stop Distance - When selected, stop distance for the trend direction can only reduce and cannot increase. This option is useful for keeping the tight stops on strong trends.

[b]🎯 Plus Minus Range*[/b]
One of the range type used is Plus/Minus Range. What it means and how are these ranges calculated? Let's have a look.

Plus Range is an upward movement of a candle from its last price or open price whichever is lower.
Minus Range is a downward movement of a candle from its last price or open price whichever is higher.

This divides True Range into two separate range for positive and negative side.

[b]Note[/b]: Effectiveness on daily charts are quire visible. However, if you want to use it for lower timeframes, please play around with settings before settling on suitable configuration.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © Trendoscope Pty Ltd
//                                       ░▒             
//                                  ▒▒▒   ▒▒      
//                              ▒▒▒▒▒     ▒▒      
//                      ▒▒▒▒▒▒▒░     ▒     ▒▒          
//                  ▒▒▒▒▒▒           ▒     ▒▒          
//             ▓▒▒▒       ▒        ▒▒▒▒▒▒▒▒▒▒▒  
//   ▒▒▒▒▒▒▒▒▒▒▒ ▒        ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒         
//   ▒  ▒       ░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░        
//   ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░▒▒▒▒▒▒▒▒         
//   ▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ ▒▒                       
//    ▒▒▒▒▒         ▒▒▒▒▒▒▒                            
//                 ▒▒▒▒▒▒▒▒▒                           
//                ▒▒▒▒▒ ▒▒▒▒▒                          
//               ░▒▒▒▒   ▒▒▒▒▓      ████████╗██████╗ ███████╗███╗   ██╗██████╗  ██████╗ ███████╗ ██████╗ ██████╗ ██████╗ ███████╗
//              ▓▒▒▒▒     ▒▒▒▒      ╚══██╔══╝██╔══██╗██╔════╝████╗  ██║██╔══██╗██╔═══██╗██╔════╝██╔════╝██╔═══██╗██╔══██╗██╔════╝
//              ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒        ██║   ██████╔╝█████╗  ██╔██╗ ██║██║  ██║██║   ██║███████╗██║     ██║   ██║██████╔╝█████╗ 
//             ▒▒▒▒▒       ▒▒▒▒▒       ██║   ██╔══██╗██╔══╝  ██║╚██╗██║██║  ██║██║   ██║╚════██║██║     ██║   ██║██╔═══╝ ██╔══╝  
//            ▒▒▒▒▒         ▒▒▒▒▒      ██║   ██║  ██║███████╗██║ ╚████║██████╔╝╚██████╔╝███████║╚██████╗╚██████╔╝██║     ███████╗
//             ▒▒             ▒   
//
//@version=5
// indicator("Master Supertrend [Trendoscope]", "MST [Trendoscope]", overlay = true)

strategy("Master Supertrend Strategy [Trendoscope]", "MSTS [Trendoscope]", overlay=true, initial_capital=1000,
         default_qty_type=strategy.percent_of_equity, default_qty_value=10, commission_type=strategy.commission.percent, 
         pyramiding=1, commission_value=0.05, close_entries_rule="ANY", margin_long=100, margin_short=100,
         max_lines_count=500, max_labels_count=500, max_boxes_count=500, use_bar_magnifier=false)

import HeWhoMustNotBeNamed/ta/1 as eta
import HeWhoMustNotBeNamed/arrayutils/22 as pa

supertrendType = input.string('Plus/Minus Range', 'Range Type', ['Plus/Minus Range', 'Ladder TR', 'True Range', 'Standard Deviation'], 'Type of range used for supertrend calculation')
rangeType = input.string('high', 'Applied Calculation', ['sma', 'ema', 'hma', 'rma', 'wma', 'high', 'median'], 'Applied calculation method on the range before using them for calculation of supertrend stops')
length = input.int(60, 'Length', 10, 1000, 10, tooltip = 'Supertrend range calculation length')
multiplier = input.int(2, 'Multiplier', 2, 100, 1, tooltip='Supertrend range multiplier')
useClosePrices = input.bool(true, 'Use Close Price', tooltip = 'Use close price as reference instad of high/low for calculation of stop')
waitForClose = input.bool(true, 'Wait for Close', tooltip = 'Wait for close before changing the direction and change direction only if close price has breached the stop line')
useDiminishingRange = input.bool(true, 'Diminishing Stop Distance', tooltip = 'When selected stop distance from reference price can only decrease and not increase')

float ladderPositiveAtr = na
float ladderNegativeAtr = na
if(supertrendType == 'Ladder TR')
    var plusLadderAtr = array.new<float>()
    var minusLadderAtr = array.new<float>()
    if(open < close)
        pa.push(plusLadderAtr, ta.tr, length)
    else
        pa.push(minusLadderAtr, ta.tr, length)

    ladderPositiveAtr := pa.ma(plusLadderAtr, rangeType, length)
    ladderNegativeAtr := pa.ma(minusLadderAtr, rangeType, length)


plusRange = supertrendType == 'Plus/Minus Range' ? math.max(high-open, high-close[1]) : supertrendType == 'Ladder TR'? ladderPositiveAtr : supertrendType == 'True Range' ? ta.tr : ta.stdev(close, length, true)
minusRange = supertrendType == 'Plus/Minus Range' ? math.max(open-low, close[1]-low) : supertrendType == 'Ladder TR'? ladderNegativeAtr : supertrendType == 'True Range' ? ta.tr : ta.stdev(close, length, true)

appliedPlusRange = supertrendType == 'Ladder TR'? plusRange : eta.ma(plusRange, rangeType, length)
appliedMinusRange = supertrendType == 'Ladder TR'? minusRange: eta.ma(minusRange, rangeType, length)

var direction = 1

var derivedPlusRange = appliedPlusRange*multiplier
var derivedMinusRange = appliedMinusRange*multiplier

currentDerivedPlusRange = appliedPlusRange*multiplier
derivedPlusRange := direction < 0 and useDiminishingRange? math.min(nz(derivedPlusRange,currentDerivedPlusRange), currentDerivedPlusRange) : currentDerivedPlusRange
currentDerivedMinusRange = appliedMinusRange*multiplier
derivedMinusRange := direction > 0 and useDiminishingRange? math.min(nz(derivedMinusRange,currentDerivedMinusRange), currentDerivedMinusRange) : currentDerivedMinusRange

buyStopCurrent = (useClosePrices? close : low) - derivedMinusRange
var buyStop = buyStopCurrent
sellStopCurrent = (useClosePrices? close : high) + derivedPlusRange
var sellStop = sellStopCurrent

buyStop:= direction > 0? math.max(nz(buyStop, buyStopCurrent), buyStopCurrent) : buyStopCurrent
sellStop:=direction < 0? math.min(nz(sellStop, sellStopCurrent), sellStopCurrent) : sellStopCurrent

direction := direction > 0 and (waitForClose?close:low) < buyStop? -1 :
                 direction < 0 and (waitForClose?close:high) > sellStop? 1 : direction

supertrend = direction[1] > 0? buyStop : sellStop
plot(supertrend, 'Supertrend', direction[1]>0? color.red:color.green)

plot(direction, "direction", display = display.data_window)
plot(strategy.equity, "Equity", display = display.data_window)
plot(strategy.openprofit, "Open Profit", display = display.data_window)
plot(strategy.opentrades, "Open Trades", display = display.data_window)
if(direction > 0)
    strategy.entry("Long", strategy.long)
if(direction < 0)
    strategy.entry("Short", strategy.short)
````
