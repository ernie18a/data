<!-- tradingview-pine-id: PUB;3412a679d830478396eb32d4f9c3a31a -->
<!-- tradingviewscripts-format: 1 -->
# Elastic Volume-Weighted Student-T Tension

Source: https://www.tradingview.com/script/Sgfm0BJ3-Elastic-Volume-Weighted-Student-T-Tension/

## Description

Overview
The Elastic Volume-Weighted Student-T Tension Bands indicator dynamically adapts to market conditions using an advanced statistical model based on the Student-T distribution. Unlike traditional Bollinger Bands or Keltner Channels, this indicator leverages elastic volume-weighted averaging to compute real-time dispersion and location parameters, making it highly responsive to volatility changes while maintaining robustness against price fluctuations.

This methodology is inspired by incremental calculation techniques for weighted mean and variance, as outlined in the paper by Tony Finch:
📄 ["Incremental Calculation of Weighted Mean and Variance"](https://www.tfinch.org/tech/meanvar/meanvar.pdf).

Key Features
✅ Adaptive Volatility Estimation – Uses an exponentially weighted Student-T model to dynamically adjust band width.
✅ Volume-Weighted Mean & Dispersion – Incorporates real-time volume weighting, ensuring a more accurate representation of market sentiment.
✅ High-Timeframe Volume Normalization – Provides an option to smooth volume impact by referencing a higher timeframe’s cumulative volume, reducing noise from high-variability bars.
✅ Customizable Tension Parameters – Configurable standard deviation multipliers (σ) allow for fine-tuned volatility sensitivity.
✅ %B-Like Oscillator for Relative Price Positioning – The main indicator is in form of a dedicated oscillator pane that normalizes price position within the sigma ranges, helping identify overbought/oversold conditions and potential momentum shifts.
✅ Robust Statistical Foundation – Utilizes kurtosis-based degree-of-freedom estimation, enhancing responsiveness across different market conditions.

How It Works

[*]Volume-Weighted Elastic Mean (eμ) – Computes a dynamic mean price using an elastic weighted moving average approach, influenced by trade volume, if not volume detected in series, study takes true range as replacement.
[*]
[*]Dispersion (eσ) via Student-T Distribution – Instead of assuming a fixed normal distribution, the bands adapt to heavy-tailed distributions using kurtosis-driven degrees of freedom.
[*]
[*]Incremental Calculation of Variance – The indicator applies Tony Finch’s incremental method for computing weighted variance instead of arithmetic sum's of fixed bar window or arrays, improving efficiency and numerical stability.
[*]
[*]Tension Calculation – There are 2 dispersion custom "zones" that are computed based on the weighted mean and dynamically adjusted standard student-t deviation.
[*]
[*]%B-Like Oscillator Calculation – The oscillator normalizes the price within the band structure, with values between 0 and 1:
   * 0.00 → Price is at the lower band (-2σ).
   * 0.50 → Price is at the volume-weighted mean (eμ).
   * 1.00 → Price is at the upper band (+2σ).
   * Readings above 1.00 or below 0.00 suggest extreme movements or possible breakouts.

Recommended Usage

[*]For scalping in lower timeframes, it is recommended to use the fixed α Decay Factor, it is in raw format for better control, but you can easily make a like of transformation to N-bar size window like in EMA-1 bar dividing 2 / decayFactor or like an RMA dividing 1 / decayFactor.
[*]The HTF selector catch quite well Higher Time Frame analysis, for example using a Daily chart and using as HTF the 200-day timeframe, weekly or monthly.
[*]Suitable for trend confirmation, breakout detection, and mean reversion plays.
[*]The %B-like oscillator helps gauge momentum strength and detect divergences in price action if user prefer a clean chart without bands, this thanks to pineScript v6 force overlay feature.
[*]Ideal for markets with volume-driven momentum shifts (e.g., futures, forex, crypto).

Customization Parameters

[*]Fixed α Decay Factor – Controls the rate of volume weighting influence for an approximation EWMA approach instead of using sum of series or arrays, making the code lightweight & computing fast O(1).
[*]HTF Volume Smoothing – Instead of a fixed denominator for computing α , a volume sum of the last 2 higher timeframe closed candles are used as denominator for our α weight factor.  This is useful to review mayor trends like in daily, weekly, monthly.
[*]Tension Multipliers (±σ) – Adjusts sensitivity to dispersion sigma parameter (volatility).
[*]Oscillator Zone Fills – Visual cues for price positioning within the cloud range.

Posible Interpretations
   As market within indicators relay on each individual edge, this are just some key ideas to glimpse how the indicator could be interpreted by the user:
📌 Price inside bands – Market is considered somehow "stable"; price is like resting from tension or "charging batteries" for volume spike moves.
📌 Price breaking outer bands – Potential breakout or extreme movement; watch for reversals or continuation from strong moves.  Market is already in tension or generating it.
📌 Narrowing Bands – Decreasing volatility; expect contraction before expansion.
📌 Widening Bands – Increased volatility; prepare for high probability pull-back moves, specially to the center location of the bands (the mean) or the other side of them.
📌 Oscillator is just the interpretation of the price normalized across the Student-T distribution fitting "curve" using the location parameter, our Elastic Volume weighted mean (eμ) fixed at 0.5 value.

Final Thoughts
The Elastic Volume-Weighted Student-T Tension indicator provides a powerful, volume-sensitive alternative to traditional volatility bands. By integrating real-time volume analysis with an adaptive statistical model, incremental variance computation, in a relative price oscillator that can be overlayed in the chart as bands, it offers traders an edge in identifying momentum shifts, trend strength, and breakout potential.   Think of the distribution as a relative "tension" rubber band in which price never leave so far alone.

DISCLAIMER:

The Following indicator/code IS NOT intended to be a formal investment advice or recommendation by the author, nor should be construed as such. Users will be fully responsible by their use regarding their own trading vehicles/assets.

The following indicator was made for NON LUCRATIVE ACTIVITIES and must remain as is, following TradingView's regulations. Use of indicator and their code are published for work and knowledge sharing. All access granted over it, their use, copy or re-use should mention authorship(s) and origin(s).

WARNING NOTICE!

THE INCLUDED FUNCTION MUST BE CONSIDERED FOR TESTING. The models included in the indicator have been taken from open sources on the web and some of them has been modified by the author, problems could occur at diverse data sceneries, compiler version, or any other externality.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Xel_Arjona 2025

//@version=6
indicator("Elastic Volume-Weighted Student-T Tension", overlay=false)

// *** THE ELASTIC VOLUME WEIGHTED STUDENT-T TENSION ***
// Ver. 1.0.30:05:2025
// © Xel_Arjona 2025

// Parameters
lookbackPeriod  = input.int(20, "Fixed lookback N period for current chart timeframe", minval=2, maxval=5000, tooltip="Fuction aplicable only when HTF setting not selected.")
rangeToogle     = input.bool(false, "Use ATR instead of volume as weight factor", tooltip="For instruments without volume or CFDs that are not as reliable to a centralized exchange volume, turning this on is recomended.")
htfAlpha        = input.bool(false, "Use HTF closed candle for volume α", tooltip="It could skew if not using time based bars like range, renko, etc.")
HTFalpha        = input.timeframe( "30", title="HTF volume resolution", tooltip="As historic HTF candle forms, when new LTF candles with higher volume arrives it tends to compress weight ratio and trend skews strong, in order to mitigate this unwanted behaviour a sum of last 2 HTF candles is used, so for example if you want to compund 1 hour, it is recomended to use it's half (30 minute).  NOTE: Always plot in lower TF than this!")
// BAND factors
up_robust       = input.float( 0.5, "Upper σ factor", group = "BAND σ FACTORS: [ Robust ]:[ Standard ] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", inline = "upperSigmas")
up_standard     = input.float( 1.0, ":", group = "BAND σ FACTORS: [ Robust ]:[ Standard ] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", inline = "upperSigmas")
dn_robust       = input.float( 0.5, "Lower σ factor", group = "BAND σ FACTORS: [ Robust ]:[ Standard ] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", inline = "lowerSigmas")
dn_standard     = input.float( 1.0, ":", group = "BAND σ FACTORS: [ Robust ]:[ Standard ] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", inline = "lowerSigmas")
// OSCILLATOR Zones
osc_x1          = input.float( 2.0, "Upper Zones", group = "Z-SOCRE OSC ZONES [ Outter ]:[ Inner ] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", inline = "upper")
osc_x2          = input.float( 1.0, "   :   ", group = "Z-SOCRE OSC ZONES [ Outter ]:[ Inner ] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", inline = "upper")
osc_x4          = input.float( -2.0, "Lower Zones", group = "Z-SOCRE OSC ZONES [ Outter ]:[ Inner ] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", inline = "bottom")
osc_x3          = input.float( -1.0, "   :   ", group = "Z-SOCRE OSC ZONES [ Outter ]:[ Inner ] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", inline = "bottom")



// @function An elastic on-line estimator with Location & Dispersion parameters for the Student-T distribution function.
// @param input                 float Series to be procesed by the distribution parameters.
// @param feedbackFactor        float Alpha(α) coefficient factor, fixed or dynamic(series) that meets the following criteria: 0 < | ∞ < α < 1.0 |
// @param degreesOfFreedom      float Fixed or dynamic(series). If default used(na) the function will use a dynamic calculation based on kurtosis.
// @returns [ ewMean, combinedSigma, standardSigma, robustSigma  ] A tuple containing the elastic estimation Mean (eμ) & dispertion standard, robust and average Sigmas (eσ) realtime calculated by the feedbackFactor (α).
ewStudentTParameters(float input, float feedbackFactor = 0.1, float degreesOfFreedom = na ) =>
    alpha = feedbackFactor
    
    // Initialize persistent variables for EWMA calculations
    var float ewMean = na
    var float ewVariance = na
    var float ewSquaredDev = na
    var float ewFourthPowerDev = na
    var float ewAbsDev = na
    
    // Initial setup on first bar
    if na(ewMean)
        ewMean := input
        ewVariance := 0.0001        // Small non-zero initial value
        ewSquaredDev := 0.0001
        ewFourthPowerDev := 0.0001
        ewAbsDev := 0.0001
    
    // Update the elastic weighted mean (location parameter)
    ewMean := alpha * input + (1 - alpha) * ewMean
    
    // Calculate deviation from mean
    deviation = input - ewMean
    
    // Update elastic weighted of squared deviation (variance)
    ewSquaredDev := alpha * math.pow(deviation, 2) + (1 - alpha) * ewSquaredDev
    
    // Update elastic weighted of absolute deviation (MAD)
    ewAbsDev := alpha * math.abs(deviation) + (1 - alpha) * ewAbsDev
    
    // Update elastic weighted of fourth power deviation (kurtosis)
    ewFourthPowerDev := alpha * math.pow(deviation, 4) + (1 - alpha) * ewFourthPowerDev
    
    // Variance output
    variance = ewSquaredDev
    
    // DEGREES OF FREEDOM ESTIMATION
    // Kurtosis output: E[(X-μ)^4] / (E[(X-μ)^2])^2
    kurtosis = variance > 0 ? ewFourthPowerDev / math.pow(variance, 2) : 3.0
    
    // Estimate our dynamic Degrees of Freedom with "Method Of Moments" using kurtosis
    // For t-distribution, kurtosis = 3 + 6/(df-4) for df > 4
    dynamicDegOfFreedom = 0.0
    if kurtosis > 3.0
        dynamicDegOfFreedom := 6.0 / (kurtosis - 3.0) + 4.0
    else
        dynamicDegOfFreedom := 30.0  // Default to approximately normal
    
    // If no Degrees Of Freedom passed by the function input, use our dynamic calculation:
    degOfFreedom = na(degreesOfFreedom) ? dynamicDegOfFreedom : degreesOfFreedom

    // Bound our degrees of freedom
    degOfFreedom := math.max(5.0, math.min(30.0, degOfFreedom))
    
    // Calculate scale factor for t-distribution
    scaleFactor = math.sqrt(degOfFreedom / (degOfFreedom - 2.0))
    
    // Calculate robust scale estimate using elastic weighted of absolute deviations
    // EWMA-MAD/0.6745 is our consistent estimator for std dev under normality
    robustScale = ewAbsDev / 0.6745
    
    // Calculate our sigma output (standard deviation)
    stdDev = math.sqrt(variance)
    
    // Combine robust and standard measures for final scale
    combinedScale = math.avg(robustScale, stdDev)
    
    // Return our scales parameters:
    combinedSigma = math.max(combinedScale * scaleFactor, 0.000001)
    standardSigma = math.max(stdDev * scaleFactor, 0.000001)
    robustSigma   = math.max(robustScale * scaleFactor, 0.000001)

    // OUTPUTS TUPLE
    [ ewMean, combinedSigma, standardSigma, robustSigma ]


// Persistent Variables
float upRobustSigma   = 0.00    // Weighted scale parameter Robust +σ
float upStandardSigma = 0.00    // Weighted scale parameter Standard +σ
float wMean           = open    // Weighted location parameter μ 
float dnRobustSigma   = 0.00    // Weighted scale Robust parameter -σ
float dnStandardSigma = 0.00    // Weighted scale Standard parameter -σ
float alphaWeight     = 1.5     // Weighted stability index (alpha)
float weightSum       = 0.0     // Running sum of weights
bool initialized      = false

// Definition Variables
float weightInput   =   rangeToogle ? ta.tr : nz( volume, 1 )   // Define the input weighting
float UB_x1 = na    // Upper Band Tension 1
float UB_x2 = na    // Upper Band Tension 2
float BB_x1 = na    // Bottom Band Tension 1
float BB_x2 = na    // Bottom Band Tension 2
float oscClose = na
float oscHigh  = na
float oscLow   = na
// Request for Higher Time Frame total Volume (or range if not available)
float htfWeight  = request.security(syminfo.tickerid, HTFalpha, ta.ema( weightInput, 2), lookahead=barmerge.lookahead_on)
// Build the weight coefficient
float htfCoefficient = weightInput / htfWeight

// Initialize on first bar
if not initialized and bar_index > 0
    upRobustSigma   := 0.00001
    upStandardSigma := 0.00001
    wMean := open
    dnRobustSigma   := 0.00001
    dnStandardSigma := 0.00001
    alphaWeight := 1.5
    weightSum := 0.0
    initialized := true

// Main calculation logic
if initialized
    lastPrice   = hlcc4
    Highs       = high
    Lows        = low
    weightSum  := weightInput 

    // Update Running Volume Sum with Decay
    // This is a fastest but aproximate recursion instead of using: weightSeries/math.sum(weightSeries, N)
    weightSum := rangeToogle ? math.max(ta.highest(lookbackPeriod) - ta.lowest(lookbackPeriod), math.abs(ta.highest(lookbackPeriod) - close[lookbackPeriod+1]), math.abs(ta.lowest(lookbackPeriod) - close[lookbackPeriod+1])): math.sum( weightInput, lookbackPeriod )
    
    // Calculate volume weight as normalized volume
    alphaWeight := htfAlpha ? math.min( htfCoefficient, 0.97) : math.min( weightInput/weightSum, 0.97 )  // Cap alpha to not overshoot.
    
    // Update Student-T dispersion parameter
    [ highs_mean, highs_combinedSigma, highs_standardSigma, highs_robustSigma ] = ewStudentTParameters( Highs, alphaWeight )
    [ hlcc4_mean, hlcc4_combinedSigma, hlcc4_standardSigma, hlcc4_robustSigma ] = ewStudentTParameters( lastPrice, alphaWeight )
    [ lows_mean, lows_combinedSigma, lows_standardSigma, lows_robustSigma ]     = ewStudentTParameters( Lows, alphaWeight )

    // Apply updates
    upRobustSigma   := highs_robustSigma
    upStandardSigma := highs_standardSigma
    wMean           := hlcc4_mean
    dnRobustSigma   := lows_robustSigma
    dnStandardSigma := lows_standardSigma
    
    // Calculate bands using stable distribution quantile approximation
    UB_x2 := wMean + ( up_standard * upStandardSigma )
    UB_x1 := wMean + ( up_robust * upRobustSigma )
    BB_x1 := wMean - ( dn_robust * dnRobustSigma )
    BB_x2 := wMean - ( dn_standard * dnStandardSigma )

    // Calculate oscillator pane and rescale it to fit location parameter as 0.0 [1, -1]
    oscClose := 2 * ( ( (close - BB_x2) / (UB_x2 - BB_x2) ) - 0.5 )
    oscHigh  := 2 * ( ( (high  - BB_x2) / (UB_x2 - BB_x2) ) - 0.5 )
    oscLow   := 2 * ( ( (low   - BB_x2) / (UB_x2 - BB_x2) ) - 0.5 )
    
// Plotting
// Bands:
ux2 = plot(UB_x2, "+σ x2", color=#6600ff, force_overlay = true)
ux1 = plot(UB_x1, "+σ x1", color=#6600ff, force_overlay = true)
plot(wMean, "eVolume μ", color=#6600ff1a, linewidth=2, force_overlay = true)
dx1 = plot(BB_x1, "-σ x1", color=#6600ff, force_overlay = true)
dx2 = plot(BB_x2, "-σ x2", color=#6600ff, force_overlay = true)
// Oscillator %
oscH = plot(oscHigh,  title="oscHigh", color=#6600ff18, histbase=0.0,  style=plot.style_columns)
oscC = plot(oscClose, title="oscClose", color=color.rgb(48, 0, 120), histbase=0.0, style=plot.style_line, linewidth = 2)
oscL = plot(oscLow,   title="oscLow", color=#6600ff18, histbase=0.0,   style=plot.style_columns)
top  = hline(osc_x1,  title="osc x2 +σ", color=color.rgb(255, 153, 0, 95), linestyle=hline.style_dotted)
loc  = hline(0.0,  title="osc eμ", color=color.red, linestyle=hline.style_dashed )
pqu  = hline(osc_x2,  title="osc x1 +σ", color=color.rgb(255, 153, 0, 95), linestyle=hline.style_dotted )
pqd  = hline(osc_x3, title="osc x1 -σ", color=color.rgb(255, 153, 0, 95), linestyle=hline.style_dotted )
bot  = hline(osc_x4, title="osc x2 -σ", color=color.rgb(255, 153, 0, 95), linestyle=hline.style_dotted )

// BAND Fills
fill(ux1, ux2, color=#6600ff0a, editable=true, title="Upper BAND Shadow")
fill(dx1, dx2, color=#6600ff0a, editable=true, title="Bottom BAND Shadow")
// OSCILLATOR Fills
fill(pqu, top, color=#6600ff15, editable=true, title="Upper OSC Shadow")
fill(bot, pqd, color=#6600ff15, editable=true, title="Bottom OSC Shadow")
````
