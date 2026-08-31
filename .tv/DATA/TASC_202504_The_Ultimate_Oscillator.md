<!-- tradingview-pine-id: PUB;32d9d9bc22b24b9aaa0f0b0cb935ff22 -->
<!-- tradingviewscripts-format: 1 -->
# TASC 2025.04 The Ultimate Oscillator

Source: https://www.tradingview.com/script/sVP0SZo5-TASC-2025-04-The-Ultimate-Oscillator/

## Description

█ OVERVIEW

This script implements an alternative, refined version of the Ultimate Oscillator (UO) designed to reduce lag and enhance responsiveness in momentum indicators, as introduced by John F. Ehlers in his article "Less Lag In Momentum Indicators, The Ultimate Oscillator" from the [April 2025 edition of TASC's Traders' Tips](https://traders.com/Documentation/FEEDbk_docs/2025/04/TradersTips.html).

█ CONCEPTS

In his article, Ehlers states that indicators are essentially filters that remove unwanted noise (i.e., unnecessary information) from market data. Simply put, they process a series of data to place focus on specific information, providing a different perspective on price dynamics. Various filter types attenuate different periodic signals within the data. For instance, a lowpass filter allows only low-frequency signals, a highpass filter allows only high-frequency signals, and a bandpass filter allows signals within a specific frequency range. 

Ehlers explains that the key to removing indicator lag is to combine filters of different types in such a way that the result preserves necessary, useful signals while minimizing delay (lag). His proposed UltimateOscillator aims to maintain responsiveness to a specific frequency range by measuring the difference between two highpass filters' outputs. The oscillator uses the following formula:

UO = (HP1 - HP2) / RMS

Where:

[*]HP1 is the first highpass filter. 
[*]HP2 is another highpass filter that allows only shorter wavelengths than the critical period of HP1.
[*]RMS is the root mean square of the highpass filter difference, used as a scaling factor to standardize the output. 

The resulting oscillator is similar to a bandpass filter, because it emphasizes wavelengths between the critical periods of the two highpass filters. Ehlers' UO responds quickly to value changes in a series, providing a responsive view of momentum with little to no lag. 

█ USAGE

Ehlers' UltimateOscillator sets the critical periods of its highpass filters using two parameters: BandEdge and Bandwidth: 

[*]The BandEdge sets the critical period of the second highpass filter, which determines the shortest wavelengths in the response. 
[*]The Bandwidth is a multiple of the BandEdge used for the critical period of the first highpass filter, which determines the longest wavelengths in the response. Ehlers suggests that a Bandwidth value of 2 works well for most applications. However, traders can use any value above or equal to 1.4. 

Users can customize these parameters with the "Bandwidth" and "BandEdge" inputs in the "Settings/Inputs" tab. 

The script plots the UO calculated for the specified "Source" series in a separate pane, with a color based on the chart's foreground color. Positive UO values indicate upward momentum or trends, and negative UO values indicate the opposite. 

Additionally, this indicator provides the option to display a "cloud" from 10 additional UO series with different settings for an aggregate view of momentum. The "Cloud" input offers four display choices: "Bandwidth", "BandEdge", "Bandwidth + BandEdge", or "None".

The "Bandwidth" option calculates oscillators with different Bandwidth values based on the main oscillator's setting. Likewise, the "BandEdge" option calculates oscillators with varying BandEdge values. The "Bandwidth + BandEdge" option calculates the extra oscillators with different values for both parameters.  

When a user selects any of these options, the script plots the maximum and minimum oscillator values and fills their space with a color gradient. The fill color corresponds to the net sum of each UO's sign, indicating whether most of the UOs reflect positive or negative momentum. Green hues mean most oscillators are above zero, signifying stronger upward momentum. Red hues mean most are below zero, indicating stronger downward momentum.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © PineCodersTASC

//  TASC Issue: April 2025
//     Article: Less Lag In Momentum Indicators
//              The Ultimate Oscillator
//  Article By: John F. Ehlers
//    Language: TradingView's Pine Script® v6
// Provided By: PineCoders, for tradingview.com

//@version=6
title ="TASC 2025.04 The Ultimate Oscillator"
stitle = "UO"
indicator(title, stitle, false)


import TradingView/ta/9 as ta // import library for RMS function


//#region --- Constants and inputs ---

// @variable The source series to analyze.
float src = input.source(close, "Source:")

// @variable The width of the critical period range in the UO"s high-pass filters.
float Bandwidth = input.float(2, "Bandwidth:", 1.4, step = 0.1)

// @variable Defines the base critical period in the UO calculation. 
//           The HPF with the shorter wavelength uses this value directly.
//           The HPF with the longer wavelength multiplies this value by `Bandwidth` for its period.
float BandEdge = input.float(20, "BandEdge:", 3)

// @variable Determines whether the script displays a "cloud" of 10 additional UO series with different settings.
string cloudType = input.string("None", "Cloud: ", options = ["Bandwidth", "BandEdge", "Bandwidth + BandEdge", "None"])

// @variable Color input for the first fill().
color upColor = input.color(#08998180, "Cloud colors  ", inline = "1") 
color dnColor = input.color(#ff525280, "", inline="1")
//#endregion


//#region --- Functions ---

// @function      Calculates a second-order highpass filter.
// @param src     Series of values to process.
// @param period  Length of the filter"s critical period.
// @returns       The filtered series value.
HP(float src, float period) =>
    var float sq2 = math.sqrt(2.0)
    float a1      =  math.exp(-sq2 * math.pi / period)
    float c2      =  2.0 * a1 * math.cos(sq2 * math.pi / period)
    float c3      = -math.pow(a1, 2)
    float c1      = (1 + c2 - c3) * 0.25
    float hp      = 0.0
    if bar_index >= 4
        hp := c1 * (src - 2 * src[1] + src[2]) + 
              c2 * hp[1] + c3 * hp[2]
    hp


// @function   Calculates the Ultimate Oscillator.
// @param src  Series of values to process.
// @param bw   Width of the UO"s critical period range.
// @param be   Shortest critical period. 
// @returns    The UO value. 
UO(float src, float bw, float be) =>
    float hp1    = HP(src, bw * be)
    float hp2    = HP(src,      be)
    float signal = hp1 - hp2
    float rms    = ta.rms(signal, 100)
    rms == 0 ? 0 : signal / rms


// @function  Calculates 10 UO series with varying Bandwidth and BandEdge values.
UOCloud(float src, float bw, float be, simple string cloudType) =>
    var array<float> result = array.new<float>(10)
    var bool modBW = str.contains(cloudType, "Bandwidth")
    var bool modBE = str.contains(cloudType, "BandEdge")
    if modBW or modBE
        float minBW  = modBW ? math.max(bw * 0.5, 1.4) : bw
        float minBE  = modBE ? math.max(be * 0.5, 3) : be
        float bwStep = (bw - minBW) / 5
        float beStep = (be - minBE) / 5
        result.set(0, UO(src, minBW,              minBE             ))
        result.set(1, UO(src, minBW +     bwStep, minBE +     beStep))
        result.set(2, UO(src, minBW + 2 * bwStep, minBE + 2 * beStep))
        result.set(3, UO(src, minBW + 3 * bwStep, minBE + 3 * beStep))
        result.set(4, UO(src, minBW + 4 * bwStep, minBE + 4 * beStep))
        result.set(5, UO(src, minBW + 5 * bwStep, minBE + 5 * beStep))
        result.set(6, UO(src, minBW + 6 * bwStep, minBE + 6 * beStep))
        result.set(7, UO(src, minBW + 7 * bwStep, minBE + 7 * beStep))
        result.set(8, UO(src, minBW + 8 * bwStep, minBE + 8 * beStep))
        result.set(9, UO(src, minBW + 9 * bwStep, minBE + 9 * beStep))
    result
//#endregion


//#region --- Calculations and display

// @variable The UO of the `src` series based on the input settings.
float UO = UO(src, Bandwidth, BandEdge)

// @variable An array of UO values for the cloud display.
array<float> cloudValues = UOCloud(src, Bandwidth, BandEdge, cloudType)

// @variable The sum of each oscillator's polarity.
float sgnCount = math.sign(UO)
for val in cloudValues
    sgnCount += math.sign(val)

// @variable A gradient color based on the `sgnCount`.
color fillColor = color.from_gradient(sgnCount, -11, 11, dnColor, upColor)

// Calculate the maximum and minimum UO values for the cloud display.
float cloudMax = math.max(cloudValues.max(), UO)
float cloudMin = math.min(cloudValues.min(), UO)

// Plot the `cloudMax` and `cloudMin` and fill their space with the `fillColor`.
p1 = plot(cloudMax, "Cloud max", color.gray)
p2 = plot(cloudMin, "Cloud min", color.gray)
fill(p1, p2, fillColor)
// Plot the `UO`.
plot(UO, "Ultimate Oscillator", chart.fg_color, 3)
// Plot a horizontal line at 0.
hline(0)
//#endregion
````
