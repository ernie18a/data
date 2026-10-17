# Custom MACD

- url: https://www.tradingview.com/script/L8IFlmPS-Custom-MACD/
- type: indicator
- pine_id: PUB;23df89c69fcf42b5b58c51de4a39ebbd
- version: 1.0

## Description

Custom MACD Histogram optimized for Top Dog Trading. This lightweight, optimized Pine Script v6 indicator modifies the classic MACD histogram to track pure momentum slope direction as taught in the Top Dog Trading methodologies.Standard MACD indicators switch colors based on whether the histogram is above or below the zero line. This version completely ignores the zero line, focus-firing instead on bar-by-bar acceleration and deceleration.Core Logic:Green Bars: Momentum is accelerating upward (current bar is higher than the previous bar).Red Bars: Momentum is accelerating downward (current bar is lower than the previous bar).Key Features:Fully compliant with Pine Script v6 syntax.Completely adjustable colors via user inputs to match light or dark chart styles.Ideal for filtering out counter-momentum entries and aligning trades with short-term energy shifts.

## Source Code

````pine
//@version=6
indicator("Top Dog Trading - MACD", shorttitle="TDT MACD Corrected", overlay=false)

// ==========================================
// INPUTS - Fully Adjustable Settings
// ==========================================
fast_length   = input.int(12, title="Fast EMA Length", minval=1)
slow_length   = input.int(26, title="Slow EMA Length", minval=1)
signal_length = input.int(9, title="Signal EMA Length", minval=1)
src           = input.source(close, title="Source Data")

// Customizable Color Inputs 
group_colors  = "Top Dog Histogram Colors"
color_momentum_up = input.color(color.green, title="Momentum Up (Slope Rising)", group=group_colors)
color_momentum_dn = input.color(color.red, title="Momentum Down (Slope Falling)", group=group_colors)

group_lines   = "Line Colors"
color_macd    = input.color(color.blue, title="MACD Line", group=group_lines)
color_signal  = input.color(color.orange, title="Signal Line", group=group_lines)

// ==========================================
// CALCULATIONS
// ==========================================
// Calculate standard MACD values
[macd_line, signal_line, hist_value] = ta.macd(src, fast_length, slow_length, signal_length)

// Pure Top Dog Course 2 Logic: Color based strictly on the direction of the slope
color hist_color = hist_value >= hist_value[1] ? color_momentum_up : color_momentum_dn

// ==========================================
// PLOTTING
// ==========================================
// Zero Reference Line
hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dashed)

// Histogram Bars (Thickness set to 3 for better readability)
plot(hist_value, title="Histogram", color=hist_color, style=plot.style_histogram, linewidth=3)

// MACD and Signal Lines (Fixed integer line widths)
plot(macd_line, title="MACD Line", color=color_macd, linewidth=2)
plot(signal_line, title="Signal Line", color=color_signal, linewidth=2)
````
