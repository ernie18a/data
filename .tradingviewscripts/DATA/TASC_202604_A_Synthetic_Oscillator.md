<!-- tradingview-pine-id: PUB;41c8a70412b549f0ad75bf269a1e978c -->
<!-- tradingviewscripts-format: 1 -->
# TASC 2026.04 A Synthetic Oscillator

Source: https://www.tradingview.com/script/we9AMcvE-TASC-2026-04-A-Synthetic-Oscillator/

## Description

█ Overview

This script implements a Synthetic Oscillator as presented by John F. Ehlers in the [April 2026 TASC Traders' Tips](https://traders.com/Documentation/FEEDbk_docs/2026/04/TradersTips.html) article "Avoiding Whipsaw Trades". The indicator aims to provide a smooth, low-lag oscillator for timely trading signals by dynamically mapping a sine wave to price data.

█ CONCEPTS

"Whipsaw" trades are a common issue in algorithmic trading. They occur when the market quickly moves against a position, causing the trader/trading system to reverse their position at a loss, and then the market reverses again and continues in the original direction. Such trades occur because the trading system is attempting to react quickly to market moves instead of focusing on broader market cycles.

A typical solution for reducing whipsaw trades is to apply linear filters to smooth the data and emphasize specific cycles. However, linear filters cannot have both a smooth response and a low computational lag. Therefore, strategy designs utilizing linear filters require a tradeoff between smoothness and lag. 

Ehlers proposes a nonlinear indicator as a solution to bridge the gap and achieve a smooth, timely response while reducing whipsaw trades. 

The Synthetic oscillator adapts to market conditions by calculating a dynamic sine wave from the estimated instantaneous dominant cycle over a range of periods. 

The process to calculate the indicator is as follows:

[*]Smooth the price data with a 12-bar Hann Window filter to reduce high-frequency noise, which can affect dominant cycle estimates.

[*]Band-pass filter the windowed data with a two-pole high-pass filter and a SuperSmoother filter to focus on the range of cycles between a specified lower bound and upper bound, and normalize the result using the filter's 100-bar root mean square (RMS).

[*]Calculate the one-bar rate of change (ROC) in the oscillator from step 2, and normalize the ROC using its 100-bar RMS.

[*]Estimate the instantaneous dominant cycle from the oscillators in steps 2 and 3 by treating the series as a complex waveform, where the first oscillator represents the waveform's band-limited "real" component ("I"), and the second represents the band-limited "imaginary" component ("Q").

[*]Cumulatively sum the reciprocal of the dominant cycle (i.e., the dominant frequency) to obtain the phase angle of the sine wave.

[*]To reduce cumulative errors and lag in the phase angle calculation, compute a secondary band-bass filter from a high-pass filter and the UltimateSmoother, and reset the angle to 0 or 180 degrees when that filter crosses above or below 0. 

[*]Calculate the Synthetic Oscillator as the sine of the final phase angle. 

█ USAGE

[image]https://www.tradingview.com/x/3aYBBhvl/[/image]

This indicator displays the Synthetic Oscillator and a horizontal zero line in a separate pane. Users can analyze the crossings between the oscillator value and 0, or the behavior of the oscillator as it reaches 1 or -1, to derive potential timely trading signals. 

Ehlers notes in the article that the peaks and valleys of the Synthetic Oscillator can provide signals a little too early, depending on the settings and context. Therefore, he recommends applying another smoother to the oscillator, such as a Hann Window filter with an optimizable length, to adjust timing as necessary. 

█ INPUTS

This indicator uses multiple hardcoded parameters based on the implementation in Ehlers' article. However, users can customize the source series and the upper and lower bounds of the calculations:

[*]Source Series: The series of values to process.
[*]Lower Bound: The smallest cycle in the passband of the filters, and the lower limit of the dominant cycle estimate. 
[*]Upper Bound: The largest cycle in the passband of the filters, and the upper limit of the dominant cycle estimate.

---

## Source Code

````pine
//  TASC Issue: April 2026
//     Article: Avoiding Whipsaw Trades
//              A Synthetic Oscillator
//  Article By: John F. Ehlers
//    Language: TradingView's Pine Script® v6
// Provided By: PineCoders, for tradingview.com


//@version=6
TITLE = "TASC 2026.04 A Synthetic Oscillator"
indicator(TITLE, "SO", false)

//#region Inputs

float src = input.source(close, "Source Series:")
int lb = input.int(15, "Lower Bound:", minval = 3)
int ub = input.int(25, "Upper Bound:", minval = 4)

if lb >= ub
    runtime.error("The 'Upper Bound' value must be greater than the 'Lower Bound' value.")

//#endregion

//#region Functions

// @function The SuperSmoother is a second-order infinite im-
// pulse response (IIR) filter, meaning that it uses two
// previous calculations of the filter output in the cur-
// rent calculation of the filter response.
// @param   src     Source series
// @param   period  Critical period
// @returns Smoothed series
SuperSmoother (float src, int period) =>
    float q = math.exp(-1.414*math.pi/period)
    float c1 = 2.0*q*math.cos(1.414*math.pi/period)
    float c2 = q*q
    float a0 = (1.0 - c1 + c2)/2
    float ss = src
    if bar_index >= 4
        ss := a0*(src + src[1]) + 
              c1*ss[1] - c2*ss[2]
    ss

// @function      The UltimateSmoother is a filter created
//                by subtracting the response of a high-pass 
//                filter from that of an all-pass filter.
// @param src     Source series.
// @param period  Critical period.
// @returns       Smoothed series
UltimateSmoother (float src, int period) =>
    float q = math.exp(-1.414*math.pi/period)
    float c1 = 2.0*q*math.cos(1.414*math.pi/period)
    float c2 = q*q
    float a0 = (1.0 + c1 + c2)/4.0
    float us = src
    if bar_index >= 4
        us := (1.0 - a0)*src + 
              (2.0*a0 - c1)*src[1] + 
              (c2 - a0)*src[2] + 
              c1*nz(us[1]) - c2*nz(us[2])
    us

// @function Root Mean Square
RMS (float Source, int Length) =>
    float s2 = math.sum(Source*Source, Length)
    if s2 != 0
        math.sqrt(s2/Length)
    else
        0.0

// @function High Pass Filter
HP (float src, int Period) =>
    float Q = math.exp(-1.414*math.pi/Period)
    float c1 = 2.0*Q*math.cos(1.414*math.pi/Period)
    float c2 = Q*Q
    float a0 = (1 + c1 + c2)/4
    float hp = 0.0
    if bar_index >= 4
        hp := nz(a0*(src - 2*src[1] + 
              src[2]) + c1*hp[1] - c2*hp[2])
    hp

//@function Hann Filter
Hann (float src, int length) =>
    float filt = 0.0
    float coef = 0.0
    for c = 1 to length
        float p = math.cos(2*math.pi*c/(length + 1))
        filt += (1.0 - p) * nz(src[c - 1])
        coef += 1.0 - p
    coef != 0.0 ? filt/coef : 0.0

// @function Synthetic Oscillator.
// @param   src     Source Series.
// @param   LB      Lower Bound.
// @param   UB      Upper Bound.
// @param   length  Length period.
// @returns Synthetic Oscillator.
SO (float src=close, int LB=15, int UB=25) =>
    float price = Hann(src,12)
    // Real component is bandpass filtered and normalized
    float hp = HP(price, UB)
    float lp = SuperSmoother(hp, LB)
    float rms = RMS(lp, 100)
    float re = rms != 0.0 ? lp/rms : 0.0
    // Imaginary component is rate of change normalized.
    float roc = re - re[1]
    float qrms = RMS(roc, 100)
    float im = qrms != 0.0 ? roc/qrms : 0.0
    // Solve rate of change of arctangent.
    float denom = roc*im - (im - im[1])*re
    float dc = denom != 0.0 ? 
      6.28*(re*re + im*im)/denom : 0.0
    // Limit range of measured values.
    dc := math.max(LB, math.min(UB, dc))
    int mid = int(math.sqrt(LB*UB))
    // Create a Bandpass filter at the Average Dominant
    // Cycle Period.
    float hp2 = HP(src, mid)
    float bp = UltimateSmoother(hp2, mid)
    // Cumulate Phase and force reset at 0 and 180 degrees
    var float ph = 0.0
    ph += 2*math.pi/dc
    bool xo = ta.crossover(bp, 0.0)
    bool xu = ta.crossunder(bp, 0.0)
    switch
        xo => ph := math.pi/dc
        xu => ph := math.pi + math.pi/dc
    
    // Synthetic Oscillator is the Sine of the cumulative
    // phase angle.
    float so = math.sin(ph)
    // Remove reset glitch if continuity falls in the 
    // same quadrant.
    switch
        ph > 0.0 and ph < math.pi/2 and so < so[1] =>
            so := so[1]
        ph > math.pi and ph < 3*math.pi/2 and so > so[1] => 
            so := so[1]
        =>
            so

//#endregion

//#region Plots

so = SO(src, lb, ub)

plot(so, "Synthetic Oscillator")
hline(0, "Zero Line")

//#endregion
````
