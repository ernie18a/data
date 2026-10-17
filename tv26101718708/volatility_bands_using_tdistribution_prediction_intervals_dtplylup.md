# Volatility Bands Using t-Distribution & Prediction Intervals

- url: https://www.tradingview.com/script/DTPlYluP-Volatility-Bands-Using-t-Distribution-Prediction-Intervals/
- type: indicator
- pine_id: PUB;ebf95d9bd9114c53aed756f0f249d2a1
- version: 3.0

## Description

This indicator is a statistical tool designed to project a dynamic range where the next asset price is expected to fall within a specific level of confidence.

Unlike standard volatility bands, a prediction interval is a statistical range that estimates where a single future observation will fall, given a specific probability. Because predicting a single future outcome introduces more inherent uncertainty than predicting an average, these bands are wider and mathematically tighter for forecasting next-bar anomalies.

[b]How it Works[/b]
This indicator uses a Student's t-distribution (or an optional z-distribution for performance) to calculate historical volatility thresholds.

[b]Finding the Estimated t-distribution[/b]
When you select a 95% Confidence Level, the script sets an error alpha of 5% (1 - 0.95). Because asset price movement can deviate to either the upside or downside, it splits this error equally into both tails (a two-tailed test). The script normalizes this, targeting an exact area of 0.025 (2.5%) in the extreme tails of the curve.

To find where that target area lies, the script reconstructs the Probability Density Function (PDF) of the Student's t-distribution. The height of the curve depends heavily on the Degrees of Freedom (df = length - 1).

Because Pine Script doesn't have a native Gamma function, the script uses double factorials to calculate the complex math coefficients. If your sample size (length) is exceptionally high (>300), the t-distribution naturally mirrors a regular normal distribution, so it switches to a standard Gaussian curve equation to save some time.

[pine]// Calculate double factorial
double_fac(int n) =>
    float res = 1.0
    int curr = n
    while curr > 1
        res := res * curr
        curr := curr - 2
    res

// t-distribution formula
cur_dist(float x, int cur_df) =>
    float res = 0.0
    if cur_df > 300
        res := 0.3989422804014326779 * math.exp(-x * x * 0.5)
    else
        float coeff = double_fac(cur_df - 1) / (math.sqrt(cur_df) * double_fac(cur_df - 2) * (cur_df % 2 == 0 ? 2.0 : math.pi))
        res := coeff * math.pow(1.0 + x * x / cur_df, -0.5 * (cur_df + 1))
    res[/pine]

To find the approximate t-value that corresponds to our target tail area, the script performs numerical integration using the Trapezoid Rule (trapezoid_reverse). This is the most time consuming part.

[pine]// Reverse trapezoidal to calculate t-value from area
trapezoid_reverse(float p, int cur_df) =>
    float max_p = 0.5
    float max_stat = 300.0
    float add_prec = 1.0
    
    float result_i = 0.0
    if p == max_p
        result_i := 100000000.0 // Infinity
    else
        float trap_sum = 0.0
        float gap_width = p / (add_prec * 1250.0)
        float i = 0.0
        float last_func = cur_dist(0.0, cur_df)
        
        while trap_sum < (2500.0 * add_prec) and i < max_stat
            i := i + gap_width
            trap_sum := trap_sum + last_func
            last_func := cur_dist(i, cur_df)
            trap_sum := trap_sum + last_func
        result_i := i
    result_i[/pine]

[b]Calculating the Prediction Interval[/b]
Once the t-critical value is found, it is then put into the standard prediction interval formula. The script uses EMA instead of SMA to improve responsiveness to current trends.

[pine]float prediction_interval_top = mean + tCrit * stdev * math.sqrt(1 + 1/length)
float prediction_interval_bot = mean - tCrit * stdev * math.sqrt(1 + 1/length)[/pine]

Because the calculations for the t-distribution estimates are computationally expensive, you can select the lookback window for using the t-distribution. You can also choose to use the faster z-score for historical bars.

Note 1: The larger the sample size, the smaller you may have to set your lookback window in order to fit within the execution time limits.

You can use this for:
[list=1][*]Overbought/Oversold, Mean reversion signals
[*]Dynamic Stop-loss/Take-profit (SL/TP)[/list]

1. Overbought/Oversold/Mean Reversion
[image]https://www.tradingview.com/x/WbwzbY7k/[/image]
The indicator creates a red background to indicate that the candlestick has broken above the top 95% prediction interval band. It can be interpreted as a potential reversal.

2. Dynamic Stop-loss/Take-profit (SL/TP)
You can utilize the plotted mean and the confidence interval as entry/exit points. For example, you could put a stop-loss at the bottom band, and a take profit at the top band.

Alerts:
[list=1][*]Price Above Top PI (Close crossed out)
[*]Price Below Bottom PI (Close crossed out)
[*]High Above Top PI (Wick touched/pierced top)
[*]Low Below Bottom PI (Wick touched/pierced bottom)[/list]

Settings:
[list][*]Length: The size of the sample for the standard deviation & mean calculations. 30 is recommended.
[*]Source: Used for standard deviation & mean calculations. For example: Changing the source to 'high' would make the indicator predict the range of the next 'high'.
[*]Confidence Level: Dictates how wide the bands should be. A 95% confidence level is default. Must be entered as a decimal between 0 and 1.
[*]Lookback Length: Used to limit the amount of bars to back calculate the prediction interval using the t-distribution. Default is 300.
[*]Use z-score: Use the z-score to calculated past values. Note that this will introduce error. For example, for a sample size of 30 and a 95% confidence level, using a z-score instead of a t-score will introduce a ~4.2% error in your interval width, causing your actual prediction interval to drop from 95% down to ~94.0%.[/list]

Background Colors:
[list][*]Green: The low/close of the candle breached the lower band. Potential bullish reversal.
[*]Red: The high/close of the candle breached the upper band. Potential bearish reversal.[/list]

Limitations:
[list=1][*]The indicator assumes that the data follows a bell curve, which the markets do not.
[*]The indicator may lag behind actual price action.
[*]The indicator may produce false signals.
[*]The indicator does not predict future prices.
[/list]

Disclaimer: All trading decisions and responsibilities rest solely on the user of the indicator.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © starcat2671

//@version=6
indicator("Volatility Bands", overlay=true)

// Inputs
int length = input.int(30, title="Length", tooltip="Used for standard deviation & mean calculations. 30 is recommended.")
series float src = input.source(close, title="Source", tooltip="Used for standard deviation & mean calculations.")
float prediction = input.float(0.95, title="Confidence Level", tooltip="Increasing the confidence will make it more confident of where the next price may be. Must be between 0 and 1.")

// CALCULATING T-CRITICAL ESTIMATES
// Calculate double factorial
double_fac(int n) =>
    float res = 1.0
    int curr = n
    while curr > 1
        res := res * curr
        curr := curr - 2
    res

// t-distribution PDF formula
cur_dist(float x, int cur_df) =>
    float res = 0.0
    if cur_df > 300 // Use gauss to save time if sample size is big enough
        res := 0.3989422804014326779 * math.exp(-x * x * 0.5)
    else
        float coeff = double_fac(cur_df - 1) / (math.sqrt(cur_df) * double_fac(cur_df - 2) * (cur_df % 2 == 0 ? 2.0 : math.pi))
        res := coeff * math.pow(1.0 + x * x / cur_df, -0.5 * (cur_df + 1))
    res

// Reverse trapezoidal to calculate t-value from area
trapezoid_reverse(float p, int cur_df) =>
    float max_p = 0.5
    float max_stat = 300.0
    float add_prec = 1.0
    
    float result_i = 0.0
    if p == max_p
        result_i := 100000000.0 // Infinity
    else
        float trap_sum = 0.0
        float gap_width = p / (add_prec * 1250.0)
        float i = 0.0
        float last_func = cur_dist(0.0, cur_df)
        
        while trap_sum < (2500.0 * add_prec) and i < max_stat
            i := i + gap_width
            trap_sum := trap_sum + last_func
            last_func := cur_dist(i, cur_df)
            trap_sum := trap_sum + last_func
        result_i := i
    result_i

// Adjust p-value based on tail option before calculation
pre_adjust_p(float inp_p, int cur_tails) =>
    float res = inp_p / 2.0 // Default for option 5
    if cur_tails == 1
        res := math.max(math.min(0.5 - inp_p / 2.0, 0.5), 0.0)
    else if cur_tails == 2 or cur_tails == 3
        res := math.abs(0.5 - inp_p)
    else if cur_tails == 4
        res := math.min(inp_p, 0.5)
    res

// Flip sign of calculated t-value if required
post_adjust_t(float inp_t, float cur_p, int cur_tails) =>
    float res = inp_t
    if (cur_tails == 2 and cur_p >= 0.5) or (cur_tails == 3 and cur_p <= 0.5)
        res := -inp_t
    res

// Calculate t-value from p-value
// 1: two tails, 2: right tail, 3: left tail, 4: 0 to t, 5: -t to t
// We are calculating a two tail test⁷
calculate_t_from_p(float pVal, int df, int option) =>
    float cur_p = math.min(math.max(pVal, 0.0), option == 4 ? 0.5 : 1.0)
    float std_p = pre_adjust_p(cur_p, option)
    
    float raw_t = 0.0
    if std_p > 0.4999
        raw_t := 100000000.0 // Inf
    else
        raw_t := trapezoid_reverse(std_p, df)
        
    post_adjust_t(raw_t, cur_p, option)

// Calculate only once
var float tCrit = calculate_t_from_p(1-prediction, length-1, 1)

// Calculations
float mean = ta.ema(src, length)
float stdev = ta.stdev(src, length, false)

float prediction_interval_top = mean + tCrit * stdev * math.sqrt(1 + 1/length)
float prediction_interval_bot = mean - tCrit * stdev * math.sqrt(1 + 1/length)

// Background
bgcolor(close < prediction_interval_bot or low < prediction_interval_bot ? color.new(color.green, 90) : na)
bgcolor(close > prediction_interval_top or high > prediction_interval_top ? color.new(color.red, 90) : na)

// Prediction Interval Bands
plot(prediction_interval_top, color=color.red, title="Top")
plot(prediction_interval_bot, color=color.green, title="Bottom")
plot(mean, title="Mean")

// Alerts
alertcondition(close > prediction_interval_top, "Price Above Top PI")
alertcondition(close < prediction_interval_bot, "Price Below Bot PI")
alertcondition(high > prediction_interval_top, "High Above Top PI")
alertcondition(low < prediction_interval_bot, "Low Below Bot PI")
````
