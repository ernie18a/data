<!-- tradingview-pine-id: PUB;594989e48420400a9ecdbcf7386e5df4 -->
<!-- tradingviewscripts-format: 1 -->
# TASC 2025.02 Autocorrelation Indicator

Source: https://www.tradingview.com/script/OQtTRc35-TASC-2025-02-Autocorrelation-Indicator/

## Description

█ OVERVIEW

This script implements the Autocorrelation Indicator introduced by John Ehlers in the "Drunkard's Walk: Theory And Measurement By Autocorrelation" article from the [February 2025 edition of TASC's Traders' Tips](https://traders.com/Documentation/FEEDbk_docs/2025/02/TradersTips.html). The indicator calculates the autocorrelation of a price series across several lags to construct a periodogram, which traders can use to identify market cycles, trends, and potential reversal patterns. 

█ CONCEPTS

Drunkard's walk

A drunkard's walk, formally known as a [random walk](https://en.wikipedia.org/wiki/Random_walk), is a type of stochastic process that models the evolution of a system or variable through successive random steps. 

In his article, John Ehlers relates this model to market data. He discusses two first- and second-order partial differential equations, modified for discrete (non-continuous) data, that can represent solutions to the discrete random walk problem: the diffusion equation and the wave equation. According to Ehlers, market data takes on a mixture of two "modes" described by these equations. He theorizes that when "diffusion mode" is dominant, trading success is almost a matter of luck, and when "wave mode" is dominant, indicators may have improved performance. 

Pink spectrum

John Ehlers explains that many recent academic studies affirm that market data has a pink spectrum, meaning the power spectral density of the data is proportional to the wavelengths it contains, like [pink noise](https://en.wikipedia.org/wiki/Pink_noise). A random walk with a pink spectrum suggests that the states of the random variable are correlated and not independent. In other words, the random variable exhibits long-range dependence with respect to previous states. 

Autocorrelation function (ACF)

[Autocorrelation](https://en.wikipedia.org/wiki/Autocorrelation) measures the correlation of a time series with a delayed copy, or lag, of itself. The autocorrelation function (ACF) is a method that evaluates autocorrelation across a range of lags, which can help to identify patterns, trends, and cycles in stochastic market data. Analysts often use ACF to detect and characterize long-range dependence in a time series. 

The Autocorrelation Indicator evaluates the ACF of market prices over a fixed range of lags, expressing the results as a color-coded heatmap representing a dynamic periodogram. Ehlers suggests the information from the periodogram can help traders identify different market behaviors, including: 
[*]Cycles: Distinguishable as repeated patterns in the periodogram.
[*]Reversals: Indicated by sharp vertical changes in the periodogram when the indicator uses a short data length. 
[*]Trends: Indicated by increasing correlation across lags, starting with the shortest, over time. 

█ USAGE

This script calculates the Autocorrelation Indicator on an input "Source" series, smoothed by Ehlers' UltimateSmoother filter, and plots several color-coded lines to represent the periodogram's information. Each line corresponds to an analyzed lag, with the shortest lag's line at the bottom of the pane. Green hues in the line indicate a positive correlation for the lag, red hues indicate a negative correlation (anticorrelation), and orange or yellow hues mean the correlation is near zero. 

Because Pine has a limit on the number of plots for a single indicator, this script divides the periodogram display into three distinct ranges that cover different lags. To see the full periodogram, add three instances of this script to the chart and set the "Lag range" input for each to a different value, as demonstrated in the chart above. 

With a modest autocorrelation length, such as 20 on a "1D" chart, traders can identify seasonal patterns in the price series, which can help to pinpoint cycles and moderate trends. For instance, on the daily ES1! chart above, the indicator shows repetitive, similar patterns through fall 2023 and winter 2023-2024. The green "triangular" shape rising from the zero lag baseline over different time ranges corresponds to seasonal trends in the data.

To identify turning points in the price series, Ehlers recommends using a short autocorrelation length, such as 2. With this length, users can observe sharp, sudden shifts along the vertical axis, which suggest potential turning points from upward to downward or vice versa.

---

## Source Code

````pine
//  TASC Issue: February 2025
//     Article: Drunkards Walk:
//              Theory And Measurement By Autocorrelation.
//  Article By: John F. Elhers
//    Language: TradingView's Pine Script® v6
// Provided By: PineCoders, for tradingview.com

//@version=6
title  = "TASC 2025.02 Autocorrelation Indicator"
stitle = "ACI"
indicator(title, stitle)

// --- Constants, enums, and inputs ---

// @variable Alias for `display.pane`.
DSP = display.pane

//@enum Range selection enumeration with three members.
enum R
    R1 = "0-32"
    R2 = "33-65"
    R3 = "66-98"

// @variable The source series to analyze.
float Src = input.source(close, "Source")
// @variable Length of each correlation calculation.
int Length = input.int(20, "Length")
// @variable If `true`, uses a 30-bar sine wave for testing.
bool iTest = input.bool(false, "Use test signal")
// @variable Lag range selection: 0-32, 33-65, or 66-98.
R iR = input.enum(R.R1, "Lag range")

// --- Functions ---

// @function      UltimateSmoother 
UltimateSmoother (float src, int period) =>
    float a1 = math.exp(-1.414 * math.pi / period)
    float c2 = 2.0 * a1 * math.cos(1.414 * math.pi / period)
    float c3 = -a1 * a1
    float c1 = (1.0 + c2 - c3) / 4.0
    float us = src
    if bar_index >= 4
        us := (1.0 - c1) * src + 
              (2.0 * c1 - c2) * src[1] - 
              (c1 + c3) * src[2] + 
              c2 * nz(us[1]) + c3 * nz(us[2])
    us

// @function      Autocorrelation heatmap
correlation(float src, simple int length) =>
    var array<float> corr = array.new<float>(101, 0.0)
    var array<color> col  = array.new<color>(101, #00000000)
    var array<float> data = array.new<float>(length)
    matrix<float>    mat  = matrix.new<float>()
    data.push(src)
    data.shift()
    mat.add_row(0, data)
    float sx  = math.sum(src, length)
    float sxx = math.sum(src * src, length)
    for l = 0 to 99
        array<float> lData = data[l]
        float sy  = sx[l]
        float syy = sxx[l]
        float sxy = na(lData) ? na : mat.mult(lData).first()
        float ca1 = length * sxx - sx * sx
        float ca2 = length * syy - sy * sy
        float c = 0.0
        if ca1 > 0.0 and ca2 > 0.0
            float ca3 = length * sxy - sx * sy
            corr.set(l + 1, ca3 / math.sqrt(ca1 * ca2))
    for l = 1 to 99
        float c = corr.get(l + 1)
        if c >= 0.0
            col.set(l, color.rgb(255 * (1.0 - c), 255, 0))
            continue
        if c < 0.0
            col.set(l, color.rgb(255, 255 * (1.0 + c), 0))
    col

// --- Calculations ---

//@variable The series to analyze (test signal or smoothed source). 
float Filt = switch
    iTest => math.sin(2.0 * math.pi * bar_index / 30.0)
    =>       UltimateSmoother(Src, Length)

//@variable Color array for the autocorrelation heatmap display.
array<color> C = correlation(Filt, Length)
// Slice the array into one of three ranges.
switch iR
    R.R1 => C := C.slice(0, 32)
    R.R2 => C := C.slice(33, 65)
    =>      C := C.slice(66, 98)

// Levels for the heatmap's plots
int IDX00 = iR == R.R1 ?  0 : (iR == R.R2 ? 33 : 66)
int IDX01 = iR == R.R1 ?  1 : (iR == R.R2 ? 34 : 67)
int IDX02 = iR == R.R1 ?  2 : (iR == R.R2 ? 35 : 68)
int IDX03 = iR == R.R1 ?  3 : (iR == R.R2 ? 36 : 69)
int IDX04 = iR == R.R1 ?  4 : (iR == R.R2 ? 37 : 70)
int IDX05 = iR == R.R1 ?  5 : (iR == R.R2 ? 38 : 71)
int IDX06 = iR == R.R1 ?  6 : (iR == R.R2 ? 39 : 72)
int IDX07 = iR == R.R1 ?  7 : (iR == R.R2 ? 40 : 73)
int IDX08 = iR == R.R1 ?  8 : (iR == R.R2 ? 41 : 74)
int IDX09 = iR == R.R1 ?  9 : (iR == R.R2 ? 42 : 75)
int IDX10 = iR == R.R1 ? 10 : (iR == R.R2 ? 43 : 76)
int IDX11 = iR == R.R1 ? 11 : (iR == R.R2 ? 44 : 77)
int IDX12 = iR == R.R1 ? 12 : (iR == R.R2 ? 45 : 78)
int IDX13 = iR == R.R1 ? 13 : (iR == R.R2 ? 46 : 79)
int IDX14 = iR == R.R1 ? 14 : (iR == R.R2 ? 47 : 80)
int IDX15 = iR == R.R1 ? 15 : (iR == R.R2 ? 48 : 81)
int IDX16 = iR == R.R1 ? 16 : (iR == R.R2 ? 49 : 82)
int IDX17 = iR == R.R1 ? 17 : (iR == R.R2 ? 50 : 83)
int IDX18 = iR == R.R1 ? 18 : (iR == R.R2 ? 51 : 84)
int IDX19 = iR == R.R1 ? 19 : (iR == R.R2 ? 52 : 85)
int IDX20 = iR == R.R1 ? 20 : (iR == R.R2 ? 53 : 86)
int IDX21 = iR == R.R1 ? 21 : (iR == R.R2 ? 54 : 87)
int IDX22 = iR == R.R1 ? 22 : (iR == R.R2 ? 55 : 88)
int IDX23 = iR == R.R1 ? 23 : (iR == R.R2 ? 56 : 89)
int IDX24 = iR == R.R1 ? 24 : (iR == R.R2 ? 57 : 90)
int IDX25 = iR == R.R1 ? 25 : (iR == R.R2 ? 58 : 91)
int IDX26 = iR == R.R1 ? 26 : (iR == R.R2 ? 59 : 92)
int IDX27 = iR == R.R1 ? 27 : (iR == R.R2 ? 60 : 93)
int IDX28 = iR == R.R1 ? 28 : (iR == R.R2 ? 61 : 94)
int IDX29 = iR == R.R1 ? 29 : (iR == R.R2 ? 62 : 95)
int IDX30 = iR == R.R1 ? 30 : (iR == R.R2 ? 63 : 96)
int IDX31 = iR == R.R1 ? 31 : (iR == R.R2 ? 64 : 97)
int IDX32 = iR == R.R1 ? 32 : (iR == R.R2 ? 65 : 98)

// Plot the lag levels with the calculated colors.
plot(IDX01, "S", C.get(0) , 2, display = DSP)
plot(IDX02, "S", C.get(1) , 2, display = DSP)
plot(IDX03, "S", C.get(2) , 2, display = DSP)
plot(IDX04, "S", C.get(3) , 2, display = DSP)
plot(IDX05, "S", C.get(4) , 2, display = DSP)
plot(IDX06, "S", C.get(5) , 2, display = DSP)
plot(IDX07, "S", C.get(6) , 2, display = DSP)
plot(IDX08, "S", C.get(7) , 2, display = DSP)
plot(IDX09, "S", C.get(8) , 2, display = DSP)
plot(IDX10, "S", C.get(9) , 2, display = DSP)
plot(IDX11, "S", C.get(10), 2, display = DSP)
plot(IDX12, "S", C.get(11), 2, display = DSP)
plot(IDX13, "S", C.get(12), 2, display = DSP)
plot(IDX14, "S", C.get(13), 2, display = DSP)
plot(IDX15, "S", C.get(14), 2, display = DSP)
plot(IDX16, "S", C.get(15), 2, display = DSP)
plot(IDX17, "S", C.get(16), 2, display = DSP)
plot(IDX18, "S", C.get(17), 2, display = DSP)
plot(IDX19, "S", C.get(18), 2, display = DSP)
plot(IDX20, "S", C.get(19), 2, display = DSP)
plot(IDX21, "S", C.get(20), 2, display = DSP)
plot(IDX22, "S", C.get(21), 2, display = DSP)
plot(IDX23, "S", C.get(22), 2, display = DSP)
plot(IDX24, "S", C.get(23), 2, display = DSP)
plot(IDX25, "S", C.get(24), 2, display = DSP)
plot(IDX26, "S", C.get(25), 2, display = DSP)
plot(IDX27, "S", C.get(26), 2, display = DSP)
plot(IDX28, "S", C.get(27), 2, display = DSP)
plot(IDX29, "S", C.get(28), 2, display = DSP)
plot(IDX30, "S", C.get(29), 2, display = DSP)
plot(IDX31, "S", C.get(30), 2, display = DSP)
plot(IDX32, "S", C.get(31), 2, display = DSP)
````
