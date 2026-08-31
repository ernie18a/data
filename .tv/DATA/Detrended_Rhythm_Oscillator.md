<!-- tradingview-pine-id: PUB;0ImliGmZ1ZHPiUYCI3OCWwJvRZT3AOFu -->
<!-- tradingviewscripts-format: 1 -->
# Detrended Rhythm Oscillator

Source: https://www.tradingview.com/script/nzvqcuSh-Detrended-Rhythm-Oscillator-DRO/

## Description

How to detect the current "market beat" or market cycle?

A common way to capture the current dominant cycle length is to detrend the price and look for common rhythms in the detrended series. A common approach is to use a Detrended Price Oscillator (DPO). This is done in order to identify and isolate short-term cycles. 

A basic DPO description can be found here:
[https://www.tradingview.com/support/solutions/43000502246-detrended-price-oscillator-dpo/](https://www.tradingview.com/support/solutions/43000502246-detrended-price-oscillator-dpo/)

Improvements to the standard DPO
The main purpose of the standard DPO is to analyze historical data in order to observe cycle's in a market's movement. DPO can give the technical analyst a better sense of a cycle's typical high/low range as well as its duration. However, you need to manually try to "see" tops and bottoms on the detrended price and measure manually the distance from low-low or high-high in order to derive a possible cycle length. 

Therefore, I added the following improvements:

1) Using a DPO to detrend the price
2) Indicate the turns of the detrended price with a ZigZag lines to better see the tops/bottoms
3) Detrend the ZigZag to remove price amplitude between turns to even better see the cyclic turns ("rhythm")
4) Measure the distance from last detrended zigzag pivot (high-high / low-low) and plot the distance in bars above/below the turn

Now, you can clearly see the rhythm of the dataset indicated by the Detrended Rhythm Oscillator including the exact length between the turns. This makes the procedure to "spot" turns and "measure" distance more simple for the trader.

How to use this information
The purpose is to check if there is a common rhythm or beat in the underlying dataset. To check that, look for recurring pattern in the numbers. E.g. if you often see the same measured distance, you can conclude that there is a major dominant cycle in this market. Also watch for harmonic relations between the numbers. So in the example above you see the highlighted cluster of detected length of around 40,80 and 120. There three numbers all have a harmonic relation to 40. 

Once you have this cyclic information, you can use this number to optimize or tune technical indicators based on the current dominant cycle length. E.g. set the length parameter of a technical indicator to the detected harmonic length with the DRO indicator. 

Example Use-Case
You can use this information to set the input for the following free public open-source script:
[chart]https://www.tradingview.com/script/TmqiR1jp-RSI-cyclic-smoothed-v2/[/chart]

Disclaimer
This is not meant to be a technical indicator on its own and the derived cyclic length should not be used to forecast the next turn per se. The indicator should give you an indication of the current market beat or dominant beats which can be use to further optimize other oscillator or trading related settings.

Options & settings
The indicator allows to plot different versions. It allows to plot the original DPO, the DRO with ZigZag lines, the DRO with detrended ZigZag lines and length labels on/off. You can turn on or off these version in the indicator settings. So you can tweak it visually to your own needs.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//
// Detrended Rhythm Oscillator (DRO)
// ----------------------------------
// Uses a Detrended Price Oscillator to calculate detrended "zig zag" swings and plots the distance between the last High-High and Low-Low 
//
// Purpose:
// A tool to measure and visualize the current dominant cycle (or rhythm/beat) in the dataset
// Look for common length numbers on the Zig Zag turns to determine the current dominant cycle length, also check for harmonics (2x, 3x)
// You can use the spotted length to optimize the length parameter of technical indicators (use the length or half of the length as input for any technical indicator)
// A technical indicator with the "correct" length setting in regards to the current dominant cycle will provide much better signals
//
// References:
// Zig Zag array functions used from open-source user "LonesomeTheBlue", script Name: "Double Zig Zag with HHLL"
//
// v.1.1 
//  - fixed a bug when showing the distance lables
//  - added option to turn on/off detrending pre-processing
// v.2
//  - converted to pine v5
//  - added a final median score as label and data stream
//
// © WhenToTrade

//@version=5
indicator('Detrended Rhythm Oscillator', shorttitle='DRO', max_lines_count=30, overlay=false)

// { Inputs
// -----------------------------------------------------------------------------
indiversion = input.string('DRO', '==== Select Indicator ====', options=['DRO', 'DPO', 'BOTH'])
src = input(close, '  Source')


detrendS = input.string('On', '  Detrend', options=['On', 'Off'], group='DPO', inline='de')

fastLength = input.int(3, '  Fast  - ', group='DPO', inline='l')
slowLength = input.int(50, ' Slow:', group='DPO', inline='l')

//... ZigZag
zigperiod = input.int(30, '  Period', minval=5, group='ZigZag', inline='p')
zigstyle = input.string('Dotted', '  Line -', options=['Solid', 'Dotted'], group='ZigZag', inline='line')
zigwidth = input.int(2, ' Width  -- ', options=[1, 2, 3], group='ZigZag', inline='line')

showdistanceS = input.string('On', '  Labels', options=['On', 'Off'], group='ZigZag', inline='switch')
showdetrendedS = input.string('On', ' Detrended', options=['On', 'Off'], group='ZigZag', inline='switch')

upcolor = input.color(defval=#363A45, title='  Colors:  Up', group='ZigZag', inline='color')
downcolor = input.color(defval=#363A45, title=' Down', group='ZigZag', inline='color')
txtcol = input.color(defval=#787B86, title=' Text', group='ZigZag', inline='color')

//... Switches
showdistance = showdistanceS == 'On' ? true : false
showdetrended = showdetrendedS == 'On' ? true : false
detrenddata = detrendS == 'On' ? true : false
displayDPOdata = (indiversion == 'DPO') ? display.all : (indiversion == 'BOTH') ? display.all : display.none 
// } Inputs

// { Variables
// -----------------------------------------------------------------------------
var max_array_size = 15
var ziggyzags = array.new_float(0)
var zzl = array.new_float(0)
var cycles = array.new_float(0)
var dir1 = 0
var lastPivot = 0
var lastPivotDistance = 0
float domcycle = 0
// } Variables

// { Functions
// -----------------------------------------------------------------------------

add_to_zigzag(pointer, value, bindex) =>
    array.unshift(pointer, bindex)
    array.unshift(pointer, value)
    if array.size(pointer) > max_array_size
        array.pop(pointer)
        array.pop(pointer)

update_zigzag(pointer, value, bindex, dir) =>
    if array.size(pointer) == 0
        add_to_zigzag(pointer, value, bindex)
    else
        if dir == 1 and value > array.get(pointer, 0) or dir == -1 and value < array.get(pointer, 0)
            array.set(pointer, 0, value)
            array.set(pointer, 1, bindex)
        0.

// } Functions

// { Calculations
// -----------------------------------------------------------------------------

//... DPO - Detrending
ppo = if detrenddata
    100 * (ta.ema(src, fastLength) - ta.ema(src, slowLength)) / ta.ema(src, slowLength)
else
    ppo = src
    ppo

//... ZigZag
float highs = ta.highestbars(ppo, zigperiod) == 0 ? ppo : na
float lows = ta.lowestbars(ppo, zigperiod) == 0 ? ppo : na

iff_1 = bool(lows) and na(highs) ? -1 : dir1
dir1 := bool(highs) and na(lows) ? 1 : iff_1

dir1changed = ta.change(dir1)
if bool(highs) or bool(lows)
    if bool(dir1changed)
        add_to_zigzag(ziggyzags, dir1 == 1 ? highs : lows, bar_index)
    else
        update_zigzag(ziggyzags, dir1 == 1 ? highs : lows, bar_index, dir1)

// } Calculations

// { Plots
// -----------------------------------------------------------------------------

//... Detrended Price Oscillator
plot(indiversion == 'DPO' or indiversion == 'BOTH' ? ppo : na, display = displayDPOdata )

//... Detrended Zig-Zag lines with distance labels
if array.size(ziggyzags) >= 6
    var line zzline1 = na
    var label zzlabel1 = na
    float val = array.get(ziggyzags, 0)
    int point = math.round(array.get(ziggyzags, 1))
    if bool(ta.change(val)) or bool(ta.change(point))
        float val1 = array.get(ziggyzags, 2)
        int point1 = math.round(array.get(ziggyzags, 3))
        plabel = '?'
        lastPivotDistance := point - lastPivot
        lastPivot := point1

        if ta.change(val1) == 0 and ta.change(point1) == 0
            line.delete(zzline1)
            label.delete(zzlabel1)

            if array.size(zzl) > 1
                lastDistance = array.get(zzl, 1)
                plabel := str.tostring(lastDistance + lastPivotDistance)
                plabel

            if array.size(zzl) > 0
                array.shift(zzl)
            0.
        else
            if array.size(zzl) > 0
                lastPivotDistance := point - lastPivot
                if array.size(zzl) > 1
                    int nw = math.round(array.get(zzl, 0))
                    plabel := str.tostring(lastPivotDistance + nw)
                    plabel
                0
            else
                if array.size(zzl) > 0
                    array.shift(zzl)
                0
            0.

        if indiversion == 'DRO' or indiversion == 'BOTH'
            zzline1 := line.new(x1=point, x2=point1, y1=showdetrended ? dir1 == 1 ? 100 : -100 : val, y2=showdetrended ? dir1 == 1 ? -100 : 100 : val1, color=dir1 == 1 ? upcolor : downcolor, width=zigwidth, style=zigstyle == 'Solid' ? line.style_solid : line.style_dotted)
            zzline1

        if (indiversion == 'DRO' or indiversion == 'BOTH') and showdistance
            zzlabel1 := label.new(x=point, y=showdetrended ? dir1 == 1 ? 100 : -125 : val, text=plabel, textcolor=txtcol, style=label.style_none)
            array.unshift(zzl, lastPivotDistance)

//... zzl hold the lengths of the distance between h-h, l-l / only need the last 3 points
if array.size(zzl) > max_array_size
    array.pop(zzl)

// ...calculate median cycle length (ignore last leg, as this one is not completed)
if array.size(zzl)>3
    array.clear(cycles)
    for i = 1 to array.size(zzl) - 2 
        z1 = array.get(zzl, i)
        z2 = array.get(zzl, i+1)
        cl = z1+z2
        cycles.push(cl)
    
    domcycle := array.median(cycles)

//... Alert data stream for input of another indicator, or for data export
plot(domcycle > 0 ? domcycle : na , "Mean Dominant Cycle Length", display=display.data_window) 

// } Plots and alert data stream      

//... show final label
if barstate.islast
    //log.info("--Dominant median cycle length: " + str.tostring(domcycle))
    if (domcycle>0)
        label.new(chart.point.now(0), "Mean: "+str.tostring(domcycle), color = color.teal, textcolor = color.white, style = label.style_label_left, size=size.small)
````
