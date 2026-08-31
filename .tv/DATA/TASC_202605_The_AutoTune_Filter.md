<!-- tradingview-pine-id: PUB;a8e321b8a11b49029658c1bc642d034b -->
<!-- tradingviewscripts-format: 1 -->
# TASC 2026.05 The AutoTune Filter

Source: https://www.tradingview.com/script/GqKlw3yv-TASC-2026-05-The-AutoTune-Filter/

## Description

█ OVERVIEW

This script implements the AutoTune Filter described by John F. Ehlers in the article "A Rolling Autocorrelation Function" from the [May 2026 edition of the TASC Traders' Tips](https://traders.com/Documentation/FEEDbk_docs/2026/05/TradersTips.html). The script analyzes rolling autocorrelation in filtered price data to calculate a band-pass filter that dynamically adjusts to apparent dominant cycles. 

█ CONCEPTS

Autocorrelation function (ACF)

[Autocorrelation](https://en.wikipedia.org/wiki/Autocorrelation) measures the correlation of a time series with a lagged version of itself. The autocorrelation function (ACF) evaluates autocorrelation across a range of lags to gauge the extent to which values in a series vary jointly with previous values at different offsets. 

The ACF can help traders identify patterns and trends in stochastic market data, characterize long-range dependence in a series, and more. In his article, Ehlers explains how the ACF can serve as a "bridge" between analysis in the time and frequency domains for identifying dominant cycles in market data. 

Ehlers notes that at low lags, such as one bar, the autocorrelation in price data tends to be very high because prices don't often change dramatically from one bar to the next. As the lag increases, autocorrelation often decreases, reaching near zero for offsets at which the latest prices do not show a clear relationship with past prices. 

However, he also observed that at specific lags, anticorrelation (negative correlation) can emerge, where the current values in the series move in one direction while past values move in the opposite direction. Based on this observation, he suggests that a lag with strong anticorrelation can indicate a significant cycle in the market data, where the cycle length is twice that of the analyzed lag. 

To understand why this behavior can indicate significant cycles, consider a sine wave that completes a full oscillation every 20 bars. If the series is currently moving up, it will then move down 10 bars later, and then complete the cycle by moving up again 10 bars after that. The ACF of that sine wave returns a value of -1 for a lag of 10 bars, but not for other lower lags or higher lags up to 20. 

In other words, a pure sine wave with a given period has perfect anticorrelation with a delayed version of itself that is offset by half of that period.

While market data does not typically behave like a pure sine wave, the same underlying principle applies: if the current prices exhibit a strong anticorrelation with previous prices at a given offset, a dominant cycle with a length of twice that offset is likely present in the current data. 

AutoTune Filter

Ehlers proposes that traders can use the dominant cycle obtained via autocorrelation to set the critical period of a filter. Tuning a filter to respond most strongly to the measured cycle may promote more consistency in time alignment and help reduce destructive phase shifts. 

He demonstrates one such implementation with his AutoTune Filter, an adaptive band-pass filter whose center period dynamically increments toward the dominant cycle calculated from an ACF over a given window.

The steps to calculate the AutoTune Filter are as follows:

[*]Apply a two-pole high-pass filter to the series to reduce the effect of low-frequency (long-period) cycles on the autocorrelation calculation. The filtered series emphasizes cycles with lengths up to the specified cutoff period, and attenuates all others.
[*]Compute the rolling ACF of the filtered data across the same window length as the filter's cutoff period. 
[*]Check the autocorrelation for each lag period, and identify the smallest lag with the lowest autocorrelation value. Multiply that lag by two to obtain the dominant cycle for the analyzed window.
[*]If the difference between the current and previous dominant cycle is greater than two, limit the result for the current bar to two greater or less than the previous cycle's value to prevent large, sudden shifts in the filter's center period. 
[*]Finally, compute a band-pass filter using the value from step 4 as the center period.

█ USAGE

This indicator includes four display modes to visualize the AutoTune Filter's calculations:

[*]"High-pass filter": Plots the high-pass filtered data that the script analyzes for autocorrelation calculations. 
[*]"Min. correlation": Plots the lowest autocorrelation value calculated for the filtered series over the analyzed window. 
[*]"Dominant cycle": Plots the dominant cycle value that the final filter uses for its center period. 
[*]"Tuned band-pass filter" (default): Plots the final band-pass filtered result, i.e., the AutoTune filter. 

Ehlers suggests that traders can identify peaks and valleys in prices for potential mean reversion signals by analyzing the rate of change in the tuned band-pass filter. If the rate of change is zero, the current price might be near a local high if the filter's value is positive, or near a local low if the value is negative.

Users can analyze the additional outputs to gain further insight into the filter's behaviors, and they can pass these plotted values to other scripts via source inputs for easy use in other custom calculations. 

█ INPUTS

The indicator includes the following inputs in the "Settings/Inputs" tab:

[*]Source: The series of values to process.
[*]Window: The window length of the ACF calculation, and the cutoff period of the high-pass filter. The maximum possible dominant cycle length is two times this value. 
[*]Output: One of the four display modes ("High-pass filter", "Min. correlation", "Dominant cycle", or "Tuned band-pass filter").

---

## Source Code

````pine
//  TASC Issue: May 2026
//     Article: A Rolling Autocorrelation Function
//              The AutoTune Filter
//  Article By: John F. Ehlers
//    Language: TradingView's Pine Script® v6
// Provided By: PineCoders, for tradingview.com

//@version=6
indicator("TASC 2026.05 The AutoTune Filter", "AutoTune")


//#region --- Constants and inputs ---

// @enum An enumeration of display options.
enum disp
    F = "High-pass filter"
    M = "Min. correlation"
    D = "Dominant cycle"
    B = "Tuned band-pass filter"

// @variable The source series to process.
float source = input.source(close, "Source:")
// @variable The window length of the AutoTune Filter.
int window = input.int(20, "Window:", 3)
// @variable The selected display option.
disp dispType = input.enum(disp.B, title = "Output:")
//#endregion


//#region --- Functions ---

// @function      Calculates Ehlers' high-pass filter.
// @param src     The series of values to process.
// @param period  The cutoff period.
// @returns       The high-pass filtered value.
hpf(float src, int period) =>
    float w   = 1.414 * math.pi / period
    float q   = math.exp(-w)
    float c1  = 2.0 * q * math.cos(w)
    float c2  = q * q
    float a0  = 0.25 * (1.0 + c1 + c2)
    float res = 0.0
    if bar_index >= 4
        res := (
            a0 * (src - 2.0 * src[1] + src[2])
            + c1 * nz(res[1]) - c2 * nz(res[2])
        )
    res

// @function      Calculates Ehlers' band-pass filter.
// @param src     The series of values to process.
// @param period  The center period of the filter.
// @param bw      The bandwidth for the passband.
// @returns       The band-pass filtered value.
bpf(float src, int period, float bw) =>
    float w0  = 2.0 * math.pi / period
    float l1  = math.cos(w0)
    float g1  = math.cos(w0 * bw)
    float s1  = 1.0 / g1 - math.sqrt(1.0 / (g1 * g1) - 1.0)
    float res = 0.0
    if bar_index >= 3
        res := (
            0.5 * (1.0 - s1) * (src - src[2])
            + l1 * (1.0 + s1) * nz(res[1])
            - s1 * nz(res[2])
        )
    res

// @function      Calculates the AutoTune filter, which 
//                is a band-pass filter whose center 
//                period is dynamically adjusted based 
//                on autocorrelation in a high-pass 
//                filtered series.
// @param src     The series of values to process.
// @param window  The period of the high-pass filter, and the
//                window over which to analyze autocorrelation 
//                in the high-pass series.
//                The center period of the band-pass filter is
//                The period with the lowest autocorrelation, 
//                or the previous period + or - 2 if the distance 
//                to the current period is greater than 2.
// @param bw      The bandwidth for the passband.
// @returns       A tuple containing the following values:
//                 - The high-pass filtered value.
//                 - The lowest calculated autocorrelation.
//                 - The band-pass filter's center period.
//                 - The tuned band-pass filter's value.
autoTuneFilter(
    float src, simple int window, float bw
) =>
    var array<float> data = array.new<float>(window)
    var array<float> acf  = array.new<float>(window)
    matrix<float>    mat  = matrix.new<float>()
    float hp  = hpf(src, window)
    float sx  = math.sum(hp, window)
    float sxx = math.sum(hp * hp, window)
    data.unshift(hp), data.pop()
    mat.add_row(0, data)
    for i = 0 to window - 1
        int lag = i + 1
        array<float> lData = data[lag]
        float sy  = sx[lag]
        float syy = sxx[lag]
        float sxy = if not na(lData)
            mat.mult(lData).first()
        float cov  = window * sxy - sx * sy
        float vx   = window * sxx - sx * sx
        float vy   = window * syy - sy * sy
        float corr = cov / math.sqrt(vx * vy)
        acf.set(i, nz(corr, 1))
    float minCorr = acf.min()
    int dc = (acf.indexof(minCorr) + 1) * 2
    dc := nz(math.min(math.max(dc, dc[1] - 2), dc[1] + 2), dc)
    float bp = bpf(src, dc, bw)
    [hp, minCorr, dc, bp]
//#endregion


//#region --- Calculations and display ---

// Calculate the high-pass filter, minimum autocorrelation,
// dominant cycle, and tuned band-pass filter for the input 
// values. 
[f, m, d, b] = autoTuneFilter(source, window, 0.25)

// @variable The series to display.
float displaySeries = switch
    dispType == disp.F => f
    dispType == disp.M => m
    dispType == disp.D => d
    dispType == disp.B => b

// Plot the selected series and display a zero line.
hline(0, title = "Zero line")
plot(displaySeries, title = "Series")
//#endregion
````
