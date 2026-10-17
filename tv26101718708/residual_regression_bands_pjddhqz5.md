# Residual Regression Bands

- url: https://www.tradingview.com/script/pJddhQz5-Residual-Regression-Bands/
- type: indicator
- pine_id: PUB;2dcb14811cd04cba909b9812edfc3308
- version: 1.0

## Description

This indicator plots a linear regression “fair value” path with upper and lower bands based on the standard deviation of price residuals from the fitted regression line.

Unlike a simple standard deviation channel, the bands are calculated around the current regression slope, helping the channel remain trend-adjusted during strong directional moves. This can make the opposite band more useful as a pullback or mean-reversion reference instead of expanding unrealistically far away from price.

Default settings use a 25-period lookback and 2 residual standard deviations.

The indicator can be used to visualize:
	•	Trend-adjusted fair value
	•	Price extension from the regression path
	•	Pullback zones within a trend
	•	Potential mean-reversion areas

As always, this tool is intended for analysis and should be combined with your own risk management and trading plan.

## Source Code

````pine
//@version=6
indicator("Residual Regression Bands", overlay=true)

// ============================================================
// INPUTS
// ============================================================
regLen    = input.int(25, "Regression Lookback", minval=2)
sigmaMult = input.float(2, "Sigma Multiplier", step=0.1)
src       = input.source(close, "Source")

showFill  = input.bool(true, "Show Channel Fill")

// ============================================================
// TRUE LINEAR REGRESSION + RESIDUAL STANDARD DEVIATION
// This mirrors your larger strategy/panel version.
// ============================================================
f_reg_and_resid_std(_src, _len) =>
    float reg_value = na
    float resid_std = na

    if bar_index >= _len - 1
        float x_mean = (_len - 1) / 2.0
        float var_x = 0.0

        // Variance of x values
        for j = 0 to _len - 1
            float x = j
            var_x += math.pow(x - x_mean, 2)

        // Mean of y values
        float y_sum = 0.0
        for j = 0 to _len - 1
            y_sum += _src[_len - 1 - j]

        float y_mean = y_sum / _len

        // Covariance of x and y
        float cov_xy = 0.0
        for j = 0 to _len - 1
            float x = j
            float y = _src[_len - 1 - j]
            cov_xy += (x - x_mean) * (y - y_mean)

        float slope = cov_xy / var_x
        float intercept = y_mean - slope * x_mean

        // Regression value at the current bar
        reg_value := intercept + slope * (_len - 1)

        // Residual standard deviation
        // Each historical close is compared to its own point on the fitted line.
        float ss = 0.0
        for j = 0 to _len - 1
            float x = j
            float y = _src[_len - 1 - j]
            float y_hat = intercept + slope * x
            float resid = y - y_hat
            ss += resid * resid

        resid_std := math.sqrt(ss / _len)

    [reg_value, resid_std]

// ============================================================
// CHANNEL CALCULATION
// ============================================================
[basis, residStd] = f_reg_and_resid_std(src, regLen)

upperBand = basis + sigmaMult * residStd
lowerBand = basis - sigmaMult * residStd

// ============================================================
// PLOTS
// ============================================================
basisPlot = plot(basis, "Regression", color=color.yellow, linewidth=2)
upperPlot = plot(upperBand, "Upper Channel", color=color.red, linewidth=1)
lowerPlot = plot(lowerBand, "Lower Channel", color=color.lime, linewidth=1)

fill(
     upperPlot,
     lowerPlot,
     color = showFill ? color.new(color.gray, 88) : na,
     title = "Channel Fill"
)
````
