<!-- tradingview-pine-id: PUB;9410078a82ee4673b180a5633bcb016b -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Variance-Weighted Regression Trend [BackQuant]

Source: https://www.tradingview.com/script/9KcWvaBf-Variance-Weighted-Regression-Trend-BackQuant/

## Description

Variance-Weighted Regression Trend [BackQuant]

Overview
Variance-Weighted Regression Trend is a rolling linear-regression trend indicator that adjusts the influence of observations according to the estimated variance of their regression residuals.

The script first calculates a standard ordinary least-squares regression across the selected window. It then measures the squared residuals around that fit and uses those residuals to estimate how variable the regression error has been through the sample.

Those variance estimates are converted into relative weights. Lower estimated residual variance can receive more influence, while higher estimated residual variance can receive less. A second weighted regression is then calculated using those weights.

The indicator also includes:

[*]EMA, RMA or rolling-average residual variance.
[*]Configurable inverse-variance weighting strength.
[*]Weight regularization and upper/lower weight limits.
[*]Weighted R² and slope-quality diagnostics.
[*]Two regression-channel methods.
[*]Optional trend-flip quality confirmation.
[*]OLS comparison.
[*]Linear regression projection.
[*]Trend colouring and alerts.

Calculation
The basic process is:

[*]Fit an ordinary least-squares regression over the Regression Length.
[*]Calculate the squared residual of every observation around that fit.
[*]Smooth those squared residuals to estimate local residual variance.
[*]Add a regularization floor to reduce unstable extreme weights.
[*]Convert variance into relative observation weights.
[*]Clamp weights between the selected minimum and maximum.
[*]Calculate a second weighted regression.

The weighted line is therefore influenced more by observations receiving larger relative weights and less by those receiving smaller ones.

Variance Weighting
The weighting is based on regression residual variance, not ATR, trading volume or raw price volatility.

For each point:

[*]Residual = Source - OLS fitted value
[*]Squared Residual = Residual²

The squared residuals are then processed using the selected Variance Model.

EMA
Uses exponential smoothing and responds more quickly to recent residual changes.

RMA
Uses a slower recursive smoothing process.

Rolling Mean
Uses a finite moving average of squared residuals.

Weight Power
Weight Power controls how strongly estimated variance affects the regression.

The raw weighting relationship is:

[*]Weight ∝ 1 / Variance^Weight Power

0 gives equal weighting, making the final fit behave like the OLS regression.

1 applies standard inverse-variance-style weighting.

Values above 1 increase the difference between low- and high-variance observations.

Higher settings can make the regression more selective, but can also concentrate too much influence in a small part of the sample.

Variance Regularization
Very small variance estimates can otherwise create extremely large inverse weights.

The script therefore adds a fraction of the window's mean squared residual to each local variance estimate.

Higher regularization makes the weights more uniform.

Lower regularization allows stronger differences between observations.

Minimum and Maximum Relative Weight
Raw weights are normalized relative to their average before being clamped.

A relative weight above 1 means the observation has greater-than-average influence.

A value below 1 means it has less.

The Minimum Relative Weight prevents high-variance observations from effectively disappearing from the regression.

The Maximum Relative Weight prevents very low-variance observations from dominating the entire fit.

Weighted Regression
Once the final weights are calculated, the script solves a weighted linear regression:

[*]Y = Intercept + Slope × X

The displayed line is the current endpoint of that rolling weighted regression.

Each new bar shifts the regression window and recalculates:

[*]OLS.
[*]Residuals.
[*]Variance estimates.
[*]Weights.
[*]Weighted slope and intercept.

OLS Comparison
The optional OLS line shows the endpoint of the initial equal-weight regression.

This makes it easy to see how much the variance weighting is actually changing the result.

If Weight Power is set to 0, the weighted regression and OLS should be effectively aligned.

As the weighting becomes more aggressive, the lines may separate depending on the residual structure inside the window.

Trend State
Trend direction comes from the sign of the weighted regression slope.

[*]Positive slope = bullish.
[*]Negative slope = bearish.

A bullish flip occurs when the stored trend changes from bearish to bullish.

A bearish flip occurs when it changes from bullish to bearish.

Quality Confirmation
Quality Confirmation can be enabled to prevent weak slope changes from immediately flipping the trend state.

When enabled, an opposite slope must also satisfy:

[*]Minimum Weighted R².
[*]Minimum Slope / Standard Error.

If those conditions are not met, the existing trend state remains active even if the current slope temporarily changes sign.

Weighted R²
Weighted R² measures how well the weighted straight-line regression describes the current sample.

Higher values indicate that the weighted observations are more closely aligned with a linear fit.

Lower values indicate a less orderly linear relationship.

R² does not determine trend direction and should not be interpreted as a forecast of future performance.

Slope / Standard Error
The script calculates the absolute weighted slope relative to its estimated standard error:

[*]|Slope| / Slope Standard Error

This is used as a practical slope-quality measure.

Higher values indicate that the fitted slope is larger relative to the estimated regression error.

It is used by the optional Quality Confirmation setting and is not presented as a formal significance test.

Regression Channels
Two channel-width methods are available.

Weighted Residual RMS
Uses the weighted root-mean-square distance of observations from the fitted regression.

This reflects the general amount of scatter around the line.

Regression Standard Error
Uses the calculated standard error of the fitted current regression value.

This normally represents a different and often narrower measure than residual RMS.

The Channel Multiplier scales whichever method is selected.

Expand During Poor Fit
When enabled, the channel becomes wider as Weighted R² decreases.

This is intended to visually reflect greater uncertainty when the current window is poorly described by a straight line.

The expansion affects only the channel width.

It does not alter the regression or trend calculation.

Projection
The Projection extends the current regression slope forward by the selected number of bars.

It is simply:

[*]Current fitted line extended using the current slope.

It is not a separate forecasting model.

As the regression changes on new bars, the projection also changes.

Current Relative Weight
The Data Window shows the final relative weight assigned to the newest observation.

A value:

[*]Above 1 = greater-than-average influence.
[*]Below 1 = less-than-average influence.

This can help show how the current observation is being treated by the variance-weighting model.

Effective Sample Size
The indicator also reports:

[*]Effective N = (Sum of Weights)² / Sum of Squared Weights

This provides a simple measure of weight concentration.

If weights are similar, Effective N remains close to the full Regression Length.

If a smaller group of observations receives most of the weight, Effective N falls.

This is useful when experimenting with aggressive Weight Power or wide weight limits.

Trend Strength
Trend Strength is used only for the regression glow.

It combines:

[*]60% Weighted R².
[*]40% normalized Slope / Standard Error.

It does not affect the regression or signals.

ATR(14) is used only to scale the visual width of the glow and flip bloom to the instrument.

Input Guide
Regression Length
Controls the size of the rolling regression sample.

Projection Bars
Controls how far the current fitted slope is extended visually.

Variance Length
Controls how quickly the residual-variance estimate changes.

Variance Model
Selects EMA, RMA or Rolling Mean smoothing of squared residuals.

Weight Power
Controls the strength of inverse-variance weighting.

Variance Regularization
Reduces extreme differences between weights.

Minimum / Maximum Relative Weight
Limits how little or how much influence any one observation can receive.

Channel Width
Selects Weighted Residual RMS or Regression Standard Error.

Channel Multiplier
Scales the regression channel.

Poor Fit Expansion
Optionally widens the channel as R² deteriorates.

Quality Confirmation
Requires minimum regression fit and slope quality before allowing trend flips.

How to use it
The indicator can be used as:

[*]A regression-based trend filter.
[*]A comparison between ordinary and variance-weighted regression.
[*]A way to study how residual-based weighting changes a rolling trend estimate.
[*]A trend-quality filter using R² and slope strength.
[*]A regression channel for visualizing fit dispersion.

The OLS Comparison and Data Window values are particularly useful when testing the weighting settings, because they show whether the extra weighting is materially changing the regression or simply producing a result close to ordinary least squares.

Limitations

[*]The variance estimates are derived from OLS residuals inside the same rolling window.
[*]The model is a custom two-stage weighted regression rather than a full generalized least-squares procedure.
[*]Higher Weight Power can concentrate the fit in a relatively small part of the sample.
[*]Linear regression cannot represent every type of market structure.
[*]High R² does not imply future trend continuation.
[*]The forward projection is only a linear extrapolation of the current fit.
[*]Quality Confirmation can reduce weak flips but can also delay genuine changes in direction.

Data Window
The script exposes:

[*]Weighted Slope.
[*]Weighted R².
[*]Slope / Standard Error.
[*]Weighted Residual RMS.
[*]Regression Standard Error.
[*]Current Relative Weight.
[*]Effective Sample Size.
[*]Trend Strength.

Alerts
The indicator includes:

[*]Variance-Weighted Regression Bullish: trend changes from bearish to bullish.
[*]Variance-Weighted Regression Bearish: trend changes from bullish to bearish.
[*]Variance-Weighted Regression Flip: either transition occurs.

Summary
Variance-Weighted Regression Trend starts with a normal rolling OLS regression, measures the residual variance around that fit, and uses those estimates to assign relative weights to the observations in a second regression.

The weighting strength, variance smoothing, regularization and weight limits are all configurable, making it possible to move from essentially equal-weight OLS to a much more selective fit.

The final weighted slope controls the trend state, while Weighted R² and the Slope / Standard Error score can optionally be used to filter weak reversals.

Regression channels, OLS comparison, forward projection and the visual strength system provide additional context around the core weighted regression without changing the underlying trend logic.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BackQuant

import TradingView/ta/12 as ta

//@version=6
indicator("Variance-Weighted Regression Trend [BackQuant]", overlay = true)

// Groups
const string g1 = "Regression Settings"
const string g2 = "Variance Weighting"
const string g3 = "Channel Settings"
const string g4 = "Trend Settings"
const string g5 = "UI Settings"

const color GREEN = #00ff00
const color RED   = #ff0000

// Regression Settings
float src = input.source(close, "Source", group = g1)
int regLen = input.int(60, "Regression Length", minval = 10, maxval = 300, group = g1, inline = "1")
int projectionBars = input.int(5, "Projection Bars", minval = 1, maxval = 50, group = g1, inline = "1")

// Variance Weighting
int varianceLen = input.int(20, "Variance Length", minval = 2, maxval = 100, group = g2, inline = "2")
string varianceMode = input.string("EMA", "Variance Model", options = ["EMA", "RMA", "Rolling Mean"], group = g2, inline = "2")
float weightPower = input.float(1.0, "Weight Power", minval = 0.0, maxval = 3.0, step = 0.05, group = g2, tooltip = "Controls inverse-variance weighting. 0 = equal weights, 1 = inverse variance, values above 1 suppress high-variance observations more aggressively.")
float varianceReg = input.float(0.05, "Variance Regularization", minval = 0.0, maxval = 1.0, step = 0.01, group = g2, tooltip = "Adds a fraction of mean residual variance to each local variance estimate to prevent unstable extreme weights.")
float minWeight = input.float(0.10, "Minimum Relative Weight", minval = 0.01, maxval = 1.0, step = 0.05, group = g2, inline = "3")
float maxWeight = input.float(10.0, "Maximum Relative Weight", minval = 1.0, maxval = 100.0, step = 0.5, group = g2, inline = "3")

// Channel Settings
string channelMode = input.string("Weighted Residual RMS", "Channel Width", options = ["Weighted Residual RMS", "Regression Standard Error"], group = g3)
float channelMult = input.float(2.0, "Channel Multiplier", minval = 0.1, maxval = 10.0, step = 0.05, group = g3)
bool expandPoorFit = input.bool(false, "Expand During Poor Fit", group = g3)
float poorFitExpansion = input.float(0.50, "Poor Fit Expansion", minval = 0.0, maxval = 3.0, step = 0.05, group = g3)

// Trend Settings
bool qualityConfirm = input.bool(false, "Quality Confirmation", group = g4, tooltip = "Requires minimum fit quality before allowing the trend state to flip.")
float minR2 = input.float(0.15, "Minimum Weighted R²", minval = 0.0, maxval = 1.0, step = 0.05, group = g4, inline = "4")
float minSlopeScore = input.float(0.50, "Minimum Slope / SE", minval = 0.0, maxval = 10.0, step = 0.10, group = g4, inline = "4")

// UI Settings
bool showRegression = input.bool(true, "Show Weighted Regression", group = g5)
bool showOLS = input.bool(false, "Show OLS Comparison", group = g5)
bool showChannel = input.bool(true, "Show Regression Channel", group = g5)
bool showFill = input.bool(true, "Gradient Fill", group = g5)
bool showGlow = input.bool(true, "Regression Glow", group = g5)
bool showProjection = input.bool(true, "Show Projection", group = g5)
bool paintBars = input.bool(true, "Color Candles", group = g5)
int lineW = input.int(3, "Line Width", minval = 1, maxval = 6, group = g5)
color longCol = input.color(GREEN, "Bullish", inline = "c", group = g5)
color shortCol = input.color(RED, "Bearish", inline = "c", group = g5)
color olsCol = input.color(#ffffff, "OLS", inline = "c", group = g5)

// Same-Window Variance-Weighted Regression
hwRegression(float source, simple int length, simple int varLen, string varMode, float power, float reg, float minW, float maxW, int projection) =>
    float sx = 0.0
    float sy = 0.0
    float sxx = 0.0
    float sxy = 0.0
    int n = 0

    for i = 0 to length - 1
        if not na(source[i])
            float x = length - 1 - i
            float y = source[i]
            sx += x
            sy += y
            sxx += x * x
            sxy += x * y
            n += 1

    float olsDen = n * sxx - sx * sx
    float olsSlope = n == length and olsDen != 0.0 ? (n * sxy - sx * sy) / olsDen : na
    float olsIntercept = n == length and not na(olsSlope) ? (sy - olsSlope * sx) / n : na
    float olsCurrent = not na(olsIntercept) ? olsIntercept + olsSlope * (length - 1) : na

    array<float> residual2 = array.new_float(length, na)
    float residualSum = 0.0

    if n == length and not na(olsIntercept)
        for i = 0 to length - 1
            float x = length - 1 - i
            float fitted = olsIntercept + olsSlope * x
            float resid = source[i] - fitted
            float r2 = resid * resid
            array.set(residual2, i, r2)
            residualSum += r2

    float meanResidual2 = n == length ? residualSum / length : na
    float varianceFloor = not na(meanResidual2) ? math.max(meanResidual2 * reg, syminfo.mintick * syminfo.mintick) : na

    array<float> variances = array.new_float(length, na)
    float varianceState = na
    float rollingSum = 0.0

    if n == length
        for j = 0 to length - 1
            int i = length - 1 - j
            float r2 = array.get(residual2, i)

            if varMode == "EMA"
                float alpha = 2.0 / (varLen + 1.0)
                varianceState := na(varianceState) ? r2 : alpha * r2 + (1.0 - alpha) * varianceState
            else if varMode == "RMA"
                float alpha = 1.0 / varLen
                varianceState := na(varianceState) ? r2 : alpha * r2 + (1.0 - alpha) * varianceState
            else
                rollingSum += r2
                if j >= varLen
                    int oldIndex = length - 1 - (j - varLen)
                    rollingSum -= array.get(residual2, oldIndex)
                varianceState := rollingSum / math.min(j + 1, varLen)

            array.set(variances, i, varianceState + varianceFloor)

    float rawWeightSum = 0.0

    if n == length
        for i = 0 to length - 1
            float variance = array.get(variances, i)
            float rawWeight = power == 0.0 ? 1.0 : 1.0 / math.pow(math.max(variance, 1e-12), power)
            rawWeightSum += rawWeight

    float avgRawWeight = n == length ? rawWeightSum / length : na

    float sw = 0.0
    float sw2 = 0.0
    float swx = 0.0
    float swy = 0.0
    float swxx = 0.0
    float swxy = 0.0

    if n == length and not na(avgRawWeight)
        for i = 0 to length - 1
            float x = length - 1 - i
            float y = source[i]
            float variance = array.get(variances, i)
            float rawWeight = power == 0.0 ? 1.0 : 1.0 / math.pow(math.max(variance, 1e-12), power)
            float relativeWeight = rawWeight / avgRawWeight
            float w = math.max(minW, math.min(maxW, relativeWeight))

            sw += w
            sw2 += w * w
            swx += w * x
            swy += w * y
            swxx += w * x * x
            swxy += w * x * y

    float weightedDen = sw * swxx - swx * swx
    float slope = weightedDen != 0.0 ? (sw * swxy - swx * swy) / weightedDen : na
    float intercept = sw > 0.0 and not na(slope) ? (swy - slope * swx) / sw : na
    float regression = not na(intercept) ? intercept + slope * (length - 1) : na
    float projected = not na(intercept) ? intercept + slope * (length - 1 + projection) : na
    float weightedMean = sw > 0.0 ? swy / sw : na

    float sse = 0.0
    float sst = 0.0

    if n == length and not na(intercept)
        for i = 0 to length - 1
            float x = length - 1 - i
            float y = source[i]
            float variance = array.get(variances, i)
            float rawWeight = power == 0.0 ? 1.0 : 1.0 / math.pow(math.max(variance, 1e-12), power)
            float relativeWeight = rawWeight / avgRawWeight
            float w = math.max(minW, math.min(maxW, relativeWeight))
            float fitted = intercept + slope * x

            sse += w * math.pow(y - fitted, 2)
            sst += w * math.pow(y - weightedMean, 2)

    float residualRms = sw > 0.0 ? math.sqrt(sse / sw) : na
    float weightedR2 = sst > 0.0 ? math.max(0.0, math.min(1.0, 1.0 - sse / sst)) : 0.0
    float residualVariance = n > 2 ? sse / (n - 2) : na

    float xMean = sw > 0.0 ? swx / sw : na
    float centeredSxx = sw > 0.0 ? swxx - swx * swx / sw : na
    float slopeVariance = not na(residualVariance) and centeredSxx > 0.0 ? residualVariance / centeredSxx : na
    float slopeSE = not na(slopeVariance) and slopeVariance > 0.0 ? math.sqrt(slopeVariance) : na
    float slopeScore = not na(slopeSE) and slopeSE > 0.0 ? math.abs(slope) / slopeSE : 0.0

    float currentX = length - 1
    float fitVariance = not na(residualVariance) and centeredSxx > 0.0 ? residualVariance * (1.0 / sw + math.pow(currentX - xMean, 2) / centeredSxx) : na
    float regressionSE = not na(fitVariance) and fitVariance > 0.0 ? math.sqrt(fitVariance) : na

    float effectiveN = sw2 > 0.0 ? sw * sw / sw2 : na

    float currentVariance = array.get(variances, 0)
    float currentRawWeight = power == 0.0 ? 1.0 : 1.0 / math.pow(math.max(currentVariance, 1e-12), power)
    float currentWeight = not na(avgRawWeight) and avgRawWeight > 0.0 ? math.max(minW, math.min(maxW, currentRawWeight / avgRawWeight)) : na

    [regression, projected, slope, residualRms, regressionSE, weightedR2, slopeScore, currentWeight, effectiveN, olsCurrent]

// Calculation
[regression, projected, slope, residualRms, regressionSE, weightedR2, slopeScore, currentWeight, effectiveN, ols] = hwRegression(src, regLen, varianceLen, varianceMode, weightPower, varianceReg, minWeight, maxWeight, projectionBars)

// Trend State
bool qualityPass = not qualityConfirm or (weightedR2 >= minR2 and slopeScore >= minSlopeScore)

var int trend = 0

if trend == 0 and not na(slope)
    trend := slope >= 0.0 ? 1 : -1
else if slope > 0.0 and trend != 1 and qualityPass
    trend := 1
else if slope < 0.0 and trend != -1 and qualityPass
    trend := -1

bool bullFlip = trend == 1 and trend[1] == -1
bool bearFlip = trend == -1 and trend[1] == 1
bool trendFlip = bullFlip or bearFlip

color trendCol = trend == 1 ? longCol : trend == -1 ? shortCol : color.gray

// Channel
float channelBase = channelMode == "Weighted Residual RMS" ? residualRms : regressionSE
float fitExpansion = expandPoorFit ? 1.0 + (1.0 - weightedR2) * poorFitExpansion : 1.0
float channelWidth = channelBase * channelMult * fitExpansion

float upperChannel = regression + channelWidth
float lowerChannel = regression - channelWidth

// Trend Quality
float fitStrength = math.max(0.0, math.min(weightedR2, 1.0))
float slopeStrength = math.max(0.0, math.min(slopeScore / 3.0, 1.0))
float trendStrength = math.min(fitStrength * 0.60 + slopeStrength * 0.40, 1.0)

int barsSinceFlip = nz(ta.barssince(trendFlip), 100000)
float bloomStrength = barsSinceFlip == 1 ? 1.0 : barsSinceFlip == 2 ? 0.55 : barsSinceFlip == 3 ? 0.25 : 0.0

// Plots
pReg = plot(showRegression ? regression : na, "Variance-Weighted Regression", color = trendCol, linewidth = lineW)
plot(showOLS ? ols : na, "OLS Comparison", color = color.new(olsCol, 50), linewidth = 1)

pUpper = plot(showChannel ? upperChannel : na, "Upper Regression Channel", color = color.new(trendCol, 80), linewidth = 1)
pLower = plot(showChannel ? lowerChannel : na, "Lower Regression Channel", color = color.new(trendCol, 80), linewidth = 1)

fill(
     pReg, pUpper,
     upperChannel, regression,
     showChannel and showFill ? color.new(trendCol, 92) : na,
     showChannel and showFill ? color.new(trendCol, 28) : na,
     title = "Upper Channel Gradient")

fill(
     pReg, pLower,
     regression, lowerChannel,
     showChannel and showFill ? color.new(trendCol, 28) : na,
     showChannel and showFill ? color.new(trendCol, 92) : na,
     title = "Lower Channel Gradient")

// Projection
plot(showProjection ? projected : na, "Regression Projection", color = color.new(trendCol, 30), linewidth = 2, offset = projectionBars)

// Regression Glow
float atr = ta.atr(14)
float glow = atr * (0.035 + trendStrength * 0.030)
float outerGlow = glow * 2.4

pGlowLower = plot(showGlow ? regression - glow : na, "Glow Lower", display = display.none, editable = false)
pGlowUpper = plot(showGlow ? regression + glow : na, "Glow Upper", display = display.none, editable = false)
pOuterGlowLower = plot(showGlow ? regression - outerGlow : na, "Outer Glow Lower", display = display.none, editable = false)
pOuterGlowUpper = plot(showGlow ? regression + outerGlow : na, "Outer Glow Upper", display = display.none, editable = false)

fill(pOuterGlowLower, pOuterGlowUpper, showGlow ? color.new(trendCol, 95 - int(math.round(trendStrength * 8.0))) : na, title = "Outer Regression Glow")
fill(pGlowLower, pGlowUpper, showGlow ? color.new(trendCol, 86 - int(math.round(trendStrength * 22.0))) : na, title = "Inner Regression Glow")

// Flip Bloom
float bloomWidth = atr * (0.10 + bloomStrength * 0.10)
bool bloomReady = showGlow and bloomStrength > 0.0 and not na(regression)

pBloomLower = plot(bloomReady ? regression - bloomWidth : na, "Bloom Lower", display = display.none, editable = false)
pBloomUpper = plot(bloomReady ? regression + bloomWidth : na, "Bloom Upper", display = display.none, editable = false)

fill(pBloomLower, pBloomUpper, bloomReady ? color.new(trendCol, 90 - int(math.round(bloomStrength * 18.0))) : na, title = "Flip Bloom")

// Candles
plotcandle(open, high, low, close, "Trend Candles", trendCol, trendCol, true, bordercolor = trendCol, display = paintBars ? display.all : display.none)

// Data Window
plot(slope, "Weighted Slope", display = display.data_window, editable = false)
plot(weightedR2 * 100.0, "Weighted R²", display = display.data_window, editable = false)
plot(slopeScore, "Slope / Standard Error", display = display.data_window, editable = false)
plot(residualRms, "Weighted Residual RMS", display = display.data_window, editable = false)
plot(regressionSE, "Regression Standard Error", display = display.data_window, editable = false)
plot(currentWeight, "Current Relative Weight", display = display.data_window, editable = false)
plot(effectiveN, "Effective Sample Size", display = display.data_window, editable = false)
plot(trendStrength * 100.0, "Trend Strength", display = display.data_window, editable = false)

// Alerts
alertcondition(bullFlip, "Variance-Weighted Regression Bullish", "Variance-Weighted Regression Trend turned bullish on {{ticker}}")
alertcondition(bearFlip, "Variance-Weighted Regression Bearish", "Variance-Weighted Regression Trend turned bearish on {{ticker}}")
alertcondition(bullFlip or bearFlip, "Variance-Weighted Regression Flip", "Variance-Weighted Regression Trend changed direction on {{ticker}}")
````
