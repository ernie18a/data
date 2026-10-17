# [blackcat] L2 Volatility of Williams VixFix Risk Assessment

- url: https://www.tradingview.com/script/U71YHk3h-blackcat-L2-Volatility-of-Williams-VixFix-Risk-Assessment/
- type: indicator
- pine_id: PUB;ad9ff97adec847eaaa3f3dc73269f21e
- version: 1.0

## Description

my update to a fix for the buy and sell on the chart

## Source Code

````pine
    // ____  __    ___   ________ ___________  ___________ __  ____ ___ 
   // / __ )/ /   /   | / ____/ //_/ ____/   |/_  __<  / // / / __ |__ \
  // / __  / /   / /| |/ /   / ,< / /   / /| | / /  / / // /_/ / / __/ /
 // / /_/ / /___/ ___ / /___/ /| / /___/ ___ |/ /  / /__  __/ /_/ / __/ 
// /_____/_____/_/  |_\____/_/ |_\____/_/  |_/_/  /_/  /_/  \____/____/  
                                     

// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © blackcat1402

//@version=5
indicator("[blackcat] L2 Volatility of Williams VixFix Risk Assessment", shorttitle="VoWVRA", overlay=false)

// Williams_Vix_Fix Indicator Inputs
lookback_period_stddev_high = input.int(22, title="LookBack Period Standard Deviation High")
bollinger_band_length = input.int(20, title="Bollinger Band Length")
bollinger_band_stddev_up = input.float(2.0, minval=1, maxval=5, title="Bollinger Band Standard Deviation Up")
lookback_period_percentile_high = input.int(50, title="Look Back Period Percentile High")
percentile_threshold = input.float(.85, title="Percentile - 0.90=90%, 0.95=95%, 0.99=99%")

// Risk Assessment Indicator Inputs
risk_assessment_length = input.int(33, title='Risk Length')
safety_assessment_length = input.int(21, title = "Safety Length")
ema_length = input.int(20, title = "EMA Length")

// Calculate Williams_Vix_Fix Indicator
calculate_williams_vix_fix(close, lookback_period_stddev_high, bollinger_band_length, bollinger_band_stddev_up, lookback_period_percentile_high, percentile_threshold) =>
    high_close = ta.highest(close, lookback_period_stddev_high)
    williams_vix_fix = ((high_close - low) / high_close) * 100
    standard_deviation = bollinger_band_stddev_up * ta.stdev(williams_vix_fix, bollinger_band_length)
    mid_line = ta.sma(williams_vix_fix, bollinger_band_length)
    lower_band = mid_line - standard_deviation
    upper_band = mid_line + standard_deviation
    range_high = (ta.highest(williams_vix_fix, lookback_period_percentile_high)) * percentile_threshold
    color_wvf = williams_vix_fix >= upper_band or williams_vix_fix >= range_high ? color.red : color.gray
    [williams_vix_fix, color_wvf]

// Calculate Risk Assessment Indicator
calculate_risk_assessment(low, high, close, risk_assessment_length, safety_assessment_length, ema_length) =>
    lowest_low = ta.lowest(low, risk_assessment_length)
    highest_high = ta.highest(high, safety_assessment_length)
    ema_value = ta.ema((close - lowest_low) / (highest_high - lowest_low) * 100, ema_length) * 0.998
    current_safety_level = 100 - ta.ema(0.667 * ema_value[1] + 0.333 * ema_value, 1)
    color_risk = current_safety_level >= 80 ? color.blue : current_safety_level >= 50 ? color.green : current_safety_level >= 20 ? color.yellow : color.red
    [current_safety_level, color_risk]

// Normalize and scale the indicators to the range of 0 to 100
normalize_indicator(indicator_value, lookback_period) =>
    normalized_value = (indicator_value - ta.lowest(indicator_value, lookback_period)) / (ta.highest(indicator_value, lookback_period) - ta.lowest(indicator_value, lookback_period)) * 100
    normalized_value

// Merge the normalized indicators
merge_indicators(normalized_wvf, normalized_risk) =>
    merged_value = ta.alma((normalized_wvf + normalized_risk) / 2, 8, 0.85, 6)
    merged_value

// Main logic
[williams_vix_fix, color_wvf] = calculate_williams_vix_fix(close, lookback_period_stddev_high, bollinger_band_length, bollinger_band_stddev_up, lookback_period_percentile_high, percentile_threshold)
[current_safety_level, color_risk] = calculate_risk_assessment(low, high, close, risk_assessment_length, safety_assessment_length, ema_length)
normalized_wvf = normalize_indicator(williams_vix_fix, lookback_period_stddev_high)
normalized_risk = normalize_indicator(current_safety_level, risk_assessment_length)
merged_value = merge_indicators(normalized_wvf, normalized_risk)

// Plot the merged value
plot(merged_value, title="Merged Indicator", color=merged_value > 70 ? color.red : merged_value < 30 ? color.green : color.gray, linewidth=2)
h1 = hline(70, color=color.green)
h2 = hline(30, color=color.red)
hline(50, color=color.silver)
fill(h1, h2, color=color.new(color.gray, 60))

// Plotting the label at fixed value
l70 = label.new(bar_index, 70, text='May Short when > 70', style=label.style_label_down, textcolor=color.white, color=color.new(color.red, 80), size=size.small)
label.delete(l70[1])
l50 = label.new(bar_index, 50, text='Sideways in gray', style=label.style_label_down, textcolor=color.white, color=color.new(color.gray, 80), size=size.small)
label.delete(l50[1])
l30 = label.new(bar_index, 30, text='May Long when < 30', style=label.style_label_up, textcolor=color.white, color=color.new(color.green, 80), size=size.small)
label.delete(l30[1])

// Buy and Sell labels based on crossings
if (ta.crossover(merged_value[2], merged_value))
    label.new(bar_index, merged_value, text="sell", style=label.style_label_up, textcolor=color.white, color=color.green, size=size.small)
if  (ta.crossunder(merged_value[2], merged_value))
    label.new(bar_index, merged_value, text="buy", style=label.style_label_down, textcolor=color.white, color=color.red, size=size.small)

// Alerts
alertcondition(ta.crossover(merged_value[2], merged_value), title="Buy Alert", message="Buy signal triggered")
alertcondition(ta.crossunder(merged_value[2], merged_value), title="Sell Alert", message="Sell signal triggered")
````
