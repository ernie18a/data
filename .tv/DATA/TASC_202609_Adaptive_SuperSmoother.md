<!-- tradingview-pine-id: PUB;ad2b361e592042d4a164d6eb2e3ef392 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# TASC 2026.09 Adaptive SuperSmoother

Source: https://www.tradingview.com/script/FnlMn99W-TASC-2026-09-Adaptive-SuperSmoother/

## Description

█ OVERVIEW

This script implements the Adaptive SuperSmoother by John F. Ehlers, as presented in the "Improved Filter Performance" article from the [September 2026 edition of the TASC Traders' Tips](https://traders.com/Documentation/FEEDbk_docs/2026/09/TradersTips.html). The script demonstrates a simple technique to adapt the SuperSmoother's critical period to improve the filter's responsiveness.

█ CONCEPTS

In his article, Ehlers explains that many adaptive smoothers rely on [Exponential Moving Averages (EMAs)](https://www.tradingview.com/support/solutions/43000592270/) at their core. Typically, these smoothers dynamically adjust an EMA's smoothing factor (alpha) based on specific volatility measures, often to reduce sensitivity during periods of volatile or choppy price movements. However, he suggests that EMAs are not great filters; they are first-order smoothers that offer very limited reduction, or attenuation, of high-frequency (low-period) signals in the dataset. For example, for an EMA with a critical period of 12 bars, the maximum gain reduction of smaller-period cycles is only about -17 decibels (dB). At this level of attenuation, a significant amount of high-frequency noise remains in an EMA-filtered series.

Ehlers proposes that traders should use the SuperSmoother instead of an EMA in most applications, including adaptive filtering. The SuperSmoother is a second-order filter. It has a second-degree polynomial in its transfer function and a zero of transmission at the [Nyquist frequency](https://en.wikipedia.org/wiki/Nyquist_frequency). Thanks to these characteristics, the SuperSmoother offers a substantially greater reduction of higher frequencies than an EMA. Additionally, Ehlers notes that the filter's computational lag is not perceptibly greater than that of an EMA, further underscoring its usefulness as an improved filter. 

Ehlers notes that there are many ways to make the SuperSmoother adaptive to market conditions. He demonstrates his preferred method, dubbed the Adaptive SuperSmoother, in the article's code. Rather than tuning the smoothing factor of an EMA based on a volatility measure, the Adaptive SuperSmoother dynamically adjusts the critical period of one SuperSmoother based on the rate of change (ROC) in another. The steps to calculate the filter are as follows:

[*]Calculate a SuperSmoother filter using a fixed critical period. 
[*]Measure the one-bar ROC in the first filter, and calculate the RMS (Root Mean Square) of the result over a specified length (81 bars by default, as per the article). 
[*]Scale the ROC by the RMS, and limit the maximum scaled value to 2.
[*]Calculate the factor for adjusting the final filter's period. The value is the square of one minus half of the scaled ROC. 
[*]Multiply the first filter's period by the factor from step 4, then limit the result to a minimum value of 2, to calculate the adaptive period. 
[*]Calculate a separate SuperSmoother using the adaptive period from step 5. This filter is the Adaptive SuperSmoother. 

The resulting filter dynamically reduces its critical period to increase responsiveness when changes in the fixed-period SuperSmoother increase relative to the RMS. This behavior applies reasonable smoothing, while offering significantly reduced lag for aligning with market movements. 

█ USAGE

This indicator plots a fixed-period SuperSmoother (red) and the Adaptive SuperSmoother (blue) on the main chart as well as an oscillator showing the relationship between the filters in the separate pane. Ehlers recommends analyzing the difference between these two filters to derive trading signals. The preferred trading direction is long when the Adaptive SuperSmoother is above the fixed-period SuperSmoother, and short otherwise. Ehlers also suggests that peaks and valleys in the difference between the filters can help identify turning points. 

This script includes three inputs for customizing the filter calculations:

[*]Source: The source series to process. The default is "Close".
[*]Base period: The base period of the filters. The default is 20.
[*]RMS length: The number of bars in the RMS calculation. The default is 81. 

The snapshot below shows the indicator's outputs using default settings on a 1D S&P 500 Futures chart. The Adaptive SuperSmoother responds to market movements more quickly than the fixed-period SuperSmoother, while still smoothing out high-frequency noise in the data:

[image]https://www.tradingview.com/x/oJZZ8pQZ/[/image]

---

## Source Code

````pine
//  TASC Issue: September 2026
//     Article: Improved Filter Performance
//              Adaptive SuperSmoother
//  Article By: John F. Ehlers
//    Language: TradingView's Pine Script™ v6
// Provided By: PineCoders, for tradingview.com

//@version=6
TITLE = "TASC 2026.09 Adaptive SuperSmoother"
SHORTTITLE = "SS - Adaptive"
indicator(TITLE, SHORTTITLE)


//#region --- Inputs --- 

// @variable The source series to analyze. 
float srcInput = input.source(close, "Source")
// @variable The base period of the filters. 
int perInput = input.int(20, "Base period", 2)
// @variable The RMS length for the Adaptive SuperSmoother.
int rmsInput = input.int(81, "RMS length", 2)
//#endregion


//#region --- Functions ---

// @function      Calculates the root mean square (RMS) of a 
//                series over a specified number of bars.
// @param source  The series of values to process.
// @param length  The number of bars in the calculation.
// @returns       The RMS value. 
rms(float source, int length) =>
    math.sqrt(ta.sma(source * source, length))

// @function      Calculates the SuperSmoother with a specified
//                critical period. The SuperSmoother is a 
//                second-order IIR filter. Its transfer response
//                includes a second-degree polynomial in the 
//                denominator. The filter offers significantly 
//                greater maximum attenuation of high frequencies,
//                without a perceptibly greater amount of 
//                computational lag.
// @param source  The series of values to process.
// @param period  The filter's critical period.
// @returns       The smoothed series.
superSmoother(float source, int period) =>
    float w   = 1.414 * math.pi / period
    float q   = math.exp(-w)
    float c1  = 2.0 * q * math.cos(w)
    float c2  = q * q
    float a0  = (1.0 - c1 + c2) / 2.0
    float res = source
    if bar_index >= 4
        res := (
            a0 * (source + source[1])
            + c1 * res[1] - c2 * res[2]
        )
    res

// @function         Calculates the Adaptive SuperSmoother. The filter
//                   adapts its critical period based on the rate of 
//                   change in an initial SuperSmoother with a specified
//                   base period. 
// @param source     The series of values to process.
// @param period     The base period of the filter calculation.
// @param rmsLength  Optional. The number of bars over which to calculate 
//                   the RMS of ROC in the base SuperSmoother. The RMS 
//                   scales the ROC in the adaptive period calculation.
//                   The default is 81.
// @returns          The adaptively smoothed series. 
adaptiveSuperSmoother(
    float source, int period, int rmsLength = 81
) =>
    float ss = superSmoother(source, period)
    float roc1 = nz(ss - ss[1])
    float rocRMS = rms(roc1, rmsLength)
    float roc = 0.0
    if rocRMS > 0
        roc := math.min(math.abs(roc1 / rocRMS), 2.0)
    float factor = math.pow(1.0 - 0.5 * roc, 2)
    int aPeriod = math.max(int(period * factor), 2)
    superSmoother(source, aPeriod)
//#endregion


//#region --- Calculations and plots ---

// @variable The fixed-period SuperSmoother.
float ssBase = superSmoother(srcInput, perInput)
// @variable The Adaptive SuperSmoother. 
float ssAdaptive = adaptiveSuperSmoother(srcInput, perInput, rmsInput)

float osc = ssAdaptive - ssBase

// Plot the two series for visual comparison. 
plot(ssBase,     "SuperSmoother",          color.red,  force_overlay = true)
plot(ssAdaptive, "Adaptive SuperSmoother", color.blue, force_overlay = true)

plot(0,   "SS Base",                color.red)
plot(osc, "Adaptive SS Oscillator", color.blue)
//#endregion
````
