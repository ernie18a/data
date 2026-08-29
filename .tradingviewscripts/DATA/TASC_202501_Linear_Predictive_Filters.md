<!-- tradingview-pine-id: PUB;7fd1d7961a8a465796a7c530b11307b6 -->
<!-- tradingviewscripts-format: 1 -->
# TASC 2025.01 Linear Predictive Filters

Source: https://www.tradingview.com/script/i8qanSzP-TASC-2025-01-Linear-Predictive-Filters/

## Description

█ OVERVIEW

This script implements a suite of tools for identifying and utilizing dominant cycles in time series data, as introduced by John Ehlers in the "Linear Predictive Filters And Instantaneous Frequency" article featured in the [January 2025 edition of TASC's Traders' Tips](https://traders.com/Documentation/FEEDbk_docs/2025/01/TradersTips.html). Dominant cycle information can help traders adapt their indicators and strategies to changing market conditions. 

█ CONCEPTS

Conventional technical indicators and strategies often rely on static, unchanging parameters, which may fail to account for the dynamic nature of market data. In his article, John Ehlers applies digital signal processing principles to address this issue, introducing linear predictive filters to identify cyclic information for adapting indicators and strategies to evolving market conditions. 

This approach treats market data as a [complex](https://en.wikipedia.org/wiki/Complex_number) series in the time domain. Analyzing the series in the frequency domain reveals information about its cyclic components. To reduce the impact of frequencies outside a range of interest and focus on a specific range of cycles, Ehlers applies second-order [highpass](https://en.wikipedia.org/wiki/High-pass_filter) and [lowpass filters](https://en.wikipedia.org/wiki/Low-pass_filter) to the price data, which attenuate or remove wavelengths outside the desired range. This band-limited analysis isolates specific parts of the frequency spectrum for various trading styles, e.g., longer wavelengths for position trading or shorter wavelengths for swing trading.  

After filtering the series to produce band-limited data, Ehlers applies a linear predictive filter to predict future values a few bars ahead. The filter, calculated based on the techniques proposed by Lloyd Griffiths, adaptively minimizes the error between the latest data point and prediction, successively adjusting its coefficients to align with the band-limited series. The filter's coefficients can then be applied to generate an adaptive estimate of the band-limited data's structure in the frequency domain and identify the dominant cycle. 

█ USAGE

This script implements the following tools presented in the article:

[*]Griffiths Predictor 
This tool calculates a linear predictive filter to forecast future data points in band-limited price data. The crosses between the prediction and signal lines can provide potential trade signals.
[*]Griffiths Spectrum 
This tool calculates a partial frequency spectrum of the band-limited price data derived from the linear predictive filter's coefficients, displaying a color-coded representation of the frequency information in the pane. This mode's display represents the data as a periodogram. The bottom of each plotted bar corresponds to a specific analyzed period (inverse of frequency), and the bar's color represents the presence of that periodic cycle in the time series relative to the one with the highest presence (i.e., the dominant cycle). Warmer, brighter colors indicate a higher presence of the cycle in the series, whereas darker colors indicate a lower presence. 
[*]Griffiths Dominant Cycle  
This tool compares the cyclic components within the partial spectrum and identifies the frequency with the highest power, i.e., the dominant cycle. Traders can use this dominant cycle information to tune other indicators and strategies, which may help promote better alignment with dynamic market conditions.

Notes on parameters

Bandpass boundaries:
In the article, Ehlers recommends an upper bound of 125 bars or higher to capture longer-term cycles for position trading. He recommends an upper bound of 40 bars and a lower bound of 18 bars for swing trading. If traders use smaller lower bounds, Ehlers advises a minimum of eight bars to minimize the potential effects of aliasing. 

Data length:
The Griffiths predictor can use a relatively small data length, as autocorrelation diminishes rapidly with lag. However, for optimal spectrum and dominant cycle calculations, the length must match or exceed the upper bound of the bandpass filter. Ehlers recommends avoiding excessively long lengths to maintain responsiveness to shorter-term cycles.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © PineCodersTASC

//  TASC Issue: January 2025
//     Article: Linear Predictive Filters And
//              Instataneous Frequency
//  Article By: John F. Ehlers
//    Language: TradingView's Pine Script™ v6
// Provided By: PineCoders, for tradingview.com

//@version=6
title  = 'TASC 2025.01 Linear Predictive Filters'
stitle = 'LPF'
indicator(title, stitle, false)

//#region Inputs and constants:

// @variable Alias for `display.all`.
DSPA = display.all
// @variable Alias for `display.none`.
DSPN = display.none
// @variable Alias for `plot.style_columns`.
PSH = plot.style_columns
// @variable Full circular rotation (360 degrees).
float FROT = 2.0 * math.pi
// @variable Square root of 2 (~1.414).
float SQRT2 = math.sqrt(2.0)
// @variable Perfect cycle test signal (30 bars).
float TS = math.sin(FROT * bar_index / 30.0)

// @enum Enumeration of indicator display choices.
enum eID
    GP  = 'Griffiths Predictor'
    GS  = 'Griffiths Spectrum'
    GD  = 'Griffiths Dominant Cycle'
    GSD = 'Griffiths Spectrum and Dominant Cycle'

// @variable Indicator display choice.
eID iChoice = input.enum(eID.GSD, 'Select Indicator:')
// @variable Enables the test signal.
bool iTest  = input.bool(false, 'Use Test Signal:')

// Parameters:
float Src    = input.source(close, 'Source:')
int   LBound = input.int(18, 'Lower Bound:')
int   UBound = input.int(40, 'Upper Bound:')
int   Length = input.int(40, 'Length:')
int   BarsF  = input.int(2,'Griffiths Predictor Bars Forward:')
//#endregion

//#region Filter functions

// @function High Pass Filter.
HP (float Source, int Period) =>
    float a0 = math.pi * math.sqrt(2.0) / Period
    float a1 = math.exp(-a0)
    float c2 = 2.0 * a1 * math.cos(a0)
    float c3 = -a1 * a1
    float c1 = (1.0 + c2 - c3) * 0.25
    float hp = 0.0
    if bar_index >= 4
        hp := c1 * (Source - 2.0 * Source[1] + Source[2]) + 
              c2 * nz(hp[1]) + c3 * nz(hp[2])
    hp

// @function Super Smoother.
SS (float Source, int Period) =>
    float a0 = math.pi * math.sqrt(2.0) / Period
    float a1 = math.exp(-a0)
    float c2 = 2.0 * a1 * math.cos(a0)
    float c3 = -a1 * a1
    float c1 = 1.0 - c2 - c3
    float ss = Source
    if bar_index >= 4
        ss := c1 * ((Source + Source[1]) / 2.0) + 
              c2 * nz(ss[1]) + c3 * nz(ss[2])
    ss

// @function Common function.
CF (float Source = close, int LowerB = 18, int UpperB = 40, 
 bool Test=false ) =>
    float HP   = HP(Source, UpperB)
    float LP   = SS(HP, LowerB)
    float Peak = 0.1
    Peak := 0.991 * nz(Peak[1])
    if math.abs(LP) > Peak
        Peak := math.abs(LP)
    if Test
        TS
    else
        float Signal = 0.0
        if Peak != 0.0
            Signal := LP / Peak
        Signal
//#endregion

//#region Griffiths Predictor

GP (float source = close, int lowerB = 18, int upperB = 40,
 int length = 18, int barsF = 2, bool Test = false) =>
    float MU     = 1.0 / length
    float Signal = CF(source, lowerB, upperB, Test)
    var array<float> XX   = array.new<float>(length + 1, 0.0)
    var array<float> Coef = array.new<float>(length + 1, 0.0)
    float XBar = 0.0
    XX.set(length, Signal)
    for count = 1 to length - 1
        XX.set(count, nz(Signal[length - count]))
    for count = 1 to length
        XBar += XX.get(length - count) * Coef.get(count)
    for count = 1 to length
        Coef.set(count, Coef.get(count) + 
                 MU * (XX.get(length) - XBar) *
                 XX.get(length - count))
    // Prediction
    float XPred = 0.0
    for advance = 1 to barsF
        XPred := 0.0
        for count = 1 to length
            XPred += XX.get(length + 1 - count) * Coef.get(count)
        for count = advance to length - advance
            XX.set(count, XX.get(count + 1))
        for count = 1 to length - 1
            XX.set(count, XX.get(count + 1))
        XX.set(length, XPred)
    [Signal, XPred]
//#endregion

//#region Griffiths Spectrum

GS (float source = close, int lowerB = 10, int upperB = 40, 
 int length = 40, bool Test = false) =>
    int LP1 = length + 1 , float MU = 1.0 / length
    float Signal = CF(source, lowerB, upperB, Test)
    var array<float>  XX   = array.new<float>(LP1, 0.0)
    var array<float>  Coef = array.new<float>(LP1, 0.0)
    var matrix<float> Pwr  = matrix.new<float>(LP1, 2, 0.0)
    float XBar = 0.0
    XX.set(length, Signal)
    for count = 1 to length - 1
        XX.set(count, nz(Signal[length - count]))
    for count = 1 to length
        XBar += XX.get(length - count) * Coef.get(count)
    for count = 1 to length
        Coef.set(count, Coef.get(count) + 
                 MU * (XX.get(length) - XBar) *
                 XX.get(length - count))
    // Instataneous Frequency
    for period = lowerB to upperB
        Pwr.set(period, 1, Pwr.get(period, 0))
        float re = 0.0 , float im = 0.0
        for count = 1 to length
            float a0 = FROT * count / period
            re += Coef.get(count) * math.cos(a0)
            im += Coef.get(count) * math.sin(a0)
        float denom = math.pow(1.0 - re, 2.0) + math.pow(im, 2.0)
        Pwr.set(period, 0, 0.1 / denom)
    float MaxPwr = Pwr.col(0).max()
    if MaxPwr != 0 
        for period = lowerB to upperB
            Pwr.set(period, 0, Pwr.get(period, 0) / MaxPwr)
    // Plot the Spectrum Colors
    array<color> Spectrum = array.new<color>(100, #000000)
    for period = lowerB to upperB
        // Convert Power to RGB Color for display
        float p0 = Pwr.get(period, 0)
        float r  = p0 >= 0.5 ? 255.0 : 255.0 * 2.0 * p0
        float g  = p0 >= 0.5 ? 255.0 * (2.0 * p0 - 1.0) : 0.0
        Spectrum.set(period, color.rgb(r, g, 0.0))
    Spectrum
//#endregion

//#region Griffiths Dominant Cycle

GD (float source = close, int lowerB = 18, int upperB = 40,
 int length = 40, bool Test = false) =>
    int LP1 = length + 1 , float MU = 1.0 / length
    float Signal = CF(source, lowerB, upperB, Test)
    var array<float>  XX   = array.new<float>(LP1, 0.0)
    var array<float>  Coef = array.new<float>(LP1, 0.0)
    var matrix<float> Pwr  = matrix.new<float>(LP1, 2, 0.0)
    float XBar = 0.0
    XX.set(length, Signal)
    for count = 1 to length - 1
        XX.set(count, nz(Signal[length - count]))
    for count = 1 to length
        XBar += XX.get(length - count) * Coef.get(count)
    for count = 1 to length
        Coef.set(count, Coef.get(count) + 
                 MU * (XX.get(length) - XBar) *
                 XX.get(length - count))
    // Instataneous Frequency
    for period = lowerB to upperB
        Pwr.set(period, 1, Pwr.get(period, 0))
        float re = 0.0 , float im = 0.0
        for count = 1 to length
            float a0 = FROT * count / period
            re += Coef.get(count) * math.cos(a0)
            im += Coef.get(count) * math.sin(a0)
        denom = math.pow(1.0 - re, 2.0) + math.pow(im, 2.0)
        Pwr.set(period, 0, 0.1 / denom)
    float MaxPwr = Pwr.col(0).max()
    float cycle  = Pwr.col(0).indexof(MaxPwr)
    cycle := switch
        cycle >= cycle[1] + 2.0 => cycle[1] + 2.0
        cycle <= cycle[1] - 2.0 => cycle[1] - 2.0
        => cycle
    cycle
//#endregion

//#region Plots:

// Indicator IO Conditionals:
D1 = iChoice == eID.GP ? DSPA : DSPN
D2 = iChoice == eID.GS or iChoice == eID.GSD ? DSPA : DSPN
D3 = iChoice == eID.GD or iChoice == eID.GSD ? DSPA : DSPN
// Griffiths Predictor
[s2, p2] = GP(Src, LBound, UBound, Length, 2, iTest)
plot(s2, 'Signal', color.blue, display = D1)
hline(0, display = D1)
plot(p2, 'Predict', color.red, display = D1)
// Griffiths Spectrum
array<color> SP = GS(Src, LBound, UBound, math.max(UBound, Length), iTest)
plot(19, '', SP.get(18), 1, PSH, false, 18, display = D2)
plot(20, '', SP.get(19), 1, PSH, false, 19, display = D2)
plot(21, '', SP.get(20), 1, PSH, false, 20, display = D2)
plot(22, '', SP.get(21), 1, PSH, false, 21, display = D2)
plot(23, '', SP.get(22), 1, PSH, false, 22, display = D2)
plot(24, '', SP.get(23), 1, PSH, false, 23, display = D2)
plot(25, '', SP.get(24), 1, PSH, false, 24, display = D2)
plot(26, '', SP.get(25), 1, PSH, false, 25, display = D2)
plot(27, '', SP.get(26), 1, PSH, false, 26, display = D2)
plot(28, '', SP.get(27), 1, PSH, false, 27, display = D2)
plot(29, '', SP.get(28), 1, PSH, false, 28, display = D2)
plot(30, '', SP.get(29), 1, PSH, false, 29, display = D2)
plot(31, '', SP.get(30), 1, PSH, false, 30, display = D2)
plot(32, '', SP.get(31), 1, PSH, false, 31, display = D2)
plot(33, '', SP.get(32), 1, PSH, false, 32, display = D2)
plot(34, '', SP.get(33), 1, PSH, false, 33, display = D2)
plot(35, '', SP.get(34), 1, PSH, false, 34, display = D2)
plot(36, '', SP.get(35), 1, PSH, false, 35, display = D2)
plot(37, '', SP.get(36), 1, PSH, false, 36, display = D2)
plot(38, '', SP.get(37), 1, PSH, false, 37, display = D2)
plot(39, '', SP.get(38), 1, PSH, false, 38, display = D2)
plot(40, '', SP.get(39), 1, PSH, false, 39, display = D2)
// Griffiths Dominant Cycle
float cycle = GD(Src, LBound, UBound, math.max(UBound, Length), iTest)
plot(cycle, 'Dominant Cycle', color.blue, 3, display = D3)
//#endregion
````
