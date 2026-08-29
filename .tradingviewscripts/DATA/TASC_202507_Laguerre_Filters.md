<!-- tradingview-pine-id: PUB;323f9e665b3c45e2ae7e89fa69bb98b9 -->
<!-- tradingviewscripts-format: 1 -->
# TASC 2025.07 Laguerre Filters

Source: https://www.tradingview.com/script/6QWQYUT8-TASC-2025-07-Laguerre-Filters/

## Description

█ OVERVIEW

This script implements the Laguerre filter and oscillator described by John F. Ehlers in the article "A Tool For Trend Trading, Laguerre Filters" from the [July 2025 edition of TASC's Traders' Tips](https://traders.com/Documentation/FEEDbk_docs/2025/07/TradersTips.html#). The new Laguerre filter utilizes the UltimateSmoother filter in place of an exponential moving average (EMA) in its calculation, offering improved responsiveness and reduced lag. 

█ CONCEPTS

As Ehlers explains in his article, the Laguerre filter is a form of transversal filter. A transversal filter calculates an output signal using a tapped delay line. It creates multiple delayed versions of an input signal, applies weight to each delay, and then calculates their sum to generate the filtered result. 

The Laguerre filter's structure relies on Laguerre polynomials — solutions to a differential equation solved by Edmond Laguerre in the 1800s. When Ehlers analyzed the formula for these polynomials on discrete systems (e.g., financial time series), he found that the first term's expression corresponds to an EMA response, and all subsequent terms correspond to an all-pass response. In contrast to other filter types, an all-pass filter produces phase shift (i.e., delay) in an input signal's components without affecting its amplitude. 

Ehlers observed that these characteristics of Laguerre polynomials make them suitable for use in a transversal filter structure, and thus the Laguerre filter was born. However, he notes that EMAs are not great filters in general. As such, to improve on the Laguerre filter's design, Ehlers modified it by replacing the EMA term with his UltimateSmoother filter. The resulting Laguerre filter has significantly reduced lag, achieving a tighter response to market fluctuations while maintaining smoothness. Ehlers suggests that traders can analyze crossings between the UltimateSmoother and this Laguerre filter, or those between two Laguerre filters of different order, for helpful buy and sell signals.

In addition to the Laguerre filter, Ehlers derived a smooth, low-lag oscillator based on the difference between the first and second terms in the modified filter structure, scaled by the root mean square (RMS). The resulting oscillator provides an alternative filtered representation of market data, which can help traders identify swing and mean-reversion signals. 

█ USAGE

This indicator calculates both the Laguerre filter and the Laguerre oscillator described in Ehlers' article. It displays the Laguerre filter on the main chart pane and the oscillator in a separate pane. 

Users can control the behavior of the filter and oscillator with the inputs in the "Settings/Inputs" tab:

[*]The "Period" input defines the critical period of the UltimateSmoother used in the Laguerre filter and oscillator calculations. Its default value is 30. 
[*]The "Gamma" input determines the weighting behavior of the Laguerre filter and oscillator. It accepts a positive value between 0 and 1. Use a lower value for quicker responsiveness to market changes, and a higher value for trends. The default value is 0.5.
[*]The "RMS length" input determines the length of the RMS calculation for oscillator normalization. The default value is 100 bars.

---

## Source Code

````pine
//  TASC Issue: July 2025
//     Article: A Tool For Trend Trading
//              Laguerre Filters
//  Article By: John F. Ehlers
//    Language: TradingView's Pine Script® v6
// Provided By: PineCoders, for tradingview.com


//@version=6
TITLE       = "TASC 2025.07 Laguerre Filters"
SHORT_TITLE = "LF"
indicator(TITLE, SHORT_TITLE) 


//#region   --- Inputs ---

// @variable The source series. 
float sourceInput = input.source(close, "Source:")

// @variable The critical period of the UltimateSmoother. 
const string TT1 = "Critical period of the UltimateSmoother."
int usInput = input.int(30, "Period:", 3, tooltip = TT1)

// @variable The "gamma" value for Laguerre calculations.
const string TT2 = "Use a lower value for quicker responsiveness to market movements, and a higher value for trends."
float gammaInput = input.float(0.5, "Gamma:", 0.0, 0.999, 0.01, tooltip = TT2)

// @variable The number of bars in the RMS calculation.
const string TT3 = "Length of the RMS for oscillator normalization."
int rmsInput = input.int(100, "RMS length:", 1, tooltip = TT3)
//#endregion


//#region   --- Functions ---

// @function      Calculates the UltimateSmoother filter. 
//                The UltimateSmoother's response is the 
//                result of subtracting the response of 
//                a highpass filter from that of an allpass
//                filter.
//                See [TASC 2024.04](https://www.tradingview.com/script/X67OSwqc-TASC-2024-04-The-Ultimate-Smoother/)
// @param src     The source series to process.
// @param period  The length of the filter's critical period.
// @returns       The smoothed series.
ultimateSmoother(float src, int period) =>
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


// @function      Calculates a modified Laguerre filter based 
//                on the UltimateSmoother. 
// @param src     The source series to process.
// @param period  The critical period of the UltimateSmoother 
//                used as the first term in the Laguerre
//                polynomial.
// @param gamma   Optional. Controls the phase response of 
//                the filter's terms. With a smaller gamma, 
//                the filter is more responsive to rapid 
//                changes. With a larger gamma, the filter 
//                is more responsive to trends. The default is 0.8.
// @returns       The filtered series. 
laguerreFilter(float src, int period, float gamma = 0.8) =>
    float l0 = ultimateSmoother(src, period)
    float l1 = 0.0 
    float l2 = 0.0 
    float l3 = 0.0
    float l4 = 0.0 
    float l5 = 0.0
    float g1 = 1.0 - gamma
    l1 := g1 * nz(l0[1], src) + gamma * nz(l1[1], src)
    l2 := g1 * nz(l1[1], src) + gamma * nz(l2[1], src)
    l3 := g1 * nz(l2[1], src) + gamma * nz(l3[1], src)
    l4 := g1 * nz(l3[1], src) + gamma * nz(l4[1], src)
    l5 := g1 * nz(l4[1], src) + gamma * nz(l5[1], src)
    float lf = nz(l0 + 4.0 * l1 + 6.0 * l2 + 4.0 * l3 + l5) / 16


// @function         Calculates the root mean square (RMS) of a series.
// @param source     The series of values to process.
// @param length     The number of bars in the calculation.
// @returns          The RMS of the `source` values over `length` bars.
rms(float source, int length) =>
    math.sqrt(ta.sma(source * source, length))


// @function      Calculates the Laguerre oscillator, representing 
//                the normalized difference between zeroth- and 
//                first-order terms from a modified Laguerre 
//                filter based on the UltimateSmoother.
// @param src     The source series to process. 
// @param period  The critical period of the UltimateSmoother. 
// @param gamma   Optional. Controls the phase response of 
//                the filter's terms. With a smaller gamma, 
//                the filter is more responsive to rapid 
//                changes. With a larger gamma, the filter 
//                is more responsive to trends. The default is 0.5.
// @param rmsLen  Optional. The length of the RMS calculation that 
//                normalizes the oscillator. The default is 100.
// @returns       The Laguerre oscillator. 
laguerreOscillator(float src, int period, float gamma = 0.5, int rmsLen = 100) =>
    float l0   = ultimateSmoother(src, period)
    float l1   = 0.0
    l1 := nz(l0[1], src) + gamma * (nz(l1[1], src) - l0)
    float diff = l0 - l1
    float rms  = rms(diff, rmsLen)
    float lOsc = rms != 0.0 ? diff / rms : rms
//#endregion


//#region   --- Calculations and display ---

// @variable The Laguerre filter of the `src` series with specified settings. 
float filter = laguerreFilter(sourceInput, usInput, gammaInput)

// @variable The Laguerre oscillator for the `src` series with specified settings. 
float oscillator = laguerreOscillator(sourceInput, usInput, gammaInput, rmsInput)

// Plot the `filter` series on the main chart pane.
plot(filter, "Laguerre Filter", linewidth = 2, force_overlay = true)

// Display the `oscillator` series and a zero line in a separate pane.
plot(oscillator, "Laguerre Oscillator", #f23645, 2)

hline(0, "Zero line", chart.fg_color)
//#endregion
````
