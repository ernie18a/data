<!-- tradingview-pine-id: PUB;ca1ad56347524b069579822759e4bc85 -->
<!-- tradingviewscripts-format: 1 -->
# TASC 2025.06 Cybernetic Oscillator

Source: https://www.tradingview.com/script/QwMaFZTL-TASC-2025-06-Cybernetic-Oscillator/

## Description

█ OVERVIEW

This script implements the Cybernetic Oscillator introduced by John F. Ehlers in his article "The Cybernetic Oscillator For More Flexibility, Making A Better Oscillator" from the [June 2025 edition of the TASC Traders' Tips](https://traders.com/Documentation/FEEDbk_docs/2025/06/TradersTips.html). It cascades two-pole highpass and lowpass filters, then scales the result by its root mean square (RMS) to create a flexible normalized oscillator that responds to a customizable frequency range for different trading styles. 

█ CONCEPTS

Oscillators are indicators widely used by technical traders. These indicators swing above and below a center value, emphasizing cyclic movements within a frequency range. In his article, Ehlers explains that all oscillators share a common characteristic: their calculations involve computing differences. The reliance on differences is what causes these indicators to oscillate about a central point.

The difference between two data points in a series acts as a highpass filter — it allows high frequencies (short wavelengths) to pass through while significantly attenuating low frequencies (long wavelengths). Ehlers demonstrates that a simple difference calculation attenuates lower-frequency cycles at a rate of 6 dB per octave. However, the difference also significantly amplifies cycles near the shortest observable wavelength, making the result appear noisier than the original series. To mitigate the effects of noise in a differenced series, oscillators typically smooth the series with a lowpass filter, such as a moving average. 

Ehlers highlights an underlying issue with smoothing differenced data to create oscillators. He postulates that market data statistically follows a pink spectrum, where the amplitudes of cyclic components in the data are approximately directly proportional to the underlying periods. Specifically, he suggests that cyclic amplitude increases by 6 dB per octave of wavelength.

Because some conventional oscillators, such as RSI, use differencing calculations that attenuate cycles by only 6 dB per octave, and market cycles increase in amplitude by 6 dB per octave, such calculations do not have a tangible net effect on larger wavelengths in the analyzed data. The influence of larger wavelengths can be especially problematic when using these oscillators for mean reversion or swing signals. For instance, an expected reversion to the mean might be erroneous because oscillator's mean might significantly deviate from its center over time.

To address the issues with conventional oscillator responses, Ehlers created a new indicator dubbed the Cybernetic Oscillator. It uses a simple combination of highpass and lowpass filters to emphasize a specific range of frequencies in the market data, then normalizes the result based on RMS. The process is as follows:

[*]Apply a two-pole highpass filter to the data. This filter's critical period defines the longest wavelength in the oscillator's passband. 
[*]Apply a two-pole SuperSmoother (lowpass filter) to the highpass-filtered data. This filter's critical period defines the shortest wavelength in the passband.
[*]Scale the resulting waveform by its RMS. If the filtered waveform follows a normal distribution, the scaled result represents amplitude in standard deviations. 

The oscillator's two-pole filters attenuate cycles outside the desired frequency range by 12 dB per octave. This rate outweighs the apparent rate of amplitude increase for successively longer market cycles (6 dB per octave). Therefore, the Cybernetic Oscillator provides a more robust isolation of cyclic content than conventional oscillators. Best of all, traders can set the periods of the highpass and lowpass filters separately, enabling fine-tuning of the frequency range for different trading styles. 

█ USAGE

The "Highpass period" input in the "Settings/Inputs" tab specifies the longest wavelength in the oscillator's passband, and the "Lowpass period" input defines the shortest wavelength. The oscillator becomes more responsive to rapid movements with a smaller lowpass period. Conversely, it becomes more sensitive to trends with a larger highpass period. Ehlers recommends setting the smallest period to a value above 8 to avoid aliasing. The highpass period must not be smaller than the lowpass period. Otherwise, it causes a runtime error. 

The "RMS length" input determines the number of bars in the RMS calculation that the indicator uses to normalize the filtered result.

This indicator also features two distinct display styles, which users can toggle with the "Display style" input. With the "Trend" style enabled, the indicator plots the oscillator with one of two colors based on whether its value is above or below zero. With the "Threshold" style enabled, it plots the oscillator as a gray line and highlights overbought and oversold areas based on the user-specified threshold. 

Below, we show two instances of the script with different settings on an equities chart. The first uses the "Threshold" style with default settings to pass cycles between 20 and 30 bars for mean reversion signals. The second uses a larger highpass period of 250 bars and the "Trend" style to visualize trends based on cycles spanning less than one year:

[image]https://www.tradingview.com/x/Byy4gzD7/[/image]

---

## Source Code

````pine
//  TASC Issue: June 2025
//     Article: The Cybernetic Oscillator For More Flexibility
//              Making A Better Oscillator
//  Article By: John F. Ehlers
//    Language: TradingView's Pine Script® v6
// Provided By: PineCoders, for tradingview.com

//@version=6
TITLE   = "TASC 2025.06 Cybernetic Oscillator"
S_TITLE = "CO"
indicator(TITLE, S_TITLE)


//#region --- Enum and inputs ---

// @enum An enumeration of possible display styles.
enum style 
    Trend
    Threshold

// @variable The source series to process. 
float srcInput = input.source(close, "Source series:")
// @variable The highpass filter critical period. 
int hpInput = input.int(30, "Highpass period:", 3)
// @variable The lowpass filter critical period. 
int lpInput = input.int(20, "Lowpass period:", 3)
// @variable The number of bars in the RMS calculation.
int rmsInput = input.int(100, "RMS length:", 1)

// @variable A named value for the display style. 
style styleInput = input.enum(style.Trend, "Display style:")
// @variable The absolute threshold for the "Threshold" display style.
float thInput = input.float(1, "Threshold:", minval = 0, step = 0.1)

// Raise a runtime error if `hpInput` is less than `lpInput`.
if hpInput < lpInput
    runtime.error("The highpass period cannot be less than the lowpass period.")
//#endregion


//#region --- Functions ---

// @function         Calculates coefficients for the `hp()` and `ss()` functions.
// @param period     The critical period of the filter.
// @param isHp       If `true`, the coefficients are for a highpass filter. Otherwise, 
//                   they are for a lowpass filter. 
// @returns          A tuple containing the highpass or lowpass filter coefficients. 
coefs(simple int period, simple bool isHp) =>
    var float a0 = 1.414 * math.pi / period
    var float a1 = math.exp(-a0)
    var float c2 = 2.0 * a1 * math.cos(a0)
    var float c3 = -a1 * a1
    var float c1 = isHp ? (1.0 + c2 - c3) * 0.25 : 1.0 - c2 - c3
    [c1, c2, c3]


// @function         Calculates a second-order highpass filter.
// @param source     The series of values to process. 
// @param period     The length of the filter's critical period.
// @returns          The filtered `source` value. 
hp(float source, simple int period) =>
    var float result = 0.0
    if bar_index >= 4
        [c1, c2, c3] = coefs(period, true)
        result := c1 * (source - 2.0 * source[1] + source[2]) + 
                  c2 * nz(result[1]) + 
                  c3 * nz(result[2])
    result


// @function         Calculates a Super Smoother filter (second-order lowpass).
// @param source     The series of values to process.
// @param period     The length of the filter's critical period.
// @returns          The filtered `source` value. 
ss(float source, simple int period) =>
    var float result = source
    if bar_index >= 4
        [c1, c2, c3] = coefs(period, false)
        result := c1 * 0.5 * (source + source[1]) + 
                  c2 * nz(result[1]) +
                  c3 * nz(result[2])
    result


// @function         Calculates the root mean square (RMS) of a series.
// @param source     The series of values to process.
// @param length     The number of bars in the calculation.
// @returns          The RMS of the `source` values over `length` bars.
rms(float source, simple int length) =>
    math.sqrt(ta.sma(source * source, length))


// @function         Calculates the Cybernetic Oscillator.
// @param source     The series of values to process. 
// @param hpPeriod   The highpass filter critical period.
// @param lpPeriod   The lowpass filter critical period.
// @param rmsInput   The number of bars in the RMS calculation. 
// @returns          The Cybernetic Oscillator of `source` with specified settings.
co(float source, simple int hpPeriod, simple int lpPeriod, simple int rmsInput) =>
    var float result = 0.0
    float hp  = hp(source, hpPeriod)
    float lp  = ss(hp, lpPeriod)
    float rms = rms(lp, rmsInput)
    if rms != 0.0
        result := lp / rms
    result
//#endregion


//#region --- Calculations and display ---

// @variable Is `true` if the selected style is `style.Threshold`; `false` otherwise. 
bool isThresh = styleInput == style.Threshold 

// @variable The Cybernetic Oscillator of the `srcInput` series with specified settings. 
float osc = co(srcInput, hpInput, lpInput, rmsInput)

// Plot the `osc` value with a color based on the chosen display style. 
p0 = plot(
     osc, "Cybernetic Oscillator", 
     isThresh ? #aa9b9b : osc > 0.0 ? #4caf4f : #af4e4c, 2
 )
// Plot the upper and lower thresholds. 
pu = plot(isThresh ?  thInput : na, "Upper threshold", #b2b5be80)
pl = plot(isThresh ? -thInput : na, "Lower threshold", #b2b5be80)
// Fill the space between the plots based on the `osc` and `thInput` values. 
fill(p0, pu, isThresh and osc >   thInput ? #af4e4c93 : na, title = "Upper fill")
fill(p0, pl, isThresh and osc < - thInput ? #4caf4f93 : na, title = "Lower fill")

// Create a horizontal line at 0.
hline(0)
//#endregion
````
