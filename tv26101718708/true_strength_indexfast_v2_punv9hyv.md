# True Strength Index-Fast V2

- url: https://www.tradingview.com/script/PUNv9hyv-True-Strength-Index-Fast-V2/
- type: indicator
- pine_id: PUB;defa841c90874365ad58d842279db69b
- version: 1.0

## Description

The True Strength Index - Fast (TSI-Fast) utilizes the standard True Strength Index as published.  The changes made are in 2 areas - 1) The default parameters have been set to 8, 8, 3, so that it responds faster; and 2) 2 levels are used at +42 and -42, where +42 is overbought and -42 is oversold.  Visibility is increased with the area over +42 and under -42 are color filled.

User input parameters are available for user customization

## Source Code

````pine
//@version=6
//True Strength Index - Fast with upper & lower threshold levels at +/- 42
indicator("True Strength Index-Fast V2", shorttitle="TSI-Fast", format=format.price, precision=4, timeframe="", timeframe_gaps=true)

// Inputs
long = input(title="Long Length", defval=8)
short = input(title="Short Length", defval=8)
signal = input(title="Signal Length", defval=3)
upper_thresh = input.float(42.0, title="Upper Threshold")
lower_thresh = input.float(-42.0, title="Lower Threshold")

price = close

double_smooth(src, long, short) =>
    fist_smooth = ta.ema(src, long)
    ta.ema(fist_smooth, short)

pc = ta.change(price)
double_smoothed_pc = double_smooth(pc, long, short)
double_smoothed_abs_pc = double_smooth(math.abs(pc), long, short)
tsi_value = 100 * (double_smoothed_pc / double_smoothed_abs_pc)

// Plot TSI & Signal (Assigned TSI plot to a variable)
p_tsi = plot(tsi_value, title="True Strength Index", color=#2962FF)
plot(ta.ema(tsi_value, signal), title="Signal", color=#E91E63)

// Threshold Lines (Plotted as variables for fill compatibility)
p_upper = plot(upper_thresh, title="Upper Threshold", color=#f69b6bbf)
p_lower = plot(lower_thresh, title="Lower Threshold", color=#f69b6bbf)
hline(0, title="Zero", color=#787B86)

// Area Fills
// 1. Fills area above the upper threshold (+42) when TSI breaks above it
fill(p_tsi, p_upper, 
     color = tsi_value > upper_thresh ? color.new(#2962FF, 60) : color.new(color.white, 100), 
     title="Upper Breakout Fill")

// 2. Fills area below the lower threshold (-42) when TSI breaks below it
fill(p_tsi, p_lower, 
     color = tsi_value < lower_thresh ? color.new(#E91E63, 60) : color.new(color.white, 100), 
     title="Lower Breakout Fill")
````
