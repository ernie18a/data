<!-- tradingview-pine-id: PUB;3f3114505bf64d7dae2ec48e0b8165a3 -->
<!-- tradingviewscripts-format: 1 -->
# Dynamic Volume Profile Oscillator | AlphaAlgos

Source: https://www.tradingview.com/script/UKGKPPqM-Dynamic-Volume-Profile-Oscillator-AlphaAlgos/

## Description

Dynamic Volume Profile Oscillator | AlphaAlgos

Overview
The Dynamic Volume Profile Oscillator is an advanced technical analysis tool that transforms traditional volume analysis into a responsive oscillator. By creating a dynamic volume profile and measuring price deviation from volume-weighted equilibrium levels, this indicator provides traders with powerful insights into market momentum and potential reversals.

Key Features
• Volume-weighted price deviation analysis
• Adaptive midline that adjusts to changing market conditions
• Beautiful gradient visualization with 10-level intensity zones
• Fast and slow signal lines for trend confirmation
• Mean reversion mode that identifies price extremes relative to volume
• Fully customizable sensitivity and smoothing parameters

Technical Components

1. Volume Profile Analysis
The indicator builds a dynamic volume profile by:
• Collecting recent price and volume data within a specified lookback period
• Calculating a volume-weighted mean price (similar to VWAP)
• Measuring how far current price has deviated from this weighted average
• Adjusting this deviation based on historical volatility

2. Oscillator Calculation
The oscillator offers two calculation methods:
• Mean Reversion Mode (default): Measures deviation from volume-weighted mean price, normalized to reflect potential overbought/oversold conditions
• Standard Mode: Normalizes volume activity to identify unusual volume patterns

3. Adaptive Zones
The indicator features dynamic zones that:
• Center around an adaptive midline that reflects the average oscillator value
• Expand and contract based on recent volatility (standard deviation)
• Visually represent intensity through multi-level gradient coloring
• Provide clear visualization of bullish/bearish extremes

4. Signal Generation
Trading signals are generated through:
• Main oscillator line position relative to the adaptive midline
• Crossovers between fast (5-period) and slow (15-period) signal lines
• Color changes that instantly identify trend direction
• Distance from the midline indicating trend strength

Configuration Options

Volume Analysis Settings:
• Price Source - Select which price data to analyze
• Volume Source - Define volume data source
• Lookback Period - Number of bars for main calculations
• Profile Calculation Periods - Frequency of profile recalculation

Oscillator Settings:
• Smoothing Length - Controls oscillator smoothness
• Sensitivity - Adjusts responsiveness to price/volume changes
• Mean Reversion Mode - Toggles calculation methodology

Threshold Settings:
• Adaptive Midline - Uses dynamic midline based on historical values
• Midline Period - Lookback period for midline calculation
• Zone Width Multiplier - Controls width of bullish/bearish zones

Display Settings:
• Color Bars - Option to color price bars based on trend direction

Trading Strategies

Trend Following:
• Enter long positions when the oscillator crosses above the adaptive midline
• Enter short positions when the oscillator crosses below the adaptive midline
• Use signal line crossovers for entry timing
• Monitor gradient intensity to gauge trend strength

Mean Reversion Trading:
• Look for oscillator extremes shown by intense gradient colors
• Prepare for potential reversals when the oscillator reaches upper/lower zones
• Use divergences between price and oscillator for confirmation
• Consider scaling positions based on gradient intensity

Volume Analysis:
• Use Standard Mode to identify unusual volume patterns
• Confirm breakouts when accompanied by strong oscillator readings
• Watch for divergences between price and volume-based readings
• Use extended periods in extreme zones as trend confirmation

Best Practices
• Adjust sensitivity based on the asset's typical volatility
• Use longer smoothing for swing trading, shorter for day trading
• Combine with support/resistance levels for optimal entry/exit points
• Consider multiple timeframe analysis for comprehensive market view
• Test different profile calculation periods to match your trading style

This indicator is provided for informational purposes only. Always use proper risk management when trading based on any technical indicator. Not financial advise.

---

## Source Code

````pine
// @version=6
indicator("Dynamic Volume Profile Oscillator | AlphaAlgos", overlay = false)

// Input Groups
VS = "Volume Analysis"
OS = "Oscillator Settings"
DS = "Display Settings"
TS = "Threshold Settings"

// Volume Analysis Settings
price_src = input.source(close, "Price Source", group = VS)
volume_src = input.source(volume, "Volume Source", group = VS)
lookback = input.int(50, "Lookback Period", minval = 10, group = VS)
profile_periods = input.int(10, "Profile Calculation Periods", minval = 5, maxval = 100, group = VS)

// Oscillator Settings
smoothing = input.int(5, "Smoothing Length", minval = 1, maxval = 50, group = OS)
sensitivity = input.float(1.0, "Sensitivity", minval = 0.1, maxval = 5.0, step = 0.1, group = OS)
mean_reversion = input.bool(true, "Mean Reversion Mode", group = OS, tooltip="Measures deviation from volume-weighted mean price")

// Threshold Settings
use_adaptive_midline = input.bool(true, "Use Adaptive Midline", group = TS, tooltip="Calculates a dynamic midline based on historical oscillator values")
midline_period = input.int(50, "Adaptive Midline Period", minval = 10, maxval = 200, group = TS)
zone_width = input.float(1.5, "Zone Width Multiplier", minval = 0.5, maxval = 3.0, step = 0.1, group = TS)

// Display Settings
color_bars = input.bool(true, "Color Bars", group = DS)

bull_color = color.rgb(0, 241, 255)
bear_color = color.rgb(255, 1, 154)

// Normalize to 0-100 scale
normalize(value, min_val, max_val) =>
    range1 = max_val - min_val
    range1 <= 0 ? 50 : math.min(100, math.max(0, ((value - min_val) / range1) * 100))

// Calculate Price-Volume relationships
calculate_volume_profile() =>
    var profile = array.new_float(0)
    var prices = array.new_float(0)
    
    // Reset arrays on new calculation
    if array.size(profile) == 0 or bar_index % profile_periods == 0
        array.clear(profile)
        array.clear(prices)
        
        // Build recent price history with volume
        for i = 0 to math.min(lookback - 1, bar_index)
            array.push(prices, price_src[i])
            array.push(profile, volume_src[i])
    
    // Calculate weighted metrics
    sum_vol = array.sum(profile)
    if sum_vol > 0
        // Calculate volume-weighted mean price
        sum_price_vol = 0.0
        for i = 0 to array.size(prices) - 1
            sum_price_vol += array.get(prices, i) * array.get(profile, i)
        vwap = sum_price_vol / sum_vol
        
        // Calculate volume-weighted deviation
        sum_dev = 0.0
        for i = 0 to array.size(prices) - 1
            price_dev = array.get(prices, i) - vwap
            vol_weight = array.get(profile, i) / sum_vol
            sum_dev += math.abs(price_dev) * vol_weight
        
        [vwap, sum_dev]
    else
        [price_src, 0]

// Calculate Volume Profile metrics
[vwap_level, price_deviation] = calculate_volume_profile()

// Calculate oscillator value
oscillator_raw = mean_reversion ? 50 + (price_src - vwap_level) / (price_deviation * sensitivity) * 25 : normalize(ta.sma(volume_src, smoothing), ta.lowest(ta.sma(volume_src, smoothing), lookback), ta.highest(ta.sma(volume_src, smoothing), lookback))

// Smooth the oscillator
oscillator = ta.ema(oscillator_raw, smoothing)

// Calculate adaptive midline
adaptive_midline = use_adaptive_midline ? ta.sma(oscillator, midline_period) : 50

// Calculate standard deviation for adaptive zones
oscillator_stdev = ta.stdev(oscillator, midline_period) * zone_width
upper_zone = adaptive_midline + oscillator_stdev
lower_zone = adaptive_midline - oscillator_stdev

// Calculate signal lines
fast_signal = ta.ema(oscillator, 5)
slow_signal = ta.ema(oscillator, 15)

// Determine trend relative to adaptive midline
is_bullish = oscillator > adaptive_midline or fast_signal > slow_signal
is_bearish = not is_bullish

// Detect crossovers
crossover_up = ta.crossover(fast_signal, slow_signal)
crossover_down = ta.crossunder(fast_signal, slow_signal)

// Set signal colors
main_color = is_bullish ? bull_color : bear_color
midline_color = color.new(color.gray, 0)
zone_bull_color = color.new(bull_color, 85)
zone_bear_color = color.new(bear_color, 85)

// Plot oscillator and signals
plot(oscillator, "Volume Profile Oscillator", main_color, 2)
plot(fast_signal, "Fast Signal", color.new(main_color, 40), 1)
plot(slow_signal, "Slow Signal", color.new(main_color, 70), 1)

// Plot adaptive midline
mid_line = plot(adaptive_midline, "Adaptive Midline", midline_color, 1, plot.style_line)

// Gradient fill for upper zone (bearish zone)
// Create multiple layers between upper_zone and midline with increasing transparency
// Upper zone gradient
upper_grad1 = plot(upper_zone, "Upper Zone", color.new(bear_color, 0), 1, plot.style_line)
upper_step = (upper_zone - adaptive_midline) / 10

upper_grad2 = plot(upper_zone - upper_step, "UG2", color.new(bear_color, 70), 1, plot.style_line)
fill(upper_grad1, upper_grad2, color.new(bear_color, 70))

upper_grad3 = plot(upper_zone - upper_step * 2, "UG3", color.new(bear_color, 75), 1, plot.style_line)
fill(upper_grad2, upper_grad3, color.new(bear_color, 75))

upper_grad4 = plot(upper_zone - upper_step * 3, "UG4", color.new(bear_color, 80), 1, plot.style_line)
fill(upper_grad3, upper_grad4, color.new(bear_color, 80))

upper_grad5 = plot(upper_zone - upper_step * 4, "UG5", color.new(bear_color, 83), 1, plot.style_line)
fill(upper_grad4, upper_grad5, color.new(bear_color, 83))

upper_grad6 = plot(upper_zone - upper_step * 5, "UG6", color.new(bear_color, 86), 1, plot.style_line)
fill(upper_grad5, upper_grad6, color.new(bear_color, 86))

upper_grad7 = plot(upper_zone - upper_step * 6, "UG7", color.new(bear_color, 89), 1, plot.style_line)
fill(upper_grad6, upper_grad7, color.new(bear_color, 89))

upper_grad8 = plot(upper_zone - upper_step * 7, "UG8", color.new(bear_color, 92), 1, plot.style_line)
fill(upper_grad7, upper_grad8, color.new(bear_color, 92))

upper_grad9 = plot(upper_zone - upper_step * 8, "UG9", color.new(bear_color, 95), 1, plot.style_line)
fill(upper_grad8, upper_grad9, color.new(bear_color, 95))

upper_grad10 = plot(upper_zone - upper_step * 9, "UG10", color.new(bear_color, 98), 1, plot.style_line)
fill(upper_grad9, upper_grad10, color.new(bear_color, 98))

fill(upper_grad10, mid_line, color.new(bear_color, 99))

// Lower zone gradient
lower_grad1 = plot(lower_zone, "Lower Zone", color.new(bull_color, 0), 1, plot.style_line)
lower_step = (adaptive_midline - lower_zone) / 10

lower_grad2 = plot(lower_zone + lower_step, "LG2", color.new(bull_color, 70), 1, plot.style_line)
fill(lower_grad1, lower_grad2, color.new(bull_color, 70))

lower_grad3 = plot(lower_zone + lower_step * 2, "LG3", color.new(bull_color, 75), 1, plot.style_line)
fill(lower_grad2, lower_grad3, color.new(bull_color, 75))

lower_grad4 = plot(lower_zone + lower_step * 3, "LG4", color.new(bull_color, 80), 1, plot.style_line)
fill(lower_grad3, lower_grad4, color.new(bull_color, 80))

lower_grad5 = plot(lower_zone + lower_step * 4, "LG5", color.new(bull_color, 83), 1, plot.style_line)
fill(lower_grad4, lower_grad5, color.new(bull_color, 83))

lower_grad6 = plot(lower_zone + lower_step * 5, "LG6", color.new(bull_color, 86), 1, plot.style_line)
fill(lower_grad5, lower_grad6, color.new(bull_color, 86))

lower_grad7 = plot(lower_zone + lower_step * 6, "LG7", color.new(bull_color, 89), 1, plot.style_line)
fill(lower_grad6, lower_grad7, color.new(bull_color, 89))

lower_grad8 = plot(lower_zone + lower_step * 7, "LG8", color.new(bull_color, 92), 1, plot.style_line)
fill(lower_grad7, lower_grad8, color.new(bull_color, 92))

lower_grad9 = plot(lower_zone + lower_step * 8, "LG9", color.new(bull_color, 95), 1, plot.style_line)
fill(lower_grad8, lower_grad9, color.new(bull_color, 95))

lower_grad10 = plot(lower_zone + lower_step * 9, "LG10", color.new(bull_color, 98), 1, plot.style_line)
fill(lower_grad9, lower_grad10, color.new(bull_color, 98))

fill(lower_grad10, mid_line, color.new(bull_color, 99))

// Bar coloring
barcolor(color_bars ? (is_bullish ? bull_color : bear_color) : na)
````
